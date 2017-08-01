function [dRow,dCol] = compute_geometry_diff_in_pixels( rd2po0, rd2po1, row, col, mjd, ...
    basisString )
%
% compute_geometry_diff_in_pixels -- compute the geometry difference between the geometry
% models of 2 raDec2PixClass objects, in units of pixels
%
% [dRow,dCol] = compute_geometry_diff_in_pixels( rd2po0, rd2po1, row, col, mjd, 
%    basisString ) uses raDec2PixClass object rd2po0 to compute the RA and Dec of the
%    points represented in vectors row and col, on all mod/outs; the RA and Dec are then
%    converted back into row and column using the rd2po1 raDec2PixClass object.  The
%    difference between the final row/column and the initial values are reported in the
%    dRow and dCol return vectors. In the event that the final mod/out does not equal the
%    initial mod/out, the values with mismatched mod/outs will be reported as NaNs.  The
%    user must specify either one-based or zero-based coordinates by the value of the
%    sixth argument ('one-based' or 'zero-based', respectively).
%
% version date:  2008-September-19.
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

% Revision history:
%
%     2008-September-19, PT:
%         support for zero- or one-based coordinates.
%
%=========================================================================================

% handle the basisString now

  if ( strcmpi(basisString,'one-based') )
      rd2po0 = become_one_based(rd2po0) ;
      rd2po1 = become_one_based(rd2po1) ;
  elseif ( strcmpi(basisString,'zero-based') )
      rd2po0 = become_zero_based(rd2po0) ;
      rd2po1 = become_zero_based(rd2po1) ;
  else
      error('Arg 6 in compute_geometry_diff_in_pixels must be either ''one-based'' or ''zero-based'' ') ;
  end

% There are 84 mod/outs and nPoints row/col value pairs.  We need to make these vectors
% equal in length, and properly organized.  

  [mod,out] = convert_to_module_output(1:84) ;
  mod = mod(:)' ; out = out(:)' ;
  row = row(:) ; col = col(:) ;
  
  nPoints = length(row) ;
  mod = repmat(mod,nPoints,1) ; mod0 = mod(:) ;
  out = repmat(out,nPoints,1) ; out0 = out(:) ;
  row = repmat(row,84,1) ; row0 = row(:) ;
  col = repmat(col,84,1) ; col0 = col(:) ;
  
% convert to RA and Dec using the initial raDec2PixClass object

  [ra,dec] = pix_2_ra_dec(rd2po0, mod0, out0, row0, col0, mjd) ;
  
% convert back to MORC coordinates using the other raDec2PixClass object

  [mod1,out1,row1,col1] = ra_dec_2_pix(rd2po1, ra, dec, mjd) ;
  
% form the diff vectors

  dRow = row0 - row1 ;
  dCol = col0 - col1 ;
  
% NaN any values which fell off of the mod/out

  badMod = find(mod1 ~= mod0) ; badOut = find(out1 ~= out0) ;
  badPoints = unique([badMod(:) ; badOut(:)]) ;
  dRow(badPoints) = NaN ; dCol(badPoints) = NaN ;
  
% and that's it!

%
%
%