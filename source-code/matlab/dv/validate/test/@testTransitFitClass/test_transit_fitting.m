function self = test_transit_fitting( self )
%
% test_transit_fitting -- test transitFitClass methods closely related to fitting and
% returning of transit parameters
%
% This is a unit test of the following transitFitClass methods:
%
% --> fit_transit
% --> fill_planet_results_struct
% --> get_fitted_transit_object
%
% Specifically, it tests the following:
%
% ==> The fitter operates as expected for fitType values 0, 1 and 2
% ==> The fitter operates as expected for oddEvenFlag values 0, 1, and 2
% ==> The fitter operates as expected when robust fitting is selected
% ==> The fitter returns a fitted transit object upon request for all valid fit types
% ==> The planet results structure is correctly filled with results for all valid fit
%     types
% ==> For all-transits fits, the number of expected and observed transits is filled in the
%     planet results structure
% ==> All errors in all 3 methods are thrown under the correct conditions.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testTransitFitClass('test_transit_fitting'));
%
% Version date:  2010-May-07.
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
%    2010-May-07, PT:
%        move to BKJD from MJD for fitting.
%    2010-May-01, PT:
%        updates related to use of transitGeneratorCollectionClass.
%    2009-November-19, PT:
%        add modelDegreesOfFreedom field to fit results struct.
%    2009-September-25, PT:
%        test for square modelParameterCovariance, and adjust code to make value check
%        between uncertainties and covariance work right despite this.
%
%=========================================================================================

  disp('... testing transitFitClass fitter and related methods ... ')
  
  doFit = false ;
  testTransitFitClass_initialization ;  
  load(fullfile(testDataDir,'planet-results-struct')) ;
  originalTransitFitObject = transitFitObject1 ;
  
  transitFitObject1 = fit_transit( transitFitObject1 ) ;
  
  originalTransitGeneratorObject = transitFitStruct.transitGeneratorObject ;
    
% get the fitted transitGeneratorClass object 

  fittedTransitGeneratorObject = get_fitted_transit_object( transitFitObject1 ) ;
  fittedPlanetModel = get( fittedTransitGeneratorObject, 'planetModel' ) ;
  
% the fitted and original transit generator objects should have non-equal planet models

  assert_not_equals( get(originalTransitGeneratorObject, 'planetModel'), ...
      fittedPlanetModel, ...
      'Fitted planet model is identical to original planet model' ) ;
  
% convert the fit object to a struct and examine its fields to make sure they are as
% expected.  For reasons too complicated to get into here, the fitted planet model and the
% final parameter values are not to-the-bit equal, but are different by an amount
% comparable to eps, so the check has to be that the values in the two things agree within
% tolerances

  transitFitStruct1 = get( transitFitObject1, '*' ) ;
  [cadencesUsed, cadencesNotUsed] = get_included_excluded_cadences( ...
      originalTransitFitObject, true ) ;
  expectedFinalParValues = [ ...
      fittedPlanetModel.transitEpochBkjd ; ...
      fittedPlanetModel.planetRadiusEarthRadii ; ...
      fittedPlanetModel.semiMajorAxisAu ; ...
      fittedPlanetModel.orbitalPeriodDays ] ;
  fieldsOk = all( abs( transitFitStruct1.finalParValues(:) - expectedFinalParValues(:) ) ...
      < 16 * eps('double') * ones(4,1) ) ;
  fieldsOk = fieldsOk && isscalar(transitFitStruct1.chisq) && ...
       isnumeric(transitFitStruct1.chisq) ;
  fieldsOk = fieldsOk && isnumeric(transitFitStruct1.parValueCovariance) && ...
       isequal( size(transitFitStruct1.parValueCovariance), [4 4] ) ;
  fieldsOk = fieldsOk && isvector(transitFitStruct1.robustWeights) && ...
       isequal( length(transitFitStruct1.robustWeights), ...
       length(transitFitStruct1.whitenedFluxTimeSeries.values) ) && ...
       all( transitFitStruct1.robustWeights(cadencesUsed) == 1 ) && ...
       all( transitFitStruct1.robustWeights(cadencesNotUsed) == 0 ) ;
  fieldsOk = fieldsOk && isscalar(transitFitStruct1.ndof) && ...
       isnumeric(transitFitStruct1.ndof) ;
   
  mlunit_assert( fieldsOk, ...
       'Fields in transitFitObject not as expected for all-transits fit, non-robust fitting' ) ;
   
% fill the planet results struct and make sure that it is correctly filled in this process

  planetResultsStruct1 = fill_planet_results_struct( transitFitObject1, ...
      planetResultsStruct ) ;
  
  allTransitsFit = planetResultsStruct1.allTransitsFit ;
  transitFitFields = {'keplerId', 'limbDarkeningModelName', 'modelChiSquare', ...
      'modelParameterCovariance', 'modelParameters', 'modelDegreesOfFreedom', ...
      'planetNumber', 'robustWeights', 'transitModelName'} ;
  planetCandidateOriginal = planetResultsStruct.planetCandidate ;
  planetCandidateOriginal1 = planetResultsStruct1.planetCandidate ;
  planetCandidateStripped = rmfield( planetResultsStruct.planetCandidate, ...
      { 'expectedTransitCount', 'observedTransitCount' } ) ;
  planetResultsStruct.planetCandidate = planetCandidateStripped ;
  planetCandidateStripped1 = rmfield( planetResultsStruct1.planetCandidate, ...
      { 'expectedTransitCount', 'observedTransitCount' } ) ;
  planetResultsStruct1.planetCandidate = planetCandidateStripped1 ;
  otherFieldsOk = isequal( rmfield( planetResultsStruct, 'allTransitsFit' ), ...
      rmfield( planetResultsStruct1, 'allTransitsFit' ) ) ;
  planetResultsStruct.planetCandidate = planetCandidateOriginal ;
  planetResultsStruct1.planetCandidate = planetCandidateOriginal1 ;
  fieldsCorrect = all( isfield(allTransitsFit,transitFitFields) ) && ...
      length(fields(allTransitsFit)) == length(transitFitFields) ;
  fieldsOk = allTransitsFit.keplerId == planetResultsStruct1.keplerId ;
  fieldsOk = fieldsOk && allTransitsFit.planetNumber == planetResultsStruct1.planetNumber ;
  fieldsOk = fieldsOk && allTransitsFit.modelChiSquare == transitFitStruct1.chisq ;
  fieldsOk = fieldsOk && isequal( allTransitsFit.robustWeights, ...
      transitFitStruct1.robustWeights ) ;
  fieldsOk = fieldsOk && strcmp( allTransitsFit.transitModelName, ...
      get( fittedTransitGeneratorObject, 'transitModelName' ) ) ;
  fieldsOk = fieldsOk && strcmp( allTransitsFit.limbDarkeningModelName, ...
      get( fittedTransitGeneratorObject, 'limbDarkeningModelName' ) ) ;
  
  fitParValues = [allTransitsFit.modelParameters.value] ;
  fitParNames = {allTransitsFit.modelParameters.name} ;
  fitParUncertainties = [allTransitsFit.modelParameters.uncertainty] ;
  isFitted = [allTransitsFit.modelParameters.fitted] ;
  modelParameterCovariance = reshape( allTransitsFit.modelParameterCovariance, ...
      length(fitParValues), length(fitParValues) ) ;
  
  fieldsOk = fieldsOk && all( abs( fitParValues(1:end-1)' - ...
      cell2mat(struct2cell(fittedPlanetModel)) ) < 16 * eps('double') * ones(11,1) ) ;
  fieldsOk = fieldsOk && all( strcmp( fitParNames(1:end-1)', ...
      fieldnames(fittedPlanetModel) ) ) ;
  fieldsOk = fieldsOk && isequal( fitParUncertainties(:), ...
      sqrt(diag(modelParameterCovariance)) ) ;
  fieldsOk = fieldsOk && isequal( isFitted(:), ...
      [true ; false ; false ; true ; true ; false ; false ; false ; false ; false ; ...
       true ; false] ) ;
  fieldsOk = fieldsOk && ...
       planetResultsStruct1.planetCandidate.expectedTransitCount > 0 && ...
       planetResultsStruct1.planetCandidate.observedTransitCount == ...
       planetResultsStruct1.planetCandidate.expectedTransitCount ;
  fieldsOk = fieldsOk && ...
      isvector( allTransitsFit.modelParameterCovariance ) ;
   
  mlunit_assert( fieldsCorrect && fieldsOk && otherFieldsOk, ...
       'planetResultsStruct not correctly filled for all-transits fit' ) ;

% change to performing odd-even fits and check that the fit executes properly

  load(fullfile(testDataDir,'transit-generator-model')) ;
  transitObject = transitGeneratorCollectionClass( transitModel, 1 ) ;
  transitFitStruct.transitGeneratorObject = transitObject ;
  transitFitObject2 = transitFitClass( transitFitStruct, 1 ) ;
  [cadencesUsed, cadencesNotUsed] = get_included_excluded_cadences( transitFitObject2, ...
      true ) ;
  transitFitObject2 = fit_transit( transitFitObject2 ) ;
  fittedTransitGeneratorObject = get_fitted_transit_object( transitFitObject2 ) ;
  fittedPlanetModel = get( fittedTransitGeneratorObject, 'planetModel' ) ;
  
  transitFitStruct2 = get( transitFitObject2, '*' ) ;
  expectedFinalParValues = [ ...
      fittedPlanetModel(1).transitEpochBkjd ; ...
      fittedPlanetModel(1).planetRadiusEarthRadii ; ...
      fittedPlanetModel(1).semiMajorAxisAu ; ...
      fittedPlanetModel(1).orbitalPeriodDays ; ...
      fittedPlanetModel(2).transitEpochBkjd ; ...
      fittedPlanetModel(2).planetRadiusEarthRadii ; ...
      fittedPlanetModel(2).semiMajorAxisAu ; ...
      fittedPlanetModel(2).orbitalPeriodDays ] ;
  fieldsOk = all( abs( transitFitStruct2.finalParValues(:) - expectedFinalParValues(:) ) ...
      < 16 * eps('double') * ones(8,1) ) ;
   fieldsOk = fieldsOk && isscalar(transitFitStruct2.chisq) && ...
       isnumeric(transitFitStruct2.chisq) ;
   fieldsOk = fieldsOk && isnumeric(transitFitStruct2.parValueCovariance) && ...
       isequal( size(transitFitStruct2.parValueCovariance), [8 8] ) ;
   fieldsOk = fieldsOk && isvector(transitFitStruct2.robustWeights) && ...
       isequal( length(transitFitStruct2.robustWeights), ...
       length(transitFitStruct2.whitenedFluxTimeSeries.values) ) && ...
       all( transitFitStruct2.robustWeights(cadencesUsed) == 1 ) && ...
       all( transitFitStruct2.robustWeights(cadencesNotUsed) == 0 ) ;
   fieldsOk = fieldsOk && isscalar(transitFitStruct2.ndof) && ...
       isnumeric(transitFitStruct2.ndof) ;
   
   mlunit_assert( fieldsOk, ...
       'Fields in transitFitObject not as expected for odd-transits fit, non-robust fitting' ) ;

% Fill the planet results structure and make sure that it operates correctly

  planetResultsStruct2 = fill_planet_results_struct( transitFitObject2, ...
      planetResultsStruct ) ;

  oddTransitsFit = planetResultsStruct2.oddTransitsFit ;
  fieldsToRemove = {'oddTransitsFit', 'evenTransitsFit'} ;
  otherFieldsOk = isequal( rmfield( planetResultsStruct, fieldsToRemove ), ...
      rmfield( planetResultsStruct2, fieldsToRemove ) ) ;
  fieldsCorrect = all( isfield(oddTransitsFit,transitFitFields) ) && ...
      length(fields(oddTransitsFit)) == length(transitFitFields) ;
  fieldsOk = oddTransitsFit.keplerId == planetResultsStruct2.keplerId ;
  fieldsOk = fieldsOk && oddTransitsFit.planetNumber == planetResultsStruct2.planetNumber ;
  fieldsOk = fieldsOk && oddTransitsFit.modelChiSquare == transitFitStruct2.chisq ;
  fieldsOk = fieldsOk && isequal( oddTransitsFit.robustWeights, ...
      transitFitStruct2.robustWeights ) ;
  fieldsOk = fieldsOk && strcmp( oddTransitsFit.transitModelName, ...
      get( fittedTransitGeneratorObject, 'transitModelName' ) ) ;
  fieldsOk = fieldsOk && strcmp( oddTransitsFit.limbDarkeningModelName,  ...
      get( fittedTransitGeneratorObject, 'limbDarkeningModelName' ) ) ;
  
  fitParValues = [oddTransitsFit.modelParameters.value] ;
  fitParNames = {oddTransitsFit.modelParameters.name} ;
  fitParUncertainties = [oddTransitsFit.modelParameters.uncertainty] ;
  isFitted = [oddTransitsFit.modelParameters.fitted] ;
  modelParameterCovariance = reshape( oddTransitsFit.modelParameterCovariance, ...
      length(fitParValues), length(fitParValues) ) ;
  
  fieldsOk = fieldsOk && all( abs( fitParValues(1:end-1)' - ...
      cell2mat(struct2cell(fittedPlanetModel(1))) ) < 16 * eps('double') * ones(11,1) ) ;
  fieldsOk = fieldsOk && all( strcmp( fitParNames(1:end-1)', ...
      fieldnames(fittedPlanetModel(1)) ) ) ;
  fieldsOk = fieldsOk && isequal( fitParUncertainties(:), ...
      sqrt(diag(modelParameterCovariance)) ) ;
  fieldsOk = fieldsOk && isequal( isFitted(:), ...
      [true ; false ; false ; true ; true ; false ; false ; false ; false ; false ; ...
       true ; false] ) ;
  fieldsOk = fieldsOk && ...
       planetResultsStruct2.planetCandidate.expectedTransitCount == 0 && ...
       planetResultsStruct2.planetCandidate.observedTransitCount == ...
       planetResultsStruct2.planetCandidate.expectedTransitCount ;
  fieldsOk = fieldsOk && ...
      isvector( oddTransitsFit.modelParameterCovariance ) ;
   
  mlunit_assert( fieldsCorrect && fieldsOk && otherFieldsOk, ...
       'planetResultsStruct not correctly filled for odd-transits fit' ) ;
   
% Now examine the even-transits fits to make sure that they were correctly filled at the
% same time.  Remember that the epoch returned value differs from the actual fitted value,
% so make appropriate adjustments!

  evenTransitsFit = planetResultsStruct2.evenTransitsFit ;
  otherFieldsOk = isequal( rmfield( planetResultsStruct, fieldsToRemove ), ...
      rmfield( planetResultsStruct2, fieldsToRemove ) ) ;
  fieldsCorrect = all( isfield(evenTransitsFit,transitFitFields) ) && ...
      length(fields(evenTransitsFit)) == length(transitFitFields) ;
  fieldsOk = evenTransitsFit.keplerId == planetResultsStruct2.keplerId ;
  fieldsOk = fieldsOk && evenTransitsFit.planetNumber == planetResultsStruct2.planetNumber ;
  fieldsOk = fieldsOk && evenTransitsFit.modelChiSquare == transitFitStruct2.chisq ;
  fieldsOk = fieldsOk && isequal( evenTransitsFit.robustWeights, ...
      transitFitStruct2.robustWeights ) ;
  fieldsOk = fieldsOk && strcmp( evenTransitsFit.transitModelName, ...
      get( fittedTransitGeneratorObject, 'transitModelName' ) ) ;
  fieldsOk = fieldsOk && strcmp( evenTransitsFit.limbDarkeningModelName,  ...
      get( fittedTransitGeneratorObject, 'limbDarkeningModelName' ) ) ;
  
  fitParValues = [evenTransitsFit.modelParameters.value] ;
  fitParNames = {evenTransitsFit.modelParameters.name} ;
  fitParUncertainties = [evenTransitsFit.modelParameters.uncertainty] ;
  isFitted = [evenTransitsFit.modelParameters.fitted] ;
  modelParameterCovariance = reshape( evenTransitsFit.modelParameterCovariance, ...
      length(fitParValues), length(fitParValues) ) ;
  fitParValues(1) = fitParValues(1) - fitParValues(11) ;
  
  fieldsOk = fieldsOk && all( abs( fitParValues(1:end-1)' - ...
      cell2mat(struct2cell(fittedPlanetModel(2))) ) < 16 * eps('double') * ones(11,1) ) ;
  fieldsOk = fieldsOk && all( strcmp( fitParNames(1:end-1)', ...
      fieldnames(fittedPlanetModel(2)) ) ) ;
  fieldsOk = fieldsOk && isequal( fitParUncertainties(:), ...
      sqrt(diag(modelParameterCovariance)) ) ;
  fieldsOk = fieldsOk && isequal( isFitted(:), ...
      [true ; false ; false ; true ; true ; false ; false ; false ; false ; false ; ...
       true ; false] ) ;
  fieldsOk = fieldsOk && ...
       planetResultsStruct2.planetCandidate.expectedTransitCount == 0 && ...
       planetResultsStruct2.planetCandidate.observedTransitCount == ...
       planetResultsStruct2.planetCandidate.expectedTransitCount ;
  fieldsOk = fieldsOk && ...
      isvector( evenTransitsFit.modelParameterCovariance ) ;
   
  mlunit_assert( fieldsCorrect && fieldsOk && otherFieldsOk, ...
       'planetResultsStruct not correctly filled for even-transits fit' ) ;
   
  
% Still using even-transits fitting, try out fitType values 0 and 2 and make sure they do
% the right thing; to do this, make sure that the fit object is properly configured

  transitFitStruct.transitGeneratorObject = get_transit_object_with_new_star_radius( ...
      get_fitted_transit_object( transitFitObject2 ), 1.5 ) ;
  transitFitObject4 = transitFitClass( transitFitStruct, 0 ) ;
  transitFitObject4 = fit_transit( transitFitObject4 ) ;
  fittedTransitGeneratorObject = get_fitted_transit_object( transitFitObject4 ) ;
  fittedPlanetModel = get( fittedTransitGeneratorObject, 'planetModel' ) ;
  
  transitFitStruct4 = get( transitFitObject4, '*' ) ;
  fieldsOk = isequal( transitFitStruct4.finalParValues(:), ...
      [fittedPlanetModel(1).transitEpochBkjd ; ...
       fittedPlanetModel(1).planetRadiusEarthRadii ; ...
       fittedPlanetModel(1).semiMajorAxisAu ; ...
       fittedPlanetModel(1).minImpactParameter ; ...
       fittedPlanetModel(2).transitEpochBkjd ; ...
       fittedPlanetModel(2).planetRadiusEarthRadii ; ...
       fittedPlanetModel(2).semiMajorAxisAu ; ...
       fittedPlanetModel(2).minImpactParameter] ) ;
   fieldsOk = fieldsOk && isnumeric(transitFitStruct4.parValueCovariance) && ...
       isequal( size(transitFitStruct4.parValueCovariance), [8 8] ) ;

  planetResultsStruct4 = fill_planet_results_struct( transitFitObject4, ...
      planetResultsStruct ) ;

  evenTransitsFit = planetResultsStruct4.evenTransitsFit ;
  fitParValues = [evenTransitsFit.modelParameters.value] ;
  fitParNames = {evenTransitsFit.modelParameters.name} ;
  fitParUncertainties = [evenTransitsFit.modelParameters.uncertainty] ;
  isFitted = [evenTransitsFit.modelParameters.fitted] ;
  modelParameterCovariance = reshape( evenTransitsFit.modelParameterCovariance, ...
      length(fitParValues), length(fitParValues) ) ;
  fitParValues(1) = fitParValues(1) - fitParValues(11) ;
  
  fieldsOk = fieldsOk && isequal( fitParValues(1:end-1)', ...
      cell2mat(struct2cell(fittedPlanetModel(2))) ) ;
  fieldsOk = fieldsOk && all( strcmp( fitParNames(1:end-1)', ...
      fieldnames(fittedPlanetModel(2)) ) ) ;
  fieldsOk = fieldsOk && isequal( fitParUncertainties(:), ...
      sqrt(diag(modelParameterCovariance)) ) ;
  fieldsOk = fieldsOk && isequal( isFitted(:), ...
      [true ; false ; false ; true ; true ; true ; false ; false ; false ; false ; ...
       false ; false] ) ;
  fieldsOk = fieldsOk && ...
      isvector( evenTransitsFit.modelParameterCovariance ) ;

  mlunit_assert( fieldsOk, ...
      'fit and planet-struct fill not properly handled for fitType == 0' ) ;

  transitFitObject5 = transitFitClass( transitFitStruct, 2 ) ;
  transitFitObject5 = fit_transit( transitFitObject5 ) ;
  fittedTransitGeneratorObject = get_fitted_transit_object( transitFitObject5 ) ;
  fittedPlanetModel = get( fittedTransitGeneratorObject, 'planetModel' ) ;
  
  transitFitStruct5 = get( transitFitObject5, '*' ) ;
  fieldsOk = isequal( transitFitStruct5.finalParValues(:), ...
      [fittedPlanetModel(1).transitEpochBkjd ; ...
       fittedPlanetModel(1).planetRadiusEarthRadii ; ...
       fittedPlanetModel(1).semiMajorAxisAu ; ...
       fittedPlanetModel(2).transitEpochBkjd ; ...
       fittedPlanetModel(2).planetRadiusEarthRadii ; ...
       fittedPlanetModel(2).semiMajorAxisAu] ) ;
   fieldsOk = fieldsOk && isnumeric(transitFitStruct5.parValueCovariance) && ...
       isequal( size(transitFitStruct5.parValueCovariance), [6 6] ) ;

  planetResultsStruct5 = fill_planet_results_struct( transitFitObject5, ...
      planetResultsStruct ) ;

  evenTransitsFit = planetResultsStruct5.evenTransitsFit ;
  fitParValues = [evenTransitsFit.modelParameters.value] ;
  fitParNames = {evenTransitsFit.modelParameters.name} ;
  fitParUncertainties = [evenTransitsFit.modelParameters.uncertainty] ;
  isFitted = [evenTransitsFit.modelParameters.fitted] ;
  modelParameterCovariance = reshape( evenTransitsFit.modelParameterCovariance, ...
      length(fitParValues), length(fitParValues) ) ;
  fitParValues(1) = fitParValues(1) - fitParValues(11) ;
  
  fieldsOk = fieldsOk && isequal( fitParValues(1:end-1)', ...
      cell2mat(struct2cell(fittedPlanetModel(2))) ) ;
  fieldsOk = fieldsOk && all( strcmp( fitParNames(1:end-1)', ...
      fieldnames(fittedPlanetModel(2)) ) ) ;
  fieldsOk = fieldsOk && isequal( fitParUncertainties(:), ...
      sqrt(diag(modelParameterCovariance)) ) ;
  fieldsOk = fieldsOk && isequal( isFitted(:), ...
      [true ; false ; false ; true ; true ; false ; false ; false ; false ; false ; ...
       false ; false] ) ;
  fieldsOk = fieldsOk && ...
      isvector( evenTransitsFit.modelParameterCovariance ) ;

  mlunit_assert( fieldsOk, ...
      'fit and planet-struct fill not properly handled for fitType == 2' ) ;
  
% enable robust fitting and make sure that a robust fit is actually performed, as
% indicated by the robust weights being set to values other than 1 for points in the fit
% and 0 for points not in the fit

  transitFitStruct.configurationStruct.robustFitEnabled = true ; 
  transitFitStruct.configurationStruct.tolSigma = 1 ;
  transitFitObject6 = transitFitClass( transitFitStruct, 2 ) ;
  [cadencesUsed, cadencesNotUsed] = get_included_excluded_cadences( transitFitObject6, ...
      true ) ;
  transitFitObject6 = fit_transit( transitFitObject6 ) ;
  transitFitStruct6 = get( transitFitObject6, '*' ) ;
  fieldsOk = isvector(transitFitStruct6.robustWeights) && ...
       isequal( length(transitFitStruct6.robustWeights), ...
       length(transitFitStruct6.whitenedFluxTimeSeries.values) ) && ...
       any( transitFitStruct6.robustWeights(cadencesUsed) < 1 ) && ...
       all( transitFitStruct6.robustWeights(cadencesNotUsed) == 0 ) ;

   mlunit_assert( fieldsOk, 'Robust fit not properly performed' ) ;
   
% Exercise error conditions in the 3 methods:

% attempting to get a fitted transitGeneratorClass object from a transitFitClass object
% which has not yet performed a fit

  transitFitObject7 = transitFitClass( transitFitStruct, 2 ) ;
  try_to_catch_error_condition( 'get_fitted_transit_object(transitFitObject7)', ...
      'noFitPerformed', transitFitObject7, 'transitFitObject7' ) ;
  
  disp(' ') ;
   
return

% and that's it!

%
%
%
