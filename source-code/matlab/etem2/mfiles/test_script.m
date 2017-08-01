%%
% compare etem1 and etem2 prf polynomial coefficients
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
load ../../Released/ETEM/Results/run100/cpix_run100.mat
load output/run100/prfPoly.mat

etemc = zeros(size(cpix));
prfc = zeros(size(cpix));
err = zeros(size(cpix));

for k=1:size(cpix, 1)
    etemc(k,:,:) = squeeze(cpix(k,:,:));
    prfc(k,:,:) = squeeze(prfPolyCoeffs1(k,:,:));
    err(k,:,:) = abs(etemc(k,:,:) - prfc(k,:,:));
    meandiff(k) = mean(mean(squeeze(err(k,:,:))));
    maxdiff(k) = max(max(squeeze(err(k,:,:))));
end

figure
for k=1:size(cpix, 1)
    subplot(1,3,1);
    mesh(squeeze(etemc(k,:,:)));
    title(['from etem, k=' num2str(k)]);
    subplot(1,3,2);
    mesh(squeeze(prfc(k,:,:)));
    title(['from etem2, k=' num2str(k)]);
    subplot(1,3,3);
    mesh(squeeze(err(k,:,:)));
    title(['error, k=' num2str(k)]);
    pause;
end

%%
% draw the design ranges
clear;
load ../../Released/ETEM/Results/run100/cpix_run100.mat
load output/run100/prfPoly.mat

etemDesignRangex = Ac(:,2);
etemDesignRangey = Ac(:,3);
etem2DesignRangex = prfDesignMatrix1(:,2);
etem2DesignRangey = prfDesignMatrix1(:,3);

figure
scatter(etemDesignRangex, etemDesignRangey);
hold on
scatter(etem2DesignRangex, etem2DesignRangey, 'r', '.');
hold off
%%
% compare actual etem1 and etem2 prfs at various subpix positions
clear;
load ../../Released/ETEM/Results/run100/cpix_run100.mat
load output/run100/prfPoly.mat

figure
etemDesignRangex = Ac(:,2);
etemDesignRangey = Ac(:,3);
etem2DesignRangex = prfDesignMatrix1(:,2);
etem2DesignRangey = prfDesignMatrix1(:,3);
for subrow = 1:10
    for subcol = 1:10
        etemPrf = [];
        etem2Prf = [];
        etemxmesh = [];
        etemymesh = [];
        etem2xmesh = [];
        etem2ymesh = [];
        for r=0:10
            for c=0:10
                etemPrf = [etemPrf; Ac*cpix(:,subrow+10*r, subcol+10*c)];
                etem2Prf = [etem2Prf; prfDesignMatrix1*prfPolyCoeffs1(:,subrow+10*r, subcol+10*c)];
                etemxmesh = [etemxmesh; etemDesignRangex+r];
                etemymesh = [etemymesh; etemDesignRangey+c];
                etem2xmesh = [etem2xmesh; etem2DesignRangex+r];
                etem2ymesh = [etem2ymesh; etem2DesignRangey+c];
            end
        end
        plot3(etemxmesh, etemymesh, etemPrf, '.', etem2xmesh, etem2ymesh, etem2Prf, 'r.');
        legend('from etem', 'from etem2');
        title(['subrow, subcol = ' num2str([subrow, subcol])]);
        pause(0.1);
    end
end

%%
% draw etem1 and etem2 motions
clear;
load ../../Released/ETEM/Results/run100/Ajit_run100.mat
load output/run100/motionBasis.mat

s1 = size(Ajit_Cell, 1);
s2 = size(Ajit_Cell, 2);
figure
for r=1:s1
    for c=1:s2
        etemA = Ajit_Cell{r,c};
        etemMotionx = etemA(:,2)/etemA(1,1);
        etemMotiony = etemA(:,3)/etemA(1,1);
        etem2A = motionBasis1(r,c).designMatrix;
        etem2Motionx = etem2A(:,2)/etem2A(1,1);
        etem2Motiony = etem2A(:,3)/etem2A(1,1);

        subplot(s1, s2, r+s1*(c-1));
        scatter(etemMotionx, etemMotiony);
        hold on
        scatter(etem2Motionx, etem2Motiony, 'r', '.');
        hold off
    end
end
legend('etem', 'etem2');

%%
% draw motion bases
clear;
load output_7day/run_long_m13o2s1/motionBasis.mat

s1 = size(motionBasis1, 1);
s2 = size(motionBasis1, 2);
figure
for r=1:s1
    for c=1:s2
        etem2A = motionBasis1(r,c).designMatrix;
        etem2Motionx = etem2A(:,2)/etem2A(1,1);
        etem2Motiony = etem2A(:,3)/etem2A(1,1);

        subplot(s1, s2, r+s1*(c-1));
        scatter(etem2Motionx, etem2Motiony);
    end
end
%%
% load the visible pixel polynomials
clear;
% load the etem polys first, one coefficient frame at a time
sizevec = [1024,1100];
nCoef = 28;
etemPixCoef = zeros(nCoef, sizevec(1), sizevec(2));
etem2PixCoef1 = zeros(nCoef, sizevec(1), sizevec(2));
etem2PixCoef2 = zeros(nCoef, sizevec(1), sizevec(2));
etemfid = fopen('../../Released/ETEM/Results/run100/c_ccd_run100.dat','r','ieee-be');
etem2fid1 = fopen('output/run100/visiblePixelPoly1.dat','r','ieee-be');
etem2fid2 = fopen('output/run100/visiblePixelPoly2.dat','r','ieee-be');

for c=1:nCoef
    etemPixCoef(c,:,:) = fread(etemfid, sizevec, 'float32');
    etem2PixCoef1(c,:,:) = fread(etem2fid1, sizevec, 'float32');
    etem2PixCoef2(c,:,:) = fread(etem2fid2, sizevec, 'float32');
end

fclose(etemfid);
fclose(etem2fid1);
fclose(etem2fid2);

etem2PixCoef = etem2PixCoef1 + etem2PixCoef2;

%%
% load the ccd pixel polynomials
clear;
% load the etem polys first, one coefficient frame at a time
sizevec = [1070, 1132];
nCoef = 28;
etemPixCoef = zeros(nCoef, sizevec(1), sizevec(2));
etem2PixCoef1 = zeros(nCoef, sizevec(1), sizevec(2));
etem2PixCoef2 = zeros(nCoef, sizevec(1), sizevec(2));
etemfid = fopen('../../Released/ETEM/Results/run100/c_ccd2_run100.dat','r','ieee-be');
etem2fid1 = fopen('output/run100/ccdPixelPoly1.dat','r','ieee-be');
etem2fid2 = fopen('output/run100/ccdPixelPoly2.dat','r','ieee-be');

for c=1:nCoef
    etemPixCoef(c,:,:) = fread(etemfid, sizevec, 'float32');
    etem2PixCoef1(c,:,:) = fread(etem2fid1, sizevec, 'float32');
    etem2PixCoef2(c,:,:) = fread(etem2fid2, sizevec, 'float32');
end

fclose(etemfid);
fclose(etem2fid1);
fclose(etem2fid2);

etem2PixCoef = etem2PixCoef1 + etem2PixCoef2;

%%
% load the ccd effect pixel polynomials
clear;
% load the etem polys first, one coefficient frame at a time
sizevec = [1070, 1132];
nCoef = 28;
etemPixCoef = zeros(nCoef, sizevec(1), sizevec(2));
etem2PixCoef1 = zeros(nCoef, sizevec(1), sizevec(2));
etem2PixCoef2 = zeros(nCoef, sizevec(1), sizevec(2));
etemfid = fopen('../../Released/ETEM/Results/run100/c_ccdnew_run100.dat','r','ieee-be');
etem2fid1 = fopen('output/run100/ccdPixelEffectPoly1.dat','r','ieee-be');
etem2fid2 = fopen('output/run100/ccdPixelEffectPoly2.dat','r','ieee-be');

for c=1:nCoef
    etemPixCoef(c,:,:) = fread(etemfid, sizevec, 'float32');
    etem2PixCoef1(c,:,:) = fread(etem2fid1, sizevec, 'float32');
    etem2PixCoef2(c,:,:) = fread(etem2fid2, sizevec, 'float32');
end

fclose(etemfid);
fclose(etem2fid1);
fclose(etem2fid2);

etem2PixCoef = etem2PixCoef1 + etem2PixCoef2;

%% 
% look at the visible pixel polynomial coefficients

c = 1;
figure
ax(1) = subplot(1,2,1);
h = imagesc(squeeze(etemPixCoef(c,:,:)), [0 1e4]);
set(h, 'Parent', ax(1));
title(['etem, coefficient ' num2str(c)]);
ax(2) =subplot(1,2,2);
h = imagesc(squeeze(etem2PixCoef(c,:,:)), [0 1e4]);
set(h, 'Parent', ax(2));
title(['etem2, coefficient ' num2str(c)]);
linkaxes(ax);

% look at the difference
figure
imagesc(squeeze(etemPixCoef(c,:,:)) - squeeze(etem2PixCoef(c,:,:)));
colorbar

%%
% compute the images for the loaded coefficients using a small motion
% offset
A = make_binned_design_matrix(0.01, -0.01, 6);
etemImage = zeros(sizevec);
etem2Image = zeros(sizevec);
for r=1:size(etem2PixCoef, 2)
    for c=1:size(etem2PixCoef, 3)
        etemImage(r,c) = A*etemPixCoef(:,r,c);
        etem2Image(r,c) = A*etem2PixCoef(:,r,c);
    end
end
%%
figure
ax(1) = subplot(1,2,1);
h = imagesc(etemImage, [0 1e4]);
set(h, 'Parent', ax(1));
title('etem image');
ax(2) =subplot(1,2,2);
h = imagesc(etem2Image, [0 1e4]);
set(h, 'Parent', ax(2));
title('etem2 image');
linkaxes(ax);

diffImage = etemImage - etem2Image;
meanDiffImage = mean(mean(diffImage(etemImage~=0)./etemImage(etemImage~=0)))
stdDiffImage = std(std(diffImage(etemImage~=0)./etemImage(etemImage~=0)))
%% 
% compare pixels of interest and the ccd image
clear;
range = 5e4;
load output/run_short_m14o3s1/ccdObject.mat
load output/run_short_m14o3s1/ccdImage.mat
poiStruct = ccdObject.cadenceDataObject.poiStruct;
poi = zeros(size(ccdImage));
poi(poiStruct.poiPixelIndex) = 1;
figure
ax(1) = subplot(1,2,1);
h = imagesc(poi);
set(h, 'Parent', ax(1));
title('pixels of interest');
colormap(hot);
ax(2) =subplot(1,2,2);
h = imagesc(ccdImage, [0 range]);
set(h, 'Parent', ax(2));
title('etem2 image');
colormap(hot);
linkaxes(ax);

figure;
imagesc(ccdImage.*poi, [0 range]);
title('etem2 pixels of interest');
colormap(hot);

%%
% compare TAD aperture definitions and etem2 target positions

load output/run_short_m4o2s1/catalogData.mat
load output/run_short_m4o2s1/ETEM2_tad_inputs.mat amaResultStruct
targetDefs = amaResultStruct.targetDefinitions;
TADrows = [targetDefs.referenceRow];
TADcols = [targetDefs.referenceColumn];
targetIds = [targetDefs.keplerId];
etemTargets = ismember([catalogData.kicId], targetIds);
etemRows = catalogData.row(etemTargets);
etemCols = catalogData.column(etemTargets);

figure(300)
plot(etemCols + 12, etemRows + 20, '+', TADcols, TADrows, 'ro');
