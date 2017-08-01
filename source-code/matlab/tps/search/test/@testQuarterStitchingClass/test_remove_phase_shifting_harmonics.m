function self = test_remove_phase_shifting_harmonics( self )
%
% test_remove_phase_shifting_harmonics -- unit test of quarterStitchingClass method
% remove_phase_shifting_harmonics
%
% This unit test exercises the following functionality of the method:
%
% ==> The method removes harmonics from the time series quarter by quarter
% ==> The harmonics-removed time series are restored to the values member, while the
%     removed harmonics are stored in the harmonicsValues member.
%
% This test is performed in the mlunit context.  For standalone operation, use the
% following syntax:
%
%      run(text_test_runner, testQuarterStitchingClass('test_remove_phase_shifting_harmonics'));
%
% Version date:  2010-December-02.
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
%    2010-December-02, PT:
%        eliminate test case which only had harmonics due to problems with edge
%        detrending; now that edge detrending algorithm is fixed (or at least improved),
%        that case no longer has "harmonics" to remove.
%
%=========================================================================================

  disp(' ... testing harmonic removal method ... ') ;
  
% set the test data path and retrieve the standard input struct 

  tpsDataFile = 'tps-multi-quarter-struct' ;
  tpsDataStructName = 'tpsInputs' ;
  tps_testing_initialization ;
  load( fullfile( testDataPath, 'quarterStitchingClass-struct' ) ) ;
  
% validate the input and update the quarterStitchingStruct with anything
% new that it might need
  
  nTargets = length(quarterStitchingStruct.timeSeriesStruct) ;
  tpsInputs.tpsTargets = tpsInputs.tpsTargets(1) ;
  tpsInputs.tpsTargets(1:nTargets) = tpsInputs.tpsTargets;
  tpsInputs = validate_tps_input_structure( tpsInputs ) ;
  quarterStitchingStruct.gapFillParametersStruct = tpsInputs.gapFillParameters ;
  quarterStitchingStruct.harmonicsIdentificationParametersStruct = tpsInputs.harmonicsIdentificationParameters ;
  quarterStitchingStruct.randStreams = tpsInputs.randStreams ;

% to keep execution time acceptable, go down to only 9 targets, none of which have
% extremely high frequency harmonics

  targetsToKeep = [13 19 20 29 36 37 47 63 76] ;
  quarterStitchingStruct.timeSeriesStruct = ...
      quarterStitchingStruct.timeSeriesStruct( targetsToKeep ) ;
  for iTarget = 1:length(quarterStitchingStruct.timeSeriesStruct)
      quarterStitchingStruct.timeSeriesStruct(iTarget).keplerId = 11703707 ;
  end
  
% instantiate the object and take it through the stitching steps prior to harmonics
% removal

  quarterStitchingObject = quarterStitchingClass( quarterStitchingStruct ) ;
  quarterStitchingObject = median_correct_time_series( quarterStitchingObject ) ;
  quarterStitchingStruct2 = struct( quarterStitchingObject ) ;
  quarterStitchingObject = remove_phase_shifting_harmonics( quarterStitchingObject ) ;
  quarterStitchingStructAfter = struct( quarterStitchingObject ) ;
  
% loop over targets

  for iTarget = 1:length( quarterStitchingStruct2.timeSeriesStruct )
      
      timeSeriesStruct      = quarterStitchingStruct2.timeSeriesStruct(iTarget) ;
      timeSeriesStructAfter = quarterStitchingStructAfter.timeSeriesStruct(iTarget) ;
      gapIndicators         = timeSeriesStruct.gapIndicators ;
      
%     the harmonics should not all be zero

      mlunit_assert( any( timeSeriesStructAfter.harmonicsValues ~= 0 ), ...
          [ 'Harmonics values identically zero in target ', num2str( iTarget ),'!' ] ) ;
      
%     the sum of the harmonics and the new values should be equal to the old values

      mlunit_assert( all( abs( timeSeriesStructAfter.harmonicsValues + ...
          timeSeriesStructAfter.values - timeSeriesStruct.values ) < 1e-12 ), ...
          [ 'Harmonics + values not as expected for target ', num2str(iTarget), '!' ] ) ;
      
%     the gapped cadences should still be identically zero in both the values and the
%     harmonics

      mlunit_assert( all( timeSeriesStruct.values( gapIndicators ) == 0 ) && ...
          all( timeSeriesStruct.harmonicsValues( gapIndicators ) == 0 ), ...
          [ 'Gapped values / harmonics not as expected for target ', ...
          num2str(iTarget), '!' ] ) ;
      
  end
  
  disp('') ;
  
return

% and that's it!

%
%
%
