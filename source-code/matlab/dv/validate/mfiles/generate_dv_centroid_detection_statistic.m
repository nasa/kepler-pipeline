function [targetResults, alertsOnly] = ...
    generate_dv_centroid_detection_statistic(whitenerResultsStruct,targetStruct,targetResults,centroidType,alertsOnly)
% 
% function [targetResults, alertsOnly] = ...
%     generate_dv_centroid_detection_statistic(whitenerResultsStruct,targetStruct,targetResults,centroidType,alertsOnly)
% 
% This function calculates the centroid detection statistic and the null
% assumption significance for each planetResultsStruct in targetResults. 
% The normalized detection statistic for the ra and dec centroids are
% computed separately from the chi-squared of the fitted whitened transit
% models from the centroid test iterative whitener. They are then combined
% to form the centroid detection statistic. The null assumption
% significance is calculated assuming the detection statistic is drawn from
% a chi-squared distribution with two degrees of freedom.
%
% The detection statistic is developed directly from the output of the
% iterative whitener and the total detection statistic is the sum of the
% ra and dec detection statistics.
% T^2 = chiSquare( residual + fittedWhitenedModel ) - chiSquare( residual )
% Tcentroid^2 = Tra^2 + Tdec^2
%
% The definition of the detection statistic in the whitened domain is:
% T^2 = (x*s)^2 / s*s
% where: x = whitened data, s = fitted whitened signal model
% The detection statistic is calculated directly from this definition in
% cases where delta chi square as computed above is < 0.
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

% The whitenerResultsStruct contains the iterative fit information needed
% to produce the detection statistic.
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
% whitenerResultsStruct.ra
% ans = 
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

disp('DV:CentroidTest:Generating centroid detection statistic');

% unpack parameters
motionResultsString = [centroidType,'MotionResults'];
targetDecDegrees = targetStruct.decDegrees.value;

% check if whitener results are available
if( isempty(whitenerResultsStruct.ra.whitenedResidual) || isempty(whitenerResultsStruct.dec.whitenedResidual) )
    disp(['     Whitener results not available. Detection statistic and significance ',...
                'set to default values for all planets.']);
    alertsOnly = add_dv_alert(alertsOnly, ['Centroid test ',centroidType], 'warning',...
                ['Whitener results not available. Detection statistic and significance ',...
                'set to default values for all planets.'],...
                targetStruct.targetIndex, targetStruct.keplerId); 
    return;
end

% get whitened residual and original gap indicators used in whitener robust fit
raResidual = whitenerResultsStruct.ra.whitenedResidual;
raGaps = whitenerResultsStruct.ra.whitenedGaps;
decResidual = whitenerResultsStruct.dec.whitenedResidual;
decGaps = whitenerResultsStruct.dec.whitenedGaps;

% calculate weighted chi square of the whitened residual
raResidualChiSquare = sum( whitenerResultsStruct.ra.robustWeights .* raResidual.^2 );
decResidualChiSquare = sum( whitenerResultsStruct.dec.robustWeights .* decResidual.^2 );

nPlanets = length(targetResults.planetResultsStruct);
iPlanet = 0;

while( iPlanet < nPlanets )
    iPlanet = iPlanet + 1;
    
    if( whitenerResultsStruct.ra.validDesignColumn(iPlanet) &&...
            whitenerResultsStruct.dec.validDesignColumn(iPlanet) &&...
            whitenerResultsStruct.ra.converged &&...
            whitenerResultsStruct.dec.converged)
        
        % construct whitened fitted model from whitener results
        raFittedModel =  whitenerResultsStruct.ra.whitenedDesignMatrix(:,iPlanet) * ...
            whitenerResultsStruct.ra.coefficients(iPlanet);
        decFittedModel =  whitenerResultsStruct.dec.whitenedDesignMatrix(:,iPlanet) * ...
            whitenerResultsStruct.dec.coefficients(iPlanet);
        
        % calculate weighted chi square of residual + fitted model
        raChiSquare = sum( whitenerResultsStruct.ra.robustWeights .*(raResidual + raFittedModel).^2 );
        decChiSquare = sum( whitenerResultsStruct.dec.robustWeights .*(decResidual + decFittedModel).^2 );        
      
        % the square of the ra and dec detection statistic is the difference
        % between the (residual + model) chi square and the residual chi square
        T2ra = raChiSquare - raResidualChiSquare;
        T2dec = decChiSquare - decResidualChiSquare;
        
        % check ra and dec detection results - use alternate method to
        % calculate detection statistic if delta chi square produced negative
        % results
        if( T2ra < 0 )
            x = raResidual(~raGaps) + raFittedModel(~raGaps);
            s = raFittedModel(~raGaps);            
            T2ra = ((rowvec(x) * colvec(s))^2)/(rowvec(s)*colvec(s));
            disp(['     ra delta chi square < 0 for planet ',num2str(iPlanet)]);
            disp(['     Using definition of detection statistic, T^2 = (x*s)^2/s*s = ',num2str(T2ra)]); 
            
            alertsOnly = add_dv_alert(alertsOnly, ['Centroid test ',centroidType], 'warning',...
                ['ra detection statistic and significance not robust for planet ',num2str(iPlanet),'.'],...
                targetStruct.targetIndex, targetStruct.keplerId,iPlanet);            
        end
        
        if( T2dec < 0 )             
            x = decResidual(~decGaps) + decFittedModel(~decGaps);
            s = decFittedModel(~decGaps);            
            T2dec = ((rowvec(x) * colvec(s))^2)/(rowvec(s)*colvec(s));
            disp(['     dec delta chi square < 0 for planet ',num2str(iPlanet)]);             
            disp(['     Using definition of detection statistic, T^2 = (x*s)^2/s*s = ',num2str(T2dec)]);
            
            alertsOnly = add_dv_alert(alertsOnly, ['Centroid test ',centroidType], 'warning',...
                ['dec detection statistic and significance not robust for planet ',num2str(iPlanet),'.'],...
                targetStruct.targetIndex, targetStruct.keplerId,iPlanet);  
        end        

        % ~~~~~~~~~~~~~ % compute centroid detection statistic and significance

        % combine ra and dec detection statistic to get centroid statistic
        % include cod(dec) correction per KSOC-3440
        T2centroid = T2ra.*(cosd(targetDecDegrees).^2) + T2dec;

        % evaluate significance of centroid statistic assuming a chi-square distribution w/2 degrees of freedom
        significance = 1 - chi2cdf( T2centroid, 2 );

        targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).motionDetectionStatistic.value = ...
            T2centroid;
        targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).motionDetectionStatistic.significance = ...
            significance;

    else
        disp(['     Transit model not available and/or whitener did not converge.',...
                ' Detection statistic and significance set to default values for planet ',...
                num2str(iPlanet),'.']);
        alertsOnly = add_dv_alert(alertsOnly, ['Centroid test ',centroidType], 'warning',...
                ['Transit model not available and/or whitener did not converge.',...
                ' Detection statistic and significance set to default values for planet ',...
                num2str(iPlanet),'.'],...
                targetStruct.targetIndex, targetStruct.keplerId,iPlanet); 
    end
end


