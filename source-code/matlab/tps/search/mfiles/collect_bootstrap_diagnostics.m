function tpsResult = collect_bootstrap_diagnostics( tpsResult, ...
    tpsModuleParameters, bootstrapParameters, foldingParameterStruct )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function tpsResults = collect_bootstrap_diagnostics( tpsResults )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Function to run the bootstrap for additional nTransits to collect
% diagnostics that will hopefully be useful later.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

superResolutionFactor            = tpsModuleParameters.superResolutionFactor ;
usePolyFitTransitModel           = tpsModuleParameters.usePolyFitTransitModel ;
isPlanetACandidate               = tpsResult.isPlanetACandidate;
waveletObject                    = tpsResult.waveletObject ;
indexOfSesAdded                  = tpsResult.indexOfSesAdded ;
nCadences                        = foldingParameterStruct.nCadences ;
trialTransitDurationInCadences   = foldingParameterStruct.trialTransitDurationInCadences ;
bootstrapDiagnosticStruct        = tpsResult.bootstrapDiagnosticStruct;
nTransitsVector                  = bootstrapDiagnosticStruct.nTransits ;


% generate the trial transit pulse train through the superResolutionClass   
scalingFilterCoeffts = get( waveletObject, 'h0' ) ;
superResolutionStruct = struct('superResolutionFactor', superResolutionFactor, ...
    'pulseDurationInCadences', trialTransitDurationInCadences, 'usePolyFitTransitModel', ...
    usePolyFitTransitModel ) ;
superResolutionObject = superResolutionClass( superResolutionStruct, scalingFilterCoeffts ) ;
superResolutionObject = set_statistics_time_series_shift_length( superResolutionObject) ; 

% generate the padded in-transit cadence indicator to mask out whatever
% event was returned from the search
transitModel = generate_trial_transit_pulse_train( superResolutionObject, ...
    indexOfSesAdded, nCadences ) ;
nPadCadences = min( ceil(trialTransitDurationInCadences * 0.5), 4 ) ;
inTransitIndicator = generate_padded_transit_indicator( transitModel, nPadCadences );

% generate the bootstrap input from various TPS ingredients
bootstrapInputStruct = generate_tps_bootstrap_input( waveletObject, ...
    tpsResult, tpsModuleParameters, bootstrapParameters, foldingParameterStruct, ...
    inTransitIndicator );

% explicitly set some of the bootstrap parameters
bootstrapInputStruct.deemphasizeQuartersWithoutTransits = false;
bootstrapInputStruct.searchTransitThreshold = 7.1;

% loop over the various nTransits
for iTransit = 1:length(nTransitsVector)
    bootstrapInputStruct.observedTransitCount = nTransitsVector(iTransit);
    
    % compute the bootstrap info
    bootstrapResultsStruct = compute_threshold_by_bootstrap( bootstrapInputStruct, [], 7.1 ) ;
    
    % populate the diagnostic struct
    bootstrapDiagnosticStruct.threshold(iTransit) = bootstrapResultsStruct.thresholdForDesiredPfa;
    bootstrapDiagnosticStruct.mean(iTransit) = bootstrapResultsStruct.mesMeanEstimate;
    bootstrapDiagnosticStruct.std(iTransit) = bootstrapResultsStruct.mesStdEstimate;
end
    
% put the diagnostic struct in the results
tpsResult.bootstrapDiagnosticStruct = bootstrapDiagnosticStruct;

return