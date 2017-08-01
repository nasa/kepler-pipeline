function [triangleNumber,rowVertex,colVertex,row,column] = find_triangle( ...
    prfCollectionObject, row, column )
%
% find_triangle -- determine the correct region of the mod/out for PRF interpolation
%
% [triangleNumber, rowVertex, columnVertex, row, column] = find_triangle( 
%    prfCollectionObject, row, column ) determines which of the four triangular regions on
%    a mod/out contains the point specified by the row and column. If the point lies
%    outside all 4 triangular regions, find_triangle will perform interpolation for the
%    nearest point which is valid, return the coordinates of that point, and issue a
%    warning.  The vertices of the triangle are also returned.
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
%         eliminate error for out-of-bounds points; issue a warning, do interp on nearest
%         valid point, and return that point's coordinates.
%
%=========================================================================================

  triangleNumber = 0 ;

% loop over triangles

  for iTriangle = 1:4
      [rowVertex, colVertex] = get_triangle_vertices( prfCollectionObject, iTriangle ) ;
      if inpolygon(row,column,rowVertex,colVertex)
          triangleNumber = iTriangle ;
          break ;
      end
  end
  
% did we find it?  If not, issue warning and handle the situation

  if (triangleNumber == 0)
      warning('prf:findTriangle:pointNotWithinAnyTriangle', ...
          'find_triangle: specified point (row==%f, column==%f) is not within any triangle', ...
          row,column) ;
      [row,column] = find_nearest_valid_point( prfCollectionObject, row, column ) ;
      [triangleNumber, rowVertex, colVertex, row, column] = find_triangle( ...
          prfCollectionObject, row, column ) ;
  end
  
% and that's it!

%
%
%

%=========================================================================================

% subfunction to find the nearest valid point

function [row, column] = find_nearest_valid_point( prfCollectionObject, row, column )

% find the maximum and minimum row/column values which are acceptable in this case

  minRow = min(prfCollectionObject.vertexRow) ;
  maxRow = max(prfCollectionObject.vertexRow) ;
  minCol = min(prfCollectionObject.vertexColumn) ;
  maxCol = max(prfCollectionObject.vertexColumn) ;

% the nearest point is the one which is closest to the min/max in each dimension.  There's
% a simple way to find this value, which is to sort the vector ([min max val]) and take
% the 2nd value of the sorted vector.  

  sortRow = sort([minRow maxRow row])    ; row    = sortRow(2) ;
  sortCol = sort([minCol maxCol column]) ; column = sortCol(2) ;
  