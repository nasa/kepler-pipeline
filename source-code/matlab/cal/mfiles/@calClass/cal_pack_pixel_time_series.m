function [nInvocations, nPackedPixelSeries] = cal_pack_pixel_time_series(calObject)
% function [nInvocations, nPackedPixelSeries] = cal_pack_pixel_time_series(calObject)
%
% Interface between cal_matlab_controller and pack_pixel_time_series_for_access_by_cadence function.
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


% start clock
tic;
metricsKey = metrics_interval_start;

% Combine the new pixels into a single array of pixel time series
% structures.
[pixelTimeSeries] = ...
    create_single_time_series([], calObject.blackPixels);
[pixelTimeSeries] = ...
    create_single_time_series(pixelTimeSeries, calObject.maskedBlackPixels);
[pixelTimeSeries] = ...
    create_single_time_series(pixelTimeSeries, calObject.virtualBlackPixels);
[pixelTimeSeries] = ...
    create_single_time_series(pixelTimeSeries, calObject.maskedSmearPixels);
[pixelTimeSeries] = ...
    create_single_time_series(pixelTimeSeries, calObject.virtualSmearPixels);
[pixelTimeSeries] = ...
    create_single_time_series(pixelTimeSeries, calObject.targetAndBkgPixels);

% Pack available pixels for later processing by cadence. Throw an error if
% there are no pixels at all.
if ~isempty(pixelTimeSeries)

    [nInvocations, nPackedPixelSeries] = save_pixel_time_series_for_access_by_cadence(calObject, pixelTimeSeries);    
    
else
    error('CAL:calPackPixelTimeSeries:noPixelsForCalibration', 'No input pixels for calibration')
end

display_cal_status('CAL:cal_matlab_controller: Pixel time series packing complete', 1);
metrics_interval_stop('cal.cal_pack_pixel_time_series.execTimeMillis',metricsKey);

return


function [pixelTimeSeries] = create_single_time_series(pixelTimeSeries, newPixels)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pixelTimeSeries] = ....
% create_single_time_series(pixelTimeSeries, newPixels)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Create a single array of pixel time series structs with values and gap
% indicators fields. The length of the values and gap indicators for all of
% the time series should be equal to the number of cadences.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% Proceed only if new pixels structure is not empty.
if ~isempty(newPixels)
    
    % Set the fields to keep.
    desiredFields = {'values' ; 'gapIndicators'};

    % Get the names of the fields in the new input structure.
    inputFields = fieldnames(newPixels);

    % Remove unwanted fields from the new input structure.
    newPixels = rmfield(newPixels, setxor(inputFields, desiredFields));

    % Concatenate new pixels with existing pixel time series.
    pixelTimeSeries = [pixelTimeSeries newPixels];

end

return
