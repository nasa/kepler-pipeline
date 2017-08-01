function  plot_residual_centroid_time_series(madThresholdForCentroidOutliers,attitudeSolutionStruct, raDec2PixObject)


% Get current cadence times and number of cadences
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
numCadences      = length(attitudeSolutionStruct);

% this parameter is to reject centroids that might be gross outliers
% madThresholdForCentroidOutliers

% Loop over all cadences present in the data
for cadenceIndex = 1 : numCadences
    
    %----------------------------------------------------------------------
    % Step 1: collect the sky coordinates (RA and Dec) and the measured
    % centroidRows and centroidColumns for all stars on all modouts
    %----------------------------------------------------------------------
    centroidRows     = attitudeSolutionStruct(cadenceIndex).centroidRows;
    centroidColumns  = attitudeSolutionStruct(cadenceIndex).centroidColumns;
    
    
    %----------------------------------------------------------------------
    % Step 2: repeat what was done in obtain_attitude-solution to identify
    % and remove centroids of saturated stars.
    % The criterion for identifying out of family centroids is by (robust)
    % fitting a quadratic function separately to the row and column
    % centroids as a function of kepler magnitude, and setting an indicator
    % to true if the row or column residual for any target is more than a
    % specified number of MAD's from the median. Tagging of targets as
    % outliers merely indicates that the uncertainties are not appropriate
    % for targets of specified kepler magnitude. If the kepler magnitude
    % itself is incorrect for some reason, then we risk rejecting good
    % targets based on this criterion.
    %----------------------------------------------------------------------
    CcentroidColumn = attitudeSolutionStruct(cadenceIndex).CcentroidColumn;
    CcentroidRow = attitudeSolutionStruct(cadenceIndex).CcentroidRow;
    
    
    % if any of the centroidRows or centroidColumns are -ve, remove them and
    % remove corresponding rows and columns form  covariance matrix too
    centroidColumnUncertainties = sqrt(diag(CcentroidColumn));
    centroidRowUncertainties = sqrt(diag(CcentroidRow));
    keplerMags = attitudeSolutionStruct(cadenceIndex).keplerMags;
    centroidGapIndicators = false(length(keplerMags), 1);
    
    
    
    invalidRows = find(centroidRows <= 0);
    invalidColumns = find(centroidColumns <= 0);
    
    invalidEntries = [invalidRows; invalidColumns];
    invalidEntries = invalidEntries(:);
    
    centroidGapIndicators(invalidEntries) = true;
    
    [outOfFamilyIndicators] = ...
        identify_out_of_family_centroids(keplerMags, centroidRowUncertainties, ...
        centroidColumnUncertainties, centroidGapIndicators, madThresholdForCentroidOutliers);
    
    
    outOfFamilyIndicators = (outOfFamilyIndicators | centroidGapIndicators);
    
    invalidEntriesNow = find(outOfFamilyIndicators);
    validEntries = find(~outOfFamilyIndicators);
    
    
    attitudeSolutionStruct(cadenceIndex).invalidEntries = invalidEntriesNow;
    attitudeSolutionStruct(cadenceIndex).validEntries = validEntries;
    
    
    raStars    = attitudeSolutionStruct(cadenceIndex).raStars;
    decStars   = attitudeSolutionStruct(cadenceIndex).decStars;
    
    cadenceTimeStamp = attitudeSolutionStruct(cadenceIndex).cadenceTime;
    
    
    fovCenter   = attitudeSolutionStruct(cadenceIndex).nominalPointing;
    boreSightRa         = fovCenter(1);
    boreSightDec        = fovCenter(2);
    boreSightRoll       = fovCenter(3);
    dvaFlag = 1;
    
    
    %----------------------------------------------------------------------
    % Step 3 get predicted star row/column position
    % call ra_dec_2_pix_absolute to get current predicted star positions
    %----------------------------------------------------------------------
    
    if isempty(raStars) || isempty (decStars) % RLM 1/24/11 -- added check for empty structs
        return % RLM -- skip it for now. Nothing critical to PDQ after this point.
        
        rowStarsHat = [];
        colStarsHat = [];
    else
        [mm, oo, rowStarsHat, colStarsHat] = ...
            ra_dec_2_pix_absolute(raDec2PixObject, raStars, decStars, cadenceTimeStamp, boreSightRa, boreSightDec, boreSightRoll, dvaFlag);
    end
    attitudeSolutionStruct(cadenceIndex).starRows = rowStarsHat;
    attitudeSolutionStruct(cadenceIndex).starColumns = colStarsHat;
end


nStars = length(attitudeSolutionStruct(cadenceIndex).starRows);

centroidRowResidual = -ones(nStars, numCadences);
centroidColumnResidual = -ones(nStars, numCadences);

centroidRows = -ones(nStars, numCadences);
centroidColumns = -ones(nStars, numCadences);

starRows = -ones(nStars, numCadences);
starColumns = -ones(nStars, numCadences);


for jCadence = 1:numCadences
    
    invalidEntries = attitudeSolutionStruct(jCadence).invalidEntries;
    validEntries = attitudeSolutionStruct(jCadence).validEntries;
    
    centroidRowResidual(validEntries,jCadence) = attitudeSolutionStruct(jCadence).starRows(validEntries) - attitudeSolutionStruct(jCadence).centroidRows(validEntries);
    centroidColumnResidual(validEntries,jCadence) = attitudeSolutionStruct(jCadence).starColumns(validEntries) - attitudeSolutionStruct(jCadence).centroidColumns(validEntries);
    
    centroidRowResidual(invalidEntries,jCadence) = -1;
    centroidColumnResidual(invalidEntries,jCadence) =-1;
    
    centroidRows(validEntries,jCadence) = attitudeSolutionStruct(jCadence).centroidRows(validEntries);
    centroidColumns(validEntries,jCadence) = attitudeSolutionStruct(jCadence).centroidColumns(validEntries);
    centroidRows(invalidEntries,jCadence) = -1;
    centroidColumns(invalidEntries,jCadence) =-1;
    
    starRows(validEntries,jCadence) = attitudeSolutionStruct(jCadence).starRows(validEntries);
    starColumns(validEntries,jCadence) = attitudeSolutionStruct(jCadence).starColumns(validEntries);
    
end

save centroidResidualTimeHistory.mat attitudeSolutionStruct centroidRows centroidColumns starRows starColumns centroidRowResidual centroidColumnResidual;

%----------------------------------------------------------------------
% Histograms
%----------------------------------------------------------------------

figure;
hist(mean(centroidRowResidual,2),1000);
xlabel('pixels');
ylabel('count');
title({'Histogram of mean (over cadences) of centroid row residuals'; '(predicted centroid rows - computed centroid rows)'})


paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;
fileNameStr = 'Histogram of row residuals';
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);



figure;
hist(mean(centroidColumnResidual,2),1000);
xlabel('pixels');
ylabel('count');
title({'Histogram of mean (over cadences) of centroid column residuals'; '(predicted centroid columns - computed centroid columns)'})
fileNameStr = 'Histogram of column residuals';
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);


%----------------------------------------------------------------------
% generate random colors
%----------------------------------------------------------------------
colorSpec = zeros(nStars, 3); % R, G, B colors

shuffleOrder = randperm(nStars);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,1) = linspace(0.001, 1, nStars);
shuffleOrder = randperm(nStars);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,2) = linspace(0.001, 1, nStars);
shuffleOrder = randperm(nStars);
shuffleOrder = shuffleOrder(:);
colorSpec(shuffleOrder,3) = linspace(0.001, 1, nStars);


%----------------------------------------------------------------------
% Residual time series
%----------------------------------------------------------------------
figure;

for j=1:nStars
    validEntries = find(centroidRowResidual(j,:) ~= -1);
    plot(validEntries, centroidRowResidual(j,validEntries), '-', 'Color', colorSpec(j,:));
    hold on
end;

xlabel('cadence number');
ylabel('residuals in pixels');
title('Centroid row residual time series for all PDQ targets')
fileNameStr = 'Centroid row residual time series for all PDQ targets';

plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);


figure;

for j=1:nStars
    validEntries = find(centroidColumnResidual(j,:) ~= -1);
    plot(validEntries, centroidColumnResidual(j,validEntries), '-', 'Color', colorSpec(j,:));
    hold on
end;

xlabel('cadence number');
ylabel('residuals in pixels');
title('Centroid column residual time series for all PDQ targets')
fileNameStr = 'Centroid column residual time series for all PDQ targets';
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);

close all;
return
