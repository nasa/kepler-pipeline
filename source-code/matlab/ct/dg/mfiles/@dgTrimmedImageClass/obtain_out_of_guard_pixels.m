function [starTable, lbTable, tbTable, msTable, vsTable] = obtain_out_of_guard_pixels(dgTrimmedImageObj, LGB ,HGB)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%[starTable, lbTable, tbTable, msTable, vsTable] = obtain_out_of_guard_pixels(dgTrimmedImageObj, LGB ,HGB)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% obtain_out_of_guard_pixels(dgTrimmedImageObj, LGB ,HGB) returns matrices
% for pixel regions that had pixel values that went out of the guard bands
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS:
%            
%       dgTrimmedImageObj: [object] with the following fields-
%
%           module: [int] CCD module number
%           output: [int] CCD output number
%        numCoadds: [int] number of coadds
%         startMjd: [double] start MJD time of data
%           endMjd: [double] end MJD time of data
%             star: [array double] normalized pixel values of the star region
%     leadingBlack: [array double] normalized pixel values of leading black region
%    trailingBlack: [array double] normalized pixel values of the trailing black region
%      maskedSmear: [array double] normalized pixel values of the masked smear region
%     virtualSmear: [array double] normalized pixel values of thevirtual
%     smear region
%
%              LGB: [1 x 84 vector] the low guard bands, 95% of the mean black
%               for ea/ modout
%              HGB: [double] the high guard band value (2^14-1)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUTS:
%
%         table: [array double] of pixels that went out of guard bands for
%         ea/ of the pixel regions.  First column = pixel row.  Second column =
%         pixel column.  Third column = pixel value.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
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
magicNumber = 1.59e7;

star = get(dgTrimmedImageObj, 'star');
lb = get(dgTrimmedImageObj, 'leadingBlack');
tb = get(dgTrimmedImageObj, 'trailingBlack');
ms = get(dgTrimmedImageObj, 'maskedSmear');
vs = get(dgTrimmedImageObj, 'virtualSmear');
mod = get(dgTrimmedImageObj, 'module');
out = get(dgTrimmedImageObj, 'output');



ch = convert_from_module_output(mod, out);



% get the start row and columns to add on to indeces
[starRowStart, starRowEnd, starColStart,starColEnd,... 
    leadingBlackRowStart, leadingBlackRowEnd, leadingBlackColStart, leadingBlackColEnd,...
    trailingBlackRowStart, trailingBlackRowEnd, trailingBlackColStart, trailingBlackColEnd,...
    maskedSmearRowStart, maskedSmearRowEnd, maskedSmearColStart, maskedSmearColEnd...
    virtualSmearRowStart, virtualSmearRowEnd, virtualSmearColStart] =...
    define_pixel_regions();



% star
[indxRow indxCol] = find((star <= LGB(ch) | star >= HGB) & (star <= magicNumber)); 
rowStar = indxRow + starRowStart - 1;
colStar =indxCol + starColStart - 1;
count = length(indxRow);
values = zeros(count,1);
 for n=1:count
     values(n) = star(indxRow(n), indxCol(n));
 end
starTable = [ rowStar colStar values];



% leading black
[indxRow indxCol] = find((lb< LGB(ch) | lb > HGB)& (lb <= magicNumber));  
rowLb = indxRow + leadingBlackRowStart - 1;
colLb =indxCol + leadingBlackColStart - 1;
count = length(indxRow);
values = zeros(count,1);
for n=1:count
    values(n) = lb(indxRow(n), indxCol(n));
end
lbTable = [ rowLb colLb values];



% trailing black
[indxRow indxCol] = find((tb < LGB(ch) | tb > HGB) & (tb <= magicNumber));  
rowTb = indxRow + trailingBlackRowStart - 1;
colTb =indxCol + trailingBlackColStart - 1;
count = length(indxRow);
values = zeros(count,1);
for n=1:count
    values(n) = tb(indxRow(n), indxCol(n));
end
tbTable = [ rowTb colTb values];



% masked smear
[indxRow indxCol] = find((ms < LGB(ch) | ms > HGB) & (ms <= magicNumber)); 
rowMs = indxRow + maskedSmearRowStart - 1;
colMs =indxCol + maskedSmearColStart - 1;
count = length(indxRow);
values = zeros(count,1);
for n=1:count
    values(n) = ms(indxRow(n), indxCol(n));
end
msTable = [ rowMs colMs values];



% virtual smear
[indxRow indxCol] = find((vs < LGB(ch) | vs > HGB) & (vs <= magicNumber)); 
rowVs = indxRow + virtualSmearRowStart - 1;
colVs =indxCol + virtualSmearColStart - 1;
count = length(indxRow);
values = zeros(count,1);
for n=1:count
    values(n) = vs(indxRow(n), indxCol(n));
end
vsTable = [ rowVs colVs values];


return