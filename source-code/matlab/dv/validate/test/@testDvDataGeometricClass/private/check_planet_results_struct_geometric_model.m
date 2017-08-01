function check_planet_results_struct_geometric_model( planetResultsStruct, planetResultsStructExpected, iTarget, iPlanet )
%
% check_planet_results_struct_geometric_model -- verify that two planet results structs agree to within desired tolerances
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
%    2010-August-13, PT:
%        protect against orbital periods which are not fitted but are asserted.
%
%=========================================================================================


% step 1 is to do a comparison of field names and dimensions

  fieldNames         = fieldnames( orderfields( planetResultsStruct ) );
  fieldNamesExpected = fieldnames( orderfields( planetResultsStructExpected ) );
  
  assert_equals( fieldNames, fieldNamesExpected, ['Target ', num2str(iTarget), ' planet ', num2str(iPlanet), 'planetResultsStruct fields not correct!'] );
  
% loop over fields; for substructs, check dimensions, for other classes check values

  for iField = 1:length(fieldNames)
      
      if isstruct( planetResultsStruct.(fieldNames{iField}) ) 
          
          assert_equals( size( planetResultsStruct.(fieldNames{iField}) ), size( planetResultsStructExpected.(fieldNames{iField}) ), ...
              ['Target ',num2str(iTarget), ' planet ', num2str(iPlanet), ' field ', fieldNames{iField}, ' has wrong dimensions!'] );
          
      else
          
          assert_equals( planetResultsStruct.(fieldNames{iField}), planetResultsStructExpected.(fieldNames{iField}), ...
              ['Target ',num2str(iTarget), ' planet ', num2str(iPlanet), ' field ', fieldNames{iField}, ' has wrong values!'] );
              
      end
      
  end
  
% drill down and perform checkout on the planet candidate struct

  check_planet_candidate_struct_geometric_model( planetResultsStruct.planetCandidate, planetResultsStructExpected.planetCandidate, iTarget, iPlanet );
  
% perform checkout on the transit fit results structs -- note that, if the odd-transits or even-transits fit has only 1 transit, the uncertainty on the fitted period will be zero,
% which can cause a failure in the check process despite excellent agreement on the parameters.  Protect against this corner-case by allowing the uncertainty from the all-transits
% fit to be used

 orbitalPeriodIndex = find( strcmp( {planetResultsStruct.allTransitsFit.modelParameters.name}, 'orbitalPeriodDays' ) );
 substituteOrbitalPeriodUncertaintyOdd  = [];
 substituteOrbitalPeriodUncertaintyEven = [];
 
 if ~planetResultsStruct.oddTransitsFit.modelParameters(orbitalPeriodIndex).fitted
     substituteOrbitalPeriodUncertaintyOdd   = planetResultsStruct.allTransitsFit.modelParameters(orbitalPeriodIndex).uncertainty;
 end
 if ~planetResultsStruct.evenTransitsFit.modelParameters(orbitalPeriodIndex).fitted
     substituteOrbitalPeriodUncertaintyEven  = planetResultsStruct.allTransitsFit.modelParameters(orbitalPeriodIndex).uncertainty;
 end

  check_transit_fit_struct_geometric_model( planetResultsStruct.allTransitsFit, planetResultsStructExpected.allTransitsFit, iTarget, iPlanet, 'all-transits fit' );
  check_transit_fit_struct_geometric_model( planetResultsStruct.oddTransitsFit, planetResultsStructExpected.oddTransitsFit, iTarget, iPlanet, 'odd-transits fit', ...
      substituteOrbitalPeriodUncertaintyOdd  );
  check_transit_fit_struct_geometric_model( planetResultsStruct.evenTransitsFit, planetResultsStructExpected.evenTransitsFit, iTarget, iPlanet, 'even-transits fit', ...
      substituteOrbitalPeriodUncertaintyEven );
  
return 

% and that's it!
