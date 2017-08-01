function create_hist_plots(quarterString, cadenceTypeString, channelArray, figurePath)
%
% function to create histogram plots of calibrated black and smear pixels for
% a given module/output (channel)
%
%
% The output from dawg scripts include 3D arrays of the calibrated black
% pixels (black residuals) and calibrated smear pixel difference (masked
% minus virtual smear):
%
%   Q0_flight_longCad_full3DArrays.mat
%   allBlackResidualsArray      1070x476x84            342263040  double
%   allSmearResidualsArray      1132x476x84            362095104  double
%
%   channelList                   84x1                       672  double
%   rowsAndColumnsStruct          84x1                   5955376  struct
%
%
%
% ex. channelArray = [1; 19; 41; 46; 58; 10]
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

paperOrientationFlag = false;
includeTimeFlag      = false;
printJpgFlag         = false;
dataTypeString       = 'flight';
closeAllFlag         = true;


if (strcmpi(quarterString, 'Q2') && strcmpi(cadenceTypeString, 'long') && nargin<4)

    figurePath = '/path/to/cal_Q2_data_review/long_cad_flight_figs_18_Aug_2010_16_21_23/';

elseif (strcmpi(quarterString, 'Q2') && strcmpi(cadenceTypeString, 'short') && nargin<4)

    figurePath = '/path/to/cal_Q2_data_review/short_cad_flight_figs_19_Aug_2010_01_00_54/';
end

% rename (shorten) strings for titles/filenames
if strcmpi(cadenceTypeString, 'long')
    cadenceTypeStringForPlot = 'LC';
elseif  strcmpi(cadenceTypeString, 'short')
    cadenceTypeStringForPlot = 'SC';
end


load([figurePath quarterString '_' dataTypeString '_' cadenceTypeString 'Cad_full3DArrays.mat'])

colorString = {'r*-', 'bs-', 'g.-', 'cx-', 'm+-', 'rd-', 'b*-', 'co-'};

%--------------------------------------------------------------------------
% plot black residual (over time) histograms for the list of channels
%--------------------------------------------------------------------------
for i = 1:length(channelArray)

    if i==1
        figure;
    else
        hold on
    end

    twoDArray = allBlackResidualsArray(:, :, channelArray(i)); % nRows x nCadences

    %medBlackAcrossRows = nanmedian(twoDArray);  % 1 x nCadences

    medBlackAcrossTime = nanmedian(twoDArray');  % 1 x nRows

    % trim the array and use the same bin
    trim = ([prctile(medBlackAcrossTime(:), 5) prctile(medBlackAcrossTime(:), 95)]);

    trimMedBlackAcrossTime = medBlackAcrossTime(medBlackAcrossTime >= trim(1) & medBlackAcrossTime <= trim(2));


    % [n,xout] = hist(...) returns vectors n and xout containing the frequency
    % counts and the bin locations. You can use bar(xout, n) to plot the histogram.
    [n, xout] = hist(trimMedBlackAcrossTime, 51);

    plot(xout, n, colorString{i})
end

xlabel('Frequency Counts', 'fontsize', 12)
ylabel('Bin Locations', 'fontsize', 12)

title([quarterString '-' cadenceTypeStringForPlot '-' dataTypeString ': Median (Over Time) Black Residuals (ADU/read)'], 'fontsize', 12)

legend([{['Channel ' num2str(channelArray(1))], ['Channel ' num2str(channelArray(2))], ['Channel ' num2str(channelArray(3))], ['Channel ' num2str(channelArray(4))]}, 'Location', 'Best']);


fileNameStr = [figurePath, quarterString '_' cadenceTypeStringForPlot '_' dataTypeString '_black_per_row_hist_plot'];
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

if closeAllFlag
    close all;
end

%--------------------------------------------------------------------------
% plot black residual (over row) histograms for the list of channels
%--------------------------------------------------------------------------
for i = 1:length(channelArray)

    if i==1
        figure;
    else
        hold on
    end

    twoDArray = allBlackResidualsArray(:, :, channelArray(i)); % nRows x nCadences

    medBlackAcrossRows = nanmedian(twoDArray);  % 1 x nCadences

    %medBlackAcrossTime = nanmedian(twoDArray');  % 1 x nRows

    % trim the array and use the same bin
    trim = ([prctile(medBlackAcrossRows(:), 5) prctile(medBlackAcrossRows(:), 95)]);

    trimMedBlackAcrossRows = medBlackAcrossRows(medBlackAcrossRows >= trim(1) & medBlackAcrossRows <= trim(2));


    % [n,xout] = hist(...) returns vectors n and xout containing the frequency
    % counts and the bin locations. You can use bar(xout, n) to plot the histogram.
    [n, xout] = hist(trimMedBlackAcrossRows, 51);

    plot(xout, n, colorString{i})
end

xlabel('Frequency Counts', 'fontsize', 12)
ylabel('Bin Locations', 'fontsize', 12)

title([quarterString '-' cadenceTypeStringForPlot '-' dataTypeString ': Median (Across Rows) Black Residuals (ADU/read)'], 'fontsize', 12)

legend([{['Channel ' num2str(channelArray(1))], ['Channel ' num2str(channelArray(2))], ['Channel ' num2str(channelArray(3))], ['Channel ' num2str(channelArray(4))]}, 'Location', 'Best']);


fileNameStr = [figurePath, quarterString '_' cadenceTypeStringForPlot '_' dataTypeString '_black_per_cad_hist_plot'];
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

if closeAllFlag
    close all;
end

%--------------------------------------------------------------------------
% plot smear difference per cad histograms for the list of channels
%--------------------------------------------------------------------------
for i = 1:length(channelArray)

    if i==1
        figure;
    else
        hold on
    end

    twoDArray = allSmearResidualsArray(:, :, channelArray(i)); % nCols x nCadences

    %medSmearAcrossRows = nanmedian(twoDArray);  % 1 x nCadences

    medSmearAcrossTime = nanmedian(twoDArray');  % 1 x nCols

    % trim the array and use the same bin
    trim = ([prctile(medSmearAcrossTime(:), 5) prctile(medSmearAcrossTime(:), 95)]);

    trimMedSmearAcrossTime = medSmearAcrossTime(medSmearAcrossTime >= trim(1) & medSmearAcrossTime <= trim(2));


    % [n,xout] = hist(...) returns vectors n and xout containing the frequency
    % counts and the bin locations. You can use bar(xout, n) to plot the histogram.
    [n, xout] = hist(trimMedSmearAcrossTime, 51);

    plot(xout, n, colorString{i})
end

xlabel('Frequency Counts', 'fontsize', 12)
ylabel('Bin Locations', 'fontsize', 12)

title([quarterString '-' cadenceTypeStringForPlot '-' dataTypeString ': Median (Over Time) M-V Smear Residuals (ADU/read)'], 'fontsize', 12)

legend([{['Channel ' num2str(channelArray(1))], ['Channel ' num2str(channelArray(2))], ['Channel ' num2str(channelArray(3))], ['Channel ' num2str(channelArray(4))]}, 'Location', 'Best']);


fileNameStr = [figurePath, quarterString '_' cadenceTypeStringForPlot '_' dataTypeString '_smear_per_col_hist_plot'];
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

if closeAllFlag
    close all;
end


%--------------------------------------------------------------------------
% plot smear difference per col histograms for the list of channels
%--------------------------------------------------------------------------
for i = 1:length(channelArray)

    if i==1
        figure;
    else
        hold on
    end

    twoDArray = allSmearResidualsArray(:, :, channelArray(i)); % nCols x nCadences

    medSmearAcrossCols = nanmedian(twoDArray);  % 1 x nCadences

    %medSmearAcrossTime = nanmedian(twoDArray');  % 1 x nCols

    % trim the array and use the same bin
    trim = ([prctile(medSmearAcrossCols(:), 5) prctile(medSmearAcrossCols(:), 95)]);

    trimMedSmearAcrossCols = medSmearAcrossCols(medSmearAcrossCols >= trim(1) & medSmearAcrossCols <= trim(2));


    % [n,xout] = hist(...) returns vectors n and xout containing the frequency
    % counts and the bin locations. You can use bar(xout, n) to plot the histogram.
    [n, xout] = hist(trimMedSmearAcrossCols, 51);

    plot(xout, n, colorString{i})
end

xlabel('Frequency Counts', 'fontsize', 12)
ylabel('Bin Locations', 'fontsize', 12)

title([quarterString '-' cadenceTypeStringForPlot '-' dataTypeString ': Median (Across Columns) M-V Smear Residuals (ADU/read)'], 'fontsize', 12)

legend([{['Channel ' num2str(channelArray(1))], ['Channel ' num2str(channelArray(2))], ['Channel ' num2str(channelArray(3))], ['Channel ' num2str(channelArray(4))]}, 'Location', 'Best']);


fileNameStr = [figurePath, quarterString '_' cadenceTypeStringForPlot '_' dataTypeString '_smear_per_cad_hist_plot'];
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

if closeAllFlag
    close all;
end





return;

