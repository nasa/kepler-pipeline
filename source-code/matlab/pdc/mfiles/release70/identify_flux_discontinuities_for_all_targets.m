function [discontinuityStruct, alerts, eventStruct] = ...
identify_flux_discontinuities_for_all_targets(targetDataStruct, ...
discontinuityConfigurationStruct, gapFillConfigurationStruct, ...
dataAnomalyIndicators, alerts, eventStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [discontinuityStruct, alerts, eventStruct] = ...
% identify_flux_discontinuities_for_all_targets(targetDataStruct, ...
% discontinuityConfigurationStruct, gapFillConfigurationStruct, ...
% dataAnomalyIndicators, alerts, eventStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Identify *unexplained* flux discontinuities for all PDC targets. Basis
% for identification of discontinuities is call to detect_regime_shift()
% for each target. Discontinuities are reconciled with known anomalies so
% that only unexplained discontinuities are returned. Cadences of
% astrophysical events are passed in and out of this function through the
% event struct array.
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


% Get the target flux values and return if insufficient data are
% available.
fluxValuesArray = [targetDataStruct.values];
gapArray = [targetDataStruct.gapIndicators];

nCadences = size(fluxValuesArray, 1);
nTargets = size(fluxValuesArray, 2);

discontinuityStruct = repmat(struct( ...
    'keplerId', 0, ...
    'foundDiscontinuity', false, ...
    'index', [], ...
    'discontinuityStepSize', [], ...
    'tooManyCadencesInGiantTransits', false, ...
    'tooManyUnexplainedDiscontinuities', false, ...
    'positiveStepDetected', false), [nTargets, 1]);

keplerIds = [targetDataStruct.keplerId];
keplerIdsCellArray = num2cell(keplerIds);
[discontinuityStruct(1 : nTargets).keplerId] = keplerIdsCellArray{ : };

if nCadences < discontinuityConfigurationStruct.savitzkyGolayFilterLength || ...
        nCadences < length(discontinuityConfigurationStruct.discontinuityModel) || ...
        nCadences < discontinuityConfigurationStruct.medianWindowLength
    [alerts] = add_alert(alerts, 'warning', ...
        'insufficient number of cadences to identify target flux discontinuities');
    disp(alerts(end).message);
    return
end % if /end

% If there are not enough valid samples in any time series to detect
% discontinuites then ensure that no discontinuities are identified.
isValidTimeSeries = sum(~gapArray, 1) > 2;
if all(~isValidTimeSeries)
    [alerts] = add_alert(alerts, 'warning', ...
        'insufficient number of valid samples to identify target flux discontinuities');
    disp(alerts(end).message);
    return
elseif any(~isValidTimeSeries)
    gapArray( : , ~isValidTimeSeries) = false;
    fluxValuesArray( : , ~isValidTimeSeries) = 0;
end % if / elseif
fluxValuesArray(gapArray) = 0;

% Detect the discontinuities and add the keplerIds.
[discontinuityStruct, eventStruct] = detect_regime_shift(fluxValuesArray, gapArray, ...
    dataAnomalyIndicators, discontinuityConfigurationStruct, ...
    gapFillConfigurationStruct, eventStruct);

[discontinuityStruct(1 : nTargets).keplerId] = keplerIdsCellArray{ : };

% Return.
return
