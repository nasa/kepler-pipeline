% classdef fovPlottingClass
% Tools class to compile and plot various metrics across for all CCD channels
% Currently just a collection of static methods, in lack of Matlab's support for namespaces
%
% See plot_on_modout for the main function to genrate the plot
%
% METHODS:
%
%   goodness = compile_goodness_from_taskdirs
%   plot_goodness_on_ccd(goodness)
%
%   [taskdirList taskdirMatrix] = parse_taskdirs(csv_fn)
%   plot_on_modout(module,output,data,varargin)
%   plot_modout_grid
%   make_ccd_legend_plot
%   [row,column] = modout2rowcolumn(module,output)
%
%
% SIMPLE INSTRUCTIONS to plot goodness metrics:
%   1. run "goodness = fovPlottingClass.compile_goodness_from_taskdirs"
%      in the directory containing the task files and the i*.csv file
%   2. run "fovPlottingClass.plot_goodness_on_ccd(goodness)"
%
% TO PLOT A SINGLE QUARTER ANALYSIS:
%   1. [perTargetStatistics] = fovPlottingClass.compile_per_target_statistics_from_taskDirs ,<quarter>, [], true, false)
%   2. [fovStatistics] = fovPlottingClass.generate_fov_figures_and_statistics (perTargetStatistics, true, [], [<lowMag> <hihgMag>])
%
% TO DO A COMPLETE MULTI-QUARTER PDC RUN GOODNESS ANALYSIS DO THIS:
%   1. perTargetStatisticsAllQuarters = fovPlottingClass.compile_per_target_statistics_for_all_quarters(dataSaveDir, quarterRange, false)
%   2. fovPlottingClass.generate_fov_figures_all_magnitude_ranges(perTargetStatisticsAllQuarters, figureSaveDir, [])
%
%
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

classdef fovPlottingClass


properties(GetAccess = 'public', Constant = true)
    nChannels = 84;
end

%*********************************************************************************************************
%*********************************************************************************************************
%*********************************************************************************************************
% Methods for plotting the FOV for any data
methods (Static, Access='public')

    %*********************************************************************************************************
    %% plot_on_modout
    %
    % function plot_on_modout(module,output,data,colorrange)
    %
    % Inputs:
    %   module      -- [int array] list of modules to plot corresponding to the data array (example: [1:25])
    %   output      -- [int array] list of outputs to plot (exmaple: [1,2,3,4,1,2,3,4,...]
    %   data        -- [float array] list of values to plot for each mod.out
    %   colorrange: -- [float 2x1 array OPTIONAL] range for fixed colorrange
    %   figureHandle-- [int] use this figure handle, if empty generate one
    %
    % Outputs:
    %   figureHandle    -- [int] the figure handle of the figure plotted
    %

    function [figureHandle] = plot_on_modout(module,output,data,varargin)

        clim = [];
        if (~isempty(varargin))
            clim = varargin{1};
            if (length(clim)~=2)
                disp('colorrange must be a 2 element vector, or not provided at all');
                return
            end

            if length(varargin) > 1
                figureHandle = varargin{2};
            end
        end
 
        if (~exist('figureHandle', 'var'))
            figureHandle = figure;
        else
            figure(figureHandle);
        end


        ccd = zeros(11,11);
        ccd(:) = nan; % or 0
        for i=1:length(data)
            [r,c] = fovPlottingClass.modout2rowcolumn(module(i),output(i));
            if (~isempty(r) && ~isempty(c) && (~isnan(r)) && (~isnan(c)))
                ccd(r,c) = data(i);
            end
        end
        p_ = pcolor(ccd);    
        set(gca,'ydir','reverse');
        daspect([1 1 1]);
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        if (~isempty(clim))
            caxis(clim);
        end
        colorbar;
 
        % disable edges
        set(p_,'LineStyle','none');
 
        % and draw manual grid
        hold on;
        fovPlottingClass.plot_modout_grid (figureHandle);

    end

    %*************************************************************************************************************
    % Plots a module output grid
    %
    % Inputs:
    %   figureHandle    -- [int (optional)] If present then plots the mod.out designation on this figure, otherwise creates a new figure 
    %
    % Outputs:
    %   figureHandle    -- [int] the figure plotted to
    %

    function [figureHandle] = plot_modout_grid (varargin)

        if (~isempty(varargin))
            figureHandle = varargin{1};
            figure(figureHandle);
        else
            figureHandle = figure;
        end
        
        hold on;

        % bold module edges
        plot([3 3;5 5;7 7;9 9]',[1 11;1 11;1 11;1 11]','k-','linewidth',2);    
        plot([1 11;1 11;1 11;1 11]',[3 3;5 5;7 7;9 9]','k-','linewidth',2);    

        % thin output edges
        plot([2 2;4 4;6 6;8 8;10 10]',[1 11;1 11;1 11;1 11;1 11]','k-','linewidth',0.5);    
        plot([1 11;1 11;1 11;1 11;1 11]',[2 2;4 4;6 6;8 8;10 10]','k-','linewidth',0.5);    

        % Blacken the fine guidance modules
        fill([1 3 3 1], [1 1 3 3], 'k');
        fill([9 11 11 9], [1 1 3 3], 'k');
        fill([1 3 3 1], [9 9 11 11], 'k');
        fill([9 11 11 9], [9 9 11 11], 'k');

    end
    
    %*********************************************************************************************************
    %% make_ccd_legend_plot 
    %
    % Generates a legend plot showing the mod.out designations for each mod,out
    %
    % Inputs:
    %   figureHandle    -- [int (optional)] If present then plots the mod.out designation on this figure, otherwise creates a new figure
    %   plotChannelsNotModOuts  -- [logical OPTIONAL] If true plot channel number NOT mod.out
    %   
    %
    % Outputs:
    %   figureHandle    -- [int] the figure plotted to
    %
    function figureHandle = make_ccd_legend_plot (varargin)

        FS = 12;
        mods = [2:4 6:20 22:24];
        outs = 1:4;

        plotChannelsNotModOuts = false;

        if (~isempty(varargin))
            for iArg = 1 : length(varargin)
                if (islogical(varargin{iArg}))
                    plotChannelsNotModOuts = varargin{iArg};
                elseif (isnumeric(varargin{iArg}))
                    figureHandle = varargin{1};
                    figure(figureHandle);
                elseif (isa(varargin{iArg}, 'matlab.ui.Figure'))
                    % Matlab 2014b uses a class object for figure handle
                    figureHandle = varargin{1};
                    figure(figureHandle); 
                else
                    error('Unknown optional argument');
                end
            end
        end

        % Create a figure if one is not passed
        if (~exist('figureHandle', 'var'))
            figureHandle = figure;
            % Generarate the grid
            fovPlottingClass.plot_modout_grid (figureHandle);
            set(gca,'ydir','reverse');
            daspect([1 1 1]);
            set(gca,'xtick',[]);
            set(gca,'ytick',[]);
        end
 
        % Plot the text
        if (plotChannelsNotModOuts)
            % Plot channel number
            for m = mods
                for o = outs
                    [r,c] = fovPlottingClass.modout2rowcolumn(m,o);
                    str = int2str(convert_mod_out_to_from_channel(m, o));
                    t_ = text(c+0.5,r+0.5,str);
                    set(t_,'FontSize',FS,'HorizontalAlignment','center','VerticalAlignment','middle');            
                end
            end
            title('Channel Layout Legend');
        else
            % Plot mod.out
            for m = mods
                for o = outs
                    [r,c] = fovPlottingClass.modout2rowcolumn(m,o);
                    str = [ int2str(m) '.' int2str(o) ];
                    t_ = text(c+0.5,r+0.5,str);
                    set(t_,'FontSize',FS,'HorizontalAlignment','center','VerticalAlignment','middle');            
                end
            end
            title('Mod.Out Layout Legend');
        end
    end    

    %*********************************************************************************************************
    %% modout2rowcolumn
    % And finally, does something unkown since there is no header
    function [row,column] = modout2rowcolumn(module,output)

        % convert inputs to double, prevents rounding problems with uint
        module = double(module);
        output = double(output);
 
        % coarse first (module only)
        % map to 5x5 grid
        row = floor((module-1)/5)+1;
        column = mod(module-1,5)+1;
 
        % remap to 10x10 grid, centered
        row = row *2 -.5;
        column = column *2 -.5;
 
        % and then apply output as +- 0.5 fine modifier
        % first define offset table
 
        cyc = [ 4 3 2 1 ]; % just as dummy for invalid inputs (which are mapped to nan later)
 
        if (any(ismember([ 2 3 4 7 8 ],module)))
            cyc = [4 3 2 1];
        end
        if (any(ismember([ 6 11 12 13 16 17 ],module)))
            cyc = [3 2 1 4 ];
        end
        if (any(ismember([ 18 19 22 23 24 ],module)))
            cyc = [2 1 4 3];
        end
        if (any(ismember([ 9 10 14 15 20 ],module)))
            cyc = [1 4 3 2];
        end
        if (any(ismember([ 1 5 21 25 ],module)))
            cyc = [1 2 3 4]; % dummy
        end
 
        rowmod = [-0.5 -0.5 +0.5 +0.5];
        columnmod = [-0.5 +0.5 +0.5 -0.5];
 
        % and apply the correction
        row = row + rowmod(cyc==output);
        column = column + columnmod(cyc==output);
 
        if (any(ismember([ 0 1 5 21 25 ],module)))
            row = nan;
            column = nan;
        end

    end
        
    %*********************************************************************************************************
    %% parse_taskdirs
    % Does something (Who wrote this?)
    function [taskdirList taskdirMatrix] = parse_taskdirs(csv_fn)

        %% column description:
        % 1st column: PI_PIPELINE_INSTANCE_ID
        % 2nd column: PI_PIPELINE_INST_NODE_ID
        % 3rd column: PI_PIPELINE_TASK_ID
        % 4th column: ELEMENT
        % 5th column: MAPKEY
 
        taskdirList = repmat(struct('ccdModule',-1,'ccdOutput',-1,'taskdir',''),80,1);
        taskdirMatrix = cell(25,4);
 
        %% check if file exists
        if ~exist(csv_fn,'file')
            disp('you could at least provide a valid csv file!!');
            return
        end
 
        %% load file    
        f = fopen(csv_fn);
        a = textscan(f,'%u%u%u%u%s','headerlines',1,'delimiter',',');
 
        %% find module and output columns
        I_module = strcmp(a{5},'ccdModule');
        I_output = strcmp(a{5},'ccdOutput');
 
        %% get list of taskdirs
        unique_tasks = unique(a{3});
 
        %%
        for i=1:length(unique_tasks)
            I_taskid = (a{3} == unique_tasks(i));
            idx = find(I_taskid);
            mod = a{4}(I_taskid & I_module);
            out = a{4}(I_taskid & I_output);
            taskdirList(i).ccdModule = mod;
            taskdirList(i).ccdOutput = out;
            taskdirList(i).taskdir = ['pdc-matlab-' int2str(a{1}(idx(1))) '-' int2str(unique_tasks(i)) ];
            taskdirMatrix{mod,out} = ['pdc-matlab-' int2str(a{1}(idx(1))) '-' int2str(unique_tasks(i)) ];
        end

    end

    end % static methods

%*********************************************************************************************************
%*********************************************************************************************************
%*********************************************************************************************************
% Methods for plotting goodness values
methods (Static, Access='public')
        
    %*********************************************************************************************************
    %% plot_goodness_on_ccd(goodness)
    % function plot_goodness_on_ccd(goodness)
    %
    % INPUTS:
    %    goodness        a 80x1 struct array, as created by commpile_goodness_from_taskdirs()

    function plot_goodness_on_ccd(goodness)
        FIXEDSCALE = 0;

        %% prepare data
        mod = [ goodness(:).ccdModule ];
        out = [ goodness(:).ccdOutput ];
        for i=1:length(goodness)        
            gm_total(i) = mean(goodness(i).total);
            gm_ep(i) = mean(goodness(i).earthPoints);
            gm_noise(i) = mean(goodness(i).noise);
        gm_deltaVar(i) = mean(goodness(i).deltaVar);
        gm_corr(i) = mean(goodness(i).correlation);
        end
    
        %***
        %% plots
        % total
        if (FIXEDSCALE)
            fovPlottingClass.plot_on_modout(mod,out,gm_total,[0 1]);
        else
        fovPlottingClass.plot_on_modout(mod,out,gm_total);
        end
        title('goodness: total');

        % earthPoint
        if (FIXEDSCALE)
            fovPlottingClass.plot_on_modout(mod,out,gm_ep,[0 1]);
        else
            fovPlottingClass.plot_on_modout(mod,out,gm_ep);
        end
        title('goodness: earth points');

        % noise
        if (FIXEDSCALE)
            fovPlottingClass.plot_on_modout(mod,out,gm_noise,[0 1]);
        else
            fovPlottingClass.plot_on_modout(mod,out,gm_noise);
        end
        title('goodness: introduced noise');

        % deltaVar
        if (FIXEDSCALE)
            fovPlottingClass.plot_on_modout(mod,out,gm_deltaVar,[0 1]);
        else
            fovPlottingClass.plot_on_modout(mod,out,gm_deltaVar);
        end
        title('goodness: delta variability');

        % correlation
        if (FIXEDSCALE)
            fovPlottingClass.plot_on_modout(mod,out,gm_corr,[0 1]);
        else
            fovPlottingClass.plot_on_modout(mod,out,gm_corr);
        end
        title('goodness: correlation');

        % legend
        fovPlottingClass.make_ccd_legend_plot();    
    end

    %*********************************************************************************************************
    %% compile_goodness_from_taskdirs
    % function goodness = compile_goodness_from_taskdirs_using_goodness_figure
    % 
    % RUN IN PARENT-DIRECTORY CONTAINING THE PDC-MATLAB* DIRS AND THE i*.csv FILE
    % note: the information is actually taken from the i*.csv file, and the goodness metric plots
    %       could also get the same information from pdc-inputs-0.mat and pdc-outputs-0.mat,
    %       but that would require significantly more I/O (in particular via NFS)

    function goodness = compile_goodness_from_taskdirs_using_goodness_figure

        goodness = [];
 
        csv_fn = dir('*.csv');
        if (isempty(csv_fn))
            disp('Would it be great to go to a valid directory and try this again?');
            return
        end
 
        [taskdirList taskdirMatrix] = fovPlottingClass.parse_taskdirs(csv_fn(1).name);    
 
        d = dir('pdc*')
        if (length(d)==0)
            disp('Would it be great to go to a valid directory and try this again?');
            return
        end
 
        for i=1:length(d)
            disp(['processing ' int2str(i) '/' int2str(length(d)) '...']);
            I = strcmp({taskdirList(:).taskdir},d(i).name); % just in case the order is different
            gm(i).ccdModule = taskdirList(I).ccdModule;
            gm(i).ccdOutput = taskdirList(I).ccdOutput;
            gm(i).taskdir = d(i).name;
            cd(d(i).name)
            f_ = openfig('goodness_metric_plots/goodness_metric.fig');
            % total
            a_ = subplot(2,1,1);
            c_ = get(a_,'Children');
            gm(i).total = get(c_(1),'ydata');
            a_ = subplot(2,1,2);
            % components
            c_ = get(a_,'Children');
            for j=1:length(c_)
                if strcmp(get(c_(j),'DisplayName'),'Delta Variability Part')
                    gm(i).deltaVar = get(c_(j),'ydata');
                end
                if strcmp(get(c_(j),'DisplayName'),'Correlation Part')
                    gm(i).correlation = get(c_(j),'ydata');
                end
                if strcmp(get(c_(j),'DisplayName'),'Delta Noise Part')
                    gm(i).noise = get(c_(j),'ydata');
                end
                if strcmp(get(c_(j),'DisplayName'),'Earth Point Part')
                    gm(i).earthPoints = get(c_(j),'ydata');
                end
            end
            close
            cd ..
        end
        goodness = gm;
    end

    %*********************************************************************************************************
    % function [perTargetStatistics] = compile_per_target_statistics_from_taskDirs (quarter, dataSaveDir, useUowDirectory, recomputeGoodnessMetrics)
    %
    % Crawls through the task directories and creates FOV plots of various performance metrics. Run this in the top level directory with all the pdc-Matlab-*
    % directories.
    %
    % Created Plots:
    %
    % Inputs:
    %   quarter                 -- [int] Generate statistics for this quarter (only works for Kepler data! Use -1 for K2)
    %   dataSaveDir             -- [char] path to where outputs should be saved. If empty then do not save figures
    %   useUowDirectory         -- [logical OPTIONAL] If true then will use the OUW links to find the appropriate quarter. DOES NOT WORK WITH K2 DATA
    %   recomputeGoodnessMetrics-- [logical OPTIONAL] If true then recompute the goodness metrics
    %
    % Outputs:
    %   perTargetStatistics -- [struct array(nTargets)] raw data for each target
    %
    %*********************************************************************************************************
    function [perTargetStatistics] = compile_per_target_statistics_from_taskDirs (quarter, dataSaveDir, useUowDirectory, recomputeGoodnessMetrics)

    nChannels = fovPlottingClass.nChannels;

    % We do not know a-priori the number of total targets so we have to dynamically increase the size of this struct
    perTargetStatistics = struct('module', nan(2,1), 'output', nan(2,1), 'channel', nan(2,1), 'keplerId', nan(2,1), 'keplerMag', nan(2,1), 'cdpp', nan(2,1), ...
                'totalGoodness', nan(2,1), 'introducedNoise', nan(2,1), 'correlation', nan(2,1), 'earthPointRemoval', nan(2,1), 'spikeRemoval', nan(2,1));
    perTargetStatistics.pdcMethod = cell(2,1);
    iTarget = 1;

    if (exist('useUowDirectory', 'var') && ~isempty(useUowDirectory) && useUowDirectory)
        taskDirNames = dir('./uow/pdc-*');
        % Find sub-tasks for this quarter
        useThisDirectory = false(length(taskDirNames),1);
        for iTask = 1 : length(taskDirNames)
            if (quarter < 10)
                stringPattern = ['-q0', num2str(quarter)];
            else
                stringPattern = ['-q', num2str(quarter)];
            end
            useThisDirectory(iTask) = ~isempty(strfind(taskDirNames(iTask).name, stringPattern));
        end
        taskDirNames = taskDirNames(useThisDirectory);
        dirHeaderPath = [pwd, '/uow/'];
    else
        useUowDirectory = false;
        % Find all run directories
        taskDirNames = dir('pdc-matlab*');
        dirHeaderPath = './';
    end

    if (exist('recomputeGoodnessMetrics', 'var'))
        if (~islogical(recomputeGoodnessMetrics))
            error('recomputeGoodnessMetrics must be a logical');
        end
    else
        recomputeGoodnessMetrics = false;
    end

    nTaskDirs = length(taskDirNames);

    for iTaskDir = 1 : nTaskDirs
        
        cd ([dirHeaderPath, taskDirNames(iTaskDir).name]);

        display(['Working on Task ', num2str(iTaskDir), ' of ', num2str(nTaskDirs)]);
            
        % Find all sub-task directories
        subTaskDirNames = dir('st-*');
        nSubTaskDirs = length(subTaskDirNames);

        if (useUowDirectory)
            % We are using the OUW links so no sub-tasks to step through
            nSubTaskDirs = 1;
            subTaskDirNames(1).name = '.';
        end

        for iSubTaskDir = 1 : nSubTaskDirs

            cd (subTaskDirNames(iSubTaskDir).name);

            if (~exist('pdc-inputs-0.mat', 'file'))
                % No data, skip this task
                cd ..
                continue;
            end
            inputsStruct = load('pdc-inputs-0.mat');
            inputsStruct = inputsStruct.inputsStruct;

            % Only collect data for specified quarter
            inputQuarter = convert_from_cadence_to_quarter (inputsStruct.startCadence, inputsStruct.cadenceType);
            % Taking the round of inputQuarter becuase the decimal gives the month
            if (round(inputQuarter) == quarter)

                % Load the outputsStruct to collect the data
                
                outputsStruct = load('pdc-outputs-0.mat');
                outputsStruct = outputsStruct.outputsStruct;

                if (recomputeGoodnessMetrics)
                    display('Recomputing Goodness Metric...');
                    inputsStruct.goodnessMetricConfigurationStruct = assert_field(inputsStruct.goodnessMetricConfigurationStruct , 'spikeScale', 5.0e-6, false);
                    % %TODO:  Spike basis vectors are not available for 9.2 data, so cannot calculate this!
                    spikeBasisVectors = [];
                    % Earth Point Goodness will also not be calculated
                    goodnessMetric = pdc_goodness_metric (inputsStruct, outputsStruct, spikeBasisVectors);
                    % Overwrite goodnessMetric in outputsStruct
                    for iGoodnessTarget = 1 : length(outputsStruct.targetResultsStruct)
                        outputsStruct.targetResultsStruct(iGoodnessTarget).pdcGoodnessMetric = goodnessMetric(iGoodnessTarget);                
                    end

                end

                % Get the mod.out for each target on each channel
                % Have to account for old PDC data before the multi-Channel struct was develoepd
                if (isfield(inputsStruct, 'channelDataStruct'))
                    multiChannelData = true;
                    nChannelsInTask = length(inputsStruct.channelDataStruct);
                else
                    multiChannelData = false;
                    nChannelsInTask = 1;
                end
                for iChannel = 1 : nChannelsInTask
                    if (multiChannelData)
                        thisModule = inputsStruct.channelDataStruct(iChannel).ccdModule;
                        thisOutput = inputsStruct.channelDataStruct(iChannel).ccdOutput;
                    else
                        thisModule = inputsStruct.ccdModule;
                        thisOutput = inputsStruct.ccdOutput;
                    end
                    thisChannel = convert_from_module_output(thisModule, thisOutput);

                    keplerIdsInOutputsStruct = [outputsStruct.targetResultsStruct.keplerId];

                    if (multiChannelData)
                        nTargets = length(inputsStruct.channelDataStruct(iChannel).targetDataStruct);
                    else
                        nTargets = length(inputsStruct.targetDataStruct);
                    end
                    for iTargetSubTask = 1 : nTargets

                        perTargetStatistics.module(iTarget) = thisModule;
                        perTargetStatistics.output(iTarget) = thisOutput;
                        perTargetStatistics.channel(iTarget) = thisChannel;

                        if (multiChannelData)
                            perTargetStatistics.keplerId(iTarget)   = inputsStruct.channelDataStruct(iChannel).targetDataStruct(iTargetSubTask).keplerId;
                            perTargetStatistics.keplerMag(iTarget)  = inputsStruct.channelDataStruct(iChannel).targetDataStruct(iTargetSubTask).keplerMag;
                        else                                      
                            perTargetStatistics.keplerId(iTarget)   = inputsStruct.targetDataStruct(iTargetSubTask).keplerId;
                            perTargetStatistics.keplerMag(iTarget)  = inputsStruct.targetDataStruct(iTargetSubTask).keplerMag;
                        end

                        % Find this target in the outputsStruct
                        thisTargetIndex = find(keplerIdsInOutputsStruct == perTargetStatistics.keplerId(iTarget));
                        if (isempty(thisTargetIndex) || length(thisTargetIndex) ~= 1)
                            error ('Target does not appear in the outputsStruct!');
                        end
                
                        % CDPP is only available for SOC 9.3
                        if (isfield(outputsStruct.targetResultsStruct(thisTargetIndex).pdcGoodnessMetric, 'cdpp'))
                            perTargetStatistics.cdpp(iTarget)        = outputsStruct.targetResultsStruct(thisTargetIndex).pdcGoodnessMetric.cdpp.value;
                        else
                            perTargetStatistics.cdpp(iTarget)        = nan;
                        end
                        perTargetStatistics.totalGoodness(iTarget)   = outputsStruct.targetResultsStruct(thisTargetIndex).pdcGoodnessMetric.total.value;
                        perTargetStatistics.introducedNoise(iTarget) = outputsStruct.targetResultsStruct(thisTargetIndex).pdcGoodnessMetric.introducedNoise.value;
                        perTargetStatistics.correlation(iTarget)     = outputsStruct.targetResultsStruct(thisTargetIndex).pdcGoodnessMetric.correlation.value;
                        perTargetStatistics.earthPointRemoval(iTarget) = outputsStruct.targetResultsStruct(thisTargetIndex).pdcGoodnessMetric.earthPointRemoval.value;
                        if (isfield(outputsStruct.targetResultsStruct(thisTargetIndex).pdcGoodnessMetric, 'spikeRemoval'));
                            perTargetStatistics.spikeRemoval(iTarget)    = outputsStruct.targetResultsStruct(thisTargetIndex).pdcGoodnessMetric.spikeRemoval.value;
                        end
                        perTargetStatistics.pdcMethod{iTarget}       = outputsStruct.targetResultsStruct(thisTargetIndex).pdcProcessingStruct.pdcMethod;
                
                        iTarget = iTarget + 1;
                    end
                end

            end

            if (~useUowDirectory)
                cd ..
            end

        end

        cd ..

    end

    if (useUowDirectory)
        cd ..
    end

    if (iTarget == 1)
        error ('No tasks for specified quarter were found!');
    end

    if (~exist(dataSaveDir, 'dir'))
        mkdir(dataSaveDir);
    end

    if (exist(dataSaveDir, 'dir') && ~isempty(dataSaveDir))
        save ([dataSaveDir, '/', 'perTargetStatistics.mat'],  'perTargetStatistics');
    end

    end % function compile_per_target_statistics_from_taskDirs

    %*********************************************************************************************************
    % function [perTargetStatisticsAllQuarters] = compile_per_target_statistics_for_all_quarters ...
    %           (dataSaveDir, quarterRange, recomputeGoodnessMetrics)
    %
    % Crawls through the task directories and creates FOV plots of various performance metrics. It will generate figures for each quarter that is available.
    % Run this in the top level directory with all the pdc-Matlab-* directories.
    %
    % It will save the individual figures in seperate sub-directories for each quarter in <dataSaveDir>.
    %
    % This will only work for Kepler data, NOT K2 data!
    %
    % Inputs:
    %   dataSaveDir    -- [char] path to where figures and outputs should be saved. If empty then do not save figures
    %   quarterRange            -- [int array(2) OPTIONAL] array of quarters to generate figures for, default: all quarters
    %   recomputeGoodnessMetrics-- [logical] If true then recompute the goodness metrics
    %
    % Outputs:
    %   perTargetStatisticsAllQuarters  -- [struct array(nTargets)] rawe data for each target for each quarter
    %
    %*********************************************************************************************************
    function [perTargetStatisticsAllQuarters] = compile_per_target_statistics_for_all_quarters ...
                    (dataSaveDir, quarterRange, recomputeGoodnessMetrics)

        if (exist('quarterRange', 'var') && ~isempty(quarterRange))
            minQuarter = min(quarterRange);
            maxQuarter = max(quarterRange);
        else
            minQuarter = 0;
            maxQuarter = 17; % Kepler primary mission ended with Quarter 17 : (
        end

        % Check if each quarter is in a seperate subdirectory (THis occured for the final SC processing)
        quarterDirs = dir('q*');
        if (~isempty(quarterDirs))
            quarterDivided = true;
        else
            quarterDivided = false;
        end

        
        quarterIndex = 1;
        for iQuarter = minQuarter : maxQuarter
            if quarterDivided
                cd(['q', num2str(iQuarter)]);
            end
        
            display(['Working on Quarter ', num2str(iQuarter), ' of ', num2str(maxQuarter - minQuarter)]);

            perTargetStatisticsAllQuarters(quarterIndex).quarter = iQuarter;

            [perTargetStatisticsAllQuarters(quarterIndex).perTargetStatistics] = ...
                fovPlottingClass.compile_per_target_statistics_from_taskDirs (iQuarter, [], true, recomputeGoodnessMetrics);

            close all;
        
            quarterIndex = quarterIndex + 1;

            if quarterDivided
                cd ..
            end
        end

        save (fullfile(dataSaveDir, 'perTargetStatisticsAllQuarters.mat'), 'perTargetStatisticsAllQuarters');
        
    end % function compile_fov_statistics_for_all_quarters 

    %*********************************************************************************************************
    % function [fovStatistics] = generate_fov_figures_and_statistics (perTargetStatistics, doPlot, figureSaveDir, magnitudeRange)
    %
    % Crawls through the task directories and creates FOV plots of various performance metrics. Run this in the top level directory with all the pdc-Matlab-*
    % directories.
    %
    % Created Plots:
    %
    % Inputs:
    %   perTargetStatistics     -- [struct array(nTargets)] raw data for each target
    %   doPlot                  -- [logical] If true then generate the plots , otherwise just return the data (default = TRUE)
    %   figureSaveDir           -- [char] path to where figures and outputs should be saved. If empty then do not save figures
    %   magnitudeRange          -- [double array(2)] min and max range of Kepler Magnitudes to examine
    %
    % Outputs:
    %   fovStatistics       -- [struct array(nChannels)] summary statistics for each mod.out
    %
    %*********************************************************************************************************
    function [fovStatistics] = generate_fov_figures_and_statistics (perTargetStatistics, doPlot, figureSaveDir, magnitudeRange)
    
    if (~exist('doPlot'))
        doPlot = true;
    end

    channelList =  unique([perTargetStatistics.channel]);
    nChannels = length(channelList);

    fovStatistics = struct('channel', nan(nChannels,1), 'module', nan(nChannels,1), 'output', nan(nChannels,1), 'medianCDPP', nan(nChannels,1), ...
            'tenthPrctileCDPP', nan(nChannels,1), 'mapUtilizationRatio', nan(nChannels,1), 'ninetiethPrctileTotalGoodness', nan(nChannels,1), ...
            'ninetiethPrctileIntroducedNoise', nan(nChannels,1), 'ninetiethPrctileCorrelation', nan(nChannels,1), 'ninetiethPrctileSpike', nan(nChannels,1),...
            'ninetiethPrctileEarthPoint', nan(nChannels,1), 'msMapUtilizationRatio', nan(nChannels,1));

    if (length(magnitudeRange) ~= 2 || ~isreal(magnitudeRange(1)) || ~isreal(magnitudeRange(2)) || ~(magnitudeRange(2) > magnitudeRange(1)))
        error('magnitudeRange incorrect syntax');
    end

    targetChannelArray   = perTargetStatistics.channel;
    pdcMethod            = perTargetStatistics.pdcMethod;
    cdppArray            = perTargetStatistics.cdpp;
    keplerMagArray       = perTargetStatistics.keplerMag;
    totalGoodnessArray   = perTargetStatistics.totalGoodness;
    introducedNoiseArray = perTargetStatistics.introducedNoise;
    correlationArray     = perTargetStatistics.correlation;
    if (isfield(perTargetStatistics, 'earthPointRemoval') && length(perTargetStatistics.earthPointRemoval) == length(perTargetStatistics.channel))
        earthPointArray  = perTargetStatistics.earthPointRemoval;
    else
        earthPointArray  = zeros(size(correlationArray));
    end
    if (isfield(perTargetStatistics, 'spikeRemoval') && length(perTargetStatistics.spikeRemoval) == length(perTargetStatistics.channel))
        spikeArray       = perTargetStatistics.spikeRemoval;
    else
        spikeArray       = zeros(size(correlationArray));
    end

    for i = 1 : nChannels

        iChannel = channelList(i);

        [thisModule thisOutput]  = convert_to_module_output (iChannel);
        fovStatistics.channel(iChannel) = iChannel;
        fovStatistics.module(iChannel)  = thisModule;
        fovStatistics.output(iChannel)  = thisOutput;

        % Find all targets on this channel and with 12th Mag (within [11.5,12.5])
        targetIndices = ismember(targetChannelArray, iChannel) & keplerMagArray > magnitudeRange(1) & keplerMagArray < magnitudeRange(2);
        fovStatistics.medianCDPP(iChannel) = nanmedian(cdppArray(targetIndices));
        fovStatistics.tenthPrctileCDPP(iChannel) = prctile(cdppArray(targetIndices), 10);

        fovStatistics.ninetiethPrctileTotalGoodness(iChannel) = prctile(totalGoodnessArray(targetIndices), 10);

        fovStatistics.ninetiethPrctileIntroducedNoise(iChannel) = prctile(introducedNoiseArray(targetIndices), 10);

        fovStatistics.ninetiethPrctileCorrelation(iChannel) = prctile(correlationArray(targetIndices), 10);

        fovStatistics.ninetiethPrctileEarthPoint(iChannel) = prctile(earthPointArray(targetIndices), 10);

        fovStatistics.ninetiethPrctileSpike(iChannel) = prctile(spikeArray(targetIndices), 10);

        mapUtilized = ismember(targetChannelArray(targetIndices), iChannel) & ...
                    (ismember(pdcMethod(targetIndices), 'regularMap')    | ismember(pdcMethod(targetIndices), 'MAP') | ...
                     ismember(pdcMethod(targetIndices), 'multiScaleMap') | ismember(pdcMethod(targetIndices), 'msMap')); 
        fovStatistics.mapUtilizationRatio(iChannel) = sum(mapUtilized) / sum(ismember(targetChannelArray(targetIndices), iChannel));

        msMapUtilized = ismember(targetChannelArray(targetIndices), iChannel) & ...
                    (ismember(pdcMethod(targetIndices), 'multiScaleMap') | ismember(pdcMethod(targetIndices), 'msMap')); 
        fovStatistics.msMapUtilizationRatio(iChannel) = sum(msMapUtilized) / sum(ismember(targetChannelArray(targetIndices), iChannel));
    end


    if (doPlot)
        % Median CDPP 12th Magnitude Stars
        medianCDPPFigureHandle = fovPlottingClass.plot_on_modout([fovStatistics.module], [fovStatistics.output], [fovStatistics.medianCDPP]);
        medianCDPPFigureHandle = fovPlottingClass.make_ccd_legend_plot(medianCDPPFigureHandle);
        colorbar;
        colormap('Cool');
        title (['Median CDPP Across Focal Plane for ', num2str(magnitudeRange(1)), ' < Kp < ', num2str(magnitudeRange(2))]);
        
        % 10th Percentile CDPP 12th Magnitude Stars
        tenthCDPPFigureHandle = fovPlottingClass.plot_on_modout([fovStatistics.module], [fovStatistics.output], [fovStatistics.tenthPrctileCDPP]);
        tenthCDPPFigureHandle = fovPlottingClass.make_ccd_legend_plot(tenthCDPPFigureHandle);
        colorbar;
        colormap('Cool');
        title (['10th percentile CDPP Across Focal Plane for ', num2str(magnitudeRange(1)), ' < Kp < ', num2str(magnitudeRange(2))]);
        
        % MAP Untilization  CDPP 12th Magnitude Stars
        mapFigureHandle = fovPlottingClass.plot_on_modout([fovStatistics.module], [fovStatistics.output], [fovStatistics.mapUtilizationRatio]);
        mapFigureHandle = fovPlottingClass.make_ccd_legend_plot(mapFigureHandle);
        colorbar;
        colormap('Cool');
        title (['MAP Utilization Ratio Across Focal Plane for ', num2str(magnitudeRange(1)), ' < Kp < ', num2str(magnitudeRange(2))]);

        % msMAP Untilization CDPP 12th Magnitude Stars
        msMapFigureHandle = fovPlottingClass.plot_on_modout([fovStatistics.module], [fovStatistics.output], [fovStatistics.msMapUtilizationRatio]);
        msMapFigureHandle = fovPlottingClass.make_ccd_legend_plot(msMapFigureHandle);
        colorbar;
        colormap('Cool');
        title (['Multi-Scale MAP Utilization Ratio Across Focal Plane for ', num2str(magnitudeRange(1)), ' < Kp < ', num2str(magnitudeRange(2))]);

        % 90th percentile Total Goodness CDPP 12th Magnitude Stars
        totalGoodnessFigureHandle = fovPlottingClass.plot_on_modout([fovStatistics.module], [fovStatistics.output], [fovStatistics.ninetiethPrctileTotalGoodness]);
        totalGoodnessFigureHandle = fovPlottingClass.make_ccd_legend_plot(totalGoodnessFigureHandle);
        colorbar;
        colormap('Cool');
        title (['Bottom 10th Percentile Total Goodness Across Focal Plane for ', num2str(magnitudeRange(1)), ' < Kp < ', num2str(magnitudeRange(2))]);

        % 90th percentile Introduced Noise CDPP 12th Magnitude Stars
        introducedNoiseFigureHandle = fovPlottingClass.plot_on_modout([fovStatistics.module], [fovStatistics.output], [fovStatistics.ninetiethPrctileIntroducedNoise]);
        introducedNoiseFigureHandle = fovPlottingClass.make_ccd_legend_plot(introducedNoiseFigureHandle);
        colorbar;
        colormap('Cool');
        title (['Bottom 10th Percentile Introduced Noise Across Focal Plane for ', num2str(magnitudeRange(1)), ' < Kp < ', num2str(magnitudeRange(2))]);

        % 90th pertentile correlation CDPP 12th Magnitude Stars
        correlationFigureHandle = fovPlottingClass.plot_on_modout([fovStatistics.module], [fovStatistics.output], [fovStatistics.ninetiethPrctileCorrelation]);
        correlationFigureHandle = fovPlottingClass.make_ccd_legend_plot(correlationFigureHandle);
        colorbar;
        colormap('Cool');
        title (['Bottom 10th Percentile Correlation Across Focal Plane for ', num2str(magnitudeRange(1)), ' < Kp < ', num2str(magnitudeRange(2))]);

        % 90th pertentile Earth Point Removal CDPP 12th Magnitude Stars
        earthPointFigureHandle = fovPlottingClass.plot_on_modout([fovStatistics.module], [fovStatistics.output], [fovStatistics.ninetiethPrctileEarthPoint]);
        earthPointFigureHandle = fovPlottingClass.make_ccd_legend_plot(earthPointFigureHandle);
        colorbar;
        colormap('Cool');
        title (['Bottom 10th Percentile Earth Point Removal Across Focal Plane for ', num2str(magnitudeRange(1)), ' < Kp < ', num2str(magnitudeRange(2))]);

        % 90th pertentile Spike Removal CDPP 12th Magnitude Stars
        spikeFigureHandle = fovPlottingClass.plot_on_modout([fovStatistics.module], [fovStatistics.output], [fovStatistics.ninetiethPrctileSpike]);
        spikeFigureHandle = fovPlottingClass.make_ccd_legend_plot(spikeFigureHandle);
        colorbar;
        colormap('Cool');
        title (['Bottom 10th Percentile Spike Removal Across Focal Plane for ', num2str(magnitudeRange(1)), ' < Kp < ', num2str(magnitudeRange(2))]);

        % CDPP vs Kepler Mag scatter plot
        cdppVsKepMagFigure = figure;
        plot(keplerMagArray, cdppArray, '.');
        axis([8 17 0 1000]);
        title('CDPP vs. Kepler Magnitude, full FOV');
        xlabel('Kepler Magnitude');
        ylabel('CDPP [ppm]');
        grid on;

        if (~exist(figureSaveDir, 'dir'))
            mkdir(figureSaveDir);
        end

        if (exist(figureSaveDir, 'dir') && ~isempty(figureSaveDir))
            saveas(medianCDPPFigureHandle, [figureSaveDir, '/', 'medianCdpp.fig']);
            saveas(tenthCDPPFigureHandle , [figureSaveDir, '/', 'tenthCdpp.fig']);
            saveas(mapFigureHandle , [figureSaveDir, '/', 'mapUtilization.fig']);
            saveas(msMapFigureHandle , [figureSaveDir, '/', 'msMapUtilization.fig']);
            saveas(totalGoodnessFigureHandle , [figureSaveDir, '/', 'totalGoodness.fig']);
            saveas(introducedNoiseFigureHandle , [figureSaveDir, '/', 'introducedNoise.fig']);
            saveas(correlationFigureHandle , [figureSaveDir, '/', 'correlation.fig']);
            saveas(earthPointFigureHandle , [figureSaveDir, '/', 'earthPoint.fig']);
            saveas(spikeFigureHandle , [figureSaveDir, '/', 'spike.fig']);
            saveas(cdppVsKepMagFigure , [figureSaveDir, '/', 'cdppVsKepMag.fig']);

            save ([figureSaveDir, '/', 'fovStatistics.mat'],        'fovStatistics');
        end

    end

    end % function generate_fov_figures_and_statistics

    %*********************************************************************************************************
    % function [fovStatisticsAllQuarters] = compile_fov_statistics_for_magnitude_range ...
    %           (perTargetStatisticsAllQuarters, dataSaveDir, magnitudeRange)
    %
    % Crawls through the task directories and creates FOV plots of various performance metrics. It will generate figures for each quarter that is available.
    % Run this in the top level directory with all the pdc-Matlab-* directories.
    %
    % It uses all quarters in perTargetStatisticsAllQuarters. You can also just pass data for one quarter (or for K2 data)
    %
    % It will save the individual figures in seperate sub-directories for each quarter in <dataSaveDir>.
    %
    % This will only work for Kepler data, NOT K2 data!
    %
    % Inputs:
    %   perTargetStatisticsAllQuarters  -- [struct array(nTargets)] rawe data for each target for each quarter, 
    %                                       from compile_per_target_statistics_for_all_quarters or generate_fov_figures_all_magnitude_ranges
    %   dataSaveDir     -- [char] path to where figures and outputs should be saved. If empty then do not save data, just return
    %   magnitudeRange          -- [double array(2)] min and max range of Kepler Magnitudes to examine
    %
    % Outputs:
    %   fovStatisticsAllQuarters        -- [struct array(nChannels)] summary statistics for each mod.out for each quarter
    %
    %*********************************************************************************************************
    function [fovStatisticsAllQuarters] = compile_fov_statistics_for_magnitude_range (perTargetStatisticsAllQuarters, dataSaveDir, magnitudeRange)

        
        for iQuarter = 1 : length(perTargetStatisticsAllQuarters)
        
            display(['Working on quarter index ', num2str(iQuarter), ' of ', num2str(length(perTargetStatisticsAllQuarters))]);

            % This function is also used when only one quarter data is passed.
            if (isfield(perTargetStatisticsAllQuarters(iQuarter), 'quarter'))
                doPlot = false;
                fovStatisticsAllQuarters(iQuarter).quarter = perTargetStatisticsAllQuarters(iQuarter).quarter;
                
                fovStatisticsAllQuarters(iQuarter).fovStatistics = ...
                    fovPlottingClass.generate_fov_figures_and_statistics (perTargetStatisticsAllQuarters(iQuarter).perTargetStatistics, doPlot, [], magnitudeRange);
            else
                % If only a single quarter then generate figures for this quarter ranges
                doPlot = true;
                fovStatisticsAllQuarters(iQuarter).fovStatistics = ...
                    fovPlottingClass.generate_fov_figures_and_statistics (perTargetStatisticsAllQuarters, doPlot, dataSaveDir, magnitudeRange);
            end

        end

        if (~isempty(dataSaveDir))
            if (isfield(perTargetStatisticsAllQuarters(iQuarter), 'quarter'))
                save (fullfile(dataSaveDir, 'fovStatisticsAllQuarters.mat'), 'fovStatisticsAllQuarters');
            else
                save (fullfile(dataSaveDir, 'fovStatistics.mat'), 'fovStatisticsAllQuarters');
            end
        end
        
    end % function compile_fov_statistics_for_all_quarters 

    %*********************************************************************************************************
    % function generate_multi-quarter_figures (fovStatisticsAllQuarters, saveDir, titleHeader)
    %
    % Inputs:
    % fovStatisticsAllQuarters  -- [struct] Output from fovPlottignStruct.compile_fov_statistics_for_all_quarters 
    % saveDir                   -- [char] If NOT empty then save figures to this directory
    % titleHeader               -- [char] what to place at the beginning of each figure (I.e magnitude range being plotted)
    % saveFileHeader            -- [char] what to place at the beginning of each file (I.e magnitude range being plotted)
    %
    %
    %*********************************************************************************************************

    function generate_multi_quarter_figures (fovStatisticsAllQuarters, saveDir, titleHeader, saveFileHeader)

        quartersArray = int32([fovStatisticsAllQuarters.quarter]);
        
        nChannels = fovPlottingClass.nChannels;
        nQuarters = length(fovStatisticsAllQuarters);

        fovPerQuarterArray = [fovStatisticsAllQuarters.fovStatistics];

        % Tick labels for each Quarter
        for iTick = 1 : nQuarters
            tickLabels{iTick} = int2str(fovStatisticsAllQuarters(iTick).quarter);
        end

        %***
        % Plot Channel Legend Figure
        ChannelLegendfigure = fovPlottingClass.make_ccd_legend_plot (true);

        %***
        % Median CDPP
        medianCdppFigure = figure;
        hold on;
        medianCdppMatrix = [fovPerQuarterArray.medianCDPP]';
        % Force colormap to plot only reasonable CDPP values (I.e. nothing near zero)
        minCdpp = 15;
        minCdpp = min(min(medianCdppMatrix));
        maxCdpp = max(max(medianCdppMatrix));
        if (isnan(maxCdpp) || maxCdpp < minCdpp)
            maxCdpp = minCdpp+1;
        end

        imagesc(medianCdppMatrix);
        set(gca,'YTick', 1:nQuarters)
        set(gca,'YTickLabel', tickLabels)
        caxis([minCdpp, maxCdpp]);
        colorbar;
        xlabel('Channel');
        ylabel('Quarter');
        title([titleHeader, '; Median CDPP']);

        %***
        % 10th Percentile CDPP
        tenthCdppFigure = figure;
        hold on;
        tenthCdppMatrix = [fovPerQuarterArray.tenthPrctileCDPP]';
        % Force colormap to plot only reasonable CDPP values (I.e. nothing near zero)
        minCdpp = 15;
        minCdpp = min(min(tenthCdppMatrix));
        maxCdpp = max(max(tenthCdppMatrix));
        if (isnan(maxCdpp) || maxCdpp < minCdpp)
            maxCdpp = minCdpp+1;
        end

        imagesc(tenthCdppMatrix);
        set(gca,'YTick', 1:nQuarters)
        set(gca,'YTickLabel', tickLabels)
        caxis([minCdpp, maxCdpp]);
        colorbar;
        xlabel('Channel');
        ylabel('Quarter');
        title([titleHeader, '; Tenth Percentile CDPP']);

        %***
        % MAP Utilization
        mapUtlizationFigure = figure;
        hold on;
        mapUtilizationMatrix = [fovPerQuarterArray.mapUtilizationRatio]';

        imagesc(mapUtilizationMatrix);
        set(gca,'YTick', 1:nQuarters)
        set(gca,'YTickLabel', tickLabels)
        colorbar;
        xlabel('Channel');
        ylabel('Quarter');
        title([titleHeader, '; Map Utilization Ratio']);

        %***
        % msMap Utilization
        msMapUtilizationFigure = figure;
        hold on;
        msMapUtilizationMatrix = [fovPerQuarterArray.msMapUtilizationRatio]';

        imagesc(msMapUtilizationMatrix);
        set(gca,'YTick', 1:nQuarters)
        set(gca,'YTickLabel', tickLabels)
        colorbar;
        xlabel('Channel');
        ylabel('Quarter');
        title([titleHeader, '; msMAP Utlization Ratio']);

        %***
        % 90th Percentile Total Goodness
        nintiethTotalGoodnessFigure = figure;
        hold on;
        nintiethTotalGoodnessMatrix = [fovPerQuarterArray.ninetiethPrctileTotalGoodness ]';

        imagesc(nintiethTotalGoodnessMatrix);
        set(gca,'YTick', 1:nQuarters)
        set(gca,'YTickLabel', tickLabels)
        colorbar;
        xlabel('Channel');
        ylabel('Quarter');
        title([titleHeader, '; 90% Total Goodness']);

        %***
        % 90th Percentil Introduced Noise
        nintiethIntroducedNoiseFigure = figure;
        hold on;
        ninetiethPrctileIntroducedNoiseMatrix = [fovPerQuarterArray.ninetiethPrctileIntroducedNoise]';

        imagesc(ninetiethPrctileIntroducedNoiseMatrix);
        set(gca,'YTick', 1:nQuarters)
        set(gca,'YTickLabel', tickLabels)
        colorbar;
        xlabel('Channel');
        ylabel('Quarter');
        title([titleHeader, '; 90% Introduced Noise']);

        %***
        % nintiethCorrelation
        nintiethCorrelationFigure = figure;
        hold on;
        ninetiethPrctileCorrelationMatrix = [fovPerQuarterArray.ninetiethPrctileCorrelation]';

        imagesc(ninetiethPrctileCorrelationMatrix);
        set(gca,'YTick', 1:nQuarters)
        set(gca,'YTickLabel', tickLabels)
        colorbar;
        xlabel('Channel');
        ylabel('Quarter');
        title([titleHeader, '; 90% Correlation Goodness']);

        %***
        % nintieth Earth-Point
        nintiethEarthPointFigure = figure;
        hold on;
        ninetiethPrctileEarthPointMatrix = [fovPerQuarterArray.ninetiethPrctileEarthPoint]';

        imagesc(ninetiethPrctileEarthPointMatrix);
        set(gca,'YTick', 1:nQuarters)
        set(gca,'YTickLabel', tickLabels)
        colorbar;
        xlabel('Channel');
        ylabel('Quarter');
        title([titleHeader, '; 90% Earth Point Removal Goodness']);

        %***
        % nintieth Spike
        nintiethSpikeFigure = figure;
        hold on;
        ninetiethPrctileSpikeMatrix = [fovPerQuarterArray.ninetiethPrctileSpike]';

        imagesc(ninetiethPrctileSpikeMatrix);
        set(gca,'YTick', 1:nQuarters)
        set(gca,'YTickLabel', tickLabels)
        colorbar;
        xlabel('Channel');
        ylabel('Quarter');
        title([titleHeader, '; 90% Spike Removal Goodness']);

            
        if (~exist(saveDir, 'dir'))
            mkdir(saveDir);
        end

        if (exist(saveDir, 'dir') && ~isempty(saveDir))
            % NOTE: keep these consistent with the plotPostNames in generate_fov_figures_all_magnitude_ranges!!!!!!!!!!!!!!!!!!
            saveas(medianCdppFigure,                fullfile(saveDir, [saveFileHeader, '_medianCdpp.fig']));
            saveas(tenthCdppFigure,                 fullfile(saveDir, [saveFileHeader, '_tenthCdpp.fig']));
            saveas(mapUtlizationFigure,             fullfile(saveDir, [saveFileHeader, '_mapUtlization.fig']));
            saveas(msMapUtilizationFigure,          fullfile(saveDir, [saveFileHeader, '_msMapUtilization.fig']));
            saveas(nintiethTotalGoodnessFigure,     fullfile(saveDir, [saveFileHeader, '_nintiethTotalGoodness.fig']));
            saveas(nintiethIntroducedNoiseFigure,   fullfile(saveDir, [saveFileHeader, '_nintiethIntroducedNoise.fig']));
            saveas(nintiethCorrelationFigure,       fullfile(saveDir, [saveFileHeader, '_nintiethCorrelation.fig']));
            saveas(nintiethEarthPointFigure,        fullfile(saveDir, [saveFileHeader, '_nintiethEarthPoint.fig']));
            saveas(nintiethSpikeFigure,             fullfile(saveDir, [saveFileHeader, '_nintiethSpike.fig']));        
        end

    end % function generate_multi_quarter_figures 

    %*********************************************************************************************************
    % function generate_fov_figures_all_magnitude_ranges (perTargetStatisticsAllQuarters, figureSaveDir, magnitudeLimits)
    %
    % This functionc an be used to generate either single-quarter or multi-quarter figures. K2 means single-quarter : )
    %
    % Inputs:
    %   perTargetStatisticsAllQuarters  -- [struct array(nTargets)] rawe data for each target for each quarter, from compile_per_target_statistics_for_all_quarters
    %   figureSaveDir                   -- [char] If NOT empty then save figures to this directory
    %   magnitudeLimits                 -- [double array] list magnitude ranges to plot, default = [0 9.5 10.5 11.5 12.5 13.5 14.5 15.5 16.5 100];
    %
    %*********************************************************************************************************
    function generate_fov_figures_all_magnitude_ranges (perTargetStatisticsAllQuarters, figureSaveDir, magnitudeLimits)

        if (~exist('magnitudeLimits', 'var') || isempty(magnitudeLimits))
            magnitudeLimits  = [0 9.5 10.5 11.5 12.5 13.5 14.5 15.5 16.5 100];
        end


        nMagnitudes = length(magnitudeLimits) - 1;
        saveFileHeader = cell([nMagnitudes,1]);
        for iRange = 1 : nMagnitudes

            display(['Working on magnitude range ', num2str(iRange), ' of ', num2str(length(magnitudeLimits) - 1)]); 

            magnitudeRange(1) = magnitudeLimits(iRange);
            magnitudeRange(2) = magnitudeLimits(iRange+1);

            magRangeDir{iRange} = [figureSaveDir, '/' num2str(magnitudeRange(1)), '_Kp_', num2str(magnitudeRange(2))];
            if (~exist(magRangeDir{iRange}, 'dir'))
                mkdir(magRangeDir{iRange});
            end
            fovStatisticsAllQuarters = fovPlottingClass.compile_fov_statistics_for_magnitude_range (perTargetStatisticsAllQuarters, magRangeDir{iRange}, magnitudeRange);
    
            if (length(fovStatisticsAllQuarters) > 1)
                titleHeader     = [num2str(magnitudeRange(1)), ' < Kp < ', num2str(magnitudeRange(2))];
                saveFileHeader{iRange}  = ['Kp', num2str(magnitudeRange(1)), '-', 'Kp', num2str(magnitudeRange(2))];
                
                fovPlottingClass.generate_multi_quarter_figures (fovStatisticsAllQuarters, magRangeDir{iRange}, titleHeader, saveFileHeader{iRange});
            end
                
            close all;
        end

        if (length(fovStatisticsAllQuarters) == 1)
            % Single quarter data, no more work to do!
            return;
        end

        %***
        % Now place all magnitude slice plots on one figure

        % Only if more than one magnitude raneg was specified
        if (nMagnitudes > 1)

            display('Generating multi-mag plots...');
            
            nRows = 3;
            nCols = nMagnitudes / nRows;
            
            % NOTE: keep these consistent with the names in generate_multi_quarter_figures !!!!!!!!!!!!!!!!!
            plotPostNames = {'_medianCdpp.fig', ...
                             '_tenthCdpp.fig', ...
                             '_mapUtlization.fig', ...
                             '_msMapUtilization.fig', ...
                             '_nintiethTotalGoodness.fig', ...
                             '_nintiethIntroducedNoise.fig', ...
                             '_nintiethCorrelation.fig', ...
                             '_nintiethEarthPoint.fig', ...
                             '_nintiethSpike.fig'};       
            
            
            % Cycle through each plot type (I.e. median CDPP, spike goodness, etc...)
            for iPlotType = 1 : length(plotPostNames)
            
                currentGroupFigure = figure;
            
                caxisAllFigures = zeros(2, nMagnitudes);
            
                % Cycle through the magnitudes
                for iMag = 1 : nMagnitudes
                    % Load the figure
                    figureNameFullPath = [magRangeDir{iMag}, '/', saveFileHeader{iMag}, plotPostNames{iPlotType}];
                    figureHandle = hgload(figureNameFullPath);
                    caxisAllFigures(:,iMag) = caxis;
            
                    % Prepare the subplot
                    figure(currentGroupFigure);
                    subplotHandle = subplot(nRows, nCols, iMag);
            
                    % Paste figure onto the sublot
                    copyobj(allchild(get(figureHandle, 'CurrentAxes')), subplotHandle);
                    close(figureHandle);
                end
            
                % Set the color axis to be the same for all figures
                % IGnore last magnitude range which is poorly populated
               %minCaxis = min(caxisAllFigures(1,1:end-1));
               %maxCaxis = max(caxisAllFigures(2,1:end-1));
                minCaxis = max(min(caxisAllFigures(1,1:end-1)), 0.5);
                maxCaxis = min(max(caxisAllFigures(2,1:end-1)), 100);
                maxCaxis = max([minCaxis+0.01 maxCaxis]);
                for iMag = 1 : nMagnitudes
                    subplotHandle = subplot(nRows, nCols, iMag);
                    caxis([minCaxis maxCaxis]);
                end
            
                % Place colorbar to the right of all figures
                BRplot = get(subplot(3,3,9), 'Position');
                TRplot = get(subplot(3,3,3), 'Position');
                colorbar('Position', [BRplot(1) + BRplot(3) + 0.02 BRplot(2) 0.03 (TRplot(2) + TRplot(4)) - (BRplot(2)) ]);
            
            
                saveas(currentGroupFigure, fullfile(figureSaveDir, ['all_magnitudes', plotPostNames{iPlotType}]));
                close(currentGroupFigure);
            
            end
        end

    end % function generate_fov_figures_all_magnitude_ranges 

    %*********************************************************************************************************
    % function fovStatisticsAllQuartersDiff = multi-quarter_difference_figures (fovStatisticsAllQuartersOne, fovStatisticsAllQuartersTwo, figureSaveDir)
    %
    % Compares the FOV statistics between two different PDC runs.
    %
    % Uses first one as the reference, I.e:
    %   diff = (two - one)
    % so, positive means value increased with second run.
    %
    % Inputs:
    %   fovStatisticsAllQuartersOne    -- [fovStatisticsStruct] From compile_fov_statistics_for_all_quarters 
    %   fovStatisticsAllQuartersTwo    -- [fovStatisticsStruct] From compile_fov_statistics_for_all_quarters 
    %   figureSaveDir       -- [char] directory to save figures to, empty means do not save
    %
    %*********************************************************************************************************
    function fovStatisticsAllQuartersDiff = multi_quarter_difference_figures (fovStatisticsAllQuartersOne, fovStatisticsAllQuartersTwo, figureSaveDir)

        % Check that the two runs use the same data.
       %if (~all(fovStatisticsAllQuartersOne.channel == fovStatisticsAllQuartersTwo.channel) || ~all(fovStatisticsAllQuartersOne.module ==
       %    fovStatisticsAllQuartersTwo.module) || ...
       %    ~all(fovStatisticsAllQuartersOne.output  == fovStatisticsAllQuartersTwo.output))
       %    error ('The two fovStatistic Struct do not appear to be for the same data');
       %end

        fovStatisticsAllQuartersDiff = fovStatisticsAllQuartersOne;   

        for iQuarter = 1 : length(fovStatisticsAllQuartersDiff)
            fovStatisticsAllQuartersDiff(iQuarter).fovStatistics.medianCDPP = ...
                fovStatisticsAllQuartersTwo(iQuarter).fovStatistics.medianCDPP - fovStatisticsAllQuartersOne(iQuarter).fovStatistics.medianCDPP;
            fovStatisticsAllQuartersDiff(iQuarter).fovStatistics.tenthPrctileCDPP = ...
                fovStatisticsAllQuartersTwo(iQuarter).fovStatistics.tenthPrctileCDPP - fovStatisticsAllQuartersOne(iQuarter).fovStatistics.tenthPrctileCDPP;
            fovStatisticsAllQuartersDiff(iQuarter).fovStatistics.mapUtilizationRatio = ...
                fovStatisticsAllQuartersTwo(iQuarter).fovStatistics.mapUtilizationRatio - fovStatisticsAllQuartersOne(iQuarter).fovStatistics.mapUtilizationRatio;
            fovStatisticsAllQuartersDiff(iQuarter).fovStatistics.ninetiethPrctileTotalGoodness = ...
                fovStatisticsAllQuartersTwo(iQuarter).fovStatistics.ninetiethPrctileTotalGoodness - fovStatisticsAllQuartersOne(iQuarter).fovStatistics.ninetiethPrctileTotalGoodness;
            fovStatisticsAllQuartersDiff(iQuarter).fovStatistics.ninetiethPrctileIntroducedNoise = ...
                fovStatisticsAllQuartersTwo(iQuarter).fovStatistics.ninetiethPrctileIntroducedNoise - fovStatisticsAllQuartersOne(iQuarter).fovStatistics.ninetiethPrctileIntroducedNoise;
            fovStatisticsAllQuartersDiff(iQuarter).fovStatistics.ninetiethPrctileCorrelation = ...
                fovStatisticsAllQuartersTwo(iQuarter).fovStatistics.ninetiethPrctileCorrelation - fovStatisticsAllQuartersOne(iQuarter).fovStatistics.ninetiethPrctileCorrelation;
            fovStatisticsAllQuartersDiff(iQuarter).fovStatistics.ninetiethPrctileEarthPoint = ...
                fovStatisticsAllQuartersTwo(iQuarter).fovStatistics.ninetiethPrctileEarthPoint - fovStatisticsAllQuartersOne(iQuarter).fovStatistics.ninetiethPrctileEarthPoint;
            fovStatisticsAllQuartersDiff(iQuarter).fovStatistics.msMapUtilizationRatio = ...
                fovStatisticsAllQuartersTwo(iQuarter).fovStatistics.msMapUtilizationRatio - fovStatisticsAllQuartersOne(iQuarter).fovStatistics.msMapUtilizationRatio;
            fovStatisticsAllQuartersDiff(iQuarter).fovStatistics.ninetiethPrctileSpike = ...
                fovStatisticsAllQuartersTwo(iQuarter).fovStatistics.ninetiethPrctileSpike - fovStatisticsAllQuartersOne(iQuarter).fovStatistics.ninetiethPrctileSpike;
        end
        

        fovPlottingClass.generate_multi_quarter_figures (fovStatisticsAllQuartersDiff, figureSaveDir, 'difference', 'difference')

    end % function multi_quarter_difference_figures 

    %*********************************************************************************************************
    % Works on AllQuarters data
    % 
    % Two - one
    %
    % Assumes both structs come for the same run!
    %*********************************************************************************************************

    function perTargetStatisticsDiff = create_perTargetStatisticsDiff (perTargetStatisticsOne, perTargetStatisticsTwo)

        perTargetStatisticsDiff  = perTargetStatisticsTwo;
        
        % Set difference data
        for iQuarter = 1 : length(perTargetStatisticsTwo)
        
            perTargetStatisticsDiff(iQuarter).perTargetStatistics.cdpp = ...
                perTargetStatisticsTwo(iQuarter).perTargetStatistics.cdpp - perTargetStatisticsOne(iQuarter).perTargetStatistics.cdpp;
        
            perTargetStatisticsDiff(iQuarter).perTargetStatistics.totalGoodness = ...
                perTargetStatisticsTwo(iQuarter).perTargetStatistics.totalGoodness - perTargetStatisticsOne(iQuarter).perTargetStatistics.totalGoodness;
        
            perTargetStatisticsDiff(iQuarter).perTargetStatistics.introducedNoise = ...
                perTargetStatisticsTwo(iQuarter).perTargetStatistics.introducedNoise - perTargetStatisticsOne(iQuarter).perTargetStatistics.introducedNoise;
        
            perTargetStatisticsDiff(iQuarter).perTargetStatistics.correlation = ...
                perTargetStatisticsTwo(iQuarter).perTargetStatistics.correlation - perTargetStatisticsOne(iQuarter).perTargetStatistics.correlation;
        
            if (isfield(perTargetStatisticsOne(iQuarter).perTargetStatistics, 'earthPointRemoval ') && ...
                isfield(perTargetStatisticsTwo(iQuarter).perTargetStatistics, 'earthPointRemoval '))
                perTargetStatisticsDiff(iQuarter).perTargetStatistics.earthPointRemoval = ...
                    perTargetStatisticsTwo(iQuarter).perTargetStatistics.earthPointRemoval - perTargetStatisticsOne(iQuarter).perTargetStatistics.earthPointRemoval;
            else
                perTargetStatisticsDiff(iQuarter).perTargetStatistics.earthPointRemoval = zeros(length(perTargetStatisticsDiff(iQuarter).perTargetStatistics.correlation),1);
            end
        
            if (isfield(perTargetStatisticsOne(iQuarter).perTargetStatistics, 'spikeRemoval'))
                perTargetStatisticsDiff(iQuarter).perTargetStatistics.spikeRemoval = ...
                    perTargetStatisticsTwo(iQuarter).perTargetStatistics.spikeRemoval - perTargetStatisticsOne(iQuarter).perTargetStatistics.spikeRemoval;
            end
        
        end

    end


    %*********************************************************************************************************
    % function fovStatisticsDiff = fov_metrics_comparison_plots (fovStatisticsOne, fovStatisticsTwo, figureSaveDir)
    % 
    % Compares the FOV statistics between two different PDC runs.
    %
    % Uses first one as the reference, I.e:
    %   diff = (two - one)
    % so, positive means value increased with second run.
    %
    % Inputs:
    %   fovStatisticsOne    -- [fovStatisticsStruct] From compile_fov_statistics_from_taskDirs 
    %   fovStatisticsTwo    -- [fovStatisticsStruct] From compile_fov_statistics_from_taskDirs 
    %   figureSaveDir       -- [char] directory to save figures to, empty means do not save
    %
    %*********************************************************************************************************
    function fovStatisticsDiff = fov_metrics_comparison_plots (fovStatisticsOne, fovStatisticsTwo, figureSaveDir)

        % Check that the two runs use the same data.
        if (~all(fovStatisticsOne.channel == fovStatisticsTwo.channel) || ~all(fovStatisticsOne.module == fovStatisticsTwo.module) || ...
            ~all(fovStatisticsOne.output  == fovStatisticsTwo.output))
            error ('The two fovStatistic Struct do not appear to be for the same data');
        end
        
        fovStatisticsDiff = fovStatisticsOne;
        
       %fovStatisticsDiff.medianCDPP = (fovStatisticsTwo.medianCDPP - fovStatisticsOne.medianCDPP) ./ fovStatisticsOne.medianCDPP;
       %fovStatisticsDiff.tenthPrctileCDPP = (fovStatisticsTwo.tenthPrctileCDPP  - fovStatisticsOne.tenthPrctileCDPP ) ./ fovStatisticsOne.tenthPrctileCDPP;
       %fovStatisticsDiff.mapUtilizationRatio = (fovStatisticsTwo.mapUtilizationRatio  - fovStatisticsOne.mapUtilizationRatio ) ./ fovStatisticsOne.mapUtilizationRatio;
       %fovStatisticsDiff.ninetiethPrctileTotalGoodness = (fovStatisticsTwo.ninetiethPrctileTotalGoodness  - fovStatisticsOne.ninetiethPrctileTotalGoodness ) ./ fovStatisticsOne.ninetiethPrctileTotalGoodness;
       %fovStatisticsDiff.ninetiethPrctileIntroducedNoise = (fovStatisticsTwo.ninetiethPrctileIntroducedNoise  - fovStatisticsOne.ninetiethPrctileIntroducedNoise ) ./ fovStatisticsOne.ninetiethPrctileIntroducedNoise;
       %fovStatisticsDiff.ninetiethPrctileCorrelation = (fovStatisticsTwo.ninetiethPrctileCorrelation  - fovStatisticsOne.ninetiethPrctileCorrelation ) ./ fovStatisticsOne.ninetiethPrctileCorrelation;
       %fovStatisticsDiff.msMapUtilizationRatio = (fovStatisticsTwo.msMapUtilizationRatio  - fovStatisticsOne.msMapUtilizationRatio ) ./ fovStatisticsOne.msMapUtilizationRatio;

        fovStatisticsDiff.medianCDPP = (fovStatisticsTwo.medianCDPP - fovStatisticsOne.medianCDPP);
        fovStatisticsDiff.tenthPrctileCDPP = (fovStatisticsTwo.tenthPrctileCDPP - fovStatisticsOne.tenthPrctileCDPP);
        fovStatisticsDiff.mapUtilizationRatio = (fovStatisticsTwo.mapUtilizationRatio - fovStatisticsOne.mapUtilizationRatio);
        fovStatisticsDiff.ninetiethPrctileTotalGoodness = (fovStatisticsTwo.ninetiethPrctileTotalGoodness - fovStatisticsOne.ninetiethPrctileTotalGoodness);
        fovStatisticsDiff.ninetiethPrctileIntroducedNoise = (fovStatisticsTwo.ninetiethPrctileIntroducedNoise - fovStatisticsOne.ninetiethPrctileIntroducedNoise);
        fovStatisticsDiff.ninetiethPrctileCorrelation = (fovStatisticsTwo.ninetiethPrctileCorrelation  - fovStatisticsOne.ninetiethPrctileCorrelation);
        fovStatisticsDiff.msMapUtilizationRatio = (fovStatisticsTwo.msMapUtilizationRatio  - fovStatisticsOne.msMapUtilizationRatio);
        
        % Median CDPP 12th Magnitude Stars
        medianCDPPFigureHandle = fovPlottingClass.plot_on_modout([fovStatisticsDiff.module], [fovStatisticsDiff.output], [fovStatisticsDiff.medianCDPP]);
        medianCDPPFigureHandle = fovPlottingClass.make_ccd_legend_plot(medianCDPPFigureHandle);
        colorbar;
       %colormap('Cool');
        title ('Median CDPP for 12th Magnitude Stars; DIFFERENCE: (two - one)');
        
        % 10th Percentile CDPP 12th Magnitude Stars
        tenthCDPPFigureHandle = fovPlottingClass.plot_on_modout([fovStatisticsDiff.module], [fovStatisticsDiff.output], [fovStatisticsDiff.tenthPrctileCDPP]);
        tenthCDPPFigureHandle = fovPlottingClass.make_ccd_legend_plot(tenthCDPPFigureHandle);
        colorbar;
       %colormap('Cool');
        title ('10th percentile CDPP for 12th Magnitude Stars; DIFFERENCE: (two - one)');
        
        % MAP Untilization
        mapFigureHandle = fovPlottingClass.plot_on_modout([fovStatisticsDiff.module], [fovStatisticsDiff.output], [fovStatisticsDiff.mapUtilizationRatio]);
        mapFigureHandle = fovPlottingClass.make_ccd_legend_plot(mapFigureHandle);
        colorbar;
       %colormap('Cool');
        title ('MAP Utilization Ratio; DIFFERENCE: (two - one)');
        
        % msMAP Untilization
        msMapFigureHandle = fovPlottingClass.plot_on_modout([fovStatisticsDiff.module], [fovStatisticsDiff.output], [fovStatisticsDiff.msMapUtilizationRatio]);
        msMapFigureHandle = fovPlottingClass.make_ccd_legend_plot(msMapFigureHandle);
        colorbar;
       %colormap('Cool');
        title ('Multi-Scale MAP Utilization Ratio; DIFFERENCE: (two - one)');
        
        % 90th percentile Total Goodness
        totalGoodnessFigureHandle = fovPlottingClass.plot_on_modout([fovStatisticsDiff.module], [fovStatisticsDiff.output], [fovStatisticsDiff.ninetiethPrctileTotalGoodness ]);
        totalGoodnessFigureHandle = fovPlottingClass.make_ccd_legend_plot(totalGoodnessFigureHandle);
        colorbar;
       %colormap('Cool');
        title ('Bottom 10th Percentile Total Goodness; DIFFERENCE: (two - one)');
        
        % 90th percentile Introduced Noise
        introducedNoiseFigureHandle = fovPlottingClass.plot_on_modout([fovStatisticsDiff.module], [fovStatisticsDiff.output], [fovStatisticsDiff.ninetiethPrctileIntroducedNoise ]);
        introducedNoiseFigureHandle = fovPlottingClass.make_ccd_legend_plot(introducedNoiseFigureHandle);
        colorbar;
       %colormap('Cool');
        title ('Bottom 10th Percentile Introduced Noise; DIFFERENCE: (two - one)');
        
        % 90th pertentile correlation
        correlationFigureHandle = fovPlottingClass.plot_on_modout([fovStatisticsDiff.module], [fovStatisticsDiff.output], [fovStatisticsDiff.ninetiethPrctileCorrelation ]);
        correlationFigureHandle = fovPlottingClass.make_ccd_legend_plot(correlationFigureHandle);
        colorbar;
       %colormap('Cool');
        title ('Bottom 10th Percentile Correlation; DIFFERENCE: (two - one)');
        
        if (~exist(figureSaveDir, 'dir'))
            mkdir(figureSaveDir);
        end
        
        if (exist(figureSaveDir, 'dir') && ~isempty(figureSaveDir))
            saveas(medianCDPPFigureHandle, [figureSaveDir, '/', 'medianCdppDifference.fig']);
            saveas(tenthCDPPFigureHandle , [figureSaveDir, '/', 'tenthCdppDifference.fig']);
            saveas(mapFigureHandle , [figureSaveDir, '/', 'mapUtilizationDifference.fig']);
            saveas(msMapFigureHandle , [figureSaveDir, '/', 'msMapUtilizationDifference.fig']);
            saveas(totalGoodnessFigureHandle , [figureSaveDir, '/', 'totalGoodnessDifference.fig']);
            saveas(introducedNoiseFigureHandle , [figureSaveDir, '/', 'introducedNoiseDifference.fig']);
            saveas(correlationFigureHandle , [figureSaveDir, '/', 'correlationDifference.fig']);
        
            save ([figureSaveDir, '/', 'fovStatisticsDiff.mat'],        'fovStatisticsDiff');
        end

    end % function fov_metrics_comparison_plots 


end % static methods for plotting goodness

end % classdef
