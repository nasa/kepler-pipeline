function bart2DBlackStruct = get_bart_model(module, output, temperature, figFlag, saveFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function bart2DBlackStruct = get_bart_model(module, output, temperature, figFlag, saveFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% returns a structure bart2DBlackStruct containing the extrapolated
% temperature dependent 2D-black and its uncertainties.  If fig figFlag is
% on 2 figures will be generated.  If saveFlag is on, figures will be
% saved.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  INPUT:
%
%               module: [int] CCD module number
%               output: [int] CCD output number
%          temperature: [double] temperature for the desired 2D-black
%              figFlag: [logical] turns figures on/off
%             saveFlag: [logical] turns saving of the figures on or off
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:
%
%      bart2DBlackStruct is a 1x1 structure containing the fields -
%                .module [int] CCD module number
%                .output [int] CCD output number
%                .inputTemperature [double] temperature of the model
%                .twoDBlack [nRow nCol] 2-D Black model at specified temp
%                .uncertainties [nRow nCol] uncertainties of the model
%
%     if figFlag is on two figures will be produced -
%           
%               figure 1 will contain a 2D Black image at the extrapolated
%               temperature
%
%               figure 2 will contain one subplot of the uncertainties from
%               the extrapolated 2D Black and one subplot for the
%               histogram of these uncertainites
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

% import FcConstants
import gov.nasa.kepler.common.FcConstants;



% check input arguments
if nargin ~= 5
    error('CT:BART:get_bart_model', 'get_bart_model takes 5 input arguments')
end

% check that all inputs are scalar
if ~( numel(module)==1 && numel(output)==1 && numel(temperature)==1 && numel(figFlag)==1 )
    error('CT:BART:get_bart_model', 'all input arguments must be scalar')
end

% check valid module
if ~(any(module == FcConstants.modulesList)) 
    error('CT:BART:get_bart_model', 'invalid module')
end

% check valid output
if ~(any(output == FcConstants.outputsList))
    error('CT:BART:get_bart_model', 'invalid output')
end

% check valid figFlag
if ~(figFlag == 1 || figFlag == 0)
    error('CT:BART:get_bart_model', 'figFlag has to be 0 or 1')
end

% check valid saveFlag
if ~(saveFlag == 1 || saveFlag == 0)
    error('CT:BART:get_bart_model', 'saveFlag has to be 0 or 1')
end

% check valid saveFlag
if figFlag ==0 && saveFlag ==1
    error('CT:BART:get_bart_model', 'if figFlag = 0 then saveFlag can''t be 1 ')
end



% initialize the structure to return to workspace
bart2DBlackStruct = struct('module', [], 'output', [],...
    'inputTemperature', [],'twoDBlack', [], 'uncertainties', []);

% make the search string based on input modules and output
searchString = strcat('bart_mod', num2str(module), '_out', num2str(output));

% search for a file in pwd with the search string
fileStruct = dir([searchString '*model.mat']);

if isempty(fileStruct) % model not found
    error('CT:BART:get_bart_model', 'no model found for the specified module output')
end

if length(fileStruct)>1 % multiple ones found, don't know which to use
    error('CT:BART:get_bart_model', 'multiple BART models found for the specified module output')
end

modelFileName = fileStruct(1).name; % the name of the single model file found, with date stamp on it
eval(['load ' modelFileName]) % load the file



% get variables out of bartOutputModelStruct
T0 = bartOutputModelStruct.T0 ;
deltaTemp = temperature - T0;
uncertaintyC0_squared = squeeze(bartOutputModelStruct.covarianceMatrix(3,:,:));
uncertaintyC1_squared = squeeze(bartOutputModelStruct.covarianceMatrix(1,:,:));
uncertaintyC0C1 = squeeze(bartOutputModelStruct.covarianceMatrix(2,:,:));
C0 = squeeze(bartOutputModelStruct.modelCoefficients(2,:,:));
C1 = squeeze(bartOutputModelStruct.modelCoefficients(1,:,:));

% the extrapolated 2D Black is ...
twoDBlack = C0 + C1*deltaTemp;

% the uncertainty of the 2D Black is ...
uncertainties = sqrt(uncertaintyC0_squared + (deltaTemp^2)*uncertaintyC1_squared + 2*deltaTemp*uncertaintyC0C1);

% plug variables into bart2DBlackStruct
bart2DBlackStruct.module = module;
bart2DBlackStruct.output = output;
bart2DBlackStruct.inputTemperature = temperature;
bart2DBlackStruct.twoDBlack = twoDBlack;
bart2DBlackStruct.uncertainties = uncertainties;



%% plot figFlag turned on
close all 
if figFlag == true

    % plot figure 1
    fig1_h = figure('units', 'pixels', 'position', [30 100 580 420]);
    set(fig1_h, 'numbertitle', 'off')
    set(fig1_h, 'name', 'Two-D-Black Image')
    ax1_h = axes('parent', fig1_h);
    % make image suitable for kepler images and 0 based
    smart_imagesc(twoDBlack, [0, FcConstants.CCD_COLUMNS-1],[0 FcConstants.CCD_ROWS-1], ax1_h);
    colormap(hot)
    title(['Two-D-Black at ' num2str(temperature) '\circC for module ' num2str(module) ' output ' num2str(output) ], 'fontsize', 12 , 'fontweight', 'bold')
    xlabel('Column', 'fontsize', 12, 'fontweight', 'bold' )
    ylabel('Row', 'fontsize', 12, 'fontweight', 'bold' )
    colorbar('peer', ax1_h)

    % plot figure 2
    fig2_h = figure('units', 'pixels', 'position', [620 100 580 730]);
    set(fig2_h, 'numbertitle', 'off')
    set(fig2_h, 'name', 'Uncertainty Plots of the Two-D-Black')

    % image of uncertainties on top
    ax2_h = subplot(2,1,1, 'parent', fig2_h); % top plot
    smart_imagesc( uncertainties, [0, FcConstants.CCD_COLUMNS-1], [0 FcConstants.CCD_ROWS-1],ax2_h);
    colormap(jet)
    title(['Image of Uncertainties at ' num2str(temperature) '\circC for module ' num2str(module) ' output ' num2str(output)], 'fontsize', 12, 'fontweight', 'bold')
    xlabel('Column','fontsize', 12, 'fontweight', 'bold')
    ylabel('Row', 'fontsize', 12, 'fontweight', 'bold')
    colorbar('peer', ax2_h)

    % histogram of uncertainties on bottom
    subplot(2,1,2)
    hist(uncertainties(:), 100) % 100 bins
    grid on
    title(['Histogram of Uncertainties at ' num2str(temperature) '\circC for module ' num2str(module) ' output ' num2str(output)], 'fontsize', 12, 'fontweight', 'bold')
    xlabel('Uncertainties (DN/Read)', 'fontsize', 12, 'fontweight', 'bold')
    ylabel('Count','fontsize', 12, 'fontweight', 'bold')

end



if saveFlag ==1

    figName1fig = ['2DBlack_mod', num2str(module), '_out', num2str(output), '_', num2str(temperature), '_','degC.fig'];
    figName1png = ['2DBlack_mod', num2str(module), '_out', num2str(output), '_', num2str(temperature), '_','degC.png'];
    hgsave(fig1_h, figName1fig)
    saveas(fig1_h, figName1png)

    figName2fig = ['uncertainties_2DBlack_mod', num2str(module), '_out', num2str(output), '_', num2str(temperature), '_','degC.fig'];
    figName2png = ['uncertainties_2DBlack_mod', num2str(module), '_out', num2str(output), '_', num2str(temperature), '_','degC.png'];
    hgsave(fig2_h, figName2fig)
    saveas(fig2_h, figName2png)


end


