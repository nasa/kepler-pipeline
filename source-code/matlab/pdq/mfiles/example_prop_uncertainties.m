% example_prop_uncertainties.m
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
close all;
clc;

x = (0: 0.02: 2.5)';
y = erf(x);
sigWgn = .1;
filtLen = 3;
nRealizations = 1000;

%p = polyfit(x,y,filtLen);
%y = polyval(p,x);


%%

wgn = randn(length(x),1)*sigWgn;

cgn = filter(ones(1,filtLen)/filtLen, 1, wgn);

covWgnTheoretical = eye(length(x))*sigWgn^2;

% A neat way to construct the covariance matrix of correlated (colored)
% noise
% The transformation applied is the filtering operation T
% (filter(ones(filtLen,1)/filtLen, 1)
% Ccorr = T*Cwhite*T' where Cwhite is the covariance matrix of WGN
% (eye(length(x))*sigWgn^2;
% T is a linear transform, so apply it to the columns of Cwhite first and
% apply it to the rows of matrix resulting from step 1

covCgnTheoretical = covWgnTheoretical;
for i = 1:length(x)
    covCgnTheoretical(:,i) = filter (ones(filtLen,1)/filtLen, 1, covCgnTheoretical(:,i));
end
for i = 1:length(x)
    covCgnTheoretical(i,:) = filter (ones(filtLen,1)/filtLen, 1, covCgnTheoretical(i,:));
end

%%
covCgnEmpirical = zeros(length(x));
covwgn = zeros(length(x));
for j =1:nRealizations;
    wgn = randn(length(x),1)*.1;
    cgn = filter(ones(filtLen,1)/filtLen, 1, wgn);
    covCgnEmpirical = covCgnEmpirical + cgn*cgn';
    covwgn = covwgn + wgn*wgn';
end
covCgnEmpirical = covCgnEmpirical./nRealizations;
covwgn = covwgn./nRealizations;
clc

%%
figure,...
imagesc([covCgnEmpirical,covCgnTheoretical]),colorbar
figure,...
plot([diag(covCgnEmpirical),diag(covCgnTheoretical)])
figure
plot([(covCgnEmpirical(:,50)),(covCgnTheoretical(:,50))])

%%

figure;
h1 = plot(x,y+cgn,'m-');
hold on
plot(x,y+cgn+2*sqrt(diag(covCgnTheoretical)),'m:');
plot(x,y+cgn-2*sqrt(diag(covCgnTheoretical)),'m:');


A = weighted_design_matrix(x, 1, 3, 'standard');

% [x,stdx,mse,S] = lscov(A,b,V,alg)
% lscov assumes that the covariance matrix of B is known only up to a scale
% factor. mse is an estimate of that unknown scale factor, and lscov scales
% the outputs S and stdx appropriately. However, if V is known to be
% exactly the covariance matrix of B, then that scaling is unnecessary. To
% get the appropriate estimates in this case, you should rescale S and stdx
% by 1/mse and sqrt(1/mse), respectively.
[c1 stdx1, mse1, S1] = lscov(A, y+cgn, covCgnTheoretical);

S1 = S1*(1/mse1);




B = A*S1*A'; % cov matrix of uncertainties in the fitted values


z1 = A*c1;
h2 = plot(x,z1,'b.-'); % fitted value
z1u = z1+2*sqrt(diag(B)); % upper bound containing fitted values 90% of the time
z1l = z1-2*sqrt(diag(B)); % lower bound containing fitted values 90% of the time

plot(x,z1u,'b:')
plot(x,z1l,'b:')
title('Generalized least squares fit of data with correlated measurement errors');
legend([h1 h2], {'a realization of data + correlated noise'; 'generalized least squares fit of data'})

%%

figure;
h3 = plot(x,y+wgn,'r-');
hold on
plot(x,y+wgn+2*sqrt(diag(covWgnTheoretical)),'r:')
plot(x,y+wgn-2*sqrt(diag(covWgnTheoretical)),'r:')


[c0 stdx0, mse0, S0] = lscov(A, y+wgn, covWgnTheoretical);


S0 = S0*(1/mse0);

D = A*S0*A'; % cov matrix of uncertainties in the fitted values




z0 = A*c0;
h4 = plot(x,z0,'b.-');
hold on;
z0u = z0+2*sqrt(diag(D)); % upper bound containing fitted values 90% of the time
z0l = z0-2*sqrt(diag(D)); % lower bound containing fitted values 90% of the time

plot(x,z0u,'b:')
plot(x,z0l,'b:')

title('Generalized least squares fit of data with independent measurement errors');
legend([h3 h4], {'a realization of data + white noise'; 'generalized least squares fit of data'})

%%


fprintf('');

%%