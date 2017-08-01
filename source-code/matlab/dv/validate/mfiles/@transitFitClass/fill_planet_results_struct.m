function planetResultsStruct = fill_planet_results_struct( transitFitObject, ...
    planetResultsStruct, whitenedModelLightCurve, whitenedModelGapIndicators, convergenceFlag, seededWithPriorFitFlag )
%
% fill_planet_results_struct -- fill the values in a planetResultsStruct from a transit
% fit object
%
% It fills in the allTransitsFit struct of the planetResultsStruct (or the
% oddTransitsFit and evenTransitsFit, depending on the value of oddEvenFlag) and returns
% it to the caller.
%
% Version date:  2015-April-09.
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
%    2015-April-09, JL:
%        Add input argument 'whitenedModelGapIndicators'
%    2014-December-01, JL:
%        Error out if the values of model light curve are all zero 
%        when robustWeights are not zero
%    2014-September-02, JL:
%        Set default value to be 0 and default uncertainty to be -1
%    2014-August-22, JL:
%        Update uncertainties and covariance matrix to include propagated
%        uncertainties of stellar parameters
%    2012-December-20, SS:
%        Add TPS chi-square calculation 
%    2012-October-03, JL:
%        Add input argument 'whitenedModelLightCurve'
%        Add fields 'whitenedFluxTimeSeries' and 'whitenedModelLightCurve'
%    2012-August-23, JL:
%        Move calculation of inclination angle to transitGeneratorClass
%    2012-March-15, JL:
%        Add field 'allTransitsFit.seeded WithPriorFit'
%    2011-October-05, JL:
%        'allTransitsFit.transitEpochBkjd' is increased by integer times of 
%        'orbitalPeriodDays' if it is less than the first time stamp of barycentric
%        cadence times
%    2011-June-28, JL:
%        error generated when fitted 'transitEpochBkjd' is smaller than
%        first start timestamp or larger than last end timestamp
%    2011-June-06, JL:
%        update the field 'modelFitSnr' of all/odd/even transit fit struct
%    2011-May-25, JL:
%        update fields of all/odd/even transit fit struct instead of
%        generating a new transit fit struct
%    2011-March-31, JL:
%        add the check of low bound of 'orbitalPeriodDays'
%    2011-March-04, JL:
%        add the check of lower bounds of 'ratioPlanetRadiusToStarRadius'
%        'ratioSemiMajorAxisToStarRadius' and 'transitDurationHours' 
%    2011-Februray-18, JL:
%        check validity of fitted parameters   
%    2011-February-01, JL:
%         fill transit model light curve in planetResultsStruct
%    2011-January-31, JL:
%         add convergenceFlag in the inputs  
%    2010-Dec-01, JL:
%         add iObject to the iputs when calling get_fitted_to_unfitted_jacobian
%    2010-Nov-05, JL:
%         when geometric transit model is used, call the transitGeneratorClass method
%         compute_inclination_angle_with_geometric_model 
%    2010-Sept-24, JT:
%         added fullConvergence parameter. Assume for now that the fit
%         fully converged.
%    2010-May-05, PT:
%        convert from transitEpochMjd to transitEpochBkjd.
%    2010-May-03, PT:
%        offset epoch for even transits and individual-fit structs.
%    2010-May-01, PT:
%        revamped based on transitGeneratorCollectionClass changes.  Signature changed!
%    2009-December-03, PT:
%        new validity test on period, epoch, and transit duration.
%    2009-November-04, PT:
%        add modelDegreesOfFreedom to the transit fit struct, and populate it.
%    2009-October-16, PT:
%        change modelParameters to row-vector of structs from column-vector of structs to
%        make unit tests of autogenerated read/write tools run correctly.
%    2009-September-25, PT:
%        convert the covariance to a column-vector for transfer to Java-side.
%    2009-September-22, PT:
%        eliminated error checking for out-of-bounds fit parameters -- turns out that such
%        parameters hit other errors in the course of execution before reaching the end of
%        this method.
%    2009-August-26, PT:
%        fill the expected and observed transit count fields.
%    2009-August-18, PT:
%        completely reworked!
%
%=========================================================================================

  oddEvenFlag = transitFitObject.oddEvenFlag ;

% do somewhat different things based on the oddEvenFlag

  switch oddEvenFlag
      
      case 0
          
%         all-transits fit:  just one struct, fill it now; also, fill in the # of observed
%         and expected transits (we only note whether a transit was entirely gapped or
%         filled, since there's not really a way to determine that the data was present
%         but had no transit in it)

          planetResultsStruct.allTransitsFit  = fill_transit_fit_struct(transitFitObject, planetResultsStruct.allTransitsFit,  1, convergenceFlag, 'all' );
          planetResultsStruct.allTransitsFit.seededWithPriorFit = seededWithPriorFitFlag;
          planetResultsStruct.modelLightCurve = fill_model_light_curve(transitFitObject);
          
          lightCurveZeroFlag = all( planetResultsStruct.modelLightCurve.values( planetResultsStruct.allTransitsFit.robustWeights ~= 0 ) == 0 );
          if ( lightCurveZeroFlag )
              error('dv:fillPlanetResultsStruct:lightCurveAllZeroWhenRobustWeightsNotZero', 'The values of model light curve are all zero when robustWeights are not zero');
          end
          
          whitenedGapIndicators = transitFitObject.whitenedFluxTimeSeries.gapIndicators;
          whitenedFilledIndices = transitFitObject.whitenedFluxTimeSeries.filledIndices;
          whitenedGapIndicators(whitenedFilledIndices) = true;
          planetResultsStruct.whitenedFluxTimeSeries.values         = transitFitObject.whitenedFluxTimeSeries.values;
          planetResultsStruct.whitenedFluxTimeSeries.gapIndicators  = whitenedGapIndicators;
          
          whitenedModelLightCurve(whitenedModelGapIndicators)       = 0;
          planetResultsStruct.whitenedModelLightCurve.values        = whitenedModelLightCurve;
          planetResultsStruct.whitenedModelLightCurve.gapIndicators = whitenedModelGapIndicators;

          transitGeneratorObjectVector = get(transitFitObject.transitGeneratorObject, 'transitGeneratorObjectVector');
          [expectedTransitCount, observedTransitCount] = ...
              get_number_of_transits_in_time_series(transitGeneratorObjectVector, get( transitFitObject.transitGeneratorObject, 'cadenceTimes' ) , ...
                 transitFitObject.whitenedFluxTimeSeries.gapIndicators, transitFitObject.whitenedFluxTimeSeries.filledIndices);
          planetResultsStruct.planetCandidate.expectedTransitCount = expectedTransitCount;
          planetResultsStruct.planetCandidate.observedTransitCount = observedTransitCount;
          
          if ~transitFitObject.configurationStruct.reducedParameterFitsEnabled
              % if this is the all-transits fit and not the
              % reducedParameters fit then generate the TPS chiSquare2 by
              % using the astrophysics model
              transitModelPulseTrain = generate_planet_model_light_curve( transitFitObject.transitGeneratorObject );
              % Note that because there are features in the residual flux
              % that is used to compute the whitener, we might need to
              % explicitly gap/fill in-transit cadences to get the residual
              % flux and corresponding whitener
              [chiSquare, chiSquareDof, chiSquareGof, chiSquareGofDof] = compute_model_chisquare2( transitFitObject.whiteningFilterObject, ...
                  transitFitObject.targetFluxTimeSeries.values, transitModelPulseTrain, transitFitObject.robustWeights ) ;
              planetResultsStruct.planetCandidate.modelChiSquare2 = chiSquare ;
              planetResultsStruct.planetCandidate.modelChiSquareDof2 = chiSquareDof ;
              planetResultsStruct.planetCandidate.modelChiSquareGof = chiSquareGof ;
              planetResultsStruct.planetCandidate.modelChiSquareGofDof = chiSquareGofDof ;
          end
          
      case 1
          
%         odd-even fit:  fill the 2 structs in turn

          planetResultsStruct.oddTransitsFit  = fill_transit_fit_struct(transitFitObject, planetResultsStruct.oddTransitsFit,  1, convergenceFlag, 'odd' );
          planetResultsStruct.evenTransitsFit = fill_transit_fit_struct(transitFitObject, planetResultsStruct.evenTransitsFit, 2, convergenceFlag, 'even');
          
      otherwise % error case
          
          error('dv:fillPlanetResultsStruct:oddEvenFlagInvalid', 'fill_planet_results_struct:  value of oddEvenFlag is invalid');
          
  end % switch statement

return



% subfunction which performs the actual grunt work of filling a transit fit struct

function transitFitStruct = fill_transit_fit_struct(transitFitObject, transitFitStruct, iObject, convergenceFlag, oddEvenStr)

% build an empty struct for parameters

  modelParameters = struct('name', [], 'value', 0, 'uncertainty', -1, 'fitted', false);

% get the updated transitGeneratorObject which is correct for the current value of iObject

  transitGeneratorObject = get_fitted_transit_object( transitFitObject );
  transitGeneratorObject = get( transitGeneratorObject, 'transitGeneratorObjectVector' );
  transitGeneratorObject = transitGeneratorObject( iObject );
  
% fill in values which come directly from the fitStruct. 

  transitFitStruct.fullConvergence       = convergenceFlag ;
  transitFitStruct.modelChiSquare        = transitFitObject.chisq ;
  transitFitStruct.modelDegreesOfFreedom = transitFitObject.ndof ;
  transitFitStruct.robustWeights         = transitFitObject.robustWeights ;
  
  if strcmp(oddEvenStr, 'odd')
      transitFitStruct.modelFitSnr       = transitFitObject.oddTransitSnr;
  elseif strcmp(oddEvenStr, 'even')
      transitFitStruct.modelFitSnr       = transitFitObject.evenTransitSnr;
  else
      transitFitStruct.modelFitSnr       = transitFitObject.allTransitSnr;
  end
      

% get additional values from the transitFitObject, taking into account that if there are
% multiple embedded objects in the transitGeneratorCollectionClass then we will want to
% obtain a subset of the values in the fit object.  Also, if there are no fit pars for
% this value of iObject, we can return without filling in too much of the struct
  
  covariance        = transitFitObject.parValueCovariance ;
  parMapStruct      = transitFitObject.parameterMapStruct( iObject ) ;
  parMapValues      = cell2mat( struct2cell( parMapStruct ) ) ;
  parMapIndex       = find( parMapValues ~= 0 ) ;
  parMapValues      = parMapValues( parMapIndex ) ;
  parMapFieldNames  = fieldnames(parMapStruct) ;
  parMapFieldNames  = parMapFieldNames( parMapIndex ) ;
  nFittedParameters = length(parMapFieldNames) ; 
  
  if nFittedParameters > 0
      
      lowIndex                   = min(parMapValues) ;
      highIndex                  = max(parMapValues) ;
      covarianceFittedParameters = covariance(lowIndex:highIndex, lowIndex:highIndex) ;
  
%     get the planet model and its field names list from the transit generator object

      planetModel           = get( transitGeneratorObject, 'planetModel' );
      planetModelFieldNames = fieldnames(planetModel);
      nPlanetModelFields    = length(planetModelFieldNames);

%     construct the modelParameters structure for return

      modelParameters = repmat( modelParameters, nPlanetModelFields, 1 );
  
%     In allTransitsFit, adjust planetModel.transitEpochBkjd so that it is larger than (or equal to) the first start timestamp
%     of barycentric cadence times

      epochOffsetPeriods = 0;
      transitEpochBkjd   = planetModel.transitEpochBkjd;
      orbitalPeriodDays  = planetModel.orbitalPeriodDays;
      if strcmp(oddEvenStr, 'all')  
          while (transitEpochBkjd + epochOffsetPeriods*orbitalPeriodDays) < transitFitObject.barycentricCadenceTimes.startTimestamps(1)
              epochOffsetPeriods = epochOffsetPeriods + 1;
          end
          planetModel.transitEpochBkjd = transitEpochBkjd + epochOffsetPeriods*orbitalPeriodDays;
      end

%     Adjust epoch for evenTransitsFit

      if iObject > 1 
          epochOffsetPeriods = iObject - 1;
      end
      
%     put the fit parameters into the transitFitStruct

      for iPar = 1:nPlanetModelFields

          modelParameters(iPar).name = planetModelFieldNames{iPar};

          if ( isfinite( planetModel.(planetModelFieldNames{iPar}) ) && isreal( planetModel.(planetModelFieldNames{iPar}) ) )
              
              modelParameters(iPar).value = planetModel.(planetModelFieldNames{iPar});
              
              if strcmp(modelParameters(iPar).name, 'ratioPlanetRadiusToStarRadius')
                  if modelParameters(iPar).value <= transitFitObject.configurationStruct.ratioPlanetRadiusToStarRadiusLowerBound
                      error('dv:fill_planet_results_struct:ratioPlanetRadiusToStarRadius_equalToOrSmallerThanLowerBound', ...
                          'fitted ratioPlanetRadiusToStarRadius is equal to or smaller than the lower bound');
                  end
              end
              
              if strcmp(modelParameters(iPar).name, 'ratioSemiMajorAxisToStarRadius')
                  if modelParameters(iPar).value <= transitFitObject.configurationStruct.ratioSemiMajorAxisToStarRadiusLowerBound
                      error('dv:fill_planet_results_struct:ratioSemiMajorAxisToStarRadius_equalToOrSmallerThanLowerBound', ...
                          'fitted ratioSemiMajorAxisToStarRadius is equal to or smaller than the lower bound');
                  end
              end
              
              if strcmp(modelParameters(iPar).name, 'orbitalPeriodDays')
                  if modelParameters(iPar).value <= transitFitObject.configurationStruct.orbitalPeriodDaysLowerBound
                      error('dv:fill_planet_results_struct:orbitalPeriodDays_equalToOrSmallerThanLowerBound', ...
                          'fitted orbitalPeriodDays is equal to or smaller than the lower bound');
                  end
              end
              
              if strcmp(modelParameters(iPar).name, 'transitEpochBkjd') && strcmp(oddEvenStr, 'all')
                  if modelParameters(iPar).value < transitFitObject.barycentricCadenceTimes.startTimestamps(1)
                      error('dv:fill_planet_results_struct:transitEpochBkjd_smallerThanFirstStartTimestamp', ...
                          'fitted transitEpochBkjd is smaller than the first start timestamp');
                  end
                  if modelParameters(iPar).value > transitFitObject.barycentricCadenceTimes.endTimestamps(end)
                      error('dv:fill_planet_results_struct:transitEpochBkjd_largerThanLastEndTimestamp', ...
                          'fitted transitEpochBkjd is larger than the last end timestamp');
                  end
              end
              
              if strcmp(modelParameters(iPar).name, 'transitDurationHours')
                  if modelParameters(iPar).value < transitFitObject.configurationStruct.transitDurationHoursLowerBound
                      error('dv:fill_planet_results_struct:transitDurationHours_smallerThanLowerBound', ...
                          'derived transitDurationHours is smaller than the lower bound');
                  end
              end
              
          else
              
              errorIdentifier = ['dv:fill_planet_results_struct:' planetModelFieldNames{iPar} '_notReal'];
              errorMessage    = ['model parameter ' planetModelFieldNames{iPar} ' is not a finite real number'];
              error(errorIdentifier, errorMessage);
              
          end
         
          if ismember( modelParameters(iPar).name, parMapFieldNames )
              modelParameters(iPar).fitted = true ;
          end

      end      
      
%     if necessary, adjust the value of the epoch

      if iObject > 1

          modelParameterNames = { modelParameters.name };
          modelParameters(strcmp(modelParameterNames, 'transitEpochBkjd')).value = modelParameters(strcmp(modelParameterNames, 'transitEpochBkjd' )).value + ...
                                                              epochOffsetPeriods * modelParameters(strcmp(modelParameterNames, 'orbitalPeriodDays')).value;
          
      end
  
%     compute covariance matrix and uncertainty of model parameters 

      [modelParameters, covarianceModelParameters]  = compute_model_parameter_uncertainties(transitGeneratorObject, modelParameters, covarianceFittedParameters, epochOffsetPeriods);
      
      transitFitStruct.modelParameters              = modelParameters';
      transitFitStruct.modelParameterCovariance     = covarianceModelParameters(:);
      
  end % nFittedParameters > 0
  
return 


% subfunction which fills the transit model light curve struct in the planetResultsStruct.
% Only for all transits fit.

function transitModelLightCurve = fill_model_light_curve(transitFitObject)

% get the updated transitGeneratorObject and generate the light curve

  transitGeneratorObject = get_fitted_transit_object(transitFitObject);
  lightCurveValues       = generate_planet_model_light_curve(transitGeneratorObject);

  transitModelLightCurve.values        = lightCurveValues(:);
  transitModelLightCurve.gapIndicators = false( size(transitModelLightCurve.values) );
 
return





