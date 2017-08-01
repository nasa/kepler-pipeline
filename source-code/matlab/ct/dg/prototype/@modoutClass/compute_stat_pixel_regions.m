function statStruct=compute_stat_pixel_regions(modoutObj, NumFfi)
% primary function statStruct reads in the object modoutObj,
% trims it to its pixel region (star and collaterals) and
% computes the statistics for these regions.
% First level of statStruct:  star, leadingBlack, trailingBlack,
% maskedSmear, and virtualSmear
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

if ( nargin == 1 )
    NumFfi = 1;
end

% statistics for star region
pixels = get(modoutObj,'starRegion')/NumFfi;
statStruct.starRegion = local_stat(pixels, modoutObj);

% statistics for leading black region
pixels = get(modoutObj,'leadingBlackRegion')/NumFfi;
statStruct.leadingBlackRegion = local_stat(pixels, modoutObj);

% statistics for trailing black region
pixels = get(modoutObj,'trailingBlackRegion')/NumFfi;
statStruct.trailingBlackRegion = local_stat(pixels, modoutObj);

% statistics for masked smear region
pixels = get(modoutObj,'maskedSmearRegion')/NumFfi;
statStruct.maskedSmearRegion = local_stat(pixels,modoutObj);

% statistics for virtual smear region
pixels = get(modoutObj,'virtualSmearRegion')/NumFfi;
statStruct.virtualSmearRegion = local_stat(pixels, modoutObj);



%% subfunction to compute the statistics for a pixel region

function s = local_stat(pixels, modoutObj)
% subfunction local_stat to compute statistics


% create and initialize structure with the fields
s = struct('min', -1, 'max', -1, 'mean', -1, 'median', -1, ...
    'mode', -1, 'std', -1, 'pixel', ...
    struct( 'expectedCount', -1, 'missingCount', -1, ...
    'inHighGuard', -1, 'inLowGuard', -1, 'completeness', -1));

% obtain min, max, mean, median, mode, std
minNumber = min(pixels(:));
maxNumber = max(pixels(:));
meanNumber = mean(pixels(:));
medianNumber = median(pixels(:));
modeNumber = mode(pixels(:));
stdNumber = std(pixels(:));

% compute expected number of pixels and count missing ones
expected = numel(pixels);
missing = sum(pixels(:) == 2^32-1);

% obtain the channel (same as index) for the frame and grab high guard
% low guard values using read_high_low_guards.m
index  = get(modoutObj, 'channel');
[highGuardVal, lowGuardVal] = feval(@read_high_low_guards, index);
highGuardCount = sum(pixels(:) > highGuardVal & pixels(:) < 2^32-1);
lowGuardCount = sum(pixels(:) < lowGuardVal);

% calculate percent completeness of pixel region
complete = 100*(expected-missing)/expected;

% place above computed values into structure s
s.min = minNumber;
s.max = maxNumber;
s.mean = meanNumber;
s.median = medianNumber;
s.mode = modeNumber;
s.std = stdNumber;
s.pixel.expectedCount = expected;
s.pixel.missingCount = missing;
s.pixel.inHighGuard = highGuardCount;
s.pixel.inLowGuard = lowGuardCount;
s.pixel.completeness = complete;









