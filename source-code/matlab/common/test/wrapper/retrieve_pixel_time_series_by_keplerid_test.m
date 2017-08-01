function retrieve_pixel_time_series_by_keplerid_test
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
    % Kepler IDs for PiDevPipeline setup:
    %
    keplerIds = [8804069 8610382 8610381 8216882 8081256 8480235 8285594 8738591 8608624 8350630 8545795];

    isKepsnpq = 1
    if isKepsnpq
        mjdStart = 55003; % for kepsnpq
        mjdEnd = 55060; % for kepsnpq
    else
        mjdStart = 54000; % for dev pipeline
        mjdEnd = 60000; % for dev pipeline
    end

    % All defaults:
    calLc         = retrieve_pixel_time_series_calibrated_by_keplerid(  keplerIds,    mjdStart, mjdEnd);
    uncalLc       = retrieve_pixel_time_series_uncalibrated_by_keplerid(keplerIds,    mjdStart, mjdEnd);
    check_this(calLc, uncalLc, keplerIds);    
    calLcSingle   = retrieve_pixel_time_series_calibrated_by_keplerid(  keplerIds(1), mjdStart, mjdEnd);
    uncalLcSingle = retrieve_pixel_time_series_uncalibrated_by_keplerid(keplerIds(1), mjdStart, mjdEnd);
    check_this(calLcSingle, uncalLcSingle, keplerIds(1));
    
    % One default
    calLc         = retrieve_pixel_time_series_calibrated_by_keplerid(  keplerIds,    mjdStart, mjdEnd, 1);
    uncalLc       = retrieve_pixel_time_series_uncalibrated_by_keplerid(keplerIds,    mjdStart, mjdEnd, 1);
    check_this(calLc, uncalLc, keplerIds);    
    calLcSingle   = retrieve_pixel_time_series_calibrated_by_keplerid(  keplerIds(1), mjdStart, mjdEnd, 1);
    uncalLcSingle = retrieve_pixel_time_series_uncalibrated_by_keplerid(keplerIds(1), mjdStart, mjdEnd, 1);
    check_this(calLcSingle, uncalLcSingle, keplerIds(1));
    
    % No default
    calLc         = retrieve_pixel_time_series_calibrated_by_keplerid(  keplerIds,    mjdStart, mjdEnd, 1, 1);
    uncalLc       = retrieve_pixel_time_series_uncalibrated_by_keplerid(keplerIds,    mjdStart, mjdEnd, 1, 1);
    check_this(calLc, uncalLc, keplerIds);    
    calLcSingle   = retrieve_pixel_time_series_calibrated_by_keplerid(  keplerIds(1), mjdStart, mjdEnd, 1, 1);
    uncalLcSingle = retrieve_pixel_time_series_uncalibrated_by_keplerid(keplerIds(1), mjdStart, mjdEnd, 1, 1);
    check_this(calLcSingle, uncalLcSingle, keplerIds(1));    
    
    try
        calLc = retrieve_pixel_time_series_calibrated_by_keplerid([], mjdStart, mjdEnd, 1) %#ok<NASGU>
        assert(false); % no error-- fail test
    catch
        assert(true); % expected error-- pass test
    end
return

function check_this(calLc, uncalLc, keplerIds)
    length(calLc.keplerIdTimeSeriesStruct)
    assert(length(calLc.keplerIdTimeSeriesStruct)   == length(keplerIds));
    assert(length(uncalLc.keplerIdTimeSeriesStruct) == length(keplerIds));

    assert(length(calLc.mjdArray)   > 1);
    assert(length(uncalLc.mjdArray) > 1);

    for ii = 1:length(keplerIds)
        assert(length(calLc.mjdArray)   <= size(calLc.keplerIdTimeSeriesStruct(ii).timeSeries, 1));
        assert(length(uncalLc.mjdArray) <= size(uncalLc.keplerIdTimeSeriesStruct(ii).timeSeries, 1));

        assert(length(calLc.keplerIdTimeSeriesStruct(ii).row)   == size(calLc.keplerIdTimeSeriesStruct(ii).timeSeries, 2));
        assert(length(uncalLc.keplerIdTimeSeriesStruct(ii).row) == size(uncalLc.keplerIdTimeSeriesStruct(ii).timeSeries, 2));
    end
return
