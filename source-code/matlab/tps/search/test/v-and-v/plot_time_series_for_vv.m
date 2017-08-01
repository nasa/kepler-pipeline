function plot_time_series_for_vv( tpsInputStruct, tpsOutputStruct, iTarget )
%
% plot_time_series_for_vv -- plot time series for verification and validation
%
% plot_time_series_for_vv( tpsInputStruct, tpsOutputStruct, iTarget ) plots the before and
%    after fluxes of the selected target.  Valid data and fills from PDC are plotted in
%    blue; gap fills in TPS are plotted in red in the after-quarter-stitching plot.
%
% Version date:  2010-October-22.
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

% start by idenfitying the cadences which are gapped vs ungapped

  timeSeries0 = tpsInputStruct.tpsTargets(iTarget).fluxValue ;
  timeSeries1 = tpsOutputStruct.tpsResults(iTarget).detrendedFluxTimeSeries ;
  keplerId    = tpsInputStruct.tpsTargets(iTarget).keplerId ;
  
  gapIndicators = false( size( timeSeries0 ) ) ;
  gapIndicators( tpsInputStruct.tpsTargets(iTarget).gapIndices+1) = true ;
  validPoints = find( ~gapIndicators ) ;
  invalidPoints = find( gapIndicators ) ;
  
  validCadenceTimes = find( ~tpsInputStruct.cadenceTimes.gapIndicators ) ;
  invalidCadenceTimes = find( tpsInputStruct.cadenceTimes.gapIndicators ) ;

  cadenceTimes = tpsInputStruct.cadenceTimes.midTimestamps ;
  cadenceTimes( invalidCadenceTimes ) = interp1( validCadenceTimes, ...
      cadenceTimes(validCadenceTimes), invalidCadenceTimes, 'linear', 'extrap' ) ;
  cadenceTimes = cadenceTimes - cadenceTimes(1) ;
  
% get the valid and invalid segments

  validSegments   = find_segments( validPoints ) ;
  invalidSegments = find_segments( invalidPoints ) ;
  
% do some plottin' 

  subplot(2,1,1) ; 
  for iSegment = 1:length(validSegments)
      indices = validSegments{iSegment} ;
      plot( cadenceTimes(indices), timeSeries0(indices) ) ;
      hold on
  end
  hold off
  ylabel('Absolute Flux [e^-]') ;
  title( [ 'Kepler ID ', num2str(keplerId) ] ) ;
  
  subplot(2,1,2) ;
  for iSegment = 1:length(validSegments)
      indices = validSegments{iSegment} ;
      plot( cadenceTimes(indices), timeSeries1(indices) ) ;
      hold on
  end
  for iSegment = 1:length(invalidSegments)
      indices = invalidSegments{iSegment} ;
      plot( cadenceTimes(indices), timeSeries1(indices), 'r' ) ;
      hold on
  end
  hold off
  xlabel('Time Since Start of Unit Of Work [Days]') ;
  ylabel('Relative Flux') ;
  
% adjust the horizontal axes

  subplot(2,1,2) ;
  xlimDesired = get( gca, 'xlim' ) ;
  subplot(2,1,1) ;
  set( gca, 'xlim', xlimDesired ) ;

return

%=========================================================================================

% subfunction to return vectors of indices which are valid and invalid segments

function segmentIndices = find_segments( validCadences )

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
  
% now convert to segmentIndices

  segmentIndices = cell(nBlocks,1) ;
  for iBlock = 1:nBlocks
      segmentIndices{iBlock} = cadenceSegments{iBlock}(1):cadenceSegments{iBlock}(2) ;
  end
  
return
