function peruse_dv_fits_no_ground_truth( dvResultsStruct,  ...
    rootDirectory, targetNumber, planetNumber, displayStatistics, ...
    displayFits )
%
% peruse_dv_fits_no_ground_truth( dvResultsStruct, rootDirectory, ...
%    targetNumber, planetNumber, displayStatistics, displayFits  ) -- examine the results of a DV fit
%
% peruse_dv_fits_no_ground_truth( dvResultsStruct, rootDirectory ) displays the fit 
%    results for DV targets.  The dvResultsStruct is the results struct from DV;
%    rootDirectory is the top-level directory for use in searching for figures (ie, it is
%    at the level above the dvResultsStruct.targetResultsStruct.dvFiguresRootDirectory
%    directories).  For planets, the epoch (in MJD), period (in days), transit duration
%    (in days), star radius (in Solar radii), planet radius (in Earth radii), and
%    planet/star radius ratio (in Earth radii / solar radii, ie, Earth orbiting the sun
%    has a ratio of 1) are displayed, along with the unwhitened folded flux time series
%    and the unfolded flux time series (whitened and unwhitened).  For EBs, the plots are
%    not displayed but the EB epoch, period, duration, and eclipse depth are displayed.
%    Press the space bar after each object (planet or EB) to advance to the next one.
%
% peruse_dv_fits_no_ground_truth( ... , whitenedFoldedFlag ) displays the averaged,
%    whitened, folded flux time series instead of the unwhitened, unaveraged flux time
%    series.
%
% Version date:  2010-February-11.
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
%    2010-February-11, PT:
%        add displayFits flag.
%    2010-January-13, PT:
%        bugfix on moving legend to SW corner.  Remove targetVector option and add
%        whitenedFoldedFlag option.
%    2009-December-03, PT:
%        display the MES / SES ratio.
%    2009-December-02, PT:
%        display the summary plot before moving on from one target to the next.  Display 
%        kepler magnitude for each target.  Add maxMES and maxSES to text display.
%
%=========================================================================================

  nResultTargets = length( dvResultsStruct.targetResultsStruct ) ;
  disp( [ 'Number of targets in results struct:  ', ...
      num2str( nResultTargets ) ] ) ;
  disp(' ') ;
  
  resultKeplerId = [dvResultsStruct.targetResultsStruct.keplerId] ;
  targetKics = retrieve_kics_by_kepler_id_sdf( resultKeplerId ) ;
  
  if ~exist( 'displayStatistics', 'var' ) || isempty( displayStatistics )
      displayStatistics = false ;
  end
  
  if ~exist( 'displayFits', 'var' ) || isempty( displayFits )
      displayFits = true ;
  end

  
% determine the mod/outs on which the fitting loop was terminated by the loop count limit
% but addtional TCEs were present

  if ~isempty(dvResultsStruct.alerts)
      exitOnLimitCellArray = strfind( {dvResultsStruct.alerts.message}, ...
          'Limit on number of planets is reached AND one additional threshold crossing event is reported by TPS') ;
  else
      exitOnLimitCellArray = [] ;
  end
  for iCell = 1:length(exitOnLimitCellArray)
      if isempty(exitOnLimitCellArray{iCell})
          exitOnLimitCellArray{iCell} = 0 ;
      end
  end
  exitOnLimitMsgIndex = find( cell2mat( exitOnLimitCellArray ) ) ;
  targetsAtLimit = [] ;
  for iTarget = 1:length(exitOnLimitMsgIndex)
      alertMessage = dvResultsStruct.alerts(exitOnLimitMsgIndex(iTarget)).message ;
      i1 = strfind( alertMessage, 'target=' ) + 7 ;
      i2 = strfind( alertMessage(i1:end), ',' ) + i1 - 1;
      targetsAtLimit = [targetsAtLimit ; str2num(alertMessage(i1:i2))] ;
  end
  
% loop over the targets

  if ~exist( 'targetNumber', 'var' ) || isempty( targetNumber )
      targetVector = 1:nResultTargets ;
  else
      targetVector = targetNumber ;
  end

  for iTarget = targetVector
      
      keplerId = resultKeplerId(iTarget) ;
      disp( [ 'Target # ', num2str(iTarget),', Kepler ID ', num2str(keplerId)] ) ;
      disp(['  Kepler Magnitude ', ...
          num2str( double( targetKics(iTarget).keplerMag.value ) )]) ;
      dvFiguresRootDirectory = ['target-', num2str(keplerId, '%09d')];
      figuresRootDirectory = [rootDirectory filesep dvFiguresRootDirectory] ;
      
%     how many planets were detected, and how many things were present?

      nDetectedObjects = length( dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct ) ;
      if ~ismember( iTarget, targetsAtLimit )
          disp( [ 'Number of detected objects in target:  ', num2str(nDetectedObjects) ] ) ;
      else
          disp( [ 'Number of detected objects in target:  ', ...
              num2str(nDetectedObjects),'+'] ) ;
      end
                
%     display results for the fitted objects

      if ~exist( 'planetNumber', 'var' ) || isempty( planetNumber )
          planetVector = 1:nDetectedObjects ;
      else
          planetVector = planetNumber ;
      end
      
      if ( displayFits )

          for iObject = planetVector 

              planetResultsStruct = ...
                  dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iObject) ;
              modelParameters = planetResultsStruct.allTransitsFit.modelParameters ;
              covariance = planetResultsStruct.allTransitsFit.modelParameterCovariance ;
              disp( ' ' );
              disp( [ 'Fit results for object ', num2str(iObject) ] ) ;
              disp( ' ' );
              disp( [ '  maxSES =        ', ...
                  num2str(planetResultsStruct.planetCandidate.maxSingleEventSigma) ] ) ;
              disp( [ '  maxMES =        ', ...
                  num2str(planetResultsStruct.planetCandidate.maxMultipleEventSigma) ] ) ;
              disp( [ '  pulseDur =      ', ...
                  num2str(planetResultsStruct.planetCandidate.trialTransitPulseDuration) ] ) ;
              disp( ' ' );

              if ~isempty( covariance )

                  parameterNames = {modelParameters.name} ;
                  iEpoch = find( strcmp( 'transitEpochBkjd', parameterNames ) ) ;
                  iPeriod = find( strcmp( 'orbitalPeriodDays', parameterNames ) ) ;
                  iPlanetRadius = find( strcmp( 'planetRadiusEarthRadii', parameterNames ) ) ;
                  iStarRadius = find( strcmp( 'starRadiusSolarRadii', parameterNames ) ) ;
                  iDuration = find( strcmp( 'transitDurationHours', parameterNames ) ) ;
                  iDepth = find( strcmp( 'transitDepthPpm', parameterNames ) ) ;
                  iPlanetToStarRadius = find( strcmp( 'ratioPlanetRadiusToStarRadius', parameterNames ) ) ;
                  iSemiMajorAxisToStarRadius = find( strcmp( 'ratioSemiMajorAxisToStarRadius', parameterNames ) ) ;
                  iImpactParameter = find( strcmp( 'minImpactParameter', parameterNames ) ) ;
                  
                  epoch = modelParameters(iEpoch).value ;
                  dEpoch = modelParameters(iEpoch).uncertainty ;

                  period = modelParameters(iPeriod).value ;
                  dPeriod = modelParameters(iPeriod).uncertainty ;

                  starRadius = modelParameters(iStarRadius).value ;
                  planetRadius = modelParameters(iPlanetRadius).value ;

                  dStarRadius = modelParameters(iStarRadius).uncertainty ;
                  dPlanetRadius = modelParameters(iPlanetRadius).uncertainty ; 

                  duration = modelParameters(iDuration).value / 24 ; % hours 2 days
                  dDuration = modelParameters(iDuration).uncertainty / 24 ; % hours 2 days

                  depth = modelParameters(iDepth).value ;
                  dDepth = modelParameters(iDepth).uncertainty ;
                  
                  sizeRatio = modelParameters(iPlanetToStarRadius).value ;
                  dSizeRatio = modelParameters(iPlanetToStarRadius).uncertainty ;
                  
                  semiMajorAxisRatio = modelParameters(iSemiMajorAxisToStarRadius).value ;
                  dSemiMajorAxisRatio = modelParameters(iSemiMajorAxisToStarRadius).uncertainty ;
                  
                  impactParameter = modelParameters(iImpactParameter).value ;
                  dImpactParameter = modelParameters(iImpactParameter).uncertainty ;

                  disp( [ '  Epoch =            ', num2str(epoch), ' +/- ', num2str(dEpoch) ] ) ;
                  disp( [ '  Period =           ', num2str(period), ' +/- ', num2str(dPeriod) ] ) ;
                  disp( [ '  Duration =         ', num2str(duration), ' +/- ', num2str(dDuration)  ] ) ;
                  disp( [ '  Star radius =      ', num2str(starRadius), ' +/- ', ...
                      num2str( dStarRadius )] ) ;
                  disp( [ '  Planet radius =    ', num2str(planetRadius), ' +/- ', ...
                      num2str( dPlanetRadius )] ) ;
                  disp( [ '  r/R* =             ', num2str(sizeRatio), ' +/- ', num2str(dSizeRatio) ] ) ;
                  disp( [ '  a/R* =             ', num2str(semiMajorAxisRatio), ' +/- ', num2str(dSemiMajorAxisRatio) ] ) ;
                  disp( [ '  Impact Parameter = ', num2str(impactParameter), ' +/- ', num2str(dImpactParameter) ] ) ;
                  disp( [ '  Depth PPM =        ', num2str(depth), ' +/- ', num2str(dDepth) ] ) ;
                  disp( ' ' );

                  if (displayStatistics)
                      display_statistics( planetResultsStruct ) ;
                  end

%                 display the unwhitened filtered folded zoomed light curve

                  figureDir0 = [figuresRootDirectory filesep 'planet-' num2str(iObject, '%02d') ...
                      filesep 'planet-search-and-model-fitting-results'] ;
                  figureDir = [figureDir0 filesep 'all-transits-fit'] ;
                  listing = dir(figureDir);
                  names = {listing.name};
                  
                  figureName = names{cellfun('length', strfind(names, '-unwhitened-filtered-zoomed.')) > 0} ;
                  
                  if exist( fullfile(figureDir, figureName), 'file' )
                    
                    open( fullfile( figureDir, figureName ) ) ;
                    figNumber = gcf ; axisNumber = gca ;
                    position = get(figNumber, 'position') ;
                    position = [500 800 position(3) position(4)] ;
                    set(figNumber, 'position', position) ;
                  end

%                 display the all-transits whitened folded light curve

                  figureName = names{cellfun('length', strfind(names, '-whitened.')) > 0} ;
                  
                  if exist( fullfile(figureDir, figureName), 'file' )
                    
                    open( fullfile( figureDir, figureName ) ) ;
                    figNumber = gcf ; axisNumber = gca ;
                    position = get(figNumber, 'position') ;
                    position = [500 450 position(3) position(4)] ;
                    set(figNumber, 'position', position) ;
                  end

%                 display the all-transits whitened folded zoomed light
%                 curve

                  figureName = names{cellfun('length', strfind(names, '-whitened-zoomed.')) > 0} ;
                  
                  if exist( fullfile(figureDir, figureName), 'file' )
                    
                    open( fullfile( figureDir, figureName ) ) ;
                    figNumber = gcf ; axisNumber = gca ;
                    position = get(figNumber, 'position') ;
                    position = [500 100 position(3) position(4)] ;
                    set(figNumber, 'position', position) ;
                  end
                  
              elseif ~isempty( modelParameters ) % eclipsing binary

                  disp(' Eclipsing binary, estimated parameters:' ) ;
                  parameterNames = {modelParameters.name} ;
                  iEpoch = find( strcmp( 'transitEpochMjd', parameterNames ) ) ;
                  iPeriod = find( strcmp( 'orbitalPeriodDays', parameterNames ) ) ;
                  iDuration = find( strcmp( 'transitDurationHours', parameterNames ) ) ;
                  iDepth = find( strcmp( 'transitDepthPpm', parameterNames ) ) ;
                  epoch = modelParameters(iEpoch).value ;
                  period = modelParameters(iPeriod).value ;
                  duration = modelParameters(iDuration).value / 24 ;
                  depth = modelParameters(iDepth).value ;
                  disp( [ '  Epoch =      ', num2str(epoch) ] ) ;
                  disp( [ '  Period =     ', num2str(period) ] ) ;
                  disp( [ '  Duration =   ', num2str(duration) ] ) ;
                  disp( [ '  Depth =      ', num2str(depth) ] ) ;


              else % fit failed

                  disp('  Fit failed ') ;

              end % empty model parameters condition

              disp(' ') ;
              pause ;
              close all

          end % loop over detected objects
      
      end % displayFits condition
      
%     display the summary plot

      figureDir = [figuresRootDirectory filesep 'summary-plots'];
      listing = dir(figureDir);
      names = {listing.name};
      figureNames = names(cellfun('length', strfind(names, 'dv-fit')) > 0) ;
      
      xoffset = 0;
      
      for iFigure = 1:length(figureNames)
          
          summaryPlotName = figureNames{iFigure};
          
          if exist( fullfile( figureDir, summaryPlotName ), 'file' )
              
              open( fullfile( figureDir, summaryPlotName ) ) ;
              figNumber = gcf ; axisNumber = gca ;
              position = get(figNumber, 'position') ;
              position = [10+xoffset 300 position(3) position(4)] ;
              set(figNumber, 'position', position) ;
              xoffset = xoffset + 950;
          end
      end
      
      disp(' ');
      pause;
      close all
          
  end % loop over targets
  
return 

%=========================================================================================

% % subfunction which manages the averaging of the flux time series
% 
% function replace_flux_with_averaged( axisNumber )
% 
% % set the averaging to 30 minutes
% 
%   averagingBinWidth = 30 * get_unit_conversion('min2day') ;
%   
% % get the child objects of the axis
% 
%   axisChildren = get( axisNumber, 'children' ) ;
%   
% % loop over children, get their x and y data, if any, bin and average it, and put it back
% 
%   for iChild = axisChildren(:)'
%       
%       childProperties = get(iChild) ;
%       if isfield(childProperties,'XData')
%           
%           xData = childProperties.XData ;
%           yData = childProperties.YData ;
%           [xData,yData] = bin_and_average_time_series( xData, yData, averagingBinWidth ) ;
%           set( iChild, 'xdata', xData ) ;
%           set( iChild, 'ydata', yData ) ;
%           
%       end
%       
%   end
%   
% % change the title
% 
%   titleObject = get( axisNumber, 'title' ) ;
%   titleString = get( titleObject, 'string' ) ;
%   titleString{2} = 'Whitened Folded Averaged Flux Time Series' ;
%   set( titleObject, 'string', titleString ) ;
%   
% return

%=========================================================================================

% % subfunction to perform the averaging
% 
% function [xDataOut, yDataOut] = bin_and_average_time_series( xData, yData, averageBinWidth )
% 
% % compute the bin edge values -- start by computing time in days prior to and after the
% % cadenceTimes0 value (which we want to have as a bin center)
% 
%   earliestTime = -min(xData) ; 
%   latestTime   = max(xData) ;
%   
%   earliestEdgeInCadences = ceil(earliestTime / averageBinWidth) + 0.5 ;
%   latestEdgeInCadences   = ceil(latestTime / averageBinWidth) + 0.5 ;
%   edgeRangeInCadences = -earliestEdgeInCadences:latestEdgeInCadences ;
%   edgeRangeInMjd = edgeRangeInCadences * averageBinWidth ;
%   binCenterInMjd = edgeRangeInMjd + averageBinWidth / 2 ;
%   binCenterInMjd(end) = [] ;
%   nBins = length(binCenterInMjd) ;
%   
% % perform the binning of cadence times
% 
%   [nCadencesPerBin, binIndex] = histc( xData, edgeRangeInMjd ) ;
% 
% % bin and average the time series
% 
%   yDataOut = zeros(nBins,1) ;
%   for iBin = 1:nBins
%       if (nCadencesPerBin(iBin)>0)
%           yDataOut(iBin) = sum(yData(binIndex==iBin)) ...
%               / nCadencesPerBin(iBin) ;
%       end
%           
%   end
%   yDataOut(nCadencesPerBin(1:nBins)==0) = [] ;
%   
% % construct the returned timestamps
% 
%   xDataOut = binCenterInMjd(nCadencesPerBin>0) ;
%   
% return

%=========================================================================================

function display_statistics( planetResultsStruct )

  statistic = planetResultsStruct.centroidResults.prfMotionResults.motionDetectionStatistic ;
  value = statistic.value ;
  significance = statistic.significance ;

  display_value_and_significance('PRF centroid test:           ', value, significance ) ;

  statistic = planetResultsStruct.centroidResults.fluxWeightedMotionResults.motionDetectionStatistic ;
  value = statistic.value ;
  significance = statistic.significance ;

  display_value_and_significance('Flux weighted centroid test: ', value, significance ) ;

  statistic = planetResultsStruct.binaryDiscriminationResults.oddEvenTransitDepthComparisonStatistic ;
  value = statistic.value ;
  significance = statistic.significance ;

  display_value_and_significance('Depth test:                  ', value, significance ) ;

  statistic = planetResultsStruct.binaryDiscriminationResults.oddEvenTransitEpochComparisonStatistic ;
  value = statistic.value ;
  significance = statistic.significance ;

  display_value_and_significance('Epoch test:                  ', value, significance ) ;

  statistic = planetResultsStruct.binaryDiscriminationResults.shorterPeriodComparisonStatistic ;
  value = statistic.value ;
  significance = statistic.significance ;

  display_value_and_significance('Shorter period test:         ', value, significance ) ;

  statistic = planetResultsStruct.binaryDiscriminationResults.longerPeriodComparisonStatistic ;
  value = statistic.value ;
  significance = statistic.significance ;

  display_value_and_significance('Longer period test:          ', value, significance ) ;

return

%=========================================================================================

% subfunction which performs display of the value and significance of a test

function display_value_and_significance( nameString, value, significance )

  disp( [ '  ', nameString, 'Value = ', num2str(value), ', Significance = ', ...
      num2str(significance) ] ) ;
  
return