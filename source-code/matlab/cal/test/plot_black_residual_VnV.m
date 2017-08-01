function mapOut = plot_black_residual_VnV(rootPath,varargin)
% function mapOut = plot_black_residual_VnV(rootPath,varargin)
% 
% This tool displays the following CAL pipeline plots for review during V&V
% or DAWG processes.
%   1) cal_black_residuals_imagesc
%   2) cal_1dblack_over_pixels_cad#
%   3) cal_1dblack_over_fgs_pixels_cad#
%   4) cal_smear_difference_imagesc
%   5) cal_dark_current_metric
%   6) cal_std_dev_black_residuals
% 
% Scene dependent rows as identified by the map consistent with the unit of
% work are marks as red dashes on figures 2, 3 and 6. 
%
% Results for each CAL task file directory are displayed one at a time,
% pausing between results. Hit any key to continue.
%
% Note this tool attemps to read the task file map from 'map-struct.mat' at
% the root directory level. If this file exists it will use that map. If it
% does not exist it will create that map and return it as output and save 
% this map as the vaiable 'mapOut' in the file 'map-struct.mat'under the
% root directory for future runnings of this tool. The default is to produce 
% plots for all indices in mapOut with a pause of DEFAULT_PAUSE between plot
% displays. varargin{1} allows the user to midify the number of seconds to 
% pause. varargin{2} allows the user to filter by Kepler quarter of K2 
% campaign. varagin{3} allows the user to filter by channel number.
% 
% INPUTS:
%   rootPath    ==  full pathname to directory which contains the CAL task file
%                   directories (cal-matlab-###-####)
%   varargin{1} ==  autopause in seconds. Set <= 0 for hard pause.
%   varargin{2} ==  Kepler quarter number or K2 campaign number
%   varargin{3} ==  Channel #
% OUTPUT:
%   mapOut  ==  stucture containing mapping to CAL task file sub
%               directories
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

channels = 1:84;
DEFAULT_PAUSE = 2;

p1 = [1320, 670, 560, 420];
p2 = [1884, 670, 560, 420];
p3 = [2448, 670, 560, 420];
p4 = [1320, 165, 560, 420];
p5 = [1884, 165, 560, 420];
p6 = [2448, 165, 560, 420];


TASK_FILE_MAP_FILENAME = 'task-file-map.mat';

if ~exist([rootPath,TASK_FILE_MAP_FILENAME],'file')
    mapOut = produce_matlab_taskfile_map( rootPath, 'cal' );
    save([rootPath,TASK_FILE_MAP_FILENAME],'mapOut');
else
    load([rootPath,TASK_FILE_MAP_FILENAME]);
end

% set logical indexing based on quarter or campaign
if nargin > 1
    autopause = max([0 varargin{1}]);
    if nargin > 2
        q = varargin{2};
        if ~mapOut(1).isK2Uow
            lidx = [mapOut.quarter] == q;
        else
            lidx = [mapOut.k2Campaign] == q;
        end
        if nargin > 3
            ch = varargin{3};
            nidx = [mapOut(lidx).channel] == ch;
            lidx = lidx & nidx;
        end
    else
        % use all indices
        lidx = true(size(mapOut));
    end
else
    % use default pause
    autopause = DEFAULT_PAUSE;
    % use all indices
    lidx = true(size(mapOut));
end

idx = find(lidx);

for i=1:length(channels)
    
    thisIdx = find([mapOut(idx).channel] == channels(i));
    
    if ~isempty(thisIdx)                
        
        for subIdx = 1:length(thisIdx)
            
            disp(mapOut(idx(thisIdx(subIdx))));
            
            figHandles = -ones(6,1);
            figDrawn = false(6,1);
        
            % open black residual image
            if exist([mapOut(idx(thisIdx(subIdx))).taskFileFullPath,'figures/cal_black_residuals_imagesc.fig'],'file')
                figHandles(1) = openfig([mapOut(idx(thisIdx(subIdx))).taskFileFullPath,'figures/cal_black_residuals_imagesc.fig']);
                axis xy;
                set(gcf,'Position',p1);
                figDrawn(1) = true;
            end

            % open black fit over pixels
            d = dir([mapOut(idx(thisIdx(subIdx))).taskFileFullPath,'figures/cal_1dblack_over_pixels*.fig']);
            if ~isempty(d)
                figHandles(2) = openfig([mapOut(idx(thisIdx(subIdx))).taskFileFullPath,'figures/',d(end).name]);
                set(gcf,'Position',p2);
                figDrawn(2) = true;
            end

            % open black fit over fgs pixels
            d = dir([mapOut(idx(thisIdx(subIdx))).taskFileFullPath,'figures/cal_1dblack_over_fgs_pixels*.fig']);
            if ~isempty(d)
                figHandles(3) = openfig([mapOut(idx(thisIdx(subIdx))).taskFileFullPath,'figures/',d(end).name]);
                set(gcf,'Position',p3);
                figDrawn(3) = true;
            end

            % open smear difference image
            if exist([mapOut(idx(thisIdx(subIdx))).taskFileFullPath,'figures/cal_smear_difference_imagesc.fig'],'file')
                figHandles(4) = openfig([mapOut(idx(thisIdx(subIdx))).taskFileFullPath,'figures/cal_smear_difference_imagesc.fig']);
                axis xy;
                set(gcf,'Position',p4);
                figDrawn(4) = true;
            end

            % open dark current metric
            if exist([mapOut(idx(thisIdx(subIdx))).taskFileFullPath,'figures/cal_dark_current_metric.fig'],'file')
                figHandles(5) = openfig([mapOut(idx(thisIdx(subIdx))).taskFileFullPath,'figures/cal_dark_current_metric.fig']);
                set(gcf,'Position',p5);
                figDrawn(5) = true;
            end

            % open stdev black residuals plot
            if exist([mapOut(idx(thisIdx(subIdx))).taskFileFullPath,'figures/cal_std_dev_black_residuals.fig'],'file')
                figHandles(6) = openfig([mapOut(idx(thisIdx(subIdx))).taskFileFullPath,'figures/cal_std_dev_black_residuals.fig']);
                set(gcf,'Position',p6);
                figDrawn(6) = true;
            end

            % load scene dependent row markers based on start time of unit of work
            if mapOut(idx(thisIdx(subIdx))).isK2Uow
                S = scene_dependent_rows_K2(mapOut(idx(thisIdx(subIdx))).channel,mapOut(idx(thisIdx(subIdx))).k2Campaign);
            else
                S = scene_dependent_rows(mapOut(idx(thisIdx(subIdx))).channel,mapOut(idx(thisIdx(subIdx))).season);
            end
            if any(S)
                % mark black fit over pixels figures
                for iFig = [2,3,6]
                    if figDrawn(iFig)
                        figure(figHandles(iFig));
                        hold on;
                        vline(find(S));
                        hold off;
                    end
                end
            end
            if autopause > 0
                pause(autopause);
            else
                pause;
            end
            close all;
        end
    end
end