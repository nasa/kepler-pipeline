function aggregate_dv_output_matrix_within_skygroup( dvMatlabPath )
%
%  This function aggregates the matrices dvOutputMatrixTarget of each target within a skygroup into a matrix dvOutputMatrixSkygroup.
%  The matrix dvOutputMatrixSkygroup and the cell array dvOutputMatrixColumns are saved in the file 'dvOutputMatrixSkygroup.mat'
%  under the user specified folder 'dvMatlabPath', which is in the format '~/dv-matlab-####-######'.
%
%  Version date:  2013-March-27.
%
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

%  Modification History:
%
%    2013-March-27, JL:
%        Initial release.
%
%=========================================================================================

% Define string pattern and names of the file to be saved and the failure log file
stString        = 'st-';
savedFileName   = fullfile(dvMatlabPath, 'dvOutputMatrixSkygroup.mat');
failureFileName = fullfile(dvMatlabPath, 'retrieve_dv_output_matrix_target_failures.txt');

fid = fopen(failureFileName, 'w');

dvOutputMatrixSkygroup = [];
dvOutputMatrixColumns  = [];

% The folder 'dvMatlabPath', in the format of ~/dv-matlab-####-######/ (#### is a four-digit run number and ###### is a six-digit task ID), is one level above the folders 'st-##'.
% The DV output matrices of different targets (dvOutputMatrixTarget) are saved in the files with the same name 'dvOutputMatrixTarget.mat' under different folders 'st-##'. 
% The aggregated matrix (dvOutputMatrixSkygroup) is saved in the file 'dvOutputMatrixSkygroup.mat' under dvMatlabPath.

dirStructs = dir(dvMatlabPath);
if ~isempty(dirStructs)
    
    nDirs = length(dirStructs);
    for iDir=1:nDirs
        
        dirName = dirStructs(iDir).name;
        index  = strfind(dirName, stString);
        if dirStructs(iDir).isdir && ~isempty(index)
            
            stNumber     = str2num(dirName( (index+length(stString)):end ));
            dataFileName = fullfile(dvMatlabPath, dirName, 'dvOutputMatrixTarget.mat');
            if exist(dataFileName, 'file')
                
                try
                    load(dataFileName);
                catch
                    fprintf(fid, ['Failed to load:       ' dataFileName '\n']);
                    continue;
                end
                
                if ~isempty(dvOutputMatrixTarget)
                    dvOutputMatrixTarget(:,114) = stNumber;
                    dvOutputMatrixSkygroup      = [dvOutputMatrixSkygroup; dvOutputMatrixTarget];
                end
            
            else
                
                fprintf(fid, ['File does not exist:  ' dataFileName '\n']);
               
            end
            
        end
        
    end
    
end

fclose(fid);

eval(['save ' savedFileName ' dvOutputMatrixSkygroup dvOutputMatrixColumns']);
