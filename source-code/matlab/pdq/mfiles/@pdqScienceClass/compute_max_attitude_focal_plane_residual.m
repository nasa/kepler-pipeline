function [pdqOutputStruct] = compute_max_attitude_focal_plane_residual(pdqScienceObject, pdqOutputStruct,raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [pdqOutputStruct] =
% compute_max_attitude_focal_plane_residual(pdqScienceObject,
% pdqOutputStruct,raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This script computes the maximum offset between measured "star" (extreme
% corners of FOV on the visible CCD) positions and the mapped star
% positions given the attitude solution. It is a measure of goodness of the
% computed attitude solution.
%
% Step 1
% Define extreme corners (artificial stars) of the active field of view (5
% pixels in from the edges) There are 20 masked smear cornerStarRows & 12
% leading black cornerStarColumns row = 26 column = 18
%
% Step 2
% using pix2RaDec and nominal attitude, map these "corners" to {ra, dec}
%
% Step 3
% Using raDec2Pix and actual attitude, map those artificial stars'
% ("corners") {ra, dec} to {row, col}
%
% Step 4
% Compute distance each "star" moved in row, col space and get the
% maximum distance over the entire focal plane
%
% step 5
% concatenate current time series with historical time series
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

% Define extreme corners of the field of view (5 pixels in from the
% edges)
%
% mod = 2  out = 4 modOut = 4   row = 13 col = 21
% mod = 4  out = 3 modout = 11
% mod = 6  out = 3 modOut = 15
% mod = 10 out = 4 modOut = 32
% mod = 16 out = 4 modOut = 56
% mod = 20 out = 3 modOut = 71
% mod = 22 out = 3 modOut = 75
% mod = 24 out = 4 modout = 84


%--------------------------------------------------------------------------
% Step 1
% Define extreme corners (artificial stars) of the active field of view (5
% pixels in from the edges) There are 20 masked smear cornerStarRows & 12 leading
% black cornerStarColumns row = 26 column = 18
%--------------------------------------------------------------------------

pointingObject = pointingClass(get(raDec2PixObject,'pointingModel'));

modules             = [ 2  2  3  3  4  4  6  6  11  11  16  16  22  22  23   23  24  24  20  20  15  15 10 10]';
outputs             = [ 4  3  3  4  4  3  3  4   3   4   3   4   3   4   3   4   3    4   3   4   3  4   3  4]';
cornerStarRows      = repmat(26,24,1);
cornerStarColumns   = repmat(18, 24,1);

cadenceTimes        = pdqScienceObject.cadenceTimes; % in MJD
nCadences           = length(cadenceTimes);
nCornerStars        = length(cornerStarRows);


rowErrors = zeros(nCadences,nCornerStars);
columnErrors = zeros(nCadences,nCornerStars);

maxAttitudeDistanceError = zeros(nCadences,1);
maxAttitudeDistanceErrorUncertainty = zeros(nCadences,1);


for jCadence = 1 : nCadences

    %--------------------------------------------------------------------------
    % Step 2
    % using pix2RaDec and nominal attitude, map these "corners" to {ra, dec}
    %--------------------------------------------------------------------------
    aberrateFlag = 1; % not a boolean


    nominalPointing        = get_pointing(pointingObject, cadenceTimes(jCadence));
    raNominalPointing      = nominalPointing(1);
    decNominalPointing     = nominalPointing(2);
    rollNominalPointing    = nominalPointing(3);

    [raAber, decAber] = pix_2_ra_dec_absolute(raDec2PixObject, modules, outputs, cornerStarRows, cornerStarColumns, cadenceTimes(jCadence), ...
        raNominalPointing, decNominalPointing, rollNominalPointing, aberrateFlag);

    %--------------------------------------------------------------------------
    % Step 3
    % Using raDec2Pix and actual attitude, map those artificial stars'
    % ("corners") {ra, dec} to {row, col}
    %--------------------------------------------------------------------------
    actualAttitude = pdqOutputStruct.attitudeSolution(jCadence, :); % nCadences X 3


    if(any(actualAttitude == -1))

        warning('PDQ:computeMaxAttitudeError:noAttitudeSolution', ...
            ['can''t compute maxAttitudeResidualInPixels for cadence ' num2str(jCadence) ' as the attitude solution is unavailable'] );
        continue;
    end

    raActualPointing      = actualAttitude(1);
    decActualPointing     = actualAttitude(2);
    rollActualPointing    = actualAttitude(3);

    [modulesMapped outputsMapped rowsMapped columnsMapped] = ra_dec_2_pix_absolute(raDec2PixObject, raAber, decAber, cadenceTimes(jCadence), ...
        raActualPointing, decActualPointing, rollActualPointing, aberrateFlag);

    % detect errors in mapping
    if(~isequal(modules,modulesMapped)|| ~isequal(outputs,outputsMapped))
        error('PDQ:computeMaxAttitudeError:raDec2PixMappingFailed', ...
            'raDec2Pix mapping the corners of FOV on to differenet modules/outputs');
    end

    distancesMoved = sqrt( (cornerStarRows - rowsMapped).^2 + (cornerStarColumns - columnsMapped).^2 );

    
    rowErrors(jCadence,:) = (cornerStarRows - rowsMapped);
    columnErrors(jCadence,:) = (cornerStarColumns - columnsMapped);
    
    %--------------------------------------------------------------------------
    % Step 4
    % Compute distance each "star" moved in row, col space and get the
    % maximum distance over the entire focal plane
    %--------------------------------------------------------------------------

    maxAttitudeDistanceError(jCadence) = max(distancesMoved);

    %--------------------------------------------------------------------------
    % Step 5
    % compute numerical(finite difference approximation) jacobian T
    % (transformation from reconstructed attitude -> max attitude focal
    % plane residual)
    %--------------------------------------------------------------------------

    % set up deltaRa and deltaDec and deltaRot for establishing gradients (one
    % arcsec offsets)
    
    
    derivStep = eps^(1/3); % from statset('nlinfit'), used to compute numerical jacobian
    
    deltaRa     = [derivStep; 0; 0];
    deltaDec    = [0; derivStep; 0];
    deltaRot    = [0; 0; derivStep];


    deltaRaDecRoll = [deltaRa deltaDec deltaRot];


    TattitudeToMetric = zeros(3,1);

    rowsOffset = zeros(nCornerStars, numel(deltaRa));

    colsOffset = zeros(nCornerStars, numel(deltaRa));


    for i = 1 : numel(deltaRa)

        [modulesMapped outputsMapped rowsOffset(:,i) colsOffset(:,i)] = ra_dec_2_pix_absolute(raDec2PixObject, raAber, decAber, cadenceTimes(jCadence), ...
            raActualPointing+deltaRa(i), decActualPointing+deltaDec(i), rollActualPointing+deltaRot(i), aberrateFlag);



        % detect errors in mapping
        if(~isequal(modules,modulesMapped)|| ~isequal(outputs,outputsMapped))
            error('PDQ:computeMaxAttitudeError:raDec2PixMappingFailed', ...
                'raDec2Pix mapping the corners of FOV on to differenet modules/outputs');
        end

        distancesOffset = sqrt( (cornerStarRows - rowsOffset(:,i) ).^2 + (cornerStarColumns - colsOffset(:,i)).^2 );

        %--------------------------------------------------------------------------
        % Step 4
        % Compute distance each "star" moved in row, col space and get the
        % maximum distance over the entire focal plane
        %--------------------------------------------------------------------------

        TattitudeToMetric(i) =   (max(distancesOffset) - maxAttitudeDistanceError(jCadence)) /deltaRaDecRoll(i,i);

    end

    CdeltaAttitudes =  pdqOutputStruct.attitudeSolutionUncertaintyStruct(jCadence).CdeltaAttitudes;
    maxAttitudeDistanceErrorUncertainty(jCadence) =  sqrt(TattitudeToMetric' * CdeltaAttitudes *  TattitudeToMetric);


end

%--------------------------------------------------------------------------
% concatenate current time series with historical time series
%--------------------------------------------------------------------------

% Retrieve the existing brightness metric structure if any (will be empty if it does
% not exist
maxAttitudeResidualInPixels   = pdqScienceObject.inputPdqTsData.maxAttitudeResidualInPixels;


if (isempty(maxAttitudeResidualInPixels.values))

    maxAttitudeResidualInPixels.values        = maxAttitudeDistanceError(:);

    maxAttitudeResidualInPixels.uncertainties = maxAttitudeDistanceErrorUncertainty(:);

    % no  gaps associated with this metric
    maxAttitudeResidualInPixels.gapIndicators = false(length(maxAttitudeDistanceError),1);

else

    maxAttitudeResidualInPixels.values = [maxAttitudeResidualInPixels.values(:); maxAttitudeDistanceError(:)];



    maxAttitudeResidualInPixels.uncertainties = [maxAttitudeResidualInPixels.uncertainties(:); maxAttitudeDistanceErrorUncertainty(:)];

    % no  gaps associated with this metric
    gapIndicators = false(length(maxAttitudeResidualInPixels.values));


    maxAttitudeResidualInPixels.gapIndicators = [maxAttitudeResidualInPixels.gapIndicators(:); gapIndicators(:)];

    % Sort time series using the time stamps as a guide
    [allTimes sortedTimeSeriesIndices] = ...
        sort([pdqScienceObject.inputPdqTsData.cadenceTimes(:); ...
        pdqScienceObject.cadenceTimes(:)]);

    maxAttitudeResidualInPixels.values          = maxAttitudeResidualInPixels.values(sortedTimeSeriesIndices);
    maxAttitudeResidualInPixels.uncertainties   = maxAttitudeResidualInPixels.uncertainties(sortedTimeSeriesIndices);
    maxAttitudeResidualInPixels.gapIndicators   = maxAttitudeResidualInPixels.gapIndicators(sortedTimeSeriesIndices);

end
%--------------------------------------------------------------------------
% Save results in pdqOutputStruct
% This is a time series for tracking and trending
%--------------------------------------------------------------------------
pdqOutputStruct.outputPdqTsData.maxAttitudeResidualInPixels = maxAttitudeResidualInPixels;



plot(columnErrors(:), rowErrors(:), 'mo', 'MarkerEdgeColor','k','MarkerFaceColor',[.49 1 .63], 'MarkerSize',12);

title('Measured vs. computed star positions on the extreme corners of the focal plane');
xlabel('column error in pixels');
ylabel('row error in pixels');
paperOrientationFlag = false;
includeTimeFlag = false;
printJpgFlag = false;
fileNameStr = 'Measured vs. computed star positions on the extreme corners of the focal plane';
plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
close all;

return

