% function croppedInputsStruct = crop_inputsstruct(inputsStruct,nCadences)
%   crops an input struct to a speficied number of cadences
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

function croppedInputsStruct = crop_inputsstruct(inputsStruct,nCadences)

    croppedInputsStruct = inputsStruct;
    
    % cadenceTimes
    fn = fieldnames(croppedInputsStruct.cadenceTimes);
    for i=1:length(fn)
        croppedInputsStruct.cadenceTimes.(fn{i}) = croppedInputsStruct.cadenceTimes.(fn{i})(1:nCadences);
    end
    
    % longCadenceTimes
    fn = fieldnames(croppedInputsStruct.longCadenceTimes);
    for i=1:length(fn)
        croppedInputsStruct.longCadenceTimes.(fn{i}) = croppedInputsStruct.longCadenceTimes.(fn{i})(1:nCadences);
    end
    
    croppedInputsStruct.motionBlobs.gapIndicators = croppedInputsStruct.motionBlobs.gapIndicators(1:nCadences);
    croppedInputsStruct.motionBlobs.blobIndices = croppedInputsStruct.motionBlobs.blobIndices(1:nCadences);
    croppedInputsStruct.motionBlobs.endCadence = croppedInputsStruct.motionBlobs.startCadence + nCadences-1;
    
%     % cadenceTimes
%     croppedInputsStruct.cadenceTimes.startTimestamps = croppedInputsStruct.cadenceTimes.startTimestamps(1:nCadences);
%     croppedInputsStruct.cadenceTimes.midTimestamps = croppedInputsStruct.cadenceTimes.midTimestamps(1:nCadences);
%     croppedInputsStruct.cadenceTimes.endTimestamps = croppedInputsStruct.cadenceTimes.endTimestamps(1:nCadences);
%     croppedInputsStruct.cadenceTimes.gapIndicators = croppedInputsStruct.cadenceTimes.gapIndicators(1:nCadences);
%     croppedInputsStruct.cadenceTimes.requantEnabled = croppedInputsStruct.cadenceTimes.requantEnabled(1:nCadences);
%     croppedInputsStruct.cadenceTimes.cadenceNumbers = croppedInputsStruct.cadenceTimes.cadenceNumbers(1:nCadences);
%     croppedInputsStruct.cadenceTimes.isSefiAcc = croppedInputsStruct.cadenceTimes.isSefiAcc(1:nCadences);
%     croppedInputsStruct.cadenceTimes.isSefiCad = croppedInputsStruct.cadenceTimes.isSefiCad(1:nCadences);
%     croppedInputsStruct.cadenceTimes.isLdeOos = croppedInputsStruct.cadenceTimes.isLdeOos(1:nCadences);
%     croppedInputsStruct.cadenceTimes.isFinePnt = croppedInputsStruct.cadenceTimes.isFinePnt(1:nCadences);
%     croppedInputsStruct.cadenceTimes.isMmntmDmp = croppedInputsStruct.cadenceTimes.isMmntmDmp(1:nCadences);
%     croppedInputsStruct.cadenceTimes.isLdeParEr = croppedInputsStruct.cadenceTimes.isLdeParEr(1:nCadences);
%     croppedInputsStruct.cadenceTimes.isScrcErr = croppedInputsStruct.cadenceTimes.isScrcErr(1:nCadences);
%     croppedInputsStruct.cadenceTimes.dataAnomalyTypes = croppedInputsStruct.cadenceTimes.dataAnomalyTypes(1:nCadences);

%     % longCadenceTimes
%     croppedInputsStruct.longCadenceTimes.startTimestamps = croppedInputsStruct.longCadenceTimes.startTimestamps(1:nCadences);
%     croppedInputsStruct.longCadenceTimes.midTimestamps = croppedInputsStruct.longCadenceTimes.midTimestamps(1:nCadences);
%     croppedInputsStruct.longCadenceTimes.endTimestamps = croppedInputsStruct.longCadenceTimes.endTimestamps(1:nCadences);
%     croppedInputsStruct.longCadenceTimes.gapIndicators = croppedInputsStruct.longCadenceTimes.gapIndicators(1:nCadences);
%     croppedInputsStruct.longCadenceTimes.requantEnabled = croppedInputsStruct.longCadenceTimes.requantEnabled(1:nCadences);
%     croppedInputsStruct.longCadenceTimes.cadenceNumbers = croppedInputsStruct.longCadenceTimes.cadenceNumbers(1:nCadences);
%     croppedInputsStruct.longCadenceTimes.isSefiAcc = croppedInputsStruct.longCadenceTimes.isSefiAcc(1:nCadences);
%     croppedInputsStruct.longCadenceTimes.isSefiCad = croppedInputsStruct.longCadenceTimes.isSefiCad(1:nCadences);
%     croppedInputsStruct.longCadenceTimes.isLdeOos = croppedInputsStruct.longCadenceTimes.isLdeOos(1:nCadences);
%     croppedInputsStruct.longCadenceTimes.isFinePnt = croppedInputsStruct.longCadenceTimes.isFinePnt(1:nCadences);
%     croppedInputsStruct.longCadenceTimes.isMmntmDmp = croppedInputsStruct.longCadenceTimes.isMmntmDmp(1:nCadences);
%     croppedInputsStruct.longCadenceTimes.isLdeParEr = croppedInputsStruct.longCadenceTimes.isLdeParEr(1:nCadences);
%     croppedInputsStruct.longCadenceTimes.isScrcErr = croppedInputsStruct.longCadenceTimes.isScrcErr(1:nCadences);
%     croppedInputsStruct.longCadenceTimes.dataAnomalyTypes = croppedInputsStruct.longCadenceTimes.dataAnomalyTypes{1:nCadences};

    % targetDataStruct
    for i=1:length(croppedInputsStruct.targetDataStruct)
        croppedInputsStruct.targetDataStruct(i).values = croppedInputsStruct.targetDataStruct(i).values(1:nCadences);
        croppedInputsStruct.targetDataStruct(i).gapIndicators = croppedInputsStruct.targetDataStruct(i).gapIndicators(1:nCadences);
        croppedInputsStruct.targetDataStruct(i).uncertainties = croppedInputsStruct.targetDataStruct(i).uncertainties(1:nCadences);
    end
end
