%nlinfit_monte_carlo.m
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

function nlinfit_monte_carlo_non_linear_fit

% This example involves fitting the error function, erf(x), by a polynomial
% in x. This is a risky project because erf(x) is a bounded function, while
% polynomials are unbounded, so the fit might not be very good. 
% 
% First generate a vector of x points, equally spaced in the interval ;
% then evaluate erf(x) at those points. 

noiseVar = 0.01;
x = (-1: 0.01: 1)';
y = 1.6*exp(-(x-0.25).^2/(2*0.04))+ sqrt(noiseVar)*randn(length(x),1); 
y(100:110) = y(100)+1; % outlier
% The coefficients in the approximating polynomial of degree 6 are 
%p = polyfit(x,y,6);

%p = 0.0084  -0.0983   0.4217   -0.7435  0.1471   1.1064  0.0004

%y = polyval(p,x) +sqrt(.25)*randn(length(x),1);

uncertainties = repmat(sqrt(noiseVar), length(x),1);
modelFun = @(alpha,x) gaussian(alpha,x)./uncertainties;

lastwarn('');


nlinfitOptions = statset('Robust', 'on');
[fittedParameters, rw, Jw, Sigma, mse, robustWeights] = kepler_nonlinear_fit(x, y./uncertainties, modelFun, [1  0 .1], nlinfitOptions);

fprintf('');


% There are seven coefficients and the polynomial is
% To see how good the fit is, evaluate the polynomial at the data points wit

function ygauss = gaussian(alpha, x)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function ygauss = gaussian(alpha, x)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%   ygauss = gaussian(alpha,X) gives the predicted fit of the
%   Gaussian as a function of the vector of
%   parameters, ALPHA, and the matrix of data, X.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

a1 = alpha(1);
a2 = alpha(2);
a3 = alpha(3);

ygauss = a1 * exp(-((x-a2).*(x-a2))./(2*a3*a3) ) ;



return
