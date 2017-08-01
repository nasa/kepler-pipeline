function [pdqTempStruct,pdqOutputStruct] = compute_encircled_energy_metric_main(pdqScienceObject, pdqTempStruct, pdqOutputStruct,currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pdqTempStruct,pdqOutputStruct] =
% compute_encircled_energy_metric_main(pdqScienceObject, pdqTempStruct,
% pdqOutputStruct,currentModOut)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function invokes another function to compute the encircled energy
% metric (defined as the distance in pixels at which fluxFraction percent
% of the energy is enclosed. The estimate is based on a polynomial fit to
% the cumulative flux sorted as a function of radius) and appends to the
% (existing) metric time series.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

targetIndices   = pdqTempStruct.targetIndices;

% if no stellar targets to process, then return
if (isempty(targetIndices))
    return;
end


%--------------------------------------------------------------------------
% invoke the script to compute the metric
%--------------------------------------------------------------------------
pdqTempStruct = compute_encircled_energy_metric_using_hybrid_fit(pdqTempStruct);

%pdqTempStruct = compute_encircled_energy_metric_by_fitting_pixel_flux(pdqTempStruct);
%pdqTempStruct = compute_encircled_energy_metric(pdqTempStruct);
%pdqTempStruct1 = compute_encircled_energy_metric_erf_based(pdqTempStruct);


% Retrieve the existing encircledEnergies metric structure if any (will be empty if it does
% not exist
encircledEnergies    = pdqScienceObject.inputPdqTsData.pdqModuleOutputTsData(currentModOut).encircledEnergies;
nCadences = length(pdqTempStruct.cadenceTimes);


if (isempty(encircledEnergies.values))

    encircledEnergies.values = pdqTempStruct.encircledEnergies(:);
    encircledEnergies.uncertainties = pdqTempStruct.encircledEnergiesUncertainties(:);
    encircledEnergies.gapIndicators = false(nCadences,1);

    % set the gap indicators to true wherever the metric = -1;
    metricGapIndex = find(pdqTempStruct.encircledEnergies(:) == -1);

    if(~isempty(metricGapIndex))
        encircledEnergies.gapIndicators(metricGapIndex) = true;
    end

else

    encircledEnergies.values = [encircledEnergies.values(:); pdqTempStruct.encircledEnergies(:)];
    encircledEnergies.uncertainties = [encircledEnergies.uncertainties(:); pdqTempStruct.encircledEnergiesUncertainties(:)];

    gapIndicators = false(nCadences,1);

    % set the gap indicators to true wherever the metric = -1;
    metricGapIndex = find(pdqTempStruct.encircledEnergies(:) == -1);

    if(~isempty(metricGapIndex))
        gapIndicators(metricGapIndex) = true;
    end

    encircledEnergies.gapIndicators = [encircledEnergies.gapIndicators(:); gapIndicators(:)];

    % Sort time series using the time stamps as a guide
    [allTimes sortedTimeSeriesIndices] = ...
        sort([pdqScienceObject.inputPdqTsData.cadenceTimes(:); ...
        pdqScienceObject.cadenceTimes(:)]);

    encircledEnergies.values = encircledEnergies.values(sortedTimeSeriesIndices);
    encircledEnergies.uncertainties = encircledEnergies.uncertainties(sortedTimeSeriesIndices);
    encircledEnergies.gapIndicators = encircledEnergies.gapIndicators(sortedTimeSeriesIndices);

end
%--------------------------------------------------------------------------
% Save results in pdqOutputStruct
% This is a time series for tracking and trending
%--------------------------------------------------------------------------
pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModOut).encircledEnergies = encircledEnergies;

close all;
return
