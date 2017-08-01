function fpgFitObject = update_initial_parameters( fpgFitObject, oldFpgFitObject, ...
    useInitialValues)
%
% UPDATE_INITIAL_PARAMETERS -- copy the FPG fit parameters from one fpgFitObject for use
% as initial parameters for another fpgFitObject.
%
% fpgFitObject = update_initial_parameters( fpgFitObject, oldFpgFitObject ) takes the fit
%    parameters from its second fpgFitClass argument, oldFpgFitObject, and transfers them
%    for use as initial parameters in the first fpgFitClass argument, fpgFitObject.  The
%    information which is transferred is as follows:
%
%        If oldFpgFitObject fitted the geometry parameters, those parameters are inserted
%           into the raDec2PixObject of the fpgFitObject (so it can use an up-to-date
%           initial geometry for its fits)
%
%       If oldFpgFitObject and fpgFitObject both fit the geometry parameters, those
%           parameters are copied to the initialParValues member of fpgFitObject, so that
%           fpgFitObject's geometry fit can start with the best current estimate of the
%           geometry from a previous fit.
%
%       If oldFpgFitObject and fpgFitObject both fit the spacecraft pointing for the same
%           cadence, the pointing fit from oldFpgFitObject is copied to the
%           initialParValues member of fpgFitObject so that the latter can use the best
%           estimate of the cadence pointings for all cadence pointing fits.
%
% fpgFitObject = update_initial_parameters(..., useInitialValues) copies the initial
%    values from oldFpgFitObject to fpgFitObject if useInitialValues is true.
%
% Version date:  2008-April-23.
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
%    2009-April-23, PT:
%        support for pincushion parameter.
%
%=========================================================================================

% is useInitialValues present?  If not, it is by default false

  if (nargin == 2)
      useInitialValues = false ;
  end

% get the data we really need from the oldFpgFitObject: its fitGeometryFlag, its mjd
% vector, its cadence RA/Dec/Roll maps, its geometry parameter maps, and its final
% parameter values.


  oldFitGeometryFlag = get(oldFpgFitObject,'fitGeometryFlag') ;
  oldGeometryParMap = get(oldFpgFitObject,'geometryParMap') ;
  oldPlateScaleParMap = get(oldFpgFitObject,'plateScaleParMap') ;
  oldCadenceRAMap = get(oldFpgFitObject,'cadenceRAMap') ;
  oldCadenceDecMap = get(oldFpgFitObject,'cadenceDecMap') ;
  oldCadenceRollMap = get(oldFpgFitObject,'cadenceRollMap') ;
  oldPincushionScaleFactor = get(oldFpgFitObject,'pincushionScaleFactor') ;
  oldMjd = get(oldFpgFitObject,'mjd') ;
  
  if (~useInitialValues)
      oldFinalParValues = get(oldFpgFitObject,'finalParValues') ;
  else
      oldFinalParValues = get(oldFpgFitObject,'initialParValues') ;
  end
  
% get rid of the old object for the sake of cleanliness, and make sure that the fit
% actually happened

  clear oldFpgFitStruct oldFpgFitObject ;
  
  if (~isempty(oldFinalParValues))
      
%     if a geometry fit was done on the old fit, copy its geometry parameters to their
%     correct locations in the geometryModel of the new fit's raDec2PixObject.  Remember
%     that plate scale / pincushion parameters are fitted as 1 per CCD but stored as 1 per
%     mod/out, so each plate scale / pincushion value has to go into 2 slots in the model

      if (oldFitGeometryFlag)
          
          geometryModel = get(fpgFitObject.raDec2PixObject,'geometryModel') ;
          geometryParIndex = find(oldGeometryParMap ~= 0) ;
          geometryModel.constants(1).array(geometryParIndex) = ...
              oldFinalParValues(1:length(geometryParIndex)) ;
          
          plateScaleParIndex = find(oldPlateScaleParMap(:,1) ~= 0) ;
          nGeometryPars = length(geometryParIndex) ;
          nPlateScales = length(plateScaleParIndex) ;
          modelParIndex = nGeometryPars + (1:nPlateScales) ;
          if (~isempty(plateScaleParIndex))
              geometryModel.constants(1).array(252+2*plateScaleParIndex-1) = ...
                  oldFinalParValues(modelParIndex) ;
              geometryModel.constants(1).array(252+2*plateScaleParIndex) = ...
                  oldFinalParValues(modelParIndex) ;
              geometryModel.constants(1).array(336+2*plateScaleParIndex-1) = ...
                  oldFinalParValues(modelParIndex+nPlateScales) / ...
                  oldPincushionScaleFactor ;
              geometryModel.constants(1).array(336+2*plateScaleParIndex) = ...
                  oldFinalParValues(modelParIndex+nPlateScales) / ...
                  oldPincushionScaleFactor ;
          end

          for iGM = 2:length(geometryModel.constants)
              geometryModel.constants(iGM).array = geometryModel.constants(1).array ;
          end
          
          fpgFitObject.raDec2PixObject = set(fpgFitObject.raDec2PixObject,...
              'geometryModel',geometryModel) ;
          
%         if the later fit is also performing a geometry fit, then copy the results of the
%         old fit for use as the starting point of the new fit.  Note that the old and new
%         fits can have different mappings of their geometry parameters.  The easiest way
%         to get this right is to extract the initial values for fpgFitObject from the
%         geometryModel, rather than the oldFinalParValues vector itself.

          if (fpgFitObject.fitGeometryFlag)
              
              geometryParIndex = find(fpgFitObject.geometryParMap ~= 0) ;
              fpgFitObject.initialParValues(1:length(geometryParIndex)) = ...
                  geometryModel.constants(1).array(geometryParIndex) ;
              plateScaleParMapToFit = find(fpgFitObject.plateScaleParMap(:,1)~=0) ;
              plateScalePars = fpgFitObject.plateScaleParMap(plateScaleParMapToFit,1) ;
              pincushionPars = fpgFitObject.plateScaleParMap(plateScaleParMapToFit,2) ;
              if (~isempty(plateScaleParMapToFit))
                  fpgFitObject.initialParValues(plateScalePars) = ...
                      geometryModel.constants(end).array(252 + plateScaleParMapToFit*2) ;
                  fpgFitObject.initialParValues(pincushionPars) = ...
                      geometryModel.constants(end).array(336 + plateScaleParMapToFit*2) * ...
                      oldPincushionScaleFactor ;
              end
              
          end
          
      end % oldFitGeometryFlag conditional
  
%     Now we capture the pointing parameters from the old fit and insert them into the new
%     one.  This is accomplished by looping over the MJDs in the old fit, and looking to
%     see (1) whether that MJD had any pointing fits, and (2) whether it's in the new fit;
%     if both conditions are met, perform the copy.  The assumption is made that if the
%     pointing of a cadence was performed on the old fit, and that cadence is used on the
%     new fit, then the pointing has to be fitted on the new fit as well.  Note that we
%     only do this if the old fit had pointing parameters in it.

      if (~isempty(oldCadenceRAMap))

          for iCadence = 1:length(oldMjd)

              cadenceIndex = find(fpgFitObject.mjd == oldMjd(iCadence)) ;
              if ( (~isempty(cadenceIndex)) && (oldCadenceRAMap(iCadence) ~= 0) )
                  raPointer   = fpgFitObject.cadenceRAMap(cadenceIndex) ;
                  decPointer  = fpgFitObject.cadenceDecMap(cadenceIndex) ;
                  rollPointer = fpgFitObject.cadenceRollMap(cadenceIndex) ;

                  fpgFitObject.initialParValues(raPointer) = ...
                      oldFinalParValues(oldCadenceRAMap(iCadence)) ;
                  fpgFitObject.initialParValues(decPointer) = ...
                      oldFinalParValues(oldCadenceDecMap(iCadence)) ;
                  fpgFitObject.initialParValues(rollPointer) = ...
                      oldFinalParValues(oldCadenceRollMap(iCadence)) ;
              end

          end
          
      end
      
% here's the end of the conditional on oldFinalParValues.  If the oldFinalParValues vector
% is empty, then the old fpgFitObject is returned unmodified.

  end
  
% and that's it!

%
%
%