% script to analyze multi-quarter PRF fit test results
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

nTrials = 100;

directRaMat = zeros(nTrials, 8);
directRaSigmaMat = zeros(nTrials, 8);
diffRaMat = zeros(nTrials, 8);
diffRaSigmaMat = zeros(nTrials, 8);
directDecMat = zeros(nTrials, 8);
directDecSigmaMat = zeros(nTrials, 8);
diffDecMat = zeros(nTrials, 8);
diffDecSigmaMat = zeros(nTrials, 8);

for i=1:8
	load(['multiQStatTest_' num2str(i) '_quarters_100_trials.mat']);
	directRaMat(:,i) = directRa;
	directDecMat(:,i) = directDec;
	diffRaMat(:,i) = diffRa;
	diffDecMat(:,i) = diffDec;
	directRaSigmaMat(:,i) = directRaSigma;
	directDecSigmaMat(:,i) = directDecSigma;
	diffRaSigmaMat(:,i) = diffRaSigma;
	diffDecSigmaMat(:,i) = diffDecSigma;
end

x = 1:8;

figure('Color', 'white')
subplot(1,2,1);
plot(x, std(directRaMat), '+-', x, mean(directRaSigmaMat), 'o-');
title(['direct image RA, ' num2str(nTrials) ' trials']);
xlabel('number of quarters fit');
ylabel('uncertainty');
legend('monte carlo estimate', 'propagated uncertainty');

subplot(1,2,2);
plot(x, std(directDecMat), '+-', x, mean(directDecSigmaMat), 'o-');
title(['direct image Dec, ' num2str(nTrials) ' trials']);
xlabel('number of quarters fit');
ylabel('uncertainty');
legend('monte carlo estimate', 'propagated uncertainty');

figure('Color', 'white')
subplot(1,2,1);
plot(x, std(diffRaMat), '+-', x, mean(diffRaSigmaMat), 'o-');
title(['difference image RA, ' num2str(nTrials) ' trials']);
xlabel('number of quarters fit');
ylabel('uncertainty');
legend('monte carlo estimate', 'propagated uncertainty');

subplot(1,2,2);
plot(x, std(diffDecMat), '+-', x, mean(diffDecSigmaMat), 'o-');
title(['difference image Dec, ' num2str(nTrials) ' trials']);
xlabel('number of quarters fit');
ylabel('uncertainty');
legend('monte carlo estimate', 'propagated uncertainty');

