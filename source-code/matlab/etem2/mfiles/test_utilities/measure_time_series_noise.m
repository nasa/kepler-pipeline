function noiseStruct = measure_time_series_noise(location)
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

oldPath = path;
addpath('user_utilities');

pixelSeries = get_pixel_time_series(location, 'targets');
load([location filesep 'runParamsObject.mat']);
load([location filesep 'motionBasis.mat']);
guardBandOffset = get(runParamsObject, 'guardBandOffset');
electronsPerADU = get(runParamsObject, 'electronsPerADU');
numLeadingBlack = get(runParamsObject, 'numLeadingBlack');
numMaskedSmear = get(runParamsObject, 'numMaskedSmear');
numCcdRows = get(runParamsObject, 'numCcdRows');
numCcdCols = get(runParamsObject, 'numCcdCols');
readNoise = get(runParamsObject, 'readNoise');
cadenceDuration = get(runParamsObject, 'cadenceDuration');
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');

% % prepare the polynomials for computing the motion at a pixel

trendA = [];
for i=1:size(motionBasis1, 1)
    for j=1:size(motionBasis1, 2)
        c = motionBasis1(i,j).designMatrix(1,1);
        dx = motionBasis1(i,j).designMatrix(:,2)/c;
        dy = motionBasis1(i,j).designMatrix(:,3)/c;
        trendA = [trendA dx dy dx.*dx dy.*dy dx.*dy];
    end
end
solutionA = (trendA'*trendA)\trendA';
    
nCadences = size(pixelSeries(1).pixelValues, 1);
nTargets = length(pixelSeries);
% for each target
for t=1:nTargets
    % remove any low-order trend
    pixVals = pixelSeries(t).pixelValues;
    meanPixVal = mean(pixVals);
    detrended = detrendcols(pixVals - repmat(meanPixVal, nCadences, 1), 4);
    
    % now detrend against motion
    coefs = solutionA*detrended;
    residual = detrended - trendA*coefs;

    noiseStruct(t).estimatedShotNoise = sqrt((meanPixVal - guardBandOffset)*electronsPerADU)/electronsPerADU;
    noiseStruct(t).measuredNoise = std(residual);
    noiseStruct(t).referenceRow = pixelSeries.referenceRow;
    noiseStruct(t).referenceColumn = pixelSeries.referenceColumn;
end

display(['estimated read noise = ' num2str(readNoise*sqrt(exposuresPerCadence))/electronsPerADU]);

path(oldPath);
