function dvResultsStruct = perform_dv_ghost_diagnostic_tests(dvDataObject, dvResultsStruct)

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Purpose of the ghost diagnostic test
%
% The ghost diagnostic test determines whether a transit signal is likely
% to be contaminated by a spurious signal from a star located away from the
% target star.
% 
% Kepler data contains a class of false positives due to contamination of a
% target star by a "ghost reflection", which occurs when light from a
% bright star that is reflected from the CCD reflects again from the field
% flattener plate and back onto the CCD as a large, diffuse, out-of-focus
% image of the pupil of the telescope. A similar type of false positive
% results from "direct PRF contamination", when flux from the broad wings
% of the point response function (PRF) of a nearby bright star on the CCD
% overlaps a target star's PRF. 
%
% Reference: "Contamination in the Kepler Field. Identification of 685 KOIs
% as False Positives via Ephemeris Matching Based on Q1-Q12 Data",
% Coughlin et al., 2014 AJ, 147, 163 
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% How the ghost diagnostic test works
%
% Suppose a ghost reflection (or the PRF of a nearby star) containing a
% transit signature (e.g. due to an eclipsing binary) overlaps the PRF of a
% target star. Then the transit signal from the contaminating flux should
% be significantly stronger in the wings of the target star's PRF, where it
% doesn't compete with the flux in the core of the PRF.
% 
% The ghost diagnostic test is designed to detect ghost contamination by
% checking whether the transit model is more correlated with the flux in
% annulus of pixels surrounding the target star's optimal aperture or with
% the flux in the pixels of the optimal aperture itself. If that is the
% case, the transit signal is most likely due to a spurious signal from a
% ghost reflection.
% 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Definition of the ghost diagnostic statistics
%
% The correlation statistics described above and their significances
% are computed in the function generate_dv_ghost_detection_statistic,
% and are fully described in the comments therein.
% The target aperture is defined as the set of pixels in the
% optimal aperture. The halo aperture is defined as an annulus of pixels
% surrounding and adjacent to the target aperture. These apertures and
% their associated fluxes are constructed in the function
% build_dv_core_and_halo_flux_timeseries.
% The halo statistic is the correlation (in the whitened
% domain) between the transit model and the mean of the flux
% timeseries over the pixels in the halo aperture.
% The core statistic is the correlation (in the whitened
% domain) between the transit model and the mean of the
% flux timeseries over the pixels in the target aperture minus
% the mean of the flux timeseries over the pixels in the halo aperture.
% In the case of contamination by a ghost reflection, we expect (as
% explained in detailed comments in build_dv_core_and_halo_timeseries)
% that (ideally) subtraction of halo flux from core flux will yield a core
% statistic free of ghost contamination; while the halo statistic will be
% dominated by the ghost contamination flux.
% 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Interpretation of the ghost diagnostic test statistics
%
% According to the foregoing discussion, when the halo statistic is greater
% than the core statistic, the transit signal is likely due to
% contamination of the target star flux by a ghost reflection, or by flux
% from the PRF of another star that has a transit signal and that is near
% to the target on the focal plane.
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

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% perform_dv_ghost_diagnostic_tests is adapted from perform_dv_centroid_tests
% The following block of comments is from perform_dv_centroid_tests
% This data validation method accepts input of the dvDataObject and the
% dvResultsStruct. For each planet and each target passed in the
% dvResultsStruct the corresponding row and column centroid time series
% from the dvDataObject are detrended against differential velocity aberation
% (DVA) and ancillary data. The detrended centroid time series then passed
% to an iterative whitener which produces scale coefficients and covariance
% by fitting scaled transit models to the centroid time series in the
% whitened domain. The in-transit centroid offsets are then determined in
% the unwhitened domain using these coefficients and the fractional transit
% depth from the transit model. The whitener also provides row and column
% detection statistics from the chi-squared of the scaled transit model in
% the whitened domain. These statistics are combined to form the centroid
% statistic which yields the statistical significance of the detection
% under the assumption of chi-squared statistics. The location of a
% transiting background source responsible for transit features in the
% centroid time series is estimated from the backgorund source row and
% column offset and the mean out of transit centroid by inverting the
% motion polynomial from the cadence whose raw centroid is closest to the
% mean value. Folded and unfolded plots of the detrended row and column
% centroid time series and the corresponding corrected flux time series are
% produced. The transit models as they are fitted to the centroid time
% series are overlayed on the centroid plots. A cloud (or rain) plot of the
% median detrended corrected flux as a function of the median detrended row
% and column centroids is provided in the unwhitened domain. A similar plot
% in the whitened domain may be provided in the future.
%
% This test is performed on both PRF and flux-weighted centroids on a per
% target per planet basis.
%
% INPUT:    dvDataObject            = data object from dvDataStruct as defined in dv_matlab_controller.m
%           dvResultsStruct         = results struct as defined in dv_matlab_controller.m
% OUTPUT:   dvResultsStruct         = same as input struct with the following fields populated:
%
% targetResultsStruct: [struct array]               results for each target with a TCE
%   planetResultsStruct: [struct array]             results for each planet for the given target
%       centroidResults: [struct]                   centroid checks for given planet
%           prfMotionResults: [struct]              PRF-based centroid motion results
%               motionDetectionStatistic: [struct]  centroid motion test
%                   value: [float]                  value of computed statistic
%                   significance: [float]           significance of computed statistic
%               peakRaOffset: [struct]              maximum mean in transit centroid rigth ascension angle offset, arcseconds
%                   value: [float]                  value of computed statistic
%                   uncertainty: [float]            uncertainty of computed statistic
%                                                   (same struct elements for the following structs)
%               peakDecOffset: [struct]             maximum mean in transit centroid declination angle offset, arcseconds
%               sourceRaOffset: [struct]            background source right ascension angle offset from target, arcseconds
%               sourceDecOffset:[struct]            background source declination angle offset from target, arcseconds
%               sourceRaHours: [struct]             background source location, right ascension, hours
%               sourceDecDegrees: [struct]          background source location, declination, degrees
%           fluxWeightedMotionResults: [struct]     flux-weighted centroid motion results
%                                                   (similar to prfMotionResults)
%
%  alerts: [struct array]                           module alert(s)
%   time: [double]                                  alert time, MJD
%   severity: [string]                              alert severity ('error' or 'warning')
%   message: [string]                               alert message
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Comments specific to the implementation of perform_dv_ghost_diagnostic are included below. 

% hard coded
DV_BACKEND_PROCESSING_PER_TARGET_SECS = 3600;

% start timer
tic

% unit conversion
SECONDS_PER_MINUTE = get_unit_conversion('min2sec');

% parse necessary stuff from dvDataObject
planetFitConfigurationStruct = dvDataObject.planetFitConfigurationStruct;
trapezoidalFitConfigurationStruct = dvDataObject.trapezoidalFitConfigurationStruct;
configMaps = dvDataObject.configMaps;
raDec2PixModel = dvDataObject.raDec2PixModel;
dataAnomalyIndicators = dvDataObject.dvCadenceTimes.dataAnomalyFlags;

% parse timeout parameters
taskTimeoutSecs = dvDataObject.taskTimeoutSecs;
refTime = dvDataObject.refTime;

% extract centroidTestConfigurationStruct (used in iterative whitening)
% disable fine mesh
% calculate and attach minutes per cadence
centroidTestConfigurationStruct = dvDataObject.centroidTestConfigurationStruct;
centroidTestConfigurationStruct.centroidModelFineMeshEnabled = false;
centroidTestConfigurationStruct.minutesPerCadence = nanmedian(get_long_cadence_period(configMapClass(configMaps))) / SECONDS_PER_MINUTE;

% attach now as start time of test
centroidTestConfigurationStruct.testStartTimeSeconds = clock;

% load conditioned ancillary data from local file containing single
% variable: conditionedAncillaryDataArray
load(dvDataObject.conditionedAncillaryDataFile);

% Number of targets
nTargets = length(dvResultsStruct.targetResultsStruct);

% attach time limit if non-negative otherwise return w/default (incoming) results + alert
timeoutPerTargetSeconds = centroidTestConfigurationStruct.timeoutPerTargetSeconds;
tLimitSecs = min(taskTimeoutSecs - etime(clock,refTime) - DV_BACKEND_PROCESSING_PER_TARGET_SECS .* nTargets, timeoutPerTargetSeconds .* nTargets);
if tLimitSecs < 0
    % add alert and return
    message = 'Insufficient processing time remaining. Returning default values.';
    for iTarget = 1 : nTargets
        [dvResultsStruct] = add_dv_alert(dvResultsStruct,...
            'Ghost diagnostic test', ...
            'warning', message, iTarget, ...
            dvResultsStruct.targetResultsStruct(iTarget).keplerId);
        disp(dvResultsStruct.alerts(end).message);
    end % for iTarget
    return;
else
    centroidTestConfigurationStruct.tLimitSecs = tLimitSecs / nTargets;
end

% ~~~~~~~~~~~~~~~~~~ get the randstreams if they exist
streams = false;
fields = fieldnames(dvDataObject);
if any(strcmp('randStreamStruct', fields))
    randStreams = dvDataObject.randStreamStruct.ghostDiagnosticRandStreams;
    streams = true;
end % if

% ~~~~~~~~~~~~~~~~~~ compute average flux per pixel in the core and halo
% apertures for each quarter
[dvResultsStruct, quarterlyApertureFluxStruct] = build_dv_core_and_halo_flux_timeseries(dvDataObject, dvResultsStruct);

% parse alerts struct from dvResultsStruct
% need two layer struct 'altertsOnly.alerts' in order to use add_dv_alert
alertsOnly = struct('alerts',dvResultsStruct.alerts);

% ~~~~~~~~~~~~~~~~~~ set up detrending configuration structs
% instantiate a raDec2Pix object
raDec2PixObject = raDec2PixClass(raDec2PixModel,'one-based');

% set up detrending structures
coarsePdcConfigurationStruct = struct('ccdModule',0, ...
    'ccdOutput',0, ...
    'cadenceTimes',dvDataObject.dvCadenceTimes, ...
    'pdcModuleParameters',dvDataObject.pdcConfigurationStruct,...
    'raDec2PixObject',raDec2PixObject,...
    'gapFillConfigurationStruct',dvDataObject.gapFillConfigurationStruct,...
    'harmonicsIdentificationConfigurationStruct',dvDataObject.pdcHarmonicsIdentificationConfigurationStruct);

detrendParamStruct = struct('ancillaryDesignMatrixConfigurationStruct',dvDataObject.ancillaryDesignMatrixConfigurationStruct, ...
    'pdcConfigurationStruct',dvDataObject.pdcConfigurationStruct,...
    'coarsePdcConfigurationStruct',coarsePdcConfigurationStruct,...
    'saturationSegmentConfigurationStruct',dvDataObject.saturationSegmentConfigurationStruct,...
    'gapFillConfigurationStruct',dvDataObject.gapFillConfigurationStruct,...
    'tpsConfigurationStruct',dvDataObject.tpsConfigurationStruct);


% ~~~~~~~~~~~~~~~~~~ run  ghost diagnostic tests one target at a time
iTarget = 0;
while (iTarget < nTargets)
    iTarget = iTarget + 1;
    
    % parse data and results structures for this target
    targetStruct = dvDataObject.targetStruct(iTarget);
    targetResults = dvResultsStruct.targetResultsStruct(iTarget);
    keplerId = targetResults.keplerId;
    
    % Number of planets on current target
    nPlanets = length(targetResults.planetResultsStruct);
    
    disp(['DV:ghostDiagnosticTests:Processing target ',num2str(iTarget),', keplerId = ',num2str(keplerId)]);
    
    % set target-specific randstreams
    if streams
        randStreams.set_default(keplerId);
    end % if
    
    % add some needed fields to the targetStruct
    targetStruct.debugLevel = dvDataObject.dvConfigurationStruct.debugLevel;
    targetStruct.targetIndex = iTarget;
    
    % build barycentric time structure for this target
    quarters = dvDataObject.dvCadenceTimes.quarters;
    barycentricTimeStruct = struct('values',dvDataObject.barycentricCadenceTimes(iTarget).midTimestamps,...
        'gapIndicators',dvDataObject.barycentricCadenceTimes(iTarget).gapIndicators,...
        'quarters',quarters);
    
    % Extract quarterly aperture fluxes for this target    
    quarterlyApertureFluxes = quarterlyApertureFluxStruct(iTarget);
    
    % detrend core and halo aperture flux timeseries against conditioned ancillary data
    disp('DV:ghostDiagnosticTests:Detrending core and halo aperture flux across quarters');
    detrendedApertureFluxTimeSeries = ...
        detrend_core_and_halo_flux(dvDataObject,...
        quarterlyApertureFluxes,...
        conditionedAncillaryDataArray,...
        detrendParamStruct,...
        dataAnomalyIndicators,...
        quarters,...
        iTarget);
    toc
    
    % The ghost diagnostic implementation is adapted from the
    % perform_dv_pixel_correlation_tests and perform_dv_centroid_tests codes.
    % and in order to seamlessly exploit the existing machinery used by these codes, we have chosen to reuse parts of it
    % without modification. The tradeoff is that we inherit and use  a few variable and field
    % names that are neither related to nor appropriate for the ghost diagnostic test.
    % The centroid test requires two passes through this loop for each
    % target -- the first for "prf" centroids and the second for "fluxWeighted"
    % centroids.
    % By contrast, the ghost diagnostic tests requires only a single pass through this loop
    % for each target; we therefore associate this pass with centroidType == "prf" in order
    % to reuse the centroid test machinery.
    % For each target: core aperture flux is contained in the prf.ra field, 
    % and the halo aperture flux is contained in
    % the prf.dec field of detrendedApertureFluxTimeSeries. 
    % Again, the reason for these odd and seemingly inappropriate field names .ra and .dec
    % is to allow reuse of the centroid_test_iterative_whitener code *without* modification.
    centroidType = 'prf';
    disp('DV:ghostDiagnosticTests:Processing core and halo aperture fluxes');
    
    % load detrended time series into a temporary struct
    centroidStruct = detrendedApertureFluxTimeSeries.(centroidType);
        
    % If aperture flux data is all gapped throw alert
    if all(centroidStruct.ra.gapIndicators) && all(centroidStruct.dec.gapIndicators)
        disp('     No core and halo aperture data available.  Ghost diagnostic tests results set to default values for all planets.');
        alertsOnly = add_dv_alert(alertsOnly, 'ghost diagnostic tests', 'warning',...
            'No core and halo aperture data available.  Ghost diagnostic tests results set to default values for all planets.',...
            targetStruct.targetIndex, keplerId);
        
        % otherwise do iterative whitening and calculate ghost diagnostic tests
        % statistic and significance
    else
        
        disp('DV:ghostDiagnosticTests:Performing iterative whitening');
        
        % Iterative Whitening
        % set arguments used in non-centroid whitening to empty.
        previousWhitenerResultsStruct = [];
        typeNoneIdentifier = [];
        
        [whitenerResultsStruct, alertsOnly] = ...
            centroid_test_iterative_whitener(previousWhitenerResultsStruct,...
            centroidStruct,...
            targetStruct,...
            targetResults,...
            planetFitConfigurationStruct,...
            trapezoidalFitConfigurationStruct,...
            configMaps,...
            detrendParamStruct,...
            barycentricTimeStruct,...
            centroidTestConfigurationStruct,...
            centroidType,...
            typeNoneIdentifier,...
            alertsOnly);
        
        toc
        
        % output stuff if not timed out in the whitener
        if ~whitenerResultsStruct.timeoutTriggered
            
            % ghost diagnostic tests statistics
            [targetResults, alertsOnly] = ...
                generate_dv_ghost_detection_statistic(whitenerResultsStruct,...
                iTarget,...
                targetResults,...
                alertsOnly);
            
            % Print the mean and std (estimated from the mad) in the core and halo aperture timeseries
            stdCore = 1.4826*mad(whitenerResultsStruct.ra.whitenedCentroid(~(whitenerResultsStruct.ra.whitenedGaps)),1);
            stdHalo = 1.4826*mad(whitenerResultsStruct.dec.whitenedCentroid(~(whitenerResultsStruct.dec.whitenedGaps)),1);
            medianCore = median(whitenerResultsStruct.ra.whitenedCentroid(~(whitenerResultsStruct.ra.whitenedGaps)));
            medianHalo = median(whitenerResultsStruct.dec.whitenedCentroid(~(whitenerResultsStruct.dec.whitenedGaps)));
            if ~isnan(medianCore) || ~isnan(medianHalo) || ~isnan(stdCore) || ~isnan(stdHalo)
                fprintf('keplerId %d: Whitener statistics --  Core aperture flux: median %6.2f, std %6.2f; Halo aperture flux: median %6.2f, std %6.2f\n',keplerId,medianCore,stdCore,medianHalo,stdHalo);
            end
            
            % ghost diagnostic test: statistic/significance results are computed in generate_dv_ghost_detection_statistic
            % The target aperture is defined as the set of pixels in the
            % optimal aperture.
            % The halo aperture is defined as an annulus of pixels
            % surrounding and adjacent to the target aperture.
            % The halo statistic is the correlation (in the whitened
            % domain) between the transit model and the mean of the flux
            % timeseries over the pixels in the halo aperture.
            % The core statistic is the correlation (in the whitened
            % domain) between the transit model and the mean of the
            % flux timeseries over the pixels in the target aperture minus
            % the mean of the flux timeseries over the pixels in the halo aperture.
            % As explained in detailed comments in build_dv_core_and_halo_timeseries,
            % we expect that (ideally) subtraction of halo flux from core
            % flux will yield a core statistic free of ghost contamination; while the halo
            % statistic will be dominated by the ghost contamination flux.
            
            for iPlanet = 1:nPlanets
                % Core statistic and significance
                tCoreValue = targetResults.planetResultsStruct(iPlanet).ghostDiagnosticResults.coreApertureCorrelationStatistic.value;
                tCoreSignificance = targetResults.planetResultsStruct(iPlanet).ghostDiagnosticResults.coreApertureCorrelationStatistic.significance;
                % Halo statistic and significance
                tHaloValue = targetResults.planetResultsStruct(iPlanet).ghostDiagnosticResults.haloApertureCorrelationStatistic.value;
                tHaloSignificance = targetResults.planetResultsStruct(iPlanet).ghostDiagnosticResults.haloApertureCorrelationStatistic.significance;
                fprintf('keplerId %d: Planet #%d ghost diagnostic tests -- core: statistic %6.2f Significance %6.2f; halo: statistic %6.2f Significance %6.2f\n',keplerId,iPlanet,tCoreValue,tCoreSignificance,tHaloValue,tHaloSignificance)
            end
            
            % update dvResultsStruct for iTarget
            dvResultsStruct.targetResultsStruct(iTarget) = targetResults;
            
        else
            % throw alert if timeout occured in iterative whitener
            message = ['Ghost diagnostic test timed out. Results set to default values for all planets for target ',num2str(keplerId),'.'];
            disp(message);
            alertsOnly = add_dv_alert(alertsOnly, 'Ghost diagnostic test ','warning',message,targetStruct.targetIndex,keplerId);
        end
        
    end
        
    % restore the default randstreams
    if streams
        randStreams.restore_default();
    end % if
    
end % loop over targets

% update alerts
dvResultsStruct.alerts = alertsOnly.alerts;

% return
return
