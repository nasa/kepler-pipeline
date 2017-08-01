function [rowMotionCoeffStruct, columnMotionCoeffStruct, motionCoeffGapIndicators, ...
    rowChiSquare, nRowCentroids, columnChiSquare, nColumnCentroids, ...
    rowRobustWeightArray, columnRobustWeightArray] = ...
    fit_motion_polynomials_by_cadence(centroidRows, centroidRowUncertainties, ...
    centroidColumns, centroidColumnUncertainties, targetRa, targetDec, gapArray, ...
    motionConfigurationStruct)
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
%**************************************************************************
% function [rowMotionCoeffStruct, columnMotionCoeffStruct, motionCoeffGapIndicators, ...
%     rowChiSquare, nRowCentroids, columnChiSquare, nColumnCentroids, ...
%     rowRobustWeightArray, columnRobustWeightArray] = ...
%     fit_motion_polynomials_by_cadence(centroidRows, centroidRowUncertainties, ...
%     centroidColumns, centroidColumnUncertainties, targetRa, targetDec, gapArray, ...
%     motionConfigurationStruct)
%**************************************************************************
%
% Compute a time series of row and column motion polynomials from target
% centroids organized by cadence
%
% inputs: 
%   centroidRows() # of cadences x # of targets array containing
%       row centroid values.  The target location is specified below
%   centroidRowUncertainties() # of cadences x # of targets array containing
%       uncertainties in the row centroid values.
%   centroidColumns() # of cadences x # of targets array containing
%       column centroid values.  The target location is specified below
%   centroidRowUncertainties() # of cadences x # of targets array containing
%       uncertainties in the row centroid values.
%   targetRa(), targetDec() # of targets x 1 arrays containing target right
%       ascension and declination in units of degrees
%   gapArray(): array of size(centroidRows) (and centroidColumns) containing
%       1 at gap locations, 0 otherwise.  May be a sparse matrix.
%   motionConfigurationStruct: structure containing various
%       configuration parameters
%
% output: 
%   rowMotionCoeffStruct() 1 x # of cadences array of polynomial
%       coefficient structs as returned by robust_polyfit2d()
%   columnMotionCoeffStruct() 1 x # of cadences array of polynomial
%       coefficient structs as returned by robust_polyfit2d()
%   motionGapIndicators() # cadences x 1 array containing motion polynomial
%       gap indicators
%   rowChiSquare() # cadences x 1 array of weighted chi-square values for
%       row motion polynomial fits
%   nRowCentroids() # cadences x 1 array of number of row centroids with
%       non-zero robust weights
%   columnChiSquare() # cadences x 1 array of weighted chi-square values
%       for column motion polynomial fits
%   nColumnCentroids() # cadences x 1 array of number of column  centroids
%       with non-zero robust weights
%
%   See also ROBUST_POLYFIT2D
%
%**************************************************************************

% unpack configuration parameters
centroidBiasRemovalIterations   = motionConfigurationStruct.centroidBiasRemovalIterations;
centroidBiasFitOrder            = motionConfigurationStruct.centroidBiasFitOrder;

% get the order of the motion fit
rowFitOrder     = motionConfigurationStruct.rowFitOrder;
columnFitOrder  = motionConfigurationStruct.columnFitOrder;
fitMinPoints    = motionConfigurationStruct.fitMinPoints;

% check that we have the required data sizes
if length(targetRa) ~= length(targetDec) || length(targetRa) ~= size(centroidRows, 2) ...
        || length(targetRa) ~= size(centroidColumns, 2)
    error('PA:fitMotionPolynomialsByCadence:invalidDataSize', ...
        '# of target RA''s, DEC''s and centroids not in agreement');
end
if ~isequal(size(centroidRows), size(gapArray)) ...
        || ~isequal(size(centroidRows), size(centroidColumns)) ...
        || ~isequal(size(centroidRows), size(centroidRowUncertainties)) ...
        || ~isequal(size(centroidRows), size(centroidColumnUncertainties))
    error('PA:fitMotionPolynomialsByCadence:invalidArraySize', ...
        'gap or centroids/uncertainties arrays of different sizes');
end

% initialize the motion coefficient gap indicators and output chi-square
% vectors
nCadences = size(gapArray, 1);
motionCoeffGapIndicators = false([nCadences, 1]);
rowChiSquare = zeros([nCadences, 1]);
columnChiSquare = zeros([nCadences, 1]);
nRowCentroids = zeros([nCadences, 1]);
nColumnCentroids = zeros([nCadences, 1]);
rowRobustWeightArray = zeros(size(gapArray));
columnRobustWeightArray = zeros(size(gapArray));

% do the actual fit on the row and column centroids, cadence by cadence
nTargets = size(gapArray, 2);

% pre-allocate the motion coefficient structs with dummy 0-th order
% 2d polynomials
rowMotionCoeffStruct = make_weighted_poly(2, 0, nCadences);
columnMotionCoeffStruct = make_weighted_poly(2, 0, nCadences);


% use original centroids to calculate residual and chi-squared
originalCentroidRows = centroidRows;
originalCentroidColumns = centroidColumns;

% iterate fit removing bias in centroids after each fit
iFit = 0;
while( iFit < centroidBiasRemovalIterations )
    iFit = iFit + 1;    

    for iCadence = 1:nCadences

        if isempty(centroidRowUncertainties) || isempty(centroidColumnUncertainties)
            rowWeights = ones(nTargets, 1);
            columnWeights = ones(nTargets, 1);
        else
            warning off all
            rowWeights = 1 ./ centroidRowUncertainties(iCadence, : )';
            columnWeights = 1 ./ centroidColumnUncertainties(iCadence, : )';
            rowWeights(isinf(rowWeights)) = 0;
            columnWeights(isinf(columnWeights)) = 0;
            warning on all
        end
        rowWeights(gapArray(iCadence, : ) == 1) = 0;
        columnWeights(gapArray(iCadence, : ) == 1) = 0;

        % require that there be a minimum number of centroid data points
        if sum(rowWeights > 0) < fitMinPoints || sum(columnWeights > 0) < fitMinPoints
            % if not set to invalid polynomial
            rowMotionCoeffStruct(iCadence).coeffs = 0;
            rowMotionCoeffStruct(iCadence).message = 'not enough centroid data points';
            columnMotionCoeffStruct(iCadence).coeffs = 0;
            columnMotionCoeffStruct(iCadence).message = 'not enough centroid data points';
            motionCoeffGapIndicators(iCadence) = true;
            continue;
        end

        % use the robust polyfit, which is robust against data outliers;
        % set gap indicator if an error is thrown; check to ensure that motion
        % polynomial coefficients and covariances are finite valued
        try
            warning off all
            [rowMotionCoeffStruct(iCadence), rowCondA, rowWeightedA, rowRobustWeights] = ...
                robust_polyfit2d(targetRa, targetDec, centroidRows(iCadence, : )', ...
                rowWeights, rowFitOrder);                                                                                               %#ok<*ASGLU>
            [columnMotionCoeffStruct(iCadence), columnCondA, columnWeightedA, columnRobustWeights] = ...
                robust_polyfit2d(targetRa, targetDec, centroidColumns(iCadence, : )', ...
                columnWeights, columnFitOrder);
            warning on all
            
            if any(~isfinite(rowMotionCoeffStruct(iCadence).coeffs)) || ...
                    any(~isfinite(rowMotionCoeffStruct(iCadence).covariance( : ))) || ...
                    any(~isfinite(columnMotionCoeffStruct(iCadence).coeffs)) || ...
                    any(~isfinite(columnMotionCoeffStruct(iCadence).covariance( : )))
                error('PA:fitMotionPolynomialsByCadence:invalidMotionPolynomial', ...
                    'throw error within try/catch block for invalid motion polynomial');
            end
            
        catch                                                                                                                           %#ok<CTCH>
            
            rowMotionCoeffStruct(iCadence).coeffs = 0;
            rowMotionCoeffStruct(iCadence).message = 'robust_polyfit2d error';
            columnMotionCoeffStruct(iCadence).coeffs = 0;
            columnMotionCoeffStruct(iCadence).message = 'robust_polyfit2d error';
            motionCoeffGapIndicators(iCadence) = true;
            
            warning on all
            continue;
            
        end

        
        % compute the weighted chi-square and estimate the number of fitted
        % row and column centroids with non-zero weights        
            
        lsWeights = rowWeightedA( : , 1);

        residuals = lsWeights .* originalCentroidRows(iCadence, : )' - ...
            rowWeightedA * rowMotionCoeffStruct(iCadence).coeffs;                       % calculate residuals from original centroids

        rowChiSquare(iCadence) = residuals' * residuals;
        nRowCentroids(iCadence) = sum(lsWeights > eps);
        rowRobustWeightArray(iCadence, : ) = rowRobustWeights';            

        lsWeights = columnWeightedA( : , 1);

        residuals = lsWeights .* originalCentroidColumns(iCadence, : )' - ...
            columnWeightedA * columnMotionCoeffStruct(iCadence).coeffs;                 % calculate residuals from original centroids

        columnChiSquare(iCadence) = residuals' * residuals;
        nColumnCentroids(iCadence) = sum(lsWeights > eps);
        columnRobustWeightArray(iCadence, : ) = columnRobustWeights';
        

    end % for iCadence
    
    
    % calculate row and column bias and remove for next iteration    
    if iFit < centroidBiasRemovalIterations
        
        if ~all(motionCoeffGapIndicators) && nCadences > centroidBiasFitOrder + 1
            
            % step 1) estimate bias in centroids to order == centroidBiasFitOrder over cadences from the fit residuals
            rowEstimate = centroidRows;
            columnEstimate = centroidColumns;
            
            rowEstimate(~motionCoeffGapIndicators,:) = ...
                (weighted_polyval2d(targetRa(:),targetDec(:),rowMotionCoeffStruct(~motionCoeffGapIndicators)))';
            columnEstimate(~motionCoeffGapIndicators,:) = ...
                (weighted_polyval2d(targetRa(:),targetDec(:),columnMotionCoeffStruct(~motionCoeffGapIndicators)))';
                        
            rowResidual =  centroidRows - rowEstimate;
            columnResidual =  centroidColumns - columnEstimate;
            
            rowBias = rowResidual - detrendcols(rowResidual,centroidBiasFitOrder,find(motionCoeffGapIndicators));
            columnBias = columnResidual - detrendcols(columnResidual,centroidBiasFitOrder,find(motionCoeffGapIndicators));

            % step 2) remove these biases from the centroids for next iteration
            centroidRows = centroidRows - rowBias;
            centroidColumns = centroidColumns - columnBias;
            
        else
            iFit = centroidBiasRemovalIterations;    
        end         
    end    
end % while iFit

return
