function self = test_dg_finds_out_of_guardband_data(self)
% mlunit for testing pixels that go out of bands
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


fprintf('\n \n testing detection for out of guard bands pixels \n \n')

import gov.nasa.kepler.common.FcConstants;
% values within expected range
ffiImage = ones(FcConstants.CCD_ROWS, FcConstants.CCD_COLUMNS)*270*700;

[starRowStart, starRowEnd, starColStart,starColEnd,... 
    leadingBlackRowStart, leadingBlackRowEnd, leadingBlackColStart, leadingBlackColEnd,...
    trailingBlackRowStart, trailingBlackRowEnd, trailingBlackColStart, trailingBlackColEnd,...
    maskedSmearRowStart, maskedSmearRowEnd, maskedSmearColStart, maskedSmearColEnd...
    virtualSmearRowStart, virtualSmearRowEnd, virtualSmearColStart, virtualSmearColEnd] =...
    define_pixel_regions(); %#ok<NASGU>


% define the names of the pixel regions:

region = {'star', 'leadingBlack', 'trailingBlack', 'maskedSmear', 'virtualSmear'};

    hgb = (2^14-1)*.95; 
    lgb(1:84) = 600; % value of 600 DN/read for low guard band
    
    disp('testing for pixels out of low guard band for each pixel region')
    
    for r = 1:length(region)
        stringRowStart = strcat(region{r}, 'RowStart');
        stringRowEnd= strcat(region{r}, 'RowEnd');
        stringColStart = strcat(region{r}, 'ColStart');
        stringColEnd = strcat(region{r}, 'ColEnd');

        eval(['rowStart =' stringRowStart, ';'])
        eval(['rowEnd =' stringRowEnd, ';'])
        eval(['colStart =' stringColStart, ';'])
        eval(['colEnd =' stringColEnd, ';'])




        % 0 number of pixels out of guard band
        fprintf('%s %s %s\n','testing for no pixels out of low guard band in' ,region{r}, 'region')
        obj = dgTrimmedImageClass( 3, 1, 270, 50000, 50001, ffiImage);
        resultStruct = dg_compute_stat(obj, hgb, lgb);
        expectedAnswer = isequal(resultStruct.(region{r}).countPixLowGuardBand, 0);
        mlunit_assert(expectedAnswer, 'expected 0 pixels in low guard band')

        % 300 pixels out of low guard band
        fprintf('%s %s %s\n','testing for 300 pixels out of low guard band in' ,region{r}, 'region')
        interest =ffiImage(rowStart:rowEnd, colStart:colEnd);
        interest(1:300)= 500; % make 300 pixels below low guard band
        ffiImage(rowStart:rowEnd, colStart:colEnd)= interest;
        obj =  dgTrimmedImageClass( 3, 1, 270, 50000, 50001, ffiImage);
        resultStruct = dg_compute_stat(obj, hgb, lgb);
        expectedAnswer = isequal(resultStruct.(region{r}).countPixLowGuardBand, 300);
        mlunit_assert(expectedAnswer, 'expected 300 pixels below low guard band')

        % all pixels out of low guard band
        fprintf('%s %s %s\n','testing for all pixels out of low guard band in' ,region{r}, 'region')
        interest = ffiImage(rowStart:rowEnd, colStart:colEnd);
        interest(:,:) = 500; % make all pixels out of low guard band
        ffiImage(rowStart:rowEnd, colStart:colEnd)= interest;
        obj =  dgTrimmedImageClass( 3, 1, 270, 50000, 50001, ffiImage);
        resultStruct = dg_compute_stat(obj, hgb, lgb);
        expectedAnswer = isequal(resultStruct.(region{r}).countPixLowGuardBand, numel(interest));
        mlunit_assert(expectedAnswer, 'expected all pixels out of low guard band')



    end

    
    
    
    % now test for high guard band
    
        disp('testing for pixels out of high guard band for each pixel region')
    
    for r = 1:length(region)
        stringRowStart = strcat(region{r}, 'RowStart');
        stringRowEnd= strcat(region{r}, 'RowEnd');
        stringColStart = strcat(region{r}, 'ColStart');
        stringColEnd = strcat(region{r}, 'ColEnd');

        eval(['rowStart =' stringRowStart, ';'])
        eval(['rowEnd =' stringRowEnd, ';'])
        eval(['colStart =' stringColStart, ';'])
        eval(['colEnd =' stringColEnd, ';'])




        % 0 number of pixels out of guard band
        fprintf('%s %s %s\n','testing for no pixels out of high guard band in' ,region{r}, 'region')
        obj = dgTrimmedImageClass( 3, 1, 270, 50000, 50001, ffiImage);
        resultStruct = dg_compute_stat(obj, hgb, lgb);
        expectedAnswer = isequal(resultStruct.(region{r}).countPixHighGuardBand, 0);
        mlunit_assert(expectedAnswer, 'expected 0 pixels in high guard band')

        % 300 pixels out of low guard band
        fprintf('%s %s %s\n','testing for 300 pixels out of high guard band in' ,region{r}, 'region')
        interest =ffiImage(rowStart:rowEnd, colStart:colEnd);
        interest(1:300)= (2^15)*270; % make 300 pixels above high guard band
        ffiImage(rowStart:rowEnd, colStart:colEnd)= interest;
        obj =  dgTrimmedImageClass( 3, 1, 270, 50000, 50001, ffiImage);
        resultStruct = dg_compute_stat(obj, hgb, lgb);
        expectedAnswer = isequal(resultStruct.(region{r}).countPixHighGuardBand, 300);
        mlunit_assert(expectedAnswer, 'expected 300 pixels out of high guard band')

        % all pixels out of low guard band
        fprintf('%s %s %s\n','testing for all pixels out of high guard band in' ,region{r}, 'region')
        interest = ffiImage(rowStart:rowEnd, colStart:colEnd);
        interest(:,:) = (2^15)*270; % make all pixels out of high guard band
        ffiImage(rowStart:rowEnd, colStart:colEnd)= interest;
        obj =  dgTrimmedImageClass( 3, 1, 270, 50000, 50001, ffiImage);
        resultStruct = dg_compute_stat(obj, hgb, lgb);
        expectedAnswer = isequal(resultStruct.(region{r}).countPixHighGuardBand, numel(interest));
        mlunit_assert(expectedAnswer, 'expected all pixels out of high guard band')



    end
    
    fprintf('\n \n finished testing out of guard band values\n \n')

