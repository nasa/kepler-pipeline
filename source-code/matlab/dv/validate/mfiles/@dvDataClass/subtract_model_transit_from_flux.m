function dvResultsStruct = subtract_model_transit_from_flux(dvDataObject, ...
    dvResultsStruct, iTarget, iPlanet, thresholdCrossingEvent )
%
% subtract_model_transit_from_flux -- subtract a model transit from a flux time series
%
% dvResultsStruct = subtract_model_transit_from_flux(dvDataObject, dvResultsStruct,
%    iTarget, iPlanet, thresholdCrossingEvent) uses the allTransitsFit struct for target
%    iTarget and planet iPlanet to remove the effect of the model transit from the flux
%    time series.  The resulting flux time series is stored in dvResultsStruct as the
%    residual flux time series for target iTarget.
%
% Version date:  2010-April-27.
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
%    2010-April-27, PT:
%        change signature of removal method.
%    2009-December-10, PT:
%        include gapped values in median calculation for median subtraction.
%    2009-November-30, PT:
%        re-subtract the median of non-gapped, non-filled points.
%    2009-September-14, PT:
%        switch to use of module parameters to control subtraction options.
%    2009-September-02, PT:
%        change to use of remove_transit_signature_from_flux_time_series private method.
%    2009-August-04, PT:
%        updates to match current organization of data in DV.
%    2009-May-15, PT:
%        changes to support use of median-corrected flux time series.
%
%=========================================================================================

% Instantiate a transitGeneratorClass object from the allTransitsFit sub-structure in the
% dvResultsStruct and the associated information in the dvDataObject

  targetResultsStruct = dvResultsStruct.targetResultsStruct(iTarget) ;
  allTransitsFit = targetResultsStruct.planetResultsStruct(iPlanet).allTransitsFit ;
  transitGeneratorModel = convert_tps_parameters_to_transit_model( dvDataObject, ...
      iTarget, thresholdCrossingEvent ) ;
  transitGeneratorModel.planetModel = allTransitsFit.modelParameters ;
  
  subtractModelTransitRemovalMethod = ...
      dvDataObject.planetFitConfigurationStruct.subtractModelTransitRemovalMethod ;
  subtractModelTransitRemovalBufferTransits = ...
      dvDataObject.planetFitConfigurationStruct.subtractModelTransitRemovalBufferTransits ;
  
  
  dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries = ...
      remove_transit_signature_from_flux_time_series( ...
      dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries, ...
      transitGeneratorClass( transitGeneratorModel ), ...
      subtractModelTransitRemovalMethod, ...
      subtractModelTransitRemovalBufferTransits ) ;
  
% by subtracting and/or gapping the residual flux time series, the median value may have
% shifted slightly.  Subtract the median to get back to a time series with zero median
% (use only valid values for the median calculation, not gapped values).

  residualFluxTimeSeries = ...
      dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries ;
  gapIndicators = residualFluxTimeSeries.gapIndicators ;
  
  medianFluxValue = median( residualFluxTimeSeries.values( ~gapIndicators ) ) ;
  
% It's not obvious that there is any particular benefit to performing the subtraction for
% all values, rather than just all valid values, but I'm going to go ahead and subtract
% the median from all values regardless of gap / fill status

  residualFluxTimeSeries.values = residualFluxTimeSeries.values - medianFluxValue ;
  
  dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries = ...
      residualFluxTimeSeries ;
    
return

% and that's it!

%
%
%
  