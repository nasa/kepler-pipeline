function ffiDataStruct = retrieve_filestore_ffi(varargin)
%
% The FFI data extractor retrieves the origain or calibrated FFI data from
% the file store.
%
% ffiDataStruct = retrieve_filestore_ffi(getRawData)
%
% ffiDataStruct = retrieve_filestore_ffi(getRawData, saveLocalCopies)
%
% ffiDataStruct = retrieve_filestore_ffi(start_mjd, end_mjd, getRawData)
%
% ffiDataStruct = retrieve_filestore_ffi(start_mjd, end_mjd, getRawData, saveLocalCopies)
%
% ffiDataStruct = retrieve_filestore_ffi(start_mjd, end_mjd, modules, outputs, getRawData)
%
% ffiDataStruct = retrieve_filestore_ffi(start_mjd, end_mjd, modules, outputs, getRawData, saveLocalCopies)
%
% INPUTS:
%
%   getRawData            If 1, uncalibrated data is retrieved,
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
%   saveLocalCopies       A flag to determine if local copies of the FITS
%                           files are saved (1), or removed after extracting the data (0). Defaults
%                           to 0.
%
% OUTPUTS:
%   ffiDataStruct           A 1 x N array of structures sorted in the
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
%       .isOriginalData   A flag with the value of the input arg getRawData.
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

    import gov.nasa.kepler.systest.sbt.SbtRetrieveFilestoreFfi;
    sbt = SbtRetrieveFilestoreFfi();
    
    CALIBRATED_FFI_SUFFIX = 'ffi-cal.fits';
    RAW_FFI_SUFFIX = 'ffi-orig.fits';

    if nargin < 1 || nargin > 6
            error('Matlab:common:wrapper:retrieve_filestore_ffi', ...
                'Incorrect number of args.  1-6 args are allowed.  Please see helptext.');
    end
    
    channels = 1:84;
    switch nargin
        case {5,6}
            modules = varargin{3};
            outputs = varargin{4};
            channels = convert_from_module_output(modules, outputs);
    end
    
    saveLocalCopies = false;
    switch nargin
        case {2,4,6}
            saveLocalCopies = varargin{end};
    end
    
    getRawData = false;
    switch nargin 
        case {3, 4}
            getRawData = varargin{3};
        case {5, 6}
            getRawData = varargin{5};
    end
    
    ffiFilenamesJava = sbt.retrieveFilestoreFfi(varargin{:});
    
    ffiDataStruct = repmat(struct('ffiImage', []), 1, ffiFilenamesJava.size() * length(channels) / 2);
    ffiCount = 1;
    for ifile = 1:ffiFilenamesJava.size()
        
        ffiFilename = ffiFilenamesJava.get(ifile-1);

        fileIsCalibrated   = ~isempty(strfind(ffiFilename, CALIBRATED_FFI_SUFFIX));
        fileIsUncalibrated = ~isempty(strfind(ffiFilename, RAW_FFI_SUFFIX));

        for ichannel = 1:length(channels)
            channel = channels(ichannel);
            
            if get_do_extraction(fileIsCalibrated, fileIsUncalibrated, getRawData)
                ffiDataStruct(ffiCount).ffiImage = fitsread(ffiFilename, 'Image', channel);
                ffiDataStruct(ffiCount).ffiKeywords = extract_fits_header(ffiFilename);
                ffiCount = ffiCount + 1;
            end

        end
        
        if ~saveLocalCopies
            delete(ffiFilename);
        end
    end
    
    SandboxTools.close;
return

function doExtraction = get_do_extraction(fileIsCalibrated, fileIsUncalibrated, getRawData)
    doExtraction = false;
    if fileIsCalibrated
        if ~getRawData
            doExtraction = true;
        end
    elseif fileIsUncalibrated
        if getRawData
            doExtraction = true;
        end
    else
        error('MATLAB:SBT:wrapper:retrieve_filestore_ffi', ...
            'FFI name %s from filesystem does not end with either suffix %s or suffix %s.  Error!', ...
            ffiFilename, CALIBRATED_FFI_SUFFIX, RAW_FFI_SUFFIX);
    end
return

function keywordStruct = extract_fits_header(ffiFilename)

    wantedHeaderFields = {...
        'STARTIME', ...
        'END_TIME', ...
        'INT_TIME', ...
        'NUM_FFI', ...
        'DATATYPE'};

    % Extract the fitsinfo
    fitsInfo = fitsinfo(ffiFilename);

    % Read the header values into the output struct when the
    % header field key matches one of the wanted fields: 
    %   STARTIME END_TIME INT_TIME NUM_FFI DATATYPE
    %
    keywordStruct = struct( ...
        'startTime', 0, ...
        'endTime',   0, ...
        'intTime',   0, ...
        'dataType',  0, ...
        'numFFI',    0);

    for iheader = 1:length(fitsInfo.PrimaryData.Keywords)
        header_key = fitsInfo.PrimaryData.Keywords{iheader, 1};
        header_val = fitsInfo.PrimaryData.Keywords{iheader, 2};

        switch header_key
            case wantedHeaderFields{1}
                keywordStruct.startTime = header_val;
            case wantedHeaderFields{2}
                keywordStruct.endTime   = header_val;
            case wantedHeaderFields{3}
                keywordStruct.intTime   = header_val;
            case wantedHeaderFields{4}
                keywordStruct.numFFI    = header_val;
            case wantedHeaderFields{5}
                keywordStruct.dataType  = header_val;
        end
    end
    
return
