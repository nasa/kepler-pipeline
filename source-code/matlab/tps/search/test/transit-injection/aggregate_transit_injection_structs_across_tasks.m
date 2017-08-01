function aggregate_transit_injection_structs_across_tasks( fullPathToTaskFiles, ...
    nSubdirsMax, saveToWorkingDir )
%
% aggregate_transit_injection_structs_across_tasks( fullPathToTaskFiles, ...
%    nSubdirsMax, saveToWorkingDir )
%
%
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

saveFilenameBase   = 'tps-injection-struct' ; % root of the savename for the struct
saveErrorNameBase  = 'tps-injection-errors' ; % root for struct of target dawg errors
saveFilename       = saveFilenameBase ;
saveErrorName      = saveErrorNameBase ;

if ~saveToWorkingDir
    saveFilename   = fullfile(fullPathToTaskFiles,saveFilename) ;
    saveErrorName  = fullfile(fullPathToTaskFiles,saveErrorName) ;
end

firstFileParsed = false ;
targetFailureStruct = [] ;

% acquire the full list of subdirectories to topDir, removing the '.' and '..' instances

subdirList = get_list_of_subdirs( fullPathToTaskFiles ) ;

% toss out the logfile directory
subdirListCell = struct2cell(subdirList);
subdirListCell = subdirListCell(1,:);
subdirList(ismember(subdirListCell,'logfiles')) = [];

nDirs = min( nSubdirsMax, length(subdirList) ) ;

% loop over directories

for iDir = 1:nDirs

    disp( [' ... ', datestr(now), ...
        ':assembling TPS Injection information from ',subdirList(iDir).name, ...
        ' directory ...' ] ) ;
    parsedInjFile = false ;
    try
        localInjectionStructDir = dir( fullfile( fullPathToTaskFiles, subdirList(iDir).name, ...
            [saveFilenameBase,'*'] ) ) ;

        % if the file doesnt exist then the within-task aggregator failed
        % to run so run it now
        if isempty(localInjectionStructDir)
            dirName = strcat(fullPathToTaskFiles,'/',subdirList(iDir).name) ;
            aggregate_transit_injection_structs_within_task( char(dirName),[],[]) ;
            localInjectionStructDir = dir( fullfile( fullPathToTaskFiles, subdirList(iDir).name, ...
                [saveFilenameBase,'*'] ) ) ;
        end

        localInjectionStructName = localInjectionStructDir.name ;
        dummy = load( fullfile( fullPathToTaskFiles, subdirList(iDir).name, localInjectionStructName ) ) ;
        localInjectionStruct = dummy.injectionOutputStruct ;
        clear dummy ;

%       if this is the first task, then we can construct the tpsDawgStruct with all
%       appropriate fields -- all the standard fields except for pulseDurations and
%       unitOfWorkKjd, plus we need to put topDir into position

        if ~firstFileParsed

            injFieldNames = fieldnames( localInjectionStruct ) ;
            tpsInjectionStruct.topDir = fullPathToTaskFiles ;
            for iField = 1:length( injFieldNames )
                tpsInjectionStruct.(injFieldNames{iField}) = ...
                    localInjectionStruct.(injFieldNames{iField}) ;
            end
            firstFileParsed = true ;

        else % on subsequent passes, we can simply concatenate the appropriate fields

            for iField = 1:length( injFieldNames ) 
                thisFieldName = injFieldNames{iField} ;
                tpsInjectionStruct.(thisFieldName) = [tpsInjectionStruct.(thisFieldName) ; ...
                    localInjectionStruct.(thisFieldName)] ;
            end
            
            parsedInjFile = true ;

        end % conditional on iDir == 1

        localErrorStructDir = dir( fullfile( fullPathToTaskFiles, subdirList(iDir).name, ...
            [saveErrorNameBase,'*'] ) ) ;
        localErrorStructName = localErrorStructDir.name ;
        dummy = load( fullfile( fullPathToTaskFiles, subdirList(iDir).name, localErrorStructName ) ) ;
        if ~isempty(dummy.targetFailureStruct(1).directory)
            targetFailureStruct = [targetFailureStruct ; dummy.targetFailureStruct] ;
        end



        clear dummy          
        clear localInjectionStruct ;
        pause(1) ;

    catch

        thrownError = lasterror ;
        if parsedInjFile
            disp( ['    ... error aggregating target failure info, identifier == ', ...
                thrownError.identifier,', continuing to next sky group'] ) ;
        else
            disp( ['    ... error aggregating Injection info, identifier == ', ...
                thrownError.identifier,', continuing to next sky group'] ) ;
        end

    end

end % loop over directories

% perform the save

disp(' ... saving full-run Injection struct ... ' ) ;
%  save( saveFilename, 'tpsDawgStruct', 'unitOfWork', 'pulseLengths', '-v7.3' ) ;
intelligent_save( saveFilename, 'tpsInjectionStruct' ) ;
disp(' ... saving full-run target error struct ... ') 
%  save( saveErrorName, 'targetFailureStruct', '-v7' ) ;
intelligent_save( saveErrorName, 'targetFailureStruct' ) ;

return


% load tps-injection-struct
% load tps-injection-struct2
% fieldNames = fieldnames( tpsInjectionStruct ) ;
% fieldNames=fieldNames(1:(end-2));
% taskfile=tpsInjectionStruct.taskfile;
% taskfile=[taskfile; tpsInjectionStruct2.taskfile];
% for j=1:length(fieldNames)
%     thisFieldName = fieldNames{j};
%     injResults.(thisFieldName) = [tpsInjectionStruct.(thisFieldName);tpsInjectionStruct2.(thisFieldName)];
% end
% injResults.taskfile = taskfile;
% injResults.topDir = tpsInjectionStruct.topDir;
% intelligent_save( 'injResults.mat', 'injResults' ) ;
