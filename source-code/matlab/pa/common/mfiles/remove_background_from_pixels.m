function [pixelValues, pixelUncertainties, pouStructArray] = ...
    remove_background_from_pixels(pixelValues, pixelUncertainties, ...
    row, column, backgroundCoeffStruct, gapArray, pouConfigStruct, pouStructArray)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pixelValues, pixelUncertainties, pouStructArray] = ...
%     remove_background_from_pixels(pixelValues, pixelUncertainties, ...
%     row, column, backgroundCoeffStruct, gapArray, pouConfigStruct, pouStructArray)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Remove the background signal contained in backgroundCoeffStruct from the
% pixelValues, properly updating pixelUncertainties
%
% inputs: 
%   pixelValues() # of cadences x # of pixels array of pixel values.  
%   pixelUncertainties() # of cadences x # of pixels array containing
%       uncertainties in pixel values.
%   row(), column() # of pixels x 1 array containing row and column of each
%       pixel in CCD module output coordinates. 
%   backgroundCoeffStruct() 1 x # of cadences array of polynomial
%       coefficient structs as returned by robust_polyfit2d().
%   gapArray() # of cadences x # of pixels array of optional gap indicators.
%   pouConfigStruct: optional POU structure with POU parameters and # of cadences
%       x 1 array of absolute cadence numbers.
%
% output: 
%   pixelValues() # of cadences x # of pixels array of background removed 
%       pixel values.  
%   pixelUncertainties() # of cadences x # of pixels array containing
%       uncertainties in background removed pixel values.
%
%   See also WEIGHTED_POLYVAL2D, ADD_WITH_UNCERTAINTIES
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

% hard coded
MAX_POU_PIXELS = 250;                   % maximum pixels in target for full pou


% create array of (false) gap indicators if one was not provided
if ~exist('gapArray', 'var') || isempty(gapArray)
    gapArray = false(size(pixelValues));
end

% set pouEnabled to false if a pouConfigStruct was not provided
if ~exist('pouConfigStruct', 'var') || isempty(pouConfigStruct)
    pouEnabled = false;
else
    pouEnabled = pouConfigStruct.pouEnabled;
    cadenceChunkSize = pouConfigStruct.pouCadenceChunkSize;
    interpDecimation = pouConfigStruct.pouInterpDecimation;
    interpMethod = pouConfigStruct.pouInterpMethod;
    cadenceNumbers = pouConfigStruct.cadenceNumbers;
end

% initialize pouStructArray to empty if it was not passed in
if ~exist('pouStructArray','var')
    pouStructArray = [];
end

% get the # of pixels
nPixels = size(pixelValues, 2);

% get the # of cadences
nCadences = size(pixelValues, 1);

% check that we have the required data sizes
if length(row) ~= length(column) || length(row) ~= nPixels
    error('PA:Common:remove_background_from_pixels', ...
        '# of rows, columns and pixels not in agreement');
end
if ~isempty(pixelUncertainties) && ...
        ~isequal(size(pixelUncertainties), size(pixelValues))
    error('PA:Common:remove_background_from_pixels', ...
        'pixel and uncertainty sizes not the same');
end 
if length(backgroundCoeffStruct) ~= nCadences
    error('PA:Common:remove_background_from_pixels', ...
        '# of coefficient structs not equal to # of cadences');
end


% get the decimated cadences for which the target covariances will be
% computed without interpolation if POU is enabled. Check max pixels condition.
if pouEnabled
    if nPixels > MAX_POU_PIXELS
        disp(['nPixels = ',num2str(nPixels),' which is > MAX_POU_PIXELS (', num2str(MAX_POU_PIXELS),'). Disabling full pou for pixel set.']);
        pouEnabledForPixels = false;
    else
        decimatedCadenceList = downsample(cadenceNumbers, interpDecimation);
        chunkedCadenceList = [];
        pouEnabledForPixels = true;
    end
else
    pouEnabledForPixels = false;
end
        
% remove the background cadence by cadence
for iCadence = 1 : nCadences 
    
    % get the background/uncertainty estimate for these pixel's rows and
    % columns
    backgroundPoly = backgroundCoeffStruct(iCadence);
    [backgroundValues, backgroundUncertainties, Aback] = ...
        weighted_polyval2d(row, column, backgroundPoly);

    gapIndicators = gapArray(iCadence, : );
    
    if isempty(pixelUncertainties)
        % just subtract the background pixels
        pixelValues(iCadence, ~gapIndicators) = pixelValues(iCadence, ~gapIndicators) - ...
            backgroundValues(~gapIndicators)';
    else
        % save the initial pixel uncertainties for the given cadence
        inputUncertainties = pixelUncertainties(iCadence, : );
        
        % subtract the background with the uncertainties
        [pixelValues(iCadence, ~gapIndicators), pixelUncertainties(iCadence, ~gapIndicators)] = ...
            add_with_uncertainties(1, pixelValues(iCadence, ~gapIndicators), ...
            pixelUncertainties(iCadence, ~gapIndicators), -1, ...
            backgroundValues(~gapIndicators)', backgroundUncertainties(~gapIndicators)');
        
        % correct the uncertainties if full POU is enabled
        if pouEnabledForPixels
            
            % Retrieve a chunk of decimated covariances if necessary.
            cadence = cadenceNumbers(iCadence);

            if isempty(chunkedCadenceList) || ...
                    (cadence > chunkedCadenceList(end) && ...
                    ~isempty(decimatedCadenceList))

                nRemain = length(decimatedCadenceList);
                chunkSize = min(cadenceChunkSize, nRemain);
                chunkedCadenceList = decimatedCadenceList(1 : chunkSize);
                if chunkSize == nRemain
                    decimatedCadenceList = [];
                else
                    decimatedCadenceList(1 : chunkSize - 1) = [];
                end

                clear Cv
                [Cv, covarianceGapIndicators, pouStructArray] = ...
                    retrieve_cal_pixel_covariance(row, column, ...
                    chunkedCadenceList, pouConfigStruct, pouStructArray);

                isValidCovariance = ~all(covarianceGapIndicators, 2);
                nValidCovariances = sum(isValidCovariance);
                Cv = Cv(isValidCovariance, : , : );
                validCadenceList = chunkedCadenceList(isValidCovariance);

            end % if
            
            % Interpolate the covariance matrix for the given cadence if
            % there are a sufficient number of valid matrices to do that.
            % If there is only one cadence then interpolation is not
            % necessary. Create a diagonal covariance matrix if that is the
            % best that can be done in a reasonable amount of time.
            if (nValidCovariances == 1 && nCadences ~= 1) || ...
                    nValidCovariances == 0
                CtargetPix = diag(inputUncertainties .^ 2);
            else % there is just one cadence or interpolation is possible
                if nValidCovariances > 1
                    CtargetPix = squeeze(interp1(validCadenceList, Cv, ...
                        cadence, interpMethod, 'extrap'));
                else % nCadences == 1
                    CtargetPix = squeeze(Cv);
                end
            end % if /else
            
            % compute the covariance for the background removed target
            % pixels and update the uncertainties
            CtargetPixBackRemoved = CtargetPix + ...
                Aback * backgroundPoly.covariance * Aback';
            uncertainties = sqrt(diag(CtargetPixBackRemoved));
            pixelUncertainties(iCadence, ~gapIndicators) = ...
                uncertainties(~gapIndicators);
            
        end % if pouEnabled
        
    end % if / else
    
end % for iCadence

return
