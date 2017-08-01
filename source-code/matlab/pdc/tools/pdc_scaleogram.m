% pdc_scaleogram.m
% 23 Oct 2013 -- Makes scaleograms with either wavelet coefficients or
% the levels of the multiresolution analysis
% Inputs:
%   pdc-inputs-0.mat, input file for a PDC run
%   targetDataStruct_beforeBS.mat, one of the output files from a PDC run
%==========================================================================
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
clear all
close all

% Specify plot type
plotType = input('Scalogram type: M(multiresolution) W(wavelet) -- ','s');

% Q10 modout 7.3 noforcerobustfit
% From ksop-1721, Q10, modout 7.03
% dataDir =   '/path/to/TEST/pipeline_results/photometry/lc/pdc/ksop-1721-pdc-lc-q1-q15/uow/pdc-8072-q10-07.03/';
dataDir = '/path/to/pdc-8072-q10-07.03/';
plotDir = '/path/to/Q10_modout_17.03_plots/';

% Load the input struct
inputStructFile = [dataDir,'pdc-inputs-0.mat'];
load(inputStructFile);

% List of targets with possible end effects or other msMap problems,
% identified via find_artifacts
% keplerIdList = [ 5359678 5788623 5095511 5096776 5098444 ...
% 5097962 5097446 5530881 5270698 5444392 5446821 5703230 4919121 4918333 ...
% 4920178 5180418 5180885 5184472 5182451 ...
% 5617953 5788360 5095968 4831185 4831130 ...
% 5268696 5095159 5095232 4650686 4918708];

% Select targets to plot
targetList = 50 + [1, 10, 13, 18, 23, 24];

% Get target data
targetDataFile = [dataDir,'targetDataStruct_beforeBS.mat'];
load(targetDataFile);
bsTargetDataStruct = targetDataStruct_beforeBS(targetList);

% Remove median from input light curve data
skip = false;
iCount = 0;
nCadences = length(bsTargetDataStruct(1).values);
if(~skip)
    for iTarget = targetList
        
        % Increment counter
        iCount = iCount + 1;
        
        % Get light curve data
        data = bsTargetDataStruct(iCount).values;
        
        % Center cadences at zero
        cadences = (1:nCadences)';
        cadences = cadences - mean(cadences);
        
        % Remove median from data
        bsTargetDataStruct(iCount).values = data - median(data);
        
    end
end % skip

% Do bandsplitting
bsConfigStruct = inputsStruct.bandSplittingConfigurationStruct;

% !!!!! Test: option to change number of wavelet taps
nTaps = 12;
%nTaps = input('Number of wavelet taps (must be even number) ? ');
if(nTaps ~= 12)
    bsConfigStruct.numberOfWaveletTaps = nTaps;
end

% Bandsplitting
fprintf('Doing Bandsplitting...\n')
tic
[~, bsDataObject]=bs_controller_split(bsTargetDataStruct,bsConfigStruct,[]);
toc

% Examine/process results in the wavelet domain
allBands = bsDataObject.allBands;
waveletCoefficients = bsDataObject.waveletCoefficients;
nScales = bsDataObject.nScales;

% Cadence scales
% Reverse order of scales -- so that it goes from large scales to small
% scales
scales = 2.^(0:nScales-1);

% Select targets
keplerIds = [bsTargetDataStruct.keplerId];

% Make scaleograms for flux and wavelet coefficients
iCount = 0;
for iTarget = targetList
    
    % Increment counter
    iCount = iCount + 1;
    
    % Set up figure
    figure
    box on
    hold on
    
    % Plot input light curve
    numSubplots = 2;
    subplot(numSubplots,1,1)
    flux = bsTargetDataStruct(iCount).values;
    cadences = 1:length(flux);
    hold on
    plot(cadences, flux,'k-')
    xlabel('time [cadences]')
    ylabel({'median-removed flux';'[e-/cadence]'})
    title(['Flux for KeplerId ',num2str(keplerIds(iCount))])
     
    % Light curve from lowest band
    if(plotType == 'M')
        x = fliplr(allBands{iCount});
        nScales;
        plot(cadences,sum(x(:,scales>=1024),2),'r-')
        hold on
        legend('total flux','band 1 flux')
    end
    axis tight
    colorbar
       
    % Scaleogram
    if(plotType=='M')
        % Multiresolution analysis: flux timeseries at each scale
        subplot(numSubplots,1,2)
        x = fliplr(allBands{iCount});
        % The top row is the 'Smooth' (or 'Average' layer), 
        % the rest of the rows are the 'Details' of the multiresolution analysis
        imagesc(real(log10(x(:,1:nScales)')))
        set(gca,'YDir','normal')
        colorbar
        % Tune the color palette
        caxis([0,4])
        xlabel('time [cadences]')
        ylabel('scale [cadences]')
        hold on
        title(['Multiresolution Analysis of Flux Time Series for KeplerId ',num2str(keplerIds(iCount))])
    
    elseif(plotType=='W')
        % Wavelet coefficients for each scale scale
        subplot(numSubplots,1,2)
        x = waveletCoefficients{iCount};
        % Plot log of wavelet coefficients for better dynamic range
        imagesc(real(log10(x(:,1:nScales)')))
        set(gca,'YDir','normal')
        colorbar
        % Tune the color palette
        caxis([0,6])
        xlabel('shift [cadences]')
        ylabel('scale [cadences]')
        hold on
        title(['Wavelet Coefficients [log scale] for KeplerId ',num2str(keplerIds(iCount))])
    end
    
    % Change FontSize to 12
    set(gca,'FontSize',12)
    set(findall(gcf,'type','axes'),'FontSize',12,'FontWeight','bold')
    set(findall(gcf,'type','text'),'FontSize',12,'FontWeight','bold')
    
    % label Y axis with cadence scale
    set(gca,'YTick',1:2:11)
    set(gca,'YtickLabel',2.^((1:2:11)-1))
    
    % Save fig, tiff and jpeg plots
    plotRoot = [plotDir,'scaleograms_',num2str(nTaps),'taps_',bsConfigStruct.edgeEffectMitigationMethod,'_',num2str(keplerIds(iCount))];
    print('-r150','-dtiff',plotRoot)
    print('-r150','-djpeg',plotRoot)
    hgsave(plotRoot)
end

