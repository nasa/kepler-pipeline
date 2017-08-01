function correctedMesPdf = correctedMes
% Outputs a function for the correctedMesPdf
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

% Determin PDF of MES correction factor (multiplier) as a function of impact parameter

% Given nominal MES corresponding to zero impact parameter, calculate the
% 'MES broadening' and 'duration broadening' that results from a
% uniform distribution of impact parameters.
%==========================================================================

% Initialize
% clear all
% close all

% Monte Carlo draws of impact parameters from uniform distribution
nMonteCarlo = 1.e6;
bRange = rand(nMonteCarlo,1);

% MES multiplier and duration multiplier
% MES is reduced from the 'naive' value by a factor that depends on the
% impact parameter
mesMultiplier = ( 1 - bRange.^2 ).^(1/4);
durationMultiplier = ( 1 - bRange.^2 ).^(1/2);

% Grid of MES multipliers
% data for beta distribution must lie on (0,1)
dx = 0.001;
bins = dx:dx:1;

% Distribution of MES correction factor due to impact parameter
% distribution
counts = hist(mesMultiplier,bins);
normCounts = counts./sum(counts);

% Try interpolation
correctedMesPdf = @(x) interp1(bins,normCounts,x);


% Plot the MES correction factor vs. impact parameter
figure
hold on
grid on
plot(bRange,mesMultiplier,'b.')
xlabel('impact parameter')
ylabel('MES multiplier')
    
skip = true;
if(~skip)
    
    % Test
    % Fit a beta distribution
    % But beta function is *not* a good model!
    % Beta parameters (not sure why parameters have to be reversed)
    alpha = 0.01;
    [pHat, CI] = betafit(normCounts,alpha);
    A = pHat(1);
    B = pHat(2);
    bb = betapdf(bins,B,A);
    normBeta = bb./(sum(bb));
    
    
    % Corrected MES: PDF vs. beta pdf model
    testBins = bins(25:75)-.15273;
    testY = correctedMesPdf(testBins);
    
    figure
    hold on
    axis([0,1,0,inf])
    xlabel('MES correction factor')
    plot(bins,normCounts,'b.')
    plot(testBins,testY,'r.')
    legend('corrected MES PDF','interpolated')
end







