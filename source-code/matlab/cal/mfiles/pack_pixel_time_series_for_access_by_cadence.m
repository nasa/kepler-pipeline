function [nInvocations, nPackedPixelSeries] = ...
    pack_pixel_time_series_for_access_by_cadence(firstCall, lastCall, ...
    pixelTimeSeries, nTotalPixelSeries, nCadences, localFilenames)
% function [nInvocations, nPackedPixelSeries] = ...
% pack_pixel_time_series_for_access_by_cadence(firstCall, lastCall, ...
% pixelTimeSeries, nTotalPixelSeries, nCadences, localFilenames)
%
% For each invocation, pack new pixel time series into a two-dimensional
% array of size nTotalPixelSeries by nCadences for further processing of all
% module output pixels by cadence. The array is loaded from a state (.mat)
% file for each invocation and saved to the same file once the new pixel
% series have been included.
%
%
% INPUT:  The following arguments must be provided to this function.
%
%
%                       firstCall: [logical]  flag indicates first invocation
%                        lastCall: [logical]  flag indicates last invocation
%            pixelTimeSeries: [struct array]  requantized pixel values and gap
%                                             indicators
%                   nTotalPixelSeries: [int]  total pixels for module output
%                           nCadences: [int]  number of cadences per pixel
%
%   Second level
%
%  pixelTimeSeries is an array of structs (one per pixel) containing the
%  following fields:
%
%                        values: [int array]  requantized pixel values
%             gapIndicators: [logical array]  missing data indicators
%
%
%
%  OUTPUT:  The following are returned by this function.
%
%
%   Top Level
%
%                        nInvocations: [int]  number of invocations of this
%                                             function
%                  nPackedPixelSeries: [int]  number of pixel time series
%                                             packed thus far
%
%--------------------------------------------------------------------------
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


% Define constant.
NAN_VALUE = -1;

% Initialize variables.
nPixels = length(pixelTimeSeries);
stateFilename = [localFilenames.stateFilePath, localFilenames.calCompEffFilename];


% Initialize the state if this is the first invocation, otherwise load
% the state from the state file.
if firstCall

    % If the first invocation flag is set, then allocate space for
    % a new array of requantized pixel values for the full module
    % output. Set the prior invocation number and the number of
    % packed pixel series to 0.
    requantPixelValuesArray = zeros([nTotalPixelSeries, nCadences], 'int32');
    nInvocations = 0;
    nPackedPixelSeries = 0;

else % not the first invocation

    % Load the state from the state file. Throw an error if the
    % state file does not exist.
    nTotalPixelSeriesIn = nTotalPixelSeries;
    nCadencesIn = nCadences;

    if ~exist(stateFilename, 'file')
        error('CAL:packPixelTimeSeriesForAccessByCadence:missingStateFile', ...
            'CAL state file is missing')
    end

    load(stateFilename, 'requantPixelValuesArray', 'nInvocations', ...
        'nPackedPixelSeries', 'nTotalPixelSeries', 'nCadences');

    if ~exist('requantPixelValuesArray', 'var')
        error('CAL:packPixelTimeSeriesForAccessByCadence:loadFailure', ...
            'Unable to load requantPixelValuesArray from state file');
    end

    % Perform invocation to invocation consistency checks.
    if nTotalPixelSeriesIn ~= nTotalPixelSeries
        error('CAL:packPixelTimeSeriesForAccessByCadence:invalidInputParameter', ...
            'Inconsistent number of total pixel series (%d vs %d)', ...
            nTotalPixelSeriesIn, nTotalPixelSeries);
    end

    if nCadencesIn ~= nCadences
        error('CAL:packPixelTimeSeriesForAccessByCadence:invalidInputParameter', ...
            'Inconsistent number of cadences (%d vs %d)', ...
            nCadencesIn, nCadences);
    end

end % if/else

% Perform some additional error checks. Bounds checks should be
% performed when CAL class objects are instantiated by the
% cal_matlab_controller.
for iPixel = 1 : nPixels

    values = pixelTimeSeries(iPixel).values;

    if nCadences ~= length(values)
        error('CAL:packPixelTimeSeriesForAccessByCadence:invalidPixelValuesLength', ...
            'Invalid pixel values vector length (%d vs %d)', ...
            length(values), nCadences)
    end

    gapIndicators = pixelTimeSeries(iPixel).gapIndicators;

    if nCadences ~= length(gapIndicators)
        error('CAL:packPixelTimeSeriesForAccessByCadence:invalidGapIndicatorsLength', ...
            'Invalid gap indicators vector length (%d vs %d)', ...
            length(gapIndicators), nCadences)
    end

end

% Pack the new pixel time series into the requantized pixel values array for
% further processing. The size of the full array is nTotalPixelSeries by
% nCadences. Although the time series are provided on a pixel by pixel basis,
% the compression efficiency must be determined on a cadence by cadence basis.
% First set all missing pixel values to NaN so that the gap indicators must
% not be stored as well.
requantPixelValues = [pixelTimeSeries.values]';
gapIndicators = [pixelTimeSeries.gapIndicators]';
requantPixelValues(gapIndicators) = NAN_VALUE;

startRow = 1 + nPackedPixelSeries;
nPackedPixelSeries = nPackedPixelSeries + nPixels;
endRow = nPackedPixelSeries;
if endRow <= nTotalPixelSeries
    requantPixelValuesArray(startRow : endRow, : ) = requantPixelValues;                                      %#ok<NASGU>
else
    error('CAL:packPixelTimeSeriesForAccessByCadence:incorrectArraySize', ...
        'Incorrect requant pixel values array size (%d rows vs %d)', ...
        endRow, nTotalPixelSeries)
end

% Perform one last check if this is the last invocation.
if lastCall
    if nTotalPixelSeries ~= nPackedPixelSeries
        error('CAL:packPixelTimeSeriesForAccessByCadence:incorrectNumberPixelSeries', ...
            'Incorrect number of total pixel time series (%d vs %d)', ...
            nPackedPixelSeries, nTotalPixelSeries)
    end
end

% Update the number of invocations and save the state. Use -v7.3 option for
% save because requantPixelValuesArray can exceed 2 GB.
nInvocations = nInvocations + 1;

% clear warning message
lastwarn('');

% try to save under v7.0
save( stateFilename, 'requantPixelValuesArray', 'nInvocations', ...
    'nPackedPixelSeries', 'nTotalPixelSeries', 'nCadences');

% if warning is issued and contains 'use the -v7.3 switch' re-save under v7.3
if ~isempty(lastwarn) && ~isempty(strfind(lastwarn,'use the -v7.3 switch'))
    save('-v7.3', stateFilename, 'requantPixelValuesArray', 'nInvocations', ...
    'nPackedPixelSeries', 'nTotalPixelSeries', 'nCadences');
end

% Return.
return
