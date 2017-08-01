function [includedCadences, excludedCadences] = get_included_excluded_cadences( ...
    transitFitObject, removeCadencesFarFromTransit )
%
% get_included_excluded_cadences -- determine the lists of cadences which are included and
% excluded in planet fitting
%
% [includedCadences, excludedCadences] = get_included_excluded_cadences( transitFitObject
%    ) determines which cadences will be included or excluded from the fit based on gap
%    indicators and fill flags, and returns boolean vectors with size = [nCadences,1] for
%    each.
%
% [...] = get_included_excluded_cadences( ..., removeCadencesFarFromTransit ) marks as
%    excluded any cadences which are far from a transit if removeCadencesFarFromTransit
%    is true (default is false).
%
% Version date:  2013-February-20.
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
%    2013-February-20, JL:
%        change 'constraintPointWindowWidthTransits' to 5
%    2010-April-30, PT:
%        use only cadences which are near a transit to constrain the fit.
%
%=========================================================================================

% handle the optional argument

  if ~exist( 'removeCadencesFarFromTransit', 'var' ) || ...
          isempty( removeCadencesFarFromTransit )
      removeCadencesFarFromTransit = false ;
  end

% for now, we hard-code the "nearness to a transit" factor to 3 transits, and convert this
% to a buffer size

%  constraintPointWindowWidthTransits = 3.0 ;
  constraintPointWindowWidthTransits = 5.0 ;
  constraintPointBufferTransits = (constraintPointWindowWidthTransits-1) / 2 ;

% The excluded cadences are the ones with true gap indicators, or which are listed in the
% filledIndices list

  cadencesNotUsed = find(transitFitObject.whitenedFluxTimeSeries.gapIndicators) ;
  cadencesNotUsed = sort( [cadencesNotUsed(:) ; ...
      transitFitObject.whitenedFluxTimeSeries.filledIndices(:)] ) ;

  nCadences = length( transitFitObject.whitenedFluxTimeSeries.gapIndicators ) ;
  excludedCadences = repmat(false,nCadences,1) ;
  excludedCadences(cadencesNotUsed) = true ;
  includedCadences = ~excludedCadences ;
  
% remove the cadences which are far from a transit  
  
  if ( removeCadencesFarFromTransit )

      transitNumber = identify_transit_cadences( transitFitObject.transitGeneratorObject, ...
          get( transitFitObject.transitGeneratorObject, 'cadenceTimes' ), ...
          constraintPointBufferTransits ) ;
      cadencesOutOfTransit = find( transitNumber == 0 ) ;
      includedCadences( cadencesOutOfTransit ) = false ;
      excludedCadences( cadencesOutOfTransit ) = true ;
  
  end
  
  
return