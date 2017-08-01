Copyright 2017 United States Government as represented by the
Administrator of the National Aeronautics and Space Administration.
All Rights Reserved.

NASA acknowledges the SETI Institute's primary role in authoring and
producing the Kepler Data Processing Pipeline under Cooperative
Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
NNX11AI14A, NNX13AD01A & NNX13AD16A.

This file is available under the terms of the NASA Open Source Agreement
(NOSA). You should have received a copy of this agreement with the
Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.

No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
AND DISTRIBUTES IT "AS IS."

Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
TERMINATION OF THIS AGREEMENT.

README_CAL_ETEM_FILES.txt

Description of files on /path/to/matlab/cal
  (other .m files noted below are located in cal/test/etem2_functions_for_cal_inputs/)
----------------------------------------------------
----------------------------------------------------

calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn.mat

	These .mat files contain a structure "s" which contains all of the 
	knobs that CAL uses for an etem run

	This file is created from construct_cal_input_structs_for_etem2()


example:

>> load calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn.mat

s = 
            outputDirectory: 'calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn_dir'
                   filename: 'calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn'
                numCadences: 5
                  ccdModule: 7
                  ccdOutput: 3
                cadenceType: 'long'
           twoDBlackEnabled: 0
               starsEnabled: 0
               smearEnabled: 0
                darkEnabled: 0
           darkCurrentValue: 2
        nonlinearityEnabled: 0
          undershootEnabled: 0
           flatFieldEnabled: 0
           readNoiseEnabled: 0
          quantNoiseEnabled: 0
           shotNoiseEnabled: 0
          cosmicRaysEnabled: 0
       supressAllMotionFlag: 1
              makeCleanFlag: 0
          targetListSetName: 'q1-lc'
    refPixTargetListSetName: 'q1-rp'
               runStartDate: '1-April-2009'
      requantizationTableId: 175

 This structure s is passed into a modified (for CAL) etem2 
 input parameters function as follows:
 
  gloabalConfigurationStruct = create_cal_etem2_inputs(s)

  (see last entry in this file)


----------------------------------------------------
----------------------------------------------------
calInputs_calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn_RQ_cr.mat

	This file contains two CAL input structures that
	are created from etem2 output data. 
 
	See run_etem2_for_cal_pou.m, which calls:
	        run_etem2_and_construct_cal_inputs.m
	which runs etem2 and calls:
	      	set_cal_input_struct

example:

	calCollateralInputs    
  	calPhotometricInputs   


----------------------------------------------------
----------------------------------------------------
calIntermedStructs_2d_st_sm_dc_nl_lu_ff_rn_qn_sn_RQ_cr.mat

	This file contains the intermediate data structs
	created during a CAL run

example:

	calCollateralIntermediateStruct        
  	calPhotometricIntermediateStruct_1    


----------------------------------------------------
----------------------------------------------------
calOutputs_calETEM_2d_st_sm_dc_nl_lu_ff_rn_qn_sn_RQ_cr.mat

	This file contains the outputs from the CAL run

example:
	
	calCollateralOutputs      
  	calPhotometricInputs    

----------------------------------------------------
----------------------------------------------------
ccdObject_params_2d_st_sm_dc_nl_lu_ff_rn_qn_sn.mat

	This file contains the parameters that were
	actually used in an etem run.

	See run_cal_batch_with_etem2_inputs.m, which 
	calls (in batch) run_cal_with_etem2_inputs.m
	
	The ccdObject is loaded for each etem run,
	and relevant data are saved to
	dataUsedByEtemStruct = get_ccdObject_parameters(ccdObject)

example:

dataUsedByEtemStruct = 
              etem2_outputDir: './calETEM_2D_st_sm_dc_nl_lu_ff_rn_qn_sn_dir/run_long_m7o3s1'
         etem2_outputLocation: './calETEM_2D_st_sm_dc_nl_lu_ff_rn_qn_sn_dir'
            etem2_numCadences: 5
               etem2_startMjd: 54922
                 etem2_endMjd: 5.4922e+04
         etem2_cadencesPerDay: 48.9389
    etem2_nonlinearityEnabled: 0
                   etem2_gain: 111.0900
              etem2_meanBlack: 722
          etem2_fixedOffsetLC: 419405
          etem2_fixedOffsetSC: 419405
         etem2_requantTableId: 175
           etem2_requantTable: [65536x1 double]
         etem2_2dBlackEnabled: 1
      etem2_2DBlackArrayInAdu: [1070x1132 double]
      etem2_undershootEnabled: 0
       etem2_shotNoiseEnabled: 0
           etem2_smearEnabled: 0
     etem2_darkCurrentEnabled: 0
       etem2_darkCurrentValue: 0
       etem2_flatFieldEnabled: 0
       etem2_cosmicRayEnabled: 0
     etem2_suppressMotionFlag: 1
      etem2_suppressStarsFlag: 1
      etem2_quantNoiseEnabled: 0


----------------------------------------------------
----------------------------------------------------
gloabalConfigurationStruct_2d_st_sm_dc_nl_lu_ff_rn_qn_sn.mat

	This file contains the structure that is passed into
	etem2(gloabalConfigurationStruct),

	Each gloabalConfigurationStruct is created from the 
	input structure "s" (see first description of this file):
 	gloabalConfigurationStruct = create_cal_etem2_inputs(s)

example:

gloabalConfigurationStruct_2D_st_sm_dc_nl_lu_ff_rn_qn_sn = 
        runParamsData: [1x1 struct]
              ccdData: [1x1 struct]
         tadInputData: [1x1 struct]
    catalogReaderData: [1x1 struct]
