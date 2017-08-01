function result = run_cal_sensitivity_test( calInputStruct )
%
% function result = run_cal_sensitivity_test( newInputsStruct )
%
% This function runs CAL and PA on a single mod out in order to perfrom a
% sensitivity analysis on the CAL calibrations. The following operations
% are performed:
% 1) The models in each inputsStruct in the cal-inputs-#.mat files are
%    changed to match those provided in the calInputStruct.
% 2) CAL is run and cal-outputs-#.mat files are produced.
% 3) The calibrated pixels from the cal-outputs-#.mat files are transfered
%    to the appropriate pa-inputs-#.mat files.
% 4) PA is run and pa-outputs-#.mat files are produced.
% %%% DON'T DO PLOTTING YET -------- 5) Centroids and/or other PA output is plotted.
%
% INPUTS:   calInputStruct  = calInputStruct which contains modified models
% OUTPUT:   result          = dummy boolean, set to true
% 
% Note: The function must be run from the directory which contains existing
% cal-inputs-#.mat files
% pa-inputs-#.mat files
% any blob files used by PA
% These are produced presumably from a pipeline run. Any cal-outputs-#.mat 
% and pa-outputs-#.mat files in the working directory will be overwritten.
%
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

result = true;

dirCal = dir('cal-inputs-*.mat');
nCalInvocations = length(dirCal) - 1;

dirPa = dir('pa-inputs-*.mat');
nPaInvocations = length(dirPa) - 1;

save cal_sensitivity_state.mat nCalInvocations nPaInvocations;

disp('Modifying CAL input structs.');
batch_modify_cal_input_parameters( calInputStruct, nCalInvocations );


clear classes;
load cal_sensitivity_state.mat;
disp('Running CAL.');
run_cal_in_batch( nCalInvocations );

disp('Transferring calibrated pixels to pa inputs.');
transfer_calibrated_outputs_to_pa_inputs( nCalInvocations, nPaInvocations );

clear classes;
load cal_sensitivity_state.mat;
disp('Running PA.');
run_pa_in_batch( nPaInvocations );


% plot_centroid_results(outputsStruct, cadenceGapList);
