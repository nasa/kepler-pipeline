function quarterStitchingObject = detrend_edges_of_data_blocks( quarterStitchingObject, ...
    displayMessages )
%
% detrend_edges_of_data_blocks -- perform edge detrending of time series, one data block
% at a time
%
% quarterStitchingObject = detrend_edges_of_data_blocks( quarterStitchingObject ) goes
%    through the time series in the quarterStitchingObject and performs edge detrending on
%    each contiguous block of data in each time series.  This simplifies the problem of
%    gap-filling the segments between blocks by making the block edges match one another
%    better than they otherwise would, and also reduces confusion for the harmonic removal
%    algorithm.
%
% ... = detrend_edges_of_data_blocks( ..., false ) disables the display of the start and
%    end messages.  The default is to display messages.
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

% Modification history:
%
%   2011-May-26, PT:
%       update to use new version of edge detrending (mainly changes the function
%       signature, which in turn means changes in information which is unpacked in this
%       method).
%
%=========================================================================================

% handle optional argument

 if ~exist( 'displayMessages', 'var' ) || isempty( displayMessages )
     displayMessages = true ;
 end

% extract some useful information from the object

  timeSeriesStruct        = quarterStitchingObject.timeSeriesStruct ;

  parametersStruct        = quarterStitchingObject.quarterStitchingParametersStruct ;
  randStreams             = quarterStitchingObject.randStreams ;
  debugLevel              = parametersStruct.debugLevel ;
  cadencesPerDay          = parametersStruct.cadencesPerDay ;
  dataAnomalyFlags        = quarterStitchingObject.cadenceTimes.dataAnomalyFlags ;
  earthPoints             = dataAnomalyFlags.earthPointIndicators ;
  safeModes               = dataAnomalyFlags.safeModeIndicators ;
  
% disable messages if debugLevel < 0 
  
  if debugLevel < 0
      displayMessages = false ;
  end
  
% define an edge-detrending parameter struct

  edgeDetrendingParametersStruct.cadencesPerDay = cadencesPerDay ;
  
% send a message to the log

  if displayMessages
      disp( ['    Performing edge detrending for ', num2str( length( timeSeriesStruct ) ), ...
          ' targets ... '] ) ;
  end
  startTime = clock ;
  
  timeSeriesStruct(1).frontExponentialSize = [] ;
  timeSeriesStruct(1).backExponentialSize  = [] ;

% loop over targets, and within that over segments

  for iTarget = 1:length( timeSeriesStruct )
      
      target = timeSeriesStruct(iTarget) ;
      randStreams.set_default( target.keplerId ) ;
      
%     if we need to perform detrending of the monthly transients, change the local data
%     and gap segment information such that the monthly and safe mode intervals become
%     gaps

      if parametersStruct.edgeDetrendWithinQuarters
          
%         we need to make a fake "quarters" vector which shows that each safe mode or
%         earth point is an inter-quarter gap
          
          psuedoQuarters = zeros(size(earthPoints)) ;
          psuedoQuarters(target.gapIndicators) = -1 ;
          psuedoQuarters(earthPoints)          = -1 ;
          psuedoQuarters(safeModes)            = -1 ;
          
          psuedoGapIndicators = psuedoQuarters == -1 ;
          
          iQuarter = 1 ;
          psuedoQuarters(1) = iQuarter ;
          for iCadence = 2:length(psuedoQuarters)
              if psuedoQuarters(iCadence) ~= -1
                  if psuedoQuarters(iCadence-1) == -1
                      iQuarter = iQuarter + 1 ;
                  end
                  psuedoQuarters(iCadence) = iQuarter ;
              end
          end
          
          [target.dataSegments] = ...
              get_segments_and_gap_fill_info( ...
              psuedoGapIndicators, target.fillIndices, psuedoQuarters ) ;
          
      end
      
      for iSegment = 1:length( target.dataSegments )
          
          segmentStart = target.dataSegments{iSegment}(1) ;
          segmentEnd   = target.dataSegments{iSegment}(2) ;
          fluxValues   = target.values(segmentStart:segmentEnd) ;
                    
%         perform edge detrending and tune up median subtraction

          [detrendedFluxValues, frontExponentialSize, backExponentialSize] = ...
              detrend_edges_of_time_series( fluxValues, ...
              edgeDetrendingParametersStruct ) ;
          
          detrendedFluxValues = detrendedFluxValues - median(detrendedFluxValues) ;
          timeSeriesStruct(iTarget).frontExponentialSize = ...
              [timeSeriesStruct(iTarget).frontExponentialSize ; ...
              frontExponentialSize] ;
          timeSeriesStruct(iTarget).backExponentialSize = ...
              [timeSeriesStruct(iTarget).backExponentialSize ; ...
              backExponentialSize] ;
          
          target.values(segmentStart:segmentEnd) = detrendedFluxValues ;
          
      end % loop over segments
      
      timeSeriesStruct(iTarget).values = target.values ;
      
  end % loop over targets
  
  quarterStitchingObject.timeSeriesStruct = timeSeriesStruct ;
  randStreams.restore_default() ;
  
% display duration message to the log

  elapsedTime = etime( clock, startTime ) ;
  if displayMessages 
      disp( ['    ... done with edge detrending after ', ...
          num2str( elapsedTime ), ' seconds.' ] ) ;
  end
  
return

% and that's it!

%
%
%
