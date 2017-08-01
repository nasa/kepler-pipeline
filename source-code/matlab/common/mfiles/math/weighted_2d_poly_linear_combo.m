function polyWeighted = weighted_2d_poly_linear_combo( polyVector, coeffs )
%
% weighted_2d_poly_linear_combo -- produce a linear combination of weighted 2d
% polynomials.
%
% polyWeighted = weighted_2d_poly_linear_combo( polyVector, coeffs ) takes a vector of
%    2-D weighted polynomial structures (see weighted_polyfit_2d for the details of this
%    structure) and a vector of coefficients, and produces a polynomial which is a linear
%    combination of the given polynomial, with the coefficients of the combination given
%    by the coeffs vector.  All of the polynomials in polyVector must be of the
%    'not_scaled' type.
%
% See also:  weighted_polyfit2d weighted_polyval2d.
%
% Version date:  2009-January-14.
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
%     2009-January-14, PT:
%         properly handle case in which some polynomials are identically zero due to
%         insufficient data.
%     2008-October-01, PT:
%         vectorize to eliminate for-loop for improved performance
%=========================================================================================

% input tests:  make sure that both inputs are vectors of equal length

  if (~isvector(polyVector) || ~isvector(coeffs))
      error('math:weighted2dPolyLinearCombo:argsNotVectors', ...
          'weighted_2d_poly_linear_combo:  arguments 1 and 2 must be vectors') ;
  end
  if (length(polyVector) ~= length(coeffs))
      error('math:weighted2dPolyLinearCombo:argsNotEqualLengths', ...
          'weighted_2d_poly_linear_combo:  arguments 1 and 2 must be equal in length') ;
  end

  coeffs = coeffs(:) ;
  coeffs2 = coeffs.^2 ;
  
  polyOrder = [polyVector.order] ;
  
  [maxOrder,maxOrderPolyIndex] = max(polyOrder) ;
  
% Extend all of the polynomials up to the required maximum order

  polyVector = extend_poly_order( polyVector, maxOrder ) ;
  
% use the first entry in polyVector as a field template for the output

   polyWeighted = polyVector(1) ;
   
%  perform the linear combination of coefficients and covariance  
   
  polyCoeffs = [polyVector.coeffs] ;
  polyCovariance = [polyVector.covariance] ;
  polyCovariance = reshape(polyCovariance, ...
      size(polyCoeffs,1)^2, size(polyCoeffs,2)) ;
  polyWeighted.coeffs = polyCoeffs * coeffs ;
  
% If some of the polynomials are not assigned, then their polyCovariance values are set to
% be identically equal to 1, but we don't want to combine that meaningless value with the
% meaningful values of the other polynomials.  We can detect this, since any polynomial
% which is not assigned has all its polyCoeffs identically 0 and the sum of its covariance
% identically 1

  polysNotAssigned = ( all(polyCoeffs==0) & sum(polyCovariance)==1 ) ;
  coeffs2(polysNotAssigned) = 0 ;
  
  polyWeighted.covariance = reshape( polyCovariance * coeffs2, ...
      size(polyCoeffs,1), size(polyCoeffs,1) ) ;
  
% and that's it!

%
%
%

%=========================================================================================

% function which extends polynomials from their current order to a larger one

function polyVectorOut = extend_poly_order( polyVectorIn, order, extendVector )

  polyVectorOut = polyVectorIn ;

% determine the number of coefficients required for a 2-D polynomial of the given order

  nCoeffs = sum(1:order+1) ;
  zeroVector = zeros(nCoeffs,1) ;
  zeroMatrix = zeros(nCoeffs) ;
  
% loop over polynomials and extend the coeffs and covariance fields

  for iPoly = 1:length(polyVectorOut)
      
      if (~strcmp(polyVectorIn(iPoly).type,'not_scaled'))
          error('math:weighted2dPolyLinearCombo:polyVectorInvalidType', ...
              'weighted_2d_poly_linear_combo:  polyVector must be ''not_scaled'' type') ;
      end
      thisPolyOrder = polyVectorIn(iPoly).order ;
      polyVectorOut(iPoly).order = order ;
      polyVectorOut(iPoly).coeffs = zeroVector ;
      oldCoeffs = polyVectorIn(iPoly).coeffs ;
      polyVectorOut(iPoly).coeffs(1:length(oldCoeffs)) = oldCoeffs ;
      polyVectorOut(iPoly).covariance = zeroMatrix ;
      oldCovariance = polyVectorIn(iPoly).covariance ;
      polyVectorOut(iPoly).covariance(1:size(oldCovariance,1),1:size(oldCovariance,2)) = ...
          oldCovariance ;
      
  end
  
% and that's it!

%
%
%