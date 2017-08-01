function [zp,yp] = morc_to_focal_plane_coords( module, out, row, col, baseString, flag )
%
% MORC_TO_FOCAL_PLANE_COORDS -- convert module, output, row, column coordinates to uniform
% coordinates on the Kepler focal plane.
%
% [zp,yp] = morc_to_focal_plane_coords( mod, out, row, col, baseString ) takes 4 
%    equal-length vectors which specify the module, output, row, and column coordinates of
%    a set of points, and returns the coordinates on the focal plane, zp (Matlab-ese for
%    the Z' coordinate) and yp (Y').  The coordinates are in units of pixels.  The gap
%    between CCDs on a module are represented approximately correctly, as are the gaps
%    between modules.  The orientation is with module 2 in the upper-left portion of the
%    display, consistent with the coordinate system defined in Figure 5.2.3-3 of the GS-FS
%    ICD (KP-116 rev E). Argument baseString indicates whether the coordinates in row and
%    col are one-based (baseString == 'one-based') or zero-based (baseString ==
%    'zero-based').
%
% [dzp,dyp] = morc_to_focal_plane_coords( mod, out, drow, dcol, baseString, 1 ) takes 
%    differential vectors drow and dcol and returns differential coordinate changes dzp
%    and dyp.  In other words, use of a 1 as the 6th argument causes
%    morc_to_focal_plane_coords to apply the necessary rotations and sign changes to get
%    drow,dcol -> dzp,dyp, but does not apply the fixed offset on the focal plane between
%    the center of the focal plane and the requested module.
%
% [zp,yp] = morc_to_focal_plane_coords( mod, out, row, col, baseString, flag ), when flag 
%    is a vector equal in length to mod, out, row, col, causes the calculation of the
%    differential coordinate transform for values which have flag == 1 and calculation of
%    the absolute for values which have flag == 0.  HOWEVER:  all absolute calculations
%    must be either one-based or zero-based; mixing one- and zero-based conversions is not
%    supported!
%
% The arguments to morc_to_focal_plane_coords can be any mixture of row and column
% vectors.  In return, zp will be given the shape of row, and yp the shape of column.
%
% Version date:  2008-September-19.
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

% Modification history:
%
%     2008-September-19, PT:
%         require either zero- or one-based usage.
%     2008-july-10, PT:
%         switch to use of helper function get_ccd_orientation to figure out rotations of
%         the CCDs; change arguments to get_z_y_from_row_col in support of same.
%
%========================================================================================

% police the inputs -- make sure that they are all good, that the vectors are of equal
% length, and so on.  If flag is present and is a scalar, convert it to an equivalent
% vector; if it's absent, return an appropriate zero vector for it.

  if (nargin == 5)
      flag = police_args( module, out, row, col ) ;
  elseif (nargin == 6)
      flag = police_args( module, out, row, col, flag ) ;
  else
      error(' morc_to_focal_plane_coords requires 5 or 6 arguments') ;
  end
  
% convert everything to column vectors to simplify vector operations henceforth

  rowIsRow = (size(row,2) == 1) ;
  colIsRow = (size(col,2) == 1) ;
  module = module(:) ; out = out(:) ; row = row(:) ; col = col(:) ; flag = flag(:) ;

% convert row and col to one-based if they are passed as zero-based and if they are
% intended for absolute transformation (ie, if the flag value which goes with those
% row/col values is 0)

  if (strcmpi(baseString,'one-based'))
      
%     do nothing, this is the default      
      
  elseif (strcmpi(baseString,'zero-based'))
      absoluteXfrm = find(flag==0) ;
      row(absoluteXfrm) = row(absoluteXfrm) + 1 ;
      col(absoluteXfrm) = col(absoluteXfrm) + 1 ;
  else
      error(' morc_to_focal_plane coords arg 5 must be either ''zero-based'' or ''one-based'' ') ;
  end
  
% for absolute transforms, convert the column coordinate to CCD-based; for relative
% transforms, just flip the sign of the columns on odd-numbered outputs
 
  colCCD = convert_to_ccd_column( out, col, 'one-based' );
  flipSignOnly = find( mod(out,2)==0 & flag == 1 ) ;
  colCCD(flipSignOnly) = -col(flipSignOnly) ;
  
% get the CCD number -- do this by converting mod/out to channel # and dividing by 2

  ccdNum = ceil( convert_from_module_output( module, out ) / 2 ) ;
  
% apply the necessary rotation based on the CCD #

  [zp,yp] = get_z_y_from_row_col( row, colCCD, module, out ) ;
  
% get the offset from the center of the focal plane to row 0, col 0 on the CCD for cases
% in which an absolute coordinate is desired (flag == 0)

  [zp_offset,yp_offset] = get_ccd_offsets( module, ccdNum, flag ) ;
  
% add the offset to the return vectors

  zp = zp + zp_offset ;
  yp = yp + yp_offset ;
  
% since zp and yp are returned as column vectors, flip them if row and col were originally
% row vectors

  if (rowIsRow)
      zp = zp' ;
  end
  if (colIsRow)
      yp = yp' ;
  end
  
  
% and that's it!

%
%
%
  
%========================================================================================
%========================================================================================
%========================================================================================

% function police_args -- check the input arguments are well formed

function flag = police_args( mod, out, row, col, flag )
  
% if the last argument is missing, initialize it to a zero-vector equal in length to the
% size of mod

  if (nargin == 4)
      flag = zeros(size(mod)) ;
  end

% if flag is a scalar, convert it to a vector

  if (isscalar(flag))
      flag = flag * ones(size(mod)) ;
  end
  
% capture the length of the mod argument
  
  lvector = length(mod) ;

  % the 5 arguments all have to be real numeric vectors

  if ( ~isvector(mod) || ~isvector(out) || ~isvector(row) || ~isvector(col) || ...
       ~isvector(flag) )
      error('arguments to morc_to_focal_plane_coords must all be vectors') ;
  elseif ( ~isnumeric(mod) || ~isnumeric(out) || ~isnumeric(row) || ~isnumeric(col) || ...
           ~isnumeric(flag) )
      error('arguments to morc_to_focal_plane_coords must all be numeric') ;
  elseif ( ~isreal(mod) || ~isreal(out) || ~isreal(row) || ~isreal(col) || ~isreal(flag) )
      error('arguments to morc_to_focal_plane_coords must all be real') ;
      
% all the vectors have to have the same length

  elseif ( length(out) ~= lvector || length(row) ~= lvector || length(col) ~= lvector || ...
           length(flag) ~= lvector )
      error('arguments to morc_to_focal_plane_coords must have equal length') ;
      
  end
      
% value checking

  valCheck = {'mod',[],[],'[2:4,6:20,22:24]'''} ;
  validate_field(mod,valCheck,'morc_to_focal_plane') ;
  
  valCheck = {'out',[],[],'[1 2 3 4]'''} ;
  validate_field(out,valCheck,'morc_to_focal_plane') ;
  
  valCheck = {'flag',[],[],'[0 1]'''} ;
  validate_field(flag,valCheck,'morc_to_focal_plane') ;

  % and that's it!

%
%
%

%========================================================================================

% function which converts row and column to Z' and Y' based on the orientation of the CCD

function [zp,yp] = get_z_y_from_row_col( row, col, module, out ) 

  zp = zeros(size(row)) ; yp = zp ;
    
  orientation = get_ccd_orientation( module, out ) ;

% now assign the values

  orientation0 = find(orientation == 0) ;
  orientation1 = find(orientation == 1) ;
  orientation2 = find(orientation == 2) ;
  orientation3 = find(orientation == 3) ;

  zp(orientation0) =  col(orientation0) ; yp(orientation0) =  row(orientation0) ;
  zp(orientation1) =  row(orientation1) ; yp(orientation1) = -col(orientation1) ;
  zp(orientation2) = -col(orientation2) ; yp(orientation2) = -row(orientation2) ;
  zp(orientation3) = -row(orientation3) ; yp(orientation3) =  col(orientation3) ;
  
% and that's it!

%
%
%

%========================================================================================

% function which gets the offset from the center of the FOV to the row==0, col==0
% position on a given CCD, in the case where flag == 0; where flag == 1, the offset is
% zero.

function [zp_offset,yp_offset] = get_ccd_offsets( module, ccdNum, flag ) ;

% assign an initial zero vector to the returns

  zp_offset = zeros(size(module)) ; yp_offset = zp_offset ;
  
% find the ones of interest

  absoluteXfrm = find(flag == 0) ;
  
% define the size of a module, in pixels:  this is equal to the # of columns on a CCD plus
% the space between CCDs

  nColCCD = 2200 ; interCCDSpacePixels = 210 ;
  moduleSizePixels = nColCCD + interCCDSpacePixels ;
  
% define the distance from the center of the FOV to the center of each module, in units of
% module sizes

  modvec = reshape([1:25],5,5) ; modvec = modvec' ;
  
  dyMod = -ceil(modvec/5) + 3 ; dyMod = dyMod' ; dyMod = dyMod(:) ;
  dzMod = mod(modvec-1,5) - 2 ; dzMod = dzMod' ; dzMod = dzMod(:) ;
  
% add these to the offsets, in cases where the flag is set to zero

  zp_offset(absoluteXfrm) = moduleSizePixels * dzMod(module(absoluteXfrm)) ;
  yp_offset(absoluteXfrm) = moduleSizePixels * dyMod(module(absoluteXfrm)) ;
  
% the center of the module is at column 1112.5, row 1083.5.  Thus, the offset needs to be
% incremented by -1083.5 rows and -1112.5 columns, but these have to be converted to dZ'
% and dY' for the appropriate CCD.  Do that now.  Note that we will ask the
% get_z_y_from_row_col function to do all of the CCDs, not just the ones that are in the
% CCD list, since this turns out to be an efficient way to later extract the values we
% want.  

  [modlist,outlist] = convert_to_module_output( [1:2:84] ) ;

  [dz,dy] = get_z_y_from_row_col( -1083.5 * ones(1,42), -1112.5 * ones(1,42), ...
      modlist, outlist ) ;
  
  zp_offset(absoluteXfrm) = zp_offset(absoluteXfrm) + dz(ccdNum(absoluteXfrm))' ;
  yp_offset(absoluteXfrm) = yp_offset(absoluteXfrm) + dy(ccdNum(absoluteXfrm))' ;
  
% and that's it!

%
%
%

%=========================================================================================
  