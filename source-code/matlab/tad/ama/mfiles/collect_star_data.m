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
load ama-inputs-0.mat
%%
load maskDefinitions_ort3_s3_1halo_test1.mat
inputsStruct.maskDefinitions = maskDefinitions;
inputsStruct.maskTableParametersStruct = maskTableParametersStruct;

%%
inputsStruct.debugFlag = 1;
amaOutputStruct = ama_matlab_controller(inputsStruct);

%%
starIndex = find([amaOutputStruct.targetDefinitions.keplerId] < 100000000);
starData = amaOutputStruct.targetDefData(starIndex);
starTdefs = amaOutputStruct.targetDefinitions(starIndex);

%%
load m18_catalog_data.mat

%%

for i=1:length(starTdefs)
    catIndex = find(starTdefs(i).keplerId == catalog.keplerId);
    if isempty(catIndex)
        starTdefs(i).keplerMagnitude = 18;
        starTdefs(i).apertureNumPix = 0;
        starTdefs(i).maskNumPix = 0;
    else
        starTdefs(i).keplerMagnitude = catalog.keplerMagnitude(catIndex);
        starTdefs(i).apertureNumPix = starData(i).apertureNumPix;
        starTdefs(i).maskNumPix = starData(i).maskNumPix;
    end
end
save starTdefs_ort3_s3.mat starTdefs starData

%%

figure;
plot([starTdefs.keplerMagnitude], [starTdefs.apertureNumPix], '+', ...
    [starTdefs.keplerMagnitude], [starTdefs.maskNumPix], 'd');
xlabel('magnitude');
ylabel('# of pixels');
legend('# of pixels in aperture','# of pixels in mask');

xs = [starTdefs.excessPixels];
mags = [starTdefs.keplerMagnitude];
[sortMags sortI] = sort(mags);
sortXs = xs(sortI);
figure;
plot(sortMags, cumsum(sortXs));
xlabel('magnitude');
ylabel('accumulated excess');
figure;
plot(mags, xs, 'x');
xlabel('magnitude');
ylabel('excess');

%%
deltaM = 0.5;
mCount = 1;
for m = 4:deltaM:16
    inRangeIndex = find(mags > m & mags < m+deltaM);
    excessInRange(mCount) = sum(xs(inRangeIndex));
    magRangeStart(mCount) = m;
    magRangeEnd(mCount) = m + deltaM;
    mCount = mCount + 1;
end
figure;
bar(magRangeStart, excessInRange);
xlabel('magnitude');
ylabel('accumulated excess');

    
