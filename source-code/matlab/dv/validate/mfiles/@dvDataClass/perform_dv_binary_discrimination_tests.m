function [dvResultsStruct] = perform_dv_binary_discrimination_tests(dvDataObject, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvResultsStruct] = perform_dv_binary_discrimination_tests(dvDataObject, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Perform eclipsing binary discrimination tests (if enabled) for the targets with planet candidates, 
% which inculde comparison of depths and epochs of the odd and even transits, comparison of orbital
% periods of the planet and the one with shorter/longer period The test statistics and significance
% levels are computed to help to discriminate between ecliping binaries and planet transits.
%
% Upon return, the DV results structure has been updated with the statistics and significance levels
% of the eclipsing binary discrimination tests.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Get targetResultsStruct from the dvResultsStruct for all the targets with planet candidates.
targetResultsStruct = dvResultsStruct.targetResultsStruct;

% Get debugLevel from dvConfigurationStruct 
debugLevel = dvDataObject.dvConfigurationStruct.debugLevel;

% Define parameter name string
orbitalPeriodString = 'orbitalPeriodDays';

% Get the randstreams if they exist
streams = false;
fields = fieldnames(dvDataObject);
if any(strcmp('randStreamStruct', fields))
    randStreams = dvDataObject.randStreamStruct.binaryDiscriminationTestRandStreams;
    streams = true;
end % if

% Loop over the targets with planet candidates
nTargets = length(targetResultsStruct);
for iTarget = 1 : nTargets

    % Get keplerId of the given target
    keplerId = targetResultsStruct(iTarget).keplerId;
    
    % Set target-specific randstreams
    if streams
        randStreams.set_default(keplerId);
    end % if
    
    % Get planet candidate data structure of the given target
    planetResultsStructs = targetResultsStruct(iTarget).planetResultsStruct;
    nPlanets = length(planetResultsStructs);
    
    % Get transit periods of planet candidates
    periodValues = zeros(nPlanets, 1);
    for jPlanet = 1 : nPlanets
        
        % Transit periods of planets are determined with estimates in allTransitsStruct 
        [transitPeriodStruct, uniqueMatchFlag] = ...
            retrieve_model_parameter(planetResultsStructs(jPlanet).allTransitsFit.modelParameters, orbitalPeriodString);
        
        if ( uniqueMatchFlag )
            periodValues(jPlanet) = transitPeriodStruct.value;
        end
    
    end

    % Add alert if no valid estimates of orbital periods of the planets of the given target 
    if all(periodValues<=0)
        dvResultsStruct = add_dv_alert(dvResultsStruct, 'performDvBinaryDiscrimination', 'warning', ...
            'No valid estimates of orbital periods of the planets of the given target', iTarget, keplerId);
        disp(dvResultsStruct.alerts(end).message);
    end

    % Planets are sorted by transit periods in ascending order
    [sortedPeriodValues, sortedIndices]  = sort(periodValues);
    
    % Loop over planet candidates of the given target
    for jPlanet = 1 : nPlanets
        
        display(' ');
        display(['DV: Performing Eclipsing Binary Discrimination tests for target #' num2str(iTarget) ' (keplerId: ' num2str(keplerId) ') planet #' num2str(jPlanet)]);
        display(' ');
        
        % The odd/even depth/epoch comparison tests are done only when the odd/even transits fits are available
        if (dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).oddTransitsFit.modelChiSquare~=-1 && ...
                dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(jPlanet).evenTransitsFit.modelChiSquare~=-1 )
            % Compare depths of odd and even transits
            dvResultsStruct = compare_odd_even_transit_depth(dvResultsStruct, iTarget, jPlanet, debugLevel);
            
            % Compare epochs of odd and even transits
            dvResultsStruct = compare_odd_even_transit_epoch(dvResultsStruct, iTarget, jPlanet, debugLevel);
        end
        
        % Compare transit periods of the neighboring planets in the list sorted by transit periods
        dvResultsStruct = compare_planet_orbital_period(dvResultsStruct, iTarget, jPlanet, sortedIndices, debugLevel);
        
        % Vaccum the figures make subplots
        generate_binary_discrimination_test_subplots(dvResultsStruct, iTarget, jPlanet)
        
    end % for jPlanet
    
    % Restore the default randstreams
    if streams
        randStreams.restore_default();
    end % if
    
end % for iTarget

% Return.
return
