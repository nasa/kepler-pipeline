function eeMetricStruct = collect_ee_radius_from_super_resolution_prf(modOutsProcessed, fcConstantsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function eeMetricStruct = collect_ee_radius_from_super_resolution_prf(modOutsProcessed, fcConstantsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


if(~exist('modOutsProcessed', 'var') || isempty(modOutsProcessed))
    load attitudeSolutionStruct % has modOutsProcessed, nModOuts
end

if(~exist('fcConstantsStruct', 'var') || isempty(fcConstantsStruct))
    load pdq-inputs-0.mat % has fcConstants
    fcConstantsStruct = inputsStruct.fcConstants;
end

nModOuts = length(modOutsProcessed);

fprintf('\n\n---------------------------------------------------------------------------------\n');
fprintf('PDQ:Starting encircled energy computation using super resolution prfs for %d ...\n', nModOuts);
fprintf('---------------------------------------------------------------------------------\n');

eeMetricStruct = repmat(struct('eeRadiusFromPrf', [], 'encircledEnergies', [], 'encircledEnergiesUncertainties', []), nModOuts,1);
totalTimeToComputeEeRadiusUsingPrfs = 0;

for currentModOut = find(modOutsProcessed(:)')

    if(~modOutsProcessed(currentModOut))
        continue;
    end
    sFileName = ['pdqTempStruct_' num2str(currentModOut) '.mat'];

    % check to see the existence ofthe .mat file

    if(~exist(sFileName, 'file'))
        continue;
    end

    tStartForPrfEe = tic;
    load(sFileName, 'pdqTempStruct');
    pdqTempStruct = compute_ee_radius_from_super_resolution_prf(pdqTempStruct, fcConstantsStruct);
    timeToComputeEeFromPrf = toc(tStartForPrfEe);


    totalTimeToComputeEeRadiusUsingPrfs = totalTimeToComputeEeRadiusUsingPrfs + timeToComputeEeFromPrf;

    fprintf('Time taken to compute encircled energy using super resolution prf for %d mod/out is %f seconds\n', currentModOut, timeToComputeEeFromPrf);

    eeMetricStruct(currentModOut).eeRadiusFromPrf =  pdqTempStruct.eeRadiusFromPrf;

    eeMetricStruct(currentModOut).encircledEnergies =  pdqTempStruct.encircledEnergies;
    eeMetricStruct(currentModOut).encircledEnergiesUncertainties =  pdqTempStruct.encircledEnergiesUncertainties;

    clear pdqTempStruct;

end

fprintf('\n\n---------------------------------------------------------------------------------\n');
fprintf('Time taken to compute encircled energy using super resolution prf for %d modouts is %f seconds\n', nModOuts, totalTimeToComputeEeRadiusUsingPrfs);
fprintf('---------------------------------------------------------------------------------\n');

return


