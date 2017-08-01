function modelVector = model_function( fpgFitObject, modelParameters )
%
% MODEL_FUNCTION -- compute the model value of a set of constraint points for Focal Point
% Geometry fitting.
%
% modelVector = model_function( fpgFitObject, modelParameters ) is a method of the
%    fpgFitClass Matlab class.  It takes as its arguments an object of the fpgFitClass and
%    a vector of model parameter values, and returns a vector of model values which can be
%    compared to the values in the constraintPoints method.  
%
% Version date:  2009-April-23.
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
%     2009-April-23, PT:
%         support for pincushion parameter fitting.
%     2008-July-30, PT:
%         support for fitting of the pointing on the reference cadence.
%     2008-July-18, PT:
%         support user-specified pointing for the reference cadence.
%     2008-July-08, PT:
%         move put_geometry_pars_in_raDec2PixObject into a private helper method, from
%         being a function in this file (the functionality is needed by other methods).
%
%=========================================================================================

% first step:  update the geometry parameters in raDec2PixObject with the parameter values
% in the modelParameters vector

  fpgFitObject.raDec2PixObject = put_geometry_pars_in_raDec2PixObject( modelParameters, ...
      fpgFitObject.raDec2PixObject, fpgFitObject.geometryParMap, ...
      fpgFitObject.plateScaleParMap, fpgFitObject.pincushionScaleFactor ) ;
  
% get the # of cadences from the length of the MJD vector

  nCadences = length(fpgFitObject.mjd) ;
  
% allocate the cadence-by-cadence pointing offsets 

  dRA   = zeros(nCadences,1) ;
  dDec  = dRA ;
  dRoll = dRA ;
  
% get the pointing of the reference cadence

  raRefCadence = fpgFitObject.pointingRefCadence(1) ;
  decRefCadence = fpgFitObject.pointingRefCadence(2) ;
  rollRefCadence = fpgFitObject.pointingRefCadence(3) ;
  
% get the pointing offsets from the fitter and put them into arrays for use by
% ra_dec_2_pix_relative:  if the cadenceRAMap value for a cadence is zero, that's the
% reference cadence, so leave it alone, but find the indices into cadenceRAMap of all
% non-zero values
  
  raIndices = find(fpgFitObject.cadenceRAMap ~= 0) ;
  
% copy the modelParameters values of the cadence pointing offsets into the local copies
% for ra_dec_2_pix_relative
  
  dRA(raIndices)   = modelParameters(fpgFitObject.cadenceRAMap(raIndices))   ;
  dDec(raIndices)  = modelParameters(fpgFitObject.cadenceDecMap(raIndices))  ;
  dRoll(raIndices) = modelParameters(fpgFitObject.cadenceRollMap(raIndices)) ;
  
% construct the model vector as a column vector with the correct # of values, and then
% start looping over cadences 

  modelVector = zeros(fpgFitObject.nConstraintPoints,1) ;
  iEnd = 0 ;
  for iCadence = 1:nCadences
  
%     figure out the indices into modelVector where the model row and column values should
%     be placed
      
      iStart = iEnd + 1 ;
      iEnd   = iStart + 2*length(fpgFitObject.raDecModOut(iCadence).matrix(:,3)) - 1 ;

%     get the module and output # expected for the constraint points
  
      mod1 = fpgFitObject.raDecModOut(iCadence).matrix(:,3) ;
      out1 = fpgFitObject.raDecModOut(iCadence).matrix(:,4) ;
      
%     perform the ra_dec_2_pix call for this cadence  
  
      [mod,out,row,col] = ra_dec_2_pix_absolute(fpgFitObject.raDec2PixObject, ...
          fpgFitObject.raDecModOut(iCadence).matrix(:,1), ...
          fpgFitObject.raDecModOut(iCadence).matrix(:,2), ...
          fpgFitObject.mjd(iCadence), ...
          dRA(iCadence)+raRefCadence, ...
          dDec(iCadence)+decRefCadence, ...
          dRoll(iCadence)+rollRefCadence ) ;
                         
%     if ra_dec_2_pix_relative returned invalid numbers, or thinks that some of the RAs
%     and Decs are on different mod/outs than they are expected to be on, then they
%     constitute bad data; turn them into NaNs so that nlinfit won't try to use them as
%     data!
                     
      row(find(mod ~= mod1)) = NaN ;
      row(find(out ~= out1)) = NaN ;
      col(find(mod ~= mod1)) = NaN ;
      col(find(out ~= out1)) = NaN ;
   
%     assemble and reshape the row and column information 

      modelVector(iStart:iEnd) = [row ; col] ;
      
  end

% if the reference cadence is getting its attitude fitted, then there are the 3
% constraints on the CCD angles which have to be taken care of; do that now 
%
% The nature of the constraint set is as follows:
%   ->the mean of the CCD 3 angles should be zero (nonzero indicates that the 3 angles are
%     being used to take out some net pointing error in the direction of the 3 angles)
%   ->the mean of the CCD 2 angles should be zero (similar reasoning as for the 3 angles,
%     above)
%   ->the mean difference between the rotation angles of the CCD and the rotation angle in
%     the original model should be zero (nonzero indicates that the rotation angles of the
%     CCD are being used to take out some rotation of the FOV wrt the original model).
  
  if ( ~isempty(fpgFitObject.ccdsForPointingConstraint) )
      nConstraintPoints = fpgFitObject.nConstraintPoints ;
      [angle3Indices, angle2Indices, angle1Indices] = find_allowed_angle_indices( ...
          fpgFitObject.ccdsForPointingConstraint, ...
          fpgFitObject.geometryParMap) ;
      angle3 = modelParameters(angle3Indices) ; 
      angle2 = modelParameters(angle2Indices) ;
      angle1 = modelParameters(angle1Indices) - fpgFitObject.initialParValues(angle1Indices) ;
      modelVector(nConstraintPoints-2) = mean(angle3) ;
      modelVector(nConstraintPoints-1) = mean(angle2) ;
      modelVector(nConstraintPoints  ) = mean(angle1) ;
  end
  
% and that's it!

%
%
%

%=========================================================================================

% function for determination of acceptable CCD angles to use in the constraint, and
% conversion to indexing into the modelParameters vector

function [angle3Indices, angle2Indices, angle1Indices] = find_allowed_angle_indices( ...
          ccdsForPointingConstraint, geometryParMap) 

% first, set up to use all the 3 angles, all the 2 angles, and all the 1 angles

  angle3Indices = 1:3:126 ; 
  angle2Indices = 2:3:126 ;
  angle1Indices = 3:3:126 ;
  
% now just use the ones which are included based on the ccdsForPointingConstraint vector

  angle3Indices = angle3Indices(ccdsForPointingConstraint) ;
  angle2Indices = angle2Indices(ccdsForPointingConstraint) ;
  angle1Indices = angle1Indices(ccdsForPointingConstraint) ;
  
% now, that tells me which parameters in a geometryModel.constants vector I want, but not
% which parameters in the modelParameters vector!  To get those, we use the geometry
% parameter map

  angle3Indices = geometryParMap(angle3Indices) ;
  angle2Indices = geometryParMap(angle2Indices) ;
  angle1Indices = geometryParMap(angle1Indices) ;
  
  
