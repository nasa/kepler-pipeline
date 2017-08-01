%%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
amt_test();
coaResultStruct = read_CoaOutputs('/path/to/java/tad/coa/outputs-7-success.bin');
% load /path/to/matlab/tad/coaResultStruct_m16o1.mat
%%
maskDefinitions = amtResultStruct.maskDefinitions;
apertures = coaResultStruct.optimalApertures;
apertures = rmfield(apertures, 'signalToNoiseRatio');
apertures = rmfield(apertures, 'crowdingMetric');

amaParameterStruct.maskDefinitions = maskDefinitions;
amaParameterStruct.apertureStructs = apertures;
amaParameterStruct.debugFlag = 1;

amaResultStruct = ama_matlab_controller(amaParameterStruct);
amaResultStruct1 = amaResultStruct;

%%
% convert result back to 1-base
for t=1:length(amaResultStruct.targetDefinitions)
    amaResultStruct.targetDefinitions(t).maskIndex = amaResultStruct.targetDefinitions(t).maskIndex + 1;
    amaResultStruct.targetDefinitions(t).referenceRow = amaResultStruct.targetDefinitions(t).referenceRow + 1;
    amaResultStruct.targetDefinitions(t).referenceColumn = amaResultStruct.targetDefinitions(t).referenceColumn + 1;
end

%%
% print out some metrics
nPixPerAp = zeros(length(amaParameterStruct.apertureStructs), 1);
for a=1:length(amaParameterStruct.apertureStructs)
    nPixPerAp(a) = length(amaParameterStruct.apertureStructs(a).offsets);
end
display(['average # of pixels per aperture: ' num2str(mean(nPixPerAp))]);
nPixPerMask = zeros(length(amaResultStruct.targetDefinitions), 1);
nExcessPixels = 0;
for m=1:length(amaResultStruct.targetDefinitions)
    nPixPerMask(m) = length(... 
        amaParameterStruct.maskDefinitions(amaResultStruct.targetDefinitions(m).maskIndex).offsets);
    nExcessPixels = nExcessPixels + amaResultStruct.targetDefinitions(m).excessPixels;
end
display(['average # of pixels per mask: ' num2str(mean(nPixPerMask))]);
display(['# of excess pixels: ' num2str(nExcessPixels)]);


%%
% find the unique apertures in the input set
[uniqueAps apsMap] = find_unique_apertures(amaParameterStruct.apertureStructs, ...
    amaParameterStruct.useHaloApertures);

%% 
% sort the unique apertures in order of total number of excess pixels
% caused by that aperture
% first sum the excess pixels for each unique aperture
for a=1:length(uniqueAps)
    % find the target definitions using this unique aperture
    idSet = [amaParameterStruct.apertureStructs(apsMap == a).keplerId];
    targetIndices = find(ismember([amaResultStruct.targetDefinitions.keplerId], idSet));
    targetSet = amaResultStruct.targetDefinitions(targetIndices);
    % sum the excess pixels for those target definitions
    apExcess(a) = sum([targetSet.excessPixels]);
end
noExcess = find([amaResultStruct.targetDefinitions.excessPixels] == 0);
perfectMasks = unique([amaResultStruct.targetDefinitions(noExcess).maskIndex]);

[sortedApExcess apExcessSortIndex] = sort(apExcess, 'descend');

%%
currentAp = 1;
for m = 1:length(amaParameterStruct.maskDefinitions)
    % find a non-perfect mask
    if ~ismember(m, perfectMasks)
        if apExcess(apExcessSortIndex(currentAp)) > 0 % if this aperture caused some excess
            % replace it with the next aperture in the sorted list
            % zero apertures are at end of sorted list
%             amaParameterStruct.maskDefinitions(m).offsets = [];
            amaParameterStruct.maskDefinitions(m).offsets = ...
                uniqueAps(apExcessSortIndex(currentAp)).offsets;
        end
        currentAp = currentAp + 1;
        if currentAp > length(uniqueAps)
            break;
        end
    end
end

%%
for m = 1:length(amaParameterStruct.maskDefinitions)
    for i=1:length(amaParameterStruct.maskDefinitions(m).offsets)
        amaParameterStruct.maskDefinitions(m).offsets(i).row = ...
            double(amaParameterStruct.maskDefinitions(m).offsets(i).row);
        amaParameterStruct.maskDefinitions(m).offsets(i).column = ...
            double(amaParameterStruct.maskDefinitions(m).offsets(i).column);
    end
end

% re-assign masks with the new mask table
amaResultStruct = ama_matlab_controller(amaParameterStruct);
%%
% print out some metrics
nPixPerAp = zeros(length(amaParameterStruct.apertureStructs), 1);
for a=1:length(amaParameterStruct.apertureStructs)
    nPixPerAp(a) = length(amaParameterStruct.apertureStructs(a).offsets);
end
display(['average # of pixels per aperture: ' num2str(mean(nPixPerAp))]);
nPixPerMask = zeros(length(amaResultStruct.targetDefinitions), 1);
nExcessPixels = 0;
for m=1:length(amaResultStruct.targetDefinitions)
    nPixPerMask(m) = length(... 
        amaParameterStruct.maskDefinitions(amaResultStruct.targetDefinitions(m).maskIndex+1).offsets);
    nExcessPixels(m) = amaResultStruct.targetDefinitions(m).excessPixels;
end
display(['average # of pixels per mask: ' num2str(mean(nPixPerMask))]);
display(['# of excess pixels: ' num2str(sum(nExcessPixels))]);

