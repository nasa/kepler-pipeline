function transitEphemeris = make_ephemeris(period,duration,epoch,startTime,endTime,makeTransitIndicators,samplingInterval)
% Function to make transit ephemeris for a set of transiting planets
%==========================================================================
% Inputs
%==========================================================================
% period, duration, epoch are column vectors
% period -- transit period in days
% duration -- transit duration in days
% epoch -- time of first mid-transit after the startTime, in days
% startTime and endTime -- start and end times of the desired observing window in days
% makeTransitIndicators -- 'Y' or 'N' (or true or false), switch that controls the production of transit
%   indicator vector(s).
% samplingInterval -- unit of the transit sampling grid in days; should
% be much smaller than the transit duration
%   0.0033 days ~ 5 min, about 1 part in 100 for an 8 hour transit
%   0.005 days ~ 7.5 min
%   0.01 days ~ 15 min
%   0.02 days ~ 30 min
%==========================================================================
% Outputs
%==========================================================================
% transitEphemeris: struct with fields
%   .times -- mid-transit times in days for each input object
%       If there is no transit between startTime and endTime, .times = []; 
%   .indicator -- transit indicator vector for each input object (optional)
%       Indicator vector accounts for the corner cases that can occur when
%       a transit overlaps either startTime or endTime or both.
%       If there is no transit between startTime and endTime AND there is
%       no transit that overlaps startTime or endTime, then .indicator is
%       all zeros.
% =========================================================================
% Adjust the epoch to make sure it is the first mid-transit time
% after startTime
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
    
% Cases: epoch >= startTime and epoch < startTime
% Pseudocode:
% if(epoch >= startTime)
%     % Subtract from the epoch the maximum integer number of
%     % periods such that the difference is >= startTime
%     epoch = epoch - floor((epoch - startTime)./period).*period
% elseif(epoch < startTime)
%     % Add to the epoch the minimum integer number of periods such
%     % that the sum is >= startTime.
%     epoch = epoch + ceil((startTime - epoch)./period).*period
% end

% Make an indicator vector for the two cases
epochIndicator = epoch >= startTime;

% Case epoch >= startTime
epoch(epochIndicator==true) = epoch(epochIndicator==true) - ...
    floor((epoch(epochIndicator==true) - startTime) ...
    ./period(epochIndicator==true)).*period(epochIndicator==true);

% Case epoch < startTime
epoch(epochIndicator==false) = epoch(epochIndicator==false) + ...
    ceil((startTime - epoch(epochIndicator==false)) ...
    ./period(epochIndicator==false)).*period(epochIndicator==false);

%==========================================================================
% Number of objects for which we will make a transit ephemeris
nObjects = length(period);

% Sample the observation window in units of samplingInterval
sampleTimes = startTime/samplingInterval:endTime/samplingInterval;
nSamples = length(sampleTimes);

% Initialize for the transit ephemeris calculation loop
% nSamples = length(sampleTimes);
transitEphemeris = struct([]);

% Transit ephemeris calculation loop over pairs of objects
for iObject = 1:nObjects
    
    % Compute transit ephemeris (mid-transit time series) for this object
    midTransitTimes = epoch(iObject):period(iObject):endTime;
    
    % If there is no mid-transit time between startTime and endTime, then
    % epoch must be > endTime
    % Find the first mid-transit time before startTime
    % the closest mid-transit to startTime and use that as a reference
    % time.
    % if(isempty(midTransitTimes))
    %    midTransitReferenceTime = 
    % end
    
    % Set transitEphemeris vector for this object
    transitEphemeris(iObject).times = midTransitTimes;
    
    % Optionally construct a transit indicator vector which oversamples the transit duration,
    % taking a value of one during the transits and a value of zero outside the transits
    if(makeTransitIndicators =='Y' || makeTransitIndicators == true)
        
        % Extend midTransitTimes to include the first transit before
        % startTime and the first transit after endTime
        if(~isempty(midTransitTimes))
            midTransitTimeBefore = midTransitTimes(1) - period(iObject);
            midTransitTimeAfter = midTransitTimes(end) + period(iObject);
        elseif(isempty(midTransitTimes))
            % If midTransitTimes is empty, epoch *must* be after endTime,
            % because of the 'epoch adjustment' logic above.
            % In this case, the first mid-transit time before startTime 
            % occurs at epoch - period and the first mid-transit time after
            % endTime occurs at epoch
            midTransitTimeBefore = epoch(iObject) - period(iObject);
            midTransitTimeAfter = epoch(iObject);
        end
        extendedMidTransitTimes = [midTransitTimeBefore midTransitTimes midTransitTimeAfter];
        
        % Transit start and end times for this object, in units of sampling
        % interval
        startTransitTimes = (extendedMidTransitTimes-0.5*duration(iObject))./samplingInterval;
        endTransitTimes   = (extendedMidTransitTimes+0.5*duration(iObject))./samplingInterval;
        nTransits = length(startTransitTimes);
        
        % Transit indicator function is one during transits, zero outside
        % transits
        % Initialize
        transitIndicator = zeros(1,nSamples);
       for iTransit = 1:nTransits
           
           % Indicator function for this transit only
            thisTransitIndicator = sampleTimes >= startTransitTimes(iTransit)  & ...
                 sampleTimes <= endTransitTimes(iTransit);
            
            % Update cumulative transit indicator function with this transit
            transitIndicator(thisTransitIndicator) = 1;
       end
        
        % Set the output transit indicator function for this object
        transitEphemeris(iObject).indicator = transitIndicator;
        
    end % Set transit indicator option
    
    % Show progress
    if(mod(iObject,100)==0)
        fprintf('Object number %d\n',iObject)
    end
    
end % Transit ephemeris calculation loop

return



