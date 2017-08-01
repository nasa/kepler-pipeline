function run_cal_with_etem2_inputs(etem2ParametersString,  getRequantizedPixFlag, includeCosmicRaysFlag)
%
%
% This function loads the inputs created from an ETEM2 run:
%
%  calInputs_calETEM_xxx.mat    loads calCollateralInputs and calPhotometricInputs
%
% where xxx indicates which CAL features are included in that run:
%
% ex:  calETEM_2D_ST_SM_DC_NL_LU_FF_RN_QN_SN.mat
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
%  RQ       requantized
%  rq       not requantized
%  CR       with cosmic rays       
%  cr       without cosmic rays
%
% Upper case letters in filename indicate the effects are on (enabled)
% Lower case letters indicate that the effects are off
%--------------------------------------------------------------------------
%
% ex:  calInputs_calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn_RQ_cr.mat
%
%
% etem2ParametersString = '2D_ST_sm_DC_nl_lu_ff_RN_QN_SN'
%
% getRequantizedPixFlag includes '_RQ' if true, '_rq' if false
% includeCosmicRaysFlag includes '_CR' if true, '_cr' if false
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


cd(['/path/to/matlab/etem2/mfiles/calETEM_' etem2ParametersString '_dir/']);

%--------------------------------------------------------------------------
% load cal inputs
%--------------------------------------------------------------------------
if (getRequantizedPixFlag && ~includeCosmicRaysFlag)

    load(['/path/to/matlab/cal/calInputs_calETEM_' etem2ParametersString '_RQ_cr.mat']);  %  loads calCollateralInputs calPhotometricInputs
    calCollateralInputs.cadenceTimes.requantEnabled  = true(size(calCollateralInputs.cadenceTimes.requantEnabled));
    calPhotometricInputs.cadenceTimes.requantEnabled = true(size(calPhotometricInputs.cadenceTimes.requantEnabled));

    eval(['save /path/to/matlab/cal/calInputs_calETEM_', etem2ParametersString, '_RQ_cr.mat calCollateralInputs calPhotometricInputs']);
    eval(['save calInputs_calETEM_', etem2ParametersString, '_RQ_cr.mat calCollateralInputs calPhotometricInputs']);


elseif (getRequantizedPixFlag && includeCosmicRaysFlag)

    load(['/path/to/matlab/cal/calInputs_calETEM_' etem2ParametersString '_RQ_CR.mat']);  %  loads calCollateralInputs calPhotometricInputs
    calCollateralInputs.cadenceTimes.requantEnabled  = true(size(calCollateralInputs.cadenceTimes.requantEnabled));
    calPhotometricInputs.cadenceTimes.requantEnabled = true(size(calPhotometricInputs.cadenceTimes.requantEnabled));

    eval(['save /path/to/matlab/cal/calInputs_calETEM_', etem2ParametersString, '_RQ_CR.mat calCollateralInputs calPhotometricInputs']);
    eval(['save calInputs_calETEM_', etem2ParametersString, '_RQ_CR.mat calCollateralInputs calPhotometricInputs']);

elseif (~getRequantizedPixFlag && ~includeCosmicRaysFlag)

    load(['/path/to/matlab/cal/calInputs_calETEM_' etem2ParametersString '_rq_cr.mat']);  %  loads calCollateralInputs calPhotometricInputs
    calCollateralInputs.cadenceTimes.requantEnabled  = false(size(calCollateralInputs.cadenceTimes.requantEnabled));
    calPhotometricInputs.cadenceTimes.requantEnabled = false(size(calPhotometricInputs.cadenceTimes.requantEnabled));

    eval(['save /path/to/matlab/cal/calInputs_calETEM_', etem2ParametersString, '_rq_cr.mat calCollateralInputs calPhotometricInputs']);
    eval(['save calInputs_calETEM_', etem2ParametersString, '_rq_cr.mat calCollateralInputs calPhotometricInputs']);

elseif  (~getRequantizedPixFlag && includeCosmicRaysFlag)

    load(['/path/to/matlab/cal/calInputs_calETEM_' etem2ParametersString '_rq_CR.mat']);  %  loads calCollateralInputs calPhotometricInputs
    calCollateralInputs.cadenceTimes.requantEnabled  = false(size(calCollateralInputs.cadenceTimes.requantEnabled));
    calPhotometricInputs.cadenceTimes.requantEnabled = false(size(calPhotometricInputs.cadenceTimes.requantEnabled));

    eval(['save /path/to/matlab/cal/calInputs_calETEM_', etem2ParametersString, '_rq_CR.mat calCollateralInputs calPhotometricInputs']);
    eval(['save calInputs_calETEM_', etem2ParametersString, '_rq_CR.mat calCollateralInputs calPhotometricInputs']);

end


%--------------------------------------------------------------------------
% run data through CAL (default is pouEnabled=true and debugLevel=2)
%--------------------------------------------------------------------------
calCollateralOutputs  = cal_matlab_controller(calCollateralInputs);
calPhotometricOutputs = cal_matlab_controller(calPhotometricInputs);


%--------------------------------------------------------------------------
% save output structs:  calOutputs_calETEM_xxx
%--------------------------------------------------------------------------
if (getRequantizedPixFlag && ~includeCosmicRaysFlag)

    save(['calOutputs_calETEM_' etem2ParametersString '_RQ_cr.mat'], 'calCollateralOutputs', 'calPhotometricOutputs');

    save(['/path/to/matlab/cal/calOutputs_calETEM_' etem2ParametersString '_RQ_cr.mat'], 'calCollateralOutputs', 'calPhotometricOutputs');

elseif (getRequantizedPixFlag && includeCosmicRaysFlag)

    save(['calOutputs_calETEM_' etem2ParametersString '_RQ_CR.mat'], 'calCollateralOutputs', 'calPhotometricOutputs');

    save(['/path/to/matlab/cal/calOutputs_calETEM_' etem2ParametersString '_RQ_CR.mat'], 'calCollateralOutputs', 'calPhotometricOutputs');

elseif (~getRequantizedPixFlag && ~includeCosmicRaysFlag)

    save(['calOutputs_calETEM_' etem2ParametersString '_rq_cr.mat'], 'calCollateralOutputs', 'calPhotometricOutputs');

    save(['/path/to/matlab/cal/calOutputs_calETEM_' etem2ParametersString '_rq_cr.mat'], 'calCollateralOutputs', 'calPhotometricOutputs');

elseif  (~getRequantizedPixFlag && includeCosmicRaysFlag)

    save(['calOutputs_calETEM_' etem2ParametersString '_rq_CR.mat'], 'calCollateralOutputs', 'calPhotometricOutputs');

    save(['/path/to/matlab/cal/calOutputs_calETEM_' etem2ParametersString '_rq_CR.mat'], 'calCollateralOutputs', 'calPhotometricOutputs');    
end



%--------------------------------------------------------------------------
% save intermediate structs:  calIntermedStructs_xxx
%--------------------------------------------------------------------------
%   ex. collateral_data_18_Dec_2008_14_03_20
%       photometric_data_part1_18_Dec_2008_14_12_33

collateralDir  = dir('collateral_data*Jan*');
photometricDir = dir('photometric_data*Jan*');

load([collateralDir(end).name '/calCollateralIntermediateDataStruct.mat']);
load([photometricDir(end).name '/calPhotometricIntermediateDataStruct1.mat']);



if (getRequantizedPixFlag && ~includeCosmicRaysFlag)

    save(['calIntermedStructs_' etem2ParametersString '_RQ_cr.mat'], 'calCollateralIntermediateStruct', 'calPhotometricIntermediateStruct_1');

    save(['/path/to/matlab/cal/calIntermedStructs_' etem2ParametersString '_RQ_cr.mat'], 'calCollateralIntermediateStruct', 'calPhotometricIntermediateStruct_1');
 
elseif (getRequantizedPixFlag && includeCosmicRaysFlag)
   
    save(['calIntermedStructs_' etem2ParametersString '_RQ_CR.mat'], 'calCollateralIntermediateStruct', 'calPhotometricIntermediateStruct_1');

    save(['/path/to/matlab/cal/calIntermedStructs_' etem2ParametersString '_RQ_CR.mat'], 'calCollateralIntermediateStruct', 'calPhotometricIntermediateStruct_1');

elseif (~getRequantizedPixFlag && ~includeCosmicRaysFlag)
     
    save(['calIntermedStructs_' etem2ParametersString '_rq_cr.mat'], 'calCollateralIntermediateStruct', 'calPhotometricIntermediateStruct_1');

    save(['/path/to/matlab/cal/calIntermedStructs_' etem2ParametersString '_rq_cr.mat'], 'calCollateralIntermediateStruct', 'calPhotometricIntermediateStruct_1');

elseif  (~getRequantizedPixFlag && includeCosmicRaysFlag)
 
    save(['calIntermedStructs_' etem2ParametersString '_rq_CR.mat'], 'calCollateralIntermediateStruct', 'calPhotometricIntermediateStruct_1');

    save(['/path/to/matlab/cal/calIntermedStructs_' etem2ParametersString '_rq_CR.mat'], 'calCollateralIntermediateStruct', 'calPhotometricIntermediateStruct_1');    
end



%--------------------------------------------------------------------------
% set permissions
%--------------------------------------------------------------------------
cd('/path/to/matlab/cal/')
!chmod 777 *.mat
cd('/path/to/matlab/etem2/mfiles')

return;

