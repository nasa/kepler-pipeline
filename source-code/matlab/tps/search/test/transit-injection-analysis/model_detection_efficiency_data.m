% model_detection_efficiency_data.m
%==========================================================================
% Gather detection efficiency data for experiments so far:
% Groups 1-1, 1-2, 1-3, 2, 3, 4, 5, and 6
% comprising 120 G, K and M stars
% WARNING: Different versions of the transit injection code were used for
% these runs.
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

% !!!!! Run make_detection_efficiency_curve.m on all the data sets,
% immediately *before* running this script.

% !!!!! Can run synthesize_detection_efficiency_curves.m *after* running this script.


clear all
close all

% Period range
periodRangeLabel = '20-to-240-days';

% Scripts directory
baseDir = '/path/to/matlab/tps/search/test/transit-injection-analysis/';
plotDir = '/codesaver/work/transit_injection/plots/characterization/';


% Load the completeStructArray with stellar parameters created by Chris Burke in KSO-416
if(~exist('completeStructArray','var'))
    fprintf('Loading completeStructArray...\n')
    load('/path/to/so-products-DR25/Complete_Seed_DR25_04-05-2016.mat');
end

% Get RA and DEC, other stellar parameters
RAall = [completeStructArray.new3ra]';
DECall = [completeStructArray.new3dec]';
new3rstarAll = [completeStructArray.new3rstar]';
new3teffAll = [completeStructArray.new3teff]';
new3loggAll = [completeStructArray.new3logg]';
new3ValidKicAll = [completeStructArray.new3ValidKic]';
kpmagAll = [completeStructArray.kpmag]';
keplerIdAll = [completeStructArray.keplerId]';


% Get RMS CDPP, dutyCycle and dataSpan for the 14 pulse durations
nTargets = length(completeStructArray);
nPulseDurations = length(completeStructArray(1).rmsCdpps2);
rmsCdpp2All = zeros(nTargets,nPulseDurations);
rmsCdpp1All = zeros(nTargets,nPulseDurations);
dataSpansAll = zeros(nTargets,nPulseDurations);
dutyCyclesAll = zeros(nTargets,nPulseDurations);
for iTarget = 1:nTargets
    rmsCdpp2All(iTarget,:) = [completeStructArray(iTarget).rmsCdpps2];
    rmsCdpp1All(iTarget,:) = [completeStructArray(iTarget).rmsCdpps1];
    dataSpansAll(iTarget,:) = [completeStructArray(iTarget).dataSpans1];
    dutyCyclesAll(iTarget,:) = [completeStructArray(iTarget).dutyCycles1];
end



%==========================================================================

% Model for detection efficiency
modelType = input('Model: Q(logistic quadratic cdppSlope), R(robust quadratic cdppSlope) W(robust linear logMedianWaveletCoeff)-- ','s');
switch modelType
    
    case 'S'
        modelString = 'Sigmoid CDPP slope ';
        labelString = 'sigmoid_cdpp_slope';
        
    case 'L'
        modelString = 'Linear CDPP slope';
        labelString = 'linear_cdpp_slope';
        
    case 'Q'
        modelString = 'Quadratic CDPP slope';
        labelString = 'quadratic_cdpp_slope';
        
    case 'M'
        modelString = 'Multilinear with 14 log RMS CDPPs ';
        labelString = 'multilinear_log_rms_cdpp'; 
        
    case 'R'
        modelString = 'Robust Quadratic CDPP slope';
        labelString = 'robust_quadratic_cdpp_slope';
        
    case 'W'
        modelString = 'Quadratic in both CDPP slope and log10(WC6/WC1)';
        labelString = 'quadratic_in_cdpp_slope_and_log10WC6';
        
end

% Initialize
groupList = cell(1,7);
groupList{1} = 'Group1-1';
% groupList{2} = 'Group1-2'; % duplicates stars in Group1-1
% groupList{3} = 'Group1-3'; % duplicates stars in Group1-1
groupList{2} = 'Group2';
groupList{3} = 'Group3';
groupList{4} = 'Group4';
groupList{5} = 'Group5';
groupList{6} = 'Group6';
groupList{7} = 'KSOC-4964-4';
% groupList{8} = 'KSOC-5004-1'; % original run with MES targeting ON
groupList{8} = 'KSOC-5004-1-run2'; % MES targeting OFF
groupList{9} = 'KSOC-5004-2'; % MES targeting OFF

% Groups A and B only
groupList1 = cell(1,2);
groupList1{1} = 'GroupA';
groupList1{2} = 'GroupB';

% KSOC-5004 Groups 1 and 2 only
groupList2 = cell(1,2);
groupList2{1} = 'KSOC-5004-1-run2';
groupList2{2} = 'KSOC-5004-2';


% Selected MES bins for computing a 'sufficient
% statistic' for detection efficiency curve
% lowerMesBin = 13; % MES 6.125
% upperMesBin = 27; % MES 9.625
% 20 <- 7.875
lowerMesBin = 20; 
upperMesBin = 20;

% Data for stellar parameters
stellarParametersDir = '/codesaver/work/transit_injection/data/';

% Pulse durations
pulseDurationsHours = [1.5, 2.0, 2.5, 3.0, 3.5, 4.5 , 5.0, 6.0, 7.5, 9.0, 10.5, 12.0, 12.5, 15.0];

% CDPP slope range
cdppSlopeRange = (-0.6:0.01:0.4)';

% Initialize accumulator variables
detectionEfficiency = [];
exitflag = [];
fval = [];
nDetected = [];
nMissed = [];
gammaParameter1 = [];
gammaParameter2 = [];
gammaParameter3 = [];
keplerId = [];
keplerIdCheck = [];
log10SurfaceGravity = [];
log10Metallicity = [];
effectiveTemp = [];
stellarRadiusInSolarRadii = [];
rmsCdpp = [];
dataSpanInCadences = [];
dutyCycle = [];
keplerMag = [];

% Loop over the transit injection runs, and accumulate data for all 140 unique targets
% Option to test using GroupA and GroupB only
test1 = false;
if(test1)
    groupList = groupList1;
end

% Option to use KSOC-5004 Group1 and Group2 only. These injections should
% be valid for all periods, out to 730 days.
test2 = logical(input('Use KSOC-5004 Group1 and Group2 injections only: 0 or 1 -- '));
if(test2)
    % Use only KSOC-5004 Groups 1 and 2
    groupList = groupList2;
    
    % Option to use det eff curve that goes to max period of 730 days instead of max period of
    % 240 days
    useLongPeriodDetectionEfficiencyCurve = logical(input('Use 20 to 730 day det eff instead of 20 to 240 days? 0 or 1 -- '));
    if(useLongPeriodDetectionEfficiencyCurve)
        periodRangeLabel = '20-to-730-days';
    end
end


% !!!!! test -- Override groupList
% clear groupList
% groupList{1} = 'KSOC-5007-shallow-test1';


% !!!!! All the detection efficiency files are for 20-to-240-days because
% all are valid in that range, but not necessarily at longer periods, due
% to correction of errors in the injection codes since the earlier runs.
for groupLabel = groupList
    
    
    switch char(groupLabel)
        
        case 'Group1-1'
            dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group1-1/';
            fileName = strcat('Group1-1-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');
            
        case 'Group1-2'
            dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group1-2/';
            fileName = strcat('Group1-2-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');
            
        case 'Group1-3'
            dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group1-3/';
            fileName = strcat('Group1-3-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');
            
        case 'Group2'
            dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group2/';
            fileName = strcat('Group2-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');
            
        case 'Group3'
            dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group3/';
            fileName = strcat('Group3-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');
            
        case 'Group4'
            dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group4/';
            fileName = strcat('Group4-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');
            
        case 'Group5'
            dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group5/';
            fileName = strcat('Group5-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');
            
        case 'Group6'
            dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/Group6/';
            fileName = strcat('Group6-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');
            
        case 'KSOC-4964-4'
            dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/KSOC-4964-4/';
            fileName = strcat('KSOC-4964-4-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');
            
        case 'GroupA'
            % Group A (3 G stars and 2 K stars -- previous injection targets?)
            dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/GroupA/';
            fileName = strcat('GroupA-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');
            
        case 'GroupB'
            % Group B (1 G star, 1 K star and 3 M stars -- previous injection targets?)
            dataDir ='/codesaver/work/transit_injection/detection_efficiency_curves/GroupB/';
            fileName = strcat('GroupB-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');
            
        case 'KSOC-5004-1'
            % KSOC-5004 Group1, 20 stars selected for CDPP slope spanning
            % desired range, but MES targeting is ON
            dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/KSOC-5004-1/';
            fileName = strcat('KSOC-5004-1-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');

            
        case 'KSOC-5004-1-run2'
            % This run repeated the last, but with MES targeting turned off.
            % 20 Targets with CDPP slope in desired range roughly 650K
            % injections on each
            dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/KSOC-5004-1-run2/';
            fileName = strcat('KSOC-5004-1-run2-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');
            
        case 'KSOC-5004-2'
            % KSOC-5004 Group2, 20 stars selected for CDPP slope spanning
            % desired range, MES targeting turned OFF
            dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/KSOC-5004-2/';
            fileName = strcat('KSOC-5004-2-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');
    
        case 'KSOC-5007-shallow-test1' % 98 stars
            dataDir = '/codesaver/work/transit_injection/detection_efficiency_curves/KSOC-5007-shallow-test1/';
            fileName = strcat('KSOC-5007-shallow-test1-detection-efficiency-epoch-matching-generalized-logistic-function-model-period-',periodRangeLabel,'.mat');
            
        otherwise
            fprintf('!!!!! Error --no data for groupLabel %s !!!!!\n',char(groupLabel))
            
    end % case
    
    % Accumulate stellar parameters data
    stellarParametersFile = strcat(stellarParametersDir,char(groupLabel),'_stellar_parameters.mat');
    load(stellarParametersFile);
    keplerIdCheck = [keplerIdCheck ; stellarParameterStruct.keplerId ];
    log10SurfaceGravity = [ log10SurfaceGravity ; stellarParameterStruct.log10SurfaceGravity ];
    log10Metallicity = [ log10Metallicity ; stellarParameterStruct.log10Metallicity ];
    effectiveTemp = [ effectiveTemp ; stellarParameterStruct.effectiveTemp ];
    stellarRadiusInSolarRadii = [ stellarRadiusInSolarRadii ; stellarParameterStruct.stellarRadiusInSolarRadii ];
    rmsCdpp = [ rmsCdpp ; stellarParameterStruct.rmsCdpp ];
    dataSpanInCadences = [ dataSpanInCadences ; stellarParameterStruct.dataSpanInCadences ];
    dutyCycle = [ dutyCycle ; stellarParameterStruct.dutyCycle ];
    keplerMag = [ keplerMag ; stellarParameterStruct.keplerMag ];
    
    % Accumulate detection efficiency data from this target
    detectionEfficiencyFile = strcat(dataDir,fileName);
    load(detectionEfficiencyFile)
    detectionEfficiency = [ detectionEfficiency , detectionEfficiencyAll ];
    nDetected = [ nDetected , nDetectedAll];
    nMissed = [ nMissed , nMissedAll];
    keplerId = [ keplerId ; uniqueKeplerId ];
    
    % Detection curve was optionally fitted to a model
    detEffModelFit = false;
    if(detEffModelFit)
        exitflag = [ exitflag ; exitflagAll];
        fval = [ fval ; fvalAll ];
        gammaParameter1 = [ gammaParameter1 ; parameter1 ];
        gammaParameter2 = [ gammaParameter2 ; parameter2 ];
        gammaParameter3 = [ gammaParameter3 ; parameter3 ];
    end
    clear detectionEfficiencyAll exitflagAll fvalAll nDetectedAll nMissedAll parameter1 parameter2 parameter3 uniqueKeplerId
    clear stellarParameterStruct
    
end % for

% Trim the data from the bad K stars in Group 3
badKeplerIds = [4142913; 6804018; 7033670];
goodTargetIdx = ~ismember(keplerId,badKeplerIds);
keplerIdCheck = keplerIdCheck(goodTargetIdx);
keplerId = keplerId(goodTargetIdx);
log10SurfaceGravity = log10SurfaceGravity(goodTargetIdx);
log10Metallicity = log10Metallicity(goodTargetIdx);
effectiveTemp = effectiveTemp(goodTargetIdx);
stellarRadiusInSolarRadii = stellarRadiusInSolarRadii(goodTargetIdx);
rmsCdpp = rmsCdpp(goodTargetIdx,:);
dataSpanInCadences = dataSpanInCadences(goodTargetIdx);
dutyCycle = dutyCycle(goodTargetIdx);
keplerMag = keplerMag(goodTargetIdx);
detectionEfficiency = detectionEfficiency(:,goodTargetIdx);
nDetected = nDetected(goodTargetIdx);
nMissed = nMissed(goodTargetIdx);
nTargets = length(keplerId);
if(detEffModelFit)
    exitflag = exitflag(goodTargetIdx);
    fval = fval(goodTargetIdx);
    gammaParameter1 = gammaParameter1(goodTargetIdx);
    gammaParameter2 = gammaParameter2(goodTargetIdx);
    gammaParameter3 = gammaParameter3(goodTargetIdx);
end


% Match keplerIds to entries in keplerIdAll from completeStructArray,
% and cross-match to RA and DEC and other stellar parameters
[TF, indexInKeplerIdAll] = ismember(keplerId,keplerIdAll);
RA = RAall(indexInKeplerIdAll);
DEC = DECall(indexInKeplerIdAll);
new3rstar = new3rstarAll(indexInKeplerIdAll);
new3teff = new3teffAll(indexInKeplerIdAll);
new3logg = new3loggAll(indexInKeplerIdAll);
new3ValidKic = new3ValidKicAll(indexInKeplerIdAll);
kpmag = kpmagAll(indexInKeplerIdAll);
rmsCdpp2 = rmsCdpp2All(indexInKeplerIdAll,:);
rmsCdpp1 = rmsCdpp1All(indexInKeplerIdAll,:);

% Check for agreement between Burke's catalog and the one I got from TPS
fprintf('Number of stars for which my Teff disagrees with Burke catalog = %d, std dev of diff = %6.2e\n',sum(effectiveTemp ~= new3teff),std(effectiveTemp - new3teff))
fprintf('Number of stars for which my stellar radius disagrees with Burke catalog = %d, std dev of diff = %6.2e\n',sum(stellarRadiusInSolarRadii ~= new3rstar),std(stellarRadiusInSolarRadii - new3rstar))
fprintf('Number of stars for which my logg disagrees with Burke catalog = %d, std dev of diff = %6.2e\n',sum(log10SurfaceGravity ~= new3logg),std(log10SurfaceGravity - new3logg))
fprintf('Number of stars for which my kepler mag disagrees with Burke catalog = %d, std dev of diff = %6.2e\n',sum(keplerMag ~= kpmag),std(keplerMag - kpmag))


% Get cdpp slope
% Modified: uses ordinary least squares instead of robust least squares
% cdppSlope is computed for the last 6 pulse durations [9:14] for consistency with
% Chris Burke
cdppSlope = get_cdpp_slope(rmsCdpp2,rmsCdpp1);

% Check
validRmsCdpp = false(size(cdppSlope));
for iTarget = 1:nTargets
    validRmsCdpp(iTarget,1) = isreal(cdppSlope(iTarget,1));
end
fprintf('number of invalid RMS CDPP values is %d\n',sum(~validRmsCdpp))

% Save the catalog of keplerIds
catalogDir = '/codesaver/work/transit_injection/catalogs/';
save(strcat(catalogDir,'compositeInjectionTargetList'),'keplerId');

% RMS CDPP vs. pulse duration
pulseIndexRange = 9:14;
plotRmsCdppVsPulseDuration = logical(input('Plot RMS CDPP vs. pulse duration? 1 or 0 -- '));
if(plotRmsCdppVsPulseDuration)
    figure
    loglog(pulseDurationsHours,rmsCdpp(1,:),'k--','LineWidth',1)
    hold on
    loglog(pulseDurationsHours,rmsCdpp(1,:),'r--','LineWidth',1)
    loglog(pulseDurationsHours,rmsCdpp(cdppSlope<0,:),'k--','LineWidth',1)
    loglog(pulseDurationsHours(pulseIndexRange),rmsCdpp(cdppSlope<0,pulseIndexRange),'k-','LineWidth',2)
    loglog(pulseDurationsHours,rmsCdpp(cdppSlope>=0,:),'r--','LineWidth',1)
    loglog(pulseDurationsHours(pulseIndexRange),rmsCdpp(cdppSlope>=0,pulseIndexRange),'r-','LineWidth',2)
    box on
    grid on
    xlabel('Pulse Duration [Hours]')
    ylabel('RMS CDPP [ppm]')
    title(['RMS CDPP for ',num2str(length(keplerId)),' injection targets'])
    legend([num2str(sum(cdppSlope<0)),' with CDPP slope < 0'],[num2str(sum(cdppSlope>=0)),' with CDPP slope >= 0'],'Location','Best')
    axis([1, 20, 10, 10^3])
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'pulse_duration_vs_rms_cdpp');
    print('-dpng','-r150',plotName)
end

%==========================================================================
% Get wavelet coefficients data
[keplerId0, medianWhiteningCoefficients0, whiteningCoefficients0] = get_wavelet_data('deep40');
% Match wavelet coefficients to target IDs
[TF, loc] = ismember(keplerId, keplerId0);
medianWhiteningCoefficientsTmp = medianWhiteningCoefficients0(loc,:);
whiteningCoefficients = whiteningCoefficients0(loc,:,:);

% normalize by first column (scale=1)
skip = false;
if(~skip)
    medianWhiteningCoefficients = zeros(nTargets,11);
    for iRow = 1:nTargets
        
        medianWhiteningCoefficients(iRow,:) = medianWhiteningCoefficientsTmp(iRow,:)./medianWhiteningCoefficientsTmp(iRow,1);
    end
else
    medianWhiteningCoefficients = medianWhiteningCoefficientsTmp;
end

% Plot the wavelet coefficients across time
colors = 'krgbmc';
markers = '-.';
skip = true;
if(~skip)
    for iTarget = 1:nTargets
        
        figure
        box on
        
        for iScale = 7:11
            semilogy(whiteningCoefficients(iTarget,:,iScale),[colors(mod(iScale,6)+1),'-'] )
            hold on
            
            xlabel('time [cadences]')
            ylabel('wavelet coefficient value')
            set(gca,'FontSize',12)
            set(findall(gcf,'type','text'),'FontSize',12)
            grid on
        end
        legend('Scale 1','2','3','4','5','Location','Best')
        title(['target Kepler Id ',num2str(keplerId(iTarget))])
        plotName = strcat(plotDir,'wavelet_coeffs_vs_time_',num2str(keplerId(iTarget)));
        print('-dpng','-r150',plotName)
        
    end
end %skip

% Plot the median wavelet coefficients across scales
figure
box on

for iTarget = 1:nTargets
    
    semilogy(medianWhiteningCoefficients(iTarget,:) )
    hold on
    
end
xlabel('wavelet coefficient index')
ylabel('wavelet coefficient value')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
grid on
plotName = strcat(plotDir,'wavelet_coeffs_vs_scale_all_targets');
print('-dpng','-r150',plotName)

%==========================================================================
% Look for trends in cdppSlope against *other* stellar parameters: no trends
% found

plotTrendsCdppSlope = logical(input('Plot trends of cdppSlope against other stellar parameters -- 1 or 0 --'));
if(plotTrendsCdppSlope)
    
    % cdppSlope vs. Effective temperature
    figure
    hold on
    grid on
    box on
    plot(effectiveTemp, cdppSlope, 'b*')
    % plot(effectiveTemp(exitflag==0),cdppSlope(exitflag==0),'ro')
    xlabel('Stellar Effective Temperature [K]')
    ylabel('CDPP slope')
    title('CDPP Slope vs. Stellar Effective Temperature')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'stellar_effective_temperature_vs_cdpp_slope');
    print('-dpng','-r150',plotName)
    
    % cdppSlope vs. keplerMag
    figure
    hold on
    grid on
    box on
    plot(keplerMag, cdppSlope, 'b*')
    xlabel('kepler magnitude')
    ylabel('CDPP slope')
    title('CDPP Slope vs. kepler magnitude')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'kepler_magnitude_vs_cdpp_slope');
    print('-dpng','-r150',plotName)
    
    % cdppSlope vs. log10SurfaceGravity
    figure
    hold on
    grid on
    box on
    plot(log10SurfaceGravity, cdppSlope, 'b*')
    xlabel('log10SurfaceGravity')
    ylabel('CDPP slope')
    title('CDPP Slope vs. log10SurfaceGravity')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'cdpp_slope_vs_log10SurfaceGravity');
    print('-dpng','-r150',plotName)
    
    % cdppSlope vs. log10Metallicity
    figure
    hold on
    grid on
    box on
    plot(log10Metallicity, cdppSlope, 'b*')
    xlabel('log10Metallicity')
    ylabel('CDPP slope')
    title('CDPP Slope vs. log10Metallicity')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'cdpp_slope_vs_log10Metallicity');
    print('-dpng','-r150',plotName)
    
    % cdppSlope vs. stellarRadiusInSolarRadii
    figure
    hold on
    grid on
    box on
    plot(stellarRadiusInSolarRadii, cdppSlope, 'b*')
    xlabel('stellarRadiusInSolarRadii')
    ylabel('CDPP slope')
    title('CDPP Slope vs. stellarRadiusInSolarRadii')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'cdpp_slope_vs_stellarRadiusInSolarRadii');
    print('-dpng','-r150',plotName)
    
    
    
end % plotTrendsCdppSlope


% cdppSlope histogram
plotCdppSlopeHistogram = logical(input('Plot cdppSlope histogram -- 1 or 0 --'));
if(plotCdppSlopeHistogram)
    
    figure
    hold on
    grid on
    box on
    hist(cdppSlope)
    xlabel('cdppSlope')
    ylabel('Counts')
    title('CDPP Slope')
    axis([-.6 0.4 0 40])
    legend(['Median ',num2str(median(cdppSlope),'%7.2f')],'Location','Best')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'cdppSlope_histogram');
    print('-dpng','-r150',plotName)
    
end % plotCdppSlopeHistogram

%==========================================================================
% Sufficient Statistic for detection efficiency curve
sufficientStatisticType = 'A'; %input('Sufficient Statistic for Detection Efficiency Curve: A(avg Det Eff over fixed MES range) B(avg MES over fixed Det Eff range) -- ','s');
% NOTE: For 40 stars, residual with Model A is 0.045, but it's 0.4 with Model B

switch sufficientStatisticType
    
    case 'A' % median over fixed MES range
        if(lowerMesBin < upperMesBin)
            % detectionEfficiencyStatistic = median(detectionEfficiency(lowerMesBin:upperMesBin,:))';
            detectionEfficiencyStatistic = mean(detectionEfficiency(lowerMesBin:upperMesBin,:))';
        elseif(lowerMesBin == upperMesBin)
            detectionEfficiencyStatistic = detectionEfficiency(upperMesBin,:)';
        end
        
    case 'B' % median over MES range of 25th to 75th percentile
        detectionEfficiencyStatistic = zeros(nTargets,1);
        for iTarget = 1:nTargets
            
            % Select MES range from detection efficiency in [0.25,0.75]
            mesBinIndicator = detectionEfficiency(:,iTarget) > 0.25 & detectionEfficiency(:,iTarget) < 0.75;
            detectionEfficiencyStatistic(iTarget) = median(midMesBin(mesBinIndicator));
        end
        
end

% Various stellar properties plotted against sufficient statistic for
% detection efficiency curve
plotTrendsSufficientStatistic = logical(input('Plot sufficient statistic against stellar properties? 1 or 0 -- '));
if(plotTrendsSufficientStatistic)
    
    %======================================================================
    % 1. Robust linear fit to effective temperature
    [parameters1, stats1] = robustfit(effectiveTemp, detectionEfficiencyStatistic);
    detectionEfficiencyVsEffectiveTemperatureModel = parameters1(1) + parameters1(2).*effectiveTemp;
    
    % Sufficient statistic for detection efficiency curve vs effective temperature
    figure
    hold on
    box on
    grid on
    plot(effectiveTemp,detectionEfficiencyStatistic,'k.')
    plot(effectiveTemp,detectionEfficiencyVsEffectiveTemperatureModel,'r-','LineWidth',2)
    ylabel(['Median Detection Efficiency in MES range ',num2str(midMesBin(lowerMesBin)),' to ',num2str(midMesBin(upperMesBin))])
    xlabel('Stellar Effective Temperature [K]')
    title('Detection Efficiency vs. Stellar Effective Temperature')
    legend(['Slope = ',num2str(parameters1(2),'%g'),'+/- ',num2str(stats1.se(2),'%g')],'Location','Best')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'stellar_effective_temperature_vs_detection_efficiency','-period-',periodRangeLabel);
    print('-dpng','-r150',plotName)
    
    %======================================================================
    % 2. Robust linear fit to log10SurfaceGravity
    % [parameters3, stats3] = robustfit(log10SurfaceGravity, detectionEfficiency(binIndex,:));
    [parameters3, stats3] = robustfit(log10SurfaceGravity, detectionEfficiencyStatistic);
    detectionEfficiencyVsLog10SurfaceGravityModel = parameters3(1) + parameters3(2).*log10SurfaceGravity;
    
    % Sufficient statistic for detection efficiency curve vs log10SurfaceGravity
    figure
    hold on
    box on
    grid on
    plot(log10SurfaceGravity,detectionEfficiencyStatistic,'k.')
    plot(log10SurfaceGravity,detectionEfficiencyVsLog10SurfaceGravityModel,'r-','LineWidth',2)
    ylabel('Sufficient statistic for detection efficiency curve')
    xlabel('log10 ( Surface Gravity [cm/s^2] ) ')
    legend(['Slope = ',num2str(parameters3(2),'%g'),'+/- ',num2str(stats3.se(2),'%g')],'Location','Best')
    title('Detection Efficiency vs. Surface Gravity')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'log10_surface_gravity_vs_detection_efficiency','-period-',periodRangeLabel);
    print('-dpng','-r150',plotName)
    
    %======================================================================
    % 3. Robust linear fit to log10Metallicity
    [parameters4, stats4] = robustfit(log10Metallicity, detectionEfficiencyStatistic);
    detectionEfficiencyVsLog10MetallicityModel = parameters4(1) + parameters4(2).*log10Metallicity;
    
    % Sufficient statistic for detection efficiency curve vs log10Metallicity
    figure
    hold on
    box on
    grid on
    plot(log10Metallicity,detectionEfficiencyStatistic,'k.')
    plot(log10Metallicity,detectionEfficiencyVsLog10MetallicityModel,'r-','LineWidth',2)
    ylabel('Sufficient statistic for detection efficiency curve')
    xlabel('log10 ( Metallicity [Fe/H] ) ')
    legend(['Slope = ',num2str(parameters4(2),'%g'),'+/- ',num2str(stats4.se(2),'%g')],'Location','Best')
    title('Detection Efficiency vs. Metallicity')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'log10_metallicity_vs_detection_efficiency','-period-',periodRangeLabel);
    print('-dpng','-r150',plotName)
    
    %======================================================================
    % 4. Robust linear fit to stellarRadiusInSolarRadii
    [parameters5, stats5] = robustfit(stellarRadiusInSolarRadii, detectionEfficiencyStatistic);
    detectionEfficiencyVsStellarRadiusInSolarRadiiModel = parameters5(1) + parameters5(2).*stellarRadiusInSolarRadii;
    
    % Sufficient statistic for detection efficiency curve vs stellarRadiusInSolarRadii
    figure
    hold on
    box on
    grid on
    plot(stellarRadiusInSolarRadii,detectionEfficiencyStatistic,'k.')
    plot(stellarRadiusInSolarRadii,detectionEfficiencyVsStellarRadiusInSolarRadiiModel,'r-','LineWidth',2)
    ylabel('Sufficient statistic for detection efficiency curve')
    xlabel('stellarRadiusInSolarRadii [Suns]')
    legend(['Slope = ',num2str(parameters5(2),'%g'),'+/- ',num2str(stats5.se(2),'%g')],'Location','Best')
    title('Detection Efficiency vs. Stellar Radius')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'stellar_radius_vs_detection_efficiency','-period-',periodRangeLabel);
    print('-dpng','-r150',plotName)
    
    %======================================================================
    % 5. Robust linear fit to keplerMag
    [parameters6, stats6] = robustfit(keplerMag, detectionEfficiencyStatistic);
    detectionEfficiencyVsKeplerMagModel = parameters6(1) + parameters6(2).*keplerMag;
    
    % Sufficient statistic for detection efficiency curve vs keplerMag
    figure
    hold on
    box on
    grid on
    plot(keplerMag,detectionEfficiencyStatistic,'k.')
    plot(keplerMag,detectionEfficiencyVsKeplerMagModel,'g-','LineWidth',2)
    ylabel('Sufficient statistic for detection efficiency curve')
    xlabel('keplerMag')
    legend(['Slope = ',num2str(parameters6(2),'%g'),'+/- ',num2str(stats6.se(2),'%g')],'Location','Best')
    title('Detection Efficiency vs. Kepler Magnitude')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'kepler_mag_vs_detection_efficiency','-period-',periodRangeLabel);
    print('-dpng','-r150',plotName)
    
end % plotTrendsSufficientStatistic





% Fit detection efficiency sufficient statistic against selected model
switch modelType
    case 'L'
        
        % Linear fit to cdppSlope
        [parameters, stats] = robustfit(cdppSlope, detectionEfficiencyStatistic,'logistic');
        detectionEfficiencyModel = [ones(size(keplerId)), cdppSlope]*parameters;        
        detectionEfficiencyModelRange = [ones(size(cdppSlopeRange)), cdppSlopeRange]*parameters;
        % modelLabel = 'robust_logistic_linear_cdppslope';
        % modelHeader = 'Robust (logistic) linear fit to cdppSlope';
        
    case 'Q'
        
        % Robust (logistic) Quadratic fit to cdppSlope 
        [parameters, stats] = robustfit([cdppSlope cdppSlope.^2], detectionEfficiencyStatistic,'logistic');
        detectionEfficiencyModel = [ones(size(keplerId)), cdppSlope, cdppSlope.^2]*parameters;
        detectionEfficiencyModelRange = [ones(size(cdppSlopeRange)), cdppSlopeRange, cdppSlopeRange.^2]*parameters;
        % modelLabel = 'robust_logistic_quadratic_cdppslope';
        % modelHeader = 'Robust (logistic) quadratic fit to cdppSlope';
        % Parameters
        fprintf('Quadratic Model parameters constant %7.3f, linear %7.3f, quadratic %7.3f\n',parameters(1), parameters(2), parameters(3))
       
    case 'R'
        
        % Robust (bisquare) Quadratic fit to cdppSlope
        [parameters, stats] = robustfit([cdppSlope cdppSlope.^2], detectionEfficiencyStatistic);
        detectionEfficiencyModel = [ones(size(keplerId)), cdppSlope, cdppSlope.^2]*parameters;
        detectionEfficiencyModelRange = [ones(size(cdppSlopeRange)), cdppSlopeRange, cdppSlopeRange.^2]*parameters;
        % modelLabel = 'robust_bisquare_quadratic_cdppslope';
        % modelHeader = 'Robust (bisquare) quadratic fit to cdppSlope';
        
        % Parameters
        fprintf('Quadratic Model parameters constant %7.3f, linear %7.3f, quadratic %7.3f\n',parameters(1), parameters(2), parameters(3))
        
    case 'S' 
        
        % Sigmoid model
        % Fit detectionEfficiency dependency on *negative* cdppSlope to a generalized logistic function:
        % a four-parameter model allows max to be different than 0
        % generalizedLogisticFunction = @(x) x(4) + 1./(1+exp(-x(1).*(-cdppSlope'-x(2)))).^x(3);
        % generalizedLogisticFunction = @(x) 1./( x(4) + exp( -x(1).*( -cdppSlope' - x(2) ) ) ).^x(3);
        generalizedLogisticFunction =  @(x) x(4)./(1+exp(-x(1).*(-cdppSlope-x(2)))).^x(3);
        generalizedLogisticFunction2 = @(x) x(4)./(1+exp(-x(1).*(-cdppSlopeRange-x(2)))).^x(3);
        costFunction = @(x) sum ( ( detectionEfficiencyStatistic -  generalizedLogisticFunction(x) ).^2 );
        % costFunction = @(x) sum ( abs( detectionEfficiencyStatistic -  generalizedLogisticFunction(x) ) );
        
        % Initial guess
        % x0 = [1,1,1,1];
        x0 = [10,-1,10,1]; % change to be closer to solution reached without converging
       
        
        % Fit
        [x,fvalAll,exitflagAll,output] = fminsearch(costFunction,x0);
        
        % FittedModel
        detectionEfficiencyModel = generalizedLogisticFunction([x(1),x(2),x(3),x(4)]);
        detectionEfficiencyModelRange = generalizedLogisticFunction2([x(1),x(2),x(3),x(4)]);
        
    case 'M'
        
        % Multilinear model using all 14 cdpp measurements as predictors
        [parameters, stats] = robustfit(log10(rmsCdpp), detectionEfficiencyStatistic,'ols');
        detectionEfficiencyModel = [ones(size(keplerId)), log10(rmsCdpp)]*parameters;
        
        
    case 'W'
        
        % Fit to whitening coeffs and cdppSlope
        % Both AIC and BIC say that the model #8 that is quadratic in both whitening coeff #6 and
        % cdppSlope is best
        
        % Try various models
        done = false;
        while(~done)
            
            modelNumber = 8; % input('Model number ');
            
            switch modelNumber
                case 1
                    disp('1. quadratic in cdppSlope, no WC6')
                    [parameters, stats] = robustfit([cdppSlope, cdppSlope.^2], detectionEfficiencyStatistic,'fair');
                    detectionEfficiencyModel = [ones(size(keplerId)), cdppSlope, cdppSlope.^2]*parameters;
                    
                case 2 
                     disp('2. quadratic in cdppSlope, linear in WC6')
                    [parameters, stats] = robustfit( [cdppSlope, cdppSlope.^2, log10(medianWhiteningCoefficients(:,6)./repmat(medianWhiteningCoefficients(:,1),1,1))], detectionEfficiencyStatistic,'fair');
                    detectionEfficiencyModel = [ones(size(keplerId)), cdppSlope, cdppSlope.^2, log10(medianWhiteningCoefficients(:,6)./repmat(medianWhiteningCoefficients(:,1),1,1))]*parameters;
                    
                case 3
                    disp('3. linear cdppSlope, linear in WC6')
                    [parameters, stats] = robustfit( [cdppSlope, log10(medianWhiteningCoefficients(:,6)./repmat(medianWhiteningCoefficients(:,1),1,1))], detectionEfficiencyStatistic,'fair');
                    detectionEfficiencyModel = [ones(size(keplerId)), cdppSlope, log10(medianWhiteningCoefficients(:,6)./repmat(medianWhiteningCoefficients(:,1),1,1))]*parameters;
                    
                case 4
                    disp('4. linear in WC6')
                    [parameters, stats] = robustfit( [log10(medianWhiteningCoefficients(:,6)./repmat(medianWhiteningCoefficients(:,1),1,1))], detectionEfficiencyStatistic,'fair');
                    detectionEfficiencyModel = [ones(size(keplerId)), log10(medianWhiteningCoefficients(:,6)./repmat(medianWhiteningCoefficients(:,1),1,1))]*parameters;
                    
                case 5
                    disp('5. linear in RMScdpp scaled by first column')
                    [parameters, stats] = robustfit(log10(rmsCdpp(:,2:end)./repmat(rmsCdpp(:,1),1,13)), detectionEfficiencyStatistic,'fair');
                    detectionEfficiencyModel = [ones(size(keplerId)),log10(rmsCdpp(:,2:end)./repmat(rmsCdpp(:,1),1,13))]*parameters;
                    
                case 6
                    disp('6. linear in RMScdpp scaled by first column, linear in WC6')
                    [parameters, stats] = robustfit( [log10(rmsCdpp(:,2:end)./repmat(rmsCdpp(:,1),1,13)), log10(medianWhiteningCoefficients(:,6)./repmat(medianWhiteningCoefficients(:,1),1,1))], detectionEfficiencyStatistic,'fair');
                    detectionEfficiencyModel = [ones(size(keplerId)), log10(rmsCdpp(:,2:end)./repmat(rmsCdpp(:,1),1,13)), log10(medianWhiteningCoefficients(:,6)./repmat(medianWhiteningCoefficients(:,1),1,1)) ]*parameters;

                 case 7
                    disp ('7. linear in RMScdpp scaled by first column, linear in WC6, quadratic in cdppSlope')
                    [parameters, stats] = robustfit( [cdppSlope, cdppSlope.^2,log10(rmsCdpp(:,2:end)./repmat(rmsCdpp(:,1),1,13)), log10(medianWhiteningCoefficients(:,6)./repmat(medianWhiteningCoefficients(:,1),1,1))], detectionEfficiencyStatistic,'fair');
                    detectionEfficiencyModel = [ones(size(keplerId)), cdppSlope, cdppSlope.^2, log10(rmsCdpp(:,2:end)./repmat(rmsCdpp(:,1),1,13)), log10(medianWhiteningCoefficients(:,6)./repmat(medianWhiteningCoefficients(:,1),1,1)) ]*parameters;
           
            
                 case 8 % best model
                     disp('8. quadratic in cdppSlope, quadratic in WC6')
                    [parameters, stats] = robustfit( [cdppSlope, cdppSlope.^2, log10(medianWhiteningCoefficients(:,6)./medianWhiteningCoefficients(:,1)), log10(medianWhiteningCoefficients(:,6)./medianWhiteningCoefficients(:,1)).^2], detectionEfficiencyStatistic,'fair');
                    detectionEfficiencyModel = [ones(size(keplerId)), cdppSlope, cdppSlope.^2, log10(medianWhiteningCoefficients(:,6)./medianWhiteningCoefficients(:,1)) log10(medianWhiteningCoefficients(:,6)./medianWhiteningCoefficients(:,1)).^2]*parameters;
                    
                 case 9
                     disp('9. quadratic in cdppSlope, cubic in WC6')
                    [parameters, stats] = robustfit( [cdppSlope, cdppSlope.^2, log10(medianWhiteningCoefficients(:,6)./medianWhiteningCoefficients(:,1)), log10(medianWhiteningCoefficients(:,6)./medianWhiteningCoefficients(:,1)).^2 log10(medianWhiteningCoefficients(:,6)./medianWhiteningCoefficients(:,1)).^3], detectionEfficiencyStatistic,'fair');
                    detectionEfficiencyModel = [ones(size(keplerId)), cdppSlope, cdppSlope.^2, log10(medianWhiteningCoefficients(:,6)./medianWhiteningCoefficients(:,1)) log10(medianWhiteningCoefficients(:,6)./medianWhiteningCoefficients(:,1)).^2 log10(medianWhiteningCoefficients(:,6)./medianWhiteningCoefficients(:,1)).^3]*parameters;
                    
                case 10
                    disp('10. linear in WC 2 - 6')
                    [parameters, stats] = robustfit( [log10(medianWhiteningCoefficients(:,2:6)./repmat(medianWhiteningCoefficients(:,1),1,5))], detectionEfficiencyStatistic,'fair');
                    detectionEfficiencyModel = [ones(size(keplerId)), log10(medianWhiteningCoefficients(:,2:6)./repmat(medianWhiteningCoefficients(:,1),1,5))]*parameters;
                    
                case 11
                    disp('11. quadratic in cdppSlope, linear in WC 2 - 6')
                    [parameters, stats] = robustfit( [cdppSlope, cdppSlope.^2,log10(medianWhiteningCoefficients(:,2:6)./repmat(medianWhiteningCoefficients(:,1),1,5))], detectionEfficiencyStatistic,'fair');
                    detectionEfficiencyModel = [ones(size(keplerId)), cdppSlope, cdppSlope.^2, log10(medianWhiteningCoefficients(:,2:6)./repmat(medianWhiteningCoefficients(:,1),1,5))]*parameters;

            end % case
                        
            
            % Compute residuals, AIC, BIC and print output
            modelResiduals = detectionEfficiencyStatistic - detectionEfficiencyModel;
            rmsModelResiduals = sqrt(mean(modelResiduals.^2));
            AIC = nTargets*(log(sum(modelResiduals.^2/nTargets))) + 2*(length(parameters)+1);
            BIC = nTargets*(log(sum(modelResiduals.^2/nTargets))) + log(nTargets)*(length(parameters)+1);
            fprintf('modelNumber %d, rms = %7.3f AIC = %7.3f, BIC = %7.3f\n',modelNumber,rmsModelResiduals,AIC,BIC)
            
            % Terminate the loop through models?
            done = logical(input('Done? 1 or 0 -- '));
            
        end % while
        
end % model fitting


% Model Residual and rms residuals
modelResiduals = detectionEfficiencyStatistic - detectionEfficiencyModel;
rmsModelResiduals = sqrt(mean(modelResiduals.^2));
AIC = nTargets*(log(sum(modelResiduals.^2/nTargets))) + 2*(length(parameters)+1);
BIC = nTargets*(log(sum(modelResiduals.^2/nTargets))) + log(nTargets)*(length(parameters)+1);


% Sort the residuals and print out list with associated keplerId
[MM, II] = sort(modelResiduals);
for ii = 1:nTargets
    fprintf('keplerId %d, CDPP slope %7.3f, model residual = %8.4f log mean whitening coeff 6 = %8.4f \n',double(keplerId(II(ii))),cdppSlope(II(ii)),MM(ii),log(medianWhiteningCoefficients(II(ii),6)))
end

%==========================================================================
plotModelVsCdppSlope = true;% logical(input('Plot Model vs. cdppSlope? 1 or 0 -- '));
if(plotModelVsCdppSlope)
    
    % CDPP slope vs. model residual
    figure
    hold on
    box on
    grid on
    if(modelType == 'S')
        plot(-cdppSlope,modelResiduals,'k.')
        xlabel('-CDPP Slope')
    else
        plot(cdppSlope,modelResiduals,'k*')
        xlabel('CDPP Slope')
    end
    ylabel('Model Residual')
    title([modelString,' Model'])
    legend(['RMS resid of sufficient statistic vs. model = ',num2str(rmsModelResiduals,'%7.3f')],'Location','Best')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,labelString,'_model_residual','-period-',periodRangeLabel);
    print('-dpng','-r150',plotName)
    
    % CDPP slope vs. Sufficient statistic for detection efficiency curve and model
    figure
    hold on
    box on
    grid on
    if(modelType == 'S')
        plot(-cdppSlope,detectionEfficiencyStatistic,'k.')
        plot(-cdppSlopeRange,detectionEfficiencyModelRange,'r-','LineWidth',2)
        xlabel('-CDPP Slope')
    else
        plot(cdppSlope,detectionEfficiencyStatistic,'k.')
        xlabel('CDPP slope')
    end
    if(modelType ~= 'M' && modelType ~= 'S' && modelType ~= 'W')
        plot(cdppSlopeRange,detectionEfficiencyModelRange,'r-','LineWidth',2)
    end
    ylabel('Sufficient statistic for detection efficiency curve')
    title(['Detection Efficiency: ',modelString,' Model'])
    legend(['RMS resid of sufficient statistic vs. model = ',num2str(rmsModelResiduals,'%7.3f')],'Location','Best')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,labelString,'_cdpp_slope_vs_detection_efficiency','-period-',periodRangeLabel);
    print('-dpng','-r150',plotName)
    
end % plotModelVsCdppSlope


% Sufficient statistic for detection efficiency curve vs. model residual: need to understand why
% there is linear correlation
plotStatisticVsModel = logical(input('Plot detectionEfficiencyStatistic vs. Model? 1 or 0 -- '));
if(plotStatisticVsModel)
    [parameters1, stats1] = robustfit(detectionEfficiencyStatistic, modelResiduals);
    detectionEfficiencyStatisticVsResidualModel = parameters1(1) + parameters1(2).*detectionEfficiencyStatistic;
    figure
    hold on
    box on
    grid on
    plot(detectionEfficiencyStatistic,detectionEfficiencyStatisticVsResidualModel,'r-','LineWidth',2)
    plot(detectionEfficiencyStatistic,modelResiduals,'b.')
    xlabel('Sufficient statistic for detection efficiency curve')
    ylabel('Model Residual')
    title([modelString,' Model'])
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,labelString,'_model_residual_vs_detection_efficiency','-period-',periodRangeLabel);
    legend('Det. Eff. Sufficient Statistic vs. Model Residual: linear fit',['RMS Model Residual = ',num2str(rmsModelResiduals,'%7.3f')],'Location','Best')
    print('-dpng','-r150',plotName)
    
    % Sufficient statistic for detection efficiency curve vs. model detection efficiency
    figure
    hold on
    box on
    grid on
    plot(detectionEfficiencyStatistic,detectionEfficiencyModel,'r*')
    plot(0:0.01:0.7,0:0.01:0.7,'k-')
    xlabel('Sufficient statistic for detection efficiency curve')
    ylabel('Model Detection Efficiency')
    title([modelString,' Model'])
    legend(['RMS detection efficiency residual = ',num2str(rmsModelResiduals,'%7.3f')],'Location','Best')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,labelString,'_model_vs_detection_efficiency','-period-',periodRangeLabel);
    print('-dpng','-r150',plotName)
end


% Plot sufficient statistic vs. RA,DEC
% Show that low values are scattered over the
% focal plane, and not concentrated in any locations.
figure
box on
grid on
hold on
% Gray background
plot(RAall(RAall>0),DECall(RAall>0),'.','color',[0.5,0.5,0.5])
hold on
% detection efficiency statistic
scatter(RA,DEC,15,detectionEfficiencyStatistic,'filled')
xlabel('RA [degrees]')
ylabel('DEC [degrees]')
title(['Detection efficiency statistic vs focal plane location for ',num2str(nTargets),' Kepler DR25 targets'])
t = colorbar('peer',gca);
colormap('Jet')
set(get(t,'ylabel'),'String', 'detection efficiency statistic');
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
plotName = strcat(plotDir,'detection_efficiency_statistic_vs_position');
print('-dpng','-r150',plotName)





%==========================================================================
% Linear fits of the CDPP slope model *residual* to various stellar properties other than CDPP
% slope show no evidence of correlation.

makeResidPlots = logical(input('Plot model residual vs. stellar properties 1(yes) or 0(no) -- '));
if(makeResidPlots)
    
    %======================================================================
    % 1. Robust linear fit of model residuals to effective temperature
    [parameters1, stats1] = robustfit(effectiveTemp, modelResiduals);
    detectionEfficiencyVsEffectiveTemperatureModel = parameters1(1) + parameters1(2).*effectiveTemp;
    
    
    % Sufficient statistic for detection efficiency curve vs effective temperature
    figure
    hold on
    box on
    grid on
    plot(effectiveTemp,modelResiduals,'k.')
    plot(effectiveTemp,detectionEfficiencyVsEffectiveTemperatureModel,'r-','LineWidth',2)
    % ylabel(['Median Detection Efficiency in MES range ',num2str(midMesBin(lowerMesBin)),' to ',num2str(midMesBin(upperMesBin))])
    ylabel('Model Residual')
    xlabel('Stellar Effective Temperature [K]')
    title('Detection Efficiency Sufficient Statistic: Model Residual vs. Stellar Effective Temperature')
    legend(['Slope = ',num2str(parameters1(2),'%g'),'+/- ',num2str(stats1.se(2),'%g')],'Location','Best')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'stellar_effective_temperature_vs_detection_efficiency_model_residual','-period-',periodRangeLabel);
    print('-dpng','-r150',plotName)
    
    %======================================================================
    % 2. Robust linear fit  of model residuals to log10SurfaceGravity
    [parameters3, stats3] = robustfit(log10SurfaceGravity, modelResiduals);
    detectionEfficiencyVsLog10SurfaceGravityModel = parameters3(1) + parameters3(2).*log10SurfaceGravity;
    
    % Sufficient statistic for detection efficiency curve vs log10SurfaceGravity
    figure
    hold on
    box on
    grid on
    plot(log10SurfaceGravity,modelResiduals,'k.')
    plot(log10SurfaceGravity,detectionEfficiencyVsLog10SurfaceGravityModel,'r-','LineWidth',2)
    ylabel('Model Residual')
    xlabel('log10 ( Surface Gravity [cm/s^2] ) ')
    legend(['Slope = ',num2str(parameters3(2),'%g'),'+/- ',num2str(stats3.se(2),'%g')],'Location','Best')
    title('Detection Efficiency Sufficient Statistic: Model Residual vs. Surface Gravity')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'log10_surface_gravity_vs_detection_efficiency_model_residual','-period-',periodRangeLabel);
    print('-dpng','-r150',plotName)
    
    %======================================================================
    % 3. Robust linear fit  of model residuals to log10Metallicity
    [parameters4, stats4] = robustfit(log10Metallicity, modelResiduals);
    detectionEfficiencyVsLog10MetallicityModel = parameters4(1) + parameters4(2).*log10Metallicity;
    
    % Sufficient statistic for detection efficiency curve vs log10Metallicity
    figure
    hold on
    box on
    grid on
    plot(log10Metallicity,modelResiduals,'k.')
    plot(log10Metallicity,detectionEfficiencyVsLog10MetallicityModel,'r-','LineWidth',2)
    ylabel('Model Residual')
    xlabel('log10 ( Metallicity [Fe/H] ) ')
    legend(['Slope = ',num2str(parameters4(2),'%g'),'+/- ',num2str(stats4.se(2),'%g')],'Location','Best')
    title('Detection Efficiency Sufficient Statistic: Model Residual vs. Metallicity')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'log10_metallicity_vs_detection_efficiency_model_residual','-period-',periodRangeLabel);
    print('-dpng','-r150',plotName)
    
    %======================================================================
    % 4. Robust linear fit  of model residuals to stellarRadiusInSolarRadii
    [parameters5, stats5] = robustfit(stellarRadiusInSolarRadii, modelResiduals);
    detectionEfficiencyVsStellarRadiusInSolarRadiiModel = parameters5(1) + parameters5(2).*stellarRadiusInSolarRadii;
    
    % Sufficient statistic for detection efficiency curve vs stellarRadiusInSolarRadii
    figure
    hold on
    box on
    grid on
    plot(stellarRadiusInSolarRadii,modelResiduals,'k.')
    plot(stellarRadiusInSolarRadii,detectionEfficiencyVsStellarRadiusInSolarRadiiModel,'r-','LineWidth',2)
    ylabel('Model Residual')
    xlabel('stellarRadiusInSolarRadii [Suns]')
    legend(['Slope = ',num2str(parameters5(2),'%g'),'+/- ',num2str(stats5.se(2),'%g')],'Location','Best')
    title('Detection Efficiency Sufficient Statistic: Model Residual vs. Stellar Radius')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'stellar_radius_vs_detection_efficiency_model_residual','-period-',periodRangeLabel);
    print('-dpng','-r150',plotName)
    
    %======================================================================
    % 5. Robust linear fit  of model residuals to keplerMag
    [parameters6, stats6] = robustfit(keplerMag, modelResiduals);
    detectionEfficiencyVsKeplerMagModel = parameters6(1) + parameters6(2).*keplerMag;
    
    % Sufficient statistic for detection efficiency curve vs keplerMag
    figure
    hold on
    box on
    grid on
    plot(keplerMag,modelResiduals,'k.')
    plot(keplerMag,detectionEfficiencyVsKeplerMagModel,'g-','LineWidth',2)
    ylabel('Model Residual')
    xlabel('keplerMag')
    legend(['Slope = ',num2str(parameters6(2),'%g'),'+/- ',num2str(stats6.se(2),'%g')],'Location','Best')
    title('Detection Efficiency Sufficient Statistic: Model Residual vs. Kepler Magnitude')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'kepler_mag_vs_detection_efficiency_model_residual','-period-',periodRangeLabel);
    print('-dpng','-r150',plotName)
    
end % makeResidPlots


% Plot model residual vs. wavelet coefficient
plotModelResidVsWaveletCoeff = logical(input('Plot model residual vs. wavelet coeff 1(yes) or 0(no) -- '));
if(plotModelResidVsWaveletCoeff)
    
    % Sufficient statistic for detection efficiency curve vs keplerMag
    figure
    semilogy(modelResiduals,medianWhiteningCoefficients(:,6)./medianWhiteningCoefficients(:,1),'r.','LineWidth',2)
    xlabel('Model Residual')
    ylabel('whitening coeff 6 scaled by whitening coeff 1')
    hold on
    box on
    grid on
    % legend(['Slope = ',num2str(parameters6(2),'%g'),'+/- ',num2str(stats6.se(2),'%g')],'Location','Best')
    title('Detection Efficiency Sufficient Statistic: Model Residual vs. wavelet coefficient')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'whitening_coefficient_vs_detection_efficiency_model_residual','-period-',periodRangeLabel);
    print('-dpng','-r150',plotName)
    
    % return
    
    % Select targets with large residuals and plot their detection
    % efficiency curves
    % idx = abs(modelResiduals) > 0.05;
    idx = log10(medianWhiteningCoefficients(:,6)) < -2;
    
    keplerIdList = keplerId(idx);
    indsAll = 1:length(keplerId);
    inds = indsAll(idx);
    inds1 = setdiff(indsAll,inds);
    
    figure
    hold on
    grid on
    box on
    xlabel('MES')
    ylabel('Detection Efficiency')
    title('Detection Efficiency for outliers')
    
    % Plot dummy points to be able to set legend.
    plot(-1,-1,'k.')
    plot(-1,-1,'r.')
    
    % Small WC6/WC1
    for iTarget = inds
        plot(midMesBin,detectionEfficiency(:,iTarget),'k-')
    end
    
    % Large WC6/WC1
    for iTarget = inds1
        plot(midMesBin,detectionEfficiency(:,iTarget),'r-')
    end
    
    legend('log(WC6/WC1) < -2','log(WC6/WC1) >= -2','Location','SouthEast')
    axis([0,25,0,1])
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(plotDir,'det_eff_vs_whitening_coefficient_ratio');
    print('-dpng','-r150',plotName)
    
end

% !!!!! To pass to synthesize_detection_efficiency_curves.m
transposeDetectionEfficiency = logical(input('Transpose detection Efficiency if going on to run synthesize_detection_efficiency_curves -- 1 or 0? -- '));
if(transposeDetectionEfficiency)
    detectionEfficiency = detectionEfficiency';
end







