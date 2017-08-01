function attitude_solution_monte_carlo(attitudeSolutionStruct, raDec2PixModel)

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


raDec2PixObject = raDec2PixClass(raDec2PixModel);

nRealizations = 100;


%fovCenter   = attitudeSolutionStruct(1).nominalPointing;
NOMINAL_FOV_CENTER_DEGREES = [290+40/60; 44.5; 0.0];
fovCenter   = NOMINAL_FOV_CENTER_DEGREES;


numCadences = length(attitudeSolutionStruct);

deltaUncertaintyStruct = repmat(struct('CdeltaAttitude',zeros(3,3)),nRealizations,1);
deltaUncertaintyStructNLF = deltaUncertaintyStruct;

uncertaintyStruct = repmat(struct('deltaUncertaintyStruct', deltaUncertaintyStruct), numCadences,1);
uncertaintyStructNLF = repmat(struct('deltaUncertaintyStructNLF', deltaUncertaintyStruct), numCadences,1);


zeromatrix                = zeros(numCadences, nRealizations);
boreSightRaLinearFit      = zeromatrix;
boreSightDecLinearFit     = zeromatrix;
boreSightRollLinearFit    = zeromatrix;
attitudeErrorLinearFit       = zeromatrix;
boreSightRaNonLinearFit      = zeromatrix;
boreSightDecNonLinearFit     = zeromatrix;
boreSightRollNonLinearFit    = zeromatrix;
attitudeErrorNonLinearFit       = zeromatrix;

%h = waitbar(0,'Please wait...');
% Loop over all cadences present in the data
for cadenceIndex = 1 : numCadences
    fprintf('cadence % d/%d\n', cadenceIndex, numCadences);



    % row, column centroid covariance matrices
    CcentroidColumn     = attitudeSolutionStruct(cadenceIndex).CcentroidColumn;
    CcentroidRow        = attitudeSolutionStruct(cadenceIndex).CcentroidRow;
    %         CcentroidColumn = diag(repmat(median(diag(CcentroidColumn)),size(diag(CcentroidColumn))));
    %         CcentroidRow    = diag(repmat(median(diag(CcentroidRow)),size(diag(CcentroidRow))));
    % get the time stamp for the current cadence
    cadenceTimeStamp    = attitudeSolutionStruct(cadenceIndex).cadenceTime;

    %----------------------------------------------------------------------
    % Step 1: aberrate the attitude because that's what FC API retrieves from
    % FC CSCI
    %------------------------------------------------------------------
    import gov.nasa.kepler.common.ModifiedJulianDate;
    cadenceTimeStampInJulian = cadenceTimeStamp + ModifiedJulianDate.MJD_OFFSET_FROM_JD;


    [ra0, dec0 ]        = aberrate_ra_dec(fovCenter(1), fovCenter(2), cadenceTimeStampInJulian);

    rot0                = fovCenter(3);

    % collect ra, dec of stars on this module
    raStars    = attitudeSolutionStruct(cadenceIndex).raStars;
    decStars   = attitudeSolutionStruct(cadenceIndex).decStars;

    nStars = length(raStars);

    if( (nStars ~= size(CcentroidColumn,1))||(nStars ~= size(CcentroidRow,1)) )
        CcentroidColumn = CcentroidColumn(1:nStars,1:nStars);
        CcentroidRow    = CcentroidRow(1:nStars,1:nStars);
    end

    % generate a new realization for each iteration
    %----------------------------------------------------------------------
    % Step 2: Aberrate the real positions of each star to the apparent
    % position
    %----------------------------------------------------------------------
    import gov.nasa.kepler.common.ModifiedJulianDate;
    cadenceTimeStampInJulian = cadenceTimeStamp + ModifiedJulianDate.MJD_OFFSET_FROM_JD;

    [raStarsAber  decStarsAber] = aberrate_ra_dec(raStars, decStars, cadenceTimeStampInJulian); % computationally efficient do just once
    raStarsAber     = raStarsAber(:);
    decStarsAber    = decStarsAber(:);

    %----------------------------------------------------------------------
    % Step 2: generate artificial centroids
    %----------------------------------------------------------------------

    aberrateFlag = 0;
    [module, output, predictedCentroidRows, predictedCentroidColumns] = ...
        ra_dec_2_pix_absolute(raDec2PixObject, raStarsAber, decStarsAber , cadenceTimeStamp, ra0,  dec0, rot0, aberrateFlag);


    measuredCentroidsStruct = repmat(struct('measuredCentroidRows',zeros(length(predictedCentroidRows),nRealizations),...
        'predictedCentroidRows',zeros(length(predictedCentroidRows)),...
        'measuredCentroidColumns',zeros(length(predictedCentroidRows),nRealizations),...
        'predictedCentroidColumns',zeros(length(predictedCentroidColumns)) ), numCadences,1);

    measuredCentroidsStruct(cadenceIndex).predictedCentroidRows = predictedCentroidRows;
    measuredCentroidsStruct(cadenceIndex).predictedCentroidColumns = predictedCentroidColumns;
    %----------------------------------------------------------------------
    % Step 3: perturb the artificial centroids using the covariance
    % matrices of uncertainties for column and row centroids
    % respectively
    %----------------------------------------------------------------------

    [Trow,errFlagRow] = factor_covariance_matrix(CcentroidRow);
    if errFlagRow < 0 % => T = []
        % not a valid covariance matrix.
        error('PDQ:attitudeSolutionMonteCarlo:InvalidCcentroidRowCovMat', 'Covariance matrix must be positive definite or positive semidefinite.');
    end

    [Tcolumn,errFlagColumn] = factor_covariance_matrix(CcentroidColumn);
    if errFlagColumn < 0 % => T = []
        %  not a valid covariance matrix.
        error('PDQ:attitudeSolutionMonteCarlo:InvalidCcentroidColumnCovMat', 'Covariance matrix must be positive definite or positive semidefinite.');
    end
    boreSightRa     = ra0 + (0/3600);
    boreSightDec    = dec0 + (0/3600);
    boreSightRoll   = rot0 + (2/3600);

    exaggerationFactor = 1;

    CcentroidRow = CcentroidRow.*exaggerationFactor^2; % measured centroids errors are exaggerated by a factor 100 below; to account for that in the covariance matrix...
    CcentroidColumn = CcentroidColumn*exaggerationFactor^2;

    for k = 1:nRealizations
        fprintf('realization % d/%d\n', k, nRealizations);

        measuredCentroidRows    = predictedCentroidRows + Trow*randn(nStars,1)*exaggerationFactor;
        measuredCentroidColumns = predictedCentroidColumns + Tcolumn*randn(nStars,1)*exaggerationFactor;


        % save to structure
        measuredCentroidsStruct(cadenceIndex).measuredCentroidRows(:,k) = measuredCentroidRows;
        measuredCentroidsStruct(cadenceIndex).measuredCentroidColumns(:,k) = measuredCentroidColumns;


        % using robustfit that includes uncertainties
        % using chi-square fit
        % using lscov with full covariance matrix
        % starting attitude - can be wrong (choose boreSightRa + 2 arc sec, boreSightDec
        % + 2 arc sec, boreSightRot + (2/7) arc sec)




        % attitudeError is defined as = sqrt(mean( (rowStarsHat - predictedCentroidRows).^2 + (colStarsHat - predictedCentroidColumns).^2));

        %     [boreSightRaLinearFit(k), boreSightDecLinearFit(k), boreSightRollLinearFit(k), attitudeError(k), deltaUncertaintyStruct(k).CdeltaAttitudes] = ...
        %         iterate_attitude_solution_using_chisquare_fit(raStarsAber, decStarsAber ,measuredCentroidRows, measuredCentroidColumns,...
        %         CcentroidRow, CcentroidColumn,     boreSightRa, boreSightDec, boreSightRoll, cadenceTimeStamp, aberrateFlag);

        [boreSightRaLinearFit(cadenceIndex, k), boreSightDecLinearFit(cadenceIndex, k), boreSightRollLinearFit(cadenceIndex,k), ...
            attitudeErrorLinearFit(cadenceIndex, k), deltaUncertaintyStruct(k).CdeltaAttitude] = ...
            iterate_attitude_solution_using_robust_fit(raDec2PixObject, raStarsAber, decStarsAber, measuredCentroidRows, measuredCentroidColumns,...
            CcentroidRow, CcentroidColumn, boreSightRa, boreSightDec, boreSightRoll, cadenceTimeStamp, aberrateFlag);

        [boreSightRaNonLinearFit(cadenceIndex, k), boreSightDecNonLinearFit(cadenceIndex, k), boreSightRollNonLinearFit(cadenceIndex,k), ...
            attitudeErrorNonLinearFit(cadenceIndex, k), deltaUncertaintyStructNLF(k).CdeltaAttitude] = ...
            iterate_attitude_solution_using_nlinfit(raDec2PixObject, raStarsAber, decStarsAber, measuredCentroidRows, measuredCentroidColumns, CcentroidRow, CcentroidColumn,...
            boreSightRaLinearFit(cadenceIndex, k), boreSightDecLinearFit(cadenceIndex, k), boreSightRollLinearFit(cadenceIndex, k), cadenceTimeStamp, aberrateFlag);

        %        [boreSightRaNonLinearFit(cadenceIndex, k), boreSightDecNonLinearFit(cadenceIndex, k), boreSightRollNonLinearFit(cadenceIndex,k), ...
        %             attitudeErrorNonLinearFit(cadenceIndex, k), deltaUncertaintyStructNLF(k).CdeltaAttitude] = ...
        %             iterate_attitude_solution_using_nlinfit(raDec2PixObject, raStarsAber, decStarsAber, measuredCentroidRows, measuredCentroidColumns, CcentroidRow, CcentroidColumn,...
        %             boreSightRa, boreSightDec, boreSightRoll, cadenceTimeStamp, aberrateFlag);




        %%
        % The rotation quaternion that produces no rotation is [0; 0; 0; 1]
        % The quaternion that corresponds to desired = actual is [1; 0; 0; 0];
        % deltaQ      = [0; 0; 0; 1];     % Null rotation quaternion
        % qActual     = [1; 0; 0; 0];     % Actual attitude quaternion in
        %                                   spacecraft frame of reference

        % Calculate the difference between the ACTUAL and DESIRED attitudes.
        % Note: these are in units of degrees (from Dave Koch)
        actualRaDecPhi = [boreSightRa boreSightDec boreSightRoll]';
        desiredRaDecPhi = [boreSightRaNonLinearFit(cadenceIndex, k), boreSightDecNonLinearFit(cadenceIndex, k), boreSightRollNonLinearFit(cadenceIndex,k)]';
        rotmatActual    = get_rotation_matrix(actualRaDecPhi);
        rotmatDesired   = get_rotation_matrix(desiredRaDecPhi);

        % The rotmatRelative is the rotational matrix that transforms from the
        % ACTUAL spacecraft attitude to the DESIRED spacecraft attitude
        rotmatRelative  = rotmatDesired * rotmatActual';

        xp = rotmatRelative(1,:);
        yp = rotmatRelative(2,:);
        zp = rotmatRelative(3,:);

        % Calculate the delta quaternion that transforms actual attitude into
        % desired attitude (note: quaternions in PDQ are column vectors)
        deltaQuaternion     = J20002Q(xp, yp, zp)';

        % Apply the delta quaternion to the ACTUAL space craft attiude and
        % calculate the quaternion of the DESIRED attitude. Then compare this to
        % the input DESIRED attitude and calculate the residuals.
        quatA               = [1; 0; 0; 0];              % Spacecraft attitude
        deltaQInverse       = quaternion_inverse(deltaQuaternion);
        qCalcDesired        = quaternion_product(deltaQuaternion, quaternion_product(quatA, deltaQInverse));

        % This method deals with quaternions - very easy to get relative desired
        % quaternion (qDesired)
        [rotmat qDesired]   = rotational_matrix(actualRaDecPhi, desiredRaDecPhi);

        % Calculate the residuals between the desired attitude derived from the
        % delta quaternion and the input value:
        residuals           = qCalcDesired(1:3) - qDesired(1:3);

        fprintf('');
        %waitbar( ((cadenceIndex-1)*nRealizations + k)  /(nRealizations*numCadences));

    end
    uncertaintyStruct(cadenceIndex).deltaUncertaintyStruct = deltaUncertaintyStruct;
    uncertaintyStructNLF(cadenceIndex).deltaUncertaintyStructNLF = deltaUncertaintyStructNLF;
end
save temp.mat

return




