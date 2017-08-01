function tcatInputDataStruct = validate_tcat_input_struct(tcatInputDataStruct)
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




%______________________________________________________________________
% validate the structure field  fcConstantsStruct in tcatInputStruct
%______________________________________________________________________
% read from FcConstants, change the hard coded constants, okay to leave
% the hard coded constants

fieldsAndBounds = cell(9,4);
fieldsAndBounds(1,:)  = { 'nRowsImaging'; '== 1024'; []; []};
fieldsAndBounds(2,:)  = { 'nColsImaging'; '== 1100'; []; []};
fieldsAndBounds(3,:)  = { 'nLeadingBlack'; '==12'; []; []};
fieldsAndBounds(4,:)  = { 'nTrailingBlack'; '==20'; []; []};
fieldsAndBounds(5,:)  = { 'nVirtualSmear'; '==26'; []; []};
fieldsAndBounds(6,:)  = { 'nMaskedSmear'; '== 20'; []; []};
fieldsAndBounds(7,:)  = { 'CCD_ROWS'; '== 1070'; []; []};
fieldsAndBounds(8,:)  = { 'CCD_COLUMNS'; '== 1132'; []; []};
fieldsAndBounds(9,:)  = { 'MODULE_OUTPUTS'; '== 84'; []; []};




validate_structure(tcatInputDataStruct.fcConstantsStruct, fieldsAndBounds, 'tcatInputDataStruct.fcConstantsStruct');

% also check for the size of black2DModel as it has to be [1070x1132 double]

clear fieldsAndBounds;

%______________________________________________________________________
% check for the existence of this cross talk image in input validation
%______________________________________________________________________

if(~exist(tcatInputDataStruct.xTalkFitsFileName, 'file'))
    error('TCAT:MissingCrossTalkFitsFile', ...
        'validate_tcat_input_struct: Unable to locate cross talk fits file; can''t proceed any further; quitting TCAT ....');
end

%______________________________________________________________________
% check for the existence of directories and .mat files
%______________________________________________________________________


if(~exist(tcatInputDataStruct.runDir, 'dir'))

    error('TCAT:MissingDirectoy', ...
        ['validate_tcat_input_struct: directory ' runDir ' not found']);

end


dirNames = eval(['dir(''' tcatInputDataStruct.runDir '/run*'')']);

dirNames = {dirNames.name}';

nRunDir = length(dirNames);

for j = 1:nRunDir

    if(~exist([tcatInputDataStruct.runDir '/' dirNames{j} '/model' ], 'dir') && ...
            ~exist([tcatInputDataStruct.runDir '/' dirNames{j} '/diagnostics' ], 'dir'))

        error('TCAT:MissingModelDirectories', ...
            ['validate_tcat_input_struct: Both BART Model directory and BART Diagnostics directory not found under '  tcatInputDataStruct.runDir '/' dirNames{j} ] );

    end
    if(~exist([tcatInputDataStruct.runDir '/' dirNames{j} '/model' ], 'dir') )

        error('TCAT:MissingModelDirectories', ...
            ['validate_tcat_input_struct: BART Model directory not found under '  tcatInputDataStruct.runDir '/' dirNames{j} ] );

    end
    if( ~exist([tcatInputDataStruct.runDir '/' dirNames{j} '/diagnostics' ], 'dir'))

        error('TCAT:MissingDiagnosticsDirectories', ...
            ['validate_tcat_input_struct:BART Diagnostics directory not found under '  tcatInputDataStruct.runDir '/' dirNames{j} ] );

    end

end
nModOuts = tcatInputDataStruct.fcConstantsStruct.MODULE_OUTPUTS;

diagnosticFileAvailable = false(nModOuts,1);
diagnosticFileNames     = cell(nModOuts,1);
modelFileAvailable      = false(nModOuts,1);
modelFileNames          = cell(nModOuts,1);



for j = 1:nModOuts


    [module, output] = convert_to_module_output(j);
    % date str unknown - so use wildcard character to look for the
    % diagnostics mat file for this module and output




    for k = 1:nRunDir
        diagnosticsDir = [tcatInputDataStruct.runDir '/' dirNames{k} '/diagnostics'];
        diagnosticsMatFileName = dir([ diagnosticsDir '/bart_mod' num2str(module) '_out' num2str(output) '*_diagnostics.mat']);
        if(~isempty(diagnosticsMatFileName))
            break;
        end
    end

    if(isempty(diagnosticsMatFileName))
        warning('TCAT:MissingDiganosticMatFileForModOut', ...
            ['validate_tcat_input_struct: diagnostic .mat file missing for module ' num2str(module)  ', output ' num2str(output)']);
        % there should be only one file with that name
    elseif(length(diagnosticsMatFileName) > 1)
        % throw a warning.. or move this to input validation
        warning('TCAT:TooManyDiganosticMatFilesForOneModOut', ...
            ['validate_tcat_input_struct: more than one diagnostic .mat file for module ' num2str(module)  ', output ' num2str(output)']);
    else
        diagnosticFileAvailable(j) = true;
        diagnosticFileNames{j}  = fullfile(diagnosticsDir, diagnosticsMatFileName.name);
    end



    for k = 1:nRunDir
        modelDir = [tcatInputDataStruct.runDir '/' dirNames{k} '/model'];
        modelMatFileName = dir([ modelDir '/bart_mod' num2str(module) '_out' num2str(output) '*_model.mat']);
        if(~isempty(modelMatFileName))
            break;
        end
    end


    if(isempty(modelMatFileName))
        warning('TCAT:MissingModelMatFileForModOut', ...
            ['validate_tcat_input_struct: model .mat file missing for module ' num2str(module)  ', output ' num2str(output)']);
        % there should be only one file with that name
    elseif(length(modelMatFileName) > 1)
        % throw a warning.. or move this to input validation
        warning('TCAT:TooManyModelMatFilesForOneModOut', ...
            ['validate_tcat_input_struct: more than one model .mat file for module ' num2str(module)  ', output ' num2str(output)']);
    else
        modelFileAvailable(j) = true;
        modelFileNames{j}  = fullfile(modelDir, modelMatFileName.name);
    end

end


tcatInputDataStruct.modelFileNames = modelFileNames;
tcatInputDataStruct.modelFileAvailable = modelFileAvailable;


tcatInputDataStruct.diagnosticFileNames = diagnosticFileNames;
tcatInputDataStruct.diagnosticFileAvailable = diagnosticFileAvailable;

tcatInputDataStruct.nHistogramBins = 50;



return
