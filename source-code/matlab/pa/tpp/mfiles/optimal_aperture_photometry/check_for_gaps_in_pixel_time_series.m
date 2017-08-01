function targetStarStruct = check_for_gaps_in_pixel_time_series(targetStarStruct, gapFillParametersStruct)

% tppInputStruct.targetStarStruct
% ans =
% 150x1 struct array with fields:
%     referenceRow
%     referenceColumn
%     pixelTimeSeriesStruct
%     gapList
% tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(1)
% ans =
%                     row: 703
%                  column: 546
%     isInOptimalAperture: 1
%              timeSeries: [4464x1 double]
%           uncertainties: [4464x1 double]
%                 gapList: []
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




nTargets = length(targetStarStruct);



for target = 1:nTargets

    nPixels = length(targetStarStruct(target).pixelTimeSeriesStruct);
    nCadences = length(targetStarStruct(target).pixelTimeSeriesStruct(1).timeSeries);
    dataGapIndicators = false(nCadences,1);
    pixelTimeSeries = zeros(nCadences, nPixels);

    for iPixel = 1:nPixels

        gapList = targetStarStruct(target).pixelTimeSeriesStruct(iPixel).gapList;
        pixelTimeSeries(:,iPixel) = targetStarStruct(target).pixelTimeSeriesStruct(iPixel).timeSeries;

        if(~isempty(gapList))

            pixelTimeSeriesWithGaps = targetStarStruct(target).pixelTimeSeriesStruct(iPixel).timeSeries;
            uncertaintiesWithGaps = targetStarStruct(target).pixelTimeSeriesStruct(iPixel).uncertainties;

            pixelTimeSeries(gapList,iPixel) = 0;

            pixelTimeSeriesWithGaps(gapList) = 0;
            uncertaintiesWithGaps(gapList) = 0;

            dataGapIndicators(gapList) = true;

            % use the new signature that returns uncertainties

            [ pixelTimeSeriesWithGapsFilled, uncertaintiesWithGapsFilled] = ...
                fill_short_data_gaps(pixelTimeSeriesWithGaps, dataGapIndicators,gapFillParametersStruct, uncertaintiesWithGaps);


            targetStarStruct(target).pixelTimeSeriesStruct(iPixel).timeSeries(gapList) = pixelTimeSeriesWithGapsFilled(gapList);
            targetStarStruct(target).pixelTimeSeriesStruct(iPixel).uncertainties(gapList) = uncertaintiesWithGapsFilled(gapList);
        end;

    end

    % targetStarStruct.gapList contains gaps at target level
    % when constructing the design matrix, remember to exclude these cadences
    % in the pixel data as well as the ancillary data

    masterGapList = unique(cat(2,targetStarStruct(1).pixelTimeSeriesStruct.gapList));

    fluxInAperure = sum(pixelTimeSeries,2);

    acceptableCadences = setdiff((1:nCadences)', masterGapList(:));

    meanFlux = mean(fluxInAperure(acceptableCadences));

    moreTargetLevelGaps = find((fluxInAperure./meanFlux)  < gapFillParametersStruct.gapFluxCompletenessFraction);


    if(~isempty(moreTargetLevelGaps))
        targetStarStruct(target).targetLevelGapsMasterList = [targetStarStruct(target).gapList(:) moreTargetLevelGaps];
    else
        targetStarStruct(target).targetLevelGapsMasterList = targetStarStruct(target).gapList;
    end


end

