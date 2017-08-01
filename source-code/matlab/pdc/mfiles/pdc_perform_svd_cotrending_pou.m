function [Cfit, Ccot] = pdc_perform_svd_cotrending_pou(U, uncertainties)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [Cfit, Ccot] = pdc_perform_svd_cotrending_pou(U, uncertainties)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Perform propagation of uncertainties for SVD-based cotrending (where the
% design matrix A = U * S * V').
%
% The errors in the input flux values are assumed to be independent. The
% propagation of uncertainties is performed in a memory efficient manner
% that does not require the computation or storage of any matrices with
% dimension nCadences x nCadences. That would be a show stopper for short
% cadence PA.
%
% For the fitted data, the full covariance matrix is given by:
%
%    Cfit = (U * U') * Cflux * (U * U')' = (U * U') * Cflux * (U * U')
%
% where Cflux = diag(uncertainties .^ 2)
%
% We are only interested in computing and returning the diagonal elements
% of Cfit.
%
% For the cotrended data, the full covariance matrix is given by:
%
%    Ccot = [I - (U * U')] * Cflux * [I - (U * U')]'
%
%         = Cflux - (U * U') * Cflux 
%               - Cflux * (U * U') + (U * U') * Cflux * (U * U')
%
% Again, we are only interested in computing and returning the diagonal
% elements of Ccot. Once cotrending has been performed and the errors
% propagated, there is no need to carry the full covariance matrix forward
% in PDC.
%
% Ensure that numerical rounding/truncation does not allow negative
% values to be returned for the diagonal covariances.
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


% First propagate the uncertainties in the fit. Compute only the diagonal
% elements in the covariance for the fit.
variances = uncertainties .^ 2;
tempRxR = scalerow(variances, U') * U;
tempRxN = tempRxR * U';
Cfit = abs(sum(U .* tempRxN', 2));
clear tempRxR tempRxN

% Now propagate the uncertainties in the cotrended flux. Note that the
% final term in the computation of Ccot is equal to Cfit. Again compute
% only the diagonal elements of the covariance matrix.
 Ccot = abs(variances - 2 * sum(U .^ 2, 2) .* variances + Cfit);

%beta = U * U';
%Ccot = abs(variances' - 2 * variances' * beta' + (beta * variances)' * beta');

% Return.
return
