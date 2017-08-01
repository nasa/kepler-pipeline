function resultsStruct = compare_MP_to_raDec2Pix(paTaskFileDir, spiceFileDir, DISPLAY_PLOTS)
%
% function resultsStruct = compare_MP_to_raDec2Pix(paTaskFileDir, spiceFileDir)
% 
% Plot the difference between row/column positions as determined by raDec2Pix and determined by the motion polynomials.
% Overlay the median position of ppa targets over the unit of work.
% Red points == robust weight above robustWeightGappingThreshold so they participate in the fit.
% Black circles == robust weight below robustWeightGappingThreshold so they do not participate in the fit (robustWeight is set to zero).
%
% INPUTS:   paTaskFileDir   = path from you working directory to the PA task file directory containing PA inputs and outputs as weel as the
%                             PA state file
%           spiceFileDir    = path from your working directory to a directory containing the spice files
%                               naif0009.tls
%                               de421.bsp
%                               spk_(start-time-stamp)_(end-time-stamp)_kplr.bsp
%           DISPLAY_PLOTS   = boolean; true == display plots, false == don't display plots
% OUTPUTS:  resultsStruct   = structure containing the following fields:
%                             row   = structure containing the following fields:
%                                       index               = one-based row coordinate of mesh (nPoints x 1)
%                                       residual            = raDec2Pix estimate - mean motion polynomial estimate on mesh
%                                       modes               = first three most likely values of residual
%                                       madFromFirstMode    = median absolute deviation from value of primary mode
%                                       maxDevFromFirstMode = maximum absoltue deviation from value of first mode
%                                       binSize             = bin size used in histogram which gives modes
%                             col   = structure containing the following fields:
%                                       (same fields as under row)
%
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

% constants
DEGREES_PER_HOUR = 360/24;

% grid parameters
meshSize = 10;
maxRow = 1040; minRow = 30;
maxCol = 1110; minCol = 30;

% histogram binwidth (pixels)
binwidth = 0.001;
nModes = 3;

% build output struct
dimResult = struct('index',[],...
                    'residual',[],...
                    'modes',[],...
                    'madFromFirstMode',[],...
                    'maxDevFromFirstMode',[],...
                    'binSize',binwidth,...
                    'polyOrder',[]);
                
resultsStruct = struct('ccdModule',[],...
                        'ccdOutput',[],...
                        'row',dimResult,...
                        'col',dimResult);



% retrieve motion polynomials and ppa target centroids from task file
disp('Loading selected variables from pa_state.mat...');
load(fullfile(paTaskFileDir,'pa_state.mat'),'motionPolyStruct','ppaTargetStarResultsStruct');
validRowPoly = logical([motionPolyStruct.rowPolyStatus]);
validColPoly = logical([motionPolyStruct.colPolyStatus]);
rowPolyAll = [motionPolyStruct(validRowPoly).rowPoly];
colPolyAll = [motionPolyStruct(validColPoly).colPoly];
meanMjd = mean([motionPolyStruct(validRowPoly & validColPoly).mjdMidTime]);


% build mean row motion polynomial over unit of work
rowPoly = rowPolyAll(1);
rowPoly.coeffs = mean([rowPolyAll.coeffs],2);
A = zeros(length(rowPoly.coeffs),length(rowPoly.coeffs),length(rowPolyAll));
for iPoly = 1:length(rowPolyAll)
    A(:,:,iPoly) = rowPolyAll(iPoly).covariance;
end
rowPoly.covariance = mean(A,3);
clear A;

% build mean column motion polynomial over unit of work
colPoly = colPolyAll(1);
colPoly.coeffs = mean([colPolyAll.coeffs],2);
A = zeros(length(colPoly.coeffs),length(colPoly.coeffs),length(colPolyAll));
for iPoly = 1:length(colPolyAll)
    A(:,:,iPoly) = colPolyAll(iPoly).covariance;
end
colPoly.covariance = mean(A,3);
clear A;

% save polyorders for output
resultsStruct.row.polyOrder = rowPoly.order;
resultsStruct.col.polyOrder = colPoly.order;

% calculate median ppa target prf centroids over unit of work
prfCentroids = [ppaTargetStarResultsStruct.prfCentroids];
prfRow = [prfCentroids.rowTimeSeries];
prfRowVal = [prfRow.values];
prfRowGap = [prfRow.gapIndicators];
prfCol = [prfCentroids.columnTimeSeries];
prfColVal = [prfCol.values];
prfColGap = [prfCol.gapIndicators];

ppaRow = median(prfRowVal);
ppaCol = median(prfColVal);
ppaGap = all(prfRowGap) | all(prfColGap);

% extract PPA target ra and dec
ppaTargetRaDegrees = [ppaTargetStarResultsStruct.raHours].*DEGREES_PER_HOUR;
ppaTargetDecDegrees = [ppaTargetStarResultsStruct.decDegrees];

% retrieve raDec2PixModel from inputsStruct
disp('Loading inputsStruct from pa-inputs-0.mat...');
load(fullfile(paTaskFileDir,'st-0','pa-inputs-0.mat'));

% update inputs to 7.0 defaults
inputsStruct = pa_convert_62_data_to_70(inputsStruct);

raDec2PixModel = inputsStruct.raDec2PixModel;
raDec2PixModel.spiceFileDir = spiceFileDir;
raDec2PixObject = raDec2PixClass(raDec2PixModel,'one-based');

% retrieve mod/out
module = inputsStruct.ccdModule;
output = inputsStruct.ccdOutput;
resultsStruct.ccdModule = module;
resultsStruct.ccdOutput = output;
modOutString = ['module/output ',num2str(module),'/',num2str(output),' - '];


% build evenly spaced grid over mod out in pixel space
row = repmat((minRow:meshSize:maxRow)',numel(minCol:meshSize:maxCol),1);
col = repmat(minCol:meshSize:maxCol,numel(minRow:meshSize:maxRow),1); 
col = col(:);

% convert grid points from row/column to ra/dec space using radec2Pix
[ra dec] = pix_2_ra_dec(raDec2PixObject, module.*ones(size(row)), output.*ones(size(col)), row , col, meanMjd, 1);

% convert back to row/column using mean motion polynomial
fittedRow = weighted_polyval2d(ra,dec,rowPoly);
fittedCol = weighted_polyval2d(ra,dec,colPoly);

% find residuals over grid
rowResidual = row - fittedRow;
columnResidual = col - fittedCol;


% compute row residual histogram
[Nrow, Xrow] = hist(rowResidual,(max(rowResidual) - min(rowResidual))/binwidth);
[modeValues, modeIndices] = sort(Nrow,'descend');                                                                                                            %#ok<ASGLU>
modeRowResidual = colvec(Xrow(modeIndices(1:nModes)));
madFromModeRowResidual = median(abs(rowResidual - modeRowResidual(1)));
maximumAbsoluteDeltaFromModeRowResidual = max(abs(rowResidual - modeRowResidual(1)));

% populate row output
resultsStruct.row.index                 = row;
resultsStruct.row.residual              = rowResidual;
resultsStruct.row.modes                 = modeRowResidual;
resultsStruct.row.madFromFirstMode      = madFromModeRowResidual;
resultsStruct.row.maxDevFromFirstMode   = maximumAbsoluteDeltaFromModeRowResidual;

% compute column histogram
[Ncol, Xcol] = hist(columnResidual,(max(columnResidual) - min(columnResidual))/binwidth);
[modeValues, modeIndices] = sort(Ncol,'descend');                                                                                                            %#ok<ASGLU>
modeColumnResidual = colvec(Xcol(modeIndices(1:nModes)));
madFromModeColumnResidual = median(abs(columnResidual - modeColumnResidual(1)));
maximumAbsoluteDeltaFromModeColumnResidual = max(abs(columnResidual - modeColumnResidual(1)));

% populate column output
resultsStruct.col.index                 = col;
resultsStruct.col.residual              = columnResidual;
resultsStruct.col.modes                 = modeColumnResidual;
resultsStruct.col.madFromFirstMode      = madFromModeColumnResidual;
resultsStruct.col.maxDevFromFirstMode   = maximumAbsoluteDeltaFromModeColumnResidual;


if (DISPLAY_PLOTS)
    
    % load pa-dawg-motion results containg fit residuals
    load(fullfile(paTaskFileDir,'pa-dawg-motion.mat'));
    
    % load robust weights from state file
    load(fullfile(paTaskFileDir,'pa_state.mat'),'rowRobustWeightArray','columnRobustWeightArray');
    robustRowAvailable = true;
    robustColumnAvailable = true;
    
    % If running mpe_true PA data rowRobustWeightArray and columnRobustWeightArray will not be available since MP are fit during the
    % mpe_false run. Set these all to 1 and throw a warning message.
    if ~exist('rowRobustWeightArray', 'var')
        rowRobustWeightArray = ones(size(rowResidual));
        display('Variable rowRobustWeightArray not found in pa_state.mat. Setting all weights to 1.');
        robustRowAvailable = false;
    end
    if ~exist('columnRobustWeightArray', 'var')
        columnRobustWeightArray = ones(size(columnResidual));
        display('Variable columnRobustWeightArray not found in pa_state.mat. Setting all weights to 1.');
        robustColumnAvailable = false;
    end    
    
    % set robust weight flags
    robustThreshold = inputsStruct.motionConfigurationStruct.robustWeightGappingThreshold;
    ppaGreenRow = median(rowRobustWeightArray) > robustThreshold;
    ppaRedRow = median(rowRobustWeightArray) <= robustThreshold;
    ppaGreenCol = median(columnRobustWeightArray) > robustThreshold;
    ppaRedCol = median(columnRobustWeightArray) <= robustThreshold;
    
    % define mesh grid
    rowMesh = minRow:meshSize:maxRow;
    colMesh = minCol:meshSize:maxCol;
    
    
    % convert ppaTarget KIC ra and dec to pixels using raDec2Pix
    [returnedModule returnedOutput ppaRowRA ppaColRA] = ra_dec_2_pix(raDec2PixObject, ppaTargetRaDegrees, ppaTargetDecDegrees, meanMjd, 1);
    
    % convert ppaTarget KIC ra and dec to pixels using motion polynomials
    ppaRowMP = weighted_polyval2d(ppaTargetRaDegrees,ppaTargetDecDegrees,rowPoly);
    ppaColMP = weighted_polyval2d(ppaTargetRaDegrees,ppaTargetDecDegrees,colPoly);
    
    % build residual at ppa target locations
    ppaRowresidual = ppaRowRA - ppaRowMP;
    ppaColResidual = ppaColRA - ppaColMP;

    
    
    
    % display the residual (raDec2Pix - Motion Poly)
    
    % ROW
    
    figure(11);
    mesh(colMesh,rowMesh,reshape(rowResidual,numel(rowMesh),numel(colMesh)));
    colorbar;
    hold on;
    plot3(ppaColRA,ppaRowRA,ppaRowRA - ppaRowMP,'k.');
    hold off;
    title([modOutString,'ROW Residual (raDec2Pix - Motion Polynomial) (pixels)']);
    ylabel('one-based row (pixels)');
    xlabel('one-based column (pixels)');
    zlabel('\DeltaRow Coordinate (pixels)');
    
    figure(12);
    bar(Xrow, Nrow);
    title([modOutString,'ROW Residual Distribution (raDec2Pix - Motion Polynomial)']);
    ylabel('number of grid points');
    xlabel('pixels');
    
    figure(13);
    hist(ppaRowresidual, 21);
    title([modOutString,'ROW Residual Distribution (raDec2Pix - Motion Polynomial) PPA Targets Only']);
    ylabel('number of targets');
    xlabel('pixels');
    
    figure(14);
    imagesc(colMesh,rowMesh,reshape(row - fittedRow,numel(rowMesh),numel(colMesh)));
    axis xy
    colorbar;
    hold on;
    plot(ppaCol(ppaGreenRow & ~ppaGap),ppaRow(ppaGreenRow & ~ppaGap),'k.');
    plot(ppaCol(ppaRedRow & ~ppaGap),ppaRow(ppaRedRow & ~ppaGap),'ko');
    hold off;
    title([modOutString,'ROW Residual (raDec2Pix - Motion Polynomial) (pixels)']);
    ylabel('one-based row (pixels)');
    xlabel('one-based column (pixels)');
    
    if robustRowAvailable
        figure(15);
        plot(mean(motionOutputStruct.rowResidual) .* median(rowRobustWeightArray),'o');
        grid;
        xlabel('PPA Target Index');
        ylabel('pixels');
        title([modOutString,'Row Robust Fit Residual']);
    end
    
    figure(16);
    plot(mean(motionOutputStruct.rowResidual),'o');
    grid;
    xlabel('PPA Target Index');
    ylabel('pixels');
    title([modOutString,'Row Fit Residual']);
    
    
    % COLUMN
   
    figure(21);
    mesh(colMesh,rowMesh,reshape(columnResidual,numel(rowMesh),numel(colMesh)));
    colorbar;
    hold on;
    plot3(ppaColRA,ppaRowRA,ppaColRA - ppaColMP,'k.');
    hold off;
    title([modOutString,'COLUMN Residual (raDec2Pix - Motion Polynomial) (pixels)']);
    ylabel('one-based row (pixels)');
    xlabel('one-based column (pixels)');
    zlabel('\DeltaColumn Coordinate (pixels)');
    
    figure(22);
    bar(Xcol, Ncol);
    title([modOutString,'COLUMN Residual Distribution (raDec2Pix - Motion Polynomial)']);
    ylabel('number of grid points');
    xlabel('pixels');
    
    figure(23);
    hist(ppaColResidual, 21);
    title([modOutString,'COLUMN Residual Distribution (raDec2Pix - Motion Polynomial) PPA Targets Only']);
    ylabel('number of targets');
    xlabel('pixels');
    
    figure(24);
    imagesc(colMesh,rowMesh,reshape(col - fittedCol,numel(rowMesh),numel(colMesh)));
    axis xy
    colorbar;
    hold on;
    plot(ppaCol(ppaGreenCol & ~ppaGap),ppaRow(ppaGreenCol & ~ppaGap),'k.');
    plot(ppaCol(ppaRedCol & ~ppaGap),ppaRow(ppaRedCol & ~ppaGap),'ko');
    hold off;
    title([modOutString,'COLUMN Residual (raDec2Pix - Motion Polynomial) (pixels)']);
    ylabel('one-based row (pixels)');
    xlabel('one-based column (pixels)');
    
    if robustColumnAvailable
        figure(25);
        plot(mean(motionOutputStruct.colResidual) .* median(columnRobustWeightArray),'o');
        grid;
        xlabel('PPA Target Index');
        ylabel('pixels');
        title([modOutString,'Column Robust Fit Residual']);
    end
    
    figure(26);
    plot(mean(motionOutputStruct.colResidual),'o');
    grid;
    xlabel('PPA Target Index');
    ylabel('pixels');
    title([modOutString,'Column Fit Residual']);
    
    % display AIC polynomial order determination - This figure will not exist in mpe_true PA runs since MP are only fit on mpe_false runs
    if exist(fullfile(paTaskFileDir,'pa_motion_aic.fig'), 'file')
        open(fullfile(paTaskFileDir,'pa_motion_aic.fig'));
    end
end



  