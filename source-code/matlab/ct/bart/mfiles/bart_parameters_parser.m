function bartDataInStruct = bart_parameters_parser( inputParameterFilename )
% function bartDataInStruct = bart_paramsters_parser( inputParameterFilename )
% Parsing a user supplied input parameter file to extract the information
% for running BART through bart_matlab_controller()
%
%   Top Level Input
%
%   inputParameterFilename is a parameter file with the following fields:
%
%  SelectedChannels         = 1:84
%  OutputFoldername         = /path/to/matlab/bart/outputs
%  OutputTag                = TVAC
%  ReferenceTemperature     = 25
%  TemperatureMnemonics     = mnemonic_file.txt
%  InputFoldername          = /path/to/matlab/bart/inputs/ORT2a
%  FitsFilenames            =
%                kplr2009074050000_ffi-orig.fits
%--------------------------------------------------------------------------
%
%   Top Level Output
%
%    bartDataInStruct is data structure with the following fields:
%       inputFoldername: [string] input folder name of FITS files
%         fitsFilenames: [cell array] a list of column major FITS file names
%      selectedChannels: [int array]
%  temperatureMnemonics: [string]
%  referenceTemperature: [double]
%      outputFoldername: [string] top level output folder name
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

MsgID = 'CT:BART:bart_parameters_parser';

if ( nargin == 0 )
    error(MsgID, 'Usage: paramStruct = bart_paramsters_parser(inputParameterFilename)' );
elseif (isempty( inputParameterFilename ) || ...
        ~ischar(inputParameterFilename) || exist(inputParameterFilename, 'file') ~= 2 )
    error(MsgID, 'Input parameter file is empty, not string or does not exist!' );
end

% open the input parameter file
fid = fopen(inputParameterFilename, 'r');
if ( fid == -1 )
    error(MsgID, ['Error in opening file ' inputParameterFilename]);
end

fieldValues = textscan(fid, '%s %s', 'Delimiter', '=', 'MultipleDelimsAsOne', '1', 'CommentStyle','#');
if isempty( fieldValues )
    error(MsgID, ['Error in reading file ' inputParameterFilename]);
end

fclose(fid);

nLines = size( fieldValues{1}, 1 );
nColumns = size( fieldValues, 2 );
if ( nLines < 1 || nColumns < 2 )
    error(MsgID, ['Error in reading keyword values from file ' inputParameterFilename]);
end

% construct the data structure
bartDataInStruct = struct( ...
    'inputFoldername',      [], ...
    'fitsFilenames',        [], ...
    'selectedChannels',     [], ...
    'temperatureMnemonics', [], ...
    'referenceTemperature', [], ...
    'outputFoldername',     [], ...
    'outputTag',            [] ...
    );

pmrfFilename = [];
mnemonicFilename = [];
k = 1;
while ( k <= nLines )
    keyword = strtrim( fieldValues{1}{k} );
    value = strtrim( fieldValues{2}{k} );
    if isempty( keyword ) || ~ischar(keyword)
        error(MsgID, 'Unexpected empty or none character keyword');
    end

    if strcmp('FitsFilenames', keyword )
        fileIdxStart = k + 1;
        while isempty( strtrim( fieldValues{2}{k})) && ~isempty( strtrim( fieldValues{1}{k}))
            k = k + 1;
            if ( k > nLines )
                break;
            end
        end
        nFitsFiles = k - fileIdxStart;
        if isempty(pmrfFilename)
            bartDataInStruct.fitsFilenames = strtrim( fieldValues{1}(fileIdxStart:k-1) );
        else
            bartDataInStruct.fitsFilenames = cell(nFitsFiles, 2);
            bartDataInStruct.fitsFilenames(:, 1) = strtrim( fieldValues{1}(fileIdxStart:k-1) );
            bartDataInStruct.fitsFilenames(:, 2) = repmat({pmrfFilename}, nFitsFiles, 1);
        end

        strtrim( fieldValues{1}(fileIdxStart:k-1) );

    else
        % expecting non-empty values
        if isempty( value ) || ~ischar(value)
            error(MsgID, 'Unexpected empty or none character keyword');
        end

        if strcmp('SelectedChannels',  keyword)
            bartDataInStruct.selectedChannels = int32( str2num( value ) );
        elseif strcmp('OutputFoldername', keyword )
            if ( exist(value, 'dir') == 7 )
                bartDataInStruct.outputFoldername = value;
            else
                error(MsgID, 'outputFoldername does not exist');
            end
        elseif strcmp('OutputTag', keyword )
            bartDataInStruct.outputTag = value;
        elseif strcmp('ReferenceTemperature', keyword )
            bartDataInStruct.referenceTemperature = str2double( value );
        elseif strcmp('MnemonicFilename', keyword )
            mnemonicFilename = value;
        elseif strcmp('InputFoldername', keyword )
            if ( exist(value, 'dir') == 7 )
                bartDataInStruct.inputFoldername = value;
            else
                error(MsgID, 'inputFoldername does not exist');
            end
        elseif strcmp('PMRFFilename', keyword )
            pmrfFilename = value;
        else
            warning(MsgID, ['Unknown variable names: ' keyword]);
        end
    end

    % increment the line index
    k = k + 1;
end

% we read the mnemonic file
if isempty(mnemonicFilename) || ~( exist(mnemonicFilename, 'file') == 2 )
    error(MsgID, 'Mnemonic file does not exist');
else
    [mnemonicValueString, mnemonicStatusString] = textread(mnemonicFilename, '%s %s');
    bartDataInStruct.temperatureMnemonics = [mnemonicValueString, mnemonicStatusString];
end

if ~(isfield(bartDataInStruct, 'inputFoldername') && ...
        isfield(bartDataInStruct, 'fitsFilenames') && ...
        isfield(bartDataInStruct, 'selectedChannels') && ...
        isfield(bartDataInStruct, 'temperatureMnemonics') && ...
        isfield(bartDataInStruct, 'referenceTemperature') && ...
        isfield(bartDataInStruct, 'outputFoldername'))

    error(MsgID, 'Missing fields in bartDataInStruct');
end
return