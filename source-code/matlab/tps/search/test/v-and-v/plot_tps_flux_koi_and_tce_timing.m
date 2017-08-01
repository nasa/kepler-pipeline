function plot_tps_flux_koi_and_tce_timing( koiAndTceStruct, tceStruct, iTarget )
%
% plot_tps_flux_koi_and_tce_timing( koiAndTceStruct, iTarget ) -- plot 
%    in 5 subplots the median-corrected TPS input flux, the tps detrended flux, the single
%    event statistics time series, and the whitened flux for a selected target (2x).  On
%    the first 3 plots, superimpose the expected transit locations and depths from the KOI
%    data; on the fourth, fold at the KOI period and center on the KOI epoch; on the
%    fifth, fold at the TPS period and center on the TPS epoch.s
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
  
  keplerId   = koiAndTceStruct.keplerId( iTarget ) ;
  koiPeriodDays = koiAndTceStruct.koiPeriodDays( iTarget ) ;
  koiEpochKjd   = koiAndTceStruct.koiEpochKjd( iTarget )  ;
  tcePeriodDays = koiAndTceStruct.tcePeriodDays( iTarget ) ;
  tceEpochKjd   = koiAndTceStruct.tceEpochKjd( iTarget )  ;
  koiNumber  = koiAndTceStruct.koiNumber( iTarget ) ;
  ephemerisMatch = koiAndTceStruct.ephemerisMatch( iTarget ) ;
  unitOfWork = tceStruct.unitOfWorkKjd ;

% get the TPS input struct

  tpsTaskFile = get_tps_struct_by_kepid_from_task_dir_tree( tceStruct, keplerId, ...
      'input', false ) ;
  
% compute the timestamps

  timeStampsKjd = get_midTimestamps_filling_gaps( tpsTaskFile.cadenceTimes ) - ...
      kjd_offset_from_mjd ;
  cadenceDurationDays    = median( diff( timeStampsKjd ) ) ;
  
% determine the filled and normal cadences (we ignore the gapped ones)

  [gapIndicators, fillIndicators, normalIndicators] = get_indicators( ...
      tpsTaskFile ) ;
  [normalChunks, fillChunks] = get_normal_and_fill_chunks( ...
      tpsTaskFile.tpsTargets.gapIndices, tpsTaskFile.tpsTargets.fillIndices, ...
      length( timeStampsKjd ), false ) ;
  fluxValue = compute_median_corrected_flux_values( tpsTaskFile, normalIndicators, ...
      fillIndicators, true ) ;
  
% plot the normal flux

  subplot(3,2,1) ;
  plot_data_and_fill( timeStampsKjd, fluxValue, normalChunks, fillChunks ) ;
  hold on
  superimpose_koi_timing_and_depth( gca, unitOfWork, koiPeriodDays, koiEpochKjd, ...
      'g' ) ;
  superimpose_koi_timing_and_depth( gca, unitOfWork, tcePeriodDays, tceEpochKjd, ...
      'r' ) ;
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
 
  subplot(3,2,3) ;
  plot_data_and_fill( timeStampsKjd, tpsDiagnosticStruct(1).detrendedFluxTimeSeries, ...
      normalChunks, fillChunks ) ;
  hold on
  koiTransitTimesKjd = superimpose_koi_timing_and_depth( gca, unitOfWork, koiPeriodDays, koiEpochKjd, ...
      'g' ) ;
  tceTransitTimesKjd = superimpose_koi_timing_and_depth( gca, unitOfWork, tcePeriodDays, tceEpochKjd, ...
      'r' ) ;
  plot_data_and_fill( timeStampsKjd, tpsDiagnosticStruct(1).detrendedFluxTimeSeries, ...
      normalChunks, fillChunks ) ;
  hold off
  
  title(['Detrended Stitched Flux']) ;
  ylabel('Relative Flux') ;
  
% now for the SES time series

  allTimeStamps = timeStampsKjd ; 
  allTimeStamps(~normalIndicators) = nan ;
  [ses,~,bestPulse] = get_single_event_statistics( tpsDiagnosticStruct, ...
      allTimeStamps, tceTransitTimesKjd ) ;
  subplot(3,2,5) ;
  plot_data_and_fill( timeStampsKjd, ses, normalChunks, [] ) ;
  hold on
  transitCadences = get_transit_cadences( tceTransitTimesKjd, timeStampsKjd ) ;
  transitCadences(ismember(transitCadences,find(~normalIndicators))) = [] ;
  plot(timeStampsKjd(transitCadences),ses(transitCadences),'ro') ;
  ses = get_single_event_statistics( tpsDiagnosticStruct(bestPulse), ...
      allTimeStamps, koiTransitTimesKjd ) ;
  transitCadences = get_transit_cadences( koiTransitTimesKjd, timeStampsKjd ) ;
  transitCadences(ismember(transitCadences,find(~normalIndicators))) = [] ;
  plot(timeStampsKjd(transitCadences),ses(transitCadences),'go') ;  
  hold off
  xlabel('Cadence Time [KJD]') ;
  ylabel('SES [\sigma]') ;
  title('Single Event Statistics') ;

  
% adjust the x range of the plots to match the middle plot

  subplot(3,2,3) ;
  xLimits = get( gca, 'xlim' ) ;
  subplot(3,2,1) ;
  set( gca, 'xlim', xLimits ) ;
  subplot(3,2,5) ;
  set( gca, 'xlim', xLimits ) ;
    
% plot the whitened folded averaged flux time series  

  [~,phaseSorted,sortKey] = fold_time_series( timeStampsKjd, koiEpochKjd, ...
      koiPeriodDays ) ;
  whitenedFluxSorted = tpsDiagnosticStruct(1).whitenedFluxTimeSeries(sortKey) ;
  phaseSortedDays = phaseSorted * koiPeriodDays ;
  
  [phaseSortedDays, whitenedFluxAvg] = bin_and_average_time_series_by_cadence_time( ...
      phaseSortedDays, whitenedFluxSorted, 0, cadenceDurationDays ) ;
  whitenedFluxAvg = whitenedFluxAvg / std( whitenedFluxAvg ) ;
  
  subplot(2,2,2) ;
  plot( phaseSortedDays, whitenedFluxAvg ) ;
  title({'Whitened KOI-Folded Averaged Flux Time Series', ...
      ['KOI Epoch ',num2str(koiEpochKjd),' Period ',num2str(koiPeriodDays)]})
  xlabel('Phase [Days]') ;
  ylabel('Flux [\sigma]') ;
  
% plot the whitened folded averaged flux time series  

  [~,phaseSorted,sortKey] = fold_time_series( timeStampsKjd, tceEpochKjd, ...
      tcePeriodDays ) ;
  whitenedFluxSorted = tpsDiagnosticStruct(1).whitenedFluxTimeSeries(sortKey) ;
  phaseSortedDays = phaseSorted * tcePeriodDays ;
  
  [phaseSortedDays, whitenedFluxAvg] = bin_and_average_time_series_by_cadence_time( ...
      phaseSortedDays, whitenedFluxSorted, 0, cadenceDurationDays ) ;
  whitenedFluxAvg = whitenedFluxAvg / std( whitenedFluxAvg ) ;
  
  subplot(2,2,4) ;
  plot( phaseSortedDays, whitenedFluxAvg ) ;
  title({'Whitened TCE-Folded Averaged Flux Time Series', ...
      ['TCE Epoch ',num2str(tceEpochKjd),' Period ',num2str(tcePeriodDays), ...
      ' Match ', num2str(ephemerisMatch)]})

  xlabel('Phase [Days]') ;
  ylabel('Flux [\sigma]') ;
  
return
  
  