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
load /path/to/prf_uncertainty/prfData/prf-outputs-0.mat
load(['/path/to/prf_uncertainty/prfData/' outputsStruct.prfCollectionBlobFileName]);

fcConstants = convert_fc_constants_java_2_struct();

% load C:\path\to\test_data\prf\prf_uncertainty\prf-outputs-0.mat
% load(['C:\path\to\test_data\prf\prf_uncertainty\' outputsStruct.prfCollectionBlobFileName]);
% 
% load C:\path\to\test_data\fpg\fcConstants 

% here we evaluate a prf collection class
prfObject = prfCollectionClass(inputStruct, fcConstants);
pix = evaluate(prfObject, 100.0, 300.0);
figure;
imagesc(reshape(pix, 11, 11));
title('evaluation of interpolated PRF');

%%
% to evaluate with uncertainties, we need to interpolate the prf collection
% to a single prf, then evaluate on the single prf.
interpolatedPrfObject = get_interpolated_prf(prfObject, 100.2, 300.4, 1);
[pix, rowArray, colArray, uncertainties] = evaluate(interpolatedPrfObject, 100.2, 300.4);
figure;
subplot(1,2,1);
mesh(reshape(pix, 11, 11)/sum(pix));
title('evaluation of interpolated PRF');
subplot(1,2,2);
mesh(reshape(uncertainties, 11, 11));
title('uncertainties of interpolated PRF');

%%
% same for single PRF
%fid = fopen('/path/to/prf_uncertainty/prfData/kplr2008102115-112_prf.bin');
%singlePrfObject = prfClass(blob_to_struct(fread(fid, 'uint8')));
singlePrfObject = get(prfObject,'prfCenterObject') ;
if (~isa(singlePrfObject,'prfClass'))
   error('singlePrfObject is not of class prfClass') ;
end
[pix, rowArray, colArray, uncertainties] = evaluate(singlePrfObject, 100.2, 300.4);
figure;
subplot(1,2,1);
mesh(reshape(pix, 11, 11)/sum(pix));
title('evaluation of single PRF');
subplot(1,2,2);
mesh(reshape(uncertainties, 11, 11));
title('uncertainties of single PRF');

