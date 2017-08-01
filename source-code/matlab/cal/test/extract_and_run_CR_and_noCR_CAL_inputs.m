

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


cadenceList = 1:3000;
ccdModule = 7;
ccdOutput = 3;

etem2RunDirName = './';
etem2RunDir = 'run_short_m7o3s1';
pixelDataMatFilename = 'TC01_SC';
getRequantizedPixFlag = true;
includeCosmicRaysFlag = false;
requantTableID = 200;

addpath /path/to/matlab/etem2/mfiles/user_utilities/

extract_SC_pixel_time_series_from_etem2(etem2RunDirName,...
                                        etem2RunDir,...
                                        pixelDataMatFilename,...
                                        getRequantizedPixFlag,...
                                        includeCosmicRaysFlag,...
                                        requantTableID);

                                    
includeCosmicRaysFlag = true;

extract_SC_pixel_time_series_from_etem2(etem2RunDirName,...
                                        etem2RunDir,...
                                        pixelDataMatFilename,...
                                        getRequantizedPixFlag,...
                                        includeCosmicRaysFlag,...
                                        requantTableID);
includeCosmicRaysFlag = false;

[inputsStruct0_noCR, inputsStruct1_noCR] = set_cal_SC_input_struct(etem2RunDir,...
                                                                          pixelDataMatFilename,...
                                                                          cadenceList,...
                                                                          getRequantizedPixFlag,...
                                                                          includeCosmicRaysFlag,...
                                                                          ccdModule,...
                                                                          ccdOutput);
includeCosmicRaysFlag = true;

[inputsStruct0_CR, inputsStruct1_CR] = set_cal_SC_input_struct(etem2RunDir,...
                                                                          pixelDataMatFilename,...
                                                                          cadenceList,...
                                                                          getRequantizedPixFlag,...
                                                                          includeCosmicRaysFlag,...
                                                                          ccdModule,...
                                                                          ccdOutput);
                                                                     
rmpath /path/to/matlab/etem2/mfiles/user_utilities/



% set module parameters
moduleParametersStruct.debugEnabled                         = false;
moduleParametersStruct.linearityCorrectionEnabled           = true;
moduleParametersStruct.undershootEnabled                    = true;
moduleParametersStruct.crCorrectionEnabled                  = true;
moduleParametersStruct.flatFieldCorrectionEnabled           = true;
moduleParametersStruct.falseRejectionRate                   = 1.0000e-04;
moduleParametersStruct.polyOrderMax                         = 10;
moduleParametersStruct.madSigmaThresholdForBleedingColumns  = 15;
moduleParametersStruct.madSigmaThresholdForSmearLevels      = 3.5000;
moduleParametersStruct.undershootReverseFitPolyOrder        = 1;
moduleParametersStruct.undershootReverseFitWindow           = 10;

% set pou parameters
pouModuleParametersStruct.pouEnabled            = false;
pouModuleParametersStruct.compressionEnabled    = false;
pouModuleParametersStruct.maxSvdOrder           = 10;
pouModuleParametersStruct.numErrorPropVars      = 30;
pouModuleParametersStruct.pixelChunkSize        = 2500;
pouModuleParametersStruct.interpDecimation      = 24;
pouModuleParametersStruct.interpMethod          = 'linear';
pouModuleParametersStruct.cadenceChunkSize      = 1;


inputsStruct0_noCR.moduleParametersStruct = moduleParametersStruct;
inputsStruct0_noCR.pouModuleParametersStruct = pouModuleParametersStruct;
inputsStruct1_noCR.moduleParametersStruct = moduleParametersStruct;
inputsStruct1_noCR.pouModuleParametersStruct = pouModuleParametersStruct;

inputsStruct0_CR.moduleParametersStruct = moduleParametersStruct;
inputsStruct0_CR.pouModuleParametersStruct = pouModuleParametersStruct;
inputsStruct1_CR.moduleParametersStruct = moduleParametersStruct;
inputsStruct1_CR.pouModuleParametersStruct = pouModuleParametersStruct;


% run cosmic rays off data set trough CAL
output0_noCR = cal_matlab_controller(inputsStruct0_noCR);
output1_noCR = cal_matlab_controller(inputsStruct1_noCR);

% run cosmic rays on data set trough CAL
output0_CR = cal_matlab_controller(inputsStruct0_CR);
output1_CR = cal_matlab_controller(inputsStruct1_CR);


