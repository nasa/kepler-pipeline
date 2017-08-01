function self = test_improve_tce_giant_transit_handler( self )
%
% test_improve_tce_giant_transit_handler -- tests to see whether the algorithms in method
% improve_threshold_crossing_event which handle presence or absence of giant transits are
% operating correctly.
%
% This unit test exercises the following functionality:
%
% ==> In the case where some subharmonics have giant transits at all times predicted by
%     TCE, and others do not, only the ones with all giant transits present will be
%     included in the determination of best TCE
% ==> The module parameter which determines how far above detection threshold a giant
%     transit must be for inclusion in the calculation above is correctly handled.
%
% This test is intended to be executed in the mlunit context.  For standalone execution
% use the following syntax:
%
%      run(text_test_runner, testDvDataClass('test_improve_tce_giant_transit_handler'));
%
% Version date:  2009-December-18.
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
%
%=========================================================================================

  disp('... testing improve-tce method with giant transits present ... ')
  
% Load a data file in which there's an EB on which the eclipse intervals are 2:1, and an
% extra giant transit has been added to make TPS think that the period is 1/3 of its
% actual value
  
  dvDataFilename = 'improve-tce-giant-transit-test-data' ;
  testDvDataClass_fitter_initialization ;
  
% run improve_threshold_crossing_event and look at the period which is selected for the
% TCE; it should be about 3x the period of the TCE which went into the call

  tceNew = improve_threshold_crossing_event( dvDataObject, dvResultsStruct, ...
      thresholdCrossingEvent, 1, 1 ) ;
  
  periodRatio = tceNew.orbitalPeriod / thresholdCrossingEvent.orbitalPeriod ;
  
  mlunit_assert( abs(periodRatio - 3) < 0.1, ...
      'Orbital period ratio not near 3 for test with nominal giant transit ratio' ) ;
  
% now crank up the parameter which sets how far above threshold each giant transit has to
% be in order to be "counted" as a giant transit (ie, it disallows transits which are
% close to detection threshold under the theory that some transits may be seen and others
% missed if they are close to threshold).  In this case the improver's ability to use the
% presence or absence of giant transits should be defeated.

  dvDataStruct.planetFitConfigurationStruct.giantTransitDetectionThresholdScaleFactor = 1e9 ;
  dvDataObject = dvDataClass( dvDataStruct ) ;

  tceNew = improve_threshold_crossing_event( dvDataObject, dvResultsStruct, ...
      thresholdCrossingEvent, 1, 1 ) ;
  
  periodRatio = tceNew.orbitalPeriod / thresholdCrossingEvent.orbitalPeriod ;
  
  mlunit_assert( abs(periodRatio - 1) < 0.1, ...
      'Orbital period ratio not near 1 for test with enlarged giant transit ratio' ) ;
  
return

% and that's it!

%
%
%
