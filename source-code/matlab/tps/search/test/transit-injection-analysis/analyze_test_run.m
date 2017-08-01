% analyze_test_run.m
% periodDays > 150, planetRadiusInearthRadii > 3, impactParameter < 0.3
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

% this code is in
% /path/to/matlab/tps/search/test/transit-injection-analysis/

clear
close all

% Constants
cadencesPerDay = 48.9390982304706;

%==========================================================================
% Load injection results
disp('Loading injection results ...')

% Local runs from Dec 10 & 11
% Local run 500 injections on KIC 3114789
% topDir = '/codesaver/work/transit_injection/test/KSOC-4930_10Dec2015T185402/';
% Local run 500 injections on KIC 9898170
% topDir = '/codesaver/work/transit_injection/test/KSOC-4930_11Dec2015T124654/';
% outputStructFile = strcat(topDir,'tps-injection-results-struct-500-injections.mat');
% tpsInjectionStruct = injectionOutputStruct;

% KSOC-4964-2 run, like KSOC-4964 but with tps spsd detector OFF
% topDir = '/path/to/transitInjections/KSOC-4964/testRun_2_with_2_G_stars/tps-matlab-2015344/';
% outputStructFile = strcat(topDir,'tps-injection-struct.mat');
% load(outputStructFile)

% Local run from Dec 22 with 20 injections
% topDir = 'topDir = '/codesaver/work/transit_injection/test/KSOC-4930_22Dec2015T152705/';
topDir = '/codesaver/work/transit_injection/test/KSOC-4930_22Dec2015T175424/';
outputStructFile = strcat(topDir,'tps-injection-results-struct-20-injections.mat');
load(outputStructFile);
tpsInjectionStruct = injectionOutputStruct;

% Nececessary fields from tpsInjectionStruct
chiSquare2 = tpsInjectionStruct.chiSquare2;                 % veto threshold = 7
robustStatistic = tpsInjectionStruct.robustStatistic;       % veto threshold = 7
chiSquareGof = tpsInjectionStruct.chiSquareGof;             % veto threshold = 6.8
chiSquareDof2 = tpsInjectionStruct.chiSquareDof2;
chiSquareGofDof = tpsInjectionStruct.chiSquareGofDof;
periodDays = tpsInjectionStruct.periodDays;
% thresholdForDesiredPfa field is all -1's, so bootstrapOkay is always true
% in fold_statistics_and_apply_vetores.m
thresholdForDesiredPfa = tpsInjectionStruct.thresholdForDesiredPfa;
% Get necessary information from the tpsInjectionStruct
impactParameter = tpsInjectionStruct.impactParameter;
injectedPeriodDays = tpsInjectionStruct.injectedPeriodDays;
planetRadiusInEarthRadii = tpsInjectionStruct.planetRadiusInEarthRadii;
isPlanetACandidate = logical(tpsInjectionStruct.isPlanetACandidate);
fitSinglePulse = tpsInjectionStruct.fitSinglePulse;
injectedEpochKjd = tpsInjectionStruct.injectedEpochKjd;
numSesInMes = tpsInjectionStruct.numSesInMes;
injectedDepthPpm = tpsInjectionStruct.injectedDepthPpm;
epochKjd = tpsInjectionStruct.epochKjd;
injectedDurationInHours = tpsInjectionStruct.injectedDurationInHours;
trialTransitPulseInHours = tpsInjectionStruct.trialTransitPulseInHours;
transitModelMatch = tpsInjectionStruct.transitModelMatch;
% maxMes is degraded from true MES due to coarseness of period grid, transit duration grid
% and shape mismatch
maxMes = tpsInjectionStruct.maxMes;
maxSesInMes = tpsInjectionStruct.maxSesInMes;
maxSesMesRatio = maxSesInMes./maxMes;
fittedDepthPpm = 1.e6*tpsInjectionStruct.fittedDepth;
fittedDepthChiPpm = 1.e6*tpsInjectionStruct.fittedDepthChi;
fittedDepth = tpsInjectionStruct.fittedDepth;
fittedDepthChi = tpsInjectionStruct.fittedDepthChi;

% Epoch match
epochMatchIndicator = abs(tpsInjectionStruct.injectedEpochKjd - tpsInjectionStruct.epochKjd) < tpsInjectionStruct.injectedDurationInHours / 2 / 24 ;

% Expected MES -- see Shawn's notes
% This is the best estimate of MES, correcting maxMes for coarseness of period and
% transit duration grids, whitener, and transit shape mismatch.
% !!!!! should we use normSum000 instead ?????
% What about the formula used in fold_time_series.c, which is 
% maximumMultipleEventStatistic = corrsum/sqrt(normsum)
expectedMes = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum111;
expectedMes001 = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum001;
expectedMes011 = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum011;
expectedMes010 = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum010;
expectedMes100 = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum100;
expectedMes101 = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum101;
expectedMes111 = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum111;
expectedMes110 = injectedDepthPpm .* 1e-6 .* tpsInjectionStruct.normSum110;


%==========================================================================
% Get list of .mat files with intermediate results (~ 7 MB each) saved by injection run
disp('Getting list of intermediate data and png file names ...')
dirStruct = dir(strcat(topDir,'*data-for-injection*.mat'));
nFiles = size(dirStruct,1);

% Get injection index corresponding to each mat file
fileNames = cell(nFiles,1);
fullFileNames = cell(nFiles,1);
injIndex = zeros(nFiles,1);
for iFile = 1:nFiles
    fileNames{iFile} = dirStruct(iFile).name;
    
    % Get the injection number corresponding to this file
    place1Ind = find(fileNames{iFile}=='-');
    place2Ind = find(fileNames{iFile}=='.');
    injIndex(iFile) = str2double(fileNames{iFile}(place1Ind+1:place2Ind-1));
    
    % Make the full filename
    fullFileNames{iFile} = strcat(topDir,fileNames{iFile});
    
end

% Sort filenames in order of injection number
[sortedInjIndex, II] = sort(injIndex);
sortedFullFileNames = fullFileNames(II);

% .png filenames, also sorted in order of injection number
sortedPngFiles = strrep(sortedFullFileNames,'.mat','.png');


%==========================================================================
% Show whitened flux plots for black-hole injections
blackHoleInds = find(fittedDepth > 0 & ~isPlanetACandidate);
goodInds = find(fittedDepth > 0 & isPlanetACandidate);
badInds = find(~fitSinglePulse & numSesInMes == 3 & ~isPlanetACandidate);
% badInds = find(fittedDepth < 0);
% Choose list of injections for plot
% injectionIndsForPlot = goodInds;
% injectionIndsForPlot = blackHoleInds;
injectionIndsForPlot = badInds;


% Plot whitened and unwhitened flux against deemphasis weights 
count = 0;
nInjectionsInList = length(injectionIndsForPlot);
for injectionInd = injectionIndsForPlot
    
    % reconstruct the whitenedFlux & deemphasisWeights plots from the
    % intermediate data file
    skip = false;
    if(~skip)
        
        % Clear figure 
        if(exist('figH','var'))
            clf(figH)
        end
        
        % Load the intermediate data file
        load(sortedFullFileNames{injectionInd});
        
        % cadencesAll
        % inTransitCadenceIndicator
        
        % lightCurve
        % fluxValue
        % whitenedFlux
        % deemphasisWeights
        % iInjection
        
        % From save_tps_intermediate_data.m
        % But there is a problem using this code
        % to extract the needed data from the data saved wwith saveAll = true
        skip = true;
        if(~skip)
            
            % Get the waveletObject
            waveletObject = tpsResultsCopy.waveletObject;
            
            % Get whitened flux
            addpath('/path/to/matlab/common/mfiles/wavelet/');
            whitenedFlux  = apply_whitening_to_time_series( waveletObject );
            
            % Get model light curve
            tpsTargets = get(tpsScienceObjectInjCopy,'tpsTargets');
            
            % Model of the transit train, base on the ephemeris
            lightCurve = tpsTargets.diagnostics.addedPlanetStruct.lightCurve;
            
            % Quarter-stitched light curve (?)
            fluxValue = tpsTargets.fluxValue;
            tpsDetrendedFlux = tpsTargets.tpsDetrendedFlux;
            
            % Get in-transit cadences
            inTransitCadenceIndicator = lightCurve<0;
            cadencesAll = 1:length(inTransitCadenceIndicator);
            
            % Get deemphasis weights
            deemphasisWeight = tpsResultsCopy.deemphasisWeight;
        end % skip
        
        % Plot whitened & unwhitened light curve against deemphasis weights
        figH = figure(100);
        
        % Whitened flux
        ax1 = subplot(2,1,1);
        hold on
        grid on
        box on
        plot(cadencesAll./cadencesPerDay, whitenedFlux,'b')
        plot(cadencesAll./cadencesPerDay,10*deemphasisWeight,'r')
        
        % Highlight deemphasisWeights for in-transit times
        plot(cadencesAll(inTransitCadenceIndicator)./cadencesPerDay,10*deemphasisWeight(inTransitCadenceIndicator),'g*')
        xlabel('Time [days]')
        ylabel('Whitened Flux')
        title(['Whitened Flux for Injection #',num2str(iInjection)])
        legend('whitenedFlux','10 x deempWeights','10 x *in-transit* deemphWeights','Location','SouthEast')
       
        
        % Unwhitened Flux
        ax2 = subplot(2,1,2);
        hold on
        grid on
        box on
        plot(cadencesAll(inTransitCadenceIndicator)./cadencesPerDay, fluxValue(inTransitCadenceIndicator),'m.')
        plot(cadencesAll./cadencesPerDay, tpsDetrendedFlux,'k')
        plot(cadencesAll./cadencesPerDay,0.01*deemphasisWeight,'r')
        
        % Highlight deemphasisWeights for in-transit times
        plot(cadencesAll(inTransitCadenceIndicator)./cadencesPerDay,0.01*deemphasisWeight(inTransitCadenceIndicator),'g*')
        set(gcf,'units','normalized','outerposition',[0 0 1 1])
        xlabel('Time [days]')
        ylabel('Flux')
        title(['Flux for Injection #',num2str(iInjection)])
        legend('unwhitenedFlux','tpsDetrendedFlux','0.01 x deemphWeights','0.01 x *in-transit* deemphWeights','Location','SouthEast')
       
        % Make plot full-screen
        % set(gcf,'units','normalized','outerposition',[0 0 1 1])
        set(gca,'FontSize',12)
        set(findall(gcf,'type','text'),'FontSize',12)
        
        % Link axes in subplots
        linkaxes([ax1,ax2],'x');
        
        
        % Print out important parameters
        fprintf('\n\nThere are %d injections to display\n',length(injectionIndsForPlot))
        fprintf('Injection index %d:\n',injectionInd)
        fprintf('\n\ninjected depth = %7.1f, fittedDepth = %7.1f, fittedDepthWhenSearchedAtInjectedEphemerisPpm = %7.1f \n', ...
            injectedDepthPpm(injectionInd), fittedDepthPpm(injectionInd), ...
            1.e6*tpsInjectionStruct.fittedDepthWhenSearchedWithInjectedPeriodAndDuration(injectionInd))
        fprintf('fitSinglePulse = %d, fitSinglePulseWhenSearchedAtInjectedEphemeris = %d\n', ...
            tpsInjectionStruct.fitSinglePulse(injectionInd), tpsInjectionStruct.fitSinglePulseWhenSearchedWithInjectedPeriodAndDuration(injectionInd))
        fprintf('estimatedMesWhenSearchedAtInjectedEphemeris = %7.1f\n', ...
            tpsInjectionStruct.estimatedMesWhenSearchedWithInjectedPeriodAndDuration(injectionInd))
        fprintf('robustStatistic = %7.1f, robustStatisticWhenSearchedAtInjectedEphemeris = %7.1f\n', ...
            tpsInjectionStruct.robustStatistic(injectionInd), tpsInjectionStruct.robustStatisticWhenSearchedWithInjectedPeriodAndDuration(injectionInd))
        fprintf('maxMes = %7.1f, maxMesWhenSearchedAtInjectedEphemeris = %7.1f\n', ...
            tpsInjectionStruct.maxMes(injectionInd),tpsInjectionStruct.maxMesWhenSearchedWithInjectedPeriodAndDuration(injectionInd))
        fprintf('numSesInMes = %d, numSesInMesWhenSearchedAtInjectedEphemeris = %d\n', ...
            numSesInMes(injectionInd), tpsInjectionStruct.numSesInMesWhenSearchedWithInjectedPeriodAndDuration(injectionInd))
        fprintf('robustfitFailWhenSearchedAtInjectedEphemeris = %d\n', ...
            tpsInjectionStruct.robustfitFailWhenSearchedWithInjectedPeriodAndDuration(injectionInd))
        fprintf('injectedPeriod = %7.1f days fittedPeriod = %7.1f days\n', ...
            tpsInjectionStruct.injectedPeriodDays(injectionInd),tpsInjectionStruct.periodDays(injectionInd))
        fprintf('injectedEpochKjd = %7.1f days epochKjd = %7.1f days\n', ...
            tpsInjectionStruct.injectedEpochKjd(injectionInd),tpsInjectionStruct.epochKjd(injectionInd))
        
      
        % Prepare for next plot
        clear cadencesAll
        clear inTransitCadenceIndicator
        clear lightCurve
        clear whitenedFlux
        clear fluxValue
        clear iInjection
        clear deemphasisWeight
        clear tpsDetrendedFlux
        
        % Wait for keyboard input
        pause
        
    end % skip
    
        
end


return

%==========================================================================
% Depth ratio vs. deltaEpoch
inds = [goodInds(:);blackHoleInds(:)];
depthRatio = 1.e6*tpsInjectionStruct.fittedDepth(inds)./tpsInjectionStruct.injectedDepthPpm(inds);
deltaEpoch =  tpsInjectionStruct.epochKjd(inds) - tpsInjectionStruct.injectedEpochKjd(inds);

figure
hold on
box on
grid on
% semilogy(deltaEpoch,depthRatio,'r.')
plot(deltaEpoch,depthRatio,'r.')
xlabel('fittedEpochKjd minus injectedEpochKjd [days]')
ylabel('fittedDepth./injectedDepth')
set(gca,'FontSize',12)
set(findall(gcf,'type','text'),'FontSize',12)
title('Epoch mismatch causes missed signal')
plotName = strcat(topDir,'epoch_mismatch');
legend([num2str(length(inds)),' of ',num2str(length(fittedDepth)),' injections had fittedDepth > 0'],'Location','Best')
print('-djpeg','-r150',plotName)






