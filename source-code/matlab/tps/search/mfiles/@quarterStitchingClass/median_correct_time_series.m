function quarterStitchingObject = median_correct_time_series( quarterStitchingObject )
%
% median_correct_time_series -- perform quarter-by-quarter median correction of a
% multi-quarter time series
%
% quarterStitchingObject = median_correct_time_series( quarterStitchingObject )
%    performs median correction and median normalization of a multi-quarter time series.
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

% extract some useful information from the object

  timeSeriesStruct        = quarterStitchingObject.timeSeriesStruct ;

  parametersStruct        = quarterStitchingObject.quarterStitchingParametersStruct ;
  debugLevel              = parametersStruct.debugLevel ;
    
% send a message to the log

  if debugLevel >= 0
      disp( ['    Performing median correction for ', num2str( length( timeSeriesStruct ) ), ...
          ' targets ... '] ) ;
  end
  startTime = clock ;

% loop over targets, and within that over segments

  for iTarget = 1:length( timeSeriesStruct )
      
      target = timeSeriesStruct(iTarget) ;
      for iSegment = 1:length( target.dataSegments )
          
          segmentStart = target.dataSegments{iSegment}(1) ;
          segmentEnd   = target.dataSegments{iSegment}(2) ;
          
%         perform median correction and median normalization

          fluxValues        = target.values(segmentStart:segmentEnd) ;
          fluxUncertainties = target.uncertainties(segmentStart:segmentEnd) ;
          
          medianValue       = median(fluxValues) ;
          fluxValues        = fluxValues - medianValue ;
          if abs(medianValue) > sqrt(eps('double'))
              fluxValues        = fluxValues / abs(medianValue) ;
              fluxUncertainties = fluxUncertainties / abs(medianValue) ;     
          end
                    
          target.values(segmentStart:segmentEnd)        = fluxValues ;
          target.uncertainties(segmentStart:segmentEnd) = fluxUncertainties ;
          target.medianValues(iSegment)                 = medianValue ;
          
      end % loop over segments
      
      timeSeriesStruct(iTarget) = target ;
      
  end % loop over targets
  
  quarterStitchingObject.timeSeriesStruct = timeSeriesStruct ;
  
% display duration message to the log

  elapsedTime = etime( clock, startTime ) ;
  if debugLevel >= 0
      disp( ['    ... done with median correction after ', num2str( elapsedTime ), ' seconds.' ] ) ;
  end
  
return

% and that's it!



%
%
%
