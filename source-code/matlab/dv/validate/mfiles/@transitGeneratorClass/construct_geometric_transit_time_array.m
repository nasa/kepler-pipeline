function [timestampArray, timestampsInTransitIdx] = ...
    construct_geometric_transit_time_array(transitModelObject)
% function [timestampArray, timestampsInTransitIdx] = ...
%    construct_geometric_transit_time_array(transitModelObject)
%
% function to construct a new time array that includes the n samples between
% input timestamps. A corresponding logical array which specifies the
% timestamps that are in transit is also output.
%
%
% INPUTS
%   transitModelObject
%
%
% OUTPUTS
%   timestampArray
%   timestampsInTransitIdx
%
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


% extract parameters from object
debugFlag  = transitModelObject.debugFlag; %#ok<NASGU>
timestamps = transitModelObject.cadenceTimes;

timeParametersStruct     = transitModelObject.timeParametersStruct;
transitBufferCadences    = timeParametersStruct.transitBufferCadences;
transitSamplesPerCadence = timeParametersStruct.transitSamplesPerCadence;

sec2day = get_unit_conversion('sec2day');
cadenceDurationDays =  (timeParametersStruct.exposureTimeSec + ...
    timeParametersStruct.readoutTimeSec) * ...
    timeParametersStruct.numExposuresPerCadence * sec2day;


% for each input timestamp, we want to sample N additional timestamps between 
% +/-  1/2*cadence duration, where N is the input transitSamplesPerCadence
deltaTime = cadenceDurationDays/transitSamplesPerCadence;

numTimestampsToAddToEachSide = floor(transitSamplesPerCadence/2);

inputTimestamps = timestamps;
nInputTimestamps = length(timestamps);

timestampArray = zeros(nInputTimestamps*(transitSamplesPerCadence-1), 1);
timestampArray(1:nInputTimestamps) = inputTimestamps;

for n = 1:numTimestampsToAddToEachSide
    
    newStartIdx = length(find(timestampArray))+1;
    
    % compute the +/- times and concatenate
    newTimestampsLeft = inputTimestamps - n*deltaTime;
    
    newTimestampsRight = inputTimestamps + n*deltaTime;
    
    timestampArray(newStartIdx : newStartIdx + 2*nInputTimestamps-1) = ...
        [newTimestampsLeft(:); newTimestampsRight(:)];
end


% sort timestampArray
timestampArray = sort(timestampArray);


%--------------------------------------------------------------------------
% find times that are within a transit (+/- buffer)
%--------------------------------------------------------------------------

[numExpectedTransits, numActualTransits, transitStruct] = ...
    get_number_of_transits_in_time_series(transitModelObject, timestamps); %#ok<ASGLU>

transitStartTimesNoBufferBkjd = [transitStruct.bkjdTransitStart]';
transitEndTimesNoBufferBkjd   = [transitStruct.bkjdTransitEnd]';

% preallocate logical array to collect indices of timestamps that are
% within a transit (including the +/- transit buffer)
timestampsInTransitIdx = false(length(timestampArray), 1);

for iTransit = 1:numExpectedTransits
    
    validIdx = timestampArray > (transitStartTimesNoBufferBkjd(iTransit) - transitBufferCadences*cadenceDurationDays) & ...
               timestampArray < (transitEndTimesNoBufferBkjd(iTransit)   + transitBufferCadences*cadenceDurationDays);
    
    timestampsInTransitIdx = timestampsInTransitIdx | validIdx;
end


return;

