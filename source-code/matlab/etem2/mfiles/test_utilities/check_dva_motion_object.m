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
pluginList = defined_plugin_classes();
etem2ConfigurationStruct = ETEM2_inputs_current();

modules = [2:4 6:20 22:24];
modOutIndex = 1;
cornerRow = [1 1 1024 1024 1]';
cornerCol = [1 1100 1100 1 1]';

rowSpacing = [1 512 1024];
colSpacing = [1 550 1100];
[colGrid rowGrid] = meshgrid(colSpacing, rowSpacing);

runParamsObject = runParamsClass(etem2ConfigurationStruct.runParamsData);
startTime = get(runParamsObject, 'runStartTime');
runTime = startTime:15:startTime + 30;
timeIndex = length(runTime);
figure
hold on;
for m = 1:length(modules)
	module = modules(m);
	for output = 1:4
        etem2ConfigurationStruct.runParamsData.simulationData.moduleNumber = module;
        etem2ConfigurationStruct.runParamsData.simulationData.outputNumber = output;
        
        runParamsObject = runParamsClass(etem2ConfigurationStruct.runParamsData);
        dvaMotionObject = dvaMotionClass(pluginList.dvaMotionData, runParamsObject);
        raDec2PixObject = get(get(runParamsObject, 'raDec2PixObject'), 'raDec2PixObject');
        
		for i=1:size(rowGrid, 1)
			for j=1:size(rowGrid, 2)
                % via the dvaMotion object
                [modOut(modOutIndex).motion(i,j).deltaRow modOut(modOutIndex).motion(i,j).deltaCol] = ...
                    get_motion(dvaMotionObject, rowGrid(i,j), colGrid(i,j), runTime);
				modOut(modOutIndex).motion(i,j).row = rowGrid(i,j) + modOut(modOutIndex).motion(i,j).deltaRow;
				modOut(modOutIndex).motion(i,j).col = colGrid(i,j) + modOut(modOutIndex).motion(i,j).deltaCol;
                % directly via raDec2Pix
% 				[modOut(modOutIndex).catalogRa(i,j) modOut(modOutIndex).catalogDec(i,j)] = ...
% 					pix_2_ra_dec(raDec2PixObject, module, output, rowGrid(i,j), ...
% 					colGrid(i,j), runTime(1), 0);
%                 for t=1:length(runTime)
%                     [modOut(modOutIndex).motion(i,j).row(t) modOut(modOutIndex).motion(i,j).col(t)] ...
%                         = ra_dec_2_pix(raDec2PixObject, ...
%                         modOut(modOutIndex).catalogRa(i,j), modOut(modOutIndex).catalogDec(i,j), ...
%                         runTime(t), 1);
%                 end
                
				[modOut(modOutIndex).baseRa(i,j) modOut(modOutIndex).baseDec(i,j)] = ...
					pix_2_ra_dec(raDec2PixObject, module, output, ...
					rowGrid(i,j), ...
                    colGrid(i,j), ...
                    runTime(1), 1);
				[modOut(modOutIndex).initRa(i,j) modOut(modOutIndex).initDec(i,j)] = ...
					pix_2_ra_dec(raDec2PixObject, module, output, ...
					rowGrid(i,j), ...
                    colGrid(i,j), ...
                    runTime(timeIndex), 1);
				[modOut(modOutIndex).motionRa(i,j) modOut(modOutIndex).motionDec(i,j)] = ...
					pix_2_ra_dec(raDec2PixObject, module, output, ...
					modOut(modOutIndex).motion(i,j).row(timeIndex), ...
                    modOut(modOutIndex).motion(i,j).col(timeIndex), ...
                    runTime(timeIndex), 1);
				modOut(modOutIndex).deltaRa(i,j) = modOut(modOutIndex).motionRa(i,j) ...
                    - modOut(modOutIndex).initRa(i,j);
				modOut(modOutIndex).deltaDec(i,j) = modOut(modOutIndex).motionDec(i,j) ...
                    - modOut(modOutIndex).initDec(i,j);
            end
		end
		[modOut(modOutIndex).cornerRa modOut(modOutIndex).cornerDec] = ...
			pix_2_ra_dec(raDec2PixObject, repmat(module, size(cornerRow)), repmat(output, size(cornerRow)), ...
			cornerRow, cornerCol, runTime(1), 1);

		plot(modOut(modOutIndex).cornerRa, modOut(modOutIndex).cornerDec, 'r--');
		quiver(modOut(modOutIndex).baseRa, modOut(modOutIndex).baseDec, ...
            modOut(modOutIndex).deltaRa, modOut(modOutIndex).deltaDec, 0.8);
		text(mean(modOut(modOutIndex).cornerRa), mean(modOut(modOutIndex).cornerDec), num2str(modOutIndex));
		drawnow;
		
		modOutIndex = modOutIndex + 1;
        
        clear runParamsObject raDec2PixObject dvaMotionObject
	end
end
hold off
set(gca, 'YDir', 'reverse');

save modOutDvaObject.mat modOut
