function raDec2PixObject = put_geometry_pars_in_raDec2PixObject( modelParameters, ...
      raDec2PixObject, geometryParMap, plateScaleParMap, pincushionScaleFactor ) 
%
% put_geometry_pars_in_raDec2PixObject -- function which takes a vector of model
% parameters and inserts it into an raDec2PixClass object, making use of the parameter
% maps which are passed to it.  This is a private helper function of the fpgFitClass.
%
% Version date:  2009-May-02.
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
%    2009-May-02, PT:
%        support for fitting 1 plate scale and 1 pincushion per CCD.
%    2009-April-23, PT:
%        support for pincushion parameter fits.
%
%=========================================================================================  
  
% get the geometry model out of the raDec2PixClass object

  geometryModel = get(raDec2PixObject,'geometryModel') ;
  nGM = length(geometryModel.constants) ;

% find the parameters which have been fitted, and their order in the modelParameters
% vector 
  
  fittedGeometryParameters = find(geometryParMap ~= 0) ;
  nFittedGeometryParameters = length(fittedGeometryParameters) ;
  
% put the model parameters into the geometry model
  
  geometryModel.constants(1).array(fittedGeometryParameters) = ...
      modelParameters(1:nFittedGeometryParameters) ;

% If the plate scale and pincushion are fitted, then they are 1 per CCD.  The data is in
% the geometry model at the level of 1 per mod/out, so each value in the modelParameters
% array has to go into 2 slots in the geometry model
  
    fittedPlateScales = find(plateScaleParMap(:,1)~=0) ;
    nFittedPlateScales = length(fittedPlateScales) ;
    modelParIndex = nFittedGeometryParameters + (1:nFittedPlateScales) ;
    if (~isempty(fittedPlateScales))
        geometryModel.constants(1).array(252+2*fittedPlateScales-1) = ...
            modelParameters(modelParIndex) ;
        geometryModel.constants(1).array(252+2*fittedPlateScales) = ...
            modelParameters(modelParIndex) ;
        geometryModel.constants(1).array(336+2*fittedPlateScales-1) = ...
            modelParameters(modelParIndex+nFittedPlateScales) / pincushionScaleFactor ;
        geometryModel.constants(1).array(336+2*fittedPlateScales) = ...
            modelParameters(modelParIndex+nFittedPlateScales) / pincushionScaleFactor ;
    end
  
  for iGM = 2:nGM
      geometryModel.constants(iGM) = geometryModel.constants(1) ;
  end
  
% put the geometry model back into the raDec2PixClass object
  
  raDec2PixObject = set(raDec2PixObject,'geometryModel',geometryModel) ;
  
% and that's it!

%
%
%
