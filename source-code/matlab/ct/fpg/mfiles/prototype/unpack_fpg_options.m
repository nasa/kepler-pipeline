function [constraintPoints, covariance, fitterArgs, initialParValues, fitterOptions, ...
          dataStatusMapAll, dPointing, refLCDataStruct] = ...
      unpack_fpg_options(testing,fpgTestDataFileName)
%
% unpack_fpg_options -- get focal plane geometry fitting options from a file and generate
% information needed for the FPG fit.
%
% [constraintPoints, covariance, fitterArgs, initialParValues, fitterOptions] =
%    unpack_fpg_options(test) prompts the user to select a mat-file.  The mat-file must
%    contain a data structure, fpgOptions, which has the following fields:
%
%               refCadence:  cadence # of the reference cadence
%            otherCadences:  cadence #'s of all other cadences to be used
%         excludedChannels:  list of FOV channels to be excluded from the fit
%        fitPlateScaleFlag:  0 == no fit, 1 == fit the plate scale
%            constraintRow:  list of rows for constraint points
%            constraintCol:  list of columns of constraint points
%                     tolX:  desired tolX value for the fit.
%                   tolFcn:  desired tolFcn value for the fit.
%                 filename:  file specification of test-data file (ignored if not 
%                            operating in test mode)
%
%    If argument test is nonzero, unpack_fpg_options will use the filename in fpgOptions
%    to perform its unpacking from test data rather than from the sandbox.
%
%    unpack_fpg_options will then produce the information needed for the focal plane
%    geometry fit:
%
%        constraintPoints:  a structure containing the row and column positions used as 
%                           the data to be fit.  The data for each call to nlinfit is
%                           stored in constraintPoints(:).array.
%              covariance:  covariance matrix data structure for constraintPoints.  The
%                           data for each call to nlinfit is stored as
%                           covariance(:).matrix.
%              fitterArgs:  data structures which are passed as the independent variable 
%                           to nlinfit.
%        initialParValues:  initial value structure of the parameters which are to be 
%                           fitted.  The values for each call are stored in
%                           initialParValues(:).array.
%           fitterOptions:  options data structure for nlinfit.
%           dataStatusMap:  nChannel x nCadence matrix; values indicate whether the
%                           selected channel had good status (1) or bad status (0) on the
%                           selected cadence.
%
%    The fit is performed with one or more calls to nlinfit, with call iFit using
%    constraintPoints(iFit), covariance(iFit), fitterArgs(iFit), initialParValues(iFit),
%    and fitterOptions(iFit).
%
%    see also:  update_fpg, statset.  For more information on the constraintPoints
%    organization, type help fpg_constraintPoints.  For more information on the fitterArgs
%    organization, type help fpg_fitterArgs.
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
%    2008-September-19, PT:
%        update raDec2PixClass call.
%    2008-june-24, PT:
%        changes in support of running off of Kepler Mission-provided laptop.
%    2008-june-06, PT:
%        set good channels on bad cadences in the map to have a value of 0.5, so that they
%        appear grey on the status display.
%    2008-june-05, PT:
%        "get" (ie, make) the data structure associated with the reference cadence data,
%        in a format which mocks up the return from the retrieve_target_time_series
%        sandbox tool.  Don't bother with robust fitting if the user doesn't want it.
%    2008-may-30, PT:
%        add support for getting the design values of the pointings for non-reference
%        cadences and returning to the caller.
%    2008-may-23, PT:
%        add dataStatusMap to returned arguments.
%    2008-may-21, PT:
%        mods to support running off the laptop (which can't perform a
%        retrieve_ra_dec_2_pix_model operation).
%    2008-may-19, PT:
%        support for 2 final fits with geometry parameters, first non-robust and then
%        robust, to fix long convergence time when a CCD is missing on the initial fit but
%        present in the all-in-one fit.
%    2008-may-15, PT:
%        support for row/col status maps in test data.
%    2008-may-14, PT:
%        incorporation of exception handling for bad / missing polynomials.  Accept file
%        name from caller for test file specification.
%    2008-may-13, PT:
%        change structure of fitterArgs.RADecModOut from 4-column matrix to data structure
%        of 4-column matrices, 1 for each cadence in the fit.
%    2008-may-12, PT:
%        change from use of statset_fpg to kepler_set_soc function.
%    2008-may-02, PT:
%        turn on robust fitting with default robust options.  Identify and manage missing
%        motion polynomials on individual or multiple cadences.
%    2008-apr-29, PT:
%        restructure to support separate fits for the geometry and the pointings, followed
%        by an all-in-one fit.
%    2008-apr-24, PT:
%        change format of geometry parameter map to (3*nCCD,1), with zeroes representing
%        the CCDs which are not fitted.
%
%=========================================================================================

% if there is a file specification from the caller, use it now

  if (~isempty(fpgTestDataFileName))
      load(fpgTestDataFileName) ;
  else

%     Display file-open GUI to get the mat-file with the fpgOptions data structure in it:

      [filename,path,filterindex] = uigetfile('*.mat','Load FPG Options mat-file') ;
      load(fullfile(path,filename)) ;
      if (~exist('fpgOptions'))
          error('  File name "',filename,'" has no valid fpgOptions structure') ;
      end
  end
  
% if we're testing, we need to translate the information in the testing data structure so
% that it has the same format as the output of the tool which gets motion polynomials out
% of the sandbox; also, in this case the cadence #'s are assigned by the function which
% performs the data structure translation, rather than by the user:

  if (testing)
      if (isfield(fpgOptions,'rowStatusMap'))
          rowStatusMap = fpgOptions.rowStatusMap ;
      else
          rowStatusMap = [] ;
      end
      if (isfield(fpgOptions,'colStatusMap'))
          colStatusMap = fpgOptions.colStatusMap ;
      else
          colStatusMap = [] ;
      end
      if (isfield(fpgOptions,'robustFitting'))
          robustFitting = fpgOptions.robustFitting ;
      else
          robustFitting = 0 ;
      end
      [motionPolyStruc, fpgOptions.refCadence, fpgOptions.otherCadences, ...
          raDec2PixActual] = ...
          get_motion_polys_from_test_data(fpgOptions.filename, ...
                                          rowStatusMap, colStatusMap) ;      
  else
      error(' Non-testing operation not yet supported in unpack_fpg_options.m') ;
  end
  
% reorganize the motionPolyStruc data structure such that the first column is the
% reference cadence and the remainder of the cadences follow in their current order

  motionPolyStruc = sort_motionPolyStruc( motionPolyStruc, fpgOptions.refCadence ) ;
  
% get the mjd range for the data structure and the mjd of the reference cadence

  [mjdMin, mjdMax, mjdRefCadence] = get_mjd_info( motionPolyStruc ) ;

% get a map of the status values for each channel on each cadence

  dataStatusMap = get_data_status_map( motionPolyStruc ) ;
  
% save the status map with the bad cadences (since the bad cadences are "purged" from the
% bad status map later on

  dataStatusMapAll = dataStatusMap ;

% identify and remove cadences which have too many bad channels (note that if the 
% reference cadence is so removed, the function will throw an error)

  [motionPolyStruc, dataStatusMap, badCadences] = remove_bad_cadences( motionPolyStruc, ...
					dataStatusMap ) ;
                
% in dataStatusMapAll, set the good channels on bad cadences to 0.5 (so they are grey in
% the status display)

  dataStatusMapAll = double(dataStatusMapAll) ;
  dataStatusMapAll(:,badCadences) = dataStatusMapAll(:,badCadences) / 2 ;
                
% get the dPointing values for non-reference cadences from the sorted and purged
% motionPolyStruc

  dPointing = get_dPointing( motionPolyStruc ) ;

% identify channels which are bad on the reference cadence, and channels which
% are bad on all cadences -- these channels must be handled with special care in
% the fits

  badChannelsRefCadence  = find_bad_channels( dataStatusMap(:,1) ) ;
  badChannelsAllCadences = find_bad_channels( dataStatusMap ) ;
  
% get an raDec2PixClass object which covers the range of mjds desired

  raDec2PixMod = get_canned_or_live_raDec2PixModel(mjdMin, mjdMax) ;
  raDec2PixObj = raDec2PixClass(raDec2PixMod,'zero-based') ;
                                      
% On each mod/out, we'll start with the nominal row and column positions of the constraint
% points and construct a grid (same grid for each mod/out).  Construct that grid from the
% list of rows and columns now.

  [gridRow,gridCol] = construct_grid_from_row_col_vectors( fpgOptions.constraintRow, ...
                                                           fpgOptions.constraintCol       ) ;
                                                  
% use the rows and columns to get the RA and Dec of each grid point on each included
% channel, using the existing geometry model and the pointing of the reference cadence.
% This is just a simple way to get a set of RAs and Decs which should lie on each of the
% mod/outs

  import gov.nasa.kepler.common.FcConstants ;
  nChannels = FcConstants.nModules * FcConstants.nOutputsPerModule ;

  constraintRA  = zeros(length(gridRow),nChannels) ;
  constraintDec = constraintRA ;
  onesVec = ones(length(gridRow),1) ;
  for iChannel = 1:nChannels
      [iMod,iOut] = convert_to_module_output(iChannel) ;
      [constraintRA(:,iChannel), constraintDec(:,iChannel)] = ...
          pix_2_ra_dec_absolute(raDec2PixObj, iMod*onesVec, ...
          iOut*onesVec, gridRow, gridCol, mjdRefCadence) ;
  end
  
% construct the data structure of auxiliary data which must be passed to the main
% data-reorganization tool 

  fitData.gridRow = gridRow ;
  fitData.gridCol = gridCol ;
%
  fitData.excludedChannels = fpgOptions.excludedChannels ;
  fitData.constraintRA = constraintRA ;
  fitData.constraintDec = constraintDec ;
  fitData.raDec2PixObj = raDec2PixObj ;

% The first thing we do is always to use the reference cadence to fit the focal plane
% geometry (but no pointing errors).  Take care of that case now.

  fitData.badChannels = badChannelsRefCadence ;
  fitData.dataStatusMap = dataStatusMap(:,1) ;
      
  [constraintPointsVec, covarianceMat, fitterArgsStruc, initialParValuesVec] = ...
     unpack_fpg_options_main( motionPolyStruc(:,1), fitData, ...
                         1, fpgOptions.fitPlateScaleFlag, 0 ) ;

   constraintPoints(1).array = constraintPointsVec ;
   covariance(1).matrix      = covarianceMat       ;
   fitterArgs(1)             = fitterArgsStruc     ;
   initialParValues(1).array = initialParValuesVec ;
   
 % as long as we have the fitData structure organized for the reference cadence, get the
 % long cadence data for the good channels on that cadence.  We need to substitute the
 % actual RaDec2PixClass object, and then un-substitute it afterwards
 
   fitData.raDec2PixObj = raDec2PixActual ;
   
   disp('..."Getting" (ie, making) reference LC pixel data...');
   t0 = clock ;
   refLCDataStruct = get_time_series_good_channels( fitData, mjdRefCadence ) ;
   disp(['...done with "getting" reference LC pixel data, elapsed time = ',...
       num2str(etime(clock,t0))] ) ;
   
   fitData.raDec2PixObj = raDec2PixObj ;
   
% if there are additional cadences, then first we will fit their pointing errors (but not
% their focal plane geometries), and then we'll do an all-in-one fit.  Set up that case
% now.  In order to avoid expanding the structure over and over again, we'll instantiate
% the last member of each structure array first (to grow it to its final size), and then
% fill in the middle.  Also, if there are CCDs which are fitted on the all-in-one fit
% which are not in the initial fit (due to problems with the data for the reference
% cadence), then we will do the all-in-one fit twice:  once in non-robust mode, to get
% an approximate starting condition for the last fit, which is robust.  This has been
% shown to improve the overall time needed to fit, even though it requires an additional
% non-robust, all-in-one execution of nlinfit.  Note that we only need to do this if we
% want to do robust fitting; if robust fitting is not selected, then an extra fit is not
% needed.

% A note on the status information:  in the all-cadences fit, the list of bad channels
% is the same as the list of channels which are bad on all cadences -- if there is any
% good data for a given channel, it can go into the complete fit.  For the fits on the
% non-reference cadences, we use the badChannels information to identify channels which
% did not get their geometry fitted in the reference-cadence fit, since a CCD with 
% unknown pointing cannot be used to fit the pointing of the spacecraft.

  if (size(motionPolyStruc,2) > 1)

      fitData.badChannels = badChannelsAllCadences ;
      fitData.dataStatusMap = dataStatusMap ;
      
      [constraintPointsVec, covarianceMat, fitterArgsStruc, initialParValuesVec] = ...
         unpack_fpg_options_main( motionPolyStruc, ...
                             fitData, 1, fpgOptions.fitPlateScaleFlag, ...
                            [0 ; ones(size(motionPolyStruc,2)-1,1)] ) ;

      iCadence = size(motionPolyStruc,2) + 1 ;
      constraintPoints(iCadence).array = constraintPointsVec ;
      covariance(iCadence).matrix      = covarianceMat       ;
      fitterArgs(iCadence)             = fitterArgsStruc     ;
      initialParValues(iCadence).array = initialParValuesVec ;
      
      needExtraFitStep = (length(find(fitterArgs(iCadence).geometryParMap~=0)) ~= ...
          length(find(fitterArgs(1).geometryParMap~=0)) ) ;
      
      if (needExtraFitStep & robustFitting)
          constraintPoints(iCadence+1).array = constraintPointsVec ;
          covariance(iCadence+1).matrix      = covarianceMat       ;
          fitterArgs(iCadence+1)             = fitterArgsStruc     ;
          initialParValues(iCadence+1).array = initialParValuesVec ;
      end
          
      
      for iCadence = 2:size(motionPolyStruc,2)
          fitData.badChannels = badChannelsRefCadence ;
          fitData.dataStatusMap = dataStatusMap(:,iCadence) ;
          [constraintPointsVec, covarianceMat, fitterArgsStruc, initialParValuesVec] = ...
             unpack_fpg_options_main( motionPolyStruc(:,iCadence),  ...
             fitData, 0, 0, 1 ) ;
         
          constraintPoints(iCadence).array = constraintPointsVec ;
          covariance(iCadence).matrix      = covarianceMat       ;
          fitterArgs(iCadence)             = fitterArgsStruc     ;
          initialParValues(iCadence).array = initialParValuesVec ;
          
      end
      
      
  end % if ~isempty(otherCadences) conditional
         
% construct a fitterOptions data structure with the desired tolX and tolFcn values, turn
% on robust fitting, and set the uncertainty convergence criterion rather loose, to say
% 0.1 sigmas.  Also, set up so that NaN or Inf are treated as missing data rather then
% causing an error. 

  fitterOptionsAll = kepler_set_soc('TolX', fpgOptions.tolX, 'TolFun', fpgOptions.tolFun, ...
      'Robust','on','convSigma',0.1,'FunValCheck','off') ;
  
% if there is more than 1 fit, then we want to do the preliminary fits without any
% robustness, since the preliminary fits are only used to get the parameters into the
% right range for the final fit, which is robust.  Generate an options structure which
% does not enable robust fitting for the early steps

  fitterOptionsSimple = kepler_set_soc('TolX', fpgOptions.tolX, 'TolFun', fpgOptions.tolFun, ...
      'FunValCheck','off' ) ;
  
% bundle the fit options together -- note that if only non-robust fitting is desired, then
% don't put the fitterOptionsAll structure into the vector of fitting options structures.

  nFit = length(fitterArgs) ;
  if (robustFitting)
      fitterOptions(nFit) = fitterOptionsAll ;
  else
      fitterOptions(nFit) = fitterOptionsSimple ;
  end
  fitterOptions(1:nFit-1) = fitterOptionsSimple ;
  
% and that's it! 
  
%
%
%

%=========================================================================================

% function get_motion_polys_from_test_data -- loads a test-function data structure and
% manipulates it to produce a data structure which matches the output of the sandbox tool
% for extracting motion polynomials from the datastore.  In the process it sets the% cadence numbers for all cadences and the cadence number of the reference cadence (they
% are set to negative numbers so that they never conflict with the cadence numbers of real
% cadences).

function [motionPolyStruc, refCadence, otherCadences, raDec2PixActual] = ...
    get_motion_polys_from_test_data(filename, rowStatusMap, colStatusMap) 

% load the file with the test data

  load(filename) ;
  
% find the one which has the right class ('fpgTestData') and assign it to a new name

  s = whos() ;
  for iVar = 1:length(s)
      if ( strcmp( s(iVar).class,'fpgTestData') )
          eval(['fpgTestData1 = ',s(iVar).name,' ;']) ;
      end
  end
  
% construct the structure -- its dimensions are nChannel x nCadence with fields:
%
%    mjd
%    cadence
%    channel
%    rowPoly
%    rowStatus
%    colPoly
%    colStatus
%
% In addition, in order to emulate certain capabilities which will come with the
% production version, the structure will include the following fields:
%
%    dRA
%    dDec
%    dRoll
%
% where these are the nominal pointing offsets, by cadence.

  rowPoly = get(fpgTestData1,'rowPoly') ; colPoly = get(fpgTestData1,'colPoly') ;
  nCadence = size(rowPoly,2) ;
  
  mjd = get(fpgTestData1,'mjd') ;
  dPointing = get(fpgTestData1,'cadencedOrientation') ;
  
  cadenceList = -1*(1:nCadence) ;

% if the row status map or the column status map are empty, set them to be maps of
% all good status

  if (isempty(rowStatusMap))
      rowStatusMap = ones(84,nCadence) ;
  end
  if (isempty(colStatusMap))
      colStatusMap = ones(84,nCadence) ;
  end
  
  motionPolyStruc = [] ;
  
  for iChannel = 1:84
      for iCadence = 1:nCadence
          motionPolyStruc(iChannel,iCadence).mjd = mjd ;
          motionPolyStruc(iChannel,iCadence).cadence = cadenceList(iCadence) ;
          motionPolyStruc(iChannel,iCadence).channel = iChannel ;
          motionPolyStruc(iChannel,iCadence).rowPoly   = rowPoly(iChannel,iCadence) ;
          motionPolyStruc(iChannel,iCadence).rowStatus = rowStatusMap(iChannel,iCadence) ;
          motionPolyStruc(iChannel,iCadence).colPoly   = colPoly(iChannel,iCadence) ;
          motionPolyStruc(iChannel,iCadence).colStatus = colStatusMap(iChannel,iCadence) ;
          motionPolyStruc(iChannel,iCadence).dRA   = dPointing(1,iCadence) ;
          motionPolyStruc(iChannel,iCadence).dDec  = dPointing(2,iCadence) ;
          motionPolyStruc(iChannel,iCadence).dRoll = dPointing(3,iCadence) ;
      end
  end
  
% find the cadence which is at the reference orientation
  
  for iCadence = 1:nCadence
      if ( sum(dPointing(:,iCadence) == [0 ; 0 ; 0]) == 3 )
          refCadence = -iCadence ;
      end
  end
  
% make the list of non-reference cadences

  otherCadences = cadenceList(find(cadenceList ~= refCadence)) ;
  
% finally, get the actual raDec2PixClass object from the test data structure.  Since
% Matlab often converts these back to structs, be prepared to re-convert to a class

  raDec2PixActual = get(fpgTestData1,'raDec2PixObject') ;
  if (~isa(raDec2PixActual,'raDec2PixClass'))
      raDec2PixActual = raDec2PixClass(raDec2PixActual) ;
  end
  
% and that's it!

%
%
%

%=========================================================================================

% function get_mjd_info -- find the min and max modified julian dates in a set of motion
% polynomials, and the mjd of the reference cadence; assumes that the reference cadence
% has been sorted into the first column of motionPolyStruc.

function [mjdMin, mjdMax, mjdRefCadence] = get_mjd_info(motionPolyStruc)

% use the Matlab tools for element-by-element extraction from a structure to get a list of
% MJDs

  mjds = [motionPolyStruc(1,:).mjd] ;
    
% find the mjd corresponding to the reference cadence, and then the min and max mjds in
% the dataset 
  
  mjdRefCadence = mjds(1) ;
  mjdMin = min(mjds) ;
  mjdMax = max(mjds) ;
  
  
% and that's it!

%
%
%

%=========================================================================================
      
% function construct_grid_from_row_col_vectors -- take a vector of row positions (M x 1) and a
% vector of column positions (N x 1) and construct a grid of row and column positions (M x
% N) which corresponds to it.

function [gridRow,gridCol] = construct_grid_from_row_col_vectors( constraintRow, ...
                                                                  constraintCol       )

  nRow = length(constraintRow) ; nCol = length(constraintCol) ;
    
% the row is just nCol repetitions of the constraintRow information

  gridRow = repmat(constraintRow(:),nCol,1) ;
  
% the column is a bit trickier -- start with a vector of ones

  gridCol = ones(nRow*nCol,1) ;
  
% loop over the constraintCol vector and perform appropriate assignments  
  
  for iCol = 1:nCol
      colStart = nRow*(iCol-1) + 1 ;
      colEnd   = colStart + nRow - 1 ;
      gridCol(colStart:colEnd) = constraintCol(iCol) ;
  end
  
% and that's it!

%
%
%

%=========================================================================================

% weighted_polyval2d_fpg -- a temporary version of weighted_polyval2d which returns a
% covariance matrix as its 4th argument.  Will be eliminated once weighted_polyval2d has
% been appropriately modified

function [z zu A covar] = weighted_polyval2d_fpg(x,y,c,A)

if (length(c(1).coeffs) == 1 && c(1).coeffs == 0)
    z = 0;
    return;
end

if nargin == 3 || isempty(A) % don't have a pre-computed design matrix
    % scale x to improve conditioning
    xp = c(1).offsetx + c(1).scalex*(x - c(1).originx);
    yp = c(1).offsety + c(1).scaley*(y - c(1).originy);

    A = weighted_design_matrix2d(xp, yp, 1, c(1).order);
end
% compute the fitted values at the input x,y
z = A*[c.coeffs];
% if requested, return the uncertainties in the fitted values
% this operation takes much longer (about 10 times longer) than the rest of
% this routine
if nargout > 1
% the following line is an efficient computation of zu = sqrt(diag(A*[c.covariance]*A'));
    zu = sqrt(sum(A*[c.covariance].*A, 2));
end

if nargout > 3
    covar = A*c.covariance*A' ;
end
    
% and that's it!

%
%
%

%=========================================================================================

% allocate a sparse covariance matrix for a system with a known number of channels,
% cadences, and points per channel per cadence

function  covariance = allocate_sparse_covariance_fpg(nChannelTotal,nPoint)

% the covariance matrix is a block-diagonal, with blocks of size nPoint x nPoint.  The
% number of elements is nPoint * nPoint * 2(rows and columns) * nChannelTotal.
% Allocate some arrays to hold that now

  nNonZero = nPoint^2 * 2 * nChannelTotal ;
  iVec = zeros(nNonZero,1) ; jVec = iVec ; sVec = iVec ; 
  
% the non-sparse dimension of the matrix is square, with nrow = nPoint * 2 * nChannel *
% nCadence, and ncol == nrow.

  m = nPoint * 2 * nChannelTotal ; n = m ; 
  
% the basic unit of the matrix is the nPoint x nPoint grid.  Generate indices for that now

  [iUnit,jUnit] = construct_grid_from_row_col_vectors([1:nPoint], [1:nPoint]) ;
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
  
% create the matrix as dimensioned here and return it

  covariance = sparse(iVec,jVec,sVec,m,n) ;

% and that's it!

%
%
%

%=========================================================================================

% This function returns the constraint points vector, covariance matrix, fitter args
% structure, and initial parameter values for a fit.  It takes as inputs the motion
% polynomial structure, list of cadences to be used in the fit, a structure which
% transfers some data from the caller, and flags to indicate whether the CCD 3-2-1 angles,
% plate scale, or cadence pointings are to be fitted.  Since pointing varies
% cadence-to-cadence, fitPointingFlags is a vector which indicates whether the pointing
% for each cadence in the list is to be fitted.

function [constraintPoints, covariance, fitterArgs, initialParValues] = ...
    unpack_fpg_options_main( motionPolyStruc, fitData, ...
                             fit321Flag, fitPlateScaleFlag, fitPointingFlags )

% unpack the fitData structure to get local variables

  gridRow                = fitData.gridRow ;
  gridCol                = fitData.gridCol ;
  excludedChannels       = fitData.excludedChannels ;
  badChannels            = fitData.badChannels ;
  constraintRA           = fitData.constraintRA ;
  constraintDec          = fitData.constraintDec ;
  raDec2PixObj           = fitData.raDec2PixObj ;
  dataStatusMap          = fitData.dataStatusMap ;
   
  nCadences = size(motionPolyStruc,2) ;
  
% construct a list of channels which are suppressed in all cadences (this is the union of
% the channels suppressed by the user and the ones which were determined to be bad in all
% cadences), and lists by cadence of which channels are suppressed in each cadence (this
% is the union of the suppress-in-all list and the bad channels in each cadence).  The
% reason that we preserve a suppress-in-all list which is separate from the suppress-in-
% each lists is that the suppress-in-all is the list of channels which have to be left out
% when determining geometry fit parameters, while if a channel is bad in some cadences but
% not others its geometry parameters can be included.
  
  excludedChannelsAllCadences = unique([excludedChannels(:)' badChannels(:)']) ;
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

  import gov.nasa.kepler.common.FcConstants ;
  nChannels = FcConstants.nModules * FcConstants.nOutputsPerModule ;
  nChannelsTotal = nChannels * nCadences - sum(nBadChannelsByCadence) ;
  nCCDs = nChannels / 2 ;  
  
% construct the vector of constraint points and the matrix of covariances -- these are the
% results of putting the RA and Dec values computed above through the motion polynomials
% for the correct cadence and mod/out.  TODO:  support for motion polynomials returned
% with bad status from the tool which gets them out of the sandbox.

  nConstraintPoints = 2 * length(gridRow) * nChannelsTotal ;
  nPointsPerChannel = 2 * length(gridRow) ;
  constraintPoints = zeros(nConstraintPoints,1) ;
  fitterArgs.nConstraintPoints = nConstraintPoints ;

% use a sparse matrix for the covariance...

  covariance = allocate_sparse_covariance_fpg(nChannelsTotal,length(gridRow)) ;
  
% fill the constraintPoints and covariance matrices with values.  Note that, within 1
% cadence, all of the row values precede all of the column values.  This makes it simple
% to take the raDec2Pix output (which is a vector of each of M O R C) and construct a
% vector which compares the two (ie model values of the constraint points are [R ; C]).
% While we're at it, fill fitterArgs with matrices of the RA, Dec, Mod, and Out values for
% all constraint points
  
  conStart = 1 ;
  for iCadence = 1:nCadences
      
      [includedChannels,includedCCDs] = get_included_channels( badChannelsByCadence(iCadence).array ) ; 
      [includedMods,includedOuts] = convert_to_module_output( includedChannels ) ;
     
      fitterArgs.RADecModOut(iCadence).matrix = zeros(length(includedChannels)*length(gridRow),4) ;
      constraintRAThisCadence  = constraintRA(:,includedChannels) ;
      constraintDecThisCadence = constraintDec(:,includedChannels) ; 
      fitterArgs.RADecModOut(iCadence).matrix(:,1) = constraintRAThisCadence(:) ;
      fitterArgs.RADecModOut(iCadence).matrix(:,2) = constraintDecThisCadence(:) ;
      for iChannel = 1:length(includedChannels)
          chanStart = length(gridRow) * (iChannel-1) + 1 ;
          chanEnd   = chanStart + length(gridRow) - 1 ;
          fitterArgs.RADecModOut(iCadence).matrix(chanStart:chanEnd,3) = ...
              repmat(includedMods(iChannel),length(gridRow),1) ;
          fitterArgs.RADecModOut(iCadence).matrix(chanStart:chanEnd,4) = ...
              repmat(includedOuts(iChannel),length(gridRow),1) ;
      end

      for iChannel = includedChannels(:)' 
          
          [rowPolyRow,rowPolySig,dmyMat,rowPolyCovar] = weighted_polyval2d_fpg( ...
               constraintRA(:,iChannel), constraintDec(:,iChannel), ...
               motionPolyStruc(iChannel,iCadence).rowPoly) ;
          conEnd = conStart + length(rowPolyRow) - 1 ;
          constraintPoints(conStart:conEnd) = rowPolyRow ;
          covariance(conStart:conEnd, conStart:conEnd) = rowPolyCovar ; 
          conStart = 1+conEnd ;
          
      end

      for iChannel = includedChannels(:)' 
          
          [colPolyCol,colPolySig,dmyMat,colPolyCovar] = weighted_polyval2d_fpg( ...
              constraintRA(:,iChannel), constraintDec(:,iChannel), ...
             motionPolyStruc(iChannel,iCadence).colPoly) ;
          conEnd = conStart + length(colPolyCol) - 1 ;
          constraintPoints(conStart:conEnd) = colPolyCol ;
          covariance(conStart:conEnd, conStart:conEnd) = colPolyCovar ; 
          conStart = 1+conEnd ;
          
      end 
  end

% In addition to the RA and Dec values, fitterArgs has to carry some additional
% information.  Fill that in now.
  
  fitterArgs.raDec2PixObject = raDec2PixObj ;
  fitterArgs.mjds = zeros(nCadences,1) ;
  for iCadence = 1:nCadences
      fitterArgs.mjds(iCadence) = motionPolyStruc(1,iCadence).mjd ;
  end
  
% construct a map which relates the parameters in the parameter vector to their locations
% in the geometry model.  For this, the included channels and CCDs are the ones which are
% included on any cadence, so we should only exclude the ones which the user excluded from
% all cadences and which are bad on all cadences.

  [includedChannels,includedCCDs] = get_included_channels( excludedChannelsAllCadences ) ; 
  [includedMods,includedOuts] = convert_to_module_output( includedChannels ) ;
  fitterArgs.geometryParMap = zeros(3*nCCDs,1) ;
  if (fit321Flag) 
      for iCCD = 0:length(includedCCDs)-1
          ccdNum = includedCCDs(iCCD+1)-1 ;
          fitterArgs.geometryParMap(3*ccdNum+1:3*ccdNum+3) = 3*iCCD+1:3*iCCD+3 ;
      end
      nGeomPars = length(includedCCDs) * 3 ;
  else
      nGeomPars = 0 ;
  end
  
% set the geometry fit flag if there are geometry parameters to be fitted -- this will be
% useful later as a simple way to identify fits with geometry parameters in them

  if (nGeomPars ~= 0)
      fitterArgs.fitGeometryFlag = 1 ;
  else
      fitterArgs.fitGeometryFlag = 0 ;
  end
  
% set the identity of the parameter which holds the plate scale, if desired

  if (fitPlateScaleFlag)
      fitterArgs.plateScaleParMap = nGeomPars + 1 ;
      nPars = nGeomPars + 1 ;
  else
      fitterArgs.plateScaleParMap = 0 ;
      nPars = nGeomPars ;
  end
  
% set up the map between fit parameters and RA, Dec, Roll errors 

  
  fitterArgs.cadenceRAMap  = zeros(length(find(fitPointingFlags~=0)),1) ;
  fitterArgs.cadenceDecMap  = fitterArgs.cadenceRAMap ;
  fitterArgs.cadenceRollMap = fitterArgs.cadenceRAMap ;
  
  for iCadence = 1:nCadences
      if (fitPointingFlags(iCadence))
          fitterArgs.cadenceRAMap(iCadence) = nPars + 1 ;
          fitterArgs.cadenceDecMap(iCadence) = nPars + 2 ;
          fitterArgs.cadenceRollMap(iCadence) = nPars + 3 ;
          nPars = nPars + 3 ;
      end
  end
  
% get the initial values of all the parameters -- basically, the current geometry model
% and plate scale, zeros for the current estimate of the orientation error on the
% non-reference cadences

  initialParValues = zeros(nPars,1) ;
  
  geometryModel = get(raDec2PixObj,'geometryModel') ;
  nonZeroIndices = find(fitterArgs.geometryParMap ~= 0) ;
  initialParValues(1:length(nonZeroIndices)) = ...
      geometryModel.constants(1).array(nonZeroIndices) ;

  if (fitterArgs.plateScaleParMap ~= 0)
      initialParValues(fitterArgs.plateScaleParMap) = ...
          geometryModel.constants(1).array(end) ;
  end
  
% and that's it!

%
%
%

%=========================================================================================

% function which takes a list of excluded channels and converts to a list of included
% channels, along with a list of included CCDs

function [includedChannels,includedCCDs] = get_included_channels( excludedChannels )

% determine the number of channels and build a vector of them 

  import gov.nasa.kepler.common.FcConstants ;
  nChannels = FcConstants.nModules * FcConstants.nOutputsPerModule ;
  allChannels = 1:nChannels ;
  
% generate an array which can be used as a mask for included vs excluded channels

  includedChannelIndex = ones(size(allChannels)) ;
  includedChannelIndex(unique(excludedChannels)) = 0 ;
  
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

% function which generates a data status map from the status values in the motion
% polynomial structure

function dataStatusMap = get_data_status_map( motionPolyStruc )

  nCadence = size(motionPolyStruc,2) ;
  nChannel = size(motionPolyStruc,1) ;
   
% extract the row and column status information for all cadences

  rowStatus = [motionPolyStruc.rowStatus] ;
  colStatus = [motionPolyStruc.colStatus] ;
  rowStatus = reshape(rowStatus,nChannel,nCadence) ;
  colStatus = reshape(colStatus,nChannel,nCadence) ;
  
% determine the datasets which have good status -- to have good status, both the row
% status and the column status for that channel on that cadence must be good
  
  dataStatusMap = rowStatus & colStatus ;
    
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

% function which identifies and removes bad cadences from both a motion polynomial 
% structure and a data status map.  If the reference cadence is removed, an error is
% raised; for all other removed cadences, a warning is issued

function [mPSOut, dSMOut, badCadences] = remove_bad_cadences( mPSIn, dSMIn ) 

% get the max # of channels and the total # of good channels in each cadence

  nChannels = size(mPSIn,1) ;
  nGoodChannels = sum(dSMIn) ;

% the cadence is good if it has a sufficient fraction of good channels

  nChannelCutoff = ceil(nChannels * 0.9) ;

  goodCadences = find(nGoodChannels >= nChannelCutoff) ; 
  badCadences  = find(nGoodChannels <  nChannelCutoff) ;

% if the first (reference) cadence is bad, error out

  if (~isempty(find(badCadences==1)))
      error(' Reference cadence bad in Focal Plane Geometry') ;
  end

% for all other cadences, raise a warning

  cadenceNumbers = [mPSIn(1,:).cadence] ;
  badCadenceNumbers = cadenceNumbers(badCadences) ; 
  for iCadence = badCadenceNumbers
      warning([' Cadence # ',num2str(iCadence),' bad in Focal Plane Geometry']) ;
  end

% construct the output variables by extrcating the non-bad cadences 

  mPSOut = mPSIn(:,goodCadences) ;
  dSMOut = dSMIn(:,goodCadences) ;

% and that's it!

%
%
%

%=========================================================================================

% function which sorts the motion polynomial structure, making the first column of the
% structure the reference cadence and following it with all the other cadences.

function motionPolyStrucOut = sort_motionPolyStruc( motionPolyStrucIn, refCadence ) 

% get the cadence numbers out of the input motion polynomial structure

  cadenceList = [motionPolyStrucIn(1,:).cadence] ;
  
% find the one which is the reference cadence, and which ones are others

  refCadenceIndex = find(cadenceList == refCadence) ;
  otherCadenceIndex = find(cadenceList ~= refCadence) ;
  
% move the reference cadence to the first column and keep the rest in their current order

  motionPolyStrucOut = [motionPolyStrucIn(:,refCadenceIndex) ...
                        motionPolyStrucIn(:,otherCadenceIndex)   ] ;
                    
% and that's it!

%
%
%

%=========================================================================================

% function which takes a channel status map and a cadence index and returns the bad
% channels for that cadence (ie, the number of zeroes in the matrix first argument in the
% column selected by the scalar second argument).

function bad_channel_list = get_bad_channel_list(channel_status_map, column)

% pretty simple, really:  the only refinement is that, for testing purposes, we need to
% handle the case where the status map is empty

  if (~isempty(channel_status_map))
      bad_channel_list = find(channel_status_map(:,column)==0) ;
  else
      bad_channel_list = [] ;
  end
  
% and that's it!

%
%
%

%=========================================================================================

% Either go to retrieve an raDec2Pix model or else load a canned one,
% depending on whether we are running on a laptop or on pixel

function raDec2PixMod = get_canned_or_live_raDec2PixModel(mjdMin, mjdMax) 

  hostname = getenv('HOSTNAME') ;
  
  switch hostname
      
      case 'ilc-quarkpt.win.slac.stanford.edu'
          
          disp('...loading canned RaDec2Pix model from disk...') ;
          load('C:/PT Files/Kepler/Documents/NotArchived/FPG/TestDataForPrototype/raDec2PixModel.mat') ;
          raDec2PixMod = rd2pm ;
          
      case {'kplt03'}
          
          disp('...loading canned RaDec2Pix model from disk...') ;
          load('C:/PTFiles/Kepler/NotArchived/FPG/TestDataForPrototype/raDec2PixModel.mat') ;
          raDec2PixMod = rd2pm ;
          
      case 'pixel.arc.nasa.gov'
          
          disp('...retrieving live RaDec2Pix model...') ;
          raDec2PixMod = retrieve_ra_dec_2_pix_model(mjdMin, mjdMax) ;
          
      otherwise
          
          disp('...unknown host assumed to be Kepler workstation, ') ;
          disp('   attempting to retrieve live RaDec2PixModel...') ;
          raDec2PixMod = retrieve_ra_dec_2_pix_model(mjdMin, mjdMax) ;

  end
  
% and that's it!

%
%
%

%=========================================================================================

% function to extract the design pointing values for non-reference cadences from the
% motion polynomial structure

function dPointing = get_dPointing( motionPolyStruc )

% how many cadences?

  nCadences = size(motionPolyStruc,2) ;
  
% dimension the return variable

  dPointing = zeros(3,nCadences-1) ;
  
% get the values out and put them in the correct slots in dPointing

  for iCadence = 2:nCadences
      
      dPointing(1,iCadence-1) = motionPolyStruc(1,iCadence).dRA   ;
      dPointing(2,iCadence-1) = motionPolyStruc(1,iCadence).dDec  ;
      dPointing(3,iCadence-1) = motionPolyStruc(1,iCadence).dRoll ;
      
  end
  
% and that's it!

%
%
%

%=========================================================================================

% function to "get" (ie, generate) the mockup of the output of the time-series extractor
% sandbox tool.  We only get this for channels which are good in the reference cadence.

function refLCDataStruct = get_time_series_good_channels( fitData, mjdRefCadence )

% construct the list of channels which we don't want from information in the fitData

  excludedChannels = unique([fitData.excludedChannels(:)' fitData.badChannels(:)']) ;
  
% convert into a list of good channels, then a list of mod/outs to include

  [includedChannels,includedCCDs] = get_included_channels( excludedChannels ) ;
  [includedMods, includedOuts] = convert_to_module_output( includedChannels ) ;
  
% now call the mock sandbox tool...

  refLCDataStruct = mock_retrieve_target_time_series( includedMods, includedOuts, ...
      mjdRefCadence, mjdRefCadence, 1, 0, 2000, fitData.raDec2PixObj ) ;
  
% and that's it!

%
%
%