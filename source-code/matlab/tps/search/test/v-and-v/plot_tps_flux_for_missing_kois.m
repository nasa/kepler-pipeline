function plot_tps_flux_for_missing_kois( koiStruct, tceStruct, iTarget )
%
% plot_tps_flux_for_missing_kois( koiStruct, tceStruct, iTarget ) -- plot 
%    in 4 subplots the median-corrected TPS input flux, the tps detrended flux, the single
%    event statistics time series, and the whitened flux for a selected target.  On the
%    first 3 plots, superimpose the expected transit locations and depths from the KOI
%    data; on the fourth, fold at the KOI period and center on the KOI epoch.
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

%=========================================================================================

  
  keplerId   = koiStruct.keplerId( iTarget ) ;
  periodDays = koiStruct.periodDays( iTarget ) ;
  epochKjd   = koiStruct.epochKjd( iTarget ) ;
  depthPpm   = koiStruct.depthPpm( iTarget ) ;
  koiNumber  = koiStruct.koiNumber( iTarget ) ;

% get the TPS input struct

  tpsTaskFile = get_tps_struct_by_kepid_from_task_dir_tree( tceStruct, keplerId, ...
      'input', false ) ;
  
% compute the timestamps

  timeStampsKjd = get_midTimestamps_filling_gaps( tpsTaskFile.cadenceTimes ) - ...
      kjd_offset_from_mjd  ;
  cadenceDurationDays    = median( diff( timeStampsKjd ) ) ;
  unitOfWorkKjd = tceStruct.unitOfWorkKjd ;
  
% determine the filled and normal cadences (we ignore the gapped ones)

  [gapIndicators, fillIndicators, normalIndicators] = get_indicators( ...
      tpsTaskFile ) ;
  [normalChunks, fillChunks] = get_normal_and_fill_chunks( ...
      tpsTaskFile.tpsTargets.gapIndices, tpsTaskFile.tpsTargets.fillIndices, ...
      length( timeStampsKjd ), false ) ;
  fluxValue = compute_median_corrected_flux_values( tpsTaskFile, normalIndicators, ...
      fillIndicators, true ) ;
  
% plot the normal flux

  subplot(2,2,1) ;
  plot_data_and_fill( timeStampsKjd, fluxValue, normalChunks, fillChunks ) ;
  hold on
  superimpose_koi_timing_and_depth( gca, unitOfWorkKjd, periodDays, epochKjd, ...
      'g', depthPpm ) ;
  plot_data_and_fill( timeStampsKjd, fluxValue, normalChunks, fillChunks ) ;
  hold off
  
% construct the title

  title(['Kepler ID ', num2str( keplerId ), ' KOI ', num2str(koiNumber)] ) ;
  ylabel('Relative Flux') ;
  
% now for the detrended, stitched flux time series  

  tpsDiagnosticStruct = get_tps_struct_by_kepid_from_task_dir_tree( tceStruct, ...
      keplerId, 'diagnostic', false ) ;
  fillIndicators( gapIndicators ) = true ;
  fillChunks   = identify_contiguous_integer_values( find( fillIndicators ) ) ;
 
  subplot(2,2,3) ;
  plot_data_and_fill( timeStampsKjd, tpsDiagnosticStruct(1).detrendedFluxTimeSeries, ...
      normalChunks, fillChunks ) ;
  hold on
  transitTimesKjd = superimpose_koi_timing_and_depth( gca, unitOfWorkKjd , ...
      periodDays, epochKjd, 'g', depthPpm ) ;
  plot_data_and_fill( timeStampsKjd, tpsDiagnosticStruct(1).detrendedFluxTimeSeries, ...
      normalChunks, fillChunks ) ;
  hold off
  
  title(['Kepler ID ', num2str( keplerId ), ' Detrended Stitched Flux']) ;
  ylabel('Relative Flux') ;
  xlabel('Cadence Time [JD-2454900]') ;
  
% adjust the x range of the top plot to match the bottom plot

  subplot(2,2,3) ;
  xLimits = get( gca, 'xlim' ) ;
  subplot(2,2,1) ;
  set( gca, 'xlim', xLimits ) ;
  
% plot the single event statistics
  
  allTimeStamps = timeStampsKjd ; 
  allTimeStamps(~normalIndicators) = nan ;
  [ses,bestMes,bestPulse] = get_single_event_statistics( tpsDiagnosticStruct, ...
      allTimeStamps, transitTimesKjd ) ;
  subplot(2,2,2) ;
  plot_data_and_fill( timeStampsKjd, ses, normalChunks, [] ) ;
  hold on
  transitCadences = get_transit_cadences( transitTimesKjd, timeStampsKjd ) ;
  goodTransitCadences = transitCadences .* normalIndicators(transitCadences) ;
  goodTransitCadences(goodTransitCadences == 0) = [] ;
  plot(timeStampsKjd(goodTransitCadences),ses(goodTransitCadences),'go') ;
  hold off
  
  set( gca, 'xlim', xLimits ) ;
  ylabel('Single Event Statistic [\sigma]') ;
  xlabel('Cadence Time [JD - 2454900]') ;
  title(['Median ',num2str(median(ses(goodTransitCadences))), ...
      ', STD ',num2str(mad(ses(goodTransitCadences),1)*1.4826), ...
      ', N ', num2str(length(find(goodTransitCadences))), ...
      ', MES ',num2str(bestMes)]) ;
  if bestMes >= 7.1
      disp([num2str(keplerId),'  ', num2str(periodDays),'  ', ...
          num2str(bestMes), '  ',num2str(bestPulse)]) ;
  end
  
% plot the whitened folded averaged flux time series  

  [~,phaseSorted,sortKey] = fold_time_series( timeStampsKjd, epochKjd, ...
      periodDays ) ;
  whitenedFluxSorted = tpsDiagnosticStruct(1).whitenedFluxTimeSeries(sortKey) ;
  phaseSortedDays = phaseSorted * periodDays ;
  
  [phaseSortedDays, whitenedFluxAvg] = bin_and_average_time_series_by_cadence_time( ...
      phaseSortedDays, whitenedFluxSorted, 0, cadenceDurationDays ) ;
  whitenedFluxAvg = whitenedFluxAvg / std( whitenedFluxAvg ) ;
  
  subplot(2,2,4) ;
  plot( phaseSortedDays, whitenedFluxAvg ) ;
  title('Whitened Folded Averaged Flux Time Series')
  xlabel('Phase [Days]') ;
  ylabel('Flux [\sigma]') ;
  
return





  
  
  