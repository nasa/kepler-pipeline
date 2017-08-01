function [pixelTsArr, trendMat] = get_conditioned_time_series(obj, targetIdx )
%**************************************************************************  
% [pixelTsArr, trendMat] = get_conditioned_time_series(obj, targetIdx )
%**************************************************************************  
% Return time series for all pixels in the specified target's aperture,
% with variance stabilized and gaps filled. 
%
% 1. Divide non-gapped cadences of all pixel time series by their
%    associated uncertainties.
% 2. Detrend
% 2. Fill gaps.
% 4. Determine the target pixel's 4-connected neighbors.
%
% INPUTS
%     targetIdx
%
% OUTPUTS
%
%     pixelTsArr   : An array of structures containing time series and the
%     |              associated lags to use in the model. The first element
%     |              of this array MUST represent the time series for which 
%     |              predictions are desired.
%     |-.ts        : The time series data array.
%     |-.gaps      : Gap indicators for the time series.
%     |-.nbrInd    : Indices of the pixel's neighbors in tsArr.
%     |-.lags      : An array of integer lags.
%      -.label     : A descriptive label
%
%     trendMat     : An nCadences x nPixels matrix whose columns contain
%                    the trend removed from each pixel.
%
%                    originalPixelTs(i) = PixelTsArr(i).uncertainty * 
%                        (pixelTsArr(i).ts + trendMat(:,i))
%
% NOTES:
%     The output time series should be approximately constant mean and
%     the *innovation* process should have approximately constant variance.
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
    tsStruct = struct('ts',[],'gaps',[],'nbrInd', [],'lags',[],'p',[], ...
                      'label','');
    nCadences = length(obj.timestamps);
    targetStruct = obj.targetArray(targetIdx);
    
    %----------------------------------------------------------------------
    % Do variance stabilization and fill gaps for all target pixels.
    %----------------------------------------------------------------------
    nPixels = numel(targetStruct.pixelDataStruct);
    pixelTsArr = repmat(tsStruct, [nPixels, 1]);
    trendMat = zeros(nCadences, nPixels);

    for k = 1:nPixels
        pixelStruct           = targetStruct.pixelDataStruct(k);
        pixelFlux             = pixelStruct.values;
        pixelGaps             = pixelStruct.gapIndicators;
        pixelUncertainties    = pixelStruct.uncertainties;
        
        % Normalize variance.
        pixelFlux(~pixelGaps) = pixelFlux(~pixelGaps) ...
                                ./ pixelUncertainties(~pixelGaps); 
        
        % Detrend
        [detrended, trend]    = medfilt_detrend_with_linear_gap_fill( ...
                                    pixelFlux, pixelGaps, ...
                                    obj.params.longMedianFilterLength);
        trendMat(:,k)         = trend;
        pixelTsArr(k).ts      = detrended;            

        pixelTsArr(k).gaps    = pixelGaps;
        
        % Add a label containing pixel position, if available.
        labelString = 'pixel';
        if isfield(pixelStruct, 'ccdRow')
            labelString ...
                = [labelString, ', row=', num2str(pixelStruct.ccdRow)];
        end
        if isfield(pixelStruct, 'ccdColumn')
            labelString ...
                = [labelString, ', col=', num2str(pixelStruct.ccdColumn)];
        end
        pixelTsArr(k).label   = labelString;
    end    
end


function [detrended, trend] = medfilt_detrend_with_linear_gap_fill( ts, ...
                                                 gapIndicators, medfiltLen)
%**************************************************************************  
% [detrended, trend] = medfilt_detrend_with_ar_gap_fill( ts, ...
%                                               gapIndicators, medfiltLen )
%**************************************************************************  
% Detrend a time series.
%
% INPUTS:
%     ts            : An N-length real array representing a time series.
%     gapIndicators : An N-length logical array of gap indicators. If 
%                     gapIndicators(i) == true, then ts(i) is treated as
%                     missing data.
%     medfiltLen    : Optional window size for the median filter. 
%
% OUTPUTS:
%     detrended     : ts - trend.
%     trend         : The median filter output after filling gaps and
%                     extending endpoints. 
%
%************************************************************************** 
    if ~exist('gapIndicators','var')
        gapIndicators = false(size(ts));
    end

    if ~exist('medfiltLen','var')
        medfiltLen = 49;
    end

    filled = cosmicRayCleanerClass.linear_gap_fill(ts, gapIndicators);
    trend  = cosmicRayCleanerClass.padded_median_filter(filled(:), ...
                                                        medfiltLen);
    
    % Return a vector of the same dimensions as ts.
    detrended = reshape(filled(:) - trend, size(ts));
end

%********************************** EOF ***********************************
