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
clear;

load /path/to/prf/prf_m16o1.mat;
prfObject = prfClass(prfPolyStruct);

% centroid_type = 'prf';
% centroid_type = 'gaussian-marginal';
% centroid_type = '2D-gaussian';
% centroid_type = 'flux-weighted';
centroid_type = 'best';

pixStruct = get_pixel_time_series('output/run_long_m16o1s1');
load output/run_long_m16o1s1/scienceTargetList.mat;
load output/run_long_m16o1s1/tadInputStruct.mat;
maskDefs = tadInputStruct.maskDefinitions;

nTargets = length(pixStruct);

raDec2PixObject = raDec2PixClass(retrieve_ra_dec_2_pix_model(), 'one-based');

[m o projectedRow projectedCol] = ra_dec_2_pix(raDec2PixObject, ...
    [targetList.ra], ...
    [targetList.dec], ...
    datestr2mjd('24-Jun-2010 12:00:00.000'));
    
cadence = 1;
h = waitbar(0, 'computing centroids');

startTime = clock;
for t = 1:nTargets
    tStruct = pixStruct(t);
	mask = maskDefs(tStruct.maskIndex);
    starCentroidStruct.row = tStruct.referenceRow + 1 + [mask.offsets.row];
    starCentroidStruct.row = starCentroidStruct.row(:);
    starCentroidStruct.column = tStruct.referenceColumn + 1 + [mask.offsets.column];
    starCentroidStruct.column = starCentroidStruct.column(:);
    starCentroidStruct.values = tStruct.pixelValues(cadence, :)';
    starCentroidStruct.uncertainties = ones(size(starCentroidStruct.values));
    starCentroidStruct.gapIndicators = zeros(size(starCentroidStruct.values));
    starCentroidStruct.inOptimalAperture = ones(size(starCentroidStruct.values));
	starCentroidStruct.seedRow = [];
	starCentroidStruct.seedColumn = [];
    
    [centroidRow, ...
        centroidColumn, ...
        status, ...
        centroidCovariance, ...
        transformationStruct] ...
        = compute_starDataStruct_centroid(starCentroidStruct, prfObject, [], centroid_type);

    rowError(t) = centroidRow - projectedRow(t, cadence);
    colError(t) = centroidColumn - projectedCol(t, cadence);
    centroidStatus(t) = status;
%     keyboard
    clear starCentroidStruct;
    waitbar(t/nTargets, h, ['computed centroid for target ' ...
        num2str(t) ' of ' num2str(nTargets)]);
end
elapsedTime = etime(clock, startTime);
close(h);
disp([centroid_type ' centroiding, took ' num2str(elapsedTime) ...
    ' seconds or ' num2str(elapsedTime/nTargets) ...
    ' seconds per centroid']);
v = [rowError; colError];
for i=1:size(v, 2)
    normError(i) = norm(v(:,i));
end
