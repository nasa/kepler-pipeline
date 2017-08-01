function outputs_struct = etem2_matlab_controller( inputs_struct )
% function outputs_struct = etem2_matlab_controller( inputs_struct )
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

disp('etem2_matlab_controller START');

inputs_struct

module_num = inputs_struct.ccdModule;
output_num = inputs_struct.ccdOutput;
run_duration_cadences = inputs_struct.numCadences;
cadence_type = inputs_struct.cadenceType;
start_date = inputs_struct.startDate;
output_dir = inputs_struct.outputDir
target_list_set_name = inputs_struct.targetListSetName
refpix_target_list_set_name = inputs_struct.refPixTargetListSetName
requant_id = inputs_struct.requantExternalId;
planned_config_map = inputs_struct.plannedConfigMap;
etem_inputs_file = inputs_struct.etemInputsFile
refPixelCadenceInterval = inputs_struct.refPixelCadenceInterval;
refPixelCadenceOffset = inputs_struct.refPixelCadenceOffset;
fcConstants = inputs_struct.fcConstants;

raOffset = inputs_struct.raOffset;
decOffset = inputs_struct.decOffset;
phiOffset = inputs_struct.phiOffset;

previousQuarterRunDir = inputs_struct.previousQuarterRunDir

disp(['output_dir = ' output_dir]);
planned_config_map

if(strcmp(refpix_target_list_set_name, ''))
    % make sure refpix_target_list_set_name is empty if not set on the java
    % side
    refpix_target_list_set_name = [];
end;

localConfigurationStruct.numberOfTargetsRequested=0; % Not used, always get target defs from database

localConfigurationStruct.runStartDate = start_date; % start date of current run
localConfigurationStruct.runDuration = run_duration_cadences; % length of run in the units defined in the next field
localConfigurationStruct.runDurationUnits = 'cadences'; % units of run length paramter: 'days' or 'cadences'

localConfigurationStruct.moduleNumber = module_num; % which CCD module, ouput and season, legal values: 2-4, 6-20, 22-24
localConfigurationStruct.outputNumber = output_num; % legal values: 1-4
localConfigurationStruct.observingSeason = 1; % not used

localConfigurationStruct.cadenceType = cadence_type; % cadence types, <long> or <short>

globalConfigurationStruct = eval(etem_inputs_file);

%globalConfigurationStruct.runParamsData.etemInformation.etem2Location = '';

globalConfigurationStruct.runParamsData.etemInformation.etem2OutputLocation = output_dir; 
globalConfigurationStruct.runParamsData.keplerData.requantizationTableId = requant_id;

globalConfigurationStruct.runParamsData.keplerData.refPixCadenceInterval = refPixelCadenceInterval;
globalConfigurationStruct.runParamsData.keplerData.refPixCadenceOffset = refPixelCadenceOffset;

globalConfigurationStruct.runParamsData.keplerData.raOffset = raOffset;
globalConfigurationStruct.runParamsData.keplerData.decOffset = decOffset;
globalConfigurationStruct.runParamsData.keplerData.phiOffset = phiOffset;

globalConfigurationStruct.runParamsData.simulationData.cleanOutput = 1;

globalConfigurationStruct.runParamsData.keplerData.fcConstants = fcConstants;

% from PlannedSpacecraftConfigParameters

globalConfigurationStruct.runParamsData.keplerData.exposuresPerShortCadence = planned_config_map.integrationsPerShortCadence;
globalConfigurationStruct.runParamsData.keplerData.shortsPerLongCadence = planned_config_map.shortCadencesPerLongCadence;
globalConfigurationStruct.runParamsData.keplerData.maskedSmearCoAddRows = (planned_config_map.maskedStartRow+1):(planned_config_map.maskedEndRow+1);
globalConfigurationStruct.runParamsData.keplerData.virtualSmearCoAddRows = (planned_config_map.smearStartRow+1):(planned_config_map.smearEndRow+1);
globalConfigurationStruct.runParamsData.keplerData.blackCoAddCols = (planned_config_map.darkStartCol+1):(planned_config_map.darkEndCol+1);
% Integration time is commanded in number of FGS frames. So the period of each integration is
% fgsFramesPerIntegration * the FGS frame period (FDMINTPER * 0.10379 sec)
globalConfigurationStruct.runParamsData.keplerData.integrationTime = ...
    planned_config_map.fgsFramesPerIntegration * (planned_config_map.millisecondsPerFgsFrame / 1000);
globalConfigurationStruct.runParamsData.keplerData.transferTime = planned_config_map.millisecondsPerReadout / 1000;
globalConfigurationStruct.runParamsData.keplerData.requantTableLcFixedOffset = planned_config_map.lcRequantFixedOffset;
globalConfigurationStruct.runParamsData.keplerData.requantTableScFixedOffset = planned_config_map.scRequantFixedOffset;

pluginList = defined_plugin_classes();
globalConfigurationStruct.tadInputData = pluginList.databaseTadData;
globalConfigurationStruct.tadInputData.targetListSetName = target_list_set_name;
globalConfigurationStruct.tadInputData.refPixTargetListSetName = refpix_target_list_set_name;

if(~inputs_struct.enableAstrophysics)
    disp('Astrophysics DISABLED for this module/output');
    globalConfigurationStruct.ccdData.targetScienceManagerData = [];
end;

% if inputs_struct.previousQuarterRunDir is set, pass that value on to
% initialScienceRun
if(~isempty(previousQuarterRunDir))
    disp(['setting initialScienceRun = ' previousQuarterRunDir]);
    globalConfigurationStruct.runParamsData.simulationData.initialScienceRun = previousQuarterRunDir;
end;

% Run ETEM2

disp('Running etem2()');

warning verbose;
warning off MATLAB:intConvertNonIntVal;
warning off MATLAB:NonIntegerInput;
warning off MATLAB:intMathOverflow;
warning off MATLAB:intConvertNaN;

etem2(globalConfigurationStruct, localConfigurationStruct);

% This logic is duplicated from runParamsClass.m because there doesn't seem
% to be an easy way to access that object from here without creating a new
% instance (which involves too much overhead, such as initializing
% RaDec2Pix)
runDir = ...
    [output_dir filesep ...
    'run_' cadence_type ...
    '_m' num2str(module_num) ...
    'o' num2str(output_num) ...
    's1' ]; 

% save off the pixel counts
disp(['Saving pixel counts to: ' runDir]);

if(strcmp(cadence_type,'long'))
    pixelCounts = get_pixel_numbers(runDir);
    save([runDir filesep 'pixelCounts.mat'], '-struct', 'pixelCounts' );
else
    pixelCounts = get_short_cadence_pixel_numbers(runDir);
    save([runDir filesep 'pixelCounts.mat'], '-struct', 'pixelCounts' );
end

disp(pixelCounts);

% save the target counts
disp(['Saving target counts to: ' runDir]);
targetCounts.target = size(get_target_definitions(runDir, 'target'),2);
targetCounts.background = size(get_target_definitions(runDir, 'background'),2);
save([runDir filesep 'targetCounts.mat'], '-struct', 'targetCounts' );

disp(targetCounts);

disp('Done!');

outputs_struct.status = 0;

disp('etem2_matlab_controller END');
