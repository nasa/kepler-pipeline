function L = get_background_binary_location_from_ground_truth(root,taskDirectoryList)

% function L = get_background_binary_location_from_ground_truth(root,taskDirectoryList)
%
% This function supports SOC 6.1 DV Verification and Validation testing.
%
% This function accepts a root directory name and an array of matlab
% directory structures containing DV task file directory names. These each
% contain a .mat file with the DV ground truth from ETEM. It produces a 
% structure containing the the Kepler Id for each associated target and 
% the absolute row and column location of the target and any associated
% background binaries. Offsets of the background binaries are calculated
% as backgroundBinaryLocation - targetLocation for each background binary.
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
%               taskDirName     = task file directory name containing the
%                                 ground truth
%               targetRow       = target row from ground truth including
%                                 fractional part
%               targetCol       = target column from ground truth including
%                                 fractional part
%               backgroundBinaryRow     = array of background binary rows from 
%                                         ground truth including fractional part.
%                                         One entry for each background
%                                         binary associated with this
%                                         target.
%               backgroundBinaryCol     = array of background binary columnss from 
%                                         ground truth including fractional part.
%                                         One entry for each background
%                                         binary associated with this
%                                         target.
%               offsetRow               = array of offset rows
%                                         (background - target)
%                                         
%               offsetCol               = array of offset columns
%                                         (background - target)
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

groundTruthFilename = 'dv-ground-truth.mat';

% allocate space for output
L = repmat(struct('keplerId',[],...
                    'taskDirName',[],...
                    'targetRow',[],...
                    'targetCol',[],...
                    'backgroundBinaryRow',[],...
                    'backgroundBinaryCol',[],...
                    'offsetRow',[],...
                    'offsetCol',[]),...
                    MAXTARGETS,1);

index = 0;

% step through task file list
for i=1:length(taskDirectoryList)
    
    outputString = [num2str(i),'---',root,taskDirectoryList(i).name];
    
    if( exist([root,taskDirectoryList(i).name,fs,groundTruthFilename],'file') )
        
        outputString = [outputString,filesep,groundTruthFilename];                                              %#ok<AGROW>
                
        
        % load ground truth variables:
        %   dvTargetList
        %   dvBackgroundBianaryList
        load([root,taskDirectoryList(i).name,fs,groundTruthFilename]);


        % step through background binary list
        for j=1:length(dvBackgroundBinaryList)

            keplerId = dvBackgroundBinaryList(j).targetKeplerId;

            inListIdx = find([L.keplerId]==keplerId);

            if(~isempty(inListIdx))
                index = inListIdx;
            else
                index = index + 1;

                targetIdx = find([dvTargetList.keplerId]==keplerId);            

                L(index).keplerId = keplerId;
                L(index).taskDirName = taskDirectoryList(i).name;
                L(index).targetRow = dvTargetList(targetIdx).row + (0.1)*dvTargetList(targetIdx).rowFraction;
                L(index).targetCol = dvTargetList(targetIdx).column + (0.1)*dvTargetList(targetIdx).columnFraction;
            end


            L(index).backgroundBinaryRow = ...
                [L(index).backgroundBinaryRow, dvBackgroundBinaryList(j).initialData.data.row + ...
                    (0.1)*dvBackgroundBinaryList(j).initialData.data.subRow];

            L(index).backgroundBinaryCol = ...
                [L(index).backgroundBinaryCol, dvBackgroundBinaryList(j).initialData.data.column + ...
                    (0.1)*dvBackgroundBinaryList(j).initialData.data.subCol];
        end    

        % compute ground truth offset
        L(index).offsetRow = L(index).backgroundBinaryRow - L(index).targetRow;
        L(index).offsetCol = L(index).backgroundBinaryCol - L(index).targetCol;
    end

    disp(outputString);
    
end

if(index>0)
    % trim output structure
    L = L(1:index);
else
    % return single element array with empty structure
    L = L(1);
end


 