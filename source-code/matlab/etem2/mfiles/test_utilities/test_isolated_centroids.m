function catData = test_isolated_centroids()
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
dataDir = 'output/pdq_test/cleanmotionbadpsf/run_long_m12o1s1';
isoDataDir = 'output/pdq_test/cleanmotion/run_long_m12o1s1';
load([dataDir filesep 'ccdImage.mat']);
load([isoDataDir filesep 'catalogData.mat']);
isolatedCatalogData = catalogData;
load([dataDir filesep 'catalogData.mat']);
load([dataDir filesep 'motionBasis.mat']);

raDec2PixObject = raDec2PixClass(retrieve_ra_dec_2_pix_model(), 'one-based');
dateMjd = datestr2mjd('23-Aug-2010')

innerRadius = 5;

black = mean(ccdImage(:,1110:1130), 2);
calCcd = ccdImage - repmat(black, 1, size(ccdImage, 2));
smear = mean(calCcd(5:15, :), 1);
calCcd = calCcd - repmat(smear, size(ccdImage, 1), 1);
% calCcd = ccdImage;

% find isolated targets
isolatedTargetList = find_isolated_targets(isolatedCatalogData);
disp(['found ' num2str(length(isolatedTargetList)) ' of ' num2str(length(isolatedCatalogData.row)) ' isolated targets']);
for t=1:length(isolatedTargetList)
    isolatedTargetList(t) = find(catalogData.kicId == isolatedCatalogData.kicId(isolatedTargetList(t)));
end

for t=1:length(isolatedTargetList)
	targetIndex = isolatedTargetList(t);
	catData(t).kicId = catalogData.kicId(targetIndex);
	catData(t).mag = catalogData.keplerMagnitude(targetIndex);
	catData(t).ra = catalogData.ra(targetIndex);
	catData(t).dec = catalogData.dec(targetIndex);
	catData(t).row = catalogData.row(targetIndex);
	catData(t).col = catalogData.column(targetIndex);
	catData(t).rowFraction = catalogData.rowFraction(targetIndex);
	catData(t).colFraction = catalogData.columnFraction(targetIndex);
	catData(t).subrow = (catData(t).rowFraction-1)/10;
	catData(t).subcol = (catData(t).colFraction-1)/10;
	
	catData(t).predictedRow = catData(t).row + catData(t).subrow - 0.5;
	catData(t).predictedCol = catData(t).col + catData(t).subcol - 0.5;
	
	rowRange = [catData(t).row - innerRadius catData(t).row + innerRadius];
	colRange = [catData(t).col - innerRadius catData(t).col + innerRadius];

	starPixels = calCcd(rowRange(1):rowRange(2), colRange(1):colRange(2));
	pixRow = 1:size(starPixels, 1);
	pixCol = 1:size(starPixels, 2);
	[meshCol meshRow] = meshgrid(pixCol, pixRow);
	ccdRow = meshRow + rowRange(1) - 1;
	ccdCol = meshCol + colRange(1) - 1;
	flux = sum(sum(starPixels));
	catData(t).centRow = sum(meshRow(:).*starPixels(:))/flux;
	catData(t).centCol = sum(meshCol(:).*starPixels(:))/flux;
	catData(t).centCcdRow = sum(ccdRow(:).*starPixels(:))/flux;
	catData(t).centCcdCol = sum(ccdCol(:).*starPixels(:))/flux;
	

	[m o catData(t).catRow catData(t).catCol] = ra_dec_2_pix(raDec2PixObject, catData(t).ra, catData(t).dec, dateMjd, 1);

	catData(t).centError = [catData(t).centCcdRow - catData(t).catRow catData(t).centCcdCol - catData(t).catCol];
	catData(t).errorNorm = norm(catData(t).centError);
	catData(t).predError = [catData(t).centCcdRow - catData(t).predictedRow catData(t).centCcdCol - catData(t).predictedCol];
	catData(t).predErrorNorm = norm(catData(t).predError);
end

figure(103);
subplot(1,3,1)
plot([catData.mag], [catData.errorNorm], '+');
title('error norm vs. magnitude');
xlabel('target magnitude');
ylabel('error norm');
subplot(1,3,2)
h = hist([catData.errorNorm], 1000);
hist([catData.errorNorm], 1000);
title('error norm histogram');
xlabel('error norm');
subplot(1,3,3)
hist([catData.errorNorm], 1000);
axis([0 0.3 0 1.01*max(h)]);
title('error norm histogram');
xlabel('error norm');

%%
figure(104);
escale = 100;
for i=1:length(catData)
    centRowError(i) = catData(i).centError(1);
    centColError(i) = catData(i).centError(2);
    eangle(i) = atan2(centRowError(i),centColError(i));
end
quiver([catData.catRow], [catData.catCol], escale*centRowError, escale*centColError, 0);
figure(105)
hist(eangle, 200);

%%

function isolatedTargetList = find_isolated_targets(catalogData)
isolatedTargetList = [];
for t=1:length(catalogData.row)
	if check_target_is_isolated(catalogData, t) && catalogData.keplerMagnitude(t) < 16
		isolatedTargetList = [isolatedTargetList t];
	end
end

function tf = check_target_is_isolated(cd, t)
r = cd.row(t);
c = cd.column(t);
oR = 10;
tf = 1;
for s=1:length(cd.row)
	if s ~= t
		if abs(cd.row(s) - r) < oR && abs(cd.column(s) - c) < oR
			tf = 0;
			break;
		end
	end
end


