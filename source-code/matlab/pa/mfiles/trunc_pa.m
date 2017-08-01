function [paDataStruct] = ...
trunc_pa(paDataStruct, nCadences, nBackgroundPixels, nTargets)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [paDataStruct] = ...
% trunc_pa(paDataStruct, nCadences, nBackgroundPixels, nTargets)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Trim a PA input structure to the given number of cadences, background
% pixels and targets. Very useful for (quick) testing! 
%
% Note that the PPA target count must be updated manually, since we cannot
% determine its correct value from a single paDataStruct. 
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
paDataStruct.endCadence = paDataStruct.startCadence + nCadences - 1;

nBg = min(length(paDataStruct.backgroundDataStruct), nBackgroundPixels);
paDataStruct.backgroundDataStruct = ...
    paDataStruct.backgroundDataStruct(1 : nBg);
for i = 1 : nBg
    paDataStruct.backgroundDataStruct(i).values = ...
        paDataStruct.backgroundDataStruct(i).values(1 : nCadences);
    paDataStruct.backgroundDataStruct(i).uncertainties = ...
        paDataStruct.backgroundDataStruct(i).uncertainties(1 : nCadences);
    paDataStruct.backgroundDataStruct(i).gapIndicators = ...
        paDataStruct.backgroundDataStruct(i).gapIndicators(1 : nCadences);
end

nT = min(length(paDataStruct.targetStarDataStruct), nTargets);
paDataStruct.targetStarDataStruct = ...
    paDataStruct.targetStarDataStruct(1 : nT);
for i = 1 : nT
    targetStarDataStruct = paDataStruct.targetStarDataStruct(i);
    nPixels = length(targetStarDataStruct.pixelDataStruct);
    for j = 1 : nPixels
        targetStarDataStruct.pixelDataStruct(j).values = ...
            targetStarDataStruct.pixelDataStruct(j).values(1 : nCadences);
        targetStarDataStruct.pixelDataStruct(j).uncertainties = ...
            targetStarDataStruct.pixelDataStruct(j).uncertainties(1 : nCadences);
        targetStarDataStruct.pixelDataStruct(j).gapIndicators = ...
            targetStarDataStruct.pixelDataStruct(j).gapIndicators(1 : nCadences);
    end
    paDataStruct.targetStarDataStruct(i) = targetStarDataStruct;
end

if ~isempty(paDataStruct.calUncertaintyBlobs.blobIndices)
    paDataStruct.calUncertaintyBlobs.blobIndices = ...
        paDataStruct.calUncertaintyBlobs.blobIndices(1 : nCadences);
    paDataStruct.calUncertaintyBlobs.gapIndicators = ...
        paDataStruct.calUncertaintyBlobs.gapIndicators(1 : nCadences);
end

% Truncate numeric and logical fields of paDataStruct.cadenceTimes.
fn = fieldnames(paDataStruct.cadenceTimes);
for iField = 1:numel(fn)
    currentField = paDataStruct.cadenceTimes.(fn{iField});
    
    if isnumeric(currentField) || islogical(currentField)
        currentField = currentField(1 : nCadences);
        paDataStruct.cadenceTimes.(fn{iField}) = currentField;
    end
end

% Truncate data anomaly flags.
fn = fieldnames(paDataStruct.cadenceTimes.dataAnomalyFlags);
for iField = 1:numel(fn)
    currentField = paDataStruct.cadenceTimes.dataAnomalyFlags.(fn{iField});
    
    if isnumeric(currentField) || islogical(currentField)
        currentField = currentField(1 : nCadences);
        paDataStruct.cadenceTimes.dataAnomalyFlags.(fn{iField}) = currentField;
    end
end


return
