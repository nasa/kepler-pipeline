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
nTargets = length(pixStruct);
nCadences = size(pixStruct(1).pixelValues, 1);
lc = zeros(nTargets, nCadences);
lcNoCr = zeros(nTargets, nCadences);
for t=1:nTargets
    lc(t,:) = sum(pixStruct(t).pixelValues, 2);
    lcNoCr(t,:) = sum(pixStructNoCr(t).pixelValues, 2);
end
cr = lc - lcNoCr;
crNz = cr(cr(:)>0);
crNze = crNz*116;
hist(crNze, 1000);
%%
for i=1:nTargets
%     plot(1:nCadences, lc(i,:), 1:nCadences, lcNoCr(i,:));
    plot(1:nCadences, cr(i,:));
    title(['t=' num2str(i) ' row=' num2str(pixStruct(i).referenceRow) ...
        ' col=' num2str(pixStruct(i).referenceColumn)]); 
    pause; 
end
%%
for i=1:nTargets
    plot(1:nCadences, lc(i,:), 1:nCadences, lcNoCr(i,:));
    title(['t=' num2str(i) ' row=' num2str(pixStruct(i).referenceRow) ...
        ' col=' num2str(pixStruct(i).referenceColumn)]); 
    pause; 
end
%%
for i=1:nTargets
%     plot(1:nCadences, lc(i,:), 1:nCadences, lcNoCr(i,:));
    plot(pixStruct(i).pixelValues);
    title(['t=' num2str(i) ' row=' num2str(pixStruct(i).referenceRow) ...
        ' col=' num2str(pixStruct(i).referenceColumn)]); 
    pause; 
end

%%
for i=1:nTargets
%     plot(1:nCadences, lc(i,:), 1:nCadences, lcNoCr(i,:));
    plot(pixStruct(i).pixelValues - pixStructNoCr(i).pixelValues);
    title(['t=' num2str(i) ' row=' num2str(pixStruct(i).referenceRow) ...
        ' col=' num2str(pixStruct(i).referenceColumn)]); 
    pause; 
end

%%
zeroCols = [];
zeroRows = [];
nonzeroCols = [];
nonzeroRows = [];
for i=1:nTargets
    if all(cr(i,:)==0)
        zeroRows = [zeroRows; pixStruct(i).referenceRow];
        zeroCols = [zeroCols; pixStruct(i).referenceColumn];
    else
        nonzeroRows = [nonzeroRows; pixStruct(i).referenceRow];
        nonzeroCols = [nonzeroCols; pixStruct(i).referenceColumn];
    end
end

%% count target pixels
nPixels = 0;
nCrPixels = 0;
for t=1:nTargets
    nPixels = nPixels + length(pixStruct(t).pixelValues(1,:));
    crPix = pixStruct(t).pixelValues - pixStructNoCr(t).pixelValues;
    nCrPixels = nCrPixels + length(crPix(crPix(:) > 0));
end
disp(['predicted # of hit pixels: ' num2str(pi*nPixels*size(lc,2)/48)]);
disp(['actual # of hit pixels: ' num2str(nCrPixels)]);
disp(['ratio: ' num2str(nCrPixels/(pi*nPixels*size(lc,2)/48))]);
