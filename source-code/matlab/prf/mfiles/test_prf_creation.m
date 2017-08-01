% script to exercise the various methods of creating a PRF
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

mod = 2;
out = 1;

fcModel = convert_fc_constants_java_2_struct();
% get a PRF model
if ~exist('prfCollectionObject', 'var')
    prfData = retrieve_prf_model(mod, out);
    prfCollectionObject = prfCollectionClass(prfData.blob, fcModel);
end
testCount = 1;
testPix(testCount).prfObject = prfCollectionObject;
testPix(testCount).title = 'original prfCollection object';

% root location of discrete PRF files
discretePrfDirectory = '/path/to/PRF/PRF_utilities/allSinglePrfMesh/';

% build filenames
for i=1:5
    prfFile{i} = [discretePrfDirectory filesep 'prf_m' num2str(mod) ...
        '_o' num2str(out) '_p' num2str(i) '.dat'];
    % load the data in this file
    fid = fopen(prfFile{i}, 'r');
    prfLinearArrayStruct(i).prfArray = fread(fid, 'float32'); % load as float array
    fclose(fid);
    prfArraySize = sqrt(length(prfLinearArrayStruct(i).prfArray));
    if prfArraySize ~= fix(prfArraySize)
        error('input array not square');
    end
    
    % reshape into a square array 
    prfArrayStruct(i).prfArray = reshape(prfLinearArrayStruct(i).prfArray, prfArraySize, prfArraySize); 
end

% build from file
testCount = testCount + 1;
testPix(testCount).prfObject = prfCollectionClass(prfFile, fcModel);
testPix(testCount).title = 'from file';
% build from linear array
testCount = testCount + 1;
testPix(testCount).prfObject = prfCollectionClass(prfLinearArrayStruct, fcModel);
testPix(testCount).title = 'from linear array';
% build from array
testCount = testCount + 1;
testPix(testCount).prfObject = prfCollectionClass(prfArrayStruct, fcModel);
testPix(testCount).title = 'from array';

% build from polynomial PRF
discretePrfSpecification.oversample = 50;
testCount = testCount + 1;
if exist('prfFromPolyObject', 'var')
    testPix(testCount).prfObject = prfFromPolyObject;
else
    tic;
    % the following took 31 minutes
    testPix(testCount).prfObject = prfCollectionClass(prfCollectionObject, fcModel, ...
        discretePrfSpecification);
	prfFromPolyObject = testPix(testCount).prfObject;
    toc/60
end
testPix(testCount).title = 'from prfCollection';


%%
row = 800+rand(1,1);
col = 900+rand(1,1);

masterPixels = evaluate(prfCollectionObject, row, col);
masterPixels = reshape(masterPixels, sqrt(length(masterPixels)), sqrt(length(masterPixels)));

% create irregular apertures
threshold = 1e-3;
[ppi ppj] = find(masterPixels > threshold);
centralPix = fix(size(masterPixels)/2) + 1;
offsetRows = ppi - centralPix(1);
offsetCols = ppj - centralPix(2);
apRows = fix(row) + offsetRows;
apCols = fix(col) + offsetCols;

for i=1:length(testPix)
    [testPix(i).pixels, testPix(i).row, testPix(i).col] ...
        = evaluate(testPix(i).prfObject, row, col, apRows, apCols);
    ri = testPix(i).row - fix(row) + centralPix(1);
    ci = testPix(i).col - fix(col) + centralPix(2);
    testPix(i).error = testPix(i).pixels - testPix(1).pixels;
    testPix(i).image = zeros(size(masterPixels));
    testPix(i).difImage = zeros(size(masterPixels));
    for p=1:length(testPix(i).pixels)
        testPix(i).image(ri(p), ci(p)) = testPix(i).pixels(p);
        testPix(i).difImage(ri(p), ci(p)) = testPix(i).error(p);
    end
    testPix(i).errorNorm = norm(testPix(i).error(:));
end

figure('Color', 'white');
for i=1:length(testPix)
    subplot(2,length(testPix),i)
    imagesc(testPix(i).image);
    title([testPix(i).title ', error norm = ' num2str(testPix(i).errorNorm)]);
    subplot(2,length(testPix),i + length(testPix))
    imagesc(testPix(i).difImage);
end





