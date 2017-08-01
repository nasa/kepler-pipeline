function self = test_find_transit_cadences( self )
%
% test_find_transit_cadences -- unit test of find_transit_cadences method of
% transitGeneratorCollectionClass
%
% test_find_transit_cadences tests the following functionality of the
%    find_transit_cadences method:
%
% ==> basic functionality -- method executes correctly
% ==> When the epoch of one embedded object is changed, the cadence numbers for that
%     object change but the cadence numbers for other objects do not.
%
% This is a unit test in the mlunit context.  To execute just this unit test, use the
% following syntax:
%
%   run(text_test_runner, testTransitGeneratorCollectionClass('test_find_transit_cadences'));
%
% Version date:  2010-May-10.
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
%    2010-May-10, PT:
%        Updates in support of BKJD time standard.
%
%=========================================================================================

  disp(' ... testing transitGeneratorCollectionClass get method ... ') ;
  
% initialize with the correct transit model

  testTransitGeneratorCollectionClass_initialization ;
  transitObject = transitGeneratorCollectionClass( transitModel, 2 ) ;
  
% get the cadence numbers for the first transit from objects 1 and 2; they should agree

  cadences1 = find_transit_cadences( transitObject, 1, 1, 1.0 ) ;
  cadences2 = find_transit_cadences( transitObject, 2, 1, 1.0 ) ; 
  assert_equals( cadences1, cadences2, ...
      'Cadences for transit 1, objects 1 and 2, do not agree' ) ;
  
% move the epoch for the first embedded object by about 1 cadence

  planetModel = get( transitObject, 'planetModel' ) ;
  planetModel(1).transitEpochBkjd = planetModel(1).transitEpochBkjd + 0.0205 ;
  transitObject = set( transitObject, 'planetModel', planetModel ) ;
  
% get the cadences again

  cadences3 = find_transit_cadences( transitObject, 1, 1, 1.0 ) ;
  cadences4 = find_transit_cadences( transitObject, 2, 1, 1.0 ) ;
  assert_equals( cadences3-1, cadences4, ...
      'Cadences for transit 1, objects 1 and 2, do not have correct offset' ) ;
  assert_equals( cadences4, cadences2, ...
      'Cadences for transit 1, object 2, before and after set do not agree' ) ;
  
  disp(' ') ;
  
return

% and that's it!

%
%
%

