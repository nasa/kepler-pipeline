function relFluxUncert = compute_variance(inputsStruct,ensemble,instrumentWeights,varianceWeights)
%
%
% Function to compute the variances of differential light curves by
% propagation of errors given the mathematical formulation for the ensemble
%
% INPUT
% inputsStruct
% ensemble
% varianceWeights
% nearstars
%
% OUTPUT
% relFluxUncert
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

% use weightsTotal? 2000 x 2000


%instrumental errors
instrumentWeightsArray = repmat(instrumentWeights,inputsStruct.nCadences,1);

%compare instrumental errors to variances of the differential light curves of ensemble stars
varianceWeightsArray = repmat(varianceWeights,inputsStruct.nCadences,1);

%size of ensemble is [nCadences x nStars]
medianEns = median(ensemble);  %[1 x nStars]

normFactor = sum(1 ./ varianceWeights);
normFactorArray = repmat(normFactor,inputsStruct.nCadences,inputsStruct.nStars);

relFluxVariance = instrumentWeightsArray .* (repmat(medianEns,inputsStruct.nCadences, 1) .^ 2) ./ ... 
    (ensemble .^ 2) + normFactorArray .^ (-2) .* ...
    repmat(sum(instrumentWeightsArray ./ (varianceWeightsArray .^ 2), 2), 1, inputsStruct.nStars) .*  ...
    (inputsStruct.flux .^ 2) .* (repmat(medianEns,inputsStruct.nCadences, 1) .^ 2) ./ (ensemble .^ 4);


%propagating the errors
% relFluxVariance = instrumentWeightsArray(:,i)*(medianEns^2) ./ ...
%     (ensemble .^ 2) + normFactorArray .^ (-2) .* ...
%     sum(instrumentWeightsArray ./ (varianceWeightsArray.^2), 2) .*  ...
%     (inputsStruct.flux(:,i) .^ 2) * (medianEns^2) ./ (ensemble.^4);

relFluxUncert = sqrt(relFluxVariance);

return
