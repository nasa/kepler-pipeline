% load prf-outputs-0.mat
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
dataLocation = '/path/to/pipeline_results/c039_ksop99/kepsnpq_5prfPerModOut/prf-matlab-';
taskMapFile = '/path/to/pipeline_results/c039_ksop99/kepsnpq_5prfPerModOut/prf_mapping_toModOut.csv';
% dataLocation = '/path/to/pipeline_results/c039_ksop99/kepsnpq_5prfPerModOut_TEST_MP_FIXES/prf-matlab-';
% taskMapFile = '/path/to/pipeline_results/c039_ksop99/kepsnpq_5prfPerModOut_TEST_MP_FIXES/prf_mapping_toModOut.csv';
taskMapArray = read_task_map(taskMapFile);

nIterations = size(taskMapArray, 1);

module = 8;
output = 1;

moduleList = [2:4 6:20 22:24];
for m = 1:length(moduleList)
for output = 1:4
module = moduleList(m);
channel = convert_from_module_output(module,output);

iteration = 8;

directoryName = [dataLocation num2str(taskMapArray(iteration,channel).instanceId) ...
    '-' num2str(taskMapArray(iteration,channel).taskId)];
load([directoryName '/prf-outputs-0.mat']);
% load([directoryName '/prfResultData_m' num2str(module) 'o' num2str(output) '.mat']);

% load '/path/to/prf-matlab-45-4292/prfMotion_20090502T064739.mat';
% oldMotionPoly = inputStruct;

load([directoryName filesep outputsStruct.motionPolyBlobFileName]);
%%
inputStruct = inputStruct(1:2:end);

% figure
% plot([outputsStruct.centroids.rows], [outputsStruct.centroids.columns], '+')
% title('centroid locations');

rowPos = linspace(15,1040,5);
colPos = linspace(25,1105,5);
[colMesh, rowMesh] = meshgrid(colPos, rowPos);
colMesh = colMesh(:);
rowMesh = rowMesh(:);

raDec2PixObject = raDec2PixClass(retrieve_ra_dec_2_pix_model(), 'one-based');
module = repmat(inputStruct(1).module, size(rowMesh));
output = repmat(inputStruct(1).output, size(rowMesh));
[raMesh, decMesh] = pix_2_ra_dec(raDec2PixObject, module, ...
    output, rowMesh, colMesh, inputStruct(1).mjdMidTime);
row = zeros(length(rowMesh), length(inputStruct));
col = zeros(length(rowMesh), length(inputStruct));
for i=1:length(inputStruct)
    row(:,i) = weighted_polyval2d(raMesh, decMesh, inputStruct(i).rowPoly);
    col(:,i) = weighted_polyval2d(raMesh, decMesh, inputStruct(i).colPoly);
end
%figure (1);
clf;
% subplot(1,2,1);
hold on;
for i=1:length(inputStruct)
    plot(row - repmat(row(:,1),1,length(inputStruct)), col - repmat(col(:,1),1,length(inputStruct)), 'r+');
end
% for i=1:length(inputStruct)
%     row = weighted_polyval2d(raMesh, decMesh, oldMotionPoly(i).rowPoly);
%     col = weighted_polyval2d(raMesh, decMesh, oldMotionPoly(i).colPoly);
%     plot(row, col, 'go');
% end
hold off;
title(['motion polynomial evaluation, module ' num2str(inputStruct(1).module), ' output ' num2str(inputStruct(1).output)]);
axis([-1    1   -1    1]);
%%
% subplot(1,2,2);
% hold on;
% for i=1:length(inputStruct)
%     row = weighted_polyval2d(raMesh, decMesh, inputStruct(i).rowPoly);
%     col = weighted_polyval2d(raMesh, decMesh, inputStruct(i).colPoly);
%     plot(row, col, '+');
% end
% hold off;
% title(['motion polynomial evaluation, module ' num2str(inputStruct(1).module), ' output ' num2str(inputStruct(1).output)]);
% axis([14   16  293  297]);
% pause;

saveas(gcf, ['/path/to/motionPolyFigs/motion_polys_m' num2str(module(1)) 'o' num2str(output(1)) '.fig']);
end
end
