function apertureStruct = get_target_apertures(location, requantize)
% function apertureStruct = get_target_apertures(location, requantize)
%
% return apertures with pixels values for all target objects in the output
% at <location>.  Each entry of the returned 1 x nTargetObjects structure
% array contains: 
%   .row, .col row and column of each pixel in aperture
%   .pixelValues pixel value of each pixel in aperture
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
if nargin < 2
    requantize = 1;
end

pixelData = get_pixel_time_series(location, 'targets', requantize);
targetDefs = get_target_definitions(location, 'targets');
maskDefinitions = get_mask_definitions(location, 'targets');
load([location filesep 'tadInputStruct.mat']);
nTargets = length(targetDefs);
targetCount = 1;
apertureStruct = struct('keplerId', 0, 'row', 0, 'col', 0, 'pixelValues', 0, ...
    'isInOptimalAperture', 0);
for t=1:nTargets
    % check to see if we've already added this keplerId
    if ~ismember(tadInputStruct.targetDefinitions(t).keplerId, ...
            [apertureStruct.keplerId])
        apertureStruct(targetCount).keplerId = ...
            tadInputStruct.targetDefinitions(t).keplerId;
        % for this keplerId, find all the targets definitions with this
        % kepleId
        apList = find([tadInputStruct.targetDefinitions.keplerId] == ...
            apertureStruct(targetCount).keplerId);
%         disp(['target ' num2str(t) ' apList: ' num2str(apList)]);
        apertureStruct(targetCount).row = [];
        apertureStruct(targetCount).col = [];
        apertureStruct(targetCount).pixelValues = [];
        for a = 1:length(apList)
            % load the mask apertures
            ap = apList(a);
            mask = maskDefinitions(targetDefs(ap).maskIndex);
            apertureStruct(targetCount).row = [apertureStruct(targetCount).row ...
                targetDefs(ap).referenceRow + 1 + [mask.offsets.row]];
            apertureStruct(targetCount).col = [apertureStruct(targetCount).col ...
                targetDefs(ap).referenceColumn + 1 + [mask.offsets.column]];
            for p=1:length([mask.offsets.row])
                pixelValues(:,p) = pixelData(ap).pixelValues(:,p);
            end
            pixelData(ap).pixelValues = [];
            apertureStruct(targetCount).pixelValues = [apertureStruct(targetCount).pixelValues ...
                pixelValues];
            clear pixelValues;
        end
        % mark the optimal apertures
        % first find the optimal aperture for this Kepler Id
        optAps = tadInputStruct.coaResultStruct.optimalApertures;
        optApTarget = find([optAps.keplerId] == apertureStruct(targetCount).keplerId);
        optApRow = optAps(optApTarget).referenceRow + 1 + [optAps(optApTarget).offsets.row];
        optApCol = optAps(optApTarget).referenceColumn + 1 + [optAps(optApTarget).offsets.column];
        apertureStruct(targetCount).isInOptimalAperture = ...
            ismember(apertureStruct(targetCount).row, optApRow) ...
            & ismember(apertureStruct(targetCount).col, optApCol);
        targetCount = targetCount + 1;
    end
end

