function [image numFilledPixels numCoadds] = fits_rc_extractor(channelNumber, lcDataFile, lcPmrfFile, NUM_CCD_ROWS, NUM_CCD_COLUMNS)
%
% image = fits_rc_extractor(channelNumber, lcDataFile, lcPmrfFile, NUM_CCD_ROWS, NUM_CCD_COLUMNS)
%
% INPUTS:
%   channelNumber   -- the channel number (1-84) to get data for.
%
%   lcDataFile      -- the RC LC data file.
%
%   lcPmrfFile      -- the PRMF file.
%
%   NUM_CCD_ROWS    -- the number of rows on an output, courtesy FcConstants.java
%
%   NUM_CCD_COLUMNS -- the number of columns on an output, courtesy FcConstants.java
%
%
% OUTPUTS:
%   image -- the RC LC data for channelNumber as a NUM_CCD_ROWSxNUM_CCD_COLUMNS
%            (1070x1132) double-precision array, filled with bitFillValue where
%            pixels aren't specified by the PMRF.
%
%   numFilledPixels -- the number of pixels on channelNumber that were specified
%                      in the PMRF, but were gap-filled (as determined by the 
%                      FitsConstants.MISSING_CAL_PIXEL_VALUE value).
%
%   numCoadds -- The number of CCD exposures coadded to get the RCLC data.
%                This value is extracted from the configuration map.
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

    if nargin ~= 5
        error('CT:BART:fits_rc_extractor', 'Usage: channelNumber, lcDataFile, lcPmrfFile.');
    end
    if channelNumber > 84 || channelNumber < 1
        error('CT:BART:fits_rc_extractor', 'Channel number must be between 1 and 84.');
    end
    
    bitFillValue = -1;
    image = bitFillValue + zeros(NUM_CCD_ROWS, NUM_CCD_COLUMNS);
        
    % Get the values and locations of the pixel data:
    %
    [lcData lcRows lcCols] = get_data_and_pmrf_from_files(channelNumber, lcDataFile, lcPmrfFile, NUM_CCD_ROWS, NUM_CCD_COLUMNS);

    % Determine the number of pixels that have the magic gap-filled pixel value:
    %
    missingPixelValue = -1;
    otherMissingPixelValue = int32(-1); % just in case
    numFilledPixels = sum(lcData == missingPixelValue | lcData == otherMissingPixelValue);

    % Get the fixed offset/mean black/number-of-coadds correction:
    %
    configMapStruct = get_config_map(lcDataFile);
    configMapObject = configMapClass(configMapStruct);
    fixedOffset = get_fixed_offset(configMapObject);
    meanBlack   = get_mean_black(lcDataFile, channelNumber);
    numCoadds   = get_number_of_exposures_per_long_cadence_period(configMapObject);
    adjustment = - fixedOffset + meanBlack * numCoadds;

    % Update the pixels specified by the PMRF with the corrected pixel data.
    %
    pixIndex = sub2ind(size(image), lcRows, lcCols);
    image(pixIndex) = lcData + adjustment;
return

function meanBlack = get_mean_black(lcDataFile, channelNumber)
% Get the mean black from the requant table, retrieving the requantTableId from lcDataFile's header:
%

    % Make the most recently used requantTableId and the associated mean
    % black table persistent to reduce database calls in the tight loop
    % that fits_rc_extractor is called in.
    %
    persistent requantTableIdOld meanBlackEntries;
    
    requantTableIdKeyword = 'COMPTABL';
    requantTableId = bart_get_fits_header_value(requantTableIdKeyword, lcDataFile);
    if ischar(requantTableId)
        requantTableId = str2double(requantTableId);
    end
    
    if isempty(requantTableIdOld) || requantTableId ~= requantTableIdOld
        [requantEntries meanBlackEntries] = retrieve_requant_table(requantTableId);
        requantTableIdOld = requantTableId;
    end

    meanBlack = double(meanBlackEntries(channelNumber));
return

function configMapReturn = get_config_map(lcDataFile)
% Get config map using config ID from lcDataFile's header:
%

    % Make the most recently used configMapId and the associated config map 
    % persistent to reduce database calls in the tight loop
    % that fits_rc_extractor is called in.
    %
    persistent configMapIdOld configMap;

    configMapIdKeyword = 'SCCONFID';
    configMapId = bart_get_fits_header_value(configMapIdKeyword, lcDataFile);
    if ischar(configMapId)
        configMapId = str2double(configMapId);
    end
    
    if isempty(configMapIdOld) || configMapId ~= configMapIdOld
        configMap = retrieve_config_map_by_id(configMapId);
        configMapIdOld = configMapId;
    end
    
    % Copy the configMap to configMap return so that configMap can be
    % persisted (if configMap in the return specified in the function 
    % definition line, it cannot be persisted)
    %
    configMapReturn = configMap;
return

function [data rows cols] = get_data_and_pmrf_from_files(channelNumber, dataFile, pmrfFile, NUM_CCD_ROWS, NUM_CCD_COLUMNS)
% [data rows cols] = get_data_and_pmrf_from_files(channelNumber, dataFile, pmrfFile, NUM_CCD_ROWS, NUM_CCD_COLUMNS)
%
% Subfunction to extract the data/rows/cols for a given channel from a given
% pair of LC data and PMRF files The return rows and cols vectors are one-based
% (as opposed to the zero-based PMRF files).  The output data is checked to
% ensure each vector is the same length as the other two.  The pixel coordinates
% are validated to be on the CCD.
%
    try 
        lcData = fitsread(dataFile, 'bintable', channelNumber);
    catch
        error('CT:BART:fits_rc_extractor', 'FITSREAD on %s failed', dataFile);
    end

    try
        pmrfData = fitsread(pmrfFile, 'bintable', channelNumber);
    catch
        error('CT:BART:fits_rc_extractor', 'FITSREAD on %s failed', pmrfFile);
    end
     
    % Test for zero-length PMRF/lcData entries for this channel.  If both
    % are zero, this is a legitimate (although empty)  entry.  If only one
    % is zero, the data is inconsistent.
    %
    if isempty(lcData) && isempty(pmrfData) % both RCLC and PMRF outputs are empty
        warning('CT:BART:fits_rc_extractor', ...
            'RCLC data and PMRF data are both empty for channel %d. This may not be an error.  A blank image will be returned.', ...
            channelNumber);
        lcData{1} = [];
        pmrfData{1} = [];
        pmrfData{2} = [];
    elseif isempty(lcData)
        error('CT:BART:fits_rc_extractor', 'RCLC data length is zero, but PMRF is not for channel %d in %s', channelNumber, dataFile);
    elseif isempty(pmrfData)
        error('CT:BART:fits_rc_extractor', 'PMRF data length is zero, but RCLC data is not for channel %d in %s', channelNumber, pmrfFile);
    end

    % Get the pixel values/rows/columns out of the fitsread return structures:
    % Convert the zero-based row/columns coordinates from the PMRF file to matlab one-based coordinates.
    %
    data = lcData{1};
    rows = 1 + pmrfData{1};
    cols = 1 + pmrfData{2};

    % Check for data/row/column size match:
    %
    if length(rows) ~= length(cols)
        error('CT:BART:fits_rc_extractor', 'Row and column coordinates lengths are different from PMRF file.');
    end
    if length(rows) ~= length(data)
        error('CT:BART:fits_rc_extractor', 'data and pixel coordinate lengths are different.');
    end

    % Sanity check to warn the user if rows/cols is different from FcConstants:
    %
    import gov.nasa.kepler.common.FcConstants;
    if NUM_CCD_ROWS ~= FcConstants.CCD_ROWS || NUM_CCD_COLUMNS ~= FcConstants.CCD_COLUMNS
        warn('CT:BART:fits_rc_extractor', 'CCD rows/cols arent the same as FcConstants: rows is %d, cols is %d.', NUM_CCD_ROWS, NUM_CCD_COLUMNS);
    end

    % Check that all pixels are on the CCD:
    %
    if any(rows > NUM_CCD_ROWS| rows < 1)
        errMsg = ['Row coordinates at indices ' num2str(find(rows > NUM_CCD_ROWS | rows < 1)) ' are out of bounds'];
        error('CT:BART:fits_rc_extractor', errMsg);
    end
    if any(cols > NUM_CCD_COLUMNS | cols < 1)
        errMsg = ['Col coordinates at indices ' num2str(find(cols > NUM_CCD_COLUMNS | cols < 1)) ' are out of bounds'];
        error('CT:BART:fits_rc_extractor', errMsg);
    end
return
