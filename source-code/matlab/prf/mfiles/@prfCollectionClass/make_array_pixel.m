function [prfValue, prfRow, prfColumn] = make_array_pixel( prfCollectionObject, pixelsToDraw, row, column, ...
    resolution, reverse, offset )
%
% make_array -- make an array of the values in a prfCollectionClass object
%
% [prfValue, prfRow, prfColumn] = make_array( prfCollectionObject, row, column ) returns
%    an array containing the shape of the pixel response function at the specified
%    location, given the prfCollectionClass object:  prfValue(i) is the intensity of a
%    pxiel when the center of that pixel is prfRow(i) rows and prfColumn(i) columns from
%    the centroid of a point source of light.  
%
% [...] = make_array( ... , resolution, reverse ) allows the user to specify the desired
%    resolution and reversal of the output wrt the nominal.
%
% Version date:  2008-October-10.
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
%         improved argument handling for case of 1 PRF in object.
%     2008-September-24, PT:
%         add use of interpolateFlag.
%
%=========================================================================================

% set defaults if the last 2 arguments are missing

  if nargin < 5
      resolution = 500;
  end

  if nargin < 6
      reverse = 1;
  end
  
  if nargin < 7
    offset = [0 0];
  end
  
% if there is only 1 prfClass object, use its make_array method

%     find the triangle which contains the point of interest

  [triangleNumber, rowVertex, colVertex,row,column] = find_triangle( ...
      prfCollectionObject, row, column ) ;

%     get the arrays of the individual PRFs and interpolate them

  [prfArray1,prfRow,prfColumn] = make_array_pixel( ...
      prfCollectionObject.prfCornerObject(triangleNumber), pixelsToDraw, resolution, reverse, offset ) ;
  [prfArray2,prfRow,prfColumn] = make_array_pixel( ...
      prfCollectionObject.prfCornerObject(triangleNumber+1), pixelsToDraw, resolution, reverse, offset ) ;
  [prfArrayC,prfRow,prfColumn] = make_array_pixel( ...
      prfCollectionObject.prfCenterObject, pixelsToDraw, resolution, reverse, offset ) ;
  prfValue = linear_interp_triangular( prfArray1, prfArray2, prfArrayC, row, column, ...
      rowVertex, colVertex, false ) ;
  
% and that's it!

%
%
%


