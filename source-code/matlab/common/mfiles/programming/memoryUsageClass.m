%*************************************************************************************************************
% classdef memoryUsageClass
%
% This class is for monitoring Matlab memory usage. The procedure for using the class is very simple:
%
% 1) Construct the class:
%
%   global memUsage; % Make memUsage global so that it can be accessed in each function you call
%   memUsage = memoryUsageClass('Title'); % where <Title> is a name to reference the object.
%
% 2) At each point within your code (and within any function if memUsage is declared global) add a memory usage log entry
%
%   memUsage.add('comment'); %  where <comment> references to the line or point in the code
%
% 3) It's a good idea to record a final entry right at the end of your code
%
%   memUsage.add('end');
%
% 4) The memory usage can be plotted at any time with
%
%   memUsage.plot_memory_usage
%
% NOTE: this class relies on the get_memory_usage_function which is only compatible with linux since it relies on the format of the pmap function.
% 
%*************************************************************************************************************
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

classdef memoryUsageClass < handle

    properties
        stamp = repmat(struct('time', [], 'comment', [], 'virMbUsed', [], 'resMbUsed', []), [0,0]);
        titleString = []; % Used when plotting the memory usage
        PID  = []; % Process ID for this Matlab session
    end

%*************************************************************************************************************
    methods

    %*************************************************************************************************************
    % constructor
    %
    % Creat the object and add in a first memory stamp.
    %
    %*************************************************************************************************************

    function obj = memoryUsageClass (titleString)

        if (exist('titleString'))
            obj.titleString = titleString;
        end

        obj.PID = feature('getpid');

        obj.add('start');
        
    end % constructor

    %*************************************************************************************************************
    % function [virMbUsed, resMbUsed] = add (comment)
    %
    % Adds a timestamp with comment to stamp
    %
    % Inputs:
    %   comment     -- [char] comment to attach to each memory stamp
    %
    % Outputs:
    %   virMbUsed   -- [double] Total Vitrual memory used in MagaBytes
    %   resMbUsed   -- [double] Total Resident memory used in MagaBytes
    %
    %*************************************************************************************************************

    function [virMbUsed, resMbUsed] = add (obj, comment)

        % Add usage line
 
        nextIndex = length(obj.stamp)+1;
  
        % datestr(time) to get human readable time
        obj.stamp(nextIndex).time = now;
        obj.stamp(nextIndex).comment = comment;
        [obj.stamp(nextIndex).virMbUsed obj.stamp(nextIndex).resMbUsed] = get_matlab_memory_usage;

        virMbUsed = obj.stamp(nextIndex).virMbUsed;
        resMbUsed = obj.stamp(nextIndex).virMbUsed;

    end % function add

    %*************************************************************************************************************
    % function plot_memory_usage
    %
    % Plots both the virtual and resident memory at each of the recorded memory stamps. Using the Data Cursor one can click on any point and obtain:
    %   Time for each stamp
    %   Virtual memory used in GigaBytes
    %   Resident memory used in GigaBytes
    %   Comment attached to each memory stamp
    %
    %*************************************************************************************************************
    function plot_memory_usage (obj)

        memUsageFig = figure;
        startTime = obj.stamp(1).time;

        subplot(2,1,1);
        plot([obj.stamp.virMbUsed]/1024, '-*r');
        title([obj.titleString, ' PID: ', num2str(obj.PID), ' PDC Virtual Memory Usage']);
        xlabel('Memory stamp entry');
        ylabel('Virtual memory utilization [GB]');
        set(gca,'XTick',[])
        grid on;

        subplot(2,1,2);
        plot([obj.stamp.resMbUsed]/1024, '-*b');
        title('PDC Resident Memory Usage');
        xlabel('Memory stamp entry');
        ylabel('Resident memory utilization [GB]');
        set(gca,'XTick',[])
        grid on;

        % Turn on data cursor mode to display comments for each timestamp
        datacursormode(memUsageFig )
        dcm_obj = datacursormode(memUsageFig);
        set(dcm_obj,'UpdateFcn', @obj.cursorUpdateFcn)

    end % plot_memory_usage

    end % public methods


%*************************************************************************************************************
    methods (Access = 'private')

    %*************************************************************************************************************
    %   function output_txt = cursorUpdateFcn(obj, ~, event_obj)
    %
    % This function sets the cursor text when in data cursor mode
    %
    % Inputs:
    %   ~            Currently not used (empty)
    %   event_obj    Handle to event object
    %
    % Outputs:
    %   output_txt   Data cursor text string (string or cell array of strings).
    %
    %*************************************************************************************************************

    function output_txt = cursorUpdateFcn(obj, ~, event_obj)

        pos = get(event_obj,'Position');
        output_txt = {['Time: ', datestr(obj.stamp(pos(1)).time)],...
                      ['virGbUsage: ',num2str(obj.stamp(pos(1)).virMbUsed/1024,4)],...
                      ['resGbUsage: ',num2str(obj.stamp(pos(1)).resMbUsed/1024,4)],...
                      ['Comment: ', obj.stamp(pos(1)).comment]};

    end

end % private methods

%*************************************************************************************************************
    methods (Static)

    function memData = plot_total_matlab_memory_usage_from_file (filename)

        fid = fopen(filename , 'r');
        if (fid <3)
            error('Error opening task file map');
        end
 
        format = '%u %u %u %u %u %u %*[^\n]';
        memData = textscan(fid, format, 'headerlines', 1, 'delimiter', ' ');
        
        % Convert from KB to GB
        for iField = 1 : length(memData)
            memData{iField} = double(memData{iField}) / 1024 / 1024;
        end

        memData{7} = memData{1} + memData{3} + memData{5};
        memData{8} = memData{2} + memData{4} + memData{6};
        
        figure;
        subplot(2,1,1);
        plot(memData{1}, '-b');
        hold on;
        plot(memData{3}, '-r');
        plot(memData{5}, '-m');
        plot(memData{7}, '-k', 'LineWidth',2);
        legend('Mother Process', 'Daughter Process', 'Granddaughter Process', 'Total Usage', 'Location', 'Best');
        xlabel('Time [Minutes]');
        ylabel('Memory usage [GB]');
        title('Total Matlab Virtual Memory Usage over all processes');

        subplot(2,1,2);
        plot(memData{2}, '-b');
        hold on;
        plot(memData{4}, '-r');
        plot(memData{6}, '-m');
        plot(memData{8}, '-k', 'LineWidth',2);
        legend('Mother Process', 'Daughter Process', 'Granddaughter Process', 'Total Usage', 'Location', 'Best');
        xlabel('Time [Minutes]');
        ylabel('Memory usage [GB]');
        title('Total Matlab Resident Memory Usage over all processes');

    end

end % Static methods

end % memoryUsageClass
