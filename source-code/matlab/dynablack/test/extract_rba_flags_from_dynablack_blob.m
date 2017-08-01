function rbaResults = extract_rba_flags_from_dynablack_blob( inputStruct, rbaFlagConfigurationStruct, fcConstants )
% 
% function rbaResults = extract_rba_flags_from_dynablack_blob( inputStruct, rbaFlagConfigurationStruct, fcConstants )
%
% This function may be used to create 4-bit rolling band flags double
% precision variation levels from the dynablack fit residuals contained in
% the dynabalck blob. The test pulse duration as well as the other
% thresholds are configurable using the rbaFlagConfigurationStruct. Note
% 'testPulseDurations' in this structure is a vector of pulse 'durations' measured in
% number of long cadences. These must be positive integer.
%
% INPUT:
% inputStruct                       == dynablack blob inputStruct
% rbaFlagConfigurationStruct        == rolling band flag configuration struct (see dynablack_matlab_controller.m) 
% This structure contains the following fields (default values):
%                     cleaningScale: 21
%                meanSigmaThreshold: 1
%             numberOfFlagVariables: 9
%                testPulseDurations: [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21]
%     pixelNoiseThresholdAduPerRead: 1.6500
%      pixelBiasThresholdAduPerRead: 0.0160
%             robustWeightThreshold: 0.5000
%                 severityQuantiles: [2x1 double]
%        transitDepthSigmaThreshold: 0
% fcConstants                       == fc constants
% OUTPUT:
% rbaResults                        == [nTestPulses x 1] array of results structures
% This structure contains the following fields:
%       flagsRollingBands: [nRows x nCadences uint8]
%          variationLevel: [nRows x nCadences double]
%     testPulseDurationLc: test pulse duration in long cadences
%                     RBA: [1x1 struct]
%                               numFlags: number of rba flags in nRows x nCadences data set
%                          fractionFlags: fraction of data flagged
%                           meanSeverity: mean severity of flagged data
%                                rowList: one-based list of rows in flagsRollingBands and variationLevel
%                         relCadenceList: one-based list of cadences relative to cadence(1) in unit of work in flagsRollingBands and variationLevel
%                SceneDep: [1x1 struct]
%                                numRows: number of scene dependent rows
%                           fractionRows: fraction of fit rows that are scene dependent
%                                rowList: one-based list of scene dependent rows
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

% set up dynablack class constructor input
temp.ccdModule = inputStruct.ccdModule;
temp.ccdOutput = inputStruct.ccdOutput;
temp.cadenceTimes = inputStruct.cadenceTimes;
temp.fcConstants = fcConstants;
temp.rbaFlagConfigurationStruct = rbaFlagConfigurationStruct;

% update input fields to 9.3
temp = dynablack_convert_92_data_to_93(temp);

% make dynabalck object
tempObj = dynablackClass(temp);

% use dynablackClass method to generate rba flags
outputStruct = B2a_main(tempObj,inputStruct);

% parse the flag results from the output
rbaResults = outputStruct.B2a_results;