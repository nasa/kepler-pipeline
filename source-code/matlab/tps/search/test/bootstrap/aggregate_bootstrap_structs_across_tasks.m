function aggregate_bootstrap_structs_across_tasks( fullPathToTaskFiles, ...
    nSubdirsMax, saveToWorkingDir )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% handle optional arguments

if ~exist('nSubdirsMax','var') || isempty( nSubdirsMax )
    nSubdirsMax = inf ;
end
if ~exist('saveToWorkingDir','var') || isempty(saveToWorkingDir)
    saveToWorkingDir = false ;
end

% define the filename which is to be used for the save, a constant for now, and define the
% full path for saving the struct

saveFilenameBase   = 'bootstrap-struct' ; % root of the savename for the struct
saveErrorNameBase  = 'bootstrap-errors' ; % root for struct of target dawg errors
saveFilename       = saveFilenameBase ;
saveErrorName      = saveErrorNameBase ;

if ~saveToWorkingDir
    saveFilename   = fullfile(fullPathToTaskFiles,saveFilename) ;
    saveErrorName  = fullfile(fullPathToTaskFiles,saveErrorName) ;
end

targetFailureStruct = [] ;
outputStructTemplate = struct('nTransits', -1, 'nTrials', -1, 'duration', -1, ...
    'nCadences', -1, 'mesBins', -1, 'counts', -1, 'probSum', -1);
bootstrapStruct = outputStructTemplate;

% acquire the full list of subdirectories to topDir, removing the '.' and '..' instances

subdirList = get_list_of_subdirs( fullPathToTaskFiles ) ;

% toss out the logfile directory
subdirListCell = struct2cell(subdirList);
subdirListCell = subdirListCell(1,:);
subdirList(ismember(subdirListCell,'logfiles')) = [];

nDirs = min( nSubdirsMax, length(subdirList) ) ;

% loop over directories
firstOutputFilled = false;
for iDir = 1:nDirs

    disp( [' ... ', datestr(now), ...
        ':assembling Bootstrap information from ',subdirList(iDir).name, ...
        ' directory ...' ] ) ;
    try
        localBootstrapStructDir = dir( fullfile( fullPathToTaskFiles, subdirList(iDir).name, ...
            [saveFilenameBase,'*'] ) ) ;

        % if the file doesnt exist then the within-task aggregator failed
        % to run so run it now
        if isempty(localBootstrapStructDir)
            dirName = strcat(fullPathToTaskFiles,'/',subdirList(iDir).name) ;
            aggregate_bootstrap_structs_within_task( char(dirName),[],[]) ;
            localBootstrapStructDir = dir( fullfile( fullPathToTaskFiles, subdirList(iDir).name, ...
                [saveFilenameBase,'*'] ) ) ;
        end

        localBootstrapStructName = localBootstrapStructDir.name ;
        dummy = load( fullfile( fullPathToTaskFiles, subdirList(iDir).name, localBootstrapStructName ) ) ;
        localBootstrapStruct = dummy.bootstrapOutputStruct ;
        clear dummy ;

        nTransitsFull = [bootstrapStruct.nTransits];
        
        for iLocal = 1:length(localBootstrapStruct)
            nTransitIndicator = nTransitsFull == localBootstrapStruct(iLocal).nTransits;
            if any(nTransitIndicator)
                % we already have an output struct for this nTransits so
                % update it with the new information
                bootstrapStruct(nTransitIndicator).nTrials = ...
                    bootstrapStruct(nTransitIndicator).nTrials + localBootstrapStruct(iLocal).nTrials;
                bootstrapStruct(nTransitIndicator).counts = ...
                    bootstrapStruct(nTransitIndicator).counts + localBootstrapStruct(iLocal).counts;
                bootstrapStruct(nTransitIndicator).probSum = ...
                    bootstrapStruct(nTransitIndicator).probSum + localBootstrapStruct(iLocal).probSum;
            else
                % we dont have an output struct for this nTransits, so add a
                % new one and copy over the information
                if firstOutputFilled
                    outputIndex = length(nTransitsFull) + 1;
                else
                    outputIndex = 1;
                    firstOutputFilled = true;
                end
                bootstrapStruct(outputIndex) = outputStructTemplate;
                bootstrapStruct(outputIndex).nTransits = localBootstrapStruct(iLocal).nTransits;
                bootstrapStruct(outputIndex).nTrials = localBootstrapStruct(iLocal).nTrials;
                bootstrapStruct(outputIndex).duration = localBootstrapStruct(iLocal).duration;
                bootstrapStruct(outputIndex).nCadences = localBootstrapStruct(iLocal).nCadences;
                bootstrapStruct(outputIndex).mesBins = localBootstrapStruct(iLocal).mesBins;
                bootstrapStruct(outputIndex).counts = localBootstrapStruct(iLocal).counts;
                bootstrapStruct(outputIndex).probSum = localBootstrapStruct(iLocal).probSum;
            end
        end

        localErrorStructDir = dir( fullfile( fullPathToTaskFiles, subdirList(iDir).name, ...
            [saveErrorNameBase,'*'] ) ) ;
        localErrorStructName = localErrorStructDir.name ;
        dummy = load( fullfile( fullPathToTaskFiles, subdirList(iDir).name, localErrorStructName ) ) ;
        if ~isempty(dummy.targetFailureStruct(1).directory)
            targetFailureStruct = [targetFailureStruct ; dummy.targetFailureStruct] ;
        end

        clear dummy          
        clear localBootstrapStruct ;
        pause(1) ;

    catch

        thrownError = lasterror ;
        disp( ['    ... error aggregating Injection info, identifier == ', ...
            thrownError.identifier,', continuing to next sky group'] ) ;
    end

end % loop over directories

% perform the save

disp(' ... saving full-run Bootstrap struct ... ' ) ;
intelligent_save( saveFilename, 'bootstrapStruct' ) ;
disp(' ... saving full-run target error struct ... ') 
intelligent_save( saveErrorName, 'targetFailureStruct' ) ;

return
