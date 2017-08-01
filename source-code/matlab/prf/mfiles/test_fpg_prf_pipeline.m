% script to run fpg/prf iteration loop
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
load fpgPrfPipelineTestData/paOutputs.mat % loads paOutputs()
load fpgPrfPipelineTestData/paInputs.mat % loads paInputs()
load fpgPrfPipelineTestData/fpgExampleInput.mat % loads exampleFpgInputsStruct

%%

fpgInputStruct = make_fpg_inputs_from_pa(paOutputs, exampleFpgInputsStruct);
fpgOutputStruct = fpg_matlab_controller(fpgInputStruct);

%%

load fpgPrfPipelineTestData/fpgOutput1.mat


%%
fpgOutputStruct.geometryBlobFileName = 'firstIterationTest4/geometryModelBlob_fpgOutput_20081224T233024.mat'
for i=1:1
    prfInputStruct(i) = make_prf_inputs_from_pa(paOutputs(i), paInputs(i), fpgOutputStruct);
    prfInputStruct(i).prfConfigurationStruct.magnitudeRange = [12 12.5];
    prfInputStruct(i).prfConfigurationStruct.numPrfsPerChannel = 5;

    prfResultStruct(i) = prf_matlab_controller(prfInputStruct(i));
end

%%

!mv prfResultData_m7o4.mat prfResultData_m7o4_1.mat
!mv prfResultData_m9o4.mat prfResultData_m9o4_1.mat
!mv prfResultData_m17o4.mat prfResultData_m17o4_1.mat
!mv prfResultData_m19o4.mat prfResultData_m19o4_1.mat

!mv centroidChangeData_m7o4.mat centroidChangeData_m7o4_1.mat
!mv centroidChangeData_m9o4.mat centroidChangeData_m9o4_1.mat
!mv centroidChangeData_m17o4.mat centroidChangeData_m17o4_1.mat
!mv centroidChangeData_m19o4.mat centroidChangeData_m19o4_1.mat

%%

fpgInputStruct2 = make_fpg_inputs_from_prf(prfResultStruct, fpgOutputStruct, exampleFpgInputsStruct);
fpgOutputStruct2 = fpg_matlab_controller(fpgInputStruct2);

%%
for i=1:length(paOutputs)
    prfInputStruct2(i) = make_prf_inputs_from_prf(prfResultStruct(i), prfInputStruct(i), fpgOutputStruct2);
    prfInputStruct2(i).prfConfigurationStruct.magnitudeRange = [12 12.5];

    prfResultStruct2(i) = prf_matlab_controller(prfInputStruct2(i));
end


