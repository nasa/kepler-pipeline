function self = test_tps_matlab_controller(self)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function self = test_tps_matlab_controller(self)
%
% This test exercises the tps_matlab_controller, and also the auto-generated
% binfile read-write utilities.  The functionality tested is as follows:
% 
% ==> TPS-Full:
%     --> tps_matlab_controller executes without errors.
%     --> The resulting input and output structs can be read and written
%         by the utilities.
% ==> TPS-Lite:
%     --> tps_matlab_controller executes without errors.
%     --> The resulting input and output structs can be read and written
%         by the utilities.
%     --> The results related to an actual planet search are all set to
%         values which indicate that no search has been performed.
%
% If the regression test fails, an error condition occurs.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%  Use a test runner to run the test method:
%  Example: run(text_test_runner, testTpsClass('test_tps_matlab_controller'));
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

  disp( ' ... testing tps_matlab_controller and auto-generated read/write utilities ... ' ) ;

% obtain a correct TPS-full input file

  tpsDataFile = 'tps-full-data-struct' ;
  tpsDataStructName = 'tpsDataStruct' ;
  tps_testing_initialization ;
  tpsInputStruct = tpsDataStruct ;
  
% set debug level to -1 so we dont write output files

  tpsInputStruct.tpsModuleParameters.debugLevel = -1 ;
  
% set the parameter to do quarter stitching

  tpsInputStruct.tpsModuleParameters.performQuarterStitching = true ;

% verify that the basic functionality is present

  [tpsResultsStruct] = tps_matlab_controller(tpsInputStruct);
  mlunit_assert( all( [tpsResultsStruct.tpsResults.maxMultipleEventStatistic] > 0 ), ...
      'TPS-Full MES not correctly determined!' ) ;

% none of the following fields should be present in the tpsResults struct  
  
  fieldsToRemoveCell = {'correlationTimeSeriesHiRes'; 'normalizationTimeSeriesHiRes'; ...
    'foldedStatisticAtTrialPeriods'; 'possiblePeriodsInCadences';...
    'deemphasizeSuperResolutionCadenceIndicators';'foldedStatisticAtTrialPhases' ;...
    'phaseLagInCadences'; 'deemphasizeAroundSafeModeTweakIndicators'}; % can add addional fields
  
  mlunit_assert( all( ~isfield( tpsResultsStruct.tpsResults, fieldsToRemoveCell ) ), ...
      'Fields to remove not all removed in TPS-full!' ) ;

% test the reading and writing functions

%   inputFileName = 'inputs-0.bin';
%   outputFileName = 'outputs-0.bin';
%   
%   write_TpsInputs( inputFileName, tpsInputStruct ) ;
%   recoveredTpsInputs = read_TpsInputs( inputFileName ) ;
%   
%   write_TpsOutputs( outputFileName, tpsResultsStruct ) ;
%   recoveredTpsOutputs = read_TpsOutputs( outputFileName ) ;
%   
% % the inputs and the outputs are not identical through the read/write process in several
% % important ways:
% %
% % ==> The write/read process converts double precision to single and then back to double
% % ==> Many fields in the TPS outputs are not written to the bin-file, hence are not
% %     present when the bin-file is converted back into a MATLAB struct
% % ==> The tpsResults struct array in the outputs gets its shape reversed (from n x 1 to 1
% %     x n).
% %
% % The following comparision logic takes care of those issues
% 
%   tpsInputStructSingle = convert_struct_fields_to_float( tpsInputStruct ) ;
%   recoveredTpsInputs = convert_struct_fields_to_float( recoveredTpsInputs ) ;
%   assert_equals( tpsInputStructSingle, recoveredTpsInputs, ...
%       'TPS-full inputs do not agree across binfile write-read cycle!' ) ;
%   
%   tpsResultsStructSingle = convert_struct_fields_to_float( tpsResultsStruct ) ;
%   recoveredTpsOutputs = convert_struct_fields_to_float( recoveredTpsOutputs ) ;
%   recoveredTpsOutputs.tpsResults = recoveredTpsOutputs.tpsResults' ;
%   originalFields = fieldnames( tpsResultsStructSingle.tpsResults ) ;
%   binfileFields = fieldnames( recoveredTpsOutputs.tpsResults ) ;
%   tpsResultsStructSingle.tpsResults = rmfield( tpsResultsStructSingle.tpsResults, ...
%       originalFields( find( ~ismember( originalFields, binfileFields ) ) ) ) ;
%   tpsResultsStructSingle = rmfield( tpsResultsStructSingle, 'quarterlySegmentStruct' ) ;
%   assert_equals( tpsResultsStructSingle, recoveredTpsOutputs, ...
%        'TPS-full outputs do not agree across binfile write-read cycle!' ) ;
% 
%   delete(inputFileName);
%   delete(outputFileName) ;

% Now perform the same analysis with TPS-Lite

  tpsInputStruct.tpsModuleParameters.tpsLiteEnabled = true ;
  [tpsResultsStruct] = tps_matlab_controller(tpsInputStruct);
  mlunit_assert( all( [tpsResultsStruct.tpsResults.detectedOrbitalPeriodInDays] == -1 ) && ...
      all( [tpsResultsStruct.tpsResults.maxMultipleEventStatistic] == -1 ) && ...
      all( [tpsResultsStruct.tpsResults.timeToFirstTransitInDays] == -1 ) && ...
      all( [tpsResultsStruct.tpsResults.timeOfFirstTransitInMjd] == -1 ) && ...
      all( [tpsResultsStruct.tpsResults.detectedMicrolensOrbitalPeriodInDays] == -1 ) && ...
      all( [tpsResultsStruct.tpsResults.timeToFirstMicrolensInDays] == -1 ) && ...
      all( [tpsResultsStruct.tpsResults.timeOfFirstMicrolensInMjd] == -1 ) && ...
      all( [tpsResultsStruct.tpsResults.minMultipleEventStatistic] == -1 ) && ...
      all( ~[tpsResultsStruct.tpsResults.isPlanetACandidate] ) , ...
      'TPS-Lite folding results not all set to -1!' ) ;

  mlunit_assert( all( ~isfield( tpsResultsStruct.tpsResults, fieldsToRemoveCell ) ), ...
      'Fields to remove not all removed in TPS-lite!' ) ;
  
%   write_TpsInputs( inputFileName, tpsInputStruct ) ;
%   recoveredTpsInputs = read_TpsInputs( inputFileName ) ;
%   
%   write_TpsOutputs( outputFileName, tpsResultsStruct ) ;
%   recoveredTpsOutputs = read_TpsOutputs( outputFileName ) ;
%   
%   tpsInputStructSingle = convert_struct_fields_to_float( tpsInputStruct ) ;
%   recoveredTpsInputs = convert_struct_fields_to_float( recoveredTpsInputs ) ;
%   assert_equals( tpsInputStructSingle, recoveredTpsInputs, ...
%       'TPS-lite inputs do not agree across binfile write-read cycle!' ) ;
%   
%   tpsResultsStructSingle = convert_struct_fields_to_float( tpsResultsStruct ) ;
%   recoveredTpsOutputs = convert_struct_fields_to_float( recoveredTpsOutputs ) ;
%   recoveredTpsOutputs.tpsResults = recoveredTpsOutputs.tpsResults' ;
%   originalFields = fieldnames( tpsResultsStructSingle.tpsResults ) ;
%   binfileFields = fieldnames( recoveredTpsOutputs.tpsResults ) ;
%   tpsResultsStructSingle.tpsResults = rmfield( tpsResultsStructSingle.tpsResults, ...
%       originalFields( find( ~ismember( originalFields, binfileFields ) ) ) ) ;
%   tpsResultsStructSingle = rmfield( tpsResultsStructSingle, 'quarterlySegmentStruct' ) ;
%   assert_equals( tpsResultsStructSingle, recoveredTpsOutputs, ...
%        'TPS-lite outputs do not agree across binfile write-read cycle!' ) ;
% 
%   delete(inputFileName);
%   delete(outputFileName) ;
  
  disp('') ;
  
return
