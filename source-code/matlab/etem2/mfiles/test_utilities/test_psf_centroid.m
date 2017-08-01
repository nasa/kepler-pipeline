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
innerRadius = 5;

% rowRange = [785 805];
% colRange = [675 695];

raDec2PixObject = raDec2PixClass(retrieve_ra_dec_2_pix_model(), 'one-based');
dateMjd = datestr2mjd('23-Aug-2010');

dataDir = 'output/pdq_test/cleanmotionbadpsf/run_long_m12o1s1';
load([dataDir filesep 'ccdImage.mat']);
load([dataDir filesep 'catalogData.mat']);
load([dataDir filesep 'motionBasis.mat']);

black = mean(ccdImage(:,1110:1130), 2);
calCcd = ccdImage - repmat(black, 1, size(ccdImage, 2));
smear = mean(ccdImage(5:15, :), 1);
calCcd = ccdImage - repmat(smear, size(ccdImage, 1), 1);
% calCcd = ccdImage;

% targetIndex = find(catalogData.row > rowRange(1) ...
%     & catalogData.row < rowRange(2) ...
%     & catalogData.column > colRange(1) ...
%     & catalogData.column < colRange(2));
targetIndex = find(catalogData.kicId == isoData(305).kicId);

catData.ra = catalogData.ra(targetIndex);
catData.dec = catalogData.dec(targetIndex);
catData.row = catalogData.row(targetIndex);
catData.col = catalogData.column(targetIndex);
catData.rowFraction = catalogData.rowFraction(targetIndex);
catData.colFraction = catalogData.columnFraction(targetIndex);
catData.subrow = (catData.rowFraction-1)/10;
catData.subcol = (catData.colFraction-1)/10;

rowRange = [catData.row - innerRadius, catData.row + innerRadius];
colRange = [catData.col - innerRadius, catData.col + innerRadius];

starPixels = calCcd(rowRange(1):rowRange(2), colRange(1):colRange(2));
pixRow = 1:size(starPixels, 1);
pixCol = 1:size(starPixels, 2);
[meshCol meshRow] = meshgrid(pixCol, pixRow);
ccdRow = meshRow + rowRange(1) - 1;
ccdCol = meshCol + colRange(1) - 1;
flux = sum(sum(starPixels));
centRow = sum(meshRow(:).*starPixels(:))/flux;
centCol = sum(meshCol(:).*starPixels(:))/flux;
centCcdRow = sum(ccdRow(:).*starPixels(:))/flux;
centCcdCol = sum(ccdCol(:).*starPixels(:))/flux;

figure(10);
clf;
subplot(1,3,1);
imagesc(ccdImage, [0 2e6]);
hold on
plot(centCcdCol, centCcdRow, 'xm');
hold off
axis equal
axis([colRange rowRange]);
colormap(hot);
subplot(1,3,2);
imagesc(starPixels, [0 2e6]);
hold on
plot(centCol, centRow, 'xm');
hold off
axis equal
axis tight
subplot(1,3,3);
mesh(starPixels);

[m o r c] = ra_dec_2_pix(raDec2PixObject, catData.ra, catData.dec, dateMjd, 1)
catData
disp(['centroid in star image ' num2str([centRow centCol])]);
disp(['centroid in ccd image ' num2str([centCcdRow centCcdCol])]);
disp(['centroid error ' num2str([centCcdRow - r centCcdCol - c])]);

