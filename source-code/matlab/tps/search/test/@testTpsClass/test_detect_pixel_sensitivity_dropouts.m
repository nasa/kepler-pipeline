function self = test_detect_pixel_sensitivity_dropouts( self )
%
% test_detect_pixel_sensitivity_dropouts -- test detection of Sudden Pixel Sensitivity
% Dropouts (SPSD) in TPS
%
% This unit test exercises basic functionality of the SPSD detector in TPS:
%
% ==> The test detects a pixel sensitivity dropout when configured nominally
% ==> When the detection threshold is raised, the detection does not occur.
%
% This test is performed in the mlunit context.  For standalone operation, use the
% following syntax:
%
%      run(text_test_runner, testTpsClass('test_detect_pixel_sensitivity_dropouts'));
%
% Version date:  2011-February-18.
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

  disp(' ... testing sudden-pixel-sensitivity-dropout detection method ... ') ;

% set the test data path and retrieve the input struct 

  tpsDataFile = 'tps-spsd-workspace' ;
  tpsDataStructName = 'tpsStruct' ;
  tps_testing_initialization ;

% With recent changes, the data struct for the SPSD doesn't quite trigger the detector
% (it's misidentified as an outrider to a giant transit).  Adjust the transit depth
% threshold so that the detection will be exercised properly

% validate to get inputs added

  tpsStruct = validate_tps_input_structure( tpsStruct ) ;  
  tpsStruct.tpsModuleParameters.searchTransitThreshold = 10 ;
  
% instantiate the tpsClass object

  tpsObject = tpsClass( tpsStruct ) ;
  
% detect the cadences in the SPSD event, and compare to expected

  dropoutCadences = detect_pixel_sensitivity_dropouts( tpsObject, tpsResults, ...
      extendedFlux ) ;
  mlunit_assert( isequal(dropoutCadences, dropoutCadencesExpected), ...
      'Detected SPSD cadences not as expected!' ) ;
  
% set the detection threshold very high and rerun

  tpsStruct.tpsModuleParameters.pixelSensitivityDropoutThreshold = 5000 ;
  tpsObject = tpsClass( tpsStruct ) ;
  dropoutCadences = detect_pixel_sensitivity_dropouts( tpsObject, tpsResults, ...
      extendedFlux ) ;
  
  mlunit_assert( isempty( find( dropoutCadences, 1 ) ) , ...
      'SPSD cadences detected with ultra-high threshold!' ) ;
  disp('') ;
  
return

