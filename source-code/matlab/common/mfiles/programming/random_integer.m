function r = random_integer( varargin )
%
% random_integer -- generate arrays of random integers
%
% r = random_integer( lowestValue, highestValue ) returns an integer, randomly generated
%    between lowestValue and highestValue.  Generation is inclusive, ie, lowestValue and
%    highestValue are both possible values for r.
% 
% r = random_integer( M, lowestValue, highestValue ) returns an M x M array of random
%    integers.
%
% r = random_integer( M, N, ... P, lowestValue, highestValue ) returns an M x N x ... x P
%    array of random integers.
%
% r = random_integer( [M N ... P], lowestValue, highestValue ) is the same as
%    random_integer( M, N, ... P, lowestValue, highestValue ).
%
% The random_integer function uses rand internally to generate its random integers.  Thus,
%    control of the rand state controls the sequence produced by random_integer.
%
% See also rand.
%
% Version date:  2008-November-24.
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

% unpack arguments and repackage dimension arguments depending on their format

  if (nargin < 2)
      error('common:randomInteger:insufficientArguments', ...
          'random_integer:  number of arguments must be 2 or more') ;
  end
  lowestValue = varargin{nargin-1} ;
  highestValue = varargin{nargin} ;
  
  if (nargin > 3)
      dimVector = [] ;
      for iDim = 1:nargin-2
          dimVector = [dimVector varargin{iDim}] ;
      end
  elseif (nargin == 3)
      dimVector = varargin{1} ;
  else % nargin == 2
      dimVector = 1 ;
  end
  
  if ( ~isvector(dimVector) || ~isscalar(lowestValue) || ~isscalar(highestValue) )
      error('common:randomInteger:badArgumentFormat', ...
          'random_integer:  invalid argument format') ;
  end
  
% if the user reversed the order of the range arguments, issue a warning and exchange them

  if (highestValue < lowestValue)
      warning('common:randomInteger:valueArgsReversed', ...
          'random_integer:  lowest and highest value arguments are reversed') ;
      tempValue = lowestValue ;
      lowestValue = highestValue ;
      highestValue = tempValue ;
      clear tempValue ;
  end
  
% compute the multiplier for rand

  randRange = highestValue - lowestValue + 1 ;
  
% get the random integer array

  r = lowestValue + floor(rand(dimVector)*randRange) ;
  
return

% and that's it!

%
%
%

          