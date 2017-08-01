function quarterStitchingObject = remove_phase_shifting_harmonics( quarterStitchingObject )
%
% remove_phase_shifting_harmonics -- identify and remove phase-shifting harmonics from the
% time series in a quarterStitchingClass object
%
% quarterStitchingObject = remove_phase_shifting_harmonics( quarterStitchingObject )
%    performs target-by-target and quarter-by-quarter removal of phase-shifting harmonics
%    from contiguous blocks of data within each time series.  The harmonic-removed time
%    series is returned to the values field of the timeSeriesStruct; the removed harmonics
%    are placed in the harmonicsValues field of the timeSeriesStruct.
%
% Version date:  2010-September-16.
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
%=========================================================================================

% extract some parameters and substructs, and define some local variables

  gapFillParametersStruct                 = quarterStitchingObject.gapFillParametersStruct ;
  removeEclipsingBinariesOnList           = gapFillParametersStruct.removeEclipsingBinariesOnList ;
  cadenceDurationInMinutes                = gapFillParametersStruct.cadenceDurationInMinutes ;
  timeSeriesStruct                        = quarterStitchingObject.timeSeriesStruct ;
  randStreams                             = quarterStitchingObject.randStreams ;
  debugLevel                              = ...
      quarterStitchingObject.quarterStitchingParametersStruct.debugLevel ;
  
  nPoorConvergenceHarmonicFitter = 0 ;
  nHarmonicsFitterCalls          = 0 ;
  displayProgressInterval        = 0.1 ; % display progress every 10% or so
  nTargets                       = length( timeSeriesStruct ) ;
  nCallsProgress                 = nTargets * displayProgressInterval ;
  progressReports                = nCallsProgress:nCallsProgress:nTargets ;
  progressReports                = unique(floor(progressReports)) ;
  
% disable the poor convergence warnings

  warning( 'off', 'MATLAB:lscov:RankDefDesignMat' ) ;
  warning( 'off', 'stats:nlinfit:IterationLimitExceeded' ) ;
  
% send a start message to the log and start the clock ticking

  if debugLevel >= 0
      disp(  [ '    Performing harmonics removal for ', num2str(nTargets), ' targets ... ' ] ) ;
  end
  startTime = clock ;
  
% load EB Catalog if needed

   if removeEclipsingBinariesOnList
       ebCatalog = load_eclipsing_binary_catalog() ;
   end

% loop over targets and over quarters, displaying messages where appropriate

  for iTarget = 1:nTargets
      
      if ismember( iTarget, progressReports ) && debugLevel >= 0
          disp( [ '       Harmonic Removal:  starting target number ', ...
              num2str(iTarget), ' out of ', num2str(nTargets), ' total ' ] ) ;
      end
      
      target = timeSeriesStruct(iTarget) ;
      randStreams.set_default( target.keplerId ) ;
      harmonicCombDetected = false(length(target.dataSegments),1) ;
      
%     reinitialize the harmonics identification parameters for each target
      
      harmonicsIdentificationParametersStruct = ...
          quarterStitchingObject.harmonicsIdentificationParametersStruct ;
            
%************************
% KSOC-4933 scale length and number parameters by the quarter length
% Need to first find the length of each quarter and the maximum length

        for iSegment = 1:length(target.dataSegments)
            quarterNCadences(iSegment) = target.dataSegments{iSegment}(2) - target.dataSegments{iSegment}(1);
        end
        % Note: we want the harmonics fitter to operate the same independently of which quarters are run. But we also want to scale the harmonic parameters by
        % the relative quarter lengths. The longest quarter is Q15 at 4778 cadences. We will hard-code 4778 as the reference. That way if a run without Q15
        % occurs, we will still use this quarter as the reference.
       %maxQuarterNCadences = max(quarterNCadences);
        maxQuarterNCadences = 4778;
%************************
  
%     use the full time series to perform a search for harmonics, which will subsequently
%     be used to seed the harmonic removal process in each quarter

      fullTimeSeriesPars = harmonicsIdentificationParametersStruct ;
      fullTimeSeriesPars.retainFrequencyCombsEnabled = false ;
      fillIndices = target.fillIndices(:) ;
      gapIndices = find(target.gapIndicators) ;
      
% %     NB:  in certain cases, the FFT of the full flux time series is not an orthogonal
% %     basis for representation of same.  This is because there can be gapped cadences or
% %     even gapped quarters, such that the actual # of data points is much smaller than the
% %     # of frequencies.  However, this doesn't actually matter since we aren't using the
% %     "removal" of harmonics over the full flux for anything other than finding strong
% %     harmonics which are then passed to the quarter-by-quarter process.  So disable the
% %     relevant warning now and turn it back on afterwards.
%       
%       warning('off','MATLAB:rankDeficientMatrix') ;
% 
%       [~,~,~,fullHarmonicRemovalObject] = identify_and_remove_harmonics( ...
%           target.values, gapFillParametersStruct, fullTimeSeriesPars, ...
%           unique([fillIndices ; gapIndices]), [] ) ;
%       
%       warning('on','MATLAB:rankDeficientMatrix') ;
    
      iterateHarmonicRemoval = true ;
      while iterateHarmonicRemoval 
        for iSegment = 1:length(target.dataSegments)
          
          segmentStart  = target.dataSegments{iSegment}(1) ;
          segmentEnd    = target.dataSegments{iSegment}(2) ;
          fluxValues    = target.values(segmentStart:segmentEnd) ;
          nCadences     = segmentEnd - segmentStart + 1 ;
          fillIndices   = target.fillIndices( target.fillIndices >= segmentStart & ...
              target.fillIndices <= segmentEnd ) ;
          fillIndices   = fillIndices - (segmentStart-1) ;
          gapIndicators = false(nCadences,1) ;
          gapIndicators(fillIndices) = true ;
          
%         remove harmonics and capture the resulting time series back into the struct
          
          if ~isfield(target, 'outlierIndicators')
              indexOfAstroEvents = [];
          else
              outlierIndicators = target.outlierIndicators(segmentStart:segmentEnd) ;
              indexOfAstroEvents = find( outlierIndicators == true ) ;
              if isempty( indexOfAstroEvents )
                  % if it exists but it is empty, then harmonic removal
                  % should not do the identification over again, so set it
                  % to -1 to turn it off internally
                  indexOfAstroEvents = -1;
              end
          end
          
          tooManySamplesInGiantTransit = false;
          nSamplesInGiantTransit = length( indexOfAstroEvents ) ;
          
          if nSamplesInGiantTransit / nCadences > 0.5
              tooManySamplesInGiantTransit = true;
          end
          
%         If we are removing EB's then we should protect all nT/2 harmonics

          protectedPeriod = [];
          if removeEclipsingBinariesOnList
              ebIndex = find(ebCatalog(:,1)==target.keplerId,1) ;
              if ~isempty(ebIndex)
                  periodInDays = ebCatalog(ebIndex,3) ;
                  protectedPeriod = periodInDays * 24 * 60/cadenceDurationInMinutes ;
              end
          end
          
          lastwarn('') ;
          if ~tooManySamplesInGiantTransit
              %************************
%               KSOC-4933 scale maxHarmonicComponents by the quarter length
                scaleFactor = quarterNCadences(iSegment) / maxQuarterNCadences;
                harmonicsIdentificationParametersStructModified = harmonicsIdentificationParametersStruct;

                harmonicsIdentificationParametersStructModified.maxHarmonicComponents = ...
                    round(harmonicsIdentificationParametersStruct.maxHarmonicComponents * scaleFactor);

                harmonicsIdentificationParametersStructModified.minHarmonicSeparationInBins = ...
                    round(harmonicsIdentificationParametersStruct.minHarmonicSeparationInBins * scaleFactor);

                % Length parameters must be ODD!
                harmonicsIdentificationParametersStructModified.medianWindowLengthForTimeSeriesSmoothing = ...
                    round(harmonicsIdentificationParametersStruct.medianWindowLengthForTimeSeriesSmoothing * scaleFactor);
                if (rem(harmonicsIdentificationParametersStructModified.medianWindowLengthForTimeSeriesSmoothing,2) ~= 1)
                    harmonicsIdentificationParametersStructModified.medianWindowLengthForTimeSeriesSmoothing= ...
                    harmonicsIdentificationParametersStructModified.medianWindowLengthForTimeSeriesSmoothing + 1;
                end

                harmonicsIdentificationParametersStructModified.medianWindowLengthForPeriodogramSmoothing = ...
                    round(harmonicsIdentificationParametersStruct.medianWindowLengthForPeriodogramSmoothing* scaleFactor);
                if (rem(harmonicsIdentificationParametersStructModified.medianWindowLengthForPeriodogramSmoothing,2) ~= 1)
                    harmonicsIdentificationParametersStructModified.medianWindowLengthForPeriodogramSmoothing= ...
                    harmonicsIdentificationParametersStructModified.medianWindowLengthForPeriodogramSmoothing + 1;
                end

                harmonicsIdentificationParametersStructModified.movingAverageWindowLength = ...
                    round(harmonicsIdentificationParametersStruct.movingAverageWindowLength* scaleFactor);
                if (rem(harmonicsIdentificationParametersStructModified.movingAverageWindowLength,2) ~= 1)
                    harmonicsIdentificationParametersStructModified.movingAverageWindowLength= ...
                    harmonicsIdentificationParametersStructModified.movingAverageWindowLength + 1;
                end
              %************************

              [harmonicsRemovedTimeSeries, harmonicTimeSeries, ~, ~, ~, ~, harmonicCombDetected(iSegment)] = ...
                  identify_and_remove_phase_shifting_harmonics( fluxValues, gapIndicators, ...
                  gapFillParametersStruct, harmonicsIdentificationParametersStructModified, ...
                  indexOfAstroEvents, [], [], fillIndices, protectedPeriod ) ;

          else
              harmonicsRemovedTimeSeries = fluxValues ;
              harmonicTimeSeries = [];
          end
          
          nHarmonicsFitterCalls = nHarmonicsFitterCalls + 1 ;
          
         if ~isempty( harmonicTimeSeries )
              target.harmonicsValues(segmentStart:segmentEnd) = harmonicTimeSeries + ...
                  median( harmonicsRemovedTimeSeries ) ;
         end
         
         target.values(segmentStart:segmentEnd) = harmonicsRemovedTimeSeries - ...
              median( harmonicsRemovedTimeSeries ) ;
          
%         check for poor convergence and record if seen
  
          [warningMsg1, warningMsg2] = lastwarn ;
          if isequal( warningMsg2, 'MATLAB:lscov:RankDefDesignMat' ) || ...
                isequal( warningMsg2, 'stats:nlinfit:IterationLimitExceeded' )
            nPoorConvergenceHarmonicFitter = nPoorConvergenceHarmonicFitter + 1 ;
          end
          
        end % loop over segments
        
%       we want to enforce consistency in the harmonic-comb removal across all quarters;
%       so if some quarters have combs and others do not, we assume that the combs are
%       spurious and need to remove them, which requires going back through harmonic
%       removal with a change in the parameters
        
        if any(harmonicCombDetected) && ~all(harmonicCombDetected)
            iterateHarmonicRemoval = true ;
            harmonicsIdentificationParametersStruct.retainFrequencyCombsEnabled = false ;
        else
            iterateHarmonicRemoval = false ;
        end
        
      end % while loop
      
      timeSeriesStruct(iTarget) = target ;
      clear fullHarmonicRemovalObject ;
      
  end % loop over targets
  
% re-enable the poor convergence warnings

  warning( 'on', 'MATLAB:lscov:RankDefDesignMat' ) ;
  warning( 'on', 'stats:nlinfit:IterationLimitExceeded' ) ;

% if the # of poor convergences is nonzero, issue a warning

  if nPoorConvergenceHarmonicFitter > 0 && debugLevel >= 0
      disp( ...
          [ '    harmonic fit poor convergence encountered ', ...
          'in ', num2str( nPoorConvergenceHarmonicFitter ), ' cases out of ', ...
          num2str( nHarmonicsFitterCalls ), ' total calls'] ) ;
  end
  
  quarterStitchingObject.timeSeriesStruct = timeSeriesStruct ;
  randStreams.restore_default() ;
    
  elapsedTime = etime( clock, startTime ) ;
  if debugLevel >= 0
      disp( [ '    ... done with harmonics removal after ', num2str(elapsedTime), ' seconds' ] ) ;
  end
  
return

% and that's it!

%
%
%

