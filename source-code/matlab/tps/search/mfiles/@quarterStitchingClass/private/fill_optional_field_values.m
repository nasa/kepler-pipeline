function quarterlyStitchingObject = fill_optional_field_values( quarterlyStitchingObject )
%
% fill_optional_field_values -- private method which populates the optional members of the
% quarterlyStitchingClass object
%
% quarterlyStitchingObject = fill_optional_field_values( quarterlyStitchingObject ) fills
%    the dataSegments, gapSegments, and harmonicsValues fields of the timeSeriesStruct,
%    the cadenceDurationInMinutes field of the gapFillParametersStruct, and the
%    cadencesPerDay and cadencesPerHour fields of the quarterlyStitchingParametersStruct.
%    In all cases the fill is performed only if the original field is empty.  This is a
%    private method of the quarterlyStitchingClass and should only be called in the class
%    constructor.
%
% Version date:  2011-May-26.
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
%    2011-May-26, PT:
%        convert fills which are contiguous with gaps back into gaps.
%    2010-October-12, PT:
%        populate medianValues field of timeSeriesStruct.
%    2010-September-22, PT:
%        add keplerId and timeSeriesType fields.
%
%=========================================================================================

% start with the easy ones:  the cadence-duration related ones

  if isempty( quarterlyStitchingObject.gapFillParametersStruct.cadenceDurationInMinutes )
      cadenceDurationInDays = median( diff( ...
          quarterlyStitchingObject.cadenceTimes.midTimestamps ) ) ;
      cadenceDurationInMinutes = cadenceDurationInDays * get_unit_conversion( 'day2min' ) ;
      quarterlyStitchingObject.gapFillParametersStruct.cadenceDurationInMinutes = ...
          cadenceDurationInMinutes ;
  end
  
  if isempty( quarterlyStitchingObject.quarterStitchingParametersStruct.cadencesPerDay )
      cadenceDurationInDays = ...
          quarterlyStitchingObject.gapFillParametersStruct.cadenceDurationInMinutes * ...
          get_unit_conversion( 'min2day' ) ;
      quarterlyStitchingObject.quarterStitchingParametersStruct.cadencesPerDay = ...
          1 / cadenceDurationInDays ;
  end

  if isempty( quarterlyStitchingObject.quarterStitchingParametersStruct.cadencesPerHour )
      cadenceDurationInHours = ...
          quarterlyStitchingObject.gapFillParametersStruct.cadenceDurationInMinutes * ...
          get_unit_conversion( 'min2day' ) * get_unit_conversion( 'day2hour' ) ;
      quarterlyStitchingObject.quarterStitchingParametersStruct.cadencesPerHour = ...
          1 / cadenceDurationInHours ;
  end
 
% now for the hard part:  filling the data and gap segment information for each target

  timeSeriesStruct = quarterlyStitchingObject.timeSeriesStruct ;
  for iTarget = 1:length(timeSeriesStruct)
      
      gapIndicators = [] ;
      if isempty( timeSeriesStruct(iTarget).dataSegments )
          
          originalGapIndicators = timeSeriesStruct(iTarget).gapIndicators ;
          [dataSegments, gapSegments, gapIndicators, fillIndices] = ...
              get_segments_and_gap_fill_info( ...
              originalGapIndicators, ...
              timeSeriesStruct(iTarget).fillIndices, ...
              quarterlyStitchingObject.cadenceTimes.quarters ) ;
          timeSeriesStruct(iTarget).dataSegments  = dataSegments ;
          timeSeriesStruct(iTarget).gapSegments   = gapSegments ;
          timeSeriesStruct(iTarget).gapIndicators = gapIndicators ;
          timeSeriesStruct(iTarget).fillIndices   = fillIndices ;
          
%         in this case, there may be some cadences which were marked as gaps in the input
%         struct and which are now marked as fills because they are not inter-quarter
%         gaps. Find those cadences and give them a super-cheap filling with linear
%         interpolation now

          stillGapIndicators = originalGapIndicators & ~gapIndicators ;
          if ~all(stillGapIndicators)
              timeSeriesStruct(iTarget).values(stillGapIndicators) = interp1( ...
                  find(~stillGapIndicators), ...
                  timeSeriesStruct(iTarget).values(~stillGapIndicators), ...
                  find(stillGapIndicators), 'linear','extrap') ;
          end
          
      else
          
          gapIndicators = timeSeriesStruct(iTarget).gapIndicators ;
          
      end
      if isempty( timeSeriesStruct(iTarget).harmonicsValues )
          timeSeriesStruct(iTarget).harmonicsValues = zeros( ...
              size( timeSeriesStruct(iTarget).values ) ) ;
      end
      if isempty( timeSeriesStruct(iTarget).keplerId )
          timeSeriesStruct(iTarget).keplerId = -1 ;
      end
      if isempty( timeSeriesStruct(iTarget).timeSeriesType )
          timeSeriesStruct(iTarget).timeSeriesType = 'unknown' ;
      end
      if isempty( timeSeriesStruct(iTarget).outlierIndicators )
          timeSeriesStruct(iTarget).outlierIndicators = false( size( timeSeriesStruct(iTarget).values ) ) ;
      end
      
%     make sure that all gapped cadences are set to zero, since some fill cadences may
%     have been changed to gaps
      
      timeSeriesStruct(iTarget).values(gapIndicators) = 0 ;
      
  end
  
  quarterlyStitchingObject.timeSeriesStruct = timeSeriesStruct ;
  
return


  