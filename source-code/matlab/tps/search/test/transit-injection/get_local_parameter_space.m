function [searchSpaceStruct, totalSearchPoints, isValidInjection] = get_local_parameter_space( ...
    injectedPeriodDays, injectedDurationHours, tpsModuleParameters, ...
    nCadences, nPeriodsToSearch, nDurationsToSearch, alwaysInject )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function get_local_parameter_space
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description: This function returns the period sub space and duration sub
% space to search
% Inputs:
% Outputs:
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

% initialize output
searchSpaceStruct = struct('searchDurationInHours', [], 'searchPeriodsInDays', []);
totalSearchPoints = 0;

% compute the space of transit pulses TPS searches over
trialTransitPulseDurationsInHours = compute_trial_transit_durations(tpsModuleParameters);
durationDifferences = abs(injectedDurationHours - trialTransitPulseDurationsInHours);

% determine the durations to search over
if nDurationsToSearch > length(trialTransitPulseDurationsInHours)
    searchDurations = trialTransitPulseDurationsInHours;
elseif nDurationsToSearch < 2
    % just search the closest duration
    searchDurations = trialTransitPulseDurationsInHours( ...
        durationDifferences == min(durationDifferences) );
else
    sortedDifferences = sort(durationDifferences);
    searchDurations = trialTransitPulseDurationsInHours( ...
        ismember(durationDifferences, sortedDifferences(1:nDurationsToSearch)) );
end

isValidInjection = true;
closestDurationIndex = -1;

for iDuration = 1:length(searchDurations)
    if isValidInjection
        transitPulseDurationInHours = searchDurations(iDuration);
        searchSpaceStruct(iDuration).searchDurationInHours = searchDurations(iDuration);

        % compute the period space that TPS searches over

        cadencesPerDay = tpsModuleParameters.cadencesPerDay;
        superResolutionFactor = tpsModuleParameters.superResolutionFactor;

        minimumSearchPeriodInDays = get_min_search_period_days( tpsModuleParameters, ...
            transitPulseDurationInHours ) ;
        maximumSearchPeriodInDays = get_max_search_period_days( tpsModuleParameters, ...
            transitPulseDurationInHours ) ;

        % For some high impact parameter injections there might not be any
        % valid period space - check for this

        if (injectedPeriodDays <= minimumSearchPeriodInDays || ...
                injectedPeriodDays >= maximumSearchPeriodInDays ) && ~alwaysInject
            isValidInjection = false;
        else
            
            searchPeriodsInCadences = compute_search_periods( tpsModuleParameters, transitPulseDurationInHours, nCadences );

            %convert to normal resolution in days
            searchPeriodsInDays = searchPeriodsInCadences / (cadencesPerDay * superResolutionFactor);

            % make sure we always have at least one search period and no more than
            % all the periods available
            periodDifferences = abs( injectedPeriodDays - searchPeriodsInDays );

            if nPeriodsToSearch > length(searchPeriodsInDays)
                searchSpaceStruct(iDuration).searchPeriodsInDays = searchPeriodsInDays;
            elseif nPeriodsToSearch < 2
                % just search the closest period
                searchSpaceStruct(iDuration).searchPeriodsInDays = searchPeriodsInDays( ...
                    periodDifferences == min(periodDifferences) );
            else
                sortedDifferences = sort(periodDifferences);
                searchSpaceStruct(iDuration).searchPeriodsInDays = searchPeriodsInDays( ...
                    ismember(periodDifferences, sortedDifferences(1:nPeriodsToSearch)) );
                if isequal(iDuration,1)
                    closestDurationIndex = 1;
                    durationDelta = searchSpaceStruct(1).searchDurationInHours * (1/24) - injectedDurationHours * (1/24);
                    periodDelta = searchSpaceStruct(1).searchPeriodsInDays - injectedPeriodDays;
                    distanceMinimum = min( sqrt( durationDelta.^2 + periodDelta.^2) );
                else
                    durationDelta = searchSpaceStruct(iDuration).searchDurationInHours * (1/24) - injectedDurationHours * (1/24);
                    periodDelta = searchSpaceStruct(iDuration).searchPeriodsInDays - injectedPeriodDays; 
                    distanceTemp = min( sqrt( durationDelta.^2 + periodDelta.^2) );
                    if distanceTemp < distanceMinimum
                        closestDurationIndex = iDuration;
                        distanceMinimum = distanceTemp;
                    end
                end
            end

            totalSearchPoints = totalSearchPoints + length( searchSpaceStruct(iDuration).searchPeriodsInDays);
            
        end
    end
end

% reorder the struct so that the duration with the closest template is
% first 
if ~isequal(closestDurationIndex, -1)
    durationIndicator = false(nDurationsToSearch,1);
    durationIndicator(closestDurationIndex) = true;
    tempSearchSpaceStruct = searchSpaceStruct;
    searchSpaceStruct(1) = tempSearchSpaceStruct(durationIndicator);
    searchSpaceStruct(2:nDurationsToSearch) = tempSearchSpaceStruct(~durationIndicator);
end

return
