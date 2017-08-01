function [backgroundCoeffStruct, backgroundCoeffGapIndicators, chiSquare, ...
    nFittedPixels] = ...
    fit_background_by_cadence(backgroundPixels, backgroundUncertainties, ...
    row, column, gapArray, backgroundConfigurationStruct, pouStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [backgroundCoeffStruct, backgroundCoeffGapIndicators, chiSquare, ...
%     nFittedPixels] = ...
%     fit_background_by_cadence(backgroundPixels, backgroundUncertainties, ...
%     row, column, gapArray, backgroundConfigurationStruct, pouStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Compute a time series of background polynomials from background pixels
% organized by cadence
%
% inputs: 
%   backgroundPixels() # of cadences x # of pixels array containing
%       background pixel values.  The pixels are assumed to be at a fixed
%       location over time
%   backgroundUncertainties() # of cadences x # of pixels array containing
%       background pixel values.  The pixels are assumed to be at a fixed
%       location over time
%   row(), column() # of pixels x 1 array containing row and column of each
%       pixel in CCD module output coordinates 
%   gapArray(): array of size(backgroundPixels) containing 1 at gap
%       locations, 0 otherwise.  May be a sparse matrix.
%   backgroundConfigurationStruct: structure containing various
%       configuration parameters
%   pouStruct: optional POU structure with POU parameters and # of cadences
%       x 1 array of absolute cadence numbers
%
% output: 
%   backgroundCoeffStruct() 1 x # of cadences array of polynomial
%       coefficient structs as returned by robust_polyfit2d()
%   backgroundCoeffGapIndicators() # cadences x 1 array containing
%       background coefficient gap indicators
%   chiSquare() # cadences x 1 array of weighted chi-square values for
%       background fits
%   nFittedPixels() # cadences x 1 array of number of pixels with non-zero
%       robust weights
%
%   See also ROBUST_POLYFIT2D, FIT_BACKGROUND_BY_TIME_SERIES
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

% check optional arguments
if ~exist('pouStruct', 'var')
    pouEnabled = false;
else
    pouEnabled = pouStruct.pouEnabled;
    cadenceNumbers = pouStruct.cadenceNumbers;
    interpDecimation = pouStruct.pouInterpDecimation;
    interpMethod = pouStruct.pouInterpMethod;
    cadenceChunkSize = pouStruct.pouCadenceChunkSize;
end

% get the order of the low-order background fit
fitOrder = backgroundConfigurationStruct.fitOrder;
fitMinPoints = backgroundConfigurationStruct.fitMinPoints;

% check that we have the required data sizes
if length(row) ~= length(column) || length(row) ~= size(backgroundPixels, 2)
    error('PA:Common:fit_background_cadence', ...
        '# of rows, columns and pixels not in agreement');
end
if ~isequal(size(gapArray), size(backgroundPixels))
    error('PA:Common:fit_background_cadence', ...
        'gap and pixel array of different sizes');
end
if pouEnabled && size(backgroundPixels, 1) ~= length(cadenceNumbers)
    error('PA:Common:fit_background_cadence', ...
        'dimension of cadence numbers vector is incorrect');
end

% initialize the background coefficient gap indicators and output
% chi-square vector
nCadences = size(backgroundPixels, 1);
backgroundCoeffGapIndicators = false([nCadences, 1]);
chiSquare = zeros([nCadences, 1]);
nFittedPixels = zeros([nCadences, 1]);

% get the decimated cadences for which the target covariances will be
% computed without interpolation if POU is enabled
if pouEnabled
    decimatedCadenceList = downsample(cadenceNumbers, interpDecimation);
    chunkedCadenceList = [];
    pouStructArray = [];
end
    
% do the actual fit, cadence by cadence
nPixels = size(backgroundPixels, 2);

% pre-allocate the background coefficient struct with dummy 0-th order
% 2d polynomials
backgroundCoeffStruct = make_weighted_poly(2, 0, nCadences);

for iCadence = 1 : nCadences

    if isempty(backgroundUncertainties)
        weights = ones(nPixels, 1);
    else
        warning off all
        weights = 1 ./ backgroundUncertainties(iCadence, : )';
        weights(isinf(weights)) = 0;
        warning on all
    end
    weights(gapArray(iCadence,:) == 1) = 0; 
    
    % require that there be a minimum number of background data points
    if sum(weights > 0) < fitMinPoints
        % if not set to invalid polynomial
        backgroundCoeffStruct(iCadence).coeffs = 0;
        backgroundCoeffStruct(iCadence).message = 'not enough background data points';
        backgroundCoeffGapIndicators(iCadence) = true;
        continue;
    end
    
    % use the robust polyfit, which is robust against data outliers;
    % set gap indicator if an error is thrown. compute the weighted
    % chi-square for each cadence. propagate the uncertainties for the
    % background pixels through to the background polynomial if POU is
    % enabled
    try
        pixels = backgroundPixels(iCadence, : )';
        warning off all
        [backgroundCoeffStruct(iCadence), condA, weightedA] = ...
            robust_polyfit2d(row, column, pixels, weights, fitOrder);
        warning on all
    catch
        backgroundCoeffStruct(iCadence).coeffs = 0;
        backgroundCoeffStruct(iCadence).message = 'robust_polyfit2d error';
        backgroundCoeffGapIndicators(iCadence) = true;
    end % try / catch
    
    if ~backgroundCoeffGapIndicators(iCadence)
        
        % compute the weighted chi-square and estimate the number of fitted
        % pixels with non-zero weights
        lsWeights = weightedA( : , 1);
        residuals = lsWeights .* pixels - ...
            weightedA * backgroundCoeffStruct(iCadence).coeffs;
        chiSquare(iCadence) = residuals' * residuals;
        nFittedPixels(iCadence) = sum(lsWeights > eps);
        
        % perform full POU if enabled
        if pouEnabled
            
            % retrieve decimated covariances in chunks
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
                    chunkedCadenceList, pouStruct, pouStructArray);
                
                isValidCovariance = ~all(covarianceGapIndicators, 2);
                nValidCovariances = sum(isValidCovariance);
                Cv = Cv(isValidCovariance, : , : );
                validCadenceList = chunkedCadenceList(isValidCovariance);

            end % if
            
            % interpolate the covariance matrix if necessary. create a
            % diagonal covariance matrix for the background pixels if that
            % is the best that can be done in reasonable time
            if (nValidCovariances == 1 && nCadences ~= 1) || ...
                    nValidCovariances == 0
                CbackPix = diag(backgroundUncertainties(iCadence, : ) .^ 2);

            else % there is just one cadence or interpolation is possible
                if nValidCovariances > 1
                    CbackPix = squeeze(interp1(validCadenceList, Cv, ...
                        cadence, interpMethod, 'extrap'));
                else % nCadences == 1
                    CbackPix = squeeze(Cv);
                end
            end % if / else
            
            % scale the background pixel covariance matrix in place without
            % calls to scalerow and scalecol. then, propagate the
            % uncertainty and update the covariance in the background
            % coefficient structure
            for iRow = 1 : nPixels
                CbackPix(iRow, : ) = ...
                    lsWeights(iRow) * (CbackPix(iRow, : ) .* lsWeights');
            end
            Tpoly = pinv(weightedA);
            Cpoly = Tpoly * CbackPix * Tpoly';
            backgroundCoeffStruct(iCadence).covariance = Cpoly;
            clear CbackPix Tpoly
            
        end % if
        
    end % if
    
end % for iCadence

return
