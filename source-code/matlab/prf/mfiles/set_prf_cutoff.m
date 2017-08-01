function set_prf_cutoff(channel, iteration, taskMap, location)
% function set_prf_cutoff(channel, iteration, taskMap, location)
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

c = channel;
userData.channel = channel;

taskMapArray = read_task_map(taskMap);
dataLocation = [location '/prf-matlab-'];
directoryName = [dataLocation num2str(taskMapArray(iteration,c).instanceId) ...
    '-' num2str(taskMapArray(iteration,c).taskId)];
load([directoryName '/prf-outputs-0.mat']);
load([directoryName '/' outputsStruct.prfCollectionBlobFileName]);

[userData.module, userData.output] = convert_to_module_output(c);

for i=1:5
    userData.prfObject(i) = prfClass(inputStruct(i).polyStruct);
    [userData.prfData(i).array, userData.prfData(i).row, userData.prfData(i).column] ...
        = make_array(userData.prfObject(i), 100, 1);
end

subPlotPositionLeft = [0.05 0.7 0.05 0.7 0.35];
subPlotPositionBottom = [0.6 0.6 0.05 0.05 0.35];
subPlotSize = 0.3;

load newCutoffValues.mat
userData.cutoffValue = cutoffValues;

figureHandle = figure;
set(figureHandle, 'UserData', userData);
for i=1:5
    sliderHandle(i) = uicontrol(figureHandle,'Style','slider',...
                    'Max',1e-2,'Min',1e-3,'Value',1e-3,...
                    'SliderStep',[0.01 0.2],...
                    'Units', 'normalized', ...
                    'Position',[subPlotPositionLeft(i), ...
                        subPlotPositionBottom(i) - .04, ...
                        subPlotSize, 0.02], ...
                    'Callback', {@sliderCallback, i});
end
sliderCallback(sliderHandle(1), [], 1);
pause;

newUserData = get(figureHandle, 'UserData');
disp(['final cutoff values = ' num2str(newUserData.cutoffValue(userData.channel, :))]);
close(figureHandle);
cutoffValues = newUserData.cutoffValue;
save newCutoffValues.mat cutoffValues

function sliderCallback(sliderHandle, eventData, prf)

subPlotPositionLeft = [0.05 0.7 0.05 0.7 0.35];
subPlotPositionBottom = [0.6 0.6 0.05 0.05 0.35];
subPlotSize = 0.3;

figureHandle = get(sliderHandle, 'Parent');
userData = get(figureHandle, 'UserData');

prfData = userData.prfData;

cutoffValue = get(sliderHandle, 'Value');

userData.cutoffValue(userData.channel, prf) = cutoffValue;


for i=1:5
    subplot('Position', [subPlotPositionLeft(i), subPlotPositionBottom(i), subPlotSize, subPlotSize]);
    contour(prfData(i).row, prfData(i).column, prfData(i).array, ...
        linspace(1e-4,max(max(prfData(i).array)), 50));
    hold on;
    contour(prfData(i).row, prfData(i).column, prfData(i).array, ...
        [userData.cutoffValue(userData.channel, i) ...
        userData.cutoffValue(userData.channel, i)], 'Color', 'Red');
    title(['channel ' num2str(userData.channel) ' m ' num2str(userData.module) ...
        ' o ' num2str(userData.output) ' prf ' num2str(i) ...
        ' cutoff value = ' num2str(userData.cutoffValue(userData.channel, i))]);
    hold off;

    xlabel('row pixel');
    ylabel('column pixel');
    axis equal;
end    

disp(['new cutoff values = ' num2str(userData.cutoffValue(userData.channel, :))]);
set(figureHandle, 'UserData', userData);
