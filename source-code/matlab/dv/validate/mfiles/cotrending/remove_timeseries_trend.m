function [detrendedTimeSeries] = ...
remove_timeseries_trend(conditionedAncillaryDataArray, timeSeriesToDetrend, ...
ancillaryDesignMatrixConfigurationStruct, pdcConfigurationStruct, ...
saturationSegmentConfigurationStruct, gapFillConfigurationStruct, ...
restoreMeanFlag, dataAnomalyIndicators)
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [residualFluxTimeSeries] = ...
% remove_timeseries_trend(conditionedAncillaryDataArray, timeSeriesToDetrend, ...
% ancillaryDesignMatrixConfigurationStruct, pdcConfigurationStruct, ...
% saturationSegmentConfigurationStruct, gapFillConfigurationStruct, ...
% restoreMeanFlag, dataAnomalyIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Use PDC cotrending to remove the trend from the given (array of) time
% series based on the conditioned ancillary data provided as an input
% argument. By default, do not restore the mean levels for each time
% series and do not set data anomaly flags. Assume that identification of
% saturated segments is not necessary.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% Check if there are any valid targets and return if there are not.
% Otherwise, get the number of cadences.
nSeries = length(timeSeriesToDetrend);

if nSeries == 0
    detrendedTimeSeries = [];
    return
end % if

nCadences = length(timeSeriesToDetrend(1).values);

% Check optional arguments and set default values if necessary.
if ~exist('restoreMeanFlag', 'var')
    restoreMeanFlag = false;
end % if

if ~exist('dataAnomalyIndicators', 'var')
    dataAnomalyIndicators = struct( ...
        'attitudeTweakIndicators', false([nCadences, 1]), ...
        'safeModeIndicators', false([nCadences, 1]), ...
        'earthPointIndicators', false([nCadences, 1]), ...
        'coarsePointIndicators', false([nCadences, 1]), ...
        'argabrighteningIndicators', false([nCadences, 1]), ...
        'excludeIndicators', false([nCadences, 1]), ...
        'planetSearchExcludeIndicators', false([nCadences, 1]));
end % if

% Add Kepler magnitudes to not allow identification of saturated segments
% and detrending within each segment.
keplerMagCellArray = num2cell(20 * ones([1, nSeries]));
[timeSeriesToDetrend(1 : nSeries).keplerMag] = keplerMagCellArray { : };

% Perform the detrending without restoring the mean level for the
% respective time series.
[detrendedTimeSeries] = ...
    correct_systematic_error_for_all_target_tables( ...
    conditionedAncillaryDataArray, timeSeriesToDetrend, ...
    ancillaryDesignMatrixConfigurationStruct, pdcConfigurationStruct, ...
    saturationSegmentConfigurationStruct, gapFillConfigurationStruct, ...
    restoreMeanFlag, dataAnomalyIndicators);

% Copy the filled indices from the time series to detrend to the detrended
% time series if they exist.
if isfield(timeSeriesToDetrend, 'filledIndices')
    filledIndicesCellArray = {timeSeriesToDetrend.filledIndices};
    [detrendedTimeSeries(1 : nSeries).filledIndices] = ...
        filledIndicesCellArray{ : };
end % if

% Return.
return
