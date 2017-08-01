function self = test_dg_statistics(self)
% mlunit for testing truthfulness of statistics
% It shall demonstrate that statistics are still calculated correctly even
% with 50% of the pixels gapped, in the low guard bands and in the high
% guard bands
% 
% 
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
import gov.nasa.kepler.common.FcConstants;

numCoadds = 270;
module = 3;
output =1;
hgb = (2^14-1)*.95;
lgb(1:84) = 600;


ffiImage = ones(FcConstants.CCD_ROWS, FcConstants.CCD_COLUMNS)*numCoadds*1000;

[starRowStart, starRowEnd, starColStart,starColEnd,...
    leadingBlackRowStart, leadingBlackRowEnd, leadingBlackColStart, leadingBlackColEnd,...
    trailingBlackRowStart, trailingBlackRowEnd, trailingBlackColStart, trailingBlackColEnd,...
    maskedSmearRowStart, maskedSmearRowEnd, maskedSmearColStart, maskedSmearColEnd...
    virtualSmearRowStart, virtualSmearRowEnd, virtualSmearColStart, virtualSmearColEnd] =...
    define_pixel_regions(); %#ok<NASGU>

% define the names of the pixel regions:
 region = {'star', 'leadingBlack', 'trailingBlack', 'maskedSmear', 'virtualSmear'};

fprintf('\n \n testing min, max, mean, median, mode, stdev calculation with gappy data NaN in ea/ pixel region\n\n')

for r = 1:length(region)
    stringRowStart = strcat(region{r}, 'RowStart');
    stringRowEnd= strcat(region{r}, 'RowEnd');
    stringColStart = strcat(region{r}, 'ColStart');
    stringColEnd = strcat(region{r}, 'ColEnd');

    eval(['rowStart =' stringRowStart, ';'])
    eval(['rowEnd =' stringRowEnd, ';'])
    eval(['colStart =' stringColStart, ';'])
    eval(['colEnd =' stringColEnd, ';'])

    interest =ffiImage(rowStart:rowEnd, colStart:colEnd);
    interest(1:end*.50)= 2^32-1; % make half the pixels missing in the area of interest
    ffiImage(rowStart:rowEnd, colStart:colEnd)= interest;
    obj =  dgTrimmedImageClass( module, output, numCoadds, 50000, 50001, ffiImage);
    resultStruct = dg_compute_stat(obj, hgb, lgb);
    stat(1) = 1000;
    stat(2) = 1000;
    stat(3) = 1000;
    stat(4) = 1000;
    stat(5) = 1000;
    stat(6) = 0;
    statisticsName = {'min','max', 'mean', 'median', 'mode', 'stdev'};

    message = {['expected min value of' num2str(stat(1))],...
        ['expected max value of ' num2str(stat(2))]...
        ['expected mean value of ' num2str(stat(module))],...
        ['expected median value of ' num2str(stat(4))]...
        ['expected mode value of ' num2str(stat(5))],...
        ['expected stdev value of ' num2str(stat(6))]};

    
   for s = 1:6
        fprintf('%s %s %s %s %s \n','testing for', statisticsName{s},...
            'in region', region{r}, 'with 50% gappy data')
        expectedAnswer = isequal(resultStruct.(region{r}).(statisticsName{s}), stat(s));
        mlunit_assert(expectedAnswer, message{s})

    end
end



% now test with values in low guard band
fprintf('\n \ntesting min, max, mean, median, mode, stdev calculation with data in low guard band\n')
ffiImage = ones(FcConstants.CCD_ROWS, FcConstants.CCD_COLUMNS)*numCoadds*1000; % reset ffiImage


for r = 1:length(region)
    
    stringRowStart = strcat(region{r}, 'RowStart');
    stringRowEnd= strcat(region{r}, 'RowEnd');
    stringColStart = strcat(region{r}, 'ColStart');
    stringColEnd = strcat(region{r}, 'ColEnd');

    eval(['rowStart =' stringRowStart, ';'])
    eval(['rowEnd =' stringRowEnd, ';'])
    eval(['colStart =' stringColStart, ';'])
    eval(['colEnd =' stringColEnd, ';'])

    interest =ffiImage(rowStart:rowEnd, colStart:colEnd);
    interest(1:end*.50)= 600*numCoadds; % make half the pixels into low guard band
    ffiImage(rowStart:rowEnd, colStart:colEnd)= interest;
    obj =  dgTrimmedImageClass( module, 1, numCoadds, 50000, 50001, ffiImage);
    resultStruct = dg_compute_stat(obj, hgb, lgb);
    statisticsName = {'min','max', 'mean', 'median', 'mode', 'stdev'};
    stat(1) = min(interest(:)/numCoadds);
    stat(2) = max(interest(:)/numCoadds);
    stat(module) = mean(interest(:)/numCoadds);
    stat(4) = median(interest(:)/numCoadds);
    stat(5) = mode(interest(:)/numCoadds);
    stat(6) = std(interest(:)/numCoadds);

    message = {['expected min value of' num2str(stat(1))],...
        ['expected max value of ' num2str(stat(2))]...
        ['expected mean value of ' num2str(stat(module))],...
        ['expected median value of ' num2str(stat(4))]...
        ['expected mode value of ' num2str(stat(5))],...
        ['expected stdev value of ' num2str(stat(6))]};

    for s = 1:6
        fprintf('%s %s %s %s %s \n','testing for', statisticsName{s},...
            'in region', region{r}, 'with 50% pixels in low guard band')
        expectedAnswer = isequal(resultStruct.(region{r}).(statisticsName{s}), stat(s));
        mlunit_assert(expectedAnswer, message{s})

    end
end




% now test with values in high guard band
fprintf('\n \ntesting min, max, mean, median, mode, stdev calculation with high guard band\n')
ffiImage = ones(FcConstants.CCD_ROWS, FcConstants.CCD_COLUMNS)*numCoadds*1000;
for r = 1:length(region)
    
    stringRowStart = strcat(region{r}, 'RowStart');
    stringRowEnd= strcat(region{r}, 'RowEnd');
    stringColStart = strcat(region{r}, 'ColStart');
    stringColEnd = strcat(region{r}, 'ColEnd');

    eval(['rowStart =' stringRowStart, ';'])
    eval(['rowEnd =' stringRowEnd, ';'])
    eval(['colStart =' stringColStart, ';'])
    eval(['colEnd =' stringColEnd, ';'])

    interest =ffiImage(rowStart:rowEnd, colStart:colEnd);
    interest(1:end*.50)= (2^14-1)*numCoadds; % make half the pixels into high guard band
    ffiImage(rowStart:rowEnd, colStart:colEnd)= interest;
    obj =  dgTrimmedImageClass( module, 1, numCoadds, 50000, 50001, ffiImage);
    resultStruct = dg_compute_stat(obj, hgb, lgb);
    statisticsName = {'min','max', 'mean', 'median', 'mode', 'stdev'};
    stat(1) = min(interest(:)/numCoadds);
    stat(2) = max(interest(:)/numCoadds);
    stat(module) = mean(interest(:)/numCoadds);
    stat(4) = median(interest(:)/numCoadds);
    stat(5) = mode(interest(:)/numCoadds);
    stat(6) = std(interest(:)/numCoadds);
    message = {['expected min value of' num2str(stat(1))],...
        ['expected max value of ' num2str(stat(2))]...
        ['expected mean value of ' num2str(stat(module))],...
        ['expected median value of ' num2str(stat(4))]...
        ['expected mode value of ' num2str(stat(5))],...
        ['expected stdev value of ' num2str(stat(6))]};
    
    for s = 1:6
  
        fprintf('%s %s %s %s %s \n','testing for', statisticsName{s},...
            'in region', region{r}, 'with 50% pixels in high guard band')
        expectedAnswer = isequal(resultStruct.(region{r}).(statisticsName{s}), stat(s));
        mlunit_assert(expectedAnswer, message{s})

    end
end

fprintf('\n\n finished testing statistics calculation\n \n')


