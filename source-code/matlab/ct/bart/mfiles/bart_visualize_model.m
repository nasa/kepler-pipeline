function bart_visualize_model(module, output)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function bart_visualize_model(module, output)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% finds the mat file with the bart model for the input module and output
% and returns and saves 2 figures for visualizing the model
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  INPUT:
%
%               module: [int] CCD module number
%               output: [int] CCD output number
%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:
%
%         fiugre1: subplot1 has the image of coeff C0
%                  subplot2 has the image of coeff C1  
%
%         figure2: subplot1 has the image of the uncertainties of coeff C0
%                  subplot2 has the image of the uncertainties of coeff C1
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
if nargin ~= 2
    error('CT:BART:bart_visualize_model','bart_visualize_model takes 2 input arguments')
end

% check that all inputs are scalar
if ~( numel(module)==1 && numel(output)==1)
    error('CT:BART:bart_visualize_model', 'all input arguments must be scalar')
end

% check valid module
if ~(any(module == [2:4, 6:20, 22:24])) 
    error('CT:BART:bart_visualize_model', 'invalid module')
end

% check valid output
if ~(any(output == 1:4))
    error('CT:BART:bart_visualize_model', 'invalid output')
end

close all

% import FcConstants, needed for plotting
import gov.nasa.kepler.common.FcConstants;

% make the search string based on input modules and output
searchString = strcat('bart_mod', num2str(module), '_out', num2str(output));

% search for a file in pwd with the search string
fileStruct = dir([searchString '*model.mat']);



if isempty(fileStruct) % model not found
    error('CT:BART:bart_visualize_model', 'no model found for the specified module output')
end

if length(fileStruct)>1 % multiple ones found, don't know which to use
    error('CT:BART:bart_visualize_model', 'multiple BART models found for the specified module output')
end

% load mat file
modelFileName = fileStruct(1).name; % the name of the single model file found, with date stamp on it
eval(['load ' modelFileName]) % load the file

% get variables from structure
C0 = squeeze(bartOutputModelStruct.modelCoefficients(2,:,:));
C1 = squeeze(bartOutputModelStruct.modelCoefficients(1,:,:));
uncertaintyC0_squared = squeeze(bartOutputModelStruct.covarianceMatrix(3,:,:));
uncertaintyC1_squared = squeeze(bartOutputModelStruct.covarianceMatrix(1,:,:));
uncertaintyCO = sqrt(uncertaintyC0_squared);
uncertaintyC1 = sqrt(uncertaintyC1_squared);



% figure1
fig3_h = figure('units', 'pixels', 'position', [60 80 580 730]);
set(fig3_h, 'numbertitle', 'off')
set(fig3_h, 'name', 'Image of the Two-D-Black Coefficients')
ax3_h = subplot(2,1,1, 'parent', fig3_h); % top plot C0

% subplot1 coefficients C0
%smart_imagesc(C0,  [0, FcConstants.CCD_COLUMNS-1], [0 FcConstants.CCD_ROWS-1], ax3_h);
smart_imagesc( C0, [0, FcConstants.CCD_COLUMNS-1], [0 FcConstants.CCD_ROWS-1], ax3_h);
colormap(jet)
title(sprintf('C_0 for module %s output %s', num2str(module), num2str(output)), 'fontsize', 12, 'fontweight', 'bold', 'parent', ax3_h)
xlabel('Column','fontsize', 12, 'fontweight', 'bold', 'parent', ax3_h)
ylabel('Row', 'fontsize', 12, 'fontweight', 'bold', 'parent', ax3_h)
colorbar('eastoutside')
set(ax3_h, 'ydir', 'normal')
% subplot2 coefficients C1
ax4_h = subplot(2,1,2, 'parent', fig3_h); % bottom plot C1
% smart_imagesc(C1,  [0, FcConstants.CCD_COLUMNS-1], [0 FcConstants.CCD_ROWS-1], ax4_h);
smart_imagesc( C1, [0, FcConstants.CCD_COLUMNS-1], [0 FcConstants.CCD_ROWS-1], ax4_h)
title(sprintf('C_1 for module %s output %s', num2str(module), num2str(output)), 'fontsize', 12, 'fontweight', 'bold', 'parent', ax4_h)
xlabel('Column','fontsize', 12, 'fontweight', 'bold', 'parent', ax4_h)
ylabel('Row', 'fontsize', 12, 'fontweight', 'bold', 'parent', ax4_h)
colorbar('eastoutside')
set(ax4_h, 'ydir', 'normal')

% save the first figure
figName1fig = ['fitCoefficients_' strtok(modelFileName, '.') '.fig'];
figName1png = ['fitCoefficients_' strtok(modelFileName, '.') '.png'];
hgsave(fig3_h, figName1fig)
saveas(fig3_h, figName1png)



% figure2
fig4_h = figure('units', 'pixels', 'position', [645 80 580 730]);
set(fig4_h, 'numbertitle', 'off')
set(fig4_h, 'name', 'Image of the Uncertainties of the Two-D-Black Coefficients')

% subplot1
ax5_h = subplot(2,1,1, 'parent', fig4_h); % top plot C0
smart_imagesc( uncertaintyCO, [0, FcConstants.CCD_COLUMNS-1], [0 FcConstants.CCD_ROWS-1], ax5_h )
colormap(jet)
title(sprintf('Uncertainties in C_0 for module %s output %s', num2str(module), num2str(output)), 'fontsize', 12, 'fontweight', 'bold', 'parent', ax5_h)
xlabel('Column','fontsize', 12, 'fontweight', 'bold', 'parent', ax5_h)
ylabel('Row', 'fontsize', 12, 'fontweight', 'bold', 'parent', ax5_h)
colorbar('eastoutside')
set(ax5_h, 'ydir', 'normal')

% subplot2
ax6_h = subplot(2,1,2, 'parent', fig4_h); % bottom plot C1
smart_imagesc(uncertaintyC1, [0, FcConstants.CCD_COLUMNS-1], [0 FcConstants.CCD_ROWS-1], ax6_h)
title(sprintf('Uncertainties  in C_1 for module %s output %s', num2str(module), num2str(output)), 'fontsize', 12, 'fontweight', 'bold', 'parent', ax6_h)
xlabel('Column','fontsize', 12, 'fontweight', 'bold', 'parent', ax6_h)
ylabel('Row', 'fontsize', 12, 'fontweight', 'bold', 'parent', ax6_h)
colorbar('eastoutside')
set(ax6_h, 'ydir', 'normal')

% save the second figure
figName2fig = ['uncertaintiesFitCoefficients_' strtok(modelFileName, '.') '.fig'];
figName2png = ['uncertaintiesFitCoefficients_' strtok(modelFileName, '.') '.png'];
hgsave(fig4_h, figName2fig)
saveas(fig4_h, figName2png)







