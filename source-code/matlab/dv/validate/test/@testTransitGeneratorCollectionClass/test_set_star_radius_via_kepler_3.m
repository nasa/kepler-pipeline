function self = test_set_star_radius_via_kepler_3( self ) 
%
% test_set_star_radius_via_kepler_3 -- unit test of transitGeneratorCollectionClass method
% set_star_radius_via_kepler_3
%
% This unit test exercises the following functionality of the
% transitGeneratorCollectionClass method set_star_radius_via_kepler_3:
%
% ==> For fitType == 1 or fitType == 2, the star radius is changed and the orbital period
%     is restored to its old value
% ==> For fitType == 0, no changes are made to the planet model.
% 
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitGeneratorCollectionClass('test_set_star_radius_via_kepler_3'));
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

  disp('... testing set_star_radius_via_kepler_3 method ... ')
  
% initialize with the correct transit model

  testTransitGeneratorCollectionClass_initialization ;
  transitObject = transitGeneratorCollectionClass( transitModel, 2 ) ;
  
% get the initial planet model

  planetModel = get( transitObject, 'planetModel' ) ;
  
% set new values into the planet model and capture the old ones

  oldOrbitalPeriod = [planetModel.orbitalPeriodDays] ;
  oldStarRadius    = [planetModel.starRadiusSolarRadii] ;
  
  for iObject = 1:length( planetModel )
      planetModel(iObject).planetRadiusEarthRadii = ...
          planetModel(iObject).planetRadiusEarthRadii * 1.01 ;
      planetModel(iObject).semiMajorAxisAu = ...
          planetModel(iObject).semiMajorAxisAu * 1.01 ;
  end
  planetModel(1).orbitalPeriodDays = planetModel(1).orbitalPeriodDays + 1 ;
  planetModel(2).minImpactParameter = 0.001 ;
  
  fitType = [1 0 2 2 2 2] ;
  
  newPlanetModel = set_star_radius_via_kepler_3( transitObject, planetModel, ...
      oldOrbitalPeriod, fitType ) ;
  newStarRadius    = [newPlanetModel.starRadiusSolarRadii] ;
  newOrbitalPeriod = [newPlanetModel.orbitalPeriodDays] ;
  
  starRadiusChanged    = newStarRadius ~= oldStarRadius ;
  orbitalPeriodChanged = newOrbitalPeriod ~= oldOrbitalPeriod ;
  
  starRadiusCorrect    = all( isequal( starRadiusChanged, [true false true true true true] ) ) ;
  orbitalPeriodCorrect = all( ~orbitalPeriodChanged ) ;
  
  mlunit_assert( starRadiusCorrect, 'star radii not correct' ) ;
  mlunit_assert( orbitalPeriodCorrect, 'orbital periods not correct' ) ;
  
  disp(' ') ;
  
return

% and that's it!

%
%
%
