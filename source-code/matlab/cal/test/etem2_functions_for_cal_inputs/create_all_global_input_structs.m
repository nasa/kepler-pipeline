function create_all_global_input_structs(etem2ParametersString)
%function create_all_global_input_structs(etem2ParametersString)
%
% function to create the gloabalConfigurationStruct that is input into
% ETEM2 for a run with the given input name
%
%
% For each input string (ex. '2d_st_sm_dc_nl_lu_ff_rn_qn_sn'), the
% structure "s" that was created in set_input_structs_for_etem2_cal_runs.m
% is loaded, and used to create the gloabalConfigurationStruct that is
% input into etem2:
% 
% ex. gloabalConfigurationStruct_2d_st_sm_dc_nl_lu_ff_rn_qn_sn.mat
%
% gloabalConfigurationStruct_2d_st_sm_dc_nl_lu_ff_rn_qn_sn = 
%         runParamsData: [1x1 struct]
%               ccdData: [1x1 struct]
%          tadInputData: [1x1 struct]
%     catalogReaderData: [1x1 struct]
%
%
% ETEM2 is run as follows:   
%    etem2(gloabalConfigurationStruct)
%
% A matfile with the gloabalConfigurationStruct is saved in each etem2 run
% dir and to path/to/matlab/cal
%--------------------------------------------------------------------------
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

cd('/path/to/matlab/etem2/mfiles')

%--------------------------------------------------------------------------
% load the struct (s) which was input to etem2(create_cal_etem2_inputs(s))
%--------------------------------------------------------------------------
load(['calETEM_' etem2ParametersString '.mat']);

eval(['gloabalConfigurationStruct_' etem2ParametersString ' = create_cal_etem2_inputs(s)']);

% cd into etem2 run directory 
cd(['calETEM_' etem2ParametersString '_dir/'])

% save global struct which is input into etem2()
save(['gloabalConfigurationStruct_' etem2ParametersString '.mat'], ['gloabalConfigurationStruct_' etem2ParametersString]);

% save global struct
save(['/path/to/matlab/cal/gloabalConfigurationStruct_' etem2ParametersString '.mat'], ['gloabalConfigurationStruct_' etem2ParametersString]);

cd('/path/to/matlab/etem2/mfiles')

%--------------------------------------------------------------------------
% set permissions
%--------------------------------------------------------------------------
%cd('/path/to/matlab/cal/')
%!chmod 777 *.mat
%cd('/path/to/matlab/etem2/mfiles')

return;

