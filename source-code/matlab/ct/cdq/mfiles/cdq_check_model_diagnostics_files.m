function cdqInputStruct = cdq_check_model_diagnostics_files(cdqInputStruct)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function cdqInputStruct = cdq_check_model_diagnostics_files(cdqInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This function checks for the existence of model files and diagnostics files
% under the user specified BART output directory. If there are unique model
% file and diagnostics file, get the file names and save them in cdqInputStruct.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
% check for the existence of BART output directory
%______________________________________________________________________
bartOutputDir = cdqInputStruct.bartOutputDir;
if( ~exist(bartOutputDir, 'dir') )

    error('CDQ:checkModelDiagnosticsFiles', 'BART output directory not found');

end

%______________________________________________________________________
% check for the existence of BART run directories
%______________________________________________________________________
runDirNames = dir([ bartOutputDir 'run_*']);
nRunDirs    = length(runDirNames);
if ( nRunDirs==0 )
    error('CDQ:checkModelDiagnosticsFiles', 'No run directories under the specified bart output directory.');
end

%______________________________________________________________________
% check for the existence of model directory and diagnostics directory
% under BART run directories
%______________________________________________________________________
for i=1:nRunDirs
    modelDir        = [bartOutputDir runDirNames(i).name '/model'];
    diagnosticsDir  = [bartOutputDir runDirNames(i).name '/diagnostics'];
    if( ~exist(modelDir, 'dir') || ~exist(diagnosticsDir, 'dir'))

        error('CDQ:checkModelDiagnosticsFiles', ['No model or diagnostics directory under ' runDirNames(i).name]);
        
    end
end

% Allocate memory
nModOuts = cdqInputStruct.fcConstantsStruct.MODULE_OUTPUTS;
diagnosticFileAvailable = false(nModOuts,1);
diagnosticFileNames     = cell(nModOuts,1);
modelFileAvailable      = false(nModOuts,1);
modelFileNames          = cell(nModOuts,1);

for j = 1:nModOuts

    [mod, out] = convert_to_module_output(j);

    %______________________________________________________________________
    % check for the existence of model file for each module/output
    % If there is unique model file, get the file name
    %______________________________________________________________________
    k = 0;
    for i=1:nRunDirs
        
        fileName = dir( [bartOutputDir '/' runDirNames(i).name '/model/bart_mod' num2str(mod) '_out' num2str(out) '_*_model.mat']);
        if (~isempty(fileName))
            if ( length(fileName)==1 )
                k = k + 1;
                runIndex = i;
                fileNameStr = fileName.name;
            else
                k = k + 2;
            end
        end
        
    end
    
    if ( k==0 )
        warning('CDQ:checkModelDiagnosticsFiles', ['No model file found for module ' num2str(mod) ' output ' num2str(out)]);
    elseif ( k>1 )
        warning('CDQ:checkModelDiagnosticsFiles', ['More than one model files found for module ' num2str(mod) ' output ' num2str(out)]);
    else
        modelFileAvailable(j) = true;
        modelFileNames{j}     = [bartOutputDir runDirNames(runIndex).name '/model/' fileNameStr];
    end

    %______________________________________________________________________
    % check for the existence of diagnostics file for each module/output
    % If there is unique diagnostics file, get the file name
    %______________________________________________________________________
    
    k = 0;
    for i=1:nRunDirs
        
        fileName = dir( [bartOutputDir '/' runDirNames(i).name '/diagnostics/bart_mod' num2str(mod) '_out' num2str(out) '_*_diagnostics.mat']);
        if (~isempty(fileName))
            if ( length(fileName)==1 )
                k = k + 1;
                runIndex = i;
                fileNameStr = fileName.name;
            else
                k = k + 2;
            end
        end
        
    end
    
    if ( k==0 )
        warning('CDQ:checkModelDiagnosticsFiles', ['No diagnostics file found for module ' num2str(mod) ' output ' num2str(out)]);
    elseif ( k>1 )
        warning('CDQ:checkModelDiagnosticsFiles', ['More than one diagnostics files found for module ' num2str(mod) ' output ' num2str(out)]);
    else
        diagnosticFileAvailable(j) = true;
        diagnosticFileNames{j}     = [bartOutputDir runDirNames(runIndex).name '/diagnostics/' fileNameStr];
    end

end

% Save the results in cdqInputStruct
cdqInputStruct.modelFileNames           = modelFileNames;
cdqInputStruct.modelFileAvailable       = modelFileAvailable;

cdqInputStruct.diagnosticFileNames      = diagnosticFileNames;
cdqInputStruct.diagnosticFileAvailable  = diagnosticFileAvailable;

return
