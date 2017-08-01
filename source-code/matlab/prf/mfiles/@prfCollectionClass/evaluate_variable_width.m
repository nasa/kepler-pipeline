function [pixelArray, rowArray, columnArray] = evaluate_variable_width( prfCollectionObject, row, ...
    column, rowsEvaluate, columnsEvaluate, width, polyBasis )
%
% evaluate -- compute the pixel response function at a given point given a collection of 
%    PRFs
%
% [pixelArray, rowArray, columnArray] = evaluate( prfCollectionObject, row, column ) 
%    evaluates the pixel response function at (one-based!) location (row,column).  The
%    prfCollectionObject is interpolated to the point of interest via triangular
%    interpolation.  The function returns a vector of pixel values (the PRF) and vectors
%    of rows and columns which correspond to the location of the PRF values.  The range of
%    pixels is determined by the prfCollectionObject's defaultRows and defaultColumns
%    members.
%
% [...] = evaluate( ... , rowsEvaluate, columnsEvaluate ) is the same except that the user
%    specifies the pixel positions which are to be used in the evaluation.
%
% [...] = evaluate( ... , rowsEvaluate, columnsEvaluate, polyBasis ) is the same except that the user
%    specifies the basis (design matrix) against with the prf polynomials are evaluated.
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
%     2008-September-24, PT:
%         if the interpolateFlag is false, just use the evaluate method on the
%         prfCenterObject.
%     2008-September-10, PT:
%         change the manner in which the default range of pixels for evaluation is
%         selected, based on guarantee that PRFs within a collection will all have the
%         same size.
%
%=========================================================================================

% if the prfCollectionClass actually contains only 1 PRF, skip the interpolation and use
% its evaluate method

if nargin < 4
    rowsEvaluate = [];
    columnsEvaluate = [];
end
if nargin < 7
    polyBasis = [];
end

  if ( ~prfCollectionObject.interpolateFlag )
          [pixelArray, rowArray, columnArray] = evaluate_variable_width( ...
              prfCollectionObject.prfCenterObject, row, column, rowsEvaluate, ...
              columnsEvaluate, width, polyBasis ) ;
  else

%     in this case, we need to really do the interpolation, so:

%     Find out which if the 4 triangles, if any, contains the point, and get the
%     vertices

      [triangleNumber, rowVertices, columnVertices,row,column] = find_triangle( ...
          prfCollectionObject, row, column ) ;
  
%     evaluate the PRFs which correspond to the triangle in question

      [prfCorner1,r1,c1] = evaluate_variable_width( ...
          prfCollectionObject.prfCornerObject(triangleNumber), ...
          row, column, rowsEvaluate, columnsEvaluate, width, polyBasis ) ;
      [prfCorner2,r2,c2] = evaluate_variable_width ( ...
          prfCollectionObject.prfCornerObject(triangleNumber+1), ...
          row, column, rowsEvaluate, columnsEvaluate, width, polyBasis ) ;
      [prfCenter,rc,cc] = evaluate_variable_width( ...
          prfCollectionObject.prfCenterObject, row, column, ...
           rowsEvaluate, columnsEvaluate, width, polyBasis ) ;
  
%     perform triangular interpolation on the 3 PRFs

      pixelArray = linear_interp_triangular( prfCorner1, prfCorner2, prfCenter, row, column, ...
           rowVertices, columnVertices , false ) ;
       rowArray = rc ; 
       columnArray = cc ; 
   
  end % interpolateFlag condition
   
% and that's it!

%
%
%


       
  