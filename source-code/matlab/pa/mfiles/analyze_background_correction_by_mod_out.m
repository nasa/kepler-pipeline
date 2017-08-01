function [backgroundAnalysisStruct] = ...
analyze_background_correction_by_mod_out()

% Assume that gaps only occur at the cadence level, i.e. all pixels are
% gapped when a cadence is gapped and only when a cadence is gapped.
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

f = dir('pa_state.mat');
if isempty(f)
    backgroundAnalysisStruct = [];
    disp('no data available')
    return
end

load('pa_state.mat', 'backgroundPolyStruct', 'nInvocations');

load('pa-inputs-0.mat')
if strcmpi(inputsStruct.cadenceType, 'LONG')
    startInvocation = 1;
else
    startInvocation = 0;
end
clear inputsStruct

iiTarget = 0;
keplerIds = [];
keplerMags = [];

for iInvocation = startInvocation : nInvocations - 1
    
    load(['pa-inputs-', num2str(iInvocation), '.mat']);
    
    paDataStruct = inputsStruct;
    clear inputsStruct
    
    ccdModule = paDataStruct.ccdModule;
    ccdOutput = paDataStruct.ccdOutput;
    modOutIndex = convert_from_module_output(ccdModule, ccdOutput);
    polyOrder = backgroundPolyStruct(1).backgroundPoly.order;
    
    cadenceTimes = paDataStruct.cadenceTimes;
    cadenceGapIndicators = ...
        cadenceTimes.gapIndicators | cadenceTimes.isMmntmDmp;
    nCadences = length(cadenceGapIndicators);
    
    targetStarDataStruct = paDataStruct.targetStarDataStruct;
    keplerIds = vertcat(keplerIds, [targetStarDataStruct.keplerId]');
    keplerMags = vertcat(keplerMags, [targetStarDataStruct.keplerMag]');
    
    nTargets = length(targetStarDataStruct);
    
    for iTarget = 1 : nTargets
        
        iiTarget = iiTarget + 1;
        
        backgroundCorrection = zeros([nCadences, 1]);
        backgroundLevel = zeros([nCadences, 1]);
        excessBackgroundLevel = zeros([nCadences, 1]);
        
        pixelDataStruct = targetStarDataStruct(iTarget).pixelDataStruct;
        ccdRow = [pixelDataStruct.ccdRow]' + 1;
        ccdColumn = [pixelDataStruct.ccdColumn]' + 1;
        inOptimalAperture = [pixelDataStruct.isInOptimalAperture]';
        pixelValues = [pixelDataStruct.values];
        
        for iCadence = 1 : nCadences
            
            if cadenceGapIndicators(iCadence)
                continue;
            end
            
            [backgroundEstimates] = ...
                weighted_polyval2d(ccdRow, ccdColumn, ...
                backgroundPolyStruct(iCadence).backgroundPoly);
            
            backgroundCorrection(iCadence) = ...
                median(backgroundEstimates(inOptimalAperture));
            
            backgroundLevel(iCadence) = ...
                median(pixelValues(iCadence, ~inOptimalAperture));
            
            backgroundCorrectedPixelValues = ...
                pixelValues(iCadence, : )' - backgroundEstimates;
            
            excessBackgroundLevel(iCadence) = ...
                median(backgroundCorrectedPixelValues(~inOptimalAperture));
            
        end % for iCadence
        
        medianBackgroundCorrection(iiTarget) = ...
            median(backgroundCorrection(~cadenceGapIndicators));            %#ok<AGROW>
        medianBackgroundLevel(iiTarget) = ...
            median(backgroundLevel(~cadenceGapIndicators));                 %#ok<AGROW>
        medianExcessBackgroundLevel(iiTarget) = ...
            median(excessBackgroundLevel(~cadenceGapIndicators));           %#ok<AGROW>
        
    end % for iTarget
    
end % for iInvocations

excessBackgroundFraction = ...
    medianExcessBackgroundLevel ./ medianBackgroundLevel;

backgroundAnalysisStruct.ccdModule = ccdModule;
backgroundAnalysisStruct.ccdOutput = ccdOutput;
backgroundAnalysisStruct.modOutIndex = modOutIndex;
backgroundAnalysisStruct.polyOrder = polyOrder;
backgroundAnalysisStruct.keplerIds = keplerIds;
backgroundAnalysisStruct.keplerMags = keplerMags;
backgroundAnalysisStruct.medianBackgroundCorrection = ...
    medianBackgroundCorrection';
backgroundAnalysisStruct.medianBackgroundLevel = ...
    medianBackgroundLevel';
backgroundAnalysisStruct.medianExcessBackgroundLevel = ...
    medianExcessBackgroundLevel';
backgroundAnalysisStruct.excessBackgroundFraction = ...
    excessBackgroundFraction';

return
    