function geometryChangeStruct = compute_changed_geometry( mainHandle )
%
% geometryChangeStruct = compute_changed_geometry( mainHandle ) :
%
% function which calculates the change in geometry from the current to the fitted.  If
% called with its argument == 0, then it returns a zero structure with the correct format.
%
% Version date:  2009-February-17.
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


% construct a zero structure with the desired format

  parameterZeroStruct.value = 0 ;
  parameterZeroStruct.uncertainty = 0 ;
  geometryChangeStruct.angle3ChangeDegrees = parameterZeroStruct ;
  geometryChangeStruct.angle2ChangeDegrees = parameterZeroStruct ;
  geometryChangeStruct.angle1ChangeDegrees = parameterZeroStruct ;
  geometryChangeStruct.rowChangePixels      = parameterZeroStruct ;
  geometryChangeStruct.columnChangePixels   = parameterZeroStruct ;
  geometryChangeStruct.rotationChangePixels = parameterZeroStruct ;
  geometryChangeStruct.chisq                = 0 ;
  geometryChangeStruct.ndof                 = 0 ;
  
% continue filling in if the argument ain't zero and if there is an fpgFitClass object
  
  if ( mainHandle ~= 0 && ~isempty(getappdata(mainHandle,'fpgFitObject')))

%     get the fpgFitObject and convert to a struct via the get(*) method
      
      fpgFitObject = getappdata(mainHandle,'fpgFitObject') ;
      fpgFitStruct = get(fpgFitObject,'*') ;
      
%     replace the initialParValues with the ones from the current geometry and
%     reinstantiate

      currentGeometry = getappdata(mainHandle,'currentGeometry') ;
      ccdNumber = getappdata(mainHandle,'ccdNumber') ;
      angle1Index = 3*ccdNumber ;
      fpgFitStruct.initialParValues = ...
          currentGeometry.constants(1).array(angle1Index-2:angle1Index) ;
      
%     make an fpgResultsClass struct which has nothing but the fpgFitStruct in it as a
%     sub-field (we only need one fpgResultsClass method, and it uses only the embedded
%     fpgFitClass object)

      fpgResultsStruct.fpgFitClass = fpgFitStruct ;
      fpgResultsStruct.fitParsRowColumn = [] ;
      fpgResultsStruct.parCovarianceRowColumn = [] ;
      fpgResultsObject = fpgResultsClass(fpgResultsStruct) ;
      
%     compute the dRow, dColumn values

      fpgResultsObject = convert_fit_pars_to_row_column(fpgResultsObject) ;
      
%     fill in the values in the structure

      geometryChangePixels = get(fpgResultsObject,'fitParsRowColumn') ;
      geometryCovariancePixels = get(fpgResultsObject,'parCovarianceRowColumn') ;
      geometryChangeStruct.rowChangePixels.value = geometryChangePixels(1) ;
      geometryChangeStruct.rowChangePixels.uncertainty = ...
          sqrt(geometryCovariancePixels(1,1)) ;
      geometryChangeStruct.columnChangePixels.value = geometryChangePixels(2) ;
      geometryChangeStruct.columnChangePixels.uncertainty = ...
          sqrt(geometryCovariancePixels(2,2)) ;
      geometryChangeStruct.rotationChangePixels.value = geometryChangePixels(3) ;
      geometryChangeStruct.rotationChangePixels.uncertainty = ...
          sqrt(geometryCovariancePixels(3,3)) ;
      
%     scale the rotation change from degrees to pixels -- in this case, it's given by
%     dTheta * R, where R is the distance from the center of the CCD to the most distant
%     pixel (the corner)

      ccdImage = getappdata(mainHandle,'ccdImage') ;
      imageSize = size(ccdImage) ;
      ccdRadius = sqrt(imageSize(2)^2 + (imageSize(1)/2)^2) ;
      degreesToRadians = pi/180 ;
      geometryChangeStruct.rotationChangePixels.value = ...
          geometryChangeStruct.rotationChangePixels.value * degreesToRadians * ccdRadius ;
      geometryChangeStruct.rotationChangePixels.uncertainty = ...
          geometryChangeStruct.rotationChangePixels.uncertainty * degreesToRadians * ccdRadius ;
      
%     now fill in the changes and uncertainties in the 3-2-1 angles

      geometryChangeStruct.angle3ChangeDegrees.value = ...
          fpgFitStruct.finalParValues(1) - fpgFitStruct.initialParValues(1) ;
      geometryChangeStruct.angle3ChangeDegrees.uncertainty = ...
          sqrt( fpgFitStruct.parValueCovariance(1,1) ) ;
      geometryChangeStruct.angle2ChangeDegrees.value = ...
          fpgFitStruct.finalParValues(2) - fpgFitStruct.initialParValues(2) ;
      geometryChangeStruct.angle2ChangeDegrees.uncertainty = ...
          sqrt( fpgFitStruct.parValueCovariance(2,2) ) ;
      geometryChangeStruct.angle1ChangeDegrees.value = ...
          fpgFitStruct.finalParValues(3) - fpgFitStruct.initialParValues(3) ;
      geometryChangeStruct.angle1ChangeDegrees.uncertainty = ...
          sqrt( fpgFitStruct.parValueCovariance(3,3) ) ;
      
%     fill in chisq and ndof

      [geometryChangeStruct.chisq geometryChangeStruct.ndof] = fpg_chisq( ...
          fpgFitClass(fpgFitStruct),0,0,0) ;
          
  end % mainHandle ~= 0 etc conditional
  
return

% end of change computing function

%
%
%

%=========================================================================================
