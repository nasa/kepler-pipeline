% script to test 2D black
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

location = 'output/run_long_m12o1s1';
load([location filesep 'inputStructs.mat']);
blackCols = runParamsData.keplerData.blackCoAddCols;
module = runParamsData.simulationData.moduleNumber;
output = runParamsData.simulationData.outputNumber;
runStartMjd = datestr2mjd(runParamsData.simulationData.runStartDate);

% load black 
blackObject = twoDBlackClass(retrieve_two_d_black_model(module, output));
twoDBlack = get_two_d_black(blackObject, runStartMjd);
% simulate co-added black
numExposuresPerCadence = runParamsData.keplerData.exposuresPerShortCadence ...
    * runParamsData.keplerData.shortsPerLongCadence;
blackColValues = twoDBlack(:,blackCols);
coAddedBlack = sum(blackColValues, 2) * numExposuresPerCadence;

% load black from ETEM
quantizedBlackVals = get_pixel_time_series(location, 'black', 1);
unquantizedBlackVals = get_pixel_time_series(location, 'black', 0);

% load the FFI for this run
load([location filesep 'ccdImage.mat']);
ffiBlack = ccdImage(:,blackCols);
coAddedFfiBlack = sum(ffiBlack, 2);

% get the science data
load([location filesep 'ccdObject.mat']);
poiStruct = get(ccdObject, 'poiStruct');
numPixInCadence = length(poiStruct.poiRow);
trailingBlackStruct = get(ccdObject, 'trailingBlackStruct');
tf = ismember(poiStruct.poiPixelIndex, trailingBlackStruct.poiPixelIndex);
trailingBlackIndex = find(tf);

fid = fopen([location filesep 'ccdTimeSeries.dat'], 'r', 'ieee-be');
cadenceData = fread(fid, numPixInCadence, 'float32');
fclose(fid);
cadenceBlackData = cadenceData(trailingBlackIndex(1:(20*1070)));
cadenceBlack = reshape(cadenceBlackData, [1070, 20]);
cadenceBlackCols = cadenceBlack(:,blackCols - 1113);
coAddedCadenceBlack = sum(cadenceBlackCols, 2);

figure;
subplot(1, 3, 1);
plot([coAddedBlack, unquantizedBlackVals(1,:)', quantizedBlackVals(1,:)', coAddedFfiBlack]);
legend('from black model', 'unquantized cadence data', 'quantized cadence data', 'from ffi');
subplot(1, 3, 2);
plot(unquantizedBlackVals(1,:)'./coAddedBlack);
title('ratio of unquantized cadence dat to black model');
subplot(1, 3, 3);
plot(unquantizedBlackVals(1,:)'./coAddedFfiBlack);
title('ratio of ffi dat to black model');

