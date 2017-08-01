% make_v0_or_v1_contours.m
% Usage notes:
% Before running this script: run 
% get_stellar_parameters_for_injection_targets.m,
% get_transit_injection_diagnostics, and
% make_detection_efficiency_curves
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

% After running this script: can run comparisons such as compare_v1_v2.m

% modified version of make_v1_contours.m
% allows option of either v0 or v1 contours
% For v0, uses approximations to one sigma depth function and window function.

% Construct vx contours for a single target using
% 1. detection efficiency curve
% 2. window function and 1-sigma depth function calculated at the
%    period and duration
% 3. depth calculated at a given radius and impact parameter

% The assumption for these contours used to be that period and radius map to a
% single MES value: MES = f(R,P)

% But this is not true when you consider that transits will have a distribution of impact
% parameters uniform on [0 , 1].  In this case, MES is a function of
% impact parameter as well

% This follows because
% 1. transit duration is proportional to sqrt((1-B)^2), and
% 2. MES is proportional to sqrt(transit duration)
% 3. depth is also a function of impact parameter due to limb-darkening

% Therefore, we modify the mapping from (period,radius) to MES to
% account for the dependence on impact parameter.
% Instead of associating a unique value of MES with each (period, radius) bin,
% we now consider that each bin is associated with
% a (uniform) distribution of impact parameters, which determines a
% distribution of possible transit durations. Which determines the
% one sigma depth function and window function.
% The MES is also reduced by a limb-darkening correction to the depth
% that depends on impact parameter.

% In each period-radius bin, we loop over a uniform grid of
% impact parameters, determining the corresponding detection efficiency.
% Then we average over the distribution
% of detection efficiencies in that bin.

% 1. Bin phase space in radius and period

% 2. Loop over a uniform grid of impact parameters
%    At each impact parameter

%    Compute the corrected transit duration and the corresponding one
%       sigma depth function and window function.
%    Determine the corrected transit depth due to limb-darkening
%    Calculate the corrected MES
%    Intepolate the detection efficiency

% 3. Average over the detection efficiency
%==========================================================================
% Initialize
clear all

% Constants
cadencesPerDay = 48.9390982304706;
superResolutionFactor = 3;
minWindowFunction = 0.97;
correlationThreshold = 0.92;
mesCorrectionFactor = 0.8739;
eccentricity = 1;
pulseDurationsHours = [1.5, 2.0, 2.5, 3.0, 3.5, 4.5 , 5.0, 6.0, 7.5, 9.0, 10.5, 12.0, 12.5, 15.0];
rSunCm = 6.95508d10; %cm, from Allen's astrophysical quantities, 3rd ed.,  p. 340
au2cm=1.49598d13 ;% 1 AU = 1.49598e13 cm (agrees to 5 decimal places with Allen's astrophysical quantities, 3rd ed.,  p. 340)
rEarthCm = 6378.136d5;

% !!!!! Minimum planet radius for injection run
minPlanetRadiusEarthRadii = 0.5;


% Control parameters
% !!!!! NOTE -- if using empirical WF, will still name the saved file for
% the selected dutyCycle. Should fix this. For now, just use 99 for
% selected dutyCycle
% useEmpiricalWindowFunction = logical(input('Use empirical window function -- 1 or 0? '));
maxImpactParameter = 0.95;
highMesThreshold = 15;

% Specify contour type
contourType = input('Contour type -- v0 or v1: ','s');

% Duty cycle label
dutyCycleLabel = [];

% Set validityThreshold and dutyCycle
% validityThreshold = [];
switch contourType
    case 'v1'
        % validityThreshold is not used !!!!!
        % validityThreshold = [];%input('Validity threshold -- return for none, or 0, 0.25, 0.5, 0.75, 0.85, 0.95: ');
    case 'v0'
        overrideDutyCycle = logical(input('Override dutyCycle from TPS? 0 or 1 -- '));
end

% Threshold label for diagnostics
% Set validity threshold to default
validityThreshold = 0.5;
if(~isempty(validityThreshold))
    validityThresholdLabel = strcat('-threshold-',num2str(validityThreshold));
else
    validityThresholdLabel = [];
end


% !!!!! Path to utility functions
addpath /codesaver/work/eta_earth/common

% =========================================================================
% The following code is modified from make_v2_contours.m
% to compute v0 and v1 contours
%==========================================================================
% Inputs: tps-injection-struct.mat

% Generate a grid of impact parameters and corresponding durationMultipliers and mesMultipliers
dx = 1.e-2;
impactParameterGrid = 0:dx:1;
durationMultiplier = ( 1 - impactParameterGrid.^2 ).^(1/2);
nImpactParameterValues = length(impactParameterGrid);

% Control
% groupLabel = input('groupLabel: Group1 (20 G stars), Group2 (20 K stars), Group3 (20 M stars) , Group4 (20 G stars), Group6 (20 K stars), KSOC4886 (1 G, 1 K, and 1 M star), KIC3114789, GroupA, GroupB, KSOC-4930, or KSOC-4964' : ','s');
groupLabel = input('groupLabel, e.g. KSOC-4976-1: ','s');
contourLabel = 'period-radius';%input('Contour type: ''period-mes'' or ''period-radius'': ','s');

% Choose method of matching injected transits to detected ones.
% Use ephemeris-matching 
% Use threshold correlation of 0.92 to select valid injections (87% pass).
% matchMethod = 'tpsephem'; % 9/16/2015 -- found that epoch matches overlap tps-ephem matches by only 87%
matchMethod = 'epoch'; % Hardwired since 10/1/2015, when I discovered that tpsephem is not what I thought it was.
fprintf('matchMethod = %s\n',matchMethod)

% Scripts directory
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis';
cd(baseDir)

% Data directory, for stellar parameters
dataDir = '/codesaver/work/transit_injection/data/';

% Option to model detection efficiency as generalized logistic function OR CDF function
% !!!!! Hardwired to 'L'; see KSOC-4881 for demonstration that 'L' is
% better than 'G'
detectionEfficiencyModelLabel = 'generalized-logistic-function';

% Directories for injection data and diagnostics
[topDir, diagnosticDir] = get_top_dir(groupLabel);

% Directory for detection efficiency contours
contoursDir = strcat('/codesaver/work/transit_injection/contour_plots/',groupLabel,'/');
if( ~exist(contoursDir,'dir') )
    mkdir(contoursDir)
end

% Directory for detection efficiency curves
detectionEfficiencyDir = strcat('/codesaver/work/transit_injection/detection_efficiency_curves/',groupLabel,'/');

% Prepare detectionEfficiencyModel
detectionEfficiencyModelName = 'L';
switch detectionEfficiencyModelName
    case 'L'
        detectionEfficiencyModelLabel = 'generalized-logistic-function';
    case 'G'
        detectionEfficiencyModelLabel = 'gamma-cdf';
end

% Load the tps-injection-struct
load(strcat(topDir,'tps-injection-struct.mat'))

% Unique keplerIds
uniqueKeplerIdAll = unique(tpsInjectionStruct.keplerId);
nTargets = length(uniqueKeplerIdAll);


%==========================================================================
% Initialize for loop over unique keplerIds

% Necessary tpsInjectionStruct fields
% isPlanetACandidate = tpsInjectionStruct.isPlanetACandidate;
% chiSquare2 = tpsInjectionStruct.chiSquare2;               % veto threshold is 7
% robustStatistic = tpsInjectionStruct.robustStatistic;     % veto threshold is 7
% chiSquareGof = tpsInjectionStruct.chiSquareGof;           % veto threshold is 6.8
% chiSquareDof2 = tpsInjectionStruct.chiSquareDof2;
% chiSquareGofDof = tpsInjectionStruct.chiSquareGofDof;
% maxMes = tpsInjectionStruct.maxMes;
% periodDays = tpsInjectionStruct.periodDays;
% thresholdForDesiredPfa field is all -1's, so bootstrapOkay is always true
% in fold_statistics_and_apply_vetoes.m
thresholdForDesiredPfa = tpsInjectionStruct.thresholdForDesiredPfa;
% Expected MES -- see Shawn's notes
% Not used in this code
% expectedMes = tpsInjectionStruct.injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum000;
% expectedMes = tpsInjectionStruct.injectedDepthPpm .* 1e-6 .*
% tpsInjectionStruct.normSum111; % 3/9/2016 Chris uses this

% !!!!! Set 2D binning scheme, same for all targets
% minPeriodDays = 250;
% maxPeriodDays = 600;
minPeriodDays = input('Minimum orbit period in days -- e.g. 20: ');
maxPeriodDays = input('Maximum orbit period in days -- e.g. 730: ');

% Period label for plots
periodLabel = ['-period-',num2str(minPeriodDays),'-to-',num2str(maxPeriodDays),'-days'];
fprintf('!!!!! Using detection efficiency curves computed for range %s ...\n',periodLabel(2:end))

minRadiusEarths = 0.5; % !!!!! This will be smaller for M stars in Groups 3 and 6
maxRadiusEarths = 15;
mesLowerLimit = 3;
mesUpperLimit = 25;
% nBins = [70 30 30]; % binwidth of 10 days, from 20 to 720 days
nBins = [71 30 30]; % binwidth of 10 days, from 20 to 730 days
% Period bins
binWidthPeriod = (maxPeriodDays - minPeriodDays)/nBins(1); % 10 days
% Radius bins
binWidthRadius = (log10(maxRadiusEarths) - log10(minRadiusEarths))/nBins(2);
% MES bins
binWidthMes = (mesUpperLimit - mesLowerLimit)/nBins(3);

% Set up bins and labels for contour plot, depending on contour type
switch contourLabel
    case 'period-radius'
        binEdges = {minPeriodDays:binWidthPeriod:maxPeriodDays log10(minRadiusEarths):binWidthRadius:log10(maxRadiusEarths) };
        yLabelString = ['log_{10}( Radius [Earths] ), bin size =  ',num2str(binWidthRadius,'%6.2f')];
    case 'period-mes'
        binEdges = { minPeriodDays:binWidthPeriod:maxPeriodDays mesLowerLimit:binWidthMes:mesUpperLimit };
        yLabelString = ['MES, bin size =  ',num2str(binWidthMes,'%6.2f')];
end

% Calculate grids for contour plots

% Bin edges
binEdges1 = binEdges{1};
deltaPeriodDays = binEdges1(2) - binEdges1(1);
binEdges2 = binEdges{2};

% Bin centers from binEdges
binCenters1 = (binEdges1(2:end) + binEdges1(1:end-1))./2;
binCenters2 = (binEdges2(2:end) + binEdges2(1:end-1))./2;
binCenters = {binCenters1 binCenters2};
nBinsX = length(binCenters{1});
nBinsY = length(binCenters{2});

% Make 2D meshgrid of binCenters
[xGridCenters,yGridCenters] = meshgrid(binCenters{1},binCenters{2});

% Loop over unique targets
nInjected = zeros(nTargets,nBinsX,nBinsY);
nInjectedThatBecameTces = zeros(nTargets,nBinsX,nBinsY);
pipelineDetectionEfficiency = zeros(nTargets,nBinsX,nBinsY);
pipelineDetectionEfficiency1 = zeros(nTargets,nBinsX,nBinsY);
pipelineDetectionEfficiency2 = zeros(nTargets,nBinsX,nBinsY);
pipelineDetectionEfficiencyNominal = zeros(nTargets,nBinsX,nBinsY);
periodBinCenters = binCenters{1};
log10RadiusBinCenters = binCenters{2};

% Input dutyCycle to use for all targets !!!! over-rides value from stellarParameterStruct
% Option to override dutyCycle from stellarParameterStruct (which is
% incorrectly determined)
if(overrideDutyCycle)
    dutyCycleForV0 = input('Specify dutyCycle -- 0.78 is nominal: ');
    dutyCycleLabel = strcat('-duty-cycle-',num2str(dutyCycleForV0));
    
end

for iTarget = 1:nTargets
    
    % keplerId, for this target
    targetId = uniqueKeplerIdAll(iTarget);
    fprintf('Target %d KIC %d ...\n',iTarget,targetId)
    
    
    % Get stellar parameters for this target
    fprintf('Getting stellar parameters ...\n')
    load(strcat(dataDir,groupLabel,'_stellar_parameters.mat'));
    
    
    % Load detection efficiency file for this target
    fprintf('Getting detection efficiency curve ...\n')
    detEffFileName = strcat(detectionEfficiencyDir,groupLabel,'-detection-efficiency-',matchMethod,'-matching-',detectionEfficiencyModelLabel,'-model',periodLabel,'.mat');
    load(detEffFileName)
    
    % Load diagnostics for this target
    
    % Initialize for one-sigma depth function and window function
    fprintf('Getting diagnostics ...\n')
    diagnosticStruct = load(strcat(diagnosticDir,'tps-diagnostic-struct-',groupLabel,'-KIC-',num2str(targetId),validityThresholdLabel,'.mat'));
    tpsDiagnosticStruct = diagnosticStruct.tpsDiagnosticStruct;
    nPulses = length(tpsDiagnosticStruct);
    nPeriods = length(tpsDiagnosticStruct(1).periodsWindowFunction);
    windowFunctionGrid = zeros(nPeriods,nPulses);
    periodsWindowFunctionGrid = zeros(nPeriods,nPulses);
    oneSigmaDepthFunctionGrid = zeros(nPeriods,nPulses);

    % Injected impact parameters are uniform between 0 and 0.95, but density tails off
    % between 0.95 and 1. Approximate by uniform distribution.
    % Could check the sensitivity to approximation by using actual injected impact
    % parameter distribution.
 
    % Pull out the stellar parameters corresponding
    % to the current target, identified by keplerId
    keplerIdAll = stellarParameterStruct.keplerId;
    
    % Indicator for entries in stellarParameterStruct corresponding to this target
    thisTargetIndicator = ismember(keplerIdAll,targetId);
    
    % depth = 1.e6*(10.^(iRadius)*rEarthCm).^2./(stellarParameterStruct.stellarRadiusInSolarRadii(1)*rSunCm).^2;
    % Include effects of limb-darkening
    stellarRadiusInSolarRadii = stellarParameterStruct.stellarRadiusInSolarRadii(thisTargetIndicator);
    log10SurfaceGravity = stellarParameterStruct.log10SurfaceGravity(thisTargetIndicator);
    log10Metallicity = stellarParameterStruct.log10Metallicity(thisTargetIndicator);
    effectiveTemperature = stellarParameterStruct.effectiveTemp(thisTargetIndicator);
    dataSpanInCadences = stellarParameterStruct.dataSpanInCadences(thisTargetIndicator);
    dutyCycle = stellarParameterStruct.dutyCycle(thisTargetIndicator);
    rmsCdpp = stellarParameterStruct.rmsCdpp(thisTargetIndicator,:);
    % Only need the first entry
    stellarRadiusInSolarRadii = stellarRadiusInSolarRadii(1);
    log10SurfaceGravity = log10SurfaceGravity(1);
    log10Metallicity = log10Metallicity(1);
    effectiveTemperature = effectiveTemperature(1);
    dataSpanInCadences = dataSpanInCadences(1);
    dataSpanInDays = dataSpanInCadences./cadencesPerDay;
    dutyCycle = dutyCycle(1);
    rmsCdpp = rmsCdpp(1,:);

    % Option to override dutyCycle from TPS
    if(overrideDutyCycle)
        dutyCycle = dutyCycleForV0;
    end
   
    % Calculate empirical window function for this target -- use the
    % high-MES version
    % Empirical window functions are smoothed using Savitzky-Golay filter
    
    % if(useEmpiricalWindowFunction)
        [periodBinCentersX, ~, ~, empiricalWindowFunction1, ~, ~, empiricalWindowFunction2] = get_empirical_window_function(minPeriodDays,maxPeriodDays,deltaPeriodDays,groupLabel,targetId,highMesThreshold,maxImpactParameter);
        % Choose the fitSinglePulse window function
        % empiricalWindowFunction = empiricalWindowFunction1;
        % Choose the high-MES window function
        % empiricalWindowFunction = empiricalWindowFunction2;
    % end
     
    % Calculate analytic window function for this target
    [pBins, analyticWindowFunction] = get_analytic_window_function(minPeriodDays,maxPeriodDays,deltaPeriodDays,groupLabel,targetId,dutyCycle);
    % Make a contour plot for detection probability vs. T and Rp for valid
    % injections
    
    % Loop over period and log10radius bins
    % Account for uniform distribution of impact parameters
    % Compute resulting distribution of MES
    % and average over resulting distribution of detection efficiency at
    % each bin center
    
   % Loop over radius and period
   fprintf('Looping over radius and period ...\n')
   for iRadius = 1:nBinsY
        fprintf('Averaging detection efficiency over impact parameter at radius bin %d of %d ...\n',iRadius,nBinsY)
        
        for iPeriod = 1:nBinsX
            
            % Nominal transit duration (i.e. for full transit)
            durationHours = transit_duration(stellarRadiusInSolarRadii,log10SurfaceGravity,periodBinCenters(iPeriod),eccentricity);
            
            % Find index of closest trial pulse to nominal transit duration
            [~,II] = min( abs( pulseDurationsHours - durationHours) );
            
            % Compute one-sigma depth function and window function:
            % Identify the closest trial pulse to the pulse duration
            % Interpolate the one sigma depth function and window function
            % corresponding to the closest trial pulse, at the bin period.
            % Note that search periods in periodsWindowFunction are in
            % superresolution cadences, so we have to scale the period in
            % days by cadencesPerDay*superResolutionFactor
            % Note that one sigma depth function is 1.e6./tpsDiagnosticStruct().meanMes
            periodInSuperResolutionCadences = periodBinCenters(iPeriod)*cadencesPerDay*superResolutionFactor;
            if( periodInSuperResolutionCadences > tpsDiagnosticStruct(II).periodsWindowFunction(end) )
                % Extrapolate
                windowFunction = tpsDiagnosticStruct(II).windowFunction(end);
                oneSigmaDepthFunction = 1.e6./tpsDiagnosticStruct(II).meanMes(end);
            else
                % Interpolate
                windowFunction =        interp1(tpsDiagnosticStruct(II).periodsWindowFunction, ...
                    tpsDiagnosticStruct(II).windowFunction, ...
                    periodInSuperResolutionCadences);
                oneSigmaDepthFunction = interp1(tpsDiagnosticStruct(II).periodsWindowFunction, ...
                    1.e6./tpsDiagnosticStruct(II).meanMes, ...
                    periodInSuperResolutionCadences);
            end
            
            % Nominal Transit Depth (zero impact parameter) in PPM
            rplanet = 10.^log10RadiusBinCenters(iRadius);
            nominalDepth = rp_to_tpssquaredepth(stellarRadiusInSolarRadii,rplanet,0);
            
            % Nominal MES at zero impact parameter in this bin
            nominalMes = nominalDepth/(oneSigmaDepthFunction);
            
            % Nominal detection efficiency (assuming impact parameter of
            % zero)
            if(nominalMes > midMesBin(end))
                % Extrapolate
                pipelineDetectionEfficiencyNominal(iTarget,iPeriod,iRadius) =  detectionEfficiencyAll(end,iTarget).*windowFunction;
            else
                % Interpolate
                pipelineDetectionEfficiencyNominal(iTarget,iPeriod,iRadius) = interp1(midMesBin',detectionEfficiencyAll(:,iTarget),nominalMes,'pchip').*windowFunction;
            end
            
            
            % Transit duration grid over impact parameter values
            durationHoursValues = durationHours.*durationMultiplier;
            
            % Loop over duration and MES corresponding to a uniform
            % distribution of impact parameters
            % Identify the closest trial pulse to the pulse duration
            % Interpolate the one sigma depth function and window function
            % corresponding to the period
            % Transform the MES according to the signal at this impact
            % parameter and duration.
            % Interpolate the detection efficiency for the transformed MES
            % Finally, integrate (average) over the detection efficiencies
            % corresponding to the uniform distribution of impact
            % parameters to get the transformed detection efficiency in
            % this bin.
            JJ = zeros(1,nImpactParameterValues);
            windowFunctionGrid = cell(1,nImpactParameterValues);
            oneSigmaDepthFunctionGrid = cell(1,nImpactParameterValues);
            detEffValues = zeros(1,nImpactParameterValues);
            detEffValues1 = zeros(1,nImpactParameterValues);
            detEffValues2 = zeros(1,nImpactParameterValues);
           
            % Compute the mean detection efficiency over a uniform distribution of impact parameter values in this [period,radius] bin
            for iImpactParameter = 1:nImpactParameterValues
                
                
                % For v1 contours, use the provided numerical WF and OSDF
                % For v0 contours, use analytic approximation to WF and OSDF
                switch contourType
                    
                    case 'v1'
                        
                        
                        % Compute the Window Function and One-Sigma Depth Function
                        % For v1 contours, WF and OSDF depend on transit duration
                        % Identify the *closest trial* pulse length to this duration value
                        [~,JJ(iImpactParameter)] = min( abs( pulseDurationsHours - durationHoursValues(iImpactParameter)) );
                        
                        % Recompute the window function and the 1-sigma depth function corresponding to the transit
                        % duration set by this impact parameter.
                        
                        
                        if( periodBinCenters(iPeriod)*cadencesPerDay*superResolutionFactor > tpsDiagnosticStruct(JJ(iImpactParameter)).periodsWindowFunction(end) )
                            
                            % Extrapolate to end of grid
                            windowFunctionGrid{iImpactParameter} = tpsDiagnosticStruct(JJ(iImpactParameter)).windowFunction(end);
                            oneSigmaDepthFunctionGrid{iImpactParameter} = 1.e6./tpsDiagnosticStruct(JJ(iImpactParameter)).meanMes(end);
                            WF = windowFunctionGrid{iImpactParameter};
                            OSDF = oneSigmaDepthFunctionGrid{iImpactParameter};
                            
                        elseif( periodBinCenters(iPeriod)*cadencesPerDay*superResolutionFactor < tpsDiagnosticStruct(JJ(iImpactParameter)).periodsWindowFunction(1) )
                            
                            % Extrapolate to beginning of grid
                            windowFunctionGrid{iImpactParameter} = tpsDiagnosticStruct(JJ(iImpactParameter)).windowFunction(1);
                            oneSigmaDepthFunctionGrid{iImpactParameter} = 1.e6./tpsDiagnosticStruct(JJ(iImpactParameter)).meanMes(1);
                            WF = windowFunctionGrid{iImpactParameter};
                            OSDF = oneSigmaDepthFunctionGrid{iImpactParameter};
                            
                        else
                            
                            % Evaluate the WF and OSDF at the duration corresponding to this
                            % impact parameter, at this period
                            windowFunctionGrid{iImpactParameter} = interp1(tpsDiagnosticStruct(JJ(iImpactParameter)).periodsWindowFunction, ...
                                tpsDiagnosticStruct(JJ(iImpactParameter)).windowFunction, ...
                                periodBinCenters(iPeriod).*cadencesPerDay.*superResolutionFactor);
                            oneSigmaDepthFunctionGrid{iImpactParameter} = interp1(tpsDiagnosticStruct(JJ(iImpactParameter)).periodsWindowFunction, ...
                                1.e6./tpsDiagnosticStruct(JJ(iImpactParameter)).meanMes, ...
                                periodBinCenters(iPeriod).*cadencesPerDay.*superResolutionFactor);
                            
                            % Apply correction by interpolating WF and OSDF for the
                            % *actual* pulse duration
                            
                            if( durationHoursValues(iImpactParameter) <= pulseDurationsHours(1) )
                                % If the shortened duration is less than pulseDurationHours(1),
                                % set the target duration equal to pulseDurationHours(1)
                                durationToInterpolate = pulseDurationsHours(1);
                            elseif( durationHoursValues(iImpactParameter) >= pulseDurationsHours(end) )
                                % If the shortened duration is greater than pulseDurationHours(end),
                                % set the target duration equal to pulseDurationHours(end)
                                durationToInterpolate = pulseDurationsHours(end);
                            else
                                % Otherwise the target to interpolate is the
                                % shortened duration due to the impact parameter
                                durationToInterpolate = durationHoursValues(iImpactParameter);
                            end
                            
                            % WF, OSDF corrresponding to the closest pulse duration
                            % in the grid to the *shortened* pulse duration due to the impact parameter
                            centerWF = interp1( tpsDiagnosticStruct( JJ(iImpactParameter) ).periodsWindowFunction, ...
                                tpsDiagnosticStruct( JJ(iImpactParameter)).windowFunction, ...
                                periodBinCenters(iPeriod).*cadencesPerDay.*superResolutionFactor);
                            
                            centerOSDF = interp1( tpsDiagnosticStruct( JJ(iImpactParameter) ).periodsWindowFunction, ...
                                1.e6./tpsDiagnosticStruct(JJ(iImpactParameter)).meanMes, ...
                                periodBinCenters(iPeriod).*cadencesPerDay.*superResolutionFactor);
                            
                            centerPulseDuration = pulseDurationsHours(JJ(iImpactParameter));
                            
                            if( durationToInterpolate < pulseDurationsHours(end) || durationToInterpolate > pulseDurationsHours(1) )
                                
                                % Compute left and right elements for interpolation
                                % grid
                                if(JJ(iImpactParameter) == 1)
                                    
                                    % No left element if closest pulse is first one
                                    leftWF = -1;
                                    leftOSDF = -1;
                                    leftPulseDuration = -1;
                                    
                                elseif(JJ(iImpactParameter) == length(pulseDurationsHours))
                                    
                                    % No right element if closest pulse is the last
                                    % one
                                    rightWF = -1;
                                    rightOSDF = -1;
                                    rightPulseDuration = -1;
                                    
                                else
                                    
                                    
                                    % Left and right interpolation grid pulse
                                    % duration, WF and OSDF
                                    leftPulseDuration = pulseDurationsHours( JJ(iImpactParameter) - 1 );
                                    
                                    rightPulseDuration = pulseDurationsHours( JJ(iImpactParameter) + 1 );
                                    
                                    leftWF = interp1( tpsDiagnosticStruct( JJ(iImpactParameter) - 1 ).periodsWindowFunction, ...
                                        tpsDiagnosticStruct( JJ(iImpactParameter) - 1).windowFunction, ...
                                        periodBinCenters(iPeriod).*cadencesPerDay.*superResolutionFactor);
                                    
                                    rightWF = interp1( tpsDiagnosticStruct( JJ(iImpactParameter) + 1 ).periodsWindowFunction, ...
                                        tpsDiagnosticStruct( JJ(iImpactParameter) + 1).windowFunction, ...
                                        periodBinCenters(iPeriod).*cadencesPerDay.*superResolutionFactor);
                                    
                                    leftOSDF = interp1( tpsDiagnosticStruct( JJ(iImpactParameter) - 1 ).periodsWindowFunction, ...
                                        1.e6./tpsDiagnosticStruct( JJ(iImpactParameter) - 1 ).meanMes, ...
                                        periodBinCenters(iPeriod).*cadencesPerDay.*superResolutionFactor);
                                    
                                    rightOSDF = interp1( tpsDiagnosticStruct( JJ(iImpactParameter) + 1 ).periodsWindowFunction, ...
                                        1.e6./tpsDiagnosticStruct( JJ(iImpactParameter) + 1 ).meanMes, ...
                                        periodBinCenters(iPeriod).*cadencesPerDay.*superResolutionFactor);
                                    
                                end % compute left and right elements for interpolation grid
                                
                                % Interpolation grid
                                PDvector = [ leftPulseDuration, centerPulseDuration, rightPulseDuration ];
                                WFvector = [ leftWF, centerWF, rightWF ];
                                OSDFvector = [ leftOSDF, centerOSDF, rightOSDF ];
                                
                                % Replace a single NaN in WFvector and/or OSDFvector with
                                % its nearest neighbor
                                nansOSDF = isnan(OSDFvector);
                                nansWF = isnan(WFvector);
                                if( sum(nansOSDF>1) || sum(nansWF>1) )
                                    % Error if more than one NaN in WF or in OSDF
                                    error('>1 nans in OSDF or WF')
                                else
                                    indices = 1:3;
                                    
                                    nanIndexOSDF = indices(nansOSDF);
                                    nanIndexWF = indices(nansWF);
                                    
                                    % Replace a single nan in OSDF
                                    if(~isempty(nanIndexOSDF))
                                        switch nanIndexOSDF
                                            case 1
                                                OSDFvector(1) = OSDFvector(2);
                                            case 2
                                                OSDFvector(2) = OSDFvector(1);
                                            case 3
                                                OSDFvector(3) = OSDFvector(2);
                                        end % switch
                                    end
                                    
                                    % Replace a single nan in WF
                                    if(~isempty(nanIndexWF))
                                        switch nanIndexWF
                                            case 1
                                                WFvector(1) = WFvector(2);
                                            case 2
                                                WFvector(2) = WFvector(1);
                                            case 3
                                                WFvector(3) = WFvector(2);
                                        end % switch
                                        
                                    end % test of empty vectors
                                    
                                end % test of nans
                                
                                % Truncate interpolation grid if first or last
                                % pulse duration is bad
                                PDvector = PDvector( PDvector > -1 );
                                WFvector = WFvector( PDvector > -1 );
                                OSDFvector = OSDFvector( PDvector > -1 );
                                
                                % Eliminate duplicate pulse durations
                                % should only happen if the grid dimension is 3
                                mask = [true, true, true];
                                if(length(PDvector)==3)
                                    if(PDvector(1) == PDvector(2))
                                        mask = [false, true, true];
                                    elseif(PDvector(2) == PDvector(3))
                                        mask = [true, true, false];
                                    end
                                    PDvector = PDvector(mask);
                                    OSDFvector = OSDFvector(mask);
                                    WFvector = WFvector(mask);
                                end
                                
                                
                                % Interpolate numerical window function and one sigma depth
                                % function corresponding the the actual pulse
                                % duration
                                WF = interp1( PDvector, WFvector, durationToInterpolate);
                                OSDF = interp1( PDvector, OSDFvector , durationToInterpolate);
                                
                                % Report error if WF or OSDF is NaN
                                if( ~isfinite(OSDF) || ~isfinite(WF) )
                                    error('OSDF or WF not finite')
                                end
                                
                            end % duration is in the range for interpolation
                            
                        end % recompute WF and OSDF for the transit duration set by this impact parameter
                        
                    case 'v0'
                        
                        % Compute analytic WF and compute analytic OSDF
                        %   analytic WF doesn't depend on duration, only on
                        %       nominal number of transits
                        %   analytic OSDF is not independent of duration -- it depends on cdpp and dutyCycle
                        %       and dataSpanInCadences
                        
                        % Compute window function for this star at this period
                                                
                        % Nominal number of transits, for computation of WF
                        nTransitsEffective = dataSpanInDays./periodBinCenters(iPeriod);
                     
                        % Analytic Window Function
                        % Min number of transits should be 3, since 0, 1,
                        % and 2 are accounted for in WF
                        % Chris said this should have a floor of 3.
                        % But that makes a ramp in the residual,
                        % increasing from 0 at 300 days to 0.3 at 700
                        % days.
                        % nTransitsEffectiveForWF = max(nTransitsEffective,3);
                        % WF = 1;
                        % WF = WF - floatbino(0,nTransitsEffective,dutyCycle);
                        % WF = WF - floatbino(1,nTransitsEffective,dutyCycle);
                        % WF = WF - floatbino(2,nTransitsEffective,dutyCycle);                        
                        
                        % Clean up negative values
                        % if( WF < 0 )
                        %     WF = 0.0;
                        % end
                        
                        % Interpolate the rmsCdpp using the actual pulse duration
                        % corresponding to this impact parameter
                        % If the actual pulse duration is longer (shorter)
                        % than the max (min) trial pulse duration, then
                        % extrapolate cdpp to rightmost (leftmost) value in
                        % rmsCdpp
                  
                        if(durationHoursValues(iImpactParameter) < pulseDurationsHours(1))
                            cdppAtThisPulseDuration = rmsCdpp(1);
                        elseif(durationHoursValues(iImpactParameter) > pulseDurationsHours(end))
                            cdppAtThisPulseDuration = rmsCdpp(end);
                        else
                            cdppAtThisPulseDuration = interp1(pulseDurationsHours,rmsCdpp,durationHoursValues(iImpactParameter),'pchip');
                        end
                        
                        % Analytic One Sigma Depth Function
                        % Model is MES = depth/OSDF = ( depth./cdpp ) .* sqrt( dutyCycle.*nTransitsEffective );
                        % therefore OSDF can be defined as cdpp/(sqrt(dutyCycle*nTransitsEffective))
                        OSDF = cdppAtThisPulseDuration./sqrt(dutyCycle.*nTransitsEffective);
                        
                               
                end % switch contourType  v0 or v1
                
                % Transform the nominal MES (at zero-impact parameter), to
                % the MES for this impact parameter, accounting for loss in
                % depth
                
                % Correct nominalDepth for limb-darkening at the current impact
                % parameter and correspondingly shortened transit duration
                limbDarkenedDepth = rp_to_tpssquaredepth( stellarRadiusInSolarRadii , rplanet , impactParameterGrid(iImpactParameter) );
                
                % MES, corrected for limb-darkening, window function and one-sigma depth function at
                % current impact parameter
                % transformedMes = limbDarkenedDepth./ ...
                %     oneSigmaDepthFunctionGrid{iImpactParameter};
                transformedMes = limbDarkenedDepth./OSDF;
                
                % !!!!! 12/14/2015 Add option to use empirical window function
                % if(useEmpiricalWindowFunction)
                %    wfUsed = empiricalWindowFunction(iPeriod);
                % else
                    % wfUsed = WF;
                    wfUsed = analyticWindowFunction(iPeriod);
                % end
                
                % Interpolate the detection efficiency for the
                % corrected MES
                if(transformedMes > midMesBin(end))
                    % Extrapolate
                    % detEffValues(iImpactParameter) = detectionEfficiencyAll(end,iTarget).*windowFunctionGrid{iImpactParameter};
                    detEffValues(iImpactParameter) = detectionEfficiencyAll(end,iTarget).*wfUsed;
                    detEffValues1(iImpactParameter) = detectionEfficiencyAll(end,iTarget).*empiricalWindowFunction1(iPeriod);
                    detEffValues2(iImpactParameter) = detectionEfficiencyAll(end,iTarget).*empiricalWindowFunction2(iPeriod);
                    
                elseif(transformedMes < midMesBin(1))
                    % Extrapolate
                    % detEffValues(iImpactParameter) = detectionEfficiencyAll(1,iTarget).*windowFunctionGrid{iImpactParameter};
                    detEffValues(iImpactParameter) = detectionEfficiencyAll(1,iTarget).*wfUsed;
                    detEffValues1(iImpactParameter) = detectionEfficiencyAll(1,iTarget).*empiricalWindowFunction1(iPeriod);
                    detEffValues2(iImpactParameter) = detectionEfficiencyAll(1,iTarget).*empiricalWindowFunction2(iPeriod);
                else
                    % Interpolate
                    % detEffValues(iImpactParameter) = interp1(midMesBin',detectionEfficiencyAll(:,iTarget),transformedMes,'pchip').*windowFunctionGrid{iImpactParameter};
                    % detEffValues(iImpactParameter) = interp1(midMesBin',detectionEfficiencyAll(:,iTarget),transformedMes,'pchip').*WF;
                    detEffValues(iImpactParameter) = interp1(midMesBin',detectionEfficiencyAll(:,iTarget),transformedMes,'pchip')*wfUsed;
                    detEffValues1(iImpactParameter) = interp1(midMesBin',detectionEfficiencyAll(:,iTarget),transformedMes,'pchip')*empiricalWindowFunction1(iPeriod);
                    detEffValues2(iImpactParameter) = interp1(midMesBin',detectionEfficiencyAll(:,iTarget),transformedMes,'pchip')*empiricalWindowFunction2(iPeriod);
                end
                
            end % loop over impact parameter values
            
            % Average over detection efficiencies corresponding to a
            % uniform distribution of impact parameters,a d apply window
            % function
            meanDetEff = mean(detEffValues);
            meanDetEff1 = mean(detEffValues1);
            meanDetEff2 = mean(detEffValues2);
            
            % Detection efficiency in this bin, accounting for a uniform distribution of impact parameters
            pipelineDetectionEfficiency(iTarget,iPeriod,iRadius) = meanDetEff;
            pipelineDetectionEfficiency1(iTarget,iPeriod,iRadius) = meanDetEff1;
            pipelineDetectionEfficiency2(iTarget,iPeriod,iRadius) = meanDetEff2;
           
        end % loop over period bins
        
    end % loop over radius bins
    
    
    % dutyCycle label
    % if(useEmpiricalWindowFunction)
    %    dutyCycleLabel = num2str('99');
    %    disp('Using dutyCycle label of 99 to indicate that empirical WF is being used in place of analytic WF...')
    % else
    %    dutyCycleLabel = strcat('-duty-cycle-',num2str(dutyCycle));
    % end
    
    % Contour plot -- Pipeline detection efficiency
    figure
    [~,h2] = contourf(xGridCenters,yGridCenters,squeeze(pipelineDetectionEfficiency(iTarget,:,:))');
    set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Pipeline Detection Efficiency');
    title([contourType,' Detection Contours for ',groupLabel,' target KIC ',num2str(targetId)])
    xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
    ylabel(yLabelString)
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(contoursDir,contourType,'-detection-contours-',groupLabel,'-KIC-',num2str(targetId),'-',contourLabel,validityThresholdLabel,dutyCycleLabel,'.png');
    print('-r150','-dpng',plotName)

    % Contour plot -- Pipeline detection efficiency difference: analytic
    % minus empirical
    figure
    [~,h2] = contourf( xGridCenters,yGridCenters,squeeze( pipelineDetectionEfficiency(iTarget,:,:) - pipelineDetectionEfficiency1(iTarget,:,:) )' );
    set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Pipeline Detection Efficiency');
    title([contourType,' Analytic minus Empirical Detection Contours for ',groupLabel,' target KIC ',num2str(targetId)])
    xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
    ylabel(yLabelString)
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(contoursDir,contourType,'-analytic-minus-empirical-detection-contours-',groupLabel,'-KIC-',num2str(targetId),'-',contourLabel,validityThresholdLabel,dutyCycleLabel,'.png');
    print('-r150','-dpng',plotName)
    
    
    % Contour plot -- Nominal pipeline detection efficiency (zero impact
    % parameter
    skip = true;
    if(~skip)
        figure
        [~,h2] = contourf(xGridCenters,yGridCenters,squeeze(pipelineDetectionEfficiencyNominal(iTarget,:,:))');
        set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
        t = colorbar('peer',gca);
        set(get(t,'ylabel'),'String', 'Pipeline Detection Efficiency');
        title(['Nominal ',contourType,' Detection Contours for ',groupLabel,' target KIC ',num2str(targetId)])
        xlabel(['Period [Days], bin size = ',num2str(binWidthPeriod,'%6.2f')])
        ylabel(yLabelString)
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        plotName = strcat(contoursDir,contourType,'-detection-contours-nominal-',groupLabel,'-KIC-',num2str(targetId),'-',contourLabel,validityThresholdLabel,dutyCycleLabel,'.png');
        print('-r150','-dpng',plotName)
    end
    
end % loop over targets

% Save the detection contour data for all targets
% Saving v0 contours based on analytical and based on empirical detection efficiency
dataFile = strcat(contoursDir,contourType,'-detection-contours-',groupLabel,'-',contourLabel,validityThresholdLabel,dutyCycleLabel);
save([dataFile,'.mat'],'xGridCenters','yGridCenters','binWidthPeriod','binWidthRadius','binWidthMes','binCenters',...
    'nInjected','nInjectedThatBecameTces','pipelineDetectionEfficiency', 'pipelineDetectionEfficiency1', 'pipelineDetectionEfficiency2',...
    'groupLabel','uniqueKeplerIdAll','contourLabel','yLabelString','nTargets');

