function bartDataOutStruct = bart_matlab_controller( bartDataInStruct )
%
% BART Matlab controller.
%
%   Top Level Input
%
%   bartDataInStruct is a structure for each module output with the following fields:
%
%       inputFoldername: [string] input folder name of FITS files
%         fitsFilenames: [cell array] a list of column major FITS file
%                        names for both FFI cell(nFFI,1) and RCLC types cell(nFFI,2).
%
%      selectedChannels: [int array] list of channel indexes
%  temperatureMnemonics: [string] list of temperature mnemonics, e.g.
%                        {'PEDDRV1T', 'PEDACQ4T'}
%  referenceTemperature: [double] the reference temperature for BART model.
%      outputFoldername: [string] top level output folder name
%
%--------------------------------------------------------------------------
%
%   Top Level Output
%
%   bartDataOutStruct is a structure for each module output with the following fields:
%
%                       module: [int] the CCD module index
%                       output: [int] the CCD output index
% selectedTemperatureStruct: [struct] temperature measurements for all
%                             selected mnemonics and FFI
%--------------------------------------------------------------------------
% Second level
%
% selectedTemperatureStruct is a struct with the following fields:
%
%    temperatureMean: [double array] mean temperature measurements for each
%                      mnemonics and FFI pair
%     temperatureStd: [double array] std of temperature measurements for
%                      each mnemonics and FFI pair
%    temperatureSamples: [int array] number of temperature measurements for
%                      each mnemonics and FFI pair
% temperatureMnemonics: [cell array] list of temperature mnemonics, e.g.
%                        {'PEDDRV1T', 'PEDACQ4T'}
%
%--------------------------------------------------------------------------
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

MsgID = 'CT:BART:bart_matlab_controller';

if isempty(bartDataInStruct) || ~isstruct(bartDataInStruct)
    error(MsgID, 'Input argiment is not a valid struct');
elseif ~( isfield(bartDataInStruct, 'inputFoldername')     && ...
        isfield(bartDataInStruct, 'fitsFilenames')         && ...
        isfield(bartDataInStruct, 'selectedChannels')      && ...
        isfield(bartDataInStruct, 'temperatureMnemonics')  && ...
        isfield(bartDataInStruct, 'referenceTemperature')  && ...
        isfield(bartDataInStruct, 'outputFoldername')         ...
        )
    error(MsgID, 'Missing fields in input data struct');
end

if isempty(bartDataInStruct.inputFoldername) || ~ischar(bartDataInStruct.inputFoldername)
    error(MsgID, 'Error with input field inputFoldername');
end

if isempty(bartDataInStruct.fitsFilenames) || ~iscell(bartDataInStruct.fitsFilenames)
    error(MsgID, 'Error with input field inputFoldername');
end

if isempty(bartDataInStruct.selectedChannels) || ~isnumeric(bartDataInStruct.selectedChannels)
    error(MsgID, 'Error with input field fitsFilenames');
end

if isempty(bartDataInStruct.temperatureMnemonics) || ~iscell(bartDataInStruct.temperatureMnemonics)
    error(MsgID, 'Error with input field temperatureMnemonics');
end

if isempty(bartDataInStruct.referenceTemperature) || ~isnumeric(bartDataInStruct.referenceTemperature)
    error(MsgID, 'Error with input field referenceTemperature');
end

if isempty(bartDataInStruct.outputFoldername) || ~ischar(bartDataInStruct.outputFoldername)
    error(MsgID, 'Error with input field outputFoldername');
end

% --- Done with input struct checking -------------------------------------
% generate date stamp for identifying the output files
dateStringFormat = 30;
dateString = datestr( now(), dateStringFormat );

% BART software version indentification string:
% this requires manually set consistent with tag from svn.
swVersion = 'BART_v0.0';

% extract input attributes from the input data structure
inputFoldername      = bartDataInStruct.inputFoldername;
fitsFilenames        = bartDataInStruct.fitsFilenames;
temperatureMnemonics = bartDataInStruct.temperatureMnemonics;
referenceTemperature = bartDataInStruct.referenceTemperature;
outputFoldername     = bartDataInStruct.outputFoldername;



% the number of module output to process
nFitsFiles          = size( fitsFilenames, 1 );
nModouts            = size( bartDataInStruct.selectedChannels, 2);
nMnemonics          = size( temperatureMnemonics, 2);

if ( nFitsFiles < 2 )
    error(MsgID, 'Not enough FITS files');
elseif ( nMnemonics ~= 2 )
    error(MsgID, 'Not enough temperature mnemonics');
end

try
    % Prefetch the temperature measurements once for all files
    [selectedTemperatureStruct, averagedTemperatures] = bart_prefetch_temperatures( ...
        inputFoldername, fitsFilenames, temperatureMnemonics);
catch
    lastError = lasterror();
    disp(['Error ID: ' lastError.identifier]);
    disp(['Error Msg: ' lastError.message]);
    error(MsgID, 'Error with bart_prefetch_temperatures');
end

% return selected temperature data struct
bartDataOutStruct= struct( ...
    'channels',                    [], ... % record of what channels are processed
    'selectedTemperatureStruct',   [], ... % Details information of temperature measurements 
    'dateString',                  [] ...  % the date string generated inside the controller
    );

bartDataOutStruct.channels                  = bartDataInStruct.selectedChannels;
bartDataOutStruct.dateString                = dateString;
bartDataOutStruct.selectedTemperatureStruct = selectedTemperatureStruct;

if nModouts == 1 && bartDataInStruct.selectedChannels(1) == 0
    disp('Prep channel is used ... return with temperature information.');
    return;
end

% import the Kepler globally defined constants
try
    FcConstants = convert_fc_constants_java_2_struct;
catch
    error(MsgID, 'FcConstants is not available');
end

% extract FFI dimension from FcConstants
FFI_ROWS             = FcConstants.CCD_ROWS;   % the default number of image rows
FFI_COLS             = FcConstants.CCD_COLUMNS;   % the default number of image cols

% extract module and output from channel indexes
[selectedModules, selectedOutputs] = ...
    convert_to_module_output( bartDataInStruct.selectedChannels );
    
% loop each channel
for k = 1:nModouts

    tic;

    moduleIndex = selectedModules(k);
    outputIndex = selectedOutputs(k);

    disp(['Started module ' num2str(moduleIndex) ' output ' num2str(outputIndex) ]);

    try
        % read FFI or RCLC files in fits format and return data and header information
        [ffiData, ffiInfoStruct] = bart_read_fits_files( inputFoldername, fitsFilenames, moduleIndex, outputIndex, FFI_ROWS, FFI_COLS );
    catch
        lastError = lasterror();
        disp(['Error ID: ' lastError.identifier]);
        disp(['Error Msg: ' lastError.message]);
        error(MsgID, 'error with bart_read_fits_files()');
    end
    
    try
        % fitting FFI data to temperatures on a per pixel basis
        [modelStruct, diagnosticsStruct] = bart_linear_fitter( ffiData, averagedTemperatures, referenceTemperature);
    catch
        lastError = lasterror();
        disp(['Error ID: ' lastError.identifier]);
        disp(['Error Msg: ' lastError.message]);
        error(MsgID, 'error with bart_linear_fitter()');
    end

    try
        % collect and package history data
        historyStruct = bart_package_history(moduleIndex, outputIndex, fitsFilenames, ffiInfoStruct, ...
            averagedTemperatures, dateString, swVersion, temperatureMnemonics);
    catch
        lastError = lasterror();
        disp(['Error ID: ' lastError.identifier]);
        disp(['Error Msg: ' lastError.message]);
        error(MsgID, 'error with bart_package_history');
    end

    try
        % save the BART model and the history data
        bart_save_model( historyStruct, modelStruct, outputFoldername);
    catch
        lastError = lasterror();
        disp(['Error ID: ' lastError.identifier]);
        disp(['Error Msg: ' lastError.message]);
        error(MsgID, 'error with bart_save_model');
    end

    try
        % save the BART model and the history data
        bart_save_diagnostics( historyStruct, diagnosticsStruct, outputFoldername);
    catch
        lastError = lasterror();
        disp(['Error ID: ' lastError.identifier]);
        disp(['Error Msg: ' lastError.message]);
        error(MsgID, 'error with bart_save_diagnostics');
    end

    %{
    % commented out for now
    % Error still occur:
 
Error ID: CT:BART:bart_visualize_model
Error Msg: Error using ==> bart_visualize_model at 63
multiple BART models found for the specified module output
    
    % generate and save figures
    try
        % get original location
        origLocation = pwd;
        eval(['cd ' outputFoldername '/model'])
        bart_visualize_model(moduleIndex, outputIndex);
        eval('cd ../diagnostics')
        bart_visualize_diagnostics(moduleIndex, outputIndex, 0);
        eval(['cd ' origLocation])
    catch
        lastError = lasterror();
        disp(['Error ID: ' lastError.identifier]);
        disp(['Error Msg: ' lastError.message]);
        error(MsgID, 'error with visualizing models or diagnostics');
    end
%}
    
    modoutProcessTime = toc;

    disp(['Processed module ' num2str(moduleIndex) ' output ' num2str(outputIndex) ' in ' num2str(modoutProcessTime) ' seconds' ]);

    % clear the large memory holding structs
    clear ffiData ffiInfoStruct;
    clear modelStruct diagnosticsStruct historyStruct;

    close all hidden;
end

% these variable struct are shared by all channels
clear selectedTemperatureStruct averagedTemperatures;

return