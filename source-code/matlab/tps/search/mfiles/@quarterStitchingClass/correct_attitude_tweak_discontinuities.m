function quarterStitchingObject = ...
    correct_attitude_tweak_discontinuities( quarterStitchingObject )
%
% correct_attitude_tweak_discontinuities -- correct for discontinuities
%     caused by attitude tweaks
%
%
% Modification history:
%
%    
%
%=========================================================================================
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

  parametersStruct        = quarterStitchingObject.quarterStitchingParametersStruct ;
  gapFillParameters       = quarterStitchingObject.gapFillParametersStruct ;
  timeSeriesStruct        = quarterStitchingObject.timeSeriesStruct ;
  randStreams             = quarterStitchingObject.randStreams ;
  cadenceTimes            = quarterStitchingObject.cadenceTimes ;
  debugLevel              = parametersStruct.debugLevel ;
  debugLevel              = max(debugLevel-1,0) ;
  nTargets                = length( timeSeriesStruct ) ;
  
  applyAttitudeTweakCorrection  = parametersStruct.applyAttitudeTweakCorrection ;
  attitudeTweakIndicators       = cadenceTimes.dataAnomalyFlags.attitudeTweakIndicators ;
  
  % do this only if we are correction attitude tweaks
  
  if applyAttitudeTweakCorrection

      displayProgressInterval        = 0.1 ; % display progress every 10% or so
      nCallsProgress                 = nTargets * displayProgressInterval ;
      progressReports                = nCallsProgress:nCallsProgress:nTargets ;
      progressReports                = unique(floor(progressReports)) ;

      % send a message to the log and start the clock ticking

      if debugLevel >= 0
          disp( ['    Performing tweak correction for ', num2str(nTargets), ' targets ... '] ) ;
      end
      startTime = clock ;

      % loop over targets and perform the tweak correction where necessary

      for iTarget = 1:nTargets

          target = timeSeriesStruct( iTarget ) ;
          lastwarn('') ;

          randStreams.set_default( target.keplerId ) ;

          if ismember( iTarget, progressReports ) && debugLevel >= 0
              disp( [ '       Tweak Correction:  starting target number ', ...
                  num2str(iTarget), ' out of ', num2str(nTargets), ' total ' ] ) ;
          end  
          
          % set aside fill indices since tweak cadences will get added so that
          % the gap filling code fills them in during intra-quarter gap fill
      
          %fillIndicators = false(length(target.values),1) ;
          %fillIndicators(target.fillIndices) = true ;
          
          % there may be discontinuities at outlierIndices so generate an
          % indicator for those as well
          
          outlierIndicators = false(length(target.values),1) ;
          outlierIndicators(target.outlierIndices) = true ;

          % just loop over the segments and fix the discontinuities

          for iSegment = 1:length( target.dataSegments )

              segmentStart = target.dataSegments{iSegment}(1) ;
              segmentEnd   = target.dataSegments{iSegment}(2) ;
              timeSeries = target.values(segmentStart:segmentEnd) ;
              tweakIndicators = attitudeTweakIndicators(segmentStart:segmentEnd) ;
              %fillIndicatorsSegment = fillIndicators(segmentStart:segmentEnd) ;
              outlierIndicatorsSegment = outlierIndicators(segmentStart:segmentEnd) ;

              if any(tweakIndicators) || any(outlierIndicatorsSegment)
                  timeSeries = fix_discontinuity( timeSeries, tweakIndicators, ...
                      outlierIndicatorsSegment, parametersStruct, gapFillParameters );
                  target.values(segmentStart:segmentEnd)  = timeSeries;
                  %fillIndicatorsSegment = fillIndicatorsSegment | tweakIndicators ;
                  %fillIndicators(segmentStart:segmentEnd) = fillIndicatorsSegment ;
              end

          end

          %target.fillIndices = find(fillIndicators) ;
          timeSeriesStruct(iTarget) = target ;
          
      end
      
      quarterStitchingObject.timeSeriesStruct = timeSeriesStruct ;
      
      % restore default stream - note that it is not necessary to set the 
      % randStreams in the quarterStitchingObject to randStreams since it is a
      % property of a class, it updates automatically.  The same is true for the
      % randStreams in tpsObject

      randStreams.restore_default() ;
  
      % display duration message to the log

      elapsedTime = etime( clock, startTime ) ;
      if debugLevel >= 0
          disp( ['    ... done with tweak correction after ', num2str( elapsedTime ), ' seconds.' ] ) ;
      end
      
  end

return

%--------------------------------------------------------------------------
% fix discontinuities
%--------------------------------------------------------------------------

function [fluxOut, tweakCadencesFull] = fix_discontinuity( fluxIn, tweakIndicators, ...
    outlierIndicators, parametersStruct, gapFillParameters )

  % extract needed parameters
  varianceWindowLength                = parametersStruct.varianceWindowLengthMultiplier ;
  tweakDeemphasisPeriod               = parametersStruct.deemphasizePeriodAfterTweakInCadences ;
  cadenceDurationInMinutes            = gapFillParameters.cadenceDurationInMinutes;
  giantTransitPolyFitChunkLength      = gapFillParameters.giantTransitPolyFitChunkLengthInHours;
  polyFitChunkLengthInCadences        = fix(giantTransitPolyFitChunkLength * 60/cadenceDurationInMinutes);
  madXFactor                          = gapFillParameters.madXFactor;
  maxDetrendPolyOrder                 = gapFillParameters.maxDetrendPolyOrder;
  
  nCadences = length(fluxIn) ;
  tweakCadencesFull = false(nCadences,1) ;
  
  fluxOut = fluxIn ;
  tweakIndices = find(tweakIndicators);
  outlierIndices = find(outlierIndicators);
  tweakLocations = identify_contiguous_integer_values( sort([tweakIndices;outlierIndices]) ) ;
  
  for iDisco = 1:length(tweakLocations)
      thisDis = tweakLocations{iDisco} ;
      disEnd   = thisDis(end) ;
      disStart = thisDis(1) ;
      
      % determine which cadences will be deemphasized for this tweak in the
      % same way that they are constructed during input validation
      tweakCadences = false(nCadences,1) ;
      tweakCadences(thisDis) = true ;
      if ismember(thisDis,tweakIndices)
          deemphasisParameter = set_deemphasis_parameter( find_datagap_locations( tweakCadences ), ...
              tweakDeemphasisPeriod, nCadences ) ;
          tweakCadences = deemphasisParameter ~= 1 ;
          tweakCadencesFull = tweakCadencesFull | tweakCadences ;
      end

      % if the tweak is within the deemphasis period of the start or end of
      % the time series, then dont do the tweak adjustment since the
      % tweak cadences are getting filled 
      
      if ~( tweakCadences(1) || tweakCadences(end) )
         
          % first do some local detrending outside of the tweak window - just
          % ignore any gaps that might be present since they should be linearly
          % interpolated and thats good enough for now
          tweakRegionStart = find(tweakCadences,1,'first') ;
          tweakRegionEnd = find(tweakCadences,1,'last') ;
          %leftChunkCadences = ( max( tweakRegionStart - polyFitChunkLengthInCadences, 1 ):(tweakRegionStart - 1) )';
          %rightChunkCadences = ( (tweakRegionEnd+1):min( tweakRegionEnd + polyFitChunkLengthInCadences, nCadences ) )';
          leftChunkCadences = ( max( tweakRegionStart - polyFitChunkLengthInCadences, 1 ):(disStart - 1) )';
          rightChunkCadences = ( (disEnd+1):min( tweakRegionEnd + polyFitChunkLengthInCadences, nCadences ) )';

          % fill cadences near tweak
          %tempTweakCadences = tweakCadences;
          %tempTweakCadences(disStart-1:disEnd+1) = false;
          %fluxOutTemp = fluxOut ;
          [~,~,~,~,fittedTrendLeft] = fill_short_gaps( fluxOut(leftChunkCadences),...
              false(length(leftChunkCadences),1), [], 0, gapFillParameters, [] ) ;
          [~,~,~,~,fittedTrendRight] = fill_short_gaps( fluxOut(rightChunkCadences), ...
              false(length(rightChunkCadences),1), [], 0, gapFillParameters, [] ) ;

          %fittedTrendLeft = medfilt1( fluxOut(leftChunkCadences), varianceWindowLength );
          %fittedTrendRight = medfilt1( fluxOut(rightChunkCadences), varianceWindowLength );

          residualLeft = fluxOut(leftChunkCadences) - fittedTrendLeft ;
          residualRight = fluxOut(rightChunkCadences) - fittedTrendRight ;

          % calculate the tweak shift delta 
          tweakDelta = fittedTrendLeft(end) - fittedTrendRight(1) ;

          % get an estimate of the local noise before and after the tweak
          medianLeft = medfilt1(residualLeft,varianceWindowLength);
          medianRight = medfilt1(residualRight,varianceWindowLength);
          sigmaLeft = median( medfilt1(abs(residualLeft - medianLeft))/0.675);
          sigmaRight = median( medfilt1(abs(residualRight - medianRight))/0.675);
          
          % if the delta is larger than sigma then do the adjustment
          if abs(tweakDelta) > min(sigmaLeft,sigmaRight)
              % fix post-tweak data with shift of delta
              %fluxOut(tweakRegionEnd+1:end) = fluxOut(tweakRegionEnd+1:end) + Delta ;
              fluxOut(disEnd+1:end) = fluxOut(disEnd+1:end) + tweakDelta ;
          end
          
      end
                
  end
  
  % if we adjusted for attitude tweaks then subtract off a robust linear
  % fit so the quarter ends match up reasonably well
  
  %if isTweakAdjusted
      
      
  %end
  
return 