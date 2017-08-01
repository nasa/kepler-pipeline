function self = test_detrend_edges_of_data_blocks( self )
%
% test_detrend_edges_of_data_blocks -- unit test for quarterStitchingClass method
% detrend_edges_of_data_blocks
%
% This test exercises the following functionality of the edge-detrending method of the
% quarterStitchingClass:
%
% ==> On each data block, the edges are detrended (ie, slope and mean value of the
%     detrended periods are closer to zero after detrending than before).
%
% This test is performed in the mlunit context.  For standalone operation, use the
% following syntax:
%
%      run(text_test_runner, testQuarterStitchingClass('test_detrend_edges_of_data_blocks'));
%
% Version date:  2010-September-16.
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
%=========================================================================================

  disp(' ... testing edge-detrending method ... ') ;
  
% define the # of cadences which are used to define the "edge" which is detrended

  edgeLengthCadences = 49 ;
  xAxis = (-edgeLengthCadences+1)/2 : (edgeLengthCadences-1)/2 ;
  xAxis = xAxis(:) ;

% set the test data path and retrieve the standard input struct 

  tpsDataFile = 'tps-multi-quarter-struct' ;
  tpsDataStructName = 'tpsInputs' ;
  tps_testing_initialization ;
  load( fullfile( testDataPath, 'quarterStitchingClass-struct' ) ) ;
  
% validate the input and update the quarterStitchingStruct with anything
% new that it might need
  
  nTargets = length(quarterStitchingStruct.timeSeriesStruct) ;
  for iTarget = 1:nTargets
      quarterStitchingStruct.timeSeriesStruct(iTarget).keplerId = 11703707 ;
  end
  tpsInputs.tpsTargets = tpsInputs.tpsTargets(1) ;
  tpsInputs.tpsTargets(1:nTargets) = tpsInputs.tpsTargets;
  tpsInputs = validate_tps_input_structure( tpsInputs ) ;
  quarterStitchingStruct.gapFillParametersStruct = tpsInputs.gapFillParameters ;
  quarterStitchingStruct.harmonicsIdentificationParametersStruct = tpsInputs.harmonicsIdentificationParameters ;
  quarterStitchingStruct.randStreams = tpsInputs.randStreams ;
  

% instantiate the object and median-correct it

  quarterStitchingObject = quarterStitchingClass( quarterStitchingStruct ) ;
  quarterStitchingObject = median_correct_time_series( quarterStitchingObject ) ;
  
% perform the detrending and cast the object back to a struct

  quarterStitchingObject = detrend_edges_of_data_blocks( quarterStitchingObject ) ;
  quarterStitchingStructAfter = struct( quarterStitchingObject ) ;
  
% loop over targets and data blocks

  for iTarget = 1:length( quarterStitchingStructAfter.timeSeriesStruct )
      
      target        = quarterStitchingStruct.timeSeriesStruct(iTarget) ;
      targetAfter   = quarterStitchingStructAfter.timeSeriesStruct(iTarget) ;
      
      for iQuarter = 1:length( targetAfter.dataSegments )
          
          dataStart  = targetAfter.dataSegments{iQuarter}(1) ;
          dataEnd    = targetAfter.dataSegments{iQuarter}(2) ;
          dataRegion = dataStart:dataEnd ;
          dataLength = length(dataRegion) ;

%         compute the slope and intercept of the start and end regions before and after
%         detrending -- both the slope and the intercept should be lower after than before

          startLineFitBefore = polyfit( xAxis, ...
              target.values(dataRegion(1:edgeLengthCadences)), 1 ) ;
          endLineFitBefore = polyfit( xAxis, ...
              target.values(dataRegion(dataLength-edgeLengthCadences+1:end)), 1 ) ;
          startLineFitAfter = polyfit( xAxis, ...
              targetAfter.values(dataRegion(1:edgeLengthCadences)), 1 ) ;
          endLineFitAfter = polyfit( xAxis, ...
              targetAfter.values(dataRegion(dataLength-edgeLengthCadences+1:end)), 1 ) ;
          mlunit_assert( abs(startLineFitBefore(1)) > abs(startLineFitAfter(1)) && ...
              abs(startLineFitBefore(2)) > abs(startLineFitAfter(2)) && ...
              abs(endLineFitBefore(1)) > abs(endLineFitAfter(1)) && ...
              abs(endLineFitBefore(2)) > abs(endLineFitAfter(2)), ...
              ['Detrending on target ',num2str(iTarget), ' quarter ', num2str(iQuarter), ...
              ' not as expected!'] ) ;
          
      end % loop over data segments
      
  end % loop over targets
  
  disp('') ;
  
return

% and that's it!

%
%
%
