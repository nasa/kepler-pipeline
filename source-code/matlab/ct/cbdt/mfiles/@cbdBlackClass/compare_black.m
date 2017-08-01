function [cbdObj, differenceBlackModel] = compare_black(cbdObj, blackModels, badPixels)
% function [cbdObj, cleranFFIs] = compare_black(cbdObj, blackModels)
% compare the difference between black model and the measurements from FFIs
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

constants;

%% examine the measurements to determine the standard varation still in check.

% compute the 2D difference: model subtracted by measurement;
differenceBlackModel = double(blackModels.fc2dBlackModel - cbdObj.measured2DBlack);

if ( cbdObj.debugStatus )
    % show the difference between 2d black model and 2d black measurement
    meanDif = median( differenceBlackModel(:) );
    stdDif = 1;
    figure, imagesc(differenceBlackModel, [ meanDif - 3 * stdDif, meanDif + 3 * stdDif]); 
    axis xy;
    title('Difference of 2D black model and measurement');
    colorbar;
end

%%

% the difference between model and our measurement
cbdObj.difference2DBlackModel = single(differenceBlackModel);
cbdObj.differenceSignificanceMean2DBlackModel = mean(blackModels.fc2dBlackModel(:)) - cbdObj.measuredMeanBlack; % difference of two means of model and measurements

alpha = cbdObj.statisticalAlpha;

% Do we detect and remove the outliers before the test?
[h, prob, muhat, sighat] = compute_norm_significance(differenceBlackModel(:), alpha);

cbdObj.differenceSignificance2DBlackModel = prob;

if ( cbdObj.debugStatus )
    fprintf(' 2D Black measurement h = %1d; prob = %f; muhat = %f; sighat=%f\n', h, prob, muhat, sighat);
    figure, hist( differenceBlackModel(:), [ meanDif - 3 * stdDif : 0.1 : meanDif + 3 * stdDif]); title('Residuals of 2DBlackModel - 2DBlackMeasurement');
    xlim([ meanDif - 3 * stdDif, meanDif + 3 * stdDif]);
    xlabel('DN normalized by coAddNum');
    ylabel('Pixel Count');
end


return;
