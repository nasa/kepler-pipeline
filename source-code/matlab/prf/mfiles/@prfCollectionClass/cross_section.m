function [xSectionValue, xSectionCoords] = cross_section( prfCollectionObject, ...
    dim, row, column, slice, resolution, reverse ) 
%
% cross_section -- get the cross-sectional shape of a prfCollectionClass object.
%
% [xSectionValue, xSectionCoords] = cross_section( prfCollectionObject, dim, row, column )
%    takes a cross-section of a prfCollectionClass object.  The cross-section value as a
%    function of row value (dim==1) or as a function of column value (dim==2) can be
%    returned.  The prfCollectionClass is evaluated at a particular row and column of the
%    module output specified by the row and column arguments.
%
% [...] = cross_section(..., slice, resolution, reverse ) allows the user to specify the
%    slice of interest (default is through the center of the PRF), the resolution, and
%    whether the PRF is to be reversed in evaluation.
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
%         improve argument management in case of one PRF in the object.
%     2008-September-24, PT:
%         add use of interpolateFlag.
%
%=========================================================================================

% if the last 3 arguments are missing set default values

  if nargin < 6
      resolution = 5000;
  end

  if nargin < 7
      reverse = 1;
  end

  if nargin < 5
      slice = fix(resolution/2);
  end
  
% if there is only one PRF here, use its cross-section method

  if ( ~prfCollectionObject.interpolateFlag )
      
      switch nargin
          
          case {2,3,4}
              [xSectionValue, xSectionCoords] = cross_section( ...
                  prfCollectionObject.prfCenterObject, dim ) ;
          case 5 % optional slice argument
              [xSectionValue, xSectionCoords] = cross_section( ...
                  prfCollectionObject.prfCenterObject, dim, slice ) ;
          case 6 % optional resolution argument
              [xSectionValue, xSectionCoords] = cross_section( ...
                  prfCollectionObject.prfCenterObject, dim, slice, resolution ) ;
          case 7 % optional reverse argument
              [xSectionValue, xSectionCoords] = cross_section( ...
                  prfCollectionObject.prfCenterObject, dim, slice, resolution, reverse ) ;
          otherwise
              error('prf:prfCollectionClass:cross_section:invalidArgs', ...
                'prfCollectionClass:cross_section:  invalid arguments') ;
            
      end

      
  else
      
%     otherwise, perform the interpolation:

%     find the triangle which contains the point of interest

      [triangleNumber, rowVertex, colVertex, row, column] = find_triangle( ...
          prfCollectionObject, row, column ) ;
  
%     get the cross-sections of the individual PRFs and interpolate them

      [xSection1, xSectionCoords] = cross_section( ...
          prfCollectionObject.prfCornerObject(triangleNumber), dim, slice, resolution, ...
          reverse ) ;
      [xSection2, xSectionCoords] = cross_section( ...
          prfCollectionObject.prfCornerObject(triangleNumber+1), dim, slice, resolution, ...
          reverse ) ;
      [xSectionC, xSectionCoords] = cross_section( ...
          prfCollectionObject.prfCenterObject, dim, slice, resolution, reverse ) ;
      xSectionValue = linear_interp_triangular( xSection1, xSection2, xSectionC, row, column, ...
          rowVertex, colVertex, false ) ;
  
  end % interpolateFlag condition
  
% and that's it!

%
%
%
