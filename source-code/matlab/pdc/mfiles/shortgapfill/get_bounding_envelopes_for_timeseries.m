%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [upperBoundEnvelope, lowerBoundEnvelope] =
% get_bounding_envelopes_for_timeseries(timeSeriesWithGapsFilled,
% dataGapIndicators,indexOfGiantTransits)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
%     This function computes the upper and lower bound envelopes for a
%     given time series as (movingAverage + 3*movingStd) and (movingAverage
%     - 3*movingStd) respectively time series of a given time series over a
%     window.
%
% Input: 
%       1. timeSeriesWithGapsFilled - time series whose gaps have been
%       filled
%       2. dataGapIndicators - a logical array with 1's indicating the
%       location of the data gaps
%       3. indexOfGiantTransits - an array with indices of samples
%       identified as belonging to giant transits
% 
% Output:
%        1. upperBoundEnvelope - an envelope created by the (moving mean +
%            3* moving std) time series
%        2. lowerBoundEnvelope - an envelope created by the (moving mean -
%            3* moving std) time series
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

function [upperBoundEnvelope, lowerBoundEnvelope] = get_bounding_envelopes_for_timeseries(timeSeriesWithGapsFilled, dataGapIndicators,indexOfGiantTransits)

nWindowLength = 21; % window length to the left of the sample as filtfilt function in get_moving_std used forward and backward filtering to get the moving std

if(~isempty(indexOfGiantTransits))
    dataGapIndicators(indexOfGiantTransits) = true;
end;

indexOfAvailable = find(~dataGapIndicators);

nLength = length(dataGapIndicators);



[movingAverageShort, movingStdShort] = get_moving_std(timeSeriesWithGapsFilled, nWindowLength);

movingAverageShort = movingAverageShort(indexOfAvailable);
movingAverageShort(1:nWindowLength) = movingAverageShort(nWindowLength+1);
movingAverageShort(end:end-nWindowLength) = movingAverageShort(end-nWindowLength-1);

movingStdShort = movingStdShort(indexOfAvailable);
movingStdShort(1:nWindowLength) = movingStdShort(nWindowLength+1);
movingStdShort(end:end-nWindowLength) = movingStdShort(end-nWindowLength-1);

movingAverage = interp1(indexOfAvailable, movingAverageShort, (1:nLength)', 'linear');
movingStd = interp1(indexOfAvailable, movingStdShort, (1:nLength)', 'linear');


upperBoundEnvelope = movingAverage + 4* movingStd;
lowerBoundEnvelope = movingAverage - 4* movingStd;


if(~isempty(indexOfGiantTransits))
    %do nothing effective...
    upperBoundEnvelope(indexOfGiantTransits)  = timeSeriesWithGapsFilled(indexOfGiantTransits) + 3* movingStd(indexOfGiantTransits);
    lowerBoundEnvelope(indexOfGiantTransits) = timeSeriesWithGapsFilled(indexOfGiantTransits) - 3* movingStd(indexOfGiantTransits);

end;




return;

