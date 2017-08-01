function [varDifferentialLightCurve,normalizedWeights] = ...
    compute_light_curve(Xin,nNearstars,nearstars,weights)
% [varDifferentialLightCurve,normalizedWeights] =...
%    compute_light_curve(Xin,nNearstars,nearstars,weights)
%
% Function to construct, for each comparison star, an ensemble using the "other" 
% stars, and compute (1) differential light curve and (2) variance of light curve
%
% INPUT
% Xin
% nNearstars
% nearstars
% weights
%
% OUTPUT
% varDifferentialLightCurve
% normalizedWeights
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

%pre-allocate array for differential light curve and variance
differentialLightCurve = zeros(Xin.nCadences, nNearstars);
varDifferentialLightCurve = zeros(1, nNearstars);
normalizedWeights = zeros(Xin.nCadences, nNearstars);

%loop over nNearstars (stars within ensRadius)
for k = 1:nNearstars
    %renormalize the weights removing star k
    nearstarsTMP = nearstars;
    nearstarsTMP(k) = [];
 
    kTMP = 1:nNearstars;
    kTMP(k) = [];
    weightsTMP = weights(:,kTMP);
    %weightsTMP = weights;
    %weightsTMP(:,k) = [];

    %normalization factor with star k removed
    normFactor = sum(1 ./ weightsTMP,2);
    %replicate normFactor (nNearstars-1) times
    normFactorArray  = repmat(normFactor, 1, nNearstars-1);
    %normalized weights (to multiply Xin.flux by for diff. light curve)
    normalizedWeights = (1 ./ weightsTMP) ./ normFactorArray ;
    
    %compute ensemble that excludes star k
    ensemble = sum(normalizedWeights .* Xin.flux(:,nearstarsTMP), 2);
    medianEns = median(ensemble);

    %compute light curve for star k
    differentialLightCurve(:,k) = Xin.flux(:,nearstars(k)) ./ (ensemble ./ medianEns);
    
    %compute variance of differentialLightCurve for star k, which will be new weight
    varDifferentialLightCurve(k)=var(differentialLightCurve(:,k)); 
end
return

 