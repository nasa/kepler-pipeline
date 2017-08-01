function [periodBinCenters, NNtce1, NNall1, empiricalWindowFunction1, NNtce2, NNall2, empiricalWindowFunction2] = ...
    get_empirical_window_function(minPeriodDays,maxPeriodDays,binWidthPeriod,groupLabel,keplerId,highMesThreshold,maxImpactParameter)

% NOTE: 3/08/2016 -- takes fitSinglePulse and numSesInMes from fit using actual transit
% ephemeris
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

% function get_empirical_window_function.m
% Compute the window function empirically:
% Identify all injections with Rp > 3.0*Rearth and impactParameter < 0.3.
% In a given period bin, the fraction of these injections with fitSinglePulse == false is
% the "empirical window function".

% Empirical window function definition #1: *true* empirical window function
%   Pass window function if (nTransits > 3) or (nTransits == 3 & ~fitSinglePulse)
% Empirical window function definition #2
%   Approximation, as per conversation with Chris Burke 1/25/2016

% Directories for injection data and diagnostics
[topDir, ~] = get_top_dir(groupLabel);


% Load the tps-injection-struct
load(strcat(topDir,'tps-injection-struct.mat'))

% Get the stellar parameters file created by
% get_stellar_parameters_for_injection_targets.m
% saveDir = '/codesaver/work/transit_injection/data/';
% load(strcat(saveDir,groupLabel,'_stellar_parameters.mat'))

% Get indices into tpsInjectionStruct that correspond to the desired keplerId
targetIndicator = tpsInjectionStruct.keplerId == keplerId;

% Get necessary information from the tpsInjectionStruct
impactParameter = tpsInjectionStruct.impactParameter(targetIndicator);
injectedPeriodDays = tpsInjectionStruct.injectedPeriodDays(targetIndicator);
periodDays = tpsInjectionStruct.periodDays(targetIndicator);
isPlanetACandidate = tpsInjectionStruct.isPlanetACandidate(targetIndicator);
% !!!!! Try using new diagnostic for isPlanetACandidate 3/9/2016 
%   Test by running plot_window_functions on KSOC-4976-1. 
%       Result: 
%           WF2 (black) gets a bit better for KIC 2837133 (evolved star), resulting in slightly poorer agreement between empirical WFs
%           But for KIC-9574801 (dwarf star) there is little change.
% isPlanetACandidate = tpsInjectionStruct.isPlanetACandidateWhenSearchedWithInjectedPeriodAndDuration(targetIndicator);
expectedMes = tpsInjectionStruct.injectedDepthPpm(targetIndicator) .* 1e-6 .* tpsInjectionStruct.normSum111(targetIndicator); % !!!!! using this for expected MES estimate
injectedDepthPpm = tpsInjectionStruct.injectedDepthPpm(targetIndicator);
% Note 3/9/2016 -- is the only role of the new
% fitSinglePulse and numSesInMes diagnostics is to accurately compute
% the window function? Should they also be used in computing detection
% efficiency and completeness contours?
fitSinglePulse = tpsInjectionStruct.fitSinglePulseWhenSearchedWithInjectedPeriodAndDuration(targetIndicator);
numSesInMes = tpsInjectionStruct.numSesInMesWhenSearchedWithInjectedPeriodAndDuration(targetIndicator);
% planetRadiusInEarthRadii = tpsInjectionStruct.planetRadiusInEarthRadii(targetIndicator);
% maxMes = tpsInjectionStruct.maxMesWhenSearchedWithInjectedPeriodAndDuration(targetIndicator);
% injectedEpochKjd = tpsInjectionStruct.injectedEpochKjd(targetIndicator);
% epochKjd = tpsInjectionStruct.epochKjd(targetIndicator);
% injectedDurationInHours = tpsInjectionStruct.injectedDurationInHours(targetIndicator);
% trialTransitPulseInHours = tpsInjectionStruct.trialTransitPulseInHours(targetIndicator);

% !!!!! Set 2D binning scheme, same for all targets
% minPeriodDays = 20;
% maxPeriodDays = 720;
% minPeriodDays = 250;
% maxPeriodDays = 600;
minRadiusEarths = 0.5; % !!!!! This will be smaller for M stars in Groups 3 and 6
maxRadiusEarths = 15;
mesLowerLimit = 3;
mesUpperLimit = 25;
% nBins = [70 30 30]; % binwidth of 10 days, from 20 to 720 days

% Threshold for inclusion in high-MES injections
% highMesThreshold = 15;

% Maximum impact parameter for inclusion in high-MES injections
% maxImpactParameter = 0.95;

% Period bins
% binWidthPeriod = (maxPeriodDays - minPeriodDays)/nBins(1); % 10 days
% binWidthPeriod = 0.1;% (maxPeriodDays - minPeriodDays)/nBins(1); % 10 days

% Radius bins
% binWidthRadius = (log10(maxRadiusEarths) - log10(minRadiusEarths))/nBins(2);
binWidthRadius = (log10(maxRadiusEarths) - log10(minRadiusEarths))/30;

% MES bins
% binWidthMes = (mesUpperLimit - mesLowerLimit)/nBins(3);
binWidthMes = 0.5; % (mesUpperLimit - mesLowerLimit)/nBins(3);

% Set up bins and labels for contour plot, depending on contour type
contourLabel = 'period-radius';
switch contourLabel
    case 'period-radius'
        binEdges = {minPeriodDays:binWidthPeriod:maxPeriodDays log10(minRadiusEarths):binWidthRadius:log10(maxRadiusEarths) };
        % yLabelString = ['log_{10}( Radius [Earths] ), bin size =  ',num2str(binWidthRadius,'%6.2f')];
    case 'period-mes'
        binEdges = { minPeriodDays:binWidthPeriod:maxPeriodDays mesLowerLimit:binWidthMes:mesUpperLimit };
        % yLabelString = ['MES, bin size =  ',num2str(binWidthMes,'%6.2f')];
end

% Calculate grids for contour plots

% Bin edges
periodBinEdges = binEdges{1}';

% Bin centers from periodBinEdges
periodBinCenters = (periodBinEdges(2:end) + periodBinEdges(1:end-1))./2;

% Indicator that period is within bounds
periodIsInSpecifiedRange = injectedPeriodDays > minPeriodDays & injectedPeriodDays < maxPeriodDays;

% High MES indicator
highMesIndicator = expectedMes > highMesThreshold & impactParameter < maxImpactParameter;

% Indicator for at least 3 good transits
numTransitIndicator = numSesInMes > 3 | numSesInMes == 3 & ~fitSinglePulse;
% Valid injections, for computation of empirical window function:
%  - Nonzero injected depth
%  - Injected period in desired range
%  - High MES
validInjectionIndicator = periodIsInSpecifiedRange & injectedDepthPpm ~= 0;

%==========================================================================
% Empirical window function definition #1: *true* empirical window function

% Pass window function if (nTransits > 3) or (nTransits == 3 & ~fitSinglePulse)
denominatorIndicator1 = validInjectionIndicator;
numeratorIndicator1 = denominatorIndicator1 & numTransitIndicator;

% Bin by period
[NNall1, ~] = histc(periodDays(denominatorIndicator1),periodBinEdges);
[NNtce1, ~] = histc(periodDays(numeratorIndicator1),periodBinEdges);

%==========================================================================
% Empirical window function definition #2
% !!!!! best approximation, as per conversation with Chris Burke 1/25/2016

% Pass window function if isPlanetACandidate
denominatorIndicator2 = validInjectionIndicator & highMesIndicator;
numeratorIndicator2 = denominatorIndicator2 & isPlanetACandidate;

% Bin by period
[NNall2, ~] = histc(periodDays(denominatorIndicator2),periodBinEdges);
[NNtce2, ~] = histc(periodDays(numeratorIndicator2),periodBinEdges);

% Compute empirical window function
empiricalWindowFunction1 = NNtce1(1:end-1)./NNall1(1:end-1);
empiricalWindowFunction2 = NNtce2(1:end-1)./NNall2(1:end-1);

%==========================================================================
% Apply Savitzky-Golay smoothing
frameSize = 11;
polynomialOrder = 3;
empiricalWindowFunction1 = sgolayfilt(empiricalWindowFunction1,polynomialOrder,frameSize);
empiricalWindowFunction2 = sgolayfilt(empiricalWindowFunction2,polynomialOrder,frameSize);

return
