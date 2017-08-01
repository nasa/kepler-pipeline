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

warning off all
notConverged = true;
iterationCount = 1;
while notConverged && iterationCount < 10
    
    if iterationCount == 1
        fpgInputStruct = make_fpg_inputs_from_pa(paOutputs, exampleFpgInputsStruct);
        fpgInputStruct.fpgModuleParameters.reportGenerationEnabled = false;
        fpgOutputStruct = fpg_matlab_controller(fpgInputStruct);

        for i=1:length(paOutputs)
            prfInputStruct(i) = make_prf_inputs_from_pa(paOutputs(i), ...
                paInputs(i), fpgOutputStruct);
            prfInputStruct(i).prfConfigurationStruct.numPrfsPerChannel = 5;
            prfInputStruct(i).prfConfigurationStruct.magnitudeRange = [12 13.5];
            
            prfResultStruct(i) = prf_matlab_controller(prfInputStruct(i));
            
            % save the result data
            sourceFilename = ['prfResultData_m' num2str(prfInputStruct(i).ccdModule) ...
                'o' num2str(prfInputStruct(i).ccdOutput)];
            destFilename = [sourceFilename 'i' num2str(iterationCount)];
            movefile([sourceFilename '.mat'], [destFilename '.mat']);

            % save the centroid convergence data
            sourceFilename = ['centroidChangeData_m' num2str(prfInputStruct(i).ccdModule) ...
                'o' num2str(prfInputStruct(i).ccdOutput)];
            destFilename = [sourceFilename 'i' num2str(iterationCount)];
            movefile([sourceFilename '.mat'], [destFilename '.mat']);
        end
        clear paInputs paOutputs
    else
        fpgInputStruct = make_fpg_inputs_from_prf(prfResultStruct, ...
            fpgOutputStruct, exampleFpgInputsStruct);
        fpgInputStruct.fpgModuleParameters.reportGenerationEnabled = false;
        fpgOutputStruct = fpg_matlab_controller(fpgInputStruct);

        for i=1:length(prfResultStruct)
            prfInputStruct(i) = make_prf_inputs_from_prf(prfResultStruct(i), ...
                prfInputStruct(i), fpgOutputStruct);
            prfInputStruct(i).prfConfigurationStruct.numPrfsPerChannel = 5;
            prfInputStruct(i).prfConfigurationStruct.magnitudeRange = [12 13.5];

            prfResultStruct(i) = prf_matlab_controller(prfInputStruct(i));
            
            % save the result data
            sourceFilename = ['prfResultData_m' num2str(prfInputStruct(i).ccdModule) ...
                'o' num2str(prfInputStruct(i).ccdOutput)];
            destFilename = [sourceFilename 'i' num2str(iterationCount)];
            movefile([sourceFilename '.mat'], [destFilename '.mat']);

            % save the centroid convergence data
            sourceFilename = ['centroidChangeData_m' num2str(prfInputStruct(i).ccdModule) ...
                'o' num2str(prfInputStruct(i).ccdOutput)];
            destFilename = [sourceFilename 'i' num2str(iterationCount)];
            movefile([sourceFilename '.mat'], [destFilename '.mat']);
        end
    end
    
    % save the intputs and outputs
    save(['prfIteration_i' num2str(iterationCount) '.mat'], 'fpgInputStruct', ...
        'fpgOutputStruct', 'prfInputStruct', 'prfResultStruct');


    iterationCount = iterationCount + 1;
end
    
    
