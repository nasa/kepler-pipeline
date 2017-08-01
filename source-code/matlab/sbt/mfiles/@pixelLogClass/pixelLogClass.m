function pixelLogObject = pixelLogClass(pixelLogs)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pixelLogObject = pixelLogClass(pixelLogs)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Construct a pixelLogObject from the results of retrieve_pixel_log
%
% Input: 
%   pixelLogs                                           1 x nPixelLogs array of structures describing the pixel logs. 
%                                                       nPixelLogs is the number of pixel logs in the array.
%                                                       The structure contains the following fields:
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
% Output:
%   pixeLogObject                                       An object of the pixel logs.
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
% Validity check on input
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

debugFlag = 1;
if nargin ~= 1
    error('MATLAB:SBT:pixelLogClass:pixelLogClass:wrongNumberOfInputs', 'MATLAB:SBT:pixelLogClass:pixelLogClass: must be called with one input argument.');
end
if ( isempty(pixelLogs) )
    error('MATLAB:SBT:pixelLogClass:pixelLogClass:invalidInput', 'pixelLogs cannot be empty.');
end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Sanity check on fields of each member of pixelLogs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                       
fieldsAndBounds = cell(22,4);
fieldsAndBounds( 1,:) = { 'cadenceNumber';          '>= 0';     '< 1e12';   []};
fieldsAndBounds( 2,:) = { 'cadenceType';            [];         [];         {'SHORT', 'LONG'}};
fieldsAndBounds( 3,:) = { 'dataSetType';         	[];         [];         {'Target', 'Background', 'Collateral'}};
fieldsAndBounds( 4,:) = { 'dispatcherType';         [];         [];         {'LONG_CADENCE_PIXEL', 'SHORT_CADENCE_PIXEL', 'GAP_REPORT', 'CONFIG_MAP', 'REF_PIXEL', ...
                                                                             'LONG_CADENCE_TARGET_PMRF', 'SHORT_CADENCE_TARGET_PMRF', 'BACKGROUND_PRMF', ...
                                                                             'LONG_CADENCE_COLLATERAL_PMRF', 'SHORT_CADENCE_COLLATERAL_PMRF', 'HISTOGRAM', ...
                                                                             'ANCILLARY', 'EPHEMERIS', 'SCLK', 'CRCT', 'FFI', 'HISTORY'}};
fieldsAndBounds( 5,:) = { 'fitsFilename';           [];         [];         []};
fieldsAndBounds( 6,:) = { 'dataSetName';            [];         [];         []};
fieldsAndBounds( 7,:) = { 'mjdStartTime';           '>= 54000'; '<= 64000'; []};
fieldsAndBounds( 8,:) = { 'mjdEndTime';             '>= 54000'; '<= 64000'; []};
fieldsAndBounds( 9,:) = { 'mjdMidTime';             '>= 54000'; '<= 64000'; []};
fieldsAndBounds(10,:) = { 'spacecraftConfigId';     '>= 0';     '< 1e12';   []};
fieldsAndBounds(11,:) = { 'lcTargetTableId';        '>= 0';     '< 1e12';   []};
fieldsAndBounds(12,:) = { 'scTargetTableId';        '>= 0';     '< 1e12';   []};
fieldsAndBounds(13,:) = { 'backTargetTableId';      '>= 0';     '< 1e12';   []};
fieldsAndBounds(14,:) = { 'targetApertureTableId';  '>= 0';     '< 1e12';   []};
fieldsAndBounds(15,:) = { 'backApertureTableId';    '>= 0';     '< 1e12';   []};
fieldsAndBounds(16,:) = { 'compressionTableId';     '>= 0';     '< 1e12';   []};
fieldsAndBounds(17,:) = { 'isDataRequantizedForDownlink';                   [];     [];     '[1 0]'''};
fieldsAndBounds(18,:) = { 'isDataEntropicCompressedForDownlink';            [];     [];     '[1 0]'''};
fieldsAndBounds(19,:) = { 'isDataOriginatedAsBaselineImage';                [];     [];     '[1 0]'''};
fieldsAndBounds(20,:) = { 'isBaselineCreatedFromResidualBaselineImage';     [];     [];     '[1 0]'''};
fieldsAndBounds(21,:) = { 'baselineImageRootname';                          [];     [];     []};
fieldsAndBounds(22,:) = { 'residualBaselineImageRootname';                  [];     [];     []};

% Take sanity check on each member of the array pixelLogs. The invalid members are deleted from the array.
indexInvalidPixelLogs = [];
%     for iPixelLog = 1:length(pixelLogs)
%         try
%             validate_structure(pixelLogs(iPixelLog), fieldsAndBounds, ['MATLAB:SBT:pixelLogClass:pixelLogClass:pixelLogs_' num2str(iPixelLog)]);
%         catch
%             indexInvalidPixelLogs = [indexInvalidPixelLogs iPixelLog];
%             if (debugFlag)
%                 err = lasterror;
%                 error(err.identifier, err.message);
%             end
%         end
%     end
%     pixelLogs(indexInvalidPixelLogs) = [];

    if ( isempty(pixelLogs) || isempty([pixelLogs.cadenceNumber]) )
        warning('Matlab:SBT:pixelLogClass:pixelLogClass:outputStructWithEmptyFields', ...
            'No valid data in pixelLogs. A pixelLogObject with empty fields is provided for output.');
    end

    % Construct a pixelLogObject
pixelLogObject = class(pixelLogs, 'pixelLogClass');

return


