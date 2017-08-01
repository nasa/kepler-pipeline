function dynablackResultsStruct = dynablack_matlab_controller(dynablackInputsStruct)
% function dynablackResultsStruct = dynablack_matlab_controller(dynablackInputsStruct)
% 
% This is the top level function on the MATLAB side of the dynablack CSCI.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure 'dynablackInputsStruct' with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%   dynablackInputsStruct is a structure with the following fields:
%
%                            ccdModule: [int]               CCD module number
%                            ccdOutput: [int]               CCD output number
%            dynablackModuleParameters: [struct]            module parameters for dynablack
%           rbaFlagConfigurationStruct: [struct]            configuration parameters for the rba flagging routine (B2a)
%       ancillaryEngineeringDataStruct: [struct array]      engineering temperature data for detrending over cadences
%                              rawFfis: [struct array]      raw ffi data
%                         cadenceTimes: [struct]            cadence times and gap indicators for long cadence data
%                          blackPixels: [struct array]      raw black collateral for long cadence data
%                    maskedSmearPixels: [struct array]      raw masked smear collateral for long cadence data
%                   virtualSmearPixels: [struct array]      raw virtual smear collateral for long cadence data
%                     backgroundPixels: [struct array]  -------- NOT USED
%                      arpTargetPixels: [struct array]      raw artifact removal pixels for long cadence data
%           reverseClockedCadenceTimes: [struct]            cadence times and gap indicators for reverse clocked data
%            reverseClockedBlackPixels: [struct array]      raw black collateral for reverse clocked data
%      reverseClockedMaskedSmearPixels: [struct array]      raw masked smear collateral for reverse clocked data
%     reverseClockedVirtualSmearPixels: [struct array]      raw virtual smear collateral for reverse clocked data
%       reverseClockedBackgroundPixels: [struct array]      raw background pixels for reverse clocked data
%           reverseClockedTargetPixels: [struct array]      raw target pixels for reverse clocked data
%                       twoDBlackModel: [struct]            static 2D black model
%                      undershootModel: [struct]        -------- NOT USED
%                            gainModel: [struct]        -------- NOT USED
%                       flatFieldModel: [struct]        -------- NOT USED
%                       linearityModel: [struct]        -------- NOT USED
%                       readNoiseModel: [struct]        -------- NOT USED
%                  spacecraftConfigMap: [struct array]      one or more spacecraft config maps
%                        requantTables: [struct]            requantization table (dynablack needs only the mean black table from this)
%                        huffmanTables: [struct]        -------- NOT USED
%                          fcConstants: [struct]            fc constants
%                               season: [int]               indicates observing season [0,1,2,3] 
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
% 
%   dynablackModuleParameters is a structure with the following fields:
%                                                           
%                 NOTE: ALL ROW AND COLUMN INDICES IN DYNABLACK MODULE PARAMETERS ARE ONE-BASED
%
%                 ancillaryEngineeringMnemonics: {cell array}       ancillary mnemonic names
%                          rawFfiFileTimestamps: {cell array}       ffi time stamps in string form
%                      pixelBrightnessThreshold: [double]           brightness threshold to determine scene dependence (ADU/lc)
%     minimumColumnForExcludingTrailingBlackRow: [int]              
%                         reverseClockedEnabled: [logical]          enable processing of reverse clocked data
%                         dynablackBlobFilename: [string]           output blob local filename
%                           cadenceGapThreshold: [int]              gapped cadence threshold triggering insertion of bias step in smoothing
%                                                                   model over cadences 
%                           includeStepsInModel: [logical]          enables bias steps in smoothing model
%                               maxA1CoeffCount: [int]              maximum allowed FGS coefficients in A1 (vertical) fit
%                               maxA2CoeffCount: [int]              maximum allowed FGS coefficients in A2 (horizontal) fit
%                               maxB1CoeffCount: [int]              maximum allowed coefficients in B1a/B1b smoothing models
%                                 numModelTypes: [int]              number of B1a/B1b smoothing models 
%                          numB1PredictorCoeffs: [int]              number of B1 predictors (nominally 2, temperature and time)
%                           parallelPixelSelect: [int array]        clock cycles for fgs parallel pixels to fit in A1
%                         a2ParallelPixelSelect: [int array]        clock cycles for fgs parallel pixels to fit in A2
%                              framePixelSelect: [int array]        clock cycles for fgs frame pixels to fit in A1
%                            a2FramePixelSelect: [int array]        clock cycles for fgs frame pixels to fit in A2
%                           leadingColumnSelect: [int array]        leading columns for A1 fit
%                         a2LeadingColumnSelect: [int array]        leading columns for A2 fit
%                              thermalRowOffset: [double]           LDE thermal settling time measured in rows
%                        defaultRowTimeConstant: [double]           starting point for vertical non-linear fit
%                              minUndershootRow: [int]              row range minimum for undershoot estimate
%                              maxUndershootRow: [int]              row range maximum for undershoot estimate
%                               undershootSpan0: [int]              length of initial undershoot feature in columns
%                                undershootSpan: [int]              length of final undershoot feature in columns
%                               scDPixThreshold: [double]           brightness threshold to determine scene dependence (ADU/lc)
%                                       blurPix: [int]              size of row buffer for scene dependence
%                                  nearTbMinpix: [double]           column threshold for scene dependence in black
%                            a1NumPredictorRows: [int]              number of coefficients in the A1 (vertical) model
%                   a1NumNonlinearPredictorRows: [int]              number of nonlinear coefficients in the A1 (vertical) model
%                         a1NumFfiPredictorRows: [int]              number of coefficients in the ffi (vertical) model
%                                    a2SkipDiff: [logical]          disable smear difference fit
%                        a2ColumnPredictorCount: [int]              number of coefficients in the A2 (horizontal) model
%                    a2LeadColumnPredictorCount: [int]              number of lead columns to include in the A2 fit
%                         a2SmearPredictorCount: [int]              number of coefficeints in the A2 smear model
%                                    a2SolRange: [int array]        list of start of line ringing columns
%                                    a2SolStart: [int]              start of line ringing statr column
%                                                                   The ROIs (Region Of Interest) below are retangular regions defined by
%                                                                   the four component vector [row_min row_max column_min column_max]:
%                                    leadingArp: [int array]        define leading arp region 
%                                   trailingArp: [int array]        define trainling arp region
%                                 trailingArpUs: [int array]        define trailing arp undershoot region
%                                trailingCollat: [int array]        define trailing black region
%                               neartrailingArp: [int array]        define near trailing arp region
%                                   trailingFfi: [int array]        define trailing black region for ffis
%                                      rclcTarg: [int array]        define reverse clocked target region
%                           trailingMaskedSmear: [int array]        define masked smear region in the trailing black
%                            leadingMaskedSmear: [int array]        define masked smear region in the leading black
%              blackResidualsThresholdDnPerRead: [double]           if more than numBlackPixelsAboveThreshold of the standard deviation over
%                                                                   cadences of the fit residuals are above this threshold the dynablack fit
%                                                                   is deemed to be unreliable and validDynablackFit will be set to false in
%                                                                   the output blob 
%                  numBlackPixelsAboveThreshold: [int]              (see blackResidualsThresholdDnPerRead)
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second Level
%
%   rbaFlagConfigurationStruct is a struct with the following fields:
% 
%       pixelNoiseThresholdAduPerRead: [double]         20 ppm noise level in adu/read/pixel for 12th mag. star
%        pixelBiasThresholdAduPerRead: [double]         20 ppm bias level in adu/read/pixel for 12th mag. star
%                       cleaningScale: [int]            smoothing filter length in long cadences
%                  testPulseDurations: [int]            duration in long cadences for square wave transit model to test for rba
%               numberOfFlagVariables: [int]            number of flag variables in suspect data flag
%                   severityQuantiles: [double array]   quantiles to report in severity parameter monitoring (nominally [0.977, 0.5])
%                  meanSigmaThreshold: [double]         bias threshold in sigma
%               robustWeightThreshold: [double]         robust weight threshold
%          transitDepthSigmaThreshold: [double]         transit depth threshold in sigma
% 
%-------------------------------------------------------------------------------------------------------------------------------------------------%   Second level
%
%   ancillaryEngineeringDataStruct is an array of structures with the following fields:
%
%         mnemonic: [string]            mnemonic name of engineering data 
%       timestamps: [double array]      timestamp (MJD)
%           values: [double array]      engineering data value (ADU)
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level 
%
%   rawFfis is an array of structures with the following fields:
% 
%             fileName: [string]        date and time ffi filename
%   	startTimestamp: [double]        start time (MJD)
%         midTimestamp: [double]        mid time (MJD)
%         endTimestamp: [double]        end tiem (MJD)
%                image: [struct array]  1 x nCcdRows array of structures each containing a [double array] of nCcdColumns x 1 ffi values
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
% 
%   blackPixels and reverseClockedBlackPixels are arrays of structures with the following fields:
%
%               row: [int]              zero based row index
%            values: [double array]     nCadence x 1 array of raw values
%     gapIndicators: [logical array]    nCadence x 1 array of gap indicators
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
% 
%   maskedSmearPixels, virtualSmearPixels, reverseClockedMaskedSmearPixels and reverseClockedVirtualSmearPixels are arrays of structures
%   with the following fields: 
%
%            column: [int]              zero based column index
%            values: [double array]     nCadence x 1 array of raw values
%     gapIndicators: [logical array]    nCadence x 1 array of gap indicators
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
% 
%   backgroundPixels, arpTargetPixels, reverseClockedBackgroundPixels and reverseClockedTargetPixels are arrays of structures with the
%   following fields: 
%
%               row: [int]              zero based row index
%            column: [int]              zero based column index
%            values: [double array]     nCadence x 1 array of raw values
%     gapIndicators: [logical array]    nCadence x 1 array of gap indicators
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
% 
%   cadenceTimes and reversClockedCadenceTimes are structs with the following fields:
%
%           startTimestamps: [double array]     cadence start times (MJD)
%             midTimestamps: [double array]     cadence mid times (MJD)
%             endTimestamps: [double array]     cadence end times (MJD)
%             gapIndicators: [logical array]    true if cadence is unavailable
%            requantEnabled: [logical array]    true if requantization was enabled
%            cadenceNumbers: [int array]        absolute cadence numbers
%                 isSefiAcc: [logical array]    single event functional interrupt in accumulation memory (isSefiAcc = T)
%                 isSefiCad: [logical array]    single event functional interrupt in cadence memory (isSefiCad = T)
%                  isLdeOos: [logical array]    local detector electronics out of synch reported (isLdeOos = T)
%                 isFinePnt: [logical array]    spacecraft is in fine point (isFinePnt = T)
%                isMmntmDmp: [logical array]    momentum dump occurred during accumulation (isMmntmDmp = T)
%                isLdeParEr: [logical array]    local detector electronics parity error occurred (isLdeParEr = T)
%                 isScrcErr: [logical array]    SDRAM controller memory pixel error occurred (isScrcErr = T)
%          dataAnomalyFlags: [struct]           data anomaly flags - 1 x nCadence logical vector for each anomaly type
% 
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Third Level
%
%   dataAnomalyFlags is a struct with the following fields:
%
%               attitudeTweakIndicators: [logical array]
%                    safeModeIndicators: [logical array]
%                 coarsePointIndicators: [logical array]
%             argabrighteningIndicators: [logical array]
%                     excludeIndicators: [logical array]
%                  earthPointIndicators: [logical array]
%
%-------------------------------------------------------------------------------------------------------------------------------------------------
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:  A data structure dynablackResultsStruct with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Top level
%
% dynablackResultsStruct is a structure containing the following fields:
%
%                  validDynablackFit: 1
%                          ccdModule: 2
%                          ccdOutput: 1
%                       cadenceTimes: [1x1 struct]
%              dynablackBlobFilename: 'dynablack_blob.mat'
%                     meanBlackTable: [84x1 double]
%                     A1_fit_results: [1x1 struct]
%                   A1_fit_residInfo: [1x1 struct]
%                        A1ModelDump: [1x1 struct]
%                     A2_fit_results: [1x1 struct]
%                   A2_fit_residInfo: [1x1 struct]
%                        A2ModelDump: [1x1 struct]
%                    B1a_fit_results: [1x1 struct]
%                  B1a_fit_residInfo: [1x1 struct]
%                       B1aModelDump: [1x1 struct]
%                    B1b_fit_results: [1x1 struct]
%                  B1b_fit_residInfo: [1x1 struct]
%                       B1bModelDump: [1x1 struct]
%                       B2c_monitors: [1x1 struct]
%     rollingBandArtifactFlagsStruct: [1070x1 struct]
%                        B2a_results: [1x1 struct] 
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
%
%   A1_fit_results
%     channel_number: 1
%                 LC: [1x1 struct]
%                FFI: [1x1 struct]
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
%
%   A1_fit_residInfo
%     channel_number: 1
%                 LC: [1x1 struct]
%                FFI: [1x1 struct]
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
%
%   A1ModelDump
%              FCLC_Model: [1x1 struct]
%               FFI_Model: [1x1 struct]
%     rowsModelLinearRows: [1 2 3 4 8 9]
%                     ROI: [1x1 struct]
%                  Inputs: [1x1 struct]
%               Constants: [1x1 struct]
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
%
%   A2_fit_results
%          coeffs_and_errors_xRC: [6x1305 double]
%     smearCoeffs_and_errors_xLC: [58x9 double]
%                    fit_results: {[1]  [2x1 double]}
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
%
%   A2_fit_residInfo
%          residuals_xRC: [6x109156 double]
%     smearResiduals_xLC: [58x22 double]
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
%
%   A2ModelDump
%                   Inputs: [1x1 struct]
%                Constants: [1x1 struct]
%               RCLC_Model: [1x1 struct]
%               FCLC_Model: [1x1 struct]
%                      ROI: [1x1 struct]
%       RCLC_spatial_model: [54578x435 double]
%     FCDiff_spatial_model: 0
%         FC_spatial_model: [11x3 double]
%        smearParamIndices: [2 3]
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
%
%   B1a_fit_results
%     B1coeffs_and_errors_xCoeff: [264x4x59 double]
%        B1robust_weights_xCoeff: [264x4x58 double]
%                     ch2probALL: [1x1 struct]
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
%
%   B1a_fit_residInfo
%     B1residuals_xCoeff: [264x4x116 double]
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
%
%   B1aModelDump
%     initInfo: [1x1 struct]
%       Inputs: [1x1 struct]
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
%
%   B1b_fit_results
%     B1bcoeffs_and_errors_xCoeff: [130x4x59 double]
%        B1brobust_weights_xCoeff: [130x4x58 double]
%           chi2_probabilitiesB1b: [130x8 double]
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
%
%   B1b_fit_residInfo
%     B1bresiduals_xCoeff: [130x4x116 double]
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
%
%   B1bModelDump
%     initInfo: [1x1 struct]
%       Inputs: [1x1 struct]
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
%
%   B2c_monitors
%     trailingBlackResidual: [1x1 struct]
%        frameFGSDeltaCoeff: [1x1 struct]
%     parallelFGSDeltaCoeff: [1x1 struct]
%       serialFGSDeltaCoeff: [1x1 struct]
%           undershootCoeff: [1x1 struct]
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Second level
%
%   rollingBandArtifactFlagsStruct is a structure containing the following fields:
%             row: [int]        zero based ccd row number
%           flags: [struct]     rba flag time series
%-------------------------------------------------------------------------------------------------------------------------------------------------
%   Third level
%
%   flags is a structure containing the following fields:
%               values: [double array]         nCadences x 1 array of rba flag values
%        gapIndicators: [logical array]        nCadences x 1 array of gap indicators
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


% update inputs
dynablackInputsStruct = update_dynablack_inputs(dynablackInputsStruct);

% validate inputs
validate_dynablack_inputs(dynablackInputsStruct);

% convert inputs
dynablackInputsStruct = convert_dynablack_inputs(dynablackInputsStruct);

% create object
dynablackObject = dynablackClass(dynablackInputsStruct);

% initialize results structure
dynablackResultsStruct = initialize_dynablack_results(dynablackObject);

% perform fits
dynablackResultsStruct = perform_dynablack_fits(dynablackObject, dynablackResultsStruct);

% package outputs
dynablackResultsStruct = package_dynablack_outputs(dynablackObject, dynablackResultsStruct);

% convert outputs
dynablackResultsStruct = convert_dynablack_outputs(dynablackResultsStruct);

% validate outputs
validate_dynablack_outputs(dynablackResultsStruct);

% produce blob file
produce_dynablack_blob(dynablackResultsStruct);