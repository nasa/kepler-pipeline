function [dvTargetList, dvBackgroundBinaryList] = retrieve_ground_truth(dvInputStruct, etemDirectory)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvTargetList, dvBackgroundBinaryList] = retrieve_ground_truth(dvInputStruct, etemDirectory)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Retrieve ground truth data related to target stars of the DV input struture from the ETEM output directory.
%
% Inputs:
%   dvInputStruct               DV input structure.
%   etemDiectory                ETEM output directory. Under etemDirectory there should be one or several directories in the format of 
%                               'run_long_m&o$s1' (& and $ are module and output numbers respectively), under which the data files
%                               'scienceTargetList.mat' and 'targetScienceManagerData.mat' are stored.
% Outputs:
%   dvTargetList                A subset of targetList in scienceTargetList.mat. The subset includes all target stars of dvInputStruct
%                               in the targetList. dvTargetList is an empty structure when no target stars of dvInputStruct are found
%                               in the targetList.
%   dvBackgroundBinaryList      A subset of backgroundBinaryList in targetScienceManagerData.mat. The subset includes all target stars 
%                               of dvInputStruct in the backgroundBinaryList. dvBackgroundBinaryList is an empty structure when no 
%                               target stars are found in the backgroundBinaryList.
%                               
%
% Example:
% [dvTargetList, dvBackgroundBinaryList] = retrieve_ground_truth(dvInputStruct, '/path/to/etem/q2/etem/')
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Define the run_long_m&o$s1 directory based on the module/output numbers in dvInputStruct.targetTableDataStruct
module           = dvInputStruct.targetTableDataStruct.ccdModule;
output           = dvInputStruct.targetTableDataStruct.ccdOutput;
runLongDirectory = ['run_long_m' num2str(module) 'o' num2str(output) 's1'];

% Get number of target stars of dvInputStruct
nDvTargets = length(dvInputStruct.targetStruct);

% Get keplerIds of target stars of dvInputStruct
dvKeplerIds = [dvInputStruct.targetStruct.keplerId];

% Retrieve scienceTargetList.mat from the run_long_m&o$s1 directory
scienceTargetListFilename = fullfile(etemDirectory, runLongDirectory, 'scienceTargetList.mat');
if exist(scienceTargetListFilename, 'file') 
    
    % Load scienceTargetList.mat when it exists
    load(scienceTargetListFilename);
    
    % Get keplerIds of targetList in scienceTargetList.mat
    targetKeplerIds = [targetList.keplerId];
    
    % Search for target stars of dvInputStruct in the targetList and generate the subset dvTargetList.
    targetCount = 0;
    for i=1:nDvTargets
        targetIndex = find(dvKeplerIds(i)==targetKeplerIds);
        if length(targetIndex)==1
            targetCount =  targetCount + 1;
            dvTargetList(targetCount) = targetList(targetIndex);
        else
            disp(['No match for keplerId ' num2str(dvKeplerIds(i)) ' when retrieving target list'])
        end
    end

    % dvTargetList is set to empty structure when no target stars of dvInputStruct are found in the targetList
    if targetCount==0
        dvTargetList = struct([]);
    end

else
    
    % When scienceTargetList.mat does not exist, dvTargetList is set to empty structure.
    disp([scienceTargetListFilename ' does not exist. dvTargetList is set to empty structure.'])
    dvTargetList = struct([]);
    
end

% Retrieve targetScienceManagerData.mat from the run_long_m&o$s1 directory
targetScienceManagerDataFilename = fullfile(etemDirectory, runLongDirectory, 'targetScienceManagerData.mat');
if exist(targetScienceManagerDataFilename, 'file') 
    
    % Load targetScienceManagerData.mat when it exists
    load(targetScienceManagerDataFilename);

    % Get keplerIds of backgroundBinaryList in targetScienceManagerData.mat
    bkBinaryKeplerIds = [targetScienceManagerData.backgroundBinaryList.targetKeplerId];

    % Search for target stars of dvInputStruct in the backgroundBinaryList and generate the subset dvBackgroundBinaryList.
    bkBinaryCount = 0;
    for j=1:nDvTargets
        bkBinaryIndex = find(dvKeplerIds(j)==bkBinaryKeplerIds);
        if length(bkBinaryIndex)==1
            bkBinaryCount = bkBinaryCount + 1;
            dvBackgroundBinaryList(bkBinaryCount) = targetScienceManagerData.backgroundBinaryList(bkBinaryIndex);
        end
    end

    % dvBackgroundBinaryList is empty when no target stars of dvInputStruct are found in the backgroundBinaryList
    if bkBinaryCount==0
        dvBackgroundBinaryList = struct([]);
    end

else
    
    % When targetScienceManagerData.mat does not exist, dvBackgroundBinaryList is set to empty structure.
    disp([targetScienceManagerDataFilename ' does not exist. dvBackgroundBinaryList is set to empty structure.'])
    dvBackgroundBinaryList = struct([]);

end

return

