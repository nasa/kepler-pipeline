function motionStruct = measure_time_series_motion(location)
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

quantized = 0;
cosmicRays = 0;

cadenceType = strfind(location, 'short');
if isempty(cadenceType)
    % it's a long cadence
    pixelSeries = get_pixel_time_series(location, 'targets', quantized, cosmicRays);
    backgroundSeries = get_pixel_time_series(location, 'background', quantized, cosmicRays);
    meanBackground = mean(backgroundSeries, 2);
else
    pixelSeries = get_short_cadence_time_series(location, quantized, cosmicRays);
    % set the backgound to the dimmest pixel in the first series
    meanBackground = min(pixelSeries(1).pixelValues(1, :));
end
targetMaskTable = get_mask_definitions(location, 'targets');

load([location filesep 'motionBasis.mat']);

numLeadingBlack = 12;
numMaskedSmear = 20;
numCcdRows = 1070;
numCcdCols = 1132;

nCadences = size(pixelSeries(1).pixelValues, 1);

rowMotion = zeros(size(motionBasis1));
colMotion = zeros(size(motionBasis1));
for cadence=1:nCadences
    for i=1:size(motionBasis1, 1)
        for j=1:size(motionBasis1, 2)
            colMotion(i,j) = motionBasis1(i,j).designMatrix(cadence,2)./motionBasis1(i,j).designMatrix(cadence,1);
            rowMotion(i,j) = motionBasis1(i,j).designMatrix(cadence,3)./motionBasis1(i,j).designMatrix(cadence,1);       
        end
    end
    rowMotionCoeff(cadence) = weighted_polyfit2d(motionGridRow(:)/numCcdRows, ...
        motionGridCol(:)/numCcdCols, rowMotion(:), 1, 3);
    colMotionCoeff(cadence) = weighted_polyfit2d(motionGridRow(:)/numCcdRows, ...
        motionGridCol(:)/numCcdCols, colMotion(:), 1, 3);  
end


meanRowMotion = zeros(1, nCadences);
meanColMotion = zeros(1, nCadences);
meanInjectedRowMotion = zeros(1, nCadences);
meanInjectedColMotion = zeros(1, nCadences);
nTargets = length(pixelSeries);
targetMotion = repmat(struct('rowCentroid', 0, 'colCentroid', 0, 'flux', 0, ...
    'rowInjectedMotion', 0, 'colInjectedMotion', 0), 1, nTargets);
% for each target
for t=1:nTargets
    targetStruct = pixelSeries(t);
    mask = targetMaskTable(targetStruct.maskIndex);
    pixRow = targetStruct.referenceRow + [mask.offsets.row];
    pixCol = targetStruct.referenceColumn + [mask.offsets.column];
    
    % pixelValues is nCadences x nPixels
    pixelValues = targetStruct.pixelValues - repmat(meanBackground, 1, size(targetStruct.pixelValues, 2));
    
    % compute the c of the series
    flux = sum(pixelValues, 2);
    targetMotion(t).rowCentroid = (pixRow*pixelValues')./flux';
    targetMotion(t).colCentroid = (pixCol*pixelValues')./flux';
    
    meanRowMotion = meanRowMotion + targetMotion(t).rowCentroid/nTargets;
    meanColMotion = meanColMotion + targetMotion(t).colCentroid/nTargets;
    
    targetMotion(t).flux = flux;
    % compute the injected motion
    targetMotion(t).rowInjectedMotion = weighted_polyval2d( ...
        targetStruct.referenceRow/numCcdRows, targetStruct.referenceColumn/numCcdCols, ...
        rowMotionCoeff);
    targetMotion(t).colInjectedMotion = weighted_polyval2d( ...
        targetStruct.referenceRow/numCcdRows, targetStruct.referenceColumn/numCcdCols, ...
        colMotionCoeff); 
    
    meanInjectedRowMotion = meanInjectedRowMotion + targetMotion(t).rowInjectedMotion/nTargets;
    meanInjectedColMotion = meanInjectedColMotion + targetMotion(t).colInjectedMotion/nTargets;
end

motionStruct.targetMotion = targetMotion;
motionStruct.pixelSeries = pixelSeries;
motionStruct.targetMaskTable = targetMaskTable;
motionStruct.meanRowMotion = meanRowMotion;
motionStruct.meanColMotion = meanColMotion;
motionStruct.meanInjectedRowMotion = meanInjectedRowMotion;
motionStruct.meanInjectedColMotion = meanInjectedColMotion;
