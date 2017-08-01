function [dataSegments, gapSegments, interQuarterGapIndicators, fillIndices] = ...
    get_segments_and_gap_fill_info( gapIndicators, fillIndices, quarters )
%
% get_segments_and_gap_fill_info -- determine where contiguous data regions and data gaps
% are present in a time series
%
% [dataSegments, gapSegments, gapIndicators, fillIndices] = 
%    get_segments_and_gap_fill_info( gapIndicators, fillIndices, quarters ) uses the
%    quarters vector from cadenceTimes to determine the location of inter-quarter gaps.
%    Any other gap or fill which is adjacent to an inter-quarter gap is converted into
%    part of that gap. Any non-inter-quarter gap is converted to a fill.  Thus at the end
%    there are good data cadences, inter-quarter gaps, and intra-quarter fills, and
%    nothing else. The return variables include updated gap indicators and fill indices
%    (after the conversion of any fills adjacent to gaps), plus start and end cadences for
%    each data region and gap region in the time series.
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

% take the quarters vector and squeeze out the intra-quarter gap locations within it

  nQuarters = max(quarters) ;
  for iQuarter = 1:nQuarters
      quarters(find(quarters==iQuarter,1,'first'):find(quarters==iQuarter,1,'last')) = ...
          iQuarter ;
  end

% build the vector of inter-quarter gap indicators from the quarters vector
  
  interQuarterGapIndicators = quarters < 0 ;
  
% construct a vector with all of the fill or gap indicators which are not inter quarter
% gaps

  fillIndicators = false( size( gapIndicators ) ) ;
  fillIndicators( fillIndices ) = true ;
  gapOrFillIndicators = fillIndicators | gapIndicators ;
  gapOrFillIndicators = gapOrFillIndicators & ~interQuarterGapIndicators ;
  
% get the start and stop of every current gap and fill region in the time series

  gapSegments  = fill_data_or_gap_segments( find( interQuarterGapIndicators ) ) ;
  fillSegments = fill_data_or_gap_segments( find( gapOrFillIndicators ) ) ;
  
% convert the fill segments cell array into a matrix for ease of use

  fillSegments = cell2mat( fillSegments ) ;
  fillSegments = reshape( fillSegments, 2, length( fillSegments ) / 2 ) ;
  
  fillSegmentConversionIndicator = false( size( fillSegments, 2 ), 1 ) ;
  
% loop over gap segments looking for leading or trailing fill segments, if they are found
% set the appropriate conversion indicator

  for iGapSegment = 1:length( gapSegments ) 
      
      startCadence = gapSegments{iGapSegment}(1) ;
      endCadence   = gapSegments{iGapSegment}(2) ;
      segmentPointer = find( startCadence-1 == fillSegments(2,:) ) ;
      if ~isempty( segmentPointer )
          fillSegmentConversionIndicator( segmentPointer ) = true ;
      end
      segmentPointer = find( endCadence+1 == fillSegments(1,:) ) ;
      if ~isempty( segmentPointer )
          fillSegmentConversionIndicator( segmentPointer ) = true ;
      end
      
  end
  
% for each fill segment which is marked, transform the filled cadences back to gapped
% cadences

  for iFillSegment = find( fillSegmentConversionIndicator' )
      
      interQuarterGapIndicators( fillSegments(1,iFillSegment):...
                                 fillSegments(2,iFillSegment) ) = true ;
      gapOrFillIndicators(       fillSegments(1,iFillSegment):...
                                 fillSegments(2,iFillSegment) ) = false ;
      
  end
    
% convert fill indicators back to indices

  fillIndices = find( gapOrFillIndicators ) ;
  
% find the data and gap segments based on the updated information

  dataSegments = fill_data_or_gap_segments( find( ~interQuarterGapIndicators ) ) ;
  gapSegments  = fill_data_or_gap_segments( find(  interQuarterGapIndicators ) ) ;
  
return

%=========================================================================================

% subfunction which converts the list of cadences to a set of start-and-end cadences for
% each block

function cadenceSegments = fill_data_or_gap_segments( validCadences )

% find the steps between valid cadences, and mark the end of the delta vector with an inf;
% note that if there's only 1 cadence in validCadences, then deltaCadences = [inf].

  
  if ~isempty( validCadences )

      deltaCadences = diff( validCadences ) ;
      deltaCadences = [deltaCadences ; inf] ;
      nBlocks = length(find(deltaCadences>1)) ;
      cadenceSegments = cell(nBlocks,1) ;

      thisSegment = [validCadences(1) ; 0] ;
      stepPointer = 0 ;
      blockNumber = 1 ;

      while stepPointer == 0 || ~isinf( deltaCadences( stepPointer ) )

    %     find the next place where deltaCadences is not 1; that's where the current block
    %     ends and the next one begins

          stepPointer = stepPointer + find( deltaCadences(stepPointer+1:end) > 1, 1, 'first' ) ;
          thisSegment(2) = validCadences(stepPointer) ;
          cadenceSegments{blockNumber} = thisSegment ;

    %     if we're not yet pointing at the end of the deltaCadences vector, then there's
    %     another block yet to come, so set that up

          if ~isinf( deltaCadences( stepPointer ) )
              thisSegment = [validCadences(stepPointer+1) ; 0] ;
              blockNumber = blockNumber + 1 ;
          end

      end
      
  else
      
      cadenceSegments = cell(0) ;
      
  end
    
return