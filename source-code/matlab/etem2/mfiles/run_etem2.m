function run_etem2(configurationStruct)
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
if ~isdeployed
    oldPath = path;
    set_paths;
end

runParamsData = configurationStruct.runParamsData;
ccdData = configurationStruct.ccdData;

runStartDate = runParamsData.simulationData.runStartDate;
runDuration = runParamsData.simulationData.runDuration;
runDurationUnits = runParamsData.simulationData.runDurationUnits;

switch runDurationUnits
	case 'days'
		runDurationDays = runDuration;
		
	case 'cadences'
		% compute the duration of this type of cadence
    	exposureTotalTime = runParamsData.keplerData.integrationTime + runParamsData.keplerData.transferTime;
   		shortCadenceDuration = runParamsData.keplerData.exposuresPerShortCadence*exposureTotalTime; % seconds
    	exposuresPerLongCadence ...
        	= runParamsData.keplerData.exposuresPerShortCadence*runParamsData.keplerData.shortsPerLongCadence; % exposures / long; 
    	longCadenceDuration = exposuresPerLongCadence*exposureTotalTime; % seconds

    	switch runParamsData.simulationData.cadenceType
        	case 'long'
            	% seconds per cadence
            	cadenceDuration = longCadenceDuration;

        	case 'short'
            	% seconds per cadence
            	cadenceDuration = shortCadenceDuration;

        	otherwise 
            	error('runParamsObject.cadenceType must be either <long> or <short>');
    	end
    	cadencesPerDay = 3600*24/cadenceDuration;
 		runDurationDays = runDuration/cadencesPerDay; 

	otherwise
        error('runParamsData.runDurationUnits must be either <days> or <cadences>');
end
		
runStartTimeMjd = datestr2mjd(runStartDate);
runEndTimeMjd = runStartTimeMjd + runDurationDays;
disp(['requested start date: ' runStartDate ' requested end date ' ...
	julian2datestr(datestr2julian(runStartDate)+runDurationDays)]);

rollTimesStruct = retrieve_roll_time_model();
% get the roll times between runStartTimeMjd and runEndTimeMjd
% (retrieve_roll_time_model actually returns all roll times as of 2/9/2008)
rollTimes = rollTimesStruct.mjds;
% break the run times into a vector of roll times that contain runStartTimeMjd and runEndTimeMjd
% clip to roll times in this interval, including the rollTimeBuffer
rollTimeBuffer = 0.5; 
rollTimes = rollTimes(rollTimes + rollTimeBuffer > runStartTimeMjd ...
	& rollTimes - rollTimeBuffer < runEndTimeMjd);
% create a list of run start and end times that are rollTimeBuffer away from each start and end roll time
if ~isempty(rollTimes)
	% make sure the start date is not in the second roll interval
	if rollTimes(1) - rollTimeBuffer < runStartTimeMjd && rollTimes(1) + rollTimeBuffer > runStartTimeMjd
		% set the first runStartTime 12 hours after the first roll date
		etem2RunStartTimesMjd(1) = rollTimes(1) + rollTimeBuffer;
		etem2RunDurationDays(1) = rollTimes(2) - rollTimeBuffer - etem2RunStartTimesMjd(1);
		rollTimeFirstIndex = 2;
	else
		% start time is priort to first roll - rollTimeBuffer
		etem2RunStartTimesMjd(1) = runStartTimeMjd;		
		etem2RunDurationDays(1) = rollTimes(1) - rollTimeBuffer - etem2RunStartTimesMjd(1);		
		rollTimeFirstIndex = 1;
	end
	etem2RunTimesIndex = 2; % start filling in the second entry
	for rollTimeIndex = rollTimeFirstIndex:length(rollTimes)-1
		etem2RunStartTimesMjd(etem2RunTimesIndex) = rollTimes(rollTimeIndex) + rollTimeBuffer;
		etem2RunDurationDays(etem2RunTimesIndex) = rollTimes(rollTimeIndex+1) - rollTimeBuffer ...
			 - etem2RunStartTimesMjd(etem2RunTimesIndex);
		etem2RunTimesIndex = etem2RunTimesIndex + 1;
	end
	% check to see if runEndTimeMjd after the last roll interval
	if rollTimes(end) + rollTimeBuffer < runEndTimeMjd
		etem2RunStartTimesMjd(etem2RunTimesIndex) = rollTimes(end) + rollTimeBuffer;
		etem2RunDurationDays(etem2RunTimesIndex) = runEndTimeMjd - (rollTimes(end) + rollTimeBuffer);
	end		
else
	% the run time is entirely within rolls
	etem2RunStartTimesMjd = runStartTimeMjd;
	etem2RunDurationDays = runDurationDays;
end

% display the resulting start and stop times
for i=1:length(rollTimes)
	disp(['roll start: ' julian2datestr(mjd_to_julian_day(rollTimes(i) - rollTimeBuffer)) ...
		' roll end: ' julian2datestr(mjd_to_julian_day(rollTimes(i) + rollTimeBuffer))]);
end
for i=1:length(etem2RunStartTimesMjd)
	disp(['start date: ' julian2datestr(mjd_to_julian_day(etem2RunStartTimesMjd(i))) ...
		' end date: ' julian2datestr(mjd_to_julian_day(etem2RunStartTimesMjd(i) + etem2RunDurationDays(i)))]);
end

% now construct the input configuration structures for the individual ETEM runs
% first get RA and Dec of the center pixel on the mod/out
firstModule = runParamsData.simulationData.moduleNumber;
firstOutput = runParamsData.simulationData.outputNumber;
centerRow = fix(runParamsData.keplerData.numVisibleRows/2);
centerCol = fix(runParamsData.keplerData.numVisibleCols/2);
raDec2PixModel = retrieve_ra_dec_2_pix_model();
raDec2PixObject = raDec2PixClass(raDec2PixModel, 'one-based');
[firstRa firstDec] = pix_2_ra_dec(raDec2PixObject, firstModule, firstOutput, ...
	centerRow, centerCol, datestr2mjd(runStartDate));
for runNumber = 1:length(etem2RunStartTimesMjd)
	% initialize the input struct
	runConfigurationStruct(runNumber) = configurationStruct;
	% make text string of start date
	runConfigurationStruct(runNumber).runParamsData.simulationData.runStartDate ...
		= julian2datestr(mjd_to_julian_day(etem2RunStartTimesMjd(runNumber)));
	% set the duration
	runConfigurationStruct(runNumber).runParamsData.simulationData.runDuration ...
		= etem2RunDurationDays(runNumber);
	% set the duration units
	runConfigurationStruct(runNumber).runParamsData.simulationData.runDurationUnits ...
		= 'days';
	% compute the module and output of the orientation for each roll state
	[mod out row col] = ra_dec_2_pix(raDec2PixObject, firstRa, firstDec, ...
		etem2RunStartTimesMjd(runNumber));
	runConfigurationStruct(runNumber).runParamsData.simulationData.moduleNumber = mod;
	runConfigurationStruct(runNumber).runParamsData.simulationData.outputNumber = out;
	% set the season 
	season = find_season(etem2RunStartTimesMjd(runNumber), rollTimesStruct.mjds);
	runConfigurationStruct(runNumber).runParamsData.simulationData.observingSeason = season;
	% set the initial science run directory name
	if runNumber == 1
		initialScienceRun = set_directory_name(mod, out, season, ...
			runParamsData.simulationData.cadenceType);
	else
		runConfigurationStruct(runNumber).runParamsData.simulationData.initialScienceRun = initialScienceRun;
	end
	
	runConfigurationStruct(runNumber).runParamsData.simulationData
end

for runNumber = 1:length(runConfigurationStruct)
	etem2(runConfigurationStruct(runNumber));
end

if ~isdeployed
    path(oldPath);
end
