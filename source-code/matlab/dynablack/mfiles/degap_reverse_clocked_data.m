function inputsStruct = degap_reverse_clocked_data(inputsStruct)
% function inputsStruct = degap_reverse_clocked_data(inputsStruct)
%
% Modify reverse clocked data to include only ungapped cadences. 
% Gap free reverse clocked data is what is expected by the dynablack fits.
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


validIdx = find(~inputsStruct.reverseClockedCadenceTimes.gapIndicators);
numIdx = length(validIdx);

% reverseClockedCadenceTimes
inputsStruct.reverseClockedCadenceTimes.startTimestamps     = inputsStruct.reverseClockedCadenceTimes.startTimestamps(validIdx);
inputsStruct.reverseClockedCadenceTimes.midTimestamps       = inputsStruct.reverseClockedCadenceTimes.midTimestamps(validIdx);
inputsStruct.reverseClockedCadenceTimes.endTimestamps       = inputsStruct.reverseClockedCadenceTimes.endTimestamps(validIdx);
inputsStruct.reverseClockedCadenceTimes.gapIndicators       = inputsStruct.reverseClockedCadenceTimes.gapIndicators(validIdx);
inputsStruct.reverseClockedCadenceTimes.requantEnabled      = inputsStruct.reverseClockedCadenceTimes.requantEnabled(validIdx);
inputsStruct.reverseClockedCadenceTimes.cadenceNumbers      = inputsStruct.reverseClockedCadenceTimes.cadenceNumbers(validIdx);
inputsStruct.reverseClockedCadenceTimes.isSefiAcc           = inputsStruct.reverseClockedCadenceTimes.isSefiAcc(validIdx);
inputsStruct.reverseClockedCadenceTimes.isSefiCad           = inputsStruct.reverseClockedCadenceTimes.isSefiCad(validIdx);
inputsStruct.reverseClockedCadenceTimes.isLdeOos            = inputsStruct.reverseClockedCadenceTimes.isLdeOos(validIdx);
inputsStruct.reverseClockedCadenceTimes.isFinePnt           = inputsStruct.reverseClockedCadenceTimes.isFinePnt(validIdx);
inputsStruct.reverseClockedCadenceTimes.isMmntmDmp          = inputsStruct.reverseClockedCadenceTimes.isMmntmDmp(validIdx);
inputsStruct.reverseClockedCadenceTimes.isLdeParEr          = inputsStruct.reverseClockedCadenceTimes.isLdeParEr(validIdx);
inputsStruct.reverseClockedCadenceTimes.isScrcErr           = inputsStruct.reverseClockedCadenceTimes.isScrcErr(validIdx);

% reverse clocked anomaly flags
A = inputsStruct.reverseClockedCadenceTimes.dataAnomalyFlags;
A.attitudeTweakIndicators = A.attitudeTweakIndicators(validIdx);
A.safeModeIndicators = A.safeModeIndicators(validIdx);
A.coarsePointIndicators = A.coarsePointIndicators(validIdx);
A.argabrighteningIndicators = A.argabrighteningIndicators(validIdx);
A.excludeIndicators = A.excludeIndicators(validIdx);
A.earthPointIndicators = A.earthPointIndicators(validIdx);
inputsStruct.reverseClockedCadenceTimes.dataAnomalyFlags = A;

% reverseClockedBlackPixels
numBlackPixels = length(inputsStruct.reverseClockedBlackPixels);
for i=1:numBlackPixels
    inputsStruct.reverseClockedBlackPixels(i).values = inputsStruct.reverseClockedBlackPixels(i).values(validIdx);
    inputsStruct.reverseClockedBlackPixels(i).gapIndicators = inputsStruct.reverseClockedBlackPixels(i).gapIndicators(validIdx);
end

% reverseClockedMaskedSmearPixels
numSmearPixels = length(inputsStruct.reverseClockedMaskedSmearPixels);
for i=1:numSmearPixels
    inputsStruct.reverseClockedMaskedSmearPixels(i).values = inputsStruct.reverseClockedMaskedSmearPixels(i).values(validIdx);
    inputsStruct.reverseClockedMaskedSmearPixels(i).gapIndicators = inputsStruct.reverseClockedMaskedSmearPixels(i).gapIndicators(validIdx);
    inputsStruct.reverseClockedVirtualSmearPixels(i).values = inputsStruct.reverseClockedVirtualSmearPixels(i).values(validIdx);
    inputsStruct.reverseClockedVirtualSmearPixels(i).gapIndicators = inputsStruct.reverseClockedVirtualSmearPixels(i).gapIndicators(validIdx);
end

% reverseClockedBackgroundPixels
numBackgroundPixels = length(inputsStruct.reverseClockedBackgroundPixels);
for i=1:numBackgroundPixels
    inputsStruct.reverseClockedBackgroundPixels(i).values = inputsStruct.reverseClockedBackgroundPixels(i).values(validIdx);
    inputsStruct.reverseClockedBackgroundPixels(i).gapIndicators = inputsStruct.reverseClockedBackgroundPixels(i).gapIndicators(validIdx);
end

% reverseClockedTargetPixels
numTargetPixels = length(inputsStruct.reverseClockedTargetPixels);
for i=1:numTargetPixels
    inputsStruct.reverseClockedTargetPixels(i).values = inputsStruct.reverseClockedTargetPixels(i).values(validIdx);
    inputsStruct.reverseClockedTargetPixels(i).gapIndicators = inputsStruct.reverseClockedTargetPixels(i).gapIndicators(validIdx);
end


