function inputsStruct = get_subset_of_dynablack_inputs(inputsStruct, absoluteStartCadence, absoluteEndCadence )
% function inputsStruct = get_subset_of_dynablack_inputs(inputsStruct, absoluteStartCadence, absoluteEndCadence )
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

% ~~~~~~~~~~~~~~~~ parse forward clocked data

cadenceIdx = find(inputsStruct.cadenceTimes.cadenceNumbers >= absoluteStartCadence & ...
                    inputsStruct.cadenceTimes.cadenceNumbers <= absoluteEndCadence);

% cadenceTimes
if (~isempty(inputsStruct.cadenceTimes))
    
    inputsStruct.cadenceTimes.startTimestamps = inputsStruct.cadenceTimes.startTimestamps(cadenceIdx);
    inputsStruct.cadenceTimes.midTimestamps   = inputsStruct.cadenceTimes.midTimestamps(cadenceIdx);
    inputsStruct.cadenceTimes.endTimestamps   = inputsStruct.cadenceTimes.endTimestamps(cadenceIdx);

    inputsStruct.cadenceTimes.gapIndicators  = inputsStruct.cadenceTimes.gapIndicators(cadenceIdx);
    inputsStruct.cadenceTimes.requantEnabled = inputsStruct.cadenceTimes.requantEnabled(cadenceIdx);
    inputsStruct.cadenceTimes.cadenceNumbers = inputsStruct.cadenceTimes.cadenceNumbers(cadenceIdx);

    inputsStruct.cadenceTimes.isSefiAcc   = inputsStruct.cadenceTimes.isSefiAcc(cadenceIdx);
    inputsStruct.cadenceTimes.isSefiCad   = inputsStruct.cadenceTimes.isSefiCad(cadenceIdx);
    inputsStruct.cadenceTimes.isLdeOos    = inputsStruct.cadenceTimes.isLdeOos(cadenceIdx);
    inputsStruct.cadenceTimes.isFinePnt   = inputsStruct.cadenceTimes.isFinePnt(cadenceIdx);

    inputsStruct.cadenceTimes.isMmntmDmp  = inputsStruct.cadenceTimes.isMmntmDmp(cadenceIdx);
    inputsStruct.cadenceTimes.isLdeParEr  = inputsStruct.cadenceTimes.isLdeParEr(cadenceIdx);
    inputsStruct.cadenceTimes.isScrcErr   = inputsStruct.cadenceTimes.isScrcErr(cadenceIdx);
    
    anomalyFields = fieldnames(inputsStruct.cadenceTimes.dataAnomalyFlags);
    for iField = 1:length(anomalyFields)
        inputsStruct.cadenceTimes.dataAnomalyFlags.(anomalyFields{iField}) = inputsStruct.cadenceTimes.dataAnomalyFlags.(anomalyFields{iField})(cadenceIdx);
    end
end

% blackPixels
for i=1:length(inputsStruct.blackPixels)
    inputsStruct.blackPixels(i).values = inputsStruct.blackPixels(i).values(cadenceIdx);
    inputsStruct.blackPixels(i).gapIndicators = inputsStruct.blackPixels(i).gapIndicators(cadenceIdx);
end

% maskedSmearPixels
for i=1:length(inputsStruct.maskedSmearPixels)
    inputsStruct.maskedSmearPixels(i).values = inputsStruct.maskedSmearPixels(i).values(cadenceIdx);
    inputsStruct.maskedSmearPixels(i).gapIndicators = inputsStruct.maskedSmearPixels(i).gapIndicators(cadenceIdx);
end

% virtualSmearPixels
for i=1:length(inputsStruct.virtualSmearPixels)
    inputsStruct.virtualSmearPixels(i).values = inputsStruct.virtualSmearPixels(i).values(cadenceIdx);
    inputsStruct.virtualSmearPixels(i).gapIndicators = inputsStruct.virtualSmearPixels(i).gapIndicators(cadenceIdx);
end

% backgroundPixels
for i=1:length(inputsStruct.backgroundPixels)
    inputsStruct.backgroundPixels(i).values = inputsStruct.backgroundPixels(i).values(cadenceIdx);
    inputsStruct.backgroundPixels(i).gapIndicators = inputsStruct.backgroundPixels(i).gapIndicators(cadenceIdx);
end

% arpTargetPixels
for i=1:length(inputsStruct.arpTargetPixels)
    inputsStruct.arpTargetPixels(i).values = inputsStruct.arpTargetPixels(i).values(cadenceIdx);
    inputsStruct.arpTargetPixels(i).gapIndicators = inputsStruct.arpTargetPixels(i).gapIndicators(cadenceIdx);
end



% ~~~~~~~~~~~~~~~~ parse reverse clocked data

cadenceIdx = find(inputsStruct.reverseClockedCadenceTimes.cadenceNumbers >= absoluteStartCadence & ...
                    inputsStruct.reverseClockedCadenceTimes.cadenceNumbers <= absoluteEndCadence);

% reverseClockedCadenceTimes
if (~isempty(inputsStruct.cadenceTimes))
    
    inputsStruct.reverseClockedCadenceTimes.startTimestamps = inputsStruct.reverseClockedCadenceTimes.startTimestamps(cadenceIdx);
    inputsStruct.reverseClockedCadenceTimes.midTimestamps   = inputsStruct.reverseClockedCadenceTimes.midTimestamps(cadenceIdx);
    inputsStruct.reverseClockedCadenceTimes.endTimestamps   = inputsStruct.reverseClockedCadenceTimes.endTimestamps(cadenceIdx);

    inputsStruct.reverseClockedCadenceTimes.gapIndicators  = inputsStruct.reverseClockedCadenceTimes.gapIndicators(cadenceIdx);
    inputsStruct.reverseClockedCadenceTimes.requantEnabled = inputsStruct.reverseClockedCadenceTimes.requantEnabled(cadenceIdx);
    inputsStruct.reverseClockedCadenceTimes.cadenceNumbers = inputsStruct.reverseClockedCadenceTimes.cadenceNumbers(cadenceIdx);

    inputsStruct.reverseClockedCadenceTimes.isSefiAcc   = inputsStruct.reverseClockedCadenceTimes.isSefiAcc(cadenceIdx);
    inputsStruct.reverseClockedCadenceTimes.isSefiCad   = inputsStruct.reverseClockedCadenceTimes.isSefiCad(cadenceIdx);
    inputsStruct.reverseClockedCadenceTimes.isLdeOos    = inputsStruct.reverseClockedCadenceTimes.isLdeOos(cadenceIdx);
    inputsStruct.reverseClockedCadenceTimes.isFinePnt   = inputsStruct.reverseClockedCadenceTimes.isFinePnt(cadenceIdx);

    inputsStruct.reverseClockedCadenceTimes.isMmntmDmp  = inputsStruct.reverseClockedCadenceTimes.isMmntmDmp(cadenceIdx);
    inputsStruct.reverseClockedCadenceTimes.isLdeParEr  = inputsStruct.reverseClockedCadenceTimes.isLdeParEr(cadenceIdx);
    inputsStruct.reverseClockedCadenceTimes.isScrcErr   = inputsStruct.reverseClockedCadenceTimes.isScrcErr(cadenceIdx);
    
    anomalyFields = fieldnames(inputsStruct.reverseClockedCadenceTimes.dataAnomalyFlags);
    for iField = 1:length(anomalyFields)
        inputsStruct.reverseClockedCadenceTimes.dataAnomalyFlags.(anomalyFields{iField}) = inputsStruct.reverseClockedCadenceTimes.dataAnomalyFlags.(anomalyFields{iField})(cadenceIdx);
    end
end

% reverseClockedBlackPixels
for i=1:length(inputsStruct.reverseClockedBlackPixels)
    inputsStruct.reverseClockedBlackPixels(i).values = inputsStruct.reverseClockedBlackPixels(i).values(cadenceIdx);
    inputsStruct.reverseClockedBlackPixels(i).gapIndicators = inputsStruct.reverseClockedBlackPixels(i).gapIndicators(cadenceIdx);
end

% reverseClockedMaskedSmearPixels
for i=1:length(inputsStruct.reverseClockedMaskedSmearPixels)
    inputsStruct.reverseClockedMaskedSmearPixels(i).values = inputsStruct.reverseClockedMaskedSmearPixels(i).values(cadenceIdx);
    inputsStruct.reverseClockedMaskedSmearPixels(i).gapIndicators = inputsStruct.reverseClockedMaskedSmearPixels(i).gapIndicators(cadenceIdx);
end

% reverseClockedVirtualSmearPixels
for i=1:length(inputsStruct.reverseClockedVirtualSmearPixels)
    inputsStruct.reverseClockedVirtualSmearPixels(i).values = inputsStruct.reverseClockedVirtualSmearPixels(i).values(cadenceIdx);
    inputsStruct.reverseClockedVirtualSmearPixels(i).gapIndicators = inputsStruct.reverseClockedVirtualSmearPixels(i).gapIndicators(cadenceIdx);
end

% reverseClockedBackgroundPixels
for i=1:length(inputsStruct.reverseClockedBackgroundPixels)
    inputsStruct.reverseClockedBackgroundPixels(i).values = inputsStruct.reverseClockedBackgroundPixels(i).values(cadenceIdx);
    inputsStruct.reverseClockedBackgroundPixels(i).gapIndicators = inputsStruct.reverseClockedBackgroundPixels(i).gapIndicators(cadenceIdx);
end

% reverseClockedTargetPixels
for i=1:length(inputsStruct.reverseClockedTargetPixels)
    inputsStruct.reverseClockedTargetPixels(i).values = inputsStruct.reverseClockedTargetPixels(i).values(cadenceIdx);
    inputsStruct.reverseClockedTargetPixels(i).gapIndicators = inputsStruct.reverseClockedTargetPixels(i).gapIndicators(cadenceIdx);
end

