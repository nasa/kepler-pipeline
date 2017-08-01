function check_planet_candidate_struct_geometric_model( planetCandidate, planetCandidateExpected, iTarget, iPlanet )
%
% check_planet_candidate_struct_geometric_model -- verify that two planet candidate structs agree to within desired tolerances
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
%
%=========================================================================================


% start by checking out the fields in each struct

  fieldNames         = fieldnames( orderfields( planetCandidate ) );
  fieldNamesExpected = fieldnames( orderfields( planetCandidateExpected ) );
  
  assert_equals( fieldNames, fieldNamesExpected, ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' planetCandidate fields not correct!'] );
  
% some of the fields should agree identically -- check those now

  assert_equals( planetCandidate.keplerId, planetCandidateExpected.keplerId, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' keplerId value does not match expected!'] );
  assert_equals( planetCandidate.planetNumber, planetCandidateExpected.planetNumber, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' planetNumber value does not match expected!'] );
  assert_equals( planetCandidate.suspectedEclipsingBinary, planetCandidateExpected.suspectedEclipsingBinary, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' suspectedEclipsingBinary value does not match expected!'] );
  assert_equals( planetCandidate.statisticRatioBelowThreshold, planetCandidateExpected.statisticRatioBelowThreshold, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' statisticRatioBelowThreshold value does not match expected!'] );
  assert_equals( planetCandidate.expectedTransitCount, planetCandidateExpected.expectedTransitCount, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' expectedTransitCount value does not match expected!'] );
  assert_equals( planetCandidate.observedTransitCount, planetCandidateExpected.observedTransitCount, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' observedTransitCount value does not match expected!'] );
  assert_equals( planetCandidate.significance, planetCandidateExpected.significance, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' suspectedEclipsingBinary value does not match expected!'] );

% Epoch and orbital period may agree only approximately

  mlunit_assert( abs(planetCandidate.epochMjd - planetCandidateExpected.epochMjd) < 0.1, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), 'epoch value does not match expected!'] );
  mlunit_assert( abs(planetCandidate.orbitalPeriod - planetCandidateExpected.orbitalPeriod) < 0.1, ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), 'orbital period value does not match expected!'] );
  
% MES and SES may agree only very approximately, say within a factor of 3 or so

  mlunit_assert( abs( log(planetCandidate.maxSingleEventSigma) - log(planetCandidateExpected.maxSingleEventSigma) ) < log(3), ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' maxSingleEventSigma value does not match expected!']   );
  mlunit_assert( abs( log(planetCandidate.maxMultipleEventSigma) - log(planetCandidateExpected.maxMultipleEventSigma) ) < log(3), ...
      ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), ' maxMultipleEventSigma value does not match expected!'] );
  
% for the residual flux time series, check that the values which are not gapped in either time series agree to within a few times their errors

  check_flux_time_series_geometric_model( planetCandidate.initialFluxTimeSeries, planetCandidateExpected.initialFluxTimeSeries, iTarget, iPlanet, 5, ...
      'initial flux time series' );

return

% and that's it!
