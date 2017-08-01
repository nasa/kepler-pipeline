function validate_cal_inputs_and_outputs(ccdChannel)
%
% function to run CAL for  7.0 V&V to show that there are no errors in the
% CAL inputs/outputs
%
%
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

%--------------------------------------------------------------------------
% test SC flight I/O
%--------------------------------------------------------------------------
clear classes

% dataDir = '/path/to/TEST/pipeline_results/photometry/sc/cal/i4077--release-7.0-at-42127--q6/';
% taskfileMap = 'q6-cal-task-to-mod-out-id-map.csv';

% reprocessed with all KSOC fixes:
dataDir     = '/path/to/TEST/pipeline_results/photometry/sc/cal/i4237--release-7.0-at-42287--q6_complete_copy/';
taskfileMap = 'q6-cal-task-to-mod-out-id-map.csv';

taskFilenames = get_taskfiles_from_modout(taskfileMap, 'cal', ccdChannel, dataDir);


% load inputs and run CAL
taskFullFileName = [dataDir taskFilenames{1}];

load([ taskFullFileName '/st-0/cal-inputs-0.mat'])
inputsStruct = get_subset_of_cal_inputs(inputsStruct, 150); %#ok<*NODEF>

eval(['!cp ' taskFullFileName '/blob* .'])
calScCollateral = cal_matlab_controller(inputsStruct);


load([ taskFullFileName '/st-1/cal-inputs-0.mat'])
inputsStruct = get_subset_of_cal_inputs(inputsStruct, 150); %#ok<*NODEF>

calScPhotometric = cal_matlab_controller(inputsStruct);

%--------------------------------------------------------------------------
% test LC flight I/O
%--------------------------------------------------------------------------
clear classes

% dataDir     = '/path/to/TEST/pipeline_results/photometry/lc/cal/i3817--release-7.0-at-41606--q6/';
% taskfileMap = 'i3817-q6-cal-final.csv';

% reprocessed with all KSOC fixes:
dataDir     = '/path/to/TEST/pipeline_results/photometry/lc/cal/i4217--release-7.0-at-42287--q6/';
taskfileMap = 'q6-cal-task-to-mod-out-id-map.csv';

taskFilenames = get_taskfiles_from_modout(taskfileMap, 'cal', ccdChannel, dataDir);


% load inputs and run CAL
taskFullFileName = [dataDir taskFilenames{1}];

load([ taskFullFileName '/st-0/cal-inputs-0.mat'])
inputsStruct = get_subset_of_cal_inputs(inputsStruct, 150); %#ok<*NODEF>

calLcCollateral = cal_matlab_controller(inputsStruct); %#ok<*NASGU>


load([ taskFullFileName '/st-1/cal-inputs-0.mat'])
inputsStruct = get_subset_of_cal_inputs(inputsStruct, 150); %#ok<*NODEF>

calLcPhotometric = cal_matlab_controller(inputsStruct);


%--------------------------------------------------------------------------
% test FFI I/O
%--------------------------------------------------------------------------
clear classes

% dataDir = '/path/to/TEST/pipeline_results/photometry/ffi/cal/i4117--release-7.0-at-42127--q7/';
% taskFullFileName = [dataDir 'cal-matlab-4117-172474'];

% reprocessed with all KSOC fixes:
% dataDir = '/path/to/TEST/pipeline_results/photometry/ffi/cal/i4339--release-7.0-at-42287--q8m1/';
dataDir = '/path/to/TEST/pipeline_results/photometry/ffi/cal/i4341--release-7.0-at-42287--q8m2/';
taskFullFileName = [dataDir 'cal-matlab-4341-189614'];

load([ taskFullFileName '/st-0/cal-inputs-0.mat'])

calFFICollateral = cal_matlab_controller(inputsStruct);

load([ taskFullFileName '/st-1/cal-inputs-0.mat'])

calFFIPhotometric = cal_matlab_controller(inputsStruct);



return;