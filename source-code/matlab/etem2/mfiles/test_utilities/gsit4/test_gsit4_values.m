% check long cadence data
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
disp('pre-roll targets');
targetResultPreRoll = test_gsit4_target_values('/disk2/gsit4/gsit4_ffis/', ...
    'gsit-4-a-lc1', ...
    '/path/to/recdels/gsit-4/rec/dmc/v1/kplr2012123180618_lcs-targ.fits');
if any(targetResultPreRoll == 0)
    disp('error in pre-roll target value check');
else
    disp('pre-roll targets are clean');
end

disp('post-roll targets');
targetResultPostRoll = test_gsit4_target_values('/disk2/gsit4/gsit4_ffis3/', ...
    'gsit-4-b-lc1', ...
    '/path/to/recdels/gsit-4/rec/dmc/v1/kplr2012181152531_lcs-targ.fits');
if any(targetResultPostRoll == 0)
    disp('error in post-roll target value check');
else
    disp('post-roll targets are clean');
end

%%
backgroundResultPreRoll = test_gsit4_background_values('/disk2/gsit4/gsit4_ffis/', ...
    'gsit-4-a-lc1', ...
    '/path/to/recdels/gsit-4/rec/dmc/v1/kplr2012123180618_lcs-bkg.fits');
if any(backgroundResultPreRoll == 0)
    disp('error in pre-roll background value check');
else
    disp('pre-roll background is clean');
end

%%
backgroundResultPostRoll = test_gsit4_background_values('/disk2/gsit4/gsit4_ffis3/', ...
    'gsit-4-b-lc1', ...
    '/path/to/recdels/gsit-4/rec/dmc/v1/kplr2012181152531_lcs-bkg.fits');
if any(backgroundResultPostRoll == 0)
    disp('error in post-roll background value check');
else
    disp('post-roll background is clean');
end

%%
collateralResultPreRoll = test_gsit4_collateral_values('/disk2/gsit4/gsit4_ffis/', ...
    '/path/to/recdels/gsit-4/rec/dmc/v1/kplr2012123180618_lcs-col.fits');
if any(collateralResultPreRoll == 0)
    disp('error in pre-roll collateral value check');
else
    disp('pre-roll collateral is clean');
end

%%
collateralResultPostRoll = test_gsit4_collateral_values('/disk2/gsit4/gsit4_ffis3/', ...
    '/path/to/recdels/gsit-4/rec/dmc/v1/kplr2012181152531_lcs-col.fits');
if any(collateralResultPreRoll == 0)
    disp('error in post-roll collateral value check');
else
    disp('post-roll collateral is clean');
end

%%
% check short cadence data
disp('pre-roll short cadence targets');
scTargetResultPreRoll = test_gsit4_sc_target_values('/disk2/gsit4/gsit4_ffis/', ...
    'gsit-4-a-sc2', ...
    '/path/to/recdels/gsit-4/rec/dmc/v1/kplr2012123173724_scs-targ.fits', 1);
if any(targetResultPreRoll == 0)
    disp('error in pre-roll short cadence target value check');
else
    disp('pre-roll short cadence targets are clean');
end

%%
disp('post-roll short cadence targets');
scTargetResultPostRoll = test_gsit4_sc_target_values('/disk2/gsit4/gsit4_ffis3/', ...
    'gsit-4-b-sc1', ...
    '/path/to/recdels/gsit-4/rec/dmc/v1/kplr2012181162519_scs-targ.fits', 0);
if any(scTargetResultPostRoll == 0)
    disp('error in post-roll short cadence target value check');
else
    disp('post-roll short cadence targets are clean');
end
%%
disp('pre-roll short cadence collateral');
scCollateralResultPreRoll = test_gsit4_sc_collateral_values('/disk2/gsit4/gsit4_ffis/', ...
    'gsit-4-a-sc2', ...
    '/path/to/recdels/gsit-4/rec/dmc/v1/kplr2012123173724_scs-col.fits', 1);
if any(scCollateralResultPreRoll == 0)
    disp('error in pre-roll short cadence collateral value check');
else
    disp('pre-roll short cadence collateral are clean');
end


%%
disp('post-roll short cadence collateral');
scCollateralResultPostRoll = test_gsit4_sc_collateral_values('/disk2/gsit4/gsit4_ffis3/', ...
    'gsit-4-b-sc1', ...
    '/path/to/recdels/gsit-4/rec/dmc/v1/kplr2012181162519_scs-col.fits', 0);
if any(scCollateralResultPostRoll == 0)
    disp('error in post-roll short cadence collateral value check');
else
    disp('post-roll short cadence collateral are clean');
end


