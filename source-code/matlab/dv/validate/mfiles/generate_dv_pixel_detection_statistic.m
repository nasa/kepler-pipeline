function [targetResults, alertsOnly] = generate_dv_pixel_detection_statistic(whitenerResultsStruct,...
                                                                                targetResults,...
                                                                                iTable,...
                                                                                iPixel,...
                                                                                alertsOnly)
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
% function [targetResults, alertsOnly] = generate_dv_pixel_detection_statistic(whitenerResultsStruct,...
%                                                                                targetResults,...
%                                                                                iTable,...
%                                                                                iPixel,...
%                                                                                alertsOnly)
% 
% This function calculates the pixel correlation detection statistic and the null assumption significance for the iPixel_th pixel for each
% planetResultsStruct in targetResults. The detection statistic is computed using the fitted transit model and residual in the whitened 
% domain. The null assumption significance is calculated assuming the detection statistic is drawn from a standard normal distribution.
% A signed detection statistic is produced and the significance is a measure of the signed correlation between the pixel time series and the
% fitted transit model.
%
% significance = 0   ==> anti-correlated with transit model
% significance = 0.5 ==> uncorrelated with transit model
% significance = 1   ==> correlated with transit model        
%
% The definition of the detection statistic in the whitened domain is:
% T = x * s / sqrt( s * s )
% where x = whitened data
%       s = fitted whitened signal model
% 
% A robust definiton is used to produce the detection statistic in the function:
% T = (w.*x) * s / sqrt( (w.*s) * s )
% where x = whitened data
%       s = fitted whitened signal model
%       w = robust weights from fit in whitened domain
% 
% This definition of T is equivalent to the delta robust chi^2 definition.
% T^2 = delta_robust_chi^2
%     = chi^2_robust(residual + s) - chi^2_robust(s) 
% where: chi^2_robust(x) = sum( w.*x.^2 )

% The whitenerResultsStruct contains the iterative fit information needed
% to produce the detection statistic.
%
% Because the whitener is common code used by both the centroid test and
% the pixel correlation test, some of the field names may be misleading here. In
% the pixelcorrelation test application of the whitener, only the ra dimension
% of the whitenerResultsStruct is used. It contains not a position timeseries 
% (as in the centroid test) but a pixel timeseries. The dec dimension is all
% gapped.
%
% The following is an example of the whitenerResultsStruct with the fields populated.
%
% whitenerResultsStruct = 
% 
%                         ra: [1x1 struct]
%                         dec: [1x1 struct]
%                designMatrix: [3000x2 double]
%            fineDesignMatrix: [30001x2 double]
%           validDesignColumn: [2x1 logical]
%                           t: [3000x1 double]
%                   tFineMesh: [1x30001 double]
%                    epochBjd: [2x1 double]
%         epochUncertaintyBjd: [2x1 double]
%                  periodDays: [2x1 double]
%       periodUncertaintyDays: [2x1 double]
%                durationDays: [2x1 double]
%     durationUncertaintyDays: [2x1 double]
%                    depthPpm: [2x1 double]
%         depthUncertaintyPpm: [2x1 double]
%                   inTransit: [3000x1 logical]
%
%
% whitenerResultsStruct.ra = 
%
%              whitenedCentroid: [3000x1 double]
%              whitenedResidual: [3000x1 double]
%          whitenedDesignMatrix: [3000x2 double]
%           whitenerScaleFactor: 2.5035e+03
%                  coefficients: [2x1 double]
%              covarianceMatrix: [2x2 double]
%                 robustWeights: [3000x1 double]
%                     converged: 1
%                   nIterations: 6
%      meanOutOfTransitCentroid: 361.7127
%     CmeanOutOfTransitCentroid: 1.6162e-12
%       sdOutOfTransitCentroids: 4.0676e-04
%             residualCentroids: [1x1 struct]
%                   rmsResidual: 1.2013
%



% Get whitened residual and original gap indicators used in whitener robust
% fit. Assumes whitenedResidual is not empty.
ra = whitenerResultsStruct.ra;

pixelResidual = ra.whitenedResidual;
pixelGaps = ra.whitenedGaps;
robustWeights = ra.robustWeights;
whitenedDesignMatrix = ra.whitenedDesignMatrix;
validDesignColumn = ra.validDesignColumn;
coefficients = ra.coefficients;

% push out the gaps
w = robustWeights(~pixelGaps);

% loop over fitted planets
nPlanets = length(targetResults.planetResultsStruct);

iPlanet = 0;
while( iPlanet < nPlanets )
    iPlanet = iPlanet + 1;
    
    if( validDesignColumn(iPlanet) )

        % Construct whitened fitted model from whitener results
        pixelFittedModel =  whitenedDesignMatrix(:,iPlanet) * coefficients(iPlanet);
        
%         % Calculate weighted chi square of residual + fitted model
%         pixelChiSquare = sum( w(~pixelGaps) .*(pixelResidual(~pixelGaps) + pixelFittedModel(~pixelGaps)).^2 );
%              
%         % The square of the detection statistic is the difference between
%         % the (residual + model) chi square and the residual chi square.
%         T_squared = pixelChiSquare - pixelResidualChiSquare;
%         
%         % we want the statistic (not the square of the statistic)
%         T = sqrt(T_squared);
        
        
        % This robust development of the detection statistic (T) is equivalent to the robust delta chi^2 
        % developement of T_squared commented out directly above.
        x = pixelResidual(~pixelGaps) + pixelFittedModel(~pixelGaps);
        s = pixelFittedModel(~pixelGaps); 
        
        T = ( rowvec(w.*x) * colvec(s) ) / sqrt( rowvec(w.*s) * colvec(s) );
 
        
        % Set the sign of the detection T the same as the sign of the fitted amplitude of the transit signal in the whitened domain.
        % Since it is possible for x*w*s = (mu + s)*w*s < 0 if mu*w*s < -(s*w*s) (this is not likely if mu is white and zero mean as
        % expected) we take abs(T) and force the sign to match that of the fitted amplitude
        T = sign(coefficients(iPlanet)) * abs(T);
        
        
        % Calculate the significance of the detection statistic (T) assuming it is a normally distributed random variable with unit variance.
        % significance = 0   ==> anti-correlated with transit model
        % significance = 0.5 ==> uncorrelated with transit model
        % significance = 1   ==> correlated with transit model        
        
        % The MATLAB error function, erf(x) = twice the integral of the Gaussian distribution with 0 mean and variance of 1/2 from 0 to x.
        % We would like the cdf of the standard normal distribution (variance = standard deviation = 1 by definition in the whitened domain)
        % between -inf and T so we need to scale the error function and the argument of the error function and adjust the bias appropriately.
        
        significance = 0.5 * ( 1 + erf( T/sqrt(2) ) );
        
        
        % save results
        targetResults.planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).pixelCorrelationStatisticStruct(iPixel).value = T;
        targetResults.planetResultsStruct(iPlanet).pixelCorrelationResults(iTable).pixelCorrelationStatisticStruct(iPixel).significance = significance;
        
    end
end


