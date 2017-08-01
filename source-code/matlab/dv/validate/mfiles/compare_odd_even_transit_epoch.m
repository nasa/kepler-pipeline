function [dvResultsStruct] = compare_odd_even_transit_epoch(dvResultsStruct, iTarget, jPlanet, debugLevel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = compare_odd_even_transit_epoch(dvResultsStruct, iTarget, jPlanet, debugLevel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compare epochs of odd and even transits. Statistic value and significance level are determined under null 
% hypothesis that the mean value of orbital periods of odd and even transitis is equal to the difference 
% between epochs of odd and even transits. 
% Modified on 10/07/2009: Considering the systematic error of the estimated orbit period is much larger than 
% its stochastic error, the "tolerance" of the estimated orbit period is assumed to be equal to the estimated
% transit duration.
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

% Set constant
HOURS_PER_DAY = get_unit_conversion('day2hour');

% Get keplerId of the given target.
keplerId = dvResultsStruct.targetResultsStruct(iTarget).keplerId;

% Get planetResultsStruct of the given planet of the given target.
planetResultsStruct = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet);

% Define parameter name strings
transitEpochString    = 'transitEpochBkjd';
orbitalPeriodString   = 'orbitalPeriodDays';
transitDurationString = 'transitDurationHours';

% Get estimated epoch and the uncertainty for odd transits
[oddEpochStruct, uniqueMatchFlag] = ...
    retrieve_model_parameter(planetResultsStruct.oddTransitsFit.modelParameters, transitEpochString);
if ( uniqueMatchFlag )
    oddEpochValue       = oddEpochStruct.value;
    oddEpochUncertainty = oddEpochStruct.uncertainty;
else    
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'compareOddEvenTransitEpoch', 'warning', ...
        'No unique match for epoch parameters in oddTransitsFit structure', iTarget, keplerId, jPlanet);
    disp(dvResultsStruct.alerts(end).message);
    return;
end

% Get estimated epoch and the uncertainty for even transits
[evenEpochStruct, uniqueMatchFlag] = ...
    retrieve_model_parameter(planetResultsStruct.evenTransitsFit.modelParameters, transitEpochString);
if ( uniqueMatchFlag )
    evenEpochValue       = evenEpochStruct.value;
    evenEpochUncertainty = evenEpochStruct.uncertainty;
else    
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'compareOddEvenTransitEpoch', 'warning', ...
        'No unique match for epoch parameters in evenTransitsFit structure', iTarget, keplerId, jPlanet);
    disp(dvResultsStruct.alerts(end).message);
    return;
end

% Get estimated orbital period and the uncertainty for odd transits
[oddPeriodStruct, uniqueMatchFlag] = ...
    retrieve_model_parameter(planetResultsStruct.oddTransitsFit.modelParameters, orbitalPeriodString);
if ( uniqueMatchFlag )
    oddPeriodValue       = oddPeriodStruct.value;
    oddPeriodUncertainty = oddPeriodStruct.uncertainty;
else    
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'compareOddEvenTransitEpoch', 'warning', ...
        'No unique match for orbital period parameters in oddTransitsFit structure', iTarget, keplerId, jPlanet);
    disp(dvResultsStruct.alerts(end).message);
    oddPeriodValue       = 0;
    oddPeriodUncertainty = -1;
end

% Get estimated orbital period and the uncertainty for even transits
[evenPeriodStruct, uniqueMatchFlag] = ...
    retrieve_model_parameter(planetResultsStruct.evenTransitsFit.modelParameters, orbitalPeriodString);
if ( uniqueMatchFlag )
    evenPeriodValue       = evenPeriodStruct.value;
    evenPeriodUncertainty = evenPeriodStruct.uncertainty;
else    
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'compareOddEvenTransitEpoch', 'warning', ...
        'No unique match for orbital period parameters in evenTransitsFit structure', iTarget, keplerId, jPlanet);
    disp(dvResultsStruct.alerts(end).message);
    evenPeriodValue       = 0;
    evenPeriodUncertainty = -1;
end

% Get estimated transit duration and the uncertainty for all transits
[allDurationStruct, uniqueMatchFlag] = ...
    retrieve_model_parameter(planetResultsStruct.allTransitsFit.modelParameters, transitDurationString);
if ( uniqueMatchFlag )
    allDurationValue       = allDurationStruct.value/HOURS_PER_DAY;
    allDurationUncertainty = allDurationStruct.uncertainty/HOURS_PER_DAY;
else    
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'compareOddEvenTransitEpoch', 'warning', ...
        'No unique match for transit duration parameters in allTransitsFit structure', iTarget, keplerId, jPlanet);
    disp(dvResultsStruct.alerts(end).message);
    allDurationValue       = 0;
    allDurationUncertainty = -1;
end

% Statistic value and significance level are determined only when estimated transit epochs are valid
if ( oddEpochUncertainty>0  && evenEpochUncertainty>0 )

    % Determine statistic value and significance level under null hypothesis that the mean value of orbital periods of 
    % odd and even transitis (if both are available) is equal to the difference between epochs of odd and even transits
    % Determine the difference between epochs of odd and even transits
    dataStruct(1).value       = abs(oddEpochValue - evenEpochValue);
    dataStruct(1).uncertainty = sqrt( oddEpochUncertainty^2  + evenEpochUncertainty^2  );

    % Determine the mean value of orbital periods of odd and even transits fits if both are valid
    % If only one orbital period is valid, use the valid one.
    % If neither is valid, add a DV alert and return
    if ( (oddPeriodUncertainty>0) && (evenPeriodUncertainty>0) )
        dataStruct(2).value       = (oddPeriodValue + evenPeriodValue)/2;
        dataStruct(2).uncertainty = sqrt( oddPeriodUncertainty^2 + evenPeriodUncertainty^2 )/2;
    elseif ( (oddPeriodUncertainty>0) && ~(evenPeriodUncertainty>0) )
        dataStruct(2).value       = oddPeriodValue;
        dataStruct(2).uncertainty = oddPeriodUncertainty;
    elseif ( ~(oddPeriodUncertainty>0) && (evenPeriodUncertainty>0) )
        dataStruct(2).value       = evenPeriodValue;
        dataStruct(2).uncertainty = evenPeriodUncertainty;
    else
        dvResultsStruct = add_dv_alert(dvResultsStruct, 'compareOddEvenTransitEpoch', 'warning', ...
            'No valid estimated orbital period in oddTransitsFit and evenTransitsFit structure', iTarget, keplerId, jPlanet);
        disp(dvResultsStruct.alerts(end).message);
        return;
    end
    
    % The "tolerance" of the estimated orbit period is assumed to set to the estimated transit duration if it is valid
    if ( (allDurationValue>0) && (allDurationUncertainty>0) )
        dataStruct(2).uncertainty = allDurationValue;
    end

    [dvResultsStruct] = calculate_comparison_statistic(dataStruct, dvResultsStruct, iTarget, jPlanet, 'oddEvenTransitEpoch', debugLevel);

else
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'compareOddEvenTransitEpoch', 'warning', ...
        'No valid estimated transit epoch in oddTransitsFit or evenTransitsFit structure', iTarget, keplerId, jPlanet);
    disp(dvResultsStruct.alerts(end).message);
    return;
end
    
return
