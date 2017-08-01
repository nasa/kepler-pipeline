function self = test_subtract_model_transit_from_flux_geometric_model( self )
%
% test_subtract_model_transit_from_flux_geometric_model -- unit test of the dvDataClass method subtract_model_transit_from_flux with geometric transit model
%
% This unit test exercises the following functionality of the dvDataClass method subtract_model_transit_from_flux:
%
% ==> The method gaps transits when configured to use gapping as its method
% ==> The width of the gapped region around each transit responds to the parameter which sets the gapping width
% ==> When the method is set to subtract rather than gap, the method correctly performs the subtraction.
% ==> The target # and planet # arguments are respected -- since the dvResultsStruct which is used only has results for target 1, planet 1, in practice
%     this means detecting the correct error when we request a different target or planet number.
%
% This test is intended to be executed in the mlunit context.  For standalone execution use the following syntax:
%
%      run(text_test_runner, testDvDataGeometricClass('test_subtract_model_transit_from_flux_geometric_model'));
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
  disp('... testing subtract-transit-from-flux method with geometric transit model ... ');
  disp(' ');
  
  testDvDataGeometricClass_fitter_initialization;
  
% start by testing the nominal method -- gap transits with a +/- 1 transit-duration buffer

  dvResultsStructSubtracted1 = subtract_model_transit_from_flux(dvDataObject, dvResultsStructAfterFit, 1, 1, dvDataStruct.targetStruct.thresholdCrossingEvent);
  
% the # of gap indicators in the subtracted flux should be larger, and the values which are not gapped should be equal up to some round-off error
% (since the subtraction actually does some median gymnastics).  Also, the subtractor re-subtracts the median, so handle that as well.

  originalFlux    = dvResultsStructAfterFit.targetResultsStruct.residualFluxTimeSeries;
  subtractedFlux1 = dvResultsStructSubtracted1.targetResultsStruct.residualFluxTimeSeries;
  gapIndicators   = subtractedFlux1.gapIndicators;
  
  fluxTolerance = 1e-12;
  fluxDiff      = originalFlux.values( ~gapIndicators ) - subtractedFlux1.values( ~gapIndicators ) - median( originalFlux.values( ~gapIndicators ) );
  mlunit_assert( all( abs(fluxDiff) < fluxTolerance ), 'Gapping-subtraction method does not preserve values' );
  mlunit_assert( length(find(originalFlux.gapIndicators)) < length(find(subtractedFlux1.gapIndicators)), 'Gapping-subtraction method does not gap transits' );
  
% when considering only the ungapped cadences, the range of the original flux should be very large and the range of the subtracted flux should be comparable to MAD

  originalFluxValues    = originalFlux.values( ~originalFlux.gapIndicators );
  subtractedFluxValues1 = subtractedFlux1.values( ~subtractedFlux1.gapIndicators );
  
  valuesOk =             mad(originalFluxValues,1) / mad(subtractedFluxValues1, 1) < 1.05;
  valuesOk = valuesOk && range(subtractedFluxValues1) < 15 * mad(subtractedFluxValues1, 1);
  
  mlunit_assert( valuesOk, 'Gapping-subtraction method does not reduce range/MAD sufficiently' );
  
% reduce the buffer region which is being gapped and repeat the subtraction

  dvDataStruct.planetFitConfigurationStruct.subtractModelTransitRemovalBufferTransits = 0.5;
  dvDataObject = dvDataClass( dvDataStruct );
  
  dvResultsStructSubtracted2 = subtract_model_transit_from_flux(dvDataObject, dvResultsStructAfterFit, 1, 1, dvDataStruct.targetStruct.thresholdCrossingEvent);
  
% # of gapped cadences should be smaller than before but still larger than for the pre-subtraction time series

  subtractedFlux2 = dvResultsStructSubtracted2.targetResultsStruct.residualFluxTimeSeries;
  mlunit_assert(length(find(originalFlux.gapIndicators)   ) < length(find(subtractedFlux2.gapIndicators)), 'Gapping-subtraction method with reduced buffers does not gap transits' );
  mlunit_assert(length(find(subtractedFlux1.gapIndicators)) > length(find(subtractedFlux2.gapIndicators)), 'Gapping-subtraction method with reduced buffers gaps too many cadences');
  
  subtractedFluxValues2 = subtractedFlux2.values( ~subtractedFlux2.gapIndicators );
  valuesOk =             mad(originalFluxValues, 1) / mad(subtractedFluxValues2, 1) < 1.05;
  valuesOk = valuesOk && range(subtractedFluxValues2) < 15 * mad(subtractedFluxValues2, 1);
  mlunit_assert( valuesOk, 'Gapping with reduced buffer size produces incorrect range / MAD values' );

% make sure that iPlanet and iTarget are respected -- in this case, it means that an error is thrown, since there is only 1 target and it has only 1 planet fit

  try_to_catch_error_condition( 'dvr = subtract_model_transit_from_flux(dvDataObject, dvResultsStructAfterFit, 1, 2, dvDataStruct.targetStruct.thresholdCrossingEvent);', ...
      'badsubscript', 'caller' );
  try_to_catch_error_condition( 'dvr = subtract_model_transit_from_flux(dvDataObject, dvResultsStructAfterFit, 2, 1, dvDataStruct.targetStruct.thresholdCrossingEvent);', ...
      'badsubscript', 'caller' );
  
  disp(' ');
  
return

% and that's it!
