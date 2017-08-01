function minimumGeometryModel = minimize_geometry_model( geometryModel, mjdVector )
%
% minimize_geometry_model -- reduce the geometry model used by an raDec2PixClass object to
% the minimum size required.
%
% minimumGeometryModel = minimize_geometry_model( geometryModel, mjdVector ) finds the
%    geometry models which correspond to the seasonal rolls in the mjdVector, and returns
%    a geometry model which includes just the required entries in the geometryModel
%    structure array.
%
% Version date:  2008-July-22.
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

% extract the MJDs corresponding to the start of each season

  mjdGeometryModel = [geometryModel.mjds] ;
  
% loop over the mjdVector members and figure out which geometryModel is valid for each mjd
% -- this is the geometryModel with the largest MJD which is still smaller than the mjd of
% interest (aka "The Price Is Right"-optimal value)

  requiredMjd = zeros(size(mjdVector)) ;
  for iMjd = 1:length(mjdVector)
      mjdLess = find(mjdGeometryModel <= mjdVector(iMjd)) ;
      requiredMjd(iMjd) = mjdLess(end) ;
  end
  
  requiredMjdPointer = sort(unique(requiredMjd)) ;
  
% construct the minimum geometry model

  minimumGeometryModel.mjds = geometryModel.mjds(requiredMjdPointer) ;
  minimumGeometryModel.mjds =   minimumGeometryModel.mjds(:) ;
  
  minimumGeometryModel.constants = geometryModel.constants(requiredMjdPointer) ;
  minimumGeometryModel.constants =   minimumGeometryModel.constants(:)' ;

  minimumGeometryModel.uncertainty = geometryModel.uncertainty(requiredMjdPointer) ;
  minimumGeometryModel.uncertainty =   minimumGeometryModel.uncertainty(:)' ;
  
% and that's it!

%
%
%