function backgroundCoeffStruct = fit_background_by_time_series(backgroundStruct, ...
    backgroundConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function backgroundCoeffStruct = fit_background_by_time_series(backgroundStruct, ...
%     backgroundConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Compute a time series of background polynomials from background pixels
% organized by time series by reorganizing the data by cadence
% and calling fit_background_by_cadence
%
% inputs: 
%   backgroundStruct(): 1 x # of pixels array of structures describing
%       background pixels that contain at least the following fields:
%   	.timeSeries() # of cadences x 1 array containing pixel brightness
%               time series.  
%       .uncertainties() # of cadences x 1 array containing uncertainty
%               in pixel brightness.  
%   	.gapList() # of gaps x 1 array containing the index of gaps in
%               .timeSeries
%    	.row, column row, column of this pixel in CCD coordinates
%   backgroundConfigurationStruct: structure containing various
%       configuration parameters
%
% output: 
%   backgroundCoeffStruct() 1 x # of cadences array of polynomial
%   coefficient structs as returned by robust_polyfit2d()
%
%   See also FIT_BACKGROUND_BY_CADENCE
%   BUILD_BACKGROUND_CONFIGURATION_STRUCT
%
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

% get the size of a chunk of cadences to process at a time
cadenceChunkSize = backgroundConfigurationStruct.fitCadenceChunkSize;

% get the dimensions of the pixel data
nPixels = length(backgroundStruct);
nCadences = length(backgroundStruct(1).timeSeries);

% make a sparse array containing 1's flagging data gaps for all pixels and
% all cadences 
nGaps = length(vertcat(backgroundStruct.gapList));
% initialize the sparse array
gapArray = sparse(nCadences, nPixels);
% add each pixel's gaps to the sparse array.  This line works because the
% contents of gapList are the cadences at which gaps appear
for pixel = 1:nPixels
    gapArray = gapArray + sparse(backgroundStruct(pixel).gapList, pixel, 1, ...
        nCadences, nPixels, nGaps);
end

% we process the cadences in chunks to avoid memory issues
% initialize tracking of cadence chunks
startCadence = 1;
% for each chunk do the background fit 
while startCadence <= nCadences
    % set the endCadence value
    endCadence = startCadence + cadenceChunkSize;
    % make sure we didn't exceed nCadences
    if endCadence > nCadences
        endCadence = nCadences;
    end
    % operating range of cadences
    cadenceRange = startCadence:endCadence;
    % # of cadences in this chunk
    cadenceChunkSize = length(cadenceRange);
    
    % put the pixel time series for all pixels in a 2D array organized by
    % cadence for this chunk
    backgroundPixels = zeros(cadenceChunkSize, nPixels);
    backgroundUncertainties = zeros(cadenceChunkSize, nPixels);
    for pixel = 1:nPixels
        backgroundPixels(:, pixel) = backgroundStruct(pixel).timeSeries(cadenceRange);
        backgroundUncertainties(:, pixel) = backgroundStruct(pixel).uncertainties(cadenceRange);
    end
   
    % do the background fit
    backgroundCoeffStruct(cadenceRange) = fit_background_by_cadence(...
        backgroundPixels, backgroundUncertainties, ...
        [backgroundStruct.row]', [backgroundStruct.column]', ...
        gapArray(cadenceRange,:), backgroundConfigurationStruct);
    
    % set start of next cadence chunk
    startCadence = endCadence + 1;
end