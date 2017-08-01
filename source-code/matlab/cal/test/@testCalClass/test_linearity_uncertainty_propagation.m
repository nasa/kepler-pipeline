function [meanPixelErrorsEmpirical, meanPixelsErrorsPropagated] = test_linearity_uncertainty_propagation
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


nTrials = 1000;

% create pixel array to test full dynamic range
numCoadds = 270;

maxDN = 2^14-1;

pixelsStandard = repmat(linspace(1, maxDN, 1000)'*numCoadds, 1);

pixelsStandardGaps = zeros(size(pixelsStandard));

validPixelIndices = find(~pixelsStandardGaps);

debugFlag = 1;

gain = 116;


% magnitude of added noise
shotNoiseSquared = pixelsStandard / gain;

wSig = sqrt(shotNoiseSquared);
%wSig = mean(sqrt(shotNoiseSquared));

% define poly struct for input to weighted polyval
polyStruct.coeffs = [1.0130e+00  -2.1134e-02  4.9686e-03  5.15 12e-03 -5.3412e-03]';  % 5th order
polyStruct.covariance = [];
polyStruct.order = 5;
polyStruct.maxDomain = 10289;
polyStruct.xIndex = -1;
polyStruct.type = 'standard';
polyStruct.offsetx = 0.0;
polyStruct.scalex = 2.81801e-04;
polyStruct.originx = 3.45257e+03;

% coefficients from weighted_polyval are in opposite order needed for polyder
linearityPolyDerCoeffts = flipud(polyder(flipud(polyStruct.coeffs))')*polyStruct.scalex;

% define polyder struct for input to weighted polyval
polyderStruct.coeffs = linearityPolyDerCoeffts(:);
polyderStruct.covariance = [];  % not needed
polyderStruct.order = polyStruct.order - 1;
polyderStruct.type = polyStruct.type;
polyderStruct.offsetx = polyStruct.offsetx;
polyderStruct.scalex = polyStruct.scalex;
polyderStruct.originx = polyStruct.originx;


% preallocate pixels plus noise
pixelsPlusNoiseCorr = zeros(length(pixelsStandard), nTrials);

tic
for i = 1:nTrials

    % start with fresh (standard) set of pixels
    pixels = pixelsStandard;

    % create random noise
    wPixels = randn(length(pixels), 1).*wSig;

    % add noise to pixel array
    pixelsPlusNoise = pixels + wPixels;

    %----------------------------------------------------------------------
    % feed pixels with noise into nonlinearity correction function
    [correctedPixelsPlusNoise] = ...
        correct_for_nonlinearity(pixelsPlusNoise', validPixelIndices', polyStruct, polyderStruct, gain, numCoadds, 1);

    % output from function:
    pixelsPlusNoiseCorr(:, i) = correctedPixelsPlusNoise;

    %     duration = toc;
    %     if (debugFlag)
    %         display(['CAL: nonlinearity unit test: '  num2str(duration/60) ' minutes']);
    %     end
end

%--------------------------------------------------------------------------
% empirical RMS errors
%--------------------------------------------------------------------------
pixelsPlusNoiseCorrRMS = std((pixelsPlusNoiseCorr/numCoadds), 0, 2);

%----------------------------------------------------------------------
% evaluate the polynomials with the original (noise-less) pixels and 
% propagate errors for comparison:

[correctedPixelsNoNoise, uncertaintyStructNoNoise] = ...
    correct_for_nonlinearity(pixels', validPixelIndices', polyStruct, polyderStruct, gain, numCoadds, 1);

pixelsNoNoiseErrors = wSig .* uncertaintyStructNoNoise.TBlkCorrToNonlinCorr .* gain ./ numCoadds;

%% plot
if (debugFlag)
    figure

    plot(pixels, pixelsNoNoiseErrors, 'r.', ...
        pixelsPlusNoise, pixelsPlusNoiseCorrRMS, 'b.');

    xlabel('x')
    ylabel('Rms Uncertainties')
    legend('Propagation of Errors', 'Empirical Errors',0)
    title(['pixels', int2str(nTrials), ' Trials'])


end

meanPixelErrorsEmpirical = mean(pixelsNoNoiseErrors);
meanPixelsErrorsPropagated = mean(pixelsPlusNoiseCorrRMS);





