function  [h, argaEvents] = plot_argabrightening_mitigation( paRootPath, varargin )
%**************************************************************************
% h = analyze_argabrightening_mitigation( paRootPath, varargin )
%**************************************************************************
% Generate a plot of median fitted background flux for all specified
% channels with Argabrightening cadences marked. 
%
%     paRootPath     The full path to the directory containing task 
%                    directories for the pipeline instance (this is the
%                    directory containing the uow/ subdirectory). If
%                    unspecified, the current working directory is used.
%
%     All remaining inputs are optional attribute/value pairs. Valid
%     attributes and values are: 
%    
%     Attribute             Value
%     ---------             -----
%     'channelOrModout'     A N-by-1 or N-by-2 array of channels to
%                           examine.
%     'quarterOrCampaign'   A non-negative integer. The paRootPath
%                           directory may contain results for multiple
%                           quarters or campaigns. In such cases you may
%                           specify the quarter or campaign to examine. By
%                           default the lowest numbered quarter or campaign
%                           is processed.
% OUTPUTS
%     h                     The figure handle.
%     argaEvents            An nEvents-length struct array. Each struct 
%                           specifies the cadence and channels on which the
%                           event was detected.  
% NOTES
% 
% USAGE EXAMPLES
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
    ARGA_MARKER_COLOR = 'g';
    ARGA_MARKER_STYLE = '-';
    ARGA_MARKER_WIDTH = 3.0;
    GAP_MARKER_COLOR  = [0.7, 0.7, 0.7];
    GAP_MARKER_STYLE  = '-';
    GAP_MARKER_WIDTH  = 3.0;
    
    TITLE_FONT_SIZE   = 12;
    
    %----------------------------------------------------------------------
    % Parse and validate arguments.
    %----------------------------------------------------------------------
    parser = inputParser;
    parser.addRequired('paRootPath',                          @(s)isdir(s)                             );
    parser.addParamValue('channelOrModout',          [1:84]', @validate_channels_and_modouts           );
    parser.addParamValue('quarterOrCampaign',             [], @(x)isempty(x) || isnumeric(x) && x>=0   );
    parser.parse(paRootPath, varargin{:});
    
    channelOrModout    = parser.Results.channelOrModout;
    quarterOrCampaign  = parser.Results.quarterOrCampaign;
                
    titleString  = 'Argabrightening Cadences and Median Calibrated Background Value';
    
    
    groupDirCellArray = get_group_dir( 'PA', channelOrModout, ...
            'rootPath', paRootPath, 'quarter', quarterOrCampaign);
    isValidGroupDir = cellfun(@(x)~isempty(x), groupDirCellArray);
    if ~any(isValidGroupDir)
        return
    end
    
    groupDirCellArray = groupDirCellArray(isValidGroupDir);
    if size(channelOrModout, 2) == 2
        modouts  = channelOrModout(isValidGroupDir, :);
        channels = convert_from_module_output(channelOrModout(isValidGroupDir,1), channelOrModout(isValidGroupDir,2));
    else
        channels = channelOrModout(isValidGroupDir);
        [m, o]  = convert_to_module_output(channelOrModout(isValidGroupDir, :));
        modouts = [m,o];
    end

    nChannels = length(channels);

    % Determine the number of cadences.
    load( fullfile(groupDirCellArray{find(isValidGroupDir, 1)}, ...
        'pa_state.mat'), 'isArgaCadence');
    nCadences = length(isArgaCadence);

    legendLabels   = {};    
    cadenceNumbers = [];
    medianBackground = nan(nCadences, nChannels);
    argaIndicators = false(nCadences, nChannels);
    gapIndicators  = false(nCadences, nChannels);

    %----------------------------------------------------------------------
    % Process and plot each of the specified channels. 
    %----------------------------------------------------------------------
    for iChannel = 1:nChannels
        channelDir = groupDirCellArray{iChannel};
        
        fprintf('Processing channel %d of %d directory = %s ... \n', ...
            iChannel, nChannels, channelDir);
                        
        load( fullfile(channelDir, 'pa_state.mat'), 'isArgaCadence', 'argaCadences', 'argaStatistics');
        load( fullfile(channelDir, 'st-0', 'pa-inputs-0.mat'));
                        
        argaIndicators(:, iChannel) = isArgaCadence;
        
        bgMat  = [inputsStruct.backgroundDataStruct.values];
        gapMat = [inputsStruct.backgroundDataStruct.gapIndicators];
        bgMat(gapMat) = nan;
        medianBackground(:, iChannel) = nanmedian(bgMat, 2);
        
        if isempty(cadenceNumbers)
            cadenceNumbers = inputsStruct.startCadence:inputsStruct.endCadence;
        end
        
        legendLabels(end+1) = {sprintf('%d.%d', modouts(iChannel, 1), modouts(iChannel, 2))};
    end

    %----------------------------------------------------------------------
    % Construct an array of Arga event structures. 
    %----------------------------------------------------------------------
    argaCadences = find(sum(argaIndicators, 2));
    argaEvents = struct('cadence', num2cell(argaCadences), 'channels', []);
    for iEvent = 1:numel(argaEvents)
        argaIndicatorsThisCadence = argaIndicators(argaEvents(iEvent).cadence, :);
        argaEvents(iEvent).channels = ...
            channelOrModout( argaIndicatorsThisCadence, :);
    end
    
    %----------------------------------------------------------------------
    % Create the plot. 
    %----------------------------------------------------------------------
    h = figure('color', 'white');
    plot(cadenceNumbers, medianBackground);
    grid;
    xlabel('cadences');
    ylabel('median value (e-)');
    title(titleString, 'FontSize', TITLE_FONT_SIZE, 'FontWeight', 'bold');
    %legend(legendLabels, 'Location', 'BestOutside');
    
    x = cadenceNumbers(1);
    y = medianBackground(1,:);
    for iChannel = 1:nChannels
        text(x, y(iChannel), legendLabels{iChannel}, 'HorizontalAlignment', 'right');
    end
    
    % Mark Argabrightening cadences. 
    for iEvent = 1:numel(argaEvents)
        cadenceNum = cadenceNumbers(argaEvents(iEvent).cadence);
        nChannelsThisEvent = size(argaEvents(iEvent).channels, 1);
        height = nChannelsThisEvent / nChannels;
        mark_cadences(gca, cadenceNum, height, ...
            ARGA_MARKER_COLOR, ARGA_MARKER_STYLE, ARGA_MARKER_WIDTH);
    end
    
    % Mark gaps. 
    x = sum(gapIndicators, 2);
    gapIndices = find(x);
    for iGap = 1:length(gapIndices)
        gapIndex = gapIndices(iGap);
        cadenceNum = cadenceNumbers(gapIndex);
        height = x(gapIndex) / nChannels;
        mark_cadences(gca, cadenceNum, height, ...
            GAP_MARKER_COLOR, GAP_MARKER_STYLE, GAP_MARKER_WIDTH);
    end
      
end

%**************************************************************************
function isValid = validate_channels_and_modouts(x)
    if size(x, 2) == 1
        isValid = validate_channels(x);
    elseif size(x, 2) == 2
        isValid = validate_modouts(x);
    else
        isValid = false; % x must be N-by-1 or N-by-2.
    end
end

%**************************************************************************
function isValid = validate_channels(x)
    isValid = isnumeric(x) &&  min(size(x)) == 1 ...
        && all(ismember(x, [1:84]));
end

%**************************************************************************
function isValid = validate_modouts(x)
    isValid = size(x,2) == 2 && ...
        all(ismember(x(:,1), [2:24])) && ...
        all(ismember(x(:,2), [1:4]));
end

%**************************************************************************  
% p = mark_cadences(h, cadences, height, color, style, width)
%**************************************************************************  
% INPUTS:
%     h             : An axes handle or [] to use current axes.
%     cadences      : List of relative cadences (indices) to mark.
%     height        : A scalar in the range [0, 1.0] (default = 1.0)
%     color         : The value of 'Color' passed to plot() (default =
%                     [0.7 0.7 0.7]). 
%     style         : The value of 'LineStyle' passed to plot() (default =
%                     '-').
%     width         : The value of 'LineWidth' passed to plot() (default =
%                     0.5).
%**************************************************************************        
function mark_cadences(h, cadences, height, color, style, width)
    if ~any(cadences)
        return
    end

    if ~ishandle(h)
        h = gca;
    end
        
    if ~exist('height','var')
        height = 1.0;
    end
    
    if ~exist('color','var')
        color = [0.7 0.7 0.7];
    end

    if ~exist('style','var')
        style = '-';
    end

    if ~exist('width','var')
        width = 0.5;
    end

    axes(h);
    
    original_hold_state = ishold(h);
    if original_hold_state == false
        hold on
    end

    nCadences = length(cadences);
    yLimits = ylim;
    markerXCoords = reshape([cadences(:)';cadences(:)'; nan(1, nCadences)], 3*nCadences, 1);
    markerYCoords = repmat([yLimits(1); yLimits(1) + height * (yLimits(2) - yLimits(1)); nan], nCadences, 1);
    plot(markerXCoords, markerYCoords, 'LineStyle',style,'Color', color, 'LineWidth', width);
        
    for iCadence = 1:length(cadences)
        text(cadences(iCadence), yLimits(1), ...
           sprintf('Arga event identified on %d %% of channels', ...
           round(height * 100)), 'Rotation', 90);
    end
    
    if original_hold_state == false
        hold off
    end
end



%************************************************************************** 
% Replace values with NaN for plotting purposes.
%
% INPUTS
%     x   : A matrix
%     ind : An array of indices or indicators. Empty by default.
%     val : An array of values to replace. Empty by default.
%
% OUTPUTS
%     x   : A copy of x with NaN values substituted in locations specified
%           by the ind and val input arrays.
%************************************************************************** 
function x = replace_with_nan( x, ind, val )

    if ~exist('val', 'var')
        val = [];
    end

    if ~exist('ind', 'var')
        ind = [];
    end

    x(ind) = NaN;
    x(ismember(x, val)) = NaN;

end


%********************************** EOF ***********************************
