%nlinfit_monte_carlo2.m
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
function nlinfit_monte_carlo_linear_fit

% This example involves fitting the error function, erf(x), by a polynomial
% in x. This is a risky project because erf(x) is a bounded function, while
% polynomials are unbounded, so the fit might not be very good. 
% 
% First generate a vector of x points, equally spaced in the interval ;
clc;

noiseVar = 0.01;

polyOrder = 6; % create a polynomial of order 6 for linear fit using nlinfit


x = (-2: 0.01: 2)';

% goal is to create a polynomial in x
y = erf(x);

p = polyfit(x,y,polyOrder);
%p = 0.0084  -0.0983   0.4217   -0.7435  0.1471   1.1064  0.0004

% evaluate the polynomial, add noise
y = polyval(p,x) +sqrt(noiseVar)*randn(length(x),1);

% add outliers
y(100:110) = y(100)+1; 

% uncertainties are the sqrt(variance) of the noise process added
uncertainties = repmat(sqrt(noiseVar), length(x),1);

% define the model function, which is simply polyval
modelFun = @(alpha,x) polyval(alpha,x)./uncertainties;


% set the option to robust fit on
nlinfitOptions = statset('Robust', 'on', 'TolX',1e-8);

% invoke nlinfit
[fittedParameters, rw, Jw, Sigma, mse, robustWeights] = kepler_nonlinear_fit(x, y./uncertainties, modelFun, ones(polyOrder+1,1), nlinfitOptions);

% see how the Ccoeffts computed using Jw compares with the Ccoeffts
% computed using A (design matrix)

A1 = weighted_design_matrix(x, 1./uncertainties, polyOrder, 'standard');% multiplicative weights

% orders of the column are reversed when compared to fittedParameters
A = fliplr(A1); 

Tlinfit = inv(A'*A)*A';
CcoefftsPolyFit = (Tlinfit*diag(repmat(noiseVar,length(x),1))*Tlinfit');

Ja = Jw.*repmat(robustWeights,1,polyOrder+1);
Tnlinfit = inv(Ja'*Ja)*Ja';
CcoefftsNlinfitRobust = (Tnlinfit*diag(repmat(noiseVar,length(x),1))*Tnlinfit');



Tnlinfit = inv(Jw'*Jw)*Jw';
CcoefftsNlinfitRegular = (Tnlinfit*diag(repmat(noiseVar,length(x),1))*Tnlinfit');

[diag(CcoefftsPolyFit) diag(CcoefftsNlinfitRobust) diag(CcoefftsNlinfitRegular)]


A1 = weighted_design_matrix(x, robustWeights./uncertainties, polyOrder, 'standard');
A = fliplr(A1);
Tlinfit = inv(A'*A)*A';
CcoefftsPolyFit = (Tlinfit*diag(repmat(noiseVar,length(x),1))*Tlinfit');
diag(CcoefftsPolyFit)


fprintf('');


