function fpgDataObject = fpg_data_reformat(fpgDataObject)
%
% fpg_data_reformat -- prepare an fpgDataClass object for fitting by reorganizing its
% data.
%
% fpgDataObject = fpg_data_reformat(fpgDataObject) performs the necessary rearrangment of
%    data in an fpgDataClass object that prepares the object for fitting.  During this
%    process the fpgFitObject member of the fpgDataObject is instantiated, and the
%    dataStatusMap member is populated.  The amount of data is checked in order to ensure
%    that enough data is going to be available to perform the fit as requested.
%
% Version date:  2009-May02.
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
%     2009-May-02, PT:
%         support for fitting 1 plate scale / pincushion parameter per CCD.
%     2009-April-23, PT:
%         support for pincushion parameter fits.  Switch to use of the final
%         geometryModel.constants array to get the initial parameter values.
%     2008-December-17, PT:
%         add use of convSigma convergence criterion for non-robust fits (only the last
%         and next-to-last fit get this).
%     2008-December-15, PT:
%         change Display option for robust fit to 'time'.
%     2008-September-14, PT:
%         change raDec2PixClass objects to be one-based.
%     2008-September-14, PT:
%         support for maxBadDataCutoff parameter.  Throw error if user requested fit of
%         the ref cadence pointing and it can't be done.  Throw error if a cadence's
%         pointing can't be fit because there are no good channels in overlap between the
%         reference cadence and the cadence in question.
%     2008-July-30, PT:
%         support for fitting the pointing of the reference cadence, if requested
%     2008-July-18, PT:
%         Use data object's value of the reference pointing to get RAs and Decs of
%         constraint values.
%     2008-July-09, PT:
%         manage the case in which motion polynomials are out of order or incomplete.
%
%=========================================================================================

% instantiate the raDec2PixClass object from the caller

  raDec2PixObject = raDec2PixClass( fpgDataObject.raDec2PixModel, 'one-based' ) ;
  
% sort the motion polynomial structure and the mjdLongCadence members such that the
% reference cadence is first, and all other cadences are in their current order

  fpgDataObject = make_reference_cadence_first( fpgDataObject ) ;
  
% manage the case in which motion polynomials are out of order or incomplete

  fpgDataObject = complete_and_sort_motion_polynomials( fpgDataObject ) ;
  
% populate the data status map from the motion polynomial status values

  fpgDataObject.dataStatusMap = get_data_status_map( fpgDataObject.motionPolynomials ) ;
  
% identify and remove cadences which have too many bad channels; throw an error if the
% reference cadence is removed; get a set of local variables which have been purged of bad
% cadences

  [motionPolynomials, dataStatusMap, badCadences, mjdLongCadence] = ...
      remove_bad_cadences( fpgDataObject ) ;

% set the good mod/outs on bad cadences to a value of 0.5 so they show up as medium grey
% on the final display

  fpgDataObject.dataStatusMap(:,badCadences) = fpgDataObject.dataStatusMap(:,badCadences) ...
      / 2 ;
  
% construct the grid of nominal row and column positions for the constraint points, using
% the rowGridValues and columnGridValues members

  [constraintRow, constraintColumn] = ndgrid(fpgDataObject.rowGridValues, ...
                                             fpgDataObject.columnGridValues ) ;
  constraintRow = constraintRow(:) ;
  constraintColumn = constraintColumn(:) ;
  
% identify channels which are bad on the reference cadence, and channels which
% are bad on all cadences -- these channels must be handled with special care in
% the fits

  badChannelsRefCadence  = find_bad_channels( dataStatusMap(:,1) ) ;
  badChannelsAllCadences = find_bad_channels( dataStatusMap ) ;
  
% convert the grid of nominal row/column positions to RA and Dec positions for each
% mod/out.  The idea here is just to get a set of RAs and Decs which should fall about
% where we expect them to on each mod/out.

  constraintRA = zeros(length(constraintRow),...
      fpgDataObject.fcConstants.nModules * fpgDataObject.fcConstants.nOutputsPerModule) ;
  constraintDec = zeros(size(constraintRA)) ;
  onesVec = ones(length(constraintRow),1) ;

  for iMod = fpgDataObject.fcConstants.modulesList'
      for iOut = fpgDataObject.fcConstants.outputsList'
          iChannel = convert_from_module_output(iMod,iOut) ;
          [constraintRA(:,iChannel), constraintDec(:,iChannel)] = ...
              pix_2_ra_dec_absolute(raDec2PixObject, iMod*onesVec, iOut*onesVec, ...
              constraintRow, constraintColumn, fpgDataObject.mjdRefCadence, ...
              fpgDataObject.pointingRefCadence(1), fpgDataObject.pointingRefCadence(2),...
              fpgDataObject.pointingRefCadence(3)) ;
      end
  end

%=========================================================================================
%
% fpgFitClass object instantiation
%
%=========================================================================================

% start with the first fit, which uses the reference cadence to fit the focal plane
% geometry.  If this is the only fit, then set its robust flag based on the user request,
% otherwise set it to false

  fitGeometry = true ;
  fitPointing = fpgDataObject.fitPointingRefCadence ;
  nCadencesTotal = length(mjdLongCadence) ;
  if (nCadencesTotal > 1)
      robustFit = false ;
  else
      robustFit = fpgDataObject.doRobustFit ;
  end

  fpgFitObject1 = make_fpgFitClass_object( fpgDataObject,  ...
      motionPolynomials(:,1), fpgDataObject.fitPlateScaleFlag, fitGeometry, fitPointing, ...
      robustFit, constraintRA, constraintDec, badChannelsRefCadence, dataStatusMap(:,1) ) ;

% if there's only 1 cadence in the fit, then we are done and can put fpgFitObject1 into
% the fpgDataObject...

  if (nCadencesTotal == 1)
      
      fpgDataObject.fpgFitObject = fpgFitObject1 ;
      
  else
      
%     if there's more than 1, then we should instantiate the final fit object, which is
%     the all-included fit.  This fit should use the convSigma condition whether it is
%     robust or not.

      fitPointing = [double(fpgDataObject.fitPointingRefCadence) ; ones(nCadencesTotal-1,1)] ; 
      fitPointing = logical(fitPointing) ;
      robustFit = fpgDataObject.doRobustFit ;

      fpgFitObjectFinal = make_fpgFitClass_object( fpgDataObject, ...
          motionPolynomials, fpgDataObject.fitPlateScaleFlag, ...
          fitGeometry, fitPointing, robustFit, constraintRA, constraintDec, ...
          badChannelsAllCadences, dataStatusMap, 1 ) ;
      
%     now -- IF the fit is robust, AND the set of geometry parameters fitted in the
%     reference cadence are different from the ones in the final fit, THEN we need to do a
%     preceding fit which is the same as the final fit but non-robust.  It should also
%     make use of the convSigma convergence criterion.  Set that up now.

      geometry1     = get(fpgFitObject1,'geometryParMap') ;
      geometryFinal = get(fpgFitObjectFinal,'geometryParMap') ;
      
      if ( (robustFit) && (length(find(geometry1~=0)) ~= length(find(geometryFinal~=0))) )
          
          robustFit = false ;
          nFitsTotal = nCadencesTotal + 2 ;
          
          fpgFitObjectNextToFinal = make_fpgFitClass_object( fpgDataObject, ...
              motionPolynomials, fpgDataObject.fitPlateScaleFlag, ...
              fitGeometry, fitPointing, robustFit, constraintRA, constraintDec, ...
              badChannelsAllCadences, dataStatusMap, 1 ) ;
          
      else
          
          nFitsTotal = nCadencesTotal + 1 ;
          fpgFitObjectNextToFinal = fpgFitClass ;
          
      end
      
%     construct the vector of fpgFitObjects, and plug the ones we have into the relevant
%     slots

      fpgFitObjectVector(nFitsTotal)   = fpgFitClass(fpgFitObjectFinal) ;
      fpgFitObjectVector(nFitsTotal-1) = fpgFitObjectNextToFinal ;
      fpgFitObjectVector(1)            = fpgFitObject1 ;
      
%     construct the rest of the fit objects -- these have no geometry fitting, only
%     pointing fitting on the appropriate cadence

      fitGeometry = false ;
      for iCadence = 2:nCadencesTotal
          
          robustFit = false ;
          fitPlateScaleFlag = false ;
          fitPointing = true ;
 
          fpgFitObjectVector(iCadence) = make_fpgFitClass_object( fpgDataObject, ...
              motionPolynomials(:,iCadence), fitPlateScaleFlag, ...
              fitGeometry, fitPointing, robustFit, constraintRA, constraintDec, ...
              badChannelsRefCadence, dataStatusMap(:,iCadence) ) ;
          
      end
      
%     testing -- make the last cadence use a convsigma conditional
      
      fpgDataObject.fpgFitObject = fpgFitObjectVector ;
      
  end % conditional on # of cadences
  
% and that's it!

%
%
%

%=========================================================================================
%=========================================================================================
%=========================================================================================

% function which puts the data from the reference cadence first in the mjdLongCadence
% vector and the motion polynomial data structure, and makes sure that the motion
% polynomial data structure is sorted to match the MJD vector.

function fpgDataObject = make_reference_cadence_first( fpgDataObject )

% find the ref cadence MJD in the MJD vector and move it to the front of the line -- we
% don't need to worry about not finding the reference MJD, or finding it more than once,
% since those issues are handled at validation time

  mjdSize = size(fpgDataObject.mjdLongCadence) ;
  refCadenceIndex   = find(fpgDataObject.mjdLongCadence == fpgDataObject.mjdRefCadence) ;
  otherCadenceIndex = find(fpgDataObject.mjdLongCadence ~= fpgDataObject.mjdRefCadence) ;
  otherCadences = fpgDataObject.mjdLongCadence(otherCadenceIndex) ;
  
  mjdLongCadence = [fpgDataObject.mjdLongCadence(refCadenceIndex) ; otherCadences(:)] ;
  fpgDataObject.mjdLongCadence = reshape(mjdLongCadence,mjdSize) ;
  
% Now we put the motion polynomials into the same order as the mjdLongCadence vector.

  mjdMotionPolynomials = [fpgDataObject.motionPolynomials(1,:).mjdMidTime] ;
  [mjdMPSort,mjdMPSortKey] = sort(mjdMotionPolynomials) ;
  [mjdSort,mjdSortKey] = sort(fpgDataObject.mjdLongCadence) ;
  
  motionPolynomials = fpgDataObject.motionPolynomials ;
  
  motionPolynomials(:,mjdSortKey) = fpgDataObject.motionPolynomials(:,mjdMPSortKey) ;
  
  fpgDataObject.motionPolynomials = motionPolynomials ;
  
% and that's it!

%
%
%
 
%=========================================================================================

% function which sorts the motion polynomials into mod/out order, and inserts null motion
% polynomials if there are any mod/outs missing from the data structure

function fpgDataObject = complete_and_sort_motion_polynomials( fpgDataObject )

% allocate a structure with the correct dimensions -- nrows == # of channels, ncols == #
% of cadences

  nCadences = size(fpgDataObject.motionPolynomials,2) ;
  nChannelsMax = fpgDataObject.fcConstants.nModules * ...
      fpgDataObject.fcConstants.nOutputsPerModule ;

  mp(nChannelsMax,nCadences) = fpgDataObject.motionPolynomials(1,1) ;
  
% figure out which channels are present and which are not

  includedModList = [fpgDataObject.motionPolynomials(:,1).module] ;
  includedOutList = [fpgDataObject.motionPolynomials(:,1).output] ;
  
  includedChannels = convert_from_module_output( includedModList, includedOutList ) ;
    
% get a list of excluded channels -- note that the function which gets an included list
% from an excluded list can also get an excluded list from an included list!

  [excludedChannels,excludedCCDs] = get_included_channels( includedChannels, ...
    2, nChannelsMax ) ;

% copy the good data into the correct slots in the new structure

  mp(includedChannels,:) = fpgDataObject.motionPolynomials(1:length(includedChannels),:) ;
  
% In filling in the gaps in the motion polynomial data structure, we need to be careful:
% if the object is turned into a structure that somebody wants to later turn back into an
% object, the mjdMidTime, module, and output will be checked, and the fields of the 2-d
% weighted polynomials will be checked as well; so those fields need to be right.  The
% easiest way to make sure that this is done correctly is to take the first row of the old
% motionPolynomials structure, copy it into any row which is currently empty in the new
% structure (so that the MJDs and row/col poly fields will be right), then go back and set
% the module, output, and status flags in an inner loop.

  dummyMP = fpgDataObject.motionPolynomials(1,:) ;
  
  for iChannel = excludedChannels(:)'
      
      mp(iChannel,:) = dummyMP ;
      for iCadence = 1:nCadences
          [mp(iChannel,iCadence).module, mp(iChannel,iCadence).output] = ...
              convert_to_module_output( iChannel ) ;
          mp(iChannel,iCadence).rowPolyStatus = false ;
          mp(iChannel,iCadence).colPolyStatus = false ;
      end
      
  end
  
% assign the new structure to replace the old one in the object

  fpgDataObject.motionPolynomials = mp ;

% and that's it!

%
%
%

%=========================================================================================

% function which populates the data status map from the status values of the individual
% motion polynomials

function dataStatusMap = get_data_status_map( motionPolynomials )
   
% extract the row and column status information for all cadences

  rowPolyStatus = [motionPolynomials.rowPolyStatus] ;
  colPolyStatus = [motionPolynomials.colPolyStatus] ;
  rowPolyStatus = reshape(rowPolyStatus,size(motionPolynomials)) ;
  colPolyStatus = reshape(colPolyStatus,size(motionPolynomials)) ;
  
% determine the datasets which have good status -- to have good status, both the row
% status and the column status for that channel on that cadence must be good
  
  dataStatusMap = rowPolyStatus & colPolyStatus ;
  
% convert to real values, since we eventually color in the "good but unused" data with
% another color on the displays...

  dataStatusMap = double(dataStatusMap) ;
    
% and that's it!

%
%
%

%=========================================================================================

% function which returns local variables which are purged of their bad cadences.  If the
% reference cadence proves to be bad, an error is thrown.

function [motionPolynomials, dataStatusMap, badCadences, mjdLongCadence] = ...
    remove_bad_cadences( fpgDataObject ) 

% get the total # of mod/outs, and for each cadence get the # of good mod/outs

  nModOut = fpgDataObject.fcConstants.nModules * fpgDataObject.fcConstants.nOutputsPerModule ;
  nGoodModOuts = sum(fpgDataObject.dataStatusMap) ;
  
% the cadence is good if it has a sufficient fraction of good channels, based on the
% maxBadDataCutoff parameter.  Note that there has to be at least 1 good channel no
% matter wht the value of maxBadDataCutoff!

  minGoodDataCutoff = 1 - fpgDataObject.maxBadDataCutoff ;
  nModOutCutoff = ceil(nModOut * minGoodDataCutoff) ;
  nModOutCutoff = max([1 nModOutCutoff]) ;

  goodCadences = find(nGoodModOuts >= nModOutCutoff) ; 
  badCadences  = find(nGoodModOuts <  nModOutCutoff) ;

% if the first (reference) cadence is bad, error out

  if (~isempty(find(badCadences==1)))
      error('fpg:fpgDataReformat:badRefCadence',...
          'fpg_data_reformat:  reference cadence has insufficient good data') ;
  end

% construct local variables which omit the bad cadences

  motionPolynomials = fpgDataObject.motionPolynomials(:,goodCadences) ;
  dataStatusMap = fpgDataObject.dataStatusMap(:,goodCadences) ;
  mjdLongCadence = [motionPolynomials(1,:).mjdMidTime] ;
  
% and that's it!

%
%
%

%=========================================================================================

% function which identifies bad channels from a data status map -- a bad channel is one
% which has no data on any cadence

function badChannels = find_bad_channels( dataStatusMap )

% take a row--wise sum of the data status map if there's more than one cadence;
% if only one cadence, then no need for a sum

  if (size(dataStatusMap,2) == 1)
      dSMSum = dataStatusMap ;
  else
      dSMSum = sum(dataStatusMap') ;
  end

% the bad channels are the ones which have zero good status out of all the cadences

  badChannels = find(dSMSum == 0) ;

% and that's it!

% 
%
%

%=========================================================================================

% function which constructs proper fpgFitClass objects based on the data in the
% fpgDataObject and parameters which select the overall behavior of the object; it is
% assumed that the caller has set the dimensions of motionPolynomials, fitPointing, and
% dataStatusMap so that they are consistent with one another.

function fpgFitObject = make_fpgFitClass_object( fpgDataObject, motionPolynomials, ...
    fitPlateScaleFlag, fitGeometry, fitPointing, robustFit, constraintRA, constraintDec, ...
    badChannels, dataStatusMap, convSigma ) 

% convSigma is optional -- it indicates whether the convergence criterion based on the
% change in parameters, normalized to sigma, should be used.  This parameter is
% automatically used for robust fits, but can also be used for non-robust ones based on
% the flag value.

  if (nargin == 10)
      convSigma = 0 ;
  end

% set the total # of cadences in the fit, and get the mjds

  nCadences = size(dataStatusMap,2) ;
  mjdList = [motionPolynomials(1,:).mjdMidTime] ;
  mjdList = mjdList(:)' ;
  
% convert the list of excluded modules and outputs to a list of excluded channels

  excludedChannels = convert_from_module_output( fpgDataObject.excludedModules, ...
      fpgDataObject.excludedOutputs ) ;
  
% construct a list of channels which are left out on all cadences from the bad channels
% and the excluded channels

  excludedChannelsAllCadences = unique([excludedChannels(:)' badChannels(:)']) ;
  
% use the list above and the cadence-by-cadence information in the data status map to
% construct an overall map of which channels are to be left out on each cadence, and of
% how many bad channels there are on each cadence

  badChannelsByCadence(nCadences).array = [] ;
  nBadChannelsByCadence = zeros(nCadences,1) ;
  for iCadence = 1:nCadences
      badChannelsByCadence(iCadence).array = find_bad_channels(dataStatusMap(:,iCadence)) ;
      badChannelsByCadence(iCadence).array = unique([badChannelsByCadence(iCadence).array(:)' ...
          excludedChannelsAllCadences(:)']) ;
      nBadChannelsByCadence(iCadence) = length(badChannelsByCadence(iCadence).array) ;
  end

% the total number of channels in the fit is the # of channels in the focal plane * the
% number of cadences minus the total number of excluded channels counting over all
% cadences

  nChannels = fpgDataObject.fcConstants.nModules * fpgDataObject.fcConstants.nOutputsPerModule ;
  nChannelsTotal = nChannels * nCadences - sum(nBadChannelsByCadence) ;
  nCCDs = nChannels / 2 ; 
  
% if we can't use any of the mod/outs, then throw an error

  if (nChannelsTotal == 0)
      error('fpg:fpgDataReformat:noModOutsInFit', ...
          'fpg_data_reformat:  no good module/outputs in fit') ;
  end
  
% get the # of constraint points per channel from the size of the constraintRA matrix

  nPointsPerChannel = size(constraintRA,1) ;

% construct the vector of constraint points and the matrix of covariances -- these are the
% results of putting the RA and Dec values computed above through the motion polynomials
% for the correct cadence and mod/out.  

  nConstraintPoints = 2 * nPointsPerChannel * nChannelsTotal ;

  if ( fitGeometry && fitPointing(1) )
      nConstraintPoints = nConstraintPoints + 3 ;
      extraFlag = true ;
  else
      extraFlag = false ;
  end
  constraintPoints = zeros(nConstraintPoints,1) ;
  
% use a sparse matrix for the covariance.  Note that at this point we are only using the
% diagonal, so in principle a vector could be used here.  However, we want to preserve the
% option to later revert to using a correlated error matrix, so we use a sparse matrix
% instead of a vector.

  covariance = allocate_sparse_covariance_fpg( nChannelsTotal, nPointsPerChannel, ...
      extraFlag ) ;
  
%=========================================================================================
%
% Fill constraintPoints and covariance matrices with data!
%
%=========================================================================================
 
  raDecModOut(nCadences).matrix = 0 ;
  conStart = 1 ;
  for iCadence = 1:nCadences

%     first step -- figure out which channels and which CCDs we are going to be using,
%     and convert to modules and outputs

      [includedChannels,includedCCDs] = get_included_channels( ...
          badChannelsByCadence(iCadence).array, nPointsPerChannel, nChannels ) ; 
      [includedMods,includedOuts] = convert_to_module_output( includedChannels ) ;
      
%     capture the RA, Dec, module and output information on each cadence to
%     a matrix in the raDecModOut structure

      raDecModOut(iCadence).matrix = zeros(length(includedChannels)*nPointsPerChannel,4) ;
      constraintRAThisCadence  = constraintRA(:,includedChannels) ;
      constraintDecThisCadence = constraintDec(:,includedChannels) ; 
      raDecModOut(iCadence).matrix(:,1) = constraintRAThisCadence(:) ;
      raDecModOut(iCadence).matrix(:,2) = constraintDecThisCadence(:) ;
      for iChannel = 1:length(includedChannels)
          chanStart = nPointsPerChannel * (iChannel-1) + 1 ;
          chanEnd   = chanStart + nPointsPerChannel - 1 ;
          raDecModOut(iCadence).matrix(chanStart:chanEnd,3) = ...
              repmat(includedMods(iChannel),nPointsPerChannel,1) ;
          raDecModOut(iCadence).matrix(chanStart:chanEnd,4) = ...
              repmat(includedOuts(iChannel),nPointsPerChannel,1) ;
      end
      
%     evaluate the motion polynomials to get constraint values for row and column, and to
%     get the covariance values

      for iChannel = includedChannels(:)' 
          
          [rowPolyRow,rowPolySig] = weighted_polyval2d( ...
               constraintRA(:,iChannel), constraintDec(:,iChannel), ...
               motionPolynomials(iChannel,iCadence).rowPoly) ;
          conEnd = conStart + length(rowPolyRow) - 1 ;
          constraintPoints(conStart:conEnd) = rowPolyRow ;
          covariance(conStart:conEnd, conStart:conEnd) = diag(rowPolySig.^2) ; 
          conStart = 1+conEnd ;
          
      end

      for iChannel = includedChannels(:)' 
          
          [colPolyCol,colPolySig] = weighted_polyval2d( ...
              constraintRA(:,iChannel), constraintDec(:,iChannel), ...
             motionPolynomials(iChannel,iCadence).colPoly) ;
          conEnd = conStart + length(colPolyCol) - 1 ;
          constraintPoints(conStart:conEnd) = colPolyCol ;
          covariance(conStart:conEnd, conStart:conEnd) = diag(colPolySig.^2) ; 
          conStart = 1+conEnd ;
          
      end 
      
  end % loop over cadences
  
% if the geometry is fitted AND the reference cadence pointing is fitted, then we need
% additional constraints to break the degeneracy between moving the pointing and
% systematically moving the CCDs.  The constraints themselves are described in the
% comments of the model_function method of fpgFitClass.  The constraints are that moving
% the RA and Dec angles of the pointing off of their correct values should have the same
% effect as changing the "3" or "2" angles of all the CCDs systematically, and changing
% the rotation angle of the pointing from its correct value should have the same effect as
% rotating the FOV (again, moving all the CCDs systematically).  Since each of those moves
% impacts, on average, half the constraintPoints, and changing the attitude only impacts
% the 3 degeneracy-breaking constraints, they need to be weighted much more heavily than
% the constraint points which are actual points on the CCDs.  Also, figure out which CCDs
% are to be used to evaluate the constraints.
  
  if ( fitGeometry && fitPointing(1) )
      constraintPoints(nConstraintPoints-2:nConstraintPoints) = 0 ;
      nConstraintPointsRefCadence = size(raDecModOut(1).matrix,1) ;
      sigma2 = diag(covariance) ;
      meanSigma2 = 1/mean(1./sigma2(1:2*nConstraintPointsRefCadence)) ;
      plateScale = fpgDataObject.raDec2PixModel.geometryModel.constants(1).array(336) / 3600 ;
      raSigma2 = meanSigma2 * plateScale^2 / nConstraintPointsRefCadence ;
      decSigma2 = raSigma2 ;
      approxFovRadius = 5000 ; % radius of FOV in pixels
      rollSigma2 = meanSigma2 / nConstraintPointsRefCadence / (approxFovRadius^2/3) ;
      covariance(nConstraintPoints-2,nConstraintPoints-2) = raSigma2 ;
      covariance(nConstraintPoints-1,nConstraintPoints-1) = decSigma2 ;
      covariance(nConstraintPoints  ,nConstraintPoints  ) = rollSigma2 ;
      [includedChannels,includedCCDs] = get_included_channels( ...
          badChannelsByCadence(1).array, nPointsPerChannel, nChannels ) ; 
      ccdsForPointingConstraint = get_ccds_for_pointing_constraint( includedCCDs ) ;
      if (isempty(ccdsForPointingConstraint))
          error('fpg:fpgDataReformat:ccdsForPointingConstraintEmpty', ...
              'fpg_data_reformat:  unable to fit pointing on ref cadence') ;
      end
  else
      ccdsForPointingConstraint = [] ;
  end
  
%=========================================================================================
%
% Construct parameter maps!
%
%=========================================================================================

% construct a map which relates the parameters in the parameter vector to their locations
% in the geometry model.  For this, the included channels and CCDs are the ones which are
% included on any cadence, so we should only exclude the ones which the user excluded from
% all cadences and which are bad on all cadences.

  [includedChannels,includedCCDs] = get_included_channels( excludedChannelsAllCadences, ...
      nPointsPerChannel, nChannels ) ; 
  [includedMods,includedOuts] = convert_to_module_output( includedChannels ) ;
  geometryParMap = zeros(3*nCCDs,1) ;
  if (fitGeometry) 
      for iCCD = 0:length(includedCCDs)-1
          ccdNum = includedCCDs(iCCD+1)-1 ;
          geometryParMap(3*ccdNum+1:3*ccdNum+3) = 3*iCCD+1:3*iCCD+3 ;
      end
      nGeomPars = length(includedCCDs) * 3 ;
  else
      nGeomPars = 0 ;
  end

% set the identity of the parameters which hold the plate scales, if desired; if the plate
% scales are fitted, so are the pincushion parameters.  There is 1 parameter fitted per
% CCD

  plateScaleParMap = zeros(nCCDs,2) ;
  nIncludedCCDs = length(includedCCDs) ;
  if (fitPlateScaleFlag)
      plateScaleParMap(includedCCDs,1) = (1:nIncludedCCDs) + nGeomPars ;
      plateScaleParMap(includedCCDs,2) = (1:nIncludedCCDs) + length(includedCCDs) ...
          +nGeomPars ;
      nPars = nGeomPars + 2*length(includedCCDs) ;
  else
      nPars = nGeomPars ;
  end
  
% set up the map between fit parameters and RA, Dec, Roll errors 

  cadenceRAMap  = zeros(length(find(fitPointing~=0)),1) ;
  cadenceDecMap  = cadenceRAMap ;
  cadenceRollMap = cadenceRAMap ;
  
  for iCadence = 1:nCadences
      if (fitPointing(iCadence))
          cadenceRAMap(iCadence) = nPars + 1 ;
          cadenceDecMap(iCadence) = nPars + 2 ;
          cadenceRollMap(iCadence) = nPars + 3 ;
          nPars = nPars + 3 ;
      end
  end
  
% get the initial values of all the parameters -- basically, the current geometry model,
% plate scale, and pincushion ; zeros for the current estimate of the orientation error on
% the non-reference cadences.  While we're at it, instantiate the raDec2PixObject.  Note
% that since the pincushion parameter has a very different scale from the other parameters
% (it is typically around 1e-11 or 1e-10), the Jacobian calculation will be somewhat
% unhappy unless this parameter is scaled; so we will scale it by a factor of 1e12 to make
% it comparable in scale to the rest of the parameters.  

  initialParValues = zeros(nPars,1) ;
  pincushionScaleFactor = 1e12 ; 
  
  raDec2PixObject = raDec2PixClass(fpgDataObject.raDec2PixModel, 'one-based') ;
  geometryModel = get(raDec2PixObject,'geometryModel') ;
  nonZeroIndices = find(geometryParMap ~= 0) ;
  initialParValues(1:length(nonZeroIndices)) = ...
      geometryModel.constants(end).array(nonZeroIndices) ;

% If the plate scales / pincushions are fitted, then there is 1 per CCD, but the data is
% stored in the geometry model as 1 per mod/out; so here we pick up every other value
  
  plateScaleParMapToFit = find(plateScaleParMap(:,1)~=0) ;
  plateScalePars = plateScaleParMap(plateScaleParMapToFit,1) ;
  pincushionPars = plateScaleParMap(plateScaleParMapToFit,2) ;
  if (~isempty(plateScaleParMapToFit))
       initialParValues(plateScalePars) = ...
           geometryModel.constants(end).array(252 + plateScaleParMapToFit*2) ;
       initialParValues(pincushionPars) = ...
           geometryModel.constants(end).array(336 + plateScaleParMapToFit*2) * ...
           pincushionScaleFactor ;
  end

%=========================================================================================
%
% Construct options structure!
%
%=========================================================================================
  
% this is basically just a call to the kepler_set_soc function -- set the convergence
% parameters, set it to treat a NaN or Inf as missing information, and if requested set
% robust fitting and its convergence parameter.  The user can also request that the
% convergence tolerance based on # of sigmas variation from one iteration to the next be
% incorporated, and that is handled here.

  if (~robustFit)

      fitterOptions = kepler_set_soc('TolX', fpgDataObject.tolX, 'TolFun', ...
          fpgDataObject.tolFun, 'FunValCheck','off', 'Display', 'off' ) ;
      
  else
      
      fitterOptions = kepler_set_soc('TolX', fpgDataObject.tolX, 'TolFun', ...
          fpgDataObject.tolFun, 'FunValCheck','off', 'Robust','on','convSigma', ...
          fpgDataObject.tolSigma, 'Display', 'time' ) ;
      
  end
  
  if (convSigma == 1)
      fitterOptions = kepler_set_soc(fitterOptions, 'convSigma', fpgDataObject.tolSigma) ;
  end

%=========================================================================================
%
% instantiate fpgFitClass object!
%
%=========================================================================================

% start by constructing the necessary data structure

  fpgFitStruct.raDec2PixObject = raDec2PixObject ;
  fpgFitStruct.mjd = mjdList ;
  fpgFitStruct.geometryParMap = geometryParMap ;
  fpgFitStruct.plateScaleParMap = plateScaleParMap ;
  fpgFitStruct.cadenceRAMap = cadenceRAMap ;
  fpgFitStruct.cadenceDecMap = cadenceDecMap ;
  fpgFitStruct.cadenceRollMap = cadenceRollMap ;
  fpgFitStruct.nConstraintPoints = nConstraintPoints ;
  fpgFitStruct.constraintPoints = constraintPoints ;
  fpgFitStruct.constraintPointCovariance = covariance ;
  fpgFitStruct.initialParValues = initialParValues ;
  fpgFitStruct.raDecModOut = raDecModOut ;
  fpgFitStruct.fitterOptions = fitterOptions ;
  fpgFitStruct.pointingRefCadence = fpgDataObject.pointingRefCadence ;
  fpgFitStruct.ccdsForPointingConstraint = ccdsForPointingConstraint ;
  fpgFitStruct.pincushionScaleFactor = pincushionScaleFactor ;
  
% call the constructor

  fpgFitObject = fpgFitClass(fpgFitStruct) ;
  
% and that's it!

%
%
%

%=========================================================================================
%=========================================================================================
%=========================================================================================

% allocate a sparse covariance matrix for a system with a known number of channels,
% cadences, and points per channel per cadence

function  covariance = allocate_sparse_covariance_fpg(nChannelTotal,nPoint, extraFlag)

% the covariance matrix is a block-diagonal, with blocks of size nPoint x nPoint.  The
% number of elements is nPoint * nPoint * 2(rows and columns) * nChannelTotal.
% Allocate some arrays to hold that now

  nNonZero = nPoint^2 * 2 * nChannelTotal ;
  
% if we need to constrain the attitude solution on the reference cadence, put in space for
% that here
  
  if (extraFlag)
      nNonZero = nNonZero + 3 ;
  end
  iVec = zeros(nNonZero,1) ; jVec = iVec ; sVec = iVec ; 
  
% the non-sparse dimension of the matrix is square, with nrow = nPoint * 2 * nChannel *
% nCadence, plus 3 extra rows if the ref cadence pointing fit is constrained, and ncol == 
% nrow.

  m = nPoint * 2 * nChannelTotal ; 
  if (extraFlag)
      m = m + 3 ;
  end
  n = m ; 
  
% the basic unit of the matrix is the nPoint x nPoint grid.  Generate indices for that now

  [iUnit,jUnit] = ndgrid([1:nPoint], [1:nPoint]) ;
  iUnit = iUnit(:) ; jUnit = jUnit(:) ;
  nUnit = length(iUnit) ;
  
% assign the i and j vectors 

  for iBlock = 1:(2*nChannelTotal)
      istart = nUnit*(iBlock-1)+1 ;
      istop  = istart + nUnit - 1 ;
      iVec(istart:istop) = iUnit ;
      jVec(istart:istop) = jUnit ;
      iUnit = iUnit + nPoint ;
      jUnit = jUnit + nPoint ;
  end
  
% if extra space is needed for the weights on the ref cadence pointing fit, set that up
% now
  if (extraFlag)
      iVec(nNonZero-2) = m-2 ;
      iVec(nNonZero-1) = m-1 ;
      iVec(nNonZero  ) = m   ;
      jVec(nNonZero-2) = n-2 ;
      jVec(nNonZero-1) = n-1 ;
      jVec(nNonZero  ) = n   ;
  end

% create the matrix as dimensioned here and return it

  covariance = sparse(iVec,jVec,sVec,m,n) ;

% and that's it!

%
%
%

%=========================================================================================

% function which takes a list of excluded channels and converts to a list of included
% channels, along with a list of included CCDs

function [includedChannels,includedCCDs] = get_included_channels( excludedChannels, ...
    nPointsPerChannel, nChannels )

% make lists of all channels, all odd channels, and all even channels

  allChannels = 1:nChannels ;
  allChannelsOdd = find( mod(allChannels,2) == 1 ) ;
  allChannelsEven = find( mod(allChannels,2) == 0 ) ;
  
% generate an array which can be used as a mask for included vs excluded channels

  includedChannelIndex = ones(size(allChannels)) ;
  includedChannelIndex(unique(excludedChannels)) = 0 ;
  
% Now:  if the # of points per channel is 1, then if we're not using one channel on a CCD
% we must also exclude the other.  This is because with 2 points per CCD we get 2 row and
% 2 column values, which is 4 constraints on 3 parameters; but with 1 point per CCD we
% only have 2 constraints on 3 parameters.

  if (nPointsPerChannel == 1)
      
      channelStatusEven = includedChannelIndex(allChannelsEven) ;
      channelStatusOdd  = includedChannelIndex(allChannelsOdd) ;
      channelStatus = channelStatusEven & channelStatusOdd ;
      includedChannelIndex(allChannelsEven) = channelStatus ;
      includedChannelIndex(allChannelsOdd) = channelStatus ;
      
  end
  
% the included channels are the ones which line up with the 1's in the index array

  includedChannels = allChannels(find(includedChannelIndex)) ;
  
% we will also need an included CCDs list.  There are 84 channels but only 42 CCDs, so a
% CCD should be included if either of its channels is present, but excluded if they are
% both absent:

  includedCCDs = unique(ceil(includedChannels/2)) ;
  
% and that's it!

%
%
%

%=========================================================================================

% function to determine which CCDs to use when evaluating the pointing constraint 

function ccdsForPointingConstraint = get_ccds_for_pointing_constraint( includedCCDs ) 

% Obviously the CCDs which are not included in the fit can't be used in evaluating the
% constraint which breaks the degeneracy between the pointing and the geometry on the
% reference cadence.  However, the CCD which is opposite to any CCD must also be left out!
% The reason is that the constraints operate by summing the "3" and "2" angles of the CCDs
% and looking for the sum to be zero; if a CCD is left out, the CCD which "balances" it in
% this sum must also be left out.

% here's the list of balancing CCD numbers -- the list is not a simple inversion of the
% list of CCDs, since mod 2 out 1 (ccd 1) balances mod 24 out 1 (ccd 41), etc; and since
% mod 13 is a special case.

  balancingCCDs = [        41 42   39 40   37 38   ...
                   35 36   33 34   31 32   29 30   27 28 ...
                   25 26   23 24   21 22   19 20   17 18 ...
                   15 16   13 14   11 12    9 10    7 8  ...
                            5 6     3 4     1 2 ] ;
                        
% so the CCDs which balance the ones in the fit are:

  balancingCCDsInFit = balancingCCDs( includedCCDs ) ;
  
% and CCDs are only used in the constraint if they're present in both vectors

  ccdsForPointingConstraint = intersect( includedCCDs, balancingCCDsInFit ) ;
  
% and that's it!

%
%
%
