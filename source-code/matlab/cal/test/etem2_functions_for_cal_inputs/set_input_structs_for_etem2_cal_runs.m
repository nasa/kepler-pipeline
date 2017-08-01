function set_input_structs_for_etem2_cal_runs(outputFileLocationStr)
%function set_input_structs_for_etem2_cal_runs(outputFileLocationStr)
%
% ex. set_input_structs_for_etem2_cal_runs('/path/to/matlab/cal/')
% 
% function to construct input structures (s) that will be inputs into
% running etem2:
%
%   etem2(create_cal_etem2_inputs(s))
%
% the structs are saved to the directory specified in outputFileLocationStr
% and the matfiles will be named in the following format:
%
%        calETEM_2D_ST_SM_DC_NL_LU_FF_RN_QN_SN.mat
%
%  2D       two D black on
%  ST       stars on
%  SM       smear on
%  DC       dark current on
%  NL       nonlinearity on
%  LU       lde undershoot on
%  FF       flat field on
%  RN       read noise on
%  QN       quantization noise on
%  SN       shot noise on
%
% Upper case letters in filename indicate the effects are on (enabled)
% Lower case letters indicate that the effects are off
%
% For each etem run, the pixels can be extracted in the following ways:
%
% RQ    requantized
% rq    not requantized
% CR    with cosmic rays        (if cosmic rays are enabled in this function)
% cr    without cosmic rays
%
%
% The results of running etem2 and creating collateral and photometric
% inputs (run_etem2_and_construct_cal_inputs) is a saved matfile
% (/path/to/matlab/cal) with the filename in this format:
%
%        calInputs_2D_ST_SM_DC_NL_LU_FF_RN_QN_SN_RQ_CR.mat
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



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% create input structs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
s.outputDirectory         = 'calSC_ETEM_2D_ST_sm_dc_nl_lu_ff_rn_qn_sn_dir';
s.filename                = 'calSC_ETEM_2D_ST_sm_dc_nl_lu_ff_rn_qn_sn';
s.numCadences             = 50;
s.ccdModule               = 7;
s.ccdOutput               = 4;
s.cadenceType             = 'short';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = false;
s.darkEnabled                   = false;
s.darkCurrentValue              = 0;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'ort4b_trimmed_sc3';
s.refPixTargetListSetName = 'ort4b_trimmed_rp'; 
s.runStartDate            = '1-April-2009';
s.requantizationTableId   = 200;

save([outputFileLocationStr 'calSC_ETEM_2D_ST_sm_dc_nl_lu_ff_rn_qn_sn.mat'], 's');



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
s.outputDirectory         = 'calSC_ETEM_2D_ST_SM_DC_nl_lu_ff_rn_qn_sn_dir';
s.filename                = 'calSC_ETEM_2D_ST_SM_DC_nl_lu_ff_rn_qn_sn';
s.numCadences             = 50;
s.ccdModule               = 7;
s.ccdOutput               = 4;
s.cadenceType             = 'short';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'ort4b_trimmed_sc3';
s.refPixTargetListSetName = 'ort4b_trimmed_rp'; 
s.runStartDate            = '1-April-2009';
s.requantizationTableId   = 200;

save([outputFileLocationStr 'calSC_ETEM_2D_ST_SM_DC_nl_lu_ff_rn_qn_sn.mat'], 's');



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + nonlin
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
s.outputDirectory         = 'calSC_ETEM_2D_ST_SM_DC_NL_lu_ff_rn_qn_sn_dir';
s.filename                = 'calSC_ETEM_2D_ST_SM_DC_NL_lu_ff_rn_qn_sn';
s.numCadences             = 50;
s.ccdModule               = 7;
s.ccdOutput               = 4;
s.cadenceType             = 'short';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = true;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'ort4b_trimmed_sc3';
s.refPixTargetListSetName = 'ort4b_trimmed_rp'; 
s.runStartDate            = '1-April-2009';
s.requantizationTableId   = 200;

save([outputFileLocationStr 'calSC_ETEM_2D_ST_SM_DC_NL_lu_ff_rn_qn_sn.mat'], 's');





%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + lde undershoot
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
s.outputDirectory         = 'calSC_ETEM_2D_ST_SM_DC_nl_LU_ff_rn_qn_sn_dir';
s.filename                = 'calSC_ETEM_2D_ST_SM_DC_nl_LU_ff_rn_qn_sn';
s.numCadences             = 50;
s.ccdModule               = 7;
s.ccdOutput               = 4;
s.cadenceType             = 'short';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = true;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'ort4b_trimmed_sc3';
s.refPixTargetListSetName = 'ort4b_trimmed_rp'; 
s.runStartDate            = '1-April-2009';
s.requantizationTableId   = 200;

save([outputFileLocationStr 'calSC_ETEM_2D_ST_SM_DC_nl_LU_ff_rn_qn_sn.mat'], 's');






%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + flat
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
s.outputDirectory         = 'calSC_ETEM_2D_ST_SM_DC_nl_lu_FF_rn_qn_sn_dir';
s.filename                = 'calSC_ETEM_2D_ST_SM_DC_nl_lu_FF_rn_qn_sn';
s.numCadences             = 50;
s.ccdModule               = 7;
s.ccdOutput               = 4;
s.cadenceType             = 'short';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = true;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'ort4b_trimmed_sc3';
s.refPixTargetListSetName = 'ort4b_trimmed_rp'; 
s.runStartDate            = '1-April-2009';
s.requantizationTableId   = 200;

save([outputFileLocationStr 'calSC_ETEM_2D_ST_SM_DC_nl_lu_FF_rn_qn_sn.mat'], 's');



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + nonlin + undershoot + flat
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
s.outputDirectory         = 'calSC_ETEM_2D_ST_SM_DC_NL_LU_FF_rn_qn_sn_dir';
s.filename                = 'calSC_ETEM_2D_ST_SM_DC_NL_LU_FF_rn_qn_sn';
s.numCadences             = 50;
s.ccdModule               = 7;
s.ccdOutput               = 4;
s.cadenceType             = 'short';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = true;
s.undershootEnabled             = true;
s.flatFieldEnabled              = true;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'ort4b_trimmed_sc3';
s.refPixTargetListSetName = 'ort4b_trimmed_rp'; 
s.runStartDate            = '1-April-2009';
s.requantizationTableId   = 200;

save([outputFileLocationStr 'calSC_ETEM_2D_ST_SM_DC_NL_LU_FF_rn_qn_sn.mat'], 's');




%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + nonlin + undershoot + flat + noise
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
s.outputDirectory         = 'calSC_ETEM_2D_ST_SM_DC_NL_LU_FF_RN_QN_SN_dir';
s.filename                = 'calSC_ETEM_2D_ST_SM_DC_NL_LU_FF_RN_QN_SN';
s.numCadences             = 50;
s.ccdModule               = 7;
s.ccdOutput               = 4;
s.cadenceType             = 'short';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = true;
s.undershootEnabled             = true;
s.flatFieldEnabled              = true;

s.readNoiseEnabled              = true;
s.quantNoiseEnabled             = true;
s.shotNoiseEnabled              = true;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'ort4b_trimmed_sc3';
s.refPixTargetListSetName = 'ort4b_trimmed_rp'; 
s.runStartDate            = '1-April-2009';
s.requantizationTableId   = 200;

save([outputFileLocationStr 'calSC_ETEM_2D_ST_SM_DC_NL_LU_FF_RN_QN_SN.mat'], 's');








return;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black only
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
s.outputDirectory         = 'calSC_ETEM_2D_st_sm_dc_nl_lu_ff_rn_qn_sn_dir';
s.filename                = 'calSC_ETEM_2D_st_sm_dc_nl_lu_ff_rn_qn_sn';
s.numCadences             = 50;
s.ccdModule               = 7;
s.ccdOutput               = 4;
s.cadenceType             = 'short';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = false;
s.smearEnabled                  = false;
s.darkEnabled                   = false;
s.darkCurrentValue              = 0;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'ort4b_trimmed_sc3';
s.refPixTargetListSetName = 'ort4b_trimmed_rp'; 
s.runStartDate            = '1-April-2009';
s.requantizationTableId   = 200;

save([outputFileLocationStr 'calSC_ETEM_2D_st_sm_dc_nl_lu_ff_rn_qn_sn.mat'], 's');




return;











%  LONG CADENCE: 
%
%--------------------------------------------------------------------------
% CAL ground truth etem2 runs for calibration  (5 cadences)
%--------------------------------------------------------------------------
% calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn   % all effects off, no noise
%
% calETEM_2D_st_sm_dc_nl_lu_ff_rn_qn_sn   % 2d black only
%
% calETEM_2D_ST_sm_dc_nl_lu_ff_rn_qn_sn   % 2d black + stars
%
% calETEM_2D_ST_SM_dc_nl_lu_ff_rn_qn_sn   % 2d black + stars + smear
%
% calETEM_2D_ST_sm_DC_nl_lu_ff_rn_qn_sn   % 2d black + stars + dark
%
% calETEM_2D_ST_SM_DC_nl_lu_ff_rn_qn_sn   % 2d black + stars + smear + dark  % <--- use this output to compare with all results from the runs below
%
%
% Note: all remaining runs will have 2d black + stars + smear + dark
%--------------------------------------------------------------------------
% individual effects  (5 cadences)
%--------------------------------------------------------------------------
%
% calETEM_2D_ST_SM_DC_NL_lu_ff_rn_qn_sn   % 2d black + stars + smear + dark + nonlin
%
% calETEM_2D_ST_SM_DC_nl_LU_ff_rn_qn_sn   % 2d black + stars + smear + dark + undershoot
%
% calETEM_2D_ST_SM_DC_nl_lu_FF_rn_qn_sn   % 2d black + stars + smear + dark + flat field
%
%--------------------------------------------------------------------------
% roll-up  (5 cadences)
%--------------------------------------------------------------------------
%
% calETEM_2D_ST_SM_DC_NL_LU_ff_rn_qn_sn   % 2d black + stars + smear + dark + nonlin + undershoot
%
% calETEM_2D_ST_SM_DC_NL_LU_FF_rn_qn_sn   % 2d black + stars + smear + dark + nonlin + undershoot + flat field
%
%--------------------------------------------------------------------------
% POU:  For each run above, run etem2 for the following  (100 cadences)
%--------------------------------------------------------------------------
% calETEM_xx_RN_QN_SN

% all effects off, no noise
s.outputDirectory         = 'calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn_dir';
s.filename                = 'calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn';
s.numCadences             = 5;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = false;
s.starsEnabled                  = false;
s.smearEnabled                  = false;
s.darkEnabled                   = false;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black only
s.outputDirectory         = 'calETEM_2D_st_sm_dc_nl_lu_ff_rn_qn_sn_dir';
s.filename                = 'calETEM_2D_st_sm_dc_nl_lu_ff_rn_qn_sn';
s.numCadences             = 5;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = false;
s.smearEnabled                  = false;
s.darkEnabled                   = false;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_st_sm_dc_nl_lu_ff_rn_qn_sn.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars
s.outputDirectory         = 'calETEM_2D_ST_sm_dc_nl_lu_ff_rn_qn_sn_dir';
s.filename                = 'calETEM_2D_ST_sm_dc_nl_lu_ff_rn_qn_sn';
s.numCadences             = 5;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = false;
s.darkEnabled                   = false;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_sm_dc_nl_lu_ff_rn_qn_sn.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear
s.outputDirectory         = 'calETEM_2D_ST_SM_dc_nl_lu_ff_rn_qn_sn_dir';
s.filename                = 'calETEM_2D_ST_SM_dc_nl_lu_ff_rn_qn_sn';
s.numCadences             = 5;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = false;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_SM_dc_nl_lu_ff_rn_qn_sn.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + dark
s.outputDirectory         = 'calETEM_2D_ST_sm_DC_nl_lu_ff_rn_qn_sn_dir';
s.filename                = 'calETEM_2D_ST_sm_DC_nl_lu_ff_rn_qn_sn';
s.numCadences             = 5;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = false;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_sm_DC_nl_lu_ff_rn_qn_sn.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark
s.outputDirectory         = 'calETEM_2D_ST_SM_DC_nl_lu_ff_rn_qn_sn_dir';
s.filename                = 'calETEM_2D_ST_SM_DC_nl_lu_ff_rn_qn_sn';
s.numCadences             = 5;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_SM_DC_nl_lu_ff_rn_qn_sn.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + nonlin
s.outputDirectory         = 'calETEM_2D_ST_SM_DC_NL_lu_ff_rn_qn_sn_dir';
s.filename                = 'calETEM_2D_ST_SM_DC_NL_lu_ff_rn_qn_sn';
s.numCadences             = 5;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = true;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_SM_DC_NL_lu_ff_rn_qn_sn.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + undershoot

s.outputDirectory         = 'calETEM_2D_ST_SM_DC_nl_LU_ff_rn_qn_sn_dir';
s.filename                = 'calETEM_2D_ST_SM_DC_nl_LU_ff_rn_qn_sn';
s.numCadences             = 5;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = true;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_SM_DC_nl_LU_ff_rn_qn_sn.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + flat field

s.outputDirectory         = 'calETEM_2D_ST_SM_DC_nl_lu_FF_rn_qn_sn_dir';
s.filename                = 'calETEM_2D_ST_SM_DC_nl_lu_FF_rn_qn_sn';
s.numCadences             = 5;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = true;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_SM_DC_nl_lu_FF_rn_qn_sn.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + nonlin + undershoot

s.outputDirectory         = 'calETEM_2D_ST_SM_DC_NL_LU_ff_rn_qn_sn_dir';
s.filename                = 'calETEM_2D_ST_SM_DC_NL_LU_ff_rn_qn_sn';
s.numCadences             = 5;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = true;
s.undershootEnabled             = true;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_SM_DC_NL_LU_ff_rn_qn_sn.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + nonlin + undershoot + flat field

s.outputDirectory         = 'calETEM_2D_ST_SM_DC_NL_LU_FF_rn_qn_sn_dir';
s.filename                = 'calETEM_2D_ST_SM_DC_NL_LU_FF_rn_qn_sn';
s.numCadences             = 5;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = true;
s.undershootEnabled             = true;
s.flatFieldEnabled              = true;

s.readNoiseEnabled              = false;
s.quantNoiseEnabled             = false;
s.shotNoiseEnabled              = false;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_SM_DC_NL_LU_FF_rn_qn_sn.mat'], 's');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% POU runs 200 cadences
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% create input structs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% all effects off, no noise
s.outputDirectory         = 'calETEM_2d_st_sm_dc_nl_lu_ff_RN_QN_SN_dir';
s.filename                = 'calETEM_2d_st_sm_dc_nl_lu_ff_RN_QN_SN';
s.numCadences             = 200;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = false;
s.starsEnabled                  = false;
s.smearEnabled                  = false;
s.darkEnabled                   = false;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = true;
s.quantNoiseEnabled             = true;
s.shotNoiseEnabled              = true;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2d_st_sm_dc_nl_lu_ff_RN_QN_SN.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black only
s.outputDirectory         = 'calETEM_2D_st_sm_dc_nl_lu_ff_RN_QN_SN_dir';
s.filename                = 'calETEM_2D_st_sm_dc_nl_lu_ff_RN_QN_SN';
s.numCadences             = 200;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = false;
s.smearEnabled                  = false;
s.darkEnabled                   = false;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = true;
s.quantNoiseEnabled             = true;
s.shotNoiseEnabled              = true;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_st_sm_dc_nl_lu_ff_RN_QN_SN.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars
s.outputDirectory         = 'calETEM_2D_ST_sm_dc_nl_lu_ff_RN_QN_SN_dir';
s.filename                = 'calETEM_2D_ST_sm_dc_nl_lu_ff_RN_QN_SN';
s.numCadences             = 200;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = false;
s.darkEnabled                   = false;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = true;
s.quantNoiseEnabled             = true;
s.shotNoiseEnabled              = true;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_sm_dc_nl_lu_ff_RN_QN_SN.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear
s.outputDirectory         = 'calETEM_2D_ST_SM_dc_nl_lu_ff_RN_QN_SN_dir';
s.filename                = 'calETEM_2D_ST_SM_dc_nl_lu_ff_RN_QN_SN';
s.numCadences             = 200;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = false;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = true;
s.quantNoiseEnabled             = true;
s.shotNoiseEnabled              = true;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_SM_dc_nl_lu_ff_RN_QN_SN.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + dark
s.outputDirectory         = 'calETEM_2D_ST_sm_DC_nl_lu_ff_RN_QN_SN_dir';
s.filename                = 'calETEM_2D_ST_sm_DC_nl_lu_ff_RN_QN_SN';
s.numCadences             = 200;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = false;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = true;
s.quantNoiseEnabled             = true;
s.shotNoiseEnabled              = true;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_sm_DC_nl_lu_ff_RN_QN_SN.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark
s.outputDirectory         = 'calETEM_2D_ST_SM_DC_nl_lu_ff_RN_QN_SN_dir';
s.filename                = 'calETEM_2D_ST_SM_DC_nl_lu_ff_RN_QN_SN';
s.numCadences             = 200;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = true;
s.quantNoiseEnabled             = true;
s.shotNoiseEnabled              = true;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_SM_DC_nl_lu_ff_RN_QN_SN.mat'], 's');

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + nonlin
s.outputDirectory         = 'calETEM_2D_ST_SM_DC_NL_lu_ff_RN_QN_SN_dir';
s.filename                = 'calETEM_2D_ST_SM_DC_NL_lu_ff_RN_QN_SN';
s.numCadences             = 200;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = true;
s.undershootEnabled             = false;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = true;
s.quantNoiseEnabled             = true;
s.shotNoiseEnabled              = true;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_SM_DC_NL_lu_ff_RN_QN_SN.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + undershoot

s.outputDirectory         = 'calETEM_2D_ST_SM_DC_nl_LU_ff_RN_QN_SN_dir';
s.filename                = 'calETEM_2D_ST_SM_DC_nl_LU_ff_RN_QN_SN';
s.numCadences             = 200;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = true;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = true;
s.quantNoiseEnabled             = true;
s.shotNoiseEnabled              = true;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_SM_DC_nl_LU_ff_RN_QN_SN.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + flat field

s.outputDirectory         = 'calETEM_2D_ST_SM_DC_nl_lu_FF_RN_QN_SN_dir';
s.filename                = 'calETEM_2D_ST_SM_DC_nl_lu_FF_RN_QN_SN';
s.numCadences             = 200;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = false;
s.undershootEnabled             = false;
s.flatFieldEnabled              = true;

s.readNoiseEnabled              = true;
s.quantNoiseEnabled             = true;
s.shotNoiseEnabled              = true;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_SM_DC_nl_lu_FF_RN_QN_SN.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + nonlin + undershoot

s.outputDirectory         = 'calETEM_2D_ST_SM_DC_NL_LU_ff_RN_QN_SN_dir';
s.filename                = 'calETEM_2D_ST_SM_DC_NL_LU_ff_RN_QN_SN';
s.numCadences             = 200;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = true;
s.undershootEnabled             = true;
s.flatFieldEnabled              = false;

s.readNoiseEnabled              = true;
s.quantNoiseEnabled             = true;
s.shotNoiseEnabled              = true;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_SM_DC_NL_LU_ff_RN_QN_SN.mat'], 's');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2d black + stars + smear + dark + nonlin + undershoot + flat field

s.outputDirectory         = 'calETEM_2D_ST_SM_DC_NL_LU_FF_RN_QN_SN_dir';
s.filename                = 'calETEM_2D_ST_SM_DC_NL_LU_FF_RN_QN_SN';
s.numCadences             = 200;
s.ccdModule               = 7;
s.ccdOutput               = 3;
s.cadenceType             = 'long';
s.twoDBlackEnabled              = true;
s.starsEnabled                  = true;
s.smearEnabled                  = true;
s.darkEnabled                   = true;
s.darkCurrentValue              = 2;

s.nonlinearityEnabled           = true;
s.undershootEnabled             = true;
s.flatFieldEnabled              = true;

s.readNoiseEnabled              = true;
s.quantNoiseEnabled             = true;
s.shotNoiseEnabled              = true;
s.cosmicRaysEnabled       = false;
s.supressAllMotionFlag    = true;
s.makeCleanFlag           = false;
s.targetListSetName       = 'q1-lc';
s.refPixTargetListSetName = 'q1-rp';
s.runStartDate = '1-April-2009';
s.requantizationTableId   = 175;

save([outputFileLocationStr 'calETEM_2D_ST_SM_DC_NL_LU_FF_RN_QN_SN.mat'], 's');


%--------------------------------------------------------------------------
% set permissions
%--------------------------------------------------------------------------
cd('/path/to/matlab/cal/')
!chmod 777 *.mat
cd('/path/to/matlab/etem2/mfiles')


return;

