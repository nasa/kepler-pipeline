function [attitudeSolutionStruct, pdqOutputStruct] = obtain_attitude_solution(pdqScienceObject,attitudeSolutionStruct, pdqOutputStruct, raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [attitudeSolutionStruct, pdqOutputStruct] =
% obtain_attitude_solution(pdqScienceObject,attitudeSolutionStruct,
% pdqOutputStruct, raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%
% Step 1: collect the sky coordinates (RA and Dec) and the measured
% centroidRows and centroidColumns for all stars on all modouts
%
% Step 2: abberate the real positions (ra, dec) of each star to the apparent
% position
%
% Step 3: Obtain an attitude initial guess. Test to see if a previous
% attitude solution exists. If it does - use it. If it does not - use
% the nominal pointing position value provided by FC Constants.
%
% Step 4: Run iterate_attitude_solution_using_robust_fit() to obtain
% attitude solution and also run
% iterate_attitude_solution_using_nlinfit to obtain another solution;
% keep the better of the two.
% % if any of the centroidRows or centroidColumns are -ve, remove them and
% remove corresponding rows and columns form  covariance matrix too
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

%
% attitudeSolutionStruct(1)
%             raStars: [1354x1 double]
%            decStars: [1354x1 double]
%        centroidRows: [1354x1 double]
%     centroidColumns: [1354x1 double]
%        CcentroidRow: [1354x1354 double]
%     CcentroidColumn: [1354x1354 double]
%           ccdModule: [1354x1 double]
%           ccdOutput: [1354x1 double]
%         cadenceTime: 2454814.5
%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Get current cadence times and number of cadences
numCadences      = length(attitudeSolutionStruct);


% this parameter is to reject centroids that might be gross outliers
madThresholdForCentroidOutliers = pdqScienceObject.pdqConfiguration.madThresholdForCentroidOutliers;


% Initialize previous attitude
if (size(pdqScienceObject.inputPdqTsData.attitudeSolutionRa, 2) == 3)
    previousAttitude =  [pdqScienceObject.inputPdqTsData.attitudeSolutionRa(end) ...
        pdqScienceObject.inputPdqTsData.attitudeSolutionDec(end) ...
        pdqScienceObject.inputPdqTsData.attitudeSolutionRoll(end)];
    pdqOutputStruct.previousAttitude = previousAttitude;
else
    previousAttitude = [-1 -1 -1];
end

%--------------------------------------------------------------------------
% Get the sky coordinates (RA and Dec) for all stars on all module outputs.
% Because of possible gaps in some of the cadences on some module ouputs
% the targets that have centroids calculated may be a subset of the total.
% The actual list of targets used for attitude determination must match
% those with centroids, and this is done using the gap indicators

% centroidRows & centroidCols must have real values in them.
% Otherwise issue an error.
% Use only those stars with good centroid measurements


% Allocate memory for results
attitudes               = -1*ones(numCadences,3);
attitudesUncertainties  = -1*ones(numCadences,3);
gapIndicators           = false(numCadences,1);





% Loop over all cadences present in the data
for cadenceIndex = 1 : numCadences



    %----------------------------------------------------------------------
    % Step 1: collect the sky coordinates (RA and Dec) and the measured
    % centroidRows and centroidColumns for all stars on all modouts
    %----------------------------------------------------------------------
    centroidRows     = attitudeSolutionStruct(cadenceIndex).centroidRows;
    centroidColumns  = attitudeSolutionStruct(cadenceIndex).centroidColumns;

    nValidCentroids = length(find(centroidRows ~= -1));

    if(nValidCentroids <= 2)

        warning('PDQ:attitudeSolution:notEnoughcentroids', ...
            ['attitudeSolution: only ' num2str(nValidCentroids) ' centroids available; not enough to compute attitude solution for this cadence ' num2str(cadenceIndex)]);

        gapIndicators(cadenceIndex) = true;
        continue;
    end


    %----------------------------------------------------------------------
    % Step 2: identify and remove centroids of saturated stars
    % the criterion for identifying out of family centroids is by (robust)
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
    
    
    indicesOfInFamilyCentroids = find(~outOfFamilyIndicators);
    % Need if/else loop because array size will be different depending on
    % whether previous code came from generate_attide_solution_data or
    % generate_attitude_solution_data_100s_cadences
    if numel(attitudeSolutionStruct(cadenceIndex).starIndexUsedForAttitudeSolution) == numel(outOfFamilyIndicators)
        % starIndexForRobustWeights = ...
        %     attitudeSolutionStruct(cadenceIndex).starIndexUsedForAttitudeSolution(~outOfFamilyIndicators);
        keplerIdsAssociatedWithRobustWeights = ...
            attitudeSolutionStruct(cadenceIndex).keplerIds(indicesOfInFamilyCentroids);
    else
        starIndexForRobustWeights = intersect(indicesOfInFamilyCentroids, attitudeSolutionStruct(cadenceIndex).starIndexUsedForAttitudeSolution);
        keplerIdsAssociatedWithRobustWeights = ...
            attitudeSolutionStruct(cadenceIndex).keplerIds(starIndexForRobustWeights);
    end
    
    %outOfFamilyIndicators = centroidGapIndicators;
    invalidEntriesNow = find(outOfFamilyIndicators);

    centroidRows(invalidEntriesNow) = -1;
    centroidColumns(invalidEntriesNow) = -1;

    raStars    = attitudeSolutionStruct(cadenceIndex).raStars;
    decStars   = attitudeSolutionStruct(cadenceIndex).decStars;

    cadenceTimeStamp = attitudeSolutionStruct(cadenceIndex).cadenceTime;
    %----------------------------------------------------------------------
    % Step 2: abberate the real positions of each star to the apparent
    % position
    %----------------------------------------------------------------------
    cadenceTimeStampInJulian = cadenceTimeStamp + pdqScienceObject.raDec2PixModel.mjdOffset;

    [raStarsAber  decStarsAber ] = aberrate_ra_dec(raDec2PixObject,raStars, decStars, cadenceTimeStampInJulian);


    raStarsAber = raStarsAber(:);
    decStarsAber = decStarsAber(:);


    tic;

    %----------------------------------------------------------------------
    % Step 3: Obtain an attitude initial guess. Test to see if a previous
    % attitude solution exists. If it does - use it. If it does not - use
    % the nominal pointing position value provided by FC Constants.
    %----------------------------------------------------------------------
    if (~any(previousAttitude ~= -1))
        fovCenter   = attitudeSolutionStruct(cadenceIndex).nominalPointing;
        boreSightRa         = fovCenter(1);
        boreSightDec        = fovCenter(2);
        boreSightRoll       = fovCenter(3);
    else
        boreSightRa         = previousAttitude(1);
        boreSightDec        = previousAttitude(2);
        boreSightRoll       = previousAttitude(3);
    end

    %----------------------------------------------------------------------
    % Step 4: Run iterate_attitude_solution_using_robust_fit() to obtain
    % attitude solution and also run
    % iterate_attitude_solution_using_nlinfit to obtain another solution;
    % keep the better of the two.
    %----------------------------------------------------------------------


    dvaFlag = 0;


    %     [boreSightRaNew, boreSightDecNew, boreSightRollNew, attitudeError, CdeltaAttitudes] = ...
    %         iterate_attitude_solution_using_chisquare_fit(raDec2PixObject,raStarsAber, decStarsAber ,centroidRows, centroidColumns,...
    %         CcentroidRow, CcentroidColumn,     boreSightRa, boreSightDec, boreSightRoll, cadenceTimeStamp, dvaFlag);

    [boreSightRaLinFit, boreSightDecLinFit, boreSightRollLinFit, attitudeErrorLinFit, CdeltaAttitudesLinFit] = ...
        iterate_attitude_solution_using_robust_fit(raDec2PixObject,raStarsAber, decStarsAber ,centroidRows, centroidColumns,...
        CcentroidRow, CcentroidColumn,     boreSightRa, boreSightDec, boreSightRoll, cadenceTimeStamp, dvaFlag);

    boreSightRa = boreSightRaLinFit;
    boreSightDec = boreSightDecLinFit;
    boreSightRoll = boreSightRollLinFit;

    [boreSightRaNew, boreSightDecNew, boreSightRollNew, attitudeError, CdeltaAttitudes, robustWeights] = ...
        iterate_attitude_solution_using_nlinfit(raDec2PixObject,raStarsAber, decStarsAber ,centroidRows, centroidColumns,...
        CcentroidRow, CcentroidColumn, boreSightRa, boreSightDec, boreSightRoll, cadenceTimeStamp, dvaFlag);

    disp(sprintf(['Cadence: ' int2str(cadenceIndex) '  RA = %9.5f Dec = %9.5f Roll = %9.5f attitudeError = %9.5f'], boreSightRaNew,...
        boreSightDecNew, boreSightRollNew, attitudeError));

    attitudes(cadenceIndex, :) = [boreSightRaNew, boreSightDecNew, boreSightRollNew];

    attitudesUncertainties(cadenceIndex, :) = sqrt(diag(CdeltaAttitudes));

    attitudeSolutionStruct(cadenceIndex).CdeltaAttitudes = CdeltaAttitudes;
    attitudeSolutionStruct(cadenceIndex).robustWeights = robustWeights;
    attitudeSolutionStruct(cadenceIndex).outOfFamilyIndicators = outOfFamilyIndicators;
    attitudeSolutionStruct(cadenceIndex).indicesOfInFamilyCentroids = indicesOfInFamilyCentroids(:);
    attitudeSolutionStruct(cadenceIndex).keplerIdsAssociatedWithRobustWeights = ...
        keplerIdsAssociatedWithRobustWeights(:);

    duration = toc;
    disp(sprintf('CPU time = %8.3f', duration));
end

% RLM 2/16/11 -- commented:
% if(sum(gapIndicators) == numCadences)
%     error('PDQ:attitudeSolution:notEnoughcentroids', ...
%         'attitudeSolution: could not compute attitude solution for any of the cadences...');
% 
% end


% Obtain pre-existing time series
% Append - if time series contains previous results
% all of the following are structures
attitudeSolutionRa      = pdqScienceObject.inputPdqTsData.attitudeSolutionRa;
attitudeSolutionDec     = pdqScienceObject.inputPdqTsData.attitudeSolutionDec;
attitudeSolutionRoll    = pdqScienceObject.inputPdqTsData.attitudeSolutionRoll;

% pdqScienceObject.inputPdqTsData.attitudeSolutionRa
%            values: []
%     gapIndicators: []
%     uncertainties: []
% pdqScienceObject.inputPdqTsData.attitudeSolutionDec
%            values: []
%     gapIndicators: []
%     uncertainties: []
% pdqScienceObject.inputPdqTsData.desiredAttitudeRa
%            values: []
%     gapIndicators: []
%     uncertainties: []
%


if(isempty(attitudeSolutionRa.values)) % safe to assume if Ra is empty so are Dec and Roll

    attitudeSolutionRa.values   = attitudes(:, 1);
    attitudeSolutionDec.values  = attitudes(:, 2);
    attitudeSolutionRoll.values = attitudes(:, 3);

    attitudeSolutionRa.uncertainties      = attitudesUncertainties(:, 1);
    attitudeSolutionDec.uncertainties     = attitudesUncertainties(:, 2);
    attitudeSolutionRoll.uncertainties    = attitudesUncertainties(:, 3);

    % what about gap indicators? does not make sense to have a gap
    % in attitude solution.....but to complete the structure fill anyway...
    attitudeSolutionRa.gapIndicators   = gapIndicators;
    attitudeSolutionDec.gapIndicators  = gapIndicators;
    attitudeSolutionRoll.gapIndicators = gapIndicators;

else

    attitudeSolutionRa.values      = [attitudeSolutionRa.values(:); attitudes(:, 1)];
    attitudeSolutionDec.values     = [attitudeSolutionDec.values(:); attitudes(:, 2)];
    attitudeSolutionRoll.values    = [attitudeSolutionRoll.values(:); attitudes(:, 3)];

    attitudeSolutionRa.uncertainties      = [attitudeSolutionRa.uncertainties(:); attitudesUncertainties(:, 1)];
    attitudeSolutionDec.uncertainties     = [attitudeSolutionDec.uncertainties(:); attitudesUncertainties(:, 2)];
    attitudeSolutionRoll.uncertainties    = [attitudeSolutionRoll.uncertainties(:); attitudesUncertainties(:, 3)];

    attitudeSolutionRa.gapIndicators      = [attitudeSolutionRa.gapIndicators(:); gapIndicators(:)];
    attitudeSolutionDec.gapIndicators     = [attitudeSolutionDec.gapIndicators(:); gapIndicators(:)];
    attitudeSolutionRoll.gapIndicators    = [attitudeSolutionRoll.gapIndicators(:); gapIndicators(:)];

end
% Sort time series using the time stamps as a guide


% uncomment later.....

[allTimes sortedTimeSeriesIndices] = ...
    sort([pdqScienceObject.inputPdqTsData.cadenceTimes(:); ...
    pdqScienceObject.cadenceTimes(:)]);


attitudeSolutionRa.values      = attitudeSolutionRa.values(sortedTimeSeriesIndices);
attitudeSolutionDec.values     = attitudeSolutionDec.values(sortedTimeSeriesIndices);
attitudeSolutionRoll.values    = attitudeSolutionRoll.values(sortedTimeSeriesIndices);

attitudeSolutionRa.uncertainties      = attitudeSolutionRa.uncertainties(sortedTimeSeriesIndices);
attitudeSolutionDec.uncertainties     = attitudeSolutionDec.uncertainties(sortedTimeSeriesIndices);
attitudeSolutionRoll.uncertainties    = attitudeSolutionRoll.uncertainties(sortedTimeSeriesIndices);


attitudeSolutionRa.gapIndicators      = attitudeSolutionRa.gapIndicators(sortedTimeSeriesIndices);
attitudeSolutionDec.gapIndicators     = attitudeSolutionDec.gapIndicators(sortedTimeSeriesIndices);
attitudeSolutionRoll.gapIndicators    = attitudeSolutionRoll.gapIndicators(sortedTimeSeriesIndices);


% Save new time series to pdqOutputStruct
% attitudeSolution time series is now ready for further analysis


pdqOutputStruct.outputPdqTsData.attitudeSolutionRa     = attitudeSolutionRa;
pdqOutputStruct.outputPdqTsData.attitudeSolutionDec    = attitudeSolutionDec;
pdqOutputStruct.outputPdqTsData.attitudeSolutionRoll   = attitudeSolutionRoll;

%pdqOutputStruct.outputPdqTsData.newCadenceTimes                    = cat(1,attitudeSolutionStruct.cadenceTime);
pdqOutputStruct.outputPdqTsData.cadenceTimes           = allTimes;
pdqOutputStruct.attitudeSolution                       = attitudes; % nCadences X 3


pdqOutputStruct.attitudeSolutionUncertaintyStruct = attitudeSolutionStruct;

return



