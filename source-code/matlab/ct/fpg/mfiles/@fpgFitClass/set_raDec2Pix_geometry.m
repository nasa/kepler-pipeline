function fpgFitObject = set_raDec2Pix_geometry( fpgFitObject, flag, iAngle, dTheta )
%
% set_raDec2Pix_geometry -- set the geometry used in the raDec2PixClass object which is a
% member of the fpgFitClass.
%
% fpgFitObject = set_raDec2Pix_geometry( fpgFitObject, 0 ) will set the geometry in the
%    fpgFitObject to match the geometry in the fpgFitObject's initial parameters.
%
% fpgFitObject = set_raDec2Pix_geometry( fpgFitObject, 1 ) will set the geometry in the
%    fpgFitObject to match the geometry in the fpgFitObject's final parameters.
%
% fpgFitObject = set_raDec2PixGeometry( fpgFitObject, [0 or 1], iPar, dPar ) will 
%    set the geometry to the desired parameter set but also change the geometry parameter
%    iPar by quantity dPar.
%
% Version date:  2009-April-23.
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
%     2009-April-23, PT:
%         add support for pincushion parameter fits.
%     2008-July-10, PT:
%         add capability to dither parameters by small amounts in support of conversion
%         from 3-2-1 angles to row-col-rotation.
%
%=========================================================================================

% if only 3 parameters, then make dTheta equal to zero; check to make sure that iAngle is
% a valid value

  if ( nargin == 3 )
      dTheta = 0 ;
  end
  
  if  ( (nargin > 2) && (iAngle > length(fpgFitObject.initialParValues)) )
      error('fpg:setRaDec2PixGeometry:argOutOfBounds',...
          'set_raDec2Pix_geometry: 3rd argument is out of bounds') ;
  end

% if the user wants the final parameters, make sure that they are set first

  if ( flag == 1 && isempty(fpgFitObject.finalParValues) )
      error('fpg:setRaDec2PixGeometry:noFinalValues',...
          'set_raDec2Pix_geometry:  fpgFitClass final values not set') ;
  end
  
% otherwise, pretty simple

  if ( flag == 0 )
      parameters = fpgFitObject.initialParValues ;
  else
      parameters = fpgFitObject.finalParValues ;
  end
  if (nargin > 2)
      parameters(iAngle) = parameters(iAngle) + dTheta ; 
  end

  fpgFitObject.raDec2PixObject = put_geometry_pars_in_raDec2PixObject( parameters, ...
      fpgFitObject.raDec2PixObject, fpgFitObject.geometryParMap, ...
      fpgFitObject.plateScaleParMap, fpgFitObject.pincushionScaleFactor ) ;
  
% and that's it!

%
%
%