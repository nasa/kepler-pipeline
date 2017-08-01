function transitFitObject = fit_transit( transitFitObject )
%
% fit_transit -- perform the fit in a transitFitClass object
%
% transitFitObject = fit_transit( transitFitObject ) fits a planet model using the data
%    and parameters in the transitFitClass object.  The updated object is returned.
%
% Version date:  2013-April-04.
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
%    2013-April-04, JL:
%        Implement deemphasisWeights in the model fitting
%    2013-March-13, JL:
%        Error out when there are big difference between the fitted 'transitEpochBkjd' 
%        and 'orbitalPeriodDays' and the corresponding TCE values
%    2013-January-24, JL:
%        Clean the variable 'whitenerScaleFactor' and related whitenedFluxTimeSeries.uncertainties
%    2012-October-17, JL:
%        Error out when there are no enough data points for the fitter
%    2012-July-05, JL:
%        Implement the reduced parameter fit algorithm
%    2011-October-31, JL:
%        Use fixed 'cadencesUsed' when 'cadencesUsedFixedFlag' is true 
%    2011-August-19, JL:
%        add 'impactParameterRangeZeroToOne' as input of convert_impact_parameter
%    2011-June-28, JL:
%        add 'ratioPlanetRadiusToStarRadius' as input of convert_impact_parameter
%        check all fitted parameters to be finite and real
%    2011-June-09, JL:
%        robust weights are included in the calculation of allTransitSnr,
%        oddTransitSnr and evenTransitSnr in transitFitObject
%        take square root of dataWeight to be consistent with robustWeights
%    2011-June-06, JL:
%        calculate allTransitSnr, oddTransitSnr and evenTransitSnr in transitFitObject
%        based on the algorithm suggested by Jon
%    2011-March-04, JL:
%        delete the check of lower bounds of 'ratioPlanetRadiusToStarRadius'
%        'ratioSemiMajorAxisToStarRadius' and 'transitDurationHours' 
%    2011-February-28, JL;
%        check validity of parameters 'ratioPlanetRadiusToStarRadius' and
%        'ratioSemiMajorAxisToStarRadius'
%    2011-February-18, JL:
%        check validity of parameter 'transitDurationHours'   
%    2011-February-14, JL:
%        add lower/upper bounds to fitted parameters
%    2011-January-31, JL:
%        add the flag fitTimeCheckSkipped in 'model_function'
%    2010-Dec-01, JL:
%        fit a bug related to minImpactParameterPointer  
%    2010-Nov-05, JL:
%        when fitType is 11/13, run kepler_nonlinear_fit_soc with transitFitObject.targetFluxTimeSeries
%    2010-April-28, PT:
%        updates in support of transitGeneratorCollectionClass.  Eliminate use of scaled
%        light curve uncertainties.  
%    2009-November-09, PT:
%        change debug levels -- now debug >= 2 produces fit parameter values
%    2009-November-04, PT:
%        correct use of robust weights -- weights returned from kepler_nonlinear_fit_soc are actually
%        sqrt(weights).  
%    2009-September-23, PT:
%        switch to use of robust chisq and ndof.
%    2009-September-22, PT:
%        set robust weights for gapped / filled cadences to zero.
%    2009-September-16, PT:
%        update signature for set_par_values_in_transit_generator.
%    2009-September-08, PT:
%        eliminate annoying (but otherwise unimportant) /0 warning.
%    2009-August-21, PT:
%        changes in support of robust fitting.
%    2009-August-17, PT:
%        minor typo correction:  conversion from internal to external covariance matrix
%        should be s_ext = D * s_int * D'.  Since D is a diagonal matrix in this case the
%        typo (missing ') should have no effect, but we should get this right!
%    2009-August-06, PT:
%        move cadencesNotUsed logic to separate method, which is called here.
%    2009-July-27, PT:
%        support for bounded fitting of the impact parameter.
%
%=========================================================================================

% construct a complete list of gapped cadences, filled cadences, or cadences too far from
% a transit -- these are not to be used as fit constraints

  [cadencesUsed, cadencesNotUsed] = get_included_excluded_cadences( transitFitObject, true );
  
  if transitFitObject.configurationStruct.cadencesUsedFixedFlag
    cadencesUsed    = transitFitObject.configurationStruct.cadencesUsed;
    cadencesNotUsed = ~cadencesUsed; 
  end
  
  if sum(cadencesUsed)<20
      error('dv:fit_transit:noEnoughDataPointsForFitter', 'there are no enough data points for the fitter');
  end

  reducedParameterFitsEnabled = transitFitObject.configurationStruct.reducedParameterFitsEnabled;
  
% determine the weights of the data points -- for points which are to be used in the
% constraint the weight is 1 (due to the action of the whitening filter); for points which
% are not to be used, the weight is zero.

  deemphasisWeights = transitFitObject.deemphasisWeights;
  dataWeight = zeros( size( transitFitObject.whitenedFluxTimeSeries.values ) ) ;
%   dataWeight(cadencesUsed) = ...
%       1 ./ transitFitObject.whitenedFluxTimeSeries.uncertainties(cadencesUsed) ;
  dataWeight( cadencesUsed ) = deemphasisWeights( cadencesUsed );
  
% initialize the weights 
  
  transitFitObject.robustWeights = zeros( length( dataWeight ), 1 );
  transitFitObject.robustWeights( cadencesUsed ) = deemphasisWeights( cadencesUsed );
  residuals = zeros( length( dataWeight ), 1 );
  
% define the anonymous function -- it has the weights, and also reverses the order of the
% arguments, since the model_function requires the object as its first argument (since
% it's a class method), while the nlinfit model requires the vector of parameters as its
% first argument (because nlinfit wants it that way).  The model_function call also has a
% flag indicating whether the impact parameter which is passed is an internal value or an
% external one (in this case it's an internal one).

  weighted_model = @(b,x) sqrt( dataWeight(cadencesUsed) ) .* model_function(x, b, false, false, cadencesUsed) ;
  
% get the initial parameter values, converting the impact parameter from external to
% internal 

  fitType1 = transitFitObject.fitType(1);
  initialParValues    = transitFitObject.initialParValues(:);
  
  if fitType1>10
    parValueLowerBounds = transitFitObject.parValueLowerBounds(:);
    parValueUpperBounds = transitFitObject.parValueUpperBounds(:);
    parMessages         = transitFitObject.parMessages;
  end
  
  if ~reducedParameterFitsEnabled
      
      minImpactParameterPointer = [transitFitObject.parameterMapStruct.minImpactParameter];
      minImpactParameterPointer = minImpactParameterPointer(:);
      minImpactParameterPointer = minImpactParameterPointer(minImpactParameterPointer ~= 0 );
  
      if fitType1>10
      
          ratioPlanetRadiusPointer  = [transitFitObject.parameterMapStruct.ratioPlanetRadiusToStarRadius];
          ratioPlanetRadiusPointer  = ratioPlanetRadiusPointer(:);
          ratioPlanetRadiusPointer  = ratioPlanetRadiusPointer(ratioPlanetRadiusPointer ~= 0 );
  
          if ~isempty( minImpactParameterPointer ) && ~isempty( ratioPlanetRadiusPointer  )
              initialParValues( minImpactParameterPointer ) = convert_impact_parameter( initialParValues( minImpactParameterPointer ), 1, initialParValues(ratioPlanetRadiusPointer), ...
                                                                                  transitFitObject.configurationStruct.impactParameterRangeZeroToOne );
          end
    
      else
      
          if ~isempty( minImpactParameterPointer ) 
              initialParValues( minImpactParameterPointer ) = convert_impact_parameter( initialParValues( minImpactParameterPointer ), 1 );
          end
    
      end     
  
  end  
  
% do the fit via kepler_nonlinear_fit_soc and capture the returns which we want to capture
% When fitType is 11/13, run kepler_nonlinear_fit_soc with transitFitObject.targetFluxTimeSeries;
% otherwise, run kepler_nonlinear_fit_soc with transitFitObject.whitenedFluxTimeSeries

  if (fitType1==11) || (fitType1==13)

     [finalParValues, residualsUsedCadences, jacobian, parValueCovariance, chisq, sqrtRobustWeights] = ...
        kepler_nonlinear_fit_soc_dv( transitFitObject, sqrt( dataWeight( cadencesUsed ) ) .* transitFitObject.targetFluxTimeSeries.values(cadencesUsed),   ...
                     weighted_model, initialParValues, parValueLowerBounds, parValueUpperBounds, parMessages, transitFitObject.fitOptions );
                 
  elseif (fitType1>10)
      
     [finalParValues, residualsUsedCadences, jacobian, parValueCovariance, chisq, sqrtRobustWeights] = ...
        kepler_nonlinear_fit_soc_dv( transitFitObject, sqrt( dataWeight( cadencesUsed ) ) .* transitFitObject.whitenedFluxTimeSeries.values(cadencesUsed), ...
                     weighted_model, initialParValues, parValueLowerBounds, parValueUpperBounds, parMessages, transitFitObject.fitOptions ) ;
 
  else

     [finalParValues, residualsUsedCadences, jacobian, parValueCovariance, chisq, sqrtRobustWeights] = ...
        kepler_nonlinear_fit_soc( transitFitObject, sqrt( dataWeight( cadencesUsed ) ) .* transitFitObject.whitenedFluxTimeSeries.values(cadencesUsed), ...
                     weighted_model, initialParValues, transitFitObject.fitOptions ) ;
  
  end
  residuals(cadencesUsed) = residualsUsedCadences ;

% Save robustWeights
  
  if ~isempty( sqrtRobustWeights )
      transitFitObject.robustWeights( cadencesUsed ) = (sqrtRobustWeights.^2) .* deemphasisWeights( cadencesUsed );
  end
      
% the Jacobian is huge and not actually useful, so clear it

  clear jacobian ;
  
% convert the parameter values and the covariances to "external" values, if they were
% fitted.  Also, convert the impact parameter to abs of itself.

  if ~reducedParameterFitsEnabled
      
      if ~isempty( minImpactParameterPointer )
      
          if fitType1>10
          
              if ~isempty( ratioPlanetRadiusPointer )
                  [finalParValues( minImpactParameterPointer ), derivative] = convert_impact_parameter( finalParValues(minImpactParameterPointer), -1, finalParValues( ratioPlanetRadiusPointer ), ...
                                                                                                    transitFitObject.configurationStruct.impactParameterRangeZeroToOne );
              end
          
          else
          
                  [finalParValues( minImpactParameterPointer ), derivative] = convert_impact_parameter( finalParValues(minImpactParameterPointer), -1 );
          
          end

          covarianceTransformation = eye(size(parValueCovariance));
          for iPointer=1:length(minImpactParameterPointer)
              covarianceTransformation( minImpactParameterPointer(iPointer), minImpactParameterPointer(iPointer) ) = derivative(iPointer);
          end
          parValueCovariance = covarianceTransformation * parValueCovariance * covarianceTransformation';
          finalParValues(minImpactParameterPointer) = abs( finalParValues( minImpactParameterPointer) );
      
      end
  
  end
  transitFitObject.finalParValues       = finalParValues;
  transitFitObject.parValueCovariance   = parValueCovariance;
  
  transitFitObject.configurationStruct.cadencesUsed = cadencesUsed;

% replace the original transit generation object with one which has been updated with the
% fit parameters

  transitFitObject.transitGeneratorObject = set_par_values_in_transit_generator( ...
      transitFitObject.transitGeneratorObject, ...
      transitFitObject.fitType, ...
      transitFitObject.parameterMapStruct, ...
      transitFitObject.finalParValues ) ;

% Check validity of the parameter 'transitDurationHours'  

  planetModel          = get(transitFitObject.transitGeneratorObject, 'planetModel');
  transitDurationHours = planetModel.transitDurationHours;
  if ~isfinite(transitDurationHours) || ~isreal(transitDurationHours)
      error('dv:fit_transit:transitDurationHours_notReal', 'derived transitDurationHours is not a finite real number');
  end

  if fitType1>10
      
      transitEpochBkjd               = planetModel.transitEpochBkjd;
      ratioPlanetRadiusToStarRadius  = planetModel.ratioPlanetRadiusToStarRadius;
      ratioSemiMajorAxisToStarRadius = planetModel.ratioSemiMajorAxisToStarRadius; 
      minImpactParameter             = planetModel.minImpactParameter;
      orbitalPeriodDays              = planetModel.orbitalPeriodDays;
      
      if ~isfinite(transitEpochBkjd) || ~isreal(transitEpochBkjd)
          error('dv:fit_transit:transitEpochBkjd_notReal', 'fitted transitEpochBkjd is not a finite real number');
      end
      
      if ~isfinite(minImpactParameter) || ~isreal(minImpactParameter)
          error('dv:fit_transit:minImpactParameter_notReal', 'fitted minImpactParameter is not a finite real number');
      end
      
      if ~isfinite(orbitalPeriodDays) || ~isreal(orbitalPeriodDays)
          error('dv:fit_transit:orbitalPeriodDays_notReal', 'fitted orbitalPeriodDays is not a finite real number');
      end

      if abs( transitEpochBkjd - transitFitObject.configurationStruct.transitEpochBkjdTce ) > 1.0
          error('dv:fit_transit:transitEpochBkjd_bigDifferenceFromTceValue', 'big difference between fitted transitEpochBkjd and the corresponding TCE value');
      end
      
      if abs( orbitalPeriodDays - transitFitObject.configurationStruct.orbitalPeriodDaysTce ) > 1.0
          error('dv:fit_transit:orbitalPeriodDays_bigDifferenceFromTceValue', 'big difference between fitted orbitalPeriodDays and the corresponding TCE value');
      end
      
      if ~isfinite(ratioPlanetRadiusToStarRadius) || ~isreal(ratioPlanetRadiusToStarRadius)
          error('dv:fit_transit:ratioPlanetRadiusToStarRadius_notReal', 'fitted ratioPlanetRadiusToStarRadius is not a finite real number');
      end
%       if ratioPlanetRadiusToStarRadius <= transitFitObject.configurationStruct.ratioPlanetRadiusToStarRadiusLowerBound
%           error('dv:fit_transit:ratioPlanetRadiusToStarRadius_equalToOrSmallerThanLowerBound', 'fitted ratioPlanetRadiusToStarRadius is equal to or smaller than the lower bound');
%       end
      
      if ~isfinite(ratioSemiMajorAxisToStarRadius) || ~isreal(ratioSemiMajorAxisToStarRadius)
          error('dv:fit_transit:ratioSemiMajorAxisToStarRadius_notReal', 'fitted ratioSemiMajorAxisToStarRadius is not a finite real number');
      end
%       if ratioSemiMajorAxisToStarRadius <= transitFitObject.configurationStruct.ratioSemiMajorAxisToStarRadiusLowerBound
%           error('dv:fit_transit:ratioSemiMajorAxisToStarRadius_equalToOrSmallerThanLowerBound', 'fitted ratioSemiMajorAxisToStarRadius is equal to or smaller than the lower bound');
%       end
      
%       if transitDurationHours < transitFitObject.configurationStruct.transitDurationHoursLowerBound
%           error('dv:fit_transit:transitDurationHours_smallerThanLowerBound', 'derived transitDurationHours is smaller than the lower bound');
%       end
      
  end
  
% fill in chisq, ndof and modelFitSnr

  transitFitObject.robustWeights( cadencesNotUsed ) = 0 ;
  robustWeights                     = transitFitObject.robustWeights ;
  transitFitObject.chisq            = sum( residuals.^2 .* robustWeights ) ;
  transitFitObject.ndof             = sum( robustWeights ) - length( transitFitObject.finalParValues ) ;
  
  weightedModelLightCurveWhitened   = sqrt( dataWeight ) .* model_function(transitFitObject, transitFitObject.finalParValues, true, true);

  transitGeneratorObject            = transitFitObject.transitGeneratorObject;
  transitCadences                   = identify_transit_cadences(transitGeneratorObject, get(transitGeneratorObject, 'cadenceTimes'), 1);
  oddTransitCadences                = mod( transitCadences, 2 ) == 1;
  evenTransitCadences               = mod( transitCadences, 2 ) == 0 & transitCadences > 0;
  
% 2011-June-06, JL:
% The following algorithm to calculate modelFitSnr was suggested by Jon.

  gapIndicators                     = transitFitObject.whitenedFluxTimeSeries.gapIndicators;
  oddTransitFlag                    =   oddTransitCadences                         & ~gapIndicators;
  evenTransitFlag                   =                        evenTransitCadences   & ~gapIndicators;
  allTransitFlag                    = ( oddTransitCadences | evenTransitCadences ) & ~gapIndicators;
  oddTransitLightCurve              = sqrt( robustWeights( oddTransitFlag  ) ) .* weightedModelLightCurveWhitened( oddTransitFlag  );
  evenTransitLightCurve             = sqrt( robustWeights( evenTransitFlag ) ) .* weightedModelLightCurveWhitened( evenTransitFlag );
  allTransitLightCurve              = sqrt( robustWeights( allTransitFlag  ) ) .* weightedModelLightCurveWhitened( allTransitFlag  );
  
  transitFitObject.oddTransitSnr    = norm( oddTransitLightCurve  );
  transitFitObject.evenTransitSnr   = norm( evenTransitLightCurve );
  transitFitObject.allTransitSnr    = norm( allTransitLightCurve  );
    
  if ( transitFitObject.debugLevel > 1 )
      disp( [ '      Fit parameter values ' ] ) ;
      parNames = fieldnames( transitFitObject.parameterMapStruct(1) ) ;
      for iObject = length( transitFitObject.parameterMapStruct )
        for iPar = 1:length( parNames )
          parValuePointer = ...
              transitFitObject.parameterMapStruct(iObject).(parNames{iPar}) ;     
          if parValuePointer ~= 0
              disp( [ '         ', parNames{iPar},': ', ...
                  num2str( finalParValues(parValuePointer) ), ' +/- ', ...
                  num2str( sqrt( parValueCovariance(parValuePointer,parValuePointer) ) ) ] ) ;
          end
        end
      end
      disp( [ '      chisq / ndof = ', ...
          num2str( transitFitObject.chisq / transitFitObject.ndof ) ] ) ;
  end
  
return

% and that's it!

%
%
%

