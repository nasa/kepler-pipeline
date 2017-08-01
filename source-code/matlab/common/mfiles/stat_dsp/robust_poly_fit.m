%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to do the robust fitting of the chunks using AIC to select the
% model order
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

function [polyFit, fittedPolyOrder, AIC, robustPolyCoeffs] = robust_poly_fit( yValues, xValues, maxPolyOrder )

if ~exist( 'maxPolyOrder', 'var' ) || isempty( maxPolyOrder )
    maxPolyOrder = 25;
end

nCadences = length(yValues);
polyFit = [];

% restrict polynomial order to avoid order > # samples
maxDetrendPolyOrder = min(maxPolyOrder,nCadences - 2);

% preallocate storage
AIC = zeros(maxDetrendPolyOrder + 1, 1);
robustPolyCoeffs = cell(maxDetrendPolyOrder + 1,1);

% construct design matrices
xValues = xValues(:);
xValues = xValues - min(xValues) + 1;
designMatrix = repmat(xValues/max(xValues), 1, maxDetrendPolyOrder+1).^repmat(0:maxDetrendPolyOrder,nCadences,1); 

minAIC = 1e16;
fittedPolyOrder = 0;
jPolyOrder = 0;

warningMessage = 'stats:statrobustfit:IterationLimit' ;
warningMessageRank = 'stats:robustfit:RankDeficient' ;
warningMessageSingular = 'MATLAB:nearlySingularMatrix' ;
warning( 'off', warningMessage ) ;
warning( 'off', warningMessageRank ) ;
warning( 'off', warningMessageSingular ) ;

while (jPolyOrder <= fittedPolyOrder + 2) && (jPolyOrder <= maxDetrendPolyOrder)

    % perform robust fit.  By default, ROBUSTFIT adds a column of ones to X
    [robustPolyCoeffs{jPolyOrder+1}, stats] = robustfit(designMatrix(:, 2:jPolyOrder+1), yValues);

    % extract final estimate of sigma, the larger of robust_s and a weighted
    % average of ols_s and robust_s, where stats.ols_s is the sigma estimate
    % (rmse) from least squares fit, and stats.robust_s is the robust estimate of sigma
    robustSigma = stats.s;

    K = length(robustPolyCoeffs{jPolyOrder+1});
    AIC(jPolyOrder+1) = 2*K + 0.5*nCadences*log(robustSigma) + 2*K*(K + 1)/(nCadences - K - 1);

    % update order
    if AIC(jPolyOrder+1) < minAIC
        minAIC = AIC(jPolyOrder+1);
        fittedPolyOrder = jPolyOrder;
    end

    % If AIC fails to decrease after two attempts past current minimum
    % then use the poly order corresponding to the current minAIC to 
    % construct the fit to the chunk
    if isequal(jPolyOrder, fittedPolyOrder+2)
       polyFit = designMatrix(:,1:fittedPolyOrder+1) * robustPolyCoeffs{fittedPolyOrder+1};
    end
    
    jPolyOrder = jPolyOrder + 1;
end

% if no fit succeeded then return the original values
if isempty(polyFit)
    polyFit = yValues;
    fittedPolyOrder = 0;
end

warning( 'on', warningMessage ) ;
warning( 'on', warningMessageRank ) ;
warning( 'on', warningMessageSingular ) ;
return