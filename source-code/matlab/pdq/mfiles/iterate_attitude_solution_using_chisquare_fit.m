function    [boreSightRaNew, boreSightDecNew, boreSightRollNew, attitudeError, CdeltaAttitudes] = ...
    iterate_attitude_solution_using_chisquare_fit(raDec2PixObject,raStarsAber, decStarsAber ,centroidRows, centroidColumns, CcentroidRow, CcentroidColumn,...
    boreSightRa, boreSightDec, boreSightRoll, julianTime, dvaFlag)
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


%--------------------------------------------------------------------------
% [deltaRaHat, deltaDecHat, deltaRotHat] = ...
%   iterate_quick_fit_attitude(raStarsAber,decStarsAber, centroidRows, centroidColumns, boreSightRa, boreSightDec, boreSightRoll, julianTime);
%--------------------------------------------------------------------------
%
% Returns estimate for attitude solution by determining deltaRa, deltaDec
% and deltaRotHat given the Right Ascensions (raStarsAber), Declinations
% (decStarsAber), centroids (centroidRows & centroidColumns), and the current best-fit
% attitude boreSightRa, boreSightDec, boreSightRoll (and julianTime)
%
%--------------------------------------------------------------------------
% Parse inputs
if (nargin < 7)
    dvaFlag = 0;
end

raStarsAber = raStarsAber(:);
decStarsAber = decStarsAber(:);

% call radec2pix to get current predicted star positions
% mapping the apparent ra and dec to model positions, no propagation of error here as data is not transformed
%
[mm, oo, rowStarsHat, colStarsHat] = ...
    ra_dec_2_pix_absolute(raDec2PixObject,raStarsAber, decStarsAber, julianTime, boreSightRa, boreSightDec, boreSightRoll, dvaFlag);


residRows   = centroidRows-rowStarsHat;
residCols   = centroidColumns-colStarsHat;

initialAttitudeError = sqrt(mean(residRows.^2 + residCols.^2));



count = 1;
maxCount = 100;
tol = 1e-10;


attitudeError = zeros(maxCount,1);
attitudeError(1) = initialAttitudeError;

boreSightRaNew = boreSightRa; boreSightDecNew = boreSightDec;  boreSightRollNew = boreSightRoll;
while count == 1 ||(count < maxCount && (attitudeError(count-1)- attitudeError(count) > tol) )

    count = count + 1;
    [boreSightRaNew, boreSightDecNew, boreSightRollNew, attitudeError(count), rowStarsHat, colStarsHat, CdeltaAttitudes] = ...
        iterate_linear_attitude(raDec2PixObject,raStarsAber, decStarsAber, centroidRows, centroidColumns, CcentroidRow, CcentroidColumn,...
        boreSightRaNew, boreSightDecNew, boreSightRollNew, julianTime,dvaFlag);

end
attitudeError = attitudeError(1:count);
attitudeError = attitudeError(end);


return








%function [ra0, dec0, phi0, attitudeError, rowNew, colNew] = iterate_linear_attitude(aberRa, aberDec, row0, col0, ra0, dec0, phi0, season)
function    [boreSightRaNew, boreSightDecNew, boreSightRollNew, attitudeError, rowStarsHat, colStarsHat, CdeltaAttitudes] = ...
    iterate_linear_attitude(raDec2PixObject,raStarsAber, decStarsAber, centroidRows, centroidColumns,  CcentroidRow, CcentroidColumn,...
    boreSightRa, boreSightDec, boreSightRoll, julianTime, dvaFlag)



%-----------------------------------------
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


%-----------------------------------------

zeroMatrix = zeros(size(CcentroidRow));
Cuncertainty = [CcentroidRow zeroMatrix; zeroMatrix CcentroidColumn];


[mm, oo, rowStarsHat, colStarsHat] = ...
    ra_dec_2_pix_absolute(raDec2PixObject,raStarsAber, decStarsAber, julianTime, boreSightRa, boreSightDec, boreSightRoll, dvaFlag);

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
        ra_dec_2_pix_absolute(raDec2PixObject,raStarsAber(:), decStarsAber(:), julianTime, boreSightRa+deltaRa(i), boreSightDec+deltaDec(i), boreSightRoll+deltaRot(i), dvaFlag);
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

deltaAttitudes = xMatrixScaled\yMatrixScaled;


% propagation of uncertainties

CdeltaAttitudes = inv(xMatrixScaled' * xMatrixScaled);

boreSightRaNew      = boreSightRa + deltaAttitudes(1);
boreSightDecNew     = boreSightDec + deltaAttitudes(2);
boreSightRollNew    = boreSightRoll + deltaAttitudes(3);

[mm, oo, rowStarsHat, colStarsHat] = ...
    ra_dec_2_pix_absolute(raDec2PixObject,raStarsAber, decStarsAber, julianTime, boreSightRaNew, boreSightDecNew, boreSightRollNew, dvaFlag);

attitudeError       = sqrt(mean( (rowStarsHat - centroidRows).^2 + (colStarsHat - centroidColumns).^2));

return


