function backgroundLevel = pmd_calculate_background_level_metric(pmdScienceObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function backgroundLevel = pmd_calculate_background_level_metric(pmdScienceObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function calculates background level metric from backgroundPolyStruct.
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

nCadences = length(pmdScienceObject.cadenceTimes.midTimestamps);

% initialize background level metric time series
backgroundLevel.values        = -1*ones(nCadences, 1);
backgroundLevel.uncertainties = -1*ones(nCadences, 1);
backgroundLevel.gapIndicators = true(nCadences, 1);

% get rows and cols of a grid of background targets 
[rows, cols] = meshgrid(32:100:1032, 62:100:1062);
rows         = rows(:);
cols         = cols(:);
onesVec      = ones(size(rows));              % a column vector of ones

% Loop over all cadences
for iCadence = 1:nCadences

    % Background level metric is calculated only when status of backgroundPoly is good
    if ( pmdScienceObject.backgroundPolyStruct(iCadence).backgroundPolyStatus )

        % Background targets values and covariance matrix are determined by evaluating background polynomial.
        [ backgroundValues, uncertaintyIgnored, designMatrix ] = ...
            weighted_polyval2d(rows, cols, pmdScienceObject.backgroundPolyStruct(iCadence).backgroundPoly);

        % Note:     backgroundValues  = designMatrix * backgroundPoly.coeff
        %           CbackgroundValues = designMatrix * backgroundPoly.covariance * designMatrix'
        CbackgroundValues = designMatrix * pmdScienceObject.backgroundPolyStruct(iCadence).backgroundPoly.covariance * designMatrix';
    
        % calculate weights for averaging background target values
        w = 1./diag(CbackgroundValues);
        w(isinf(w)) = 0;
        transformation = lscov(onesVec, eye(size(CbackgroundValues)), w);
        
        % calculate background level metric and uncertainty of the cadence
        backgroundLevel.values(iCadence)        = transformation * backgroundValues;
        backgroundLevel.uncertainties(iCadence) = sqrt( transformation * CbackgroundValues * transformation' );
        backgroundLevel.gapIndicators(iCadence) = false;
         
    end

end
