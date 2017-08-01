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
if ~exist('targetList1')
    q1 = 'output/run_long_m16o1s1';

    load([q1 '/scienceTargetList.mat']);
    targetList1 = targetList;
    scienceProperties1 = targetScienceProperties;
    backgroundBinaryList1 = backgroundBinaryList;

    quarterData(1).targetDefs = get_target_definitions(q1, 'targets');
    load configuration_files/maskDefinitions;

    quarterData(1).pixValues = get_pixel_time_series(q1, 'targets');
end

%% check transits
for property = 2:length(scienceProperties1)
	transitingList = scienceProperties1(property).keplerId;
	for s=1:length(transitingList)
    	kid = transitingList(s);
		targetPixId1 = find([quarterData(1).pixValues.keplerId] == kid);
		pixelFlux1 = sum(quarterData(1).pixValues(targetPixId1).pixelValues, 2);
		
    	targetListId = find([targetList1.keplerId] == kid);
 		for curveNumber = 1:length(targetList1(targetListId).initialData)
			if strcmp(targetList1(targetListId).initialData(curveNumber).description, ...
				scienceProperties1(property).description)
				break;
			end
        end
        % find the first 
 
	   	lc1 = targetList1(targetListId).lightCurveList(curveNumber).lightCurve;
 	   	compositeLc1 = targetList1(targetListId).compositeLightCurve;
    	tv1 = targetList1(targetListId).lightCurveList(curveNumber).timeVector/(24*3600);
    	tv1 = tv1 - tv1(1);
        
		period = targetList1(targetListId).initialData(curveNumber).data.orbitalPeriod;
		periodUnits = targetList1(targetListId).initialData(curveNumber).data.orbitalPeriodUnits;
		
	   	figure(1);
		subplot(3,1,1)
    	plot(tv1, lc1);
    	title([scienceProperties1(property).description ' ' num2str(s) ...
			': KID ' num2str(kid) ' period ' num2str(period) ' ' periodUnits 's light curve']);
        xlabel('modified Julian days')
		subplot(3,1,2)
    	plot(tv1, compositeLc1);
    	title('composite light curve');
		xlabel('modified Julian days')
		subplot(3,1,3)
    	plot(tv1, pixelFlux1 - pixelFlux1(1));
    	title('pixel flux time series');
		xlabel('modified Julian days')
    	pause;
	end
end

%% check background binaries
for b=1:length(backgroundBinaryList)
    kid = backgroundBinaryList1(b).targetKeplerId;
	targetPixId = [find([quarterData(1).pixValues.keplerId] == kid)];
	pixelFlux1 = sum(quarterData(1).pixValues(targetPixId(1)).pixelValues, 2);

    tv1 = backgroundBinaryList1(b).timeVector/(24*3600);
    tv1 = tv1 - tv1(1);

	period = backgroundBinaryList(b).initialData.data.orbitalPeriod;
	periodUnits = backgroundBinaryList(b).initialData.data.orbitalPeriodUnits;
	
	for q=1:length(targetPixId)
		nCadences = size(quarterData(q).pixValues(targetPixId(q)).pixelValues, 1);
		mask = maskDefinitions(quarterData(q).targetDefs(targetPixId(q)).maskIndex);
		pixRow = quarterData(q).targetDefs(targetPixId(q)).referenceRow + 1 + [mask.offsets.row];
		pixCol = quarterData(q).targetDefs(targetPixId(q)).referenceColumn + 1 + [mask.offsets.column];
		minRow = min(pixRow);
		minCol = min(pixCol);

        for c=1:nCadences
            targetData = [];
    		for i=1:length(pixRow)
        		targetData(i) ...
            		= quarterData(q).pixValues(targetPixId(q)).pixelValues(c,i);
    		end
    		minData = min(targetData);
    		targetData = targetData - minData;
    		flux = sum(sum(targetData));
    		centroid(q).x(c) = pixRow*targetData'/flux;
    		centroid(q).y(c) = pixCol*targetData'/flux;
        end	
 	end
	
    figure(2);
	subplot(4,1,1)
    plot(tv1, backgroundBinaryList1(b).lightCurve);
    title(['Background Binary ' num2str(b) ...
		': target KID ' num2str(kid) ' period ' num2str(period) ' ' periodUnits 's light curve']);
	xlabel('modified Julian days')
	subplot(4,1,2)
    plot(tv1, centroid(1).x);
    title('centroid x');
	xlabel('modified Julian days')
	subplot(4,1,3)
    plot(tv1, centroid(1).y);
    title('centroid y');
	xlabel('modified Julian days')
	subplot(4,1,4)
    plot(tv1, pixelFlux1 - pixelFlux1(1));
    title('pixel flux time series');
	xlabel('modified Julian days')
    pause;
end
