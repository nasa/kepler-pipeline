function plot_folded_tps_flux( tceStruct, keplerIdList, pulseDurations, ...
    nPulseDurationsZoom, nTransitsPlotMax, filterType, iTarget )
%
% plot_folded_tps_flux( tceStruct, keplerIdList, pulseDurations, nPulseDurationZoom, 
%    nTransitsPlotMax, filterType, iTarget ) -- look up the TPS quarter-stitched flux
%    corresponding to keplerIdList( iTarget ), high-pass filter it, fold it at the period
%    of the max MES which is specified in the tceStruct, perform binning and averaging,
%    and plot over a range of nPulseDurationsZoom (ie, nPulseDurationsZoom == 3 plots a
%    total of 3 pulse duration times centered on the nominal epoch of the light curve).
%    The parameter nTransitsPlotMax tells the maximum number of transits which should have
%    their positions plotted on the unfolded curve (ie, if nTransitsPlotMax == 10 and
%    there are 100 transits, don't plot them).  The parameter filterType indicates whether
%    to use median filtering ('medfilt') or whitening filtering ('whiten'); the latter is
%    much slower than the former but sometimes more informative.
%
% Note that, by the use of the iTarget argument at the end, this function is optimized for
%    use with the plotter_loop GUI.
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

% here we cheat and use persistent variables to reduce the number of very slow calls we
% need to make to read the TPS input struct

  persistent topDir midTimestampsKjd taskFile

% get the persistent variables if necessary

  pointer = find( tceStruct.keplerId == keplerIdList( iTarget ) ) ;
      
  taskDir = ['tps-matlab',tceStruct.taskfile{pointer}] ;

  if isempty(topDir) || ~isequal( topDir, tceStruct.topDir )
      topDir = tceStruct.topDir ;
      taskFile = read_tps_file( topDir, taskDir, 0, false ) ;
      midTimestamps = taskFile.cadenceTimes.midTimestamps ;
      gapIndicators = taskFile.cadenceTimes.gapIndicators ;
      midTimestamps(gapIndicators) = interp1( find(~gapIndicators), ...
          midTimestamps( ~gapIndicators ), ...
          find(gapIndicators), 'linear', 'extrap' ) ;
      midTimestampsKjd = midTimestamps - kjd_offset_from_mjd ;
  end

  cadenceDurationDays    = median( diff( midTimestampsKjd ) ) ;
  cadenceDurationMinutes = cadenceDurationDays * get_unit_conversion( 'day2min' ) ;
  taskFile.gapFillParameters.cadenceDurationInMinutes = cadenceDurationMinutes ;
  maxTimeKjd = max(midTimestampsKjd) ;
  
% extract the appropriate light curve
  
  load( fullfile( topDir, taskDir, 'tps-diagnostic-struct.mat' ) ) ;  
  fluxTimeSeries = tpsDiagnosticStruct(1).detrendedFluxTimeSeries ;
  
% get the pulse duration and convert to days

  if ~exist( 'pulseDurations', 'var' ) || isempty( pulseDurations )
      pulseDurationHours = tceStruct.maxMesPulseDurationHours( pointer ) ;
  else
      pulseNumber        = tceStruct.maxMesPulseNumber( pointer ) ;
      pulseDurationHours = pulseDurations( pulseNumber ) ;
  end
  pulseDurationDays =  pulseDurationHours * get_unit_conversion('hour2day') ;
  
% get the epoch and period

  epochKjd   = tceStruct.epochKjd( pointer ) ;
  periodDays = tceStruct.periodDays( pointer ) ;
  
% generate the whitener or the median filter and filter the time series

  if strcmpi( filterType, 'whiten' ) 
      if isfield(tpsDiagnosticStruct,'whitenedFluxTimeSeries')
          fluxTimeSeriesFiltered = tpsDiagnosticStruct(1).whitenedFluxTimeSeries ;
      else
          whiteningFilterModel = generate_whitening_filter_model( fluxTimeSeries, ...
              false(size(fluxTimeSeries)), pulseDurationHours, ...
              taskFile.gapFillParameters, taskFile.tpsModuleParameters ) ;
          whiteningFilterObject = whiteningFilterClass( whiteningFilterModel ) ;
          [~,fluxTimeSeriesFiltered] = ...
              whiten_time_series( whiteningFilterObject, fluxTimeSeries ) ;
      end
      plotUnit = '\sigma' ;
  else
      if periodDays > 0
          filterTimeDays = sqrt( pulseDurationDays * periodDays ) ;
      else
          filterTimeDays = sqrt( pulseDurationDays * range( midTimestampsKjd ) ) ;
      end
      filterTimeCadences = round( filterTimeDays  / cadenceDurationDays ) ;
      fluxTimeSeriesFiltered = fluxTimeSeries - medfilt1( fluxTimeSeries, ...
           filterTimeCadences, min( length(filterTimeCadences), 30000 ) ) ;
       fluxTimeSeriesFiltered = fluxTimeSeriesFiltered * 1e6 ;
       plotUnit = 'PPM' ;
  end 
       
% determine the number and timing of the anticipated transits

  if periodDays > 0
      transitTimesKjd = epochKjd:periodDays:maxTimeKjd ;
  else
      transitTimesKjd = epochKjd ;
  end
  nTransits       = length( transitTimesKjd ) ;
    
  subplot(2,1,1) ; 
  plot(midTimestampsKjd, fluxTimeSeriesFiltered) ;
  
% if required to do so, plot the transit times -- note that the particluar pattern of hold
% on/off and the repetition of the original plot command is a brute-force way to make the
% data sit on top of the transit indicator lines.  Unfortunately, this means that the plot
% command is executed twice, since I need to do something to get the ylim value!

  if nTransits <= nTransitsPlotMax
      ylim = get( gca, 'ylim' ) ;
      for iTransit = 1:nTransits
          plot( transitTimesKjd(iTransit) * [1 ; 1], ylim(:), 'g' ) ;
          hold on
      end
  end
  plot(midTimestampsKjd, fluxTimeSeriesFiltered) ;
  title( [ 'Kepler ID ', num2str( tceStruct.keplerId( pointer )), ':  ', ...
      'Epoch = KJD ', num2str(epochKjd), ', Period = ', num2str(periodDays), ...
      ' Days '] ) ;
  xlabel( 'Cadence Time [KJD]' ) ;
  ylabel( ['Relative Flux [',plotUnit,']' ] ) ;
  hold off

% fold the time series
  
  if periodDays > 0
      foldPeriod = periodDays ;
  else
      foldPeriod = range( midTimestampsKjd ) ;
  end
  [phase, phaseSorted, sortKey] = fold_time_series( midTimestampsKjd, epochKjd, ...
      foldPeriod ) ;
  fluxTimeSeriesSorted = fluxTimeSeriesFiltered( sortKey ) ;
  phaseSortedDays = phaseSorted * foldPeriod ;
 
% bin and average the time series into bins, setting the width based on the detection
% intensity

  maxMes = tceStruct.maxMes(pointer) ;
  threshold = ceil( maxMes/10 ) ;
  switch threshold
      case {1,2}
          nCadences = 4 ;
      case {3,4}
          nCadences = 2 ;
      otherwise
          nCadences = 1 ;
  end

  [phaseSortedDays, fluxTimeSeriesAvg] = bin_and_average_time_series_by_cadence_time( ...
      phaseSortedDays, fluxTimeSeriesSorted, 0, cadenceDurationDays * nCadences ) ;
  
% convert to units of the RMS of the flux time series
  
  fluxTimeSeriesAvg = fluxTimeSeriesAvg / std(fluxTimeSeriesAvg) ;
  
% plot it

  subplot(2,1,2) ;
  plot( phaseSortedDays * get_unit_conversion( 'day2hour') , ...
      fluxTimeSeriesAvg,'.-' ) ;
  
% window it

  if exist( 'nPulseDurationsZoom','var' ) && ~isempty( nPulseDurationsZoom )
      windowHalfSizeDays = nPulseDurationsZoom * pulseDurationDays * 0.5 ;
      windowHalfSizeHours = windowHalfSizeDays * get_unit_conversion( 'day2hour' ) ;
      set( gca, 'xlim', windowHalfSizeHours * [-1 1] ) ;
  end
  xlabel('Phase [Hours]') ;
  ylabel( ['Relative Flux [',plotUnit,']' ] ) ;
  title( [ 'Kepler ID ', num2str( tceStruct.keplerId( pointer )), ':  ', ...
      'Pulse = ', num2str(pulseDurationHours), ' hours, MES = ', ...
      num2str( maxMes ),' \sigma'] ) ;

return

