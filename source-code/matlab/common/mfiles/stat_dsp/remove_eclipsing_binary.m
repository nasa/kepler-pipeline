%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [binaryRemovedTimeSeries fittedTimeSeries] =
%   remove_eclipsing_binary(timeSeries, binaryPeriodInCadences, madXFactor,
%   maxFitPolyOrder, polyFitChunkLengthInCadences, gapIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% This function fits and removes EB's with a given period from the catalog.
%
% The period is used to transform to phase space.  The phase space flux is
% then split up into chains by using a knot-finding procedure similar to
% what is outlined in Andrej Prsa's paper (EBAI Project I).  Each chain is
% then piecewise robustly fit.  The fit is then converted back to the time
% domain and subtracted off the timeSeries.  The residual and the fit are
% outputs.  Note that there is wrap-around fitting so the time series must
% be detrended prior to use of this function.
%
% Inputs:
%       1) timeSeries: A detrended time series
%       2) binaryPeriodInCadences: period from catalog converted to
%          units of cadences
%       3) madXFactor:  MAD threshold multiplier for outlier screening
%          prior to robust estimation/fit.  This can be set relatively high
%          (10-20) since robustfit mitigates outliers.
%       4) maxFitPolyOrder:  Set a maximum to the polynomial order being
%          estimated and used for the fits to each chunk.
%       5) polyFitChunkLengthInCadences:  parameter for the
%          piecewise_robustfit_timeseries code that determines chunk size
%       6) gapIndicators: needed for piecewise_robustfit_timeseries
%
%         
% Output:
%       1) binaryRemovedTimeSeries: residual from fit removed time series
%       2) fittedTimeSeries: The stitched together robustly fit polynomial
%          representation of the original time series.
%
%
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

function [binaryRemovedTimeSeries fittedTimeSeries] = ...
    remove_eclipsing_binary(timeSeries, binaryPeriodInCadences, madXFactor, ...
    maxFitPolyOrder, gapIndicators)

% check validity of input parameters

nCadences = length(timeSeries);
cadenceTimes=1:nCadences;
cadenceTimes=cadenceTimes(:);

% This parameter need not become a module parameter
phaseSpacing=0.01;

if binaryPeriodInCadences > nCadences
    % if there is only a single EB transit then dont attempt any removal
    binaryRemovedTimeSeries = timeSeries;
    fittedTimeSeries = [];
    return;
end

% get the phase by folding
possiblePhasesInCadences =  (0:phaseSpacing:binaryPeriodInCadences)';
foldedStatisticAtTrialPhases = fold_phases(possiblePhasesInCadences, timeSeries, binaryPeriodInCadences);
indexOfBestPhase = locate_center_of_asymmetric_peak(-foldedStatisticAtTrialPhases);    
binaryPhaseInCadences = possiblePhasesInCadences(indexOfBestPhase);

% loop over periods to minimize string length
% this ends up doing more harm than good to the fits
% periodSpacing=0.001;
% possiblePeriodsInCadences = (binaryPeriodInCadences-8:periodSpacing:binaryPeriodInCadences+8)';
% stringLength = 0;
% for i=1:length(possiblePeriodsInCadences)
%     % transform to phase space
%     [phase, phaseSorted, tempSortKey, tempPhaseSpaceFlux, tempPhaseSpaceGapIndicators] = ...
%         fold_time_series(cadenceTimes,binaryPhaseInCadences,possiblePeriodsInCadences(i),timeSeries, gapIndicators);
%     
%     % compute string length
%     tempStringLength = sum( diff([tempPhaseSpaceFlux;tempPhaseSpaceFlux(1)]).^2 + diff([phase;phase(1)]).^2 );
%     
%     if isequal(i,1) || tempStringLength < stringLength
%         stringLength = tempStringLength;
%         sortKey = tempSortKey;
%         phaseSpaceFlux = tempPhaseSpaceFlux;
%         phaseSpaceGapIndicators = tempPhaseSpaceGapIndicators;
%     end
% end

[phase, phaseSorted, sortKey, phaseSpaceFlux, phaseSpaceGapIndicators] = ...
        fold_time_series(cadenceTimes,binaryPhaseInCadences,binaryPeriodInCadences,timeSeries, gapIndicators);

% get the unSortKey for transforming back 
[sortedSortKey, unSortKey] = sort(sortKey);

% find knots
minChainSize = 8;
knotIndices = find_knots(phaseSpaceFlux, minChainSize, gapIndicators);

% if there is less than 2 knots, set to default of [-0.4,-0.1,0.1,0.4]
if length(knotIndices) < 2
    phaseSet = [-40; -10; 10; 40];
    phases = phaseSorted * 100;
    phases = [ceil(phases(phases<=0)) ; floor(phases(phases>0))];
    [members knotIndices]=ismember(phaseSet,phases);
    knotIndices = knotIndices(members);
end

% fit chains
phaseSpaceFitValues = fit_chains(phaseSpaceFlux, knotIndices, madXFactor, ...
    maxFitPolyOrder, phaseSpaceGapIndicators);

% transform fit back to time domain and compute residual
fittedTimeSeries = phaseSpaceFitValues(unSortKey);
binaryRemovedTimeSeries = timeSeries - fittedTimeSeries;

% subplot(2,1,1)
% plot(phaseSpaceFlux,'-o')
% hold on
% plot(phaseSpaceFitValues,'r-o')
% hold off
% subplot(2,1,2)
% plot(timeSeries,'-o')
% hold on
% plot(binaryRemovedTimeSeries,'r-o')
% hold off
% pause

return;


%--------------------------------------------------------------------------
% Get precise phase from folding
%--------------------------------------------------------------------------

function foldedStatisticAtTrialPhases = fold_phases(possiblePhasesInCadences, timeSeries, periodInCadences)

possiblePhasesInCadences =  possiblePhasesInCadences(:);
timeSeries=timeSeries(:);
nCadences = length(timeSeries);
correlationTimeSeriesFolded = zeros(length(possiblePhasesInCadences),1);

iCount = 0;
for jLag = possiblePhasesInCadences'
    iCount = iCount +1;
    if(jLag <= 0.5)
        kPeriodInCadences = jLag +0.5 ; % not an integer but a float
    else
        kPeriodInCadences = jLag; % not an integer but a float
    end
    while (kPeriodInCadences <= nCadences)
        if(kPeriodInCadences > nCadences)
            break;
        end;
        correlationTimeSeriesFolded(iCount) = correlationTimeSeriesFolded(iCount) + ...
            timeSeries(round(kPeriodInCadences));
        kPeriodInCadences = kPeriodInCadences + periodInCadences;
    end;
end;

foldedStatisticAtTrialPhases = correlationTimeSeriesFolded(1:iCount);

return


%--------------------------------------------------------------------------
% Find Knots
%--------------------------------------------------------------------------

function knotIndices = find_knots(phaseSpaceFlux, minChainSize, gapIndicators)

nCadences = length(phaseSpaceFlux);
medianFlux = median(phaseSpaceFlux);

% fill the gaps with the median values so they dont play any role
phaseSpaceFlux(gapIndicators) = medianFlux;

indexBelow = find(phaseSpaceFlux < medianFlux);

[chunkArray, chunkIndices] = identify_contiguous_integer_values(indexBelow);

if isempty(chunkIndices)
     % no knots, so set to empty
    knotIndices = [];
    return;
else
    chunkArrayLengths = cellfun(@length,chunkArray);
    knotIndices = chunkArrayLengths >= minChainSize;
    
    if sum(knotIndices) < 2
        knotIndices = indexBelow(chunkIndices(knotIndices,:));
        return;
    end
    
    if isempty(knotIndices)
        return;
    end
    
    % convert indices back to original time series
    knotIndices = indexBelow(chunkIndices(knotIndices,:));
    
    % now check length between chains, if less than min combine two
    knotIndices = sort(reshape(knotIndices,numel(knotIndices),1));
    indicesToRemove =  diff(knotIndices)<minChainSize ;
    knotIndices = knotIndices( ~ismember(knotIndices,knotIndices(indicesToRemove)) );

    % check ends - will do wrap around fitting since this a detrended
    % phase space flux
    if knotIndices(1) ~= 1 && knotIndices(end) ~= nCadences
        % check length of first and last combo for wrap around fit
        if (knotIndices(1) + nCadences - knotIndices(end)) < minChainSize
            % combo of first and last is too short so get rid of last knot
            knotIndices = knotIndices(1:end-1);
        end
    end
    if knotIndices(end) == nCadences
        % check that beginning has enough cadences
        if knotIndices(1)-1 < minChainSize
            knotIndices(1) = 1;
        end
    end
    if knotIndices(1) == 1
        % check that end has enough cadences
        if (nCadences - knotIndices(end) + 1) < minChainSize
            knotIndices(end) = nCadences;
        end
    end
end
return


%--------------------------------------------------------------------------
% Fit Chains
%--------------------------------------------------------------------------

function phaseSpaceFitValues = fit_chains(phaseSpaceFlux, knotIndices, ...
    madXFactor, maxFitPolyOrder, gapIndicators)

nCadences = length(phaseSpaceFlux);
phaseSpaceFitValues = -1e9*ones(nCadences,1);

for j=2:length(knotIndices)
    % middle chains
    interval = knotIndices(j-1):knotIndices(j);
    chunkSize = length(interval);
    phaseSpaceFitValues(interval) = piecewise_robustfit_timeseries( ...
        phaseSpaceFlux(interval), chunkSize, madXFactor, ...
        maxFitPolyOrder, gapIndicators(interval));

    % if the first and last cadences are not both knots then do the fits to
    % the beginning and end, wrapping whenever possible
    if j==length(knotIndices) 
        if ~isequal(knotIndices(1),1) && isequal(knotIndices(end),nCadences)
            % last chain has a knot at end so just fit 1:knot(1)
            interval = 1:knotIndices(1);
            chunkSize = length(interval);
            phaseSpaceFitValues(interval) = piecewise_robustfit_timeseries( ...
                phaseSpaceFlux(interval), chunkSize, madXFactor, ...
                maxFitPolyOrder, gapIndicators(interval));
        elseif isequal(knotIndices(1),1) && ~isequal(knotIndices(end),nCadences)
            % last chain has no knot at end but since the first
            % knot is at the first cadence we need to treat the end as
            % a knot
            interval = knotIndices(j):nCadences;
            chunkSize = length(interval);
            phaseSpaceFitValues(interval) = piecewise_robustfit_timeseries( ...
                phaseSpaceFlux(interval), chunkSize, madXFactor, ...
                maxFitPolyOrder, gapIndicators(interval));
        elseif ~isequal(knotIndices(1),1) && ~isequal(knotIndices(end),nCadences)
            % the first and last cadences are not knots, so do wrap around
            tempChunk = [phaseSpaceFlux(knotIndices(end):nCadences);...
                phaseSpaceFlux(1:knotIndices(1)-1)];
            chunkSize = length(interval);
            tempGapIndicators = [gapIndicators(knotIndices(end):nCadences); ...
                gapIndicators(1:knotIndices(1)-1)];
            tempFit = piecewise_robustfit_timeseries( tempChunk, chunkSize, ...
                madXFactor, maxFitPolyOrder, tempGapIndicators);
            phaseSpaceFitValues(knotIndices(end):nCadences) = ...
                tempFit(1:length(knotIndices(end):nCadences));
            phaseSpaceFitValues(1:knotIndices(1)-1) = ...
                tempFit(length(knotIndices(end):nCadences)+1:end);
        end
    end
end


return

