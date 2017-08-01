function [ffiData, ffiInfoStruct] = bart_read_fits_files( fitsFoldername, fitsFilenames, moduleIndex, outputIndex, nRows, nCols )
% function [ffiData, ffiInfoStruct] = bart_read_fits_files( fitsFoldername, fitsFilenames,  moduleIndex, outputIndex, nRows, nCols )
%
% This function reads FFI or RCLC fits files and parses the FITS header for the keywords of
% STARTIME, END_TIME and NUM_FFI, the number coadds and. It then outputs the keywords struct and the pixel data
% normalized by the number of coadds in FFI format.
%
% bart_read_fits_files.
%
%   Top Level Input
%
%   bartDataInStruct is a structure for each module output with the following fields:
%
%       fitsFoldername: [string] folder name of input FITS files
%    fitsFilenames: [cell array] array of FITS file names for FFI (cell(nFFI,1))
%                                and RCLC types (cell(nFFI,2)).
%              moduleIndx: [int] module index
%              outputIndx: [int] output index
%                   nRows: [int] expected number of FFI image rows
%                   nCols: [int] expected number of FFI image cols
%--------------------------------------------------------------------------
%
%   Top Level Output
%
%             ffiData: [double array] pixel data normalized by coadds of dimension nFFI x nRows x nCols;
%       ffiInfoStruct: [array struct] FFI information
%
%   Second level
%
%   ffiInfoStruct is an array of structure with the following fields:
%
%                  STARTIME: [double] the start time in MJD
%                  END_TIME: [double] the end time in MJD
%                      NUM_FFI: [int] the number of coadds
%                  DATATYPE: [string] is either 'ffi' or 'long cadence'
%----------------------------------------------------------
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
MsgID = 'CT:BART:bart_read_fits_files';

if ( nargin < 6 )
    error(MsgID, 'Not enough input arguments');
end

% constants for existence test
FILE_EXIST      = 2;
FOLDER_EXIST    = 7;

% validate the input data structure
if ( isempty(fitsFoldername) )
    error(MsgID, ['FITS folder is empty: ', fitsFoldername] );
elseif ( exist(fitsFoldername, 'dir') ~= FOLDER_EXIST )
    error(MsgID, ['FITS folder not found: ', fitsFoldername] );
end

if ( isempty(fitsFilenames) )
    error(MsgID, ['FITS files array is empty: ', fitsFilenames] );
else
    % get the number of FITS entries and the number of files per entry
    [nFitsFiles, nRCLCFiles] = size( fitsFilenames );
    if ( nFitsFiles < 1 || nRCLCFiles > 2 || nRCLCFiles < 1)
        error(MsgID, 'Incorrect number of FFI or RCLC files');
    else
        if ( nFitsFiles == 1 )
            warning(MsgID, 'Insufficient number of FFI or RCLC files for fitting, only one!');
        elseif ( nFitsFiles == 2 )
            warning(MsgID, 'Minimum number of FFI or RCLC files for fitting, only two!');
        end

        FFI_FILE_INPUT = true;
        if ( nRCLCFiles == 2 )
            FFI_FILE_INPUT = false;
        end

    end
end

% the channel index from module output representation
if ( moduleIndex < 2 || moduleIndex > 24 || outputIndex < 1 || outputIndex > 4 ) ...
        || (moduleIndex == 5) || (moduleIndex == 21)
    error(MsgID, 'Incorrect module or output indexes');
else
    channelIndex = convert_from_module_output( moduleIndex, outputIndex );
    if ( channelIndex < 1 || channelIndex > 84 )
        error(MsgID, 'Incorrect module or output indexes');
    end
end


% Pre-allocate memory for ffi data
ffiData = zeros(nFitsFiles, nRows, nCols);

% Pre-allocate memory for ffi information extracted from header
oneInfoStruct = struct('STARTIME', 0, 'END_TIME', 0, 'NUM_FFI', 0, 'DATATYPE', []);

ffiInfoStruct = repmat( oneInfoStruct, nFitsFiles, 1);

% This is for either FFI or RCLC files
for k = 1:nFitsFiles

    disp(['Reading FITS file ' num2str(k) ]);

    if ( isempty(fitsFilenames{ k, 1 }) )
        error(MsgID, ['FITS filename is empty: ', fitsFilenames{ k, 1 }] );
    end

    % extract FITS header keywords
    fitsFullFilename = fullfile(fitsFoldername, fitsFilenames{ k, 1 });

    if ~( exist(fitsFullFilename, 'file') == FILE_EXIST )
        error(MsgID, ['FITS file not found: ', fitsFullFilename] );
    end

    try
        % extract the keyword values
        ffiKeywordStruct = retrieve_fits_primary_keywords( fitsFullFilename, ...
            'STARTIME', 'END_TIME', 'NUM_FFI', 'DATATYPE');
    catch
        error(MsgID, ['Error with retrieve_fits_primary_keywords() for FITS file ' fitsFullFilename] );
    end

    if ~all( isfield(ffiKeywordStruct, {'STARTIME', 'END_TIME', 'NUM_FFI', 'DATATYPE'}) )
        error(MsgID, 'ffiKeywordStruct has invalid fields');
    end

    ffiInfoStruct(k) =  ffiKeywordStruct;

    if ( FFI_FILE_INPUT && ( strcmp( ffiKeywordStruct.DATATYPE, 'ffi') ))

        % extract FFI data
        try
            ffiInfo = fitsinfo(fitsFullFilename);
        catch
            error(MsgID, ['Error with fitsinfo() ', fitsFullFilename]);
        end

        ffiSize = ffiInfo.Image(channelIndex).Size;
        if ~( ffiSize(1) == nCols && ffiSize(2) == nRows )
            error(MsgID, ['Expected FFI image size different from size in header ', fitsFullFilename]);
        end
        try
            ffiImage = fitsread(fitsFullFilename, 'image', channelIndex);
        catch
            error(MsgID, ['Error with fitsread() ', fitsFullFilename]);
        end

    elseif ( strcmp( ffiKeywordStruct.DATATYPE, 'long cadence') )

        if ( isempty(fitsFilenames{ k, 2 }) )
            error(MsgID, ['FITS PMRF filename is empty: ', fitsFilenames{ k, 1 }] );
        end

        % extract RCLC data and save in FFI format
        fitsPMRFFullFilename = fullfile(fitsFoldername, fitsFilenames{ k, 2 });
        if ~( exist(fitsPMRFFullFilename, 'file') == FILE_EXIST )
            error(MsgID, ['FITS PMRF file not found: ', fitsPMRFFullFilename] );
        else

            try
                % extract the keyword values
                pmrfKeywordStruct = retrieve_fits_primary_keywords( fitsPMRFFullFilename , ...
                    'STARTIME', 'END_TIME', 'DATATYPE');
            catch
                error(MsgID, ['Error with retrieve_fits_primary_keywords() for PMRF file ' fitsPMRFFullFilename] );
            end

            if ~all( isfield(pmrfKeywordStruct, {'STARTIME', 'END_TIME', 'DATATYPE'}) )
                error(MsgID, 'ffiKeywordStruct has invalid fields');
            elseif ~( strcmp( pmrfKeywordStruct.DATATYPE, 'long cadence') )
                error(MsgID, ['FITS PMRF file is invalid type: ', fitsFullFilename] );
            end

        end

        % what do we do with the timestamps from two files?

        try
            [ffiImage, dataCompleteness, numCoAdds ] = fits_rc_extractor(channelIndex, fitsFullFilename, fitsPMRFFullFilename, nRows, nCols);
        catch
            error(MsgID, ['Error with fits_rc_extractor() ' fitsFullFilename ' , ' fitsPMRFFullFilename] );
        end
        ffiKeywordStruct.NUM_FFI = numCoAdds;
        clear fitsPMRFFullFilename pmrfKeywordStruct;
    else
        error(MsgID, ['FITS file is invalid type: ', fitsFullFilename] );
    end

    % normalize the pixel data by the number of coadds
    ffiData(k, :, :) = ffiImage / ffiKeywordStruct.NUM_FFI;

    clear ffiImage ffiKeywordStruct fitsFullFilename ;
end


return
