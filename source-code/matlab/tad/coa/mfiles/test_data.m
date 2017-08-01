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
close all;
clear;
clear classes;

fid = fopen('fakeTadQuery.output');
KicData = fscanf(fid, '%f %f %f %f', [4,inf]);
fclose(fid);
nStars = size(KicData, 2);
testModule = 2; % module and output for which the above data was computed
testOutput = 1;
duration = 93; % days
% range = fix(nStars*rand(2000,1))+1;
range = 1:nStars;

debug = 1;

KICEntryDataStruct = struct('KICID', num2cell(KicData(1,range)), ...
    'RA', num2cell(KicData(2,range)), 'dec', num2cell(KicData(3,range)),...
    'magnitude', num2cell(KicData(4,range)));

% pick the brightest 2000 stars as targets
targetIndex = find(([KICEntryDataStruct.magnitude] < 15) & ...
    ([KICEntryDataStruct.magnitude] >= 9));
targetKeplerIDList = [KICEntryDataStruct(targetIndex).KICID];

% A/D converter information
ADC_guard_band_fraction_low  = 0.05;                             % 5% guard band on low end of A/D converter
ADC_guard_band_fraction_high = 0.05;                             % 5% guard band on high end of A/D converter
num_bits                     = 14;                               % 14 bit A/D converter
well_capac                   = 1.30E+06;                         % e- (1.3 million electrons full well)
electrons_per_ADU            = ((1.00 * well_capac) / 2^num_bits) / ...                          % Corrected for guard bands...
                               (1 - ADC_guard_band_fraction_low - ADC_guard_band_fraction_high); % was ~80 e- / bit
% Charge spilling
sat_spill_up_fraction        = 0.50;                             % Fraction of charge to go toward row 1.

% Quantization noise ratio
quant_fraction               = 1/4;                              % ratio of quantization noise to total noise (see makequanttble.m)

% Integration time; read time
int_time                     = 5.70845;                          % Integration time from CDPP Spreadsheet, version 5/23/06
xfer_time                    = 0.51895;                          % Read time from CDPP Spreadsheet, version 5/23/06
% timeframe allowed for short and long cadence 
short_cadence_timeframe      = 60;                                % seconds
long_cadence_timeframe       = 30*60;                             % seconds

% COMPUTED VALUES
exp_per_short_cadence        = round(short_cadence_timeframe / (int_time + xfer_time)); % exposures / short; 
short_cadence_duration       = exp_per_short_cadence*(int_time + xfer_time); % seconds
exp_per_long_cadence         = round(long_cadence_timeframe / (int_time + xfer_time)); % exposures / long; 
long_cadence_duration        = exp_per_long_cadence*(int_time + xfer_time); % seconds
shorts_per_long              = exp_per_long_cadence/exp_per_short_cadence;

pixelModelStruct.wellCapacity = well_capac;
pixelModelStruct.saturationSpillUpFraction = sat_spill_up_fraction;
pixelModelStruct.flux12 = 2.34E+05;
pixelModelStruct.longCadenceTime = long_cadence_duration;
pixelModelStruct.integrationTime = int_time;
pixelModelStruct.transferTime = xfer_time;
pixelModelStruct.exposuresPerLongCadence = exp_per_long_cadence;
pixelModelStruct.parallelCTE = 0.9996;
pixelModelStruct.serialCTE = 0.9996;
pixelModelStruct.readNoiseSquared = 25 * 25 * exp_per_long_cadence; % e-^2/long cadence
pixelModelStruct.quantizationNoiseSquared = ... % e-^2/long cadence
    ( well_capac / (2^num_bits-1))^2 / 12 * exp_per_long_cadence;


moduleDescriptionStruct.module = testModule;
moduleDescriptionStruct.output = testOutput;
moduleDescriptionStruct.nRowPix = 1024; % to be consistent w/ ra_dec_2_pix
moduleDescriptionStruct.nColPix = 1100;
moduleDescriptionStruct.leadingBlack = 12;
moduleDescriptionStruct.trailingBlack = 20;
moduleDescriptionStruct.virtualSmear = 26;
moduleDescriptionStruct.maskedSmear = 20;

coaParameterStruct.KICEntryDataStruct = KICEntryDataStruct;
coaParameterStruct.startTime = datestr2mjd('01-Dec-2008');
coaParameterStruct.pixelModelStruct = pixelModelStruct;
coaParameterStruct.moduleDescriptionStruct = moduleDescriptionStruct;
coaParameterStruct.targetKeplerIDList = targetKeplerIDList;
coaParameterStruct.duration = duration;

coaParameterStruct.debug = debug;

coaParameterStruct
pixelModelStruct
moduleDescriptionStruct


