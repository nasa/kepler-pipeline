function generate_transit_fit_plots( transitFitObject, targetFluxTimeSeries, targetTableDataStruct, cadenceNumbers, ...
    directory, keplerId, iPlanet, defaultPeriod, impactParameterSeed, reducedParameterFitsEnabled, transitDurationMultiplier, doCleanup )
%
% generate_transit_fit_plots -- produce and save the plots which will be incorporated into
% the DV report
%
% generate_transit_fit_plots( transitFitObject, targetFluxTimeSeries, directory, keplerId,
%    iPlanet, oddEvenFlag, doCleanup ) produces a series of plots related to the transit
%    fit and saves them to the appropriate directories.  If doCleanup is set to true, the
%    figures are closed prior to returning to the caller.
%
% Version date:  2013-May-01.
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
%    2013-May-01, JL:
%       Add input 'flagShowFoldedFlux' in plot_whitened_flux_time_series
%    2013-January-04, JL:
%       Update the diagnostic plots of odd/even transits fits
%    2012-November-27, JL:
%       Added input argument 'defaultPeriod'
%    2012-October-31, JL:
%       Update the caption of plots
%    2012-September-21, JT:
%       Added new transitDurationMultiplier argument for use in median
%       detrending
%    2012-July-05, JL:
%       Implement the reduced parameter fit algorithm
%    2011-January-12, JL:
%        update the plot of unwhitened flux time series to multi-quarter.
%    2010-July-15, PT:
%        replace "Kepler ID" with "KeplerId", per HW.
%    2010-July-14, PT:
%        tweak captions per discussions with SO users.
%    2010-May-05, PT:
%        completely revamped in response to requests from Science Office and changes in
%        odd-even fitting.
%    2009-November-04, PT:
%        change figure titles to 2-line.
%    2009-August-12, PT:
%        change from target # to Kepler ID #.
%
%=========================================================================================

  nTransitsZoom = 5 ;
  nTransitTimesZoom = 6 ;

  if ~exist('doCleanup','var') || isempty(doCleanup)
      doCleanup = true ;
  end
  
  allPlotHandles = [] ;

  oddEvenFlag = transitFitObject.oddEvenFlag ;

% construct the directory name

  planetFolder = sprintf('planet-%02d', iPlanet);
  switch oddEvenFlag
      
      case 0
          if ~reducedParameterFitsEnabled
              fitFolder   = 'all-transits-fit' ;
              fitTitle    = 'All Transits Fit' ;
              fitFilename = '-all-' ;
          else
              fitFolder   = ['fit-with-fixed-impact-parameter-',  num2str(impactParameterSeed, '%1.2f')];
              fitTitle    = ['Fit With Fixed b=',                 num2str(impactParameterSeed, '%1.2f')];
              fitFilename = ['-fit-with-fixed-impact-parameter-', num2str(impactParameterSeed, '%1.2f'), '-'];
          end
      case 1 
          fitFolder  = 'odd-even-transits-fit' ;
          fitTitle    = 'Odd / Even Transits Fit' ;
          fitFilename = '-odd-even-' ;
      otherwise
          error('dv:generateTransitFitPlots:oddEvenFlagInvalid', ...
              'generate_transit_fit_plots:  oddEvenFlag must be 0 or 1') ;
          
  end
  fullDirectory = fullfile( directory, planetFolder, 'planet-search-and-model-fitting-results', fitFolder ) ;

  if ~exist(fullDirectory, 'dir')
      mkdir(fullDirectory);
  end
  
% start with the unwhitened, unzoomed flux time series

  plotHandle = plot_unwhitened_flux_time_series( transitFitObject, targetFluxTimeSeries, targetTableDataStruct, cadenceNumbers, fullDirectory, keplerId, iPlanet, defaultPeriod, fitFilename );
  allPlotHandles = [allPlotHandles ; plotHandle] ;
  
% now for the zoomed version  
  
  plotHandle = plot_unwhitened_zoomed_flux_time_series( transitFitObject, targetFluxTimeSeries, nTransitsZoom ) ;
  titleString = ['Planet ', num2str(iPlanet), ' : Unwhitened Unfolded Zoomed PDC Flux Time Series'] ;
  title( titleString ) ;
  format_graphics_for_dv_report( plotHandle, 1.0, 0.5 ) ;
  set( plotHandle, 'UserData', ...
      ['PDC Flux time series for KeplerId ', num2str(keplerId), ', Planet candidate ', ...
      num2str(iPlanet),' in the unwhitened domain, zoomed on last 5 transits in the', ...
      ' unit of work.  If # of transits is smaller than 5, all transits are shown.'] ) ;
  filename = [num2str(keplerId, '%09d'),'-',num2str(iPlanet, '%02d'), fitFilename,'unwhitened-zoomed.fig'] ;

  saveas( plotHandle, fullfile( fullDirectory, filename ) ) ;  
  allPlotHandles = [allPlotHandles ; plotHandle] ;
  
% now do the whitened plot, unzoomed
    
  plotHandle = plot_whitened_flux_time_series( transitFitObject, fullDirectory, keplerId, iPlanet, oddEvenFlag, fitFilename ) ;
  allPlotHandles = [allPlotHandles ; plotHandle] ;
  
% now do the whitened plot, zoomed and with other-phase information on it. Show folded flux time series.

  plotHandle = plot_whitened_flux_time_series( transitFitObject, fullDirectory, keplerId, iPlanet, oddEvenFlag, fitFilename, nTransitTimesZoom, true ) ;
  allPlotHandles = [allPlotHandles ; plotHandle] ;
  
% do the zoomed whitened plot again and do not show folded flux time series

  plotHandle = plot_whitened_flux_time_series( transitFitObject, fullDirectory, keplerId, iPlanet, oddEvenFlag, fitFilename, nTransitTimesZoom, false ) ;
  allPlotHandles = [allPlotHandles ; plotHandle] ;

% the unwhitened data, high-pass filtered to remove stellar variability and then folded

  plotHandle = plot_filtered_zoomed_flux_time_series( transitFitObject, fullDirectory, keplerId, iPlanet, oddEvenFlag, targetFluxTimeSeries, nTransitTimesZoom, transitDurationMultiplier ) ;
  filename  = [num2str(keplerId, '%09d'), '-', num2str(iPlanet, '%02d'), fitFilename, 'unwhitened-filtered-zoomed.fig'] ;
  
  saveas( plotHandle, fullfile( fullDirectory, filename ) ) ;
  allPlotHandles = [allPlotHandles ; plotHandle] ;
  
% Fit residuals histograms:  we'll produce a single plot of the histogram of the residuals
% which are used to constrain the fit, and a 2-subplot histogram showing all the residuals
% and the residuals which were too far away to be used to constrain the fit

  plotHandle = plot_fit_residuals_histogram( transitFitObject, true ) ;
  
  titleString = ['Planet ', num2str(iPlanet), ' ', fitTitle, ' : Fit Residuals, All Used Constraint Points'] ;
  title( titleString ) ;
  format_graphics_for_dv_report( plotHandle, 1.0, 0.5 ) ;

  set( plotHandle, 'UserData', ...
      ['Fit residuals distribution for KeplerId ', num2str(keplerId), ', Planet candidate ', ...
      num2str(iPlanet),'.  Only the valid data points used to constrain the fit are shown ', ...
      'here.  A Gaussian fit to the histogram is shown in red.' ] ) ;
  filename = [num2str(keplerId, '%09d'), '-', num2str(iPlanet, '%02d'), fitFilename, 'histo-used.fig'] ;

  saveas( plotHandle, fullfile( fullDirectory, filename ) ) ;  
  allPlotHandles = [allPlotHandles ; plotHandle] ;
  
  plotHandle = plot_fit_residuals_histogram( transitFitObject, false ) ;
  
  format_graphics_for_dv_report( plotHandle ) ;

  set( plotHandle, 'UserData', ...
      ['Fit residuals distribution for KeplerId ', num2str(keplerId), ', Planet candidate ', ...
      num2str(iPlanet),'.  Top plot:  all valid data.  Bottom plot:  valid data not used ', ...
      'to constrain fit (due to distance from a transit).  Gaussian fits to the histograms ', ...
      'are shown in red.'] ) ;
  filename = [num2str(keplerId, '%09d'),'-',num2str(iPlanet, '%02d'), fitFilename,'histo-all-and-unused.fig'] ;

  saveas( plotHandle, fullfile( fullDirectory, filename ) ) ;  
  allPlotHandles = [allPlotHandles ; plotHandle] ;
  
% Robust weights plot -- a single figure with 3 subplots including the zoom

  plotHandle = plot_fit_robust_weights( transitFitObject, nTransitTimesZoom ) ;

  format_graphics_for_dv_report( plotHandle ) ;

  set( plotHandle, 'UserData', ...
      ['Robust weights distribution for KeplerId ', num2str(keplerId), ', Planet candidate ', ...
      num2str(iPlanet),'.  Top plot:  all data points.  ', ...
      'Middle plot:  all data points, folded per the fitted period and epoch.  ', ...
      'Bottom plot:    all data points, folded and zoomed.  '] ) ;
  filename = [num2str(keplerId, '%09d'), '-', num2str(iPlanet, '%02d'), fitFilename, 'robust-weights.fig'] ;

  saveas( plotHandle, fullfile( fullDirectory, filename ) ) ;  
  allPlotHandles = [allPlotHandles ; plotHandle] ;
  
% cleanup

  if (doCleanup)
      
      for iFigure = 1:length( allPlotHandles )
          close( allPlotHandles(iFigure) ) ;
      end
      
  end
  
return

% and that's it!


