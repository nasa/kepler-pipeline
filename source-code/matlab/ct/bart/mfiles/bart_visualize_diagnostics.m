function bart_visualize_diagnostics(module, output, movieFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function bart_visualize_diagnostics(module, output, movieFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% finds the mat file with the bart diagnostics for the input module and output
% and returns 2 figures for visualizing the diagnostics.  These two
% figures get saved.  If movieFlag is on two avi movies are generated and
% saved.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  INPUT:
%
%               module: [int] CCD module number
%               output: [int] CCD output number
%            movieFlag: [logical] if on, avi movies will be generated and
%            saved
%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:
%
%         fiugre1: subplot1 has the image of weighted RMS residuals
%                  subplot2 has the histogram of the weighted RMS residuals 
%
%         figure2: subplot1 has the image of the sum of the robust weights
%                  subplot2 has the histogram of the sum of robust weights
%
%         figure3: movie of of the image of weighted RMS residuals if
%         movieFlag is turned on
%
%         figure4: movie of the row plot of weighted RMS residuals if
%         movieFlag is turned on
%                     
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% check input arguments
if nargin ~= 3
    error('CT:BART:bart_visualize_diagnostics', 'bart_visualize_model takes 3 input arguments')
end

% check that all inputs are scalar
if ~( numel(module)==1 && numel(output)==1)
    error('CT:BART:bart_visualize_diagnostics', 'all input arguments must be scalar')
end

% check valid module
if ~(any(module == [2:4, 6:20, 22:24])) 
    error('CT:BART:bart_visualize_diagnostics', 'invalid module')
end

% check valid output
if ~(any(output == 1:4))
    error('CT:BART:bart_visualize_diagnostics', 'invalid output')
end

% check that the fourth argument is 0 or 1
if ~((movieFlag ~= 0) || (movieFlag ~=1))
    error('CT:BART:bart_visualize_diagnostics', 'movieFlag must be logical')
end

close all

% import FcConstants, needed for plotting
import gov.nasa.kepler.common.FcConstants;


% make the search string based on input modules and output
searchString = strcat('bart_mod', num2str(module), '_out', num2str(output));

% search for a file in pwd with the search string
fileStruct = dir([searchString '*diagnostics.mat']);


if isempty(fileStruct) % model not found
    error('CT:BART:bart_visualize_diagnostics', 'no diagnostics of model found for the specified module output')
end

if length(fileStruct)>1 % multiple ones found, don't know which to use
    error('CT:BART:bart_visualize_diagnostics', 'multiple BART model diagnostics found for the specified module output')
end

% load mat file
diagnosticsFileName = fileStruct(1).name; % the name of the single model file found, with date stamp on it
eval(['load ' diagnosticsFileName]) % load the file

% get variables from structure
weightedRmsResiduals = bartDiagnosticsWeightStruct.weightedRmsResiduals;
weightSum = bartDiagnosticsWeightStruct.weightSum;
fitResiduals = bartDiagnosticsFitStruct.fitResiduals;



% figure1
fig5_h = figure('units', 'pixels', 'position', [60 80 580 730]);
set(fig5_h, 'numbertitle', 'off')
set(fig5_h, 'name', 'Plots of the Rms Residuals')




% subplot1
ax5_1_h = subplot(2,1,1, 'parent', fig5_h); % top plot
smart_imagesc(weightedRmsResiduals, [0, FcConstants.CCD_COLUMNS-1], [0 FcConstants.CCD_ROWS-1], ax5_1_h)
colormap(jet)
title(sprintf('Weighted Rms Residuals\n module %s output %s', num2str(module), num2str(output)), 'fontsize',12, 'fontweight', 'bold', 'parent', ax5_1_h)
xlabel('Column','fontsize', 12, 'fontweight', 'bold', 'parent', ax5_1_h)
ylabel('Row', 'fontsize', 12, 'fontweight', 'bold', 'parent', ax5_1_h)
colorbar('eastoutside')
set(ax5_1_h, 'ydir', 'normal')



% subplot2
subplot(2,1,2, 'parent', fig5_h); % bottom plot
hist(weightedRmsResiduals(:), 100) % 100 bins?
grid on
title(sprintf('Histogram of the Weighted Rms Residuals\n module %s output %s', num2str(module), num2str(output)), 'fontsize', 12, 'fontweight', 'bold')
xlabel('Rms Residuals', 'fontsize', 12, 'fontweight', 'bold')
ylabel('Count','fontsize', 12, 'fontweight', 'bold')



% save the first figure
figName1fig = ['rmsResiduals_' strtok(diagnosticsFileName, '.') '.fig'];
figName1png = ['rmsResiduals_' strtok(diagnosticsFileName, '.') '.png'];
hgsave(fig5_h, figName1fig)
saveas(fig5_h, figName1png)


% figure2
fig6_h = figure('units', 'pixels', 'position', [645 80 580 730]);
set(fig6_h, 'numbertitle', 'off')
set(fig6_h, 'name', 'Plots of Weight Sum')


% subplot1
ax6_1_h = subplot(2,1,1, 'parent', fig6_h); % top plot 
smart_imagesc(weightSum, [0, FcConstants.CCD_COLUMNS-1], [0 FcConstants.CCD_ROWS-1], ax6_1_h)
colormap(jet)
title(sprintf('Weight Sum\n module %s output %s', num2str(module), num2str(output)), 'fontsize',12, 'fontweight', 'bold', 'parent', ax6_1_h)
xlabel('Column','fontsize', 12, 'fontweight', 'bold', 'parent', ax6_1_h)
ylabel('Row', 'fontsize', 12, 'fontweight', 'bold', 'parent', ax6_1_h)
colorbar('eastoutside')
set(ax6_1_h, 'ydir', 'normal')


% subplot2
subplot(2,1,2, 'parent', fig6_h); % bottom plot 
hist(weightSum(:), 100) % 100 bins?
grid on
title(sprintf('Histogram of the Weight Sum\n module %s output %s',num2str(module), num2str(output)), 'fontsize', 12, 'fontweight', 'bold')
xlabel('Sum of Weights', 'fontsize', 12, 'fontweight', 'bold')
ylabel('Count','fontsize', 12, 'fontweight', 'bold')



% save the second figure
figName2fig = ['weightSum_' strtok(diagnosticsFileName, '.') '.fig'];
figName2png = ['weightSum_' strtok(diagnosticsFileName, '.') '.png'];
hgsave(fig6_h, figName2fig)
saveas(fig6_h, figName2png)



% if movieFlag is on, make movies, this takes up some time...

if movieFlag == 1
    
    frames = size(fitResiduals);
    figure(3); set(3, 'numbertitle', 'off','name', 'Movie of the Fit Residuals')

    for f = 1:frames(1)

        smart_imagesc(squeeze(fitResiduals(f,:,:)), [0, FcConstants.CCD_COLUMNS-1], [0 FcConstants.CCD_ROWS-1], gca)
        set(gca, 'ydir', 'normal')
        title(sprintf('Fit Residuals\n module %s output %s frame %s', num2str(module), num2str(output), num2str(f)), 'fontsize',12, 'fontweight', 'bold')
        xlabel('Column','fontsize', 12, 'fontweight', 'bold')
        ylabel('Row', 'fontsize', 12, 'fontweight', 'bold')
        M(f) = getframe(3); %#ok<AGROW>
    end
    movieName1  =['movie_fitResiduals_' strtok(diagnosticsFileName, '.')];
    movie2avi(M, movieName1, 'fps', 1 )


    for f = 1:frames(1)
        figure(4); set(4, 'numbertitle', 'off','name', 'Movie of the Fit Residuals by Row')
        plot(squeeze(fitResiduals(f,:,:)))
        title(sprintf('Fit Residuals\n module %s output %s frame %s', num2str(module), num2str(output), num2str(f)), 'fontsize',12, 'fontweight', 'bold')
        xlabel('Column','fontsize', 12, 'fontweight', 'bold')
        ylabel('Fit Residuals by Row', 'fontsize', 12, 'fontweight', 'bold')
        Q(f) = getframe(4); %#ok<AGROW>
    end
    movieName2  =['movie_fitResidualsRowPlots_' strtok(diagnosticsFileName, '.')];
    movie2avi(Q, movieName2, 'fps', 1 )

end



