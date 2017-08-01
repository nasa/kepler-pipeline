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
keplerIds = [8413815 8348641 8480304];
startCadence = 0;
endCadence = 500;
tsFlux              = retrieve_ts_sdf('SapRawFluxLong',       keplerIds, startCadence, endCadence);
tsFluxUncertainties = retrieve_ts_sdf('SapRawFluxLongUncert', keplerIds, startCadence, endCadence);
errorbar(find(~tsFlux(1).gapIndicators), tsFlux(1).data(~tsFlux(1).gapIndicators), tsFluxUncertainties(1).data(~tsFluxUncertainties(1).gapIndicators));
keplerIds = [8738591 8480097 8415474];
tsPrfCentRow       = retrieve_ts_sdf('PrfCentroidRows',       keplerIds, startCadence, endCadence);
tsPrfCentRowUncert = retrieve_ts_sdf('PrfCentroidRowsUncert', keplerIds, startCadence, endCadence);
errorbar(find(~tsPrfCentRow(1).gapIndicators), tsPrfCentRow(1).data(~tsPrfCentRow(1).gapIndicators), tsPrfCentRowUncert(1).data(~tsPrfCentRowUncert(1).gapIndicators));
tsPrfCentCol       = retrieve_ts_sdf('PrfCentroidCols',       keplerIds, startCadence, endCadence);
tsPrfCentColUncert = retrieve_ts_sdf('PrfCentroidColsUncert', keplerIds, startCadence, endCadence);
errorbar(find(~tsPrfCentCol(1).gapIndicators), tsPrfCentCol(1).data(~tsPrfCentCol(1).gapIndicators), tsPrfCentColUncert(1).data(~tsPrfCentColUncert(1).gapIndicators));
cols = retrieve_ts_sdf('CentroidCols', keplerIds, startCadence, endCadence);
rows = retrieve_ts_sdf('CentroidRows', keplerIds, startCadence, endCadence);
% plot(rows.data(~rows.gapIndicators), cols.data(~cols.gapIndicators),'x')
keplerIds = [8804455 8148841 8609873];
fwcRows       = retrieve_ts_sdf('FluxWeightedCentroidRows',       keplerIds, startCadence, endCadence);
fwcRowsUncert = retrieve_ts_sdf('FluxWeightedCentroidRowsUncert', keplerIds, startCadence, endCadence);
fwcCols       = retrieve_ts_sdf('FluxWeightedCentroidCols',       keplerIds, startCadence, endCadence);
fwcColsUncert = retrieve_ts_sdf('FluxWeightedCentroidColsUncert', keplerIds, startCadence, endCadence);
row = fwcRows(1).data(~fwcRows(1).gapIndicators);
col = fwcCols(1).data(~fwcRows(1).gapIndicators);
rowe = fwcRowsUncert(1).data(~fwcRowsUncert(1).gapIndicators);
cole = fwcColsUncert(1).data(~fwcRowsUncert(1).gapIndicators);
errorbar(find(~fwcRows(1).gapIndicators), row, rowe)
errorbar(find(~fwcCols(1).gapIndicators), col, cole)
plot(row,col,'x')
keplerIds = [7875476  8218649 8150327];
sapCols       = retrieve_ts_sdf('SapCentroidCols',       keplerIds, startCadence, endCadence);
sapColsUncert = retrieve_ts_sdf('SapCentroidColsUncert', keplerIds, startCadence, endCadence);
sapRows       = retrieve_ts_sdf('SapCentroidRows',       keplerIds, startCadence, endCadence);
sapRowsUncert = retrieve_ts_sdf('SapCentroidRowsUncert', keplerIds, startCadence, endCadence);
errorbar(find(~sapCols(1).gapIndicators), sapCols(1).data(~sapCols(1).gapIndicators), sapColsUncert(1).data(~sapCols(1).gapIndicators));
errorbar(find(~sapRows(1).gapIndicators), sapRows(1).data(~sapRows(1).gapIndicators), sapRowsUncert(1).data(~sapRows(1).gapIndicators));
plot(sapRows(1).data(~sapRows(1).gapIndicators), sapCols(1).data(~sapCols(1).gapIndicators),'x')
startCadence = 0; endCadence = 355;
ccdMod = 7; ccdOut = 3;
disp('');disp('');disp('done with a')
cosmicRayMeanEnergy = retrieve_ts_sdf('PaLcCosmicRayMeanEnergy', ccdMod, ccdOut, startCadence, endCadence);
plot(cosmicRayMeanEnergy.data(~cosmicRayMeanEnergy.gapIndicators),'x-')
ts = retrieve_ts_sdf('CalAchievedCompEfficiency', 7, 3, 0, 360); plot(ts.data);
ts = retrieve_ts_sdf('CalAchievedCompEfficiencyCounts', 7, 3, 0, 360); plot(ts.data);
ts = retrieve_ts_sdf('CalBlackLevel', 7, 3, 0, 360); plot(ts.data);
ts = retrieve_ts_sdf('CalBlackLevelUncert', 7, 3, 0, 360); plot(ts.data);
ts = retrieve_ts_sdf('CalDarkCurrent', 7, 3, 0, 360); plot(ts.data);
ts = retrieve_ts_sdf('CalDarkCurrentUncert', 7, 3, 0, 360); plot(ts.data);
ts = retrieve_ts_sdf('CalSmearLevel', 7, 3, 0, 360); plot(ts.data);
ts = retrieve_ts_sdf('CalSmearLevelUncert', 7, 3, 0, 360); plot(ts.data);
ts = retrieve_ts_sdf('CalTheoreticalCompEff', 7, 3, 0, 360); plot(ts.data);
ts = retrieve_ts_sdf('CalTheoreticalCompEffCounts', 7, 3, 0, 360); plot(ts.data);
ts = retrieve_ts_sdf('PaLcCosmicRayMeanEnergy', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PaBrightness', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PaBrightnessUncert', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PaBgCosmicRayEnergyKurtosis', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PaBgCosmicRayEnergySkewness', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PaBgEnergyVariance', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PaBgHitRate', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PaBgMeanEnergy', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PaLcEnergyKurtosis', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PaLcEnergySkewness', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PaLcEnergyVariance', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PaLcHitRate', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PaLcMeanEnergy', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PaEncircledEnergy', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PaEncircledEnergyUncert', 7, 3, 0, 360); plot(ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('DrCollateralLongVirtualSmear', 7, 3, 37, 0, 400);
ts = retrieve_ts_sdf('DrCollateralLongMaskedSmear', 7, 3, 37, 0, 400);
ts = retrieve_ts_sdf('DrCollateralLongBlack', 7, 3, 37, 0, 400);
disp('');disp('');disp('done with b')
ts = retrieve_ts_sdf('PpaMaxAttitudeFocalPlaneResidual', 0, 400);% plot([ts.mjds.mjdMidTime], ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PpaCovarianceMatrix11', 0, 400);% plot([ts.mjds.mjdMidTime], ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PpaCovarianceMatrix12', 0, 400);% plot([ts.mjds.mjdMidTime], ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PpaCovarianceMatrix13', 0, 400);% plot([ts.mjds.mjdMidTime], ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PpaCovarianceMatrix22', 0, 400);% plot([ts.mjds.mjdMidTime], ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PpaCovarianceMatrix23', 0, 400);% plot([ts.mjds.mjdMidTime], ts.data(~ts.gapIndicators));
ts = retrieve_ts_sdf('PpaCovarianceMatrix33', 0, 400);% plot([ts.mjds.mjdMidTime], ts.data(~ts.gapIndicators));
startCadence = 0;
endCadence = 500;
ts = retrieve_ts_sdf('PdcSapCorrectedFlux',       9283708, startCadence, endCadence);
ts = retrieve_ts_sdf('PdcSapCorrectedFluxUncert', 9283708, startCadence, endCadence);
ts = retrieve_ts_sdf('PdcSapFilledIndices',       9283708, startCadence, endCadence);
disp('');disp('');disp('done with c')
startCadence = 0;
endCadence = 500;
fsIdStrings = {'/pa/targets/Sap/FluxWeighted/CentroidRows/long/8804455', '/pa/targets/Sap/FluxWeighted/CentroidRows/long/8148841'};
isFloat = true;
ts = retrieve_ts_sdf('user_specified_fs_ids', fsIdStrings, isFloat, startCadence, endCadence);
startCadence = 0;
endCadence = 1500;
fsIdStrings = {'/pa/targets/Sap/FluxWeighted/CentroidRows/short', '/pa/targets/Sap/FluxWeighted/CentroidRows/long'};
fsIdType = 'ts';
ts = retrieve_ts_sdf('user_specified_fs_ids', fsIdStrings, isFloat, startCadence, endCadence);
startCadence = 0;
endCadence = 1500;
disp('');disp('');disp('done with d')
barycentricTimeOffsetLong  = retrieve_ts_sdf('PaBarycentricTimeOffsetLong',  1723671, startCadence, endCadence);
barycentricTimeOffsetShort = retrieve_ts_sdf('PaBarycentricTimeOffsetShort', 3425564, startCadence, endCadence);

disp('');disp('');disp('done with e')
fsids = retrieve_ts_sdf('ls', '/pa/targets/Sap/FluxWeighted/CentroidRows/short');

disp('done!')
