function draw_prf_iteration_results(dataLocation, saveLocation)
% function draw_prf_iteration_results(dataLocation, saveLocation)
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

addpath('/path/to/matlab/ct/fpg/test');

fpgFiles = dir([dataLocation '/fpg-matlab*']);
baseRaDec2PixModel = retrieve_ra_dec_2_pix_model();
lastRaDec2PixObject = raDec2PixClass(baseRaDec2PixModel, 'one-based');
nIterations = length(fpgFiles);

load([dataLocation '/' fpgFiles(1).name '/fpg-inputs-0.mat']);
mjd = inputsStruct.timestampSeries.midTimestamps(1);
    
deltaRow = zeros([nIterations, 4, 42]);
deltaCol = deltaRow;
for i=1:nIterations
    load([dataLocation '/' fpgFiles(i).name '/fpg-outputs-0.mat']);
    load([dataLocation '/' fpgFiles(i).name '/' outputsStruct.geometryBlobFileName]);
    newGeomModel = inputStruct;
    
    mjd = inputsStruct.timestampSeries.midTimestamps(1);
    newRaDec2PixModel = baseRaDec2PixModel;
    
    newRaDec2PixModel.geometryModel.constants = newGeomModel.constants(1);
    newRaDec2PixObject = raDec2PixClass(newRaDec2PixModel, 'one-based');
    
    row = [0.5 1044.5];
    col = [12.5 12.5];
    [dRow, dCol] = compute_geometry_diff_in_pixels(lastRaDec2PixObject, ...
        newRaDec2PixObject, row, col, mjd, 'one-based');
    deltaRow(i,:,:) = reshape(dRow, 4, 42);
    deltaCol(i,:,:) = reshape(dCol, 4, 42);
    
    maxDeltaRow(i) = max(max(abs(deltaRow(i,:,:))));
    maxDeltaCol(i) = max(max(abs(deltaCol(i,:,:))));
    meanDeltaRow(i) = abs(mean(mean(deltaRow(i,:,:))));
    meanDeltaCol(i) = abs(mean(mean(deltaCol(i,:,:))));
    stdDeltaRow(i) = std(std(deltaRow(i,:,:)));
    stdDeltaCol(i) = std(std(deltaCol(i,:,:)));

    lastRaDec2PixObject = newRaDec2PixObject;
end

figure
subplot(1,3,1);
semilogy(1:nIterations, maxDeltaRow, '+-', 1:nIterations, maxDeltaCol, 'o-');
title('maximum abs corner row, column change');
ylabel('pixels');
xlabel('iteration');
legend('row', 'column');
subplot(1,3,2);
semilogy(1:nIterations, meanDeltaRow, '+-', 1:nIterations, meanDeltaCol, 'o-');
title('abs of mean corner row, column change');
ylabel('pixels');
xlabel('iteration');
subplot(1,3,3);
semilogy(1:nIterations, stdDeltaRow, '+-', 1:nIterations, stdDeltaCol, 'o-');
title('standard deviation abs corner row, column change');
ylabel('pixels');
xlabel('iteration');

