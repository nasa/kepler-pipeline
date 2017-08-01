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
clear
load /path/to/prf/single/fpg-matlab-68-12371/fpg-inputs-0.mat
fpgIn1 = inputsStruct;
load /path/to/prf/single/fpg-matlab-68-12371/fpg-outputs-0.mat
fpgOut1 = outputsStruct;
load /path/to/prf/single/prf-matlab-69-12475/prf-inputs-0.mat
prfm7o4In1 = inputsStruct;
load /path/to/prf/single/prf-matlab-69-12475/prf-outputs-0.mat
prfm7o4Out1 = outputsStruct;
load /path/to/prf/single/prf-matlab-69-12527/prf-inputs-0.mat
prfm20o4In1 = inputsStruct;
load /path/to/prf/single/prf-matlab-69-12527/prf-outputs-0.mat
prfm20o4Out1 = outputsStruct;

load /path/to/prf/single/fpg-matlab-69-12540/fpg-inputs-0.mat
fpgIn2 = inputsStruct;
load /path/to/prf/single/fpg-matlab-69-12540/fpg-outputs-0.mat
fpgOut2 = outputsStruct;
load /path/to/prf/single/prf-matlab-69-12560/prf-inputs-0.mat
prfm7o4In2 = inputsStruct;
load /path/to/prf/single/prf-matlab-69-12560/prf-outputs-0.mat
prfm7o4Out2 = outputsStruct;
load /path/to/prf/single/prf-matlab-69-12612/prf-inputs-0.mat
prfm20o4In2 = inputsStruct;
load /path/to/prf/single/prf-matlab-69-12612/prf-outputs-0.mat
prfm20o4Out2 = outputsStruct;

m7o4Channel = convert_from_module_output(7,4);
m20o4Channel = convert_from_module_output(20,4);

ao = fpgOut1.spacecraftAttitudeStruct;
ai = prfm7o4In1.spacecraftAttitudeStruct;

disp('module 7 output 4');
disp('iteration 1 PRF inputs:');
disp(['attitude ra values: ' num2str(isequal(ao.ra.values(1:2:end), ai.ra.values(1:2:end)))]);
disp(['attitude ra uncertainties: ' num2str(isequal(ao.ra.uncertainties(1:2:end), ai.ra.uncertainties(1:2:end)))]);
disp(['attitude ra gapIndices: ' num2str(isequal(ao.ra.gapIndices(1:2:end), ai.ra.gapIndices(1:2:end)))]);

disp(['attitude dec values: ' num2str(isequal(ao.dec.values(1:2:end), ai.dec.values(1:2:end)))]);
disp(['attitude dec uncertainties: ' num2str(isequal(ao.dec.uncertainties(1:2:end), ai.dec.uncertainties(1:2:end)))]);
disp(['attitude dec gapIndices: ' num2str(isequal(ao.dec.gapIndices(1:2:end), ai.dec.gapIndices(1:2:end)))]);

disp(['attitude roll values: ' num2str(isequal(ao.roll.values(1:2:end), ai.roll.values(1:2:end)))]);
disp(['attitude roll uncertainties: ' num2str(isequal(ao.roll.uncertainties(1:2:end), ai.roll.uncertainties(1:2:end)))]);
disp(['attitude roll gapIndices: ' num2str(isequal(ao.roll.gapIndices(1:2:end), ai.roll.gapIndices(1:2:end)))]);

load(['/path/to/prf/single/fpg-matlab-68-12371/' fpgOut1.geometryBlobFileName]);
fpgGeom1 = inputStruct;
load(['/path/to/prf/single/prf-matlab-69-12475/' prfm7o4In1.fpgGeometryBlobsStruct.blobFilenames{1}]);
prfm7o4Geom1 = inputStruct;
disp(['geom structure: ', num2str(isequal(fpgGeom1, prfm7o4Geom1))]);

disp('');
disp('iteration 2 FPG inputs:');
load(['/path/to/prf/single/prf-matlab-69-12475/' prfm7o4Out1.motionPolyBlobFileName]);
prfm7o4MotionOut1 = inputStruct;
load(['/path/to/prf/single/fpg-matlab-69-12540/' fpgIn2.motionBlobsStruct(m7o4Channel).blobFilenames{1}]);
fpgMotionIn2 = inputStruct;
disp(['motion structure: ', num2str(isequal(prfm7o4MotionOut1, fpgMotionIn2))]);

load(['/path/to/prf/single/fpg-matlab-69-12540/' fpgIn2.geometryBlobFileName]);
fpgGeomIn2 = inputStruct;
disp(['geometry structure: ', num2str(isequal(fpgGeom1, fpgGeomIn2))]);

ao = fpgOut2.spacecraftAttitudeStruct;
ai = prfm7o4In2.spacecraftAttitudeStruct;
disp('');
disp('iteration 2 PRF inputs:');
disp(['attitude ra values: ' num2str(isequal(ao.ra.values(1:2:end), ai.ra.values(1:2:end)))]);
disp(['attitude ra uncertainties: ' num2str(isequal(ao.ra.uncertainties(1:2:end), ai.ra.uncertainties(1:2:end)))]);
disp(['attitude ra gapIndices: ' num2str(isequal(ao.ra.gapIndices(1:2:end), ai.ra.gapIndices(1:2:end)))]);

disp(['attitude dec values: ' num2str(isequal(ao.dec.values(1:2:end), ai.dec.values(1:2:end)))]);
disp(['attitude dec uncertainties: ' num2str(isequal(ao.dec.uncertainties(1:2:end), ai.dec.uncertainties(1:2:end)))]);
disp(['attitude dec gapIndices: ' num2str(isequal(ao.dec.gapIndices(1:2:end), ai.dec.gapIndices(1:2:end)))]);

disp(['attitude roll values: ' num2str(isequal(ao.roll.values(1:2:end), ai.roll.values(1:2:end)))]);
disp(['attitude roll uncertainties: ' num2str(isequal(ao.roll.uncertainties(1:2:end), ai.roll.uncertainties(1:2:end)))]);
disp(['attitude roll gapIndices: ' num2str(isequal(ao.roll.gapIndices(1:2:end), ai.roll.gapIndices(1:2:end)))]);

load(['/path/to/prf/single/fpg-matlab-69-12540/' fpgOut2.geometryBlobFileName]);
fpgGeom2 = inputStruct;
load(['/path/to/prf/single/prf-matlab-69-12560/' prfm7o4In2.fpgGeometryBlobsStruct.blobFilenames{1}]);
prfm7o4Geom2 = inputStruct;
disp(['geom structure: ', num2str(isequal(fpgGeom2, prfm7o4Geom2))]);

nBadCentroids = 0;
nGoodCentroids = 0;
for i=1:length(prfm7o4Out1.centroids)
	if ~isequal(prfm7o4Out1.centroids(i), prfm7o4In2.previousCentroids(i))
		disp(['centroid for target ' num2str(i) ' not equal']);
		nBadCentroids = nBadCentroids + 1;
	elseif all(prfm7o4Out1.centroids(i).rows ~= 0)
		nGoodCentroids = nGoodCentroids + 1;
	end
end
disp(['there were ' num2str(nBadCentroids) ' bad centroids, ' num2str(nGoodCentroids) ' good centroids']);

disp('module 20 output 4');
disp('iteration 1 PRF inputs:');
ao = fpgOut2.spacecraftAttitudeStruct;
ai = prfm20o4In2.spacecraftAttitudeStruct;
disp(['attitude ra values: ' num2str(isequal(ao.ra.values(1:2:end), ai.ra.values(1:2:end)))]);
disp(['attitude ra uncertainties: ' num2str(isequal(ao.ra.uncertainties(1:2:end), ai.ra.uncertainties(1:2:end)))]);
disp(['attitude ra gapIndices: ' num2str(isequal(ao.ra.gapIndices(1:2:end), ai.ra.gapIndices(1:2:end)))]);

disp(['attitude dec values: ' num2str(isequal(ao.dec.values(1:2:end), ai.dec.values(1:2:end)))]);
disp(['attitude dec uncertainties: ' num2str(isequal(ao.dec.uncertainties(1:2:end), ai.dec.uncertainties(1:2:end)))]);
disp(['attitude dec gapIndices: ' num2str(isequal(ao.dec.gapIndices(1:2:end), ai.dec.gapIndices(1:2:end)))]);

disp(['attitude roll values: ' num2str(isequal(ao.roll.values(1:2:end), ai.roll.values(1:2:end)))]);
disp(['attitude roll uncertainties: ' num2str(isequal(ao.roll.uncertainties(1:2:end), ai.roll.uncertainties(1:2:end)))]);
disp(['attitude roll gapIndices: ' num2str(isequal(ao.roll.gapIndices(1:2:end), ai.roll.gapIndices(1:2:end)))]);

load(['/path/to/prf/single/fpg-matlab-68-12371/' fpgOut1.geometryBlobFileName]);
fpgGeom1 = inputStruct;
load(['/path/to/prf/single/prf-matlab-69-12527/' prfm20o4In1.fpgGeometryBlobsStruct.blobFilenames{1}]);
prfm20o4Geom1 = inputStruct;
disp(['geom structure: ', num2str(isequal(fpgGeom1, prfm20o4Geom1))]);

disp('');
disp('iteration 2 FPG inputs:');
load(['/path/to/prf/single/prf-matlab-69-12527/' prfm20o4Out1.motionPolyBlobFileName]);
prfm20o4MotionOut1 = inputStruct;
load(['/path/to/prf/single/fpg-matlab-69-12540/' fpgIn2.motionBlobsStruct(m20o4Channel).blobFilenames{1}]);
fpgMotionIn2 = inputStruct;
disp(['motion structure: ', num2str(isequal(prfm20o4MotionOut1, fpgMotionIn2))]);

load(['/path/to/prf/single/fpg-matlab-69-12540/' fpgIn2.geometryBlobFileName]);
fpgGeomIn2 = inputStruct;
disp(['geometry structure: ', num2str(isequal(fpgGeom1, fpgGeomIn2))]);

ao = fpgOut2.spacecraftAttitudeStruct;
ai = prfm20o4In2.spacecraftAttitudeStruct;
disp('');
disp('iteration 2 PRF inputs:');
disp(['attitude ra values: ' num2str(isequal(ao.ra.values(1:2:end), ai.ra.values(1:2:end)))]);
disp(['attitude ra uncertainties: ' num2str(isequal(ao.ra.uncertainties(1:2:end), ai.ra.uncertainties(1:2:end)))]);
disp(['attitude ra gapIndices: ' num2str(isequal(ao.ra.gapIndices(1:2:end), ai.ra.gapIndices(1:2:end)))]);

disp(['attitude dec values: ' num2str(isequal(ao.dec.values(1:2:end), ai.dec.values(1:2:end)))]);
disp(['attitude dec uncertainties: ' num2str(isequal(ao.dec.uncertainties(1:2:end), ai.dec.uncertainties(1:2:end)))]);
disp(['attitude dec gapIndices: ' num2str(isequal(ao.dec.gapIndices(1:2:end), ai.dec.gapIndices(1:2:end)))]);

disp(['attitude roll values: ' num2str(isequal(ao.roll.values(1:2:end), ai.roll.values(1:2:end)))]);
disp(['attitude roll uncertainties: ' num2str(isequal(ao.roll.uncertainties(1:2:end), ai.roll.uncertainties(1:2:end)))]);
disp(['attitude roll gapIndices: ' num2str(isequal(ao.roll.gapIndices(1:2:end), ai.roll.gapIndices(1:2:end)))]);

load(['/path/to/prf/single/fpg-matlab-69-12540/' fpgOut2.geometryBlobFileName]);
fpgGeom2 = inputStruct;
load(['/path/to/prf/single/prf-matlab-69-12612/' prfm20o4In2.fpgGeometryBlobsStruct.blobFilenames{1}]);
prfm20o4Geom2 = inputStruct;
disp(['geom structure: ', num2str(isequal(fpgGeom2, prfm20o4Geom2))]);

nBadCentroids = 0;
nGoodCentroids = 0;
for i=1:length(prfm20o4Out1.centroids)
	if ~isequal(prfm20o4Out1.centroids(i), prfm20o4In2.previousCentroids(i))
		disp(['centroid for target ' num2str(i) ' not equal']);
		nBadCentroids = nBadCentroids + 1;
	elseif all(prfm20o4Out1.centroids(i).rows ~= 0)
		nGoodCentroids = nGoodCentroids + 1;
	end
end
disp(['there were ' num2str(nBadCentroids) ' bad centroids, ' num2str(nGoodCentroids) ' good centroids']);

