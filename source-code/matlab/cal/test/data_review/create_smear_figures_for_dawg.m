function create_smear_figures_for_dawg(quarterString, monthString, cadenceTypeString, ...
    figurePath, dawgFigureFlag)
%
% function to create figures for median and std of black-corrected masked
% smear, virtual smear, and the difference between the masked and virtual
% to vet flight or simulated data across the focal plane.  Matlab
% .fig figures are saved to files in the figurePath
%
%
%  See start_Q*_cal_data_review for input definitions.
%
%
% if createImageFlag, the following are created with the imagesc command:
%
%
%    [quarter]_[month]_[cadenceType]_med_msmear_per_col_per_channel
%    [quarter]_[month]_[cadenceType]_std_msmear_per_col_per_channel
%
%    [quarter]_[month]_[cadenceType]_med_msmear_per_cad_per_channel
%    [quarter]_[month]_[cadenceType]_std_msmear_per_cad_per_channel
%
%    [quarter]_[month]_[cadenceType]_med_vsmear_per_col_per_channel
%    [quarter]_[month]_[cadenceType]_std_vsmear_per_col_per_channel
%
%    [quarter]_[month]_[cadenceType]_med_vsmear_per_cad_per_channel
%    [quarter]_[month]_[cadenceType]_std_vsmear_per_cad_per_channel
%
%    [quarter]_[month]_[cadenceType]_med_smeardiff_per_col_per_channel
%    [quarter]_[month]_[cadenceType]_std_smeardiff_per_col_per_channel
%
%    [quarter]_[month]_[cadenceType]_med_smeardiff_per_cad_per_channel
%    [quarter]_[month]_[cadenceType]_std_smeardiff_per_cad_per_channel
%
%
%
% if createPlotFlag, the following are created with the plot command
%
%
%    [quarter]_[month]_[cadenceType]_med_msmear_per_col_per_channel_plot
%    [quarter]_[month]_[cadenceType]_std_msmear_per_col_per_channel_plot
%
%    [quarter]_[month]_[cadenceType]_med_msmear_per_cad_per_channel_plot
%    [quarter]_[month]_[cadenceType]_std_msmear_per_cad_per_channel_plot
%
%    [quarter]_[month]_[cadenceType]_med_vsmear_per_col_per_channel_plot
%    [quarter]_[month]_[cadenceType]_std_vsmear_per_col_per_channel_plot
%
%    [quarter]_[month]_[cadenceType]_med_vsmear_per_cad_per_channel_plot
%    [quarter]_[month]_[cadenceType]_std_vsmear_per_cad_per_channel_plot
%
%    [quarter]_[month]_[cadenceType]_med_smeardiff_per_col_per_channel_plot
%    [quarter]_[month]_[cadenceType]_std_smeardiff_per_col_per_channel_plot
%
%    [quarter]_[month]_[cadenceType]_med_smeardiff_per_cad_per_channel_plot
%    [quarter]_[month]_[cadenceType]_std_smeardiff_per_cad_per_channel_plot
%
%
%--------------------------------------------------------------------------
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

allChannelsArray = 1:84;

dataPath  = [figurePath 'collateral_data/'];
eval(['load ' dataPath, 'medStdSmearArrays.mat'])

figurePath  = [figurePath 'smear_figures/'];
mkdir(figurePath)


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% generate figures showing only available mod/outs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% rename (shorten) strings for titles/filenames
if strcmpi(cadenceTypeString, 'long')
    cadenceTypeString = 'LC';
elseif  strcmpi(cadenceTypeString, 'short')
    cadenceTypeString = 'SC';
end



%--------------------------------------------------------------------------
% Masked Smear Med Per Col: Available Pixels
%--------------------------------------------------------------------------
h1 = figure;
imagesc(medMsmearAcrossTime') %#ok<NODEF>
caxis([prctile(medMsmearAcrossTime(:), 5) prctile(medMsmearAcrossTime(:), 95)]);
apply_white_nan_colormap_to_image();
xlabel(' CCD Channel ', 'fontsize', 14)
ylabel(' CCD Col Index ', 'fontsize', 14)
colorbar
title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' masked smear pixels per col per channel'], 'fontsize', 14)

set(gca, 'XTick', 1:length(allChannelsArray))
set(gca, 'XTicklabel', allChannelsArray)

set(h1, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', 13);

fileNameStr = [figurePath, lower(cadenceTypeString) '_med_msmear_per_col_per_channel'];
plot_cal_figs_to_file(fileNameStr);


if ~dawgFigureFlag
    %----------------------------------------------------------------------
    % Masked Smear Std Per Col: Available Pixels
    %----------------------------------------------------------------------
    h2 = figure;
    imagesc(stdMsmearAcrossTime') %#ok<NODEF>
    caxis([prctile(stdMsmearAcrossTime(:), 5) prctile(stdMsmearAcrossTime(:), 95)]);
    apply_white_nan_colormap_to_image();
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' CCD Col Index ', 'fontsize', 14)
    colorbar
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' masked smear pixels per col per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h2, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_msmear_per_col_per_channel'];
    plot_cal_figs_to_file(fileNameStr);
end


%--------------------------------------------------------------------------
% Virtual Smear Med Per Col: Available Pixels
%--------------------------------------------------------------------------
h3 = figure;
imagesc(medVsmearAcrossTime') %#ok<NODEF>
caxis([prctile(medVsmearAcrossTime(:), 5) prctile(medVsmearAcrossTime(:), 95)]);
apply_white_nan_colormap_to_image();
xlabel(' CCD Channel ', 'fontsize', 14)
ylabel(' CCD Col Index ', 'fontsize', 14)
colorbar
title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' virtual smear pixels per col per channel'], 'fontsize', 14)

set(gca, 'XTick', 1:length(allChannelsArray))
set(gca, 'XTicklabel', allChannelsArray)

set(h3, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', 13);

fileNameStr = [figurePath, lower(cadenceTypeString) '_med_vsmear_per_col_per_channel'];
plot_cal_figs_to_file(fileNameStr);


if ~dawgFigureFlag
    %----------------------------------------------------------------------
    % Virtual Smear Std Per Col: Available Pixels
    %----------------------------------------------------------------------
    h4 = figure;
    imagesc(stdVsmearAcrossTime') %#ok<NODEF>
    caxis([prctile(stdVsmearAcrossTime(:), 5) prctile(stdVsmearAcrossTime(:), 95)]);
    apply_white_nan_colormap_to_image();
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' CCD Col Index ', 'fontsize', 14)
    colorbar
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' virtual smear pixels per col per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h4, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_vsmear_per_col_per_channel'];
    plot_cal_figs_to_file(fileNameStr);
end


%--------------------------------------------------------------------------
% Smear Diff Med Per Col: Available Pixels
%--------------------------------------------------------------------------
h5 = figure;
imagesc(medSmearDiffAcrossTime') %#ok<NODEF>
caxis([prctile(medSmearDiffAcrossTime(:), 5) prctile(medSmearDiffAcrossTime(:), 95)]);
apply_white_nan_colormap_to_image();
xlabel(' CCD Channel ', 'fontsize', 14)
ylabel(' CCD Col Index ', 'fontsize', 14)
colorbar
title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' masked-virtual smear diff per col per channel'], 'fontsize', 14)

set(gca, 'XTick', 1:length(allChannelsArray))
set(gca, 'XTicklabel', allChannelsArray)

set(h5, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', 13);

fileNameStr = [figurePath, lower(cadenceTypeString) '_med_smeardiff_per_col_per_channel'];
plot_cal_figs_to_file(fileNameStr);


if ~dawgFigureFlag
    %--------------------------------------------------------------------------
    % Smear Diff Std Per Col: Available Pixels
    %--------------------------------------------------------------------------
    
    h6 = figure;
    imagesc(stdSmearDiffAcrossTime') %#ok<NODEF>
    caxis([prctile(stdSmearDiffAcrossTime(:), 5) prctile(stdSmearDiffAcrossTime(:), 95)]);
    apply_white_nan_colormap_to_image();
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' CCD Col Index ', 'fontsize', 14)
    colorbar
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' masked-virtual smear diff per col per channel'], 'fontsize', 14)
    
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h6, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_smeardiff_per_col_per_channel'];
    plot_cal_figs_to_file(fileNameStr);
end


%--------------------------------------------------------------------------
% Masked Smear Med and Std Per Cadence
%--------------------------------------------------------------------------
h7 = figure;
imagesc(medMsmearAcrossCols') %#ok<NODEF>
caxis([prctile(medMsmearAcrossCols(:), 5) prctile(medMsmearAcrossCols(:), 95)]);
apply_white_nan_colormap_to_image();
xlabel(' CCD Channel ', 'fontsize', 14)
ylabel(' Cadence Index ', 'fontsize', 14)
colorbar
title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' masked smear pixels per cadence per channel'], 'fontsize', 14)

set(gca, 'XTick', 1:length(allChannelsArray))
set(gca, 'XTicklabel', allChannelsArray)

set(h7, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', 13);

fileNameStr = [figurePath, lower(cadenceTypeString) '_med_msmear_per_cad_per_channel'];
plot_cal_figs_to_file(fileNameStr);


if ~dawgFigureFlag
    h8 = figure;
    imagesc(stdMsmearAcrossCols') %#ok<NODEF>
    caxis([prctile(stdMsmearAcrossCols(:), 5) prctile(stdMsmearAcrossCols(:), 95)]);
    apply_white_nan_colormap_to_image();
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Cadence Index ', 'fontsize', 14)
    colorbar
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' masked smear pixels per cadence per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h8, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_msmear_per_cad_per_channel'];
    plot_cal_figs_to_file(fileNameStr);
end


%--------------------------------------------------------------------------
% Virtual Smear Med and Std Per Cadence
%--------------------------------------------------------------------------

h9 = figure;
imagesc(medVsmearAcrossCols') %#ok<NODEF>
caxis([prctile(medVsmearAcrossCols(:), 5) prctile(medVsmearAcrossCols(:), 95)]);
apply_white_nan_colormap_to_image();
xlabel(' CCD Channel ', 'fontsize', 14)
ylabel(' Cadence Index ', 'fontsize', 14)
colorbar
title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' virtual smear pixels per cadence per channel'], 'fontsize', 14)

set(gca, 'XTick', 1:length(allChannelsArray))
set(gca, 'XTicklabel', allChannelsArray)

set(h9, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', 13);

fileNameStr = [figurePath, lower(cadenceTypeString) '_med_vsmear_per_cad_per_channel'];
plot_cal_figs_to_file(fileNameStr);



if ~dawgFigureFlag
    h10 = figure;
    imagesc(stdVsmearAcrossCols') %#ok<NODEF>
    caxis([prctile(stdVsmearAcrossCols(:), 5) prctile(stdVsmearAcrossCols(:), 95)]);
    apply_white_nan_colormap_to_image();
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Cadence Index ', 'fontsize', 14)
    colorbar
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' virtual smear pixels per cadence per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h10, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_vsmear_per_cad_per_channel'];
    plot_cal_figs_to_file(fileNameStr);
end


%--------------------------------------------------------------------------
% Smear Diff Med and Std Per Cadence
%--------------------------------------------------------------------------
h11 = figure;
imagesc(medSmearDiffAcrossCols') %#ok<NODEF>
caxis([prctile(medSmearDiffAcrossCols(:), 5) prctile(medSmearDiffAcrossCols(:), 95)]);
apply_white_nan_colormap_to_image();
xlabel(' CCD Channel ', 'fontsize', 14)
ylabel(' Cadence Index ', 'fontsize', 14)
colorbar
title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' masked-virtual smear diff per cadence per channel'], 'fontsize', 14)

set(gca, 'XTick', 1:length(allChannelsArray))
set(gca, 'XTicklabel', allChannelsArray)

set(h11, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', 13);

fileNameStr = [figurePath, lower(cadenceTypeString) '_med_smeardiff_per_cad_per_channel'];
plot_cal_figs_to_file(fileNameStr);


if ~dawgFigureFlag
    h12 = figure;
    imagesc(stdSmearDiffAcrossCols') %#ok<NODEF>
    caxis([prctile(stdSmearDiffAcrossCols(:), 5) prctile(stdSmearDiffAcrossCols(:), 95)]);
    apply_white_nan_colormap_to_image();
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Cadence Index ', 'fontsize', 14)
    colorbar
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' masked-virtual smear diff per cadence per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h12, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_smeardiff_per_cad_per_channel'];
    plot_cal_figs_to_file(fileNameStr);
end



if ~dawgFigureFlag
    
    %--------------------------------------------------------------------------
    % generate figures of median/std across time for masked smear pixels on
    % available mod/outs using plot
    %--------------------------------------------------------------------------
    
    h13 = figure;
    plot(medMsmearAcrossTime)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Median of masked smear pixels (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' masked smear pixels per col per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h13, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_med_msmear_per_col_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
    
    
    h14 = figure;
    plot(stdMsmearAcrossTime)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Std of masked smear pixels (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' masked smear pixels per col per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h14, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_msmear_per_col_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
    
    
    
    %--------------------------------------------------------------------------
    % generate figures of median/std across time for virtual smear pixels on
    % available mod/outs using plot
    %--------------------------------------------------------------------------
    
    h15 = figure;
    plot(medVsmearAcrossTime)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Median of virtual smear pixels (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' virtual smear pixels per col per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h15, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_med_vsmear_per_col_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
    
    
    h16 = figure;
    plot(stdVsmearAcrossTime)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Std of virtual smear pixels (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' virtual smear pixels per col per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h16, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_vsmear_per_col_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
    
    
    %--------------------------------------------------------------------------
    % generate figures of median/std across time for smear diff on available
    % mod/outs using plot
    %--------------------------------------------------------------------------
    
    h17 = figure;
    plot(medSmearDiffAcrossTime)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Median of (masked-virtual) smear pixels (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' masked-virtual smear diff per col per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h17, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_med_smeardiff_per_col_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
    
    
    h18 = figure;
    plot(stdSmearDiffAcrossTime)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Std of (masked-virtual) smear pixels (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' masked-virtual smear diff per col per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h18, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_smeardiff_per_col_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
    
    
    %--------------------------------------------------------------------------
    % generate figures of median/std across cols for masked smear pixels on
    % available mod/outs using plot
    %--------------------------------------------------------------------------
    
    h19 = figure;
    plot(medMsmearAcrossCols)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Median of masked smear pixels (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' masked smear pixels per cadence per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h19, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_med_msmear_per_cad_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
    
    
    h20 = figure;
    plot(stdMsmearAcrossCols)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Std of masked smear pixels (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' masked smear pixels per cadence per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h20, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_msmear_per_cad_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
    
    
    
    %--------------------------------------------------------------------------
    % generate figures of median/std across cols for virtual smear pixels on
    % available mod/outs using plot
    %--------------------------------------------------------------------------
    
    h21 = figure;
    plot(medVsmearAcrossCols)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Median of virtual smear pixels (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' virtual smear pixels per cadence per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h21, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_med_vsmear_per_cad_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
    
    
    h22 = figure;
    plot(stdVsmearAcrossCols)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Std of virtual smear pixels (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' virtual smear pixels per cadence per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h22, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_vsmear_per_cad_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
    
    
    
    %--------------------------------------------------------------------------
    % generate figures of median/std across cols for smear diff on available
    % mod/outs using plot
    %--------------------------------------------------------------------------
    
    h23 = figure;
    plot(medSmearDiffAcrossCols)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Median of (masked-virtual) smear pixels (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' masked-virtual smear diff per cadence per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h23, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_med_smeardiff_per_cad_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
    
    
    h24 = figure;
    plot(stdSmearDiffAcrossCols)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Std of (masked-virtual) smear pixels (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' masked-virtual smear diff per cadence per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h24, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_smeardiff_per_cad_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
end


return;

