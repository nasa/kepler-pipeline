function [timeSeriesStructOut, segmentInformationStruct] = perform_quarter_stitching( ...
    dvDataObject, timeSeriesStructIn, medianNormalizationFlag )
%
% perform_quarter_stitching -- apply multi-quarter time series conditioning to a DV time
% series
%
% timeSeriesStructOut = perform_quarter_stitching( dvDataObject, timeSeriesStructIn,
%    medianNormalizationFlag ) uses the TPS quarterStitchingClass to perform multi-quarter
%    time series conditioning to a DV time series struct or struct array.  When
%    medianNormalizationFlag == true, the values and uncertainties are also normalized by
%    the median value, quarter by quarter; when medianNormalizationFlag == false, no such
%    rescaling is performed.
%
% [timeSeriesStructOut, segmentInformationStruct] = performQuarterStitching( ... ) returns
%    a structure which contains target-by-target information about the data segments
%    (specifically the start and stop indices of each data segment, and the original
%    median value of each segment).
%
% Version date:  2010-October-21.
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
%    2010-October-21, PT:
%        add segmentInformationStruct return argument.
%
%=========================================================================================

% extract the necessary sub-structs

  gapFillParametersStruct          = dvDataObject.gapFillConfigurationStruct ;
  harmonicsParametersStruct        = dvDataObject.tpsHarmonicsIdentificationConfigurationStruct ;
  quarterStitchingParametersStruct = dvDataObject.tpsConfigurationStruct ;
  cadenceTimes                     = dvDataObject.dvCadenceTimes ;
  randStreams                      = dvDataObject.randStreamStruct.tpsRandStreams ;

% restore the original cadence times structure just in case

  cadenceTimes.quarters = ...
      cadenceTimes.originalQuarters;
  cadenceTimes.lcTargetTableIds = ...
      cadenceTimes.originalLcTargetTableIds;
  cadenceTimes = ...
      rmfield(cadenceTimes, {'originalQuarters', 'originalLcTargetTableIds'});

% set the median normalization flag

  quarterStitchingParametersStruct.medianNormalizationFlag = medianNormalizationFlag ;
  
% change the "filledIndices" in timeSeriesStruct to "fillIndices"

  if isfield( timeSeriesStructIn, 'filledIndices' )
      needToRename = true ;
      for iTarget = 1:length(timeSeriesStructIn)
          timeSeriesStructIn(iTarget).fillIndices = timeSeriesStructIn(iTarget).filledIndices ;
      end
      timeSeriesStructIn = rmfield( timeSeriesStructIn, 'filledIndices' ) ;
  else
      needToRename = false ;
  end
  
% add the kepler ID to the timeSeriesStruct since it is a required field

  if ~isfield( timeSeriesStructIn, 'keplerId' )
      for iTarget = 1:length(timeSeriesStructIn)
          timeSeriesStructIn(iTarget).keplerId = dvDataObject.targetStruct(iTarget).keplerId ;
      end
  end 
  
% do the quarter stitching

  quarterStitchingStruct.timeSeriesStruct                        = timeSeriesStructIn ;
  quarterStitchingStruct.gapFillParametersStruct                 = gapFillParametersStruct ;
  quarterStitchingStruct.harmonicsIdentificationParametersStruct = harmonicsParametersStruct ;
  quarterStitchingStruct.quarterStitchingParametersStruct        = quarterStitchingParametersStruct ;
  quarterStitchingStruct.cadenceTimes                            = cadenceTimes ;
  quarterStitchingStruct.randStreams                             = randStreams ;
  
  quarterStitchingObject = quarterStitchingClass( quarterStitchingStruct ) ;
  
  % identify outliers in each segment and store for continued use

  timeSeriesStructOut = get_time_series_struct(quarterStitchingObject) ;

  for iTarget = 1:length(timeSeriesStructOut)

      target = timeSeriesStructOut(iTarget) ;
      outlierIndicators = false( size( target.values) ) ;
      if isfield(target, 'fillIndices')
          fillIndicators = false( size( target.values ) ) ;
          fillIndicators(target.fillIndices) = true ;
      end
      for iSegment = 1:length( target.dataSegments )

          segmentStart = target.dataSegments{iSegment}(1) ;
          segmentEnd   = target.dataSegments{iSegment}(2) ;
          fluxValues   = target.values(segmentStart:segmentEnd) ;
          gapIndicators = target.gapIndicators(segmentStart:segmentEnd) ;
          if isfield(target, 'fillIndices')
              gapIndicators = gapIndicators | fillIndicators(segmentStart:segmentEnd) ;
          end

          [indexOfAstroEvents] = ...
              identify_astrophysical_events(fluxValues, gapIndicators, ...
                  gapFillParametersStruct) ;

          % transform indices back to full flux indices

          indexOfAstroEvents = indexOfAstroEvents + segmentStart - 1 ;
          outlierIndicators(indexOfAstroEvents) = true ;

      end

      quarterStitchingStruct.timeSeriesStruct(iTarget).outlierIndicators = ...
          outlierIndicators ;

  end

% Re-instantiate to include outlier indices and do quarter stitching

  quarterStitchingObject = quarterStitchingClass( quarterStitchingStruct ) ;
  quarterStitchingObject = perform_quarter_stitching( quarterStitchingObject ) ;
  timeSeriesStructOut    = get_time_series_struct( quarterStitchingObject ) ;
  
% rename back to "filledIndices" if necessary

  if needToRename
      for iTarget = 1:length(timeSeriesStructOut)
          timeSeriesStructOut(iTarget).filledIndices = timeSeriesStructOut(iTarget).fillIndices ;
      end
      timeSeriesStructOut = rmfield( timeSeriesStructOut, 'fillIndices' ) ;
  end
  
% fill the segmentInformationStruct if requested

  if nargout > 1
      
      segmentInformationStruct = struct( 'keplerId', [], 'timeSeriesType', '', ...
          'segment', [] ) ;
      segmentInformationStruct = repmat( segmentInformationStruct, ...
          size( timeSeriesStructOut ) ) ;
      for iTarget = 1:length( timeSeriesStructOut )
          thisTimeSeriesStruct = timeSeriesStructOut(iTarget) ;
          segmentInformationStruct(iTarget).keplerId = thisTimeSeriesStruct.keplerId ;
          segmentInformationStruct(iTarget).timeSeriesType = ...
              thisTimeSeriesStruct.timeSeriesType ;
          segment = struct( 'startIndex', [], 'endIndex', [], 'medianValue', [] ) ;
          segment = repmat( segment, length( thisTimeSeriesStruct.dataSegments ), 1 ) ;
          for iSegment = 1:length( thisTimeSeriesStruct.dataSegments )
              
              segment(iSegment).startIndex  = thisTimeSeriesStruct.dataSegments{iSegment}(1) ;
              segment(iSegment).endIndex    = thisTimeSeriesStruct.dataSegments{iSegment}(2) ;
              segment(iSegment).medianValue = thisTimeSeriesStruct.medianValues(iSegment) ;
                            
          end

          segmentInformationStruct(iTarget).segment = segment ;
          clear segment ;
          
      end
      
  end
          
  
% remove fields which are not needed

  timeSeriesStructOut = rmfield( timeSeriesStructOut, { 'dataSegments', 'gapSegments', ...
      'harmonicsValues', 'keplerId', 'timeSeriesType', 'medianValues', 'outlierFillValues' } ) ;
  
return

% and that's it!

%
%
%
