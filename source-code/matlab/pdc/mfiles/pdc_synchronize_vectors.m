%************************************************************************************************************
% function [synchronizedVectors, syncFailed] = pdc_synchronize_vectors (vectors, vectorCadenceTimes, ...
%               cadenceTimesToSyncTo, interpolationMethod)
%
% Synchronizes data at one cadence timestamp to another. Right now this assumes the <vectors> have no gaps.
% However, If using spline interpolation it does account for gaps in the cadence times. For fourier
% interpoaltion the input vectors MUST be continuous with no cadence gaps.
%
% The synchronization is performed using either a spline or a Fourier Transform interpolation. 
% Keep in mind that if the gap between subsequent vector input data points
% is too large the spline is not well constrained and will potentially return wild values.
%
% The function checks that the vector cadence times bracket the synchronize-to cadence times to within 1/10
% of a day. The spline interpolator works very poorly as an extarpolator. Right now it crashes in if sync-to
% cadences are not bracketed.
%
% WARNING: 'fourier' interpolation has not been well set up yet. Use at your own risk!
%
%************************************************************************************************************
% Inputs:
%   vectors              -- [float matrix(nCadences, nVectors)] The list of vectors to syncrhonize (can be just one)
%   vectorCadenceTimes   -- [cadenceTimesStruct] Standard cadenceTimes struct from PDC corresponding to the vectors
%   CadenceTimesToSyncTo -- [cadenceTimesStruct] Standard cadenceTimes struct to synchronize to.
%   interpolationMethod  -- [char] 'spline' or 'fourier'
%   
% Outputs:
%   synchronizedVectors  -- [float matrix(nCadences, nVectors)] The synchronized vectors
%   syncFailed           -- [logical] If true then vector cadences do not bracket sync to cadences
%
%************************************************************************************************************
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


function [synchronizedVectors, syncFailed] = pdc_synchronize_vectors (vectors, vectorCadenceTimes, ...
                    cadenceTimesToSyncTo, interpolationMethod )

doDebug = false;


nVectors = length(vectors(1,:));
nSyncToCadences = length(cadenceTimesToSyncTo.midTimestamps);

vectorCadenceTimestamps     = vectorCadenceTimes.midTimestamps;
vectorCadenceGapIndicators  = vectorCadenceTimes.gapIndicators;

cadencesToSyncToTimestamps      = cadenceTimesToSyncTo.midTimestamps;
cadencesToSyncToGapIndicators   = cadenceTimesToSyncTo.gapIndicators;

gapRemovedSyncToCadences = cadencesToSyncToTimestamps(~cadencesToSyncToGapIndicators);
gapRemovedVectorCadences = vectorCadenceTimestamps(~vectorCadenceGapIndicators);

% Make sure vector cadence data brackets sync to cadence data.
% Round to the nearest tenth of a day
if (ceil(10*min(gapRemovedSyncToCadences)) < floor(10*min(gapRemovedVectorCadences)) || ...
                floor(10*max(gapRemovedSyncToCadences)) > ceil(10*max(gapRemovedVectorCadences)) )
    syncFailed = true;
    synchronizedVectors = [];
    return;
else
    syncFailed = false;
end

if (doDebug)
    figure;
end

synchronizedVectors = zeros(nSyncToCadences, nVectors);
for iVector = 1 : nVectors

    % TODO: Fill in sync-to cadence gaps so that spline is well behaved

    % TODO: account for gaps in the vectors (that do not corresond to cadencetime gaps)

    
    switch interpolationMethod

    case ('spline')
        % Synchronize with a simple spline

        % We only want the vector data points where there are valid cadencetimes
        thisGapRemovedVector  = vectors(~vectorCadenceGapIndicators, iVector);

        synchronizedVectors(~cadencesToSyncToGapIndicators,iVector) = ...
                            spline (gapRemovedVectorCadences, thisGapRemovedVector, gapRemovedSyncToCadences);
 
        if (doDebug)
            % Plotting
            plot(gapRemovedVectorCadences, thisGapRemovedVector, '-ob')
            hold on;
            plot(gapRemovedSyncToCadences, synchronizedVectors(~cadencesToSyncToGapIndicators,iVector), '-*r')
            hold off;
            pause;
        end

    case ('fourier')

        % Use Jeff K's fourier interpolator
        % NOTE: This method ASSUMES the input vector is continious with evenly spaced cadences

        % Find the cadence range to interpolate from
        firstCadenceIndexToUse = find(gapRemovedVectorCadences < gapRemovedSyncToCadences(1));
        if (isempty(firstCadenceIndexToUse))
            firstCadenceIndexToUse = 1;
        else
            firstCadenceIndexToUse = firstCadenceIndexToUse(end);
        end

        lastCadenceIndexTouse  = find(gapRemovedVectorCadences > gapRemovedSyncToCadences(end));
        if (isempty(lastCadenceIndexTouse))
            lastCadenceIndexTouse = length(gapRemovedVectorCadences);
        else
            lastCadenceIndexTouse  = lastCadenceIndexTouse(1);
        end

        vectorIndicesToUse = firstCadenceIndexToUse:lastCadenceIndexTouse;
        syncFromCadences    = gapRemovedVectorCadences(vectorIndicesToUse);

        % Taking mean should account for and remove outliers due to cadence gaps.
        syncToCadenceLength = median(diff(gapRemovedSyncToCadences));
        vectorCadenceLength = median(diff(syncFromCadences));
        % If this isn't 30 then think really carefully about what's going on!
        interpolationRatio = round(vectorCadenceLength / syncToCadenceLength);

        % padCount is offset from interpolated Vector
        [~, nearestVectorCadenceIndex] = min(abs(syncFromCadences - gapRemovedSyncToCadences(1)));
        nearestVectorCadence  = syncFromCadences(nearestVectorCadenceIndex);
        padCount = round(mod(nearestVectorCadence - gapRemovedSyncToCadences(1), syncToCadenceLength));
        padCount = 5;


        interpolatedVector = fourier_interpolate ...
                            (vectors(vectorIndicesToUse,iVector), interpolationRatio, padCount);
        synchronizedVectors(:,iVector) = interpolatedVector(1:length(synchronizedVectors(:,iVector)));


        if (doDebug)
            % Plotting
            plot(syncFromCadences, vectors(vectorIndicesToUse, iVector), '-ob')
            hold on;
            plot(gapRemovedSyncToCadences, synchronizedVectors(~cadencesToSyncToGapIndicators,iVector), '-*r')
            hold off;
            pause;
        end

    otherwise
        error('pdc_synchronize_vectors: unknown interpolation method');
    end

end


end

%************************************************************************************************************
% function [ vectorOut ] = fourier_interpolate( vectorIn, interpolationRatio, padCount)
%
% Interpolates a vector where ensuring there is no signal content above the Nyquist frequency of the old
% vector in the new vector. This function does NOT account for arbitrary input and output cadences by virture
% of it performing in the fourier transformed domain.
%
% Here's Jeff K's header for this function:
%interpolateLCVectorToSCVector interpolates with minimal HF noise features
%   High frequencies (>1/(2 LC)) result only from the step between last and first values in output vector.
%
% JCS is generalizing this so that the ratio for interpolation is more general however I don't know how well
% this will work if not interpolating from LC to SC.
% 
% Inputs:
%   VectorIn           -- [double array] The original vector to interpolate
%   InterpolationRatio -- [int] Ratio of interpolated cadence to original cadences (i.e. 30 for LC -> SC) 
%   padCount           -- [int] Offset from interpolated vector (i.e. how many interpolated cadences before the
%                               first orginal cadence? Odd number required).
%
% Outputs:
%   vectorOut          -- [double array] the interpolated vector

function [ vectorOut ] = fourier_interpolate ( vectorIn, interpolationRatio, padCount )

if (padCount ~= 0 && mod(padCount,2) ~= 1)
    padCount = padCount + 1;
end

% constants
lengthInLongCadences=length(vectorIn);
POLYNOMIAL_ORDER=3;
augmentedLengthInLC=lengthInLongCadences+padCount;
lengthOutShortCadences=lengthInLongCadences*interpolationRatio;

if (padCount ~= 0)
    offsetStart=floor(padCount/2)+1;
    % Need to extrapolate past the offset if there is a mismatch
    % connect end and beginning of input vector with a smooth curve
    xFitVector=[-offsetStart-1;-offsetStart;offsetStart;offsetStart+1];
    yFitVector=[vectorIn(end-1:end);vectorIn(1:2)];
    polynomialCoefficients=polyfit(xFitVector,yFitVector,POLYNOMIAL_ORDER);
    xFillVector=-offsetStart+1:offsetStart-1;
    yFillVector=polyval(polynomialCoefficients,xFillVector);
    augmentedInput=[ yFillVector(offsetStart:padCount)'; vectorIn; yFillVector(1:offsetStart-1)' ];
    fftOfAugmentedInput=fft(augmentedInput);
    offsetFromSyntheticVector=round(interpolationRatio*(offsetStart-0.5));
    rangeOut=(1:lengthOutShortCadences)+offsetFromSyntheticVector;
else
    offsetStart = 0;
    fftOfAugmentedInput=fft(vectorIn);
    rangeOut = (1:lengthOutShortCadences)+round(interpolationRatio*(0.5));
end

% synthesize a spectrum at SC with exactly the same spectrum as augmented input at frequencies <1/(2LC)
syntheticShortCadenceAmplitudeSpectrum=zeros(augmentedLengthInLC*interpolationRatio,1);
lengthSplitBins=floor(augmentedLengthInLC/2);
syntheticShortCadenceAmplitudeSpectrum(1:lengthSplitBins+1)=fftOfAugmentedInput(1:lengthSplitBins+1);
syntheticShortCadenceAmplitudeSpectrum(end-lengthSplitBins+1:end)=fftOfAugmentedInput(end-lengthSplitBins+1:end);
    
% synthesize a SC time series from spectrum
syntheticShortCadenceVector=ifft(syntheticShortCadenceAmplitudeSpectrum);

% truncate to include only the interpolation range around original data
% rescale*interpolationRatio to account for MATLAB fft normalization convention
vectorOut=syntheticShortCadenceVector(rangeOut)*interpolationRatio;

end
