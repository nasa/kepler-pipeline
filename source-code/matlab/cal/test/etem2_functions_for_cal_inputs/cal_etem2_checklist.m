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
%function cal_etem2_checklist
%
% The following steps explain how to run ETEM2, convert ETEM2 target 
% definitions into pixel time series, and create two input structs for the 
% CAL CSCI for (1) collateral pixel data, and (2) photometric pixel data.
%
%
%  Note:   Modify scripts (to keep under version control) in:
%           /path/to/matlab/cal/test/etem2_functions_for_cal_inputs/
%
%          cd into /path/to/matlab/etem2/mfiles to run etem2 
%
%          outputFileLocationStr =  '/path/to/matlab/cal/'
%
%--------------------------------------------------------------------------   
%  Step 1: Configure CAL parameters (into struct "s") for ETEM2 batch run
%--------------------------------------------------------------------------   
%
%         Manually edit: 
%           ---------------------------------------------------------------
%               set_input_structs_for_etem2_cal_runs(outputFileLocationStr)
%           ---------------------------------------------------------------   
%
%         This function will set up and save a structure "s" (for each CAL 
%         desired configuration) that will eventually be input to run etem2:    
%               etem2(create_cal_etem2_inputs(s))
%
%         For each etem2 run, an "s" structure will be created as follows:
%
%           calETEM_2D_ST_SM_DC_NL_LU_FF_RN_QN_SN.mat
%
%           2D       two D black on
%           ST       stars on
%           SM       smear on
%           DC       dark current on
%           NL       nonlinearity on
%           LU       lde undershoot on
%           FF       flat field on
%           RN       read noise on
%           QN       quantization noise on
%           SN       shot noise on
%
%           Upper case letters in filename indicate the effects are on (enabled)
%           Lower case letters indicate that the effects are off
%
%       Note that for each etem run, the pixels can be extracted in the following ways:
%
%           RQ    requantized
%           rq    not requantized
%           CR    with cosmic rays        (if cosmic rays are enabled in this function)
%           cr    without cosmic rays
%
%--------------------------------------------------------------------------
%  Step 2: Run ETEM2 in batch, if desired
%--------------------------------------------------------------------------
%
%         Run: 
%           ---------------------------------------------------------------
%               run_etem2_in_batch()
%           ---------------------------------------------------------------   
%
%       This function loads each s structure, and runs etem2:
%
%           ex. load calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn.mat s
%               run_etem2(s);
%
%--------------------------------------------------------------------------
%  Step 3: Create the global configuration struct for each etem run
%--------------------------------------------------------------------------
%
%         Run: 
%           ---------------------------------------------------------------
%               create_all_global_input_structs_in_batch()
%           ---------------------------------------------------------------   
%
%       This function loads the aforementioned "s" structure, and saves the
%       gloabalConfigurationStruct to a matfile via:
%
%       create_all_global_input_structs(), which calls:
%       gloabalConfigurationStruct = create_cal_etem2_inputs(s)
%%--------------------------------------------------------------------------
%  Step 4: Construct CAL inputs in batch
%--------------------------------------------------------------------------
%
%         Run: 
%           ---------------------------------------------------------------
%               construct_cal_inputs_in_batch()
%           ---------------------------------------------------------------   
%
%       This function loads each s structure, and runs construct_cal_inputs:
%
%           construct_cal_inputs(s, getRequantizedPixFlag, includeCosmicRaysFlag)
%
%           ex. load calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn.mat s
%               construct_cal_inputs(s, 1, 0);  
%
%
%--------------------------------------------------------------------------
%  Step 5: Run CAL in batch
%--------------------------------------------------------------------------
%
%         Run: 
%           ---------------------------------------------------------------
%               run_cal_with_etem2_inputs_in_batch()
%           ---------------------------------------------------------------   
%
%       This function runs CAL and saves the CAL outputs and intermediate
%       structs to local and NFS directories
%
%--------------------------------------------------------------------------
