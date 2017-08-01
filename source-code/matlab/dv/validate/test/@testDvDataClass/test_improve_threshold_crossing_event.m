function self = test_improve_threshold_crossing_event( self ) 
%
% test_improve_threshold_crossing_event -- unit test of dvDataClass method
% improve_threshold_crossing_event
%
% This unit test exercises the following functionality of the dvDataClass method
% improve_threshold_crossing_event:
%
% ==> The method produces a different threshold crossing event from the one which it
%     receives as an input, and the values of this TCE are as expected
% ==> When the input TCE's period is reduced by a factor of 4, the correct TCE is still
%     produced by this method (ie, the subharmonic search operates correctly)
% ==> When the subharmonic search parameters are altered, the correct TCE is no longer
%     detected.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testDvDataClass('test_improve_threshold_crossing_event'));
%
% Version date:  2009-December-21
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
%    2009-December-21, PT:
%        Make regression test approximate rather than exact, looking only at the
%        parameters of interest (period and epoch).
%
%=========================================================================================

  disp('... testing improve-TCE method ... ')
  
  testDvDataClass_fitter_initialization ;
  dvResultsStruct = dvResultsStructBeforeFit ;
  
% execute the method with the nominal # of subharmonics tested but reduce the search
% window (otherwise in later steps the search windows will overlap)

  dvDataStruct.planetFitConfigurationStruct.periodSearchWindowWidthDays = 2 ;
  tce0 = dvDataStruct.targetStruct.thresholdCrossingEvent ;
  dvDataObject = dvDataClass( dvDataStruct ) ;
  improvedTce = improve_threshold_crossing_event( dvDataObject, dvResultsStruct, ...
      tce0, 1, 1 ) ;
  
% test that the improved TCE is different from the original but matches expectations based
% on regression

  assert_not_equals( orderfields( tce0 ), orderfields( improvedTce ) , ...
      'Improved TCE matches seed TCE' ) ;
%   assert_equals( improvedTce, thresholdCrossingEventRegression, ...
%       'Improved TCE does not match expected value' ) ;
  mlunit_assert( abs( improvedTce.orbitalPeriod - ...
      thresholdCrossingEventRegression.orbitalPeriod ) < 0.05, ...
      'Improved TCE orbital period does not match expected to within tolerance!' ) ;
  mlunit_assert( abs( improvedTce.epochMjd - ...
      thresholdCrossingEventRegression.epochMjd ) < 0.05, ...
      'Improved TCE epoch does not match expected to within tolerance!' ) ;
  
% reduce the seed TCE by a factor of 4 and verify that the improved TCE in that case
% matches the regression TCE

  tce0.orbitalPeriod = tce0.orbitalPeriod / 4 ;
  improvedTce2 = improve_threshold_crossing_event( dvDataObject, dvResultsStruct, ...
      tce0, 1, 1 ) ;
  assert_equals( improvedTce, improvedTce2, ...
      'Improved TCE does not match expected value when seed TCE period changed' ) ;
  
% reduce the # of subharmonics and verify that the resulting TCE is not the same as the
% regression TCE, and in particular that it is not as good as indicated by its max-MES

  dvDataStruct.planetFitConfigurationStruct.periodSearchMaxSubharmonic = 3 ;
  dvDataObject = dvDataClass( dvDataStruct ) ;
  improvedTce3 = improve_threshold_crossing_event( dvDataObject, dvResultsStruct, ...
      tce0, 1, 1 ) ;
  assert_not_equals( improvedTce3, improvedTce, ...
      'Improved TCE matches regression TCE when max subharmonic reduced' ) ;
  mlunit_assert( improvedTce3.maxMultipleEventSigma < ...
      improvedTce.maxMultipleEventSigma, ...
      'Improved TCE max-MES not smaller than regression MES for reduced max subharmonic' ) ;
  
  disp(' ') ;
  
return
  
