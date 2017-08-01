classdef mapPixelDataClass

methods (Static=true)

%************************************************************************************************
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
function [inputStruct] = create_pixel_prior_blob_struct (inputStruct, pixelPriors)

    inputStruct.pixelPriors = pixelPriors;

end

%************************************************************************************************
% The Pixel Prior data from Jeff K. is incompleted. He ignores a large number of targets including saturated targets and 
% any targets near the CCD edge. Since
% PDC has no such luxury the missing targets are filled in with NaN data to let PDC know the data is missing.
function pixelPriors = process_jeff_k_pixel_data (jeffKPixelData, kepIds, nBasisVectors)

    nTargets = length(kepIds);

    % fill is missing targets
    [~, loc] = ismember(jeffKPixelData.targetIDs, kepIds);
    pixelPriors = NaN(nTargets, nBasisVectors);
    pixelPriors(loc,:) = jeffKPixelData.priors(:,1:nBasisVectors);


end % process_jeff_k_pixel_data

function compile_pixel_priors (mapData, mapInput)

    if (length(mapInput.cbvBlobStruct.pixelPriors(:,1)) ~= mapData.nTargets)
        error('Pixel prior data does not appear to be for this MAP run.');
    end

    mapData.pixelData.priors = mapInput.cbvBlobStruct.pixelPriors;

    % Normalize the coefficients
    mapData.pixelData.priors = mapNormalizeClass.normalize_coefficients (mapData.pixelData.priors, mapData.medianFlux, mapData.meanFlux, mapData.stdFlux, ...
            mapData.noiseFloor, mapInput.mapParams.fitNormalizationMethod);

    mapData.targetsWherePixelDataNotFound = isnan(sum(mapData.pixelData.priors,2));

end % compile_pixel_priors

end % static methods

end % classdef
