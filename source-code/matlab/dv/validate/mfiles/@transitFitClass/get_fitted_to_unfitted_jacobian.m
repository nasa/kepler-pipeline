function jacobian = get_fitted_to_unfitted_jacobian( transitFitObject, fieldOrdering, iObject )
%
% get_fitted_to_unfitted_jacobian -- compute the Jacobian from the fitted parameters in a
% transitFitClass object to the unfitted ones, at the fitted parameter values.
%
% jacobian = get_fitted_to_unfitted_jacobian( transitFitObject, fieldOrdering ) computes 
%    the Jacobian from the fitted parameters in a transit fit to the unfitted (derived)
%    parameters.  Argument fieldOrder shows the desired order of the fields in the
%    Jacobian (ie, for a fit which includes epoch, planet size, semi-major axis, and
%    orbital period as parameters, fieldOrder == [1 4 5 11 2 3 6 7 8 9 10], since the
%    fitted parameters are parameters 1, 4, 5, and 11 in the planetModel).  
%
% jacobian = get_fitted_to_unfitted_jacobian( ..., inclinationAngleFlag ) allows the users
%    to specify that the Jacobian should include the terms related to the inclination
%    angle calculation (default is false).
%
% jacobian = get_fitted_to_unfitted_jacobian( ..., iObject ) allows the users
%    to specify which of the transitGeneratorCollectionClass' embedded transit objects to
%    use for the calculation (default is 1).
%
% Version date:  2012-August-23.
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
%    2012-August-23, JL:
%        Move calculation of inclination angle to transitGeneratorClass
%    2012-July-05, JL:
%       Implement the reduced parameter fit algorithm
%    2012-April-23, JT and JL:
%        comment the line for 8.2 to set transitDepthPpm in planetModel to 
%        (ratioPlanetRadiusToStarRadius)^2 *1e6 when Jacobian matrix is calculated 
%    2012-March-05, JL:
%        set transitDepthPpm in planetModel to (ratioPlanetRadiusToStarRadius)^2 *1e6
%        when Jacobian matrix is calculated 
%    2010-Dec-01, JL:
%        add finalParValues and parameterMapArray as inputs of the function
%        jacobian_private_model
%    2010-Nov-05, JL:
%        when geometric transit model is used, call the transitGeneratorClass method
%        compute_inclination_angle_with_geometric_model 
%    2010-April-28, PT:
%        updates in support of transitGeneratorCollectionClass.
%    2009-September-16, PT:
%        update signature of set_par_values_in_transit_generator.
%    2009-August-21, PT:
%        handle case where the impact parameter is very close to 1.0.  
%
%=========================================================================================

% if iObject is missing, set it to 1

  if ~exist( 'iObject', 'var' ) || isempty( iObject )
      iObject = 1 ;
  end
  
  reducedParameterFitsEnabled = transitFitObject.configurationStruct.reducedParameterFitsEnabled;

% get the object we are going to use

  transitObject = get(transitFitObject.transitGeneratorObject, 'transitGeneratorObjectVector');
  
% define the stepSize vector based on the default step size used by kepler_nonlinear_fit_soc

  nlinfitOptions = kepler_set_soc('kepler_nonlinear_fit_soc') ;
  stepSize = nlinfitOptions.DerivStep * ones(size(transitFitObject.finalParValues)) ;

% Check and see whether the impact parameter is a fit parameter.  If it is, we should use
% a negative value of the step size for it, and in any event we should limit the number of
% iterations

  nIter = 10 ;
  maxDelta = [] ;
  if ~reducedParameterFitsEnabled
      if ( transitFitObject.parameterMapStruct(iObject).minImpactParameter ~= 0 )
          impactParameterPointer = transitFitObject.parameterMapStruct(iObject).minImpactParameter ;
          stepSize(impactParameterPointer) = -stepSize(impactParameterPointer) ;
          nIter = floor( -log10( -stepSize(impactParameterPointer) ) ) ;
          maxDelta = 0.9 ;
      end
  end
  
% select the parameters to use in the calculation

  parameterMapArray = struct2array( transitFitObject.parameterMapStruct(iObject) ) ;
  parameterMapArray = parameterMapArray( parameterMapArray ~= 0 ) ;
  parValues = transitFitObject.finalParValues( parameterMapArray ) ;
  stepSize = stepSize( parameterMapArray ) ;

% define an anonymous function which matches the parameters to what compute_jacobian requires

  jacobian_model = @(modelPars) jacobian_private_model( transitObject(iObject), modelPars, transitFitObject.finalParValues, parameterMapArray, ...
      fieldOrdering, transitFitObject.parameterMapStruct(iObject), transitFitObject.fitType(iObject) );

% do the calculation

  jacobian = compute_jacobian( jacobian_model, parValues, [], stepSize, nIter, maxDelta, [], 'nothing' );
  
return



% subfunction which takes the fitted parameters and returns the unfitted ones in a nice
% vector

function unfittedParValues = jacobian_private_model( transitObject, modelPars, finalParValues, parameterMapArray, ...
    fieldOrdering, parameterMapStruct, fitType )

% update corresponding elements of finalParValues with modelPars

  finalParValues( parameterMapArray ) = modelPars;
  
% Get a transit generator object with the modelPars put into it

  transitGeneratorObject = set_par_values_in_transit_generator( ...
      transitObject, ...
      fitType, ...
      parameterMapStruct, ...
      finalParValues ) ;
  
  planetModel = get( transitGeneratorObject, 'planetModel' ) ;
  nFittedPars = length(modelPars) ; 
  nUnfittedPars = length(fieldOrdering) - nFittedPars ; 
  unfittedParValues = zeros( nUnfittedPars, 1 );
  
% Set transitDepthPpm in planetModel to (ratioPlanetRadiusToStarRadius)^2 *1e6
% Commnet the line below for 8.2 -- JT and JL on 04/23/2012 

%  planetModel.transitDepthPpm = (planetModel.ratioPlanetRadiusToStarRadius)^2 * 1e6;
  
% get the field names from the planet model

  planetModelFieldNames = fieldnames( planetModel ) ;
  
% loop and fill in the desired values

  for iPar = 1:nUnfittedPars
      
      unfittedParValues(iPar) = planetModel.(planetModelFieldNames{fieldOrdering(iPar+nFittedPars)});
      
  end
  
return

