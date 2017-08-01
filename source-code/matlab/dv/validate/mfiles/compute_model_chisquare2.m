function [chiSquare, chiSquareDof, chiSquareGof, chiSquareGofDof] = ...
    compute_model_chisquare2( whiteningFilterObject, fluxTimeSeriesValues, ...
    transitModelPulseTrain, deemphasisWeights )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [chiSquare, chiSquareDof] = compute_model_chisquare2( ...
% whiteningFilterObject, fluxTimeSeriesValues, transitModelPulseTrain, deemphasisWeights)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function computes the TPS chiSquare2 value and corresponding degrees
% of freedom.  
%
% Inputs: whiteningFilterObject - Object of the whiteningFilterClass
%         fluxTimeSeriesValues - a flux time series that contains the
%             transits.  Can be extended to power of two or not extended.
%             Should have gaps filled.
%         transitModelPulseTrain - a time series with the model transit
%             pulse train. Generated using
%             generate_planet_model_light_curve.
%         deemphasisWeights - weights used to deemphasis cadences in fit
%
% Outputs: chiSquare - the chi-square value
%          chiSquareDof - corresponding degrees of freedom
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

% Initialize the outputs
chiSquare = -1;
chiSquareDof = -1;
chiSquareGof = -1;
chiSquareGofDof = -1;

% Extract info from inputs
scalingFilterCoeffts = get(whiteningFilterObject, 'scalingFilterCoeffts') ;
whiteningCoefficients = get(whiteningFilterObject, 'whiteningCoefficients') ;
residualFluxTimeSeries = get(whiteningFilterObject, 'fluxTimeSeriesValues' ) ; % get in-transit fill values here
gapFillParametersStruct = get(whiteningFilterObject, 'gapFillConfigurationStruct') ;
noiseEstimationByQuarter = get(whiteningFilterObject, 'noiseEstimationByQuarterEnabled');
cadenceQuarterLabels = get(whiteningFilterObject, 'cadenceQuarterLabels');

gapIndicators = deemphasisWeights == 0 ;
inTransitIndicator = transitModelPulseTrain ~= 0 ;

% only continue if there are in-transit cadences that are not gapped
if ~all(gapIndicators( inTransitIndicator ))

    % identify the in-transit cadences
    inTransitCadenceChunks =  identify_contiguous_integer_values( find( inTransitIndicator ) ) ;
    
    % adjust for transits that fall entirely in gaps
    emptyIndicator = false(length(inTransitCadenceChunks),1);
    for i=1:length(inTransitCadenceChunks)
        if isequal(sum(deemphasisWeights(inTransitCadenceChunks{i})),0)
            emptyIndicator(i) = true;
            transitModelPulseTrain(inTransitCadenceChunks{i}) = 0;
        end
    end
    inTransitCadenceChunks(emptyIndicator) = [];
    inTransitIndicator = transitModelPulseTrain ~= 0 ;   
    nTransits = length(inTransitCadenceChunks) ;
    nCadences = length( inTransitIndicator ) ;

    % do not compute the metric if there are too many transits
    if nTransits > 200
        disp(' ');
        disp(['      Do not compute the metric of model chisquare2 when there are too many transits. Number of transits: ' num2str(nTransits)]);
        disp(' ');
        return
    end
    
    % build the waveletObject
    waveletObject = waveletClass(scalingFilterCoeffts) ;
    waveletObject = set_outlier_vectors( waveletObject, inTransitIndicator, ...
        residualFluxTimeSeries(inTransitIndicator), gapFillParametersStruct, [] ) ;
    waveletObject = set_extended_flux( waveletObject, fluxTimeSeriesValues, ...
        noiseEstimationByQuarter, cadenceQuarterLabels) ;
    waveletObject = set_custom_whitening_coefficients( waveletObject, whiteningCoefficients ) ;        

    % allocate storage
    corrComponentsTimeDomain = zeros(nTransits,1) ;
    normComponentsTimeDomain = zeros(nTransits,1) ;
    xTimeDomain = -1 * ones(nCadences, 1) ;
    sTimeDomain = -1 * ones(nCadences, 1) ;
    weights = -1 * ones(nCadences, 1) ;

    % compute the components
    for i=1:nTransits
        inTransitCadences = inTransitCadenceChunks{i} ;
        % if the transit is not entirely gapped then proceed
        [corrTimeSeries, normTimeSeries, xTemp, sTemp] = ...
            compute_single_pulse_statistics_time_domain( waveletObject, ...
            transitModelPulseTrain, inTransitCadences ) ;

        % toss out gapped cadences
        corrTimeSeries = corrTimeSeries .* deemphasisWeights(inTransitCadences) ;
        normTimeSeries = normTimeSeries .* deemphasisWeights(inTransitCadences) ;
        xTemp = xTemp .* deemphasisWeights(inTransitCadences) ;
        sTemp = sTemp .* deemphasisWeights(inTransitCadences) ;

        % sum up
        corrComponentsTimeDomain(i) = sum( corrTimeSeries ) ;
        normComponentsTimeDomain(i) = sum( normTimeSeries ) ;

        xTimeDomain(inTransitCadences) = xTemp ;
        sTimeDomain(inTransitCadences) = sTemp ;
        weights(inTransitCadences) = deemphasisWeights(inTransitCadences) ;
    end

    % remove zeros in case some pulses were entirely within a gap
    corrComponentsTimeDomain = corrComponentsTimeDomain(corrComponentsTimeDomain ~= 0) ;
    normComponentsTimeDomain = normComponentsTimeDomain(normComponentsTimeDomain ~= 0) ;

    % remove out-of-transit cadences from x and s
    xTimeDomain = xTimeDomain(xTimeDomain ~= -1) ;
    sTimeDomain = sTimeDomain(sTimeDomain ~= -1) ;
    weights = weights(weights ~= -1) ;

    % compute the chiSquare2 in same way as TPS
    zComponents2 = corrComponentsTimeDomain/sqrt(sum(normComponentsTimeDomain));
    qComponents2 = normComponentsTimeDomain/sum(normComponentsTimeDomain);
    deltaZ2 = zComponents2 - qComponents2*sum(zComponents2);
    chiSquare2 = (deltaZ2.^2)./qComponents2;
    chiSquare = sum(chiSquare2);

    % compute the chiSquareGof in teh same way as TPS
    chiSquareGof = xTimeDomain' * xTimeDomain - ( xTimeDomain' * sTimeDomain / norm(sTimeDomain) )^2;

    % set DOF's
    chiSquareDof = length(chiSquare2) - 1 ; % nTransits - 1
    chiSquareGofDof = length( weights ~= 0 ) - 1;
end

return
