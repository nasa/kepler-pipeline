%*****************************************************************************************************
% classdef pdcStellarPreserveClass
%
% Class to perform a PDC stellar preservation study. To be run with the wrapper function pdc_stellar_preservation_test.
%
%*****************************************************************************************************
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

classdef pdcStellarPreserveClass < handle

    properties
        debugPlotSignalInjection = false;
        debugRun = false; % Inject extra signal in injected signal that is forced in.
        nTargetsToPlot = 30;
        numWhitenIterations = 0;
        smoothFactor = 10; % SGFilter smooth factor (i.e. smoothWIndow = nDatums / smoothFactor);
        scaleInjectedSignalsBy = 'fluxStd' % ['medianFlux' 'stellarVariability' 'fluxStd' 'fluxStdNoPolyFit'}
        stellarVariabilityCutoff = 1.0; % Less than the MAP default
        stellarOscillatorModifierRange = [0 2]; % Distribution of the shift parameters in stellar oscillator injections 
        useOutputFluxFromOriginalRunToScaleInjectedSignals = true;
    end

    % amplitude study parameters
    properties (GetAccess = 'public', SetAccess = 'private')
        % These values are for fluxStd scaling
        ampStudy = struct('nAmplitudes',    15, ... ; % Number of amplitude values to inject (odd number recommened so signalAmplitude is at mid-point)
                          'minAmplitude', 1e-3, ...; % Minumum sine wave amplitude to use
                          'maxAmplitude', 1e2, ...; % Maximum sine wave amplitude to use
                          'selectedTargets', [], ...;
                          'amplitudes', []);
        % These values are for medianFlux scaling
       %ampStudy = struct('nAmplitudes',    15, ... ; % Number of amplitude values to inject (odd number recommened so signalAmplitude is at mid-point)
       %                  'minAmplitude', 5e-5, ...; % Minumum sine wave amplitude to use
       %                  'maxAmplitude', 5e-2, ...; % Maximum sine wave amplitude to use
       %                  'selectedTargets', [], ...;
       %                  'amplitudes', []);
    end

    % Injected signal data public set
    properties (GetAccess = 'public', SetAccess = 'public')
        signalType; % Type of injected signal ['sineWave', 'WGN', 'halfSineHalfWGN 'none']
        signalAmplitude; % Signal amplitude a fraction of median flux level NOT USED FOR AMPLITUDE STUDY!!!
    end

    % Injected signal data private set
    properties (GetAccess = 'public', SetAccess = 'private')
        halfAlreadySelected = []; 
        allSelected = []
        targetsInjectedWithSineWaves;
        targetsInjectedWithStellarOscillators;
        targetsInjectedWithSoho;
        targetsInjectedWithWGN;
        lambda; % wavelengths of the injected sine waves in days
        stellarSignal; % The inserted stellar signals
        scaledStellarSignal; % The inserted stellar signals scaled by Flux Fraction and crowding metric 
        stellarSignalType; % The type of injected signal for each target
        stellarSignalDiff; % Difference of stellarSignal and lightCurveDiff
        stellarSignalDiffStd = []; % STD of stellarSignalDiff
        deltaSignalStd = []; % Change in STD of the signal (STD Gain)
        atFreqCorruptionAmount = []; % Corruption of the amplitude at the injected frequency (only for Sine Waves
    end

    properties (GetAccess = 'public', SetAccess = 'private')
        nTargets;
        nCadences;
        medianAmplitude; % of input light curves
        diagnosticInputStruct;
        inputsStructOriginal;
        outputsStructOriginal;
        inputsStructInjected;
        outputsStructInjected;
        cadencesPerTwoPiRads;
        lightCurveDiff; % Difference between original and injected PDC output light curves 
        periodogramLength; % [integer] length of periodograms 
        periodogramFrequency; %
        compiledPeriodogram; % Compilation of all the target periodograms
        fullCorruptionLevel; % Median amplitude for full 100% corruption of signals (whiten spectrum) 
        outputsGaps = [];    % logical(nCadences, nTargets) The gaps and filled indices form the PDC output
    end

%*************************************************************************************************************
    methods
        %*****************************************************************************************************
        % Constructor
        function obj = pdcStellarPreserveClass(inputsStruct)

            %************
            % Set up inputsStruct

            % If this is the new multi-channel inputstruct the collect all the targets into one targetDataStruct
            if (isfield(inputsStruct, 'channelDataStruct'))
               %inputsStruct = obj.combine_targetDataStructs(inputsStruct);
                inputsStruct = pdcInputClass.process_channelDataStruct(inputsStruct);
               %inputsStruct = rmfield(inputsStruct, 'channelDataStruct');
            end

            obj.inputsStructOriginal = inputsStruct;

            obj.nTargets  = length(obj.inputsStructOriginal.targetDataStruct);
            obj.nCadences = length(obj.inputsStructOriginal.targetDataStruct(1).values);

            % Initialize with all zeros. Each set of amplitudes merges with this list.
            % Only one sine wave for target (for now)
            obj.lambda = zeros(obj.nTargets,1);

            %************
            % Set up pdcDiagnosticStruct for properties that do not change between runs
            obj.diagnosticInputStruct = struct('pdcDiagnosticStruct','','mapDiagnosticStruct','','spsdDiagnosticStruct','');
            obj.diagnosticInputStruct = pdc_populate_diagnosticinputstruct(obj.diagnosticInputStruct, obj.nTargets );
            obj.diagnosticInputStruct.mapDiagnosticStruct.doFigures = false;
            obj.diagnosticInputStruct.mapDiagnosticStruct.doSaveResultsStruct = false;

            % To get the length of the periodograms
            cadenceTimes = [obj.inputsStructOriginal.cadenceTimes.midTimestamps];
            obj.periodogramLength = 2^(ceil(log(obj.nCadences) / log(2))) / 2 + 1;

            medianCadenceLength = median(diff(cadenceTimes(cadenceTimes>0)));
            obj.cadencesPerTwoPiRads = 1 / (2 * pi * medianCadenceLength);

        end

        %*****************************************************************************************************
        % Run PDC on the original data
        function run_original_pdc (obj)

            obj.diagnosticInputStruct.mapDiagnosticStruct.runLabel = 'Original';
            obj.inputsStructOriginal.mapConfigurationStruct.useBasisVectorsAndPriorsFromBlob = false;
            obj.outputsStructOriginal = pdc_matlab_controller(obj.inputsStructOriginal, obj.diagnosticInputStruct);
            outputsStructOriginal = obj.outputsStructOriginal;
            save('outputsStructOriginal', 'outputsStructOriginal');
            clear outputsStructOriginal;

        end

        %*****************************************************************************************************
        % Run PDC on the injected signal data
        function run_injected_pdc (obj)

            obj.diagnosticInputStruct.mapDiagnosticStruct.runLabel = 'Injected';
            % Recall basis vectors and priors from original run
            obj.inputsStructInjected.cbvBlobs.blobFilenames{1} = 'cbv_blob.mat';
            obj.inputsStructInjected.mapConfigurationStruct.useBasisVectorsAndPriorsFromBlob = true;
            obj.outputsStructInjected = pdc_matlab_controller(obj.inputsStructInjected, obj.diagnosticInputStruct);
            outputsStructInjected = obj.outputsStructInjected;
            save('outputsStructInjected', 'outputsStructInjected');
            clear outputsStructInjected;

        end

        %*****************************************************************************************************
        % Inject Signals
        function [] = inject_signals (obj)

            display('Injecting signals into light curves...');

            % stellarSignal can be injected with different types of signals in
            % different functions
            obj.stellarSignal = zeros(obj.nCadences, obj.nTargets);

            % First copy over the original
            obj.inputsStructInjected = obj.inputsStructOriginal;

            obj.targetsInjectedWithSineWaves            = false (obj.nTargets,1);
            obj.targetsInjectedWithStellarOscillators   = false (obj.nTargets,1);
            obj.targetsInjectedWithSoho                 = false (obj.nTargets,1);
            obj.targetsInjectedWithWGN                  = false (obj.nTargets,1);
            % Then inject the signals
            switch obj.signalType
            
            case ('simulateStellarOscillator')

                injectionType = 'all';
                selectedTargets = obj.select_targets (injectionType);
                obj.inject_simulated_stellar_oscillator (selectedTargets, obj.signalAmplitude);

            case ('sineWave')

                injectionType = 'all';
                selectedTargets = obj.select_targets (injectionType);
                obj.inject_sine_waves (selectedTargets, obj.signalAmplitude);

            case ('quietSineWave')

                injectionType = 'quiet';
                selectedTargets = obj.select_targets (injectionType);
                obj.inject_sine_waves (selectedTargets, obj.signalAmplitude);

            case ('halfSineWave')

                injectionType = 'half';
                selectedTargets = obj.select_targets (injectionType);
                obj.inject_sine_waves (selectedTargets, obj.signalAmplitude);

            case ('quarterSineWave')

                injectionType = 'quarter';
                selectedTargets = obj.select_targets (injectionType);
                obj.inject_sine_waves (selectedTargets, obj.signalAmplitude);

            case ('WGN')

                obj.inject_WGN ('all');

            case ('halfWGN')

                obj.inject_WGN ('half');

            case ('quarterWGN')

                obj.inject_WGN ('quarter');

            case ('halfSineHalfWGN')

                injectionType = 'half';
                selectedTargets = obj.select_targets (injectionType);
                obj.inject_sine_waves (selectedTargets, obj.signalAmplitude);

                obj.inject_WGN ('half');

            case ('simulatedStellarAmplitudeStudy')
                % This is looking at the signal degredation as a function of amplitude for Simuklated Stellar Oscillators

                obj.inject_amplitude_study ('simulatedStellarAmplitudeStudy');

            case ('sineAmplitudeStudy')
                % This is looking at the signal degredation as a function of amplitude for Sine Waves

                obj.inject_amplitude_study ('sineAmplitudeStudy');

            case ('quietSineAmplitudeStudy')
                % This is looking at the signal degredation as a function of amplitude for Sine Waves only injected into quiet targets

                obj.inject_amplitude_study ('quietSineAmplitudeStudy');

            case ('SOHO')

                obj.inject_soho_data(obj.signalAmplitude);

            case ('none')
                display('INJECT_SIGNALS: No signals injected!');

            otherwise
                error('INJECT_SIGNALS: Unknown stellar signal type');
            end

            %******************
            % Add injected signals to light curves

            gaps = [obj.inputsStructOriginal.targetDataStruct.gapIndicators];
            inputFlux = [obj.inputsStructOriginal.targetDataStruct.values];
            inputFlux(gaps) = NaN;
            obj.medianAmplitude = nanmedian(inputFlux);

            % Get the reference light curve to scale injected signals relative to
            % If this is a debug run then there are no outputs! Need to use inputs!
            if (~obj.debugRun && obj.useOutputFluxFromOriginalRunToScaleInjectedSignals)
                % Get the output light curve from the original run but remove the flux fraction and crowding metric correction 
                % so that the light curve is on the same scale as the input flux
                targetDataStructOutput = pdc_convert_output_flux_to_targetDataStruct (obj.outputsStructOriginal.targetResultsStruct);
                outputFlux = [targetDataStructOutput.values];
                fluxFraction    = [obj.inputsStructOriginal.targetDataStruct.fluxFractionInAperture];
                crowdingMetric  = [obj.inputsStructOriginal.targetDataStruct.crowdingMetric];
                % from outputFlux =  (rawFluxUnscaled - (1-cm)*rawFluxMedian)/ffia;
                referenceFlux = (outputFlux .* repmat(fluxFraction, [length(outputFlux(:,1)),1])) + ...
                                    repmat((1 - crowdingMetric) .* obj.medianAmplitude, [length(outputFlux(:,1)),1]);
            else
                % Use the input light curve
                referenceFlux = inputFlux;
            end

            nanedFlux = referenceFlux;
            nanedFlux(gaps) = NaN;

            % Zero the median for the stellar signals (they are not necessarily zero and a non-zero
            % median will result in the flux fraction correction changing the amplitude of the preserved
            % signal!
            obj.stellarSignal = obj.stellarSignal - repmat(median(obj.stellarSignal), [obj.nCadences,1]);

            %******************
            % Scale injected signals by stellar flux

            switch obj.scaleInjectedSignalsBy

            case 'medianFlux'
               %% Scale signals by median flux amplitudes
                obj.stellarSignal = obj.stellarSignal .* repmat(obj.medianAmplitude, [obj.nCadences,1]);
            case 'stellarVariability'
                % Scale injected signals by stellar variability of each target
                coarseDetrendPolyOrder = 3;
                doNormalizeFlux = true;
                doMaskEpRecovery = true;
                maskWindow = 150;
                doRemoveTransits = true;
                [variability, ~] = pdc_calculate_stellar_variability ...
                    (obj.inputsStructInjected.targetDataStruct, obj.inputsStructInjected.cadenceTimes, coarseDetrendPolyOrder, doNormalizeFlux, ...
                        doMaskEpRecovery, maskWindow, doRemoveTransits);


                obj.stellarSignal = obj.stellarSignal .* repmat(obj.medianAmplitude .* variability, [obj.nCadences,1]);

            case 'fluxStd'
                % Scale by standard deviation of flux after 3rd order polynomial removed
                coarseDetrendPolyOrder = 3;
                detrendedFluxValues  = nanedFlux;
                x = [1:length(nanedFlux(:,1))]';
                for iTarget = 1:obj.nTargets
                    [p, s, mu] = polyfit(x(~gaps(:,iTarget)), nanedFlux((~gaps(:,iTarget)),iTarget), coarseDetrendPolyOrder);
                    detrendedFluxValues(:,iTarget) = nanedFlux(:,iTarget) - polyval(p, x, s, mu);
                end
                fluxStd = nanstd(detrendedFluxValues);

                obj.stellarSignal = obj.stellarSignal .* repmat(fluxStd, [obj.nCadences,1]);
            case 'fluxStdNoPolyFit'

                disp('***************************')
                disp('***************************')
                disp('***************************')
                disp('TEST: NOT performing 3rd order polynomial removal before computing std!!!!');
                disp('***************************')
                disp('***************************')
                disp('***************************')

                % Scale by standard deviation of flux DO NOT perform 3rd order polynomial removal
                fluxStd = nanstd(nanedFlux);

                obj.stellarSignal = obj.stellarSignal .* repmat(fluxStd, [obj.nCadences,1]);
            otherwise
                error('Unknown scaleInjectedSignalsBy');
            end


            %******************
            % Add the injected signals to the input flux for the injected signal run
            for iTarget = 1 : obj.nTargets
                obj.inputsStructInjected.targetDataStruct(iTarget).values = ...
                    obj.inputsStructInjected.targetDataStruct(iTarget).values + obj.stellarSignal(:,iTarget) ;
            end

            % Scale stellarSignal by flux fraction and crowding metric! But save in seperate array for use when comparing outputs.
            crowdingMetricArray = [obj.inputsStructOriginal.targetDataStruct.crowdingMetric];
            fluxFractionArray   = [obj.inputsStructOriginal.targetDataStruct.fluxFractionInAperture]';
            tempTargetDataStruct = obj.inputsStructOriginal.targetDataStruct;
            harmonicsDummy = tempTargetDataStruct;
            for iTarget = 1 : obj.nTargets
                tempTargetDataStruct(iTarget).values = obj.stellarSignal(:,iTarget);
                % There are no harmonic values so set to zero
                harmonicsDummy(iTarget).values = zeros(obj.nCadences,1);
            end
            [ tempTargetDataStruct , ~ , ~ ] = ...
                pdc_correct_flux_fraction_and_crowding_metric(tempTargetDataStruct, harmonicsDummy, ...
                crowdingMetricArray,fluxFractionArray, []);
            obj.scaledStellarSignal = [tempTargetDataStruct.values];
            clear tempTargetDataStruct harmonicsDummy;

            %******************
            if (obj.debugRun)
                cadenceTimes = [obj.inputsStructOriginal.cadenceTimes.midTimestamps];
                % For testing perturb signals at a known frequency
               %k = 2 * pi / (50*0.0204); % E.g. Perturbed signal has wavelength of 200 cadences (or ~ 4 days)
                for iTarget = 1 : obj.nTargets
                   %A = std(obj.stellarSignal(:,iTarget)) * 100e-2;
                   %A = mad(obj.inputsStructOriginal.targetDataStruct(iTarget).values) * 100e-2;
                   %obj.inputsStructInjected.targetDataStruct(iTarget).values = ...
                   %    obj.inputsStructInjected.targetDataStruct(iTarget).values + ...
                   %       A * sin(k * cadenceTimes) + A * sin((k / 5) * cadenceTimes);
                    %***
                    % Inject extra fraction of stellarSignal for testing
                    extraAmount = -1.0e-1; % Extra 10%
                    obj.inputsStructInjected.targetDataStruct(iTarget).values = ...
                        obj.inputsStructInjected.targetDataStruct(iTarget).values + ...
                           extraAmount * obj.stellarSignal(:,iTarget);
                end
            end
            %******************

            display('Finished injecting signals into light curves!');

            if (obj.debugPlotSignalInjection)
                figure;
                % Plot a selection of injected signals
                targetsToPlot = randperm(obj.nTargets);
                targetsToPlot = targetsToPlot(1:obj.nTargetsToPlot);
                for i = 1 : obj.nTargetsToPlot
                    iTarget = targetsToPlot(i);
                    gaps = obj.inputsStructOriginal.targetDataStruct(iTarget).gapIndicators;
                    plot(obj.inputsStructOriginal.cadenceTimes.midTimestamps(~gaps), ...
                         obj.inputsStructOriginal.targetDataStruct(iTarget).values(~gaps), '-b');
                    hold on;
                    plot(obj.inputsStructInjected.cadenceTimes.midTimestamps(~gaps), ...
                         obj.inputsStructInjected.targetDataStruct(iTarget).values(~gaps), '-r');
                    medianFlux = median(obj.inputsStructOriginal.targetDataStruct(iTarget).values(~gaps));
                    plot(obj.inputsStructInjected.cadenceTimes.midTimestamps(~gaps), ...
                         obj.stellarSignal(~gaps, iTarget) + medianFlux, '-m');
                    xlabel('Cadence Time (MJD)');
                    ylabel('Flux [e-/Cadence]');
                    legend('Original Light Curve', 'Injected Signal Light Curve', 'Injected Signal');
                    hold off;
                    display(['Displaying target ', num2str(i), ' of ', num2str(obj.nTargetsToPlot)]);
                    pause;
                end
            end


        end

        %*****************************************************************************************************
        function compute_post_data (obj)

            % We want to use the output gaps, that means the filledIndices from outputsStruct.
            if (obj.debugRun)
                obj.outputsGaps = [obj.inputsStructOriginal.targetDataStruct.gapIndicators];
            else
                obj.outputsGaps = [obj.outputsStructOriginal.targetResultsStruct.correctedFluxTimeSeries]; 
                obj.outputsGaps = [obj.outputsGaps.gapIndicators];
                filledIndices = [obj.outputsStructOriginal.targetResultsStruct.correctedFluxTimeSeries];
                for iTarget = 1 : length(filledIndices)
                    % FilledIndices are using the silly 0-based indexing!
                    obj.outputsGaps(filledIndices(iTarget).filledIndices+1, iTarget) = true;
                end
            end
        
            % Generate stellar signal Difference curves
            obj.find_stellar_signal_difference();
         
            % Find standard deviation of stellar signal differences
            obj.find_stellar_signal_diff_std()
         
            % Find frequency of injected signal and normalization value
            obj.find_at_frequency_corruption ();

        end
        
        %*****************************************************************************************************
        % Plot for just sineWave injected targets
        % Plots 
        % 1) the amplitude of the peridogram at the injected frequency of the corrupted signal (obj.stellarSignalDiff) vs the injected
        %       sine wave period. 
        % 2) the standard deviation of the corrupted signal vs injected signal period
        % 3) the gain in the amplitude for each injected signal vs. the injected sine wave period
        %
        % the optional argument is a logical if to save the figures generated
        %
        function generate_1D_corruption_plots(obj, varargin)

            if (isempty(obj.targetsInjectedWithStellarOscillators))
                obj.targetsInjectedWithStellarOscillators = false(obj.nTargets,1);
            end

            if (all(~obj.targetsInjectedWithSineWaves) && all(~obj.targetsInjectedWithStellarOscillators))
                display('GENERATE_1D_CORRUPTION_PLOT: No sine or stellar wave injected signals to plot!')
                return;
            end

            % Only look at targets injected with sine waves
            lambdaReduced = obj.lambda(obj.targetsInjectedWithSineWaves | obj.targetsInjectedWithStellarOscillators);

            %*********************************************************
            % At-frequency amplitude corruption

            atFreqCorruptionAmountReduced = obj.atFreqCorruptionAmount(obj.targetsInjectedWithSineWaves | obj.targetsInjectedWithStellarOscillators); 

            ampPlot = figure;
            loglog  (lambdaReduced, atFreqCorruptionAmountReduced , '*b');
            hold on;

            % Generate smooth curve to data.
            [smoothAmp, smoothAmpStd, lambdaSorted] = obj.generate_smooth_log10_curve_to_data (atFreqCorruptionAmountReduced, lambdaReduced, obj.smoothFactor);

            loglog  (lambdaSorted, smoothAmp, '-b', 'LineWidth', 2);
            % Plot threshold lines, rescaled to 100% corruption
            loglog(lambdaReduced, 1/2   * ones(size(lambdaReduced)), '-r', 'LineWidth', 2);
            loglog(lambdaReduced, 1/10  * ones(size(lambdaReduced)), '-m', 'LineWidth', 2);
            loglog(lambdaReduced, 1/100 * ones(size(lambdaReduced)), '-k', 'LineWidth', 2);
            grid on;
            xlabel('Period [days]');
            ylabel('Normalized Amplitude Corruption to Injected Signal [relative to 100% amplitude]');
            if (~isempty(smoothAmp))
                legend('Normalized Amplitude Corruption', 'Smoothed Curved', '50% corruption', '10% Corruption', '1% Corruption', 'Location', 'SouthEast');
            else
                legend('Normalized Amplitude Corruption', '50% corruption', '10% Corruption', '1% Corruption', 'Location', 'SouthEast');
            end
            title(['Corruption of Injected Sinusoids at Amplitude = ', num2str(obj.signalAmplitude), '*std(flux)']);
            hold off;

            if (~isempty(varargin) && varargin{1})
                saveas(ampPlot, 'amplitude_corruption.fig', 'fig');
            end

            %*********************************************************
            % Box-plot of At-frequency amplitude corruption

            nBins = 20;
            boxLabels = zeros(nBins,1);
            groupLabels = zeros(length(atFreqCorruptionAmountReduced),1);
            binLimits = logspace(log10(min(lambdaReduced)), log10(max(lambdaReduced+1)), nBins+1);
            for iBin = 1 : nBins
                freqCorruptionInThisBin = (lambdaReduced >= binLimits(iBin) & lambdaReduced < binLimits(iBin+1));

                % Label boxes as the center value within each bin
                boxLimits = logspace(log10(binLimits(iBin)), log10(binLimits(iBin+1)), 3);
                boxLabels(iBin) = (boxLimits(2));

                groupLabels(freqCorruptionInThisBin) = boxLabels(iBin);

                labels{iBin} = num2str(boxLabels(iBin), 2);
            end



            boxPlotFigure = figure;
            plot(log10(lambdaReduced), log10(atFreqCorruptionAmountReduced) , '.b', 'MarkerSize', 1.0);
            grid on;
            hold on;
            boxplot(log10(atFreqCorruptionAmountReduced), log10(groupLabels), 'symbol', '', 'positions', log10(groupLabels), 'widths', 0.1632, ...
                    'labels', labels);
            figure(boxPlotFigure);

            % Draw vertical lines over box centers
            for iBin = 1 : nBins
                line([log10(boxLabels(iBin)) log10(boxLabels(iBin))], [-10 10], 'LineStyle', ':');
            end
            % Rename the vertical tick marks to % corruption
            set(gca,'YLim',[-5 0.5]);
            set(gca,'YTick',[-5 -4 -3 -2 -1 0 0.5]);
            YTickMarks = {'0.001%', '0.01%', '0.1%', '1%', '10%', '100%', ''};
            set(gca,'YTickLabel', YTickMarks,'FontSize', 10);
            hold off;
            xlabel('Period [days]', 'FontSize', 10);
            ylabel('Amplitude Corruption of Injected Signal [% Corruption]', 'FontSize', 10);
            title(['Corruption of Injected Sinusoids at Amplitude = ', num2str(obj.signalAmplitude,'%4.2f'), ' * std(flux)'], 'FontSize', 12);
            hold off;

            if (~isempty(varargin) && varargin{1})
                saveas(boxPlotFigure , 'amplitude_corruption_box_plot.fig', 'fig');
            end



            %*********************************************************
            % std corruption
            
            % TURNED OFF
            if (false)
                % Only plot for sine wave injected targets
                stellarSignalDiffStdReduced = obj.stellarSignalDiffStd(obj.targetsInjectedWithSineWaves | obj.targetsInjectedWithStellarOscillators);

                nTargetsPlotted = length(obj.lambda(obj.targetsInjectedWithSineWaves | obj.targetsInjectedWithStellarOscillators));
                stdPlot = figure;
                loglog(lambdaReduced, stellarSignalDiffStdReduced, '*b');
                hold on;
             
                % Smoothed curved
                % Smooth in log10 so that it looks smooth in log10 (for plotting) and negative values not created
                [smoothStd, smoothStdStd, lambdaSorted] = obj.generate_smooth_log10_curve_to_data (stellarSignalDiffStdReduced, lambdaReduced, obj.smoothFactor);
             
                loglog(lambdaSorted, smoothStd, '-b', 'LineWidth', 2);
                loglog(lambdaReduced, 1/2   * ones(size(lambdaReduced)), '-r', 'LineWidth', 2);
                loglog(lambdaReduced, 1/10  * ones(size(lambdaReduced)), '-m', 'LineWidth', 2);
                loglog(lambdaReduced, 1/100 * ones(size(lambdaReduced)), '-k', 'LineWidth', 2);
                grid on;
                hold off;
             
                if (~isempty(smoothStd))
                    legend('Normalized Signal Corruption', 'Smooth curve to corruption', '50% corruption', '10% Corruption', '1% Corruption', 'Location', 'Best');
                else
                    legend('Normalized Signal Corruption', '50% corruption', '10% Corruption', '1% Corruption', 'Location', 'Best');
                end
                title('Standard Deviation of the Sine Wave Injected Signal Corruption')
                xlabel('Period of Injected Signal [days]');
                ylabel('Normalized Signal Amplitude Corruption Standard Deviation');
             
                if (~isempty(varargin) && varargin{1})
                    saveas(stdPlot, 'std_corruption.fig', 'fig');
                end

            end 

            %*********************************************************
            % std Gain TURNED OFF -- NOT CURRENTLY USEFUL PLOT BUT MAY WANT TO REVISIT

            % TURNED OFF
            if (false)
                % std of stellarSignal
                stellarSignalStd  = zeros(obj.nTargets,1);
                lightCurveDiffStd = zeros(obj.nTargets,1);
                for iTarget = 1 : obj.nTargets
                    gaps = obj.inputsStructOriginal.targetDataStruct(iTarget).gapIndicators;
            
                    if (obj.debugRun)
                        stellarSignalStd(iTarget)  = std(obj.stellarSignal(~gaps,iTarget));
                    else
                        % If real run then output is scaled by flux fraction so need to use scaled stellar signal
                        % as well
                        stellarSignalStd(iTarget)  = std(obj.scaledStellarSignal(~gaps,iTarget));
                    end
                    lightCurveDiffStd(iTarget) = std(obj.lightCurveDiff(~gaps,iTarget));
                end
            
                obj.deltaSignalStd = lightCurveDiffStd - stellarSignalStd;
                deltaSignalStdReduced = obj.deltaSignalStd(obj.targetsInjectedWithSineWaves | obj.targetsInjectedWithStellarOscillators);
            
                stdGainPlot = figure;
                semilogx(lambdaReduced, deltaSignalStdReduced, '*b');
                hold on;
            
                % Smoothed curved
                % Smooth in log10 so that it looks smooth in log10 (for plotting) and negative values not created
                polyOrder = 3;
                smoothWindow = floor(nTargetsPlotted / 10);
                if (mod(smoothWindow,2) == 0)
                    smoothWindow = smoothWindow - 1;
                end
                if (smoothWindow > polyOrder)
                    % Need to re-sort data by wavelength
                    [sortedLambda, sortOrder] = sort(lambdaReduced);
                    smoothStd = sgolayfilt(log10(deltaSignalStdReduced(sortOrder)), 3, smoothWindow);
                    smoothStd = 10.^smoothStd ;
                    loglog(sortedLambda, smoothStd, '-b', 'LineWidth', 2);
                end
               %loglog(lambdaReduced, 1/2   * ones(size(lambdaReduced)), '-r', 'LineWidth', 2);
               %loglog(lambdaReduced, 1/10  * ones(size(lambdaReduced)), '-m', 'LineWidth', 2);
               %loglog(lambdaReduced, 1/100 * ones(size(lambdaReduced)), '-k', 'LineWidth', 2);
                grid on;
                hold off;
            
                if (smoothWindow > polyOrder)
                    legend('Normalized Signal STD Gain', 'Smooth curve to corruption', '50% corruption', '10% Corruption', '1% Corruption', 'Location', 'Best');
                else
                    legend('Normalized Signal Corruption', '50% corruption', '10% Corruption', '1% Corruption', 'Location', 'Best');
                end
                title('Gain in Standard Deviation of the Sine Wave Injected Signal Corruption')
                xlabel('Period of Injected Signal [days]');
                ylabel('Normalized Signal Amplitude Corruption Gain in Standard Deviation [e-/cadence]');
            
                if (~isempty(varargin) && varargin{1})
                    saveas(stdGainPlot, 'std_gain.fig', 'fig');
                end

            end % TURNED OFF


        end
            
        %*****************************************************************************************************
        % The amplitude study injects sine waves of different amplitudes into the data. This function determines 
        % the corruption level statistics for each injection amplitude and then generates a plot showing the 
        % sine wave periods when the corruption becomes bad.
        %
        % the optional argument is a logical if to save the two figures generated
        function generate_amplitude_study_plot (obj, varargin)

            curveStruct = struct('curve', [], 'curveStd', [], ...
                                    'onePercentIntersectLambda', [], ...
                                    'onePercentIntersectLambdaStd', [], ...
                                    'tenPercentIntersectLambda', [], ...
                                    'tenPercentIntersectLambdaStd', [], ...
                                    'fiftyPercentIntersectLambda', [], ...
                                    'fiftyPercentIntersectLambdaStd', []);
            smoothAmplitude = repmat(struct('atFreq', curveStruct),[obj.ampStudy.nAmplitudes,1]);

            % Create smooth curves and intersections for each amplitude
            for iAmp = 1 : obj.ampStudy.nAmplitudes
                targetsWithThisAmplitude = obj.ampStudy.selectedTargets(iAmp).targets;
                lambdaReduced = obj.lambda(targetsWithThisAmplitude);

                % At-Frequency corruption
                atFreqCorruptionAmountReduced = obj.atFreqCorruptionAmount(targetsWithThisAmplitude ); 

                % STD of corruption
               %stellarSignalDiffStdReduced = obj.stellarSignalDiffStd(targetsWithThisAmplitude);

                % Find 1%, 10% and 50% intersection points

                [smoothAmplitude(iAmp).atFreq.onePercentIntersectLambda, smoothAmplitude(iAmp).atFreq.onePercentIntersectLambdaStd, ~, ~]  ...
                            = obj.find_curve_intersection (atFreqCorruptionAmountReduced, lambdaReduced, 1e-2);

                [smoothAmplitude(iAmp).atFreq.tenPercentIntersectLambda, smoothAmplitude(iAmp).atFreq.tenPercentIntersectLambdaStd, ...
                            smoothAmplitude(iAmp).atFreq.curve, smoothAmplitude(iAmp).atFreq.curveStd]  ...
                            = obj.find_curve_intersection (atFreqCorruptionAmountReduced, lambdaReduced, 1e-1);

                [smoothAmplitude(iAmp).atFreq.fiftyPercentIntersectLambda, smoothAmplitude(iAmp).atFreq.fiftyPercentIntersectLambdaStd, ~, ~]  ...
                            = obj.find_curve_intersection (atFreqCorruptionAmountReduced, lambdaReduced, 5e-1);
            end


            % Plot the intersection points as a function of amplitude
            atFreqOnePercent        = [smoothAmplitude.atFreq];
            atFreqOnePercentValues  = [atFreqOnePercent.onePercentIntersectLambda];
            atFreqOnePercentStd     = [atFreqOnePercent.onePercentIntersectLambdaStd];
            atFreqTenPercent        = [smoothAmplitude.atFreq];
            atFreqTenPercentValues  = [atFreqTenPercent.tenPercentIntersectLambda];
            atFreqTenPercentStd     = [atFreqTenPercent.tenPercentIntersectLambdaStd];
            atFreqFiftyPercent      = [smoothAmplitude.atFreq];
            atFreqFiftyPercentValues = [atFreqFiftyPercent.fiftyPercentIntersectLambda];
            atFreqFiftyPercentStd   = [atFreqFiftyPercent.fiftyPercentIntersectLambdaStd];

            ampStudyPlot = figure;
            errorbar(obj.ampStudy.amplitudes, atFreqOnePercentValues, atFreqOnePercentStd, '-k*')
            hold on;
            errorbar(obj.ampStudy.amplitudes, atFreqTenPercentValues, atFreqTenPercentStd, '-m*')
            errorbar(obj.ampStudy.amplitudes, atFreqFiftyPercentValues, atFreqFiftyPercentStd, '-r*')
           %set(gca,'YDir','reverse')
            set(gca,'XScale', 'log');
            grid on;

            legend('1% Corruption', '10% Corruption', '50% Corruption', 'Location', 'NorthWest');
            switch obj.scaleInjectedSignalsBy 
                case ('medianFlux')
                    xlabel('Amplitude of Injected Signal [% of medain flux]');
                case ({'fluxStd' 'fluxStdNoPolyFit'})
                    xlabel('Amplitude of Injected Signal [Relative to std(flux)]');
                case ('stellarVariability')
                    xlabel('Amplitude of Injected Signal [% of Flux Stellar Variability]');
                otherwise 
                    error('unknown scaleInjectedSignalBy');
            end
            ylabel('Period of Injected Signal for specified corruption level [days]')
            title ('Period at which signal is corrupted by 1%, 10% and 50%');

            % If we are saving figure then we are also not plotting individual at frequency plots
            if (~isempty(varargin) && varargin{1})
                saveas(ampStudyPlot, 'amplitude_study.fig', 'fig');
            elseif(false)
                % For testing plot the at frequency corruption for a couple amplitudes.

                testFig = figure;
                for iAmp = 1 : obj.ampStudy.nAmplitudes
             
                    targetsWithThisAmplitude = obj.ampStudy.selectedTargets(iAmp).targets;
                    lambdaReduced = obj.lambda(targetsWithThisAmplitude);

                    figure(testFig);
                    plot(lambdaReduced, obj.atFreqCorruptionAmount(targetsWithThisAmplitude), '*b');
                    hold on;
                    % Smooth curve
                    errorbar  (sort(lambdaReduced), smoothAmplitude(iAmp).atFreq.curve, smoothAmplitude(iAmp).atFreq.curveStd, '-b', 'LineWidth', 2);
                    % Plot threshold lines, rescaled to 100% corruption
                    plot(lambdaReduced, 1/2   * ones(size(lambdaReduced)), '-r', 'LineWidth', 2);
                    plot(lambdaReduced, 1/10  * ones(size(lambdaReduced)), '-m', 'LineWidth', 2);
                    plot(lambdaReduced, 1/100 * ones(size(lambdaReduced)), '-k', 'LineWidth', 2);
                    set(gca,'XScale', 'log');
                   %set(gca,'YScale', 'log');
                    grid on;
                    title(['for Amplitude ' num2str(obj.ampStudy.amplitudes(iAmp))]);
                    xlabel('Period [days]');
                    ylabel('Normalized Amplitude Corruption to Injected Signal [relative to 100% amplitude]');
                    legend('raw data', 'smooth curve','50% corruption', '10% Corruption', '1% Corruption', 'Location', 'Best');
                    hold off;
                    pause;
                end
            end

        end
        
        %*****************************************************************************************************
        function generate_2D_corruption_plot(obj)

            display('GENERATE_2D_CORRUPTION: This function is not ready to be used, Goodbye.');
            return;

            timeStamps = [obj.inputsStructInjected.cadenceTimes.midTimestamps];
            cadenceStep = median(diff(timeStamps(timeStamps>0)));
            dataLength = max(timeStamps) - min(timeStamps(timeStamps>0));

            % Generate periodogram for each target
            [periodograms, obj.periodogramFrequency] = obj.find_periodograms (obj.stellarSignalDiff);

           %sqrtPeriodogram = sqrt(periodograms);
            logSqrtPeriodogram = log(sqrt(periodograms));

            X = obj.lambda;
            Xmat = repmat(obj.lambda, [obj.periodogramLength,1]);
            Y = (obj.periodogramFrequency * obj.cadencesPerTwoPiRads).^-1;
            Ymat = repmat((obj.periodogramFrequency * obj.cadencesPerTwoPiRads).^-1, [1,obj.nTargets]);
            
            % Plot each periodogram as a function of injected signal frequency or period
            figure;
           %imagesc(X, Y(Y>=cadenceStep & Y<=dataLength), logSqrtPeriodogram((Y>=cadenceStep & Y<=dataLength),:));
           %pcolor(X(periods>=cadenceStep & periods<=dataLength,:), Y(periods>=cadenceStep & periods<=dataLength,:), ...
           %                logSqrtPeriodogram((periods>=cadenceStep & periods<=dataLength),:));

           scatter(Xmat(:), Ymat(:), 5, logSqrtPeriodogram(:))
           %pcolor(X, Y, logSqrtPeriodogram);

        end


        %*****************************************************************************************************
        % Find the net PSD of the stellar signal differences. This is only useful for WGN injected signals.
        % Compares the original and injected light curves and then compares that to the original injected
        % signals and takes the power spectum density of this difference. Then averages all PSDs to get the net
        function perform_net_PSD_analysis (obj, varargin)
    
            if (all(~obj.targetsInjectedWithWGN))
                display('PERFORM_NET_PSD_ANALSYS: No WGN injected signals to plot!')
                return;
            end

            % Generate statistics on periodograms
            % Option to smooth curve
           %[obj.compiledPeriodogram, obj.periodogramFrequency] = obj.find_sum_periodogram (obj.stellarSignalDiff, ...
           %        obj.targetsInjectedWithWGN, 201);
            [obj.compiledPeriodogram, periodogramStd, obj.periodogramFrequency] = ...
                        obj.find_periodogram_median (obj.stellarSignalDiff, obj.targetsInjectedWithWGN, 0);

            % Calibrate to 100% corruption amplitude value
            if (obj.debugRun)
                fullCorruptionSignal = obj.stellarSignal ./ repmat(std(obj.stellarSignal),[obj.nCadences,1]);
            else
                fullCorruptionSignal = obj.scaledStellarSignal ./ repmat(std(obj.scaledStellarSignal),[obj.nCadences,1]);
            end
            obj.fullCorruptionLevel = nanmedian(sqrt(obj.find_periodogram_median (fullCorruptionSignal, ...
                                                obj.targetsInjectedWithWGN, 0)));

            psdPlot = figure;
            % signal amplitude is square-root of power and rescale to 100% corruption
           %errorbar((obj.periodogramFrequency * obj.cadencesPerTwoPiRads).^-1, ...
           %        sqrt(obj.compiledPeriodogram) / sqrt(obj.fullCorruptionLevel), ...
           %        sqrt(periodogramStd)/ sqrt(obj.fullCorruptionLevel));
           %set(gca,'YScale', 'log');
           %set(gca,'XScale', 'log');
            loglog  ((obj.periodogramFrequency * obj.cadencesPerTwoPiRads).^-1, sqrt(obj.compiledPeriodogram) ./ ...
                                                                                                obj.fullCorruptionLevel);
            hold on;
            % Plot threshold lines, rescaled to 100% corruption
            loglog((obj.periodogramFrequency * obj.cadencesPerTwoPiRads).^-1, 1/2   * ones(obj.periodogramLength,1), '-r', 'LineWidth', 2);
            loglog((obj.periodogramFrequency * obj.cadencesPerTwoPiRads).^-1, 1/10  * ones(obj.periodogramLength,1), '-m', 'LineWidth', 2);
            loglog((obj.periodogramFrequency * obj.cadencesPerTwoPiRads).^-1, 1/100 * ones(obj.periodogramLength,1), '-k', 'LineWidth', 2);
            grid on;
            xlabel('Period [days]');
            ylabel('Normalized Power Amplitude [Signal Amplitude / days]');
            legend('Normalized Power Amplitude Spectrum', '50% corruption', '10% Corruption', '1% Corruption', 'Location', 'Best');
            title('Summed and Normalized PSD of WGN corrupted signal over all WGN injected targets Normalized to Injected Signal Amplitude');

            if (~isempty(varargin) && varargin{1})
                saveas(psdPlot, 'WGN_PSD_corruption.fig', 'fig');
            end
        end

        %*****************************************************************************************************
        % Uses the standard deviation of stellarSignalDiff
        function perform_std_analysis (obj, varargin)

            error ('This function is not set up');

            % Only plot for injected targets
            stellarSignalDiffStdReduced = obj.stellarSignalDiffStd(obj.targetsInjectedWithSineWaves | ...
                    obj.targetsInjectedWithStellarOscillators | obj.targetsInjectedWithSoho | obj.targetsInjectedWithWGN);

            stdPlot = figure;
            loglog(lambdaReduced, stellarSignalDiffStdReduced, '*b');
            hold on;
            
            % Smoothed curved
            % Smooth in log10 so that it looks smooth in log10 (for plotting) and negative values not created
            [smoothStd, smoothStdStd, lambdaSorted] = obj.generate_smooth_log10_curve_to_data (stellarSignalDiffStdReduced, lambdaReduced, obj.smoothFactor);
            
            loglog(lambdaSorted, smoothStd, '-b', 'LineWidth', 2);
            loglog(lambdaReduced, 1/2   * ones(size(lambdaReduced)), '-r', 'LineWidth', 2);
            loglog(lambdaReduced, 1/10  * ones(size(lambdaReduced)), '-m', 'LineWidth', 2);
            loglog(lambdaReduced, 1/100 * ones(size(lambdaReduced)), '-k', 'LineWidth', 2);
            grid on;
            hold off;
            
            if (~isempty(smoothStd))
                legend('Normalized Signal Corruption', 'Smooth curve to corruption', '50% corruption', '10% Corruption', '1% Corruption', 'Location', 'Best');
            else
                legend('Normalized Signal Corruption', '50% corruption', '10% Corruption', '1% Corruption', 'Location', 'Best');
            end
            title('Standard Deviation of the Sine Wave Injected Signal Corruption')
            xlabel('Period of Injected Signal [days]');
            ylabel('Normalized Signal Amplitude Corruption Standard Deviation');
            
            if (~isempty(varargin) && varargin{1})
                saveas(stdPlot, 'std_corruption.fig', 'fig');
            end
        end

        %*****************************************************************************************************
        % When injecting SOHO data we inject the exact same signal into every light curve. So, the standard analsys is not approvpriate. Instead we should look
        % at the variance in the preservation statistic over all targets. If not constant then figure out which targets produce better or worse preservation of
        % the exact same signal.
        %
        % This will use obj.stellarSignalDiffStd which we can plot versus a selection of KIC parameters

        function perform_soho_data_analysis (obj, varargin)

            %***
            % PLot Histogram of difference std
            stdHistPlot = figure;

            hist(obj.stellarSignalDiffStd(obj.targetsInjectedWithSoho), 30)
            title('Histogram of Stellar Signal Difference Std over all targets');
            xlabel('Stellar Signal Difference Std');

            %***
           %% PLOT wrt KIC parameters

           %% just pick targets where SOHO data was injected

           %% KeplerMag
           %% Get the wrt parameter
           %% WHY MATLAB, WHY MUST I DO THIS?!?!
           %kicArray = [obj.inputsStructOriginal.targetDataStruct(obj.targetsInjectedWithSoho)];
           %kicArray = [kicArray.kic];
           %xAxis = [kicArray.keplerMag];
           %xAxis = [xAxis.value]';
         
           %stdKepMagPlot = figure;
           %X = [xAxis, obj.stellarSignalDiffStd(obj.targetsInjectedWithSoho)];
           %smoothhist2D(X, 2, [500 500]);
           %xlabel('keplerMag');
           %ylabel('Stellar Signal Difference Std');
           %title('Stellar Signal Difference Std for SOHO injected data');

           %% RA
           %xAxis = [kicArray.ra];
           %xAxis = [xAxis.value]';
         
           %stdRaPlot = figure;
           %X = [xAxis, obj.stellarSignalDiffStd(obj.targetsInjectedWithSoho)];
           %smoothhist2D(X, 2, [500 500]);
           %xlabel('Right Assencion');
           %ylabel('Stellar Signal Difference Std');
           %title('Stellar Signal Difference Std for SOHO injected data');

           %% Dec
           %xAxis = [kicArray.dec];
           %xAxis = [xAxis.value]';
         
           %stdDecPlot = figure;
           %X = [xAxis, obj.stellarSignalDiffStd(obj.targetsInjectedWithSoho)];
           %smoothhist2D(X, 2, [500 500]);
           %xlabel('Declination');
           %ylabel('Stellar Signal Difference Std');
           %title('Stellar Signal Difference Std for SOHO injected data');

            %***
            % Target Variability
            % Use both original run and injected run target variability
            if (~obj.debugRun)
                % Original run variability
                targetVariability = [obj.outputsStructOriginal.targetResultsStruct(obj.targetsInjectedWithSoho)];
                targetVariability = [targetVariability.pdcProcessingStruct];
                targetVariability = [targetVariability.targetVariability];
                stdOrigVarPlot = figure;
                X = [targetVariability' obj.stellarSignalDiffStd(obj.targetsInjectedWithSoho)];
                smoothhist2D(X, 2, [500 500], [], 'semilogx');
                xlabel('Target Variability (from original run)');
                ylabel('Stellar Signal Difference Std');
                title('Stellar Signal Difference Std for SOHO injected data');

                % Injected run variability
               %targetVariability = [obj.outputsStructInjected.targetResultsStruct(obj.targetsInjectedWithSoho)];
               %targetVariability = [targetVariability.pdcProcessingStruct];
               %targetVariability = [targetVariability.targetVariability];
               %stdInjectVarPlot = figure;
               %X = [targetVariability' obj.stellarSignalDiffStd(obj.targetsInjectedWithSoho)];
               %smoothhist2D(X, 2, [500 500], [], 'semilogx');
               %xlabel('Target Variability (from injected run)');
               %ylabel('Stellar Signal Difference Std');
               %title('Stellar Signal Difference Std for SOHO injected data');

                %***
                % Goodness Metric

                % Collect various values
                goodnessTotal       = zeros(obj.nTargets, 1);
                goodnessEP          = zeros(obj.nTargets, 1);
                goodnessCorrelation = zeros(obj.nTargets, 1);
                goodnessVariability = zeros(obj.nTargets, 1);
                goodnessNoise       = zeros(obj.nTargets, 1);
                priorWeightOriginal = zeros(obj.nTargets, 1);
                priorWeightInjected = zeros(obj.nTargets, 1);
                for iTarget = 1 : obj.nTargets
                    % Why is this loop so slow?
                    goodnessTotal(iTarget)          = obj.outputsStructOriginal.targetResultsStruct(iTarget).pdcGoodnessMetric.total.value;
                    goodnessEP(iTarget)             = obj.outputsStructOriginal.targetResultsStruct(iTarget).pdcGoodnessMetric.earthPointRemoval.value;
                    goodnessCorrelation(iTarget)    = obj.outputsStructOriginal.targetResultsStruct(iTarget).pdcGoodnessMetric.correlation.value;
                    goodnessVariability(iTarget)    = obj.outputsStructOriginal.targetResultsStruct(iTarget).pdcGoodnessMetric.deltaVariability.value;
                    goodnessNoise(iTarget)          = obj.outputsStructOriginal.targetResultsStruct(iTarget).pdcGoodnessMetric.introducedNoise.value;
                    if (length(obj.outputsStructOriginal.targetResultsStruct(iTarget).pdcProcessingStruct.bands) == 1)
                        priorWeightOriginal(iTarget) = obj.outputsStructOriginal.targetResultsStruct(iTarget).pdcProcessingStruct.bands(1).priorWeight;
                    else
                        priorWeightOriginal(iTarget) = obj.outputsStructOriginal.targetResultsStruct(iTarget).pdcProcessingStruct.bands(2).priorWeight;
                    end
                    if (length(obj.outputsStructInjected.targetResultsStruct(iTarget).pdcProcessingStruct.bands) == 1)
                        priorWeightInjected(iTarget) = obj.outputsStructInjected.targetResultsStruct(iTarget).pdcProcessingStruct.bands(1).priorWeight;
                    else
                        priorWeightInjected(iTarget) = obj.outputsStructInjected.targetResultsStruct(iTarget).pdcProcessingStruct.bands(2).priorWeight;
                    end
                end

                stdTotalGoodnessPlot = figure;
                X = [goodnessTotal obj.stellarSignalDiffStd(obj.targetsInjectedWithSoho)];
                smoothhist2D(X, 2, [500 500]);
                xlabel('Goodness Metric Total');
                ylabel('Stellar Signal Difference Std');
                title('Stellar Signal Difference Std for SOHO injected data');

                stdEPGoodnessPlot = figure;
                X = [goodnessEP obj.stellarSignalDiffStd(obj.targetsInjectedWithSoho)];
                smoothhist2D(X, 2, [500 500]);
                xlabel('Goodness Metric Earth Point');
                ylabel('Stellar Signal Difference Std');
                title('Stellar Signal Difference Std for SOHO injected data');

                stdCorrelationGoodnessPlot = figure;
                X = [goodnessCorrelation obj.stellarSignalDiffStd(obj.targetsInjectedWithSoho)];
                smoothhist2D(X, 2, [500 500]);
                xlabel('Goodness Metric Correlation');
                ylabel('Stellar Signal Difference Std');
                title('Stellar Signal Difference Std for SOHO injected data');

                stdVariabilityGoodnessPlot = figure;
                X = [goodnessVariability obj.stellarSignalDiffStd(obj.targetsInjectedWithSoho)];
                smoothhist2D(X, 2, [500 500]);
                xlabel('Goodness Metric Variability');
                ylabel('Stellar Signal Difference Std');
                title('Stellar Signal Difference Std for SOHO injected data');

                stdNoiseGoodnessPlot = figure;
                X = [goodnessNoise obj.stellarSignalDiffStd(obj.targetsInjectedWithSoho)];
                smoothhist2D(X, 2, [500 500]);
                xlabel('Goodness Metric Noise');
                ylabel('Stellar Signal Difference Std');
                title('Stellar Signal Difference Std for SOHO injected data');

                stdPriorWeightOriginalPlot = figure;
                X = [priorWeightOriginal obj.stellarSignalDiffStd(obj.targetsInjectedWithSoho)];
                % I want this in logx form but many prior weight are zero -- convert to small number
                X(X(:,1) == 0,1) = 1e-4;
                smoothhist2D(X, 2, [500 500], [], 'semilogx');
                xlabel('Originial Prior Weight (Regular MAP)');
                ylabel('Stellar Signal Difference Std');
                title('Stellar Signal Difference Std for SOHO injected data');

                stdPriorWeightInjectedPlot = figure;
                X = [priorWeightInjected obj.stellarSignalDiffStd(obj.targetsInjectedWithSoho)];
                X(X(:,1) == 0,1) = 1e-4;
                smoothhist2D(X, 2, [500 500], [], 'semilogx');
                xlabel('Injected Prior Weight (Regular MAP)');
                ylabel('Stellar Signal Difference Std');
                title('Stellar Signal Difference Std for SOHO injected data');


            end

            %***
            if (~isempty(varargin) && varargin{1})
               %saveas(stdKepMagPlot,   'SOHO_std_kepmag_plot.fig', 'fig');
               %saveas(stdRaPlot,       'SOHO_std_ra_plot.fig', 'fig');
               %saveas(stdDecPlot,      'SOHO_std_dec_plot.fig', 'fig');
                saveas(stdHistPlot,     'SOHO_std_hist_plot.fig', 'fig');
                if (~obj.debugRun)
                    saveas(stdOrigVarPlot,              'SOHO_std_original_stellarVar_plot.fig', 'fig');
                   %saveas(stdInjectVarPlot,            'SOHO_std_injected_stellarVar_plot.fig', 'fig');
                    saveas(stdTotalGoodnessPlot,        'SOHO_std_total_goodness_plot.fig', 'fig');
                    saveas(stdEPGoodnessPlot,           'SOHO_std_EP_goodness_plot.fig', 'fig');
                    saveas(stdCorrelationGoodnessPlot,  'SOHO_std_correlation_goodness_plot.fig', 'fig');
                    saveas(stdVariabilityGoodnessPlot,  'SOHO_std_variability_goodness_plot.fig', 'fig');
                    saveas(stdNoiseGoodnessPlot,        'SOHO_std_noise_goodness_plot.fig', 'fig');
                    saveas(stdPriorWeightOriginalPlot,  'SOHO_std_prior_weight_original_plot.fig', 'fig');
                    saveas(stdPriorWeightInjectedPlot,  'SOHO_std_prior_weight_Injected_plot.fig', 'fig');
                end
            end

        end

        %*****************************************************************************************************
        % Plot the original and injected light curves
        % Note: if less than nRandomTargetsToPlot had injected signals then this function will only plot those
        % targets that did have injected signals.
        function plot_comparison (obj, nRandomTargetsToPlot)

            fluxHandle = figure;
            PSDHandle = figure;
            % Plot a random selection 
            targetsToPlot = randperm(obj.nTargets);
            counter = 1;
            targetIndex = 1;
            while (counter <= nRandomTargetsToPlot)
                iTarget = targetsToPlot(targetIndex);
                targetIndex = targetIndex + 1;
                if (~obj.targetsInjectedWithSineWaves(iTarget) && ~obj.targetsInjectedWithWGN(iTarget) && ...
                        ~obj.targetsInjectedWithStellarOscillators(iTarget) && ~obj.targetsInjectedWithSoho(iTarget))
                    % This target did not have an injected signal, skip and don't count towards the nRandomTargetsToPlot
                    continue;
                end

                % The input light curves on upper plot.
                figure(fluxHandle);
                subplot(3,1,1)
                gaps = obj.inputsStructOriginal.targetDataStruct(iTarget).gapIndicators;
                plot(obj.inputsStructOriginal.cadenceTimes.midTimestamps(~gaps), ...
                     obj.inputsStructOriginal.targetDataStruct(iTarget).values(~gaps), '-b');
                hold on;
                plot(obj.inputsStructInjected.cadenceTimes.midTimestamps(~gaps), ...
                     obj.inputsStructInjected.targetDataStruct(iTarget).values(~gaps), '-r');
                medianFlux = median(obj.inputsStructOriginal.targetDataStruct(iTarget).values(~gaps));
                plot(obj.inputsStructInjected.cadenceTimes.midTimestamps(~gaps), ...
                     obj.stellarSignal(~gaps, iTarget) + medianFlux, '-m');
                xlabel('Cadence Time (MJD)');
                ylabel('Flux [e-/Cadence]');
                legend('Original Input Light Curve', 'Injected Input Light Curve', 'Injected Signal', 'Location', 'Best');
                hold off;

                % The output light curves on middle plot.
                subplot(3,1,2)
                if (obj.debugRun)
                    plot(obj.inputsStructOriginal.cadenceTimes.midTimestamps(~gaps), ...
                         obj.inputsStructOriginal.targetDataStruct(iTarget).values(~gaps), '-b');
                    hold on;
                    plot(obj.inputsStructInjected.cadenceTimes.midTimestamps(~gaps), ...
                         obj.inputsStructInjected.targetDataStruct(iTarget).values(~gaps), '-r');
                else
                    plot(obj.inputsStructOriginal.cadenceTimes.midTimestamps(~gaps), ...
                         obj.outputsStructOriginal.targetResultsStruct(iTarget).correctedFluxTimeSeries.values(~gaps), '-b');
                    hold on;
                    plot(obj.inputsStructInjected.cadenceTimes.midTimestamps(~gaps), ...
                         obj.outputsStructInjected.targetResultsStruct(iTarget).correctedFluxTimeSeries.values(~gaps), '-r');
                end
                xlabel('Cadence Time (MJD)');
                ylabel('Flux [e-/Cadence]');
                legend('Original Output Light Curve', 'Injected Output Light Curve', 'Location', 'Best');
                hold off;

                % The signal preservation on the lower plot
                subplot(3,1,3)
                if (obj.debugRun)
                    plot(obj.inputsStructInjected.cadenceTimes.midTimestamps(~gaps), ...
                        obj.stellarSignal(~gaps, iTarget), '-m', 'LineWidth', 2);
                else
                    % If real run then output is scaled by flux fraction so need to use scaled stellar signal
                    % as well
                    plot(obj.inputsStructInjected.cadenceTimes.midTimestamps(~gaps), ...
                        obj.scaledStellarSignal(~gaps, iTarget), '-m', 'LineWidth', 2);
                end
                hold on;
                if (obj.debugRun)
                    fluxDiff = obj.inputsStructInjected.targetDataStruct(iTarget).values - ...
                        obj.inputsStructOriginal.targetDataStruct(iTarget).values;
                    plot(obj.inputsStructInjected.cadenceTimes.midTimestamps(~gaps), fluxDiff(~gaps), '-c', 'LineWidth', 2)
                else
                    fluxDiff = obj.lightCurveDiff(:,iTarget);
                    plot(obj.inputsStructInjected.cadenceTimes.midTimestamps(~gaps), fluxDiff(~gaps), '-c', 'LineWidth', 2)
                end
                xlabel('Cadence Time (MJD)');
                ylabel('Flux [e-/Cadence]');
                legend('Injected Signal', 'Preserved Signal', 'Location', 'Best');
                hold off;

                % Show metric in plot title
                subplot(3,1,1)
                string = [];
                if (obj.targetsInjectedWithSineWaves(iTarget))
                    string = [string, 'Sine Wave Injected Target: ', num2str(obj.lambda(iTarget)), ' days; '];
                elseif (obj.targetsInjectedWithWGN(iTarget))
                    string = [string, 'WGN Injected Target; '];
                elseif (obj.targetsInjectedWithStellarOscillators(iTarget))
                    string = [string, 'Stellar Oscillation Injected Target: ', num2str(obj.lambda(iTarget)), ' days; '];
                elseif (obj.targetsInjectedWithSoho(iTarget))
                    string = [string, 'SOHO Virgo Injected Target: ', num2str(obj.lambda(iTarget)), ' days; '];
                end
                % Injected signal amplitude
                if (any(strcmp(obj.signalType, {'amplitudeStudy', 'quietSineAmplitudeStudy', 'simulatedStellarAmplitudeStudy'})))
                    % Find which amplitude is used
                    selectedTargets = [obj.ampStudy.selectedTargets.targets];
                    selectedAmp = find(selectedTargets(iTarget,:));
                    string = [string, 'Injected Amplitude: ', num2str(obj.ampStudy.amplitudes(selectedAmp)), '; '];
                else
                    string = [string, 'Injected Amplitude: ', num2str(obj.signalAmplitude), ' ;'];
                end
                string = [string, ' Kepler ID: ', num2str(obj.inputsStructOriginal.targetDataStruct(iTarget).keplerId), '; Target Index: ', num2str(iTarget)];
                title(string);

                subplot(3,1,3)
                string = [];
                string = [string, 'STD Corruption = ', num2str(obj.stellarSignalDiffStd(iTarget) * 100), '%; '];
                if (~isempty(obj.deltaSignalStd))
                    string = [string, 'STD Gain = ', num2str(obj.deltaSignalStd(iTarget)), '; '];
                end
                if (obj.targetsInjectedWithSineWaves(iTarget) || obj.targetsInjectedWithStellarOscillators(iTarget))
                    string = [string, 'At Freq Amp. Corruption = ', num2str(obj.atFreqCorruptionAmount(iTarget) * 100), '%; '];
                end
                title(string);

                %******************************************************
                figure(PSDHandle);
                % Get periodogram for this one target
                [targetPeriodogram, frequency] = periodogram(obj.stellarSignalDiff(:,iTarget));
                % Signal amplitude is square-root of power and rescale to 100% corruption
                if (obj.debugRun)
                    fullCorruptionSignal = obj.stellarSignal(:,iTarget) ./ std(obj.stellarSignal(:,iTarget));
                else
                    fullCorruptionSignal = obj.scaledStellarSignal(:,iTarget) ./ std(obj.scaledStellarSignal(:,iTarget));
                end
                [fullCorruptionPeriodogram, ~] = periodogram(fullCorruptionSignal);
                if (obj.targetsInjectedWithSineWaves(iTarget))
                    % sine wave is strongly peaked so scale to peak in periodogram
                    obj.fullCorruptionLevel = max(sqrt(fullCorruptionPeriodogram));
                elseif (obj.targetsInjectedWithWGN(iTarget))
                    % Since WGN is white scale to median value
                    obj.fullCorruptionLevel = nanmedian(sqrt(fullCorruptionPeriodogram));
                elseif (obj.targetsInjectedWithStellarOscillators(iTarget))
                    % stellar oscillation is strongly peaked so scale to peak in periodogram
                    obj.fullCorruptionLevel = max(sqrt(fullCorruptionPeriodogram));

                elseif (obj.targetsInjectedWithSoho(iTarget))
                    % SOHO data is strongly peaked so scale to peak in periodogram
                    obj.fullCorruptionLevel = max(sqrt(fullCorruptionPeriodogram));
                end
                loglog  ((frequency * obj.cadencesPerTwoPiRads).^-1, sqrt(targetPeriodogram) ./ obj.fullCorruptionLevel);
                hold on;
                % Plot threshold lines, rescaled to 100% corruption
                loglog((frequency * obj.cadencesPerTwoPiRads).^-1, 1/2   * ones(obj.periodogramLength,1), '-r', 'LineWidth', 2);
                loglog((frequency * obj.cadencesPerTwoPiRads).^-1, 1/10  * ones(obj.periodogramLength,1), '-m', 'LineWidth', 2);
                loglog((frequency * obj.cadencesPerTwoPiRads).^-1, 1/100 * ones(obj.periodogramLength,1), '-k', 'LineWidth', 2);
                grid on;
                xlabel('Period [days]');
                ylabel('Normalized Amlitude of Stellar Signal Difference [sqrt(Signal Strength) / days]');
                legend('Normalized Amplitude Spectrum', '50% corruption', '10% Corruption', '1% Corruption', 'Location', 'SouthEast');
                string = [];
                if (obj.targetsInjectedWithSineWaves(iTarget) || obj.targetsInjectedWithStellarOscillators(iTarget))
                    string = [string, 'Injected Wave Frequency: ', num2str(obj.lambda(iTarget)), ' days;'];
                    % Plot line showing frequency of injected sine wave
                    x = [obj.lambda(iTarget) obj.lambda(iTarget)];
                    y = [1e-5 1e1];
                    plot(x, y, '-g', 'LineWidth', 2); 
                end
                string = [string, ' Amplitude Spectrum of Stellar Signal Difference for target index ', num2str(iTarget)]; 
                title(string);
                hold off;

                display(['Displaying target ', num2str(counter), ' of ', num2str(nRandomTargetsToPlot)]);
                pause;
                counter = counter + 1;
            end

        end
            
        %*****************************************************************************************************
        % Plot the net distribution of White Gaussian Noise injected
        function plot_injected_WGN (obj)

            %***************************************
            % Compute injected signal sum periodogram by dividing by median amplitudes so all are of same
            % scale.
            % TODO: update for different types of scaling other than median amplitude
            normalizedStellarSignal = obj.stellarSignal ./ repmat(obj.medianAmplitude, [obj.nCadences,1]);
            [compiledStellarSignalPeriodogram,~] = obj.find_periodogram_median(normalizedStellarSignal , ...
                    obj.targetsInjectedWithWGN, 0);

            % Plot injected stellar signal periodogram
            figure;
            loglog  ((obj.periodogramFrequency * obj.cadencesPerTwoPiRads).^-1, sqrt(compiledStellarSignalPeriodogram));
            grid on;
            xlabel('Period [days]');
            ylabel('Normalized Power Amplitude [Signal Amplitude / days]');
            title('Summed and Normalized PSD of WGN Injected Signals');

        end

    end

%*************************************************************************************************************
    methods (Access = 'private')
        
        %*************************************************************************************************************
        % Injects a distribution of sinewaves into targets at a variety of set amplitudes to determine how the preservation changes with amplitude of signal
        function [] = inject_amplitude_study (obj, injectionType)

            % Pick targets to inject signals into
            obj.ampStudy.selectedTargets = obj.select_targets (injectionType);

            % Pick the amplitudes to set
            if (mod(obj.ampStudy.nAmplitudes,2) ~= 1)
                display('Warning: you selected an even number of amplitudes!');
            end
    
            % Create linear amplitude distribution in log
            dataLength = obj.ampStudy.maxAmplitude - obj.ampStudy.minAmplitude;
            ampStep = (dataLength-obj.ampStudy.minAmplitude) / obj.ampStudy.nAmplitudes;
            startingLog = log10(obj.ampStudy.minAmplitude);
            endingLog = log10(obj.ampStudy.nAmplitudes*ampStep+obj.ampStudy.minAmplitude);
            logStep = (endingLog - startingLog) / (obj.ampStudy.nAmplitudes-1);
            obj.ampStudy.amplitudes = [startingLog:logStep:endingLog];
            obj.ampStudy.amplitudes = 10.^obj.ampStudy.amplitudes;

            for iAmp = 1 : obj.ampStudy.nAmplitudes
                switch injectionType

                case ('simulatedStellarAmplitudeStudy')
                    
                    obj.inject_simulated_stellar_oscillator (obj.ampStudy.selectedTargets(iAmp).targets, obj.ampStudy.amplitudes(iAmp));

                case ('sineAmplitudeStudy')

                    obj.inject_sine_waves (obj.ampStudy.selectedTargets(iAmp).targets, obj.ampStudy.amplitudes(iAmp));

                otherwise
                    error('INJECT_AMPLITUDE_STUDY: Unknown stellar signal type');
                end
            end

        end

        %*************************************************************************************************************
        function [] = inject_sine_waves (obj, selectedTargets, signalAmplitude)
    
            % record these targets as being injected with sine waves (in addtion to any others already injected with Sine Waves)
            obj.targetsInjectedWithSineWaves = selectedTargets | obj.targetsInjectedWithSineWaves;
            nSineWaveTargets = length(find(selectedTargets));

            x = [obj.inputsStructInjected.cadenceTimes.midTimestamps];
            dataStep = median(diff(x(x>0)));

            % Amplitude
            A = (signalAmplitude) .* ones(1,obj.nTargets);

            % Phase (uniform distribution in 2 PI)
            phase = 2 * pi * rand(1, obj.nTargets);

            %************
            % Wavelength 
            % Create linear wavelength distribution in log
            % Uniform distribution from 2 cadences to full data length
            % Gapped data is zeroed so only look for minimum that's greater than zero.
            dataLength = max(x) - min(x(x>0));
            startingPeriod = dataStep*2;
            lambdaStep = (dataLength-startingPeriod) / obj.nTargets;

            %******************************
            %******************************
          % % TEST: try longer periods
          % % start with 20 cadences
          % startingPeriod = dataStep*20;
          % % end with 5 years (20 quarter lengths)
          % lambdaStep = (dataLength*20-startingPeriod) / obj.nTargets;
            %******************************
            %******************************


            startingLog = log10(startingPeriod);
            endingLog = log10((obj.nTargets-1)*lambdaStep+startingPeriod);
            logStep = (endingLog - startingLog) / (nSineWaveTargets-1);
            % Randomize distribution
            randomLambda =  [startingLog: logStep :endingLog];
            randomLambda = randomLambda(randperm(length(randomLambda)));
            obj.lambda(selectedTargets) = randomLambda;
            obj.lambda(selectedTargets) = 10.^obj.lambda(selectedTargets);

            k = 2 * pi ./ obj.lambda;

            %************
            % generate some sine waves
            % only inject signals into targets selected.
            for iTarget = 1 : obj.nTargets
                if (selectedTargets(iTarget))
                    obj.stellarSignal(:,iTarget) = A(iTarget) .* sin(k(iTarget).*x + phase(iTarget));

                    % Zero gaps
                    gaps = obj.inputsStructOriginal.cadenceTimes.gapIndicators;
                    obj.stellarSignal(gaps,iTarget) = 0.0;
                end
            end

            %************
            % Iterate with whitener
            for iWhiten = 1 : obj.numWhitenIterations

                A = whiten_spectrum (obj, A, obj.stellarSignal);

                for iTarget = 1 : obj.nTargets
                    obj.stellarSignal(:,iTarget) = A(iTarget) .* sin(k(iTarget).*x + phase(iTarget));
                end

            end
        end

        %*************************************************************************************************************
        function [] = inject_simulated_stellar_oscillator (obj, selectedTargets, signalAmplitude)
    
            % record these targets as being injected with stellar oscillators (in addtion to any others already injected with stellar oscillators)
            obj.targetsInjectedWithStellarOscillators = selectedTargets | obj.targetsInjectedWithStellarOscillators;
            nSelectedTargets = length(find(selectedTargets));

            x = [obj.inputsStructInjected.cadenceTimes.midTimestamps];
            dataStep = median(diff(x(x>0)));

            % Amplitude
            A = (signalAmplitude) .* ones(1,obj.nTargets);

            % Phase (uniform distribution in 2 PI)
            phase = 2 * pi * rand(1, obj.nTargets);

            % modifier is also uniform distribution
            step = (max(obj.stellarOscillatorModifierRange) - min(obj.stellarOscillatorModifierRange)) / (nSelectedTargets-1);
            sShort = min(obj.stellarOscillatorModifierRange): step : max(obj.stellarOscillatorModifierRange);
            % Radomize distribution
            sShort = sShort(randperm(length(sShort)));
            s(selectedTargets) = sShort;

            %************
            % Wavelength (Or periods per quarter)
            % Create linear wavelength distribution in log
            % Uniform distribution from 20 cadences to full data length
            % Gapped data is zeroed so only look for minimum that's greater than zero.
            dataLength = max(x) - min(x(x>0));

            startingPeriod = dataStep*20;
            lambdaStep = (dataLength-startingPeriod) / obj.nTargets;
            startingLog = log10(startingPeriod);
            endingLog = log10((obj.nTargets-1)*lambdaStep+startingPeriod);
            logStep = (endingLog - startingLog) / (nSelectedTargets-1);
            % Radomize distribution
            randomLambda =  [startingLog: logStep :endingLog];
            randomLambda = randomLambda(randperm(length(randomLambda)));
            obj.lambda(selectedTargets) = randomLambda;
            obj.lambda(selectedTargets) = 10.^obj.lambda(selectedTargets);

            k = 2 * pi ./ obj.lambda;

            stellarOscillator = obj.generate_simulated_stellar_oscillator ();

            %************
            % generate some signals
            % only inject signals into targets selected.
            gaps = obj.inputsStructOriginal.cadenceTimes.gapIndicators;
            for iTarget = 1 : obj.nTargets
                if (selectedTargets(iTarget))
                    % normalize amplitude to one unit (range of two units, just like a sine wave).
                    signal = stellarOscillator(x, k(iTarget), s(iTarget), phase(iTarget));
                    signal = signal - (max(signal) - (range(signal)/2));
                    obj.stellarSignal(:,iTarget) = A(iTarget) .* signal ./ (range(signal)/2);

                    % Zero cadence time gaps gaps
                    obj.stellarSignal(gaps,iTarget) = 0.0;
                end
            end

        end

        %*************************************************************************************************************
        function [] = inject_soho_data (obj, signalAmplitude)

        % Time period of SOHO data to use (from data end):
            % Most recent (noisier)
            % A lot of missing data right at the end of data set so back track away from this.
            % virgoBacktrackData = 100;
            % Really noisy
            % virgoBacktrackData = 149712 - 49160;
            % Really quiet
              virgoBacktrackData = 149712 - 116000;

            % Inject into every target
            obj.targetsInjectedWithSoho = true(obj.nTargets, 1);

            % Import SOHO Virgo data

            rawVirgoData = importdata('/path/to/stellar_variability_preservation/soho_virgo_data/virgo_tsi_h_v6_002_1302.dat', ' ', 62);

            rawVirgoData = rawVirgoData.data;

            % NaN missing data
            rawVirgoData(rawVirgoData == -99) = nan;
            
            % I could be really clever and convert the date stamps to MJD but I knwo the dates stamsp are every hour -- I want every half hour. The phase is
            % unimportant!
            % Data given in hour increments. Interpolate to get half hour cadences (ignore the error since 1 LC .ne. 0.5 hours)
            virgoCadence = [1:2:obj.nCadences];
            keplerCadence = [1:obj.nCadences];
            virgoData = spline(virgoCadence, rawVirgoData(end-virgoBacktrackData-(obj.nCadences/2.0):end-virgoBacktrackData ,3), keplerCadence);

            % Normalize amplitude to one unit about zero (range of two units, just like a sine wave).
            virgoData = virgoData - (max(virgoData) - (range(virgoData)/2));
            virgoData = signalAmplitude * virgoData ./ (range(virgoData)/2);

            gaps = obj.inputsStructOriginal.cadenceTimes.gapIndicators;
            for iTarget = 1 : obj.nTargets
                if (obj.targetsInjectedWithSoho(iTarget))
                    obj.stellarSignal(:,iTarget) = virgoData;

                    % Zero cadence time gaps gaps
                    obj.stellarSignal(gaps,iTarget) = 0.0;
                end
            end
        end

        %*************************************************************************************************************
        % Returns a whitened spectrum by adjusting injecting signal amplitudes
        function [A] = whiten_spectrum (obj, A, signals)
    
            % Find periodograms
            [periodograms, ~] = obj.find_periodograms (signals);

            maxOfPeriodograms = max(periodograms);

            % Normalize amplitudes by signal amplitudes of highest frequency
            baseStrength = min(maxOfPeriodograms);

            % Amplitudes scale with square root of Periodogram strength 
            A = A .* (sqrt(baseStrength ./ maxOfPeriodograms));

        end

        %*************************************************************************************************************
        % Injectes White Gaussian Noise
        function [] = inject_WGN (obj, injectionType)
    
            % Pick targets to inject signals into
            selectedTargets = obj.select_targets (injectionType);
            obj.targetsInjectedWithWGN = selectedTargets;

            % Amplitude
           %A =(obj.signalAmplitude) .* randn(1,obj.nTargets);
            A =(obj.signalAmplitude) .* ones(1,obj.nTargets);

            %************
            % White Gaussian Noise can be easily generated with randn
            % Just inject on selected signals
            obj.stellarSignal(:, selectedTargets) = repmat(A(selectedTargets), [obj.nCadences,1]) .* ...
                randn(obj.nCadences, length(find(selectedTargets)));

        end

        %*************************************************************************************************************
        % Find periodgrams for a selection of signals (all same length), the frequency distribution will be
        % the same for all signals so only one frequency array is returned. The periodogram length is
        % calculated in the class constructor
        function [periodograms, frequency] = find_periodograms (obj, signals)

            if(size(signals,1) ~= obj.nCadences)
                error ('FIND_PERIODOGRAMS: length of signals must be obj.nCadences');
            elseif (size(signals,2) ~= obj.nTargets)
                error ('FIND_PERIODOGRAMS: number of signals must be obj.nTargets');
            end

            periodograms = zeros(obj.periodogramLength , obj.nTargets);

            for iTarget = 1 : obj.nTargets
                if (iTarget == 1)
                    % If first call then also get frequencies (which should be the same for all periodogram)
                    [periodograms(:,iTarget), frequency] = periodogram(signals(:,iTarget));
                else
                    [periodograms(:,iTarget), ~] = periodogram(signals(:,iTarget));
                end
            end
        end

        %*************************************************************************************************************
        % Average (median) over all WGN injected targets
        function [periodogramMedian, periodogramStd, frequency] = find_periodogram_median (obj, signals, selectedTargets, smoothWindow)

            nSelectedTargets = length(find(selectedTargets));

            [periodograms, frequency] = obj.find_periodograms (signals);

            % Average over all selected targets
            periodogramMedian   = median(periodograms(:,selectedTargets),2);
            %periodogramStd      = std(periodograms(:,selectedTargets),1,2);
            periodogramStd       = mad(periodograms(:,selectedTargets)',1) * 1.4826;

          %******

            % Smooth over length <smoothLength> using Savitsky-Golay filter
            % Only perform if smooth window is shorter than data length
            if (smoothWindow ~= 0 && (smoothWindow < length(sumPeriodogram)))
                % window must be odd
                if (mod(smoothWindow,2) == 0)
                    smoothWindow = smoothWindow - 1;
                end
                % Smooth in log10 so that it looks smooth in log10 (for plotting) and negative values not created
                sumPeriodogram = sgolayfilt(log10(sumPeriodogram), 3, smoothWindow);
                sumPeriodogram = 10.^sumPeriodogram;
            end

        end

        %*************************************************************************************************************
        % Pick a selection of targets to inject signals into

        function [selectedTargets] = select_targets (obj, injectionType)

            switch injectionType

            case ('all')

                % Just select them all
                selectedTargets = true(obj.nTargets, 1);

            case ('quiet')
                % Find the quiet Targets
                selectedTargets = obj.find_quiet_targets;

            case ('half')

                % Select a random half if the other half has not already been selected
                % If half has already been selected then select the "other" half
                if (~isempty(obj.allSelected) && obj.allSelected)
                    error('SELECT_TARGETS: Both halves already selected!');
                elseif (isempty(obj.halfAlreadySelected))
                    selectTheseTargets = randperm(obj.nTargets);
                    maxTarget = floor(obj.nTargets / 2);
                    selectTheseTargets = selectTheseTargets(1:maxTarget);

                    selectedTargets = false(obj.nTargets, 1);
                    selectedTargets(selectTheseTargets) = true;
                    obj.halfAlreadySelected = selectedTargets;
                    obj.allSelected = false;
                else
                    % Pick the other half
                    selectedTargets = ~obj.halfAlreadySelected;
                    obj.allSelected = true;
                end

            case ('quarter')

                if (~isempty(obj.halfAlreadySelected))
                    error('YOU FOOL!');
                else
                    selectTheseTargets = randperm(obj.nTargets);
                    maxTarget = floor(obj.nTargets / 4);
                    selectTheseTargets = selectTheseTargets(1:maxTarget);

                    selectedTargets = false(obj.nTargets, 1);
                    selectedTargets(selectTheseTargets) = true;
                    obj.halfAlreadySelected = selectedTargets;
                    obj.allSelected = false;
                end
    
            case ({'sineAmplitudeStudy', 'simulatedStellarAmplitudeStudy'})

                % Evenly divide all targets amongst the obj.nAmplitudes
                nTargetsPerAmplitude = floor(obj.nTargets / obj.ampStudy.nAmplitudes);

                % selectedTargets is here used as a struct array giving a logical array of which targets are used for each amplitude
                selectedTargets = repmat(struct('targets', false(obj.nTargets,1)), [obj.ampStudy.nAmplitudes,1]);
                randPermedTargets = randperm(obj.nTargets);
                startTargetIndex = 1;
                for iAmp = 1 : obj.ampStudy.nAmplitudes
                    endTargetIndex = startTargetIndex + nTargetsPerAmplitude - 1;
                    selectedTargets(iAmp).targets(randPermedTargets(startTargetIndex:endTargetIndex)) = true;
                    startTargetIndex = endTargetIndex + 1;
                end

            case ('quietSineAmplitudeStudy')
                % Select just the quiet targets and evenly divide amongst the amplitudes

                % Find the quiet Targets
                quietTargets = obj.find_quiet_targets;
                quietTargetIndices = find(quietTargets);

                % Evenly divide all targets amongst the obj.nAmplitudes
                nTargetsPerAmplitude = floor(length(quietTargetIndices) / obj.ampStudy.nAmplitudes);

                % selectedTargets is here used as a struct array giving a logical array of which targets are used for each amplitude
                selectedTargets = repmat(struct('targets', false(obj.nTargets,1)), [obj.ampStudy.nAmplitudes,1]);
                randPermedTargets = randperm(length(quietTargetIndices));
                startTargetIndex = 1;
                for iAmp = 1 : obj.ampStudy.nAmplitudes
                    endTargetIndex = startTargetIndex + nTargetsPerAmplitude - 1;
                    selectedTargets(iAmp).targets(quietTargetIndices(randPermedTargets(startTargetIndex:endTargetIndex))) = true;
                    startTargetIndex = endTargetIndex + 1;
                end

            otherwise
                error ('SELECT_TARGETS: Unknown target selection method');
            end

        end

        %*************************************************************************************************************
        % Finds the quiet targets based on the stellar variability as calculated from the original run.
        %
        function [quietTargets] = find_quiet_targets(obj)

            % Use the default MAP variability cutoff value
           %variabilityCutoff = obj.inputsStructOriginal.mapConfigurationStruct.variabilityCutoff;
            variabilityCutoff = obj.stellarVariabilityCutoff ;

            if (isempty(obj.outputsStructOriginal));
                if (~obj.debugRun)
                    error('OutputsStruct from original run not found, yet not a debug run! Somethign is wrong!');
                end
                display('Calculating stellar variability for debug run...');
                % Must calculate the stellar variability for this debug run
                coarseDetrendPolyOrder = 3;
                doNormalizeFlux = true;
                doMaskEpRecovery = true;
                maskWindow = 150;
                doRemoveTransits = true;
                [stellarVariability, ~] = pdc_calculate_stellar_variability ...
                    (obj.inputsStructOriginal.targetDataStruct, obj.inputsStructOriginal.cadenceTimes, coarseDetrendPolyOrder, doNormalizeFlux, ...
                        doMaskEpRecovery, maskWindow, doRemoveTransits);
                stellarVariability = stellarVariability';
            else
                stellarVariability = [obj.outputsStructOriginal.targetResultsStruct];
                stellarVariability = [stellarVariability.pdcProcessingStruct];
                stellarVariability = [stellarVariability.targetVariability];
            end

            quietTargets = stellarVariability' < variabilityCutoff;
        end

        %*****************************************************************************************************
        % Find the relative difference between the injected signal and the difference between the outputs from
        % the two runs:
        % stellarSignalDiff = [(outputFluxInjected - outputFluxOriginal) - scaledStellarSignal] / std(scaledStellarSignal)
        %
        function find_stellar_signal_difference(obj)

            display('Generating Stellar Signal Differences...');

            obj.lightCurveDiff = zeros(obj.nCadences, obj.nTargets);
            obj.stellarSignalDiff = zeros(obj.nCadences, obj.nTargets);
            for iTarget = 1 : obj.nTargets

                % Get signal differences
                if (obj.debugRun)
                    gaps = obj.inputsStructOriginal.targetDataStruct(iTarget).gapIndicators;
                    obj.lightCurveDiff(:,iTarget) = obj.inputsStructInjected.targetDataStruct(iTarget).values ...
                                   - obj.inputsStructOriginal.targetDataStruct(iTarget).values;
                    % Fill gaps with the original stellar signal so that the gap filler does not count against the preserved signal
                    obj.lightCurveDiff(gaps,iTarget) = obj.stellarSignal(gaps,iTarget);
                else
                    obj.lightCurveDiff(:,iTarget) = obj.outputsStructInjected.targetResultsStruct(iTarget).correctedFluxTimeSeries.values ...
                               - obj.outputsStructOriginal.targetResultsStruct(iTarget).correctedFluxTimeSeries.values;
                    % Fill gaps with the original stellar signal so that the gap filler does not count against the preserved signal
                    obj.lightCurveDiff(obj.outputsGaps(:,iTarget),iTarget) = obj.scaledStellarSignal(obj.outputsGaps(:,iTarget),iTarget);
                                                                                %mean(obj.lightCurveDiff(~obj.outputsGaps(:,iTarget),iTarget));
                end

                % Relative injected signal difference
                if (obj.debugRun)
                    obj.stellarSignalDiff(:,iTarget) = ...
                        (obj.lightCurveDiff(:,iTarget) - obj.stellarSignal(:,iTarget)) ./ std(obj.stellarSignal(~gaps,iTarget));
                else
                    % If real run then output is scaled by flux fraction so need to use scaled stellar signal
                    % as well
                    obj.stellarSignalDiff(:,iTarget) = (obj.lightCurveDiff(:,iTarget) - obj.scaledStellarSignal(:,iTarget)) ./ ...
                                    std(obj.scaledStellarSignal(~obj.outputsGaps(:,iTarget),iTarget));
                end

            end

            display('Finished generating Stellar Signal Differences.');

        end

        %*************************************************************************************************************
        % This computes the standard deviation of the stellar signal difference as calculated by find_stellar_signal_difference
        function find_stellar_signal_diff_std (obj)

            obj.stellarSignalDiffStd = zeros(obj.nTargets,1);
            for iTarget = 1 : obj.nTargets
                gaps = obj.inputsStructOriginal.targetDataStruct(iTarget).gapIndicators;

                obj.stellarSignalDiffStd(iTarget) = std(obj.stellarSignalDiff(~gaps,iTarget));
            end
        end

        %*************************************************************************************************************
        % This function computes the change in the amplitude of the sine wave by looking at the sqrt of the PSD at the frequency of the sine-wave.
        function find_at_frequency_corruption (obj)
 
            % periodograms of corruption
            [periodograms, frequency] = obj.find_periodograms(obj.stellarSignalDiff);
            
            % If debug run then using the input flux as the reference which is not scaled by flux fraction or crowding metric, so, 
            % do NOT use the scaledStellarSignal for comparisons
            if (obj.debugRun)
                % Create temp matrix with gaps naned for nanstd calculation (don't want gaps to influence std)
                temp = obj.stellarSignal;
                temp(obj.outputsGaps) = nan;
                fullCorruptionSignal = obj.stellarSignal ./ repmat(nanstd(temp), [obj.nCadences,1]);
            else
                % Create temp matrix with gaps naned for nanstd calculation (don't want gaps to influence std)
                temp = obj.scaledStellarSignal;
                temp(obj.outputsGaps) = nan;
                fullCorruptionSignal = obj.scaledStellarSignal ./ repmat(nanstd(temp), [obj.nCadences,1]);
            end
            [fullCorruptionPeriodograms, ~] = obj.find_periodograms(fullCorruptionSignal);
            frequencyOfInjectedSignal = (obj.cadencesPerTwoPiRads * obj.lambda).^-1;

            obj.atFreqCorruptionAmount = zeros(obj.nTargets, 1);
            for iTarget = 1 : obj.nTargets
                [~, periodogramFreqOfInjectedSignalLoc] =  min(abs(frequency - frequencyOfInjectedSignal(iTarget)));
                obj.atFreqCorruptionAmount(iTarget) = sqrt(periodograms(periodogramFreqOfInjectedSignalLoc, iTarget)) ./ ...
                        sqrt(fullCorruptionPeriodograms(periodogramFreqOfInjectedSignalLoc, iTarget));
            end

        end

        %*************************************************************************************************************
        % Smooths data in log10 so that the data looks smooth in a log plot. Uses Savitsky-Golay filter
        %
        % The smoothing window is 1/smoothFactor the data length. If smoothing cannot be performed then smoothCurve = [].
        %
        % Also finds a windowed standard deviation where the window length is <smoothFactor>
        %
        % Inputs:
        %   data    -- [float array] the data to smooth
        %   lambda  -- [float array] the wavelengths (or periods) for the injected wine wave for each targets
        %
        % Outputs:
        %   smoothCurve     -- [float array] Smooth curve to the data
        %   smoothCurveStd  -- [float array] standard deviation using the smoothFactor window
        %   lambdaSorted    -- [float array] The lambda array sorted
        %
        function [smoothCurve, smoothCurveStd, lambdaSorted] = generate_smooth_log10_curve_to_data (obj, data, lambda, smoothFactor)

            polyOrder = 3;
            nDatums = length(data);

            if (length(lambda) ~= nDatums)
                error('generate_smooth_log10_curve_to_data: lambda array is not same length as data array')
            end

            % Smooth in log10 so that it looks smooth in log10 (for plotting) and negative values are not created
            smoothWindow = floor(nDatums / smoothFactor);
            % Smooth window must be odd
            if (mod(smoothWindow,2) == 0)
                smoothWindow = smoothWindow - 1;
            end
            % for SGfilter the smooth window must be greater than the polynomial order
            if (smoothWindow > polyOrder)
                % Need to re-sort data by wavelength
                [lambdaSorted, sortOrder] = sort(lambda);
                dataSorted = data(sortOrder);
                smoothCurve = sgolayfilt(log10(dataSorted), 3, smoothWindow);
                smoothCurve = 10.^smoothCurve;

                smoothCurveStd = zeros(length(dataSorted),1);
                halfSmoothWindow = round(smoothWindow/2);
                halfSmoothWindow = 3;
                for i = 1 : length(dataSorted)
                    % This is a travelling window standard deviation
                    % Need to deal with edges of data
                    firstDatum = max(1,i-halfSmoothWindow);
                    lastDatum = min(length(dataSorted), i+halfSmoothWindow);
                   %smoothCurveStd(i) = 10.^std(log10(dataSorted(firstDatum:lastDatum)));
                    smoothCurveStd(i) = std(dataSorted(firstDatum:lastDatum));
                end

            else
                % Too few datums to do any smoothing just pass back the datums
                [lambdaSorted, sortOrder] = sort(lambda);
                smoothCurve = data(sortOrder);
                smoothCurveStd = zeros(length(data),1);  
            end
            
        end

        %*************************************************************************************************************
        % Find the intersection of a curve Y and a specific value YIntersect of the scale X
        % Also return the error bar estimate on the x intersection value

        function [xIntersectionValue, xIntersectionStd, smoothCurve, smoothCurveStd] = find_curve_intersection (obj, Y, X, YIntersect)

            % Find root of YShifted by finding the median of all zero intersections
            YShifted = Y - YIntersect;

            smoothFactor = obj.smoothFactor;
            noRoots = false;
            oneRoot = false;
            % Smooth until there is only one root
            while(~oneRoot && ~noRoots)
                [smoothCurve, smoothCurveStd, XSorted] = generate_smooth_log10_curve_to_data (obj, Y, X, smoothFactor);
                smoothShifted = smoothCurve - YIntersect;

                % find number of positive going roots
                positiveRootHere  = false(length(Y),1);
                for i = 1: length(Y)-1
                    positiveRootHere(i) = smoothShifted(i) < 0.0 && smoothShifted(i+1) > 0.0;
                end
                oneRoot = sum(positiveRootHere) == 1;
                noRoots = sum(positiveRootHere) == 0;

                smoothFactor = smoothFactor / 1.2;
                if (smoothFactor <= 1.0)
                    noRoots = true;
                end
            end

            if (noRoots)
                if (all(smoothShifted < 0.0))
                    % If all points below root then set intersection to largest value in period range
                    [xIntersectionValue, index] = max(XSorted);
                    xIntersectionStd = 0.0;
                elseif (all(smoothShifted > 0.0))
                    % If all points above root then set intersection to smallest value in period range
                    [xIntersectionValue, index] = min(XSorted);
                    xIntersectionStd = 0.0;
                else
                    % For odd curves that do not fit into the two expected catagories above set to minimum period
                    [xIntersectionValue, index] = min(XSorted);
                    xIntersectionStd = 0.0;
                end
            else
                % TODO: interpolate bracket to root
                xIntersectionValue = XSorted(positiveRootHere);

                % For error on the root, need to find the first and last curve value stds that hit the root
                % First curve value that hits root, back up until error bars outside of root value
                % For cases where all or most points are above the root and yet error bars cross the root this method 
                % can cause the error bars to be too large
                for iLower = find(positiveRootHere) : -1 : 1
                    % break when no longer within root
                    if ((smoothShifted(iLower)+smoothCurveStd(iLower)) < 0.0)
                        break;
                    end
                end
                % last curve value that hits root, move forward until error bars outside of root value
                for iUpper = find(positiveRootHere) : length(smoothShifted)
                    % break when no longer within root
                    if ((smoothShifted(iUpper)-smoothCurveStd(iUpper)) > 0.0)
                        break;
                    end
                end
                xIntersectionStd = (XSorted(iUpper) - XSorted(iLower)) / 2.0;
                % For cases where all or most points are above the root and yet error bars cross the root this method 
                % can cause the error bars to be too large
                % For now, if error bars cross zero then set to height of intersection value.
                if(xIntersectionValue - xIntersectionStd <= 0.0)
                   %xIntersectionStd = 0.0;
                    xIntersectionStd = xIntersectionValue;
                end
            end

        end

        %*************************************************************************************************************
        % timestamp = the cadence timestamps
        % k = wavenumber (i.e. wavelength)
        % s = modifying sinewave (uses obj.stellarOscillatorModifierRange)
        % phase = phase slip

        function functionHandle = generate_simulated_stellar_oscillator (obj)

            functionHandle = @(timestamp, k, s, phase) sin((3/2)*k*timestamp + phase)+ 2*sin(k*timestamp + phase) + s*sin(2*k*timestamp + phase);

        end


    end % Private methods

%*******************************************************************************
% Methods used for post-analysis or wrapping a full FOV run
    methods (Static = true)

    %*************************************************************************************************************
    % function perform_stellar_preservation_study_over_all_tasks (subTasksToRun, doSaveStellarPreserveObject, varargin)
    % 
    % Runs the stellar preservation test over all tasks in the current direcotry path.
    % Run this function in the direcotry with all the pdc-matlab-* subdirectories
    %
    % Since we will be running on many channels the stellarPreserveObjects can take up a lot of room. So there is an option to not save them to file.
    %
    %
    %
    % Inputs:
    %   subTasksToRun               -- [string cell or integer array] a list of the tasks to run (the last 6 digits of each pdc-matlab-#####-######)
    %   doSaveStellarPreserveObject -- [logical] True means keep the stellarPreserveObject files in each task directory
    %   signalType                  -- [char Optional] Type of signal to inject (see pdcStellarPreserveClass.inject_signals)
    %                                       default: 'sineAmplitudeStudy'
    %   signalAmplitude             -- [float Optional] Amplitude of injected signal, relative to target std of flux
    %                                       default: 1.0
    %   debugRun                    -- [logical Optional] If true then PDC never called, just tests internal functionality
    %                                       default: false
    % Ouputs:
    %   none
    %
    function perform_stellar_preservation_study_over_all_tasks (subTasksToRun, doSaveStellarPreserveObject, varargin)

       %dirNames = dir('pdc-matlab-*');
        dirNames = dir;
 
        if (length(dirNames) < 1)
            error ('There appears to be no task subdirectories!');
        end
 
        nDirs = length(dirNames);
        for iDir = 1 : length(dirNames)
            % Check if this task is one requested to run (strFind only operates on a single string, so need for-loop)
            runThisTask = false;
            for iTask = 1 : length(subTasksToRun)
                if (isnumeric(subTasksToRun(iTask)))
                    % convert to string
                    stringToFind = num2str(subTasksToRun(iTask));
                else
                    stringToFind = subTasksToRun{iTask};
                end
                if (strfind(dirNames(iDir).name, stringToFind ))
                    runThisTask = true;
                    break;
                end
            end

            if (runThisTask)
                display(['Working on task directory ', num2str(iDir), ' of ', num2str(length(subTasksToRun))]);
                
                cd (dirNames(iDir).name);
                % Work through each 'st-*' subdirectory
                subDirNames = dir('st-*');
                nSubDirs = length(subDirNames);
                if (nSubDirs == 0)
                    % Then this could be a single, non-st directory
                    if (exist('pdc-inputs-0.mat', 'file'))
                        nSubDirs = 1;
                        subDirNames(1).name = '.';
                    end
                end
                for iSubDir = 1 : nSubDirs
                    cd (subDirNames(iSubDir).name);
                    
                    % If amplitude_study.fig exists then this subtask has
                    % already run => skip
                    if (exist('amplitude_study.fig', 'file'))
                        cd ..
                        continue;
                    end
                
                    load 'pdc-inputs-0.mat'
                    % Run the Stellar Preservation Study
                    [~] = pdc_stellar_preservation_test (inputsStruct, [], [], varargin{:});
                    close all;
                    
                    % pdc_stellar_preservation_test  saves the stellPreservObject so if we don't want it we should delete it
                    if (~doSaveStellarPreserveObject)
                        delete ('stellarPreserveObject.mat');
                    end

                    if (~strcmp(subDirNames(iSubDir).name, '.'))
                        cd ..
                    end
                end
                
                cd ..
            end


        end

    end % perform_stellar_preservation_sturyd_over_all_tasks 

             
    %*************************************************************************************************************
    % This function works on data produced from an amplitude study run or a fixed amplitude run. It loads the figures and takes the 
    % data from the figures (instead of loading in the very huge pdcStellarPreservObjects.
    %
    % It copies all amplitude_study.fig, amplitude_corruption.fig and amplitude_corruption_box_plot.fig figures to ./processed_data 
    % and renames them with quarter, module and output.
    %
    % It then calls pdcStellarPreserveClass.create_summary_data_from_amplitude_figures to create the summaryData struct.
    %
    % Inputs:
    %
    % Outputs:
    %   summaryData(:)              -- [struct array(nTasks)] summary data for the collected data
    %       .quarter
    %       .module
    %       .output
    %       .amplitudeStudy     -- [struct] summary data from amplitude study figures for each task
    %           .onePercent.amplitude
    %           .onePercent.period
    %           .tenPercent.amplitude
    %           .tenPercent.period
    %           .fiftyPercent.amplitude
    %           .fiftyPercent.period
    %       .singleAmplitude    -- [struct] summary data from a single amplitude value run for each task, generated from box plot
    %           .period
    %           .median
    %           .twentyFifthPrctle
    %           .seventyFifthPrctle
    %

    function [summaryData] = pdc_process_stellar_preservation_data ()

        outputDirectory = './processed_data';

        if (~exist(outputDirectory, 'dir'))
            mkdir(outputDirectory);
        end
 
       %dirNames = dir('pdc-matlab-*');
        dirNames = dir;

        % Remove '.' and '..' and 'outputDirectory
        dirNames(strcmpi('.', {dirNames.name})) = [];
        dirNames(strcmpi('..', {dirNames.name})) = [];
        dirNames(strcmpi(outputDirectory(3:end), {dirNames.name})) = [];
 
        if (length(dirNames) < 1)
            error ('There appears to be no task subdirectories!');
        end
 
        figureHandles = [];
        nDirs = length(dirNames);
        for iDir = 1 : length(dirNames)
            display(['Working on task directory ', num2str(iDir), ' of ', num2str(nDirs)]);
 
            cd (dirNames(iDir).name);
            % Work through each 'st-*' subdirectory, if they exist
            subDirNames = dir('st-*');
            nSubDirs = length(subDirNames);
            if (nSubDirs == 0)
                nSubDirs = 1;
                subDirNames(1).name = '.';
            end
            for iSubDir = 1 : nSubDirs
                cd (subDirNames(iSubDir).name);
             
                % collect the task mod.out, quarter and stellar preservation information.
                % Copy the amplitude_study.fig to a seperate directory.
             
                load 'pdc-inputs-0.mat'

                inputsStruct = pdcInputClass.process_channelDataStruct(inputsStruct);

                module = inputsStruct.ccdModule;
                output = inputsStruct.ccdOutput;
 
                quarter = convert_from_cadence_to_quarter (inputsStruct.startCadence, inputsStruct.cadenceType);
                % quarter is the integer part
                quarter = quarter - rem(quarter,1);
                % month is the decimal part, if zero then this is LC full quarter data
                month = rem(quarter,1);
 

                if (exist('amplitude_study.fig', 'file'))
                    figureFilename = ['Q', num2str(quarter), '_', num2str(module), '.', num2str(output), '_amplitude_study.fig'];
                    display(['copying file ', figureFilename]);
                    copyfile('amplitude_study.fig', ['../', outputDirectory, '/', figureFilename]);
                end
 
                if (exist('amplitude_corruption.fig', 'file'))
                    figureFilename = ['Q', num2str(quarter), '_', num2str(module), '.', num2str(output), '_amplitude_corruption.fig'];
                    display(['copying file ', figureFilename]);
                    copyfile('amplitude_corruption.fig', ['../', outputDirectory, '/', figureFilename]);
                end
 
                if (exist('amplitude_corruption_box_plot.fig', 'file'))
                    figureFilename = ['Q', num2str(quarter), '_', num2str(module), '.', num2str(output), '_amplitude_corruption_box_plot.fig'];
                    display(['copying file ', figureFilename]);
                    copyfile('amplitude_corruption_box_plot.fig', ['../', outputDirectory, '/', figureFilename]);
                end
 
                if (~strcmp(subDirNames(iSubDir).name, '.'));
                    cd ..
                end
            end
            cd ..
        end

       %currentPath = pwd;
       %cd(outputDirectory);

        [summaryData] = pdcStellarPreserveClass.create_summary_data_from_amplitude_figures (outputDirectory);

       %cd(currentPath);
 
    end

    %*************************************************************************************************************
    % Takes the amplitude_*.fig figures all located in one directory and generates a summaryData struct containing the data in the figures.
    %
    % Inputs:
    %   dataDirectory -- [char] directory path to where figures are located and where the summary data will be saved
    %
    % Outputs:
    %

    function [summaryData] = create_summary_data_from_amplitude_figures (dataDirectory)

        allFileNames                    = dir([dataDirectory, '/', '*_amplitude_*.fig']);
        ampStudyFileNames               = dir([dataDirectory, '/', '*_amplitude_study.fig']);
        ampCorruptionFileNames          = dir([dataDirectory, '/', '*_amplitude_corruption.fig']);
        ampCorruptionBoxPlotFileNames   = dir([dataDirectory, '/', '*_amplitude_corruption_box_plot.fig']);


        summaryData = repmat(struct('quarter', [], 'module', [], 'output', [], 'amplitudeStudy', [], 'singleAmplitude', []), [0,1]);

        if (length(ampStudyFileNames) + length(ampCorruptionFileNames) + length(ampCorruptionBoxPlotFileNames) ~= length(allFileNames))
            error('Unexpected amplitude corruption plots detected');
        end
 
        for iFile = 1 : length(allFileNames)

            %***
            % Get quarter, module and output
            thisFileName = allFileNames(iFile).name;

            underscores = strfind(thisFileName, '_');
            firstUnderscore = underscores(1);
            secondUnderscore = underscores(2);
            if (isempty(firstUnderscore))
                error('an *_amplitude_*.fig figure appears to not be named correctly')
            end
            quarter = str2num(thisFileName(2:firstUnderscore-1));

            periods = strfind(thisFileName, '.');
            firstPeriod = periods(1);
            if (isempty(firstPeriod))
                error('an *_amplitude_*,fig figure appears to not be named correctly')
            end
            module = str2num(thisFileName(firstUnderscore+1:firstPeriod-1));

            if (isempty(secondUnderscore))
                error('an *_amplitude_*,fig figure appears to not be named correctly')
            end
            output = str2num(thisFileName(firstPeriod+1:secondUnderscore-1));
            %***
            % Create or find already created summaryData entry

            % Find an entry already for this unit of work
            entryFound = false;
            for iEntry = 1 : length(summaryData)

                if (summaryData(iEntry).quarter == quarter && summaryData(iEntry).module == module && summaryData(iEntry).output == output)
                    entryFound = true;
                    break;
                end
            end

            % Entry not found, create an entry for this task
            if (~entryFound)
                iEntry= length(summaryData) + 1;
                summaryData(iEntry).quarter  = quarter;
                summaryData(iEntry).module   = module;
                summaryData(iEntry).output   = output;
            end

            %***
                
            % Need to rename figure with .mat ending so that the data can be loaded
            secondPeriod= periods(2);
            tempFilename = [dataDirectory, '/', thisFileName(1:secondPeriod), 'mat'];
            copyfile([dataDirectory, '/', thisFileName(1:secondPeriod), 'fig'], tempFilename);

            data = load([dataDirectory, '/', thisFileName(1:secondPeriod), 'mat']);
            delete(tempFilename);

            % get name of struct
            structname = fieldnames(data);
            data = data.(structname{1});

            % Amplitude study figure
            if (regexp(thisFileName, '\w_amplitude_study.fig'))

                onePercentData   = data.children(1).children(1).properties;
                tenPercentData   = data.children(1).children(2).properties;
                fiftyPercentData = data.children(1).children(3).properties;
                
                % Confirm we got the correct data
                % We *should* never see these errors since the order of the children should never change. But we should throw an error if they do.
                if (~strcmp(onePercentData.DisplayName, '1% Corruption'))
                    error ('1% Corruption data not found!');
                elseif (~strcmp(tenPercentData.DisplayName, '10% Corruption'))
                    error ('10% Corruption data not found!');
                elseif (~strcmp(fiftyPercentData.DisplayName, '50% Corruption'))
                    error ('50% Corruption data not found!');
                end
                
                summaryData(iEntry).amplitudeStudy.onePercent.amplitude   = onePercentData.XData;
                summaryData(iEntry).amplitudeStudy.onePercent.period      = onePercentData.YData;
                summaryData(iEntry).amplitudeStudy.tenPercent.amplitude   = tenPercentData.XData;
                summaryData(iEntry).amplitudeStudy.tenPercent.period      = tenPercentData.YData;
                summaryData(iEntry).amplitudeStudy.fiftyPercent.amplitude = fiftyPercentData.XData;
                summaryData(iEntry).amplitudeStudy.fiftyPercent.period    = fiftyPercentData.YData;

            elseif (regexp(thisFileName, '\w_amplitude_corruption_box_plot.fig'))

                % Fix the text!
                set(gca,'YLim',[-5 0.5]);
                set(gca,'YTick',[-5 -4 -3 -2 -1 0 0.5]);
                YTickMarks = {'0.001%', '0.01%', '0.1%', '1%', '10%', '100%', ''};
                set(gca,'YTickLabel', YTickMarks,'FontSize', 10);
                hold off;
                xlabel('Period [days]', 'FontSize', 10);
                ylabel('Amplitude Corruption of Injected Signal [% Corruption]', 'FontSize', 10);
                title(['Corruption of Injected Sinusoids at Amplitude = ', num2str(1.0,'%4.2f'), ' * std(flux)'], 'FontSize', 12);
                saveas(gca, [dataDirectory, '/', thisFileName], 'fig');
                


                % Find the entries for median, period and 25th and 75th percentiles in box plot

                childArray = data.children.children(2).children;

                medianArray = [];
                periodMedianArray = [];
                twentyFifthPrctleArray = [];
                seventyFifthPrctleArray = [];
                periodBoxArray = [];

                for iChild = 1 : length(childArray)

                    % We must assume the order is the same for 'Median' and 'Box' 
                    % TODO: set up method

                    switch childArray(iChild).properties.Tag

                    case 'Median'
                        medianArray(end+1)          = childArray(iChild).properties.YData(1);
                        periodMedianArray(end+1)    = mean([min(childArray(iChild).properties.XData), max(childArray(iChild).properties.XData)]);

                    case 'Box'
                        twentyFifthPrctleArray(end+1)   = min(childArray(iChild).properties.YData);
                        seventyFifthPrctleArray(end+1)  = max(childArray(iChild).properties.YData);
                        periodBoxArray(end+1)           = mean([min(childArray(iChild).properties.XData), max(childArray(iChild).properties.XData)]);

                    end
                end

                % Get 50th and 75th percentiles data in same order as the median data
                if (~all(periodMedianArray == periodBoxArray))
                    error ('50th and 75th percentiles data in NOT in same order as the median data, need to write code to synchronize the data');
                end

                summaryData(iEntry).singleAmplitude.period = 10.^periodMedianArray;
                summaryData(iEntry).singleAmplitude.median = 10.^medianArray;
                summaryData(iEntry).singleAmplitude.twentyFifthPrctile = 10.^twentyFifthPrctleArray;
                summaryData(iEntry).singleAmplitude.seventyFifthPrctile = 10.^seventyFifthPrctleArray;

            end

            close all;
            
        end

        % save summary data to file
        save([dataDirectory, '/', 'summaryData'], 'summaryData');
 
    end


    %*************************************************************************************************************
    % plots the preservation performance data over the entire field of view for all channel data contained in summaryData
    %
    % Inputs:
    %   summaryData -- [struct] output from pdc_process_stellar_preservation_data
    %   quarter     -- [int] the quarter to plot
    %
    %

    function [] = plot_fov_metrics (summaryData, quarter)

        % only keep fields that are for this quarter
        keepThisIndex = false(length(summaryData),1);
        for iTask = 1 : length(summaryData)
            if (summaryData(iTask).quarter == quarter)
                keepThisIndex(iTask) = true;
            end
        end
        summaryData = summaryData(keepThisIndex);

        % Plot 1% values
        modules = [summaryData(:).module];
        outputs = [summaryData(:).output];

        % Find amplitude corruption period for signal amplitude = 1 * std(flux)
        % Since the exact value 1.0 may not be in the summaryData, linearly interpolate between the two values surrounding 1.0
        % Assume all data uses the same ranges!
        amplitudes = [summaryData(1).onePercent.amplitude];
        if (any(amplitudes == 1.0))
            % Then amp = 1.0 was an option!
            useThisIndex = find(amplitudes == 1.0);
            for iTask = 1 : length(modules)
                onePercentData(iTask)   = summaryData(iTask).onePercent.period(useThisIndex);
                tenPercentData(iTask)   = summaryData(iTask).tenPercent.period(useThisIndex);
                fiftyPercentData(iTask) = summaryData(iTask).fiftyPercent.period(useThisIndex);
            end
        else
            % Interpolate between the two nearest values
            justBelowIndex = find(amplitudes < 1.0, 1, 'last');
            justAboveIndex = find(amplitudes > 1.0, 1, 'first');
            for iTask = 1 : length(modules)
                x = [log10(amplitudes(justBelowIndex)), log10(amplitudes(justAboveIndex))];
                onePercentData(iTask) = interp1 (x, ...
                            [summaryData(iTask).onePercent.period(justBelowIndex), summaryData(iTask).onePercent.period(justAboveIndex)], log10(1.0));
                tenPercentData(iTask) = interp1 (x, ...
                            [summaryData(iTask).tenPercent.period(justBelowIndex), summaryData(iTask).tenPercent.period(justAboveIndex)], log10(1.0));
                fiftyPercentData(iTask) = interp1 (x, ...
                            [summaryData(iTask).fiftyPercent.period(justBelowIndex), summaryData(iTask).fiftyPercent.period(justAboveIndex)], log10(1.0));
            end
        end

       %% Pick the value nearest but just below relative amplitude of 1.0
       %useThisIndex = find(amplitudes < 1.0, 1, 'last');
       %chosenAmplitude = amplitudes(useThisIndex);
       %onePercentData = zeros(length(modules),1);
       %tenPercentData = zeros(length(modules),1);
       %fiftyPercentData = zeros(length(modules),1);
       %for iTask = 1 : length(modules)
       %    onePercentData(iTask)   = summaryData(iTask).onePercent.period(useThisIndex);
       %    tenPercentData(iTask)   = summaryData(iTask).tenPercent.period(useThisIndex);
       %    fiftyPercentData(iTask) = summaryData(iTask).fiftyPercent.period(useThisIndex);
       %end

        % Corruption period for ~1 std(flux) injected signals
        colorRange = [0 ceil(max([onePercentData' tenPercentData' fiftyPercentData']))];
        colorRange = [0 50];
        figureHandle = fovPlottingClass.plot_on_modout (modules, outputs, onePercentData, colorRange);
        % legend
        fovPlottingClass.make_ccd_legend_plot(figureHandle);    
        title(['Q', num2str(quarter), '; 1% corruption; Stellar Preservation; median: ', num2str(median(onePercentData)), ...
                                        '; std: ', num2str(std(onePercentData)), '; relative signal amplitude of 1 * std(flux)']);

        figureHandle = fovPlottingClass.plot_on_modout (modules, outputs, tenPercentData, colorRange);
        fovPlottingClass.make_ccd_legend_plot(figureHandle);    
        title(['Q', num2str(quarter), '; 10% corruption; Stellar Preservation; median: ', num2str(median(tenPercentData)), ...
                                        '; std: ', num2str(std(tenPercentData)), '; relative signal amplitude of 1 * std(flux)']);

        figureHandle = fovPlottingClass.plot_on_modout (modules, outputs, fiftyPercentData, colorRange);
        fovPlottingClass.make_ccd_legend_plot(figureHandle);    
        title(['Q', num2str(quarter), '; 50% corruption; Stellar Preservation; median: ', num2str(median(fiftyPercentData)), ...
                                        '; std: ', num2str(std(fiftyPercentData)), '; relative signal amplitude of 1 * std(flux)']);
        % Histograms

        % 1%, 10% and 50%corruption
        figure;
        subplot(3,1,1);
        hist(onePercentData, 50);
        title ('1% corruption period for 1 * std(flux) injected amplitudes');
        xlabel('Period [days]');
        xlim([0 50]);
        grid on;
        subplot(3,1,2);
        hist(tenPercentData, 50);
        title ('10% corruption period for 1 * std(flux) injected amplitudes');
        xlabel('Period [days]');
        xlim([0 50]);
        grid on;
        subplot(3,1,3);
        hist(fiftyPercentData, 50);
        title ('50% corruption period for 1 * std(flux) injected amplitudes');
        xlabel('Period [days]');
        xlim([0 50]);
        grid on;



    end

    %*************************************************************************************************************
    % Plots how a single amplitude run performed over all quarters
    %

    function [] = plot_all_quarters_one_channel_study (summaryData)

        % Check that all data is for the same module output
        module = summaryData(1).module;
        output = summaryData(1).output;
        for iEntry = 1 : length(summaryData)
            if (summaryData(iEntry).module ~= module || summaryData(iEntry).output ~= output)
                error ('Not all data is from the same module and output');
            end
        end

        % Plot all data versus quarter
        quarters = [summaryData.quarter];

        % Plot period when 1%, 10% and 50% median corruption occurs

        for iQuarter = 1 : length(summaryData)

            periods = [summaryData(iQuarter).singleAmplitude];
            periods = [periods.period];
            medians = [summaryData(iQuarter).singleAmplitude];
            medians = [medians.median];

            % Find the threshold
            periodOfOnePCorruption(iQuarter)      = pdcStellarPreserveClass.find_threshold (periods, medians, 0.01);
            periodOfTenPCorruption(iQuarter)      = pdcStellarPreserveClass.find_threshold (periods, medians, 0.1);
            periodOfFiftyPCorruption(iQuarter)    = pdcStellarPreserveClass.find_threshold (periods, medians, 0.5);
        end

        % Sort by quarter ascending
        [quarters, sortOrder] = sort(quarters);
        periodOfOnePCorruption      = periodOfOnePCorruption(sortOrder);
        periodOfTenPCorruption      = periodOfTenPCorruption(sortOrder);
        periodOfFiftyPCorruption    = periodOfFiftyPCorruption(sortOrder);

        % Plot when 1%, 10% and 50% occurs for each quarter
        figure;
        subplot(3,1,1)
        plot(quarters, periodOfOnePCorruption, 'o')
        grid on;
        title('Period at which 1% corruption occurs');
        xlabel('Kepler Quarter');
        ylabel('Period (Days)');

        subplot(3,1,2)
        plot(quarters, periodOfTenPCorruption, 'o')
        grid on;
        title('Period at which 10% corruption occurs');
        xlabel('Kepler Quarter');
        ylabel('Period (Days)');
        
        subplot(3,1,3)
        plot(quarters, periodOfFiftyPCorruption, 'o')
        grid on;
        title('Period at which 50% corruption occurs');
        xlabel('Kepler Quarter');
        ylabel('Period (Days)');

        % Histogram of when 1%, 10% and 50% corruption occurs for Quarters 2 - 16
        figure;
        subplot(3,1,1)
        hist(periodOfOnePCorruption(quarters > 1 & quarters < 17));
        medianVal   = median(periodOfOnePCorruption(quarters > 1 & quarters < 17));
        stdVal      = std(periodOfOnePCorruption(quarters > 1 & quarters < 17));
        grid on;
        title(['Period at which 1% corruption occurs (Quarters 2 - 16), median = ', num2str(medianVal), '; std = ', num2str(stdVal)]);
        xlabel('Period (Days)');

        subplot(3,1,2)
        hist(periodOfTenPCorruption(quarters > 1 & quarters < 17));
        medianVal   = median(periodOfTenPCorruption(quarters > 1 & quarters < 17));
        stdVal      = std(periodOfTenPCorruption(quarters > 1 & quarters < 17));
        grid on;
        title(['Period at which 10% corruption occurs (Quarters 2 - 16), median = ', num2str(medianVal), '; std = ', num2str(stdVal)]);
        xlabel('Period (Days)');

        subplot(3,1,3)
        hist(periodOfFiftyPCorruption(quarters > 1 & quarters < 17));
        medianVal   = median(periodOfFiftyPCorruption(quarters > 1 & quarters < 17));
        stdVal      = std(periodOfFiftyPCorruption(quarters > 1 & quarters < 17));
        grid on;
        title(['Period at which 50% corruption occurs (Quarters 2 - 16), median = ', num2str(medianVal), '; std = ', num2str(stdVal)]);
        xlabel('Period (Days)');



    end 

    %************************************************************************************************************
    % If using new multi-channel data this will combine the individual channel targetDataStructs into one upper-level targetDataStruct
    function [inputsStruct] = combine_targetDataStructs (inputsStruct)

        inputsStruct.ccdModule = -1;
        inputsStruct.ccdOutput = -1;

        inputsStruct.targetDataStruct = [];
        firstChannel = true;
        for iChannel = 1 : length(inputsStruct.channelDataStruct)
            % Add in the module and output to each target
            for iTarget = 1 : length(inputsStruct.channelDataStruct(iChannel).targetDataStruct)
                inputsStruct.channelDataStruct(iChannel).targetDataStruct(iTarget).ccdModule = inputsStruct.channelDataStruct(iChannel).ccdModule;
                inputsStruct.channelDataStruct(iChannel).targetDataStruct(iTarget).ccdOutput = inputsStruct.channelDataStruct(iChannel).ccdOutput;
            end
 
            inputsStruct.targetDataStruct = [inputsStruct.targetDataStruct inputsStruct.channelDataStruct(iChannel).targetDataStruct];
 
            if (firstChannel)
                % For now just populate these with the values in the first channel
                % The only one here that will really screw us up at some point is the motionBlobs. But until we do centroid priors it amkes no difference.
                inputsStruct.ccdModule                    = -1;
                inputsStruct.ccdOutput                    = -1;
                inputsStruct.ancillaryPipelineDataStruct  = inputsStruct.channelDataStruct(iChannel).ancillaryPipelineDataStruct;
                inputsStruct.cbvBlobs                     = inputsStruct.channelDataStruct(iChannel).cbvBlobs;                   
                inputsStruct.motionBlobs                  = inputsStruct.channelDataStruct(iChannel).motionBlobs;                
                inputsStruct.pdcBlobs                     = inputsStruct.channelDataStruct(iChannel).pdcBlobs;                   

                firstChannel = false;
            end
        end

        inputsStruct = rmfield(inputsStruct, 'channelDataStruct');

    end

    %************************************************************************************************************
    % Finds the first array threshold when the second array passes a certain limit

    function [thresholdValue] = find_threshold (periods, medians, threshold)

        hitLimitIndex = find(medians > threshold, 1);

        if (isempty(hitLimitIndex))
            thresholdValue = nan;
            return;
        end

        % Interpolate between the two bounds
        % The graph is in log space to convert to logs to do the linear interpolation
        thresholdValue = 10.^(interp1(log10(medians(hitLimitIndex-1:hitLimitIndex)), log10(periods(hitLimitIndex-1:hitLimitIndex)), log10(threshold))); 

    end

    end % Static methods

end % classdef
