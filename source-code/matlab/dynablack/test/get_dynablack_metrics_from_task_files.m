function [ dynablackMetrics ] = get_dynablack_metrics_from_task_files( rootPath, mapFile, varargin )
% function [ dynablackMetrics ] = get_dynablack_metrics_from_task_files( rootPath, mapFile, varargin )
%
% This dynablack utility function collects metrics on the dynablack fits in the task files located under rootPath. The metrics are returned
% in a struct array and summary plots are produced. The return struct is also saved in the current working directory as
% DYNABLACK_METRICS_FILENAME.
%
% INPUT:    rootPath            == full path to top level directory containing dynablack task files 
%                                  (e.g. rootPath = '/path/to/TEST/pipeline_results/photometry/lc/dynablack/ksop-1676-release-9.1-test-dynablack-q15-lc/';)
%           mapFile             == full filename of the *.csv file mapping module output to task directory name 
%                                  (e.g. mapFile = 'q15-dynablack-ksop1676-task-to-mod-out-map.csv';)
%           varargin{1}         == closeFigures; boolean; Close figures on exit.
% OUTPUT:   dynablackMetrics    == array of data structures containing dynablack residual metrics and rba (rolling band artifact) metrics.
%                                  There is one array entry for each task file directory. 
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


% check variable argument list
if nargin > 2
    closeFigures = logical(varargin{1});
else
    closeFigures = false;
end


% define constants
NUM_CCD_COLUMNS = 1132;
NUM_CCD_ROWS = 1070;
NUM_CHANNELS = 84;
MAX_RC_PIXELS = 150000;
MAX_SMEAR_REGIONS = floor(NUM_CCD_COLUMNS/100);

MEDIAN_ROW = floor(NUM_CCD_ROWS/2);
MEDIAN_COLUMN = floor(NUM_CCD_COLUMNS/2);
HALF_AXIS_FOCAL_PLANE_DISPLAY = 6500;
TITLE_FONT_SIZE = 12;

summaryMetricsFigures = {'dynablack_best_coeff_dashboard',...
                            'dynablack_std_black_regress_summary',...
                            'dynablack_rms_black_regress_summary',...
                            'dynablack_std_black_robust_summary',...
                            'dynablack_rms_black_robust_summary',...
                            'dynablack_std_smear_summary',...
                            'dynablack_rms_smear_summary',...
                            'dynablack_std_rc_summary',...
                            'dynablack_rms_rc_summary',...
                            'dynablack_rba_summary',...
                            'dynablack_scdep_summary_I',...
                            'dynablack_scdep_summary_II'};

DYNABLACK_METRICS_FILENAME = 'dynablack_metrics.mat';
DYNABLACK_BLOB_FILENAME = 'dynablack_blob.mat';
RBA_METRICS_FILENAME = 'dynablack_rba.mat';


% get list of task file dirs
% [~, D] = get_channels_from_taskfile_map([rootPath,mapFile], 'dynablack');
% D = mapFile;


% make some space for storage
metricsStruct = struct('module',[],...
                        'output',[],...
                        'channel',[],...
                        'fullpath',[],...
                        'validFit',[],...
                        'resultsAvailable',[],...
                        'bestCoeffs',[],...                        
                        'collatRows',[],...
                        'dynablackModuleParameters',[],...
                        'regressDnPerRead',struct('rmsResidA1',[],...
                                            'stdResidA1',[],...
                                            'rmsResidA2Lc',[],...
                                            'stdResidA2Lc',[],...
                                            'rmsResidA2Rc',[],...
                                            'stdResidA2Rc',[]),...
                        'robustDnPerRead',struct('rmsResidA1',[],...
                                            'stdResidA1',[]),...
                        'rbaMetricsAvailable',[],...
                        'rbaMetrics',[],...
                        'sceneDependentMetrics',[]);

dynablackMetrics = repmat(metricsStruct,length(mapFile),1);


% loop through the task file dirs
for iDir = 1: length(mapFile)
    
    disp(['Doing ',mapFile(iDir).taskFileFullPath,' ...']);
    
    % read dynablack residual data
    load([mapFile(iDir).taskFileFullPath,DYNABLACK_BLOB_FILENAME]);
    
    % write meta data for channel
    dynablackMetrics(iDir).module = inputStruct.ccdModule;
    dynablackMetrics(iDir).output = inputStruct.ccdOutput;
    dynablackMetrics(iDir).channel = convert_from_module_output(inputStruct.ccdModule, inputStruct.ccdOutput);
    dynablackMetrics(iDir).fullpath = mapFile(iDir).taskFileFullPath;
    dynablackMetrics(iDir).validFit = inputStruct.validDynablackFit;
    dynablackMetrics(iDir).bestCoeffs = inputStruct.bestCoefficients;    

    % process residuals if dynablack results exist
    if ~isempty(inputStruct.A1ModelDump.ROI)        
        % extract data
        a1ResidRobust = inputStruct.A1_fit_residInfo.LC.fitpix_xLC.robust_resid;
        a1ResidRegress = inputStruct.A1_fit_residInfo.LC.fitpix_xLC.regress_resid;
        collatRows = inputStruct.A1ModelDump.ROI.trailingCollat.Rows;
        nCollatRows = length(collatRows);
        a2ResidLc = inputStruct.A2_fit_residInfo.smearResiduals_xLC;
        a2ResidRc = inputStruct.A2_fit_residInfo.residuals_xRC;
        readsPerLongCadence = inputStruct.A2ModelDump.Constants.readsPerLongCadence;
        dynablackModuleParameters = inputStruct.dynablackModuleParameters;
        
        % calculate regression metrics
        a1RegressRms = sqrt(nanmean(a1ResidRegress(:,end - nCollatRows + 1:end).^2));
        [~, s] = columnwise_robust_mean_std(a1ResidRegress(:,end - nCollatRows + 1:end));
        a2RegressRmsLc = sqrt(nanmean(a2ResidLc.^2));
        [~, sLc] = columnwise_robust_mean_std(a2ResidLc);
        a2RegressRmsRc = sqrt(nanmean(a2ResidRc.^2));
        [~, sRc] = columnwise_robust_mean_std(a2ResidRc);
        
        % calculate robust metrics
        a1RobustRms = sqrt(nanmean(a1ResidRobust(:,end - nCollatRows + 1:end).^2));
        [~, sr] = columnwise_robust_mean_std(a1ResidRobust(:,end-nCollatRows+1:end));
        
        % write output
        dynablackMetrics(iDir).collatRows = collatRows;
        dynablackMetrics(iDir).regressDnPerRead.rmsResidA1   = a1RegressRms'./readsPerLongCadence;
        dynablackMetrics(iDir).regressDnPerRead.stdResidA1   = s'./readsPerLongCadence;
        dynablackMetrics(iDir).regressDnPerRead.rmsResidA2Lc = a2RegressRmsLc'./readsPerLongCadence;
        dynablackMetrics(iDir).regressDnPerRead.stdResidA2Lc = sLc'./readsPerLongCadence;
        dynablackMetrics(iDir).regressDnPerRead.rmsResidA2Rc = a2RegressRmsRc'./readsPerLongCadence;
        dynablackMetrics(iDir).regressDnPerRead.stdResidA2Rc = sRc'./readsPerLongCadence;
        dynablackMetrics(iDir).robustDnPerRead.rmsResidA1 = a1RobustRms'./readsPerLongCadence;
        dynablackMetrics(iDir).robustDnPerRead.stdResidA1 = sr'./readsPerLongCadence;
        dynablackMetrics(iDir).dynablackModuleParameters  = dynablackModuleParameters;
        dynablackMetrics(iDir).resultsAvailable = true;
    else
        dynablackMetrics(iDir).resultsAvailable = false;
    end
    
    % process RBA metrics if rba file exists
    if exist([mapFile(iDir).taskFileFullPath,RBA_METRICS_FILENAME],'file')
        % read rba metrics data
        load([mapFile(iDir).taskFileFullPath,RBA_METRICS_FILENAME]);
        
        % write meta data for channel
        dynablackMetrics(iDir).rbaMetrics = inputStruct.RBA;
        dynablackMetrics(iDir).sceneDependentMetrics = inputStruct.SceneDep;
        
        % make all field vectors columns
        names = fieldnames(dynablackMetrics(iDir).rbaMetrics);
        for iName = 1:length(names)
            dynablackMetrics(iDir).rbaMetrics.(names{iName}) = dynablackMetrics(iDir).rbaMetrics.(names{iName})(:);
        end
        names = fieldnames(dynablackMetrics(iDir).sceneDependentMetrics);
        for iName = 1:length(names)
            dynablackMetrics(iDir).sceneDependentMetrics.(names{iName}) = dynablackMetrics(iDir).sceneDependentMetrics.(names{iName})(:);
        end
        dynablackMetrics(iDir).rbaMetricsAvailable = true;
    else
        dynablackMetrics(iDir).rbaMetricsAvailable = false;
    end   
end
    

% save the output
save(DYNABLACK_METRICS_FILENAME, 'dynablackMetrics');

    
% unpack some data for plots
mod = [dynablackMetrics.module];
out = [dynablackMetrics.output];
channel = [dynablackMetrics.channel];

resultsAvailable = [dynablackMetrics.resultsAvailable];
rbaMetricsAvailable = [dynablackMetrics.rbaMetricsAvailable];

mod = mod(resultsAvailable & rbaMetricsAvailable);
out = out(resultsAvailable & rbaMetricsAvailable);
channel = channel(resultsAvailable & rbaMetricsAvailable);


% rolling band metrics
rbaMetrics = [dynablackMetrics.rbaMetrics];
rbaFractionFlags    = [rbaMetrics.fractionFlags];
rbaMeanSeverity     = [rbaMetrics.meanSeverity];
% rbaNumFlags         = [rbaMetrics.numFlags];
% rbaRowList          = [rbaMetrics.rowList];
% rbaRelCadenceList   = [rbaMetrics.relCadenceList];

% scene dependent metrics
sceneDependentMetrics = [dynablackMetrics.sceneDependentMetrics];
scdepFractionRows   = [sceneDependentMetrics.fractionRows];
scdepFractionRBAFlags = [sceneDependentMetrics.fractionRBAFlags];
scdepMeanRBASeverity = [sceneDependentMetrics.meanRBASeverity];
scdepMeanNoRBASeverity = [sceneDependentMetrics.meanNoRBASeverity];
% scdepNumRows        = [sceneDependentMetrics.numRows];
% scdepRowList        = [sceneDependentMetrics.rowList];
% scdepNumRBAflags    = [sceneDependentMetrics.numRBAflags];


% A1 fit residuals
regressResid = [dynablackMetrics.regressDnPerRead];
rmsResidA1Regress = [regressResid.rmsResidA1];
stdResidA1Regress = [regressResid.stdResidA1];

robustResid = [dynablackMetrics.robustDnPerRead];
rmsResidA1Robust = [robustResid.rmsResidA1];
stdResidA1Robust = [robustResid.stdResidA1];

% these rows should never change but take median just in case - could take dynablackMetrics(1).collatRows
collateralRows = median([dynablackMetrics.collatRows],2);

% set caxis limits on black residual images to the threshold values
mp = [dynablackMetrics.dynablackModuleParameters];
blackResidualsThresholdDnPerRead = max([mp.blackResidualsThresholdDnPerRead]);
blackResidualsStdDevThresholdDnPerRead = max([mp.blackResidualsStdDevThresholdDnPerRead]);


% allocate A2 rms and std storage
rmsResidA2Lc = nan(NUM_CHANNELS,MAX_SMEAR_REGIONS);
rmsResidA2Rc = nan(NUM_CHANNELS,MAX_RC_PIXELS);
stdResidA2Lc = nan(NUM_CHANNELS,MAX_SMEAR_REGIONS);
stdResidA2Rc = nan(NUM_CHANNELS,MAX_RC_PIXELS);

numSmearRegions = 0;
numRcPixels = 0;

% A2 fit residuals may not be all the same shape
for i = 1:length(channel)
    ch = channel(i);
    
    nSmearRegions = length(regressResid(i).rmsResidA2Lc);
    nRcPixels = length(regressResid(i).rmsResidA2Rc);
    
    rmsResidA2Lc(ch,1:nSmearRegions) = regressResid(i).rmsResidA2Lc;
    rmsResidA2Rc(ch,1:nRcPixels) = regressResid(i).rmsResidA2Rc;
    stdResidA2Lc(ch,1:nSmearRegions) = regressResid(i).stdResidA2Lc;
    stdResidA2Rc(ch,1:nRcPixels) = regressResid(i).stdResidA2Rc;
    
    if nSmearRegions > numSmearRegions
        numSmearRegions = nSmearRegions;
    end
    if nRcPixels > numRcPixels
        numRcPixels = nRcPixels;
    end    
end

% trim to largest number of columns
rmsResidA2Lc = rmsResidA2Lc(1:NUM_CHANNELS,1:numSmearRegions);
rmsResidA2Rc = rmsResidA2Rc(1:NUM_CHANNELS,1:numRcPixels);
stdResidA2Lc = stdResidA2Lc(1:NUM_CHANNELS,1:numSmearRegions);
stdResidA2Rc = stdResidA2Rc(1:NUM_CHANNELS,1:numRcPixels);


% ------------------ PRODUCE SUMMARY FIGURES


% produce dashboard chart of dynablack A1 fit coefficient type used
iFig = 1;
f(iFig) = figure;
pad_draw_ccd(1:NUM_CHANNELS/2);
axis(HALF_AXIS_FOCAL_PLANE_DISPLAY.*[-1 1 -1 1]);

reg = false(size(channel));
rob = false(size(channel));
for i=1:length(channel)
    if strcmp(dynablackMetrics(i).bestCoeffs,'regress')
        reg(i) = true;
    end
    if strcmp(dynablackMetrics(i).bestCoeffs,'robust')
        rob(i) = true;
    end
end
colour_my_mod_out( mod(reg), out(reg), 'g' );
colour_my_mod_out( mod(rob), out(rob), 'c' );
colour_my_mod_out( mod(~rob & ~reg), out(~rob & ~reg), 'w' );

% add channel numbers - get x and y cordinates for approximate center of each mod out
[x,y] = morc_to_focal_plane_coords( mod(:), out(:), MEDIAN_ROW.*ones(size(mod(:))), MEDIAN_COLUMN.*ones(size(mod(:))), 'one-based' );
for iChannel = 1:length(channel)
    text(x(iChannel),y(iChannel),num2str(channel(iChannel)));
end
title({['\bf\fontsize{',num2str(TITLE_FONT_SIZE),'}Dynablack Best Coefficient Type'],'CYAN == Robust, GREEN == Regress, WHITE == invalid fit'});
saveas(f(iFig),summaryMetricsFigures{iFig},'fig');
saveas(f(iFig),summaryMetricsFigures{iFig},'jpg');



% produce rms and std images for A1 fits

% make some temp image space
imageSpace = nan(NUM_CCD_ROWS, NUM_CHANNELS);

iFig = 2;
f(iFig) = figure;
temp = imageSpace;
temp(collateralRows,channel) = stdResidA1Regress;
imagesc(temp);
axis xy;
caxis([0 blackResidualsStdDevThresholdDnPerRead]);
colorbar;
colormap hot;
title({'DYNABLACK',['\bf\fontsize{',num2str(TITLE_FONT_SIZE),'}STD black residuals - regress fit (ADU/read)']});
xlabel('Channel');
ylabel('CCD row');
saveas(f(iFig),summaryMetricsFigures{iFig},'fig');
saveas(f(iFig),summaryMetricsFigures{iFig},'jpg');

iFig = 3;
f(iFig) = figure;
temp = imageSpace;
temp(collateralRows,channel) = rmsResidA1Regress;
imagesc(temp);
axis xy;
caxis([0 blackResidualsThresholdDnPerRead]);
colorbar;
colormap hot;
title({'DYNABLACK',['\bf\fontsize{',num2str(TITLE_FONT_SIZE),'}RMS black residuals - regress fit (ADU/read)']});
xlabel('Channel');
ylabel('CCD row');
saveas(f(iFig),summaryMetricsFigures{iFig},'fig');
saveas(f(iFig),summaryMetricsFigures{iFig},'jpg');

iFig = 4;
f(iFig) = figure;
temp = imageSpace;
temp(collateralRows,channel) = stdResidA1Robust;
imagesc(temp);
axis xy;
caxis([0 blackResidualsStdDevThresholdDnPerRead]);
colorbar;
colormap hot;
title({'DYNABLACK',['\bf\fontsize{',num2str(TITLE_FONT_SIZE),'}STD black residuals - robust fit (ADU/read)']});
xlabel('Channel');
ylabel('CCD row');
saveas(f(iFig),summaryMetricsFigures{iFig},'fig');
saveas(f(iFig),summaryMetricsFigures{iFig},'jpg');

iFig = 5;
f(iFig) = figure;
temp = imageSpace;
temp(collateralRows,channel) = rmsResidA1Robust;
imagesc(temp);
axis xy;
caxis([0 blackResidualsThresholdDnPerRead]);
colorbar;
colormap hot;
title({'DYNABLACK',['\bf\fontsize{',num2str(TITLE_FONT_SIZE),'}RMS black residuals - robust fit (ADU/read)']});
xlabel('Channel');
ylabel('CCD row');
saveas(f(iFig),summaryMetricsFigures{iFig},'fig');
saveas(f(iFig),summaryMetricsFigures{iFig},'jpg');


% produce rms and std images for A2 fits

iFig = 6;
f(iFig) = figure;
imagesc(rmsResidA2Lc');
axis xy;
caxis(prctile(rmsResidA2Lc(:),[2 98]));
colorbar;
title({'DYNABLACK',['\bf\fontsize{',num2str(TITLE_FONT_SIZE),'}RMS smear residuals (ADU/read)']});
xlabel('Channel');
ylabel('100 column smear region');
saveas(f(iFig),summaryMetricsFigures{iFig},'fig');
saveas(f(iFig),summaryMetricsFigures{iFig},'jpg');

iFig = 7;
f(iFig) = figure;
imagesc(stdResidA2Lc');
axis xy;
caxis(prctile(stdResidA2Lc(:),[2 98]));
colorbar;
title({'DYNABLACK',['\bf\fontsize{',num2str(TITLE_FONT_SIZE),'}STD smear residuals (ADU/read)']});
xlabel('Channel');
ylabel('100 column smear region');
saveas(f(iFig),summaryMetricsFigures{iFig},'fig');
saveas(f(iFig),summaryMetricsFigures{iFig},'jpg');

iFig = 8;
f(iFig) = figure;
imagesc(rmsResidA2Rc');
axis xy;
caxis(prctile(rmsResidA2Rc(:),[2 98]));
colorbar;
title({'DYNABLACK',['\bf\fontsize{',num2str(TITLE_FONT_SIZE),'}RMS RC pixel residuals (ADU/read)']});
xlabel('Channel');
ylabel('pixel index');
saveas(f(iFig),summaryMetricsFigures{iFig},'fig');
saveas(f(iFig),summaryMetricsFigures{iFig},'jpg');

iFig = 9;
f(iFig) = figure;
imagesc(stdResidA2Rc');
axis xy;
caxis(prctile(stdResidA2Rc(:),[2 98]));
colorbar;
title({'DYNABLACK',['\bf\fontsize{',num2str(TITLE_FONT_SIZE),'}STD RC pixel residuals (ADU/read)']});
xlabel('Channel');
ylabel('pixel index');
saveas(f(iFig),summaryMetricsFigures{iFig},'fig');
saveas(f(iFig),summaryMetricsFigures{iFig},'jpg');


% produce summary plot of RBA metrics /scene dependent metrics
iFig = 10;
f(iFig) = figure;
subplot(2,1,1);
plot(channel,rbaFractionFlags,'o');
grid;
ylabel('fraction data flagged');
title({'DYNABLACK',['\bf\fontsize{',num2str(TITLE_FONT_SIZE),'}Rolling Band Flags']});
subplot(2,1,2);
plot(channel,rbaMeanSeverity,'o');
grid;
ylabel('mean severity');
xlabel('channel');
saveas(f(iFig),summaryMetricsFigures{iFig},'fig');
saveas(f(iFig),summaryMetricsFigures{iFig},'jpg');

% produce summary plots of scene dependent metrics
iFig = 11;
f(iFig) = figure;
subplot(2,1,1);
plot(channel,scdepFractionRows,'o');
grid;
ylabel('fraction rows flagged');
title({'DYNABLACK',['\bf\fontsize{',num2str(TITLE_FONT_SIZE),'}Scene Dependent Flags I']});
subplot(2,1,2);
plot(channel,scdepFractionRBAFlags,'o');
grid;
ylabel('fraction w/rba');
xlabel('channel');
saveas(f(iFig),summaryMetricsFigures{iFig},'fig');
saveas(f(iFig),summaryMetricsFigures{iFig},'jpg');

iFig = 12;
f(iFig) = figure;
subplot(2,1,1);
plot(channel,scdepMeanRBASeverity,'o');
grid;
ylabel('mean RBA severity');
title({'DYNABLACK',['\bf\fontsize{',num2str(TITLE_FONT_SIZE),'}Scene Dependent Flags II']});
subplot(2,1,2);
plot(channel,scdepMeanNoRBASeverity,'o');
grid;
ylabel('mean no RBA severity');
xlabel('channel');
saveas(f(iFig),summaryMetricsFigures{iFig},'fig');
saveas(f(iFig),summaryMetricsFigures{iFig},'jpg');


% close figures
if closeFigures
    for iFig = 1:length(f)
        close(f(iFig));
    end
end

