% script to analyze prf noise test results
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

% [prfSourceData prfRbData prfRbFastData, baselineData] = noise_test_analysis()
if ~exist('baselineData', 'var')
	load noiseStudy/prf_noise_data.mat
end

x = 1:5;

figure;
plot(x, [prfSourceData.component.normDiff], 'x-', ...
	x, [prfFastRbData.component.normDiff], '+-', ...
	x, [prfRbData.component.normDiff], 'o-');
title('RSS norm of the differences of multi-prf from single-prf baseline');
xlabel('prf component');
ylabel('norm difference / max(baseline prf)');
legend('baseline', 'slow rolling band', 'fast rolling band');

figure;
plot(x, [prfSourceData.component.maxDiff], 'x-', ...
	x, [prfFastRbData.component.maxDiff], '+-', ...
	x, [prfRbData.component.maxDiff], 'o-');
title('max of the differences of multi-prf from single-prf baseline');
xlabel('prf component');
ylabel('max difference / max(baseline prf)');
legend('baseline', 'slow rolling band', 'fast rolling band');

rbXtVariation = ([prfRbData.component.maxDiff] ...
	- [prfSourceData.component.maxDiff])./[prfSourceData.component.maxDiff];
fastRbXtVariation = ([prfFastRbData.component.maxDiff] ...
	- [prfSourceData.component.maxDiff])./[prfSourceData.component.maxDiff];
figure;
plot(x, rbXtVariation, '+-', x, fastRbXtVariation, 'o-');
title('Variation in the max of the differences of multi-prf from multi-prf baseline');
xlabel('prf component');
ylabel('variation of max difference / max(baseline prf)');
legend('slow rolling band', 'fast rolling band');

rbXtVariation = ([prfRbData.component.maxDiff] ...
	- [prfSourceData.component.maxDiff]);
fastRbXtVariation = ([prfFastRbData.component.maxDiff] ...
	- [prfSourceData.component.maxDiff]);
figure;
plot(x, rbXtVariation, '+-', x, fastRbXtVariation, 'o-');
% title('Variation in the max of the differences of multi-prf from multi-prf baseline');
xlabel('prf component');
ylabel('variation of max difference');
legend('slow rolling band', 'fast rolling band');

normRbXtVariation = ([prfRbData.component.normDiff] ...
	- [prfSourceData.component.normDiff])./[prfSourceData.component.normDiff];
fastRbXtVariation = ([prfFastRbData.component.normDiff] ...
	- [prfSourceData.component.normDiff])./[prfSourceData.component.normDiff];
figure;
plot(x, rbXtVariation, '+-', x, fastRbXtVariation, 'o-');
title('Variation in the norm of the differences of multi-prf from multi-prf baseline');
xlabel('prf component');
ylabel('variation of norm difference / norm(baseline prf)');
legend('slow rolling band', 'fast rolling band');

rbXtVariation = ([prfRbData.component.normDiff] ...
	- [prfSourceData.component.normDiff]);
fastRbXtVariation = ([prfFastRbData.component.normDiff] ...
	- [prfSourceData.component.normDiff]);
figure;
plot(x, rbXtVariation, '+-', x, fastRbXtVariation, 'o-');
title('Variation in the norm of the differences of multi-prf from multi-prf baseline');
xlabel('prf component');
ylabel('variation of norm difference');
legend('slow rolling band', 'fast rolling band');

%% compute centroids 
[r,c] = quick_centroid(prfSourceData.prfArray);
disp(['single PRF source centroid: ' num2str([r,c])]);
[r,c] = quick_centroid(prfRbData.prfArray);
disp(['single PRF slow RB centroid: ' num2str([r,c])]);
[r,c] = quick_centroid(prfFastRbData.prfArray);
disp(['single PRF fast RB centroid: ' num2str([r,c])]);

pixScale = 11/200;
for i=1:5
    [r0,c0] = quick_centroid(prfSourceData.component(i).prfArray);
    disp(['component ' num2str(i) ' PRF source centroid: ' num2str([r*pixScale,c*pixScale])]);
    [r,c] = quick_centroid(prfRbData.component(i).prfArray);
    disp(['component ' num2str(i) ' PRF slow RB centroid: ' num2str([r*pixScale,c*pixScale])]);
	disp(['error: ' num2str(sqrt((r-r0)^2 + (c-c0)^2)*pixScale)]);
    [r,c] = quick_centroid(prfFastRbData.component(i).prfArray);
    disp(['component ' num2str(i) ' PRF fast RB centroid: ' num2str([r*pixScale,c*pixScale])]);
	disp(['error: ' num2str(sqrt((r-r0)^2 + (c-c0)^2)*pixScale)]);
end
