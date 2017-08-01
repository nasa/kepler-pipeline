function rd2poFakedata = make_raDec2PixClass_fakedata_object( dRow, dCol, dRot, dPlate, ...
    raDec2PixModel)
%
% make_raDec2PixClass_fakedata_object -- construct an raDec2PixClass object which can be
% used to generate fakedata for FPG testing.
%
% rd2poFakedata = make_raDec2PixClass_fakedata_object( dRow, dCol, dRot, dPlate, 
%    raDec2PixModel ) returns an raDec2PixClass object which incorporates focal plane
%    geometry errors.  The geometry errors are parameterized by the 4 arguments of the
%    function:
%
%        dRow:  maximum misalignments in row space of each CCD; misalignments are
%               generated via a uniform random number generator.  Dimensions of dRow are
%               pixels.
%
%        dCol:  maximum misalignments in column space of each CCD; misalignments are
%               generated via a uniform random number generator.  Dimensions of dCol are
%               pixels.
%
%        dRot:  maximum rotation of each CCD; misalignments are generated via a uniform 
%               random number generator.  Dimensions of dRot are degrees.
%
%        dPlate:  fractional error in plate scale.  The dPlate is directly applied to the
%                 focal plane (ie, no random number generation is involved).  dPlate is
%                 dimensionless.
%
% version date:  2008-December-30.
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
%     2008-December-30, PT:
%         use mjdStart field of raDec2PixModel as mjd for calculations.
%     2008-September-19, PT:
%         support for one-based calculation instead of zero-based.
%     2008-August-04, PT:
%         take out the mean value of the errors in row, column, and rotation (a mean error
%         in the row, column, or rotation is really a small error in the spacecraft
%         attitude, where the mean pointing of the CCDs defines the attitude).
%
%=========================================================================================

% construct an raDec2PixClass object from the model

  rd2po0 = raDec2PixClass(raDec2PixModel,'one-based') ;
  
% select for the calculations the start MJD of the model

  mjd = raDec2PixModel.mjdStart ;

% The user is asked for misalignments in row, column, and rotation angle, but the
% raDec2PixClass object uses Euler angles.  So we can start by making a Jacobian which
% relates the two, at the approximate location of the center of each CCD.

  centerRow = raDec2PixModel.nMaskedSmear + raDec2PixModel.nRowsImaging / 2 + 0.5 ;
  centerColumn = raDec2PixModel.nLeadingBlack + raDec2PixModel.nColsImaging + 0.5 ;
  
  module = repmat([2:4 6:20 22:24],2,1) ; module = module(:) ;
  output = repmat([1 ; 3],21,1) ;
  
% relate the change in pointing, in degrees, to the change in CCD position, in pixels:  
  
  dAngleOverDPix = raDec2PixModel.geometryModel.constants(1).array(336) / 3600 ;
  dTheta = 0.001 * dAngleOverDPix ;
  
% of course, what we really have access to is how the row and column change as a function
% of the Euler angles in the raDec2Pix, which is the inverse of the Jacobian we want.  So
% build up the Jacobian which goes from 3-2-1 to row-col-rotation, and invert it!

  invJacobian = eye(126) ;
  
  for iChannel = 1:length(module)
      
%     get pointers to the 3 and 2 angles in the geometry model      
      
      i3 = 3*(iChannel-1) + 1 ;
      i2 = 3*(iChannel-1) + 2 ;
      
      iRow = i3 ; iCol = i2 ;
      
%     get the RA and Dec of the CCD center coordinates
 
      [ra,dec] = pix_2_ra_dec(rd2po0,module(iChannel), output(iChannel),...
          centerRow, centerColumn, mjd) ;
      
%     tweak the 3 angle and then the 2 angle by an amount small compared to a pixel
      
      rd2po1 = twiddle_geometry( rd2po0, i3, dTheta ) ;
      [m,o,r,c] = ra_dec_2_pix(rd2po1, ra, dec, mjd ) ;
      
%     convert the column to the correct column on the CCD

      dc = convert_to_ccd_column(o,c,'one-based') - centerColumn ;
      dr = r - centerRow ;
      
      invJacobian(iRow,i3) = dr/dTheta ;
      invJacobian(iCol,i3) = dc/dTheta ;
      
      rd2po1 = twiddle_geometry( rd2po0, i2, dTheta ) ;
      [m,o,r,c] = ra_dec_2_pix(rd2po1, ra, dec, mjd ) ;
      
%     convert the column to the correct column on the CCD

      dc = convert_to_ccd_column(o,c,'one-based') - centerColumn ;
      dr = r - centerRow ;
      
      invJacobian(iRow,i2) = dr/dTheta ;
      invJacobian(iCol,i2) = dc/dTheta ;
      
  end % loop over channels
  
% now construct the Jacobian

  jacobian = inv(invJacobian) ;
  
% construct the vector of random misalignments in row, column, and rotation space

  rowRandVector = dRow * (2 * rand(1,42) - 1) ;
  colRandVector = dCol * (2 * rand(1,42) - 1) ;
  rotRandVector = dRot * (2 * rand(1,42) - 1) ;
    
  randVector = [rowRandVector ; colRandVector ; rotRandVector] ;
  randVector = randVector(:) ;
  
% convert to a vector of 3-2-1 transformations

  dEuler = jacobian * randVector ;

% take out the mean values of the 3, 2 and 1 transformation angles -- this involves a
% couple of reshapings along the way

  dEuler = reshape(dEuler,3,42) ;
  dEuler(1,:) = dEuler(1,:) - mean(dEuler(1,:)) ;
  dEuler(2,:) = dEuler(2,:) - mean(dEuler(2,:)) ;
  dEuler(3,:) = dEuler(3,:) - mean(dEuler(3,:)) ;

  % add the plate scale change

  dGeometry = [dEuler(:) ; dPlate * raDec2PixModel.geometryModel.constants(1).array(336)] ;
  
% make a vector of indices

  indexVector = [1:126 336] ; indexVector = indexVector(:) ;
  
% make the new geometry

  rd2poFakedata = twiddle_geometry( rd2po0, indexVector, dGeometry ) ;
  
% and that's it!

%
%
%
  
%=========================================================================================

% function which changes one of the geometry parameters in an raDec2PixClass object and
% returns it

function rd2po1 = twiddle_geometry( rd2po0, index, value )

  gm = get(rd2po0, 'geometryModel') ;
  for iIndex = 1:length(index)
      if (index(iIndex) < 253)
          gm.constants(1).array(index(iIndex)) = gm.constants(1).array(index(iIndex)) + ...
              value(iIndex) ;
      else
           gm.constants(1).array(253:336) = gm.constants(1).array(index(iIndex)) + ...
               value(iIndex) ;
      end
  end
 
  for iGm = 2:length(gm.constants)
      gm.constants(iGm) = gm.constants(1) ;
  end
  rd2po1 = set(rd2po0,'geometryModel',gm) ;
  
% and that's it!

%
%
%

  