function quarterStitchingObject = fill_gaps_in_time_series( quarterStitchingObject )
%
% fill_gaps_in_time_series -- fill gaps in multi-quarter time series
%
% quarterStitchingObject = fill_gaps_in_time_series( quarterStitchingObject ) performs gap
%    filling in the time series of a quarterStitchingClass object.  All gaps are
%    transformed to fills (ie, gapIndicators are set to false and fillIndices are
%    updated), but the gapSegments vector is left unchanged in case there is later a need
%    to identify the areas which have been gap-filled by this method.
%
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

% unpack stuff

  parametersStruct        = quarterStitchingObject.quarterStitchingParametersStruct ;
  gapFillParametersStruct = quarterStitchingObject.gapFillParametersStruct ;
  timeSeriesStruct        = quarterStitchingObject.timeSeriesStruct ;
  randStreams             = quarterStitchingObject.randStreams ;
  debugLevel              = parametersStruct.debugLevel ;
  debugLevel              = max(debugLevel-1,0) ;
  nTargets                = length( timeSeriesStruct ) ;

  displayProgressInterval        = 0.1 ; % display progress every 10% or so
  nCallsProgress                 = nTargets * displayProgressInterval ;
  progressReports                = nCallsProgress:nCallsProgress:nTargets ;
  progressReports                = unique(floor(progressReports)) ;

% send a message to the log and start the clock ticking

  if debugLevel >= 0
      disp( ['    Performing gap-filling for ', num2str(nTargets), ' targets ... '] ) ;
  end
  startTime = clock ;
  
% loop over targets performing gap fills

  for iTarget = 1:nTargets
      
      target = timeSeriesStruct( iTarget ) ;
      lastwarn('') ;
      
      randStreams.set_default( target.keplerId ) ;
      
      if ismember( iTarget, progressReports ) && debugLevel >= 0
          disp( [ '       Gap filling:  starting target number ', ...
              num2str(iTarget), ' out of ', num2str(nTargets), ' total ' ] ) ;
      end
      
      target.fittedTrend = zeros( size(target.values) ) ;
      
%     force TPS to redo the intra-quarter PDC gap fills

      target = fill_intra_quarter_gaps( target, gapFillParametersStruct, debugLevel ) ;

%     Now fill all remaining long gaps including missing quarters, unfilled
%     intra-quarter gaps, and also all the inter-quarter gaps.  Note that
%     this will cover the targets that were on mod3 when it failed.  Just
%     leave these uncertainties at zero.  Note also that gaps less than the
%     long gap length will all be inter-quarter gaps at this point and will
%     be re-filled with the inter quarter gap filler

      target = fill_long_quarter_gaps( target, gapFillParametersStruct ) ;
      
%     fill inter-quarter gaps using the same auto-regressive algorithm from
%     both the left and right when possible, tapering the results together
   
      target = fill_inter_quarter_gaps( target, gapFillParametersStruct, debugLevel ) ;  
      
%     update the time series

      medianValue = median( target.values ) ;
      target.values = target.values - medianValue ;
      target.outlierFillValues = target.outlierFillValues - medianValue ;
      target.fittedTrend = target.fittedTrend - medianValue ;
      timeSeriesStruct( iTarget ) = target ;
      
  end
  
  quarterStitchingObject.timeSeriesStruct = timeSeriesStruct ;
  
% restore default stream - note that it is not necessary to set the 
% randStreams in the quarterStitchingObject to randStreams since it is a
% property of a class, it updates automatically.  The same is true for the
% randStreams in tpsObject

  randStreams.restore_default() ;
    
% display the completion message

  if debugLevel >= 0
      disp( [ '    ... done with gap filling after ', num2str( etime( clock, startTime ) ), ...
          ' seconds' ] ) ;
  end
  
return

% and that's it!

%--------------------------------------------------------------------------
% Fill intra-quarter gaps short enough for AR filling
%--------------------------------------------------------------------------

function timeSeriesStruct = fill_intra_quarter_gaps( timeSeriesStruct, ...
    gapFillParametersStruct, debugLevel )

  timeSeriesStruct.outlierFillValues = [] ;
    
  for iSegment = 1:length( timeSeriesStruct.dataSegments )
          
      segmentStart = timeSeriesStruct.dataSegments{iSegment}(1) ;
      segmentEnd   = timeSeriesStruct.dataSegments{iSegment}(2) ;

      timeSeriesWithGaps = timeSeriesStruct.values(segmentStart:segmentEnd) ;
      uncertaintiesWithGaps = timeSeriesStruct.uncertainties(segmentStart:segmentEnd) ;
      gapIndicators = timeSeriesStruct.gapIndicators(segmentStart:segmentEnd) ;
      fillIndicators = false(length(timeSeriesStruct.values),1) ;
      fillIndicators(timeSeriesStruct.fillIndices) = true ;
      fillIndicators = fillIndicators(segmentStart:segmentEnd) ;

      % always identify outliers here since previous steps in the quarter
      % stitching process can significantly alter the cadences identified
      
      indexOfAstroEvents = 0 ;
      
      % if there are no gaps then generate the fitted trend and look for
      % outliers for future use
      
      if ( ~any(fillIndicators) )
          
          timeSeriesWithGapsFilled = timeSeriesWithGaps ;
          uncertaintiesWithGapsFilled = uncertaintiesWithGaps ;
          longDataGapIndicators = gapIndicators ;
          
          % still need the fitted trend
          
          [~, masterIndexOfAstroEvents, ~, ~, fittedTrend] = fill_short_gaps( timeSeriesWithGaps, ...
              fillIndicators, indexOfAstroEvents, debugLevel, ...
              gapFillParametersStruct, uncertaintiesWithGaps ) ;

      else
          
          [timeSeriesWithGapsFilled, masterIndexOfAstroEvents, ...
              longDataGapIndicators, uncertaintiesWithGapsFilled, fittedTrend] = ...
              fill_short_gaps( timeSeriesWithGaps, fillIndicators, ...
              indexOfAstroEvents, debugLevel, gapFillParametersStruct, ...
              uncertaintiesWithGaps ) ;
          
      end
      
      % record outlier indices in the indicator
      
      outlierIndicators = false(length(timeSeriesWithGaps),1) ;
      outlierIndicators(masterIndexOfAstroEvents) = true ;
      
      % now get the fill values for the outlier indices so they can be used
      % during the long gap fill and the flux extension to save from
      % calling fill_short_gaps and doing the detrending all over again

      timeSeriesWithOutliersFilled = fill_short_gaps( timeSeriesWithGapsFilled, ...
          outlierIndicators, [], debugLevel, gapFillParametersStruct,  ...
          uncertaintiesWithGapsFilled, fittedTrend ) ;
  
      outlierFillValues = timeSeriesWithOutliersFilled(outlierIndicators) ;
      outlierFillValues = outlierFillValues(:);
      gapIndicators = gapIndicators | longDataGapIndicators ;
      
      % record values
      
      timeSeriesStruct.outlierFillValues = [timeSeriesStruct.outlierFillValues; outlierFillValues] ;
      timeSeriesStruct.values(segmentStart:segmentEnd) = timeSeriesWithGapsFilled ;
      timeSeriesStruct.outlierIndicators(segmentStart:segmentEnd) = outlierIndicators ;
      timeSeriesStruct.uncertainties(segmentStart:segmentEnd) = uncertaintiesWithGapsFilled ;
      timeSeriesStruct.gapIndicators(segmentStart:segmentEnd) = gapIndicators ;
      timeSeriesStruct.fittedTrend(segmentStart:segmentEnd) = fittedTrend ;
      
      % if we didnt fill one of the intra-quarter gaps then toss it out of
      % the fill indices since it should be in the gapIndicators now
      
      timeSeriesStruct.fillIndices = setdiff(timeSeriesStruct.fillIndices,find(timeSeriesStruct.gapIndicators)) ;

  end
  
  return
  
  
%--------------------------------------------------------------------------
% Fill long and full quarter gaps by reflection
%--------------------------------------------------------------------------

function timeSeriesStruct = fill_long_quarter_gaps( timeSeriesStruct, gapFillParametersStruct )   

  maxArOrderLimit = gapFillParametersStruct.maxArOrderLimit; %% max AR model order limit set for choose_fpe_model_order function.
  maxCorrelationWindowXFactor = gapFillParametersStruct.maxCorrelationWindowXFactor;
  maxCorrelationWindowLimit = maxCorrelationWindowXFactor*maxArOrderLimit;
  
  timeSeriesWithGaps = timeSeriesStruct.values ;
  outlierIndicators = timeSeriesStruct.outlierIndicators ;
  gapIndicators = timeSeriesStruct.gapIndicators ;
  
  % replace the outliers with their fill values so outliers are supressed
  % from entering the long gaps
  
  timeSeriesWithGaps(outlierIndicators) = timeSeriesStruct.outlierFillValues ;
  
  timeSeriesWithGapsFilled = fill_missing_quarters_via_reflection( ...
      timeSeriesWithGaps, gapIndicators, [], gapFillParametersStruct ) ;
  
  % put back the original outlier values before storing
  
  timeSeriesWithGapsFilled(outlierIndicators) = timeSeriesStruct.values(outlierIndicators) ;
  
  timeSeriesStruct.values = timeSeriesWithGapsFilled ;

  % move the long gaps over to fills, this should just leave the
  % inter-quarter gaps at this point

  gapIndices = find( timeSeriesStruct.gapIndicators ) ;
  gapChunks = identify_contiguous_integer_values( gapIndices ) ;
  chunkLengths = cellfun( @length, gapChunks ) ;
  longGapIndices = vertcat( gapChunks{chunkLengths > maxCorrelationWindowLimit | chunkLengths == length(gapIndices)} ) ;
  timeSeriesStruct.fillIndices = union( timeSeriesStruct.fillIndices, longGapIndices ) ;
  
  % get the fittedTrend for these long gaps
  
  if ~isempty( longGapIndices )
      maxDetrendPolyOrder                 = gapFillParametersStruct.maxDetrendPolyOrder;
      madXFactor                          = gapFillParametersStruct.madXFactor;
      cadenceDurationInMinutes            = gapFillParametersStruct.cadenceDurationInMinutes;
      giantTransitPolyFitChunkLength      = gapFillParametersStruct.giantTransitPolyFitChunkLengthInHours;
      polyFitChunkLengthInCadences        = fix(giantTransitPolyFitChunkLength * 60/cadenceDurationInMinutes);

      gapChunks = identify_contiguous_integer_values( longGapIndices ) ;
      numChunks = length( gapChunks ) ;
      
      for i=1:numChunks
          chunkCadences = gapChunks{i} ;
          timeSeriesChunk = timeSeriesWithGapsFilled( chunkCadences ) ;
          fittedTrend = piecewise_robustfit_timeseries(timeSeriesChunk, polyFitChunkLengthInCadences, ...
              madXFactor, maxDetrendPolyOrder, false(size(timeSeriesChunk))); 
          timeSeriesStruct.fittedTrend(chunkCadences) = fittedTrend ;
      end
  end
      
  % set uncertainties for cadences filled by long gap fill to -1

  timeSeriesStruct.uncertainties(longGapIndices) = -1 ;
      
  % update gapIndicators

  gapIndices = setdiff( gapIndices, longGapIndices ) ;
  gapIndicators = false( length(timeSeriesStruct.values),1 ) ;
  gapIndicators(gapIndices) = true ;
  timeSeriesStruct.gapIndicators = gapIndicators ;

return
  
  
%--------------------------------------------------------------------------
% Fill inter-quarter gaps short enough for AR filling
%--------------------------------------------------------------------------

function timeSeriesStruct = fill_inter_quarter_gaps( timeSeriesStruct, ...
    gapFillParametersStruct, debugLevel ) 

  gapIndices = find( timeSeriesStruct.gapIndicators ) ;
  gapSegments = timeSeriesStruct.gapSegments ;
  dataSegments = timeSeriesStruct.dataSegments ;

  for iSegment = 1:length( gapSegments )
      
      segmentIndices = (gapSegments{iSegment}(1):gapSegments{iSegment}(2))' ;
      gapLength = length(segmentIndices) ;
      
      % check if this gapSegment is included in my gapIndices
      if isequal( sum(ismember(segmentIndices,gapIndices)),length(segmentIndices) )
          % this gap needs to be filled from left and right so determine
          % which data segments to use - we are guaranteed to have real
          % data on both sides
          dataSegmentEnds = vertcat( dataSegments{:} ) ;
          dataSegmentEnds = dataSegmentEnds(2:2:end) ;
          leftDataSegment = find( segmentIndices(1) > dataSegmentEnds, 1, 'last' ) ;
          dataIndicesLeft = dataSegments{leftDataSegment}(1):dataSegments{leftDataSegment}(2) ;
          dataIndicesLeft = [dataIndicesLeft(:); segmentIndices(:)] ;
          dataIndicesRight = dataSegments{leftDataSegment+1}(1):dataSegments{leftDataSegment+1}(2) ;
          dataIndicesRight = [segmentIndices(:); dataIndicesRight(:)] ;
          
          % gather the data needed for the left and right
          % time series
          timeSeriesWithGapsLeft = timeSeriesStruct.values(dataIndicesLeft) ;
          timeSeriesWithGapsRight = timeSeriesStruct.values(dataIndicesRight) ;
          % gapIndicators
          gapIndicatorsLeft = false( length(timeSeriesWithGapsLeft), 1 ) ;
          gapIndicatorsRight = false( length(timeSeriesWithGapsRight), 1 ) ;
          gapIndicatorsLeft((end-gapLength+1):end) = true ;
          gapIndicatorsRight(1:gapLength) = true ;
          % outlierIndicators
          outlierIndicatorsLeft = timeSeriesStruct.outlierIndicators(dataIndicesLeft) ;
          outlierIndicatorsRight = timeSeriesStruct.outlierIndicators(dataIndicesRight) ;
          % uncertainties
          uncertaintiesWithGapsLeft = timeSeriesStruct.uncertainties(dataIndicesLeft) ;
          uncertaintiesWithGapsRight = timeSeriesStruct.uncertainties(dataIndicesRight) ;
          
          indexOfAstroEventsLeft = find( outlierIndicatorsLeft == true ) ;
          indexOfAstroEventsRight = find( outlierIndicatorsRight == true ) ;
      
          timeSeriesWithGapsFilledLeft = ...
              fill_short_gaps( timeSeriesWithGapsLeft, gapIndicatorsLeft, ...
              indexOfAstroEventsLeft, debugLevel, gapFillParametersStruct, ...
              uncertaintiesWithGapsLeft );
          
          timeSeriesWithGapsFilledRight = ...
              fill_short_gaps( timeSeriesWithGapsRight, gapIndicatorsRight, ...
              indexOfAstroEventsRight, debugLevel, gapFillParametersStruct, ...
              uncertaintiesWithGapsRight );
          
          taperWeightsRight = linspace(0,1,gapLength) ;
          taperWeightsRight = taperWeightsRight(:) ;
          taperWeightsLeft = flipud(taperWeightsRight) ;
          
          % taper left and right together and update the gap with filled
          % values
          gapFillValues = timeSeriesWithGapsFilledLeft((end-gapLength+1):end).*taperWeightsLeft ...
              + timeSeriesWithGapsFilledRight(1:gapLength).*taperWeightsRight ;
          
          timeSeriesStruct.values(segmentIndices) = gapFillValues ;
          timeSeriesStruct.uncertainties(segmentIndices) = -1 ;
          timeSeriesStruct.gapIndicators(segmentIndices) = false ;
          timeSeriesStruct.fillIndices = union( timeSeriesStruct.fillIndices, segmentIndices ) ;
          
          % get the fittedTrend
          maxDetrendPolyOrder                 = gapFillParametersStruct.maxDetrendPolyOrder;
          madXFactor                          = gapFillParametersStruct.madXFactor;
          cadenceDurationInMinutes            = gapFillParametersStruct.cadenceDurationInMinutes;
          giantTransitPolyFitChunkLength      = gapFillParametersStruct.giantTransitPolyFitChunkLengthInHours;
          polyFitChunkLengthInCadences        = fix(giantTransitPolyFitChunkLength * 60/cadenceDurationInMinutes);

          fittedTrend = piecewise_robustfit_timeseries(gapFillValues, polyFitChunkLengthInCadences, ...
              madXFactor, maxDetrendPolyOrder, false(size(gapFillValues)) ); 
          timeSeriesStruct.fittedTrend(segmentIndices) = fittedTrend ;
      end       
  end

return

%
%
%