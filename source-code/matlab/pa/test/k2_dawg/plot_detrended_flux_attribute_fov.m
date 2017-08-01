function  h = plot_detrended_flux_attribute_fov( paRootPath, varargin )
%**************************************************************************
% h = plot_detrended_flux_attribute_fov( paRootPath, varargin )
%**************************************************************************
% Generate a color-coded FOV plot of a user-defined attribute (standard
% deviation by default) of detrended light curves for a given quarter or 
% campaign. The result for each target is plotted at the location of its
% flux-weighted centroid.
%
% This function was designed to aid in assessing the effects of thruster
% activity on raw light curves.
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
%     'attributeFun'        A function handle. The function must accept a
%                           vector of flux values and return a single
%                           numeric value (default: @(x)(log10(std(x))) ). 
%     'colorbarLabel'       A string to displayvertically along the
%                           colorbar. 
%     'medFiltWidth'        The window width (cadences) of the detrending
%                           median filter (default is two times the maximum
%                           thruster firing period).
%     'quarterOrCampaign'   A non-negative integer. The paRootPath
%                           directory may contain results for multiple
%                           quarters or campaigns. In such cases you may
%                           specify the quarter or campaign to examine. By
%                           default the lowest numbered quarter or campaign
%                           is processed.
%     'magnitudeRange'      A two element vector defining lower and upper
%                           magnitude bounds. Only targets within the
%                           specified range are considered.
%     'colorRange'          Either an empty matrix or a two-element vector
%                           specifying the lower and upper values,
%                           respectively, represented by the colormap. 
%     'excludeCustomTargs'  If true (the default), do not plot custom
%                           targets.
%     'plotLightCurves'     If true, plot the raw light curve, the
%                           identified trend, and the detrended light curve
%                           for each target (default = false).                       
%
% OUTPUTS
%     h                     The figure handle.
%
% NOTES
%   - Rather than supplying a 'colorRange' argument you can use the caxis()
%     command after the plots have been generated.
% 
% USAGE EXAMPLES
%     Plot mean and standard deviation of residuals on mod.out 18.1:
%
%     >> paRootPath = ~/c3-for-archive-ksop2211/lc/pa2/pid-997
%     >> plot_detrended_flux_attribute_fov(paRootPath, ...
%        'attributeFun', @(x)(log10(std(x))), ...
%        'colorbarLabel', 'log10 of STD', 'magnitudeRange', [0, 14] );
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
    MAX_SAWTOOTH_PERIOD_CADENCES = 36; % 18 hours
    MARKER_SIZE = 100;
    
    defaultWidth = 2 * MAX_SAWTOOTH_PERIOD_CADENCES;
    
    %----------------------------------------------------------------------
    % Parse and validate arguments.
    %----------------------------------------------------------------------
    parser = inputParser;
    parser.addRequired('paRootPath',                          @(s)isdir(s)                             );
    parser.addParamValue('channelOrModout',          [1:84]', @validate_channels_and_modouts           );
    parser.addParamValue('attributeFun', @(x)(log10(std(x))), @(x)isa(x, 'function_handle')            );
    parser.addParamValue('colorbarLabel',                 '', @(s)ischar(s)  || iscellstr(s)           );
    parser.addParamValue('medFiltWidth',        defaultWidth, @(x)isnumeric(x) && x == fix(x) && x > 0 );
    parser.addParamValue('quarterOrCampaign',             [], @(x)isempty(x) || isnumeric(x) && x>=0   );
    parser.addParamValue('magnitudeRange',                [], @(x)isnumeric(x) && length(x) == 2       );
    parser.addParamValue('colorRange',                    [], @(x)isnumeric(x) && length(x) == 2       );
    parser.addParamValue('excludeCustomTargs',          true, @(x)islogical(x) && length(x) == 1     );
    parser.addParamValue('plotLightCurves',            false, @(x)islogical(x) && length(x) == 1     );
    parser.parse(paRootPath, varargin{:});
    
    channelOrModout    = parser.Results.channelOrModout;
    attributeFun       = parser.Results.attributeFun;
    colorbarLabel      = parser.Results.colorbarLabel;
    medFiltWidth       = parser.Results.medFiltWidth;
    quarterOrCampaign  = parser.Results.quarterOrCampaign;
    magnitudeRange     = parser.Results.magnitudeRange;
    clim               = parser.Results.colorRange;
    excludeCustomTargs = parser.Results.excludeCustomTargs;
    plotLightCurves    = parser.Results.plotLightCurves;
    
    % Force median filter window size to be odd.
    if mod(medFiltWidth, 2) == 0
        medFiltWidth = medFiltWidth + 1;
    end

    nChannels = size(channelOrModout, 1);
        
    titleString  = 'Summary of Detrended Light Curves';
    
    
    %----------------------------------------------------------------------
    % Draw the focal plane array, set the title, and set the colormap and
    % color bar label. 
    %----------------------------------------------------------------------
    h = figure;
    pad_draw_ccd( 1:42 );
    hold on
    
    title(titleString, 'FontSize', 14, 'FontWeight', 'bold');

    cmap = jet;
    colormap(cmap);
    if ~isempty(clim)
        caxis(clim);
    end
    
    hcb = colorbar;
    yLabelHandle = get(hcb,'ylabel');
    set(yLabelHandle ,'String', colorbarLabel );

    groupDirCellArray = get_group_dir( 'PA', channelOrModout, ...
            'rootPath', paRootPath, 'quarter', quarterOrCampaign);

    %----------------------------------------------------------------------
    % Process and plot each of the specified channels. 
    %----------------------------------------------------------------------
    for iChannel = 1:nChannels
        channelDir = groupDirCellArray{iChannel};
        
        fprintf('Processing channel %d of %d directory = %s ... \n', ...
            iChannel, nChannels, channelDir);
        
        if isempty(channelDir)
            continue;
        end
                
        load( fullfile(channelDir, 'pa_state.mat'), 'paTargetStarResultsStruct' );
            targetStarResultsStruct = paTargetStarResultsStruct;
            clear paTargetStarResultsStruct
            
        % Prune targets outside the specified magnitude range.
        if ~isempty(magnitudeRange)
            fprintf('Excluding targets with magnitudes outside the range %0.2f <= kmag <= %0.2f\n', ...
                min(magnitudeRange), max(magnitudeRange));
            keplerMag = [targetStarResultsStruct.keplerMag];
            pruneIndicators = keplerMag < min(magnitudeRange) | keplerMag > max(magnitudeRange);
            targetStarResultsStruct(pruneIndicators) = [];
        end
        
        % Prune custom targets
        if excludeCustomTargs
            fprintf('Excluding custom targets.\n') 
            keplerId = [targetStarResultsStruct.keplerId];
            pruneIndicators = is_valid_id(keplerId, 'custom');
            targetStarResultsStruct(pruneIndicators) = [];
        end
        
        if isempty(targetStarResultsStruct)
            continue;
        end
        
        % Detrend the flux time series and derive the attribute we wish to
        % plot.
        attributeArray = analyze_detrended_flux_time_series( ...
            targetStarResultsStruct, medFiltWidth, ...
            'attributeFun', attributeFun, 'plotLightCurves', plotLightCurves);
        
        % Compute median centroid positions.
        [medianCentroidRow, medianCentroidCol] = ...
            compute_median_centroid_positions(targetStarResultsStruct);

        % Plot target positions and attributes on FOV figure.
        if size(channelOrModout, 2) == 1
            [module, output] = convert_to_module_output(channelOrModout(iChannel));
        else
            module = channelOrModout(iChannel, 1);
            output = channelOrModout(iChannel, 2);
        end
        [z, y] = morc_to_focal_plane_coords( ...
            module * ones(size(medianCentroidRow)), ...
            output * ones(size(medianCentroidRow)), ...
            medianCentroidRow, medianCentroidCol, 'one-based' );
        
        scatter(z, y, MARKER_SIZE, attributeArray, 'filled', 'marker', 'o');
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
function [medianCentroidRow, medianCentroidCol] = ...
    compute_median_centroid_positions(targetStarResultsStruct)

    centroidFieldName = 'fluxWeightedCentroids';
    
    % Get centroid time series for every target.
    nTargets = numel(targetStarResultsStruct);
    nCadences = length(targetStarResultsStruct(1).fluxTimeSeries.values);
    centroidRow = zeros(nCadences, nTargets);
    centroidCol = zeros(nCadences, nTargets);
    gaps        = false(nCadences, nTargets);
    for iTarget = 1:nTargets
        centroidRow(:, iTarget) = targetStarResultsStruct(iTarget).(centroidFieldName).rowTimeSeries.values;
        centroidCol(:, iTarget) = targetStarResultsStruct(iTarget).(centroidFieldName).columnTimeSeries.values;
        gaps(:, iTarget) = ...
            targetStarResultsStruct(iTarget).(centroidFieldName).rowTimeSeries.gapIndicators | ...
            targetStarResultsStruct(iTarget).(centroidFieldName).columnTimeSeries.gapIndicators;
    end

    % Compute median centroid positions.
    medianCentroidRow = nan(nTargets, 1);
    medianCentroidCol = nan(nTargets, 1);

    for iTarget = 1:nTargets
        validCadences = ~gaps(:, iTarget);   
        if any(validCadences)
            medianCentroidRow(iTarget) = median(centroidRow(validCadences, iTarget), 1);
            medianCentroidCol(iTarget) = median(centroidCol(validCadences, iTarget), 1);
        end
    end
end

%**************************************************************************
% attributeArray = analyze_detrended_flux_time_series( ...
%    targetStarResultsStruct, medFiltWidth, varargin )
%**************************************************************************
% Detrend the raw light curve in each element of targetStarResultsStruct
% using a median filter of length medFiltWidth. Then evaluate the function
% 'attributeFun' for each detrended light curve and return the results in
% attributeArray.
%
% INPUTS
%
%     targetStarResultsStruct : An nTargets-length struct array.
%
%     All remaining inputs are optional attribute/value pairs. Valid
%     attributes and values are: 
%    
%     Attribute             Value
%     ---------             -----
%     'attributeFun'        A function handle. The function must accept a
%                           vector of flux values and return a single
%                           numeric value (default: @(x)(log10(std(x))) ). 
%     'medFiltWidth'        The window width (cadences) of the detrending
%                           median filter (default is two times the maximum
%                           thruster firing period).
%     'plotLightCurves'     If true, plot the raw light curve, the
%                           identified trend, and the detrended light curve
%                           for each target (default = false).                       
% OUTPUTS
%     attributeArray      : A nTargets-length array, each element
%                           contianing the value of 'attributeFun' computed
%                           for the (detrended) light curve from the
%                           corresponding entry in targetStarResultsStruct.  
%
% NOTES
%     attributeArray(i) = attributeFun( ...
%         detrend(targetStarResultsStruct(i).fluxTimeSeries))
%
% USAGE EXAMPLES
% 
%**************************************************************************
function  attributeArray = analyze_detrended_flux_time_series( ...
    targetStarResultsStruct, medFiltWidth, varargin )

    %----------------------------------------------------------------------
    % Parse and validate arguments.
    %----------------------------------------------------------------------
    parser = inputParser;
    parser.addRequired('targetStarResultsStruct',             @(s)isstruct(s)                          );
    parser.addRequired('medFiltWidth',                        @(x)isnumeric(x) && x == fix(x) && x > 0 );
    parser.addParamValue('attributeFun', @(x)(log10(std(x))), @(x)isa(x, 'function_handle')            );
    parser.addParamValue('plotLightCurves',            false, @(x)islogical(x) && length(x) == 1       );
    parser.parse(targetStarResultsStruct, medFiltWidth, varargin{:});
    
    attributeFun = parser.Results.attributeFun;
    plotLightCurves = parser.Results.plotLightCurves;
    
    % Force median filter window size to be odd.
    if mod(medFiltWidth, 2) == 0
        medFiltWidth = medFiltWidth + 1;
    end
    
    nTargets       = numel(targetStarResultsStruct);
    attributeArray = nan(nTargets, 1);
        
    %----------------------------------------------------------------------
    % Compute the specified attribute of each light curve.
    %----------------------------------------------------------------------
    for iTarget = 1:nTargets
        flux = targetStarResultsStruct(iTarget).fluxTimeSeries.values;
        gaps = targetStarResultsStruct(iTarget).fluxTimeSeries.gapIndicators;
        [detrended, trend] = medfilt_detrend_with_linear_gap_fill( flux, gaps, medFiltWidth);
        
        validCadences = ~gaps;  
        if any(validCadences)
            attributeArray(iTarget) = attributeFun(detrended(validCadences));
        end
        
        if plotLightCurves
            
            % Plot the trend against the raw light curve.
            subplot(2, 1, 1);
            hold off
            plot(replace_with_nan( flux, gaps ), 'b');
            hold on
            grid on
            plot(replace_with_nan( trend, gaps ), 'g');
           
            % Plot the detrended light curve.
            subplot(2, 1, 2);
            hold off
            plot(replace_with_nan( detrended, gaps ), 'k');
            grid on
            
            pause
        end
    end        
end


%**************************************************************************  
% [detrended, trend] = 
%     medfilt_detrend_with_linear_gap_fill( ts, gapIndicators, medfiltLen )
%**************************************************************************  
% Detrend a time series.
%
% INPUTS:
%     ts            : An N-length real array representing a time series.
%     gapIndicators : An N-length logical array of gap indicators. If 
%                     gapIndicators(i) == true, then ts(i) is treated as
%                     missing data.
%     medfiltLen    : Optional window size for the median filter. 
%
% OUTPUTS:
%     detrended     : ts - trend.
%     trend         : The median filter output after filling gaps and
%                     extending endpoints. 
%
%************************************************************************** 
function [detrended, trend] = ...
    medfilt_detrend_with_linear_gap_fill( ts, gapIndicators, medfiltLen)

    if ~exist('gapIndicators','var')
        gapIndicators = false(size(ts));
    end

    if ~exist('medfiltLen','var')
        medfiltLen = 49;
    end

    filled = linear_gap_fill(ts, gapIndicators);
    trend  = padded_median_filter(filled(:), medfiltLen);
    
    % Return a vector of the same dimensions as ts.
    detrended = reshape(filled(:) - trend, size(ts));
end


%**************************************************************************  
% filled = linear_gap_fill(ts, gapIndicators);
%**************************************************************************  
% Fill gaps by coarse linear interpolation.
%
% INPUTS:
%     ts             : An N-length real-valued array representing a time
%                      series. 
%     gapIndicators  : An N-length logical array of gap indicators.
%
% OUTPUTS:
%     filled         : A copy of ts with gaps filled.
%
%************************************************************************** 
function filled = linear_gap_fill(ts, gapIndicators)
    filled = ts;

    leftOfGaps  = find(diff(gapIndicators(:)) > 0 );
    rightOfGaps = find(diff([0; gapIndicators(:)]) < 0 );
    
    % Handle cases where leftOfGaps or rightOfGaps are empty.
    if isempty(leftOfGaps) 
        if ~isempty(rightOfGaps)
            filled(1:rightOfGaps(1)) = ts(rightOfGaps(1));
        end
        return;
    elseif isempty(rightOfGaps)
        filled(leftOfGaps(end):end) = ts(leftOfGaps(end));
        return;
    end
    
    % Handle gaps at the beginning of the time series by filling with the
    % first valid value. 
    if rightOfGaps(1) - leftOfGaps(1) <= 0
        filled(1:rightOfGaps(1)) = ts(rightOfGaps(1));
        rightOfGaps(1) = [];
    end
    
    % Handle gaps at the end of the time series by filling with the last
    % valid value. Since we may have removed the first element of
    % rightOfGaps, we need to check it again.
    if  isempty(rightOfGaps) || rightOfGaps(end) - leftOfGaps(end) <= 0
        filled(leftOfGaps(end):end) = ts(leftOfGaps(end));
        leftOfGaps(end) = [];
    end
    
    % Fill in remaining gaps away from endpoints. Do nothing if leftOfGaps
    % is empty. 
    for i = 1:length(leftOfGaps)
       x0 = leftOfGaps(i);
       x1 = rightOfGaps(i);
       y0 = filled(leftOfGaps(i));
       y1 = filled(rightOfGaps(i));
       x  = leftOfGaps(i)+1:rightOfGaps(i)-1;
       filled(x) = ((x-x0)*y1 + (x1-x)*y0)/(x1-x0);
    end
    
end


%**************************************************************************
% filteredMat = padded_median_filter( columnVectorMat, filterLength )
%**************************************************************************  
% We extend the time series prior to median filtering in order to mitigate
% edge effects. In the future a more sophisticated approach may yield
% better results. A periodic extension (reflect and flip) might work well.
%
% INPUTS:
%     columnVectorMat : A matrix of column vectors.
%     filterLength    : An integer.
%
% OUTPUTS:
%     filteredMat     : A matrix of median-filtered columns.
%
%**************************************************************************  
function filteredMat = padded_median_filter( columnVectorMat, filterLength )
    padLen = fix(filterLength/2);
    topPad = repmat(columnVectorMat(1,:),[padLen 1]);
    bottomPad = repmat(columnVectorMat(end,:),[padLen 1]);
    filteredMat = medfilt1([topPad; columnVectorMat; bottomPad], ...
                     filterLength);
    filteredMat = filteredMat(padLen+1:end-padLen,:);
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
