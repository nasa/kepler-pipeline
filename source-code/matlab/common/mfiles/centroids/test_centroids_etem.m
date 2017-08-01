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
clear;

% prfIdString = 'm6o4_z5f5F1';
prfIdString = 'm6o4_z1f1F4';
% prfIdString = 'm20o4_z1f1F4';
% prfIdString = 'm20o4_z5f5F1';

% centroid_type = 'prf';
% centroid_type = 'gaussian-marginal';
% centroid_type = '2D-gaussian';
% centroid_type = 'flux-weighted';
centroid_type = 'best';

% load(['prfData_' prfIdString '.mat']);
load /path/to/matlab/prf/mfiles/prfResultData_m6o4.mat
prfObject = prfClass(prfStructureVector.prfPolyStructure.polyCoeffStruct);

% load(['prfData_' prfIdString '_notscaled.mat']);
% prfObject = prfClass(prfData.polyStruct);

load(['prfInputStruct_' prfIdString '.mat']);
raDec2PixObject = raDec2PixClass(prfInputStruct.raDec2PixModel, 'one-based');

targetStarsStruct = prfInputStruct.targetStarsStruct;
nTargets = length(targetStarsStruct);

goodTargets = find([prfInputStruct.targetStarsStruct.keplerMag] < 14 ...
    & [prfInputStruct.targetStarsStruct.tadCrowdingMetric] > 0.7);

[m o projectedRow projectedCol] = ra_dec_2_pix_absolute(raDec2PixObject, ...
    [targetStarsStruct.ra], ...
    [targetStarsStruct.dec], ...
    prfInputStruct.cadenceTimes.endTimeStamps, ...
    prfInputStruct.spacecraftAttitudeStruct.ra.values, ...
    prfInputStruct.spacecraftAttitudeStruct.dec.values, ...
    prfInputStruct.spacecraftAttitudeStruct.roll.values);
    
cadence = 1;
h = waitbar(0, 'computing centroids');

startTime = clock;
for t = 1:length(goodTargets)
    tStruct = targetStarsStruct(goodTargets(t));
    pStruct = tStruct.pixelTimeSeriesStruct;
    starCentroidStruct.row = [pStruct.row];
    starCentroidStruct.row = starCentroidStruct.row(:);
    starCentroidStruct.column = [pStruct.column];
    starCentroidStruct.column = starCentroidStruct.column(:);
    v = [pStruct.values]';
    starCentroidStruct.values = v(:,cadence);
    v = [pStruct.uncertainties]';
    starCentroidStruct.uncertainties = v(:,cadence);
    starCentroidStruct.gapIndicators = zeros(size(starCentroidStruct.values));
    v = [pStruct.gapIndices]';
    if ~isempty(v)
        starCentroidStruct.gapIndicators(v(:,cadence)) = 1;
    end
    starCentroidStruct.inOptimalAperture = [pStruct.isInOptimalAperture];
	starCentroidStruct.seedRow = [];
	starCentroidStruct.seedColumn = [];
    
    [centroidRow, ...
        centroidColumn, ...
        status, ...
        centroidCovariance, ...
        transformationStruct] ...
        = compute_starDataStruct_centroid(starCentroidStruct, prfObject, [], centroid_type);

    rowError(t) = centroidRow - projectedRow(goodTargets(t), cadence);
    colError(t) = centroidColumn - projectedCol(goodTargets(t), cadence);
    crowding(t) = tStruct.tadCrowdingMetric;
    magnitude(t) = tStruct.keplerMag;
    centroidStatus(t) = status;
%     keyboard
    clear starCentroidStruct;
    waitbar(t/length(goodTargets), h, ['computed centroid for target ' ...
        num2str(t) ' of ' num2str(length(goodTargets))]);
end
elapsedTime = etime(clock, startTime);
close(h);
disp([centroid_type ' centroiding, took ' num2str(elapsedTime) ...
    ' seconds or ' num2str(elapsedTime/length(goodTargets)) ...
    ' seconds per centroid']);
v = [rowError; colError];
for i=1:size(v, 2)
    normError(i) = norm(v(:,i));
end
cRow = robust_polyfit(crowding(centroidStatus==0)', rowError(centroidStatus==0)', 1, 0);
cCol = robust_polyfit(crowding(centroidStatus==0)', colError(centroidStatus==0)', 1, 0);
disp(['robust average error row: ' num2str(weighted_polyval(.8, cRow)) ...
    ' column ' num2str(weighted_polyval(.8, cCol))]);
