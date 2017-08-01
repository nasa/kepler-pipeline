function  h = plot_mp_centroid_residuals_fov( paRootPath, varargin )
%**************************************************************************
% h = plot_mp_centroid_residuals_fov( paRootPath, varargin )
%**************************************************************************
% 
%
% INPUTS
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
%     'plotPpa'             A logical scalar (default = true). If true,
%                           load and use PRF centroid results for PPA 
%                           targets. Otherwise plot all targets using
%                           flux-weighted centroids as the reference.
%     'residualFun'         A function handle. The function must accept a
%                           nCadences-by-nTargets matrix of residual
%                           values and return a nTargets-length array of
%                           numeric values (default: @(x)median(x) ). 
%     'quarterOrCampaign'   A non-negative integer. The paRootPath
%                           directory may contain results for multiple
%                           quarters or campaigns. In such cases you may
%                           specify the quarter or campaign to examine. By
%                           default the lowest numbered quarter or campaign
%                           is processed.
%     'colorbarLabel'       A string to displayvertically along the
%                           colorbar. 
%     'colorrange'          Either an empty matrix or a two-element vector
%                           specifying the lower and upper values,
%                           respectively, represented by the colormap. 
%     'markerSize'          The value of 'SizeData' passed to scatter()
%                           (default = 100).
%
% OUTPUTS
%     h
%
% NOTES
%   - Rather than supplying a 'colorrange' argument you can use the caxis()
%     command after the plots have been generated.
% 
% USAGE EXAMPLES
%     Plot mean and standard deviation of residuals on mod.out 18.1:
%
%     >> paRootPath = '/path/to/ksop-2128/lc/pa1'
%     >> plot_mp_centroid_residuals_fov( paRootPath, ...
%        'residualFun', @(x)log10(mean(x)), ...
%        'colorbarLabel', 'Log10 Mean Residual (pixels)' );
%     >> plot_mp_centroid_residuals_fov( paRootPath, ...
%        'residualFun', @(x)std(x), ...
%        'colorbarLabel', 'Residual Standard Dev (pixels)', ...
%        'channelOrModout', [18, 1] );
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

    DEFAULT_MARKER_SIZE = 100;
    
    %----------------------------------------------------------------------
    % Parse and validate arguments.
    %----------------------------------------------------------------------
    parser = inputParser;
    parser.addRequired('paRootPath',                        @(s)isdir(s)                       );
    parser.addParamValue('channelOrModout',        [1:84]', @validate_channels_and_modouts     );
    parser.addParamValue('plotPpa',                   true, @(x)islogical(x) && length(x) == 1 );
    parser.addParamValue('residualFun',            @median, @(x)isa(x, 'function_handle')      );
    parser.addParamValue('colorbarLabel',               '', @(s)ischar(s)  || iscellstr(s)     );
    parser.addParamValue('quarterOrCampaign',           [], @(x)isempty(x) || isnumeric(x) && x>=0 );
    parser.addParamValue('colorrange',                  [], @(x)isnumeric(x) && length(x) == 2 );
    parser.addParamValue('markerSize', DEFAULT_MARKER_SIZE, @(x)isnumeric(x) );
    parser.parse(paRootPath, varargin{:});
    
    plotPpa           = parser.Results.plotPpa;
    residualFun       = parser.Results.residualFun;
    colorbarLabel     = parser.Results.colorbarLabel;
    quarterOrCampaign = parser.Results.quarterOrCampaign;
    channelOrModout   = parser.Results.channelOrModout;
    clim              = parser.Results.colorrange;
    markerSize        = parser.Results.markerSize;
    
    nChannels = size(channelOrModout, 1);
        
    if plotPpa
        centroidType = 'prf';
        titleString  = {'PPA Target Residual Summary',  '(motion poly position - PRF centroid)'};
    else
        centroidType = 'fw';
        titleString  = {'All Target Residual Summary',  '(motion poly position - FW centroid)'};        
    end
    
    %----------------------------------------------------------------------
    % Draw the focal plane array, set the title, and set the colormap and
    % color bar label. 
    %----------------------------------------------------------------------
    h = figure('color', 'white');
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
                
        load( fullfile(channelDir, 'pa_state.mat'), 'motionPolyStruct' );
        
        if plotPpa
            load( fullfile(channelDir, 'pa_state.mat'), 'ppaTargetStarResultsStruct' );
            targetStarResultsStruct = ppaTargetStarResultsStruct;
            clear ppaTargetStarResultsStruct
        else
            load( fullfile(channelDir, 'pa_state.mat'), 'paTargetStarResultsStruct' );
            targetStarResultsStruct = paTargetStarResultsStruct;
            clear paTargetStarResultsStruct
        end
        
        [medianCentroidCol, medianCentroidRow, residualMetric] = ...
            summarize_mp_centroid_residuals( motionPolyStruct, ...
                targetStarResultsStruct, 'centroidType', centroidType, 'residualFun', residualFun);

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
        
        scatter(z, y, markerSize, residualMetric, 'filled', 'marker', 'o');
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

%********************************** EOF ***********************************
