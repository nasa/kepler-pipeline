function prfObject = get_interpolated_prf( prfCollectionObject, row, column, interpMethod )
%
% get_interpolated_prf -- return a PRF which is interpolated from a prfCollectionClass
% object at a particular location.
%
% prfObject = get_interpolated_prf( prfCollectionObject, row, column ) returns a prfClass
%    object which is obtained by interpolating the PRFs in a prfCollectionClass object at
%    the requested row and column location. 
%
% prfObject = get_interpolated_prf( prfCollectionObject, row, column, 1 ) returns a
%    prfClass object which is obtained by interpolating the polynomials of the member
%    prfClass objects, rather than their coefficient matrices.  This method is much slower
%    than the coefficient matrix method, but allows access to the interpolated covariance
%    matrices, which are not available if interpolation of the coefficient matrices is
%    used.
%
% Version date:  2008-October-10.
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
%     2008-October-10, PT:
%         switch to interpolation method allowing points to lie slightly outside viewable
%         area.
%     2008-September-30, PT:
%         add option to interpolate the weighted polynomials so that resulting PRF object
%         has covariances available.
%     2008-September-24, PT:
%         switch over to use of interpolating the coefficientMatrix instead of the
%         polynomials.  Add support for interpolateFlag.
%
%=========================================================================================

% if interpMethod is missing, set its default -- coefficient matrix interpolation

  if (nargin == 3)
      interpMethod = 0 ;
  end

% determine whether interpolation is needed, and if not simply return an appropriate
% prfObject

  if ( ~prfCollectionObject.interpolateFlag )
      
      prfObject = prfCollectionObject.prfCenterObject ;
      
  elseif strcmpi(get(prfCollectionObject.prfCenterObject,'polyType'), 'discrete')
 		% get the three prf arrays
 
      [iTriangle,rowVertex,colVertex,row,column] = find_triangle( prfCollectionObject, ...
          row, column ) ;

      prfArray1 = get( prfCollectionObject.prfCornerObject(iTriangle), ...
          'prfArray' ) ;
      prfArray2 = get( prfCollectionObject.prfCornerObject(iTriangle+1), ...
          'prfArray' ) ;
      prfArray3 = get( prfCollectionObject.prfCenterObject, ...
          'prfArray' ) ;

%         get the coefficients for the interpolation

      prfArray = linear_interp_triangular( prfArray1,prfArray2,prfArray3, row, column, ...
          rowVertex, colVertex, false ) ;
	  prfObject = prfClass(prfArray);
  
  else
      
%     otherwise:  determine the triangle which contains the point of interpolation

      [iTriangle,rowVertex,colVertex,row,column] = find_triangle( prfCollectionObject, ...
          row, column ) ;
  
%     make sure the 3 prfClass objects are of type 'not_scaled', otherwise fail out

      prfType1 = get(prfCollectionObject.prfCornerObject(iTriangle),'polyType') ;
      prfType2 = get(prfCollectionObject.prfCornerObject(iTriangle+1),'polyType') ;
      prfType3 = get(prfCollectionObject.prfCenterObject,'polyType') ;
      if (~strcmpi(prfType1,'not_scaled') || ~strcmpi(prfType2,'not_scaled') || ...
              ~strcmpi(prfType3,'not_scaled') )
          error('prf:getInterpolatedPrf:cantInterpolateScaledPolys', ...
              'get_interpolated_prf:  can''t interpolate scaled polynomial types') ;
      end
      
%     if the user requested coefficient matrix interpolation method, use that:

      if ( interpMethod == 0 )
  
%         the three prfClass objects have to have the same maxOrder for the fast
%         interpolator to operate

          maxOrder1 = get(prfCollectionObject.prfCornerObject(iTriangle),'maxOrder') ;
          maxOrder2 = get(prfCollectionObject.prfCornerObject(iTriangle+1),'maxOrder') ;
          maxOrder3 = get(prfCollectionObject.prfCenterObject,'maxOrder') ;
          maxOrder = max([maxOrder1 maxOrder2 maxOrder3]) ;
        
%         get the coefficientMatrix structs out of the 3 selected prfObjects, and expand
%         them to the correct order if necessary

          coeffMatrix1 = get(prfCollectionObject.prfCornerObject(iTriangle),...
              'coefficientMatrix') ;
          if (maxOrder1 < maxOrder)
              coeffMatrix1 = expand_coefficient_matrix( coeffMatrix1, maxOrder1, maxOrder ) ;
          end
          coeffMatrix2 = get(prfCollectionObject.prfCornerObject(iTriangle+1),...
              'coefficientMatrix') ;
          if (maxOrder2 < maxOrder)
              coeffMatrix2 = expand_coefficient_matrix( coeffMatrix2, maxOrder2, maxOrder ) ;
          end
          coeffMatrix3 = get(prfCollectionObject.prfCenterObject,...
              'coefficientMatrix') ;
          if (maxOrder3 < maxOrder)
              coeffMatrix3 = expand_coefficient_matrix( coeffMatrix3, maxOrder3, maxOrder ) ;
          end
      
%         interpolate the coefficient matrices based on the triangular interpolation

          coefficientMatrix = linear_interp_triangular( coeffMatrix1, coeffMatrix2, coeffMatrix3, ...
              row, column, rowVertex, colVertex, false ) ;
      
%         construct the prfClass object from the coefficientMatrix

          prfObject = prfClass(coefficientMatrix) ;
          
      else % direct interpolation of the polynomials
          
          polyStruct1 = get( prfCollectionObject.prfCornerObject(iTriangle), ...
              'polyStruct' ) ;
          polyStruct2 = get( prfCollectionObject.prfCornerObject(iTriangle+1), ...
              'polyStruct' ) ;
          polyStruct3 = get( prfCollectionObject.prfCenterObject, ...
              'polyStruct' ) ;
          
%         make sure that all 3 polyStructs are well-formed

          if ( isempty(polyStruct1) || isempty(polyStruct2) || isempty(polyStruct3) )
              error('prf:getInterpolatedPrf:polyStructEmpty', ...
                  'get_interpolated_prf:  one or more empty polyStruct structures') ;
          end
          
          polyStruct = polyStruct1 ;
          
%         get the coefficients for the interpolation

          polyStructCoeffs = linear_interp_triangular( [1 0 0],[0 1 0],[0 0 1], row, column, ...
              rowVertex, colVertex, false ) ;
          
%         loop over the dimensions of the polynomial and perform the interpolation using
%         the built-in method for computing linear combinations of weighted polynomials

          for k=1:size(polyStruct,3) 
              for j = 1:size(polyStruct,2)
                  for i = 1:size(polyStruct,1)
                      polyStruct(i,j,k).c = weighted_2d_poly_linear_combo( ...
                          [polyStruct1(i,j,k).c polyStruct2(i,j,k).c polyStruct3(i,j,k).c], ...
                          polyStructCoeffs ) ;
                      polyStruct(i,j,k).order = polyStruct(i,j,k).c.order ;
                  end
              end
          end
          
%         construct the prfClass object from the interpolated polyStruct's

          prfObject = prfClass( polyStruct ) ;
          
      end % interpMethod conditional
          
  end % interpolateFlag condition
  
% and that's it!

%
%
%

