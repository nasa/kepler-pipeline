function [cadenceTimes, temperatures] = condition_ancillary_data_for_dynablack( dynablackObject )
% function [cadenceTimes, temperatures] = condition_ancillary_data_for_dynablack( dynablackObject )
%
% This dynablack method is modeled after Jeff K.'s Mathematica script to condition the data aquisition and driver board temperature data
% pulled from TCAD.
% 
% Method Outline from prototype (See mkTempsQ5.nb):
% 1)    Find ancillary timestamps where all 10 channels are present (this should be all of them).
% 2)    Form the average temperature on these timestamps
% 3)    Interpolate the moving avarage (window = 36) of both the timestamps and average temps using 2nd order polynomial
% 4)    Extract the resulting temps at cadence mid timestamps to produce times and temps and return.
%
% Method Outline as implemented in Kepler SOC pipeline:
% 1)    Find median ancillary timestamps over all 10 channels.
% 2)    Form the median temperature over 10 channels on these timestamps.
% 3)    Smooth the timeseries of median temperatures using a moving average with window size = 36 points.
% 4)    Linearly interpolate this smoothed temperature time series onto long cadence mid timestamps.
% 5)    Return interpolated time series.
% 
% Both output vectors are column vectors.
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


% HARD CODED PARAMETERS
windowSize = 36;


% unpack long cadence timestamps
cadenceTimes  = dynablackObject.cadenceTimes.midTimestamps;
cadenceGaps   = dynablackObject.cadenceTimes.gapIndicators;
cadenceNumber = dynablackObject.cadenceTimes.cadenceNumbers;

% fill any cadence times which are gapped by linear interpolation
cadenceTimes(cadenceGaps) = interp1(cadenceNumber(~cadenceGaps),cadenceTimes(~cadenceGaps),cadenceNumber(cadenceGaps));

% unpack ancillary data and develop median time series
ancillaryTimestamps = median([dynablackObject.ancillaryEngineeringDataStruct.timestamps],2);
meanTempValues      = median([dynablackObject.ancillaryEngineeringDataStruct.values],2);

% extend the data on each end by the length of the filter to mitigate edge effects
meanTempValues = [mean(meanTempValues(1:windowSize)).*ones(windowSize,1);...
                  meanTempValues;...
                  mean(meanTempValues(end-windowSize:end)).*ones(windowSize,1)];
 
% smooth data with moving average zero phase shift filter
smoothedTempValues = filtfilt(ones(1,windowSize)./windowSize,1,meanTempValues);

% select original ancillary timestamps
smoothedTempValues = smoothedTempValues(windowSize+1:end-windowSize);

% linearly interpolate onto long cadence timestamps w/ nearest neighbor extrapolation at endpoints
t = cadenceTimes;
t(t < min(ancillaryTimestamps)) = min(ancillaryTimestamps);
t(t > max(ancillaryTimestamps)) = max(ancillaryTimestamps);
temperatures = interp1(ancillaryTimestamps,smoothedTempValues,t,'linear','extrap');

% ensure output is in column vectors
cadenceTimes = colvec(cadenceTimes);
temperatures = colvec(temperatures);