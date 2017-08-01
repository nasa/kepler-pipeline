function [dvResultsStruct] = compare_odd_even_transit_depth(dvResultsStruct, iTarget, jPlanet, debugLevel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = compare_odd_even_transit_depth(dvResultsStruct, iTarget, jPlanet, debugLevel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compare depths of odd and even transits. Statistic value and significance level are determined under null
% hypothesis that the depths of odd and even transits are equal.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
    
% Get keplerId of the given target.
keplerId = dvResultsStruct.targetResultsStruct(iTarget).keplerId;

% Get planetResultsStruct of the given planet of the given target.
planetResultsStruct = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet);

% Define parameter name string
transitDepthString = 'transitDepthPpm';

% Get estimated depths and the uncertainties for odd transits
[oddDepthStruct, uniqueMatchFlag] = retrieve_model_parameter(planetResultsStruct.oddTransitsFit.modelParameters, transitDepthString);
if ( uniqueMatchFlag )
    dataStruct(1).value       = oddDepthStruct.value;
    % The "uncertainty" (tolerance) of odd/even depth comparison is set to the uncertainty of the estimated depth value or 1% of the estimated depth value,
    % whichever is larger.
    % dataStruct(1).uncertainty = max([oddDepthStruct.uncertainty 0.01*oddDepthStruct.value]);
    
    % It is decided to produce the consistent test result by removing the possibility to set the uncertainty equal to 1% of the estimated depth value. 07/02/2013
    dataStruct(1).uncertainty = oddDepthStruct.uncertainty;
else 
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'compareOddEvenTransitDepth', 'warning', ...
        'No unique match for depth parameters in oddTransitsFit structure', iTarget, keplerId, jPlanet);
    disp(dvResultsStruct.alerts(end).message);
    return;
end

% Get estimated depths and the uncertainties for even transits 
[evenDepthStruct, uniqueMatchFlag] = retrieve_model_parameter(planetResultsStruct.evenTransitsFit.modelParameters, transitDepthString);
if ( uniqueMatchFlag )
    dataStruct(2).value       = evenDepthStruct.value;
    % The "uncertainty" (tolerance) of odd/even depth comparison is set to the uncertainty of the estimated depth value or 1% of the estimated depth value,
    % whichever is larger.
    % dataStruct(2).uncertainty = max([evenDepthStruct.uncertainty 0.01*evenDepthStruct.value]);
    
    % It is decided to produce the consistent test result by removing the possibility to set the uncertainty equal to 1% of the estimated depth value. 07/02/2013
    dataStruct(2).uncertainty = evenDepthStruct.uncertainty;
else    
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'compareOddEvenTransitDepth', 'warning', ...
        'No unique match for depth parameters in evenTransitsFit structure', iTarget, keplerId, jPlanet);
    disp(dvResultsStruct.alerts(end).message);
    return;
end

% Statistic value and significance level are determined only when estimated depths are valid
if ( dataStruct(1).uncertainty>0 && dataStruct(2).uncertainty>0 )

    % Determine statistic value and significance level under null hypothesis that depths of odd and even transits are equal
    [dvResultsStruct] = calculate_comparison_statistic(dataStruct, dvResultsStruct, iTarget, jPlanet, 'oddEvenTransitDepth', debugLevel);

else
    dvResultsStruct = add_dv_alert(dvResultsStruct, 'compareOddEvenTransitDepth', 'warning', ...
        'Invalid estimated depth in oddTransitsFit or evenTransitsFit structure', iTarget, keplerId, jPlanet);
    disp(dvResultsStruct.alerts(end).message);
    return;
end

return
