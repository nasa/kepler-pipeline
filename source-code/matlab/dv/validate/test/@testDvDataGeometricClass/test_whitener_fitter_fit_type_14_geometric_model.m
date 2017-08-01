function self = test_whitener_fitter_fit_type_14_geometric_model( self )
%
% test_whitener_fitter_fit_type_14 -- test perform_iterative_whitening_and_model_fitting method of dvDataClass for fit type 14
% (orbital period not fit due to only 1 transit present)
%
% This unit test exercises the following functionality of the dvDataClass method which performs the iterative whitening and fitting of the flux time series:
%
% ==> Fits odd-even transits correctly, and correctly inserts the results into the planet results structure
%
% This test is intended to be executed in the mlunit context.  For standalone execution use the following syntax:
%
%      run(text_test_runner, testDvDataGeometricClass('test_whitener_fitter_fit_type_14_geometric_model'));
%
% Version date:  2011-May-05.
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
%    2011-May-05, JL:
%        update in support of DV 7.0.
%    2010-May-03, PT:
%        updates in support of transitGeneratorCollectionClass.
%
%=========================================================================================

  disp(' ');
  disp('... testing iterative whitener-fitter method with geometric transit model, fit type 14 ... ');
  disp(' ');
  
  testDvDataGeometricClass_fitter_initialization ;
  
% construct folders to contain the plots when they are generated

  dvResultsStruct = create_directories_for_dv_figures(dvDataObject, dvResultsStructBeforeFit);
  
% Part I. 
% remove all the transits after the second one 

  modelParameters          = dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.allTransitsFit.modelParameters; 
  transitModel             = convert_tps_parameters_to_transit_model(dvDataObject, 1, dvDataStruct.targetStruct.thresholdCrossingEvent, ...
      dvResultsStructBeforeFit.targetResultsStruct.residualFluxTimeSeries);
  transitModel.planetModel = modelParameters;
  transitObject            = transitGeneratorClass(transitModel);
  transitNumber            = identify_transit_cadences( transitObject, get( transitObject, 'cadenceTimes' ), 1 );

  dvResultsStruct1 = dvResultsStructBeforeFit;
  dvResultsStruct1.targetResultsStruct.planetResultsStruct.allTransitsFit = dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.allTransitsFit;
  dvResultsStruct1.targetResultsStruct.residualFluxTimeSeries.gapIndicators( transitNumber > 2 ) = true;
    
% perform odd-even transits fit, and confirm that fitType 14 is used in both odd and even transits fit

  refTime = clock;  
  [dvResultsStruct1, converged, secondaryConverged, alertMessageStruct] = ...
      perform_iterative_whitening_and_model_fitting( dvDataObject, dvResultsStruct1, dvDataStruct.targetStruct.thresholdCrossingEvent, 1, 1, 1, inf, refTime );
  
  allTransitsFit    = dvResultsStruct1.targetResultsStruct.planetResultsStruct.allTransitsFit;
  oddTransitsFit    = dvResultsStruct1.targetResultsStruct.planetResultsStruct.oddTransitsFit;
  evenTransitsFit   = dvResultsStruct1.targetResultsStruct.planetResultsStruct.evenTransitsFit;
  periodPointerOdd  = find( strcmp( 'orbitalPeriodDays', {oddTransitsFit.modelParameters.name} ) );
  periodPointerEven = find( strcmp( 'orbitalPeriodDays', {evenTransitsFit.modelParameters.name} ) );
  
  mlunit_assert( oddTransitsFit.modelParameters(periodPointerOdd).value   == allTransitsFit.modelParameters(periodPointerOdd).value  && ...
      oddTransitsFit.modelParameters(periodPointerOdd).uncertainty   == 0 && ~oddTransitsFit.modelParameters(periodPointerOdd).fitted, ...
      'Type 14 fitting behaves incorrectly for odd-transits fits' );

  mlunit_assert( evenTransitsFit.modelParameters(periodPointerEven).value == allTransitsFit.modelParameters(periodPointerEven).value && ...
      evenTransitsFit.modelParameters(periodPointerEven).uncertainty == 0 && ~evenTransitsFit.modelParameters(periodPointerEven).fitted, ...
      'Type 14 fitting behaves incorrectly for even-transits fits' );


% Part II.
% remove all the transits after the third one 

  disp(' ');
  
  dvResultsStruct2 = dvResultsStructBeforeFit;
  dvResultsStruct2.targetResultsStruct.planetResultsStruct.allTransitsFit = dvResultsStructAfterFit.targetResultsStruct.planetResultsStruct.allTransitsFit;
  dvResultsStruct2.targetResultsStruct.residualFluxTimeSeries.gapIndicators( transitNumber > 3 ) = true;
    
% rodo odd-even transits fit, and confirm that fitType 12 is used in odd transits fit and fitType 14 is used in even transits fit

  [dvResultsStruct2, converged, secondaryConverged, alertMessageStruct] = ...
      perform_iterative_whitening_and_model_fitting( dvDataObject, dvResultsStruct2, dvDataStruct.targetStruct.thresholdCrossingEvent, 1, 1, 1, inf, refTime );
  
  allTransitsFit    = dvResultsStruct2.targetResultsStruct.planetResultsStruct.allTransitsFit;
  oddTransitsFit    = dvResultsStruct2.targetResultsStruct.planetResultsStruct.oddTransitsFit;
  evenTransitsFit   = dvResultsStruct2.targetResultsStruct.planetResultsStruct.evenTransitsFit;
  periodPointerOdd  = find( strcmp( 'orbitalPeriodDays', {oddTransitsFit.modelParameters.name} ) );
  periodPointerEven = find( strcmp( 'orbitalPeriodDays', {evenTransitsFit.modelParameters.name} ) );
  
  mlunit_assert( oddTransitsFit.modelParameters(periodPointerOdd).value   ~= allTransitsFit.modelParameters(periodPointerOdd).value  && ...
      oddTransitsFit.modelParameters(periodPointerOdd).uncertainty   ~= 0 &&  oddTransitsFit.modelParameters(periodPointerOdd).fitted, ...
      'Type 12 fitting behaves incorrectly for odd-transits fits' );

  mlunit_assert( evenTransitsFit.modelParameters(periodPointerEven).value == allTransitsFit.modelParameters(periodPointerEven).value && ...
      evenTransitsFit.modelParameters(periodPointerEven).uncertainty == 0 && ~evenTransitsFit.modelParameters(periodPointerEven).fitted, ...
      'Type 14 fitting behaves incorrectly for even-transits fits' );

return

% and that's it!
