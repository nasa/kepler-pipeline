function self = test_dg_finds_missing_data(self)
% mlunit for testing gappy data
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

% expect gappy to to come in 3 flavors:
% magic number for gapping data depends on the 'Datatype' field in fits
% header now, 3 possibilities: -1 (int32), 2^32-1 (uint32), or
% NaN(float)

% remember that these values will be normalize when turned into
% dgTrimmedImageObjects  so -1/32, (2^32-1)/NumCoadds, and NaN

% Create dgTrimmedImageObj with all gappy data in the star region
% set highGuardBand to 2^14-1 and lowGuardband to 700 (not important for
% this test)

import gov.nasa.kepler.common.FcConstants;
ffiImageMissing = ones(FcConstants.CCD_ROWS, FcConstants.CCD_COLUMNS)*1000;

[starRowStart, starRowEnd, starColStart,starColEnd,... 
    leadingBlackRowStart, leadingBlackRowEnd, leadingBlackColStart, leadingBlackColEnd,...
    trailingBlackRowStart, trailingBlackRowEnd, trailingBlackColStart, trailingBlackColEnd,...
    maskedSmearRowStart, maskedSmearRowEnd, maskedSmearColStart, maskedSmearColEnd...
    virtualSmearRowStart, virtualSmearRowEnd, virtualSmearColStart, virtualSmearColEnd] =...
    define_pixel_regions(); %#ok<NASGU>


% define the names of the pixel regions:

region = {'star', 'leadingBlack', 'trailingBlack', 'maskedSmear', 'virtualSmear'};

    hgb = 2^14-1;
    lgb(1:84) = 600;
    
    disp('testing for 0, 50, 100% pixel completeness for each pixel region')
    
for r = 1:length(region)
        stringRowStart = strcat(region{r}, 'RowStart');
        stringRowEnd= strcat(region{r}, 'RowEnd');
        stringColStart = strcat(region{r}, 'ColStart');
        stringColEnd = strcat(region{r}, 'ColEnd');
        
        eval(['rowStart =' stringRowStart, ';'])
        eval(['rowEnd =' stringRowEnd, ';'])
        eval(['colStart =' stringColStart, ';'])
        eval(['colEnd =' stringColEnd, ';'])
        
        
        for gapValue = [-1, NaN, hex2dec('FFFFFFFF')]


    % 100 % missing pixels 
    fprintf('%s %s %s %s \n','testing for 0% completeness pixels in the',...
        region{r}, 'with gap value =', num2str(gapValue))
    ffiImageMissing(rowStart:rowEnd, colStart:colEnd) = gapValue;
    obj =  dgTrimmedImageClass( 3, 1, 270, 50000, 50001, ffiImageMissing);
    resultStruct = dg_compute_stat(obj, hgb, lgb);
    expectedAnswer = isequal(resultStruct.(region{r}).percentPixelComplete, 0);
    mlunit_assert(expectedAnswer, 'expected 0 % completeness')
    
    % 50% missing pixels gap value
    fprintf('%s %s %s %s \n','testing for 50% completeness pixels in the',...
        region{r}, 'with gap value =', num2str(gapValue))
    interest =ffiImageMissing(rowStart:rowEnd, colStart:colEnd);
    interest(1:end*.50)= gapValue; % make half the pixels missing in the area of interest
    ffiImageMissing(rowStart:rowEnd, colStart:colEnd)= interest;
    obj =  dgTrimmedImageClass( 3, 1, 270, 50000, 50001, ffiImageMissing);
    resultStruct = dg_compute_stat(obj, hgb, lgb);
    expectedAnswer = isequal(resultStruct.(region{r}).percentPixelComplete, 0);
    mlunit_assert(expectedAnswer, 'expected 0 % completeness')
    
    % no gaps in data
    fprintf('%s %s %s %s \n','testing for 100% completeness pixels in the',...
        region{r}, 'with gap value =', num2str(gapValue))
    ffiImageMissing(rowStart:rowEnd, colStart:colEnd) = 2;
    obj =  dgTrimmedImageClass( 3, 1, 270, 50000, 50001, ffiImageMissing);
    resultStruct = dg_compute_stat(obj, hgb, lgb);
    expectedAnswer = isequal(resultStruct.(region{r}).percentPixelComplete, 100);
    mlunit_assert(expectedAnswer, 'expected 100 % completeness')
    
    

        end
end
