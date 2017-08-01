function create_black_figures_for_dawg(quarterString, monthString, cadenceTypeString, ...
    figurePath, dawgFigureFlag)
%
% function to create figures for median and std of black-corrected black
% pixels to vet flight or simulated data across the focal plane.  Matlab
% .fig figures are saved to files in the figurePath
%
%
%  See start_cal_data_review for input definitions.
%
%
% if createImageFlag, the following are
% created with the imagesc command:
%
%   [quarter]_[month]_[cadenceType]_med_black_per_row_per_channel
%   [quarter]_[month]_[cadenceType]_std_black_per_row_per_channel
%   [quarter]_[month]_[cadenceType]_med_black_per_cad_per_channel
%   [quarter]_[month]_[cadenceType]_std_black_per_cad_per_channel
%
% if createPlotFlag, the following are
% created with the plot command
%
%   [quarter]_[month]_[cadenceType]_med_black_per_row_per_channel_plot
%   [quarter]_[month]_[cadenceType]_std_black_per_row_per_channel_plot
%   [quarter]_[month]_[cadenceType]_med_black_per_cad_per_channel_plot
%   [quarter]_[month]_[cadenceType]_std_black_per_cad_per_channel_plot
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
eval(['load ' dataPath, 'medStdBlackArrays.mat'])

figurePath  = [figurePath 'black_figures/'];
mkdir(figurePath)


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% generate figures showing only available mod/outs and data
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% rename (shorten) strings for titles/filenames
if strcmpi(cadenceTypeString, 'long')
    cadenceTypeString = 'LC';
elseif  strcmpi(cadenceTypeString, 'short')
    cadenceTypeString = 'SC';
end


%--------------------------------------------------------------------------
% generate figures of median/std across time for black pixels on available
% mod/outs using imagesc
%--------------------------------------------------------------------------
h1 = figure;
imagesc(medBlackAcrossTime') %#ok<NODEF>
caxis([prctile(medBlackAcrossTime(:), 5) prctile(medBlackAcrossTime(:), 95)]);
apply_white_nan_colormap_to_image();
xlabel(' CCD Channel ', 'fontsize', 14)
ylabel(' CCD Row Index ', 'fontsize', 14)
colorbar
title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' black residuals per row per channel'], 'fontsize', 14)

set(gca, 'XTick', 1:length(allChannelsArray))
set(gca, 'XTicklabel', allChannelsArray)

set(h1, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', 13);

fileNameStr = [figurePath, lower(cadenceTypeString) '_med_black_per_row_per_channel'];
plot_cal_figs_to_file(fileNameStr);

if ~dawgFigureFlag
    %----------------------------------------------------------------------
    % std -- available rows
    %----------------------------------------------------------------------
    h2 = figure;
    imagesc(stdBlackAcrossTime') %#ok<NODEF>
    caxis([prctile(stdBlackAcrossTime(:), 5) prctile(stdBlackAcrossTime(:), 95)]);
    apply_white_nan_colormap_to_image();
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' CCD Row Index ', 'fontsize', 14)
    colorbar
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' black residuals per row per channel'], 'fontsize', 14)
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h2, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_black_per_row_per_channel'];
    plot_cal_figs_to_file(fileNameStr);
end


%--------------------------------------------------------------------------
% generate figures of median/std across rows for black pixels on available
% mod/outs using imagesc
%--------------------------------------------------------------------------
h3 = figure;
imagesc(medBlackAcrossRows') %#ok<NODEF>
caxis([prctile(medBlackAcrossRows(:), 5) prctile(medBlackAcrossRows(:), 95)]);
apply_white_nan_colormap_to_image();
xlabel(' CCD Channel ', 'fontsize', 14)
ylabel(' Cadence Index ', 'fontsize', 14)
colorbar
title([quarterString '-' monthString ': MED ' cadenceTypeString ' black residuals per cadence per channel'], 'fontsize', 14)

set(gca, 'XTick', 1:length(allChannelsArray))
set(gca, 'XTicklabel', allChannelsArray)

set(h3, 'PaperPositionMode', 'auto');
set(gca, 'fontsize', 13);

fileNameStr = [figurePath, lower(cadenceTypeString) '_med_black_per_cad_per_channel'];
plot_cal_figs_to_file(fileNameStr);


if ~dawgFigureFlag
    h4 = figure;
    imagesc(stdBlackAcrossRows') %#ok<NODEF>
    caxis([prctile(stdBlackAcrossRows(:), 5) prctile(stdBlackAcrossRows(:), 95)]);
    apply_white_nan_colormap_to_image();
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Cadence Index ', 'fontsize', 14)
    colorbar
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' black residuals per cadence per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h4, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_black_per_cad_per_channel'];
    plot_cal_figs_to_file(fileNameStr);
end



%--------------------------------------------------------------------------
% generate figures of median/std across time for black pixels on available
% mod/outs using plot
%--------------------------------------------------------------------------
if ~dawgFigureFlag
    h5 = figure;
    plot(medBlackAcrossTime)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Median of black residuals (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' black residuals per row per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h5, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_med_black_per_row_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
    
    
    h6 = figure;
    plot(stdBlackAcrossTime)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Std of black residuals (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' black residuals per row per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h6, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath,  lower(cadenceTypeString) '_std_black_per_row_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
end

%--------------------------------------------------------------------------
% generate figures of median/std across rows for black pixels on available
% mod/outs using plot
%--------------------------------------------------------------------------
if ~dawgFigureFlag
    h7 = figure;
    plot(medBlackAcrossRows)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Median of black residuals (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': MEDIAN ' cadenceTypeString ' black residuals per cadence per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h7, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_med_black_per_cad_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
    
    h8 = figure;
    plot(stdBlackAcrossRows)
    xlabel(' CCD Channel ', 'fontsize', 14)
    ylabel(' Std of black residuals (ADU/read) ', 'fontsize', 14)
    title([quarterString '-' monthString ': STD ' cadenceTypeString ' black residuals per cadence per channel'], 'fontsize', 14)
    
    set(gca, 'XTick', 1:length(allChannelsArray))
    set(gca, 'XTicklabel', allChannelsArray)
    
    set(h8, 'PaperPositionMode', 'auto');
    set(gca, 'fontsize', 13);
    
    fileNameStr = [figurePath, lower(cadenceTypeString) '_std_black_per_cad_per_channel_plot'];
    plot_cal_figs_to_file(fileNameStr);
end

return;
