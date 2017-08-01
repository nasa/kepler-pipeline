function [resultStruct  matFileStatus xlsFileStatus] = generate_all_stat_result(ffiName)
% generate_all_stat_result returns the statistics of an ffi in fits format
% ffiName should be a string with *.fits extension
% resultStruct is the  structure returned to the base workspace
% matFileStatus returns 1 if *.mat file is 
% successfully written, 0 otherwise
% xlsFileStatus returns 1 if *.csv file is 
% succesfully written, 0 otherwise
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

% prompt user for saving mat and spreadsheets first
defaultFileName = strtok(ffiName, '.');
[matFileName matFilePath] = uiputfile('*.mat', 'Save statistics in *.mat format', defaultFileName);
fullMatFileName = fullfile(matFilePath, matFileName);
[csvFileName, csvFilePath] = uiputfile('*.csv', 'Save statistics in *.csv format', defaultFileName );
fullCsvFileName = fullfile(csvFilePath, csvFileName );

modnumArray = zeros(84,3);

for channel = 1:84

    info = fitsinfo(ffiName);
    
    % find number of coadds from the fits main header
    indxNumCoadds = strmatch('NUM_FFI', info.PrimaryData.Keywords(:,1), 'exact');
    numCoadds = info.PrimaryData.Keywords{indxNumCoadds,2};
    
    % find the "actual module and output numbers" from the image headers
    % as channel number from fits file may not match up with modouts
    indxModule = strmatch('MODULE',info.Image(channel).Keywords(:,1), 'exact');
    indxOutput =  strmatch('OUTPUT', info.Image(channel).Keywords(:,1), 'exact');
    if isempty(indxModule) == 0 && isempty(indxOutput) == 0
        modnum = info.Image(channel).Keywords{indxModule,2};
        outnum = info.Image(channel).Keywords{indxOutput,2};
    else
        [modnum outnum] = convert_to_module_output(channel);
    end
    
    % create array of 'real' ordered modouts
    % col 1 = channel number
    % col 2 = module number
    % col 3 = output number
    
    modnumArray(channel,2) = modnum;
    modnumArray(channel,3) =outnum;
    modnumArray(channel,1)= convert_from_module_output(modnum, outnum);
    
   
    ffiImage = fitsread(ffiName, 'image', modnumArray(channel,1)); % read image portion of fits file
    imageStruct = trim_and_normalize_ffi(ffiImage, numCoadds);   
    region = {'star', 'leadingBlack', 'trailingBlack', 'maskedSmear', 'virtualSmear'};
    
    for i= 1:length(region)

        resultStruct.(region{i})(channel) = compute_stat(imageStruct.(region{i}), modnum, outnum);
        
    end

end


% save the stat structure in a mat file

string = ['save ' fullMatFileName ' resultStruct'];
eval(string);

if exist(fullMatFileName, 'file') ~= 0;
    matFileStatus = 1;
else
    matFileStatus = 0;
end


% save data in *.xls (*. csv) format (a.k.a. "human readable format")
% xlswrite not used as it is specific to MS excel (assume it is not installed on
% every machine)



% transform the structure into a cell so that it can go into 1 single sheet
statKeywords =  fieldnames(resultStruct.star)';
header =[{'channel'}, {'module'}, {'output'}, statKeywords];
starCell = squeeze(struct2cell(resultStruct.star))';
leadingBlackCell = squeeze(struct2cell(resultStruct.leadingBlack))';
trailingBlackCell = squeeze(struct2cell(resultStruct.trailingBlack))';
maskedSmearCell = squeeze(struct2cell(resultStruct.maskedSmear))';
virtualSmearCell = squeeze(struct2cell(resultStruct.virtualSmear))';
modnumCell = num2cell(modnumArray);



% create the big cell to plunk on the spreadsheet:
xlsCell = [{'star'}, repmat({''}, 1,15); ...
    header; ...
    modnumCell, starCell; ...
    repmat({''},3,16); ...
    {'Leading Black'}, repmat({''}, 1,15); ...
    header; ...
    modnumCell, leadingBlackCell; ...
    repmat({''},3,16); ...
    {'Trailing Black'}, repmat({''}, 1,15);...
    header; ...
    modnumCell, trailingBlackCell;...
    repmat({''},3,16); ...
   {'Masked Smear'}, repmat({''}, 1,15);...
   header; ...
   modnumCell, maskedSmearCell; ...
   repmat({''},3,16); ...
   {'Virtual Smear'}, repmat({''}, 1,15); ...
   header;...
   modnumCell,virtualSmearCell];



% save file in spreadsheet format
cell2csv(fullCsvFileName, xlsCell, ',');
if exist(fullCsvFileName, 'file') ~= 0;
    xlsFileStatus = 1;
else
    xlsFileStatus = 0;
end

