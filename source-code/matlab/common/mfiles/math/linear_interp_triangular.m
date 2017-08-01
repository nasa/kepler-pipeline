function P = linear_interp_triangular( P1, P2, P3, x, y, xv, yv, checkPolygon )
%
% linear_interp_triangular -- perform triangular interpolation.
%
% P = linear_interp_triangular( P1, P2, P3, x, y, xv, yv ) performs triangular interpretation
%    between 3 Matlab arrays of identical size (P1, P2, and P3); the coordinates of their
%    vertices are given by vectors xv and yv.  The array values are interpolated to the
%    point (x,y) which is within the triangle described by xv and yv.  See KADN-26054 for
%    a good description of triangular interpolation.
%
% P = linear_interp_triangular( P1, P2, P3, x, y, xv, yv, checkPolygon ) will check to make sure
%    that (x,y) is within the triangle described by xv and yv if checkPolygon is true
%    (default), or forego that test if checkPolygon is false.  The latter option is
%    intended for situations in which the caller has already verified that the point is
%    within the triangle.
%
% Version date:  2008-October-12.
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
%     2008-October-12, PT:
%         do not perform linear combination of the 3 arrays until the last step, to
%         improve computation speed.
%
%=========================================================================================

% assign default value of checkPolygon if necessary

  if (nargin == 7)
      checkPolygon = true ;
  end
  
% perform the polygon check if requested or required, and fail out if the point is not
% within the polygon.

  if (checkPolygon)
      inTriangle = inpolygon(x,y,xv,yv) ;
      if (~inTriangle)
          error('math:interpTriangular:pointNotInTriangle', ...
              'linear_interp_triangular:  the point of interest is not within the triangle') ;
      end
  end

% compute the matrix which relates the arrays P1,2,3 to the coefficients A,B,C as shown in
% KADN-26054

  interpMatrix = inv([ones(3,1) xv(:) yv(:)]) ;  
%   A = interpMatrix(1,1)*P1 + interpMatrix(1,2)*P2 + interpMatrix(1,3)*P3 ;
%   B = interpMatrix(2,1)*P1 + interpMatrix(2,2)*P2 + interpMatrix(2,3)*P3 ;
%   C = interpMatrix(3,1)*P1 + interpMatrix(3,2)*P2 + interpMatrix(3,3)*P3 ;

  A = interpMatrix(1,:) ; 
  B = interpMatrix(2,:) ;
  C = interpMatrix(3,:) ;

% compute the solution and return

%  P = A + B*x + C*y ;
 p = A + B*x + C*y ; 
 P = P1 * p(1) + P2 * p(2) + P3 * p(3) ;
  
% and that's it!

%
%
%

  