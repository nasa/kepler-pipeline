function self = test_fill_gaps_in_time_series( self )
%
% test_fill_gaps_in_time_series -- unit test of quarterStitchingClass method
% fill_gaps_in_time_series
%
% This unit test exercises the following functionality of the method:
%
% ==> Gaps are filled
% ==> The non-gap data values are not impacted
% ==> The gap indicator flags and fill indices are updated.
%
% This test is performed in the mlunit context.  For standalone operation, use the
% following syntax:
%
%      run(text_test_runner, testQuarterStitchingClass('test_fill_gaps_in_time_series'));
%
% Version date:  2010-October-22.
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
%    2010-October-22, PT:
%        test the behavior of the gap-filler on gapped uncertainties.
%
%=========================================================================================

  disp(' ... testing gap-filling method ... ') ;
  
% set the test data path and retrieve the input struct 

  tpsDataFile = 'tps-multi-quarter-struct' ;
  tpsDataStructName = 'tpsInputs' ;
  tps_testing_initialization ;
  load( fullfile( testDataPath, 'quarterStitchingClass-harmonics-corrected-struct' ) ) ;
  
% set rand seed

  s = RandStream('mcg16807','Seed',0) ;
  RandStream.setDefaultStream(s) ;  
  
% validate the input and update the quarterStitchingStruct with anything
% new that it might need
  
  dummyKeplerId = 0 ;
  nTargets = length(quarterStitchingStruct.timeSeriesStruct) ;
  tpsInputs.tpsTargets = tpsInputs.tpsTargets(1) ;
  tpsInputs.tpsTargets.keplerId = dummyKeplerId ;
  tpsInputs.tpsTargets(1:nTargets) = tpsInputs.tpsTargets;
  tpsInputs = validate_tps_input_structure( tpsInputs ) ;
  
  for i=1:nTargets
      quarterStitchingStruct.timeSeriesStruct(i).keplerId = 0;
  end
  quarterStitchingStruct.gapFillParametersStruct = tpsInputs.gapFillParameters ;
  quarterStitchingStruct.harmonicsIdentificationParametersStruct = tpsInputs.harmonicsIdentificationParameters ;
  quarterStitchingStruct.randStreams = tpsInputs.randStreams ;  
  quarterStitchingStruct.quarterStitchingParametersStruct.varianceWindowLengthMultiplier = ...
      tpsInputs.tpsModuleParameters.varianceWindowLengthMultiplier ;
  quarterStitchingStruct.quarterStitchingParametersStruct.deemphasizePeriodAfterTweakInCadences = ...
      tpsInputs.tpsModuleParameters.deemphasizePeriodAfterTweakInCadences ;
  
% instantiate the object and perform all of the necessary steps in the processing

  quarterStitchingObject = quarterStitchingClass( quarterStitchingStruct ) ;  
  quarterStitchingObjectFinal = fill_gaps_in_time_series( quarterStitchingObject ) ;
  
% retrieve the two sets of time series structs

  quarterStitchingStruct2     = struct( quarterStitchingObject ) ;
  timeSeriesStruct2           = quarterStitchingStruct2.timeSeriesStruct ;
  quarterStitchingStructAfter = struct( quarterStitchingObjectFinal ) ;
  timeSeriesStructAfter       = quarterStitchingStructAfter.timeSeriesStruct ;
  
% loop over targets

  for iTarget = 1:length( timeSeriesStruct2 )
      
      target      = timeSeriesStruct2(iTarget) ;
      targetAfter = timeSeriesStructAfter(iTarget) ;
      
      gapIndicators      = target.gapIndicators ;
      gapIndicatorsAfter = targetAfter.gapIndicators ;
      fillIndices        = target.fillIndices ;
      fillIndicesAfter   = targetAfter.fillIndices ;
      
%     test 1:  gaps are present in original struct, and are filled in the post-fill
%     struct.  Note that individual cadence values afterwards can be zero, just not all of
%     them.

      mlunit_assert( all( target.values(gapIndicators) == 0 ) && ...
          std( targetAfter.values(gapIndicators) ) > 0, ...
          [ 'Gapped cadence values in target ', num2str(iTarget), ' not as expected!' ] ) ;
      
%     test 2:  ungapped data is not touched:  since we median-corrected the values after
%     gap filling, the two need not be identically equal, but the offset between the
%     before and after values must be constant across the time series to within fairly
%     tight limits

      mlunit_assert( ...
          std( target.values(~gapIndicators) - targetAfter.values(~gapIndicators) ) < 1e-12, ...
          [ 'Ungapped cadence values in target ', num2str(iTarget), ' not as expected!' ] ) ;
      
%     test 3:  after filling, gapped cadences are converted to filled

      mlunit_assert( any( gapIndicators ) && all( ~gapIndicatorsAfter ), ...
          [ 'Gap indicators on target ', num2str(iTarget), ' not as expected!' ] ) ;
      assert_equals( sort(unique( [fillIndices(:) ; find(gapIndicators)] ) ), ...
          fillIndicesAfter(:), ...
          [ 'Fill indices on target ', num2str(iTarget), ' not as expected!' ] ) ;
      
%     test 4:  after filling, uncertaintes on ungapped cadences are unchanged,
%     uncertainties on gapped cadences are -1

      assert_equals( target.uncertainties( ~gapIndicators ), ...
          targetAfter.uncertainties( ~gapIndicators ), ...
          'Ungapped uncertainties are changed!' ) ;
      mlunit_assert( all( -1 == targetAfter.uncertainties( gapIndicators ) ), ...
          'Gapped uncertainties are not all set to -1!' ) ;
      
  end
  
  disp('') ;
  
return

% and that's it!

%
%
%

