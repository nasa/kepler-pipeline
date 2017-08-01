%% dv_convert_90_data_to_91
%
% function dvDataStruct = dv_convert_90_data_to_91(dvDataStruct)
%
% Update 9.0-era DV input structures to 9.1. This is useful when testing
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

function dvDataStruct = dv_convert_90_data_to_91(dvDataStruct)

% Add new external TCE model description (for 9.2).
if ~isfield(dvDataStruct, 'externalTceModelDescription')
    dvDataStruct.externalTceModelDescription = '';
end

% Add new DV parameters.
if ~isfield(dvDataStruct.dvConfigurationStruct, 'cbvEnabled')
    dvDataStruct.dvConfigurationStruct.cbvEnabled = false;
end

if ~isfield(dvDataStruct.dvConfigurationStruct, 'externalTcesEnabled')
    dvDataStruct.dvConfigurationStruct.externalTcesEnabled = false;
end

% Add new planet fit parameters.
if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'iterationToFreezeCadencesForFit')
    dvDataStruct.planetFitConfigurationStruct.iterationToFreezeCadencesForFit = 1;
end

if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'defaultLog10Metallicity')
    dvDataStruct.planetFitConfigurationStruct.defaultLog10Metallicity = 0.0;
end

% Remove old planet fit parameters.
if isfield(dvDataStruct.planetFitConfigurationStruct, 'oddEvenTransitRemovalMethod')
    dvDataStruct.planetFitConfigurationStruct = ...
        rmfield(dvDataStruct.planetFitConfigurationStruct, 'oddEvenTransitRemovalMethod');
end

if isfield(dvDataStruct.planetFitConfigurationStruct, 'oddEvenTransitRemovalBufferTransits')
    dvDataStruct.planetFitConfigurationStruct = ...
        rmfield(dvDataStruct.planetFitConfigurationStruct, 'oddEvenTransitRemovalBufferTransits');
end

% Add new difference image parameters.
if ~isfield(dvDataStruct.differenceImageConfigurationStruct, 'singlePrfFitForCentroidPositionsEnabled')
    dvDataStruct.differenceImageConfigurationStruct.singlePrfFitForCentroidPositionsEnabled = true;
end

if ~isfield(dvDataStruct.differenceImageConfigurationStruct, 'badQualityOffsetRemovalEnabled')
    dvDataStruct.differenceImageConfigurationStruct.badQualityOffsetRemovalEnabled = false;
end

if ~isfield(dvDataStruct.differenceImageConfigurationStruct, 'mqOffsetConstantUncertainty')
    dvDataStruct.differenceImageConfigurationStruct.mqOffsetConstantUncertainty = 0.2/3;
end

% Add new TPS parameters.
if ~isfield(dvDataStruct.tpsConfigurationStruct, 'weakSecondaryPeakRangeMultiplier')
    dvDataStruct.tpsConfigurationStruct.weakSecondaryPeakRangeMultiplier = 1.5;
end

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'positiveOutlierHaircutEnabled')
    dvDataStruct.tpsConfigurationStruct.positiveOutlierHaircutEnabled = true;
end

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'looperMaxWallTimeFraction')
    dvDataStruct.tpsConfigurationStruct.looperMaxWallTimeFraction = 0.8;
end

if ~isfield(dvDataStruct.tpsConfigurationStruct, 'usePolyFitTransitModel')
    dvDataStruct.tpsConfigurationStruct.usePolyFitTransitModel = false;
end

% Add new harmonics identification parameters.
if ~isfield(dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct, 'retainFrequencyCombsEnabled')
    dvDataStruct.tpsHarmonicsIdentificationConfigurationStruct.retainFrequencyCombsEnabled = false;
end

if ~isfield(dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct, 'retainFrequencyCombsEnabled')
    dvDataStruct.pdcHarmonicsIdentificationConfigurationStruct.retainFrequencyCombsEnabled = false;
end

% Add per target metallicity.
nTargets = length(dvDataStruct.targetStruct);

if ~isfield(dvDataStruct.targetStruct(1), 'log10Metallicity')
    for iTarget = 1 : nTargets
        if ~isempty(dvDataStruct.kics)
            keplerId = dvDataStruct.targetStruct(iTarget).keplerId;
            keplerIds = [dvDataStruct.kics.keplerId];
            [tf, loc] = ismember(keplerId, keplerIds);
            if tf
                dvDataStruct.targetStruct(iTarget).log10Metallicity = ...
                    dvDataStruct.kics(loc).log10Metallicity;
            else
                dvDataStruct.targetStruct(iTarget).log10Metallicity = struct( ...
                    'value', NaN, ...
                    'uncertainty', NaN);
            end
        else
            dvDataStruct.targetStruct(iTarget).log10Metallicity = struct( ...
                'value', NaN, ...
                'uncertainty', NaN);
        end
    end
end

% Move raHours, decDegrees and keplerMag to their own structures.
if ~isstruct(dvDataStruct.targetStruct(1).raHours)
    for iTarget = 1 : nTargets
        dvDataStruct.targetStruct(iTarget).raHours = struct( ...
            'value', dvDataStruct.targetStruct(iTarget).raHours, ...
            'uncertainty', NaN);
    end
end
if ~isstruct(dvDataStruct.targetStruct(1).decDegrees)
    for iTarget = 1 : nTargets
        dvDataStruct.targetStruct(iTarget).decDegrees = struct( ...
            'value', dvDataStruct.targetStruct(iTarget).decDegrees, ...
            'uncertainty', NaN);
    end
end
if ~isstruct(dvDataStruct.targetStruct(1).keplerMag)
    for iTarget = 1 : nTargets
        dvDataStruct.targetStruct(iTarget).keplerMag = struct( ...
            'value', dvDataStruct.targetStruct(iTarget).keplerMag, ...
            'uncertainty', NaN);
    end
end

% Add parameter provenance strings.
for iTarget = 1 : nTargets
    if ~isfield(dvDataStruct.targetStruct(iTarget).raHours, 'provenance')
        dvDataStruct.targetStruct(iTarget).raHours.provenance = 'Unknown';
    end
    if ~isfield(dvDataStruct.targetStruct(iTarget).decDegrees, 'provenance')
        dvDataStruct.targetStruct(iTarget).decDegrees.provenance = 'Unknown';
    end
    if ~isfield(dvDataStruct.targetStruct(iTarget).keplerMag, 'provenance')
        dvDataStruct.targetStruct(iTarget).keplerMag.provenance = 'Unknown';
    end
    if ~isfield(dvDataStruct.targetStruct(iTarget).radius, 'provenance')
        dvDataStruct.targetStruct(iTarget).radius.provenance = 'Unknown';
    end
    if ~isfield(dvDataStruct.targetStruct(iTarget).effectiveTemp, 'provenance')
        dvDataStruct.targetStruct(iTarget).effectiveTemp.provenance = 'Unknown';
    end
    if ~isfield(dvDataStruct.targetStruct(iTarget).log10SurfaceGravity, 'provenance')
        dvDataStruct.targetStruct(iTarget).log10SurfaceGravity.provenance = 'Unknown';
    end
    if ~isfield(dvDataStruct.targetStruct(iTarget).log10Metallicity, 'provenance')
        dvDataStruct.targetStruct(iTarget).log10Metallicity.provenance = 'Unknown';
    end
end

% Add new TCE fields.
for iTarget = 1 : nTargets
    nTces = length(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent);
    for iTce = 1 : nTces
        if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce), 'robustStatistic')
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).robustStatistic = 0.0;
        end
        if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce), 'chiSquare1')
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).chiSquare1 = -1;
        end
        if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce), 'chiSquareDof1')
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).chiSquareDof1 = 0;
        end
        if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce), 'chiSquare2')
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).chiSquare2 = -1;
        end
        if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce), 'chiSquareDof2')
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).chiSquareDof2 = 0;
        end
        if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct, 'maxMesPhaseInDays')
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.maxMesPhaseInDays = ...
                dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.bestPhaseInDays;
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct = ...
                rmfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct, 'bestPhaseInDays');
        end
        if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct, 'maxMes')
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.maxMes = ...
                dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.bestMes;
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct = ...
                rmfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct, 'bestMes');
        end
        if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct, 'minMesPhaseInDays')
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.minMesPhaseInDays = ...
                dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.maxMesPhaseInDays;
        end
        if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct, 'minMes')
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.minMes = 0;
        end
        if ~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct, 'mesMad')
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.mesMad = 0; 
        end
    end
end

return
