function [cbdDataInStruct, cbdDataOutStruct] =  generate_cbd_test_data(dataOutDir)
% function [cbdTestDataStructIn, cbdTestDataStructOut] =  generate_cbd_test_data(dataOutDir)
% Generate input and put test data structure for cbd_controller()
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

clc;
close all;
clear all classes class;

% load constants
constants;

startMjd = datestr2mjd('July 1 2010');
endMjd = startMjd + 1;

% The channels we want to compute are specified here
channelIndex = [1:1]; % [1:84]

% collateral locations
leadingBlackCols    = LEADING_BLACK_COLS;
trailingBlackCols   = TRAILING_BLACK_COLS;
virtualSmearRows    = VIRTUAL_SMEAR_ROWS;
maskedSmearRows     = MASKED_SMEAR_ROWS;

% Extrat the date tag
dateStr = date_string();

% FFI files are in the same directory and file names are stored as cellarray
if ( isunix )
    fileFFIsDir = '/path/to/FS_TVAC_2D_black_ffi/module_data';
elseif ( ispc )
    fileFFIsDir = 'C:\path\to\CBD_Data';
else
    error('Unknown platform: Windows or Linux only!');
end
fileFFIsNameArray = {'ffi_200809030929_set_001.fits' ...
    'ffi_200809030929_set_002.fits' ...
    'ffi_200809030929_set_003.fits' ...
    'ffi_200809030930_set_001.fits' ...
    'ffi_200809030930_set_002.fits' ...
    'ffi_200809030930_set_003.fits' ...
    'ffi_200809030931_set_001.fits' ...
    'ffi_200809030931_set_002.fits' ...
    'ffi_200809030931_set_003.fits' ...
    'ffi_200809031347_set_001.fits' ...
    'ffi_200809031347_set_002.fits' ...
    'ffi_200809031347_set_003.fits' ...
    'ffi_200809031508_set_001.fits' ...
    'ffi_200809031508_set_002.fits' ...
    'ffi_200809031508_set_003.fits' ...
    'ffi_200809031618_set_001.fits' ...
    'ffi_200809031618_set_002.fits' ...
    'ffi_200809031618_set_003.fits' ...
    'ffi_200809031856_set_001.fits' ...
    'ffi_200809031856_set_002.fits' ...
    'ffi_200809031856_set_003.fits' ...
    'ffi_200809032124_set_001.fits' ...
    'ffi_200809032124_set_002.fits' ...
    'ffi_200809032124_set_003.fits' ...
    'ffi_200809040117_set_001.fits' ...
    };


% Directory and file containing backup data for loading backup or future analysis.
dataArchivalDir     = '/path/to/FS_TVAC_2D_black_ffi/module_data';
dataArchivalFile    = 'CBD_Backup_10072008';

%% %%%%%%%%%%%%% don't change anything below this line %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% FFI files are in the same directory and file names are stored as cellarray
if ( ispc )
    % location of data directory
    fileFFIsDir = 'C:\path\to\CBD_Data';
elseif ( isunix )

else
    error('Error: unknown platform');
end

% Construct the input data structure
try
    % CBD internal parameters: not all used.
    cbdParameters = struct( ...
        'foldedAverage',    false, ...
        'debugOption',      false, ...
        'dummyNum',         1 ...
        );

    % single input parameter for the CBD controller
    cbdDataInStruct = struct( ...
        'startMjd',             startMjd, ...
        'endMjd',               endMjd, ...
        'channelIndex',         channelIndex, ...
        'fileFFIsDir',          fileFFIsDir, ...
        'fileFFIsNameArray',    fileFFIsNameArray, ...
        'leadingBlackCols',     leadingBlackCols, ...
        'trailingBlackCols',    trailingBlackCols, ...
        'virtualSmearRows',     virtualSmearRows, ...
        'maskedSmearRows',      maskedSmearRows, ...
        'cbdParameters',        cbdParameters, ...
        'liveMode',             true, ... %true, ...
        'dateStr',              dateStr, ...
        'dataArchivalDir',      dataArchivalDir, ...     % save input for reconstruction purpose
        'dataArchivalFile',     dataArchivalFile ...
        );
catch
    lastError = lasterror();
    error(['Error in constructing CBD_controller input data struct: ' lastError.message ' file loc: ' lastError.file ]);
end

%% execute the CBD controller
% The results are in the output data struct
tic;

try
    cbdDataOutStruct = cbd_controller(cbdDataInStruct);
catch
    lastError = lasterror();
    error(['Error with executing cbd_controller(): ' lastError.message ' file loc: ' lastError.stack(1).file ]);
end

cbd_time = toc ;

%% Extract the output data structure if necessary;
% otherwise take the output data struct as is.
try
    % save the input in a mat file: need v7.3 flag set as default.
    dataInStructFile = fullfile(dataOutDir, ['cbdDataInStruct_' dateStr]);
    save(dataInStructFile, 'cbdDataInStruct');

    % save the output in a mat file: need v7.3 flag set as default.
    dataOutStructFile = fullfile(dataOutDir, ['cbdDataOutStruct_' dateStr]);
    save(dataOutStructFile, 'cbdDataOutStruct');

    % run the report generator

catch
    lastError = lasterror();
    error(['Error with saving CBD output results and generating report: ' lastError.message ' file loc: ' lastError.stack(1).file ]);
end


% Signal the completion of the processing steps
disp(['CBD Task is completed with execution time: ' num2str(cbd_time / 3600) ' hours']);
