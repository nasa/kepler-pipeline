function [indexOfAstroEvents, fittedTrend] = ...
identify_astrophysical_events(targetFlux, targetFluxDataGapIndicators, ...
gapFillParametersStruct, singletonRemovalEnabled, maxDutyCycle)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [indexOfAstroEvents, fittedTrend] = ...
% identify_astrophysical_events(targetFlux, targetFluxDataGapIndicators, ...
% gapFillParametersStruct, singletonRemovalEnabled)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Identify giant transits (planetary and eclipsing binary) and gravitational
% microlensing events. Return indices of event flux samples. It may be
% desirable at some future time to set the event detection threshold
% differently for the transits and microlensing events. If the optional
% singleton removal parameter is enabled (true) then single cadence
% astrophysical "events" should not be returned by this function.
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

% Can optionally returen the fittedTrend that was used to detrend the data
% during identification of giant transits in the input targetFlux.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% Set default for optional arguments.
SINGLETON_REMOVAL_ENABLED = false;

if isempty(targetFluxDataGapIndicators)
    targetFluxDataGapIndicators = false(size(targetFlux));
end

if ~exist('singletonRemovalEnabled', 'var')
    singletonRemovalEnabled = SINGLETON_REMOVAL_ENABLED;
end

% set the max duty cycle of astro events if it is nonexistent
if ~exist('maxDutyCycle', 'var')    
    maxDutyCycle = 0.2;
end

% Check if there are any valid flux samples. Return if there are not.
if all(targetFluxDataGapIndicators)
    indexOfAstroEvents = [];
    fittedTrend = [];
    return
end

% First identify the giant transits. Can't proceed any further if there is
% no fitted trend.
[indexOfTransits, ~, fittedTrend] = identify_giant_transits(targetFlux, ...
    targetFluxDataGapIndicators, gapFillParametersStruct, maxDutyCycle);

if isempty(fittedTrend)
    indexOfAstroEvents = [];
    fittedTrend = [];
    return
end

if singletonRemovalEnabled && ~isempty(indexOfTransits)
    indexOfConsecutiveEvents = find(diff(indexOfTransits) == 1);
    indexOfTransits = indexOfTransits( ...
        union(indexOfConsecutiveEvents, indexOfConsecutiveEvents + 1));
end % if

% Now invert the flux and identify the microlensing events.
targetFlux = targetFlux - fittedTrend;
meanFlux = mean(targetFlux(~targetFluxDataGapIndicators));
targetFlux(~targetFluxDataGapIndicators) = 2 * meanFlux - ...
    targetFlux(~targetFluxDataGapIndicators);

% the flux was detrended so just specify a trend line of zeros so it doesnt
% get detrended internally
[indexOfMicroEvents] = identify_giant_transits(targetFlux, ...
    targetFluxDataGapIndicators, gapFillParametersStruct, maxDutyCycle, ...
    zeros(length(targetFlux),1) );

if singletonRemovalEnabled && ~isempty(indexOfMicroEvents)
    indexOfConsecutiveEvents = find(diff(indexOfMicroEvents) == 1);
    indexOfMicroEvents = indexOfMicroEvents( ...
        union(indexOfConsecutiveEvents, indexOfConsecutiveEvents + 1));
end % if

% Merge the event indices.
indexOfAstroEvents = unique([indexOfTransits; indexOfMicroEvents]);

% Return.
return
