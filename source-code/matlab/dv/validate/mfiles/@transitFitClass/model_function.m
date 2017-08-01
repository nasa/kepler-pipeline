function modelValues = model_function( transitFitObject, parameterArray, ...
    isImpactParameterExternal, fitTimeCheckSkipped, cadencesUsed )
%
% model_function -- returns a model time series for a transit with a given set of
% parameters
%
% modelTimeSeries = model_function( transitFitObject, parameterArray ) returns the model
%    flux time series for a transitFitClass object, given a vector of fit parameters.
%
% modelTimeSeries = modelFunction( ... , isImpactParameterExternal ) takes a flag
%    indicating whether the minImpact parameter has a bounded, "external" value (true,
%    default) or an unbounded, "internal" value (false).
%
% modelTimeSeries = modelFunction( ... , cadencesUsed ) returns the model flux time series
%    only for cadences which have cadencesUsed == true.
%
% Version date:  2012-July-05.
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
%    2012-July-05, JL:
%       Implement the reduced parameter fit algorithm
%    2011-August-19, JL:
%        add 'impactParameterRangeZeroToOne' as input of convert_impact_parameter
%    2011-June-28, JL:
%        add 'ratioPlanetRadiusToStarRadius' as input of convert_impact_parameter
%    2011-January-31, JL:
%        add the flag fitTimeCheckSkipped
%    2010-Nov-05, JL:
%        apply the whitening filter to the time series only when fitType is not 11 or 13
%    2010-April-27, PT:
%        changes in support of transitGeneratorCollectionClass.
%    2010-January-06, PT:
%        support for timing out fits.
%    2009-November-09, PT:
%        change debug levels -- now debugLevel >= 3 produces printout of parameter values.
%    2009-September-16, PT:
%        update signature of set_par_values_in_transit_generator.
%    2009-September-02, PT:
%        support for oddEvenFlag.
%    2009-July-27, PT:
%        support for bounded fitting.
%    2009-May-15, PT:
%        update to use median-corrected time series for fit.
%    2009-May-6:
%        update to match new understanding of transitGeneratorClass behavior.
%
%=========================================================================================

  if ~exist( 'fitTimeCheckSkipped', 'var' )
      fitTimeCheckSkipped = false;
  end
  
  reducedParameterFitsEnabled = transitFitObject.configurationStruct.reducedParameterFitsEnabled;
  fitType1                    = transitFitObject.fitType(1);

% check to see whether the fit needs to time out, if so throw an error (which is caught at
% the planet search level)

  datenumNow = datenum(now) ;
  if ~fitTimeCheckSkipped && datenumNow > transitFitObject.fitTimeoutDatenum
      error( 'dv:modelFunction:fitTimeLimitExceeded', ...
          'model_function:  fit time limit exceeded' ) ;
  end

% handle default value of isImpactParameterExternal

  if ~reducedParameterFitsEnabled
      
      if ~exist( 'isImpactParameterExternal', 'var' )
          isImpactParameterExternal = true ;
      end
  
% if the impact parameter is internal, convert to external

      impactParameterPointer = [transitFitObject.parameterMapStruct.minImpactParameter];
      impactParameterPointer = impactParameterPointer(:);
      impactParameterPointer = impactParameterPointer(impactParameterPointer ~= 0);

      if fitType1>10
      
            ratioPlanetRadiusPointer  = [transitFitObject.parameterMapStruct.ratioPlanetRadiusToStarRadius];
            ratioPlanetRadiusPointer  = ratioPlanetRadiusPointer(:);
            ratioPlanetRadiusPointer  = ratioPlanetRadiusPointer(ratioPlanetRadiusPointer ~= 0 );
  
          if  ~isImpactParameterExternal && ~isempty( impactParameterPointer ) && ~isempty( ratioPlanetRadiusPointer  )
              parameterArray( impactParameterPointer ) = convert_impact_parameter( parameterArray(impactParameterPointer), -1, parameterArray(ratioPlanetRadiusPointer), ...
                                                                             transitFitObject.configurationStruct.impactParameterRangeZeroToOne );
          end
 
      
      else
      
          if  ~isImpactParameterExternal && ~isempty( impactParameterPointer) 
              parameterArray( impactParameterPointer ) = convert_impact_parameter( parameterArray(impactParameterPointer), -1 );
          end
  
      end
      
  end

% display the parameters if required

  if ( transitFitObject.debugLevel > 2 )
      disp( parameterArray );
  end

% insert the parameters into the transit generator

  transitGeneratorObject = set_par_values_in_transit_generator( ...
      transitFitObject.transitGeneratorObject, ...
      transitFitObject.fitType, ...
      transitFitObject.parameterMapStruct, ...
      parameterArray ) ;
  
% generate the time series 

  modelValues = generate_planet_model_light_curve( transitGeneratorObject ) ;
  
% apply the whitening filter to the time series only when fitType is not 11 or 13

  if ~( (fitType1==11) || (fitType1==13) )
      [fluxValues, modelValues] = whiten_time_series( transitFitObject.whiteningFilterObject, modelValues );
  end
  
% if there is a specified set of cadences the caller wants, handle that now

  if exist( 'cadencesUsed', 'var' )
      modelValues = modelValues( cadencesUsed ) ;
  end
  
return

% and that's it!

