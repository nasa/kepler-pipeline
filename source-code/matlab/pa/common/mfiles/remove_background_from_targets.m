function targetStarStruct = remove_background_from_targets(targetStarStruct, ...
    backgroundCoeffStruct, backgroundGaps, backgroundConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function targetStarStruct = remove_background_from_targets(targetStarStruct, ...
%     backgroundCoeffStruct, backgroundGaps, backgroundConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Remove the background signal contained in backgroundCoeffStruct from the
% pixels in each target aperture, properly updating pixelUncertainties
%
% inputs: 
%   targetStarStruct(): 1D array of structures describing targets that contain
%   at least the following fields:
%       .pixelTimeSeriesStruct() # of pixels x 1 array of structures
%           descrbing pixels that contain the following fields:
%           .timeSeries() # of cadences x 1 array containing pixel brightness
%               time series.  
%           .uncertainties() # of cadences x 1 array containing uncertainty
%               in pixel brightness.  
%           .gapList() # of gaps x 1 array containing the index of gaps in
%               .timeSeries
%           .row row of this pixel
%           .column column of this pixel
%       .referenceRow row relative to which the pixels in the target are
%           located, typically the row of the target centroid
%       .referenceColumn column relative to which the pixels in the target are
%           located, typically the column of the target centroid
%   backgroundCoeffStruct() 1 x # of cadences array of polynomial
%       coefficient structs as returned by robust_polyfit2d()
%   backgroundConfigurationStruct: structure containing various
%       configuration parameters
%
% output: updates the following fields to each element of targetStarStruct 
%   with background-removed data:
%       .pixelTimeSeriesStruct() # of pixels x 1 array of structures
%           descrbing pixels that contain the following fields:
%           .timeSeries() # of cadences x 1 array containing pixel brightness
%               time series.  
%           .uncertainties() # of cadences x 1 array containing uncertainty
%               in pixel brightness.  
%
%   See also REMOVE_BACKGROUND_FROM_PIXELS
%
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

targetChunkSize = backgroundConfigurationStruct.targetBgRemovalChunkSize;

% get the number of targets
nTargets = length(targetStarStruct);
% get the number of cadences, which we assume to be the same for all pixels
nCadences = length(targetStarStruct(1).pixelTimeSeriesStruct(1).timeSeries);

% to avoid memory problems we treat the targets in chunks
targetStart = 1;
while targetStart <= nTargets
    % set the end of this chunk
    targetEnd = targetStart + targetChunkSize;
    % make sure we don't exceed the number of targets
    if targetEnd > nTargets
        targetEnd = nTargets;
    end
    % the range of targets in this chunk
    targetRange = targetStart:targetEnd;
    
    % count the total number of pixels in this chunk
    nTotalPixels = 0;
    for target = targetRange
        nTotalPixels = nTotalPixels + length(targetStarStruct(target).pixelTimeSeriesStruct);
    end
    pixelValues = zeros(nCadences, nTotalPixels);
    pixelUncertainties = zeros(nCadences, nTotalPixels);
    row = zeros(nTotalPixels, 1);
    column = zeros(nTotalPixels, 1);

    % collect the pixels values and uncertainties for the targets in this
    % chunk into an array for quick background removal a cadence at a time
    pixelOffset = 1;
    for target = targetRange
        % dereference this target structure
        targetStruct = targetStarStruct(target);
        % dereference this target pixel structure array
        pixelStruct = targetStruct.pixelTimeSeriesStruct;
        % get the number of pixels in this target
        nPixels = length(pixelStruct);

        % put the pixel time series for all pixels in a 2D array for
        % convenience
        % package the pixel values into a nCadences x nTotalPixels array
        % for processing a cadence at a time
        pixelValues(:,pixelOffset:pixelOffset+nPixels-1) = ...
            horzcat(pixelStruct.timeSeries);
        pixelUncertainties(:,pixelOffset:pixelOffset+nPixels-1) = ...
            horzcat(pixelStruct.uncertainties);

        % get the row and column of the pixels
        row(pixelOffset:pixelOffset+nPixels-1) = [pixelStruct.row];
        column(pixelOffset:pixelOffset+nPixels-1) = [pixelStruct.column];

        pixelOffset = pixelOffset + nPixels;
    end % all targets are set up

    % remove the background
    [pixelValues, pixelUncertainties] = ...
        remove_background_from_pixels(pixelValues, pixelUncertainties, ...
        row, column, backgroundCoeffStruct);

    % redistribute the result to the output time series
    pixelOffset = 0;
    for target = targetRange
        nPixels = length(targetStarStruct(target).pixelTimeSeriesStruct);
        for pixel = 1:nPixels 
            targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries = ...
                pixelValues(:, pixelOffset + pixel);
            targetStarStruct(target).pixelTimeSeriesStruct(pixel).uncertainties = ...
                pixelUncertainties(:, pixelOffset + pixel);
            % zero out the gaps since they were messed up by the background
            % subtraction
            gapList = targetStarStruct(target).pixelTimeSeriesStruct(pixel).gapList;
            targetStarStruct(target).pixelTimeSeriesStruct(pixel).timeSeries(gapList) = 0;
            targetStarStruct(target).pixelTimeSeriesStruct(pixel).uncertainties(gapList) = 0;
        end
        pixelOffset = pixelOffset + nPixels;
    end % all targets are redistributed
    
    clear pixelValues pixelUncertainties
    targetStart = targetEnd + 1;
end % next target chunk

    