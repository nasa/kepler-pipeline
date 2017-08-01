% the main controller for estimating CCD bias and dark
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

% Top level controller for CCD Bias and Dark Tool
% Author: Gary Zhang
% Date: April 3rd, 2008

%% Defining Constants Section
% load the constants
constants;

%% IO Variables Section
% allocate the input and output variables
io_variables;


%% Main Loop Section

% set the time stamp
runStartMjd = datestr2mjd('July 1 2010');
runEndMjd = runStartMjd + 1;

% get the configuration information for data validation
[status, dataConfig] = retrieve_cbd_config();

% get the pre-flight bias and dark models
[status, dataModels] = retrieve_cbd_models(runStartMjd, runEndMjd);
        
% the parameters used
procParams = cbdtParams();

% debug
nMods = 1;
nOuts = 1;

%%
% loop each of the module output
for iMods = 1:nMods

    % the current module output index
    modIdx = IDX_MOD_OUTS(iMods);
    
    for iOuts = 1:nOuts

        %% Inner Loop Section
        fprintf('Module %2d, Output: %2d\n', modIdx, iOuts );

        % get the data from sandbox and files
        [status, dataInputs] = retrieve_cbd_images();
        

        
        % check data validaty
        [status, dataState] = valilate_cbd_data(dataInputs, dataConfig);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % get the FFI images
        % status = set_image_source(dataInputs, '');
        % status = retrieve_images(dataInputs, modIdx, outIdx);
        % [status, dataCompleteness] = validate_data(dataFFIs, dataConfig);
        
        % get the models
        % status = set_model(cbdModels, modIdx, outIdx);
        % status = retrieve_models(cbdModels);
        % status = prefetch_models(cbdModels, '');
        
        % measurements
        % status = measure_black(cbdBlack, cbdFFIs);
        % status = compare_black(cbdBlack, cbdModels);
        
        % status = measure_collateral(cbdCollateral, cbdFFIs);
        % status = compare_collateral(cbdCollateral, cbdModels);
        


        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % process each module output
        [status, dataResults] = compute_cbd_statistics(dataInputs, procParams);

        % output results to sandbox and files
        [status] = save_cbd_results(dataResults);
        
    end % end of output loop
    
end % end of module loop
