function [nInvocations, nPackedPixelSeries] = save_pixel_time_series_for_access_by_cadence(calObject, pixelTimeSeries) 
% 
% function [nInvocations, nPackedPixelSeries] = save_pixel_time_series_for_access_by_cadence(calObject, pixelTimeSeries) 
%
% This calClass method is modeled after pack_pixel_time_series_for_access_by_cadence but changes the way the state file is updated in order to
% break the invocation order dependence. A separate file containg the calibrated pixel time series is saved for each invocation in an
% invocation file. On the last invoaction, these files are read back in and the pixel array concatenated. That large array is then saved to
% the compression efficiency state file.
%
% INPUT:
%   Top level
%        calObject: [calClass object]   object containing CAL input data
%     pixelTimeSeries: [struct array]   requantized pixel values and gap indicators
%
%   Second level
%
%  pixelTimeSeries is an array of structs (one per pixel) containing the following fields:
%
%                 values: [int array]   requantized pixel values
%      gapIndicators: [logical array]   missing data indicators
%
% OUTPUT:
%                nInvocations: [int]    number of invocations of this function
%          nPackedPixelSeries: [int]    number of pixel time series packed thus far
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


% define special nan constant
NAN_VALUE = -1;

% extract stuff from object
lastCall    = calObject.lastCall;
localFiles  = calObject.localFilenames;
invocation  = calObject.calInvocationNumber;
totalPixels = calObject.totalPixels;

stateFilename = localFiles.calCompEffFilename;
invocationFilename = localFiles.invocationCompFilename;
stateFilePath = calObject.localFilenames.stateFilePath;
compRootFilename = [stateFilePath,localFiles.compRootFilename];

% initialize variables
nCadences = length(pixelTimeSeries(1).values);

% Transpose the incoming pixel time series, convert to 32-bit integer and save to
% local file for further processing. Although the time series are provided on a
% pixel by pixel basis, the compression efficiency must be determined on a cadence
% by cadence basis. First set all missing pixel values to NaN so that the gap
% indicators must not be stored as well.

requantPixelValues = int32([pixelTimeSeries.values]');
gapIndicators = [pixelTimeSeries.gapIndicators]';
requantPixelValues(gapIndicators) = NAN_VALUE;                                                              

if ~lastCall
    
    % calculate return values
    nTotalPixelSeries = totalPixels;                                            %#ok<NASGU>
    nCurrentPixels = size(requantPixelValues,1);
    nPackedPixelSeries = nCurrentPixels;
    nInvocations = invocation + 1;  

    % Save the invocation file (use -v7.3 switch if variables > 2Gbytes)

    % clear warning message
    lastwarn('');
    % try to save under v7.0
    save( [stateFilePath, invocationFilename], 'requantPixelValues', 'nInvocations', ...
        'nPackedPixelSeries', 'nTotalPixelSeries', 'nCadences');
    % if warning is issued and contains 'use the -v7.3 switch' re-save under v7.3
    if ~isempty(lastwarn) && ~isempty(strfind(lastwarn,'use the -v7.3 switch'))
        save('-v7.3', [stateFilePath, invocationFilename], 'requantPixelValues', 'nInvocations', ...
        'nPackedPixelSeries', 'nTotalPixelSeries', 'nCadences');
    end
    
else
    
    % If compression efficiency state file already exists just return out of function
    % This condition should only occur if the lastCall invocation crashed on the previous attempt after
    % the state file was written in this method and it is now being re-run
    if exist([stateFilePath, stateFilename],'file') == 2
        load([stateFilePath, stateFilename],'nInvocations','nPackedPixelSeries');
        return;
    end
    
    % preallocate space for all pixels as 32-bit integers
    requantPixelValuesArray = zeros([totalPixels, nCadences], 'int32');
    
    % place the last invocation pixels in the right spot
    nCurrentPixels = size(requantPixelValues,1);
    requantPixelValuesArray((totalPixels - nCurrentPixels + 1):end, : ) = requantPixelValues;
    
    % get the rest of the invocations and load them
    nPackedPixelSeries = nCurrentPixels;
    startRow = 1;
    for i = 0:(invocation - 1)
        
        % read 'em
        currentFile = [compRootFilename,'_',num2str(i),'.mat'];
        load(currentFile,'requantPixelValues');
        nCurrentPixels = size(requantPixelValues,1);
        
        % load 'em
        requantPixelValuesArray(startRow:(startRow + nCurrentPixels - 1), : ) = requantPixelValues;
        
        % adjust index and running pixel count
        startRow = startRow + nCurrentPixels;
        nPackedPixelSeries = nPackedPixelSeries + nCurrentPixels;
        
    end
    
        
    % Perform check on the total number of pixels
    if totalPixels ~= nPackedPixelSeries
        error('CAL:packPixelTimeSeriesForAccessByCadence:incorrectNumberPixelSeries', ...
            'Incorrect number of total pixel time series (%d vs %d)', ...
            nPackedPixelSeries, totalPixels)
    end
    
    % Update variables used in legacy comp eff state files
    nInvocations = invocation + 1;
    nTotalPixelSeries = totalPixels;                                                            %#ok<NASGU>

    
    % save the state file
    
    % clear warning message
    lastwarn('');
    % try to save under v7.0
    save( [stateFilePath, stateFilename], 'requantPixelValuesArray', 'nInvocations', ...
        'nPackedPixelSeries', 'nTotalPixelSeries', 'nCadences');
    % if warning is issued and contains 'use the -v7.3 switch' re-save under v7.3
    if ~isempty(lastwarn) && ~isempty(strfind(lastwarn,'use the -v7.3 switch'))
        save('-v7.3', [stateFilePath, stateFilename], 'requantPixelValuesArray', 'nInvocations', ...
        'nPackedPixelSeries', 'nTotalPixelSeries', 'nCadences');
    end
        
end


