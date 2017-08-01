function dvResultsStruct = perform_dv_centroid_tests(dvDataObject, dvResultsStruct)
%
% function dvResultsStruct = perform_dv_centroid_tests(dvDataObject, dvResultsStruct)
%
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


% hard coded
DV_BACKEND_PROCESSING_PER_TARGET_SECS = 3600;

% unit conversion
SECONDS_PER_MINUTE = get_unit_conversion('min2sec');

% parse stuff from dvDataObject
planetFitConfigurationStruct = dvDataObject.planetFitConfigurationStruct;
trapezoidalFitConfigurationStruct = dvDataObject.trapezoidalFitConfigurationStruct;
configMaps = dvDataObject.configMaps;
raDec2PixModel = dvDataObject.raDec2PixModel;
dataAnomalyIndicators = dvDataObject.dvCadenceTimes.dataAnomalyFlags;
kics = dvDataObject.kics;
taskTimeoutSecs = dvDataObject.taskTimeoutSecs;
refTime = dvDataObject.refTime;

% extract centroidTestConfigurationStruct
% calculate and attach minutes per cadence
centroidTestConfigurationStruct = dvDataObject.centroidTestConfigurationStruct;
centroidTestConfigurationStruct.minutesPerCadence = nanmedian(get_long_cadence_period(configMapClass(configMaps))) / SECONDS_PER_MINUTE;

% attach now as start time of test
centroidTestConfigurationStruct.testStartTimeSeconds = clock;

% parse alerts struct from dvResultsStruct
% need two layer struct 'altertsOnly.alerts' in order to use add_dv_alert
alertsOnly = struct('alerts',dvResultsStruct.alerts);

% load conditioned ancillary data from local file containing single
% variable: conditionedAncillaryDataArray 
load(dvDataObject.conditionedAncillaryDataFile);


% ~~~~~~~~~~~~~~~~~~ retrieve normalized target flux from results struct
% get the detrended normalized harmonic corrected flux time series from the
% initial flux for the first planet candidate for all targets
nTargets = length(dvResultsStruct.targetResultsStruct);

% attach time limit if non-negative otherwise return w/default (incoming) results + alert
timeoutPerTargetSeconds = centroidTestConfigurationStruct.timeoutPerTargetSeconds;
tLimitSecs = min(taskTimeoutSecs - etime(clock,refTime) - DV_BACKEND_PROCESSING_PER_TARGET_SECS .* nTargets, timeoutPerTargetSeconds .* nTargets);
if tLimitSecs < 0
    % add alert and return
    message = 'Insufficient processing time remaining. Returning default values.';
    for iTarget = 1 : nTargets
        [dvResultsStruct] = add_dv_alert(dvResultsStruct,...
            'Centroid motion test', ...
            'warning', message, iTarget, ...
            dvResultsStruct.targetResultsStruct(iTarget).keplerId);
        disp(dvResultsStruct.alerts(end).message);
    end % for iTarget
    return;
else
    centroidTestConfigurationStruct.tLimitSecs = tLimitSecs / nTargets;
end

% populate last element first to allocate enough space
for iTarget = nTargets:-1:1
    normalizedTargetFlux(iTarget) = ...
        dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(1).planetCandidate.initialFluxTimeSeries;
    % treat filled flux indices as gaps for the centroid test
    if( ~isempty(normalizedTargetFlux(iTarget).filledIndices) )
        normalizedTargetFlux(iTarget).gapIndicators( normalizedTargetFlux(iTarget).filledIndices ) = ...
            true(size(normalizedTargetFlux(iTarget).filledIndices));
    end    
end


% ~~~~~~~~~~~~~~~~~~ set up detrending configuation structs
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


% get the randstreams if they exist
streams = false;
fields = fieldnames(dvDataObject);
if any(strcmp('randStreamStruct', fields))
    randStreams = dvDataObject.randStreamStruct.centroidTestRandStreams;
    streams = true;
end % if

% ~~~~~~~~~~~~~~~~~~ run centroid tests one target at a time
iTarget = 0;
while iTarget < nTargets
    iTarget = iTarget + 1;

    % parse data and results structures for this target
    targetStruct = dvDataObject.targetStruct(iTarget);
    targetResults = dvResultsStruct.targetResultsStruct(iTarget);
    keplerId = targetResults.keplerId;
    ukirtImageFileName = targetStruct.ukirtImageFileName;
    
    disp(['DV:CentroidTest:Processing target ',num2str(iTarget),', keplerId = ',num2str(keplerId)]);
    
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

    % detrend centroid timeseries against conditioned ancillary data
    disp('DV:CentroidTest:Detrend centroids across quarters');
    detrendedCentroidTimeSeries = ...
        detrend_centroids(dvDataObject,...
                            conditionedAncillaryDataArray,...
                            detrendParamStruct,...
                            dataAnomalyIndicators,...
                            quarters,...
                            iTarget);
    
    % test centroids in two passes, first pass == prf centroids, second pass == flux-weighted centroids
    pass = 0;
    while pass < 2
        pass = pass + 1;        
        if pass == 1
            centroidType = 'prf';            
        else
            centroidType = 'fluxWeighted';
        end
           
        disp(['DV:CentroidTest:Processing ',centroidType,' centroids'] );
        
        
        % load detrended centroid time series into temporary struct
        centroidStruct = detrendedCentroidTimeSeries.(centroidType);
                
        % if centroid data is all gapped throw alert
        if all(centroidStruct.ra.gapIndicators) && all(centroidStruct.dec.gapIndicators)
            disp('     No centroid data available. Centroid test results set to default values for all planets.');
            alertsOnly = add_dv_alert(alertsOnly, ['Centroid test ',centroidType], 'warning',...
                            'No centroid data available. Centroid test results set to default values for all planets.',...
                            targetStruct.targetIndex, keplerId);
                        
        % otherwise do centroid tests                
        else
            
            disp('DV:CentroidTest:Performing iterative whitening');

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
                                                
            % break for timeout in iterative whitener                                    
            if whitenerResultsStruct.timeoutTriggered
                break;
            end
            

            generate_centroid_cloud_plots(centroidStruct,...
                                            targetStruct,...
                                            targetResults,...
                                            whitenerResultsStruct,...
                                            normalizedTargetFlux(iTarget),...                                        
                                            centroidType,...
                                            centroidTestConfigurationStruct,...
                                            dvDataObject.dvConfigurationStruct.debugLevel);

            [targetResults, alertsOnly] = ...
                estimate_dv_centroid_offset(centroidStruct,...
                                            targetStruct,...
                                            targetResults,...
                                            whitenerResultsStruct,...
                                            normalizedTargetFlux(iTarget),...                                            
                                            centroidType,...
                                            centroidTestConfigurationStruct,...
                                            alertsOnly);

            [targetResults, alertsOnly] = ...
                estimate_dv_background_source_offset(targetStruct,...
                                                        targetResults,...
                                                        whitenerResultsStruct,...
                                                        centroidType,...
                                                        centroidTestConfigurationStruct,...
                                                        alertsOnly);

            [targetResults, alertsOnly] = ...
                generate_dv_centroid_detection_statistic(whitenerResultsStruct,...
                                                              targetStruct,...
                                                              targetResults,...
                                                              centroidType,...
                                                              alertsOnly);
        end
    end
    
    if ~whitenerResultsStruct.timeoutTriggered        
        % produce centroid test diagnostic figures for iTarget
        rootDir = targetResults.dvFiguresRootDirectory;        
        [alertsOnly] = plot_dv_centroid_test_source_offsets(rootDir, iTarget, ...
            keplerId, kics, targetResults, ukirtImageFileName, alertsOnly);        
        % update dvResultsStruct for iTarget
        dvResultsStruct.targetResultsStruct(iTarget) = targetResults;        
    else
        % throw alert if timeout occured in iterative whitener
        message = ['Centroid test timed out. Results set to default values for all planets for target ',num2str(keplerId),'.'];
        disp(message);
        alertsOnly = add_dv_alert(alertsOnly, ['Centroid test ',centroidType],'warning',message,targetStruct.targetIndex,keplerId);
    end
    
    % restore the default randstreams
    if streams
        randStreams.restore_default();
    end % if    
end

% update alerts
dvResultsStruct.alerts = alertsOnly.alerts;

