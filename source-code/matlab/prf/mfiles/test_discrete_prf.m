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

row = 100+rand(1,1);
col = 100+rand(1,1);
% row = 100;
% col = 100;
mod = 22;
out = 4;
prfNum = 5;

if ~exist('prfPolyObject', 'var')
    prfData = retrieve_prf_model(mod, out);
    prfPolyObject = prfClass(prfData.blob(prfNum).polyStruct);
end

% prfDiscreteObject = prfClass(['/path/to/so/discrete_prf_model/prf_m' ...
%     num2str(mod) '_o' num2str(out) '_p' num2str(prfNum) '.dat']);
% 
discretePrfSpecification.oversample = 10;
prfDiscreteObject = prfClass(prfData.blob(prfNum).polyStruct, discretePrfSpecification);

[pp ppr ppc] = evaluate(prfPolyObject, row, col);
[dp dpr dpc] = evaluate(prfDiscreteObject, row, col);

difp = dp - pp;
disp(['norm of difference = ' num2str(norm(difp(:)))]);

ppImage = zeros(sqrt(length(pp)));
dpImage = zeros(sqrt(length(dp)));
difImage = zeros(sqrt(length(pp)));

centralPix = fix(size(ppImage)/2) + 1;

ppri = ppr - fix(row) + centralPix(1);
ppci = ppc - fix(col) + centralPix(2);
dpri = dpr - fix(row) + centralPix(1);
dpci = dpc - fix(col) + centralPix(2);

for i=1:length(ppri)
    ppImage(ppri(i), ppci(i)) = pp(i);
    dpImage(dpri(i), dpci(i)) = dp(i);
    difImage(dpri(i), dpci(i)) = difp(i);
end

figure(1);
subplot(1,3,1);
imagesc(ppImage);
title('poly-based PRF');
subplot(1,3,2);
imagesc(dpImage);
title('discrete PRF');
subplot(1,3,3);
imagesc(difImage);
title(['difference at ' num2str([row, col])]);
colorbar;

% test irregular apertures
% create irregular apertures
threshold = 1e-3;
ppi = find(pp > threshold);
centralPixIndex = fix(length(pp)/2) + 1;
centralPix = [ppr(centralPixIndex) ppc(centralPixIndex)];
offsetRows = ppr(ppi) - centralPix(1);
offsetCols = ppc(ppi) - centralPix(2);
apRows = fix(row) + offsetRows;
apCols = fix(col) + offsetCols;

[ipp ippr ippc] = evaluate(prfPolyObject, row, col, apRows, apCols);
[idp idpr idpc] = evaluate(prfDiscreteObject, row, col, apRows, apCols);

idifp = idp - ipp;
disp(['norm of difference, irregular ap = ' num2str(norm(idifp(:)))]);

centralPixIndex = round(size(ppImage)/2);
ippri = ippr - fix(row) + centralPixIndex(1);
ippci = ippc - fix(col) + centralPixIndex(2);
idpri = idpr - fix(row) + centralPixIndex(1);
idpci = idpc - fix(col) + centralPixIndex(2);

ippImage = zeros(size(ppImage));
idpImage = zeros(size(dpImage));
idifImage = zeros(size(ppImage));
for i=1:length(ippri)
    ippImage(ippri(i), ippci(i)) = ipp(i);
    idpImage(idpri(i), idpci(i)) = idp(i);
    idifImage(idpri(i), idpci(i)) = idifp(i);
end

figure(3);
subplot(1,3,1);
imagesc(ippImage);
title('poly-based PRF');
subplot(1,3,2);
imagesc(idpImage);
title('discrete PRF');
subplot(1,3,3);
imagesc(idifImage);
title(['difference at ' num2str([row, col])]);
colorbar;


%%

% timing
nTiming = 100;
startTime = clock;
for i=1:nTiming
    ppr(i) = 50*rand(1,1)+50;
    ppc(i) = 50*rand(1,1)+50;
    pp = evaluate(prfPolyObject, ppr(i), ppc(i));
end
elapsedTime = etime(clock, startTime);
disp(['poly evaluate took ' num2str(elapsedTime) ...
    ' seconds or ' num2str(elapsedTime/nTiming) ...
    ' seconds per centroid']);
ppTime = elapsedTime;
startTime = clock;
for i=1:nTiming
    dpr(i) = 50*rand(1,1)+50;
    dpc(i) = 50*rand(1,1)+50;
    dp = evaluate(prfDiscreteObject, dpr(i), dpc(i));
end
elapsedTime = etime(clock, startTime);
disp(['discrete evaluate took ' num2str(elapsedTime) ...
    ' seconds or ' num2str(elapsedTime/nTiming) ...
    ' seconds per centroid']);
disp(['speedup: ' num2str(ppTime/elapsedTime)]);

% error as function of position
nError = 1000;
for i=1:nError
    ppr(i) = 100+rand(1,1);
    ppc(i) = 100+rand(1,1);
    pp = evaluate(prfPolyObject, ppr(i), ppc(i));
    dp = evaluate(prfDiscreteObject, ppr(i), ppc(i));
    difn(i) = norm(dp - pp)/norm(pp);
end
figure(2);
plot3(ppc, ppr, log10(difn), '+');
disp(['mean relative error = ' num2str(mean(difn))]);


