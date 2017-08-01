function [cgnDeviates,covCgnEmpirical, T] = generate_colored_noise(nLength, sigmaWgn)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%function [cgnDeviates,covCgnEmpirical, T] = generate_colored_noise(nLength, sigmaWgn)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description: This function generates a vector of colored gaussian
% deviates (aka colored gaussian noise (CGN) or correlated noise) of specified length as
% described below:
%
%     Step 1: introduce correlations in a white gaussian noise sequence
%             using a moving average filter
%     Step 2: compute the covariance matrix empirically
%     Step 3: factor the empirical covariance matrix into T*T'
%     Step 4: generate a white gaussian sequence and color it by
%             premultiplying by T
%
%
% Inputs:
%       nLength  - length of the desired CGN sequence
%       sigmaWgn - std of white noise sequence from which to derive the
%                  colored noise
%
% Outputs:
%       cgnDeviates     - colored gaussain deviates of length 'nLength'
%       covCgnEmpirical - covariance matrix of cgnDeviates
%       T - obtained by factoring covCgnEmpirical = T*T'
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

filtLen = max(fix(0.05*nLength), min(3,nLength));


% % A neat way to construct the covariance matrix of correlated (colored)
% % noise
% % The transformation applied is the filtering operation T
% % (filter(ones(filtLen,1)/filtLen, 1)
% % Ccorr = T*Cwhite*T' where Cwhite is the covariance matrix of WGN
% % (eye(nLength)*sigmaWgn^2;
% % T is a linear transform, so apply it to the columns of Cwhite first and
% % apply it to the rows of matrix resulting from step 1

%covWgnTheoretical = eye(nLength)*sigmaWgn^2;

% covCgnTheoretical = covWgnTheoretical;
% for i = 1:nLength
%     covCgnTheoretical(:,i) = filter (ones(filtLen,1)/filtLen, 1, covCgnTheoretical(:,i));
% end
% for i = 1:nLength
%     covCgnTheoretical(i,:) = filter (ones(filtLen,1)/filtLen, 1, covCgnTheoretical(i,:));
% end
%
% [T,errFlag] = factor_covariance_matrix(covCgnTheoretical);


%-------------------------------------------------------------------------
% yet another way to generate covariance matrix of colored gaussian noise
%-------------------------------------------------------------------------

nRealizations = 100;
covCgnEmpirical = zeros(nLength);
for j =1:nRealizations;
    wgnDeviates = randn(nLength,1)* sigmaWgn;
    coloredGaussianNoise = filter(ones(filtLen,1)/filtLen, 1, wgnDeviates);
    covCgnEmpirical = covCgnEmpirical + coloredGaussianNoise*coloredGaussianNoise';
end
covCgnEmpirical = covCgnEmpirical./nRealizations;

[T,errFlag] = factor_covariance_matrix(covCgnEmpirical);


% covCgnEmpirical is a positive definite covariance matrix.
if errFlag < 0 % => T = []
    % V is not a valid covariance matrix.
    error('MATLAB:Common:generate_colored_noise:InvalidCovMat', 'Covariance matrix must be positive definite or positive semidefinite.');
end


wgnDeviates = randn(nLength,1)*sigmaWgn;


cgnDeviates = T*wgnDeviates;

return



%
%
% figure,...
% imagesc([covCgnEmpirical,covCgnTheoretical]),colorbar
% title('Colored Gaussian Noise Covariance')
% figure,...
% plot([diag(covCgnEmpirical),diag(covCgnTheoretical)])
% title('Colored Gaussian Noise Covariance - diagonal')
% figure
% imagesc([covWgnEmpirical,covWgnTheoretical]),colorbar
% title('White Gaussian Noise Covariance')
% figure,...
% plot([diag(covWgnEmpirical),diag(covWgnTheoretical)])
% title('White Gaussian Noise Covariance - diagonal')
%
%
