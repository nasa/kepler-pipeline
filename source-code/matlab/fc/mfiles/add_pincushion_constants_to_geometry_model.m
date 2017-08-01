function geometryModelUpdated = add_pincushion_constants_to_geometry_model( ...
    geometryModelOld )
%
% add_pincushion_constants_to_geometry_model -- update an old geometry model struct to
% include constants for pincushion parameters
%
% geometryModelUpdated = add_pincushion_constants_to_geometry_model( geometryModelOld )
%    takes an existing geometry model struct, adds zero-valued constants for pincushion
%    parameters, and returns the updated geometry model.  The resulting geometry model is
%    now consistent with the new (as of 2009-April-22) requirements of the geometryClass.
%
% Version date:  2009-April-22.
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

% Hard-coded constants:  the old size of a geometry array, and the new size

  oldGeometryArrayLength = 336 ;
  newGeometryArrayLength = 420 ;
  
  geometryModelUpdated = geometryModelOld ;
  
% loop over the constants and uncertainty structs in the geometry model

  nModels = length(geometryModelUpdated.mjds) ;
  for iModel = 1:nModels
      
      if ( length(geometryModelUpdated.constants(iModel).array) == oldGeometryArrayLength )
          geometryModelUpdated.constants(iModel).array( ...
              oldGeometryArrayLength+1:newGeometryArrayLength ) = 0 ;
      elseif ( length(geometryModelUpdated.constants(iModel).array) == newGeometryArrayLength )
          continue ;
      else % length is neither old nor new length
          error( 'matlab:fc:addPincushionConstantsToGeometryModel:constantsWrongLength', ...
              'add_pincushion_constants_to_geometry_model:  constants array has wrong length' ) ;
      end
      
      if ( length(geometryModelUpdated.uncertainty(iModel).array) == oldGeometryArrayLength )
          geometryModelUpdated.uncertainty(iModel).array( ...
              oldGeometryArrayLength+1:newGeometryArrayLength ) = 0 ;
      elseif ( length(geometryModelUpdated.uncertainty(iModel).array) == newGeometryArrayLength )
          continue ;
      else % length is neither old nor new length
          error( 'matlab:fc:addPincushionConstantsToGeometryModel:uncertaintyWrongLength', ...
              'add_pincushion_constants_to_geometry_model:  uncertainty array has wrong length' ) ;
      end
      
  end
  
return

% and that's it!

%
%
%
