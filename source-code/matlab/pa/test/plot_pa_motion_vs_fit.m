function M = plot_pa_motion_vs_fit( pathName, PLOTS_ON )


% figure position array
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



% load first target invocation input just to get cadences numbers
load([pathName,'pa-inputs-1.mat']);
cadences = inputsStruct.cadenceTimes.cadenceNumbers(:);
clear inputsStruct

% load the motion polynomials
load([pathName,'pa_motion.mat']);

% get the centroids
load([pathName,'pa_state.mat'],'ppaTargetStarResultsStruct');


ra = [ppaTargetStarResultsStruct.raHours].*(360/24);
dec = [ppaTargetStarResultsStruct.decDegrees];
mod = median([inputStruct.module]);
out = median([inputStruct.output]);

rowPoly = [inputStruct.rowPoly];
colPoly = [inputStruct.colPoly];
validRowPoly = logical([inputStruct.rowPolyStatus]);
validColPoly = logical([inputStruct.colPolyStatus]);
rowPoly = rowPoly(validRowPoly);
colPoly = colPoly(validColPoly);

% COMMENT OUT FOR NOW - weighted_polyval2d ERRORS OUT WHEN TRYING TO RETURN COVARIANCE
%     [fittedRow, CfittedRow] = weighted_polyval2d(ra(:),dec(:),rowPoly(:));
%     [fittedCol, CfittedCol] = weighted_polyval2d(ra(:),dec(:),colPoly(:));

fittedRow = weighted_polyval2d(ra(:),dec(:),rowPoly(:));
fittedCol = weighted_polyval2d(ra(:),dec(:),colPoly(:));

[sortedRows, sortedRowIdx] = sort(fittedRow(:,1));
[sortedCols, sortedColIdx] = sort(fittedCol(:,1));

[nRowTargets, nRowFittedCadences] = size(fittedRow);
[nColTargets, nColFittedCadences] = size(fittedCol);


%     fwCentroids = [ppaTargetStarResultsStruct.fluxWeightedCentroids];
prfCentroids = [ppaTargetStarResultsStruct.prfCentroids];

%     fwR = [fwCentroids.rowTimeSeries];
%     fwC = [fwCentroids.columnTimeSeries];

%     fwRowVal = [fwR.values];
%     fwRowGap = [fwR.gapIndicators];
%     fwRowUnc = [fwR.uncertainties];
%     fwColVal = [fwC.values];
%     fwColGaps = [fwC.gapIndicators];
%     fwColUnc = [fwC.uncertainties];

prfR = [prfCentroids.rowTimeSeries];
prfC = [prfCentroids.columnTimeSeries];

prfRowVal = [prfR.values];
%     prfRowGap = [prfR.gapIndicators];
%     prfRowUnc = [prfR.uncertainties];
prfColVal = [prfC.values];
%     prfColGaps = [prfC.gapIndicators];
%     prfColUnc = [prfC.uncertainties];


rowResidual = prfRowVal(validRowPoly,:) - fittedRow';
colResidual = prfColVal(validColPoly,:) - fittedCol';

rowResidualMinusMedian = rowResidual - ones(nRowFittedCadences,1)*median(rowResidual);
colResidualMinusMedian = colResidual - ones(nColFittedCadences,1)*median(colResidual);

fittedRowMinusMedian = fittedRow' - ones(nRowFittedCadences,1)*median(fittedRow,2)';
fittedColMinusMedian = fittedCol' - ones(nColFittedCadences,1)*median(fittedCol,2)';

M.ccdModule = mod;
M.ccdOutput = out;
M.rowCadences = cadences(validRowPoly);
M.colCadences = cadences(validColPoly);
M.fittedRow = fittedRow';
M.fittedCol = fittedCol';
M.rowResidual = rowResidual;
M.colResidual = colResidual;


if(PLOTS_ON)

    figure(1);
    imagesc(sortedRows,cadences(validRowPoly),fittedRowMinusMedian(:,sortedRowIdx));
    colorbar;
    axis xy;
    xlabel('row');
    ylabel('cadence')
    title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Fitted Row - Median Removed']);
    set(gcf,'Position',P(1,:));

    figure(2);
    imagesc(sortedCols,cadences(validColPoly),fittedColMinusMedian(:,sortedColIdx));
    colorbar;
    axis xy;
    xlabel('column');
    ylabel('cadence')
    title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Fitted Column - Median Removed']);    
    set(gcf,'Position',P(2,:));

    figure(3);
    imagesc(sortedRows,cadences(validRowPoly),rowResidualMinusMedian(:,sortedRowIdx));
    colorbar;
    axis xy;
    xlabel('row');
    ylabel('cadence')
    title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Row Residual - Median Removed']);
    set(gcf,'Position',P(3,:));

    figure(4);
    imagesc(sortedCols,cadences(validColPoly),colResidualMinusMedian(:,sortedColIdx));
    colorbar;
    axis xy;
    xlabel('column');
    ylabel('cadence')
    title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Column Residual - Median Removed']);
    set(gcf,'Position',P(4,:));

    figure(5);
    mesh(sortedRows,cadences(validRowPoly),rowResidual(:,sortedRowIdx));
    colorbar;
    xlabel('row');
    ylabel('cadence')
    title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Row Residual']);
    set(gcf,'Position',P(5,:));

    figure(6);
    mesh(sortedCols,cadences(validColPoly),colResidual(:,sortedColIdx));
    colorbar;
    xlabel('column');
    ylabel('cadence')
    title(['Mod.Out ',num2str(mod),'.',num2str(out),' - Motion Polynomial Column Residual']);
    set(gcf,'Position',P(6,:));

    figure(7);
    plot(M.rowCadences,median(M.rowResidual,2),'o');
    grid;
    xlabel('cadence');
    ylabel('pixel');
    title(['Mod.Out ',num2str(M.ccdModule),'.',num2str(M.ccdOutput),' - Motion Polynomial Row Residual - Median Across Rows']);
    set(gcf,'Position',P(7,:));

    figure(8);
    plot(M.fittedRow(1,:),median(M.rowResidual,1),'o');
    grid;
    xlabel('row');
    ylabel('pixel');
    title(['Mod.Out ',num2str(M.ccdModule),'.',num2str(M.ccdOutput),' - Motion Polynomial Row Residual - Median Across Cadences']);
    set(gcf,'Position',P(8,:));

    figure(9);
    hist(median(M.rowResidual,1),51);
    grid;
    ylabel('number of targets');
    xlabel('pixel');
    title(['Mod.Out ',num2str(M.ccdModule),'.',num2str(M.ccdOutput),' - Motion Polynomial Row Residual - Median Across Cadences']);
    set(gcf,'Position',P(9,:));

    figure(10);
    plot(M.colCadences,median(M.colResidual,2),'o');
    grid;
    xlabel('cadence');
    ylabel('pixel');
    title(['Mod.Out ',num2str(M.ccdModule),'.',num2str(M.ccdOutput),' - Motion Polynomial Column Residual - Median Across Columns']);
    set(gcf,'Position',P(10,:));

    figure(11);
    plot(M.fittedCol(1,:),median(M.colResidual,1),'o');
    grid;
    xlabel('column');
    ylabel('pixel');
    title(['Mod.Out ',num2str(M.ccdModule),'.',num2str(M.ccdOutput),' - Motion Polynomial Column Residual - Median Across Cadences']);
    set(gcf,'Position',P(11,:));

    figure(12);
    hist(median(M.colResidual,1),51);
    grid;
    xlabel('pixel');
    ylabel('number of targets');
    title(['Mod.Out ',num2str(M.ccdModule),'.',num2str(M.ccdOutput),' - Motion Polynomial Column Residual - Median Across Cadences']);
    set(gcf,'Position',P(12,:));
    
end

drawnow();
