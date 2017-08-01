function self = test_kepler_third_law( self )
%
% test_kepler_third_law -- unit test for kepler_third_law method for transitGeneratorClass
%
% This unit test exercises the following features of kepler_third_law:
%
% ==> correct calculation of the period, star radius, and semi-major axis of a star-planet
%     system, given the other 2 parameters
% ==> an error is thrown if all 3 parameters are supplies, or if only 1 parameter is
%     supplied.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitGeneratorClass('test_kepler_third_law'));
%
% Version date:  2009-October-09.
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

  disp('... testing kepler-third-law method ... ')
  
  testTransitGeneratorClass_initialization ;

% get the length of 1 Earth year in days

  yearDays = get_unit_conversion('year2sec') * get_unit_conversion('sec2day') ;
  
% perform the 3 calculations and check their results -- note that the results do not
% exactly match expectations due to round-off and limited accuracy of some of the
% parameters in the transitObject, so we will only require them to be approximately
% correct

  semiMajorAxisAu = kepler_third_law( transitObject, [], 1, yearDays ) ;
  mlunit_assert( abs(semiMajorAxisAu - 1) < 3e-5, ...
      'semi-major axis calculation incorrect' ) ;
  
  starRadiusSolarRadii = kepler_third_law( transitObject, 1, [], yearDays ) ;
  mlunit_assert( abs(starRadiusSolarRadii - 1) < 3e-5, ...
      'star radius calculation incorrect' ) ;
  
  periodDays = kepler_third_law( transitObject, 1, 1, [] ) ;
  mlunit_assert( abs( periodDays - yearDays ) < 3e-5 * yearDays, ...
      'orbital period calculation incorrect' ) ;
  
% test all error conditions

  try_to_catch_error_condition( 'a=kepler_third_law(transitObject,[],[],[]);', ...
      'rhsArgumentsInvalid', 'caller' ) ;
  try_to_catch_error_condition( 'a=kepler_third_law(transitObject,1,[],[]);', ...
      'rhsArgumentsInvalid', 'caller' ) ;
  try_to_catch_error_condition( 'a=kepler_third_law(transitObject,[],1,[]);', ...
      'rhsArgumentsInvalid', 'caller' ) ;
  try_to_catch_error_condition( 'a=kepler_third_law(transitObject,[],[],365.25);', ...
      'rhsArgumentsInvalid', 'caller' ) ;
  try_to_catch_error_condition( 'a=kepler_third_law(transitObject,1,1,365);', ...
      'rhsArgumentsInvalid', 'caller' ) ;
  disp(' ') ;
  
return

% and that's it!

%
%
%
