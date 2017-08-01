function value = integral_of_gaussian( center, width, lowerLimit, upperLimit )
%
% integral_of_gaussian -- compute the integral of a Gaussian distribution
%
% value = integral_of_gaussian( center, width, lowerLimit, upperLimit ) returns the
%    integral of a Gaussian distribution from lowerLimit to upperLimit, given a center and
%    width for the distribution.  The Gaussian is assumed to be properly normalized, ie,
%    the integral across all values of the independent variable is identically equal to 1.
%    Effectively, this function handles all the offsetting and scaling necessary to use
%    erf to do the integral, for those of us who have to re-figure all that stuff every
%    time we use it.  This function is vectorized, but requires that any
%    non-scalar arguments must have the same size as one another.
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

% first step:  deduce the size, and while we are at it catch mismatches

  try
      argumentProduct = center .* width .* lowerLimit .* upperLimit ;
      argSize = size( argumentProduct ) ;
  catch
      error('common:integralOfGaussian:argDimsInvalid', ...
          'integral_of_gaussian: invalid argument dimensions') ;
  end
  
% converty all scalar arguments to match argSize

  if isscalar(center),     center    =repmat(center,    argSize) ; end
  if isscalar(width),      width     =repmat(width,     argSize) ; end
  if isscalar(lowerLimit), lowerLimit=repmat(lowerLimit,argSize) ; end
  if isscalar(upperLimit), upperLimit=repmat(upperLimit,argSize) ; end
  

% convert the limits

  erfUpperLimit = (upperLimit - center)./(width*sqrt(2)) ;
  erfLowerLimit = (lowerLimit - center)./(width*sqrt(2)) ;
  
% compute the value

  value = 0.5 * ( erf(erfUpperLimit) - erf(erfLowerLimit) ) ;
  
return

