function [F,S] = produce_dawg_flux_summary( pathName, channelList, quarter, month, skipCustomTargets )
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

if ~exist('channelList', 'var')
    channelList = 1:84;
end

% If a quarter was not specified, passing an empty array to get_group_dir()
% will cause it to default to the earliest available quarter under
% 'pathName'.
if ~exist('quarter', 'var')
    quarter = [];
end
if ~exist('skipCustomTargets', 'var')
    skipCustomTargets = false;
end

COPY_NEG_FLUX_FIGS_FOR_CUSOM_TARGETS = true;
MADS_FOR_HISTOGRAMS = 8;
HISTOGRAM_DEFAULT_BINS = 51;
HISTOGRAM_BIN_FACTOR = 500;

% P1 = [1125   240   760   375];
P2 = [1125   705   760   375];

fig_filenames = {'median_flux_over_expected_flux',...
                 'median_uncertainty_over_shot_noise',...
                 'median_uncertainty_over_std_dev',...
                 'median_flux_over_expected_flux_dist',...
                 'median_uncertainty_over_shot_noise_dist',...
                 'median_uncertainty_over_std_dev_dist'};


% preallocate summary structure
S = repmat(struct('ccdModule',[],...
                        'ccdOutput',[],...
                        'taskFileDirectory',[],...
                        'negativeFluxIndex',[],...
                        'negativeFluxKeplerId',[],...
                        'negativeFluxKeplerMag',[],...
                        'negativeFluxOutputFile',[],...
                        'normalizedFlux',[],...
                        'uncertaintyOverShotNoise',[],...
                        'uncertaintyOverStdDev',[]),...
                        length(channelList),1);
                    
Ftotal = struct('negativeFluxKeplerId',[],...
                'negativeFluxKeplerMag',[],...
                'negativeFluxOutputFile',[],...
                'normalizedFlux',[],...
                'uncertaintyOverShotNoise',[],...
                'uncertaintyOverStdDev',[]);
                    
% collect the dumped metrics                    
F = collect_dawg_flux_metrics( pathName, channelList, quarter, month );
                    
% Optionally remove custom targets from the cell array F
if skipCustomTargets
    F = prune_custom_targets(F);
end


% Produce distribution parameters for each channel.
% median, max, min, mad of the normalized flux, uncertainty over shot noise
% and uncertainty over standard deviation

for i=1:length(F)
    
    if( ~isempty(F{i}) )
        
        % populate summary metrics
        S(i).ccdModule = F{i}.ccdModule;
        S(i).ccdOutput = F{i}.ccdOutput;
        S(i).taskFileDirectory = F{i}.taskFileDirectory;
        S(i).negativeFluxIndex = F{i}.negativeFluxIndex;
        S(i).negativeFluxKeplerId = F{i}.negativeFluxKeplerId;
        S(i).negativeFluxKeplerMag = F{i}.negativeFluxKeplerMag;
        S(i).negativeFluxOutputFile = F{i}.negativeFluxOutputFile;

        S(i).normalizedFlux.min = min( F{i}.normalizedFlux );
        S(i).normalizedFlux.max = max( F{i}.normalizedFlux );
        S(i).normalizedFlux.mad = mad( F{i}.normalizedFlux );
        S(i).normalizedFlux.median = nanmedian( F{i}.normalizedFlux );

        S(i).uncertaintyOverShotNoise.min = min( F{i}.uncertaintyOverShotNoise );
        S(i).uncertaintyOverShotNoise.max = max( F{i}.uncertaintyOverShotNoise );
        S(i).uncertaintyOverShotNoise.mad = mad( F{i}.uncertaintyOverShotNoise );
        S(i).uncertaintyOverShotNoise.median = nanmedian( F{i}.uncertaintyOverShotNoise );

        S(i).uncertaintyOverStdDev.min = min( F{i}.uncertaintyOverStdDev );
        S(i).uncertaintyOverStdDev.max = max( F{i}.uncertaintyOverStdDev );
        S(i).uncertaintyOverStdDev.mad = mad( F{i}.uncertaintyOverStdDev );
        S(i).uncertaintyOverStdDev.median = nanmedian( F{i}.uncertaintyOverStdDev ); 
        
        % aggregate negative flux data
        Ftotal.negativeFluxKeplerId = [Ftotal.negativeFluxKeplerId, F{i}.negativeFluxKeplerId];
        Ftotal.negativeFluxKeplerMag = [Ftotal.negativeFluxKeplerMag, F{i}.negativeFluxKeplerMag];
        Ftotal.negativeFluxOutputFile = [Ftotal.negativeFluxOutputFile, F{i}.negativeFluxOutputFile];
        
        % aggregate normalized data
        Ftotal.normalizedFlux = [Ftotal.normalizedFlux, F{i}.normalizedFlux];
        Ftotal.uncertaintyOverShotNoise = [Ftotal.uncertaintyOverShotNoise, F{i}.uncertaintyOverShotNoise];
        Ftotal.uncertaintyOverStdDev = [Ftotal.uncertaintyOverStdDev, F{i}.uncertaintyOverStdDev];
        
        % copy negative flux figs if available
        if( ~isempty(F{i}.negativeFluxKeplerId) )
            
            % Use k loop as a temporary work around until the negative_flux*.fig files are again written to the root directory. Now they are
            % left in the sub-task directories
            for k = rowvec(unique((F{i}.negativeFluxOutputFile)))
                negativeFluxFigs = dir([F{i}.taskFileDirectory,'st-',num2str(k),'/negative_flux*.fig']);
                            
                for j=1:length(negativeFluxFigs)
                    s = negativeFluxFigs(j).name;
                    keplerId = str2num(s(length('negative_flux_')+1:strfind(s, '.fig')-1));
                    if ~is_valid_id(keplerId, 'custom') || (~skipCustomTargets && COPY_NEG_FLUX_FIGS_FOR_CUSOM_TARGETS)

                        fileToCopy = [F{i}.taskFileDirectory,'st-',num2str(k),'/',negativeFluxFigs(j).name];

                        % copy to current working directory
                        copyfile(fileToCopy);
                    end
                end
                
            end
            
        end
    end
end

% plot the summary metrics
close all;
plot_dawg_flux_metrics( S );


% produce distribution summary over all channels together
figure;
madData = mad(Ftotal.normalizedFlux,1);
medianData = nanmedian(Ftotal.normalizedFlux);
% maxData = max(Ftotal.normalizedFlux);
% minData = min(Ftotal.normalizedFlux);
idx = (Ftotal.normalizedFlux - medianData) < MADS_FOR_HISTOGRAMS * madData;
nData = length(Ftotal.normalizedFlux(idx));
hist(Ftotal.normalizedFlux(idx),max([HISTOGRAM_DEFAULT_BINS, floor(nData/HISTOGRAM_BIN_FACTOR)]));
grid;
ylabel('\bf\fontsize{12}count');
xlabel('\bf\fontsize{12}flux / expected flux');
title(['\bf\fontsize{12}Median Normalized Flux (all targets -  clipped at ',num2str(MADS_FOR_HISTOGRAMS),' mads)']);
set(gcf,'Position',P2);

figure;
madData = mad(Ftotal.uncertaintyOverShotNoise,1);
medianData = nanmedian(Ftotal.uncertaintyOverShotNoise);
% maxData = max(Ftotal.uncertaintyOverShotNoise);
% minData = min(Ftotal.uncertaintyOverShotNoise);
idx = (Ftotal.uncertaintyOverShotNoise - medianData) < MADS_FOR_HISTOGRAMS * madData;
nData = length(Ftotal.uncertaintyOverShotNoise(idx));
hist(Ftotal.uncertaintyOverShotNoise(idx),max([HISTOGRAM_DEFAULT_BINS, floor(nData/HISTOGRAM_BIN_FACTOR)]));
grid;
ylabel('\bf\fontsize{12}count');
xlabel('\bf\fontsize{12}Median Uncertainty (shot noise)');
title(['\bf\fontsize{12}Median Uncertainty/Shot Noise (all targets - clipped at ',num2str(MADS_FOR_HISTOGRAMS),' mads)']);
set(gcf,'Position',P2);

figure;
madData = mad(Ftotal.uncertaintyOverStdDev,1);
medianData = nanmedian(Ftotal.uncertaintyOverStdDev);
% maxData = max(Ftotal.uncertaintyOverStdDev);
% minData = min(Ftotal.uncertaintyOverStdDev);
idx = (Ftotal.uncertaintyOverStdDev - medianData) < MADS_FOR_HISTOGRAMS * madData;
nData = length(Ftotal.uncertaintyOverStdDev(idx));
hist(Ftotal.uncertaintyOverStdDev(idx),max([HISTOGRAM_DEFAULT_BINS, floor(nData/HISTOGRAM_BIN_FACTOR)]));
grid;
ylabel('\bf\fontsize{12}count');
xlabel('\bf\fontsize{12}Median Uncertainty (standard deviation)');
title(['\bf\fontsize{12}Median Uncertainty/Std Dev (all targets - clipped at ',num2str(MADS_FOR_HISTOGRAMS),' mads)']);
set(gcf,'Position',P2);

% save plots to local directory
for i=1:length(fig_filenames)
    figure(i);
    saveas(gcf,fig_filenames{i},'fig');
end
end


%**************************************************************************
function F = prune_custom_targets(F)

    for iCell = 1:numel(F)
        s = F{iCell};
        
        customIndices = is_valid_id(s.keplerId, 'custom');
        s.keplerId(customIndices)                 = [];
        s.normalizedFlux(customIndices)           = [];
        s.uncertaintyOverShotNoise(customIndices) = [];
        s.uncertaintyOverStdDev(customIndices)    = [];
        
        customIndices = is_valid_id(s.negativeFluxKeplerId, 'custom');
        s.negativeFluxKeplerId(customIndices)     = [];
        s.negativeFluxIndex(customIndices)        = [];
        s.negativeFluxOutputFile(customIndices)   = [];
        s.negativeFluxKeplerMag(customIndices)    = [];
        
        F{iCell} = s;
    end
end
