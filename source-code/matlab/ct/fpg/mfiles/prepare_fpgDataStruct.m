%
% matlab script prepare_fpgDataStruct -- this script constructs a (hopefully) valid data
% structure for initiating the FPG fit, named fpgDataStruct, from variables provided in
% the workspace by the user.  The structure which is built has the following fields:
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
%                      tolX: [double] convergence criterion for kepler_nonlinear_fit_soc
%                   tolFun:  [double] convergence criterion for kepler_nonlinear_fit_soc
%                 tolSigma:  [double] convergence criterion for kepler_nonlinear_fit_soc
%             doRobustFit:  [logical] flag to indicate robust fitting
% reportGenerationEnabled:  [logical] flag to indicate report generation (optional)
%               fcConstants: [struct] focal plane characterization constants
%            raDec2PixModel: [struct] data for instantiation of raDec2PixClass objects
%        motionPolynomials:  [struct] motion polynomials, plus information on them
%
% In order to construct this structure, the following variable must be present in the
% workspace:
%
%   mjdRange:  [double] start and end of time period containing cadences for fit
% 
% The following variables are optional -- if they are omitted, then default values will be
% used
%
%             excludedModules: [int] vector of module #'s for excluded mod/outs
%                                    default:  []
%             excludedOutputs: [int] vector of output #'s for excluded mod/outs
%                                    default:  []
%            rowGridValues: [double] vector of row positions for forming constraintPoints
%                                    default: [300 700]
%         columnGridValues: [double] vector of column positions for forming 
%                                      constraintPoints
%                                    default: [100 700]
%            mjdRefCadence: [double] approximate MJD of reference cadence
%                                    default: mjdStart
%      pointingRefCadence:  [double] vector of the pointing on the ref cadence
%                                    default:  []
%   fitPointingRefCadence: [logical] fit the pointing of the reference cadence
%                                    default: false
%       fitPlateScaleFlag: [logical] flag to indicate plate scale fitting
%                                    default: true
%                    tolX: [double] convergence criterion for kepler_nonlinear_fit_soc
%                                    default: 1e-8
%                  tolFun:  [double] convergence criterion for kepler_nonlinear_fit_soc
%                                    default: 1e-8
%                tolSigma:  [double] convergence criterion for kepler_nonlinear_fit_soc
%                                    default: 0.5
%            doRobustFit:  [logical] flag to indicate robust fitting
%                                    default: true
% reportGenerationEnabled: [logical] flag to indicate report generation
%                                    default: true
%
% Version date:  2008-December-20.
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
%    2008-December-20, PT:
%        add support for reportGenerationEnabled field.  Change default value of tolFun.
%
%=========================================================================================

% first of all:  if the required variable (mjdRange) is missing, empty, or something
% other than two real numbers, then we can't even get started

  if ( ~exist('mjdRange') || (~isvector(mjdRange)) || ...
          (~isnumeric(mjdRange)) || (~isreal(mjdRange))  || ...
          (length(mjdRange)~=2) || (mjdRange(1) > mjdRange(2))  )
      error('fpg:prepareFpgDataStruct:mjdRangeBad', ...
          ['prepare_fpgDataStruct: mjdRange must be a vector of 2 real values with '...
          'mjdRange(2) >= mjdRange(1)']) ;
  end

% second of all: if the mjdRefCadence exists, but it doesn't have the proper format, we
% still can't go anywhere

  if ( exist('mjdRefCadence') && ...
       ( (~isscalar(mjdRefCadence)) || (~isnumeric(mjdRefCadence)) || ...
         (~isreal(mjdRefCadence))  )  )
      error('fpg:prepareFpgDataStruct:mjdRefCadenceBad', ...
         'prepare_fpgDataStruct: refCadenceIndex must be a real scalar') ;
  end
  
% if mjdRefCadence doesn't exist, set it to mjdRange(1)

  if (~exist('mjdRefCadence'))
      disp(['... setting mjdRefCadence to default value of ', ...
          num2str(mjdRange(1)),'...']) ;
      mjdRefCadence = mjdRange(1) ;
  end
  
% Retrieve the motion polynomials.  Note that we may want to generate them (with the
% fakedata generator in the fpg/test directory).  We manage these options by having the
% actual retrieval done in a helper function, which takes arguments to tell it what we
% actually want it to do.  Note that generating fakedata requires that a valid
% raDec2PixModel be loaded in the workspace.

  if ( ~exist('testExecution') || (testExecution == false) )
      
%     just to be clear in later steps, set testExecution to zero
      
      testExecution = false ; 
      motionPolynomials = retrieve_motion_polys_for_fpg( mjdRange ) ;
      
  else
       
       if (~exist('pointingFakeData')) % default to 1 cadence at nominal pointing
           pointingFakeData = [0 ; 0 ; 0] ;
       end
       if (~exist('reaDec2PixModelFakeData'))
           raDec2PixModelFakeData = raDec2PixModel ;
       end
       motionPolynomials = retrieve_motion_polys_for_fpg( mjdRange, ...
       raDec2PixModelFakeData, pointingFakeData, mjdRefCadence ) ;
       
  end
  nCadences = size(motionPolynomials,2) ;
  disp(['...retrieved ',num2str(nCadences),' cadences between MJDs ', ...
      num2str(mjdRange(1)),' and ',num2str(mjdRange(2)),'...']) ;
 
% get the vector of mjdMidTimes from the motion polynomials data structure

  mjdLongCadence = [motionPolynomials(1,:).mjdMidTime] ;
  
% get the MJD of the reference cadence -- it's the MJD from the mjdLongCadence vector
% which is closest in value to the one specified by the user

  [mjdRefCadence,iCadence] = get_mjdRefCadence( mjdRefCadence, mjdLongCadence ) ;
  disp(['...reference cadence is cadence # ',num2str(iCadence),' in motionPolynomials...']) ;
  
% retrieve the raDec2PixModel and fcConstants -- this is skipped if we are in test mode,
% since testing may occur on a computer with no access to the datastore

  if (~testExecution)
      
      raDec2PixModel = retrieve_ra_dec_2_pix_model() ;
      fcConstants = convert_fc_constants_java_2_struct() ;
      
  end
  
% Look for the rest of the variables; if they don't exist, set them to their default
% values.  If they do exist, don't bother to do any validation, since the fpgDataClass
% constructor will handle that chore.

  if (~exist('excludedModules'))
      excludedModules = [] ;
      disp('...no mod/outs excluded from fit...') ;
  end
  if (~exist('excludedOutputs'))
      excludedOutputs = [] ;
  end
  if (~exist('rowGridValues'))
      rowGridValues = [300 700] ;
      disp('...rowGridValues set to [300 700]...') ;
  end
  if (~exist('columnGridValues'))
      columnGridValues = [100 700] ;
      disp('...columnGridValues set to [100 700]...') ;
  end
  if (~exist('pointingRefCadence'))
      pointingRefCadence = [] ;
      disp('...using pointing model instead of user-supplied pointing...') ;
  end
  if (~exist('fitPointingRefCadence'))
      fitPointingRefCadence = false ;
      disp('...not fitting pointing on the reference cadence...') ;
  end
  if (~exist('fitPlateScaleFlag'))
      fitPlateScaleFlag = true ;
      disp('...including plate scale in the fit...') ;
  end
  if (~exist('tolX'))
      tolX = 1e-8 ;
      disp('...setting tolX to 1e-8...') ;
  end
  if (~exist('tolFun'))
      tolFun = 2e-2 ;
      disp('...setting tolFun to 2e-2...') ;
  end
  if (~exist('tolSigma'))
      tolSigma = 0.5 ;
      disp('...setting tolSigma to 0.5...') ;
  end
  if (~exist('doRobustFit'))
      doRobustFit = true ;
      disp('...robust fitting enabled...') ;
  end
  if (~exist('reportGenerationEnabled'))
      reportGenerationEnabled = true ;
      disp('...report generation enabled...') ;
  end
  
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
  
% and that's it!

%
%
%

