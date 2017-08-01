function run_calpou_etem2(s)
%function run_calpou_etem2(s)
%
% This function runs ETEM2 for a given input struct s, which was created
% for each CAL configuration in construct_cal_input_structs_for_etem2
%
%   example:
%   s = 
%             outputDirectory: 'calETEM_2D_ST_sm_DC_nl_lu_ff_RN_QN_SN_dir'
%                    filename: 'calETEM_2D_ST_sm_DC_nl_lu_ff_RN_QN_SN'
%                 numCadences: 200
%                   ccdModule: 7
%                   ccdOutput: 3
%                 cadenceType: 'long'
%            twoDBlackEnabled: 1
%                starsEnabled: 1
%                smearEnabled: 0
%                 darkEnabled: 1
%            darkCurrentValue: 2
%         nonlinearityEnabled: 0
%           undershootEnabled: 0
%            flatFieldEnabled: 0
%            readNoiseEnabled: 1
%           quantNoiseEnabled: 1
%            shotNoiseEnabled: 1
%           cosmicRaysEnabled: 0
%        supressAllMotionFlag: 1
%               makeCleanFlag: 0
%           targetListSetName: 'q1-lc'
%     refPixTargetListSetName: 'q1-rp'
%                runStartDate: '1-April-2009'
%       requantizationTableId: 175
%
% Note: clear classes prior to running this function
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

etem2inputFilename  = s.filename;

%--------------------------------------------------------------------------
% run ETEM2
%--------------------------------------------------------------------------
    tic
    etem2(create_cal_etem2_inputs(s))

    duration = toc;
    display(['ETEM2 run ' etem2inputFilename ' complete: ' num2str(duration/60) ' minutes']);


return;
