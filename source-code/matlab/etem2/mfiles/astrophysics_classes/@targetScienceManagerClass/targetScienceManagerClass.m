function targetScienceManagerObject = targetScienceManagerClass( ...
    targetScienceManagerData, ccdObject, runParamsObject, catalogData)
% function targetScienceManagerObject = targetScienceManagerClass(targetScienceManagerData, ccdObject, ...
%	runParamsObject, catalogData)
%
% Manager of science data for each target.
% This class maintains a list of all targets, each entry of which includes 
%	- a list of lightcurve_classes for each target which in turn include parameters of each component
%		lightcurve
%	- a composite light curve for each target
%
% targetScienceManagerData includes a specification of the assignment of light curves to targets as
% science specification structures
%
% science specification structures contain the following fields:
%	- selectionType: "all", "random", "byKeplerId"
%	- lightcurve plugin name and data.  Each lightcurve plugin contains:
%		- a range of parameters specific to that light curve.  The actual values for that 
%			light curve are selceted by the constructor function of the plugin.
%		- a method for creating the light curve given the starting time, # of cadences and 
%			time interval between cadences: create_lighecurve(startTime, numCadences, cadenceDuration);
%		- a mechod for dumping the data for each light curve for each target, both as a mat file and
%			information about the curve as a text file
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

if isempty(targetScienceManagerData)
	targetScienceManagerData.targetSpecifiction(1).selectionType = 'none';
	targetScienceManagerData.targetSpecifiction(1).description = '';
	targetScienceManagerData.targetSpecifiction(1).lightCurveData = [];
	targetScienceManagerData.targetSpecifiction(1).object = [];
	targetScienceManagerData.backgroundBinaryList = [];
end

% save initialization data for continuation runs
outputDirectory = get(runParamsObject, 'outputDirectory');

targetListFileName = [outputDirectory filesep 'scienceTargetList.mat'];
if exist(targetListFileName, 'file')
    load(targetListFileName, 'targetList', 'backgroundBinaryList');
    targetScienceManagerData.targetList = targetList;
    targetScienceManagerData.backgroundBinaryList = backgroundBinaryList;
	% create background binaries
	targetScienceManagerData = reload_background_binaries(targetScienceManagerData, runParamsObject);
    % parse the target science specifications
    targetScienceManagerObject = class(targetScienceManagerData, 'targetScienceManagerClass', ...
        ccdObject, runParamsObject);
	% compute the background binary structures
	targetScienceManagerObject = compute_background_binaries(targetScienceManagerObject, ccdObject);
    return;
else
    % initialize the global light curve objects
    targetScienceManagerData = init_global_light_curves(targetScienceManagerData, runParamsObject);

    baseRun = get(runParamsObject, 'initialScienceRun');
    if baseRun == -1
        % initialize the target data
        targetScienceManagerData = init_target_list(targetScienceManagerData, ccdObject, catalogData);

        % parse the target science specifications
        [targetScienceManagerData targetScienceProperties] ...
            = parse_science_specifications(targetScienceManagerData, runParamsObject);
        % create background binaries
        targetScienceManagerData = make_background_binaries(targetScienceManagerData, runParamsObject);
    else
        % load the keplerIds of the stars from the base run
		if baseRun(1) == '/'
		    % it's a full path, so use it directly
		    load([baseRun filesep 'scienceTargetList.mat'], ...
        	    'targetList', 'backgroundBinaryList', 'targetScienceProperties');
		else
			% else look in the local run directory
        	runPath = get(runParamsObject, 'etem2OutputLocation');
		    load([runPath filesep baseRun filesep  'scienceTargetList.mat'], ...
        	    'targetList', 'backgroundBinaryList', 'targetScienceProperties');
		end
        % load([runPath filesep baseRun filesep 'scienceTargetList.mat'], ...
        %     'targetList', 'backgroundBinaryList', 'targetScienceProperties');
        for t=1:length(targetList)
            targetList(t).lightCurveList = [];
        end
        for t=1:length(backgroundBinaryList)
            backgroundBinaryList(t).lightCurve = [];
        end
        targetScienceManagerData.targetList = targetList;
        targetScienceManagerData.backgroundBinaryList = backgroundBinaryList;
        % parse the target science specifications
        targetScienceManagerData ...
            = set_science_specifications(targetScienceManagerData, runParamsObject);
        % create background binaries
        targetScienceManagerData = reload_background_binaries(targetScienceManagerData, runParamsObject);
    end
end

% instantiate the targetScienceManagerClass
targetScienceManagerData
save([outputDirectory filesep 'targetScienceManagerData.mat'], 'targetScienceManagerData');
targetScienceManagerObject = class(targetScienceManagerData, 'targetScienceManagerClass', ...
	ccdObject, runParamsObject);

% light curve classes have been assigned to targets.  Next we create the light curves and accumulate 
% into the composite light curve for each target
targetScienceManagerObject = create_light_curves(targetScienceManagerObject, runParamsObject);
% compute the background binary structures
targetScienceManagerObject = compute_background_binaries(targetScienceManagerObject, ccdObject);

% save the target list
targetList = targetScienceManagerObject.targetList;
% erase the lightCurveList objects
for t=1:length(targetList)
    for l=1:length(targetList(t).lightCurveList)
       targetList(t).lightCurveList(l).object = [];
    end
end
% save the background binary list
if isfield(struct(targetScienceManagerObject), 'backgroundBinaryList')
    backgroundBinaryList = targetScienceManagerObject.backgroundBinaryList;
    % erase the backgroundBinaryList objects
    for t=1:length(backgroundBinaryList)
       backgroundBinaryList(t).object = [];
    end
else
    backgroundBinaryList = [];
end

% save the assignment of stars to ccdPlane
% get the ccdObject's plane list
ccdPlaneList = get(ccdObject, 'ccdPlaneObjectList');
for p=1:length(ccdPlaneList)
    planeStars(p).starAssignment = get(ccdPlaneList(p), 'selectedKicIdIndex');
end
% save the simulation start time
runStartTime = get(runParamsObject, 'runStartTime');
save([outputDirectory filesep 'scienceTargetList.mat'], 'targetList', ...
    'targetScienceProperties', 'backgroundBinaryList', 'planeStars', 'runStartTime');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function targetScienceManagerData = init_global_light_curves(targetScienceManagerData, runParamsObject)
% here we define special global light curve objects that are on all targets
nScienceSpecs = length(targetScienceManagerData.targetSpecifiction);
for s=1:nScienceSpecs
	spec = targetScienceManagerData.targetSpecifiction(s);
    if ~isempty(spec.lightCurveData)
        switch spec.lightCurveData.classType
            case 'global'
                classString = ...
                    ['targetScienceManagerData.targetSpecifiction(s).object = ' ...
                    spec.lightCurveData.className '(spec.lightCurveData, ' ...
                    '[], [], runParamsObject);'];
                eval(classString);
                clear classString;

            otherwise
                targetScienceManagerData.targetSpecifiction(s).object = [];
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function targetScienceManagerData = init_target_list(targetScienceManagerData, ccdObject, catalogData)
% create the target light curve list for each target
targetStruct = get(ccdObject, 'targetStruct');
if isempty(targetStruct)
	error('targetScienceManagerClass:empty targetStruct');
end

targetScienceManagerData.targetList = repmat(struct( ...
	'keplerId', 0, 'lightCurveList', [], 'lightCurveData', [], ...
	'compositeLightCurve', []), ...
	1, length(unique([targetStruct.keplerId])));
scienceTarget = 1;
for t=1:length(targetStruct)
	% there may be multiple targets per keplerId, so filter out repetitions
	if ~ismember(targetStruct(t).keplerId, [targetScienceManagerData.targetList.keplerId])
		% add the catalog data
		keplerId = targetStruct(t).keplerId;
		targetScienceManagerData.targetList(scienceTarget).keplerId = keplerId;
		catalogIndex = find(keplerId == catalogData.kicId);
		targetScienceManagerData.targetList(scienceTarget).keplerMagnitude = ...
			catalogData.keplerMagnitude(catalogIndex);
		targetScienceManagerData.targetList(scienceTarget).ra = ...
			catalogData.ra(catalogIndex);
		targetScienceManagerData.targetList(scienceTarget).dec = ...
			catalogData.dec(catalogIndex);
		targetScienceManagerData.targetList(scienceTarget).logSurfaceGravity = ...
			catalogData.logSurfaceGravity(catalogIndex);
		targetScienceManagerData.targetList(scienceTarget).logMetallicity = ...
			catalogData.logMetallicity(catalogIndex);
		targetScienceManagerData.targetList(scienceTarget).effectiveTemperature = ...
			catalogData.effectiveTemperature(catalogIndex);
% 		targetScienceManagerData.targetList(scienceTarget).radius = ...
% 			catalogData.radius(catalogIndex);
% 		targetScienceManagerData.targetList(scienceTarget).mass = ...
% 			catalogData.mass(catalogIndex);
		targetScienceManagerData.targetList(scienceTarget).flux = ...
			catalogData.flux(catalogIndex);
		targetScienceManagerData.targetList(scienceTarget).row = ...
			catalogData.row(catalogIndex);
		targetScienceManagerData.targetList(scienceTarget).column = ...
			catalogData.column(catalogIndex);
		targetScienceManagerData.targetList(scienceTarget).rowFraction = ...
			catalogData.rowFraction(catalogIndex);
		targetScienceManagerData.targetList(scienceTarget).columnFraction = ...
			catalogData.columnFraction(catalogIndex);
		targetScienceManagerData.targetList(scienceTarget).visiblePixelIndex = ...
			catalogData.visiblePixelIndex(catalogIndex);
		targetScienceManagerData.targetList(scienceTarget).subPixelIndex = ...
			catalogData.subPixelIndex(catalogIndex);
		scienceTarget = scienceTarget + 1;
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [targetScienceManagerData targetScienceProperties] ...
    = parse_science_specifications(targetScienceManagerData, runParamsObject)
% parse the target science specifications
nScienceTargets = length(targetScienceManagerData.targetList);
nScienceSpecs = length(targetScienceManagerData.targetSpecifiction);
if nScienceSpecs == 0
	targetScienceProperties = [];
	return;
end
for s=1:nScienceSpecs
	spec = targetScienceManagerData.targetSpecifiction(s);
    targetScienceProperties(s).description = spec.description;
	switch spec.selectionType
		case 'all' % put this specification on all targets
			for t=1:nScienceTargets
				% instantiate the light curve class
				nLightCurves = length(targetScienceManagerData.targetList(t).lightCurveList);
                targetScienceManagerData.targetList(t).initialData(nLightCurves+1).data = [];
                % see if this object is global and is already instantiated
                targetScienceManagerData = add_light_curve_object(targetScienceManagerData, ...
                    s, t, nLightCurves+1, runParamsObject);
                targetScienceProperties(s).keplerId(t) = targetScienceManagerData.targetList(t).keplerId;
                targetScienceManagerData.targetList(t).initialData(nLightCurves+1).data = ...
                    get_initial_data(targetScienceManagerData.targetList(t).lightCurveList(nLightCurves+1).object);
                targetScienceManagerData.targetList(t).initialData(nLightCurves+1).lightCurveData = ...
                    spec.lightCurveData;
                targetScienceManagerData.targetList(t).initialData(nLightCurves+1).description = ...
                    spec.description;
                targetScienceManagerData.targetList(t).lightCurveList(nLightCurves+1).description = ...
                    spec.description;
			end
		case 'random'
			numToSelect = spec.selectionNumber;
            switch spec.selectionOn
                case 'properties'
					% we have to do the following in a loop because sometimes the desired
					% fields are empty and the temp arrays can't fall out of sync with 
					% targetScienceManagerData.targetList indexing
					mag = zeros(size(targetScienceManagerData.targetList));
					effT = zeros(size(targetScienceManagerData.targetList));
					logG = zeros(size(targetScienceManagerData.targetList));
					for t = 1:length(targetScienceManagerData.targetList)
						if ~isempty(targetScienceManagerData.targetList(t).keplerMagnitude)
                    		mag(t) = targetScienceManagerData.targetList(t).keplerMagnitude;
						else
							mag(t) = -1;
						end
						if ~isempty(targetScienceManagerData.targetList(t).effectiveTemperature)
                    		effT(t) = targetScienceManagerData.targetList(t).effectiveTemperature;
						else
							effT(t) = -1;
						end
 						if ~isempty(targetScienceManagerData.targetList(t).logSurfaceGravity)
                   			logG(t) = targetScienceManagerData.targetList(t).logSurfaceGravity;
						else
							logG(t) = -1;
						end
					end
                    % pick out the targets in the magnitude range
                    potentialTargetIndex = find( ...
                        mag >= spec.selectionMagnitudeRange(1) & mag <= spec.selectionMagnitudeRange(2) ...
                        & effT >= spec.selectionEffTempRange(1) & effT <= spec.selectionEffTempRange(2) ...
                        & logG >= spec.selectionlogGRange(1) & logG <= spec.selectionlogGRange(2) ...
                        );
                    % randomly pick numToSelect elements from that list
                    randomizedSelectedIndex = potentialTargetIndex(randperm(length(potentialTargetIndex)));
                    numToSelect = min(numToSelect, length(randomizedSelectedIndex));
                    if numToSelect > 0
                        selectedTargetIndex = randomizedSelectedIndex(1:numToSelect);
                        for tIndex=1:length(selectedTargetIndex)
							disp(['------>>> ' spec.description ' # ' num2str(tIndex)]);
                            t = selectedTargetIndex(tIndex);
                            nLightCurves = length(targetScienceManagerData.targetList(t).lightCurveList);
                            targetScienceManagerData.targetList(t).initialData(nLightCurves+1).data = [];
                            targetScienceManagerData = add_light_curve_object(targetScienceManagerData, ...
                                s, t, nLightCurves+1, runParamsObject);
                            targetScienceProperties(s).keplerId(tIndex) = targetScienceManagerData.targetList(t).keplerId;
                            targetScienceManagerData.targetList(t).initialData(nLightCurves+1).data = ...
                                get_initial_data(targetScienceManagerData.targetList(t).lightCurveList(nLightCurves+1).object);
                            targetScienceManagerData.targetList(t).initialData(nLightCurves+1).lightCurveData = ...
                                spec.lightCurveData;
                            targetScienceManagerData.targetList(t).initialData(nLightCurves+1).description = ...
                                spec.description;
                            targetScienceManagerData.targetList(t).lightCurveList(nLightCurves+1).description = ...
                                spec.description;
                        end
                    end
                    
                otherwise
                    error('targetScienceManagerData.targetSpecifiction.selectionOn: unknown type');
            end
		case 'byKeplerId'
			t = find([targetScienceManagerData.targetList.keplerId] == spec.keplerId);
            if isempty(t)
                disp('specification by Kepler ID: Kepler ID not found, ignoring');
            else
                nLightCurves = length(targetScienceManagerData.targetList(t).lightCurveList);
                targetScienceManagerData.targetList(t).initialData(nLightCurves+1).data = [];
                targetScienceManagerData = add_light_curve_object(targetScienceManagerData, ...
                    s, t, nLightCurves+1, runParamsObject);
                targetScienceProperties(s).keplerId(tIndex) = targetScienceManagerData.targetList(t).keplerId;
                targetScienceManagerData.targetList(t).initialData(nLightCurves+1).data = ...
                    get_initial_data(targetScienceManagerData.targetList(t).lightCurveList(nLightCurves+1).object);
                targetScienceManagerData.targetList(t).initialData(nLightCurves+1).lightCurveData = ...
                    spec.lightCurveData;
                targetScienceManagerData.targetList(t).initialData(nLightCurves+1).description = ...
                    spec.description;
                targetScienceManagerData.targetList(t).lightCurveList(nLightCurves+1).description = ...
                    spec.description;
            end
            
		case 'none'
            for t=1:nScienceTargets
                targetScienceManagerData.targetList(t).lightCurveList = [];
            end
			disp('no science specifications');
		otherwise
			disp('unknown selection type');
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function targetScienceManagerData ...
    = set_science_specifications(targetScienceManagerData, runParamsObject)
% create science lightcurve objects from data in
% targetScienceManagerData.targetList
nScienceTargets = length(targetScienceManagerData.targetList);
for targetNumber = 1:nScienceTargets
    target = targetScienceManagerData.targetList(targetNumber);
    nLightCurves = length(target.initialData);
    for lightCurveNumber=1:nLightCurves
        spec.lightCurveData = target.initialData(lightCurveNumber).lightCurveData;
        % check to see if this matches a global object
        isGlobal = false;
        for s=1:length(targetScienceManagerData.targetSpecifiction)
            inputSpec = targetScienceManagerData.targetSpecifiction(s);
            % if this object matches a global spec for which an object
            % exists
            if strcmp(spec.lightCurveData.className, inputSpec.lightCurveData.className) ...
                    && ~isempty(inputSpec.object)
                isGlobal = true;
                targetScienceManagerData.targetList(targetNumber).lightCurveList(lightCurveNumber).object ...
                    = inputSpec.object;
                if ~isempty(targetScienceManagerData.targetList(targetNumber).initialData(lightCurveNumber).data)
                    targetScienceManagerData.targetList(targetNumber).lightCurveList(lightCurveNumber).object = ...
                        initialize(targetScienceManagerData.targetList(targetNumber).lightCurveList(lightCurveNumber).object, ...
                        target.initialData(lightCurveNumber).data);
                else
                    targetScienceManagerData.targetList(targetNumber).lightCurveList(lightCurveNumber).object = ...
                        initialize(targetScienceManagerData.targetList(targetNumber).lightCurveList(lightCurveNumber).object);
                end
            end
        end
        % if the object was not defined above define it
        if ~isGlobal
            classString = get_class_string(spec.lightCurveData.className);
            eval(classString);
            clear classString;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function targetScienceManagerObject = create_light_curves(targetScienceManagerObject, runParamsObject)
nScienceTargets = length(targetScienceManagerObject.targetList);
for t=1:nScienceTargets
	target = targetScienceManagerObject.targetList(t);
	for l=1:length(target.lightCurveList)
		% call create_light_curve on the specified object
		[targetScienceManagerObject.targetList(t).lightCurveList(l).lightCurve, ...
			targetScienceManagerObject.targetList(t).lightCurveList(l).timeVector, ...
			targetScienceManagerObject.targetList(t).lightCurveList(l).lightCurveData]  ...
            = create_light_curve(targetScienceManagerObject.targetList(t).lightCurveList(l).object);
	end
	% update the local target object so it has the light curves
	target = targetScienceManagerObject.targetList(t);
	% the light curve list may be empty if there are no target science specifications
	if ~isempty(target.lightCurveList)
		% initialize composite light curve
		targetScienceManagerObject.targetList(t).compositeLightCurve = ...
			ones(size(target.lightCurveList(1).lightCurve));
		% build composite light curve
		for l=1:length(target.lightCurveList)
			targetScienceManagerObject.targetList(t).compositeLightCurve = ...
				targetScienceManagerObject.targetList(t).compositeLightCurve ...
				.* target.lightCurveList(l).lightCurve;
		end
	else
		% we need to intialize an null light curve with the right number of cadences
		targetScienceManagerObject.targetList(t).compositeLightCurve = ...
			ones(get(runParamsObject, 'runDurationCadences'), 1);		
	end
end
% get background binary light curves
if ~isfield(struct(targetScienceManagerObject), 'backgroundBinaryList')
    return;
end
if ~isempty(targetScienceManagerObject.backgroundBinaryList)
    backgroundBinaryList = targetScienceManagerObject.backgroundBinaryList;
    for l=1:length(backgroundBinaryList)
        % call create_light_curve on the specified object
        [targetScienceManagerObject.backgroundBinaryList(l).lightCurve, ...
            targetScienceManagerObject.backgroundBinaryList(l).timeVector, ...
            targetScienceManagerObject.backgroundBinaryList(l).lightCurveData]  ...
            = create_light_curve(targetScienceManagerObject.backgroundBinaryList(l).object);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function targetScienceManagerData = add_light_curve_object(targetScienceManagerData, ...
    specNumber, targetNumber, lightCurveNumber, runParamsObject)

spec = targetScienceManagerData.targetSpecifiction(specNumber);
if ~isempty(spec.object)
    targetScienceManagerData.targetList(targetNumber).lightCurveList(lightCurveNumber).object = spec.object;
    if ~isempty(targetScienceManagerData.targetList(targetNumber).initialData(lightCurveNumber).data)
        targetScienceManagerData.targetList(targetNumber).lightCurveList(lightCurveNumber).object = ...
            initialize(targetScienceManagerData.targetList(targetNumber).lightCurveList(lightCurveNumber).object, ...
            targetScienceManagerData.targetList(targetNumber).initialData(lightCurveNumber).data);
    else
        targetScienceManagerData.targetList(targetNumber).lightCurveList(lightCurveNumber).object = ...
            initialize(targetScienceManagerData.targetList(targetNumber).lightCurveList(lightCurveNumber).object);
    end
else
    % it doesn't exist globally so instantiate the object for this light curve
    classString = get_class_string(spec.lightCurveData.className);
    eval(classString);
    clear classString;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function classString = get_class_string(className)
classString = ...
    ['targetScienceManagerData.targetList(targetNumber).lightCurveList(lightCurveNumber).object = ' ...
    className '(spec.lightCurveData, ' ...
    'targetScienceManagerData.targetList(targetNumber), '...
    'targetScienceManagerData.targetList(targetNumber).initialData(lightCurveNumber).data, runParamsObject);'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function targetScienceManagerData = make_background_binaries(targetScienceManagerData, runParamsObject)
if ~isfield(targetScienceManagerData, 'backgroundBinarySpecification') ...
        || isempty(targetScienceManagerData.backgroundBinarySpecification)
    targetScienceManagerData.backgroundBinaryList = [];
    return;
end

for s=1:length(targetScienceManagerData.backgroundBinarySpecification)
    spec = targetScienceManagerData.backgroundBinarySpecification(s);
    switch spec.selectionType
        case 'random'
            numToSelect = spec.selectionNumber;
            switch spec.selectionOn
                case 'properties'
                    % we have to do the following in a loop because sometimes the desired
                    % fields are empty and the temp arrays can't fall out of sync with 
                    % targetScienceManagerData.targetList indexing
                    mag = zeros(size(targetScienceManagerData.targetList));
                    effT = zeros(size(targetScienceManagerData.targetList));
                    logG = zeros(size(targetScienceManagerData.targetList));
                    for t = 1:length(targetScienceManagerData.targetList)
                        if ~isempty(targetScienceManagerData.targetList(t).keplerMagnitude)
                            mag(t) = targetScienceManagerData.targetList(t).keplerMagnitude;
                        else
                            mag(t) = -1;
                        end
                        if ~isempty(targetScienceManagerData.targetList(t).effectiveTemperature)
                            effT(t) = targetScienceManagerData.targetList(t).effectiveTemperature;
                        else
                            effT(t) = -1;
                        end
                        if ~isempty(targetScienceManagerData.targetList(t).logSurfaceGravity)
                            logG(t) = targetScienceManagerData.targetList(t).logSurfaceGravity;
                        else
                            logG(t) = -1;
                        end
                    end
                    % pick out the targets in the magnitude range
                    potentialTargetIndex = find( ...
                        mag >= spec.selectionMagnitudeRange(1) & mag <= spec.selectionMagnitudeRange(2) ...
                        & effT >= spec.selectionEffTempRange(1) & effT <= spec.selectionEffTempRange(2) ...
                        & logG >= spec.selectionlogGRange(1) & logG <= spec.selectionlogGRange(2) ...
                        );
                    % randomly pick numToSelect elements from that list
                    randomizedSelectedIndex = potentialTargetIndex(randperm(length(potentialTargetIndex)));
                    numToSelect = min(numToSelect, length(randomizedSelectedIndex));
                    if numToSelect > 0
                        selectedTargetIndex = randomizedSelectedIndex(1:numToSelect);
                        for tIndex=1:length(selectedTargetIndex)
                            disp(['------>>> background binary # ' num2str(tIndex)]);
                            t = selectedTargetIndex(tIndex);
                            targetScienceManagerData.backgroundBinaryList(tIndex).initialData.data = [];
                            classString = get_background_binary_class_string();
                            eval(classString);
                            clear classString;
                            targetScienceManagerData.backgroundBinaryList(tIndex).targetKeplerId ...
                                = targetScienceManagerData.targetList(t).keplerId;
                            targetScienceManagerData.backgroundBinaryList(tIndex).initialData.data ...
                                = get_initial_data(targetScienceManagerData.backgroundBinaryList(tIndex).object);
                        end
                    end

                otherwise
                    error('targetScienceManagerData.backgroundBinarySpecification.selectionOn: unknown type');
            end
        case 'byKeplerId'
            t = find([targetScienceManagerData.targetList.keplerId] == spec.keplerId);
            if isempty(t)
                disp('background binary: specification by Kepler ID: Kepler ID not found, ignoring');
            else
                if isfield(targetScienceManagerData, 'backgroundBinaryList');
                    tIndex = length(targetScienceManagerData.backgroundBinaryList) + 1;
                else
                    tIndex = 1;
                end
                targetScienceManagerData.backgroundBinaryList(tIndex).initialData.data = [];
                classString = get_background_binary_class_string();
                eval(classString);
                clear classString;
                targetScienceManagerData.backgroundBinaryList(tIndex).targetKeplerId ...
                    = targetScienceManagerData.targetList(t).keplerId;
                targetScienceManagerData.backgroundBinaryList(tIndex).initialData.data ...
                    = get_initial_data(targetScienceManagerData.backgroundBinaryList(tIndex).object);
            end

        otherwise
            disp('background binary: unknown selection type');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function targetScienceManagerData = reload_background_binaries(targetScienceManagerData, runParamsObject)
% reload previously defined background binaries from backgroundBinaryList 
backgroundBinaryList = targetScienceManagerData.backgroundBinaryList;
nBkgdBinaries = length(backgroundBinaryList);
targetList = targetScienceManagerData.targetList;
if isfield(targetScienceManagerData, 'backgroundBinarySpecification');
    for s=1:length(targetScienceManagerData.backgroundBinarySpecification)
        spec = targetScienceManagerData.backgroundBinarySpecification(s);
        for tIndex=1:nBkgdBinaries
            % find this binaries taret
            t = find([targetList.keplerId] == backgroundBinaryList(tIndex).targetKeplerId);
            classString = get_background_binary_class_string();
            eval(classString);
            clear classString;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function classString = get_background_binary_class_string()
classString = ...
	['targetScienceManagerData.backgroundBinaryList(tIndex).object = ' ...
	'backgroundBinaryClass(spec.backgroundBinaryData, ' ...
	'targetScienceManagerData.targetList(t), '...
	'targetScienceManagerData.backgroundBinaryList(tIndex).initialData.data, runParamsObject);'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function targetScienceManagerObject = compute_background_binaries(targetScienceManagerObject, ccdObject)
if ~isfield(struct(targetScienceManagerObject), 'backgroundBinaryList')
    return;
end
backgroundBinaryList = targetScienceManagerObject.backgroundBinaryList;
nBkgdBinaries = length(backgroundBinaryList);
for b=1:nBkgdBinaries
	targetScienceManagerObject.backgroundBinaryList(b).object = ...
		compute_pixel_polys(backgroundBinaryList(b).object, ccdObject);
end
