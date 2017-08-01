function dynablackResultsStruct = initialize_dynablack_results(dynablackObject)
% function dynablackResultsStruct = initialize_dynablack_results(dynablackObject)
% 
% This dynablackClass method creates the results structure for dynablack and seeds it with default values. Th flag validDynablackFit is
% initialized to false then updated true based on results of fitting routines.
%
% INPUTS:   dynablackObject         = dynablackClass object
% OUTPUTS:  dynablackResultsStruct  = results structure for dynablack
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


% get channel descriptors
ccdModule = dynablackObject.ccdModule;
ccdOutput = dynablackObject.ccdOutput;
channel   = convert_from_module_output(ccdModule,ccdOutput);
validUow  = dynablackObject.validUow;
pulseDuration = rowvec(dynablackObject.rbaFlagConfigurationStruct.testPulseDurations);
nDurations = length(pulseDuration);

% extract row count for ccd
nCcdRows = dynablackObject.fcConstants.CCD_ROWS;

% get UOW descriptor
cadenceTimes = dynablackObject.cadenceTimes;
nCadences = length(cadenceTimes.cadenceNumbers);

% get dynablack configuration
dynablackModuleParameters = dynablackObject.dynablackModuleParameters;

% get otuput blob filename
dynablackBlobFilename = dynablackModuleParameters.dynablackBlobFilename;

% get instrument configuration
requantTableObject = requantTableClass(dynablackObject.requantTables);
meanBlackTable = get_mean_black_table(requantTableObject);

% get static 2D black - nCcdRows x nCcdColumns
twoDBlackObject = twoDBlackClass(dynablackObject.twoDBlackModel);
staticTwoDBlackImage = get_two_d_black(twoDBlackObject);


% setup empty results struct
A1_fit_results = struct('channel_number', channel,...
                        'LC', [],...
                        'FFI', []);

A1_fit_residInfo = struct('channel_number', channel,...
                            'LC', [],...
                            'FFI', []);
                        
A1ModelDump = struct('FCLC_Model', [],...
                        'FFI_Model', [],...
                        'rowsModelLinearRows', [],...
                        'ROI', [],...
                        'Inputs', [],...
                        'Constants', []);

A2_fit_results = struct('coeffs_and_errors_xRC', [],...
                        'smearCoeffs_and_errors_xLC', [],...
                        'fit_results', []);

A2_fit_residInfo = struct('residuals_xRC', [],...
                            'smearResiduals_xLC', []);
                        
A2ModelDump = struct('Inputs', [],...
                        'Constants', [],...
                        'RCLC_Model', [],...
                        'FCLC_Model', [],...
                        'ROI', [],...
                        'RCLC_spatial_model', [],...
                        'FCDiff_spatial_model', [],...
                        'FC_spatial_model', [],...
                        'smearParamIndices', []);
       
B1a_fit_results = struct('B1coeffs_and_errors_xCoeff', [],...
                            'B1robust_weights_xCoeff', [],...
                            'ch2probALL', []);

B1a_fit_residInfo = struct('B1residuals_xCoeff', []);

B1aModelDump = struct('initInfo', [],...
                        'Inputs', []);
                    
B1b_fit_results = struct('B1bcoeffs_and_errors_xCoeff', [],...
                            'B1brobust_weights_xCoeff', [],...
                            'chi2_probabilitiesB1b', []);
                        
B1b_fit_residInfo = struct('B1bresiduals_xCoeff', []);

B1bModelDump = struct('initInfo', [],...
                        'Inputs', []);

% monitors could be empty
B2c_monitors = struct('');

% initialize rolling band flags array for all rows with all gapped time series
rollingBandArtifactFlagsStruct = repmat(struct('testPulseDurationLc',0,...
                                                'row',[],...
                                                'flags',struct('values',zeros(nCadences,1),...
                                                        'gapIndicators',true(nCadences,1)),...
                                                'variationLevel',struct('values',zeros(nCadences,1),...
                                                        'gapIndicators',true(nCadences,1))),...
                                        nCcdRows * nDurations,1);

% assign pulse duration
for iDuration = 1:nDurations
    % assign one-based row number
    for iRow = 1:nCcdRows
        idx = (iDuration - 1)*nCcdRows + iRow;
        rollingBandArtifactFlagsStruct(idx ).testPulseDurationLc = pulseDuration(iDuration);
        rollingBandArtifactFlagsStruct(idx).row = iRow;
    end
end

% load first level results struct with configurations, initialized values and empty results structures
dynablackResultsStruct = struct('validUow', validUow, ...
                                'validDynablackFit', validUow, ...
                                'bestCoefficients', 'robust', ...
                                'ccdModule', ccdModule,...
                                'ccdOutput', ccdOutput,...
                                'cadenceTimes', cadenceTimes,...
                                'dynablackBlobFilename', dynablackBlobFilename,...
                                'dynablackModuleParameters', dynablackModuleParameters,...
                                'meanBlackTable', meanBlackTable,...
                                'staticTwoDBlackImage', staticTwoDBlackImage,...
                                'A1_fit_results', A1_fit_results,...
                                'A1_fit_residInfo', A1_fit_residInfo,...
                                'A1ModelDump', A1ModelDump,...
                                'A2_fit_results', A2_fit_results,...
                                'A2_fit_residInfo', A2_fit_residInfo,...
                                'A2ModelDump', A2ModelDump,...
                                'B1a_fit_results', B1a_fit_results,...
                                'B1a_fit_residInfo', B1a_fit_residInfo,...
                                'B1aModelDump', B1aModelDump,...
                                'B1b_fit_results', B1b_fit_results,...
                                'B1b_fit_residInfo', B1b_fit_residInfo,...
                                'B1bModelDump', B1bModelDump,...
                                'B2c_monitors',B2c_monitors,...
                                'rollingBandArtifactFlagsStruct',rollingBandArtifactFlagsStruct);





