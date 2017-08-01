% show new crowding metric results
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
load /path/to/false_positives/hires_catalog/ukirt/smallKic_ukirt_full_fov.mat;

% q6Str = '_Q6';
q6Str = '_m13';
% q6Str = '';

load(['coaResultStruct' q6Str '_low_w_zodi.mat']);
for i=1:length(coaResultStruct.optimalApertures)
	coaResultStruct.nPix(i) = length(coaResultStruct.optimalApertures(i).offsets);
end
[i ia] = ismember([coaResultStruct.optimalApertures.keplerId], newKic.kepid);
coaResultStruct.kepmag = newKic.kepmag(ia);
lowWZodi = coaResultStruct;

load(['coaResultStruct' q6Str '_high_w_zodi.mat']);
for i=1:length(coaResultStruct.optimalApertures)
	coaResultStruct.nPix(i) = length(coaResultStruct.optimalApertures(i).offsets);
end
[i ia] = ismember([coaResultStruct.optimalApertures.keplerId], newKic.kepid);
coaResultStruct.kepmag = newKic.kepmag(ia);
highWZodi = coaResultStruct;

load(['coaResultStruct' q6Str '_low_no_zodi.mat']);
for i=1:length(coaResultStruct.optimalApertures)
	coaResultStruct.nPix(i) = length(coaResultStruct.optimalApertures(i).offsets);
end
[i ia] = ismember([coaResultStruct.optimalApertures.keplerId], newKic.kepid);
coaResultStruct.kepmag = newKic.kepmag(ia);
lowNoZodi = coaResultStruct;

load(['coaResultStruct' q6Str '_high_no_zodi.mat']);
for i=1:length(coaResultStruct.optimalApertures)
	coaResultStruct.nPix(i) = length(coaResultStruct.optimalApertures(i).offsets);
end
[i ia] = ismember([coaResultStruct.optimalApertures.keplerId], newKic.kepid);
coaResultStruct.kepmag = newKic.kepmag(ia);
highNoZodi = coaResultStruct;

fcConstants = convert_fc_constants_java_2_struct();
flux12 = fcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND;
cadenceTime = 30*60;

mArray = 7:0.1:15;
% get relation between kepmag and flux fraction in aperture
p = polyfit(lowWZodi.kepmag, [lowWZodi.optimalApertures.fluxFractionInAperture]', 5);
ffPerMagLow = polyval(p, mArray);
p = polyfit(highWZodi.kepmag, [highWZodi.optimalApertures.fluxFractionInAperture]', 5);
ffPerMagHigh = polyval(p, mArray);

fArray = cadenceTime * flux12 * mag2b(mArray) / mag2b(12);
fArrayLow = ffPerMagLow.*fArray;
fArrayHigh = ffPerMagHigh.*fArray;
% get relation between kepmag and pix in optimal ap
p = polyfit(lowWZodi.kepmag, lowWZodi.nPix', 5);
pixPerMagLow = polyval(p, mArray);
p = polyfit(highWZodi.kepmag, highWZodi.nPix', 5);
pixPerMagHigh = polyval(p, mArray);

switch q6Str
    case '_Q6'
        highZodiMag = 20.3052;
        lowZodiMag = 20.3411;
        
    case '_m13'
        highZodiMag = 19.9243;
        lowZodiMag = 20.339;
        
    otherwise
        highZodiMag = 19.744;
        lowZodiMag = 20.1307;
end
        
zodiLowFlux = cadenceTime * flux12 * mag2b(20.1307) / mag2b(12);
zodiHighFlux = cadenceTime * flux12 * mag2b(19.744) / mag2b(12);

predictedCrowdingLow = fArrayLow./(fArrayLow + zodiLowFlux*pixPerMagLow);
predictedCrowdingHigh = fArrayHigh./(fArrayHigh + zodiHighFlux*pixPerMagHigh);


figure('Color', 'white');
subplot(1,2,1);
plot(lowWZodi.nPix, [lowWZodi.optimalApertures.crowdingMetric], '+', ...
	lowNoZodi.nPix, [lowNoZodi.optimalApertures.crowdingMetric], 'o');
xlabel('# of pixels in optimal aperture');
ylabel('crowding metric');
legend('with Zodi', 'without Zodi');
title('low Zodi channel');

subplot(1,2,2);
plot(highWZodi.nPix, [highWZodi.optimalApertures.crowdingMetric], '+', ...
	highNoZodi.nPix, [highNoZodi.optimalApertures.crowdingMetric], 'o');
xlabel('# of pixels in optimal aperture');
ylabel('crowding metric');
legend('with Zodi', 'without Zodi');
title('high Zodi channel');


figure('Color', 'white');
subplot(1,2,1);
plot(lowWZodi.nPix, [lowNoZodi.optimalApertures.crowdingMetric] ...
	- [lowWZodi.optimalApertures.crowdingMetric], 'o');
xlabel('# of pixels in optimal aperture');
ylabel('crowding metric difference');
title('low Zodi channel');
axis([0 60 0 .12]);

subplot(1,2,2);
plot(highWZodi.nPix, [highNoZodi.optimalApertures.crowdingMetric] ...
	- [highWZodi.optimalApertures.crowdingMetric], 'o');
xlabel('# of pixels in optimal aperture');
ylabel('crowding metric difference');
title('high Zodi channel');
axis([0 60 0 .12]);


figure('Color', 'white');
subplot(1,2,1);
plot(lowWZodi.kepmag, [lowNoZodi.optimalApertures.crowdingMetric] ...
	- [lowWZodi.optimalApertures.crowdingMetric], '.', mArray, 1-predictedCrowdingHigh, 'r', mArray, 1-predictedCrowdingLow, 'g');
xlabel('kepmag');
ylabel('crowding metric difference');
title('low Zodi channel');
axis([5 15 0 .12]);

subplot(1,2,2);
plot(highWZodi.kepmag, [highNoZodi.optimalApertures.crowdingMetric] ...
	- [highWZodi.optimalApertures.crowdingMetric], '.', mArray, 1-predictedCrowdingHigh, 'r', mArray, 1-predictedCrowdingLow, 'g');
xlabel('kepmag');
ylabel('crowding metric difference');
title('high Zodi channel');
axis([5 15 0 .12]);
legend('TAD difference', 'high-zodi predicted difference', 'low-zodi predicted difference');

figure('Color', 'white');
subplot(1,2,1);
plot(lowWZodi.kepmag, lowWZodi.nPix, 'o', mArray, pixPerMagLow, 'r');
ylabel('# of pixels in optimal aperture');
xlabel('kepmag');
title('low Zodi channel');
axis([7 15 0 60 ]);

subplot(1,2,2);
plot(highWZodi.kepmag, highWZodi.nPix, 'o', mArray, pixPerMagHigh, 'r');
ylabel('# of pixels in optimal aperture');
xlabel('kepmag');
title('high Zodi channel');
axis([7 15 0 60]);



