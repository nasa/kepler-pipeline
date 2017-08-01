function weakSecondaryResultsTable = generate_weak_secondary_results_table(planetResultsStruct)
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

planetCandidate = planetResultsStruct.planetCandidate;

depthPpm = planetCandidate.weakSecondaryStruct.depthPpm;
if (depthPpm.uncertainty ~= -1)
    depthPpmValue = sprintf('%1.1f', depthPpm.value);
    depthPpmUncertainty = sprintf('%1.4e', depthPpm.uncertainty);
else
    depthPpmValue = 'N/A';
    depthPpmUncertainty = 'N/A';
end

planetParameters = planetResultsStruct.secondaryEventResults.planetParameters;
comparisonTests = planetResultsStruct.secondaryEventResults.comparisonTests;

if (planetParameters.geometricAlbedo.uncertainty ~= -1)
    geometricAlbedoValue = sprintf('%1.1f', planetParameters.geometricAlbedo.value);
    geometricAlbedoUncertainty = sprintf('%1.4e', planetParameters.geometricAlbedo.uncertainty);
else
    geometricAlbedoValue = 'N/A';
    geometricAlbedoUncertainty = 'N/A';
end
if (comparisonTests.albedoComparisonStatistic.significance ~= -1)
    albedoComparisonStatisticValue = sprintf('%1.4f', comparisonTests.albedoComparisonStatistic.value);
    albedoComparisonStatisticSignificance = sprintf('%1.2f', 100*comparisonTests.albedoComparisonStatistic.significance);
else
    albedoComparisonStatisticValue = 'N/A';
    albedoComparisonStatisticSignificance= 'N/A';
end

if (planetParameters.planetEffectiveTemp.uncertainty ~= -1)
    planetEffectiveTempValue = sprintf('%1.0f', planetParameters.planetEffectiveTemp.value);
    planetEffectiveTempUncertainty = sprintf('%1.4e', planetParameters.planetEffectiveTemp.uncertainty);
else
    planetEffectiveTempValue = 'N/A';
    planetEffectiveTempUncertainty = 'N/A';
end
if (comparisonTests.tempComparisonStatistic.significance ~= -1)
    tempComparisonStatisticValue = sprintf('%1.4f', comparisonTests.tempComparisonStatistic.value);
    tempComparisonStatisticSignificance = sprintf('%1.2f', 100*comparisonTests.tempComparisonStatistic.significance);
else
    tempComparisonStatisticValue = 'N/A';
    tempComparisonStatisticSignificance = 'N/A';
end

weakSecondary = planetCandidate.weakSecondaryStruct;

% Result / Value / Uncertainty / Units / Statistic in Sigmas / Significance (%)
weakSecondaryResultsTable = {...
    'Orbital Period' planetCandidate.orbitalPeriod '' 'days' '' '';
    'Transit Duration' planetCandidate.trialTransitPulseDuration '' 'hours' '' '';
    'Maximum MES' sprintf('%1.1f', planetCandidate.maxMultipleEventSigma) '' '' '' '';
    'Secondary Phase' weakSecondary.maxMesPhaseInDays '' 'days' '' '';
    'Secondary MES' sprintf('%1.1f', weakSecondary.maxMes) '' '' '' '';
    'Minimum Phase' weakSecondary.minMesPhaseInDays '' 'days' '' '';
    'Minimum MES' sprintf('%1.1f', weakSecondary.minMes) '' '' '' '';
    'Median MES' sprintf('%1.1f', weakSecondary.medianMes) '' '' '' '';
    'MAD MES' weakSecondary.mesMad '' '' '' '';
    'Robust Statistic' sprintf('%1.1f', weakSecondary.robustStatistic) '' '' '' '';

    'Secondary Depth' depthPpmValue depthPpmUncertainty 'ppm' '' '';

    'Geometric Albedo' geometricAlbedoValue geometricAlbedoUncertainty '' ...
    albedoComparisonStatisticValue albedoComparisonStatisticSignificance;

    'Planet Effective Temperature' planetEffectiveTempValue planetEffectiveTempUncertainty 'Kelvin' ...
    tempComparisonStatisticValue tempComparisonStatisticSignificance;
};

end
