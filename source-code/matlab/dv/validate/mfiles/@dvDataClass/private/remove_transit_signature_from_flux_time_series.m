function fluxTimeSeriesStruct = remove_transit_signature_from_flux_time_series( ...
    fluxTimeSeriesStruct, transitObject, removalType, transitBufferFactor )
%
% remove_transit_signature_from_flux_time_series -- remove the transit signature from a
% flux time series
%
% fluxTimeSeriesStruct = remove_transit_signature_from_flux_time_series(
%    fluxTimeSeriesStruct, transitObject, oddEvenFlag, removalType, transitBufferFactor )
%    takes a flux time series structure (with fields values, uncertainties, gapIndicators,
%    filledIndices) and a transit object, and removes the transit signature from the flux
%    time series; the resulting time series struct is returned.
%
% Options are controlled by additional flags as follows:
%
%    removalType:          if removalType == 0, the transit signature is subtracted from
%                          the flux time series.  If removalType == 1, the cadences which
%                          are thus subtracted are also gapped.  Default is 0.
%    transitBufferFactor:  when removalType == 1, this allows cadences which border on a
%                          transit to also be subtracted.  The value of
%                          transitBufferFactor sets the width of the buffer in transit
%                          durations; for example, transitBufferFactor == 1 causes all
%                          cadences in a transit, all cadences within 1 transit time
%                          before the start of each transit, and all cadences within 1
%                          transit time after the end of each transit to be gapped.
%
% remove_transit_signature_from_flux_time_series is a private method of the dvDataClass.
%
% Version date:  2009-April-27.
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
%    2010-April-27, PT:
%        eliminate use of oddEvenFlag in removing transits.
%    2009-October-21, PT:
%        special case handling:  when transitBufferFactor == inf, gap all transits.  This
%        is used for testing the fitter, so that we can create a case in which the
%        all-transits will pass but the odd and even transits will fail.
%
%=========================================================================================

% set defaults and test for valid values

  if ~exist('removalType','var') || isempty(removalType)
      removalType = 0 ;
  end
  if ~exist('transitBufferFactor','var') || isempty(transitBufferFactor)
      transitBufferFactor = 0 ;
  end
  
  if ~ismember(removalType,[0 1])
      error('dv:removeTransitSignatureFromFluxTimeSeries:removalTypeInvalid', ...
          'remove_transit_signature_from_flux_time_series:  removalType value invalid') ;
  end
  if transitBufferFactor < 0
      error('dv:removeTransitSignatureFromFluxTimeSeries:transitBufferFactorInvalid', ...
          'remove_transit_signature_from_flux_time_series:  transitBufferFactor value invalid') ;
  end
  
% perform the subtraction:  since the flux time series can have a trend, but is otherwise
% expected to be median-subtracted and median-divided, we need a slightly obscure notation
% to make this work

  transitModelValues = generate_planet_model_light_curve( transitObject ) ;
  fluxValues = fluxTimeSeriesStruct.values ;
  
  fluxTimeSeriesStruct.values = ( 1 + fluxValues ) ./ ( 1 + transitModelValues ) - 1 ;
  
% if the removal type is not zero, then we must also gap the cadences which are being
% removed.  Do that now.

  if ( removalType == 1 )
      
      if isinf( transitBufferFactor )
          cadenceSize = size( get( transitObject, 'cadenceTimes' ) ) ;
          transitCadences = true(cadenceSize) ;
      else
          transitNumber = identify_transit_cadences( transitObject, ...
              get( transitObject, 'cadenceTimes' ) , transitBufferFactor ) ;
          transitCadences = transitNumber > 0 ;
      end
      
      fluxTimeSeriesStruct.gapIndicators( transitCadences ) = true ;
      
  end
  
return

% and that's it!

%
%
%
