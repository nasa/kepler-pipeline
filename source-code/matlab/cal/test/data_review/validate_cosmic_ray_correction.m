function validate_cosmic_ray_correction()
%
%
%
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


%--------------------------------------------------------------------------
% load I/O
%--------------------------------------------------------------------------
% scEtemDataDataDir   = '/path/to/etem/q2/i142/';  % <-- 12 mod/outs, 180 dirs
% cd(scEtemDataDataDir)
% 
% load cal-matlab-142-1000/cal-outputs-0.mat
% load cal-matlab-142-1000/cal-inputs-0.mat

load /path/to/matlab/cal/test/validation/cosmic_ray_struct.mat


eventsFound = plot_cal_cosmic_ray_events(inputsStruct, outputsStruct, -1, -1);


%--------------------------------------------------------------------------
% inject cosmic rays into black
%--------------------------------------------------------------------------
% cosmicRayStruct.cadenceList = [100 300 1200];
% cosmicRayStruct.madList = [200 50 100];
% cosmicRayStruct.rowList = [];
% cosmicRayStruct.colList = [];
% cosmicRayStruct.blackList = [584 917];
% cosmicRayStruct.maskedSmearList = [];
% cosmicRayStruct.virtualSmearList = [];
% cosmicRayStruct.maskedBlackFlag = true;
% cosmicRayStruct.virtualBlackFlag = true;
%
% inputsStructCR = inject_cosmic_rays_into_CAL_input_data(inputsStruct, cosmicRayStruct);


%--------------------------------------------------------------------------
% run CAL with new inputs
%--------------------------------------------------------------------------
% cd /path/to/matlab/cal/test/run_cal_here/
%
% dbstop if error; outputsStructCR = cal_matlab_controller(inputsStructCR);
 

%--------------------------------------------------------------------------
% plot the detected CRs -- were the injected CRs found?
%--------------------------------------------------------------------------
blackEventsFound = plot_cal_cosmic_ray_events(inputsStructCR, outputsStructCR, 584, -1); % blackList = [584 917];


%--------------------------------------------------------------------------
% inject cosmic rays into smear
%--------------------------------------------------------------------------
% cosmicRayStruct.cadenceList = [100 300 1200];
% cosmicRayStruct.madList = [200 50 100];
% cosmicRayStruct.rowList = [];
% cosmicRayStruct.colList = [];
% cosmicRayStruct.blackList = [584 917];
% cosmicRayStruct.maskedSmearList = [278 618];
% cosmicRayStruct.virtualSmearList = [225 984];
% cosmicRayStruct.maskedBlackFlag = true;
% cosmicRayStruct.virtualBlackFlag = true;
%
% inputsStructCRsmear = inject_cosmic_rays_into_CAL_input_data(inputsStruct, cosmicRayStruct);


%--------------------------------------------------------------------------
% run CAL with new inputs
%--------------------------------------------------------------------------
% cd /path/to/matlab/cal/test/run_cal_here/
%
% dbstop if error; outputsStructCR = cal_matlab_controller(inputsStructCRsmear);


%--------------------------------------------------------------------------
% plot the detected CRs -- were the injected CRs found?
%--------------------------------------------------------------------------
smearEventsFound = plot_cal_cosmic_ray_events(inputsStructCR, outputsStructCR, -1, 618); % maskedSmearList = [278 618];virtualSmearList = [225 984];


end
