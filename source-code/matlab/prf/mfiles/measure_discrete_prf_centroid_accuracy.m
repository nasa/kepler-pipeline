
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

mod = 9;
out = 4;
prfNum = 5;

if ~exist('prfPolyObject', 'var')
    prfModel = retrieve_prf_model(mod, out);
    prfPolyObject = prfCollectionClass(prfModel.blob, convert_fc_constants_java_2_struct());
%     prfPolyObject = prfClass(prfModel.blob(1).polyStruct);
end

oversampleArray = [5 10 15 20 25 30];

if exist('discreteTrialInit.mat', 'file')
	load discreteTrialInit.mat;
else
	for i=1:length(oversampleArray)
		discretePrfSpecification.oversample = oversampleArray(i);
		discreteTrial(i).oversample = oversampleArray(i);
		startTime = clock;
		discreteTrial(i).prfObject = prfCollectionClass(prfModel.blob, ...
			convert_fc_constants_java_2_struct(), discretePrfSpecification);
		discreteTrial(i).creationTimeSeconds = etime(clock, startTime);
		disp(['prf creation: resolution ' num2str(oversampleArray(i)) ...
			' took ' num2str(discreteTrial(i).creationTimeSeconds/60) ' minutes']);
	end
	save discreteTrialInit.mat discreteTrial;
end

centroid_type = 'best';
nCadences = 100;
starFlux = 1e7;
readNoise = 100*270;

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

	for d = 1:length(discreteTrial)
    	[prfArray row, column] ...
        	= evaluate(discreteTrial(d).prfObject, baseRow(i) + deltaRow(i), baseCol(i) + deltaCol(i));
    	discretePrfArray = prfArray/max(max(prfArray));

		evalDiff = discretePrfArray - starDataStruct(i).prfArray;
		discreteTrial(d).diffNorm(i) = norm(evalDiff);
	end
    starDataStruct(i).prfArray = starFlux*starDataStruct(i).prfArray;
    
    starDataStruct(i).row = row;
    starDataStruct(i).column = column;
    starDataStruct(i).uncertainties = repmat(readNoise*ones(size(starDataStruct(i).prfArray(:))) ...
		+ sqrt(abs(starDataStruct(i).prfArray(:))), 1, nCadences);
    starDataStruct(i).values = repmat(starDataStruct(i).prfArray(:), 1, nCadences) ...
		+ starDataStruct(i).uncertainties.*randn(length(prfArray(:)), nCadences);
    starDataStruct(i).gapIndicators = zeros(size(starDataStruct(1).values));
    starDataStruct(i).inOptimalAperture = ones(size(starDataStruct(1).row));
	starDataStruct(i).seedRow = [];
	starDataStruct(i).seedColumn = [];
end

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
polyCentroidTimeSeconds = elapsedTime;

rowError = (centroidRow - repmat(baseRow + deltaRow, 1, nCadences)).*~status;
colError = (centroidColumn - repmat(baseCol + deltaCol, 1, nCadences)).*~status;
meanRowError = mean(rowError, 2);
stdRowError = std(rowError, 0, 2);
meanColError = mean(colError, 2);
stdColError = std(colError, 0, 2);

for i=1:length(discreteTrial)
	startTime = clock;
	[centroidDiscreteRow, centroidDiscreteColumn, status, centroidDiscreteCovariance, transformationStruct] ...
    	= compute_starDataStruct_centroid(starDataStruct, discreteTrial(i).prfObject, [], centroid_type);
	elapsedDiscreteTime = etime(clock, startTime);

	discreteTrial(i).centroidRow = centroidDiscreteRow;
	discreteTrial(i).centroidCol = centroidDiscreteColumn;
	discreteTrial(i).status = status;
	discreteTrial(i).centroidRowDiff = centroidDiscreteRow - centroidRow;
	discreteTrial(i).centroidColDiff = centroidDiscreteColumn - centroidColumn;
	discreteTrial(i).rowError = (centroidDiscreteRow - repmat(baseRow + deltaRow, 1, nCadences)).*~status;
	discreteTrial(i).colError = (centroidDiscreteColumn - repmat(baseCol + deltaCol, 1, nCadences)).*~status;
	discreteTrial(i).meanRowError = mean(discreteTrial(i).rowError, 2);
	discreteTrial(i).stdRowError = std(discreteTrial(i).rowError, 0, 2);
	discreteTrial(i).meanColError = mean(discreteTrial(i).colError, 2);
	discreteTrial(i).stdColError = std(discreteTrial(i).colError, 0, 2);
	discreteTrial(i).elapsedTime = elapsedDiscreteTime;
end

save discretePrfCentroidAccuracy.mat starDataStruct discreteTrial centroidRow centroidColumn status polyCentroidTimeSeconds
