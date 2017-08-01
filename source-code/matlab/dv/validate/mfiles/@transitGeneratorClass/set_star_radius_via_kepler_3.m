function planetModel = set_star_radius_via_kepler_3( transitObject, planetModel, ...
    oldOrbitalPeriod, fitType )
%
% set_star_radius_via_kepler_3 -- transitGeneratorClass method which wraps calls to
% transitGeneratorClass method kepler_third_law
%
% planetModel = set_star_radius_via_kepler_3( transitObject, planetModel,
%    oldOrbitalPeriod, fitType ) takes a transitGeneratorClass object and a planet model
%    with updated values of some physical parameters plus the orbital period, and replaces
%    it with an equivalent model in which only the physical parameters are updated and the
%    orbital period is set back to its non-updated value.  When the planetModel is set
%    into the transitGeneratorClass object, the orbital period will be reset to its
%    updated value.  This is necessary because the transitGeneratorClass allows either its
%    physical or its observable parameters to be updated, but not a mixture.  The
%    transformation is only performed if fitType == 1 or 2.
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
  
% Use Kepler's 3rd law to compute the correct value of the star radius  

  if fitType ~= 0
    planetModel.starRadiusSolarRadii = kepler_third_law( ...
          transitObject, ...
          planetModel.semiMajorAxisAu, [], ...
          planetModel.orbitalPeriodDays ) ;
      
% put back the original orbital period -- when the planet model is set into the object
% later, the orbital period will be updated to the desired (current) value from the
% semi-major axis and the star radius, that way the changes in the planet model will be
% entirely confined to the physical parameters

    planetModel.orbitalPeriodDays = oldOrbitalPeriod ;
    
  end
  
return

% and that's it!

%
%
%
