function calInputStruct = get_subset_of_cal_inputs(calInputStruct, nCadences, startCadence)
% function calInputStruct = get_subset_of_cal_inputs(calInputStruct, nCadences, startCadence)
%
% This function extracts a subset of cadences of an input CAL structure. It is useful for quick testing and data validation.
%
% INPUTS:
%         calInputStruct:   CAL input struct for any invocation, collateral or photometric
%         nCadences:        If no startCadence is given, then this function extracts 1:nCadences
%         startCadence:     Optional argument to extract [startCadence : (startCadence + nCadences - 1)]
% OUTPUTS
%         calInputStruct:   CAL input struct with only cadences selected
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


if nargin < 3
    startCadence = 1;
else
    nCadences = startCadence + nCadences - 1;
end



% get subset of cadences in timestamp struct
if (~isempty(calInputStruct.cadenceTimes))

    %    startTimestamps: [3000x1 double]
    %       midTimestamps: [3000x1 double]
    %       endTimestamps: [3000x1 double]
    %       gapIndicators: [3000x1 logical]
    %      requantEnabled: [3000x1 logical]
    %      cadenceNumbers: [3000x1 double]
    %           isSefiAcc: [3000x1 logical]
    %           isSefiCad: [3000x1 logical]
    %            isLdeOos: [3000x1 logical]
    %           isFinePnt: [3000x1 logical]
    %          isMmntmDmp: [3000x1 logical]
    %          isLdeParEr: [3000x1 logical]
    %           isScrcErr: [3000x1 logical]
    %    dataAnomalyTypes: {1x4354 cell}

    calInputStruct.cadenceTimes.startTimestamps = calInputStruct.cadenceTimes.startTimestamps(startCadence:nCadences);
    calInputStruct.cadenceTimes.midTimestamps   = calInputStruct.cadenceTimes.midTimestamps(startCadence:nCadences);
    calInputStruct.cadenceTimes.endTimestamps   = calInputStruct.cadenceTimes.endTimestamps(startCadence:nCadences);

    calInputStruct.cadenceTimes.gapIndicators  = calInputStruct.cadenceTimes.gapIndicators(startCadence:nCadences);
    calInputStruct.cadenceTimes.requantEnabled = calInputStruct.cadenceTimes.requantEnabled(startCadence:nCadences);
    calInputStruct.cadenceTimes.cadenceNumbers = calInputStruct.cadenceTimes.cadenceNumbers(startCadence:nCadences);

    calInputStruct.cadenceTimes.isSefiAcc   = calInputStruct.cadenceTimes.isSefiAcc(startCadence:nCadences);
    calInputStruct.cadenceTimes.isSefiCad   = calInputStruct.cadenceTimes.isSefiCad(startCadence:nCadences);
    calInputStruct.cadenceTimes.isLdeOos    = calInputStruct.cadenceTimes.isLdeOos(startCadence:nCadences);
    calInputStruct.cadenceTimes.isFinePnt   = calInputStruct.cadenceTimes.isFinePnt(startCadence:nCadences);

    calInputStruct.cadenceTimes.isMmntmDmp  = calInputStruct.cadenceTimes.isMmntmDmp(startCadence:nCadences);
    calInputStruct.cadenceTimes.isLdeParEr  = calInputStruct.cadenceTimes.isLdeParEr(startCadence:nCadences);
    calInputStruct.cadenceTimes.isScrcErr   = calInputStruct.cadenceTimes.isScrcErr(startCadence:nCadences);
    
    dataAnomalyFlags = calInputStruct.cadenceTimes.dataAnomalyFlags;
    dataAnomalyFields = fieldnames(dataAnomalyFlags);
    for iField = 1: length(dataAnomalyFields)
        dataAnomalyFlags.(dataAnomalyFields{iField}) = dataAnomalyFlags.(dataAnomalyFields{iField})(startCadence:nCadences);
    end
    calInputStruct.cadenceTimes.dataAnomalyFlags = dataAnomalyFlags;
    

end


% get subset of cadences in target/background pixel struct, if available
if (~isempty(calInputStruct.targetAndBkgPixels))

    for i=1:length(calInputStruct.targetAndBkgPixels)
        calInputStruct.targetAndBkgPixels(i).values = calInputStruct.targetAndBkgPixels(i).values(startCadence:nCadences);
        calInputStruct.targetAndBkgPixels(i).gapIndicators = calInputStruct.targetAndBkgPixels(i).gapIndicators(startCadence:nCadences);
    end
end


% get subset of cadences in masked smear pixel struct, if available
if (~isempty(calInputStruct.maskedSmearPixels))

    for i=1:length(calInputStruct.maskedSmearPixels)
        calInputStruct.maskedSmearPixels(i).values = calInputStruct.maskedSmearPixels(i).values(startCadence:nCadences);
        calInputStruct.maskedSmearPixels(i).gapIndicators = calInputStruct.maskedSmearPixels(i).gapIndicators(startCadence:nCadences);
    end
end


% get subset of cadences in virtual smear pixel struct, if available
if (~isempty(calInputStruct.virtualSmearPixels))

    for i=1:length(calInputStruct.virtualSmearPixels)
        calInputStruct.virtualSmearPixels(i).values = calInputStruct.virtualSmearPixels(i).values(startCadence:nCadences);
        calInputStruct.virtualSmearPixels(i).gapIndicators = calInputStruct.virtualSmearPixels(i).gapIndicators(startCadence:nCadences);
    end
end


% get subset of cadences in black pixel struct, if available
if (~isempty(calInputStruct.blackPixels))

    for i=1:length(calInputStruct.blackPixels)
        calInputStruct.blackPixels(i).values = calInputStruct.blackPixels(i).values(startCadence:nCadences);
        calInputStruct.blackPixels(i).gapIndicators = calInputStruct.blackPixels(i).gapIndicators(startCadence:nCadences);
    end
end


% get subset of cadences in short cadence masked black pixel struct, if available
if (~isempty(calInputStruct.maskedBlackPixels))

    for i=1:length(calInputStruct.maskedBlackPixels)
        calInputStruct.maskedBlackPixels(i).values = calInputStruct.maskedBlackPixels(i).values(startCadence:nCadences);
        calInputStruct.maskedBlackPixels(i).gapIndicators = calInputStruct.maskedBlackPixels(i).gapIndicators(startCadence:nCadences);
    end
end

% get subset of cadences in short cadence virtual black pixel struct, if available
if (~isempty(calInputStruct.virtualBlackPixels))

    for i=1:length(calInputStruct.virtualBlackPixels)
        calInputStruct.virtualBlackPixels(i).values = calInputStruct.virtualBlackPixels(i).values(startCadence:nCadences);
        calInputStruct.virtualBlackPixels(i).gapIndicators = calInputStruct.virtualBlackPixels(i).gapIndicators(startCadence:nCadences);
    end
end


return;
