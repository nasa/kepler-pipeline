function statStruct = compute_stat(pixels)
% computes the statistics for a single pixel region and 
% returns it in a stucture statStruct
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

statStruct = struct('min', -1, ...
    'max', -1, ...
    'mean', -1, ...
    'median', -1, ...
    'mode', -1, ...
    'std', -1,...
    'expectedPixelCount', -1, ...
    'missingPixelCount', -1, ...
    'highGuardBandVal', -1, ...
    'highGuardPixelCount', -1, ...
    'lowGuardBandVal', -1, ...
    'lowGuardPixelCount', -1, ...
    'percentPixelComplete', -1);



% obtain min, max, mean, median, mode, std
minNumber = min(pixels(:));
maxNumber = max(pixels(:));
meanNumber = mean(pixels(:));
medianNumber = median(pixels(:));
modeNumber = mode(pixels(:));
stdNumber = std(pixels(:));




% expected number of pixels from size of pixel region 
expected = numel(pixels);



% look for data that got lost during transmission. These
% get padded with the value 2^32 - 1
missing = sum(pixels(:) == 2^32- 1);



% calculate percent completeness of pixel region
complete = 100*(expected-missing)/expected;



% high guard band is a fixed value
highGuardBandVal = 2^14 - 1;
% count the number of pixels above the high guard band but not missing
highGuardCount = sum(pixels(:) > highGuardBandVal & pixels(:) < 2^32-1);



% low guard band is read in from DB.  It is 5% below the mean black
% model = retrieve_two_d_black_model(modnum, outnum); 
% object = twoDBlackClass(model);         
% blacks = get_two_d_black(object, 55000); 
% meanBlack = mean(mean(blacks));                    
lowGuardBandVal = 700;
% count number of pixels below the low guard band
lowGuardCount = sum(pixels(:) < lowGuardBandVal);



% place above computed values into structure statStruct
statStruct.min = minNumber;
statStruct.max = maxNumber;
statStruct.mean = meanNumber;
statStruct.median = medianNumber;
statStruct.mode = modeNumber;
statStruct.std = stdNumber;
statStruct.expectedPixelCount = expected;
statStruct.missingPixelCount = missing;
statStruct.highGuardBandVal = highGuardBandVal;
statStruct.highGuardPixelCount = highGuardCount;
statStruct.lowGuardBandVal = lowGuardBandVal;
statStruct.lowGuardPixelCount = lowGuardCount;
statStruct.percentPixelComplete = complete;

