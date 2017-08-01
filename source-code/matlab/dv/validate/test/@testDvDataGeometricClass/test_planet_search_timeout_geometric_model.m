function self = test_planet_search_timeout_geometric_model( self )
%
% test_planet_search_timeout_geometric_model -- unit test of dvDataClass method perform_dv_planet_search_and_model_fitting when the fitter timeout limit is hit
%
% This unit test exercises the following functionality of the method:
%
% ==> Fit exits with an alert when the fitter timeout limit is hit.
%
% This test is intended to be executed in the mlunit context.  For standalone execution use the following syntax:
%
%      run(text_test_runner, testDvDataGeometricClass('test_planet_search_timeout_geometric_model'));
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

  disp(' ');
  disp('... testing planet-search method at timeout limit with geometric transit model ... ');
  disp(' ');
  
  dvDataFilename = 'planet-search-test-data';
  testDvDataGeometricClass_fitter_initialization;
  
% set the time for the fitter to zero

  dvDataStruct.planetFitConfigurationStruct.fitterTimeoutFraction = 0;
  dvDataObject = dvDataClass( dvDataStruct );
  
% create the directories for the figures to be shoved into

  dvResultsStruct = create_directories_for_dv_figures( dvDataObject, dvResultsStructBeforeFit );
  
% execute the planet search method

  refTime = clock;  
  dvResultsStruct = perform_dv_planet_search_and_model_fitting( dvDataObject, dvResultsStructBeforeFit, ...
      normalizedFluxTimeSeriesWithHarmonicsArray, normalizedFluxTimeSeriesHarmonicsFreeArray, refTime );
  
% In the results struct, the planetResultsStruct should be the same as it was before (ie, no results in it)

  assert_equals( dvResultsStruct.targetResultsStruct.planetResultsStruct, dvResultsStructBeforeFit.targetResultsStruct.planetResultsStruct, 'planetResultsStruct not as expected!' );
  
% There should be 1 alert, which mentions fitTimeLimitExceeded

  assert_equals( length( dvResultsStruct.alerts ), 1, 'length of alerts ~= 1!' );
  mlunit_assert( ~isempty( strfind( dvResultsStruct.alerts.message, 'fitTimeLimitExceeded' ) ), 'Alert message does not mention fitTimeLimitExceeded!' );
  
  disp(' ');
  
return

% and that's it!
