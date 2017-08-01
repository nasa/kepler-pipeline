function transitObject = transitGeneratorCollectionClass( transitModel, oddEvenFlag, ...
    gapIndicators, filledIndices )
%
% transitGeneratorCollectionClass -- constructor for the transitGeneratorCollectionClass
%
% transitObject = transitGeneratorCollectionClass( transitModel, oddEvenFlag ) constructs
%    an object of the transitGeneratorCollectionClass.  The transitModel argument is
%    identical to the transitModel argument for the transitGeneratorClass.  The
%    oddEvenFlag argument can take one of the following values:
%
%    oddEvenFlag == 0 : one transitGeneratorClass object is embedded
%    oddEvenFlag == 1:  two transitGeneratorClass objects are embedded
%    oddEvenFlag == 2:  nTransit transitGeneratorClass objects are embedded.
%
%    When oddEvenFlag == 0, the single embedded transitGeneratorClass object is used to
%    produce the light curve for the transitGeneratorCollectionClass object.  When
%    oddEvenFlag == 1, the two embedded objects contribute alternate transits to the light
%    curve.  When oddEvenFlag == 2, each embedded object contributes 1 transit to the
%    light curve.
%
% transitObject = transitGeneratorCollectionClass( ..., gapIndicators, filledIndices )
%    provides the constructor with information on which transits are present and absent.
%    This is needed only for the oddEvenFlag == 2 case.
%
% Version date:  2010-April-26.
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

  if ~isscalar( oddEvenFlag )
      error('dv:transitGeneratorCollectionClass:oddEvenFlagInvalid', ...
          'transitGeneratorClass:  oddEvenFlag must be a scalar integer between 0 and 2' ) ;
  end

% instantiate a single transitGeneratorClass object (this also validates the transitModel)

  transitGeneratorObject0 = transitGeneratorClass( transitModel ) ;
  
% based on oddEvenFlag, decide how many transitGeneratorClass objects we need in the
% embedded vector

  switch oddEvenFlag
      
      case 0
          
          transitGeneratorObject = transitGeneratorObject0 ;
          
      case 1
          
          transitGeneratorObject = [transitGeneratorObject0 ; transitGeneratorObject0] ;
          
      case 2
          
          cadenceTimes = get( transitGeneratorObject0, 'cadenceTimes' ) ;
          
          if ~exist( 'gapIndicators', 'var' ) || isempty( gapIndicators )
              warning('dv:transitGeneratorCollectionClass:gapIndicatorsNotPresent', ...
                  'transitGeneratorCollectionClass:  setting gapIndicators to all false' ) ;
              gapIndicators = false( size( cadenceTimes ) ) ;
          end
          if ~islogical( gapIndicators ) || ~isequal( size( gapIndicators ), ...
                  size( cadenceTimes ) )
              error( 'dv:transitGeneratorCollectionClass:gapIndicatorsInvalid', ...
                  'transitGeneratorCollectionClass:  gapIndicators incorrectly formed' ) ;
          end
          
          if ~exist( 'filledIndices', 'var' )
              warning('dv:transitGeneratorCollectionClass:filledIndicesNotPresent', ...
                  'transitGeneratorCollectionClass:  setting filledIndices to empty' ) ;
              filledIndices = [] ;
          end
          if ~isempty( filledIndices ) && ...
                  ( ~isvector( filledIndices ) || ...
                    any( ~ismember( filledIndices, 1:length(cadenceTimes) ) ) )
              error( 'dv:transitGeneratorCollectionClass:filledIndicesInvalid', ...
                  'transitGeneratorCollectionClass:  filledIndices incorrectly formed' ) ;
          end
              
          transitGeneratorObject = [] ;
          [nTransits,nValidTransits] = get_number_of_transits_in_time_series( ...
              transitGeneratorObject0, cadenceTimes, gapIndicators, filledIndices ) ;
          for iObject = 1:nTransits
              transitGeneratorObject = [transitGeneratorObject ; ...
                  transitGeneratorObject0] ;
          end
          
      otherwise % error case

          error('dv:transitGeneratorCollectionClass:oddEvenFlagInvalid', ...
              'transitGeneratorClass:  oddEvenFlag must be a scalar integer between 0 and 2' ) ;
  end
          
  transitStruct.transitGeneratorObjectVector = transitGeneratorObject ;
  transitStruct.oddEvenFlag = oddEvenFlag ;
  
% instantiate!  instantiate!

  transitObject = class( transitStruct, 'transitGeneratorCollectionClass' ) ;
  
return

% and that's it!

%
%
%
