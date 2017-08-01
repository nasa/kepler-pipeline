function fpgInputsPipeline = convert_fpg_inputs_to_pipeline( fpgInputsInteractive )
%
% convert_fpg_inputs_to_pipeline -- convert an fpgDataStruct from the interactive format
% to the pipeline format.
%
% fpgInputsPipeline = convert_fpg_inputs_to_pipeline( fpgInputsInteractive ) takes an
%    fpgDataStruct which is organized for interactive use and converts it to an equivalent
%    structure organized for pipeline use.  The fpgDataStruct organization for pipeline
%    use is different in a number of trivial ways, and one important one:  the motion
%    polynomials provided for interactive use are Matlab structures, while the ones
%    provided for pipeline use are blobs (since the pipeline infrastructure has no means
%    to convert a blob to a structure).
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
%     2008-December-20, PT:
%         add support for reportGenerationEnabled field, which is optional.
%     2008-October-31, PT:
%         add cadenceNumbers field to timestampSeries structure.
%     2008-September-19, PT:
%         update blobSeriesClass data structure with startCadence and endCadence fields.
%     2008-September-14, PT:
%         add support for maxBadDataCutoff field.
%     2008-September-07, PT:
%         change name of geometry blob file.  Make blobIndices double instead of int32.
%     2008-September-05, PT:
%         updated to match current definition of the pipeline inputs, blobSeries data
%         format, and motion polynomial data structure produced by PA.  blobIndices is
%         zero-based!
%
%=========================================================================================

% FPG doesn't use a debug level, so set the debug level to be zero

  fpgConfigurationStruct.debugLevel = int32(0) ;

% Start with easy stuff -- the fpgConfigurationStruct is a bunch of parameters which are
% simply copied from the original data structure

  fpgConfigurationStruct.rowGridValues = fpgInputsInteractive.rowGridValues ;
  fpgConfigurationStruct.columnGridValues = fpgInputsInteractive.columnGridValues ;
  fpgConfigurationStruct.fitPlateScaleFlag = fpgInputsInteractive.fitPlateScaleFlag ;
  fpgConfigurationStruct.tolX = fpgInputsInteractive.tolX ;
  fpgConfigurationStruct.tolFun = fpgInputsInteractive.tolFun ;
  fpgConfigurationStruct.tolSigma = fpgInputsInteractive.tolSigma ;
  fpgConfigurationStruct.doRobustFit = fpgInputsInteractive.doRobustFit ;  
  
% some fields are optional -- copy them if they are present, set them if they are absent

  if (isfield(fpgInputsInteractive,'fitPointingRefCadence'))
      fpgConfigurationStruct.fitPointingRefCadence = fpgInputsInteractive.fitPointingRefCadence ;
  else
      fpgConfigurationStruct.fitPointingRefCadence = false ;
  end
  
  if (isfield(fpgInputsInteractive,'usePointingModel'))
      fpgConfigurationStruct.usePointingModel = fpgInputsInteractive.usePointingModel ;
  else
      fpgConfigurationStruct.usePointingModel = true ;
  end
  
  if (isfield(fpgInputsInteractive,'maxBadDataCutoff'))
      fpgConfigurationStruct.maxBadDataCutoff = fpgInputsInteractive.maxBadDataCutoff ;
  else
      fpgConfigurationStruct.maxBadDataCutoff = 0.1 ;
  end
  if (isfield(fpgInputsInteractive,'reportGenerationEnabled'))
      fpgConfigurationStruct.reportGenerationEnabled = ...
          fpgInputsInteractive.reportGenerationEnabled ;
  else
      fpgConfigurationStruct.reportGenerationEnabled = true ;
  end
  
% the reference cadence can be determined by comparing the mjdRefCadence and
% mjdLongCadence variables.  Don't forget to subtract one to get from one-based to
% zero-based!
  
  refCadence = find(fpgInputsInteractive.mjdLongCadence == fpgInputsInteractive.mjdRefCadence) ;
  fpgConfigurationStruct.referenceCadence = refCadence - 1 ;
  
  if (isfield(fpgInputsInteractive,'pointingRefCadence'))
      fpgConfigurationStruct.pointingRefCadence = fpgInputsInteractive.pointingRefCadence ;
  else
      pointingObject = pointingClass(fpgInputsInteractive.raDec2PixModel.pointingModel) ;
      fpgConfigurationStruct.pointingRefCadence = get_pointing( pointingObject, ...
          fpgInputsInteractive.mjdRefCadence ) ;
  end
  
  
% construct the cadenceTimes data structure from the timestamps in the motionPolynomial
% structure

  mp = fpgInputsInteractive.motionPolynomials ;
  cadenceTimes.midTimestamps = [mp(1,:).mjdMidTime] ;
  if (isfield(mp,'mjdStartTime'))
      cadenceTimes.startTimestamps = [mp(1,:).mjdStartTime] ;
  else
      cadenceTimes.startTimestamps = cadenceTimes.midTimestamps ;
  end
  if (isfield(mp,'mjdEndTime'))
      cadenceTimes.endTimestamps = [mp(1,:).mjdEndTime] ;
  else
      cadenceTimes.endTimestamps = cadenceTimes.midTimestamps ;
  end
  cadenceTimes.gapIndicators = repmat(false,size(cadenceTimes.endTimestamps)) ;
  
% requantEnabled will be set to true, whatever the hell that means...

  cadenceTimes.requantEnabled = repmat(true,size(cadenceTimes.endTimestamps)) ;
  
% the cadenceNumbers are a simple index of the absolute cadence numbers; since FPG does
% not use them, we can put in any reasonable vector of integer values.  For simplicity,
% use zero through nCadences-1

  cadenceTimes.cadenceNumbers = 0:length(cadenceTimes.endTimestamps)-1 ;
  
% now construct the blobSeries structure for the motion polynomials:
  
% loop over mod/outs

  mpDims = size(mp) ;
  nModOuts = mpDims(1) ;
  for iModOut = 1:nModOuts 
      
%     construct a filename for the motion polynomial blob on this mod/out

      fileTimestamp = datestr(now,30) ;
      mpBlobFilename = ['motionPoly_m',num2str(mp(iModOut,1).module),'_o',...
          num2str(mp(iModOut,1).output),'_',fileTimestamp,'_blob.mat'] ;

%     convert the motionPolyStruct to a blob and store its name in the motionBlobsStruct

      struct_to_blob( mp(iModOut,:), mpBlobFilename ) ;
      motionBlobsStruct(1,iModOut).blobFilenames{1} = mpBlobFilename ;
          
%     set the other fields -- note that we reverse the sign of status to get gap indicator
%     (true status == good == no gap == false)

      motionBlobsStruct(1,iModOut).blobIndices = zeros(mpDims(2),1) ;
      rowPolyStatus = [mp(iModOut,:).rowPolyStatus] ;
      colPolyStatus = [mp(iModOut,:).colPolyStatus] ;
      motionBlobsStruct(1,iModOut).gapIndicators = (~(rowPolyStatus & colPolyStatus) ) ;
      
%     since FPG does not use the startCadence or endCadence fields, we just need to pick
%     values which will pass validation:

      motionBlobsStruct(1,iModOut).startCadence = 0 ;
      motionBlobsStruct(1,iModOut).endCadence   = 0 ;
      
      
  end % loop over mod/outs
  
% geometry model -- this comes from the raDec2Pix geometry model and is stored as a blob
% file

  gm = fpgInputsInteractive.raDec2PixModel.geometryModel ;
  fileTimestamp = datestr(now,30) ;
  gmFilename = ['geometryModelBlob_fpgInput_',fileTimestamp,'.mat'] ;
  struct_to_blob( gm, gmFilename ) ;
  
% assemble the new data structure

  fpgInputsPipeline.version = 1 ;
  fpgInputsPipeline.debug = false ;
  fpgInputsPipeline.fcConstants = fpgInputsInteractive.fcConstants ;
  fpgInputsPipeline.timestampSeries = cadenceTimes ;
  fpgInputsPipeline.fpgModuleParameters = fpgConfigurationStruct ;
  fpgInputsPipeline.raDec2PixModel = fpgInputsInteractive.raDec2PixModel ;
  fpgInputsPipeline.motionBlobsStruct = motionBlobsStruct ;
  fpgInputsPipeline.geometryBlobFileName = gmFilename ;
    
% and that's it!

%
%
%

