function display_extracted_time_series( module, output, timeSeriesStruct )
%
% DISPLAY_EXTRACTED_TIME_SERIES -- display a vector of keplerIdTimeSeriesStruct data
% structures in a particular module and output.
%
% display_extracted_time_series( module, output, timeSeriesStruct ) takes the pixels in
%    the timeSeriesStruct structure and displays them.  The position and orientation of
%    the plot is based on the module and output values (both scalars).  The
%    timeSeriesStruct is assumed to be a vector of data structures with fields that
%    include row (a row vector), column (a row vector), and timeSeries (a row vector).
%
% See also:  display_ccd.
%
% Version date:  2008-June-05.
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

% get the rows, columns, and time series into separate variables

  row = [timeSeriesStruct.row] ; 
  column = [timeSeriesStruct.column] ; 
  timeSeries = [timeSeriesStruct.timeSeries] ;
  
% construct a sparse matrix with the pixel data in it, offsetting the rows and columns so
% that row 20 (first illuminated row) becomes row 1 in the matrix and column 12 (first
% real column) becomes column 1 in the matrix.

  imageData = sparse(row-19,column-11,timeSeries,1024,1100) ;

% if the output # is even, flip the image left-right to correct for the fact that the
% even-numbered outputs have a column coordinate system which is the opposite of the
% odd-numbered outputs

  if ( mod(output,2) == 0 )
      imageData = fliplr(imageData) ;
  end

% Find the orientation of this CCD in the focal plane and use it to rotate the image to
% the correct orientation

  imageData = rot90( imageData,get_orientation( module, output ) ) ;
  
% find the positions of the corners in z', y' space (ie, FOV coordinates), and the min and
% max
  
  rowCorner = [20 20 1043 1043] ; colCorner = [12 1111 1111 12] ;
  [zLim,yLim] = morc_to_focal_plane_coords([module module module module], ....
      [output output output output], rowCorner, colCorner) ;
  zmin = min(zLim) ; zmax = max(zLim) ;
  ymin = min(yLim) ; ymax = max(yLim) ;

% display the image in the requested location on the focal plane display  
  
  colormap gray
  imagesc([zmin zmax],[ymin ymax],imageData) ;
  
% and that's it!

%
%
%

%=========================================================================================

% get the # of 90 degree clockwise rotations needed to correctly orient the current image
% on the focal plane

function orientation = get_orientation( module, output )

% convert to CCD #

  ccdNum = ceil( convert_from_module_output( module, output ) / 2 ) ;
  
% now just do a lookup

  switch ccdNum
      
      case { 1 , 3 , 5 , 9 , 11 , 32 , 34 , 38 , 40 , 42 }
          orientation = 0 ;
      case { 8 , 13 , 15 , 18 , 20 , 22 , 23 , 25 , 28 , 30 , 35 }
          orientation = 1 ;
      case { 2 , 4 , 6 , 10 , 12 , 31 , 33 , 37 , 39 , 41 }
          orientation = 2 ;
      case { 7 , 14 , 16 , 17 , 19 , 21 , 24 , 26 , 27 , 29 , 36 }
          orientation = 3 ;
          
  end
  
% and that's it!

%
%
%
