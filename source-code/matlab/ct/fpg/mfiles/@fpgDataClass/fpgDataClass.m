function fpgDataObject = fpgDataClass( fpgDataStruct )
%
% fpgDataClass -- class constructor for fpgDataClass.  Takes as its sole argument an
% fpgDataStruct.  The data structure used to instantiate an fpgDataClass object typically
% has the following fields:
%
%           mjdLongCadence:  [double] vector of MJDs of long cadence(s) in the fit
%              excludedModules: [int] vector of module #'s for excluded mod/outs
%              excludedOutputs: [int] vector of output #'s for excluded mod/outs
%             rowGridValues: [double] vector of row positions for forming constraintPoints
%          columnGridValues: [double] vector of column positions for forming 
%                                       constraintPoints
%            mjdRefCadence:  [double] scalar MJD of the reference cadence
%       pointingRefCadence:  [double] vector of the pointing on the ref cadence (optional)
%    fitPointingRefCadence: [logical] fit the pointing of the reference cadence (optional)
%        fitPlateScaleFlag: [logical] flag to indicate plate scale fitting
%                     tolX:  [double] convergence criterion for kepler_nonlinear_fit_soc
%                   tolFun:  [double] convergence criterion for kepler_nonlinear_fit_soc
%                 tolSigma:  [double] convergence criterion for kepler_nonlinear_fit_soc
%         maxBadDataCutoff:  [double] allowed fraction of bad mod/outs in a cadence
%             doRobustFit:  [logical] flag to indicate robust fitting
% reportGenerationEnabled:  [logical] flag for report generation (optional)
%               fcConstants: [struct] focal plane characterization constants
%            raDec2PixModel: [struct] data for instantiation of raDec2PixClass objects
%        motionPolynomials:  [struct] motion polynomials, plus information on them
%
% fpgDataClass adds two additional members, dataStatusMap and fpgFitObject, which are not
% present in the fpgDataStruct.
%
% When running in pipeline as part of PRF, FPG's fpgDataStruct has a different
% organization:
%
%         timestampSeries:  [struct] data structure of timestamps for cadences
%             fcConstants:  [struct] focal plane characterization constants
%     fpgModuleParameters:  [struct] parameters which control the fit operation
%          raDec2PixModel:  [struct] data for instantiation of raDec2PixClass objects
%       motionBlobsStruct:  [struct] motion polynomials in blob form
%
% In this case, the data structure is automatically reformatted to become the one
% described above.
% 
%
% Version date:  2009-January-18.
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
%     2009-January-18, PT:
%         only check values of motion polynomials which have good status.
%     2008-December-20, PT:
%         add support for reportGenerationEnabled flag.
%     2008-December-16, PT:
%         increase maximum allowed value for tolX and tolFun to 0.03.
%     2008-December-14, PT:
%         add support for MJD == 0 for gapped cadences.  Check match between MJD mid-times
%         in timestamp structure and in deblobbed motion polynomials.
%     2008-October-31, PT:
%         add support for cadenceNumbers field in timestampSeries.
%     2008-October-06, PT:
%          change validation of excluded modules / outputs -- validate_structure no longer
%          allows a field's bounds to be checked if the field is empty (which is often the
%          case for excluded modules and outputs).  Moved empty row/column grid values
%          check upstream of value validation for similar reasons.
%     2008-September-19, PT:
%          change row and column limits to one-based.
%     2008-September-18, PT:
%          allow maxBadDataCutoff to be == 1.
%     2008-September-14, PT:
%          add maxBadDataCutoff and support for same.
%     2008-September-05, PT:
%          changes in support of updates in the structure of the pipeline-style input
%          structure and updates in motion polynomial structure.
%     2008-August-01, PT:
%          add support for conversion of pipeline-style fpgDataStruct to
%          interactive-style.  Check to make sure dimensions of motion polynomials are
%          correct.
%     2008-July-30, PT:
%          add support for fitPointingRefCadence field / member.
%     2008-July-25, PT:
%          remove FOV-plotting data from the fpgDataClass!
%     2008-July-24, PT:
%          use reorganize_time_series_for_fpg function to perform time series reformat
%          instead of reorganize_pixelTimeSeries function.
%     2008-July-18, PT:
%          add pointingRefCadence field.  If optional fields are missing, fill them in as
%          empty.
%     2008-july-17, PT:
%          throw an error if the starSkyCoordinates data is present but one or both of
%          the magnitude limits is missing.
%     2008-July-09, PT:
%          update verification of maxMagnitudePlot, minMagnitudePlot, and
%          starSkyCoordinates per updated design of plotting code.  Remove requirement
%          that motionPolynomials have 84 rows.
%     2008-july-08, PT:
%          use truncation to limit validation to considering the first 9 significant
%          digits of mjds.  Remove mjdStartTime and mjdEndTime fields from motion
%          polynomial data structure.
%
%=========================================================================================

% start with verification of the structure and its bits and pieces.  Note that in this
% constructor we will not attempt the following verifications:
%
%     fcConstants:  too much of a pain
%     raDec2PixModel:  gets verified when the raDec2PixClass constructor is called
%     motionPolynomials.rowPoly/colPoly:  here we will verify that the correct fields are
%        present but not attempt to verify their values; that will be done when the
%        row/column polynomials are evaluated to produce the constraintPoints vectors.  To
%        actually figure out whether the polynomials are any good would be too complicated
%        by any method other than evaluating the polynomials.
%     minMagnitudePlot and maxMagnitudePlot:  we will verify that min <= max and that the
%        Kepler Magnitudes in the starSkyCoordinates are within this range, but not that
%        the values of minMagnitudePlot and maxMagnitudePlot make any sense.  

% that said:  if the number of arguments is not 1, blow up

  if (nargin ~= 1)
      error('fpg:fpgDataClass:numInputs',...
          'fpgDataClass:  exactly 1 input argument accepted') ;
  end
  
% check to see whether the fpgDataStruct format is interactive or pipeline, if the latter
% convert it to the former.  We need to look at 2 fields, because the test of the pipeline
% structure will remove 1 field at a time and see whether the constructor produces the
% correct error (so there's no single field which is safe for indicating which structure
% type this is during testing)

  if (isfield(fpgDataStruct,'fpgModuleParameters') || isfield(fpgDataStruct, ...
          'timestampSeries') )
      fpgDataStruct = convert_pipeline_struct_to_interactive( fpgDataStruct ) ;
  end
  
%=========================================================================================
%
% Top-level validation -- I don't use fcConstants here to construct the module list string
% because I haven't validated yet that I have it in the inputs...
%
%=========================================================================================

  
% if the optional fields are not present at all, add them

  if (~isfield(fpgDataStruct,'pointingRefCadence'))
      fpgDataStruct.pointingRefCadence = [] ;
  end
  if (~isfield(fpgDataStruct,'fitPointingRefCadence'))
      fpgDataStruct.fitPointingRefCadence = false ;
  end
  if (~isfield(fpgDataStruct,'maxBadDataCutoff'))
      fpgDataStruct.maxBadDataCutoff = 0.1 ;
  end
  if (~isfield(fpgDataStruct,'reportGenerationEnabled'))
      fpgDataStruct.reportGenerationEnabled = true ;
  end

  
% Since the bounds for some of the values depend on information which is in the
% fpgDataStruct itself, we will have to do the validation in two steps.  This is more
% because the validation tester won't work if we do it in one step than due to any actual
% validation problem.  First we do the bulk of the validation:
  
  fieldsAndBounds = cell(18,4) ;

  fieldsAndBounds(1,: ) = { 'mjdLongCadence' ; '>54500' ; '<58200' ; [] } ; % early 2008 to early 2018
  fieldsAndBounds(2,:)  = { 'excludedModules' ; [] ; [] ; [] } ;
  fieldsAndBounds(3,:)  = { 'excludedOutputs' ; [] ; [] ; [] } ;
  fieldsAndBounds(4,:)  = { 'rowGridValues' ; [] ; [] ; [] } ;
  fieldsAndBounds(5,:)  = { 'columnGridValues' ; [] ; [] ; [] } ;
  fieldsAndBounds(6,:)  = { 'mjdRefCadence' ; [] ; [] ; [] } ;
  fieldsAndBounds(7,:)  = { 'fitPlateScaleFlag' ; [] ; [] ; '[true false]' } ;
  fieldsAndBounds(8,:)  = { 'tolX' ; '>1e-20' ; '<3e-2' ; [] } ;
  fieldsAndBounds(9,:)  = { 'tolFun' ; '>1e-20' ; '<3e-2' ; [] } ;
  fieldsAndBounds(10,:) = { 'tolSigma' ; '>1e-8' ; '<1' ; [] } ;
  fieldsAndBounds(11,:) = { 'doRobustFit' ; [] ; [] ; '[true false]' } ;
  fieldsAndBounds(12,:) = { 'reportGenerationEnabled' ; [] ; [] ; '[true false]' } ;  
  fieldsAndBounds(13,:) = { 'fcConstants' ; [] ; [] ; [] } ;
  fieldsAndBounds(14,:) = { 'raDec2PixModel' ; [] ; [] ; [] } ;
  fieldsAndBounds(15,:) = { 'motionPolynomials' ; [] ; [] ; [] } ;
  fieldsAndBounds(16,:) = { 'pointingRefCadence' ; [] ; [] ; [] } ;
  fieldsAndBounds(17,:) = { 'fitPointingRefCadence' ; [] ; [] ; '[true false]' } ;
  fieldsAndBounds(18,:) = { 'maxBadDataCutoff' ; [] ; [] ; [] } ;
  
  validate_structure( fpgDataStruct, fieldsAndBounds, 'fpgDataStruct' ) ;
  
  clear fieldsAndBounds
  
% neither rowGridValues nor columnGridValues may be empty -- test that now

  if ( isempty(fpgDataStruct.rowGridValues) || isempty(fpgDataStruct.columnGridValues) )
      error('fpg:fpgDataClass:emptyGridValues',...
          'fpgDataClass:  row and/or column grid values are empty') ; 
  end
  

  
% Then we set the allowed values for modules, outputs, and mjdRefCadence based on values
% from fcConstants or from mjdLongCadence -- if either fcConstants or mjdLongCadence is
% missing from the fpgDataStruct then these lines won't work right, so to make validation
% run right we put them after the step which validates the existence of the fcConstants
% and mjdLongCadence fields.  Similarly, we now do value validation of the grid row and
% column values, since they require access to fcConstants.  Truncate the mjd string at 9
% digits precision (nnnnn.mmmm), since 0.0001 of a day = 8.6 seconds, which is shorter
% than even a short cadence (1 minute); this should be fine-grained enough for our
% purposes.  

  mjdTruncation = 9 ;

  validMjdString = ['[',num2str(fpgDataStruct.mjdLongCadence(:)',mjdTruncation),']'] ;
  validModuleString = ['[',num2str(fpgDataStruct.fcConstants.modulesList'),']'] ;
  validOutputString = ['[',num2str(1:fpgDataStruct.fcConstants.nOutputsPerModule),']'] ;
  
  minRow = fpgDataStruct.fcConstants.MASKED_SMEAR_END + 0.5 + 1;
  maxRow = fpgDataStruct.fcConstants.VIRTUAL_SMEAR_START - 0.5 + 1;
  minRowString = ['>=',num2str(minRow)] ;
  maxRowString = ['<=',num2str(maxRow)] ;
  minCol = fpgDataStruct.fcConstants.LEADING_BLACK_END + 0.5 + 1;
  maxCol = fpgDataStruct.fcConstants.TRAILING_BLACK_START - 0.5 + 1;
  minColString = ['>=',num2str(minCol)] ;
  maxColString = ['<=',num2str(maxCol)] ;
  
  fieldsAndBounds = cell(4,4) ;
  
%  fieldsAndBounds(1,:)  = { 'excludedModules' ; [] ; [] ; validModuleString } ;
%  fieldsAndBounds(2,:)  = { 'excludedOutputs' ; [] ; [] ; validOutputString } ;
  fieldsAndBounds(1,:)  = { 'mjdRefCadence' ; [] ; [] ; validMjdString } ;
  fieldsAndBounds(2,:)  = { 'rowGridValues' ; minRowString ; maxRowString ; [] } ;
  fieldsAndBounds(3,:)  = { 'columnGridValues' ; minColString ; maxColString ; [] } ;
  fieldsAndBounds(4,:)  = { 'maxBadDataCutoff' ; '>=0' ; '<=1' ; [] } ;

% since we have truncated the valid mjd string to 9 digits of precision, we need to
% perform the same truncation on values which are used in validation

  mjdLongCadenceTruncated = str2num(num2str(fpgDataStruct.mjdLongCadence,mjdTruncation)) ;
  mjdRefCadenceTruncated = str2num(num2str(fpgDataStruct.mjdRefCadence,mjdTruncation)) ;
  
  mjdLongCadenceOriginal = fpgDataStruct.mjdLongCadence ;
  mjdRefCadenceOriginal  = fpgDataStruct.mjdRefCadence ;
  fpgDataStruct.mjdLongCadence = mjdLongCadenceTruncated ;
  fpgDataStruct.mjdRefCadence = mjdRefCadenceTruncated ;
  
  validate_structure( fpgDataStruct, fieldsAndBounds, 'fpgDataStruct' ) ;
  
  fpgDataStruct.mjdLongCadence = mjdLongCadenceOriginal ;
  fpgDataStruct.mjdRefCadence = mjdRefCadenceOriginal ;  

  clear fieldsAndBounds
  
% validity check for module and output exclusion

  if (~isempty(fpgDataStruct.excludedModules) && ...
          any(~ismember(fpgDataStruct.excludedModules,...
          fpgDataStruct.fcConstants.modulesList)))
      error('fpg:fpgDataClass:invalidModuleNumbers', ...
          'fpgDataClass: invalid CCD module numbers detected') ;
  end
  if (~isempty(fpgDataStruct.excludedOutputs) && ...
          any(~ismember(fpgDataStruct.excludedOutputs,...
          [1:fpgDataStruct.fcConstants.nOutputsPerModule])))
      error('fpg:fpgDataClass:invalidOutputNumbers', ...
          'fpgDataClass: invalid CCD output numbers detected') ;
  end
    
% Dimensioning checks:  the excludedModules and excludedOutput fields must have the same
% length; size(motionPolynomials,2) == length of mjdLongCadence field

  fcConstants = fpgDataStruct.fcConstants ;

  if ( length(fpgDataStruct.excludedModules) ~= length(fpgDataStruct.excludedOutputs) )
      error('fpg:fpgDataClass:excludedModOuts', ...
          'fpgDataClass: # of excluded modules must == number of excluded outputs') ;
  end
  if ( size(fpgDataStruct.motionPolynomials,2) ~= length(fpgDataStruct.mjdLongCadence) )
      error('fpg:fpgDataClass:motionPolynomialsNCadences',...
          'fpgDataClass:  wrong number of cadences in motionPolynomial struct') ;
  end
  
% dimensioning checks:  size(motionPolynomials,1) should be equal to the # of module
% outputs, which can be determined from fcConstants

  nModOuts = fcConstants.MODULE_OUTPUTS ;
  if (size(fpgDataStruct.motionPolynomials,1) ~= nModOuts )
      error('fpg:fpgDataClass:motionPolynomialsNModOuts',...
          'fpgDataClass:  wrong number of module/outputs in motionPolynomial struct') ;
  end
  
% mjdRefCadence must be a scalar, and mjdLongCadence cannot contain any duplicates

  if ( ~isscalar(fpgDataStruct.mjdRefCadence) )
      error('fpg:fpgDataClass:mjdRefCadenceNotScalar', ...
          'fpgDataClass:  member mjdRefCadence is not scalar') ;
  end
  if ( length(unique(fpgDataStruct.mjdLongCadence)) ~= length(fpgDataStruct.mjdLongCadence) )
      error('fpg:fpgDataClass:mjdNotUnique', ...
          'fpgDataClass:  elements of mjdLongCadence member are not unique') ;
  end
  
% find the pointing model for the reference MJD, and compare it to the user-specified
% pointing model.  If the difference in any DOF is greater than 0.1 degrees, throw an
% error (that's a 90-pixel error in pointing)

  pointingObject = pointingClass( fpgDataStruct.raDec2PixModel.pointingModel ) ;
  modelPointingRefCadence = get_pointing( pointingObject, fpgDataStruct.mjdRefCadence ) ;
  if (~isempty(fpgDataStruct.pointingRefCadence))
      deltaPointing = fpgDataStruct.pointingRefCadence(:) - modelPointingRefCadence(:) ;
      if ( max(abs(deltaPointing)) > 0.1 )
          error('fpg:fpgDataClass:invalidPointing', ...
              'fpgDataClass:  pointingRefCadence is > 0.1 degrees from nominal') ;
      end
  end
  
%=========================================================================================
%
% motionPolynomials validation
%
%=========================================================================================

% motionPolynomials is a 2-D array of structures.  We will validate this in a similar
% manner to pixelTimeSeries, via concatenation.  Also like pixelTimeSeries, we will stick
% to validating the fields we need, eg:
%
%     mjdMidTime
%     module
%     output
%     rowPoly
%     rowPolyStatus
%     colPoly
%     colPolyStatus

% validate the existence of the fields of interest -- since motionPolynomials is a 2-D
% array of structures, we can accomplish this by just validating the existence of the
% fields on a single instance of the structure matrix.

  fieldsAndBounds = cell(7,4) ;
  fieldsAndBounds(1,:) = {'mjdMidTime' ; [] ; [] ; [] } ;
  fieldsAndBounds(2,:) = {'module' ; [] ; [] ; [] } ;
  fieldsAndBounds(3,:) = {'output' ; [] ; [] ; [] } ;
  fieldsAndBounds(4,:) = {'rowPoly' ; [] ; [] ; [] } ;
  fieldsAndBounds(5,:) = {'rowPolyStatus' ; [] ; [] ; [] } ;
  fieldsAndBounds(6,:) = {'colPoly' ; [] ; [] ; [] } ;
  fieldsAndBounds(7,:) = {'colPolyStatus' ; [] ; [] ; [] } ;
  
% if the start and end time fields are present, lop them off

  if (isfield(fpgDataStruct.motionPolynomials,'mjdStartTime'))
      fpgDataStruct.motionPolynomials = rmfield(fpgDataStruct.motionPolynomials,...
          'mjdStartTime') ;
  end
  if (isfield(fpgDataStruct.motionPolynomials,'mjdEndTime'))
      fpgDataStruct.motionPolynomials = rmfield(fpgDataStruct.motionPolynomials,...
          'mjdEndTime') ;
  end
  
  validate_structure(fpgDataStruct.motionPolynomials(1), fieldsAndBounds, ...
      'fpgDataStruct.motionPolynomials') ;
  clear fieldsAndBounds ;
  
  motionPolynomials = fpgDataStruct.motionPolynomials(:) ;  
  
% go through the fields one at a time...

% mjdMidTime:  this is used in the mjdLongCadence vector, so we can validate it in the
% same way as mjdReferenceCadence

  mjdMidTime = [motionPolynomials.mjdMidTime] ;
  mjdMidTime = str2num(num2str(mjdMidTime,mjdTruncation)) ;
  fieldsAndBounds = cell(1,4) ;
  fieldsAndBounds(1,:) = {'mjdMidTime' ; [] ; [] ; validMjdString } ;
  
  validate_field(mjdMidTime,fieldsAndBounds,'mjdMidTime') ;
  clear fieldsAndBounds ;
  
  mjdMidTime = reshape(mjdMidTime,size(fpgDataStruct.motionPolynomials)) ;

% the motion polynomial MJDs may not contain any duplicates, either

  if ( length(unique(mjdMidTime(1,:))) ~= length(mjdMidTime(1,:)) )
      error('fpg:fpgDataClass:mjdMotionPolynomialsNotUnique', ...
          'fpgDataClass:  motion polynomial columns have non-unique MJDs') ;
  end  
  
% but each column of motionPolynomials.mjdMidTime must have a single MJD value (ie, all of
% the MJDs for a set of motion polynomials which are supposed to be from one LC have to
% be the same)

  if ( size(unique(mjdMidTime,'rows'),1) ~= 1 )
      error('fpg:fpgDataClass:mjdMotionPolynomialsNotCommon', ...
          'fpgDataClass: motion polynomial columns have non-common MJDs') ;
  end
  
% module:  this can be validated in the same way as the pixelTimeSeries module vector  
  
  module = [motionPolynomials.module] ;
  fieldsAndBounds = cell(1,4) ;
  validModuleString = ['[',num2str(fcConstants.modulesList'),']'] ;
  fieldsAndBounds(1,:) = {'module' ; [] ; [] ; validModuleString } ;
  
  validate_field(module,fieldsAndBounds,'module') ;
  clear fieldsAndBounds ;
  
% output:  this can be validated in the same way as the pixelTimeSeries output vector  

  output = [motionPolynomials.output] ;
  fieldsAndBounds = cell(1,4) ;
  validOutputString = ['[',num2str(1:fcConstants.nOutputsPerModule),']'] ;
  fieldsAndBounds(1,:) = {'output' ; [] ; [] ; validOutputString } ;
  
  validate_field(output,fieldsAndBounds,'output') ;
  clear fieldsAndBounds ;
  
% additional validation of module and output:  The module and output must be unique within
% a cadence, but identical for a given channel across cadences.  To verify that this is
% the case, first convert mod/out to channel and reshape it to match the shape of the
% motion polynomial structure

  channelList = convert_from_module_output( module, output ) ;
  channelList = reshape(channelList,size(fpgDataStruct.motionPolynomials)) ;
  
% Analogously to the mjds, we make sure that the mod/out # is common across cadences
  
  if ( size(unique(channelList','rows'),1) ~= 1 )
      error('fpg:fpgDataClass:MotionPolynomialModOutsNotCommon', ...
          'fpgDataClass: motion polynomial rows have non-common mod/outs') ;
  end
      
% since we now know that each column is identical, we can check that there are no
% duplicate values in column 1 to ensure that there are no duplicates anywhere

  if ( length(unique(channelList(:,1))) ~= length(channelList(:,1)) )
      error('fpg:fpgDataClass:MotionPolynomialModOutsNotUnique', ...
          'fpgDataClass: motion polynomial columns have non-unique mod/outs') ;
  end

% rowPolyStatus and colPolyStatus are doubles

  rowPolyStatus = [motionPolynomials.rowPolyStatus] ;
  fieldsAndBounds = cell(1,4) ;
  fieldsAndBounds(1,:) = {'rowPolyStatus' ; [] ; [] ; '[0 1]' } ;
  
  validate_field(rowPolyStatus,fieldsAndBounds,'rowPolyStatus') ;
  clear fieldsAndBounds ;

  colPolyStatus = [motionPolynomials.colPolyStatus] ;
  fieldsAndBounds = cell(1,4) ;
  fieldsAndBounds(1,:) = {'colPolyStatus' ; [] ; [] ; '[0 1]' } ;
  
  validate_field(colPolyStatus,fieldsAndBounds,'colPolyStatus') ;
  clear fieldsAndBounds ;

% rowPoly and colPoly are weighted 2-D polynomials.  We can use the check_poly2d_struct
% function to make sure that all the polynomials are properly structured and have sensible
% values.  Unfortunately, check_poly2d_struct takes a scalar argument, so we have to loop
% through the motion polynomials to use it.  To simplify the design of the loop, the row
% and column polynomials will be concatenated into a single column vector of motion
% polynomials for the checkout.

  fieldsAndBounds = cell(1,4) ;
  fieldsAndBounds(1,:) = {'type' ; [] ; [] ; {'standard'} } ;
      
  nMotionPoly = length(motionPolynomials) ;
  rowPoly = [motionPolynomials.rowPoly] ;
  colPoly = [motionPolynomials.colPoly] ;
  rowColPoly = [rowPoly ; colPoly] ;
  rowPolyStatus = [motionPolynomials.rowPolyStatus] ;
  colPolyStatus = [motionPolynomials.colPolyStatus] ;
  rowColPolyStatus = [rowPolyStatus ; colPolyStatus] ;
  
  for iPoly = 1:2*nMotionPoly
      
      if ( iPoly < nMotionPoly )
          mnemonic = 'rowPoly' ;
      else
          mnemonic = 'colPoly' ;
      end
      
% we also check to make sure the polynomial type is 'standard.'  The check-struct function
% can't do this because the valid types 'legendre' and 'not_scaled' are not acceptable
% here.

      validate_structure( rowColPoly(iPoly), fieldsAndBounds, ...
          ['fpgDataStruct.motionPolynomials.',mnemonic]) ;

      if ( rowColPolyStatus(iPoly) )
          check_poly2d_struct( rowColPoly(iPoly), mnemonic ) ;
      end
      
      
  end
  

  
%=========================================================================================
%
% END OF VALIDATION, HURRAY!
%
%=========================================================================================

% There are two fields which are in the fpgDataClass which are not in the fpgDataStruct
% because they get constructed by fpgDataClass methods; add those to the fpgDataStruct
% now.  Note that if this class constructor is called with a data structure which has
% those fields instantiated, that's okay as well.

  if (~isfield(fpgDataStruct,'dataStatusMap'))
      fpgDataStruct.dataStatusMap = [] ;
  end
  if (~isfield(fpgDataStruct,'fpgFitObject'))
      fpgDataStruct.fpgFitObject = [] ;
  end
  
% if the pointing on the reference cadence is empty, fill it in with the value from the
% pointing model

  if (isempty(fpgDataStruct.pointingRefCadence))
      fpgDataStruct.pointingRefCadence = modelPointingRefCadence ;
  end
  
% put the fields of fpgDataStruct into a fixed order, so that any order of fields in
% fpgDataStruct can be used to instantiate fpgDataClass objects

  fpgDataStruct = orderfields(fpgDataStruct, ...
      {'mjdLongCadence','excludedModules','excludedOutputs','rowGridValues', ...
       'columnGridValues','mjdRefCadence','pointingRefCadence','fitPointingRefCadence',...
       'fitPlateScaleFlag','tolX','tolFun','tolSigma','maxBadDataCutoff','doRobustFit',...
       'reportGenerationEnabled', ...
       'fcConstants','raDec2PixModel','motionPolynomials','dataStatusMap','fpgFitObject'}) ;
  
% perform an orderfields on the fcConstants and motionPolynomials structures for a similar
% benefit.  We dare not touch the order of the raDec2PixModel fields, lest the
% raDec2PixClass constructor barf on field order.  While we're at it, strip the
% mjdStartTime and mjdEndTime out of the motion polynomial structure.

  fpgDataStruct.fcConstants = orderfields(fpgDataStruct.fcConstants) ;
  
  if (isfield(fpgDataStruct.motionPolynomials,'mjdStartTime'))
      fpgDataStruct.motionPolynomials = rmfield(fpgDataStruct.motionPolynomials,...
          'mjdStartTime') ;
  end
  if (isfield(fpgDataStruct.motionPolynomials,'mjdEndTime'))
      fpgDataStruct.motionPolynomials = rmfield(fpgDataStruct.motionPolynomials,...
          'mjdEndTime') ;
  end
  fpgDataStruct.motionPolynomials = orderfields(fpgDataStruct.motionPolynomials, ...
      {'cadence','mjdMidTime','module','output','rowPoly','rowPolyStatus','colPoly',...
      'colPolyStatus'}) ;
  
% OK, enough monkeying around -- instantiate the class for return to the caller!

  fpgDataObject = class( fpgDataStruct, 'fpgDataClass' ) ;
  
% and that's it!

%
%
%

%=========================================================================================

% function which converts the pipeline-format input structure to an interactive-style
% structure

function fpgDataStructOut = convert_pipeline_struct_to_interactive( fpgDataStructIn ) 

% first of all, we need to make sure that the necessary fields are all present in the
% structure and all its sub-structures; this we will do with validate_structure calls.  We
% won't attempt to validate any of their values, since that gets done after conversion to
% an interactive structure.

  fieldsAndBounds = cell(6,4) ;
  fieldsAndBounds(1,:) = { 'timestampSeries' ; [] ; [] ; [] } ;
  fieldsAndBounds(2,:) = { 'fcConstants' ; [] ; [] ; [] } ;
  fieldsAndBounds(3,:) = { 'fpgModuleParameters' ; [] ; [] ; [] } ;
  fieldsAndBounds(4,:) = { 'raDec2PixModel' ; [] ; [] ; [] } ;
  fieldsAndBounds(5,:) = { 'motionBlobsStruct' ; [] ; [] ; [] } ;
  fieldsAndBounds(6,:) = { 'geometryBlobFileName' ; [] ; [] ; [] } ;
  validate_structure(fpgDataStructIn, fieldsAndBounds, 'fpgDataStruct:pipeline') ;
  clear fieldsAndBounds
  
% the geometryBlobFileName has to be either a string (ie, char vector), or an empty
  
  geometryBlobFileName = fpgDataStructIn.geometryBlobFileName ;
  if ~isempty(geometryBlobFileName) 
      if (~ischar(geometryBlobFileName) | ~isvector(geometryBlobFileName) )
          error('fpg:fpgDataClass:geometryBlobFileNameInvalid', ...
              'fpgDataClass: geometryBlobFileName must be a char vector or empty') ;
      end
  end
  
% now for the timestampSeries structure -- FPG doesn't use all the fields, but they all
% have to be there to allow the read/write functions to work properly, so we'll check to
% make sure that they are present

  fieldsAndBounds = cell(6,4) ;
  fieldsAndBounds(1,:) = { 'startTimestamps' ; [] ; [] ; [] } ;
  fieldsAndBounds(2,:) = { 'midTimestamps' ; [] ; [] ; [] } ;
  fieldsAndBounds(3,:) = { 'endTimestamps' ; [] ; [] ; [] } ;
  fieldsAndBounds(4,:) = { 'gapIndicators' ; [] ; [] ; [] } ;
  fieldsAndBounds(5,:) = { 'requantEnabled' ; [] ; [] ; [] } ;
  fieldsAndBounds(6,:) = { 'cadenceNumbers' ; [] ; [] ; [] } ;
  validate_structure(fpgDataStructIn.timestampSeries, fieldsAndBounds, ...
      'fpgDataStruct.timestampSeries') ;
  clear fieldsAndBounds
  
% Since we are going to actually use this information, we need to do a bit of validation:
% the midTimeStamps and gapIndicators must be the same length, and vectors, and the latter
% must be logicals

  if ( ~isvector(fpgDataStructIn.timestampSeries.midTimestamps) || ...
       ~isvector(fpgDataStructIn.timestampSeries.gapIndicators) || ...
        length(fpgDataStructIn.timestampSeries.midTimestamps) ~= ...
           length(fpgDataStructIn.timestampSeries.gapIndicators) )
       error('fpg:fpgDataClass:timestampSeriesDimensions', ...
           'fpgDataClass:  timestampSeries midTimeStamps and/or gapIndicators are wrong size/shape') ;
  end
  if ( ~islogical(fpgDataStructIn.timestampSeries.gapIndicators) )
      error('fpg:fpgDataClass:gapIndicatorsIllogical', ...
          'fpgDataClass:  gapIndicators field not logicals') ;
  end
  
% the timestampSeries cadenceNumbers must be a vector, must be in monotonic-increasing
% order, and each value must be unique

  cadenceNumbers = fpgDataStructIn.timestampSeries.cadenceNumbers ;
  if ( ~isvector(cadenceNumbers)          || ...
        ~isequal(unique(cadenceNumbers),cadenceNumbers) )
      error('fpg:fpgDataClass:cadenceNumbersIllFormed', ...
          'fpgDataClass:  cadenceNumbers field of timestampSeries must be a monotonic, unique vector') ;
  end   
  
% now we know the # of cadences, both the total and the # which is gapped
  
  nCadencesTotal = length(fpgDataStructIn.timestampSeries.midTimestamps) ;
  nCadencesGapped = length(find(fpgDataStructIn.timestampSeries.gapIndicators)) ;
  nCadencesGood = nCadencesTotal - nCadencesGapped ;

% now do the fpgModuleParameters -- this is pretty simple, since these values are just
% copied over to the interactive structure

  validRefCadenceList = -1:nCadencesTotal-1 ;
  validRefCadenceString = ['[',num2str(validRefCadenceList),']'] ;
  fieldsAndBounds = cell(13,4) ;
  fieldsAndBounds(1,:) = { 'rowGridValues' ; [] ; [] ; [] } ;
  fieldsAndBounds(2,:) = { 'columnGridValues' ; [] ; [] ; [] } ;
  fieldsAndBounds(3,:) = { 'fitPlateScaleFlag' ; [] ; [] ; [] } ;
  fieldsAndBounds(4,:) = { 'tolX' ; [] ; [] ; [] } ;
  fieldsAndBounds(5,:) = { 'tolFun' ; [] ; [] ; [] } ;
  fieldsAndBounds(6,:) = { 'tolSigma' ; [] ; [] ; [] } ;
  fieldsAndBounds(7,:) = { 'doRobustFit' ; [] ; [] ; [] } ;
  fieldsAndBounds(8,:) = { 'reportGenerationEnabled' ; [] ; [] ; [] } ;
  fieldsAndBounds(9,:) = { 'pointingRefCadence' ; [] ; [] ; [] } ;
  fieldsAndBounds(10,:) = { 'usePointingModel' ; [] ; [] ; [] } ;
  fieldsAndBounds(11,:) = { 'fitPointingRefCadence' ; [] ; [] ; [] } ;
  fieldsAndBounds(12,:) = { 'referenceCadence' ; [] ; [] ; validRefCadenceString } ;
  fieldsAndBounds(13,:) = { 'maxBadDataCutoff' ; [] ; [] ; [] } ;
  validate_structure(fpgDataStructIn.fpgModuleParameters, fieldsAndBounds, ...
      'fpgDataStruct.fpgModuleParameters') ;
  clear fieldsAndBounds
  
% the one parameter out of this set which we use is usePointingModel, which is a scalar
% logical -- check that now

  if ( ~isscalar(fpgDataStructIn.fpgModuleParameters.usePointingModel) || ...
          ~islogical(fpgDataStructIn.fpgModuleParameters.usePointingModel) )
      error('fpg:fpgDataClass:usePointingModelImproper', ...
          'fpgDataClass: usePointingModel field not a logical scalar') ;
  end

% no detailed validation of motionBlobsStruct is needed because it will be taken care of
% when the blobSeriesClass objects are instantiated

% With that out of the way -- transforming the structure!
%
% Start with the easy parameters, the ones which simply copy over from the input structure
% to the output structure

  fpgDataStructOut.rowGridValues = fpgDataStructIn.fpgModuleParameters.rowGridValues ;
  fpgDataStructOut.columnGridValues = fpgDataStructIn.fpgModuleParameters.columnGridValues ;
  fpgDataStructOut.fitPlateScaleFlag = fpgDataStructIn.fpgModuleParameters.fitPlateScaleFlag ;
  fpgDataStructOut.tolX = fpgDataStructIn.fpgModuleParameters.tolX ;
  fpgDataStructOut.tolFun = fpgDataStructIn.fpgModuleParameters.tolFun ;
  fpgDataStructOut.tolSigma = fpgDataStructIn.fpgModuleParameters.tolSigma ;
  fpgDataStructOut.maxBadDataCutoff = fpgDataStructIn.fpgModuleParameters.maxBadDataCutoff ;
  fpgDataStructOut.doRobustFit = fpgDataStructIn.fpgModuleParameters.doRobustFit ;
  fpgDataStructOut.reportGenerationEnabled = ...
      fpgDataStructIn.fpgModuleParameters.reportGenerationEnabled ;
  fpgDataStructOut.fitPointingRefCadence = ...
      fpgDataStructIn.fpgModuleParameters.fitPointingRefCadence ;
  fpgDataStructOut.fcConstants = fpgDataStructIn.fcConstants ;
  fpgDataStructOut.raDec2PixModel = fpgDataStructIn.raDec2PixModel ;
  
% if we're supposed to get a geometry model from a blob, get it now

  if (~isempty(geometryBlobFileName))
      geometryModel = single_blob_to_struct(geometryBlobFileName) ;
      fpgDataStructOut.raDec2PixModel.geometryModel = geometryModel ;
  end
  
  if (fpgDataStructIn.fpgModuleParameters.usePointingModel)
      fpgDataStructOut.pointingRefCadence = [] ;
  else
      fpgDataStructOut.pointingRefCadence = ...
          fpgDataStructIn.fpgModuleParameters.pointingRefCadence ;
  end
  
% since the timestamps for motion-contaminated cadences are missing from the structure,
% and since FPG is expecting unique and appropriate MJDs for the missing cadences, fill in
% the MJD values for those cadences now

  fpgDataStructIn.timestampSeries = fill_missing_timestamps( ...
      fpgDataStructIn.timestampSeries ) ;
  
% get the cadence MJDs from the timestampSeries structure

  mjdLongCadence = fpgDataStructIn.timestampSeries.midTimestamps ;
  
% use the reference cadence, if specified, to determine the MJD of the reference cadence;
% if it's a gapped cadence, throw an error.

  referenceCadence = fpgDataStructIn.fpgModuleParameters.referenceCadence + 1 ; % convert to one-based
  if (referenceCadence == 0)                                % default to first cadence
      referenceCadence = 1 ;
  end
  if (fpgDataStructIn.timestampSeries.gapIndicators(referenceCadence))
      error('fpg:fpgDataClass:referenceCadenceIsGapped', ...
          'fpgDataClass:  the selected reference cadence is gapped') ;
  end
  
  mjdRefCadence = mjdLongCadence(referenceCadence) ;

% put the cadence MJDs and the MJD of the ref cadence into the pipeline-style data
% structure.  Note that we are including both good cadences and gapped ones at this point
  
  fpgDataStructOut.mjdLongCadence = mjdLongCadence ;
  fpgDataStructOut.mjdRefCadence = mjdRefCadence ;
  
% Motion polynomial blob expansion:  
%
% start by dimensioning the data structure -- the # of columns equals the number of
% mod/outs, the # of rows equals the total number of cadences (including gapped cadences).
% We'll use a motion polynomial structure selected more or less at random to get the
% fields of the structure set correctly.

  nModOuts = fpgDataStructOut.fcConstants.nModules * ...
             fpgDataStructOut.fcConstants.nOutputsPerModule ;
  blobSeriesObject = blobSeriesClass(fpgDataStructIn.motionBlobsStruct(1)) ;
  sampleMotionPolyStruct = get_struct_for_cadence(blobSeriesObject,referenceCadence) ;
  sampleMotionPolyStruct = sampleMotionPolyStruct.struct(1) ;
  mp(nModOuts,nCadencesTotal) = sampleMotionPolyStruct ;
  
% set the sample structure's status fields to bad, and assign every slot in mp to be equal
% to sampleMotionPolyStruct; that way, every mod/out on every cadence will default to bad
% status

  sampleMotionPolyStruct.rowPolyStatus = 0 ;
  sampleMotionPolyStruct.colPolyStatus = 0 ;
  mp(:,:) = sampleMotionPolyStruct ;
  
% set every entry in mp to have the correct cadence times -- this is necessary because, if
% there are not 84 mod/outs worth of data in motionBlobsStruct, some of the columns in mp
% will not be filled with data in the loop below, and the data validation process inspects
% the timestamps.  Similarly, set all the module and output values now, so that any mp
% slots which aren't filled will have the correct module and output numbers for the
% validator

  for iCadence = 1:nCadencesTotal
      for iModOut = 1:nModOuts
          [module,output] = convert_to_module_output(iModOut) ;
          mp(iModOut,iCadence).mjdMidTime = ...
              fpgDataStructIn.timestampSeries.midTimestamps(iCadence) ;
          mp(iModOut,iCadence).mjdStartTime = ...
              fpgDataStructIn.timestampSeries.startTimestamps(iCadence) ;
          mp(iModOut,iCadence).mjdEndTime = ...
              fpgDataStructIn.timestampSeries.endTimestamps(iCadence) ;
          mp(iModOut,iCadence).module = module ;
          mp(iModOut,iCadence).output = output ;
      end
  end
  
% figure out how many mod/outs worth of data are included in the structure

  nModOutsData = length(fpgDataStructIn.motionBlobsStruct) ;
  
% loop over module outputs

  for iModOut = 1:nModOutsData
      
%     make a blob series object of the relevant blob, and get the motion polynomials for
%     all the cadences (good ones and gapped ones); find the channel # from the module and
%     output of the blobSeries

      blobSeriesObject = blobSeriesClass(fpgDataStructIn.motionBlobsStruct(iModOut)) ;
      motionPolyStruct = get_struct_for_cadence(blobSeriesObject,[1:nCadencesTotal]) ;
      module = motionPolyStruct(1).struct(1).module ;
      output = motionPolyStruct(1).struct(1).output ;
      channel = convert_from_module_output(module,output) ;
      
%     loop over cadences and select the correct motion polynomial for each cadence slot in
%     the motion polynomial structure, considering only the ungapped cadences; this is
%     determined by looking at the timestamps of the motion polynomials and comparing to
%     the timestamp from the timestamp series.

      for iCadence = 1:nCadencesTotal
          
          if (~fpgDataStructIn.timestampSeries.gapIndicators(iCadence))
              
              mjdCadence = fpgDataStructIn.timestampSeries.midTimestamps(iCadence) ;
              mpMidTimes = [motionPolyStruct(iCadence).struct.mjdMidTime] ;
              mpIndex = find(mpMidTimes == mjdCadence) ;
              if (length(mpIndex) ~= 1)
                  error('fpg:fpgDataClass:illFormedMotionPolynomial', ...
                      ['fpgDataClass: no motion polynomial with module = ', ...
                      num2str(module), ', output = ',num2str(output), ...
                      ', MJD mid-time = ',num2str(mjdCadence)]) ;
              end
              mp(channel,iCadence) = motionPolyStruct(iCadence).struct(mpIndex) ;
              
         end
          
      end % loop over cadences
      
  end % loop over module outputs
  
  fpgDataStructOut.motionPolynomials = mp ;
  
% the excluded modules are empties, since there is no provision to pass them in the inputs
% in pipeline operation

  fpgDataStructOut.excludedModules = [] ;
  fpgDataStructOut.excludedOutputs = [] ;
  
% and that's it!

%
%
%
      
%=========================================================================================

% function which fills in the timestamps of cadences which are missing; also, it checks
% that the afflicted cadences are all marked as gapped, and errors if this is not the case

function timestampSeriesOut = fill_missing_timestamps( timestampSeriesIn )

  timestampSeriesOut = timestampSeriesIn ;
  
% find the locations of the unhappy timestamps in the structure

  badStartIndex = find(timestampSeriesIn.startTimestamps == 0) ;
  badMidIndex   = find(timestampSeriesIn.midTimestamps == 0) ;
  badEndIndex   = find(timestampSeriesIn.endTimestamps == 0) ;
  gapIndex      = find(timestampSeriesIn.gapIndicators == true) ;
  
% make sure that the unhappy timestamps are in agreement with one another

  if ( ~isequal(badStartIndex,badMidIndex) || (~isequal(badStartIndex,badEndIndex)) )
      error('fpg:fpgDataClass:zeroTimestampsInconsistent', ...
          'fpgDataClass:  inconsistency in zero timestamps between start, mid, end MJDs') ;
  end
  
% continue only if there are unhappy timestamps

  if ( ~isempty(badMidIndex) )
      
%     check to see that all unhappy timestamps go to gapped cadences

      if ( ~ismember(badMidIndex,gapIndex) )
          error('fpg:fpgDataClass:gapIndicatorsInconsistent', ...
              'fpgDataClass:  inconsistency between gap indicators and zero timestamps') ;
      end
      
%     Since the cadences are monotonic and roughly equal in duration, we can use linear
%     interpolation to fill in the missing values

      goodMidIndex = find(timestampSeriesIn.midTimestamps ~= 0) ;
      goodCadences = timestampSeriesIn.cadenceNumbers(goodMidIndex) ;
      badCadences  = timestampSeriesIn.cadenceNumbers(badMidIndex) ;
      
      timestampSeriesOut.startTimestamps(badMidIndex) = interp1( goodCadences, ...
          timestampSeriesOut.startTimestamps(goodMidIndex), badCadences, ...
          'linear', 'extrap' ) ;
      
      timestampSeriesOut.midTimestamps(badMidIndex) = interp1( goodCadences, ...
          timestampSeriesOut.midTimestamps(goodMidIndex), badCadences, ...
          'linear', 'extrap' ) ;
      
      timestampSeriesOut.endTimestamps(badMidIndex) = interp1( goodCadences, ...
          timestampSeriesOut.endTimestamps(goodMidIndex), badCadences, ...
          'linear', 'extrap' ) ;

  end % condition on emptiness of midBadIndex