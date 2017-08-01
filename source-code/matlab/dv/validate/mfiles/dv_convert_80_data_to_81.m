%% dv_convert_80_data_to_81
%
% function dvDataStruct = dv_convert_80_data_to_81(dvDataStruct)
%
% Update 8.0-era DV input structures to 8.1. This is useful when testing
% with existing data sets.
%%
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

function dvDataStruct = dv_convert_80_data_to_81(dvDataStruct)

% Add software revision for 8.1.
if ~isfield(dvDataStruct, 'softwareRevision')
    dvDataStruct.softwareRevision = 'Unknown';
end % if

% Add target categories list for 8.1.
if ~isfield(dvDataStruct.targetStruct(1), 'categories')
    nTargets = length(dvDataStruct.targetStruct);
    for iTarget = 1 : nTargets
        dvDataStruct.targetStruct(iTarget).categories = {'Unknown'};
    end % for iTarget
end % if

% Update planet fit parameters for 8.1.
if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'tightParameterConvergenceTolerance')
    dvDataStruct.planetFitConfigurationStruct.tightParameterConvergenceTolerance = 0.01;
end % if

if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'looseParameterConvergenceTolerance')
    dvDataStruct.planetFitConfigurationStruct.looseParameterConvergenceTolerance = 0.1;
end % if

if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'tightSecondaryParameterConvergenceTolerance')
    dvDataStruct.planetFitConfigurationStruct.tightSecondaryParameterConvergenceTolerance = 0.1;
end % if

if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'looseSecondaryParameterConvergenceTolerance')
    dvDataStruct.planetFitConfigurationStruct.looseSecondaryParameterConvergenceTolerance = 0.1;
end % if

if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'chiSquareConvergenceTolerance')
    dvDataStruct.planetFitConfigurationStruct.chiSquareConvergenceTolerance = 1.0e-3;
end % if

if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'saveTimeSeriesEnabled')
    dvDataStruct.planetFitConfigurationStruct.saveTimeSeriesEnabled = false;
end % if

if isfield(dvDataStruct.planetFitConfigurationStruct, 'convergenceTolerance')
    dvDataStruct.planetFitConfigurationStruct = ...
        rmfield(dvDataStruct.planetFitConfigurationStruct, 'convergenceTolerance');
end % if

if isfield(dvDataStruct.planetFitConfigurationStruct, 'secondaryConvergenceTolerance')
    dvDataStruct.planetFitConfigurationStruct = ...
        rmfield(dvDataStruct.planetFitConfigurationStruct, 'secondaryConvergenceTolerance');
end % if

% Add Java-only difference image parameter.
if ~isfield(dvDataStruct.differenceImageConfigurationStruct, 'boundedBoxWidth')
    dvDataStruct.differenceImageConfigurationStruct.boundedBoxWidth = 64.0;
end % if

% Update PDC parameters.
if ~isfield(dvDataStruct.pdcConfigurationStruct, 'variabilityEpRecoveryMaskEnabled')
    dvDataStruct.pdcConfigurationStruct.variabilityEpRecoveryMaskEnabled = true;
end % if

if ~isfield(dvDataStruct.pdcConfigurationStruct, 'variabilityEpRecoveryMaskWindow')
    dvDataStruct.pdcConfigurationStruct.variabilityEpRecoveryMaskWindow = 150;
end % if

if ~isfield(dvDataStruct.pdcConfigurationStruct, 'variabilityDetrendPolyOrder')
    dvDataStruct.pdcConfigurationStruct.variabilityDetrendPolyOrder = 3;
end % if

% Update TPS parameters.
if ~isfield(dvDataStruct.tpsConfigurationStruct, 'minSesInMesCount')
    dvDataStruct.tpsConfigurationStruct.minSesInMesCount = 3;
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'maxDutyCycle')
    dvDataStruct.tpsConfigurationStruct.maxDutyCycle = 0.0625;
end % if

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'applyAttitudeTweakCorrection')
    dvDataStruct.tpsConfigurationStruct.applyAttitudeTweakCorrection = true;
end % if

if isfield(dvDataStruct.tpsConfigurationStruct, 'robustStatisticWindowLengthMultiplier')
    dvDataStruct.tpsConfigurationStruct = ...
        rmfield(dvDataStruct.tpsConfigurationStruct, 'robustStatisticWindowLengthMultiplier');
end % if

return
