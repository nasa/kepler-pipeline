%% dv_report_tester_helper
%
% function dv_report_tester_helper(rootDir)
%
% Scans DV task directories for errors such as missing reports and builds 
% lists of "interesting" reports. These lists are placed in the files
% below-mes-ses-threshold-reports, fit-failed-reports,
% eclipsing-binary-reports, and planet-reports. Target results are
% categorized and per-sky group totals are displayed.
%
%% INPUTS
%
% * *rootDir:* the name of the directory that contains the results. The
% actual task directories may be nested arbitrarily deep within that
% directory.
%
%% OUTPUTS
%
% None.
%
%% DATA STRUCTURES
%
% results is a struct array that contains one element per sky group that
% contains the following fields:
%
%                    skyGroupId [int]: the sky group
% belowMesSesThreshold [struct array]: report filenames for targets that were below the
%                                      MES/SES threshold
%            fitFailed [struct array]: report filenames for targets whose fit failed
%      eclipsingBinary [struct array]: report filenames for targets that are suspected EBs
%           hasPlanets [struct array]: results for each target with a planet
%
% belowMesSesThreshold, fitFailed, and eclipsingBinary are struct arrays
% with the following fields:
%
%                      keplerId [int]: the Kepler ID
%             reportFilename [string]: report filename
%
% hasPlanets is a struct array with the following fields:
%
%                      keplerId [int]: the Kepler ID
%             reportFilename [string]: report filename
%              planets [struct array]: info for each planet
%
% planets is a struct array with the following fields:
%
%                     radius [double]: the radius
%                     period [double]: the period
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
function dv_report_tester_helper(rootDir)

if (~exist('rootDir', 'var'))
    error('Usage: dv_report_tester_helper(rootDir)\n');
end

if (~exist(rootDir, 'dir'))
    error('%s: No such file or directory\n', rootDir);
end

% Used to cache sky group ID.
lastSkyGroupId = 0;
lastParentDirectory = '';

% Strip trailing slash.
rootDir = regexprep(rootDir, '/$', '');

% Process task directories.
fprintf('Generating list of task directories in %s...\n', rootDir);
taskDirs = find_task_dirs(rootDir);
for i = 1:84
    results(i) = create_results_struct(i); %#ok<AGROW>
end
for i = 1:length(taskDirs)
    fprintf('Processing %s (%d of %d)...\n', taskDirs{i}, i, length(taskDirs));
    [lastParentDirectory lastSkyGroupId resultStruct] = process(...
        lastParentDirectory, lastSkyGroupId, taskDirs{i});
    results = update_results(results, resultStruct);
end

display_results(results);

end

%% create_results_struct
%
%
function resultsStruct = create_results_struct(skyGroupId)

resultsStruct = struct('skyGroupId', skyGroupId, 'belowMesSesThreshold', [], ...
    'fitFailed', [], 'eclipsingBinary', [], 'hasPlanets', []);

end

%% find_task_dirs
%
% Performs an in-order recursive traversal of rootDir looking for
% dv-outputs-0.mat files and and returns an array of directory names that
% contain them.
%
function taskDirs = find_task_dirs(rootDir)

taskDirs = {};

% Read the directory. If we don't have permission to read the
% directory, we'll get nothing.
files = dir(rootDir);
if (isempty(files))
    return;
end

% Create a cell array that contains the fully-qualified filenames.
files = strcat(rootDir, filesep, sort({files.name}));

% If this directory contains dv-outputs-0.mat, we're done.
loc = regexp(files, [filesep 'dv-outputs-0.mat']);
if (~isempty([loc{:}]))
    taskDirs = {rootDir};
    return;
end

% Otherwise, recurse into sub-directories.
for i = 1:length(files)
    file = char(files(i));
    % Skip . and .. .
    if (regexp(file, [filesep '\.{1,2}$']))
        continue;
    end
    if (isdir(file))
        taskDirs = [taskDirs find_task_dirs(file)]; %#ok<AGROW>
    end
end

end

%% process
%
% Processes a task directory.
%
function [lastParentDirectory lastSkyGroupId resultsStruct] = process(...
    lastParentDirectory, lastSkyGroupId, directory)

file = fullfile(directory, 'dv-outputs-0.mat');
if (~exist(file, 'file'))
    fprintf('Missing dv-outputs-0.mat file in %s\n', directory);
    return;
end
load(file);

% TODO Remove this condition and the last* variables once this script no
% longer processes 7.0 outputs.
if (~exist('outputsStruct.skyGroupId', 'var'))
    thisParentDirectory = '';
    thisSkyGroupId = 0;
    
    % To speed things up, avoid loading an inputs file if we do not have
    % to. We are guaranteed to have the same sky group ID within a set of
    % st-* directories within the same parent directory.
    if (regexp(directory, 'st-[0-9]+$'))
        [thisParentDirectory, name, ext] = fileparts(directory); %#ok<ASGLU,NASGU>
        if (strcmp(thisParentDirectory, lastParentDirectory))
            thisSkyGroupId = lastSkyGroupId;
        end
    end
    
    if (thisSkyGroupId == 0)
        file = fullfile(directory, 'dv-inputs-0.mat');
        if (~exist(file, 'file'))
            fprintf('Error: Missing dv-inputs-0.mat file in %s\n', directory);
            return;
        end
        fprintf('Loading %s...\n', file);
        load(file);
        thisSkyGroupId = inputsStruct.skyGroupId;
        lastSkyGroupId = thisSkyGroupId;
        lastParentDirectory = thisParentDirectory;
        clear inputsStruct;
    end
    outputsStruct.skyGroupId = thisSkyGroupId;
end

check_target_directories(directory, [outputsStruct.targetResultsStruct.keplerId]);

resultsStruct(length(outputsStruct.targetResultsStruct)) = create_results_struct(outputsStruct.skyGroupId);
for i = 1:length(outputsStruct.targetResultsStruct)
    resultsStruct(i) = retrieve_results(...
        directory, outputsStruct.skyGroupId, outputsStruct.targetResultsStruct(i));
end

end

%% check_target_directories
%
% Ensures that there is a target-#### directory for each target and that
% there is a report.
%
function check_target_directories(rootDir, keplerIds)

for i = 1:length(keplerIds)
    reportFilename = report_filename(rootDir, keplerIds(i));
    if (~exist(reportFilename, 'file'))
        fprintf('Error: Missing report %s\n', reportFilename);
    end
end

end

%% retrieve_results
%
% Retrieves the results for the given targets.
%
function resultsStruct = retrieve_results(directory, skyGroupId, targetResultsStruct)

reportFilename = {report_filename(directory, targetResultsStruct.keplerId)};
resultsStruct = create_results_struct(skyGroupId);
planetResultsStruct = targetResultsStruct.planetResultsStruct;

if (planetResultsStruct(1).allTransitsFit.modelChiSquare ~= -1)
    nPlanets = length(planetResultsStruct);
    planets = repmat(struct('radius', inf, 'period', -inf), 1, nPlanets);
    for i = 1:nPlanets
        if (planetResultsStruct(i).allTransitsFit.modelChiSquare == -1)
            continue;
        end
        modelParameters = planetResultsStruct(i).allTransitsFit.modelParameters;
        if (isempty(modelParameters))
            continue;
        end
        modelParameter = retrieve_model_parameter(modelParameters, 'planetRadiusEarthRadii');
        planets(i).radius = modelParameter.value;
        modelParameter = retrieve_model_parameter(modelParameters, 'orbitalPeriodDays');
        planets(i).period = modelParameter.value;
    end
    resultsStruct.hasPlanets = struct('keplerId', targetResultsStruct.keplerId, ...
        'reportFilename', reportFilename, 'planets', planets);
elseif (planetResultsStruct(1).planetCandidate.suspectedEclipsingBinary)
    resultsStruct.eclipsingBinary = struct('keplerId', targetResultsStruct.keplerId, ...
        'reportFilename', reportFilename);
elseif (planetResultsStruct(1).planetCandidate.statisticRatioBelowThreshold)
    resultsStruct.belowMesSesThreshold = struct('keplerId', targetResultsStruct.keplerId, ...
        'reportFilename', reportFilename);
else
    resultsStruct.fitFailed = struct('keplerId', targetResultsStruct.keplerId, ...
        'reportFilename', reportFilename);
end

end

%% report_filename
%
% Generates a filename for the given Kepler ID found in the given directory.
% 
function reportFilename = report_filename(directory, keplerId)

reportFilename = fullfile(directory, ...
        sprintf('target-%09d', keplerId), sprintf('dv-%09d', keplerId), ...
        sprintf('dv-%09d.pdf', keplerId));

end

%% update_results
%
% Updates the existing results with the given resultStruct.
%
function results = update_results(results, resultStruct)

for i = 1:length(resultStruct)
    skyGroupId = resultStruct(i).skyGroupId;
    results(skyGroupId).belowMesSesThreshold = ...
        [results(skyGroupId).belowMesSesThreshold resultStruct(i).belowMesSesThreshold];
    results(skyGroupId).fitFailed = ...
        [results(skyGroupId).fitFailed resultStruct(i).fitFailed];
    results(skyGroupId).eclipsingBinary = ...
        [results(skyGroupId).eclipsingBinary resultStruct(i).eclipsingBinary];
    results(skyGroupId).hasPlanets = ...
        [results(skyGroupId).hasPlanets resultStruct(i).hasPlanets];
end

end

%% display_results
%
% Display list of targets to inspect:
% For each mod/out:
%   1. List one target each of mes/ses failed, fit failed, EB, planets (one
%      with the smallest radius and longest period).
%   2. Provide count of targets in each category.
%
% Provide focal plane summary of these counts.
%
function display_results(results)

CUSTOM_TARGETS_FILENAME = 'custom-target-reports';
BELOW_MES_SES_THRESHOLD_FILENAME = 'below-mes-ses-threshold-reports';
FIT_FAILED_FILENAME = 'fit-failed-reports';
ECLIPSING_BINARY_FILENAME = 'eclipsing-binary-reports';
PLANETS_FILENAME = 'planet-reports';

customTargetTotal = 0;
customTargetsFid = xopen(CUSTOM_TARGETS_FILENAME, 'w');
belowMesSesThresholdTotal = 0;
belowMesSesThresholdFid = xopen(BELOW_MES_SES_THRESHOLD_FILENAME, 'w');
fitFailedTotal = 0;
fitFailedFid = xopen(FIT_FAILED_FILENAME, 'w');
eclipsingBinaryTotal = 0;
eclipsingBinaryFid = xopen(ECLIPSING_BINARY_FILENAME, 'w');
planetTargetTotal = 0;
planetTargetsFid = xopen(PLANETS_FILENAME, 'w');

planetTotal = 0;
maxPlanetsOverall = -inf;
minRadiusOverall = inf;
maxPeriodOverall = -inf;

heading();

for i = 1:length(results)
    if (mod(i, 50) == 0)
        heading();
    end
    
    nCustomTargets = 0;

    % For each type, write the first report filename in the list if it
    % exists.
    nBelowMesSesThreshold = length(results(i).belowMesSesThreshold);
    if (nBelowMesSesThreshold > 0)
        fprintf(belowMesSesThresholdFid, '%s\n', ...
            results(i).belowMesSesThreshold(1).reportFilename);
        nCustomTargets = nCustomTargets + count_custom_targets(results(i).belowMesSesThreshold);
    end
    nFitFailed = length(results(i).fitFailed);
    if (nFitFailed > 0)
        fprintf(fitFailedFid, '%s\n', ...
            results(i).fitFailed(1).reportFilename);
        nCustomTargets = nCustomTargets + count_custom_targets(results(i).fitFailed);
    end
    nEclipsingBinary = length(results(i).eclipsingBinary);
    if (nEclipsingBinary > 0)
        fprintf(eclipsingBinaryFid, '%s\n', ...
            results(i).eclipsingBinary(1).reportFilename);
        nCustomTargets = nCustomTargets + count_custom_targets(results(i).eclipsingBinary);
    end
    
    nPlanets = 0;
    maxPlanets = -inf;
    minRadius = inf;
    maxPeriod = -inf;
    nPlanetTargets = length(results(i).hasPlanets);
    if (nPlanetTargets > 0)
        reportFilename = sprintf('No planets in sky group %d', results(i).skyGroupId);
        targets = results(i).hasPlanets;
        for target = 1:length(targets)
            planets = targets(target).planets;
            nPlanets = nPlanets + length(planets);
            if (length(planets) > maxPlanets)
                reportFilename = targets(target).reportFilename;
                maxPlanets = length(planets);
            end
            for planet = 1:length(planets)
                minRadius = min(minRadius, planets(planet).radius);
                maxPeriod = max(maxPeriod, planets(planet).period);
            end
        end
        fprintf(planetTargetsFid, '%s\n', reportFilename);
        nCustomTargets = nCustomTargets + count_custom_targets(targets);
    end

    % If there were custom targets, find the first most interesting one and
    % write it out. 
    if (nCustomTargets > 0)
        fprintf(customTargetsFid, '%s\n', findCustomTargetFilename(results(i)));
    end
    
    fprintf('%11d%19d%12d%18d%19d%9d%16d%9d%11d%12f%12f\n', i, ...
        nBelowMesSesThreshold, nFitFailed, nEclipsingBinary, nPlanetTargets, ...
        nBelowMesSesThreshold + nFitFailed + nEclipsingBinary + nPlanetTargets, ...
        nCustomTargets, nPlanets, maxPlanets, minRadius, maxPeriod);

    customTargetTotal = customTargetTotal + nCustomTargets;
    belowMesSesThresholdTotal = belowMesSesThresholdTotal + nBelowMesSesThreshold;
    fitFailedTotal = fitFailedTotal + nFitFailed;
    eclipsingBinaryTotal = eclipsingBinaryTotal + nEclipsingBinary;
    planetTargetTotal = planetTargetTotal + nPlanetTargets;
    
    planetTotal = planetTotal + nPlanets;
    maxPlanetsOverall = max(maxPlanetsOverall, maxPlanets);
    minRadiusOverall = min(minRadiusOverall, minRadius);
    maxPeriodOverall = max(maxPeriodOverall, maxPeriod);
    
end

xclose(belowMesSesThresholdFid, BELOW_MES_SES_THRESHOLD_FILENAME);
xclose(fitFailedFid, FIT_FAILED_FILENAME);
xclose(eclipsingBinaryFid, ECLIPSING_BINARY_FILENAME);
xclose(planetTargetsFid, PLANETS_FILENAME);

heading();
fprintf('\n%-11s%19d%12d%18d%19d%9d%16d%9d%11d%12f%12f\n', 'Totals:', ...
    belowMesSesThresholdTotal, fitFailedTotal, eclipsingBinaryTotal, planetTargetTotal, ...
    belowMesSesThresholdTotal + fitFailedTotal + eclipsingBinaryTotal + planetTargetTotal, ...
    customTargetTotal, planetTotal, maxPlanetsOverall, minRadiusOverall, maxPeriodOverall);

end

function heading()
fprintf('\n%11s%19s%12s%18s%19s%9s%16s%9s%11s%12s%12s\n', 'Sky Group', ...
    'MES/SES Threshold', 'Fit Failed', 'Eclipsing Binary', 'Targets w/Planets', ...
    'Targets', 'Custom Targets', 'Planets', 'Max Count', 'Min Radius', 'Max Period');
end

function reportFilename = findCustomTargetFilename(results)

reportFilename = sprintf('No planets in sky group %d', results.skyGroupId);

for i = 1:length(results.hasPlanets)
    if (isCustomTarget(results.hasPlanets(i).keplerId))
        reportFilename = results.hasPlanets(i).reportFilename;
        return;
    end
end
for i = 1:length(results.eclipsingBinary)
    if (isCustomTarget(results.eclipsingBinary(i).keplerId))
        reportFilename = results.eclipsingBinary(i).reportFilename;
        return;
    end
end
for i = 1:length(results.fitFailed)
    if (isCustomTarget(results.fitFailed(i).keplerId))
        reportFilename = results.fitFailed(i).reportFilename;
        return;
    end
end
for i = 1:length(results.belowMesSesThreshold)
    if (isCustomTarget(results.belowMesSesThreshold(i).keplerId))
        reportFilename = results.belowMesSesThreshold(i).reportFilename;
        return;
    end
end
end

function n = count_custom_targets(targets)

n = 0;
for i = 1:length(targets)
    if (isCustomTarget(targets(i).keplerId))
        n = n + 1;
    end
end

end

function isCustomTarget = isCustomTarget(keplerId)
CUSTOM_TARGET_KEPLER_ID_START = 100000000;

isCustomTarget = false;

if (keplerId >= CUSTOM_TARGET_KEPLER_ID_START)
    isCustomTarget = true;
end

end
