function plot_pa_DAWG_dump_motion( M )

% constants
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
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
MADS_TO_PLOT = 10;
HISTOGRAM_BINS = 11;
INLIER_WEIGHT_THRESHOLD = 0.05;
    
% figure position array
P =    [1228         916         342         182;
        1576         916         342         182;
         511         752         501         346;
         511         325         501         346;
           4         752         501         346;
           4         325         501         346;
        1228         653         342         182;
        1228         390         342         182;
        1228         127         342         182;
        1576         653         342         182;
        1576         390         342         182;
        1576         127         342         182];

    
% unpack input data structure    
mod = M.ccdModule;
out = M.ccdOutput;
rowCadences = M.rowCadences;
colCadences = M.colCadences;
fittedRow = M.fittedRow;
fittedCol = M.fittedCol;
rowResidual = M.rowResidual;
colResidual = M.colResidual;    
    
    
[nRowFittedCadences, nRowTargets] = size(fittedRow);                                                                                        %#ok<NASGU>
[nColFittedCadences, nColTargets] = size(fittedCol);                                                                                        %#ok<NASGU>

% [sortedRows, sortedRowIdx] = sort(fittedRow(ceil(nRowFittedCadences/2),:));
% [sortedCols, sortedColIdx] = sort(fittedCol(ceil(nColFittedCadences/2),:));

[sortedRows, sortedRowIdx] = sort(median(fittedRow));
[sortedCols, sortedColIdx] = sort(median(fittedCol));

rowResidualMinusMedian = rowResidual - ones(nRowFittedCadences,1)*median(rowResidual);
colResidualMinusMedian = colResidual - ones(nColFittedCadences,1)*median(colResidual);

fittedRowMinusMedian = fittedRow - ones(nRowFittedCadences,1)*median(fittedRow);
fittedColMinusMedian = fittedCol - ones(nColFittedCadences,1)*median(fittedCol);

figure(1);
imagesc(1:length(sortedRows),rowCadences,fittedRowMinusMedian(:,sortedRowIdx));
colorbar;
axis xy;
xlabel('PPA Target #');
ylabel('cadence')
title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Fitted Row w/Median Over Cadences Removed']);
set(gcf,'Position',P(1,:));

figure(2);
imagesc(1:length(sortedCols),colCadences,fittedColMinusMedian(:,sortedColIdx));
colorbar;
axis xy;
xlabel('PPA Target #');
ylabel('cadence')
title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Fitted Column w/Median Over Cadences Removed']);    
set(gcf,'Position',P(2,:));

figure(3);
imagesc(1:length(sortedRows),rowCadences,rowResidualMinusMedian(:,sortedRowIdx));
madData = mad(mad(rowResidualMinusMedian(:,sortedRowIdx),1),1);
medianData = nanmedian(nanmedian(rowResidualMinusMedian(:,sortedRowIdx)));
caxis([medianData - MADS_TO_PLOT*madData, medianData + MADS_TO_PLOT*madData]);
colorbar;
axis xy;
xlabel('PPA Target #');
ylabel('cadence')
title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Row Residual - Median Removed']);
set(gcf,'Position',P(3,:));

figure(4);
imagesc(1:length(sortedCols),colCadences,colResidualMinusMedian(:,sortedColIdx));
madData = mad(mad(colResidualMinusMedian(:,sortedColIdx),1),1);
medianData = nanmedian(nanmedian(colResidualMinusMedian(:,sortedColIdx)));
caxis([medianData - MADS_TO_PLOT*madData, medianData + MADS_TO_PLOT*madData]);
colorbar;
axis xy;
xlabel('PPA Target #');
ylabel('cadence')
title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Column Residual - Median Removed']);
set(gcf,'Position',P(4,:));

figure(5);
mesh(1:length(sortedRows),rowCadences,rowResidual(:,sortedRowIdx));
madData = mad(nanmedian(rowResidual(:,sortedRowIdx)),1);
medianData = nanmedian(nanmedian(rowResidual(:,sortedRowIdx)));
aa = axis;
axis([aa(1) aa(2) aa(3) aa(4) medianData - 2*MADS_TO_PLOT*madData, medianData + 2*MADS_TO_PLOT*madData]);
caxis([medianData - MADS_TO_PLOT*madData, medianData + MADS_TO_PLOT*madData]);
colorbar;
xlabel('PPA Target #');
ylabel('cadence')
title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Row Residual']);
set(gcf,'Position',P(5,:));

figure(6);
mesh(1:length(sortedCols),colCadences,colResidual(:,sortedColIdx));
madData = mad(nanmedian(colResidual(:,sortedColIdx)),1);
medianData = nanmedian(nanmedian(colResidual(:,sortedColIdx)));
aa = axis;
axis([aa(1) aa(2) aa(3) aa(4) medianData - 2*MADS_TO_PLOT*madData, medianData + 2*MADS_TO_PLOT*madData]);
caxis([medianData - MADS_TO_PLOT*madData, medianData + MADS_TO_PLOT*madData]);
colorbar;
xlabel('PPA Target #');
ylabel('cadence')
title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Column Residual']);
set(gcf,'Position',P(6,:));

figure(7);
ydata = median(rowResidual,2);
[mean, std, inlierMask] = robust_mean_std(ydata,INLIER_WEIGHT_THRESHOLD);                                                                                      %#ok<*ASGLU>
plot(rowCadences(inlierMask),ydata(inlierMask),'o');
grid;
xlabel('cadence');
ylabel('pixel');
title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Row Residual - Median Across Targets']);
set(gcf,'Position',P(7,:));

figure(8);
ydata = median(rowResidual,1);
[mean, std, inlierMask] = robust_mean_std(ydata,INLIER_WEIGHT_THRESHOLD);
plot(median(fittedRow(:,inlierMask),1),ydata(inlierMask),'o');
grid;
xlabel('median fitted row');
ylabel('pixel');
title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Row Residual - Median Across Cadences']);
set(gcf,'Position',P(8,:));

figure(9);
[N,X]=hist(ydata(inlierMask),HISTOGRAM_BINS);
bar(X,N./sum(N));
grid;
ylabel('frequency of targets');
xlabel('pixel');
title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Row Residual - Median Across Cadences']);
set(gcf,'Position',P(9,:));

figure(10);
ydata = median(colResidual,2);
[mean, std, inlierMask] = robust_mean_std(ydata,INLIER_WEIGHT_THRESHOLD);
plot(colCadences(inlierMask),ydata(inlierMask),'o');
grid;
xlabel('cadence');
ylabel('pixel');
title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Column Residual - Median Across Targets']);
set(gcf,'Position',P(10,:));

figure(11);
ydata = median(colResidual,1);
[mean, std, inlierMask] = robust_mean_std(ydata,INLIER_WEIGHT_THRESHOLD);
plot(median(fittedCol(:,inlierMask),1),ydata(inlierMask),'o');
grid;
xlabel('median fitted column');
ylabel('pixel');
title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Column Residual - Median Across Cadences']);
set(gcf,'Position',P(11,:));

figure(12);
[N,X] = hist(ydata(inlierMask),HISTOGRAM_BINS);
bar(X,N./sum(N));
grid;
xlabel('pixel');
ylabel('frequency of targets');
title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Column Residual - Median Across Cadences']);
set(gcf,'Position',P(12,:));


