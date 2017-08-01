function paInputStructSubset = get_subset_of_pa_inputs(paInputStruct, nCadences, startCadence)
% function paInputStructSubset = get_subset_of_pa_inputs(paInputStruct, nCadences, startCadence)
%
% function to extract a subset of cadences of an input PA structure, useful
% for quick testing and validation
%
%
% paInputStruct: PA input struct for any invocation
%
% nCadences: if no startCadence is given, then this function extracts 1:nCadences
%
% startCadence: optional argument to extract [startCadence : (startCadence + nCadences - 1)]
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


% find number of short cadences per long cadence from config map
% cmObject = configMapClass(paInputStruct.spacecraftConfigMap);
% scPerLc = median(get_number_of_shorts_in_long(cmObject));
scPerLc = 30;

paInputStructSubset = paInputStruct;
origStartCadence = paInputStruct.startCadence;

if nargin < 3
    startCadence = 1;
    endCadence = nCadences;
    paInputStructSubset.startCadence = origStartCadence;
    paInputStructSubset.endCadence = origStartCadence + nCadences - 1;
else
    endCadence = startCadence + nCadences - 1;
    paInputStructSubset.startCadence = origStartCadence + startCadence;
    paInputStructSubset.endCadence = origStartCadence + startCadence + nCadences - 1;
end


% get subset of cadences in timestamp struct
if ~isempty(paInputStruct.cadenceTimes)

    %    startTimestamps: [3000x1 double]
    %       midTimestamps: [3000x1 double]
    %       endTimestamps: [3000x1 double]
    %       gapIndicators: [3000x1 logipa]
    %      requantEnabled: [3000x1 logipa]
    %      cadenceNumbers: [3000x1 double]
    %           isSefiAcc: [3000x1 logipa]
    %           isSefiCad: [3000x1 logipa]
    %            isLdeOos: [3000x1 logipa]
    %           isFinePnt: [3000x1 logipa]
    %          isMmntmDmp: [3000x1 logipa]
    %          isLdeParEr: [3000x1 logipa]
    %           isScrcErr: [3000x1 logipa]
    %    dataAnomalyTypes: {1x4354 cell}
    
    cadenceTimes = paInputStructSubset.cadenceTimes;
    cadenceTimesFields = fields(cadenceTimes);
    for iField = 1:length(cadenceTimesFields)
        if ~isstruct( cadenceTimes.(cadenceTimesFields{iField}))
            x = cadenceTimes.(cadenceTimesFields{iField});
            cadenceTimes.(cadenceTimesFields{iField}) = x(startCadence:endCadence);
        else
            tempStruct = cadenceTimes.(cadenceTimesFields{iField});
            structFields = fields(tempStruct);
            for jField = 1:length(structFields)
                x = tempStruct.(structFields{jField});
                tempStruct.(structFields{jField}) = x(startCadence:endCadence);
            end
            cadenceTimes.(cadenceTimesFields{iField}) = tempStruct;                
        end
    end
    paInputStructSubset.cadenceTimes = cadenceTimes;
end

% get subset of cadences in timestamp struct
if ~isempty(paInputStruct.longCadenceTimes)

    %    startTimestamps: [3000x1 double]
    %       midTimestamps: [3000x1 double]
    %       endTimestamps: [3000x1 double]
    %       gapIndicators: [3000x1 logipa]
    %      requantEnabled: [3000x1 logipa]
    %      cadenceNumbers: [3000x1 double]
    %           isSefiAcc: [3000x1 logipa]
    %           isSefiCad: [3000x1 logipa]
    %            isLdeOos: [3000x1 logipa]
    %           isFinePnt: [3000x1 logipa]
    %          isMmntmDmp: [3000x1 logipa]
    %          isLdeParEr: [3000x1 logipa]
    %           isScrcErr: [3000x1 logipa]
    %    dataAnomalyTypes: {1x4354 cell}
    
    
    if strcmpi(paInputStructSubset.cadenceType,'short')
        a = floor(startCadence/scPerLc) + 1;
        b = floor(endCadence/scPerLc) + 1;
    else
        a = startCadence;
        b = endCadence;
    end

    cadenceTimes = paInputStructSubset.longCadenceTimes;
    cadenceTimesFields = fields(cadenceTimes);
    for iField = 1:length(cadenceTimesFields)
        if ~isstruct( cadenceTimes.(cadenceTimesFields{iField}))
            x = cadenceTimes.(cadenceTimesFields{iField});
            cadenceTimes.(cadenceTimesFields{iField}) = x(a:b);
        else
            tempStruct = cadenceTimes.(cadenceTimesFields{iField});
            structFields = fields(tempStruct);
            for jField = 1:length(structFields)
                x = tempStruct.(structFields{jField});
                tempStruct.(structFields{jField}) = x(a:b);
            end
            cadenceTimes.(cadenceTimesFields{iField}) = tempStruct;                
        end
    end
    paInputStructSubset.longCadenceTimes = cadenceTimes;
    
    % update rolling band flags if present - this input is on long cadence time stamps
    if isfield(paInputStruct,'rollingBandArtifactFlags')    
        for i = 1:length(paInputStruct.rollingBandArtifactFlags)
            paInputStructSubset.rollingBandArtifactFlags(i).flags.values = ...
                paInputStruct.rollingBandArtifactFlags(i).flags.values(a:b);
            paInputStructSubset.rollingBandArtifactFlags(i).flags.gapIndicators = ...
                paInputStruct.rollingBandArtifactFlags(i).flags.gapIndicators(a:b);
        end
    end    
end


% update target pixels if there are any
if ~isempty(paInputStruct.targetStarDataStruct)
    for i = 1:size(paInputStruct.targetStarDataStruct,2)
        for j = 1:size(paInputStruct.targetStarDataStruct(i).pixelDataStruct,2)
            paInputStructSubset.targetStarDataStruct(i).pixelDataStruct(j).values = ...
                paInputStruct.targetStarDataStruct(i).pixelDataStruct(j).values(startCadence:endCadence);
            paInputStructSubset.targetStarDataStruct(i).pixelDataStruct(j).gapIndicators = ...
                paInputStruct.targetStarDataStruct(i).pixelDataStruct(j).gapIndicators(startCadence:endCadence);
            paInputStructSubset.targetStarDataStruct(i).pixelDataStruct(j).uncertainties = ...
                paInputStruct.targetStarDataStruct(i).pixelDataStruct(j).uncertainties(startCadence:endCadence);
        end
    end
end

% update background pixels if there are any
if ~isempty(paInputStruct.backgroundDataStruct)
    for i = 1:length(paInputStruct.backgroundDataStruct)
        paInputStructSubset.backgroundDataStruct(i).values = ...
            paInputStruct.backgroundDataStruct(i).values(startCadence:endCadence);
        paInputStructSubset.backgroundDataStruct(i).gapIndicators = ...
            paInputStruct.backgroundDataStruct(i).gapIndicators(startCadence:endCadence);
        paInputStructSubset.backgroundDataStruct(i).uncertainties = ...
            paInputStruct.backgroundDataStruct(i).uncertainties(startCadence:endCadence);
    end
end



% update cal pou blob
if ~isempty(paInputStruct.calUncertaintyBlobs.blobIndices)
    paInputStruct.calUncertaintyBlobs.blobIndices = paInputStruct.calUncertaintyBlobs.blobIndices(startCadence:endCadence);
    paInputStruct.calUncertaintyBlobs.gapIndicators = paInputStruct.calUncertaintyBlobs.gapIndicators(startCadence:endCadence);
    paInputStruct.calUncertaintyBlobs.startCadence = paInputStruct.cadenceTimes.cadenceNumbers(1);
    paInputStruct.calUncertaintyBlobs.endCadence = paInputStruct.cadenceTimes.cadenceNumbers(end);
end

% update motion blob       
if ~isempty(paInputStruct.motionBlobs.blobIndices)
    paInputStruct.motionBlobs.blobIndices = paInputStruct.motionBlobs.blobIndices(startCadence:endCadence);
    paInputStruct.motionBlobs.gapIndicators = paInputStruct.motionBlobs.gapIndicators(startCadence:endCadence);
    paInputStruct.motionBlobs.startCadence = paInputStruct.cadenceTimes.cadenceNumbers(1);
    paInputStruct.motionBlobs.endCadence = paInputStruct.cadenceTimes.cadenceNumbers(end);
end     
       
% update background blob  
if ~isempty(paInputStruct.backgroundBlobs.blobIndices)
    paInputStruct.backgroundBlobs.blobIndices = paInputStruct.backgroundBlobs.blobIndices(startCadence:endCadence);
    paInputStruct.backgroundBlobs.gapIndicators = paInputStruct.backgroundBlobs.gapIndicators(startCadence:endCadence);
    paInputStruct.backgroundBlobs.startCadence = paInputStruct.cadenceTimes.cadenceNumbers(1);
    paInputStruct.backgroundBlobs.endCadence = paInputStruct.cadenceTimes.cadenceNumbers(end);
end  



return;
