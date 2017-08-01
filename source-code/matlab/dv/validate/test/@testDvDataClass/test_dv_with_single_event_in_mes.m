function self = test_dv_with_single_event_in_mes( self )
%
% test_dv_with_single_event_in_mes -- this is a unit test of the DV validation and fitting
% algorithms for cases in which the flux time series contains a single large single event
% statistic which results in a significant (but spurious) multiple event statistic.
%
% This test exercises the following functionality:
%
% ==> The data structure is passed through the validation phase even though both targets
%     have a period of -1 from TPS
% ==> Both bad periods are detected in the fitter and the appropriate alerts are raised
% ==> No fitting is performed on either target.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testDvDataClass('test_dv_with_single_event_in_mes'));
%
% Version date:  2010-February-18.
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
%
%=========================================================================================


  disp('... testing DV with targets where MES contains a single SES ... ')
  
  initialize_soc_variables ;
  testDataDir = fullfile(socTestDataRoot, 'dv', 'unit-tests', 'dvDataClass-fit-related');

  load( fullfile( testDataDir, 'mes-with-single-ses-test-data' ) ) ;

  % TODO Delete if test data updated.
  dvDataStruct = dv_convert_62_data_to_70(dvDataStruct); %#ok<NODEF>
  
% The struct should be completely set up already, but just in case, do all the necessary
% set-up here (also this way people reading this code can see how the test is triggered)

% first, make sure that the orbital period from TPS is set to -1

  dvDataStruct.targetStruct(1).thresholdCrossingEvent.orbitalPeriod = -1 ;
  dvDataStruct.targetStruct(2).thresholdCrossingEvent.orbitalPeriod = -1 ;
  
% then, make sure that there is a single SES in each target's flux time series, so that
% the DV-TPS call will also result in an orbital period of -1
  
  fluxval = 1 + 50e-6 * randn(3000,1) ;
  fluxval(495:506) = fluxval(495:506) - 0.01 ;
  fluxval = fluxval * 1e7 ;
  
  dvDataStruct.targetStruct(1).correctedFluxTimeSeries.values = fluxval ;
  dvDataStruct.targetStruct(2).correctedFluxTimeSeries.values = fluxval ;
  
% prepend the blob names with the path to the test data

  dvDataStruct.targetTableDataStruct.backgroundBlobs.blobFilenames{1} = ...
      fullfile( testDataDir, ...
      dvDataStruct.targetTableDataStruct.backgroundBlobs.blobFilenames{1} ) ;
  dvDataStruct.targetTableDataStruct.motionBlobs.blobFilenames{1} = ...
      fullfile( testDataDir, ...
      dvDataStruct.targetTableDataStruct.motionBlobs.blobFilenames{1} ) ;
  
% prepare the raDec2PixModel path name

  dvDataStruct.raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');
  
% Finally, set the MES / SES ratio test to zero (otherwise the MES / SES alert will be
% triggered, rather than the orbital period alert)

  dvDataStruct.planetFitConfigurationStruct.minEventStatisticRatio = 0 ;
  
% run the structure through the dv_matlab_controller

  dvResultsStruct = dv_matlab_controller( dvDataStruct ) ;
  
% Test the outputs:

% Test 1:  the planet fits are not performed

  planetResults1 = dvResultsStruct.targetResultsStruct(1).planetResultsStruct.allTransitsFit ;
  planetResults2 = dvResultsStruct.targetResultsStruct(2).planetResultsStruct.allTransitsFit ;
  noPlanetFit = isequal( planetResults1.modelChiSquare, -1 ) ;
  noPlanetFit = noPlanetFit && isequal( planetResults2.modelChiSquare, -1 ) ;
  noPlanetFit = noPlanetFit && isequal( planetResults1.modelDegreesOfFreedom, -1 ) ;
  noPlanetFit = noPlanetFit && isequal( planetResults2.modelDegreesOfFreedom, -1 ) ;
  noPlanetFit = noPlanetFit && isequal( planetResults1.robustWeights, zeros(3000,1) ) ;
  noPlanetFit = noPlanetFit && isequal( planetResults2.robustWeights, zeros(3000,1) ) ;
  noPlanetFit = noPlanetFit && isempty( planetResults1.modelParameters ) ;
  noPlanetFit = noPlanetFit && isempty( planetResults2.modelParameters ) ;
  noPlanetFit = noPlanetFit && isempty( planetResults1.modelParameterCovariance ) ;
  noPlanetFit = noPlanetFit && isempty( planetResults2.modelParameterCovariance ) ;
  
  mlunit_assert( noPlanetFit, ...
      'Planet fit was performed!' ) ;
  
% test 2:  there are 2 alerts, 1 for each target, and they are the correct alerts

  alert1 = strfind( dvResultsStruct.alerts(1).message, ...
      'Threshold Crossing Event orbital period < 0 (target=1' ) ;
  alert2 = strfind( dvResultsStruct.alerts(2).message, ...
      'Threshold Crossing Event orbital period < 0 (target=2' ) ;
  
  mlunit_assert( ~isempty(alert1), ...
      'Target 1 alert not properly issued!' ) ;
  mlunit_assert( ~isempty(alert2), ...
      'Target 2 alert not properly issued!' ) ;
  
  
return

% and that's it!

%
%
%
