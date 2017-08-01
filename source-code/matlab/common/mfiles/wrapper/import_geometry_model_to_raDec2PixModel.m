function raDec2PixModel = import_geometry_model_to_raDec2PixModel( raDec2PixModel, ...
    geometryModelFilename )
%
% import_geometry_model_to_raDec2PixModel -- import a geometry model from a text file to
% an raDec2PixModel
%
% raDec2PixModel = import_geometry_model_to_raDec2PixModel( raDec2PixModel,
%    geometryModelFilename ) reads the geometry model in the specified file and copies its
%    values into the geometryModel substruct of the raDec2PixModel.  The file must be in
%    the format specified in KADN-26176.  Since plate scales are optional in the geometry
%    text files, if there are no plate scales in the file then the default plate scale
%    will be used.  constants substructure in the geometryModel struct is a vector, the
%    imported geometry coefficients will be inserted into each element of the constants
%    substructure vector.
%
% NB:  import_geometry_model_to_raDec2PixModel is intended for test usage only, and should
%    not be used in pipelines or other environments more serious than sitting at a
%    terminal with a Matlab prompt in front of you!
%
% Version date:  2009-March-27.
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
%    2009-March-27, PT:
%        completely scrapped first version and replaced with a version which uses
%        production Java code (ImporterGeometry class) -- much safer!
%
%=========================================================================================

% use the ImporterGeometry class to get the geometry values from the file

  import gov.nasa.kepler.fc.importer.ImporterGeometry ;
  importGeometry = ImporterGeometry() ;
  parsedGeometry = importGeometry.parseFile(geometryModelFilename) ;
  geometryVector = parsedGeometry.getConstantsArray ;
           
% copy the geometryVector into each element of the geometryModel.constants struct -- right
% now we do not attempt to determine which entries in the array are earlier than the
% geometry which is imported, and which are later, and it's not clear that we ever want to
% do that under any circumstances.

  for iGm = 1:length(raDec2PixModel.geometryModel.constants)
      raDec2PixModel.geometryModel.constants(iGm).array = geometryVector ;
  end
  
return

% and that's it!

%
%
%
