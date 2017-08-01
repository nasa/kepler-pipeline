function fpgDataObject = make_fpg_data_object_with_stars( mjd, raStars, decStars, ...
    modStars, outStars, rowStars, rowStarUncertainties, columnStars, ...
    columnStarUncertainties, raPointing, decPointing, rollPointing )
%
% make_fpg_data_object_with_stars -- construct an fpgDataClass object which is configured
% for performing the FPG fit with star centroids
%
% fpgDataObject = make_fpg_data_object_with_stars( mjd, raStars, decStars, modStars, 
%    outStars, rowStars, rowStarUncertainties, columnStars, columnStarUncertainties,
%    raPointing, decPointing, rollPointing ) constructs an fpgDataClass object in which
%    the fpgFitClass object has been replaced by one which uses user-provided star
%    positions to perform the fit.  Required arguments are as follows:
%
%    mjd:                      scalar, MJD value to be used in the fit
%    raStars:                  vector, RA values of constraint stars in degrees
%    decStars:                 vector, Dec values of constraint stars in degrees
%    modStars:                 vector, CCD module values of constraint stars 
%    outStars:                 vector, CCD output values of constraint stars 
%    rowStars:                 vector, one-based row centroid values of stars
%    rowStarUncertainties:     vector, uncertainties in row centroid values of stars
%    columnStars:              vector, one-based column centroid values of stars
%    columnStarUncertainties:  vector, uncertainties in column centroid values of stars.
%
% Optional arguments are as follows:
%
%    raPointing:    scalar, RA value of spacecraft attitude in degrees
%    decPointing:   scalar, Dec value of spacecraft attitude in degrees
%    rollPointing:  scalar, Roll value of spacecraft attitude in degrees.
%
% The returned fpgDataClass object is configured to perform the FPG fit using the star
%    position data provided by the caller as constraints on the FPG fit, rather than the
%    motion polynomials which are normally used in FPG.  
%
% Note:  at this time, only single-cadence fitting is supported, the user has no control
%    over fitter parameters or options, and no consistency checking or other input
%    validation is performed.  This is an experimental function for use in studying FPG
%    performance.  If it works well, expansion of its capabilities may be possible in the
%    future.
%
% Version date:  2009-July-21.
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
  
% construct a fake set of motion polynomials

  raDec2PixModel = retrieve_ra_dec_2_pix_model() ;
  raDec2PixObject = raDec2PixClass( raDec2PixModel(), 'one-based' ) ;  
  motionPolyRows = [100 300 500 700 900] ;
  motionPolyCols = [100 300 500 700 900] ;
  motionPolynomials = generate_fakedata_motion_polynomials( raDec2PixObject, ...
      mjd - 0.02, 0.04, [0 ; 0 ; 0], motionPolyRows, motionPolyCols, 1e-4, 1 ) ;
  
% get fcConstants

  fcConstants = convert_fc_constants_java_2_struct() ;
 
% set fpgDataStruct values

  mjdLongCadence = mjd ;
  mjdRefCadence = mjd ;
  excludedModules = [] ;
  excludedOutputs = [] ;
  if ( exist('raPointing','var') )
      pointingRefCadence = [raPointing decPointing rollPointing] ;
  else
      pointingRefCadence = [] ;
  end
  fitPointingRefCadence = false ;      
  fitPlateScaleFlag = true ;
  tolX = 1e-8 ;
  tolFun = 2e-2 ;
  tolSigma = 0.5 ;
  doRobustFit = true ;
  reportGenerationEnabled = true ;
  rowGridValues = [300 700] ;
  columnGridValues = [100 700] ;
  
% if we've gotten this far, we can construct the data structure:

  fpgDataStruct.mjdLongCadence = mjdLongCadence ;
  fpgDataStruct.excludedModules = excludedModules ;
  fpgDataStruct.excludedOutputs = excludedOutputs ;
  fpgDataStruct.rowGridValues = rowGridValues ;
  fpgDataStruct.columnGridValues = columnGridValues ;
  fpgDataStruct.mjdRefCadence = mjdRefCadence ;
  fpgDataStruct.pointingRefCadence = pointingRefCadence ;
  fpgDataStruct.fitPointingRefCadence = fitPointingRefCadence ;
  fpgDataStruct.fitPlateScaleFlag = fitPlateScaleFlag ;
  fpgDataStruct.tolX = tolX ;
  fpgDataStruct.tolFun = tolFun ; 
  fpgDataStruct.tolSigma = tolSigma ;
  fpgDataStruct.doRobustFit = doRobustFit ;
  fpgDataStruct.reportGenerationEnabled = reportGenerationEnabled ;
  fpgDataStruct.fcConstants = fcConstants ;
  fpgDataStruct.raDec2PixModel = raDec2PixModel ;
  fpgDataStruct.motionPolynomials = motionPolynomials ;
  
% instantiate the object

  fpgDataObject = fpgDataClass( fpgDataStruct ) ;
  
% generate the fpgFitClass objects

  fpgDataObject = fpg_data_reformat( fpgDataObject ) ;
  
% get the fpgFitClass object out of the fpgDataObject

  fpgFitObject = get( fpgDataObject, 'fpgFitObject' ) ;
  
% Now:  to make FPG work with stars we need to replace the following fpgFitClass member
% fields:  nConstraintPoints, constraintPoints, constraintPointCovariance, raDecModOut.
% Do that now.

  nConstraintPoints = 2 * length(raStars) ;
  constraintPoints = [rowStars(:) ; columnStars(:)] ;
  constraintPointCovariance = sparse( 1:nConstraintPoints, 1:nConstraintPoints, ...
      [rowStarUncertainties(:) ; columnStarUncertainties(:)].^2, ...
      nConstraintPoints, nConstraintPoints ) ;
  raDecModOut.matrix = [raStars(:) decStars(:) modStars(:) outStars(:)] ;
  
  fpgFitStruct = struct(fpgFitObject) ;
  fpgFitStruct.nConstraintPoints = nConstraintPoints ;
  fpgFitStruct.constraintPoints = constraintPoints ;
  fpgFitStruct.constraintPointCovariance = constraintPointCovariance ;
  fpgFitStruct.raDecModOut = raDecModOut ;
  
  
  fpgFitObject = fpgFitClass(fpgFitStruct) ;
  
% re-embed the fpgFitObject in the fpgDataObject
  
  fpgDataStruct = struct(fpgDataObject) ;
  fpgDataStruct.fpgFitObject = fpgFitObject ;
  fpgDataObject = fpgDataClass(fpgDataStruct) ;
  
return

% and that's it!

%
%
%

