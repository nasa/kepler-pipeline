function inputsStruct = update_dynablack_inputs(inputsStruct)
% function inputsStruct = update_dynablack_inputs(inputsStruct)
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

% This is a catch-all function to create fields in the dynablackInputsStruct and populate them if such information is not already available in the inputsStruct.
% Hard coded overrides are also applied here through dynablack_convert_92_data_to_93 if needed.

% this updater needs to remain on the 9.3 release branch until the java side
% catches up in 9.4 (10.0)
[inputsStruct] = dynablack_convert_92_data_to_93(inputsStruct);

% SET CONSTANTS FOR HARD CODED FIX FOR MODULE 3 FAILURE DURING Q4
Q4_FAILURE_MODULE = 3;
Q4_FAILURE_CADENCE_RANGE = (11914 : 16310)';                % this is the full cadence range for all of Q4 - not just the post failure cadences

module = inputsStruct.ccdModule;
cadenceRange = inputsStruct.cadenceTimes.cadenceNumbers;

% determine if uow is valid or not
if module == Q4_FAILURE_MODULE && any( ismember( cadenceRange, Q4_FAILURE_CADENCE_RANGE ) )
    inputsStruct.validUow = false;
else
    inputsStruct.validUow = true;
end


% dynablack expects scalars or row vector in dynablackModuleParameters and rbaConfigurationStruct
% change any column vectors to row vectors
dynablackModuleParameters = inputsStruct.dynablackModuleParameters;
fields = fieldnames(dynablackModuleParameters);
for iField = 1:length(fields)
    if iscolumn(dynablackModuleParameters.(fields{iField}))
        dynablackModuleParameters.(fields{iField}) = rowvec(dynablackModuleParameters.(fields{iField}));
    end
end
inputsStruct.dynablackModuleParameters = dynablackModuleParameters;

rbaFlagConfigurationStruct = inputsStruct.rbaFlagConfigurationStruct;
fields = fieldnames(rbaFlagConfigurationStruct);
for iField = 1:length(fields)
    if iscolumn(rbaFlagConfigurationStruct.(fields{iField}))
        rbaFlagConfigurationStruct.(fields{iField}) = rowvec(rbaFlagConfigurationStruct.(fields{iField}));
    end
end
inputsStruct.rbaFlagConfigurationStruct = rbaFlagConfigurationStruct;


% attach local filenames to inputsStruct
inputsStruct.monitorFilename = 'dynablack_monitors.mat';
inputsStruct.rollingBandFilename = 'dynablack_rba.mat';

% load start of line ringing model for all channels if not already supplied
if( ~isfield(inputsStruct, 'startOfLineRingingModel') )
    inputsStruct.startOfLineRingingModel = get_sol_ringing_model;
end

% reverse clocked data is assumed to be gap free - if it is not, make it so
if isfield(inputsStruct,'reverseClockedCadenceTimes')
    if isfield(inputsStruct.reverseClockedCadenceTimes,'gapIndicators')
        if any(inputsStruct.reverseClockedCadenceTimes.gapIndicators)
            inputsStruct = degap_reverse_clocked_data(inputsStruct);
        end
    end
end

% check dynablackModuleParameters struct for needed parameters and update with defaults if necessary
inputsStruct = initialize_dynablack_controls_and_bounds(inputsStruct);

