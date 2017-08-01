function [harmonicsRemovedTimeSeries, harmonicTimeSeries, indexOfGiantTransits, ...
harmonicModelStruct, medianFlux, convertedToRelativeFluxFlag, harmonicCombDetected] = ...
identify_and_remove_phase_shifting_harmonics(originalTimeSeries, gapIndicators, ...
gapFillParameters, harmonicsIdentificationParameters, indexOfGiantTransits, ...
keplerId, plotResultsFlag, fillIndices, protectedPeriodInCadences)
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [harmonicsRemovedTimeSeries, harmonicTimeSeries, indexOfGiantTransits, ...
% harmonicModelStruct, medianFlux, convertedToRelativeFluxFlag] = ...
% identify_and_remove_phase_shifting_harmonics(originalTimeSeries, gapIndicators, ...
% gapFillParameters, harmonicsIdentificationParameters, indexOfGiantTransits, ...
% keplerId, plotResultsFlag, fillIndices)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Description: This function identifies and removes the harmonic trend from
% the given time series. The function can be invoked with just the time
% series, if without gaps, or time series and the gap indicators otherwise.
% As of the 7.0 release, the time series (and associated gap indicators
% where applicable) must be a column vector; an error will be thrown
% otherwise. As of the 7.0 release, the frequency parameters are
% (non-linearly) fitted, but the components no longer include
% phase-shifting terms.
%
%
% Any combination of inputs is acceptable provided the other inputs are
% left as [].
%
% Inputs:
%
% 1. originalTimeSeries:          time series from which harmonic trend
%                                 (if one exists) needs to be removed; must
%                                 be column vector (required input)
%
% 2. gapIndicators:               boolean array with 'true' or 1 indicating
%                                 gap; must be column vector (optional, if
%                                 no gaps)
%
% 3. gapFillParameters:           refer to identify_giant_transits.m for
%                                 structure definition (optional)
%
% 4. harmonicsIdentificationParameters as defined below:
%
%      medianWindowLengthForTimeSeriesSmoothing: [int]
%                                 length of median filter for time domain
%                                 filtering in units of cadences (NOT
%                                 USED IN 7.0 RELEASE)
%      medianWindowLengthForPeriodogramSmoothing: [int]
%                                 length of median filter for frequency
%                                 domain filtering in units of cadences
%      movingAverageWindowLength: [int]
%                                 length of periodogram smoothing filter in
%                                 units of cadences
%      falseDetectionProbabilityForTimeSeries: [float]
%                                 probability of one or more false
%                                 component detections in a given time
%                                 series
%      minHarmonicSeparationInBins: [int]
%                                 minimum required separation for any two
%                                 frequency components to be identified and
%                                 fitted in a given iteration; components
%                                 from iteration to iteration can (and
%                                 often will) be more closely spaced than
%                                 this
%      maxHarmonicComponents: [int]
%                                 maximum number of harmonic components for
%                                 a given time series
%      timeOutInMinutes: [float]
%                                 timeout limit in minutes for a given time
%                                 series
%
% 5. indexOfGiantTransits:     if unspecified or empty then giant transit
%                              identification will be done internally. If 
%                              set to -1, then no giant transit 
%                              identification will be done. Otherwise it is
%                              a set of valid giant transit indices which 
%                              will be gapped and interpolated over 
%                              (optional).
%
% 6. keplerId:                    needed only for plots (optional)
%
% 7. plotResultsFlag:             set to true if plots are desired
%                                 (optional)
%
% 8. fillIndices:                 1-based indices of values in the flux
%                                 time series which are filled (optional)
%
% Outputs:
%
% 1. harmonicsRemovedTimeSeries:  time series from which harmonics (if
%                                 found) have been removed
%
% 2. harmonicTimeSeries:          detected harmonic trend or empty if none
%                                 is found
%
% 3. indexOfGiantTransits:        cadence indices where large transits are
%                                 detected and removed prior to harmonics
%                                 identification
%
% 4. harmonicModelStruct: structure containing the following fields:
%
%      cosCoeffts: [double array] 
%                                 Fourier coefficients for cosine terms
%      sinCoeffts: [double array] 
%                                 Fourier coefficients for sine terms
%      harmonicFrequenciesInHz: [double array]
%                                 harmonic frequencies in units of Hz
%      samplingTimesInSeconds: [double array]
%                                 sample times in units of seconds
% 
% 5. medianFlux:                  median of (non-gapped) values in original
%                                 time series
%
% 6. convertedToRelativeFluxFlag: if true, original time series was
%                                 normalized prior to harmonic fitting
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%--------------------------------------------------------------------------
% preliminaries
% initialize outputs and return if time series is empty; also throw error
% if original time series is not a column vector (row vectors ought to be
% supported in the future when time is available to do the work and
% associated testing)
%--------------------------------------------------------------------------
harmonicTimeSeries = [];
medianFlux = 0;
convertedToRelativeFluxFlag = false;
removeGiantTransitsFlag = false;
harmonicCombDetected = false ;

if ~isfield(harmonicsIdentificationParameters,'retainFrequencyCombsEnabled')
    ignoreCombs = false ;
else
    ignoreCombs = harmonicsIdentificationParameters.retainFrequencyCombsEnabled ;
end
%ignoreCombs = false ;

harmonicModelStruct = struct( ...
    'cosCoeffts', [], ...
    'sinCoeffts', [], ...
    'harmonicFrequenciesInHz', [], ...
    'samplingTimesInSeconds', []);

if isempty(originalTimeSeries)
    fprintf('Input time series empty; nothing to do    \n');
    harmonicsRemovedTimeSeries = originalTimeSeries;
    if ~exist('indexOfGiantTransits', 'var')
        indexOfGiantTransits = [];
    end % if
    return
end % if

if size(originalTimeSeries, 2) > 1
    error('Common:identifyAndRemovePhaseShiftingHarmonics:UnsupportedInputFormat', ...
        'The original time series must be a column vector')
end % if

%--------------------------------------------------------------------------
% preliminaries still...
% work with a bare minimum of inputs
%--------------------------------------------------------------------------

nCadences = length(originalTimeSeries);

if ~exist('gapIndicators', 'var') || isempty(gapIndicators)
    gapIndicators = false(size(originalTimeSeries));
else
    if ~isequal(size(gapIndicators), size(originalTimeSeries))
        error('Common:identifyAndRemovePhaseShiftingHarmonics:InconsistentInputFormat', ...
        'The dimensions of the original time series and gap indicators vectors do not match')
    end % if
end % if / else

if any(isnan(originalTimeSeries))
    indexOfNaNs = find(isnan(originalTimeSeries));
    gapIndicators(indexOfNaNs) = true;
    warning('Common:identifyAndRemovePhaseShiftingHarmonics', ...
        'identify_and_remove_phase_shifting_harmonics: found NaNs in the input; treating NaNs as data gaps and proceeding with identification of harmonics...');
else
    indexOfNaNs = [];
end % if / else

if sum(~gapIndicators) < 12
    warning('Common:identifyAndRemovePhaseShiftingHarmonics', ...
        'identify_and_remove_phase_shifting_harmonics: insufficient number of valid samples are available to identify and remove harmonics...');
    harmonicsRemovedTimeSeries = originalTimeSeries;
    if ~exist('indexOfGiantTransits', 'var')
        indexOfGiantTransits = [];
    end % if
    return
end % if

originalTimeSeries(indexOfNaNs) = 0;
originalGapIndicators = gapIndicators;

if ~exist('gapFillParameters', 'var') || isempty(gapFillParameters)
    gapFillParameters.madXFactor = 10;
    gapFillParameters.maxGiantTransitDurationInHours = 72;
    gapFillParameters.giantTransitPolyFitChunkLengthInHours = 72;
    gapFillParameters.maxDetrendPolyOrder =  25;
    gapFillParameters.maxArOrderLimit = 25;
    gapFillParameters.maxCorrelationWindowXFactor = 5;
    gapFillParameters.gapFillModeIsAddBackPredictionError = true;
    gapFillParameters.waveletFamily = 'daub';
    gapFillParameters.waveletFilterLength = 12;
    gapFillParameters.cadenceDurationInMinutes = 29.4244;
end % if

if ~isfield(gapFillParameters,'cadenceDurationInMinutes')
    gapFillParameters.cadenceDurationInMinutes = 29.4244;
end 

if ~exist('harmonicsIdentificationParameters', 'var') || isempty(harmonicsIdentificationParameters) || ...
        ~isfield(harmonicsIdentificationParameters, 'medianWindowLengthForTimeSeriesSmoothing')
    medianWindowLengthForTimeSeriesSmoothing = 21;      % to identify giant transits
    medianWindowLengthForPeriodogramSmoothing = 47;     % to ignore strong harmonics
    movingAverageWindowLength = 47;                     % to get a smoothed PSD of noise
    falseDetectionProbabilityForTimeSeries = 0.001;     % to set chi-square detection threshold
    minHarmonicSeparationInBins = 25;                   % to separate frequency components
    maxHarmonicComponents = 25;                         % max number of harmonic components
    timeOutInMinutes = 2.5;                             % to move on
else
    medianWindowLengthForTimeSeriesSmoothing = ...
        harmonicsIdentificationParameters.medianWindowLengthForTimeSeriesSmoothing;
    medianWindowLengthForPeriodogramSmoothing = ...
        harmonicsIdentificationParameters.medianWindowLengthForPeriodogramSmoothing;
    movingAverageWindowLength = ...
        harmonicsIdentificationParameters.movingAverageWindowLength;
    falseDetectionProbabilityForTimeSeries = ...
        harmonicsIdentificationParameters.falseDetectionProbabilityForTimeSeries;
    minHarmonicSeparationInBins = ...
        harmonicsIdentificationParameters.minHarmonicSeparationInBins;
    maxHarmonicComponents = ...
        harmonicsIdentificationParameters.maxHarmonicComponents;
    timeOutInMinutes = ...
        harmonicsIdentificationParameters.timeOutInMinutes;
end % if / else

if ~exist('indexOfGiantTransits', 'var') || isempty(indexOfGiantTransits)
    removeGiantTransitsFlag = true;
end % if

if exist('indexOfGiantTransits', 'var') && isequal(indexOfGiantTransits, -1)
    % turn off giant transit identification
    indexOfGiantTransits = [];
end % if

if ~exist('keplerId', 'var') || isempty(keplerId)
    fileNameStr = '1';
else
    fileNameStr = num2str(keplerId);
end % if / else

if ~exist('plotResultsFlag', 'var') || isempty(plotResultsFlag)
    plotResultsFlag = false;
else
    paperOrientationFlag = true;
    includeTimeFlag = false;
    printJpgFlag = true;
end % if / else

if ~exist('fillIndices','var')
    fillIndices = [] ;
end % if

if ~exist('protectedPeriodInCadences','var')
    protectedPeriodInCadences = [] ;
end % if

%--------------------------------------------------------------------------
% normalize time series if necessary
%--------------------------------------------------------------------------

medianFlux = median(originalTimeSeries(~gapIndicators));

if abs(medianFlux) > eps
    timeSeries = (originalTimeSeries - medianFlux) / medianFlux;
    convertedToRelativeFluxFlag = true;
else
    timeSeries = originalTimeSeries;
    convertedToRelativeFluxFlag = false;
end % if / else

%--------------------------------------------------------------------------
% these will not become parameters
%--------------------------------------------------------------------------

medscal = 1 / chi2inv(0.5, 2);

[hoursInDay] = get_unit_conversion('day2hour');
[minutesInHour] = get_unit_conversion('hour2min');
[secondsInMinute] = get_unit_conversion('min2sec');
cadencesPerDay = ...
    (hoursInDay * minutesInHour) / gapFillParameters.cadenceDurationInMinutes;
secondsPerCadence = (hoursInDay * minutesInHour * secondsInMinute / cadencesPerDay);
%--------------------------------------------------------------------------
% Step 1: detect giant transits and (linearly) interpolate all gaps
%--------------------------------------------------------------------------

tooManySamplesInGiantTransit = false;

% remove giant transits if flag is set
if removeGiantTransitsFlag

    % identify the large negative- and positive-going events and merge the
    % indices
    [indexOfGiantTransits1] = identify_giant_transits(timeSeries, ...
        gapIndicators, gapFillParameters);
    [indexOfGiantTransits2] = identify_giant_transits(-timeSeries, ...
        gapIndicators, gapFillParameters);
    indexOfGiantTransits = ...
        unique([indexOfGiantTransits1; indexOfGiantTransits2]);
end

% note if too many cadences have been identified, otherwise gap the
% cadences
nSamplesInGiantTransit = length(indexOfGiantTransits);

if nSamplesInGiantTransit / nCadences > 0.5
    tooManySamplesInGiantTransit = true;
elseif nSamplesInGiantTransit > 0
    gapIndicators(indexOfGiantTransits) = true;
end % if / elseif

% skip harmonics identification if too many samples are in giant transits
if tooManySamplesInGiantTransit
    harmonicsRemovedTimeSeries = originalTimeSeries;
    return
end % if tooManySamplesInGiantTransit

% linearly interpolate the gapped data values
timeSeries = interp1(find(~gapIndicators), timeSeries(~gapIndicators), ...
    (1:nCadences)', 'linear', 'extrap');

%-------------------------------------------------------------------------
% Step 2: iteratively remove harmonic component exceeding threshold and
% jointly fit extracted harmonic components until no more harmonics are
% detected; new harmonic components identified in each iteration must be
% separated at least by specified number of bins
%-------------------------------------------------------------------------

% original time series from which giant transits have been removed and
% filled with interp1
relativeFluxTimeSeries = timeSeries;

% time/frequency values for periodogram
samplingFrequency = cadencesPerDay / (hoursInDay * minutesInHour * secondsInMinute); % Hz
nPointFft = 2^nextpow2(nCadences); % Next power of 2 from length of y
f = samplingFrequency/2 * linspace(0, 1, nPointFft/2 + 1);
f = f(1:nPointFft/2);
t = (1:nCadences)' * secondsPerCadence;

if ~isempty(protectedPeriodInCadences)
    % compute harmonic frequencies to protect
    protectedPeriodInSeconds = protectedPeriodInCadences * secondsPerCadence;
    protectedFrequencies = 1/protectedPeriodInSeconds;
    protectedFrequencies = protectedFrequencies:protectedFrequencies:samplingFrequency/2; % Hz - low to high
    % find f indices closest to these harmonic frequencies
    protectedIndices = ones(length(protectedFrequencies),1);
    for i=1:length(protectedIndices)
        [~, protectedIndices(i)] = min( abs(f-protectedFrequencies(i)) );
    end
    % pad each side of the peak
    pointsToPad = 4;
    protectedIndices = repmat(protectedIndices,1,2*pointsToPad+1);
    protectedIndices = protectedIndices - repmat(-pointsToPad:1:pointsToPad,length(protectedFrequencies),1);
    protectedIndices = sort(reshape(protectedIndices,length(protectedFrequencies) * (2*pointsToPad+1),1));
    protectedIndices = protectedIndices(protectedIndices>0 & protectedIndices<length(f));
end

% determine the chi-square threshold that yields the desired false
% detection probability (probability that one or more components exceed
% threshold in absence of harmonic signal) for the given time series
chiSquareProbabilityForThreshold = ...
    (1 - falseDetectionProbabilityForTimeSeries)^(1 / (nPointFft/2));
powerThreshold = chi2inv(chiSquareProbabilityForThreshold, 2);

% there is a stopwatch timer in pdc/tps matlab controllers and this
% overwrites the tic
cpuTimeInSecSoFar = 0;
tStart = tic;

% loop until all frequency components have been identified
indicesIdentifiedEarlier = [];
harmonicsIdentifiedEarlier = [];
harmonicsRemovedTimeSeries = [];

doneWithHarmonicRemoval = false ;

while ~doneWithHarmonicRemoval

    if ~isempty(harmonicsRemovedTimeSeries) % empty only for the first iteration
        timeSeries = harmonicsRemovedTimeSeries;
    end % if

    %-------------------------------------------------------------------------
    % Step 2a: power spectrum of flux time series; ignore highest frequency
    % bin
    %-------------------------------------------------------------------------
    powerSpectrum = ...
        periodogram(timeSeries, hann(nCadences), nPointFft, samplingFrequency);
    powerSpectrum = powerSpectrum(1:nPointFft/2);

    %-------------------------------------------------------------------------
    % Step 2b: background noise estimate
    %-------------------------------------------------------------------------
    % remove outliers using a moving median filter;
    % scale the result by the median of a chi square process
    % (replace each point by the median of the nearest points)
    %-------------------------------------------------------------------------
    leftExtrapVal = ...
        median(powerSpectrum(1:medianWindowLengthForPeriodogramSmoothing));
    rightExtrapVal = ...
        median(powerSpectrum(end-medianWindowLengthForPeriodogramSmoothing+1:end));
    padLength = (medianWindowLengthForPeriodogramSmoothing - 1) / 2;
    backgroundPsd = [repmat(leftExtrapVal, [padLength, 1]); ...
        powerSpectrum; repmat(rightExtrapVal, [padLength, 1])];

    backgroundPsd = ...
        medfilt1(backgroundPsd, medianWindowLengthForPeriodogramSmoothing) * medscal;
    backgroundPsd = backgroundPsd(padLength+1 : padLength+nPointFft/2);

    % apply moving average filter and save valid samples
    leftExtrapVal = median(backgroundPsd(1:movingAverageWindowLength));
    rightExtrapVal = median(backgroundPsd(end-movingAverageWindowLength+1:end));
    padLength = (movingAverageWindowLength - 1) / 2;
    backgroundPsd = [repmat(leftExtrapVal, [padLength, 1]); ...
        backgroundPsd; repmat(rightExtrapVal, [padLength, 1])];                            %#ok<AGROW>

    backgroundPsd = conv(backgroundPsd, ...
        ones(movingAverageWindowLength, 1) / movingAverageWindowLength);
    backgroundPsd = ...
        backgroundPsd(movingAverageWindowLength : ...
        movingAverageWindowLength+nPointFft/2-1);

    %-------------------------------------------------------------------------
    % Step 2c: whiten the power spectrum (divide pointwise by background
    % noise power spectrum) and sort the components so we can pick out the
    % harmonics above the floor
    %-------------------------------------------------------------------------
    whitenedPsd = (powerSpectrum ./ backgroundPsd);

    [sortedPowerInHarmonics, indexToHarmonics] = sort(whitenedPsd, 'descend');

    %-------------------------------------------------------------------------
    % Step 2d: identify harmonic components crossing the power threshold;
    % exclude harmonic candidates that have already been fitted; new
    % components must be separated at least by specified number of bins
    %-------------------------------------------------------------------------
    if ~isempty(protectedPeriodInCadences)
        % remove indices associated with protected frequencies
        indexOfCandidates = ...
        indexToHarmonics(sortedPowerInHarmonics > powerThreshold & ...
        ~ismember(indexToHarmonics,protectedIndices)); 
    else
        indexOfCandidates = ...
        indexToHarmonics(sortedPowerInHarmonics > powerThreshold); 
    end
    
    isDuplicate = ismember(indexOfCandidates, indicesIdentifiedEarlier);
    indexOfCandidates(isDuplicate) = [];
    
    % make sure the harmonics are not too close to each other because of
    % failure to resolve a frequency
    indexToRemove = [];
    
    for iIndex = indexOfCandidates( : )'
%         if ~any(abs(iIndex - [indexToRemove ; indicesIdentifiedEarlier]) < ...
%                 minHarmonicSeparationInBins)
        if ~any(abs(iIndex - indexToRemove) < ...
                minHarmonicSeparationInBins)
            indexToRemove = [indexToRemove; iIndex];                                       %#ok<AGROW>
        end % if  
    end % for iIndex
    
    % fit only the maximum number of harmonic components (including the
    % prior components)
    nRemainingComponents = ...
        maxHarmonicComponents - length(harmonicsIdentifiedEarlier);
    if length(indexToRemove) > nRemainingComponents
        indexToRemove = indexToRemove(1:nRemainingComponents);
    end % if
    % disp(indexToRemove');  display new indices for diagnostic purposes
    
    harmonicFrequencies = f(indexToRemove);

    if ~isempty(harmonicFrequencies)

        % merge the new frequency components with earlier components and
        % sort by frequency
        harmonicFrequencies = ...
            unique([harmonicsIdentifiedEarlier, harmonicFrequencies]);

        % define the cadences which are to be used in the fit: leave out
        % gaps and fills
        cadencesUsedInFit = true(size(relativeFluxTimeSeries));
        cadencesUsedInFit(gapIndicators) = false;
        cadencesUsedInFit(fillIndices) = false;

        % construct the harmonic time series in the time domain
        frequencyModulationModelFunction = ...
            @(harmonicFrequencies, xStruct) frequency_modulated_signal(harmonicFrequencies, xStruct);
        nlinfitOptions = statset('Robust', 'off', 'Display', 'off', 'MaxIter', 10 );  % do not remove TolX, Jacobian has one column = 0

        inputStruct.t = t(cadencesUsedInFit);
        inputStruct.timeSeries = relativeFluxTimeSeries(cadencesUsedInFit);

        % if short cadence data, for harmonic rich time series, it can take
        % hours to nlinfit the harmonics; do not try to do that until
        % performance can be revisited
        w = warning('query','all');
        warning('off','all');

        if gapFillParameters.cadenceDurationInMinutes > 0 % LC & SC data
            [harmonicFrequencies] = ...
                kepler_nonlinear_fit_tps(inputStruct, relativeFluxTimeSeries(cadencesUsedInFit), ...
                frequencyModulationModelFunction, harmonicFrequencies, nlinfitOptions);
        end % if

        warning(w);
        
        % sort the components and construct the harmonic model and harmonic
        % time series; all frequency components should be positive
        harmonicFrequencies = unique(abs(harmonicFrequencies));
        [harmonicTimeSeries, harmonicModelStruct] = ...
            frequency_modulated_signal(harmonicFrequencies, inputStruct);

        if any(~cadencesUsedInFit)
            harmonicModelStruct.samplingTimesInSeconds = t;
            [harmonicTimeSeries] = ...
                build_harmonic_time_series_from_model(harmonicModelStruct, t);
        end % if
        
        % remove harmonics for next iteration and interpolate gapped data
        % if necessary
        harmonicsRemovedTimeSeries = ...
            relativeFluxTimeSeries - harmonicTimeSeries;

        if any(~cadencesUsedInFit)
            harmonicsRemovedTimeSeries = ...
                interp1(find(cadencesUsedInFit), harmonicsRemovedTimeSeries(cadencesUsedInFit), ...
                (1:nCadences)', 'linear', 'extrap');
        end % if
        
        harmonicsIdentifiedEarlier = harmonicFrequencies;
        indicesIdentifiedEarlier = unique([indicesIdentifiedEarlier; indexToRemove]);

        % create diagnostic plots if the option was selected
        if plotResultsFlag

            % Plot single-sided amplitude spectrum.
            figure;
            subplot(2,1,1)
            plot(f, powerSpectrum, '.-')
            hold on
            plot(f(indexToRemove), powerSpectrum(indexToRemove), 'or')
            plot(f, backgroundPsd, '.-g')
            title('Single-Sided Amplitude Spectrum of timeSeries(t)')
            xlabel('Frequency (Hz)')
            ylabel('|Y(f)|')
            
            subplot(2,1,2)
            plot(f, whitenedPsd, '.-')
            hold on
            plot(f(indexToRemove), whitenedPsd(indexToRemove), 'or')
            plot([f(1); f(end)], [powerThreshold; powerThreshold], '--k')
            title('Whitened PSD of timeSeries(t)')
            xlabel('Frequency (Hz)')
            ylabel('Dimensionless')

            if convertedToRelativeFluxFlag
                yLabelText = 'relative flux';
            else
                yLabelText = 'flux';
            end % if / else

            figure;
            subplot(4,1,1);
            timeSeriesWithNans = originalTimeSeries;
            timeSeriesWithNans(originalGapIndicators) = NaN;
            h1 = plot(timeSeriesWithNans, '.-');
            hold on;
            if convertedToRelativeFluxFlag
                h2 = plot((harmonicTimeSeries + 1) * medianFlux, 'r-');
            else
                h2 = plot(harmonicTimeSeries, 'r-');
            end % if / else
            h3 = plot(indexOfGiantTransits, timeSeriesWithNans(indexOfGiantTransits), 'og');

            xlabel('cadence number');
            ylabel('flux');
            if ~isempty(indexOfGiantTransits)
                legend([h1 h2 h3], {'time series', 'harmonics', 'giant transits'});
            else
                legend([h1 h2], {'time series', 'harmonics'});
            end % if / else
            title(['original time series KeplerId: ', fileNameStr]);
            
            subplot(4,1,2);
            h1 = plot(relativeFluxTimeSeries, '.-');
            hold on;
            h2 = plot(harmonicTimeSeries, 'r-');

            xlabel('cadence number');
            ylabel(yLabelText);
            legend([h1 h2], {'time series', 'harmonics'});
            title(['interpolated time series KeplerId: ', fileNameStr]);
            ylimits = ylim;

            subplot(4,1,3);
            plot(harmonicTimeSeries, '.-');
            xlabel('cadence number');
            ylabel(yLabelText);
            ylim(ylimits);
            title(['harmonic trend identified KeplerId: ', fileNameStr]);

            subplot(4,1,4);
            plot(harmonicsRemovedTimeSeries, '.-');
            xlabel('cadence number');

            ylabel(yLabelText);
            if ~convertedToRelativeFluxFlag
                ylim(ylimits);
            end % if

            title(['harmonic trend removed time series KeplerId: ', fileNameStr]);

            plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
            
            close all;
            
        end % if plotResultsFlag
        
        % check if harmonic limit has been reached
        if length(harmonicFrequencies) >= maxHarmonicComponents
            warning('Common:identifyAndRemovePhaseShiftingHarmonics:harmonicsLimitReached', ...
                ['identify_and_remove_phase_shifting_harmonics: reached harmonics limit;\n' ...
                'stopped looking for more harmonics, returning the results from the last iteration']);
            doneWithHarmonicRemoval = true ;
        end % if
        
        % check for timeout
        tElapsed = toc(tStart);
        cpuTimeInSecSoFar = cpuTimeInSecSoFar + tElapsed;
        
        if cpuTimeInSecSoFar / secondsInMinute >= timeOutInMinutes
            warning('Common:identifyAndRemovePhaseShiftingHarmonics:timeOut', ...
                ['identify_and_remove_phase_shifting_harmonics: took more than ' num2str(timeOutInMinutes) ' minutes;\n' ...
                'stopped looking for more harmonics, returning the results from the last iteration']);
            doneWithHarmonicRemoval = true ;
        end % if
        
        % start the clock again
        tStart = tic;
        
    else % isempty(harmonicFrequencies) -- in this case we are done
        
        doneWithHarmonicRemoval = true ;
        
    end % if / else
    
end % while true

% set returns and exit

harmonicsRemovedTimeSeries = originalTimeSeries ;

if ~isempty(harmonicTimeSeries)
    
%   put back the harmonic combs, if necessary 

    if (ignoreCombs)
        harmonicModelStruct = remove_frequency_combs( harmonicModelStruct, ...
            indicesIdentifiedEarlier, nPointFft/2 ) ;
        harmonicCombModelStruct = harmonicModelStruct(2) ;
        if ~isempty( harmonicCombModelStruct.harmonicFrequenciesInHz )
            [harmonicCombTimeSeries] = ...
                build_harmonic_time_series_from_model(harmonicCombModelStruct, ...
                harmonicCombModelStruct.samplingTimesInSeconds);
            harmonicTimeSeries = harmonicTimeSeries - harmonicCombTimeSeries ;
            harmonicCombDetected = true ;
        end
    end
    
    if convertedToRelativeFluxFlag
        harmonicTimeSeries =  (harmonicTimeSeries + 1) * medianFlux;
    end % if
    harmonicsRemovedTimeSeries = originalTimeSeries - harmonicTimeSeries;
end


% return
return


function [harmonicTimeSeries, harmonicModelStruct] = ...
frequency_modulated_signal(harmonicFrequencies, xStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Harmonic model function for nlinfit. Sum of non-phase shifting (for
% release 7.0) harmonic components.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

t = xStruct.t;
timeSeries = xStruct.timeSeries;

nCadences = length(t);
nFreqs = length(harmonicFrequencies);

tArray = repmat(t, [1, nFreqs]);
fArray = repmat(harmonicFrequencies, [nCadences, 1]);
phase = 2 * pi * fArray .* tArray;
clear tArray fArray
A = [cos(phase), sin(phase)];

warningState = warning('query', 'all');
warning off all;

% compute the Fourier amplitudes (ai's and bi's)
fourierCoeffts = A \ timeSeries;
cosCoeffts = fourierCoeffts(1 : nFreqs);
sinCoeffts = fourierCoeffts(nFreqs+1 : end);

% construct the extracted harmonic time series
harmonicTimeSeries = A * fourierCoeffts;

% populate the harmonic model structure
harmonicModelStruct.cosCoeffts = cosCoeffts;
harmonicModelStruct.sinCoeffts = sinCoeffts;
harmonicModelStruct.harmonicFrequenciesInHz = harmonicFrequencies( : );
harmonicModelStruct.samplingTimesInSeconds = t;

warning(warningState);

% return
return

%=========================================================================================

% subfunction which looks for frequency combs and removes them from the set of removed
% harmonics

function harmonicModelStruct = remove_frequency_combs( harmonicModelStructIn, ...
    frequencyIndices, nFrequenciesTotal )

% create a vector to hold the frequency indices which we do not want to remove, and while
% we are at it correct for the fact that the current indices are one-based, and we want
% zero frequency to occur at index == 0

  frequencyIndices          = frequencyIndices(:) - 1 ;
  survivingFrequencyIndices = frequencyIndices ;
  nFrequencies              = length(survivingFrequencyIndices) ;
  expectedCombLength        = floor(nFrequenciesTotal ./ frequencyIndices) ;
  
% build a matrix of indicators for each frequency to show whether it's in a comb, and if
% so which frequency is the base frequency for the comb
    
  inAComb = logical(eye(nFrequencies)) ;  
  
% A comb requires at least 3 frequencies which are all multiples of the base frequency; so
% loop over frequencies up to the 3rd to last

  for iFreq = 1:nFrequencies-2
      
      thisIndex = frequencyIndices(iFreq) ;
      
%     the base frequency can be off by 1 from its true value, so we need to look at the
%     comb behavior for the neighboring frequencies as well as the nominal one
      
      thisIndex = repmat([thisIndex-1 thisIndex thisIndex+1],nFrequencies,1) ;
      allFreqs  = repmat(frequencyIndices,1,3) ;
      harmonic  = round(allFreqs ./ thisIndex) ;
      offset    = allFreqs - harmonic .* thisIndex ;
      
%     For a frequency to be in a comb with the current one, its index number cannot be
%     more than 1 off from a multiple of the base frequency, and it has to have a harmonic
%     # greater than 1, and the base index cannot be DC or negative
      
      combMember = thisIndex > 0 & harmonic > 1 & abs(offset) <= 1 ;
      
%     figure out which of the 3 base frequencies makes the best comb and preserve its flag
%     values
      
      nCombMembers = sum(combMember) ;
      [~,bestComb] = max(nCombMembers) ;
      inAComb(iFreq+1:end,iFreq) = combMember(iFreq+1:end,bestComb) ;
      
  end
    
% now we start looking for combs -- we need to iteratively locate the best comb and remove
% it, then look for more, because in a true comb there will be multiple solutions (ie, the
% set of 50, 100, 150, 200, 250, 300 is a comb, but so would be 100, 200, 300), and
% because there can be more than one true comb.  Also, factor in the number of spikes
% which were expected vs the number found -- this allows us to somewhat reduce the number
% of times that super-low frequencies are spuriously combined into a real comb

  combSum = sum(inAComb) ;
  while( max(combSum) >= 3 )
      
      combCriterion = combSum.^2 ./ expectedCombLength' .* (combSum >= 3) ;
      [~,bestComb] = max(combCriterion) ;
      
%     now we need to make the frequencies in this comb inaccessible to any of the other
%     potential combs, and mark as being not surviving frequencies
      
      inThisComb = inAComb(:,bestComb) ;
      survivingFrequencyIndices(inThisComb') = -1 ;
      inThisComb = repmat(inThisComb,1,nFrequencies) ;
      inAComb = inAComb & ~inThisComb ;
      
      combSum = sum(inAComb) ;
      
  end
  
% OK:  at this point we have identified which indices are not comb members, and we want to
% keep only those.  This is accomplished by seeing which of the frequencies are members of
% the survivor set; this will give a logical showing which ones we keep

  goodFrequency =  ismember( frequencyIndices, survivingFrequencyIndices ) ;
  
% build the return struct -- it's a struct array, with the good frequencies first and the
% bad ones second
  
  harmonicModelStruct = repmat(harmonicModelStructIn,2,1) ;
  harmonicModelStruct(1).cosCoeffts = harmonicModelStructIn.cosCoeffts( goodFrequency ) ;
  harmonicModelStruct(1).sinCoeffts = harmonicModelStructIn.sinCoeffts( goodFrequency ) ;
  harmonicModelStruct(1).harmonicFrequenciesInHz = ...
      harmonicModelStructIn.harmonicFrequenciesInHz( goodFrequency ) ;
  harmonicModelStruct(2).cosCoeffts = harmonicModelStructIn.cosCoeffts( ~goodFrequency ) ;
  harmonicModelStruct(2).sinCoeffts = harmonicModelStructIn.sinCoeffts( ~goodFrequency ) ;
  harmonicModelStruct(2).harmonicFrequenciesInHz = ...
      harmonicModelStructIn.harmonicFrequenciesInHz( ~goodFrequency ) ;
  
return
  
  
