function rptsTargetsStruct = collect_reference_pixel_targets_for_all_modouts(targetListSetName)
%function rptsTargetsStruct = collect_reference_pixel_targets_for_all_modouts(targetListSetName)
%
% function to retrieve all reference pixel targets for all module/outputs 
% for a given reference pixel target list set.  An optimal aperture for all 
% reference pixel targets (apertures + halos + ldeUndershootColumn) can be
% created from the results.
% 
%
%
% targetListSets = retrieve_target_list_sets()
% ex: targetListSets(2) =
%  
%                    name: 'a-rp'
%                    type: 'Reference pixel'
%                   state: 'TAD completed and validated'
%               startDate: '2010-06-24 05:00:00.0'
%                 endDate: '2010-09-12 05:00:00.0'
%             targetLists: [1x1 struct]
%     excludedTargetLists: [1x0 struct]
%
%
% tadInputStruct = retrieve_tad(module, output, targetListSetName, includeRejected)
%  
%  tadInputStruct.targets:  1x19 struct array with fields:
%     keplerId
%     labels
%     referenceRow
%     referenceColumn
%     offsets
%     snr
%     badPixelCount
%     crowdingMetric
%     fluxFractionInAperture
%     rejected
%     signalToNoiseRatio
%     distanceFromEdge
%     isUserDefined
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


% allocate memory for rpts target struct
rptsTargetsStruct = repmat(struct('targets', []), 84, 1);

for modOutIdx = 1:84

    [moduleNum outputNum] = convert_to_module_output(modOutIdx);

    tadInputStruct = retrieve_tad(moduleNum, outputNum, targetListSetName);

    % keep only valid targets (where keplerId not equal to -1)
    validTargets = tadInputStruct.targets([tadInputStruct.targets.keplerId] ~= -1);

    rptsTargetsStruct(modOutIdx).targets = validTargets;
end

save(['/path/to/matlab/tad/rpts/rptsTargetsStruct_' targetListSetName '.mat'],  'rptsTargetsStruct');


return;
