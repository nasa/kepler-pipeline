function  dgOutputStruct = dg_matlab_controller()
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function dgOutputStruct = dg_matlab_controller()
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% dg_matlab_controller is the main controller for Data Goodness (DG) Tool
% dg_matlab_controller is invoked at command line to start DG analysis
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS: 
%           none for the command line, controller will prompt for user
%           input files
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUTS:
%          
%          fullFfiFileName: [string] directory and fits filename of file analyzed
%          fullCsvFileName: [string] directory and csv filename saved
%          fullMatFileName: [string] directory and mat filename saved
%       fullReportFileName: [string] direcotry and report filename saved
%               statStruct: [struct 1 x 84] statistics calculated
%               guardBands: [struct] with fields -
%                                       .lowGuardBand [array double]
%                                       .highGuardBand [double]
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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




tic
fprintf('starting dg_matlab_controller...\n')

os = computer;
if strcmp(os, 'GLNXA64') % increase open files to avoid report error on linux
    !ulimit -n 2000
end


dgOutputStruct = struct('fullFfiFileName', [], 'fullAncFileName', [],'fullCsvFileName', [], ...
    'fullMatFileName', [], 'fullReportFileName', [], ...
    'statStruct', [], 'guardBands', []);



% select and validate input fits file, 84 module outputs have to be found
[ffiName ffiPath] = dg_prompt_and_validate_ffi();
assignin('base', 'ffiName', ffiName)
assignin('base', 'ffiPath', ffiPath)
fullFfiFileName = fullfile(ffiPath, ffiName);
assignin('base', 'fullFfiFileName', fullFfiFileName)


% prompt user for a file with list of ancillary data to retrieve
[fullAncFileName inputMnemonicsCell] = prompt_for_anc_file();
assignin('base', 'fullAncFileName', fullAncFileName)



% prompt user for names and locations to save report, mat, and csv files
[fullMatFileName fullCsvFileName fullReportFileName reportFileName reportFilePath] = ...
   dg_prompt_user_to_save_files(fullFfiFileName);
assignin('base', 'reportFileName', reportFileName)
assignin('base', 'reportFilePath', reportFilePath)



if ~ischar(reportFileName)
    disp('TERMINATED DG TOOL BECAUSE NO REPORT WILL BE GENERATED')
    return % terminate controller if report name and location not specified
end



% extract ffi keywords, currently at 7, but additional ones can be added
[ffiKeywordStruct ffiKeywordTable] = retrieve_fits_primary_keywords(fullFfiFileName,...
    'DATATYPE', 'INT_TIME', 'NUM_FFI', 'DCT_PURP', ...
    'SCCONFID', 'STARTIME', 'END_TIME');
assignin('base', 'ffiKeywordStruct', ffiKeywordStruct)
assignin('base', 'ffiKeywordTable', ffiKeywordTable)



% get Mjd variables to use for retrieval of configMap
startMjd = ffiKeywordStruct.STARTIME;
endMjd = ffiKeywordStruct.END_TIME;



% retrieve ancillary data by inputting a cell of mnemonics and the time 
fprintf('retrieving ancillary data...\n')
try
dgAncObj = dgAncillaryClass(inputMnemonicsCell, startMjd, endMjd);
assignin('base', 'dgAncObj', dgAncObj);
catch
    fprintf('ancillary data retrieval from sandbox not working, not including ancillary data in report\n')
end



% retrieve configMap by ID number
try
configMapTable = dg_retrieve_config_map_by_id(ffiKeywordStruct.SCCONFID);
assignin('base', 'configMapTable', configMapTable)
catch
    fprintf('unable to retrieve configuration map from sandbox, leaving blank\n')
    configMapTable = [];
    assignin('base', 'configMapTable', configMapTable)
end



% read in high and low guard bands
% highGuardBand is a single value, lowGuardBand is an 84x1 array
[highGuardBand lowGuardBand] = dg_read_high_low_guard_bands(startMjd, endMjd);
assignin('base', 'highGuardBand', highGuardBand)
assignin('base', 'lowGuardBand', lowGuardBand)



% compute statistics
statStruct = dg_generate_big_stat_struct...
    (fullFfiFileName,ffiKeywordStruct, highGuardBand, lowGuardBand);
assignin('base', 'statStruct', statStruct)



%  save the stat structure in a mat file
matFileStatus = dg_save_mat_file( fullMatFileName, statStruct);
if matFileStatus == 0
    fullMatFileName = 'mat file not saved';
end



% save the stat structure in csv format
[csvFileStatus spreadsheetCell] = dg_save_csv_file(statStruct, fullCsvFileName);
assignin('base', 'spreadsheetCell', spreadsheetCell)
if csvFileStatus == 0
    fullCsvFileName = 'csv file not saved';
end



% focal plane display preparation, call to the graphing is done on the
% report side
downsampleImgStruct = dg_downsample_image(fullFfiFileName); % by default, bins in 10
gangedStruct = dg_gang_downsampled_outputs(downsampleImgStruct);
assignin('base', 'gangedStruct', gangedStruct)



% generate report in html format
report dgReportHTML -fhtml -shtml-!MultiPage
if exist(strcat(fullfile(reportFilePath, reportFileName), '.html'), 'file') == 2
fprintf('completed and saved report\n');
else
    fprintf('failed to generate report\n')
    fullReportFileName = 'report not saved';
end



% place data necessary for dg reconstruction in output structure and save in current dir
dgOutputStruct.fullFfiFileName = fullFfiFileName;
dgOutputStruct.fullAncFileName = fullAncFileName;
dgOutputStruct.fullCsvFileName = fullCsvFileName;
dgOutputStruct.fullMatFileName = fullMatFileName;
dgOutputStruct.fullReportFileName = fullReportFileName;
dgOutputStruct.statStruct = statStruct;
dgOutputStruct.guardBands = struct('highGuardBand', highGuardBand', ...
    'lowGuardBand', lowGuardBand );
save dgOutputStruct dgOutputStruct % *.mat filetype



% launch gui
fprintf('now launching gui...\n')
display_focal_plane(gangedStruct, fullFfiFileName)
mouse_over_to_get_modout
interactive_histogram(fullFfiFileName)



fprintf('completed dg_matlab controller \n it took %5.2f seconds to run data goodness\n', toc)
