function check_transit_fit_struct( transitFitStruct, transitFitStructExpected, ...
    iTarget, iPlanet, fitName, substituteOrbitalPeriod ) 
%
% check_transit_fit_struct( transitFitStruct, transitFitStructExpected, iTarget, iPlanet,
% fitName ) -- verify that two transit fit structs agree to within desired tolerances
%
% Version date:  2010-August-13.
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
%    2010-August-13, PT:
%        bugfix:  uncertainty should be a vector obtained by concatenation, not a scalar.
%        Comment out covariance test.  Protect against orbital periods which are not
%        fitted but asserted.
%
%=========================================================================================


% start by checking the names of the fields

  fieldNames = fieldnames( orderfields( transitFitStruct ) ) ;
  fieldNamesExpected = fieldnames( orderfields( transitFitStructExpected ) ) ;
  
  assert_equals( fieldNames, fieldNamesExpected, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' ', fitName, ...
      ' field names not as expected!'] ) ;
  
% some of the fields should be identical between the two sets

  assert_equals( transitFitStruct.keplerId, transitFitStructExpected.keplerId, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' ', fitName, ...
      ' keplerId value not as expected!'] ) ;
  assert_equals( transitFitStruct.limbDarkeningModelName, ...
      transitFitStructExpected.limbDarkeningModelName, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' ', fitName, ...
      ' limbDarkeningModelName value not as expected!'] ) ;
  assert_equals( transitFitStruct.planetNumber, transitFitStructExpected.planetNumber, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' ', fitName, ...
      ' planetNumber value not as expected!'] ) ;
  assert_equals( transitFitStruct.robustWeights, transitFitStructExpected.robustWeights, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' ', fitName, ...
      ' robustWeights values not as expected!'] ) ;
  assert_equals( transitFitStruct.transitModelName, ...
      transitFitStructExpected.transitModelName, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' ', fitName, ...
      ' transitModelName value not as expected!'] ) ;
  assert_equals( transitFitStruct.modelDegreesOfFreedom, ...
      transitFitStructExpected.modelDegreesOfFreedom, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' ', fitName, ...
      ' modelDegreesOfFreedom value not as expected!'] ) ;

% The model chi-square should agree to about 5% between the two structs

  mlunit_assert( abs( transitFitStruct.modelChiSquare - ...
      transitFitStructExpected.modelChiSquare ) < 0.05 * ...
      transitFitStructExpected.modelChiSquare, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' ', fitName, ...
      ' modelChiSquare value not as expected!'] ) ;
      
% The uncertainties should agree to about 16%, so the covariance should agree to about 33%

  covarianceDiff = transitFitStruct.modelParameterCovariance - ...
      transitFitStructExpected.modelParameterCovariance ;
  
%   mlunit_assert( all( abs(covarianceDiff) <= 0.33 * ...
%       abs(transitFitStructExpected.modelParameterCovariance) ), ...
%       ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' ', fitName, ...
%       ' modelParameterCovariance value not as expected!'] ) ;

% Now into the model parameters struct -- the name and fitted parameters should agree
% exactly

  assert_equals( {transitFitStruct.modelParameters.name}, ...
      {transitFitStructExpected.modelParameters.name}, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' ', fitName, ...
      ' model parameter names not as expected!'] ) ;
  assert_equals( {transitFitStruct.modelParameters.fitted}, ...
      {transitFitStructExpected.modelParameters.fitted}, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' ', fitName, ...
      ' model parameter fitted flags not as expected!'] ) ;

% The values should agree to within a few times the uncertainties, and the uncertainties
% should agree to within 16% of themselves

  parameterDiff = [transitFitStruct.modelParameters.value] - ...
      [transitFitStructExpected.modelParameters.value] ;
  uncertaintyDiff = [transitFitStruct.modelParameters.uncertainty] - ...
      [transitFitStructExpected.modelParameters.uncertainty] ;
  uncertainty = [transitFitStruct.modelParameters.uncertainty] ;
  
  mlunit_assert( all( abs( uncertaintyDiff) <= 0.16 * uncertainty ), ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' ', fitName, ...
      ' model parameter uncertainties not as expected!'] ) ;
  
  orbitalPeriodIndex = find( strcmp( {transitFitStruct.modelParameters.name}, ...
      'orbitalPeriodDays' ) ) ;
  if ~transitFitStruct.modelParameters(orbitalPeriodIndex).fitted && ...
          exist('substituteOrbitalPeriod','var') && ~isempty( substituteOrbitalPeriod )
      uncertainty(orbitalPeriodIndex) = substituteOrbitalPeriod ;
  end
  
  mlunit_assert( all( abs(parameterDiff) <= 5 * uncertainty ), ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' ', fitName, ...
      ' model parameter values not as expected!'] ) ;
      
return

% and that's it!

%
%
%
