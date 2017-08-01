function [paResultsStruct] = ...
validate_pa_outputs(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paResultsStruct] = ...
% validate_pa_outputs(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Validate the PA results structure. For now, check limits on flux time
% series and set gaps if the limits are exceeded. Also display warning
% message and issue warning alert for each target.
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

% Hard code the acceptable limits in photoelectrons per cadence.
MIN_ALLOWABLE_FLUX = 0;
MAX_ALLOWABLE_FLUX = 1e12;

MIN_ALLOWABLE_FLUX_UNCERTAINTY = 0;
MAX_ALLOWABLE_FLUX_UNCERTAINTY = 1e7;

% Set the empty value.
% emptyValue = 0;

% Get the target star results structure and alerts, and the state file name.
targetStarResultsStruct = paResultsStruct.targetStarResultsStruct;
alerts = paResultsStruct.alerts;

paFileStruct = paDataObject.paFileStruct;
paStateFileName = paFileStruct.paStateFileName;

% Load the limit structure from the state file.
load(paStateFileName, 'limitStruct');

% Loop through the targets and check the limits. DO NOT SET GAPS, BUT DO
% ISSUE WARNINGS.
nTargets = length(targetStarResultsStruct);

for iTarget = 1 : nTargets
    
    targetResultsStruct = targetStarResultsStruct(iTarget);
    keplerId = targetResultsStruct.keplerId;
    targetLimitStruct.keplerId = keplerId;
    
    fluxTimeSeries = targetResultsStruct.fluxTimeSeries;
    gapIndicators = fluxTimeSeries.gapIndicators;
    values = fluxTimeSeries.values;
    uncertainties = fluxTimeSeries.uncertainties;
    
    isOutOfLimits = (values < MIN_ALLOWABLE_FLUX | ...
        values > MAX_ALLOWABLE_FLUX) & ~gapIndicators;
    nOutOfLimits = sum(isOutOfLimits);
    targetLimitStruct.nOutOfLimitFluxValues = nOutOfLimits;
    targetLimitStruct.outOfValueLimitIndices = find(isOutOfLimits);
    if any(isOutOfLimits)
        % fluxTimeSeries.values(isOutOfLimits) = emptyValue;
        % fluxTimeSeries.uncertainties(isOutOfLimits) = emptyValue;
        % fluxTimeSeries.gapIndicators(isOutOfLimits) = true;
        % string = ['target ', num2str(iTarget), ' (Kepler ID = ', num2str(keplerId), ') : ', ...
        %     num2str(nOutOfLimits), ' out of limit flux values and associated uncertainties are being gapped'];
        string = ['target ', num2str(iTarget), ' (Kepler ID = ', num2str(keplerId), ') : ', ...
            num2str(nOutOfLimits), ' out of limit flux values'];
        [alerts] = add_alert(alerts, 'warning', string);
        disp(string);
    end % if
    
    isOutOfLimits = (uncertainties < MIN_ALLOWABLE_FLUX_UNCERTAINTY | ...
        uncertainties > MAX_ALLOWABLE_FLUX_UNCERTAINTY) & ~gapIndicators;
    nOutOfLimits = sum(isOutOfLimits);
    targetLimitStruct.nOutOfLimitFluxUncertainties = nOutOfLimits;
    targetLimitStruct.outOfUncertaintyLimitIndices = find(isOutOfLimits);
    if any(isOutOfLimits)
        % fluxTimeSeries.values(isOutOfLimits) = emptyValue;
        % fluxTimeSeries.uncertainties(isOutOfLimits) = emptyValue;
        % fluxTimeSeries.gapIndicators(isOutOfLimits) = true;
        % string = ['target ', num2str(iTarget), ' (Kepler ID = ', num2str(keplerId), ') : ', ...
        %     num2str(nOutOfLimits), ' out of limit flux uncertainties and associated values are being gapped'];
        string = ['target ', num2str(iTarget), ' (Kepler ID = ', num2str(keplerId), ') : ', ...
            num2str(nOutOfLimits), ' out of limit flux uncertainties'];
        [alerts] = add_alert(alerts, 'warning', string);
        disp(string);
    end % if
    
    targetStarResultsStruct(iTarget).fluxTimeSeries = fluxTimeSeries;
    limitStruct = [limitStruct, targetLimitStruct];
    
end % for

% Copy the target star results and alerts to the PA results structure.
paResultsStruct.targetStarResultsStruct = targetStarResultsStruct;
paResultsStruct.alerts = alerts;

% Save the updated limit structure to the PA state file.
save(paStateFileName, 'limitStruct', '-append');

% Return.
return
