function L = get_background_binary_source_offsets_from_dv_results(root,taskDirectoryList)

% function L = get_background_source_offsets_from_dv_results(root,taskDirectoryList)
%
% This function supports SOC 6.1 DV Verification and Validation testing.
%
% This function accepts a root directory name and an array of matlab
% directory structures containing DV task file directory names. These each
% contain a .mat file with the DV output. It produces a structure 
% containing the the Kepler Id for each associated target plus results from
% the centroid test for each planet fit produced by the fitter.
%
% INPUT:    root                = root directory containing task file directories.
%                                 May be empty string. (string)
%           taskDirectoryList   = array of matlab directory structures
%                                 where each element contains a name field,
%                                 e.g.
%                                   taskDirectoryList(1).name
%               
% OUTPUT:   L                   = array of output structures containing the following
%                                 fields:
%               keplerId        = Kepler ID of associated target star
%               
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

% hard coded constants
MAXTARGETS = 10000;


fs = filesep;

if(strcmp(root,''))
    % default root directory
    root='/path/to/etem/q2/i101/';
end

dvOutputFilename = 'dv-outputs-0.mat';

% allocate space for output
L = repmat(struct('keplerId',[],...
                    'taskDirName',[],...
                    'sourceRowOffsetFW',[],...
                    'sourceRowOffsetUncFW',[],...
                    'sourceColOffsetFW',[],...
                    'sourceColOffsetUncFW',[],...                    
                    'motionStatisticFW',[],...
                    'significanceFW',[],...
                    'sourceRowOffsetPRF',[],...
                    'sourceRowOffsetUncPRF',[],...
                    'sourceColOffsetPRF',[],...
                    'sourceColOffsetUncPRF',[],...
                    'motionStatisticPRF',[],...
                    'significancePRF',[]),...
                    MAXTARGETS,1);

index = 0;

% step through task file list
for i=1:length(taskDirectoryList)    
  
    if( exist([root,taskDirectoryList(i).name,fs,dvOutputFilename],'file') )
        
        outputString = [num2str(i),'---',root,taskDirectoryList(i).name,filesep,dvOutputFilename];
        disp(outputString);
            
        % load dv output struct:
        load([root,taskDirectoryList(i).name,fs,dvOutputFilename]);

        % step through targets
        for j=1:length(outputsStruct.targetResultsStruct)
            index = index + 1;

            L(index).keplerId = outputsStruct.targetResultsStruct(j).keplerId;
            L(index).taskDirName = taskDirectoryList(i).name;

            C = [outputsStruct.targetResultsStruct(j).planetResultsStruct.centroidResults];

            % step through planets
            for k=1:length(C)

                L(index).sourceRowOffsetFW(k)       = C(k).fluxWeightedMotionResults.sourceRowOffset.value;
                L(index).sourceRowOffsetUncFW(k)    = C(k).fluxWeightedMotionResults.sourceRowOffset.uncertainty;
                L(index).sourceColOffsetFW(k)       = C(k).fluxWeightedMotionResults.sourceColumnOffset.value;
                L(index).sourceColOffsetUncFW(k)    = C(k).fluxWeightedMotionResults.sourceColumnOffset.uncertainty;
                L(index).motionStatisticFW(k)       = C(k).fluxWeightedMotionResults.motionDetectionStatistic.value;
                L(index).significanceFW(k)          = C(k).fluxWeightedMotionResults.motionDetectionStatistic.significance;
                
                L(index).sourceRowOffsetPRF(k)      = C(k).prfMotionResults.sourceRowOffset.value;
                L(index).sourceRowOffsetUncPRF(k)   = C(k).prfMotionResults.sourceRowOffset.uncertainty;
                L(index).sourceColOffsetPRF(k)      = C(k).prfMotionResults.sourceColumnOffset.value;
                L(index).sourceColOffsetUncPRF(k)   = C(k).prfMotionResults.sourceColumnOffset.uncertainty;                
                L(index).motionStatisticPRF(k)      = C(k).prfMotionResults.motionDetectionStatistic.value;
                L(index).significancePRF(k)         = C(k).prfMotionResults.motionDetectionStatistic.significance;
                
            end
        end
    end
end


if(index>0)
    % trim output structure
    L = L(1:index);
else
    % return single element array with empty structure
    L = L(1);
end



 