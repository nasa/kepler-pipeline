function hLabels = add_target_labels_to_CoaImage(tadStruct, figHandle, whichLabels)
% hLabels = add_target_labels_to_CoaImage(tadStruct, figHandle, whichLabels)
% adds mouse_over_labels to a coa image displayed in figure with figure handle figHandle 
% for targets in the input tadStruct
% whichLabels can be one of:
%   keplerIds
%   firstTargetLabels
% firstTargetLabels uses the first label for each target in tadStruct.
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

if ~ishandle(figHandle)
    error('Invalid figure handle')
end

%% retrieve target definitions and mask definitions from struct
targetDefinitions = tadStruct.targetDefinitions;
maskDefinitions = tadStruct.maskDefinitions;

%% retrieve targets info from struct
targets = tadStruct.targets;

nTargets = length(targets);

%% construct labels
for i = 1:nTargets
    maskIndex = tadStruct.targetDefinitions(i).maskIndex + 1;
    nPixelsInTargetDefinitions(i) = length(tadStruct.maskDefinitions(maskIndex).offsets);
end

nTotalPixels = sum(nPixelsInTargetDefinitions);

xLabels = zeros(nTotalPixels,1);
yLabels = zeros(nTotalPixels,1);
labels = cell(nTotalPixels,1);

%%
switch whichLabels
    case 'keplerIds'
        targetLabels = cellstr(int2str(cat(1,targets.keplerId)));
    
    case 'firstTargetLabel'
        targetLabels = cell(length(targets),1);
        for i = 1:length(targets)
            targetLabels(i) = targets(i).labels(1);
        end

    otherwise
        error('add_target_labels: invalid label type')
end

decimationRadius = 10;  % pixels
i0 = 0;
for i = 1:nTargets
    % get pixels for this target
    if i==625||i==629, keyboard, end
    maskIndex = tadStruct.targetDefinitions(i).maskIndex + 1;
    referenceRow = tadStruct.targetDefinitions(i).referenceRow + 1;
    referenceCol = tadStruct.targetDefinitions(i).referenceColumn + 1;
    maskRowOffsets = [tadStruct.maskDefinitions(maskIndex).offsets.row];
    maskColOffsets = [tadStruct.maskDefinitions(maskIndex).offsets.column];
    targetRows = referenceRow + maskRowOffsets;
    targetCols = referenceCol + maskColOffsets;
    
    % determine whether the target is a star, or an extended object (like background)
    labelsI = tadStruct.targets(i).labels(:,1);
    labelsI = labelsI(:,1);
    if any(any(ismember(labelsI,{'PLANETARY','UNCLASSIFIED','GO_LC','COMPARISON','STAR_BLOOM','PPA_2DBLACK','PPA_LDE_UNDERSHOOT','ASTROMETRY','ASTERO_LC'})))
        targetRows = mean(targetRows);
        targetCols = mean(targetCols);
        ii = i0+1;
    end

    nLabelsI = length(targetCols);
    ii = i0 + (1:nLabelsI);
    xLabels(ii) = targetCols;
    yLabels(ii) = targetRows;
    labels(ii) = cellstr(repmat(targetLabels{i},nLabelsI,1));
    i0 = ii(end);
end

xLabels = xLabels(1:i0);
yLabels = yLabels(1:i0);
labels = labels(1:i0);

[xLabels, yLabels, labels] = decimate_labeled_points(xLabels, yLabels, labels, decimationRadius);

%%
hLabels = add_mouse_over_labels(figHandle, xLabels, yLabels, labels, 'color',[0,.8,1]);
    

%%
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xDecimated, yDecimated, labelsDecimated] = decimate_labeled_points(x,y,labels,decimationRadius)
% [xDecimated, yDecimated, labelsDecimated] = decimate_labeled_points(x,y,labels,decimationRadius)

[uniqueLabels, I, J] = unique(labels);

numLabels = length(uniqueLabels);

iKeep = [];
for i = 1:numLabels
    ii = find(J == i);
    [xDecimatedI, yDecimatedI] = decimate_points(x(ii), y(ii), decimationRadius);
    iKeep = [iKeep;ii(find(ismember([x(ii),y(ii)], [xDecimatedI, yDecimatedI],'rows')))];
end

xDecimated = x(iKeep);
yDecimated = y(iKeep);
labelsDecimated = labels(iKeep);

return

% partition points by label

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xDecimated, yDecimated] = decimate_points(x,y, decimationRadius)
% [xDecimated, yDecimated] = decimate_points(x, y, labels, decimationRadius)
% decimates 2D point locations {x,y} so that no two points in the output
% decimated points {xDecimated, yDecimated} are within radius
% decimationRadius of each other.

xDecimated = x;
yDecimated = y;
counter = 1;

while 1
    distanceFromCurrentPoint = ...
        sqrt( (xDecimated(counter+1:end)-xDecimated(counter)).^2 + ...
        (yDecimated(counter+1:end)-yDecimated(counter)).^2 );
    
    iRemove = counter + find( distanceFromCurrentPoint <= decimationRadius);
    
    if ~isempty(iRemove)
        xDecimated(iRemove) = [];
        yDecimated(iRemove) = [];
    end
    
    counter = counter + 1;
    
    if counter >= length(xDecimated)
        break
    end
end

return
