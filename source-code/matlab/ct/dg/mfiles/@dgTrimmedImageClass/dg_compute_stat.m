function dgStatStruct = dg_compute_stat(dgTrimmedImageObj, highGuardBand, lowGuardBand)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function dgStatStruct = dg_compute_stat(dgTrimmedImageObj)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% dg_compute_stat takes and object and does statistics analysis, pixel 
% completeness analysis, and low/high guard band counts to it
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS: 
%
%       dgTrimmedImageObj, is a 1x1 struct with the following fields:
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
%     virtualSmear: [array double] normalized pixel values of the virtual smear region
%
%    highGuardBand: [double] this is 95% of the quantization units
%     lowGuardBand: [array double] this is 95% of the mean 2D black for
%     focal plane
%                   
%     
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT: 
%       
% dgStatStruct is a 1x1 Struct with the following fields:
%
%   FIRST LEVEL- 
%
%               module : [int] CCD module number
%                output: [int] CCD output number
%             numCoadds: [int] number of cocadds
%              startMjd: [double] start MJD time of data
%                endMjd: [double] end MJD time of data
%                  star: [struct] statistics of the star region
%          leadingBlack: [struct] statistics of the leading black region
%         trailingBlack: [struct] statistics of the trailing black region
%           maskedSmear: [struct] statistics of the masked smear region
%          virtualSmear: [struct] statistics of the virtual smear region
%
%    SECOND LEVEL-
%
%           star, leadingBlack, trailingBlack, maskedSmear, virtualSmear
%           are structs having the following fields:
%
%                   min: [double] the minimum value for the normalized 
%                                 pixel region
%                   max: [double] the maximum  value for the normalized
%                                 pixel region
%                  mean: [double] the mean value for the normalized
%                                 pixel region 
%                median: [double] the median value for the normalized
%                                 pixel region
%                  mode: [double] the most frequent value for the 
%                                 normalized pixel region
%                 stdev: [double] the standard diviation for the normalized
%                                 pixel region
%    expectedPixelCount: [int] the expected number of pixels (and data
%                              points) for the pixel region
%  percentPixelComplete: [double] percent of pixels that had data
%                                 transmission
%      highGuardBandVal: [double] defined as 0.95 x (2^14-1) for all
%                                 module outputs
%     countPixHighGuardBand: [int] number of pixels above the highGuardBand for
%                              the pixel region
%       lowGuardBandVal: [double] this is defined as 0.95 x mean black of
%                                 the module output
%      countPixLowGuardBand: [int] number of pixels below the lowGuardBand for
%                              the pixel region
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% NOTE: dg_compute_stat does calculation per module output
%      (not the full 84)
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



% define the names of the pixel regions:
region = {'star', 'leadingBlack', 'trailingBlack', 'maskedSmear', 'virtualSmear'};



% initialize structure, part 1
dgStatStruct.module = dgTrimmedImageObj.module;
dgStatStruct.output = dgTrimmedImageObj.output;
dgStatStruct.numCoadds = dgTrimmedImageObj.numCoadds;
dgStatStruct.startMjd = dgTrimmedImageObj.startMjd;
dgStatStruct.endMjd = dgTrimmedImageObj.endMjd;


% initialize structure, part 2 (second level structure)
for n = 1: length(region)
    dgStatStruct.(region{n})= struct('min', [], ...
        'max', [], ...
        'mean', [], ...
        'median', [], ...
        'mode', [], ...
        'stdev', -[],...
        'expectedPixelCount', [], ...
        'missingPixelCount', [], ...
        'percentPixelComplete', [], ...
        'highGuardBandVal',[], ...
        'countPixHighGuardBand', [], ...
        'lowGuardBandVal', [], ...
        'countPixLowGuardBand', []);



    % magic number for gapping data depends on the 'Datatype' field in fits
    % header now, 3 possibilities: -1 (int32), 2^32-1 (uint32), or NaN(float)
    % this is still iffy so check for the three possibilities
    % non-gapped data cannot be NaN or negative in value anyways
  
    
    gapBitPattern = hex2dec('FFFFFFFF');
    gapBitValues = [-1/dgTrimmedImageObj.numCoadds,...
        gapBitPattern/dgTrimmedImageObj.numCoadds, ...
        NaN];
    


    % place arrays for ea/ region into a variable called  pixel and do statistics

    pixels = dgTrimmedImageObj.(region{n});
    pixels = pixels(:); % linearlize
    
    % check which format the magic number comes in 
    if any(pixels==gapBitValues(1))
        
        magicNumber = gapBitValues(1);
        indxToUse = find(pixels ~= magicNumber);
        
    elseif any(pixels >= gapBitValues(2))
        
        magicNumber = gapBitValues(2);
        indxToUse = find(pixels < magicNumber-1);
        
    elseif any(isnan(pixels))
        
        indxToUse = find(~isnan(pixels));
    else
        indxToUse = find(pixels);
    end

    
    


    % statistics excluding missing data

    
    
    
    
    usefulPixels = pixels(indxToUse); 
    
    minPixVal = min(usefulPixels);
    maxPixVal = max(usefulPixels);
    meanPixVal = mean(usefulPixels);
    medianPixVal = median(usefulPixels);
    modePixVal = mode(usefulPixels);
    stdevPixVal = std(usefulPixels);



    % pixel completeness
    expected = numel(pixels);
    missing = expected - numel(usefulPixels);

    complete = 100*(expected - missing)/expected;



    % out of range pixel values
    highGuardBandVal = highGuardBand;
    countPixHighGuardBand = sum(usefulPixels >= highGuardBandVal );
   



    % obtain channel number for module output so corresponding lowGuardBand can
    % be identified
    channel = convert_from_module_output(dgTrimmedImageObj.module, dgTrimmedImageObj.output);
    lowGuardBandVal = lowGuardBand(channel);
    countPixLowGuardBand = sum(usefulPixels <= lowGuardBandVal);



    % place computed values into second level structure
    dgStatStruct.(region{n}).min = minPixVal;
    dgStatStruct.(region{n}).max = maxPixVal;
    dgStatStruct.(region{n}).mean = meanPixVal;
    dgStatStruct.(region{n}).median = medianPixVal;
    dgStatStruct.(region{n}).mode = modePixVal;
    dgStatStruct.(region{n}).stdev = stdevPixVal;
    dgStatStruct.(region{n}).expectedPixelCount = expected;
    dgStatStruct.(region{n}).missingPixelCount = missing;
    dgStatStruct.(region{n}).percentPixelComplete = complete;
    dgStatStruct.(region{n}).highGuardBandVal = highGuardBandVal;
    dgStatStruct.(region{n}).countPixHighGuardBand = countPixHighGuardBand;
    dgStatStruct.(region{n}).lowGuardBandVal = lowGuardBandVal;
    dgStatStruct.(region{n}).countPixLowGuardBand = countPixLowGuardBand;

end

return
 