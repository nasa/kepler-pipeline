% script to test smoothing
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

module = 22;
output = 1;
channel = convert_from_module_output(module, output);
   
prfFilename = sprintf('/path/to/models/prf/09146_01_sbryson_c039_prf_5prf_delivery/kplr2009042300-%02d%d_prf.bin', module, output);
% prfFilename = sprintf('/path/to/models/prf/09126_01_sbryson_c039_prf_final_delivery/kplr2009042300-%02d%d_prf.bin', module, output);
fid = fopen(prfFilename);
prfBlob = fread(fid, 'uint8');
fclose(fid);
fcConstants = convert_fc_constants_java_2_struct();

prfStruct = blob_to_struct(prfBlob);
if isfield(prfStruct, 'c'); % it's a single prf model
    prfModel.polyStruct = prfStruct;
else
    prfModel = prfStruct;
end
prfObject = prfCollectionClass(prfModel, fcConstants);

prfSize = get(prfObject, 'nPrfArrayRows');

prfObject2 = prfObject;
% turn the smoothing off for prfObject2
prfObject2 = set(prfObject2, 'weightEffectiveZero', 1);

%% do a high resolution evaluation

nPoints = 2000;
slice = fix(nPoints*12/25);
% make cross section of the smoothed PRF in both directions, slightly
% offset from the center
tic;
[smoothedPixColumn sxc] = cross_section(prfObject, 2, 50, 50, slice, nPoints, 1);
[smoothedPixRow sxr] = cross_section(prfObject, 1, 50, 50, slice, nPoints, 1);
toc

% make cross section of the not smoothed PRF in both directions, slightly
% offset from the center
tic;
[notSmoothedPixColumn xc] = cross_section(prfObject2, 2, 50, 50, slice, nPoints, 1);
[notSmoothedPixRow xr] = cross_section(prfObject2, 1, 50, 50, slice, nPoints, 1);
toc
figure;
plot(xr+1, notSmoothedPixRow, sxr+1, smoothedPixRow, '+', xc+1, notSmoothedPixColumn, sxc+1, smoothedPixColumn, 'o');
legend('not smoothed row cross-section', 'smoothed row cross-section', ...
    'not smoothed column cross-section', 'smoothed column cross-section');
    
%% 
% do a high resolution evaluation using the same sub-pixel locations on all the pixels (to test multi-pixel 
% evaluation

nPointsPerPixel = 500;
row = 100;
column = 100;

nValues = nPointsPerPixel*prfSize;
smoothedPixColumn = zeros(nValues, 1);
notSmoothedPixColumn = zeros(nValues, 1);
sxcr = zeros(nValues, 1);
sxcc = zeros(nValues, 1);
sxrr = zeros(nValues, 1);
sxrc = zeros(nValues, 1);
smoothedPixRow = zeros(nValues, 1);
notSmoothedPixRow = zeros(nValues, 1);
for p=1:nPointsPerPixel
	columns = fix(column + (1:prfSize) - prfSize/2);
	rows = row*ones(size(columns));
    % subtract the sub-pixel position so it draws in the reversed sense
	[smoothedPixColumn(p:nPointsPerPixel:p+nValues-1), rr, rc] = ...
		evaluate(prfObject, row+0.2, column - (p-1)/(nPointsPerPixel), rows, columns);
	[notSmoothedPixColumn(p:nPointsPerPixel:p+nValues-1), rr, rc] = ...
		evaluate(prfObject2, row+0.2, column - (p-1)/(nPointsPerPixel), rows, columns);
	sxcr(p:nPointsPerPixel:p+nValues-1) = rr;
	sxcc(p:nPointsPerPixel:p+nValues-1) = rc + (p-1)/(nPointsPerPixel);
	
	rows = fix(row + (1:prfSize) - prfSize/2);
	columns = column*ones(size(rows));
    % subtract the sub-pixel position so it draws in the reversed sense
	[smoothedPixRow(p:nPointsPerPixel:p+nValues-1), rr, rc] = ...
		evaluate(prfObject, row - (p-1)/(nPointsPerPixel), column, rows, columns);
	[notSmoothedPixRow(p:nPointsPerPixel:p+nValues-1), rr, rc] = ...
		evaluate(prfObject2, row - (p-1)/(nPointsPerPixel), column, rows, columns);
	sxrr(p:nPointsPerPixel:p+nValues-1) = rr + (p-1)/(nPointsPerPixel);
	sxrc(p:nPointsPerPixel:p+nValues-1) = rc;
end
figure;
plot(sxrr, notSmoothedPixRow, sxrr, smoothedPixRow, '+', sxcc, notSmoothedPixColumn, sxcc, smoothedPixColumn, 'o');
legend('not smoothed row cross-section', 'smoothed row cross-section', ...
    'not smoothed column cross-section', 'smoothed column cross-section');



