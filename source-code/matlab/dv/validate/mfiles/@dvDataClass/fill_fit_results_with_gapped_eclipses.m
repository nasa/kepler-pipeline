function dvResultsStruct = fill_fit_results_with_gapped_eclipses( dvDataObject, ...
    dvResultsStruct, iTarget, iPlanet, thresholdCrossingEvent, gappedTransitStruct )
%
% fill_fit_results_with_gapped_eclipses -- fill in the DV planet fit results structures
% with information about gapped eclipses of eclipsing binaries
%
% dvResultsStruct = fill_fit_results_with_gapped_eclipses( dvDataObject, dvResultsStruct,
%    iTarget, iPlanet, thresholdCrossingEvent, gappedTransitStruct ) takes the information
%    about the eclipsing binary which corresponds to the thresholdCrossingEvent and was
%    detected and gapped, and fills that information into the planet fit results structs
%    in the dvResultsStruct.  This allows the epoch test, period test, and other tests to
%    compare the detected EB to later planet detections and determine whether the detected
%    planets are actually additional eclipses of the binary.
%
% Note that, since no actual fit is performed, the fit results are not completely
%    populated.  Only the epoch, period, duration, and depth of the eclipses are packaged
%    in the modelParameters struct array.
%
% Version date:  2012-July-12.
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

% Modification Date:
%
%    2012-July-12, JL:
%        update 'transitDepthPpm' in planetResultsStruct.allTransitsFit.modelParameters
%    2012-February-13, JL:
%        allTransitsFit.modelParameters is filled with TCE data in
%        perform_dv_planet_search_and_model_fitting.m, so modelParameters
%        in all, odd and even transits fit structs are not updated here
%    2010-May-05, PT:
%        convert from transitEpochMjd to transitEpochBkjd.
%
%=========================================================================================

% start by doing some unpacking of argument structs and other useful information

  planetResultsStruct = ...
      dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) ;
  planetCandidate     = planetResultsStruct.planetCandidate ;
  transitEpochMjd     = thresholdCrossingEvent.epochMjd ;
  transitEpochBkjd    = transitEpochMjd - kjd_offset_from_mjd ;
  orbitalPeriodDays   = thresholdCrossingEvent.orbitalPeriod ;
  
  configMapObject        = configMapClass( dvDataObject.configMaps ) ;
  cadenceDurationSeconds = get_long_cadence_period( configMapObject, transitEpochMjd ) ;
  cadenceDurationHours    = cadenceDurationSeconds * get_unit_conversion( 'sec2hour' ) ;
    
% start with the all-transits parameters  
  
  allTransitsModelParameters = assemble_model_parameters_struct( transitEpochBkjd, ...
      orbitalPeriodDays, cadenceDurationHours, gappedTransitStruct, 0 );
  % planetResultsStruct.allTransitsFit.modelParameters = allTransitsModelParameters ;
  
% update the parameter 'transitDepthPpm' in planetResultsStruct.allTransitsFit.modelParameters
  nameCell1       = {planetResultsStruct.allTransitsFit.modelParameters.name};
  nameCell2       = {allTransitsModelParameters.name};
  transitDepthStr = 'transitDepthPpm';
  index1          = strcmp(transitDepthStr, nameCell1);
  index2          = strcmp(transitDepthStr, nameCell2);
  planetResultsStruct.allTransitsFit.modelParameters(index1) = allTransitsModelParameters(index2);

% Now for the odd-eclipses

  oddTransitsModelParameters = assemble_model_parameters_struct( transitEpochBkjd, ...
      orbitalPeriodDays, cadenceDurationHours, gappedTransitStruct, 1 ) ;
  % planetResultsStruct.oddTransitsFit.modelParameters = oddTransitsModelParameters ;
  
% finally, the even eclipses

  evenTransitsModelParameters = assemble_model_parameters_struct( transitEpochBkjd, ...
      orbitalPeriodDays, cadenceDurationHours, gappedTransitStruct, 2 ) ;
  % planetResultsStruct.evenTransitsFit.modelParameters = evenTransitsModelParameters ;
  
% set the suspected eclipsing binary flag back in the planet candidate struct

  planetCandidate.suspectedEclipsingBinary = true ;
  
% assign the planet results struct back to the overall results struct, and exit

  planetResultsStruct.planetCandidate = planetCandidate ;
  dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet) = ...
      planetResultsStruct ;
  
return

% and that's it!

%
%
%

  
%=========================================================================================

% subfunction which assembles the model parameters structure from the data

function modelParametersStruct = assemble_model_parameters_struct( transitEpochBkjd, ...
    orbitalPeriodDays, cadenceDurationHours, gappedTransitStruct, oddEvenFlag )

% start with a template
  
  modelParametersTemplate = struct( 'name',[], 'value', [], 'uncertainty', 0, ...
      'fitted', false ) ;
  
% based on the oddEvenFlag, fill in a parity screen

  transitNumber = 1:length(gappedTransitStruct) ;
  switch oddEvenFlag
      case 0
          parityScreen = true( size(transitNumber) ) ;
      case 1
          parityScreen = mod(transitNumber,2) == 1 ;
      case 2
          parityScreen = mod(transitNumber,2) == 0 ;
  end
  
% based on the screen and whether a given transit / eclipse was already gapped before we
% started trying to identify and remove it, determine which transits are of interest to us

  preGappedTransits = [gappedTransitStruct.gapIndicator] ;
  transitIndex = ~preGappedTransits & parityScreen ;
  
% fill in the epoch first

  epochStruct       = modelParametersTemplate ;
  epochStruct.name  = 'transitEpochBkjd' ;
  epochStruct.value = transitEpochBkjd ;
  
  if ( oddEvenFlag == 2 )
      epochStruct.value = epochStruct.value + orbitalPeriodDays ;
  end
  
% now the transit duration -- use the duration of all valid transits, converted to hours

  durationStruct      = modelParametersTemplate ;
  durationStruct.name = 'transitDurationHours' ;
  if ~isempty( find( transitIndex, 1 ) )
      durationStruct.value = mean( ...
          [gappedTransitStruct(transitIndex).transitDurationCadences] ) ;
  else
      durationStruct.value = 0 ;
  end
  durationStruct.value = durationStruct.value * cadenceDurationHours ;
  
% for the depth, use the average depth of all valid transits, converted to PPM

  depthStruct      = modelParametersTemplate ;
  depthStruct.name = 'transitDepthPpm' ;
  if ~isempty( find( transitIndex, 1 ) )
      depthStruct.value = mean( [gappedTransitStruct(transitIndex).transitDepth] ) ;
  else
      depthStruct.value = 0 ;
  end
  depthStruct.value = depthStruct.value * 1e6 ;
  
% finally the period  
  
  periodStruct       = modelParametersTemplate ;
  periodStruct.name  = 'orbitalPeriodDays' ;
  periodStruct.value = orbitalPeriodDays ;
  
% finally, construct the return structure

  modelParametersStruct = [epochStruct  durationStruct  depthStruct  periodStruct] ;
  
return