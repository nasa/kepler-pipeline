function focusMat = derive_focus_time_series_matrix(targetArray, ...
                                                    motionPolyStruct)
%**************************************************************************  
% function derive_focus_time_series_matrix(obj)
%**************************************************************************  
% Derive a variance-normalized proxy for focus/plate scale at each target
% location and lightly detrend the result with a median filter.
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
    medianFilterLength = 49; %7; %obj.params.longMedianFilterLength;

    % Retrieve the RA and Dec of each target.
    raDegrees  = [targetArray.raHours] * 360/24;
    decDegrees = [targetArray.decDegrees];
    nTargets   = numel(targetArray);
    nCadences  = length(targetArray(1).pixelDataStruct(1).values);
    
    % Given the RA and Dec of each target, determine partial derivatives of 
    % the motion polynomials at each cadence.
    scale = zeros(nCadences, nTargets); % Scale time series in columns.
    for i = 1:nCadences
        [drdR drdD] = compute_poly_partial_derivatives( ...
                          raDegrees(:), ...
                          decDegrees(:), ...
                          motionPolyStruct(i).rowPoly);
        [dcdR dcdD] = compute_poly_partial_derivatives( ...
                          raDegrees(:), ...
                          decDegrees(:), ...
                          motionPolyStruct(i).colPoly);
        scale(i,:) = drdR .* dcdD - drdD .* dcdR; % Determinant 
    end    
    
    % Identify and remove trend by median filtering along scale matrix
    % columns. 
    trend = cosmicRayCleanerClass.padded_median_filter(scale, ...
                                                       medianFilterLength);
    detrended = scale - trend;

    % Normalize variance (approximately). It doesn't matter that we do this
    % after detrending since we're throwing away the trend anyway. Estimate
    % standard deviations from MAD of each column. 
    sigma = 1.4826*mad(detrended, 1); % 
    detrended = detrended ./ repmat(sigma, [nCadences, 1]);
    
    focusMat = detrended;
end

function [zx zy] = compute_poly_partial_derivatives(x,y,c)
% function [zx zy] = compute_poly_partial_derivatives(x,y,c)
%
% inputs:
%	x and y should be column vectors.  Row vectors are accepted but incur a 
%		small performance penalty
%   x: vector of the x-coordinate of points at which the polynomial is
%       evaluated
%   y: vector of the y-coordinate of points at which the polynomial is
%       evaluated
%   c: a struct created by weighted_polyfit2D that comtains the following
%       fields
%       .coeff: coefficient vector for the polynomial basis
%       .covariance: matrix giving the uncertainties in the coefficients
%       .order: order of the polynomial for these coefficients
%       .type: type of the polynomial for these coefficients
%       .offsetx, .scalex, .originx, .offsety, .scaley, .originy: data
%           that allows the scaling of the domain for improved numerical 
%           performance.  The values of these fields depends on the type
%           of polynomial
%
% returns:
%   zx: the value of the partial derivative w.r.t x of the polynomial
%       defined by c at positions x and y.
%   zy: the value of the partial derivative w.r.t y of the polynomial
%       defined by c at positions x and y.
% 
    if (length(c(1).coeffs) == 1 && c(1).coeffs == 0)
        zx = zeros(size(x));
        zy = zeros(size(x));
        return;
    end

    % scale x to improve conditioning
    xp = c(1).offsetx + c(1).scalex*(x - c(1).originx);
    yp = c(1).offsety + c(1).scaley*(y - c(1).originy);

    Ax = partial_wrt_x(xp, yp, c(1).order);
    Ay = partial_wrt_y(xp, yp, c(1).order);

    % compute the fitted values at the input x,y
    zx = Ax*[c.coeffs]; 
    zy = Ay*[c.coeffs];
end

function A = partial_wrt_x(x,y,order)
% function A = weighted_design_matrix2D(x,y,w,order,type)
% 
% returns the design matrix for a weighted (chi-squared) least-squares 
% fit using a specified basis
%
% inputs:
%   x: column vector of the x-coordinate of points
%   y: column vector of the y-coordinate of points
%   w: multiplicative weights.  This can be a column vector or scalar. 
%       Pass 1 if all points are equally valid
%   order: order of the polynomial fit
% Optional inputs:
%   type: (Default: 'standard') type of the polynomial: 'standard' 
%       or 'legendre'.
% 
% Note: x, y and w must all have the same size.
% 
% returns:
%   A: design matrix
%
% Note: type 'legendre' requires the domains x and y to be in [-1, 1]
%
%   See also WEIGHTED_POLYFIT2D, WEIGHTED_POLYVAL2D, WEIGHTED_DESIGN_MATRIX
%               
% 

    if size(x, 2) ~= 1
        x = x(:);
    end
    if size(y,2) ~= 1
        y = y(:);
    end

    % initialize size and design matrix A
    N = length(x);
    op1 = order+1;
    nterms = op1*(op1+1)/2; % = order*(order-1)/2 + order, strictly upper 
                            % triangular part of nxn matrix has n*(n-1)/2
                            % elements. 
    A = zeros(N, nterms);  

    % method based on ETEM's MakeA2D.  Faster because it treats x and y as
    % vectors so only loops over order. 
    X = cumprod( [ones(size(x)), repmat(x,1,order)], 2); % X = [1, x, x^2, x^3, ..., x^order]
    Y = cumprod( [ones(size(x)), repmat(y,1,order)], 2); % Y = [1, y, y^2, y^3, ..., y^order]

    % k indexes the column of Ajit that is a product of specified columns
    % of X and Y.
    k = 0;
    for i = 0:order
        for j = 0:i
            k = k+1; % Next index
            if i-j > 0
                % Here we evaluate the first partial derivative of A(:,k) =
                % X(:,i-j+1) .*Y(:,j+1) w.r.t x.
                A(:,k) = (i-j) * X(:,i-j) .*Y(:,j+1); % Product of selected 
                                                      % columns of X and Y. 
            end
        end
    end

end

function A = partial_wrt_y(x,y,order)
% function A = weighted_design_matrix2D(x,y,w,order,type)
% 
% returns the design matrix for a weighted (chi-squared) least-squares 
% fit using a specified basis
%
% inputs:
%   x: column vector of the x-coordinate of points
%   y: column vector of the y-coordinate of points
%   w: multiplicative weights.  This can be a column vector or scalar. 
%       Pass 1 if all points are equally valid
%   order: order of the polynomial fit
% Optional inputs:
%   type: (Default: 'standard') type of the polynomial: 'standard' 
%       or 'legendre'.
% 
% Note: x, y and w must all have the same size.
% 
% returns:
%   A: design matrix
%
% Note: type 'legendre' requires the domains x and y to be in [-1, 1]
%
%   See also WEIGHTED_POLYFIT2D, WEIGHTED_POLYVAL2D, WEIGHTED_DESIGN_MATRIX
%               
% 

    if size(x, 2) ~= 1
        x = x(:);
    end
    if size(y,2) ~= 1
        y = y(:);
    end

    % initialize size and design matrix A
    N = length(x);
    op1 = order+1;
    nterms = op1*(op1+1)/2; % = order*(order-1)/2 + order, strictly upper 
                            % triangular part of nxn matrix has n*(n-1)/2
                            % elements.  
    A = zeros(N, nterms); 

    % method based on ETEM's MakeA2D.  Faster because it treats x and y as
    % vectors so only loops over order.
    X = cumprod( [ones(size(x)), repmat(x,1,order)], 2); % X = [1, x, x^2, x^3, ..., x^order]
    Y = cumprod( [ones(size(x)), repmat(y,1,order)], 2); % Y = [1, y, y^2, y^3, ..., y^order]

    % k indexes the column of Ajit that is a product of specified columns
    % of X and Y.
    k = 0;
    for i = 0:order
        for j = 0:i
            k = k+1; % Next index
            if j > 0
                % Here we evaluate the first partial derivative of A(:,k) =
                % X(:,i-j+1) .*Y(:,j+1) w.r.t y.
                A(:,k) = j * X(:,i-j+1) .*Y(:,j); % Product of selected 
                                                  % columns of X and Y.
            end
        end
    end

end

%********************************** EOF ***********************************