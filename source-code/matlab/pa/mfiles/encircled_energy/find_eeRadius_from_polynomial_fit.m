function dataStruct = find_eeRadius_from_polynomial_fit(M, dataStruct, encircledEnergyStruct )
%
% This function performs a linear least squares fit on the system y = M * q
% with covariance Cy. Fit parameters are passed through
% encircledEnergyStruct. The fit is then integrated and evaluated at
% eeFraction to determine eeRadius. The covariance of the fit coeffecients
% is propagated to give CeeRadius per KADN-26185.
%
% INPUTS:   M                       = design matrix
%           dataStruct              = structure containing normalized and ordered pixel data
%           encircledEnergyStruct   = structute containing fit parameters
% OUTPUTS:  dataStruct              = original input dataStruct plus the following fields
%                 .q            = coeffecients from lscov fit
%                 .S            = covariance of coeffecients from lscov fit
%                 .r0           = ee radius from fmin
%                 .Cr0          = uncertainty of ee radius
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



y  = dataStruct.pixFlux - 2.*(1 - dataStruct.radius);
Cy = dataStruct.Cpixflux;

polyOrder   = encircledEnergyStruct.polyOrder;
eeFraction  = encircledEnergyStruct.eeFraction;
seedRadius  = encircledEnergyStruct.SEED_RADIUS;
sigmaWhite  = encircledEnergyStruct.ADDITIVE_WHITE_NOISE_SIGMA;

% If all zero uncertainties - make sparse identity covariance matrix
if( all(all(Cy == 0)) )
    Cy = speye(length(y));
    y = normrnd( y, sigmaWhite .* ones(size(y)) );
end

% If some but not all uncertainties == 0, set these to floating point precision
if( isvector(Cy) && any(Cy==0) )
    Cy(Cy==0) = eps(1);
end

% choose LLS fit method based on Cy
if( issparse(Cy) ); method =''; else  method = 'orth'; end

% apply lscov based on Cy
if(isvector(Cy))
    [ q, STDX, mse, S ] = lscov( M, y, 1./Cy.^2, method );
else
    [ q, STDX, mse, S ] = lscov( M, y, Cy, method );
end


%% Removed renomalization of lscov output covariance - 11/04/08 
% Uncomment if assuming input covariance is well known
% % Remove output covariance scaling                         
% eeS = S ./ mse;
%%


% Integrate the resulting polynomial and determine eeRadius using fzero to find crossing at eeFraction
options.TolX = 1e-8;
[r0, fval, exitflag, output] = fzero(@(X) ee_integral_fit(q,X) - eeFraction , seedRadius, options);                     %#ok<NASGU>

% PROPAGATE THE COVARIANCE OF THE COEFFECIENTS

% To get the covariance of the integrated normalized pixel 
% data at the eeRadius (r0), transform the covariance matrix of
% the coeffecients by the model matrix for the integrated 
% normalized pixel data as a function of normalized radius at 
% the single point (radius=r0) per KADN-26185.

% Mint = x(x - 1)^2 * M at the single point of interest, r0
% Use function build_ee_design_matrix with optional output parameters.
[ cadenceGapFlag, M, M1, m2Factor ] = build_ee_design_matrix( r0, polyOrder );

% since r0 is scalar, M1 is a row vector and m2Factor is scalar there is no
% need to use scalecol(m2Factor,M1) or diag(m2Factor) * M1 here
Mint = m2Factor .* M1;

% apply the transformation to the covariance matrix of the fit coeffecients 
% to get the variance of p(x) at x=r0
Cp = Mint * S * Mint';
% get the value of the derivative of the function p(radius) at radius=r0
dpdx = ee_derivative_fit(q,r0);
% the variance of radius scales with the inverse of the derivative
Cr0 = Cp / dpdx;
% return uncertainties as the standard deviation, std = sqrt(var)
Cr0 = sqrt(Cr0);

% % Compute AIC quality of fit metric
% % See http://en.wikipedia.org/wiki/Akaike_information_criterion AIC for 
% nPoints = length(y);
% aic = log(mse) + (nPoints + polyOrder) / (nPoints-polyOrder-2); 

% add output data to dataStruct
dataStruct.q    = q;
dataStruct.S    = S;
dataStruct.r0   = r0;
dataStruct.Cr0  = Cr0;
% dataStruct.aic  = aic ;
