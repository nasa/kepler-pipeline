function self = test_whitener_fitter_robust_fitting( self )
%
% test_whitener_fitter_fit_type_robust_fitting -- test
% perform_iterative_whitening_and_model_fitting method of dvDataClass for cases in which
% robust fitting is requested.
%
% This unit test exercises the following functionality of the dvDataClass method which
% performs the iterative whitening and fitting of the flux time series:
%
% ==> Performs robust fitting when called upon to do so
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testDvDataClass('test_whitener_fitter_robust_fitting'));
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
%
%=========================================================================================

  
  disp('... testing iterative whitener-fitter method, robust fitting ... ')
  
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
  
% Perform a test of all-transits fitting in which robust fitting is enabled
  
  dvResultsStruct = dvResultsStructBeforeFit ;
  dvDataStructRobustFit = dvDataStruct ;
  dvDataStructRobustFit.planetFitConfigurationStruct.robustFitEnabled = true ;
  dvDataObjectRobustFit = dvDataClass ( dvDataStructRobustFit ) ;
  
  dvResultsStruct = perform_iterative_whitening_and_model_fitting( dvDataObjectRobustFit, ...
      dvResultsStruct, tceForWhitenerTest, 1, 1, 0 ) ;
  allTransitsFit = dvResultsStruct.targetResultsStruct.planetResultsStruct.allTransitsFit ;
  impactParameterPointer = find( strcmp( 'minImpactParameter', ...
      {allTransitsFit.modelParameters.name} ) ) ;
  mlunit_assert( ~allTransitsFit.modelParameters(impactParameterPointer).fitted && ...
      any( allTransitsFit.robustWeights ~= 1 & allTransitsFit.robustWeights ~= 0 ), ...
      'fitType 1 with robust fit fit did not execute correctly for all-transits fit' ) ;
  
% perform a test of all-transits fitting in which both a fitType switch and robust fitting
% are enabled
  
  transitModelCentralTransit = convert_tps_parameters_to_transit_model( dvDataObject, ...
      1, tceForWhitenerTest, targetFluxTimeSeries ) ;
  modelParameters = ...
      dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.allTransitsFit.modelParameters ;
  transitModelCentralTransit.planetModel = modelParameters ;
  transitObjectCentralTransit = transitGeneratorClass( transitModelCentralTransit ) ;
  transitObjectOffsetTransit = get_transit_object_with_new_star_radius( ...
      transitObjectCentralTransit, 1.5 ) ;
  
  targetFluxTimeSeriesOffsetTransit = targetFluxTimeSeries ;
  targetFluxTimeSeriesOffsetTransit.values = ...
      targetFluxTimeSeriesOffsetTransit.values - ...
      generate_planet_model_light_curve( transitObjectCentralTransit ) + ...
      generate_planet_model_light_curve( transitObjectOffsetTransit ) ;
  
  dvResultsStruct = dvResultsStructBeforeFit ;
  dvResultsStruct.targetResultsStruct.residualFluxTimeSeries = ...
      targetFluxTimeSeriesOffsetTransit ;
      
  dvDataStructFitType0 = dvDataStruct ;
  dvDataStructFitType0.targetStruct.radius.value = 1.5 ;
  
  dvDataStructRobustFit = dvDataStructFitType0 ;
  dvDataStructRobustFit.planetFitConfigurationStruct.robustFitEnabled = true ;
  dvDataObjectRobustFit = dvDataClass ( dvDataStructRobustFit ) ;
  
  dvResultsStruct = perform_iterative_whitening_and_model_fitting( dvDataObjectRobustFit, ...
      dvResultsStruct, tceForWhitenerTest, 1, 1, 0 ) ;
  allTransitsFit = dvResultsStruct.targetResultsStruct.planetResultsStruct.allTransitsFit ;
  impactParameterPointer = find( strcmp( 'minImpactParameter', ...
      {allTransitsFit.modelParameters.name} ) ) ;
  mlunit_assert( allTransitsFit.modelParameters(impactParameterPointer).fitted && ...
      any( allTransitsFit.robustWeights ~= 1 & allTransitsFit.robustWeights ~= 0 ), ...
      'fitType 0 with robust fit fit did not execute correctly for all-transits fit' ) ;

return

% and that's it!

%
%
%

