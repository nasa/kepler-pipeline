
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

mod = 16;
out = 4;
prfNum = 5;

if ~exist('prfPolyObject', 'var')
    prfModel = retrieve_prf_model(mod, out);
    prfPolyObject = prfCollectionClass(prfModel.blob, convert_fc_constants_java_2_struct());
%     prfPolyObject = prfClass(prfModel.blob(1).polyStruct);
end

if 1
% root location of discrete PRF files
discretePrfDirectory = '/path/to/discrete_prf_model/';
%discretePrfDirectory = '/path/to/PRF/PRF_utilities/allSinglePrfMesh/';

% build filenames
for i=1:5
    prfFile{i} = [discretePrfDirectory filesep 'prf_m' num2str(mod) ...
        '_o' num2str(out) '_p' num2str(i) '.dat'];
end
prfDiscreteObject = prfCollectionClass(prfFile, convert_fc_constants_java_2_struct());
% prfDiscreteObject = prfClass(prfFile{1});
% 
else
discretePrfSpecification.oversample = 10;
tic
prfDiscreteObject = prfCollectionClass(prfModel.blob, convert_fc_constants_java_2_struct(), discretePrfSpecification);
toc/60
end

centroid_type = 'best';
nCadences = 100;
starFlux = 1e7;
uncertainties = 1e-3*starFlux;

% all offsets positive, mix of quadrants
deltaRow = [0.0; 0.001; 0.3; 0.6; 0.3; 0.7; 0.5; 0.001; 0.3; -0.2; 0.3; -0.2; -0.5];
deltaCol = [0.0; 0.001; 0.2; 0.3; 0.6; 0.7; 0.5; -0.001; 0.2; 0.3; -0.2; -0.3; -0.5];
baseRow = [100; 100; 600; 190; 390; 236; 800; 100; 600; 190; 390; 236; 800];
baseCol = [100; 150; 750; 436; 200; 642; 942; 150; 750; 436; 200; 642; 942];

for i=1:length(deltaRow)
    [prfArray row, column] ...
        = evaluate(prfPolyObject, baseRow(i) + deltaRow(i), baseCol(i) + deltaCol(i));
    starDataStruct(i).prfArray = prfArray/max(max(prfArray));

    starDataStruct(i).prfOrigArray = starDataStruct(i).prfArray;

    [prfArray row, column] ...
        = evaluate(prfDiscreteObject, baseRow(i) + deltaRow(i), baseCol(i) + deltaCol(i));
    starDataStruct(i).prfDiscreteArray = prfArray/max(max(prfArray));

	starDataStruct(i).diff = starDataStruct(i).prfDiscreteArray - starDataStruct(i).prfArray;
	starDataStruct(i).diffNorm = norm(starDataStruct(i).diff);

    starDataStruct(i).prfArray = starFlux*starDataStruct(i).prfArray;
%     starDataStruct(i).prfArray = prfArray;
    
    starDataStruct(i).row = row;
    starDataStruct(i).column = column;
    starDataStruct(i).values = repmat(starDataStruct(i).prfArray(:), 1, nCadences) + uncertainties*randn(length(prfArray(:)), nCadences);
    starDataStruct(i).uncertainties = uncertainties*ones(size(starDataStruct(1).values));
    starDataStruct(i).gapIndicators = zeros(size(starDataStruct(1).values));
    starDataStruct(i).inOptimalAperture = ones(size(starDataStruct(1).row));
	starDataStruct(i).seedRow = [];
	starDataStruct(i).seedColumn = [];
end
diffNorm = [starDataStruct.diffNorm];

% set an example of optimal aperture containing pixels with some value
starDataStruct(2).inOptimalAperture = starDataStruct(2).values(:,1) > 1e-3;
starDataStruct(4).inOptimalAperture = starDataStruct(2).values(:,1) > 1e-3;
% introduce random gaps
for s=3:length(deltaRow)
    starDataStruct(s).gapIndicators = ...
        rand(size(starDataStruct(s).gapIndicators)) < 0.1;
end
% zero out a couple cadences
starDataStruct(5).values(:, [3, 6]) = 0;

startTime = clock;
[centroidRow, centroidColumn, status, centroidCovariance, transformationStruct] ...
    = compute_starDataStruct_centroid(starDataStruct, prfPolyObject, [], centroid_type);
elapsedTime = etime(clock, startTime);

rowError = (centroidRow - repmat(baseRow + deltaRow, 1, nCadences)).*~status;
colError = (centroidColumn - repmat(baseCol + deltaCol, 1, nCadences)).*~status;
meanRowError = mean(rowError, 2);
stdRowError = std(rowError, 0, 2);
meanColError = mean(colError, 2);
stdColError = std(colError, 0, 2);

disp([centroid_type ' centroiding, took ' num2str(elapsedTime) ...
    ' seconds or ' num2str(elapsedTime/(nCadences*length(starDataStruct))) ...
    ' seconds per centroid']);
disp('row_exact row_error row_std col_exact col_error col_std');
disp([baseRow + deltaRow meanRowError stdRowError ...
    baseCol + deltaCol meanColError stdColError]);
disp(['mean row uncertainty: ' num2str(mean(mean(squeeze(sqrt(centroidCovariance(:,1,1,:)))))) ...
	' mean column uncertainty: ' num2str(mean(mean(squeeze(sqrt(centroidCovariance(:,2,2,:))))))]);

startTime = clock;
[centroidDiscreteRow, centroidDiscreteColumn, status, centroidDiscreteCovariance, transformationStruct] ...
    = compute_starDataStruct_centroid(starDataStruct, prfDiscreteObject, [], centroid_type);
elapsedDiscreteTime = etime(clock, startTime);

rowDiscreteError = (centroidDiscreteRow - repmat(baseRow + deltaRow, 1, nCadences)).*~status;
colDiscreteError = (centroidDiscreteColumn - repmat(baseCol + deltaCol, 1, nCadences)).*~status;
meanRowDiscreteError = mean(rowDiscreteError, 2);
stdRowDiscreteError = std(rowDiscreteError, 0, 2);
meanColDiscreteError = mean(colDiscreteError, 2);
stdColDiscreteError = std(colDiscreteError, 0, 2);

disp(['discrete centroiding, took ' num2str(elapsedDiscreteTime) ...
    ' seconds or ' num2str(elapsedDiscreteTime/(nCadences*length(starDataStruct))) ...
    ' seconds per centroid']);
disp('row_exact row_error row_std col_exact col_error col_std diff_norm');
disp([baseRow + deltaRow meanRowDiscreteError stdRowDiscreteError ...
    baseCol + deltaCol meanColDiscreteError stdColDiscreteError diffNorm(:)]);
disp(['mean row uncertainty: ' num2str(mean(mean(squeeze(sqrt(centroidDiscreteCovariance(:,1,1,:)))))) ...
	' mean column uncertainty: ' num2str(mean(mean(squeeze(sqrt(centroidDiscreteCovariance(:,2,2,:))))))]);

disp(['speedup: ' num2str(elapsedTime/elapsedDiscreteTime)]);
