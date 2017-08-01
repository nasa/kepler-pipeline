% script to test variable width PRF evaluation
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

m = 2;
o = 1;
if ~exist('prfObject', 'var')
if 1
	discretePrfDirectory = '/path/to/discrete_prf_model/';
	for i=1:5
		prfFilename{i} = sprintf([discretePrfDirectory 'prf_m%d_o%d_p%d.dat'], m, o, i);
	end

	fc = convert_fc_constants_java_2_struct;
	prfSpecification.type = 'PRF_DISCRETE';
	prfSpecification.oversample = 50;      
	prfObject = prfCollectionClass(prfFilename, fc, prfSpecification);
    prfSize = get(get(prfObject, 'prfCenterObject'), 'nPrfArrayRows');
	ttype = 'discrete';
else
    prfModel = retrieve_prf_model(m, o);
    % prfObject = prfClass(prfModel(1).polyStruct);
    prfObject = prfCollectionClass(prfModel.blob, convert_fc_constants_java_2_struct());
    prfSize = sqrt(size(prfModel.blob(1).polyStruct, 1));
	ttype = 'poly';
end
end
%%
% close all

testRow = 100;
testCol = 100;
testRowOffset = 0.2;
testColOffset = 0.3;
% scale = 0.914;
% scale = 0.7340;
% scale = 0.83;
% scale = 3;
% scale = 0.968;
% scale = 0.90;

theta = pi/3;
% scale = 3*[cos(theta) sin(theta); -sin(theta) cos(theta)];
% scale = [cos(theta) sin(theta); -sin(theta) cos(theta)]*[3 0;0 1];
scale = [ 1.0507   -0.0192;-0.0035    1.0898];
% scale = [.8 1;2.8 .7];

% draw(prfObject);

[prfArrayOrig row, column] ...
    = evaluate(prfObject, testRow + testRowOffset, testCol + testColOffset);
prfArrayOrig = prfArrayOrig/sum(prfArrayOrig);

[arrayCols arrayRows] = meshgrid(1:prfSize, 1:prfSize);
arrayRows = arrayRows - (fix(prfSize/2)+1) + testRow;
arrayCols = arrayCols - (fix(prfSize/2)+1) + testRow;
arrayRows = arrayRows(:);
arrayCols = arrayCols(:);
testPixIndex = find(prfArrayOrig > 0);
testRows = arrayRows(testPixIndex);
testCols = arrayCols(testPixIndex);
testRows = [];
testCols = [];

tic;
for i=1:100
	[prfArrayScaled prfRow, prfCol] ...
    	= evaluate_variable_width(prfObject, testRow + testRowOffset, ...
    	testCol + testColOffset, testRows, testCols, scale);
end
toc

[prfArrayScaled prfRow, prfCol] ...
    = evaluate_variable_width(prfObject, testRow + testRowOffset, ...
    testCol + testColOffset, testRows, testCols, scale);

prfArrayScaled = prfArrayScaled/sum(prfArrayScaled(:));
if isempty(testRows)
    prfDrawScaledArray = reshape(prfArrayScaled, prfSize, prfSize);
else
    prfDrawScaledArray = zeros(prfSize);
    prfDrawScaledArray(testPixIndex) = prfArrayScaled;
end

figure;
subplot(1,2,1);
mesh(reshape(prfArrayOrig,prfSize,prfSize));
title('original PRF');
subplot(1,2,2);
mesh(prfDrawScaledArray);
title('scaled PRF');

if 0
comparisonPrf = make_array(prfObject, testRow + testRowOffset, testCol + testColOffset, ...
    fix(scale*prfSize), 1, [testRowOffset testColOffset]);
comparisonPrf = comparisonPrf./sum(comparisonPrf(:));

figure;
subplot(1,3,1);
imagesc(reshape(prfArrayOrig,prfSize,prfSize));
title([ttype ': original PRF']);
subplot(1,3,2);
imagesc(prfDrawScaledArray);
title('scaled PRF');
subplot(1,3,3);
imagesc(comparisonPrf);
title('original PRF on scaled grid');
end

[vv ev] = eig(scale);
for i=1:size(vv,2)
	vv(i,:) = vv(i,:)./norm(vv(i,:));
end

c = ceil(prfSize/2);
th = 0:0.1:2*pi;
cx = c + sin(th);
cy = c + cos(th);

figure;
subplot(1,2,1);
% imagesc(rot90(reshape(prfArrayOrig,prfSize,prfSize)));
imagesc(reshape(prfArrayOrig,prfSize,prfSize));
title([ttype ': original PRF']);
subplot(1,2,2);
% imagesc(rot90(prfDrawScaledArray));
imagesc(prfDrawScaledArray);
line([0 ev(1,1)*vv(1,1) 0 ev(2,2)*vv(2,1)]+c, [0 ev(1,1)*vv(1,2) 0 ev(2,2)*vv(2,2)]+c, 'Color', 'w')
% line([0 vv(1,1) 0 vv(2,1)]+c, [0 vv(1,2) 0 vv(2,2)]+c, 'Color', 'w')
hold on;
plot(cx, cy, 'w');
hold off;
title('scaled PRF');

draw(prfObject, testRow + testRowOffset, testCol + testColOffset, 'contour');
title([ttype ': original PRF']);
