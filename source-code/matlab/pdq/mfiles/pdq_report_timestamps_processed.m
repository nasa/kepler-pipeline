function table = pdq_report_timestamps_processed(pdqTimestampSeries)

% Extract the cadence time stamps which is no longer an input.
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
if (isempty(pdqTimestampSeries.excluded))
    oldOrExcludedTimeStamps = pdqTimestampSeries.processed;
elseif (isempty(pdqTimestampSeries.processed))
    oldOrExcludedTimeStamps = pdqTimestampSeries.excluded;
else
    oldOrExcludedTimeStamps = pdqTimestampSeries.processed ...
        | pdqTimestampSeries.excluded;
end
current = ~oldOrExcludedTimeStamps;
cadenceTimesMjd = pdqTimestampSeries.startTimes;
cadenceTimesUtcString = mjd_to_utc(cadenceTimesMjd);
nCadences = length(cadenceTimesMjd);
table = cell(nCadences, 5);

for i = 1 : nCadences
    if (~isempty(pdqTimestampSeries.processed) && pdqTimestampSeries.processed(i))
        status = '-';
    elseif (~isempty(pdqTimestampSeries.excluded) && pdqTimestampSeries.excluded(i))
        status = 'Excluded';
    elseif (~isempty(current) && current(i))
        status = 'Processed';
    else
        status = 'Unknown';
    end
    % Sort table in reverse chronological order.
    table(nCadences - i + 1, :) = {i cadenceTimesMjd(i) cadenceTimesUtcString(i, :) ...
        pdqTimestampSeries.refPixelFileNames{i} status};
end
end