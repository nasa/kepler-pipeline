function [dropoutCadences, flareCadences] = detect_pixel_sensitivity_dropouts( tpsObject, tpsResults )
%
% detect_pixel_sensitivity_dropouts -- determine the (non-super-resolution) cadences which
% are contaminated by a pixel sensitivity dropout
%
% dropoutCadences = detect_pixel_sensitivity_dropouts( tpsObject, tpsResults, extendedFlux
%    ) uses matched-filter detection to identify pixel sensitivity dropouts (which appear
%    in flux time series as step reductions in the flux value).  In order to screen out
%    false-positive detections, the resulting dropout detection statistics are compared to
%    the detection statistics for transit pulses.  The returned array dropoutCadences is a
%    logical array of dimension nCadences x nStars, with true values for cadences which
%    are in a region contaminated by a pixel sensitivity dropout and false values for
%    cadences which are not contaminated.
%
% Version date:  2011-April-29.
%
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

% Modification History:
%
%    2011-April-29, PT:
%        Change the false-positive detection criteria:  if a transit has EITHER a leading
%        or trailing cluster of "dropout detections," then those detections are considered
%        false positive detections and vetoed (forermly it needed to have BOTH clusters).
%
%=========================================================================================


% extract the relevant parameters and compute others

  nCadences             = length( tpsObject.cadenceTimes.midTimestamps ) ;
  nStars                = length( tpsObject.tpsTargets ) ;
  debugLevel            = tpsObject.tpsModuleParameters.debugLevel ;
  superResolutionFactor = tpsObject.tpsModuleParameters.superResolutionFactor;
  cadencesPerDay        = tpsObject.tpsModuleParameters.cadencesPerDay;
  dropoutThreshold      = tpsObject.tpsModuleParameters.pixelSensitivityDropoutThreshold ;
  transitThreshold      = tpsObject.tpsModuleParameters.searchTransitThreshold ;
  clusterProximity      = tpsObject.tpsModuleParameters.clusterProximity ;
  
% parameters related to the median-filtering of the time series -- the window length of
% the median filter, and the # of days standoff before and after a detected discontinuity
  
  medfiltWindowLengthCadences = tpsObject.tpsModuleParameters.medfiltWindowLengthDays * ...
      cadencesPerDay ;
  medfiltStandoffCadences     = tpsObject.tpsModuleParameters.medfiltStandoffDays * ...
      cadencesPerDay ;
  medfiltWindowLengthCadences = round( medfiltWindowLengthCadences ) ;
  medfiltStandoffCadences     = round( medfiltStandoffCadences ) ;
  
% allocate the return array

  dropoutCadences = false( nCadences, nStars ) ;
  flareCadences = false( nCadences, nStars ) ;
  
% set up progress reporting  

  displayProgressInterval = 0.1 ; % display progress every 10% or so
  nCallsProgress = nStars * displayProgressInterval ;
  progressReports = nCallsProgress:nCallsProgress:nStars ;
  progressReports = unique(floor(progressReports)) ;
  iProgress = 0 ;
  
% reshape the TPS results struct to be more convenient

  tpsResults = tpsResults(:) ;
  nTransitPulses = length(tpsResults) / nStars ;
  tpsResults = reshape( tpsResults, nStars, nTransitPulses ) ; % so tpsResults( iStar, iPulse ) 
  
% get the filter coefficients  
  
  if (strcmp(tpsObject.tpsModuleParameters.waveletFamily, 'daub'))
      scalingFilterCoeffts = daubechies_low_pass_scaling_filter( ...
          tpsObject.tpsModuleParameters.waveletFilterLength );    
  end
  
% set up the superResolutionObject

  superResolutionStruct = struct('superResolutionFactor', 1, ...
      'pulseDurationInCadences', [], 'usePolyFitTransitModel', false, ...
      'useCustomTransitModel', true) ;
  superResolutionObject = superResolutionClass( superResolutionStruct, scalingFilterCoeffts ) ;  
    
% loop over stars

  for jStar = 1:nStars
      
      dropoutStatistic = zeros(nCadences, nTransitPulses);
      flareStatistic = zeros(nCadences, nTransitPulses);
      
      iProgress = iProgress + 1 ;
      if ( ismember( iProgress, progressReports ) && debugLevel >= 0 )
          disp( [ '    searching for pixel sensitivity dropouts in star number ', ...
              num2str(iProgress), ...
              ' out of ', num2str(nStars),' total stars' ] ) ;
      end
      
      % search for SPSD's
      
      for kPulse = 1:nTransitPulses
          
          % set the waveletObject into the superResolutionObject
          waveletObject = tpsResults(jStar,kPulse).waveletObject ;
          superResolutionObject = set_wavelet_object( superResolutionObject, waveletObject ) ;
          
          % set the pulse duration
          pulseLengthHours = tpsResults(jStar,kPulse).trialTransitPulseInHours;
          pulseLengthCadences = round(tpsObject.tpsModuleParameters.cadencesPerHour*pulseLengthHours);
          superResolutionObject = set_pulse_duration( superResolutionObject, pulseLengthCadences ) ;
          
          trialShape = zeros(pulseLengthCadences, superResolutionFactor) ;
          trialShape(1:floor(pulseLengthCadences/2),:) = 1 ;
          trialShapeMiddleCadence = ...
              0:(1/superResolutionFactor):((superResolutionFactor-1)/superResolutionFactor) ;
          trialShape(floor(pulseLengthCadences/2)+1,:) = trialShapeMiddleCadence ;
      
          correlationTimeSeries   = zeros( nCadences, superResolutionFactor ) ;
          normalizationTimeSeries = zeros( nCadences, superResolutionFactor ) ;
      
%         loop over super-resolution trial shapes

          for jSample = 1:superResolutionFactor

              % set the pulse into the superResolutionObject

              superResolutionObject = set_trial_transit_pulse( superResolutionObject, trialShape(:,jSample) ) ;
              superResolutionObject = set_statistics_time_series_shift_length( superResolutionObject ) ;

    %         perform the wavelet calculation
              [~, correlation, normalization] =  ...
                  set_hires_statistics_time_series( superResolutionObject, nCadences ) ;

              correlationTimeSeries(:,jSample)   = correlation(1:nCadences) ;
              normalizationTimeSeries(:,jSample) = normalization(1:nCadences) ;

          end % loop over super-resolution counter
      
%         get the max dropout statistic for each cadence (ie, project away the
%         super-resolution of the calculation)
      
          dropoutStatisticPulse = correlationTimeSeries ./ normalizationTimeSeries ;
          dropoutStatisticPulse = max( dropoutStatisticPulse, [], 2 ) ;
          dropoutStatistic(:,kPulse) = dropoutStatisticPulse;
      end
      
      % search for the opposite of SPSD's - flares
      
      for kPulse = 1:nTransitPulses
          
          % set the waveletObject into the superResolutionObject
          waveletObject = tpsResults(jStar,kPulse).waveletObject ;
          superResolutionObject = set_wavelet_object( superResolutionObject, waveletObject ) ;
          
          % set the pulse duration
          pulseLengthHours = tpsResults(jStar,kPulse).trialTransitPulseInHours;
          pulseLengthCadences = round(tpsObject.tpsModuleParameters.cadencesPerHour*pulseLengthHours);
          superResolutionObject = set_pulse_duration( superResolutionObject, pulseLengthCadences ) ;
          
          trialShape = zeros(pulseLengthCadences, superResolutionFactor) ;
          trialShape(1:floor(pulseLengthCadences/2),:) = 1 ;
          trialShapeMiddleCadence = ...
              0:(1/superResolutionFactor):((superResolutionFactor-1)/superResolutionFactor) ;
          trialShape(floor(pulseLengthCadences/2)+1,:) = trialShapeMiddleCadence ;
          trialShape = -1 .* trialShape;
      
          correlationTimeSeries   = zeros( nCadences, superResolutionFactor ) ;
          normalizationTimeSeries = zeros( nCadences, superResolutionFactor ) ;
      
%         loop over super-resolution trial shapes

          for jSample = 1:superResolutionFactor

              % set the pulse into the superResolutionObject

              superResolutionObject = set_trial_transit_pulse( superResolutionObject, trialShape(:,jSample) ) ;
              superResolutionObject = set_statistics_time_series_shift_length( superResolutionObject ) ;

    %         perform the wavelet calculation
              [~, correlation, normalization] =  ...
                  set_hires_statistics_time_series( superResolutionObject, nCadences ) ;

              correlationTimeSeries(:,jSample)   = correlation(1:nCadences) ;
              normalizationTimeSeries(:,jSample) = normalization(1:nCadences) ;

          end % loop over super-resolution counter
      
%         get the max dropout statistic for each cadence (ie, project away the
%         super-resolution of the calculation)
      
          flareStatisticPulse = correlationTimeSeries ./ normalizationTimeSeries ;
          flareStatisticPulse = max( flareStatisticPulse, [], 2 ) ;
          flareStatistic(:,kPulse) = flareStatisticPulse;
      end
      
      
      
%     compute the transit detection statistics for transits on this target, considering
%     all of the pulse durations and projecting away the super-resolution character of the
%     detections

      transitStatistic = zeros( nCadences, nTransitPulses ) ;
      
      for kPulse = 1:nTransitPulses
          
          correlation   = tpsResults( jStar, kPulse ).correlationTimeSeriesHiRes(:) ;
          normalization = tpsResults( jStar, kPulse ).normalizationTimeSeriesHiRes(:) ;
          correlation   = reshape( correlation, superResolutionFactor, nCadences ) ;
          normalization = reshape( normalization, superResolutionFactor, nCadences ) ;
          
          transitStatistic(:,kPulse) = max( correlation' ./ normalization', [], 2 ) ;
          
      end
      
%     if the noise estimate was done by quarter then we will have NaNs
      
      dropoutStatistic(isnan(dropoutStatistic)) = 0;
      flareStatistic(isnan(flareStatistic)) = 0;
      transitStatistic(isnan(transitStatistic)) = 0;
      
%     look for cadences which have a likely dropout, and cadences which are in a
%     likely giant transit.  The former will have the dropout statistic > the threshold
%     AND greater than all transit statistics; the latter will have transit statistic >
%     the transit threshold AND at least 1 transit statistic > the dropout statistic

      dropoutDetection = any(dropoutStatistic > dropoutThreshold, 2) & ...
          all( dropoutStatistic > transitStatistic, 2 ) ;
      flareDetection = any(flareStatistic > dropoutThreshold, 2) & ...
          all( flareStatistic > transitStatistic, 2 ) ;
      transitDetection = any( transitStatistic > transitThreshold, 2 ) & ...
          any( transitStatistic > dropoutStatistic, 2 ) ;
      transitDetectionFlare = any( transitStatistic > transitThreshold, 2 ) & ...
          any( transitStatistic > flareStatistic, 2 ) ;
      
%     A very deep transit will typically have a cluster of cadences prior and following
%     which match the criteria for a dropout; veto those now

      if any( dropoutDetection ) && any( transitDetection )
          dropoutDetection = veto_transit_leading_trailing_clusters( dropoutDetection, ...
              transitDetection, clusterProximity ) ;
      end
      
      if any( flareDetection ) && any( transitDetectionFlare )
          flareDetection = veto_transit_leading_trailing_clusters( flareDetection, ...
              transitDetectionFlare, clusterProximity ) ;
      end

%     if there are any detected dropouts, then we need to identify the cadences before and
%     after the dropout which are affected, and tell the transit detector to ignore those
%     cadences

      if any( flareDetection )
          flareCadences(:,jStar) = identify_cadences_contaminated_by_dropout( ...
              flareDetection, tpsResults( jStar, 1 ).detrendedFluxTimeSeries, ...
              medfiltWindowLengthCadences, medfiltStandoffCadences ) ;
          
%         examine each event to make sure there is a discontinuity above background  
          
          flareCadences(:,jStar) = remove_false_detections( flareCadences(:,jStar), ...
              tpsResults( jStar, 1 ).detrendedFluxTimeSeries, max(dropoutStatistic,[],2) ) ;
      end

      if any( dropoutDetection )
          dropoutCadences(:,jStar) = identify_cadences_contaminated_by_dropout( ...
              dropoutDetection, tpsResults( jStar, 1 ).detrendedFluxTimeSeries, ...
              medfiltWindowLengthCadences, medfiltStandoffCadences ) ;
          
%         examine each event to make sure there is a discontinuity above background  
          
          dropoutCadences(:,jStar) = remove_false_detections( dropoutCadences(:,jStar), ...
              tpsResults( jStar, 1 ).detrendedFluxTimeSeries, max(dropoutStatistic,[],2) ) ;
      end
      
      dropoutCadences(:,jStar) = flareCadences(:,jStar) | dropoutCadences(:,jStar);
      
  end % loop over target stars
  
  
return

%=========================================================================================

% subfunction that vetoes spurious detections

function dropoutCadences = remove_false_detections( dropoutCadences, ...
    detrendedFluxTimeSeries, maxDropoutStatistic ) 

MIN_CHUNK_SIZE = 10;
CHUNK_SIZE = 25;
PEAK_PADDING = 3;
STD_MULTIPLIER = 3;

nCadences = length(detrendedFluxTimeSeries);
dropoutClusters = identify_contiguous_integer_values( find(dropoutCadences) );

for iCluster = 1:length(dropoutClusters)
    clusterIndices = dropoutClusters{iCluster};
    peakIndex = locate_center_of_asymmetric_peak(maxDropoutStatistic(clusterIndices));
    peakIndex = clusterIndices(peakIndex);
    
    indicesLeft = max(peakIndex - PEAK_PADDING - CHUNK_SIZE + 1,1):max(peakIndex - PEAK_PADDING,1);
    indicesRight = min(peakIndex + PEAK_PADDING,nCadences):min(peakIndex + PEAK_PADDING + CHUNK_SIZE - 1,nCadences);
    
    if length(indicesLeft) > MIN_CHUNK_SIZE && length(indicesRight) > MIN_CHUNK_SIZE
        medianLeft = median(detrendedFluxTimeSeries(indicesLeft));
        medianRight = median(detrendedFluxTimeSeries(indicesRight));
        medianDelta = abs(medianLeft - medianRight);
        
        % detrend the chunks to set the MAD's on the same level - just do a
        % simple linear detrending
        fitLeft = robustfit( indicesLeft,detrendedFluxTimeSeries(indicesLeft) );
        fitRight = robustfit( indicesRight,detrendedFluxTimeSeries(indicesRight) );
        fitLeft = fitLeft(1) + fitLeft(2)*indicesLeft;
        fitRight = fitRight(1) + fitRight(2)*indicesRight;
        fitLeft = fitLeft(:);
        fitRight = fitRight(:);
        
        % get the MAD equivalent STD on left and right
        stdLeft = 1.4826 * mad(detrendedFluxTimeSeries(indicesLeft) - fitLeft,1) ;
        stdRight = 1.4826 * mad(detrendedFluxTimeSeries(indicesRight) - fitRight,1) ;
        
        if medianDelta < STD_MULTIPLIER * mean([stdLeft stdRight])
            dropoutCadences(clusterIndices) = false;
        end
    end
end

return

%=========================================================================================

% subfunction which performs the veto of clusters of false-positive dropout detections
% which lead and trail a very deep transit

function dropoutDetection = veto_transit_leading_trailing_clusters( dropoutDetection, ...
    transitDetection, clusterProximity )

% convert to clusters and combine clusters of dropout detections which are separated by a
% small number of cadences

  transitClusters = identify_contiguous_integer_values( find( transitDetection ) ) ;
  dropoutClusters = identify_contiguous_integer_values( find( dropoutDetection ) ) ;
  dropoutClusters = combine_nearby_clusters( dropoutClusters, clusterProximity ) ;
  
% loop over the transit clusters and look for a leading and a trailing dropout cluster 

  for iTransit = 1:length(transitClusters)
      
      thisTransitCluster = transitClusters{iTransit} ;
      leadingCluster     = [] ; 
      trailingCluster    = [] ;
      
      for iDropout = 1:length( dropoutClusters )
          
          thisDropoutCluster = dropoutClusters{iDropout} ;
          if thisDropoutCluster(end) + 1 == thisTransitCluster(1)
              leadingCluster = thisDropoutCluster ;
          end
          if thisDropoutCluster(1) - 1 == thisTransitCluster(end)
              trailingCluster = thisDropoutCluster ;
          end
          
      end % loop over dropout clusters
      
%     If there is a leading cluster of "dropout detections" to this transit, they are most
%     likely false positives and should not be treated as real dropouts; same goes for the
%     trailing cluster, if any

      if ~isempty(leadingCluster)
          dropoutDetection(leadingCluster) = false ;
      end
      if ~isempty(trailingCluster)
          dropoutDetection(trailingCluster) = false ;
      end
      
      
  end % loop over transit clusters

return

%=========================================================================================

% subfunction which identifies cadences which are compromised by their proximity to a
% pixel sensitivity dropout event

function dropoutCadences = identify_cadences_contaminated_by_dropout( ...
              dropoutDetection, fluxTimeSeries, ...
              medfiltWindowLengthCadences, medfiltStandoffCadences )
          
% initialize

  dropoutCadences = false( size( fluxTimeSeries ) ) ;
  trend           = nan( size( fluxTimeSeries ) ) ;
  
% get clusters of dropout detections and non-dropout-detection cadences

  dropoutClusters = identify_contiguous_integer_values( find( dropoutDetection ) ) ;
  regularClusters = identify_contiguous_integer_values( find( ~dropoutDetection ) ) ;
  
% use medfilt1 to determine the local trendline, leaving out the areas around the detected
% discontinuities.  The latter are identified as areas before and after each cluster of
% regular cadences.  Note that special handling is needed for the first cluster and last
% cluster.  

  for iCluster = 1:length(regularClusters)
      
      if regularClusters{iCluster}(1) == 1
          clusterStart = 1 ;
      else
          clusterStart = regularClusters{iCluster}(1) + medfiltStandoffCadences ;
      end
      if regularClusters{iCluster}(end) == length(trend)
          clusterEnd = length(trend) ;
      else
          clusterEnd = regularClusters{iCluster}(end) - medfiltStandoffCadences ;
      end
      trend(clusterStart:clusterEnd) = medfilt1( fluxTimeSeries(clusterStart:clusterEnd), ...
          medfiltWindowLengthCadences ) ;
      
  end
  
% Fill in missing values with interpolation, forcing the ends to zero if they are in
% regions which are being interpolated / extrapolated to

  if isnan(trend(1))
      trend(1) = 0 ;
  end
  if isnan(trend(end))
      trend(end) = 0 ;
  end
  noTrendIndex = isnan(trend) ;
  trend(noTrendIndex) = interp1( find(~noTrendIndex), trend(~noTrendIndex), ...
      find(noTrendIndex), 'linear','extrap' ) ;
  
% find the change in value at each step of the flux time series

  fluxDiff = [diff( fluxTimeSeries ) ; 0] ;
  
% loop over dropout clusters

  for iCluster = 1:length( dropoutClusters )
      
%     find the actual discontinuity by looking at the cadences in each cluster and finding
%     the one which has the fastest cadence-to-cadence drop

      [maxDropValue,maxDropIndex] = min( fluxDiff(dropoutClusters{iCluster}) ) ;
      maxDropIndex = maxDropIndex + dropoutClusters{iCluster}(1) - 1 ;
      
%     search upstream to find the local maximum, then find the next upstream point which
%     drops below the local trend; this marks the start point of the contaminated
%     cadences

      localMaximum = find( fluxDiff(1:maxDropIndex) > 0 & ...
          fluxTimeSeries(1:maxDropIndex) > trend(1:maxDropIndex), ...
          1, 'last' ) ;
      if isempty( localMaximum )
          localMaximum = 1 ;
      else
          localMaximum = localMaximum + 1 ;
      end
      upstreamEdge = find( ...
          fluxTimeSeries(1:localMaximum) <= trend(1:localMaximum), 1, 'last' ) ;
      if isempty( upstreamEdge )
          upstreamEdge = 1 ;
      end
      
%     search downstream to find the local minimum, then find the next downstream point
%     which rises above the local trend; this marks the end point of the contaminated
%     cadences

      localMinimum = find( fluxDiff(maxDropIndex:end-1) > 0 & ...
          fluxTimeSeries(maxDropIndex:end-1) < trend(maxDropIndex:end-1), 1, 'first' ) ;
      localMinimum = localMinimum + maxDropIndex - 1 ;
      if isempty( localMinimum )
          localMinimum = length(trend) ;
      end
      downstreamEdge = find( ...
          fluxTimeSeries(localMinimum:end) >= trend(localMinimum:end), 1, 'first' ) ;
      downstreamEdge = downstreamEdge + localMinimum - 1 ;
      if isempty(downstreamEdge)
          downstreamEdge = length(trend) ;
      end

%     mark the region identified above as dropout cadences

      dropoutCadences(upstreamEdge:downstreamEdge) = true ;
      
  end % loop over dropout clusters
      
return