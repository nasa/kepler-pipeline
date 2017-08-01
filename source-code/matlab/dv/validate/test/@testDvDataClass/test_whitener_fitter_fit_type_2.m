function self = test_whitener_fitter_fit_type_2( self )
%
% test_whitener_fitter_fit_type_2 -- test perform_iterative_whitening_and_model_fitting
% method of dvDataClass for fit type 2 (orbital period not fit due to only 1 transit
% present)
%
% This unit test exercises the following functionality of the dvDataClass method which
% performs the iterative whitening and fitting of the flux time series:
%
% ==> Basic functionality -- runs to completion with valid inputs and gets correct answers
%     based on a regression test
% ==> Fits odd-only or even-only transits correctly, and correctly inserts the results 
%     into the planet results structure
% ==> Gaps and fills which are present in the flux time series sent into the fit are
%     properly handled by the fit (ie, treated as points which are not to be used in the
%     fit).  Technically this is functionality of the overall method and not just the type
%     2 fits, but incorporating this test into the type 2 unit test incurred the minimum
%     penalty for test execution (ie, none).
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testDvDataClass('test_whitener_fitter_fit_type_2'));
%
% Version date:  2009-December-17.
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
%    2010-May-03, PT:
%        updates in support of transitGeneratorCollectionClass.
%
%=========================================================================================

  
  disp('... testing iterative whitener-fitter method, fit type 2 ... ')
  
  testDvDataClass_fitter_initialization ;
  
% roll back the results struct to match what it would have been before the fit was
% completed, but keep a copy of the results struct from the data file

  dvResultsStructAfterFit = dvResultsStruct ;
  dvResultsStruct.targetResultsStruct.planetResultsStruct = ...
      initialize_planet_results_structure( dvDataObject, ...
      dvDataStruct.targetStruct.keplerId, 1, ...
      dvDataStruct.targetStruct.thresholdCrossingEvent, ...
      dvResultsStruct.targetResultsStruct.residualFluxTimeSeries ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = targetFluxTimeSeries ;
  dvResultsStructBeforeFit = dvResultsStruct ;
  
% construct folders to contain the plots when they are generated

  dvr = create_directories_for_dv_figures( dvDataObject, dvResultsStruct ) ;

% loosen the criterion for convergence so that runs of the iterative whitener don't take
% so long 

  dvDataStruct.planetFitConfigurationStruct.convergenceTolerance = 1 ;
  dvDataObject = dvDataClass( dvDataStruct ) ;
  
% remove all the transits after the second one and repeat odd-even non-robust fitting, and
% confirm that fitType 2 is being used in this case

  transitModelCentralTransit = convert_tps_parameters_to_transit_model( dvDataObject, ...
      1, tceForWhitenerTest, targetFluxTimeSeries ) ;
  modelParameters = ...
      dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.allTransitsFit.modelParameters ;
  transitModelCentralTransit.planetModel = modelParameters ;
  transitObjectCentralTransit = transitGeneratorClass( transitModelCentralTransit ) ;

  dvResultsStruct = dvResultsStructBeforeFit ;
  dvResultsStruct.targetResultsStruct.planetResultsStruct.allTransitsFit = ...
      dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.allTransitsFit ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = ...
      targetFluxTimeSeries ;
  transitNumber = identify_transit_cadences( transitObjectCentralTransit, ...
      get( transitObjectCentralTransit, 'cadenceTimes' ), 1 ) ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators( ...
      transitNumber > 2 ) = true ;
    
% While we are here, set the gapIndicators and filledIndices in the data to blot out 1
% point using each approach, and show that the blotted-out points are properly tracked in
% the fitting process

  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.gapIndicators(316) = true ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.filledIndices = ...
      [dvResultsStruct.targetResultsStruct.residualFluxTimeSeries.filledIndices ; 315] ;
  dvResultsStruct = perform_iterative_whitening_and_model_fitting( dvDataObject, ...
      dvResultsStruct, tceForWhitenerTest, 1, 1, 1 ) ;
  
  oddTransitsFit = dvResultsStruct.targetResultsStruct.planetResultsStruct.oddTransitsFit ;
  allTransitsFit = dvResultsStruct.targetResultsStruct.planetResultsStruct.allTransitsFit ;
  impactParameterPointer = find( strcmp( 'minImpactParameter', ...
      {oddTransitsFit.modelParameters.name} ) ) ;
  periodPointer = find( strcmp( 'orbitalPeriodDays', ...
      {oddTransitsFit.modelParameters.name} ) ) ;
  mlunit_assert( oddTransitsFit.modelParameters(impactParameterPointer).value == 0 && ...
      oddTransitsFit.modelParameters(impactParameterPointer).uncertainty == 0 && ...
      ~oddTransitsFit.modelParameters(impactParameterPointer).fitted && ...
      abs( oddTransitsFit.modelParameters(periodPointer).value -  ...
      allTransitsFit.modelParameters(periodPointer).value ) < 1e-12 && ...
      oddTransitsFit.modelParameters(periodPointer).uncertainty < 1e-10 && ...
      ~oddTransitsFit.modelParameters(periodPointer).fitted, ...
      'Type 2 fitting behaves incorrectly for odd-transits fits' ) ;

  evenTransitsFit = dvResultsStruct.targetResultsStruct.planetResultsStruct.evenTransitsFit ;
  allTransitsFit = dvResultsStruct.targetResultsStruct.planetResultsStruct.allTransitsFit ;
  impactParameterPointer = find( strcmp( 'minImpactParameter', ...
      {evenTransitsFit.modelParameters.name} ) ) ;
  periodPointer = find( strcmp( 'orbitalPeriodDays', ...
      {evenTransitsFit.modelParameters.name} ) ) ;
  mlunit_assert( evenTransitsFit.modelParameters(impactParameterPointer).value == 0 && ...
      evenTransitsFit.modelParameters(impactParameterPointer).uncertainty == 0 && ...
      ~evenTransitsFit.modelParameters(impactParameterPointer).fitted && ...
      abs( evenTransitsFit.modelParameters(periodPointer).value -  ...
      allTransitsFit.modelParameters(periodPointer).value ) < 1e-12 && ...
      evenTransitsFit.modelParameters(periodPointer).uncertainty <1e-10 && ...
      ~evenTransitsFit.modelParameters(periodPointer).fitted, ...
      'Type 2 fitting behaves incorrectly for even-transits fits' ) ;

  mlunit_assert( evenTransitsFit.robustWeights(316) == 0 && ...
      evenTransitsFit.robustWeights(315) == 0 && ...
      oddTransitsFit.robustWeights(316) == 0 && ...
      oddTransitsFit.robustWeights(315) == 0, ...
      'Injected gapped / filled indicators not properly tracked through fit!' ) ;
  
return

% and that's it!

%
%
%
