function [result, bgResult, mpResult] = compare_pa_outputs_for_regression(r1Pathname,r2Pathname,varargin)
%
% function [result, bgResult, mpResult] = compare_pa_outputs_for_regression(r1Pathname,r2Pathname,varargin)
%
% INPUTS:   r1Pathname      = path to data directory #1
%           r2Pathname      = path to data directory #2
%           varargin        = varargin{1} = numerical absolute tolerance
%
% OUTPUTS:  result      =   logical result of isequalStruct of invocationoutputsStructs; (nInvocations + 1)x1; [logical]
%           bgResult    =   logical result of background comparision 
%           mpResult    =   logical result of motion polynomial comparision 
%
% Compare the pa-outputs-# in two different directories, r1Pathname and r2Pathname.
% Tailor the sub-function clear_fields_from_outputsStruct to remove fields from 
% the outputsStructs which are not assumed to be equal.
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%



% initialize return arguments
result = [];
bgResult = [];
mpResult = [];

% define masks and filenames
paOutputMask = 'pa-outputs-*.mat';
paMotionFilename = 'pa_motion.mat';
paBackgroundFilename = 'pa_background.mat';
cadenceType = '';

% initialize default tolerance
% tolerance = 1e-10;
tolerance = 0;
if( nargin > 2 )
    tolerance = abs(varargin{1});
end

% read directories
outputFiles_r1 = dir([r1Pathname,paOutputMask]);
outputFiles_r2 = dir([r2Pathname,paOutputMask]);
fileList1 = {outputFiles_r1.name}';
fileList2 = {outputFiles_r2.name}';

% if the sets of outputs are not equal issue a warning message and exit
if( ~all(ismember(fileList1,fileList2)) )
    disp('WARNING: List of output files not identical.');
    return;
end
    
% if the sets of outputs are empty issue a warning message and exit
if( isempty(fileList1) )
    disp('WARNING: Output directories are empty.');
    return;
end

% % list output filenames found
% disp(r1Pathname);
% disp(fileList1);
% disp(' ');
% disp(r2Pathname);
% disp(fileList2);
% disp(' ');

% for each of the output files in fileList1 compare the outputsStruct to the 
% corresponding filename in fileList2
result =false(size(fileList1));
for iFile=1:length(fileList1)
    if( exist([r2Pathname,fileList1{iFile}],'file') )
        load([r1Pathname,fileList1{iFile}]);
        os1 = outputsStruct;
        load([r2Pathname,fileList1{iFile}]);
        os2 = outputsStruct;
        clear outputsStruct;

        os1 = clear_fields_from_outputsStruct(os1);
        os2 = clear_fields_from_outputsStruct(os2);
        
        if( isempty(cadenceType) )
            cadenceType = os1.cadenceType;
        end

        [result(iFile), badField] = isequalStruct(os1,os2,tolerance);

        if( result(iFile) )
            disp([r1Pathname,fileList1{iFile},' == ',r2Pathname,fileList1{iFile}]);
        else            
            disp([r1Pathname,fileList1{iFile},' <> ',r2Pathname,fileList1{iFile},' --- badField = ',badField]);
        end
    else
        disp([r2Pathname,fileList1{iFile},' does not exist.']);
    end
end

clear os1 os2;

mpResult = false;
bgResult = false;

% check motion polynomial fits on LC data
if( strcmpi(cadenceType,'LONG') )
    if( exist([r1Pathname,paMotionFilename],'file') && exist([r2Pathname,paMotionFilename],'file') )
        load([r1Pathname,paMotionFilename]);
        is1 = inputStruct;
        load([r2Pathname,paMotionFilename]);
        is2 = inputStruct;
        
        % fits should match within tolerance
        [mpResult, badField] = isequalStruct(is1,is2,tolerance);
        if( mpResult )
            disp([r1Pathname,paMotionFilename,' == ',r2Pathname,paMotionFilename]);
        else
            disp([r1Pathname,paMotionFilename,' <> ',r2Pathname,paMotionFilename,' --- badField = ',badField]);
        end
    else
        disp([paMotionFilename,' does not exist in one or both directories.']);
    end
end

% check background fits on LC data
if( strcmpi(cadenceType,'LONG') )
    if( exist([r1Pathname,paBackgroundFilename],'file') && exist([r2Pathname,paBackgroundFilename],'file') )
        load([r1Pathname,paBackgroundFilename]);
        is1 = inputStruct;
        load([r2Pathname,paBackgroundFilename]);
        is2 = inputStruct;
        
        % fits should match within tolerance
        [bgResult, badField] = isequalStruct(is1,is2,tolerance);
        if( mpResult )
            disp([r1Pathname,paBackgroundFilename,' == ',r2Pathname,paBackgroundFilename]);
        else
            disp([r1Pathname,paBackgroundFilename,' <> ',r2Pathname,paBackgroundFilename,' --- badField = ',badField]);
        end
    else
        disp([paBackgroundFilename,' does not exist in one or both directories.']);
    end
end


if( strcmpi(cadenceType,'LONG') && (all(result) && mpResult && bgResult) || (~strcmpi(cadenceType,'LONG') && all(result)) )
    disp([r1Pathname,' == ',r2Pathname]);
else
    disp([r1Pathname,' <> ',r2Pathname]);
end

end


function os = clear_fields_from_outputsStruct(os)
%
% Sub-function to clear fields from outputsStruct which are not assumed to be equal

% time field is run time so we never expect these to be equal
if( isfield(os,'alerts') )
    if( isfield(os.alerts,'time') )
        os.alerts = rmfield(os.alerts,'time');
    end
end

% SOC 8.1 V&V compares output from SOC 8.1 to 8.0
% There are no changes to the PA outputsStruct between 8.0 and 8.1
% There are no changes to the PA outputsStruct between 8.1 and 8.2

% % in outputs starting with SOC 8.0 only
% if( isfield(os,'reactionWheelZeroCrossingIndices') )
%     os = rmfield(os,'reactionWheelZeroCrossingIndices');
% end
% 
% 
% if( isfield(os,'targetStarResultsStruct') )
%     
%     % in outputs starting with SOC 8.0 only
%     if( isfield(os.targetStarResultsStruct,'pixelApertureStruct') )
%         os.targetStarResultsStruct = rmfield(os.targetStarResultsStruct,'pixelApertureStruct');
%     end
%     
%     % Have the prf centroids have changed between 7.0 and 8.0?
%     if( isfield(os.targetStarResultsStruct,'prfCentroids') )
%         os.targetStarResultsStruct = rmfield(os.targetStarResultsStruct,'prfCentroids');
%     end
% end

end

    
