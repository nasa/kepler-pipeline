function [dvResultsStruct, quarterlyApertureFluxStruct] = build_dv_core_and_halo_flux_timeseries(dvDataObject, dvResultsStruct)
% Adapted from perform_dv_pixel_correlation_tests, this function 
% accomplishes the following
% * Build the halo aperture around the core (optimal) aperture,
% * Create structs with core and halo aperture flux time series, quarter by quarter,
% * Add fields containing these structs to dvResultsStruct 
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

% HARD CODE
MAX_PIXELS_FOR_GHOST_DIAGNOSTIC_TEST = 120;
MAGNITUDE_CUTOFF_FOR_GHOST_DIAGNOSTIC_TEST = 11;

% Initialize struct quarterlyApertureFluxStruct
nTargets = length(dvResultsStruct.targetResultsStruct);
innerStruct = struct('totalFlux',[],'uncertainties',[],'gapIndicators',[],'cadenceNumbers',[]);
quarterlyApertureFluxStruct = repmat(struct('haloAperture',[],'coreAperture',[]),1,nTargets);

% Parse alerts struct from dvResultsStruct. Place in two layer struct in order
% to use directly in add_dv_alert
alertsOnly = struct('alerts',dvResultsStruct.alerts);
    
% ~~~~~~~~~~~~~~~~~~ loop over targets
for iTarget=1:nTargets
    
    % Parse data, results and alerts structures for this target
    % Add some fields to the target data struct which may or may not be needed
    targetStruct = dvDataObject.targetStruct(iTarget);
    targetResults = dvResultsStruct.targetResultsStruct(iTarget);
    targetStruct.debugLevel = dvDataObject.dvConfigurationStruct.debugLevel;
    targetStruct.targetIndex = iTarget;
    keplerId = targetStruct.keplerId;
    keplerMag = targetStruct.keplerMag.value;
    nTables = length(targetResults.planetResultsStruct(1).pixelCorrelationResults);
    
    % Initialize inner struct of quarterlyApertureFluxStruct
    quarterlyApertureFluxStruct(iTarget).haloAperture = repmat(innerStruct,1,nTables);
    quarterlyApertureFluxStruct(iTarget).coreAperture = repmat(innerStruct,1,nTables);
    
    % Determine whether or not to proceed for this target
    maxPixels = 0;
    for iTable = 1:nTables
        
        % Populate the fields in quarterlyApertureFluxStruct. The aperture fluxes and variances are summed over the number of
        % pixels that contributed. gapIndicators time series are ORed together for all the pixels.
        % Unless we can assume that the number of tables is the same for every target,
        % we have to initialize quarterlyApertureFluxStruct on the fly.
        
        % Determine maxPixels
        nPixels = ...
            length(targetResults.planetResultsStruct(1).pixelCorrelationResults(iTable).pixelCorrelationStatisticStruct);
        maxPixels = max(nPixels, maxPixels);
    
    end % for iTable
    
    if maxPixels > MAX_PIXELS_FOR_GHOST_DIAGNOSTIC_TEST && ...
            keplerMag < MAGNITUDE_CUTOFF_FOR_GHOST_DIAGNOSTIC_TEST
        messageString = 'ghost diagnostic tests will not be performed for saturated target with large pixel mask(s).';
        [alertsOnly] = add_dv_alert(alertsOnly, 'ghost diagnostic tests', 'warning', ...
            messageString, targetStruct.targetIndex, keplerId);
        disp(alertsOnly.alerts(end).message);
        continue;
    end % if
    
    % Check that transit fit is available for at least one planet - if not,
    % skip to next target
    allTransitsFitArray = [targetResults.planetResultsStruct.allTransitsFit];
    transitModelsChiSquare = [allTransitsFitArray.modelChiSquare];
    trapezoidalFitArray = [targetResults.planetResultsStruct.trapezoidalFit];
    trapezoidalModelsChiSquare = [trapezoidalFitArray.modelChiSquare];
    if( isequal(transitModelsChiSquare, -ones(size(transitModelsChiSquare))) && ...
           isequal(trapezoidalModelsChiSquare, -ones(size(trapezoidalModelsChiSquare))) )
        allPlanetModelFitsFailed = true;
    else
        allPlanetModelFitsFailed = false;
    end
    
    if( allPlanetModelFitsFailed )
        % Transit model availability alert
        message = 'No transit fits available for any planet. Detection statistic and significance set to default values for all planets';
        disp(['     ',message]);
        alertsOnly = add_dv_alert(alertsOnly,'ghost diagnostic tests', 'warning',...
            message,targetStruct.targetIndex, keplerId);
        continue;
    end
    
    % begin processing this target
    disp(['Processing pixels for KeplerId = ',num2str(keplerId)]);
    
    % loop over target data structs (one for each target table, i.e. loop over quarters)
    for iTable = 1:length(targetStruct.targetDataStruct)
            
        % Parse cadence indices from object
        cadenceNumbers = dvDataObject.dvCadenceTimes.cadenceNumbers;
        startCadence = targetStruct.targetDataStruct(iTable).startCadence;
        endCadence = targetStruct.targetDataStruct(iTable).endCadence;
        validCadences = cadenceNumbers >= startCadence & cadenceNumbers <= endCadence;

        % Extract the calibrated pixel time series directly from the pixelDataFile
        % calibratedPixelsTimeSeries = extract_pixel_timeseries(targetStruct.targetDataStruct(iTable));
        pixelDataFileName = targetStruct.targetDataStruct(iTable).pixelDataFileName;
        [pixelDataStruct, status, path, name, ext] = ...
            file_to_struct(pixelDataFileName, 'pixelDataStruct');                                   %#ok<ASGLU>
        if ~status
            error('dv:extractPixelTimeseries:unknownDataFileType', ...
                'unknown pixel data file type (%s%s)', ...
                name, ext);
        end % if

        % calibratedPixelsTimeSeries is a 1xnPixels struct with fields values, gapIndicators, and
        % uncertainties
        calibratedPixelsTimeSeries = [pixelDataStruct.calibratedTimeSeries];
        pixelRows = [pixelDataStruct.ccdRow];
        pixelColumns = [pixelDataStruct.ccdColumn];
        
        % Indicator for Core aperture pixels
        isInCoreAperture = [pixelDataStruct.inOptimalAperture];
        clear pixelDataStruct
        nPixels = length(calibratedPixelsTimeSeries);
        allCadencesGapped = false(nPixels,1);

        % ~~~~~~~~~~~~~~~~~~~~~~~ core and aperture fluxes
        % Form halo and core flux time series for
        % the total unwhitened flux, for the current quarter
        % (targetTable)

        % Define Halo aperture pixels
        isInNewAperture = add_ring_to_aperture(pixelRows, pixelColumns, isInCoreAperture);
        isInHaloAperture = isInNewAperture&~isInCoreAperture;
        nHaloAperturePixels = sum(isInHaloAperture);
        nCoreAperturePixels = sum(isInCoreAperture);
        
        % Indices of core pixels and of halo pixels
        targetPixels = 1:nPixels;
        corePixels = targetPixels(isInCoreAperture);
        haloPixels = targetPixels(isInHaloAperture);

        % Compute average core and halo aperture fluxes per pixel
        
        % Initialize
        coreApertureFlux = zeros(sum(validCadences),1);
        haloApertureFlux = zeros(sum(validCadences),1);
        coreApertureFluxVariance = zeros(sum(validCadences),1);
        haloApertureFluxVariance = zeros(sum(validCadences),1);
        haloApertureGapIndicators = false(sum(validCadences),1);
        coreApertureGapIndicators = false(sum(validCadences),1);

        % Proceed only if the data is not all gapped, otherwise throw alert
        if( all(sum([calibratedPixelsTimeSeries(corePixels).gapIndicators],2))||all(sum([calibratedPixelsTimeSeries(haloPixels).gapIndicators],2)) )
            % allCadencesGapped(iPixel) = true;
            allCadencesGapped = true;
        else

            % Accumulate core (optimal) aperture flux sum timeseries
            % and halo aperture flux timeseries
            % !!!!! have not figured out a way
            % to incorporate the other fields pixelGaps,
            % robustWeights

            % Compute average flux per core pixel and its variance, and OR the gapIndicators for the core
            % (optimal) aperture. Then take the average flux per pixel and reduce the variance by nCoreAperturePixels
            coreApertureFlux = sum([calibratedPixelsTimeSeries(corePixels).values],2)./nCoreAperturePixels;
            coreApertureFluxVariance = sum([calibratedPixelsTimeSeries(corePixels).uncertainties].^2,2)./nCoreAperturePixels;
            coreApertureGapIndicators = any([calibratedPixelsTimeSeries(corePixels).gapIndicators],2);

            % Compute the average flux per halo pixel and its variance, and OR the gapIndicators for the halo
            % aperture. Then take the average flux per pixel and reduce the variance by nHaloAperturePixels
            haloApertureFlux = sum([calibratedPixelsTimeSeries(haloPixels).values],2)./nHaloAperturePixels;
            haloApertureFluxVariance = sum([calibratedPixelsTimeSeries(haloPixels).uncertainties].^2,2)./nHaloAperturePixels;
            haloApertureGapIndicators = any([calibratedPixelsTimeSeries(haloPixels).gapIndicators],2);

            % Redefine coreApertureFlux in place here, as the difference of coreApertureFlux and haloApertureFlux
            % The variance of the difference flux is the sum of the core and halo flux variances
            % If a ghost transit signal is present it will overlay a large region on the focal plane that includes the core aperture and extends beyond he halo aperture. 
            % The ghost contamination flux is dominated by target flux in
            % the target aperture.  Conversely, we expect that in the halo,
            % ghost contamination is the dominant contribution to the flux and is therefore a good estimate of the ghost contamination flux
            % Subtracting the halo flux from the core flux approximately removes the ghost contamination background from the flux in the core
            % aperture, yielding a target flux timeseries that is (ideally) free of ghost contamination.
            coreApertureFlux = coreApertureFlux - haloApertureFlux;
            coreApertureFluxVariance = coreApertureFluxVariance + haloApertureFluxVariance;
            coreApertureGapIndicators = coreApertureGapIndicators | haloApertureGapIndicators;

        end % compute the data needed for the ghost diagnostic

        % Populate the fields in quarterlyApertureFluxStruct. The aperture fluxes and variances are averaged over the number of
        % pixels that contributed. gapIndicators time series are ORed together for all the pixels.
        quarterlyApertureFluxStruct(iTarget).haloAperture(iTable).totalFlux = haloApertureFlux;
        quarterlyApertureFluxStruct(iTarget).haloAperture(iTable).uncertainties = sqrt(haloApertureFluxVariance);
        quarterlyApertureFluxStruct(iTarget).coreAperture(iTable).totalFlux = coreApertureFlux;
        quarterlyApertureFluxStruct(iTarget).coreAperture(iTable).uncertainties = sqrt(coreApertureFluxVariance);
        quarterlyApertureFluxStruct(iTarget).haloAperture(iTable).gapIndicators = haloApertureGapIndicators;
        quarterlyApertureFluxStruct(iTarget).coreAperture(iTable).gapIndicators = coreApertureGapIndicators;
        quarterlyApertureFluxStruct(iTarget).haloAperture(iTable).cadenceNumbers = cadenceNumbers(validCadences);
        quarterlyApertureFluxStruct(iTarget).coreAperture(iTable).cadenceNumbers = cadenceNumbers(validCadences);

        % ~~~~~~~~~~~~~~~~~~~~~~~ check alert status flags and issue alerts if set

        % Throw alert if allCadencesGapped
        if(allCadencesGapped)
            quarterId = targetStruct.targetDataStruct(iTable).quarter;
            messageString = ['No pixel data available for core and aperture flux in quarter ',num2str(quarterId),'.'];
            disp(['     ',messageString]);
            alertsOnly = add_dv_alert(alertsOnly, 'ghost diagnostic tests', 'warning',...
                messageString, targetStruct.targetIndex, keplerId);
        end
        
    end % loop over target tables (quarters)
    
    % ~~~~~~~~~~~~~~~~~~~~~~~ update dvResultsStruct with results for iTarget
    % dvResultsStruct.targetResultsStruct(iTarget) = targetResults;
      
end % loop over targets

% Update dvResultsStruct with alerts
dvResultsStruct.alerts = alertsOnly.alerts;

return
