function kernel = compute_gaussian_filter(kernelWidth, params)
%**************************************************************************
% kernel = compute_gaussian_filter(kernelWidth, params)
%**************************************************************************
% Compute a 2D Gaussian filter with unity gain.
%
% INPUTS
%    params  : A 3- or 5-element parameter vector.
%              params(1) Sigma in the row direction.
%              params(2) Sigma in the column direction.
%              params(3) Correlation coefficient in the range (-1.0, 1.0).
%              params(4) Fractional row position of the centroid (OPTIONAL)
%              params(5) Fractional column position of the centroid (OPTIONAL)
%
% OUTPUTS
%     kernel : A kernelWidth-by-kernelWidth matrix containing the
%              filter coefficients.                  
%                           
%**************************************************************************
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

    rowSigma = params(1);  % Sigma in the row direction
    colSigma = params(2);  % Sigma in the column direction
    rho      = params(3);  % Correlation coeff [-1.0, 1.0].

    if rowSigma < eps
        rowSigma = eps;
    end

    if colSigma < eps
        colSigma = eps;
    end

    if abs(rho) >= 1.0
        rho = sign(rho) * 0.999999999999999;
    end

    if length(params) > 3
        rowMean = params(4);
    else
        rowMean = ceil(kernelWidth/2);
    end

    if length(params) > 4
        colMean = params(5);
    else
        colMean = ceil(kernelWidth/2); 
    end
    
    [colGrid, rowGrid] = meshgrid(1:kernelWidth, 1:kernelWidth);
    nPoints = kernelWidth ^ 2;
    
    x = [rowvec(colGrid); rowvec(rowGrid)];
    u = repmat([colMean; rowMean], [1, nPoints]);

    % Construct covariance matrix.
    d = colSigma^2;
    e = rho * colSigma * rowSigma;
    f = rowSigma^2;   
    C = [ d, e; ...
          e, f ];
    
    % Evaluate kernel coefficients. For each point p = [c; r], compute
    %
    % exp( -a (p - u)' * inv(C) * (p - u) )
    %
    % Notation is a bit different in order to do the computation for all
    % points simultaneously.
    a = 0.5 / (1 - rho^2);
    kernel = zeros(kernelWidth);
    kernel(:) = exp( -a * dot((x - u), C \ (x - u)) );
    
    % Normalize
    sumKern = sum(kernel(:));
    if sumKern ~= 0
        kernel = kernel / sumKern;
    end
end


% %**************************************************************************
% % kernel = compute_gaussian_filter(kernelWidth, params)
% %**************************************************************************
% % Compute a 2D Gaussian filter with unity gain.
% %
% % INPUTS
% %    params  : A 3- or 5-element parameter vector.
% %              params(1) Sigma in the row direction
% %              params(2) Sigma in the column direction
% %              params(3) Clockwise rotation of the filter (radians).
% %              params(4) Fractional row position of the centroid (OPTIONAL)
% %              params(5) Fractional column position of the centroid (OPTIONAL)
% %
% % OUTPUTS
% %     kernel : A kernelWidth-by-kernelWidth matrix containing the
% %              filter coefficients.                  
% %                           
% %**************************************************************************
%     
%     rowSigma   = params(1);  % Sigma in the row direction
%     colSigma   = params(2);  % Sigma in the column direction
%     cwRotation = params(3); % Clockwise rotation of the filter (radians).
% 
%     if length(params) > 3
%         centerRow = params(4);
%     else
%         centerRow = ceil(kernelWidth/2);
%     end
% 
%     if length(params) > 4
%         centerCol = params(5);
%     else
%         centerCol = ceil(kernelWidth/2); 
%     end
%     
%     [colGrid, rowGrid] = meshgrid(1:kernelWidth, 1:kernelWidth);
%     kernel = gaussian2D(colGrid, rowGrid, centerCol, centerRow, ...
%         colSigma, rowSigma, cwRotation);
% end
% 
% 
% function z = gaussian2D(x, y, x0, y0, x_std, y_std, theta)
% %**************************************************************************
% % z = gaussian2D(x, y, x0, y0, x_std, y_std, theta)
% %**************************************************************************
% % Evaluate a two-dimensional Gaussian function.
% %
% % INPUTS
% %     x      (matrix) : An M-by-N matrix of x (column) coordiantes at which  
% %                       to evaluate the 2D Gaussian.
% %     y      (matrix) : An M-by-N matrix of y (row) coordiantes at which to 
% %                       evaluate the 2D Gaussian.
% %     x0     (scalar) : The fractional x(column) position of the centroid.
% %     y0     (scalar) : The fractional y (row) position of the centroid.
% %     x_std  (scalar) : The sandard deviation along the x-axis BEFORE 
% %                       rotation.
% %     y_std  (scalar) : The sandard deviation along the y-axis BEFORE
% %                       rotation.
% %     theta  (scalar) : The colckwise rotation angle in radians
% %
% % OUTPUTS
% %     z      (matrix) : An M-by-N matrix of normalized function values. 
% %                       sum(z(:)) == 1.0
% %
% % NOTES
% %     If x_std or y_std are zero, the value returned by 'eps' is
% %     substituted. 
% %**************************************************************************
%     % Handle the special case of zero standard deviations.    
%     if x_std == 0
%         x_std = eps;
%     end
%     
%     if y_std == 0
%         y_std = eps;
%     end
%     
%     sin_sq = sin(theta)^2;
%     cos_sq = cos(theta)^2;
%     x_std_sq = x_std^2;
%     y_std_sq = y_std^2;
%     a = 0.5  * ( cos_sq/x_std_sq + sin_sq/y_std_sq );
%     b = 0.25 * ( sin(2 * theta)/x_std_sq - sin( 2 * theta)/y_std_sq );
%     c = 0.5  * ( sin_sq/x_std_sq + cos_sq/y_std_sq );
%     z = exp( -( a*(x-x0).^2 - 2*b*(x-x0).*(y-y0) + c*(y-y0).^2 ) );
%     
%     sumz = sum(z(:));
%     if sumz ~= 0
%         z = z / sumz;
%     end
% end

%********************************** EOF ***********************************
