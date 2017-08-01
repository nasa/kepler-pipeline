function rowColVec = fpg_model_function( modelParameters, fitterArgs )
%
% rowColVec = fpg_model_function( modelParameters, fitterArgs ) produces a vector of star
%    centroid row and column positions given a vector of focal plane geometry parameters
%    (modelParameters) and a data structure containing the independent variables, mapping
%    information which connects the modelParameters values to the values in the model, and
%    other collateral data.  The vector of output, rowColVec, has the same format and
%    ordering as the measured row and column positions produced by unpack_fpg_options.
%
% See also:  unpack_fpg_options fpg_fitterArgs fpg_constraintPoints.
%
% version date:  2008-May-19.
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
%    2008-may-19, PT:
%        change to use of an external function to update the raDec2PixClass object.
%    2008-May-13, PT:
%        support change in format of fitterArgs.RADecModOut field, see comments in
%        unpack_fpg_options.m for details.
%    2008-Apr-24, PT:
%       new format for geometry parameter map.
%
%=========================================================================================

% in the interest of notational simplicity, copy the raDec2PixClass object from fitterArgs
% to a local variable

  raDec2PixObj = fitterArgs.raDec2PixObject; 
  
% update the geometry parameters in the raDec2PixClass object

  raDec2PixObj = put_geometry_pars_in_raDec2PixObj( modelParameters, raDec2PixObj, ...
      fitterArgs.geometryParMap, fitterArgs.plateScaleParMap ) ;
  
% get the number of cadences from the mjd vector length

  nCadences = length(fitterArgs.mjds) ;
  
% allocate the pointing offsets from the fitter  
  
  dRA   = zeros(nCadences,1) ;
  dDec  = dRA ;
  dRoll = dRA ;
  
% get the mjds in the shape which is safest (row-vector)

  mjds = fitterArgs.mjds(:) ; 
  mjds = mjds' ;
  
% get the pointing offsets from the fitter and put them into arrays for use by
% ra_dec_2_pix_relative:  if the cadenceRAMap value for a cadence is zero, that's the
% reference cadence, so leave it alone, but find the indices into cadenceRAMap of all
% non-zero values
  
  raIndices = find(fitterArgs.cadenceRAMap ~= 0) ;
  
% copy the modelParameters values of the cadence pointing offsets into the local copies
% for ra_dec_2_pix_relative
  
  dRA(raIndices)   = modelParameters(fitterArgs.cadenceRAMap(raIndices))   ;
  dDec(raIndices)  = modelParameters(fitterArgs.cadenceDecMap(raIndices))  ;
  dRoll(raIndices) = modelParameters(fitterArgs.cadenceRollMap(raIndices)) ;
  
% loop over cadences

  rowColVec = zeros(fitterArgs.nConstraintPoints,1) ;
  iEnd = 0 ;
  for iCadence = 1:nCadences
  
%     figure out the indices into rowColVec where the model row and column values should
%     be placed
      
      iStart = iEnd + 1 ;
      iEnd   = iStart + 2*length(fitterArgs.RADecModOut(iCadence).matrix(:,3)) - 1 ;
      
%     get the module and output # expected for the constraint points
  
      mod1 = fitterArgs.RADecModOut(iCadence).matrix(:,3) ;
      out1 = fitterArgs.RADecModOut(iCadence).matrix(:,4) ;
  
%     perform the ra_dec_2_pix call for this cadence  
  
      [mod,out,row,col] = ra_dec_2_pix_relative(raDec2PixObj, fitterArgs.RADecModOut(iCadence).matrix(:,1), ...
                             fitterArgs.RADecModOut(iCadence).matrix(:,2), ...
                             mjds(iCadence), dRA(iCadence), dDec(iCadence), dRoll(iCadence) ) ;
                     
%     if ra_dec_2_pix_relative returned invalid numbers, or thinks that some of the RAs
%     and Decs are on different mod/outs than they are expected to be on, then they
%     constitute bad data; turn them into NaNs so that nlinfit won't try to use them as
%     data!
                     
      row(find(mod ~= mod1)) = NaN ;
      row(find(out ~= out1)) = NaN ;
      col(find(mod ~= mod1)) = NaN ;
      col(find(out ~= out1)) = NaN ;
   
%     assemble and reshape the row and column information 

      rowColVec(iStart:iEnd) = [row ; col] ;
      
  end
  
% and that's it!

%
%
%
