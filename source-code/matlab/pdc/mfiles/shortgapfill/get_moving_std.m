%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [movingAverage, movingStd] = get_moving_std(timeSeries, nWindowLength)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
%     This function computes the moving mean and moving standard deviation
%     time series of a given time series over a window.
%
% Input:
%       1. timeSeries - time series without any  data gaps
%       2. nWindowLength - length of the moving window, turned to an odd
%       number if given as even
%
% Output:
%       1. movingAverage - moving average computed by processing the input
%          data in both the forward and reverse directions.  After
%          filtering in the forward direction, it reverses the filtered
%          sequence and runs it back through the filter. The resulting
%          sequence has precisely zero-phase distortion. In addition to the
%          forward-reverse filtering, it attempts to minimize startup
%          transients by adjusting initial conditions to match the DC
%          component of the signal and by prepending several filter lengths
%          of a flipped, reflected copy of the input signal.
%       2. movingStd - moving standard deviation time series computed in a
%          similar manner.
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

function [movingAverage, movingStd] = get_moving_std(indexOfAvailable, timeSeriesWithGaps, nWindowLength)


if (nWindowLength <= 0)
    error('get_moving_std:  window length less than or equal 0!')
end

if(mod(nWindowLength,2))
    nWindowLength = nWindowLength+1;
end;


nTimeSteps = (indexOfAvailable(1):indexOfAvailable(end))';

timeSeries = interp1(indexOfAvailable,timeSeriesWithGaps(indexOfAvailable), nTimeSteps, 'linear');

movingAverage = filtfilt(ones(1, nWindowLength)/nWindowLength, 1, timeSeries);

movingAverageOfSquared = filtfilt(ones(1, nWindowLength)/nWindowLength, 1, timeSeries.^2);

movingStd = sqrt(max((movingAverageOfSquared - movingAverage.^2),0));

if(~isreal(movingStd))
    error('get_moving_std:  movingStd is complex for a real time series!')
end;



return;


