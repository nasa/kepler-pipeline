function coaParameterStruct = setup_valid_coa_test_struct(coaObj)
% construct a valid input structure for coaClass
% some sample stars
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
KIDData = [11167574    11477463    11539918    11475719    11479000]; 
RAData = [19.3802   19.3430   19.2699   19.2957   19.3814]; 
decData = [46.4108   46.9803   47.0866   46.9906   46.9784];
magData = [11.9580   12.8250   10.1160   10.7480   12.6630];

kicEntryDataStruct = struct('KICID', num2cell(KIDData), ...
    'RA', num2cell(RAData), 'dec', num2cell(decData),...
    'magnitude', num2cell(magData));
targetKeplerIDList = [11167574 11539918];

import gov.nasa.kepler.common.FcConstants;

% A/D converter information
% num_bits                     = 14;                               % 14 bit A/D converter - immutable
% well_capac                   = 1.30E+06;                         % e- (1.3 million electrons full well) 

% % timeframe allowed for short and long cadence 
% short_cadence_timeframe      = 60;                                % seconds
% long_cadence_timeframe       = 30*60;                             % seconds
% 
% % COMPUTED VALUES
% exp_per_long_cadence         = round(long_cadence_timeframe / (int_time + xfer_time)); % exposures / long; 
% long_cadence_duration        = exp_per_long_cadence*(int_time + xfer_time); % seconds

pixelModelStruct.wellCapacity = 1.30E+06;
pixelModelStruct.saturationSpillUpFraction = 0.50;
pixelModelStruct.flux12 = 2.34E+05;
pixelModelStruct.cadenceTime = 1.7997e+03;
pixelModelStruct.integrationTime = 5.70845;
pixelModelStruct.transferTime = FcConstants.ccdReadTime;
pixelModelStruct.exposuresPerCadence = 289;
pixelModelStruct.parallelCTE = 0.9996;
pixelModelStruct.serialCTE = 0.9996;
% pixelModelStruct.readNoiseSquared = 25 * 25 * exp_per_long_cadence; % e-^2/long cadence
% pixelModelStruct.quantizationNoiseSquared = ... % e-^2/long cadence
%     ( well_capac / (2^num_bits-1))^2 / 12 * exp_per_long_cadence;
pixelModelStruct.readNoiseSquared = 180625; % e-^2/long cadence
pixelModelStruct.quantizationNoiseSquared = 1.5164e+05; % e-^2/long cadence

coaConfigurationStruct.dvaMeshEdgeBuffer = -1; % how close to the edge of a CCD we compute the dva
coaConfigurationStruct.dvaMeshOrder = 5; % order of the polynomial fit to dva mesh
coaConfigurationStruct.nDvaMeshRows = 5; % size of the mesh on which to compute DVA
coaConfigurationStruct.nDvaMeshCols = 5; % size of the mesh on which to compute DVA
coaConfigurationStruct.nOutputBufferPix = 2; % # of pixels to allow off visible ccd
coaConfigurationStruct.nStarImageRows = 21; % rows in each star image
coaConfigurationStruct.nStarImageCols = 21; % columns in each star image
coaConfigurationStruct.starChunkLength = 5000; % rows in each star image
coaConfigurationStruct.raOffset = 0;
coaConfigurationStruct.decOffset = 0;
coaConfigurationStruct.phiOffset = 0;

coaParameterStruct.kicEntryDataStruct = kicEntryDataStruct;
coaParameterStruct.targetKeplerIDList = targetKeplerIDList;
coaParameterStruct.pixelModelStruct = pixelModelStruct;
coaParameterStruct.coaConfigurationStruct = coaConfigurationStruct;
coaParameterStruct.startTime = '01-Dec-2008';
coaParameterStruct.duration = 1;
coaParameterStruct.module = 18;
coaParameterStruct.output = 1;

coaParameterStruct.debugFlag = 0;

coaParameterStruct.moduleDescriptionStruct.nRowPix = FcConstants.nRowsImaging;
coaParameterStruct.moduleDescriptionStruct.nColPix = FcConstants.nColsImaging;
coaParameterStruct.moduleDescriptionStruct.leadingBlack = FcConstants.nLeadingBlack;
coaParameterStruct.moduleDescriptionStruct.trailingBlack = FcConstants.nTrailingBlack;
coaParameterStruct.moduleDescriptionStruct.virtualSmear = FcConstants.nVirtualSmear;
coaParameterStruct.moduleDescriptionStruct.maskedSmear = FcConstants.nMaskedSmear;

fid = fopen('/path/to/matlab/tad/coa/prfBlob_z1f1_4.dat');
coaParameterStruct.prfStruct = blob_to_struct(fread(fid, 'uint8'));



