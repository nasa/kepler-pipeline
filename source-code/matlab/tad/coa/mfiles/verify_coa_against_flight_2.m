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
if 1
% module 7.1
load /path/to/pipeline_results/quarter1_spring2009_untrimmedTad_v1/coa-matlab-681-8450/coa-inputs-0.mat

coaParameterStruct = inputsStruct;
module = coaParameterStruct.module;
output = coaParameterStruct.output;

coaParameterStruct.raDec2PixModel = retrieve_ra_dec_2_pix_model(); 

channel = convert_from_module_output(module, output);

flightFfiLocation ...
    = '/path/to/flight/commissioning/c032_fpg_ffi/pipeline_results/calFfi/instance-49/kplr2009112151725_ffi-SocCal.fits';

modOutStr = [num2str(module) '_' num2str(output)];

%%
coaParameterStruct.debugFlag = 0;

coaResultStruct = coa_matlab_controller(coaParameterStruct);

completeOutputImage = struct_to_array2D(coaResultStruct.completeOutputImage);
save(['coaImage_test1Prf_' modOutStr '.mat'], 'completeOutputImage');

flightFfi = fitsread(flightFfiLocation, 'Image', channel);

% remove smear
flightMedian = median(median(flightFfi(21:1043,13:1111)));
flightScale = std(std(flightFfi(21:1043,13:1111)));
scaledCoaImage = completeOutputImage - repmat(mean(completeOutputImage(1048:1068,:)), 1070,1);
coaImageMedian = median(median(scaledCoaImage(21:1043,13:1111)));
coaImageScale = std(std(scaledCoaImage(21:1043,13:1111)));
scaledCoaImage = (scaledCoaImage - coaImageMedian)*flightScale/coaImageScale + flightMedian;

differenceImage = flightFfi - scaledCoaImage;

save(['coa_verification_data_m' num2str(module) 'o' num2str(output) '.mat']);

end

if 1
raDec2PixObject = raDec2PixClass(coaParameterStruct.raDec2PixModel, 'one-based');

targetIndex = find(ismember([coaParameterStruct.kicEntryDataStruct.KICID], coaParameterStruct.targetKeplerIDList));
targetKid = [coaParameterStruct.kicEntryDataStruct(targetIndex).KICID];
targetRa = [coaParameterStruct.kicEntryDataStruct(targetIndex).RA];
targetDec = [coaParameterStruct.kicEntryDataStruct(targetIndex).dec];
[m o targetRow targetCol] = ra_dec_2_pix(raDec2PixObject, targetRa*15, targetDec, 54943.63198839);

figure;
clf;
imagesc(flightFfi, [-1e4, 1e6]);
colormap(hot);
hold on;
plot(targetCol, targetRow, 'mx', targetCol, targetRow, 'go');
title('FPG flight FFI');
ax(1) = gca;

figure;
clf;
imagesc(scaledCoaImage, [-1e4, 1e6]);
colormap(hot);
hold on;
plot(targetCol, targetRow, 'mx', targetCol, targetRow, 'go');
title('coa image');
ax(2) = gca;

figure;
clf;
imagesc(differenceImage, [-1e6, 1e6]);
hold on;
plot(targetCol, targetRow, 'mx', targetCol, targetRow, 'ro');
title('flight FFI - coa image');
ax(3) = gca;

linkaxes(ax);
end

load targetImages_m7o1.mat;
tiKic = [targetImages.KICID];
tiRow = [targetImages.aberratedRow];
tiRow = tiRow + 20;
tiRow = tiRow';
targetRow = targetRow(ismember(targetKid, tiKic));
figure;
plot(targetRow, targetRow - tiRow, '+');
title('row from raDec2Pix - row from coa');
ylabel('row difference');
xlabel('row');

tiCol = [targetImages.aberratedColumn];
tiCol = tiCol';
tiCol = tiCol + 12;
targetCol = targetCol(ismember(targetKid, tiKic));
figure;
plot(targetCol, targetCol - tiCol, '+')
title('column from raDec2Pix - column from coa');
ylabel('column difference');
xlabel('column');

dv = [targetCol - tiCol, targetRow - tiRow];
figure;
quiver(targetCol, targetRow, targetCol - tiCol, targetRow - tiRow);
axis tight;
title('difference vectors between raDec2Pix star positions and coa motion polynomial star positions');


