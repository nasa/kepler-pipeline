%% script for verifying the KS and KP test
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

% Gary zhang, 04/28/08
modelMean = 0;
modelStd = 1;
N = 1000;

modelRange = [-10:.25:10]';
modelCdf = normcdf(modelRange, modelMean, modelStd);

alpha = 0.05;

resultsYes = zeros(10, 1);
resultsNo = zeros(10, 1);
p = zeros(10, 1);

N = 10000;
for k=1:N
    x = randn(N, 1);
    %x = randn(N, 1) + randn(N, 1);
    xModel = randn(N, 1);


    [d1, p(1)] = ksone(x, @normcdf);

    [d2, p(2)] = kstwo(x, xModel);

    [d3, p(3)] = kpone(x, @normcdf);

    [d4, p(4)] = kptwo(x, xModel);

    % Matlab routine
    [h5, p(5)] = kstest(x);
    [h6, p(6)] = kstest2(x, xModel);

    % Wilcoxon signed rank test
    [p(7), h7] = signrank(x);
    
    % Lillietest
    %[h8, p(8)] = lillietest(x);
    %[h8, p(8)] = lillietest(x, alpha, 'norm', 1e-4);

%     fprintf('KS test: ksone(): h = %f; dist = %f; prob = %f \n', p(1) > alpha, d1, p(1));
%     fprintf('KS test: kstwo(): h = %f dist = %f; prob = %f \n', p(2) > alpha, d2, p(2));
%     fprintf('KP test: kpone(): h = %f dist = %f; prob = %f \n', p(3) > alpha, d3, p(3));
%     fprintf('KP test: kptwo(): h = %f; dist = %f; prob = %f \n', p(4) > alpha, d4, p(4));
%     fprintf('KS test: kstest(): h = %f, prob = %f \n', h1, p(5));
%     fprintf('KS test: kstest2(): h = %f, prob = %f\n', h2, p(6));
%     fprintf('Wilcoxon test: signrank(): h = %f, prob = %f\n\n', h6, p(7));

    for m=1:7
        if ( p(m) > alpha )
            resultsYes(m) = resultsYes(m) + 1;
        else
            resultsNo(m) = resultsNo(m) + 1;
        end
    end
end
resultsYes = resultsYes / N;
resultsNo = resultsNo / N;

disp('Yes');
disp( resultsYes' );
disp('No');
disp( resultsNo' );