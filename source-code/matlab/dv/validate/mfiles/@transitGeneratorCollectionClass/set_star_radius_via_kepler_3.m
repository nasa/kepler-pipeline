function planetModel = set_star_radius_via_kepler_3( transitObject, planetModel, ...
    oldOrbitalPeriodVector, fitTypeVector )
%
% set_star_radius_via_kepler_3 -- transitGeneratorCollectionClass method which manages
% calls to transitGeneratorClass method kepler_third_law
%
% planetModel = set_star_radius_via_kepler_3( transitObject, planetModel,
%    oldOrbitalPeriodVector, fitTypeVector ) takes the new orbital periods in the
%    planetModel and replaces them with the original values of the orbital periods; at the
%    same time, it replaces the star radii in the planet model with the values which lead
%    to the desired orbital period.  This way the planet model contains changes only in
%    its physical parameters, rather than a mixture of physical and observable parameters,
%    but at the same time allows the fitter to vary the orbital period along with a number
%    of physical parameters.  The function only operates on transit models for which the
%    fitType is 1 or 2, so that fitType 0 models (which have their star radius fixed at
%    the KIC value) do not undergo such changes.
%
% Version date:  2010-April-27.
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

% loop over objects
  
  nObjects = length( transitObject.transitGeneratorObjectVector ) ;
  for iObject = 1:nObjects
      
      planetModel(iObject) = set_star_radius_via_kepler_3( ...
          transitObject.transitGeneratorObjectVector(iObject), ...
          planetModel(iObject), oldOrbitalPeriodVector(iObject), fitTypeVector(iObject) ) ;
      
%     put back the original orbital period -- when the planet model is set into the
%     object later, the orbital period will be updated to the desired (current) value
%     from the semi-major axis and the star radius, that way the changes in the planet
%     model will be entirely confined to the physical parameters

      planetModel(iObject).orbitalPeriodDays = oldOrbitalPeriodVector( iObject ) ;  
      
  end
  
return

% and that's it!

%
%
%
