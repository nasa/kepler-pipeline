function    [boreSightRaNew, boreSightDecNew, boreSightRollNew, attitudeError, CdeltaAttitudes ] = ...
    iterate_attitude_solution_using_robust_fit(raDec2PixObject, raStarsAber, decStarsAber,...
    centroidRows, centroidColumns, CcentroidRow, CcentroidColumn,...
    boreSightRa, boreSightDec, boreSightRoll, julianTime, dvaFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function    [boreSightRaNew, boreSightDecNew, boreSightRollNew, attitudeError, CdeltaAttitudes ] = ...
%     iterate_attitude_solution_using_robust_fit(raDec2PixObject, raStarsAber, decStarsAber,...
%     centroidRows, centroidColumns, CcentroidRow, CcentroidColumn,...
%     boreSightRa, boreSightDec, boreSightRoll, julianTime, dvaFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Returns estimate for attitude solution by determining deltaRa, deltaDec
% and deltaRotHat given the Right Ascensions (raStarsAber), Declinations
% (decStarsAber), centroids (centroidRows & centroidColumns), and the current best-fit
% attitude boreSightRa, boreSightDec, boreSightRoll (and julianTime)
%
% Given the measured centroids (centroidRows, centroidColumns) and the
% aberrated {ra, decs} of stellar targets, this function computes that
% attitude that will nudge the predicted centroids (obtained by mapping
% aberrated {ra, dec } on to {row, col} positions on the CCD. The mapping
% function is ra_dec_2_pix) towards the measured centroid as close as
% possible. This is a nonlinear optimization problem as the mapping
% 'ra_dec_2_pix' is nonlinear and is hence iterative.
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

% Parse inputs
if (nargin < 7)
    dvaFlag = 0;
end

raStarsAber = raStarsAber(:);
decStarsAber = decStarsAber(:);

% call ra_dec_2_pix_absolute to get current predicted star positions
% mapping the apparent ra and dec to {row, col}, no propagation of error
% here as data is not transformed
%
[mm, oo, rowStarsHat, colStarsHat] = ...
    ra_dec_2_pix_absolute(raDec2PixObject, raStarsAber, decStarsAber, julianTime, boreSightRa, boreSightDec, boreSightRoll, dvaFlag);


residRows   = centroidRows-rowStarsHat;
residCols   = centroidColumns-colStarsHat;

initialAttitudeError = sqrt(mean(residRows.^2 + residCols.^2));



% hard coded but okay since many of the built-in Matlab function have
% default values for parameters that include the max. number of iterations,
% convergence tolerance and so on...
maxCount = 100;
tol = 1e-12;


attitudeError = zeros(maxCount,1);
attitudeError(1) = initialAttitudeError;

boreSightRaOld = boreSightRa; boreSightDecOld = boreSightDec;  boreSightRollOld = boreSightRoll;

count = 1;
while count == 1 ||(count < maxCount && (attitudeError(count-1)- attitudeError(count) > tol) )

    count = count + 1;
    [boreSightRaNew, boreSightDecNew, boreSightRollNew, attitudeError(count), rowStarsHat, colStarsHat, CdeltaAttitudes] = ...
        iterate_linear_attitude(raDec2PixObject, raStarsAber, decStarsAber, centroidRows, centroidColumns, CcentroidRow, CcentroidColumn,...
        boreSightRaOld, boreSightDecOld, boreSightRollOld, julianTime,dvaFlag);

    boreSightRaOld = boreSightRaNew;
    boreSightDecOld = boreSightDecNew;
    boreSightRollOld = boreSightRollNew;

end
attitudeError = attitudeError(1:count);
attitudeError = attitudeError(end);


return


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function    [boreSightRaNew, boreSightDecNew, boreSightRollNew, attitudeError, rowStarsHat, colStarsHat, CdeltaAttitudes] = ...
    iterate_linear_attitude(raDec2PixObject, raStarsAber, decStarsAber, centroidRows, centroidColumns,...
    CcentroidRow, CcentroidColumn,...
    boreSightRa, boreSightDec, boreSightRoll, julianTime, dvaFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% if any of the centroidRows or centroidColumns are -ve, remove them and
% remove corresponding rows and columns form  covariance matrix too

invalidRows = find(centroidRows <= 0);
invalidColumns = find(centroidColumns <= 0);

invalidEntries = [invalidRows; invalidColumns];
invalidEntries = invalidEntries(:);

if(~isempty(invalidEntries))

    centroidRows(invalidEntries) = [];
    centroidColumns(invalidEntries) = [];

    CcentroidRow(invalidEntries,:) = [];
    CcentroidRow(:, invalidEntries) = [];

    CcentroidColumn(invalidEntries,:) = [];
    CcentroidColumn(:, invalidEntries) = [];

    raStarsAber(invalidEntries) = [];
    decStarsAber(invalidEntries) = [];

end

Cuncertainty = double(single( [CcentroidRow zeros(size(CcentroidRow)); zeros(size(CcentroidRow)) CcentroidColumn]));


[mm, oo, rowStarsHat, colStarsHat] = ...
    ra_dec_2_pix_absolute(raDec2PixObject, raStarsAber, decStarsAber, julianTime, boreSightRa, boreSightDec, boreSightRoll, dvaFlag);

residRows   = centroidRows-rowStarsHat;
residCols   = centroidColumns-colStarsHat;


% set up deltaRa and deltaDec and deltaRot for establishing gradients (one
% arcsec offsets)

derivStep = eps^(1/3); % from statset('nlinfit'), used to compute numerical jacobian

deltaRa     = [derivStep; 0; 0];
deltaDec    = [0; derivStep; 0];
deltaRot    = [0; 0; derivStep];


nStars = length(raStarsAber);

rowStarsOffset = zeros(nStars, numel(deltaRa));

colStarsOffset = zeros(nStars, numel(deltaRa));


for i = 1 : numel(deltaRa)
    [mm, oo, rowStarsOffset(:,i), colStarsOffset(:,i)] = ...
        ra_dec_2_pix_absolute(raDec2PixObject, raStarsAber(:), decStarsAber(:), julianTime, boreSightRa+deltaRa(i),...
        boreSightDec+deltaDec(i), boreSightRoll+deltaRot(i), dvaFlag);
end

% Find linear coefficients representing effect of deltaRa, deltaDec and
% deltaRot on the row and col positions of the stars

A = [deltaRa(:), deltaDec(:), deltaRot(:)];

bCol = colStarsOffset' - repmat(colStarsHat',3,1);

bRow = rowStarsOffset' - repmat(rowStarsHat',3,1);

% chi square fit - scale the design matrix and the data by the
% diag(CcentroidRow) or diag(CcentroidColumn)

cCol = A\bCol;

cRow  = A\bRow; % replace with lscov

% Set up matrices to be used by robustfit....a0+deltaRa(i)
xMatrix     = [cRow'; cCol'];

yMatrix     = [residRows(:); residCols(:)];


xMatrixScaled = scalecol(sqrt(diag(Cuncertainty)).^-1,xMatrix);
yMatrixScaled = scalecol(sqrt(diag(Cuncertainty)).^-1,yMatrix);

warning off all;
[deltaAttitudes, robustStats]  = robustfit(xMatrixScaled, yMatrixScaled, [], [], 'off');
warning on all;

robustWeights = sqrt(robustStats.w);

% use robust fit to identify outliers
outlierIndices = find(robustWeights == 0);

CrobustUncertainty = double(single([CcentroidRow zeros(size(CcentroidRow)); zeros(size(CcentroidColumn)) CcentroidColumn]));


CrobustUncertainty = double(single(CrobustUncertainty));

if(~isempty(outlierIndices))

    xMatrix(outlierIndices,:) = [];
    yMatrix(outlierIndices) = [];
    robustWeights(outlierIndices) = [];

    CrobustUncertainty(outlierIndices,:) = [];
    CrobustUncertainty(:, outlierIndices) = [];
end


CrobustUncertainty = double(single( diag(1./robustWeights) * CrobustUncertainty * diag(1./robustWeights)));

% this solution is used only to seed the nlinfit call for improved attitude
% solution 
[deltaAttitudes, stdx, mse, S] = lscov(xMatrix, yMatrix, 1./diag(CrobustUncertainty)); % to cure the instability problem with CrobustUncertainty



% make lscov robust - how?
% solve with lscov, then call robust fit with scaled xMatrix, ymatrix and
% pull out the weights, use the weights to preweight the data to lscov
% (apply the transformation to rows and columns Cuncertainty too)


% propagation of uncertainties
%CdeltaAttitudes = S./mse;
CdeltaAttitudes = S;

boreSightRaNew      = boreSightRa + deltaAttitudes(1);
boreSightDecNew     = boreSightDec + deltaAttitudes(2);
boreSightRollNew    = boreSightRoll + deltaAttitudes(3);

[mm, oo, rowStarsHat, colStarsHat] = ...
    ra_dec_2_pix_absolute(raDec2PixObject,  raStarsAber, decStarsAber, julianTime, boreSightRaNew,...
    boreSightDecNew, boreSightRollNew, dvaFlag);

attitudeError       = sqrt(mean( (rowStarsHat - centroidRows).^2 + (colStarsHat - centroidColumns).^2));

return


