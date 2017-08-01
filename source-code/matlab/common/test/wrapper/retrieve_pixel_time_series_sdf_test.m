function retrieve_pixel_time_series_sdf_test()
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
    mods = [7];
    outs = [3];
    startMjd = 55003;
    endMjd   = 55089;

    verify_pixels(mods, outs, startMjd, endMjd);
return

function verify_pixels(mods, outs, startMjd, endMjd)
    isCalibrateds = [0 1];
    isLongCadences = [0 1];
    for isLongCadence = isLongCadences
        for isCalibrated = isCalibrateds

            if ~isLongCadence
                endMjd = startMjd + 5;
            end
            pixels = retrieve_pixel_time_series_sdf(mods, outs, startMjd, endMjd, isLongCadence, isCalibrated);
            assert_equals(size(pixels), size(mods));

            for i = 1:length(pixels)
                validate_channel_struct(pixels(i), isCalibrated);
                verify_time_series(pixels(i), mods(i), outs(i), startMjd, endMjd, isLongCadence, isCalibrated);
                verify_collateral_and_background(pixels(i), startMjd, endMjd, isLongCadence, isCalibrated);
            end
            
        end
    end
return


function verify_collateral_and_background(pixels, startMjd, endMjd, isLongCadence, isCalibrated)
    numCadences = length(pixels.mjdArray);
    maxNumLongCadences = (endMjd - startMjd)*48;
    maxNumShortCadences = maxNumLongCadences * 30;
%     if isLongCadence
%         assert(numCadences <= maxNumLongCadences);
%     else
%         assert(numCadences <= maxNumShortCadences);
%     end
    
    assert(numCadences <= length(pixels.collateralData(1).timeSeries));
    assert(numCadences <= length(pixels.collateralData(end).timeSeries));
    assert_equals(length(pixels.collateralData(1).timeSeries), length(pixels.collateralData(end).timeSeries));
    
    if isCalibrated
        assert(numCadences <= length(pixels.calibratedBackgroundPixelData(1).timeSeries));
        assert(numCadences <= length(pixels.calibratedBackgroundPixelData(end).timeSeries));
        isCompletelyGapped = sum(pixels.calibratedBackgroundPixelData(1).gapIndicators) == length(pixels.calibratedBackgroundPixelData(1).gapIndicators);
        if ~isCompletelyGapped
            assert(sum(pixels.calibratedBackgroundPixelData(1).timeSeries) > 0);
            assert(sum(pixels.calibratedBackgroundPixelData(end).timeSeries) > 0);
        end
    else
        assert(numCadences <= length(pixels.uncalibratedBackgroundPixelData(1).timeSeries));
        assert(numCadences <= length(pixels.uncalibratedBackgroundPixelData(end).timeSeries));
        
        isCompletelyGapped = sum(pixels.uncalibratedBackgroundPixelData(1).gapIndicators) == length(pixels.uncalibratedBackgroundPixelData(1).gapIndicators);
        if ~isCompletelyGapped
            assert(sum(pixels.uncalibratedBackgroundPixelData(1).timeSeries) > 0);
            assert(sum(pixels.uncalibratedBackgroundPixelData(end).timeSeries) > 0);
        end
    end
return

function verify_time_series(pixels, mod, out, startMjd, endMjd, isLongCadence, isCalibrated)   
    assert_equals(mod, pixels.module); assert_equals(out, pixels.output);
    
    numCadences = length(pixels.mjdArray);
    maxNumLongCadences = (endMjd - startMjd)*48;
    maxNumShortCadences = maxNumLongCadences * 30;
%     if isLongCadence
%         assert(numCadences <= maxNumLongCadences);
%     else
%         assert(numCadences <= maxNumShortCadences);
%     end

    for i = 1:length(pixels.keplerIdTimeSeriesStruct)
        ts = pixels.keplerIdTimeSeriesStruct(i);
    
        assert_equals(length(ts.row), length(ts.column));
        assert_equals(length(ts.row), length(ts.isInOptimalAperture));
        if isCalibrated
            assert_equals(length(ts.row), size(ts.timeSeries, 2));
            assert_equals(size(ts.timeSeries), size(ts.uncertainties));
            assert_equals(size(ts.timeSeries), size(ts.gapIndicators));
            assert(sum(sum(ts.timeSeries)) > 0);
            assert_equals(sum(sum(ts.timeSeriesUncalibrated)), 0);
        else
            assert_equals(length(ts.row), size(ts.timeSeriesUncalibrated, 2));
            assert_equals(length(ts.timeSeries), 0);
            assert_equals(size(ts.timeSeriesUncalibrated), size(ts.gapIndicators));
            assert(sum(sum(ts.timeSeriesUncalibrated)) > 0);
            assert_equals(sum(sum(ts.timeSeries)), 0);
        end
    end
return

function validate_channel_struct(pixels, isCalibrated)
    % Verify the fields of the structs:

    fields = {'module', 'output', 'mjdArray', 'isLongCadence', 'isOriginalData', 'keplerIdTimeSeriesStruct', 'calibratedBackgroundPixelData', 'uncalibratedBackgroundPixelData', 'collateralData'};
    assert_equals(sum(isfield(pixels, fields)), length(fields))
    
    timeSeriesStructFields = { 'keplerId', 'row', 'column', 'isInOptimalAperture', 'timeSeries', 'uncertainties', 'timeSeriesUncalibrated', 'gapIndicators' };
    assert_equals(sum(isfield(pixels.keplerIdTimeSeriesStruct, timeSeriesStructFields)), length(timeSeriesStructFields));

    bkgPixFields = { 'row', 'column', 'isInOptimalAperture', 'timeSeries', 'uncertainties', 'gapIndicators' };
    if isCalibrated
        assert_equals(sum(isfield(pixels.calibratedBackgroundPixelData(1), bkgPixFields)), length(bkgPixFields));
    else
        assert_equals(sum(isfield(pixels.uncalibratedBackgroundPixelData(1), bkgPixFields)), length(bkgPixFields) - 1);
    end
    
    collateralFields = { 'coordinate', 'type', 'timeSeries', 'gapIndicators' };
    assert_equals(sum(isfield(pixels.collateralData(1), collateralFields)), length(collateralFields));
return


