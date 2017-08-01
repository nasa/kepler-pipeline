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
if ~exist('dataList')
%     dataList(1).location = 'output/multi_quarter_nominal/run_long_m15o4s15';
%     dataList(2).location = 'output/multi_quarter_nominal/run_long_m3o4s16';

%     dataList(1).location = 'output/oneyear/run_long_m16o1s10';
%     dataList(2).location = 'output/oneyear/run_long_m24o1s11';
%     dataList(3).location = 'output/oneyear/run_long_m10o1s12';
%     dataList(4).location = 'output/oneyear/run_long_m2o1s13';
%     dataList(5).location = 'output/oneyear/run_long_m16o1s14';

    dataList(1).location = 'output/gainModulation/run_long_m12o1s1/';
    for tl = 1:length(dataList)
        load([dataList(tl).location '/scienceTargetList.mat']);
        dataList(tl).targetList = targetList;
        dataList(tl).scienceProperties = targetScienceProperties;
        dataList(tl).backgroundBinaryList = backgroundBinaryList;
        dataList(tl).targetDefs = get_target_definitions(dataList(tl).location, 'targets');
        dataList(tl).pixValues = get_pixel_time_series(dataList(tl).location, 'targets');
    end
    load configuration_files/maskDefinitions;
end
if ~exist('barycentricTimeCorrectionObject')
	etem2ConfigurationStruct = ETEM2_inputs_current();
	runParamsObject = runParamsClass(etem2ConfigurationStruct.runParamsData);

	barycentricTimeCorrectionObject = get(runParamsObject, 'barycentricTimeCorrectionObject');
end

%% check transits
% use the entries in the first quarter to define the transits
for property = 2:length(dataList(1).scienceProperties) % skip stellar variability
	transitingList = dataList(1).scienceProperties(property).keplerId;
	for s=1:length(transitingList)
    	kid = transitingList(s);
        for tl=1:length(dataList)
            dataList(tl).pixId = find([dataList(tl).pixValues.keplerId] == kid);
			background = min(min(dataList(tl).pixValues(dataList(tl).pixId).pixelValues));
            dataList(tl).pixFlux = sum(dataList(tl).pixValues(dataList(tl).pixId).pixelValues - background, 2);
        end
		
    	targetListId = find([dataList(1).targetList.keplerId] == kid);
 		for curveNumber = 1:length(dataList(1).targetList(targetListId).initialData)
			if strcmp(dataList(1).targetList(targetListId).initialData(curveNumber).description, ...
				dataList(1).scienceProperties(property).description)
				break;
			end
        end


        for tl=1:length(dataList)
            dataList(tl).lc = dataList(tl).targetList(targetListId).lightCurveList(curveNumber).lightCurve;
            dataList(tl).clc = dataList(tl).targetList(targetListId).compositeLightCurve;
            dataList(tl).tv = dataList(tl).targetList(targetListId).lightCurveList(curveNumber).timeVector/(24*3600);
        end
		timeOrigin = dataList(1).tv(1);
		startTimeJulian = mjd_to_julian_day(dataList(1).tv(1));
        for tl=1:length(dataList)
            dataList(tl).tv = dataList(tl).tv - timeOrigin;
        end
        
		period = dataList(1).targetList(targetListId).initialData(curveNumber).data.orbitalPeriod;
		periodUnits = dataList(1).targetList(targetListId).initialData(curveNumber).data.orbitalPeriodUnits;
		
		% find the measured transit times
		transitCenters = [];
		for tl = 1:length(dataList)
			transitCenters = [transitCenters find_transit_center(dataList(tl).lc, dataList(tl).tv)];
		end
		
        [m, i] = min(dataList(1).lc);
        % find the predicted transit times
		transitTimes = [];
		for tl = 1:length(dataList)
			transitTimes = [transitTimes ...
				dataList(tl).targetList(targetListId).lightCurveList(curveNumber).lightCurveData.transitTimesMks];
		end
		transitTimes = (transitTimes-15*60)/(24*3600) - timeOrigin;
		transitTimes = unique(transitTimes);
		transitTimes(transitTimes < 0) = [];
		
		% compute the difference between the observered and predicted transit times
		
		% get the barycentric correction for those times
		transitCentersJulian = startTimeJulian + transitTimes;
		barycentricCorrection = get_time_correction( ...
			barycentricTimeCorrectionObject, ...
			dataList(1).targetList(targetListId).ra, ...
			dataList(1).targetList(targetListId).dec, transitCentersJulian);		
		
		transitTimesX = repmat(transitTimes,2,1);
		transitTimesY = repmat([m;1.01], 1, length(transitTimes));
		
		transitCentersX = repmat(transitCenters,2,1);
		transitCentersY = repmat([m;1], 1, length(transitCenters));
		
		% transits may fall in gaps between months, so identify missing transit centers
		if length(transitCenters) ~= length(transitTimes)
			centerDiff = diff(transitCenters);
			medianDiff = median(centerDiff);
			badDiffIndex = find(centerDiff > 1.3*medianDiff);
			for i=1:length(badDiffIndex)
				% add an entry for each bad diff after each bad diff index
				transitCenters = [transitCenters(1:badDiffIndex(i)) ...
					transitCenters(badDiffIndex(i)) + medianDiff ...
					transitCenters(badDiffIndex(i)+1:end)];
			end
		end
		if length(transitTimes) >= length(transitCenters)
			transitTimes = transitTimes(1:length(transitCenters));
			barycentricCorrection = barycentricCorrection(1:length(transitCenters));
			transitDiffs = transitCenters - transitTimes;
			figure(20);
			plot(transitCenters, (transitDiffs)*24*60, ...
				transitCenters, (barycentricCorrection)/60);
		end
        %         
    	figure(1);
        clf;
		subplot(3,1,1)
        hold on;
        for tl=1:length(dataList)
            plot(dataList(tl).tv, dataList(tl).lc);
        end
        hold off;
%     	plot(tvMatrix, lcMatrix);
    	title([dataList(1).scienceProperties(property).description ' ' num2str(s) ...
			': KID ' num2str(kid) ' period ' num2str(period) ' ' periodUnits 's light curve']);
% 		line(repmat(transitTimes, 2, 1), repmat([min([lc1;lc2]); max([lc1;lc2])], 1, length(transitTimes))); 
		line(transitTimesX, transitTimesY); 
		line(transitCentersX, transitCentersY); 
        xlabel('modified Julian days')
		subplot(3,1,2)
        hold on;
        for tl=1:length(dataList)
            plot(dataList(tl).tv, dataList(tl).clc);
        end
        hold off;
    	title('composite light curve');
		xlabel('modified Julian days')
		subplot(3,1,3)
        hold on;
        for tl=1:length(dataList)
            plot(dataList(tl).tv, dataList(tl).pixFlux);
        end
    	title('pixel flux time series');
		xlabel('modified Julian days')
    	pause;
	end
end

%% check background binaries
for b=1:length(backgroundBinaryList)
    kid = dataList(1).backgroundBinaryList(b).targetKeplerId;
    for tl=1:length(dataList)
        dataList(tl).pixId = find([dataList(tl).pixValues.keplerId] == kid);
        dataList(tl).pixFlux = sum(dataList(tl).pixValues(dataList(tl).pixId).pixelValues, 2);
    end

    targetListId = find([dataList(1).targetList.keplerId] == kid);
    for tl=1:length(dataList)
        dataList(tl).lc = dataList(tl).backgroundBinaryList(b).lightCurve;
        dataList(tl).tv = dataList(tl).backgroundBinaryList(b).timeVector/(24*3600);
    end
	timeOrigin = dataList(1).tv(1);
	startTimeJulian = mjd_to_julian_day(dataList(1).tv(1));
    for tl=1:length(dataList)
        dataList(tl).tv = dataList(tl).tv - timeOrigin;
    end

	period = dataList(1).backgroundBinaryList(b).initialData.data.orbitalPeriod;
	periodUnits = dataList(1).backgroundBinaryList(b).initialData.data.orbitalPeriodUnits;
	
	% find the measured transit times
	transitCenters = [];
	for tl = 1:length(dataList)
		transitCenters = [transitCenters find_transit_center(dataList(tl).lc, dataList(tl).tv)];
	end

    [m, i] = min(dataList(1).lc);
    % find the predicted transit times
	transitTimes = [];
	for tl = 1:length(dataList)
		transitTimes = [transitTimes ...
			dataList(tl).backgroundBinaryList(b).lightCurveData.transitTimesMks];
	end
	transitTimes = (transitTimes-15*60)/(24*3600) - timeOrigin;
	transitTimes = unique(transitTimes);
	transitTimes(transitTimes < 0) = [];
		
	% compute the difference between the observered and predicted transit times

	% get the barycentric correction for those times
	transitCentersJulian = startTimeJulian + transitTimes;
	barycentricCorrection = get_time_correction( ...
		barycentricTimeCorrectionObject, ...
		dataList(1).targetList(targetListId).ra, ...
		dataList(1).targetList(targetListId).dec, transitCentersJulian);		

	transitTimesX = repmat(transitTimes,2,1);
	transitTimesY = repmat([m;1.01], 1, length(transitTimes));

	transitCentersX = repmat(transitCenters,2,1);
	transitCentersY = repmat([m;1], 1, length(transitCenters));

	% transits may fall in gaps between months, so identify missing transit centers
	if length(transitCenters) ~= length(transitTimes)
		centerDiff = diff(transitCenters);
		medianDiff = median(centerDiff);
		badDiffIndex = find(centerDiff > 1.3*medianDiff);
		for i=1:length(badDiffIndex)
			% add an entry for each bad diff after each bad diff index
			transitCenters = [transitCenters(1:badDiffIndex(i)) ...
				transitCenters(badDiffIndex(i)) + medianDiff ...
				transitCenters(badDiffIndex(i)+1:end)];
		end
	end
	if length(transitTimes) >= length(transitCenters)
		transitTimes = transitTimes(1:length(transitCenters));
		barycentricCorrection = barycentricCorrection(1:length(transitCenters));
		transitDiffs = transitCenters - transitTimes;
		figure(20);
		plot(transitCenters, (transitDiffs)*24*60, ...
			transitCenters, (barycentricCorrection)/60);
	end

	% compute target centroids
    for tl=1:length(dataList)
        dataList(tl).pixId = find([dataList(tl).pixValues.keplerId] == kid);
        dataList(tl).pixFlux = sum(dataList(tl).pixValues(dataList(tl).pixId).pixelValues, 2);
    end
    for tl=1:length(dataList)
		nCadences = size(dataList(tl).pixValues(dataList(tl).pixId).pixelValues, 1);
		mask = maskDefinitions(dataList(tl).targetDefs(dataList(tl).pixId).maskIndex);
		pixRow = dataList(tl).targetDefs(dataList(tl).pixId).referenceRow + 1 + [mask.offsets.row];
		pixCol = dataList(tl).targetDefs(dataList(tl).pixId).referenceColumn + 1 + [mask.offsets.column];
		minRow = min(pixRow);
		minCol = min(pixCol);

        for c=1:nCadences
            targetData = [];
    		for i=1:length(pixRow)
        		targetData(i) ...
            		= dataList(tl).pixValues(dataList(tl).pixId).pixelValues(c,i);
    		end
    		minData = min(targetData);
    		targetData = targetData - minData;
    		flux = sum(sum(targetData));
    		dataList(tl).centroidx(c) = pixRow*targetData'/flux;
    		dataList(tl).centroidy(c) = pixCol*targetData'/flux;
        end	
 	end
	
    figure(2);
	clf;
	subplot(4,1,1)
    hold on;
    for tl=1:length(dataList)
        plot(dataList(tl).tv, dataList(tl).lc);
    end
    hold off;
	line(transitTimesX, transitTimesY); 
	line(transitCentersX, transitCentersY); 
    title(['Background Binary ' num2str(b) ...
		': target KID ' num2str(kid) ' period ' num2str(period) ' ' periodUnits 's light curve']);
	xlabel('modified Julian days')
	subplot(4,1,2)
    hold on;
    for tl=1:length(dataList)
        plot(dataList(tl).tv, dataList(tl).centroidx);
    end
    hold off;
    title('centroid x');
	xlabel('modified Julian days')
	subplot(4,1,3)
    hold on;
    for tl=1:length(dataList)
        plot(dataList(tl).tv, dataList(tl).centroidy);
    end
    hold off;
    title('centroid y');
	xlabel('modified Julian days')
	subplot(4,1,4)
    hold on;
    for tl=1:length(dataList)
        plot(dataList(tl).tv, dataList(tl).pixFlux);
    end
    hold off;
    title('pixel flux time series');
	xlabel('modified Julian days')
    pause;
end
