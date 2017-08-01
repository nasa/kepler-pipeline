function [dvResultsStruct] = compare_planet_orbital_period(dvResultsStruct, iTarget, jPlanet, sortedIndices, debugLevel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = compare_planet_orbital_period(dvResultsStruct, iTarget, jPlanet, sortedIndices, debugLevel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compare orbital periods of the neighboring planets in the list sorted by orbital periods. Statistic value and significance
% level are determined under null hypothesis that the orbital periods are equal. 
% Modified on 09/22/2009: Considering the systematic error of the estimated orbit period is much larger than its stochastic
% error, the "tolerance" of the estimated orbit period is assumed to be equal to the estimated transit duration.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Set constant
HOURS_PER_DAY = get_unit_conversion('day2hour');

% Get keplerId of the given target.
keplerId = dvResultsStruct.targetResultsStruct(iTarget).keplerId;

% Get planetResultsStructs of the given target.
planetResultsStructs = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct;

% Define parameter name strings
orbitalPeriodString   = 'orbitalPeriodDays';
transitDurationString = 'transitDurationHours';

% Get orbital period of the given planet
[transitPeriodStruct, uniqueMatchFlag] = ...
    retrieve_model_parameter(planetResultsStructs(jPlanet).allTransitsFit.modelParameters, orbitalPeriodString);
if ( uniqueMatchFlag )
    dataStruct(1).value       = transitPeriodStruct.value;
else    
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'comparePlanetOrbitalPeriod', 'warning', ...
        'No unique match for orbital period parameters in allTransitsFit structure', iTarget, keplerId, jPlanet);
    disp(dvResultsStruct.alerts(end).message);
    return;
end

% Get transit duration of the given planet. 
[transitDurationStruct, uniqueMatchFlag] = ...
    retrieve_model_parameter(planetResultsStructs(jPlanet).allTransitsFit.modelParameters, transitDurationString);
if ( uniqueMatchFlag )
    dataStruct(1).uncertainty = transitDurationStruct.value/HOURS_PER_DAY;
else    
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'comparePlanetOrbitalPeriod', 'warning', ...
        'No unique match for transit duration parameters in allTransitsFit structure', iTarget, keplerId, jPlanet);
    disp(dvResultsStruct.alerts(end).message);
    return;
end

% Get index of the given planet in the list sorted by orbital periods in ascending order
indexOfList = find(sortedIndices==jPlanet);

% When the given planet is not the first in the sorted list 
if indexOfList>1
    
    % Get planet number of the planet which is just ahead of the given planet in the sorted list
    planetNumber  = planetResultsStructs(sortedIndices(indexOfList-1)).allTransitsFit.planetNumber;
    
    % Get orbital period of the planet which is just ahead of the given planet in the sorted list
    [transitPeriodStruct, uniqueMatchFlag] = ...
        retrieve_model_parameter(planetResultsStructs(sortedIndices(indexOfList-1)).allTransitsFit.modelParameters, orbitalPeriodString);
    if ( uniqueMatchFlag )
        dataStruct(2).value       = transitPeriodStruct.value;
    else    
        dvResultsStruct = add_dv_alert(dvResultsStruct, 'comparePlanetOrbitalPeriod', 'warning', ...
            'No unique match for orbital period parameters in allTransitsFit structure', iTarget, keplerId, planetNumber);
        disp(dvResultsStruct.alerts(end).message);
        dataStruct(2).value       = 0;
    end

    % Get transit duration of the planet which is just ahead of the given planet in the sorted list
    [transitDurationStruct, uniqueMatchFlag] = ...
        retrieve_model_parameter(planetResultsStructs(sortedIndices(indexOfList-1)).allTransitsFit.modelParameters, transitDurationString);
    if ( uniqueMatchFlag )
        dataStruct(2).uncertainty = transitDurationStruct.value/HOURS_PER_DAY;
    else    
        dvResultsStruct = add_dv_alert(dvResultsStruct, 'comparePlanetOrbitalPeriod', 'warning', ...
            'No unique match for transit duration parameters in allTransitsFit structure', iTarget, keplerId, planetNumber);
        disp(dvResultsStruct.alerts(end).message);
        dataStruct(2).uncertainty = -1;
    end

    % Statistic value and significance level are determined only when orbital periods are valid
    if ( dataStruct(1).uncertainty>0 && dataStruct(2).uncertainty>0 )
        
        % Determine statistic value and significance level under null hypothesis that the orbital periods are equal
        [dvResultsStruct] = calculate_comparison_statistic(dataStruct, dvResultsStruct, iTarget, jPlanet, 'shorterPeriod', debugLevel, planetNumber);
       
    else
        dvResultsStruct = add_dv_alert(dvResultsStruct, 'comparePlanetOrbitalPeriod', 'warning', ...
            'No valid estimated transit duration in allTransitsFit structure for shorter period comparison', iTarget, keplerId, jPlanet);
        disp(dvResultsStruct.alerts(end).message);
    end

else
    display(['Planet #' num2str(jPlanet) ' has shortest estimated orbital period']);
end    

% When the given planet is not the last in the sorted list
if indexOfList<length(sortedIndices)

    % Get planet number of the planet which is just after the given planet in the sorted list
    planetNumber  = planetResultsStructs(sortedIndices(indexOfList+1)).allTransitsFit.planetNumber;
    
    % Get orbital period of the planet which is just after the given planet in the sorted list
    [transitPeriodStruct, uniqueMatchFlag] = ...
        retrieve_model_parameter(planetResultsStructs(sortedIndices(indexOfList+1)).allTransitsFit.modelParameters, orbitalPeriodString);
    if ( uniqueMatchFlag )
        dataStruct(2).value       = transitPeriodStruct.value;
    else    
        dvResultsStruct = add_dv_alert(dvResultsStruct, 'comparePlanetOrbitalPeriod', 'warning', ...
            'No unique match for orbital period parameters in allTransitsFit structure', iTarget, keplerId, planetNumber);
        disp(dvResultsStruct.alerts(end).message);
        dataStruct(2).value       = 0;
    end

    % Get transit duration of the planet which is just after the given planet in the sorted list
    [transitDurationStruct, uniqueMatchFlag] = ...
        retrieve_model_parameter(planetResultsStructs(sortedIndices(indexOfList+1)).allTransitsFit.modelParameters, transitDurationString);
    if ( uniqueMatchFlag )
        dataStruct(2).uncertainty = transitDurationStruct.value/HOURS_PER_DAY;
    else    
        dvResultsStruct = add_dv_alert(dvResultsStruct, 'comparePlanetOrbitalPeriod', 'warning', ...
            'No unique match for transit duration parameters in allTransitsFit structure', iTarget, keplerId, planetNumber);
        disp(dvResultsStruct.alerts(end).message);
        dataStruct(2).uncertainty = -1;
    end

    % Statistic value and significance level are determined only when orbital periods are valid
    if ( dataStruct(1).uncertainty>0 && dataStruct(2).uncertainty>0 )
        
        % Determine statistic value and significance level under null hypothesis that the orbital periods are equal
        [dvResultsStruct] = calculate_comparison_statistic(dataStruct, dvResultsStruct, iTarget, jPlanet, 'longerPeriod', debugLevel, planetNumber);

    else
        dvResultsStruct = add_dv_alert(dvResultsStruct, 'comparePlanetOrbitalPeriod', 'warning', ...
            'No valid estimated transit duration in allTransitsFit structure for longer period comparison', iTarget, keplerId, jPlanet);
        disp(dvResultsStruct.alerts(end).message);
    end

else
    display(['Planet #' num2str(jPlanet) ' has longest estimated orbital period']);
end

return
