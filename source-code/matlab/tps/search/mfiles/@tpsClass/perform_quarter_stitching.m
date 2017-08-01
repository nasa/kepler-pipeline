function [tpsObject, harmonicTimeSeriesAll, fittedTrendAll] = ...
    perform_quarter_stitching( tpsObject )
%
% perform_quarter_stitching -- combine flux time series from multiple quarters into a
% single contiguous time series
%
% tpsObject = perform_quarter_stitching( tpsObject ) performs the following operations on
%    the flux time series in the tpsClass object to make them ready for multi-quarter
%    transit searches:
%    ==> Remove quarter-to-quarter offsets in the flux level
%    ==> Perform median correction and, if requested, median normalization
%    ==> Remove harmonics quarter-by-quarter
%    ==> Remove trends at the edges of each quarter
%    ==> Fill gaps between quarters, including gaps which exceed 1 quarter in duration
%        save the fitted trend from gap filling for future use
%    ==> Replace gap markers with fill markers
%    ==> Capture the harmonic time series from each target
%
% Note that if the performQuarterStitching module parameter is set to false, the
%    perform_quarter_stitching method returns the same time series as it is called with.
%
% Version date:  2010-September-27.
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

% Modification history:
%
%=========================================================================================

  tpsModuleParameters                     = tpsObject.tpsModuleParameters ;
  gapFillParametersStruct                 = tpsObject.gapFillParameters ;
  cadenceTimes                            = tpsObject.cadenceTimes ;
  harmonicsIdentificationParametersStruct = tpsObject.harmonicsIdentificationParameters ;
  tpsTargets                              = tpsObject.tpsTargets ;
  nTargets                                = length( tpsTargets ) ;
  nCadences                               = length( cadenceTimes.cadenceNumbers ) ;
  removeEclipsingBinariesOnList           = gapFillParametersStruct.removeEclipsingBinariesOnList ;
  cadenceDurationInMinutes                = gapFillParametersStruct.cadenceDurationInMinutes ;
  randStreams                             = tpsObject.randStreams ;
  maxDutyCycle                            = tpsModuleParameters.maxDutyCycle ;
  
% load the EB catalog if we are removing EBs

  if removeEclipsingBinariesOnList
      ebCatalog                      = load_eclipsing_binary_catalog() ;
      madXFactor                     = gapFillParametersStruct.madXFactor ;
      maxFitPolyOrder                = gapFillParametersStruct.maxDetrendPolyOrder ;
      indexOfAstroEvents             = 0 ;
      powerOfTwoLengthFlag           = false ;
      debugLevel                     = tpsModuleParameters.debugLevel ;  
  end
  
  harmonicTimeSeriesAll = -1 * ones( nCadences, nTargets ) ;
  fittedTrendAll = -1 * ones( nCadences, nTargets ) ;
  
% do we need to do anything?

  if tpsModuleParameters.performQuarterStitching
      
      disp( 'TPS:  Performing quarter stitching ... ' ) ;
      
%     construct the quarterStitchingParametersStruct -- we can actually just copy over the
%     tpsModuleParameters, and then add the medianNormalizationFlag, and the constructor
%     of the quarterStitchingClass will remove any excess fields

      quarterStitchingParametersStruct                         = tpsModuleParameters ;
      quarterStitchingParametersStruct.medianNormalizationFlag = true ;

%     construct the time series struct

      timeSeriesStruct = struct( 'values', [], 'uncertainties', [], 'gapIndicators', [], ...
          'fillIndices', [], 'keplerId', [], 'timeSeriesType', 'flux' ) ;
      timeSeriesStruct = repmat( timeSeriesStruct, nTargets, 1 ) ;
      
      for iTarget = 1:nTargets
          
          timeSeriesStruct(iTarget).values         = tpsTargets(iTarget).fluxValue ;
          timeSeriesStruct(iTarget).uncertainties  = tpsTargets(iTarget).uncertainty ;
          timeSeriesStruct(iTarget).fillIndices    = tpsTargets(iTarget).fillIndices ;
          timeSeriesStruct(iTarget).outlierIndices = tpsTargets(iTarget).outlierIndices ;
          timeSeriesStruct(iTarget).keplerId       = tpsTargets(iTarget).keplerId ;
          
          gapIndicators = false( size( timeSeriesStruct(iTarget).values) ) ;
          gapIndicators( tpsTargets(iTarget).gapIndices ) = true ;
          timeSeriesStruct(iTarget).gapIndicators = gapIndicators ;
          
      end
      
%     construct the instantiation struct

      quarterStitchingStruct.timeSeriesStruct = timeSeriesStruct ;
      quarterStitchingStruct.quarterStitchingParametersStruct = ...
          quarterStitchingParametersStruct ;
      quarterStitchingStruct.gapFillParametersStruct = gapFillParametersStruct ;
      quarterStitchingStruct.harmonicsIdentificationParametersStruct = ...
          harmonicsIdentificationParametersStruct ;
      quarterStitchingStruct.cadenceTimes = cadenceTimes ;
      quarterStitchingStruct.randStreams = randStreams ;
      
%     instantiate the object

      quarterStitchingObject = quarterStitchingClass( quarterStitchingStruct ) ;
      
%     identify outliers in each segment and store for continued use

      timeSeriesStruct = get_time_series_struct(quarterStitchingObject) ;

      for iTarget = 1:nTargets
          
          target = timeSeriesStruct(iTarget) ;
          
          if removeEclipsingBinariesOnList 
              ebIndex = find(ebCatalog(:,1)==target.keplerId,1) ;
              if ~isempty(ebIndex)
%                 skip id_astro_events temporarily until EB is removed
                  quarterStitchingStruct.timeSeriesStruct(iTarget).outlierIndicators = false(length(target.values),1);
                  continue;
              end
          end
          
          outlierIndicators = identify_outliers_by_quarter( target, ...
              gapFillParametersStruct, maxDutyCycle ) ;
          quarterStitchingStruct.timeSeriesStruct(iTarget).outlierIndicators = ...
              outlierIndicators ;
      end
      
%     Re-instantiate to include outlier indices

      quarterStitchingObject = quarterStitchingClass( quarterStitchingStruct ) ;
      
%     perform quarter stitching and capture the results

      quarterStitchingObject = perform_quarter_stitching( quarterStitchingObject ) ;
      timeSeriesStruct       = get_time_series_struct( quarterStitchingObject ) ;     
      
      for iTarget = 1:nTargets 
          
          target = timeSeriesStruct(iTarget) ;
          
%         remove eclipsing binaries

          if removeEclipsingBinariesOnList
              ebIndex = find(ebCatalog(:,1)==target.keplerId,1) ;
              if ~isempty(ebIndex)
                  
                  stitchedFlux = target.values ;
                  periodInDays = ebCatalog(ebIndex,3) ;
                  periodInCadences = periodInDays * 24 * 60/cadenceDurationInMinutes ;
                  fillIndicators = false(length(target.values), 1) ;
                  fillIndicators(target.fillIndices) = true ;
                  fluxUncertainties = target.uncertainties ;
                  
                  [binaryRemovedFluxValues] = ...
                      remove_eclipsing_binary(stitchedFlux, periodInCadences, ...
                      madXFactor,maxFitPolyOrder, fillIndicators) ;
                  
%                 redo the PDC gap fill

                  [fluxValuesGapsFilled, indexOfAstroEvents, unfilledIndicators, ...
                      fluxUncertainties, fittedTrend] = ...
                      fill_short_gaps(binaryRemovedFluxValues, fillIndicators, indexOfAstroEvents, ...
                      debugLevel, gapFillParametersStruct, fluxUncertainties) ;
                  
                  outlierIndicators = false( size( target.values) ) ;
                  outlierIndicators(indexOfAstroEvents) = true ;

%                 fill outliers before filling long gaps                  
                  
                  fluxValuesOutliersFilled = ...
                      fill_short_gaps(fluxValuesGapsFilled, outlierIndicators, [], ...
                      debugLevel, gapFillParametersStruct, fluxUncertainties, fittedTrend) ;
                  
                  fluxValues = fill_missing_quarters_via_reflection( ...
                      fluxValuesOutliersFilled, unfilledIndicators, [], ...
                      gapFillParametersStruct) ;
                  
%                 put back the outliers before storing 
                  
                  fluxValues(outlierIndicators) = fluxValuesGapsFilled(outlierIndicators) ;
                  outlierFillValues = fluxValuesOutliersFilled(outlierIndicators) ;
                  fluxUncertainties(unfilledIndicators) = -1 ;
                  
%                 collect results for the eclipsing binary
                  
                  tpsTargets(iTarget).fluxValue = fluxValues ;
                  tpsTargets(iTarget).uncertainty = fluxUncertainties ;
                  tpsTargets(iTarget).gapIndices = [] ;
                  tpsTargets(iTarget).fillIndices = target.fillIndices ;
                  tpsTargets(iTarget).outlierIndicators = outlierIndicators ; 
                  tpsTargets(iTarget).outlierFillValues = outlierFillValues ;
                  tpsTargets(iTarget).frontExponentialSize = target.frontExponentialSize ;
                  tpsTargets(iTarget).backExponentialSize  = target.backExponentialSize ;
                  harmonicTimeSeriesAll(:,iTarget) = target.harmonicsValues ;
                  fittedTrendAll(:,iTarget) = fittedTrend ;
                  continue;
                  
              end
          end
          
%         collect results
          
          tpsTargets(iTarget).fluxValue    = target.values ;
          tpsTargets(iTarget).uncertainty  = target.uncertainties ;
          tpsTargets(iTarget).fillIndices  = target.fillIndices ;
          tpsTargets(iTarget).outlierIndicators = target.outlierIndicators ;
          tpsTargets(iTarget).outlierFillValues = target.outlierFillValues ;
          tpsTargets(iTarget).frontExponentialSize = target.frontExponentialSize ;
          tpsTargets(iTarget).backExponentialSize  = target.backExponentialSize ;
          tpsTargets(iTarget).gapIndices   = [] ;
          harmonicTimeSeriesAll(:,iTarget) = target.harmonicsValues ;
          fittedTrendAll(:,iTarget) = target.fittedTrend ;
          
      end
      
      tpsObject.tpsTargets = tpsTargets ;
      
  else
      
      disp( 'TPS:  skipping quarter stitching ... ' ) ;
      
      % identify outliers and store for use during flux extension
	 
      for iTarget = 1:nTargets
          fluxValues = tpsTargets(iTarget).fluxValue ;
          gapIndicators = false( size(fluxValues) ) ;
          gapIndicators( tpsTargets(iTarget).gapIndices )  = true ;
          outlierIndicators = false( size(fluxValues) ) ;
          [indexOfAstroEvents, fittedTrend] = ...
              identify_astrophysical_events(fluxValues, gapIndicators, ...
              gapFillParametersStruct, false, maxDutyCycle) ;
          outlierIndicators(indexOfAstroEvents) = true ;
          tpsObject.tpsTargets(iTarget).outlierIndicators = outlierIndicators ;
          
          % generate the fill values for the outliers for flux extension
          fluxValuesOutliersFilled = fill_short_gaps(fluxValues, ...
              outlierIndicators, [], 0, gapFillParametersStruct, ...
              [], fittedTrend) ;
          tpsObject.tpsTargets(iTarget).outlierFillValues = ...
              fluxValuesOutliersFilled(outlierIndicators) ;
          fittedTrendAll(:,iTarget) = fittedTrend ;
          
      end 
            
  end % conditional on performQuarterStitching logical
  
return

% and that's it!


%--------------------------------------------------------------------------
% identify outliers by quarter for a single targets timeSeriesStruct
%--------------------------------------------------------------------------

function outlierIndicators = identify_outliers_by_quarter( timeSeriesStruct, ...
    gapFillParametersStruct, maxDutyCycle )

  outlierIndicators = false( size( timeSeriesStruct.values) ) ;
  fillIndicators = false( size( timeSeriesStruct.values ) ) ;
  fillIndicators( timeSeriesStruct.fillIndices ) = true ;
  for iSegment = 1:length( timeSeriesStruct.dataSegments )
      
      segmentStart = timeSeriesStruct.dataSegments{iSegment}(1) ;
      segmentEnd   = timeSeriesStruct.dataSegments{iSegment}(2) ;
      fluxValues   = timeSeriesStruct.values(segmentStart:segmentEnd) ;
      gapIndicators = timeSeriesStruct.gapIndicators(segmentStart:segmentEnd) ;
      gapIndicators = gapIndicators | fillIndicators(segmentStart:segmentEnd) ;

      [indexOfAstroEvents] = ...
          identify_astrophysical_events(fluxValues, gapIndicators, ...
          gapFillParametersStruct, false, maxDutyCycle) ;

      % transform indices back to full flux indices             
      indexOfAstroEvents = indexOfAstroEvents + segmentStart - 1 ;
      outlierIndicators(indexOfAstroEvents) = true ;             
  end

return
