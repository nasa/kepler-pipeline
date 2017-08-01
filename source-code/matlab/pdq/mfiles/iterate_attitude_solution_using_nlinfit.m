function    [boreSightRaNew, boreSightDecNew, boreSightRollNew, attitudeError, CdeltaAttitudes, robustWeights ] = ...
    iterate_attitude_solution_using_nlinfit(raDec2PixObject, raStarsAber, decStarsAber ,centroidRows, ...
    centroidColumns, CcentroidRow, CcentroidColumn,...
    boreSightRa, boreSightDec, boreSightRoll, julianTime, dvaFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function    [boreSightRaNew, boreSightDecNew, boreSightRollNew, attitudeError, CdeltaAttitudes ] = ...
%     iterate_attitude_solution_using_nlinfit(raDec2PixObject, raStarsAber, decStarsAber ,centroidRows, ...
%     centroidColumns, CcentroidRow, CcentroidColumn,...
%     boreSightRa, boreSightDec, boreSightRoll, julianTime, dvaFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Given the measured centroids (centroidRows, centroidColumns) and the
% aberrated {ra, decs} of stellar targets, this function computes that
% attitude that will nudge the predicted centroids (obtained by mapping
% aberrated {ra, dec } on to {row, col} positions on the CCD. The mapping
% function is ra_dec_2_pix) towards the measured centroid as close as
% possible. This is a nonlinear optimization problem as the mapping
% 'ra_dec_2_pix' is nonlinear and is hence iterative.
%
%
% For propagation of uncertainties, see KADN-26185 Propagation of
% Uncertainties in the PDQ Pipelines.
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

% if any of the centroidRows or centroidColumns are -ve, remove them and
% remove corresponding rows and columns from  covariance matrix too
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
% Parse inputs
if (nargin < 7)
    dvaFlag = 0;
end

raStarsAber = raStarsAber(:);
decStarsAber = decStarsAber(:);

% columnUncertainties = sqrt(diag(CcentroidColumn));
% rowUncertainties = sqrt(diag(CcentroidRow));
%
% CcentroidRow = diag(rowUncertainties.^2);
% CcentroidColumn = diag(columnUncertainties.^2);

nlinfitOptions = statset('Robust', 'on', 'TolX',1e-13, 'Display', 'off');% do not remove TolX, Jacobian has one column = 0


%================new=============================================
Ccentroids = [CcentroidRow zeros(size(CcentroidColumn));  zeros(size(CcentroidColumn)) CcentroidColumn];



Ccentroids = double(single(Ccentroids));

try

    [V, errorFlag] = factor_covariance_matrix(Ccentroids);

    if errorFlag < 0 % => T = []
        %  not a valid covariance matrix.
        warning('PDQ:iterate_attitude_solution_using_nlinfit:invalidCcentroids', ...
            'factor_covariance_matrix fails for cadence %d ', cadenceIndex );

    end

catch

    errorThrown = lasterror;
    disp(errorThrown.stack(1))

    warning('PDQ:iterate_attitude_solution_using_nlinfit:invalidCcentroids', ...
        'factor_covariance_matrix fails for cadence %d ', cadenceIndex );

end
%V = V';
Vinv = inv(V);


attitudeStateModel = @(x,X) Vinv*(attitude_model_fun(raDec2PixObject, x, raStarsAber, decStarsAber, julianTime, dvaFlag));

[attitudeState, rw, Jw, Sigma, mse, robustWeights] = kepler_nonlinear_fit(1, Vinv*[centroidRows(:); centroidColumns(:)], ...
    attitudeStateModel, [boreSightRa, boreSightDec, boreSightRoll], nlinfitOptions);


[mm, oo, rowStarsHat, colStarsHat] = ...
    ra_dec_2_pix_absolute(raDec2PixObject, raStarsAber(:), decStarsAber(:),julianTime, attitudeState(1), attitudeState(2), attitudeState(3), dvaFlag);


attitudeError       = sqrt(mean( (rowStarsHat - centroidRows).^2 + (colStarsHat - centroidColumns).^2));

boreSightRaNew      = attitudeState(1);
boreSightDecNew     = attitudeState(2);
boreSightRollNew    = attitudeState(3);






%Alternatively, we can use the second and third outputs from nlinfit to
%approximate the covariance matrix of the estimated parameters, and from
%that get estimated standard errors.
% [Qw,Rw] = qr(Jw,0);
% msew = sum(abs(rw).^2)/(sum(w)-length(bFitw));
% Rinvw = inv(Rw);
% Sigmaw = Rinvw*Rinvw'*msew;




% Jw = V*Jw;
% T = (inv(Jw'*Jw))*Jw';
% T = T*diag(robustWeights); % if robust option is used
%T = T*sqrt(mse);  % scale it by the variance of the residuals unexplained by the cov. matrix

% if(any(isnan(T)))
%     warning('PDQ:attitudeSolution:usingNlinFit',....
%         'iterateAttitudeSolutionusingNlinFit:nans detected in inv(Jacobian''*jacobian)');
%     if(mse > eps)
%         CdeltaAttitudes = Sigma./mse;
%     else
%         CdeltaAttitudes = Sigma;
%     end
% else
%     CdeltaAttitudes = T*Ccentroids*T';
% end


% if(mse > eps)
%     CdeltaAttitudes = Sigma./mse;
% else
%     CdeltaAttitudes = Sigma;
% end

CdeltaAttitudes = Sigma;


return


%--------------------------------------------------------------------------
%%
%----------------------------------------------------------------------------------------------------------------------------
function rowsAndCols = attitude_model_fun(raDec2PixObject, attitudeState,raStarsAber, decStarsAber, cadenceTimeStamp, dvaFlag)
%----------------------------------------------------------------------------------------------------------------------------


[mm, oo, rowStars, colStars] = ...
    ra_dec_2_pix_absolute(raDec2PixObject, raStarsAber(:), decStarsAber(:), ...
    cadenceTimeStamp(1), attitudeState(1), attitudeState(2), attitudeState(3), dvaFlag);

rowsAndCols = [rowStars(:); colStars(:)];




return

