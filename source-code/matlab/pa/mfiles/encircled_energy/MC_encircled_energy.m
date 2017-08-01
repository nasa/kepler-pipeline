function [q,p,r,pix,noiseyPix,tppInputStruct,eeTempStruct] = MC_encircled_energy(polyOrder,APP,nCadences,randomOn,uncertaintyOn)

% function [q,p,r,pix,noiseyPix,tppInputStruct,eeTempStruct] =
% MC_encircled_energy(polyOrder,APP,nCadences,randomOn,uncertaintyOn)
%
% This function generates pixel data for a single target with aperature 
% size (2*APP + 1)^2 pixels which exactly matches the polynomial form 
% assumed by encircledEnergy.m. The data generated is stored in a 
% tppInputStruct.
% i.e.
% p'(x) = 2*(1 - x) + [(x - 1)^2 + 2x(x - 1)]q(x) + [x(x - 1)^2]q'(x)
%   where:  p'(x)   = normalized pixel data
%           x       = normalized radius from centroid
%           q(x)    = polynomial of order polyOrder
%
% This comes from the assumed form of the integrated normalized pixel data
% as a function of normalized radius:
%
% p(x) = (2x - x^2) + x(x-1)^2*q(x)
% 	Subject to constraints:	 p(1)=1, p(0)=p'(1)=0
%                   where:   q(x) = polynomial of degree polyOrder 
%
%
% INPUT:    polyOrder       = polynomial order of q as described above
%           APP             = aperture is (2xAPP + 1)^2
%           nCadences       = number of realizations or cadences
%           randomOn        = boolean; turn on random poisson number
%                             generator to produce deltas in pixel data
%                             cadence to cadence
%           uncertaintyOn   = boolean; enable uncertainty, otherwise
%                             uncertainties on pixel data is taken to be
%                             zero
% OUTPUT:   q               = polynomial coeffecients
%           p               = polynomial coeffecients
%           r               = radius data; nPixels x 1
%           pix             = noise free pixel data; nPixels x 1
%           noiseyPix       = pixel data with shot noise injected; nPixels x nCadences
%           tppInputStruct  = generated data in standard tppInputStruct form - ready to be passed to encircledEnergy.m
%           eeTempStruct    = generated data in tempStruct form (can accept pixel data covariance matrix rather than simple uncertainties)
%
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
disp(mfilename('fullpath'));


% Constants
eeFraction      = 0.95;

maxPixelValue   = 10000;
rowStar         = 100;
colStar         = 100;
centRow         = rowStar+0.2;
centCol         = colStar+0.4;
tol             = 1e-8;

meanVal         = 0;
sdBar           = 0.28;
pad             = 30;

SIGMA           = maxPixelValue / 1000 ;


% generate polyOrder + pad evenly spaced points from a mean=meanVal, sd=sd_bar normal distribution on the interval [0:1]
x = [0:1/(polyOrder+pad):1]'; %#ok<NBRAK>
y = maxPixelValue .* normpdf(x,meanVal,sdBar);

% set data point at end = 0, y(1)=0
y(end)=0;

% make covariance matrix on these points = identidy except for the point at x=1 where the variance = 0. 
% This will constrain this point during lscov the fit
Cv = eye(length(y));
Cv(end,end) = 0;

% fit the normal distribution to polyOrder+2 polynomial using lscov and
% covariance Cv, y = M*b
M = zeros(length(y),polyOrder+3);            
for n = 1:polyOrder+3
    M(:,n) = x.^(polyOrder+2+1-n);                
end
p_prime = lscov(M,y,Cv);

% integrate p' solution to get p, normalize both p, p' to p(1)

p = polyint(p_prime');
normFactor = polyval(p,1);
p = p./normFactor;
% p_prime = p_prime./normFactor;
% 
% z=[0:0.01:1];
% figure;
% plot(x,y./normFactor,'ob',z,polyval(p_prime,z),'r');

% solve the equation for p(x) to get q(x) approxiamtely, then re-construct p from this new q and p' from polyder(p)
%
% p(x) = (2x - x^2) + x(x-1)^2*q(x) = [-1, 2, 0] + [1, -2, 1, 0] * q(x)
q = polydiv(polyadd(p,[1, -2, 0]),[1, -2, 1, 0])';
% set coeffs of q < tol equal to zero, remove zeros
q(abs(q)<tol)=0;
q=unpolyzeropad(q);
% reconstruct new p and p' from this new q
p = polyadd([-1, 2, 0]',polymult([1, -2, 1, 0]',q));
% p_prime = polyder(p);
% 
% z=[0:0.01:1]';
% figure;
% plot(x,y./normFactor,'o',z,polyval(p_prime,z),'xr',z,ee_derivative_fit(q,z),'g');

% build radius and pixel data in square aperature (2xAPP + 1)^2 pixels
r   = zeros((2*APP + 1)^2,1);
row = zeros((2*APP + 1)^2,1);
col = zeros((2*APP + 1)^2,1);

% build absolute radius vector
k=1;
for i=rowStar-APP:rowStar+APP
    for j=colStar-APP:colStar+APP
        r(k) = sqrt((i-centRow)^2 + (j-centCol)^2);
        row(k) = i;
        col(k) = j;
        k=k+1;
    end
end

% normalize radius and sort radius, row, col by increasing radius
maxR = max(r);
[r, rIndex] = sort(r);
r = r./maxR;
row = row(rIndex);
col = col(rIndex);

% generate normalized pixel data at each r from model equation
pix = ee_derivative_fit(q,r);

% remove radius and pixel normalization
pix = normFactor.*pix;
r = maxR.*r;

% make column vectors of polynomials q and p
q=q(:);
p=p(:);

% uncertainty = SD = sqrt(mean value) from Poisson statistics
if(uncertaintyOn)
    deltaPix = sqrt(pix);               
else
    deltaPix = zeros(size(pix));
end

% generate nCadences copies of pixel data
noiseyPix = repmat(pix,1,nCadences);
% add shot noise and Gaussian white noise
if(randomOn)
    noiseyPix = poissrnd(noiseyPix) + normrnd(zeros(size(noiseyPix)), SIGMA);    
end    

% populate necessary elements of tppInputStruct for single target

% allocate array space under tppInputStruct.targetStarStruct.pixelTimeSeriesStruct
for k=1:length(pix)
    tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(k).timeSeries      = zeros(nCadences,1); 
    tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(k).uncertainties   = zeros(nCadences,1);
end

tppInputStruct.targetStarStruct(1).rowCentroid = centRow .* ones(nCadences,1);
tppInputStruct.targetStarStruct(1).colCentroid = centCol .* ones(nCadences,1);
tppInputStruct.targetStarStruct(1).gapList = [];

for i = 1:nCadences

    for k = 1:length(pix)          
        tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(k).timeSeries(i)       = noiseyPix(k,i); 
        tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(k).uncertainties(i)    = deltaPix(k);        
        
        if(i==1)
            tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(k).row     = row(k);
            tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(k).column  = col(k);
            tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(k).gapList = [];
        end
    end
end

tppInputStruct.encircledEnergyStruct.polyOrder      = length(q)-1;
tppInputStruct.encircledEnergyStruct.eeFraction     = eeFraction;
tppInputStruct.encircledEnergyStruct.TARGET_P_ORDER = length(q)+1;

% generate single cadence zero noise eeTempStruct w/covariance matrix
Cv = cov(noiseyPix');

% make symmetric
Cv = (Cv + Cv') ./ 2;

% write only first cadence of clean (pix = no injected noise) signal with
% covariance matrix (Cv) to eeTempStruct
eeTempStruct = generate_eeTempStruct_from_tppInputStruct(tppInputStruct);

eeTempStruct.targetStar(1).cadence              = eeTempStruct.targetStar(1).cadence(1);
eeTempStruct.targetStar(1).cadence(1).pixFlux   = pix;
eeTempStruct.targetStar(1).cadence(1).Cpixflux  = Cv;


function y = ee_derivative_fit(qPolyCoeff,x)
% build y = (2 - 2x) + [(x - 1)^2 + 2x(x - 1)]q(x) + [x(x - 1)^2]q'(x)
% where q(x) coeffs are given in qPolyCoeff
% ****** polyval expects coeffs ordered from highest power of x to lowest
y = (2 - 2.*x) + ((x-1).^2. + 2.*x.*(x - 1)).*polyval(qPolyCoeff,x) + (x.*(x - 1).^2).*polyval(polyder(qPolyCoeff),x);
return

function y = ee_integral_fit(qPolyCoeff,x)
% build y = (2x - x^2) + x(x-1)^2*q(x) where q(x) coeffs are given in qPolyCoeff
% ****** polyval expects coeffs ordered from highest power of x to lowest
y = (2.*x - x.^2) + x.*(x-1).^2.*polyval(qPolyCoeff,x);
return
