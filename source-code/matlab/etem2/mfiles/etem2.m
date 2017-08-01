function etem2(gloabalConfigurationStruct, localConfigurationStruct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% function etem2(gloabalConfigurationStruct, localConfigurationStruct)
%
% execute etem2 to generate simulated data for a Kepler module output
%
% gloabalConfigurationStruct is the name used to execute a matlab script
% which sets up the data structures controlling this run.  This name is the
% name of the .m file without the .m extension
%
% optional: localConfigurationStruct that contains fields used to override
% or supplement fields in gloabalConfigurationStruct.  This struct must
% contain the following fields:
%     .numberOfTargetsRequested
%     .runStartDate
%     .runDuration
%     .runDurationUnits: 'days' or 'cadences'
%     .moduleNumber
%     .outputNumber
%     .observingSeason
%     .cadenceType: 'long' or 'short'
%
% Example:
%   etem2('ETEM2_single_plane_inputs', localConfigurationStruct)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% set up required paths
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
etem2StartTime = clock;

if ~isdeployed
    oldPath = path;
    set_paths;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% create the global parent runParamsObject, create
% ouput directory
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

runParamsData = gloabalConfigurationStruct.runParamsData;
ccdData = gloabalConfigurationStruct.ccdData;
tadInputData = gloabalConfigurationStruct.tadInputData;
catalogReaderData = gloabalConfigurationStruct.catalogReaderData;

if nargin > 1
    runParamsData.simulationData.numberOfTargetsRequested = ...
        localConfigurationStruct.numberOfTargetsRequested;

    runParamsData.simulationData.runStartDate = localConfigurationStruct.runStartDate;
    runParamsData.simulationData.runDuration = localConfigurationStruct.runDuration;
    runParamsData.simulationData.runDurationUnits = localConfigurationStruct.runDurationUnits;
    
    runParamsData.simulationData.moduleNumber = localConfigurationStruct.moduleNumber;
    runParamsData.simulationData.outputNumber = localConfigurationStruct.outputNumber;
    runParamsData.simulationData.observingSeason = localConfigurationStruct.observingSeason;

    runParamsData.simulationData.cadenceType = localConfigurationStruct.cadenceType;
end

% save the input structs for configuration accounting
outputDirectory = ...
    [runParamsData.etemInformation.etem2OutputLocation filesep ...
    set_directory_name(runParamsData.simulationData.moduleNumber, ...
	runParamsData.simulationData.outputNumber, ...
	runParamsData.simulationData.observingSeason, ...
	runParamsData.simulationData.cadenceType)]; 
runParamsData.etemInformation.outputDirectory = outputDirectory;
if ~exist(outputDirectory, 'dir')
    mkdir(outputDirectory);
end
% set the SVN version string
runParamsData.etemInformation.svnVersion = ETEM2_svn_version; 
save([outputDirectory filesep 'inputStructs'], 'runParamsData', ...
	'ccdData', 'tadInputData', 'catalogReaderData');

% make a clean run if desired
if runParamsData.keplerData.makeClean
    pluginList = defined_plugin_classes();

    runParamsData.keplerData.supressSmear = 1;
    runParamsData.keplerData.useMeanBias = 1;
    ccdData.flatFieldDataList = [];
    ccdData.electronicsEffectDataList = [];
    ccdData.electronsToAduData = pluginList.linearEtoAData;
    % force the linear electrons to ADU object to get gain from the fc model
    ccdData.electronsToAduData.electronsPerADU = -1;
end

runParamsObject = runParamsClass(runParamsData);
clear runParamsData

% check to see that there are no rolls during the run
rollTimesStruct = retrieve_roll_time_model();
rollTimes = rollTimesStruct.mjds;
runStartTimeMjd = get(runParamsObject, 'runStartTime');
runEndTimeMjd = get(runParamsObject, 'runEndTime');

if ~isempty(rollTimes)
	if ~isempty(find(runStartTimeMjd < rollTimes & runEndTimeMjd > rollTimes))
		error('etem2:run spans a roll');
	end
end


% seed the random number generator to produce deterministic output based on
% the runtime, module and output
randSeed = get(runParamsObject, 'runStartTime') ...
    + get(runParamsObject, 'moduleNumber') + get(runParamsObject, 'outputNumber')
rand('twister', randSeed);
randn('state', randSeed);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% create the CCD object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
ccdObject = ccdClass(ccdData, runParamsObject);
if isfield(ccdData, 'motionOnly')
    return;
end

clear ccdData
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% read in the catalog data for this module, output, time period
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

% instantiate the catalog reader class specified in the input mat file
catalogReaderString = ...
    ['catalogReaderObject = ' catalogReaderData.className ...
    '(catalogReaderData, runParamsObject);'];
catalogReaderString
eval(catalogReaderString);
clear catalogReaderData

outputDirectory = get(runParamsObject, 'outputDirectory');

if ~exist([outputDirectory filesep 'catalogData.mat'], 'file')
    catalogData = read_catalog(catalogReaderObject, ccdObject);
    catalogData

    % project the stars onto the ccd
    catalogData = project_stars(ccdObject, catalogData);
    catalogData
else
    load([outputDirectory filesep 'catalogData.mat'], 'catalogData');
end
save([outputDirectory filesep 'catalogData.mat'], 'catalogData');


ssrOutputDirectory = [get(runParamsObject, 'outputDirectory') ...
    filesep get(ccdObject, 'ssrOutputDirectory')]
if ~exist(ssrOutputDirectory, 'dir')
    mkdir(ssrOutputDirectory);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% compute the pixel polynomials
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

baseRun = get(runParamsObject, 'initialScienceRun');
if baseRun == -1
    % assign stars to each of the ccdPlanes if this is not a continuation run
    ccdObject = assign_stars(ccdObject, catalogData);
else
    ccdObject = assign_stars_from_run(ccdObject, baseRun, catalogData);
end
ccdObject = compute_polys(ccdObject);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% get the TAD input (which has to match targetList)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

if isempty(tadInputData)
	% there are no tad targets so we're done
	save([outputDirectory filesep 'runParamsObject.mat'], 'runParamsObject');
	if get(runParamsObject, 'cleanOutput')
    	clean_etem2_output(outputDirectory)
	else
		save([outputDirectory filesep 'ccdObject.mat'], 'ccdObject');
	end
	return;
end

if ~exist([outputDirectory filesep 'tadInputStruct.mat'], 'file')
    % instantiate the tad input class specified in the input mat file
    tadInputString = ...
        ['tadInputObject = ' tadInputData.className '(tadInputData, runParamsObject);'];
    tadInputString
    eval(tadInputString);
    clear tadInputData

    tadInputStruct = get_tad_input(tadInputObject, catalogData);
	if isempty(tadInputStruct)
		% there are no tad targets so we're done
		save([outputDirectory filesep 'ccdObject.mat'], 'ccdObject');
		save([outputDirectory filesep 'runParamsObject.mat'], 'runParamsObject');
		return;
	end

    save([outputDirectory filesep 'tadInputStruct.mat'], 'tadInputStruct');
else
    load([outputDirectory filesep 'tadInputStruct.mat'], 'tadInputStruct');
end

% set the target list from the TAD input
targetList = [tadInputStruct.targetDefinitions.keplerId];

write_tad_ssr_bytes(ccdObject, tadInputStruct);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% assign stars and targets and pixels of interest to the CCD planes
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

% read the tad input to get the pixels of interest
ccdObject = set_pixels_of_interest(ccdObject, tadInputStruct);
% create the targetScienceManager object in ccdObject, which assigns light
% curves to each target
ccdObject = create_target_science_manager(ccdObject, catalogData);
% place the target data on each ccdPlane
ccdObject = assign_targets(ccdObject, targetList);
% compute the target polynomials
ccdObject = compute_target_poly(ccdObject);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% compute the time series
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

% identify badly fit pixels
ccdObject = identify_bad_fit_regions(ccdObject);
% actually render the time series
ccdObject = render_time_series(ccdObject);


whos

save([outputDirectory filesep 'runParamsObject.mat'], 'runParamsObject');

if get(runParamsObject, 'cleanOutput')
    clean_etem2_output(outputDirectory)
else
    save([outputDirectory filesep 'ccdObject.mat'], 'ccdObject');
end

if ~isdeployed
    path(oldPath);
end

etem2EndTime = clock;
etem2ElapsedTime = etime(etem2EndTime, etem2StartTime);
disp(['total elapsed time ' num2str(etem2ElapsedTime) ' seconds = ' ...
    num2str(etem2ElapsedTime/60) ' minutes = ' num2str(etem2ElapsedTime/3600) ' hours']);
save([outputDirectory filesep 'runTime.mat'], 'etem2EndTime', 'etem2StartTime', 'etem2ElapsedTime');
