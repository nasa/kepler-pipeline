function etem2_dark(gloabalConfigurationStruct, localConfigurationStruct)
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
ccdDarkData = gloabalConfigurationStruct.ccdDarkData;

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
	'ccdDarkData');

runParamsObject = runParamsClass(runParamsData);

if ~exist(get(runParamsObject, 'outputDirectory'), 'dir')
    mkdir(get(runParamsObject, 'outputDirectory'));
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
ccdDarkObject = ccdDarkClass(ccdDarkData, runParamsObject);

clear ccdDarkData

ssrOutputDirectory = [get(runParamsObject, 'outputDirectory') ...
    filesep get(ccdDarkObject, 'ssrOutputDirectory')]
if ~exist(ssrOutputDirectory, 'dir')
    mkdir(ssrOutputDirectory);
end

for i=1:get(ccdDarkObject, 'numDarkCadences')
    render_ccd(ccdDarkObject, i);
end


whos

outputDirectory = get(runParamsObject, 'outputDirectory');

save([outputDirectory filesep 'runParamsObject.mat'], 'runParamsObject');

save([outputDirectory filesep 'ccdDarkObject.mat'], 'ccdDarkObject');

if ~isdeployed
    path(oldPath);
end

etem2EndTime = clock;
etem2ElapsedTime = etime(etem2EndTime, etem2StartTime);
disp(['total elapsed time ' num2str(etem2ElapsedTime) ' seconds = ' ...
    num2str(etem2ElapsedTime/60) ' minutes = ' num2str(etem2ElapsedTime/3600) ' hours']);
save([outputDirectory filesep 'runTime.mat'], 'etem2EndTime', 'etem2StartTime', 'etem2ElapsedTime');
