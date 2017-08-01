function ffi_data_struct = retrieve_filestore_ffi(varargin)
%
% The FFI data extractor retrieves the origain or calibrated FFI data from
% the file store.
%
% ffi_data_struct = retrieve_filestore_ffi(get_raw_data)
%
% ffi_data_struct = retrieve_filestore_ffi(get_raw_data, save_local_copies)
%
% ffi_data_struct = retrieve_filestore_ffi(start_mjd, end_mjd, get_raw_data)
%
% ffi_data_struct = retrieve_filestore_ffi(start_mjd, end_mjd, get_raw_data, save_local_copies)
%
% ffi_data_struct = retrieve_filestore_ffi(start_mjd, end_mjd, modules, outputs, get_raw_data)
%
% ffi_data_struct = retrieve_filestore_ffi(start_mjd, end_mjd, modules, outputs, get_raw_data, save_local_copies)
%
% INPUTS:
%
%   get_raw_data            If 1, uncalibrated data is retrieved,
%                           if 0, calibrated data is received.  Defaults to 1.
%
%   start_mjd               The MJD of the start of the desired time
%                           interval.  If unspecified, the entire mission
%                           interval is used.
%
%   end_mjd                 The MJD of the end of the desired time interval. 
%                           If unspecified, the entire mission interval is used.
%
%   modules                 A list of the desired modules.  All are returned
%                           if this is not specified.  Must be the same length as 'outputs' if
%                           specified.
%
%   outputs                 A list of the desired outputs.  All are returned
%                           if this is not specified.  Must be the same length as 'modules' if
%                           specified.
%
%   save_local_copies       A flag to determine if local copies of the FITS
%                           files are saved (1), or removed after extracting the data (0). Defaults
%                           to 0.
%
% OUTPUTS:
%   ffi_data_struct         A 1 x N array of structures sorted in the
%                           ascending order of the MJD start time of the FFI (from the FITS
%                           header).
%
%       .ffiKeywordStruct   A structure containing the following fields from the FFI FITS header:
%           .startTime      The UTC start time of the observation in MJD
%           .endTime        The UTC end time of the observation in MJD
%           .intTime        The integration time of the individual integrations (seconds, between 2.5 and 8).
%           .dataType       The data type.  Should be 'FFI'.
%           .numFfi         The number of integrations in this FFI.
%
%       .moduleArray      A list of nChannels length of the modules included.  Same length as outputArray.
%       .outputArray      A list of nChannels length of the outputs included.  Same length as moduleArray.
%       .ffiImage         A 1070 by 1132 by nChannels matrix of pixel values.  nChannels is the length of moduleArray and outputArray.
%       .isOriginalData   A flag with the value of the input arg get_raw_data.
%
%
% To get a file listing of the available FFIs in the filestore, use the 
% retrieve_received_file API:
%    received_files_struct = retrieve_received_file('FFI', start_mjd, end_mjd);
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

    import gov.nasa.kepler.systest.sbt.SandboxTools;
    SandboxTools.displayDatabaseConfig;

    try
        CALIBRATED_FFI_SUFFIX = 'ffi-cal.fits';
        RAW_FFI_SUFFIX = 'ffi-orig.fits';

        import gov.nasa.kepler.fc.fitsapi.FfiOperations;
        import gov.nasa.kepler.common.FcConstants;

        switch length(varargin)
            case 1
                start_mjd = 54000;
                end_mjd   = 64000;
                get_raw_data  = varargin{1};
                save_local_copies = 0;
                is_mod_outs_given = 0;
            case 2
                start_mjd = 54000;
                end_mjd   = 64000;
                get_raw_data  = varargin{1};
                save_local_copies = varargin{2};
                is_mod_outs_given = 0;
            case 3
                start_mjd = varargin{1};
                end_mjd = varargin{2};
                save_local_copies = 0;
                get_raw_data  = 1;
                is_mod_outs_given = 0;
            case 4
                start_mjd = varargin{1};
                end_mjd = varargin{2};
                get_raw_data = varargin{3};
                save_local_copies = varargin{4};
                is_mod_outs_given = 0;
            case 5
                start_mjd = varargin{1};
                end_mjd = varargin{2};
                modules = varargin{3};
                outputs = varargin{4};
                save_local_copies = 0;
                get_raw_data  = 1;
                is_mod_outs_given = 1;
            case 6
                start_mjd = varargin{1};
                end_mjd = varargin{2};
                modules = varargin{3};
                outputs = varargin{4};
                get_raw_data = varargin{5};            
                save_local_copies = varargin{6};
                is_mod_outs_given = 1;
            otherwise
                error('MATLAB:SBT:wrapper:retrieve_filestore_ffi', ...
                    'The retrieve_filestore_ffi tool must be called with 1-6 arguments.  See help text.')
        end


        % Validate input mod/out args, if given:
        %
        if is_mod_outs_given
            channels = convert_from_module_output(modules, outputs);
        else
            num_channels = FcConstants.nModules * FcConstants.nOutputsPerModule;
            channels = 1:num_channels;
        end

        % Get filenames (for time range, if given):
        %
        received_files_struct = retrieve_received_file('FFI', start_mjd, end_mjd);
        
        num_FFIs = length(channels) * length(received_files_struct);
        if num_FFIs > 100
            warning('A large number (%d) of 1070x1132 images have been requested: this may take a while', num_FFIs);
        end

        % Extract the filestore-FFI filenames from the received_files_struct:
        %
        num_files = length([received_files_struct.mjdSocIngestTime]);
        if num_files == 0
            error('MATLAB:SBT:wrapper:retrieve_filestore_ffi', ...
                  'No files returned from retrieve_received_files');
        end
        for iname = 1:num_files
            fs_names{iname} = received_files_struct(iname).filename;
        end


        % Copy the FFIs out of filestore, and put them into the ffi_data_struct:
        %
        count = 1;
        ffi_ops = FfiOperations(); 
        for iffi= 1:length(fs_names)
            fs_name = fs_names(iffi);
            
            % If the filename matches the calibrated FFI filename suffix, and 
            % the user wants the calibrated data, get it:
            %
            calFind = strfind(fs_name, CALIBRATED_FFI_SUFFIX);
            isCal = calFind{1} > 0;

            rawFind = strfind(fs_name, RAW_FFI_SUFFIX);
            isRaw = rawFind{1} > 0;

            if isCal
                if ~get_raw_data
                    single_ffi_data_struct = get_single_ffi_data_struct(fs_name, ffi_ops, channels, save_local_copies, get_raw_data);
                    ffi_data_struct(count) = single_ffi_data_struct; %#ok<AGROW>
                    count = count + 1;
                end
            % If the filename matches the uncalibrated FFI filename suffix, and
            % the user wants the raw data, get it:
            %
            elseif isRaw
                if get_raw_data
                    single_ffi_data_struct = get_single_ffi_data_struct(fs_name, ffi_ops, channels, save_local_copies, get_raw_data);
                    ffi_data_struct(count) = single_ffi_data_struct; %#ok<AGROW>
                    count = count + 1;
                end
            % If the filename doesn't mach any FFI filename suffix, throw an
            % error:
            %
            else
                error('MATLAB:SBT:wrapper:retrieve_filestore_ffi', ...
                      'FFI name from filesystem does not end with either suffix %s or suffix %s.  Error!', ...
                      CALIBRATED_FFI_SUFFIX, RAW_FFI_SUFFIX);
            end

        end
        SandboxTools.close;
    catch
        SandboxTools.close;
        rethrow(lasterror);
    end
return


function single_ffi_data_struct = get_single_ffi_data_struct(fs_name, ffi_ops, channels, save_local_copies, get_raw_data)
    [modules outputs] = convert_to_module_output(channels);

    wanted_header_fields = {...
        'STARTIME', ...
        'END_TIME', ...
        'INT_TIME', ...
        'NUM_FFI', ...
        'DATATYPE'};

    single_ffi_data_struct = struct( ...
        'ffiKeywordStruct', struct(), ...
        'moduleArray',      [], ...
        'outputArray',      [], ...
        'ffiImage',         [], ...
        'isOriginalData',   1);

    % Populate mod/out & flag:
    %
    single_ffi_data_struct.moduleArray    = modules;
    single_ffi_data_struct.outputArray    = outputs;
    single_ffi_data_struct.isOriginalData = get_raw_data;

    % Copy file; use the FS filename for the local filename; this guarantees
    % uniqueness:
    %
    local_copy_ffi_name = sprintf('%s/%s', pwd(), fs_name{1});
    ffi_ops.copyFfiToLocal(fs_name, local_copy_ffi_name);

    % Extract the fitsinfo
    fits_info = fitsinfo(local_copy_ffi_name);

    % Read the header values into the output struct when the
    % header field key matches one of the wanted fields: 
    %   STARTIME END_TIME INT_TIME NUM_FFI DATATYPE
    %
    keyword_struct = struct( ...
        'startTime', 0, ...
        'endTime',   0, ...
        'intTime',   0, ...
        'dataType',  0, ...
        'numFfi',    0);

    for iheader = 1:length(fits_info.PrimaryData.Keywords)
        header_key = fits_info.PrimaryData.Keywords{iheader, 1};
        header_val = fits_info.PrimaryData.Keywords{iheader, 2};

        switch header_key
        case wanted_header_fields{1}
            keyword_struct.startTime = header_val;
        case wanted_header_fields{2}
            keyword_struct.endTime   = header_val;
        case wanted_header_fields{3}
            keyword_struct.intTime   = header_val;
        case wanted_header_fields{4}
            keyword_struct.numFFI    = header_val;
        case wanted_header_fields{5}
            keyword_struct.dataType  = header_val;
        end
    end
    single_ffi_data_struct.ffiKeywordStruct = keyword_struct;

    % Extract the image:
    %
    for ichannel = 1:length(channels)
        msg = sprintf('extracting channel %d of image %s', ichannel, local_copy_ffi_name);
        disp(msg)
        single_ffi_data_struct.ffiImage(:, :, ichannel) = ...
            fitsread(local_copy_ffi_name,  'Image', channels(ichannel));
    end
    
    % Delete the local copy unless requested not to:
    %
    if ~save_local_copies
        delete(local_copy_ffi_name);
    end
return
