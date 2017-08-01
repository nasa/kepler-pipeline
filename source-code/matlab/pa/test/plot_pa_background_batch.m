function Z = plot_pa_background_batch( varargin )
%**************************************************************************
% Z = plot_pa_background_batch( varargin )
%**************************************************************************
% INPUTS
%     All inputs are optional attribute/value pairs. Valid attribute and
%     values are:
%    
%     Attribute      Value
%     ---------      -----
%     'pathName'     The full path to the directory containing task
%                    directories for the pipeline instance. Note that this
%                    path must have a sub-direcory named 'uow' that
%                    contains symlinks to the other task direcories
%                    (default is the current working directory).
%     'channelList'  An array of channel numbers in the range [1:84]
%                    (default = [1:84]).
%     'quarter'      An optional quarter number in the range [0, 17]. If
%                    empty or unspecified, the earliest quarter processed
%                    by the pipeline instance is used (default = []).
%     'plotsOn'      A logical flag indicating (default = false).
%
% OUTPUTS
%     Z              A struct array containing an element for each task
%     |              directory processed.
%     |-.output
%     |-.cadences
%     |-.gapIndicators
%     |-.meanFittedValue
%     |-.medianNormalizedResidual
%     |-.madNormalizedResidual
%     |-.extremeOutlierCount
%     |-.medianNormalizedPixelUncertainty
%     |-.madNormalizedPixelUncertainty
%      -.runParameters
%
% NOTES
%
%**************************************************************************
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

%----------------------------------------------------------------------
% Parse and validate arguments.
%----------------------------------------------------------------------
parser = inputParser;
parser.addParamValue('channelList', [1:84], @(x)isnumeric(x) &&  min(size(x)) == 1 && all(ismember(x, 1:84)) );
parser.addParamValue('quarter',         [], @(x)isempty(x) || isnumeric(x) && x>=0 && x<=17  );
parser.addParamValue('pathName',       '.', @(s)isdir(s)             );
parser.addParamValue('plotsOn',      false, @(x)islogical(x)         );
parser.parse(varargin{:});

channelList = parser.Results.channelList;
quarter     = parser.Results.quarter;
pathName    = parser.Results.pathName;
PLOTS_ON    = parser.Results.plotsOn;
%----------------------------------------------------------------------

% PA filenames
PA_TASK_DIRECTORY_STRING = 'pa-matlab-*';
PA_INPUTS_0_STRING       = 'pa-inputs-0.mat';
PA_BACKGROUND_FIT_STRING = 'pa_background.mat';


% get PA task file directory names
D = dir([pathName, filesep, PA_TASK_DIRECTORY_STRING]);


% initialize storage
Z = ...
    repmat(struct('module',0,...
                    'output',0,...
                    'cadences',[],...
                    'gapIndicators',[],...
                    'meanFittedValue',[],...
                    'medianNormalizedResidual',[],...
                    'madNormalizedResidual',[],...
                    'extremeOutlierCount',[],...
                    'medianNormalizedPixelUncertainty',[],...
                    'madNormalizedPixelUncertainty',[],...
                    'runParameters',struct()),...
                    length(D),1);


for channel = rowvec(channelList)

    % find matching channel directories from map file
    channelDir = get_group_dir('PA', channel, ...
        'quarter', quarter, 'rootPath', pathName);

    if( ~isempty(channelDir) )
        channelMatch = strcmp({D.name}',channelDir);

        if( any(channelMatch) )
            channelIdx = find(channelMatch);

            disp([num2str(channel),'    --   Processing ',D(channel).name, '...']);

            for idx = rowvec(channelIdx)
                % load data
                load([pathName,filesep,D(idx).name,filesep,PA_INPUTS_0_STRING]);
                load([pathName,filesep,D(idx).name,filesep,PA_BACKGROUND_FIT_STRING]);

                % display background fit for this channel
                outputStruct = plot_pa_background_vs_fit( inputsStruct, inputStruct, PLOTS_ON );

                % populate output
                Z(idx).module                              = outputStruct.module;
                Z(idx).output                              = outputStruct.output;
                Z(idx).cadences                            = outputStruct.cadences;
                Z(idx).gapIndicators                       = outputStruct.gapIndicators;
                Z(idx).meanFittedValue                     = outputStruct.meanFittedValue;
                Z(idx).medianNormalizedResidual            = outputStruct.medianNormalizedResidual;
                Z(idx).madNormalizedResidual               = outputStruct.madNormalizedResidual;
                Z(idx).extremeOutlierCount                 = outputStruct.extremeOutlierCount;
                Z(idx).medianNormalizedPixelUncertainty    = outputStruct.medianNormalizedPixelUncertainty;
                Z(idx).madNormalizedPixelUncertainty       = outputStruct.madNormalizedPixelUncertainty;
                Z(idx).runParameters                       = outputStruct.runParameters;
            end
        end
    end
end





% ~~~~~~~~~~~~~~~~~~~~ % produce some summary plots


% find valid channel indices - only channels in channelList are populated in output structure Z
mod = [Z.module];
out = [Z.output];
validIndices = find( ismember(mod,[2:4,6:20,22:24]) & ismember(out,1:4) );

% valid channel numbers
channel = convert_from_module_output(mod(validIndices),out(validIndices));

cadences = Z(validIndices(1)).cadences(:);
nCadences = length(cadences);
nChannels = length(Z(validIndices));

[sortedChannel, idxSortedChannel] = sort(channel);

CAD = repmat(cadences,1,nChannels);
CHAN = repmat(channel(:)',nCadences,1);

% get data from output fields
nOutliers = [Z(validIndices).extremeOutlierCount];
meanValue = [Z(validIndices).meanFittedValue];
madResidual = [Z(validIndices).madNormalizedResidual];
medianResidual = [Z(validIndices).medianNormalizedResidual];
madPixelUnc = [Z(validIndices).madNormalizedPixelUncertainty];
medianPixelUnc = [Z(validIndices).medianNormalizedPixelUncertainty];

gaps = [Z(validIndices).gapIndicators];

if( nChannels > 1 )

    % set gaps to NaN for plotting
    nOutliers(gaps) = NaN;
    meanValue(gaps) = NaN;
    madResidual(gaps) = NaN;
    medianResidual(gaps) = NaN;
    madPixelUnc(gaps) = NaN;
    medianPixelUnc(gaps) = NaN;

    % plot extreme outlier metric
    figure;
    plot3(CAD(:),CHAN(:),nOutliers(:),'.');
    grid;
    xlabel('cadence');
    ylabel('channel');
    zlabel('extreme outlier count');
    title('50 MAD Outliers in Background Pixels');

    figure;
    plot(channel,nanmedian(nOutliers),'o');
    grid;
    xlabel('channel');
    title('50 MAD Outliers in Background Pixels');

    % plot mean value metric
    figure;
    mesh(sortedChannel(:),cadences,meanValue(:,idxSortedChannel));
    xlabel('channel');
    ylabel('cadence');
    zlabel('mean value (e-)');
    title('Mean Fitted Background');

    figure;
    plot(Z(validIndices(1)).cadences,meanValue);
    grid;
    xlabel('cadences');
    ylabel('mean value (e-)');
    title('Mean Fitted Background');

    % plot residual metrics
    figure;
    mesh(sortedChannel,cadences,madResidual(:,idxSortedChannel));
    xlabel('channel');
    ylabel('cadence');
    zlabel('mad residual (sigma)');
    title('Mad Background Residual');

    figure;
    plot(channel,nanmedian(madResidual),'o');
    grid;
    xlabel('channel');
    ylabel('mad residual (sigma)');
    title('Mad Background Residual');

    figure;
    mesh(sortedChannel,cadences,medianResidual(:,idxSortedChannel));
    xlabel('channel');
    ylabel('cadence');
    zlabel('median residual (sigma)');
    title('Median Background Residual');

    figure;
    plot(channel,nanmedian(medianResidual),'o');
    grid;
    xlabel('channel');
    ylabel('median residual (sigma)');
    title('Median Background Residual');

    % plot pixel uncertainty metrics
    figure;
    mesh(sortedChannel,cadences,madPixelUnc(:,idxSortedChannel));
    xlabel('channel');
    ylabel('cadence');
    zlabel('mad pixel uncertainty (sigma)');
    title('MAD Background Pixel Uncertainty Normalized to Standard Deviation Over Cadences');

    figure;
    plot(channel,nanmedian(madPixelUnc),'o');
    grid;
    xlabel('channel');
    ylabel('mad pixel uncertainty (sigma)');
    title('MAD Background Pixel Uncertainty Normalized to Standard Deviation Over Cadences');

    figure;
    mesh(sortedChannel,cadences,medianPixelUnc(:,idxSortedChannel));
    xlabel('channel');
    ylabel('cadence');
    zlabel('median pixel uncertainty (sigma)');
    title('Median Background Pixel Uncertainty Normalized to Standard Deviation Over Cadences');

    figure;
    plot(channel,nanmedian(medianPixelUnc),'o');
    grid;
    xlabel('channel');
    ylabel('median pixel uncertainty (sigma)');
    title('Median Background Pixel Uncertainty Normalized to Standard Deviation Over Cadences');

    % some image plots

    % mean fitted background - channels x cadence
    figure;
    imagesc(1:length(sortedChannel),cadences,meanValue(:,idxSortedChannel));
    axis xy;
    colorbar;
    apply_white_nan_colormap_to_image;
    set(gca,'XTick',1:length(sortedChannel));
    set(gca,'XTickLabel',sortedChannel);
    set(gca,'FontWeight','bold');
    xlabel('\bf\fontsize{12}channel #');
    ylabel('\bf\fontsize{12}cadence #');
    title('\bf\fontsize{14}Fitted Mean Background Level (e-/LC)');

    % mean fitted background w/median removed - channels x cadence
    figure;
    imagesc(1:length(sortedChannel),cadences,meanValue(:,idxSortedChannel)-ones(length(cadences),1)*nanmedian(meanValue(:,idxSortedChannel)));
    axis xy;
    colorbar;
    apply_white_nan_colormap_to_image;
    set(gca,'XTick',1:length(sortedChannel));
    set(gca,'XTickLabel',sortedChannel);
    set(gca,'FontWeight','bold');
    xlabel('\bf\fontsize{12}channel #');
    ylabel('\bf\fontsize{12}cadence #');
    title('\bf\fontsize{14}Fitted Mean Background Level Delta From Median (e-/LC)');

    % median background fit residual
    figure;
    imagesc(1:length(sortedChannel),cadences,medianResidual(:,idxSortedChannel));
    colorbar;
    caxis([-1 1]);
    axis xy;
    apply_white_nan_colormap_to_image;
    set(gca,'FontWeight','bold');
    set(gca,'XTick',1:length(sortedChannel));
    set(gca,'XTickLabel',sortedChannel);
    xlabel('\bf\fontsize{12}channel #');
    ylabel('\bf\fontsize{12}cadence #');
    title('\bf\fontsize{14}Median Background Fit Residual (sigma)');

    % mad background fit residual
    figure;
    imagesc(1:length(sortedChannel),cadences,madResidual(:,idxSortedChannel));
    caxis([0, prctile(madResidual(:),95)]);
    colorbar;
    axis xy;
    apply_white_nan_colormap_to_image;
    set(gca,'FontWeight','bold');
    set(gca,'XTick',1:length(sortedChannel));
    set(gca,'XTickLabel',sortedChannel);
    xlabel('\bf\fontsize{12}channel #');
    ylabel('\bf\fontsize{12}cadence #');
    title('\bf\fontsize{14}MAD Background Fit Residual (sigma)');

end