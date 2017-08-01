function [harmonicTimeSeries, variableTargetDataStruct, variableTargetList] = ...
pdc_identify_and_remove_phase_shifting_harmonics_from_all_targets( ...
targetDataStruct, coarsePdcConfigurationStruct, cadenceType, ...
eventStruct, identifyAllTargetsAsVariable)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [harmonicTimeSeries, variableTargetDataStruct, variableTargetList] = ...
% pdc_identify_and_remove_phase_shifting_harmonics_from_all_targets( ...
% targetDataStruct, coarsePdcConfigurationStruct, cadenceType, ...
% eventStruct, identifyAllTargetsAsVariable)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Identify and remove the harmonic content from all PDC targets. Systematic
% error correction, outlier identification and gap filling may then be
% performed on the residuals. The harmonic content will be restored to the
% corrected flux time series for the respective targets after the basic
% presearch data conditioning functions have completed.
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


% Check optional arguments
if ~exist('identifyAllTargetsAsVariable', 'var')
    identifyAllTargetsAsVariable = false;
end % if

if ~exist('eventStruct', 'var')
    eventStruct = [];
end % if

% Get necessary module parameters and configuration structures.
pdcModuleParameters = coarsePdcConfigurationStruct.pdcModuleParameters;
stellarVariabilityDetrendOrder = ...
    pdcModuleParameters.stellarVariabilityDetrendOrder;
stellarVariabilityThreshold = ...
    pdcModuleParameters.stellarVariabilityThreshold;
debugLevel = pdcModuleParameters.debugLevel;

harmonicsIdentificationConfigurationStruct = ...
    coarsePdcConfigurationStruct.harmonicsIdentificationConfigurationStruct;
gapFillConfigurationStruct = ...
    coarsePdcConfigurationStruct.gapFillConfigurationStruct;

% Initialize the output struct array.
nTargets = length(targetDataStruct);
nCadences = length(targetDataStruct(1).values);

harmonicTimeSeries = repmat(struct( ...
    'keplerId', 0, ...
    'values', zeros([nCadences, 1]), ...
    'detrendedFluxValues', zeros([nCadences, 1]), ...
    'detrendedFluxUncertainties', zeros([nCadences, 1]), ...
    'detrendedFluxGapIndicators', false([nCadences, 1]), ...
    'indexOfGiantTransits', [], ...
    'harmonicModelStruct', [], ...
    'harmonicChiSquare', 0), [1, nTargets]);

if isfield(targetDataStruct, 'keplerId')
    cellArray = {targetDataStruct.keplerId};
    [harmonicTimeSeries(1 : nTargets).keplerId] = cellArray{ : };
end % if

% Identify the variable targets at the given threshold level. Don't try to
% do an ensemble correction for short cadence data where there are very few
% targets and a significant fraction of them are variable.
fluxValuesArray = [targetDataStruct.values];
fluxUncertaintiesArray = [targetDataStruct.uncertainties];
gapIndicatorsArray = [targetDataStruct.gapIndicators];

if ~identifyAllTargetsAsVariable
    if strcmpi(cadenceType, 'long')
        ensembleCorrectionEnabled = true;
    else
        ensembleCorrectionEnabled = false;
    end

    [variableTargetList] = ...
        identify_variable_targets(fluxValuesArray, gapIndicatorsArray, ...
        stellarVariabilityDetrendOrder, stellarVariabilityThreshold, ...
        ensembleCorrectionEnabled);
else
    variableTargetList = (1 : nTargets)';
end % if / else


% Loop over the variable targets, perform coarse detrending, and identify
% the harmonics within each of the specified segments.
modOutCenterEvolutionArray = [];
iVariableTarget = 0;
variableTargetDataStruct = targetDataStruct(variableTargetList);

for iTarget = variableTargetList( : )'
    
    % Get the flux values and gap indicators for the given target.
    fluxValues = fluxValuesArray( : , iTarget);
    fluxUncertainties = fluxUncertaintiesArray( : , iTarget);
    gapIndicators = gapIndicatorsArray( :  , iTarget);
    
    % Perform coarse systematic error correction on the target flux based
    % on the known data anomalies and a low order polynomial.
    if ~isempty(eventStruct)
        indexOfGiantTransits = eventStruct(iTarget).indexOfAstroEvents;
    else
        [indexOfGiantTransits1] = ...
            identify_giant_transits(fluxValues, gapIndicators, ...
            gapFillConfigurationStruct);
        [indexOfGiantTransits2] = ...
            identify_giant_transits(-fluxValues, gapIndicators, ...
            gapFillConfigurationStruct);
        indexOfGiantTransits = ...
            unique([indexOfGiantTransits1; indexOfGiantTransits2]);
    end % if / else

    [detrendedFluxValues, detrendedFluxUncertainties, ...
        modOutCenterEvolutionArray] = ...
        pdc_perform_coarse_systematic_error_correction(fluxValues, ...
        fluxUncertainties, gapIndicators, coarsePdcConfigurationStruct, ...
        modOutCenterEvolutionArray, indexOfGiantTransits, debugLevel);
    
    harmonicTimeSeries(iTarget).detrendedFluxValues = ...
        detrendedFluxValues;
    harmonicTimeSeries(iTarget).detrendedFluxUncertainties = ...
        detrendedFluxUncertainties;
    harmonicTimeSeries(iTarget).detrendedFluxGapIndicators = ...
        gapIndicators;
    
    % Get the harmonic content.
    % Note that identify_and_remove_phase_shifting_harmonics returns an
    % empty harmonicTimeSeriesValues vector if it cannot identify harmonic
    % content. Note in the computation of the chiSquare that there are
    % three fitted coefficients per harmonic frequency.
    [harmonicRemovedValues, harmonicTimeSeriesValues, ...
        indexOfGiantTransits, harmonicModelStruct] = ...
        identify_and_remove_phase_shifting_harmonics(detrendedFluxValues, ...
        gapIndicators, gapFillConfigurationStruct, ...
        harmonicsIdentificationConfigurationStruct, ...
        indexOfGiantTransits);
    
    if ~isempty(harmonicTimeSeriesValues)
        harmonicTimeSeries(iTarget).values = ...
            harmonicTimeSeriesValues;
        harmonicTimeSeries(iTarget).indexOfGiantTransits = ...
            indexOfGiantTransits;
        harmonicTimeSeries(iTarget).harmonicModelStruct = ...
            harmonicModelStruct;
        gaps = gapIndicators;
        gaps(indexOfGiantTransits) = true;
        harmonicChiSquare = sum(((detrendedFluxValues(~gaps) - ...
            harmonicTimeSeriesValues(~gaps)) ./ detrendedFluxUncertainties(~gaps)) .^ 2) / ...
            (sum(~gaps) - 3 * length(harmonicModelStruct.harmonicFrequenciesInHz) - 1);
        harmonicTimeSeries(iTarget).harmonicChiSquare = harmonicChiSquare;
    end % if
    
    % Remove the harmonic content from the variable targets.
    iVariableTarget = iVariableTarget + 1;
    
    variableTargetDataStruct(iVariableTarget).values(~gapIndicators) = ...
        variableTargetDataStruct(iVariableTarget).values(~gapIndicators) - ...
        harmonicTimeSeries(iTarget).values(~gapIndicators);
    
end % for iTarget

% Return
return
