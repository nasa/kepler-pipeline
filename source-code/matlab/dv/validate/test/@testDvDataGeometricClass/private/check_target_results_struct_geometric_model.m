function check_target_results_struct_geometric_model( targetResultsStruct, targetResultsStructExpected, iTarget )
%
% check_target_results_struct_geometric_model -- perform tests on two targetResultsStruct structures to verify that their agreement is within desired limits
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
%    2010-July-08, PT:
%       modification so that the initial assert_equals looks only to verify that the field
%       names are identical, not that the structs are identical to the bit.
%
%=========================================================================================

  assert_equals( fieldnames(orderfields( targetResultsStruct )) , fieldnames(orderfields( targetResultsStructExpected )), ...
      ['Fields of target ', num2str(iTarget), ' results are not as expected!'] );

  targetFields = fieldnames( targetResultsStructExpected );

  for iField = 1:length(targetFields)

      structField         = targetResultsStruct.(targetFields{iField});
      structFieldExpected = targetResultsStructExpected.(targetFields{iField});
      if ( isstruct( structFieldExpected ) )
          assert_equals( size( structField ), size( structFieldExpected ), ['Target ', num2str(iTarget), ' field ', targetFields{iField}, ' dimension mismatch!'] );
      else
          assert_equals( structField, structFieldExpected, ['Target ', num2str(iTarget), ' field ', targetFields{iField}, ' value mismatch!'] ) ;
      end

  end
              
% for the residual flux time series, check that the values which are not gapped in either time series agree to within a few times their errors

  check_flux_time_series_geometric_model( targetResultsStruct.residualFluxTimeSeries, targetResultsStructExpected.residualFluxTimeSeries, ...
      iTarget, [], 5, 'residual flux time series' );
      
% check the dimensions and fields of the single event statistics

  ses         = targetResultsStruct.singleEventStatistics;
  sesExpected = targetResultsStructExpected.singleEventStatistics;

  assert_equals( size( ses ), size( sesExpected ), ['Target ', num2str(iTarget), ' single event statistics dimensions incorrect!'] );

  for iPulseLength = 1:length( ses )
      check_single_event_statistics_struct( ses(iPulseLength), sesExpected(iPulseLength), iTarget, iPulseLength );
  end
      
% check the dimensions of the planet results struct

  planetResultsStruct = targetResultsStruct.planetResultsStruct;
  planetResultsStructExpected = targetResultsStructExpected.planetResultsStruct;
  assert_equals( size( planetResultsStruct ), size( planetResultsStructExpected ), ['Target ', num2str(iTarget), ' planet results struct dimensions incorrect!'] );
      
% go through the planet results struct and check the values and substructure

  for iPlanet = 1:length( planetResultsStruct )
      check_planet_results_struct_geometric_model( planetResultsStruct(iPlanet), planetResultsStructExpected(iPlanet), iTarget, iPlanet );
  end
      
return

% and that's it!

%
%
%

%=========================================================================================

% subfunction to perform checking on a single event statistics struct

function check_single_event_statistics_struct( ses, sesExpected, iTarget, iPulseLength )

% Does the trial transit pulse duration match expected value?

  assert_equals( ses.trialTransitPulseDuration, sesExpected.trialTransitPulseDuration, ...
      ['Target ', num2str( iTarget ), ' pulse length # ', num2str( iPulseLength ), 'trial transit pulse duration not as expected!'] );
  
% are the fields the same, and are their classes and dimensions the same, as expected?

  assert_equals( fieldnames(orderfields( ses )), fieldnames(orderfields( sesExpected )), ...
      ['Fields in target ', num2str( iTarget ), ' pulse length # ', num2str( iPulseLength ),' single event statistics struct not as expected!'] );
  
% drill down to the correlation time series and normalization time series and make sure they are properly formed

  check_ses_time_series( ses.correlationTimeSeries,   sesExpected.correlationTimeSeries,   iTarget, iPulseLength, 'correlation'   );
  check_ses_time_series( ses.normalizationTimeSeries, sesExpected.normalizationTimeSeries, iTarget, iPulseLength, 'normalization' );
  
return

%=========================================================================================

% subfunction which performs checkout on the SES time series

function check_ses_time_series( ses, sesExpected, iTarget, iPulseLength, timeSeriesName ) 
  
  assert_equals( size(ses.values), size(sesExpected.values), ...
      ['Size of values field in target ',  num2str(iTarget), ' pulse length # ',        num2str( iPulseLength ),' ', timeSeriesName, ' struct not as expected!'] );
  assert_equals( class(ses.values), class(sesExpected.values), ...
      ['Class of values field in target ', num2str(iTarget), ' pulse length # ',        num2str( iPulseLength ),' ', timeSeriesName, ' struct not as expected!'] );
  assert_equals( size(ses.gapIndicators), size(sesExpected.gapIndicators), ...
      ['Size of gapIndicators field in target ', num2str(iTarget), ' pulse length # ',  num2str( iPulseLength ),' ', timeSeriesName, ' struct not as expected!'] );
  assert_equals( class(ses.gapIndicators), class(sesExpected.gapIndicators), ...
      ['Class of gapIndicators field in target ', num2str(iTarget), ' pulse length # ', num2str( iPulseLength ),' ', timeSeriesName, ' struct not as expected!'] );

return  
  
% and that's it -- note that we do not make any attempt to check values, as changes to codebase outside of DV can cause changes in these values, 
% and we do not want those codebase changes to cause failure of this unit test.



