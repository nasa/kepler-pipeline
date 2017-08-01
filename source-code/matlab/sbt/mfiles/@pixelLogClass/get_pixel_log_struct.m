function pixelLogStruct = get_pixel_log_struct(pixelLogObject, startInterval, endInterval, isInputCadenceNumber, fields)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pixelLogStruct = get_pixel_log_struct(pixelLogObject)
% or
% function pixelLogStruct = get_pixel_log_struct(pixelLogObject, startInterval, endInterval, isInputCadenceNumber)
% or
% function pixelLogStruct = get_pixel_log_struct(pixelLogObject, startInterval, endInterval, isInputCadenceNumber, fields)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Get the values of the specified fields of pixelLogObject within the specified time interval
%
% Inputs:
%   pixeLogObject                                       An object of the pixel logs.
%   startInterval                                       Optional. Start cadence number or MJD start time of the specified time interval.
%   endInterval                                         Optional. End cadence number or MJD end time of the specified time interval.
%   isInputCadenceNumber                                Optional. Flag indicating the inputs 'startInterval' and 'endInterval' are cadence numbers/MJDs when it is 1/0. 
%   fields                                              Optional. 1 x nFields array of strings describing the specified fields of the pixelLogObject.
%                                                       A valid string should be a member of the set
%                                                       {   'cadenceNumber' 
%                                                           'cadenceType' 
%                                                           'dataSetType'
%                                                           'dispatcherType'
%                                                           'fitsFilename'
%                                                           'dataSetName'
%                                                           'mjdStartTime'
%                                                           'mjdEndTime'
%                                                           'mjdMidTime'
%                                                           'spacecraftConfigId'
%                                                           'lcTargetTableId'
%                                                           'scTargetTableId'
%                                                           'backTargetTableId'
%                                                           'targetApertureTableId'
%                                                           'backApertureTableId'
%                                                           'compressionTableId' 
%                                                           'isDataRequantizedForDownlink'
%                                                           'isDataEntropicCompressedForDownlink'
%                                                           'isDataOriginatedAsBaselineImage'
%                                                           'isBaselineCreatedFromResidualBaselineImage'
%                                                           'baselineImageRootname'
%                                                           'residualBaselineImageRootname'                 }.   
%                                                       If 'fields' are not specified, all fields of pixelLogObject are provided for output.
%                                                       If 'startInterval', 'endInterval', 'isInputCadenceNumber' and 'fields' are not specified,
%                                                       all fields of pixelLogObject at all available time stamps are provided for output.
%                                                      
% Output:
%   pixelLogStruct                                      1 x nPixelLogs array of structures describing the pixel logs. 
%                                                       nPixelLogs is the number of pixel logs in the array.
%                                                       The structure contains all or some of the following fields:
%       .cadenceNumber                                  Cadence number.  
%       .cadenceType                                    A string describing the cadence type. It can be either member of the set 
%                                                       {   'SHORT'
%                                                           'LONG'          }.
%       .dataSetType                                    A string describing the data set type. It can be any member of the set 
%                                                       {   'Target'
%                                                           'Background'
%                                                           'Collateral'    }.
%       .dispatcherType                                 A string describing the dispatcher type. It can be any member of the following set
%                                                       {   'LONG_CADENCE_PIXEL'
%                                                           'SHORT_CADENCE_PIXEL'
%                                                           'GAP_REPORT'
%                                                           'CONFIG_MAP'
%                                                           'REF_PIXEL'
%                                                           'LONG_CADENCE_TARGET_PMRF'
%                                                           'SHORT_CADENCE_TARGET_PMRF'
%                                                           'BACKGROUND_PRMF'
%                                                           'LONG_CADENCE_COLLATERAL_PMRF'
%                                                           'SHORT_CADENCE_COLLATERAL_PMRF'
%                                                           'HISTOGRAM'
%                                                           'ANCILLARY'
%                                                           'EPHEMERIS'
%                                                           'SCLK'
%                                                           'CRCT'
%                                                           'FFI'
%                                                           'HISTORY'					}.
%       .fitsFilename                                   A string describing the FITS file name.
%       .dataSetName                                    A string describing the data set name.
%       .mjdStartTime                                   MJD start time of the data.
%       .mjdEndTime                                     MJD end time of the data.
%       .mjdMidTime                                     MJD mid-point time of the data.
%       .spacecraftConfigId                             Spacecraft configuration ID.
%       .lcTargetTableId                                Long cadence target table ID.
%       .scTargetTableId                                Short cadence target table ID.
%       .backTargetTableId                              Background target table ID.
%       .targetApertureTableId                          Target aperture table ID.
%       .backApertureTableId                            Background aperture table ID.
%       .compressionTableId                             Compression table ID. Same ID is used for requatization and Huffman tables.
%       .isDataRequantizedForDownlink                   Flag indicating the data is/isn't requantized for downlink when it is 1/0.
%       .isDataEntropicCompressedForDownlink            Flag indicating the data is/isn't entropic compressed for downlink when it is 1/0.
%       .isDataOriginatedAsBaselineImage                Flag indicating the data is/isn't originated as baseline image when it is 1/0.
%       .isBaselineCreatedFromResidualBaselineImage     Flag indicating the baseline is/isn't created from residual baseline image when it is 1/0.
%       .baselineImageRootname                          A string describing the baseline image rootname.
%       .residualBaselineImageRootname                  A string describing the residual baseline image rootname.
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

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Validity check on inputs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if ~( nargin==1 || nargin==4 || nargin==5 )
    error('MATLAB:SBT:pixelLogClass:get_pixel_log_struct:wrongNumberOfInputs', ...
          'MATLAB:SBT:pixelLogClass:get_pixel_log_struct: must be called with 1 or 4 or 5 input arguments.');
end

% Define a structure with empty fields
pixelLogEmptyFields = struct('cadenceNumber',                               [], ...
                             'cadenceType',                                 '', ...
                             'dataSetType',                                 '', ...
                             'dispatcherType',                              '', ...
                             'fitsFilename',                                '', ...
                             'dataSetName',                                 '', ...
                             'mjdStartTime',                                [], ... 
                             'mjdEndTime',                                  [], ...
                             'mjdMidTime',                                  [], ...
                             'spacecraftConfigId',                          [], ...
                             'lcTargetTableId',                             [], ...
                             'scTargetTableId',                             [], ...
                             'backTargetTableId',                           [], ...
                             'targetApertureTableId',                       [], ...
                             'backApertureTableId',                         [], ...
                             'compressionTableId',                          [], ...
                             'isDataRequantizedForDownlink',                [], ...
                             'isDataEntropicCompressedForDownlink',         [], ...
                             'isDataOriginatedAsBaselineImage',             [], ...
                             'isBaselineCreatedFromResidualBaselineImage',  [], ...
                             'baselineImageRootname',                       '', ...
                             'residualBaselineImageRootname',               '');   
                         
if ( isempty(pixelLogObject) )
    error('MATLAB:SBT:pixelLogClass:get_pixel_log_struct:invalidInput', 'pixelLogObject cannot be empty.');
elseif ( isempty([pixelLogObject.cadenceNumber]) )
    warning('MATLAB:SBT:pixelLogClass:get_pixel_log_struct:outputStructWithEmptyFields', ...
            'No data in pixelLogObject. A structure with empty fields is provided for output.');
    pixelLogStruct = pixelLogEmptyFields;
    return
end

isAllTimeStamps = 0;
if ( ~exist('startInterval', 'var') || ~exist('endInterval', 'var') || ~exist('isInputCadenceNumber', 'var') )
    % If any of the inputs "startInterval", "endInterval" and "isInputCadenceNumber" doesn't exist, 
    % the pixel logs at all available time stamps are provided for output.
    isAllTimeStamps = 1;
    indexPixelLog = 1:length([pixelLogObject.cadenceNumber]);
else
    % Check the validity of inputs "startInterval", "endInterval" and "isInputCadenceNumber"
    sbt_validate_time_interval(startInterval, endInterval, isInputCadenceNumber, 'MATLAB:SBT:pixelLogClass:get_pixel_log_struct:invalidInput');

    % Get the indexes of pixel logs which are within the specified time interval
    switch (isInputCadenceNumber)
        case 1
            allCadenceNumber = [pixelLogObject.cadenceNumber];
            indexPixelLog = find( allCadenceNumber>=startInterval & allCadenceNumber<=endInterval );
        case 0
            allMjdStartTime = [pixelLogObject.mjdStartTime];
            allMjdEndTime   = [pixelLogObject.mjdEndTime];
            indexPixelLog   = find( allMjdEndTime>=startInterval & allMjdStartTime<=endInterval);
        otherwise
            error('MATLAB:SBT:pixelLogClass:get_pixel_log_struct:invalidInput', 'Valid value of isInputCadenceNumber should be 1 or 0.');
    end
end

isAllFields = 0;
iValidField = 0;
validFields = [];
allFields = {'cadenceNumber' 'cadenceType' 'dataSetType' 'dispatcherType' 'fitsFilename' 'dataSetName' 'mjdStartTime' 'mjdEndTime' 'mjdMidTime' ...
             'spacecraftConfigId' 'lcTargetTableId'  'scTargetTableId' 'backTargetTableId' 'targetApertureTableId' 'backApertureTableId' 'compressionTableId' ...
             'isDataRequantizedForDownlink' 'isDataEntropicCompressedForDownlink' 'isDataOriginatedAsBaselineImage' 'isBaselineCreatedFromResidualBaselineImage' ...
             'baselineImageRootname' 'residualBaselineImageRootname'};
if ( ~exist('fields', 'var') )
    % If the input "fields" doesn't exit, all fields of the pixel logs are provided for output.
    isAllFields = 1;
    validFields = allFields;
elseif ( isempty(fields) )
    validFields = [];
else
    % Check the validity of each member of the input "fields"
    for iField = 1:length(fields)
        aField = fields{iField};
        if ( ismember(aField, allFields) )
            iValidField = iValidField + 1;
            validFields{iValidField} = aField;
        else
            warning('MATLAB:SBT:pixelLogClass:get_pixel_log_struct:invalidInput', [aField ' is not a valid field of pixelLogObject']);
        end
    end
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generate the output structure
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if ( isempty(indexPixelLog) )
    warning('MATLAB:SBT:pixelLogClass:get_pixel_log_struct:outputStructWithEmptyFields', ...
        'No pixel logs found within the specified time interval. A structure with empty fields is provided for output.');
    pixelLogStruct = pixelLogEmptyFields;
    return
end

if ( isempty(validFields) )
    warning('MATLAB:SBT:pixelLogClass:get_pixel_log_struct:outputStructWithEmptyFields', ...
            'No valid fields found in the specified "fields". A structure with empty fields is provided for output.');
    pixelLogStruct = pixelLogEmptyFields;
    return
end

if ( isAllTimeStamps==1 && isAllFields==1 )
    pixelLogStruct = struct(pixelLogObject);
elseif ( isAllTimeStamps~=1 && isAllFields==1 )
    pixelLogStruct = struct(pixelLogObject(indexPixelLog));
else
    for iPixelLog = 1:length(indexPixelLog)
        for iField = 1:length(validFields)
            indexField = strmatch(validFields{iField}, allFields, 'exact');
            pixelLogStruct(iPixelLog).(validFields{iField}) = pixelLogObject(indexPixelLog(iPixelLog)).(allFields{indexField});
        end
    end
end

return
