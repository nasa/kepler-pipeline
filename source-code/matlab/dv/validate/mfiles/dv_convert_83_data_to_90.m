%% dv_convert_83_data_to_90
%
% function dvDataStruct = dv_convert_83_data_to_90(dvDataStruct)
%
% Update 8.3-era DV input structures to 9.0. This is useful when testing
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

function dvDataStruct = dv_convert_83_data_to_90(dvDataStruct)

% Unify DV Java/Matlab timeouts.
nTargets = length(dvDataStruct.targetStruct);

if isfield(dvDataStruct.dvConfigurationStruct, 'targetTimeoutHours')
    if ~isfield(dvDataStruct, 'taskTimeoutSecs')
        dvDataStruct.taskTimeoutSecs = ...
            dvDataStruct.dvConfigurationStruct.targetTimeoutHours * ...
            get_unit_conversion('hour2sec') * nTargets;
    end
    dvDataStruct.dvConfigurationStruct = ...
        rmfield(dvDataStruct.dvConfigurationStruct, 'targetTimeoutHours');
end

% Add weak secondary info if missing.
if ~isfield(dvDataStruct.dvConfigurationStruct, 'weakSecondaryTestEnabled')
    dvDataStruct.dvConfigurationStruct.weakSecondaryTestEnabled = false;
end

for iTarget = 1 : nTargets
    nTces = length(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent);
    for iTce = 1 : nTces
        if (~isfield(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce), 'weakSecondaryStruct') || ...
                isempty(dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct) )

            periodInCadences = dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).orbitalPeriod * 48.939 ;
            phaseVector = (0:floor(periodInCadences))' ;
            phaseVector = phaseVector / 48.939 ;
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.mes = ...
                zeros(length(phaseVector), 1) ;
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.phaseInDays = ...
                phaseVector ;
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.bestPhaseInDays = ...
                phaseVector( floor(length(phaseVector)/2) ) ;
            dvDataStruct.targetStruct(iTarget).thresholdCrossingEvent(iTce).weakSecondaryStruct.bestMes = 0 ;
        end
    end
end

% Add new planet fit parameters.
if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'cotrendingEnabled')
    dvDataStruct.planetFitConfigurationStruct.cotrendingEnabled = true;
end

if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'transitDurationMultiplier')
    dvDataStruct.planetFitConfigurationStruct.transitDurationMultiplier = 5.0;
end

if ~isfield(dvDataStruct.planetFitConfigurationStruct, 'robustWeightThresholdForPlots')
    dvDataStruct.planetFitConfigurationStruct.robustWeightThresholdForPlots = 0.1;
end

% Add difference image parameters if they do not exist.
if ~isfield(dvDataStruct.differenceImageConfigurationStruct, 'maxSinglePrfFitTrials')
    dvDataStruct.differenceImageConfigurationStruct.maxSinglePrfFitTrials = 64;
end

if ~isfield(dvDataStruct.differenceImageConfigurationStruct, 'qualityThreshold')
    dvDataStruct.differenceImageConfigurationStruct.qualityThreshold = 0.7;
end

% Add empty UKIRT image string for each target if one does not exist.
if ~isfield(dvDataStruct.targetStruct(1), 'ukirtImageFileName')
    for iTarget = 1 : nTargets
        dvDataStruct.targetStruct(iTarget).ukirtImageFileName = '';
    end
end

% Add TPS parameter if it does not exist.
if ~isfield(dvDataStruct.tpsConfigurationStruct, 'maxFoldingLoopCount')
    dvDataStruct.tpsConfigurationStruct.maxFoldingLoopCount = 1000;
end

% Add simulatedTransitsEnabled flag if one does not exist.
if ~isfield(dvDataStruct.dvConfigurationStruct, 'simulatedTransitsEnabled')
    dvDataStruct.dvConfigurationStruct.simulatedTransitsEnabled = false;
end

% Add transit injection parameters file name if one does not exist.
if ~isfield(dvDataStruct, 'transitInjectionParametersFileName')
    dvDataStruct.transitInjectionParametersFileName = '';
end


return
