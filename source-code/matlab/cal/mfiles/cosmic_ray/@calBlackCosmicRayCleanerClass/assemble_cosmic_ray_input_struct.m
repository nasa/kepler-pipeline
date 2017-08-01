function inputStruct = ...
    assemble_cosmic_ray_input_struct( calObject, calIntermediateStruct )
%**************************************************************************
% function inputStruct = assemble_cosmic_ray_input_struct( calObject )
%**************************************************************************
% Convert a calClass object (and a calIntermediateStruct if processing
% short cadence) to a valid cosmicRayInputStruct.
%**************************************************************************    
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
    inputStruct = ...
        calCosmicRayCleanerClass.initialize_cosmic_ray_input_struct( ...
            calObject );
    
    if exist('calIntermediateStruct', 'var')
        pixelArray = build_black_pix_array_from_intermediate_struct( ...
            calIntermediateStruct);
        
        % Add masked and virtual black pixels to the array if processing
        % short cadence.
        if calObject.dataFlags.processShortCadence ...
           && exist('calIntermediateStruct', 'var')
            [mBlackPixelStruct, vBlackPixelStruct] ...
                = build_masked_and_virtual_black_pixels( ...
                    calObject, calIntermediateStruct);
             pixelArray = ...
                 [pixelArray; mBlackPixelStruct; vBlackPixelStruct];
        end
    else
        pixelArray = build_black_pix_array(calObject.blackPixels);
    end
            
    inputStruct.targetArray ...
        = calCosmicRayCleanerClass.assemble_collateral_targets(...
            pixelArray, calBlackCosmicRayCleanerClass.NEIGHBORHOOD);
end


%**************************************************************************
% pixelArray = build_black_pix_array(blackPixels)
%**************************************************************************
% Build a pixel array from the black pixel array contained in a calClass
% object. Assumes pixel values and gap indicators are stored as *column*
% vectors.  
%
% INPUTS
%     blackPixels 
%     |-.row [1 x 1]  
%     |-.values [C x 1]        
%      -.gapIndicators [C x 1]
%
% OUTPUTS
%     pixelArray       : 
%     |-.ccdRow        : The CCD row position of the collateral pixel.
%     |-.ccdColumn     : (contains a class-defined default value)
%     |-.values        : Column vector of flux values at each cadence.
%     |-.gapIndicators : Column vector of gap indicators at each cadence.
%      -.uncertainties : Column vector of 1's. This is just a placeholder,
%                        since uncertainties are unavailable for CAL
%                        collateral pixels).
%**************************************************************************
function pixelArray = build_black_pix_array(blackPixels)
    blackColumn = calBlackCosmicRayCleanerClass.TRAILING_COLUMN;
    
    pixelStruct = cosmicRayCleanerClass.create_empty_pixel_struct();
    pixelArray = repmat(pixelStruct, size(blackPixels));
    
    if ~isempty(blackPixels)
        [pixelArray.ccdRow]        = deal(blackPixels.row);
        [pixelArray.ccdColumn]     = deal(blackColumn);
        [pixelArray.values]        = deal(blackPixels.values);
        [pixelArray.gapIndicators] = deal(blackPixels.gapIndicators);
        [pixelArray.uncertainties] = deal(ones(size(pixelArray(1).values)));
    end
end

%**************************************************************************
% pixelArray = ...
%     build_black_pix_array_from_intermediate_struct(calIntermediateStruct)
%**************************************************************************
% Build a pixel array from a calIntermediateStruct. Assumes pixel values
% and gap indicators are stored as *row* vectors. 
%
% INPUTS
%     calIntermediateStruct : A structure assumed to have the fields
%     |                       listed.
%     |-.blackRows          : nRows x 1 array containing zeros where no
%     |                       valid pixel data exists.
%     |-.blackGaps          : nRows x nCadences
%      -.blackPixels        : nRows x nCadences
%
%     where nRows is the total number of rows (typically 1070).
%
% OUTPUTS
%     pixelArray
%     |-.ccdRow        : The CCD row position of the collateral pixel.
%     |-.ccdColumn     : (contains a class-defined default value)
%     |-.values        : Column vector of flux values at each cadence.
%     |-.gapIndicators : Column vector of gap indicators at each cadence.
%      -.uncertainties : Column vector of 1's. This is just a placeholder,
%                        since uncertainties are unavailable for CAL
%                        collateral pixels).
%%**************************************************************************
function pixelArray = ...
    build_black_pix_array_from_intermediate_struct(calIntermediateStruct)

    blackColumn = calBlackCosmicRayCleanerClass.TRAILING_COLUMN;
    blackRows          = calIntermediateStruct.blackRows;
    validRowInd        = find(blackRows);
    nValid             = length(validRowInd);

    if nValid > 0
    
        % Eliminate non-valid pixels and transpose to column vectors.
        blackRows      = blackRows(validRowInd);
        blackGapMat    = calIntermediateStruct.blackGaps(validRowInd, :)';
        blackValueMat  = calIntermediateStruct.blackPixels(validRowInd, :)';

        % Initialize output pixel array.
        pixelStruct = cosmicRayCleanerClass.create_empty_pixel_struct();
        pixelArray  = repmat(pixelStruct, [nValid, 1]);

        % Distribute array contents to pixel structs.
        c                          = num2cell(blackRows);
        [pixelArray.ccdRow]        = deal(c{:});
        
        [pixelArray.ccdColumn]     = deal(blackColumn);
        
        c                          = num2cell(blackValueMat, 1);
        [pixelArray.values]        = deal(c{:});        
        
        c                          = num2cell(blackGapMat, 1);
        [pixelArray.gapIndicators] = deal(c{:});

        [pixelArray.uncertainties] = deal(ones(size(pixelArray(1).values)));
    end
end


%**************************************************************************
% pixelArray = build_masked_and_virtual_black_pixels(calObject, 
%                                                    calIntermediateStruct)
%**************************************************************************
% Build a pixel array from a calIntermediateStruct. This function is only 
% called during short-cadence processing.
%
% INPUTS
%     calObject            
%     calIntermediateStruct 
%
% OUTPUTS
%     mBlackPixelStruct
%     vBlackPixelStruct
%
% NOTES
%     Assumes the following:
%     1) Pixel values and gap indicators are stored as column vectors. 
%     2) There is a single masked black and a single virtual black pixel
%        time series in calIntermediateStruct. 
%
%     For long cadence, black/smear collateral pixels are returned for each
%     row/column, including rows/columns in the virtual-masked/trailing
%     regions. In order to minimize storage requirements for short cadence,
%     these virtual and masked black regions and trailing smear regions are
%     condensed into two pixels where the trailing smear and masked/virtual
%     black overlap.
%**************************************************************************
function [mBlackPixelStruct, vBlackPixelStruct] ...
    = build_masked_and_virtual_black_pixels(calObject, calIntermediateStruct)

    % extract timestamp (mjds)
    cadenceTimes           = calObject.cadenceTimes;
    timestampGapIndicators = cadenceTimes.gapIndicators;
    
    isAvailableMaskedBlackPix  ...
        = calObject.dataFlags.isAvailableMaskedBlackPix;
    isAvailableVirtualBlackPix ...
        = calObject.dataFlags.isAvailableVirtualBlackPix;

    % get smear rows that were summed onboard spacecraft to find the
    % mean value, which will be the 'row' of the masked or virtual
    % black pixel value.
    mSmearRowStart   = calIntermediateStruct.mSmearRowStart;
    mSmearRowEnd     = calIntermediateStruct.mSmearRowEnd;
    vSmearRowStart   = calIntermediateStruct.vSmearRowStart;
    vSmearRowEnd     = calIntermediateStruct.vSmearRowEnd;

    if numel(mSmearRowStart) > 1 && numel(mSmearRowEnd) > 1
        mSmearRows = [mSmearRowStart mSmearRowEnd];
        validMsmearRows = mSmearRows(~timestampGapIndicators, :);
    else
        validMsmearRows = [mSmearRowStart mSmearRowEnd];
    end

    if numel(vSmearRowStart) > 1 && numel(vSmearRowEnd) > 1
        vSmearRows = [vSmearRowStart vSmearRowEnd];
        validVsmearRows = vSmearRows(~timestampGapIndicators, :);
    else
        validVsmearRows = [vSmearRowStart vSmearRowEnd];
    end

    mBlackPixelStruct = cosmicRayCleanerClass.create_empty_pixel_struct();   
    vBlackPixelStruct = cosmicRayCleanerClass.create_empty_pixel_struct();

    % Extract the masked black pixel and gaps, if available.
    if (isAvailableMaskedBlackPix)
        mBlackValues = calIntermediateStruct.mBlackPixels;  % nCadences x 1
        mBlackGaps   = calIntermediateStruct.mBlackGaps;    % nCadences x 1
        mBlackRow    = round(mean(validMsmearRows, 2));     % 1 x 1

        mBlackPixelStruct.ccdRow        = mBlackRow;
        mBlackPixelStruct.ccdColumn     = calBlackCosmicRayCleanerClass.TRAILING_COLUMN;
        mBlackPixelStruct.values        = mBlackValues;
        mBlackPixelStruct.gapIndicators = mBlackGaps;
        mBlackPixelStruct.uncertainties = ones(size(mBlackValues));
    end

    % Extract the virtual black pixel and gaps, if available.
    if (isAvailableVirtualBlackPix)
        vBlackValues = calIntermediateStruct.vBlackPixels;  % nCadences x 1
        vBlackGaps   = calIntermediateStruct.vBlackGaps;    % nCadences x 1
        vBlackRow    = round(mean(validVsmearRows, 2));     % 1 x 1

        vBlackPixelStruct.ccdRow        = vBlackRow;
        vBlackPixelStruct.ccdColumn     = calBlackCosmicRayCleanerClass.TRAILING_COLUMN;
        vBlackPixelStruct.values        = vBlackValues;
        vBlackPixelStruct.gapIndicators = vBlackGaps;
        vBlackPixelStruct.uncertainties = ones(size(vBlackValues));
    end
end

%********************************** EOF ***********************************