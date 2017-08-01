% Kepler CCD-Black-Dark
% Author: Gary Zhang
% Date: 2008
% This is the main entrance of the CBD-Black-Dark Tool
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
clear classes class;

% load constants
constants;

%% Prepare input data structure: Use edit


% Extrat the date tag
dateStr = date_string();

% get the Mjds
startMjd = get_keyboard_input('Enter Start Date', 'March 1 2009');
endMjd = get_keyboard_input('Enter End Date', 'June 1 2012');
startMjd = datestr2mjd(startMjd);
endMjd = datestr2mjd(endMjd);

channelIndex = get_keyboard_input('Enter Channel Indexes, default', (1:MOD_OUT_NO) );
leadingBlackCols = get_keyboard_input('Leading Black Columns', LEADING_BLACK_COLS - 1) + 1;
trailingBlackCols = get_keyboard_input('Trailing Black Columns', TRAILING_BLACK_COLS - 1) + 1;
virtualSmearRows = get_keyboard_input('Virtual Smear Rows', VIRTUAL_SMEAR_ROWS - 1) + 1;
maskedSmearRows = get_keyboard_input('Masked Smear Rows', MASKED_SMEAR_ROWS - 1) + 1;

% Prompt for original black-dark FFIs
defaultInputDirectory = 'c:/path/to/CBD_Data';
defaultInputFile ='';
[fileFFIsNameArray, fileFFIsDir] = uigetfile('*.fits', 'Select Original CCD Black Dark FFIs', ...
    'MultiSelect', 'on', fullfile(defaultInputDirectory, defaultInputFile));

defaultOutputDirectory = fileFFIsDir;
defaultOutputFile = ['cbd_report_' dateStr];
[dataArchivalFile, dataArchivalDir] = uiputfile('*.fits', 'Save 2D Black Report', ...
    fullfile(defaultOutputDirectory, defaultOutputFile) );


%% %%%%%%%%%%%%% don't change anything below this line %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FFI files are in the same directory and file names are stored as cellarray
if ( ispc )
    codeRoot=getenv('SOC_CODE_ROOT');
    dataArchivalDir = fileFFIsDir;
elseif ( isunix )
    codeRoot=getenv('SOC_CODE_ROOT');
else
    error('Error: unknown platform');
end


% Construct the input data structure
try
    % CBD internal parameters: not all used.
    cbdParameters = struct( ...
        'foldedAverage',    false, ...
        'debugOption',      true ...
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
    save('cbdDataInStruct.mat', 'cbdDataInStruct');
    cbdDataOutStruct = cbd_controller(cbdDataInStruct);
catch
    lastError = lasterror();
    error(['Error with executing cbd_controller(): ' lastError.message ' file loc: ' lastError.stack(1).file ]);
end

close all;
%% Extract the output data structure if necessary;
% otherwise take the output data struct as is.

try
    % save the result in a mat file: need v7.3 flag set as default.
    dataOutStructFile = fullfile(dataArchivalDir, ['cbdDataOutStruct_' dateStr]);
    save(dataOutStructFile, 'cbdDataOutStruct');

    % run the report generator to produce both html and pdf
    %generate_report_from_struct('cbd-report.rpt', dataArchivalDir, dataArchivalFile);
catch
    lastError = lasterror();
    error(['Error with saving CBD output results and generating report: ' lastError.message ' file loc: ' lastError.stack(1).file ]);
end

cbd_time = toc ;

% Signal the completion of the processing steps
disp(['CBD processinf and report are completed with time: ' num2str(cbd_time / 3600) ' hours']);
