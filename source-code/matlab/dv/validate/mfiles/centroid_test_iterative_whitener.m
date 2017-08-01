function [whitenerResultStruct, alertsOnly] = centroid_test_iterative_whitener(previousWhitenerResultsStruct,...
                                                                                centroidStruct,...
                                                                                targetStruct,...
                                                                                targetResults,...
                                                                                planetFitConfigurationStruct,...
                                                                                trapezoidalFitConfigurationStruct, ...
                                                                                configMaps,...
                                                                                detrendParamStruct,...
                                                                                barycentricTimeStruct,...
                                                                                centroidTestConfig,...
                                                                                centroidType,...
                                                                                typeNoneIdentifier,...
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
% function [whitenerResultStruct, alertsOnly] = centroid_test_iterative_whitener(previousWhitenerResultsStruct,...
%                                                                                 centroidStruct,...
%                                                                                 targetStruct,...
%                                                                                 targetResults,...
%                                                                                 planetFitConfigurationStruct,...
%                                                                                 trapezoidalFitConfigurationStruct, ...
%                                                                                 configMaps,...
%                                                                                 detrendParamStruct,...
%                                                                                 barycentricTimeStruct,...
%                                                                                 centroidTestConfig,...
%                                                                                 centroidType,...
%                                                                                 typeNoneIdentifier,...
%                                                                                 alertsOnly)
% 
% This function performs iterative whitening on the ra and dec centroid
% time series and has been adapted to work with any time series if that
% time series is loaded into the "ra" subfield of the centroidStruct and
% centroidType "none" is selected. The operations are summarized below:
%
% First, whitened versions of transit model fit to the flux
% time series are fit to the whitened centroid time series.  Then
% the whitening filter is generated using the residual to the fit in the
% unwhitened domain. This whitening and fitting process is iterated until
% the fit coefficients change by less than iterativeWhitenerTolerance.
% Results from the whitening and fitting process are returned in the
% whitenerResultsStruct. The trapezoidal model fit is utilized as a fall
% back if the limb darkened model fit to all transits was not performed or
% did not converge.
% 
% centroidType      = type of centroid timeseries contained in centroidStruct
%                     {'prf','fluxWeighted','none'}, centroifType = 'none'
%                     is used to process pixels time series using the
%                     centroid_test_iterative_whitener (for example).
%


% hard coded parameters/constants ~~~~~~~~~~~~~~
SMALL_VALUE = eps(1);
ITER_INC = 5;

% unit conversion 
HOURS_PER_DAY = get_unit_conversion('day2hour');

% unpack module parameters
fineMesh            = centroidTestConfig.centroidModelFineMeshFactor;
fineMeshEnabled     = centroidTestConfig.centroidModelFineMeshEnabled;
tolerance           = centroidTestConfig.iterativeWhitenerTolerance;
chiSquaredTolerance = centroidTestConfig.chiSquaredTolerance;
iterationLimit      = centroidTestConfig.iterationLimit;
tLimitSecs          = centroidTestConfig.tLimitSecs;
PAD_CADENCES        = centroidTestConfig.padTransitCadences;
MIN_PTS_PER_PLANET  = centroidTestConfig.minimumPointsPerPlanet;
testStartTimeSeconds= centroidTestConfig.testStartTimeSeconds;

% use barycentric timestamps for models
t = barycentricTimeStruct.values;
quarters = barycentricTimeStruct.quarters;
nCadences = length(t);

% get the cadence labels for the whitening filter model
cadenceQuarterLabels = get_intra_quarter_cadence_labels( quarters, ...
    targetStruct.rawFluxTimeSeries.gapIndicators );

% initialize design matrix and logicals
nPlanets            = length( targetResults.planetResultsStruct );
designMatrix        = zeros(length(t),nPlanets);
validDesignColumn   = false(nPlanets, 1);
inTransitArray      = false(length(t),nPlanets);
inTransit           = false(length(t),1);

% set up fine mesh time stamps for plotting model
if fineMeshEnabled
    tFineMesh = t(1) : (t(end)-t(1)) / (length(t) * fineMesh) : t(end);    
else
    tFineMesh = [];
end
fineDesignMatrix = zeros(length(tFineMesh),nPlanets);

% initialize planet fit parameter arrays
epochBjd = zeros(nPlanets,1);
epochUncertaintyBjd = zeros(nPlanets,1);
periodDays = zeros(nPlanets,1);
periodUncertaintyDays = zeros(nPlanets,1);
durationDays = zeros(nPlanets,1);
durationUncertaintyDays = zeros(nPlanets,1);
depthPpm = zeros(nPlanets,1);
depthUncertaintyPpm = zeros(nPlanets,1);

% set up results data structures
tempStruct = struct('whitenedCentroid',[],...
                        'whitenedUncertainties',[],...
                        'whitenedGaps',[],...
                        'whitenedResidual',[],...
                        'whitenedDesignMatrix',[],...
                        'whitenerScaleFactor',0,...
                        'whitenedResidualChiSquared',[],...
                        'coefficients',zeros(nPlanets,1),...
                        'covarianceMatrix',-ones(nPlanets),...                        
                        'robustWeights',[],...                        
                        'converged',false,...   
                        'nIterations',0,...
                        'meanOutOfTransitCentroid',0,...
                        'CmeanOutOfTransitCentroid',-1,...
                        'sdOutOfTransitCentroids',0,...
                        'residualCentroids',[],...
                        'rmsResidual',0,...
                        'validDesignColumn',validDesignColumn);
                    
                    

% build design matrix if not already available in previous whitener results                  
if isempty(previousWhitenerResultsStruct)
                    
    % build output structs
    whitenerResultStruct = struct('ra',tempStruct,...
                                     'dec',tempStruct,...
                                     'designMatrix',designMatrix,...
                                     'fineDesignMatrix',fineDesignMatrix,...
                                     'validDesignColumn',validDesignColumn,...
                                     't',t,...
                                     'quarters',quarters,...
                                     'tFineMesh',tFineMesh,...
                                     'epochBjd',epochBjd,...
                                     'epochUncertaintyBjd',epochUncertaintyBjd,...
                                     'periodDays',periodDays,...
                                     'periodUncertaintyDays',periodUncertaintyDays,...
                                     'durationDays',durationDays,...
                                     'durationUncertaintyDays',durationUncertaintyDays,...
                                     'depthPpm',depthPpm,...
                                     'depthUncertaintyPpm',depthUncertaintyPpm,...
                                     'inTransit',inTransit,...
                                     'timeoutTriggered',false);

    iPlanet = 0;
    while iPlanet < nPlanets
        iPlanet = iPlanet + 1;

        [modelValid, modelParameters, alertsOnly] = ...
            is_valid_model_for_centroid_test( targetResults, targetStruct.targetIndex, iPlanet, alertsOnly, centroidType );
        
        % retrieve transit model if fit is valid
        % fine mesh model is only used for plotting modeled time series        
        if modelValid
            
            % get model transit struct for this planet
            transitModelStruct = ...
                get_fit_results_for_diagnostic_test(targetResults.planetResultsStruct(iPlanet));
            
            t0 = clock;
            transitModel = ...
                retrieve_dv_centroid_model_transit(transitModelStruct,...
                                                    targetStruct,...
                                                    t,...
                                                    planetFitConfigurationStruct,...
                                                    trapezoidalFitConfigurationStruct,...
                                                    configMaps);
           t1 = clock;
           disp(['    Transit model retrieved in ',num2str(etime(t1,t0)),' seconds']);
           
           if fineMeshEnabled
               fineTransitModel = ...
                    retrieve_dv_centroid_model_transit(transitModelStruct,...
                                                        targetStruct,...
                                                        tFineMesh,...
                                                        planetFitConfigurationStruct,...
                                                        trapezoidalFitConfigurationStruct,...
                                                        configMaps);                                     
           else
               fineTransitModel = [];
           end


            % if model is non-zero, extract parameters and set valid flag for design matrix
            if ~all(transitModel == 0)
                
                % set valid modelflag
                validDesignColumn(iPlanet) = true;

                % make units days
                durationDays(iPlanet)   = modelParameters.transitDurationHours.value / HOURS_PER_DAY;            
                periodDays(iPlanet)     = modelParameters.orbitalPeriodDays.value;
                epochBjd(iPlanet)       = modelParameters.transitEpochBkjd.value;
                depthPpm(iPlanet)       = modelParameters.transitDepthPpm.value;

                durationUncertaintyDays(iPlanet)   = modelParameters.transitDurationHours.uncertainty / HOURS_PER_DAY;
                periodUncertaintyDays(iPlanet)     = modelParameters.orbitalPeriodDays.uncertainty;
                epochUncertaintyBjd(iPlanet)       = modelParameters.transitEpochBkjd.uncertainty;
                depthUncertaintyPpm(iPlanet)       = modelParameters.transitDepthPpm.uncertainty;
                
            else
                
                message = ['No transits in time interval bkjd [',num2str(min(t)),' : ',num2str(max(t)),...
                                                ']. Ignoring fitted transit model for planet ',num2str(iPlanet),'.'];
                disp(['     ' message]);
                if strcmpi(centroidType,'none')
                    alertsOnly = add_dv_alert(alertsOnly,'Pixel correlation test', 'warning', ...
                                                message, targetStruct.targetIndex, targetStruct.keplerId, iPlanet);
                else
                    alertsOnly = add_dv_alert(alertsOnly,'Centroid test', 'warning', ...
                                                message, targetStruct.targetIndex, targetStruct.keplerId, iPlanet);
                end
                
            end
            
        else
            transitModel = zeros(size(t));
            if  fineMeshEnabled
                fineTransitModel = zeros(size(tFineMesh));
            else
                fineTransitModel = [];
            end
        end

        % load transit model into design matrix
        designMatrix( :, iPlanet ) = transitModel(:);
        fineDesignMatrix( :, iPlanet ) = fineTransitModel(:);

        % update inTransitArray flag
        inTransitArray( :, iPlanet ) = abs(transitModel(:)) > SMALL_VALUE;
    end


    % flag cadences with a transit on any planet
    inTransit = colvec( any(inTransitArray,2) );

    % find edges of transits
    transitEdges = find( diff(inTransit) ~= 0 );
    lowEndEdges = transitEdges < PAD_CADENCES + 1;
    highEndEdges = transitEdges > nCadences - PAD_CADENCES;
    transitEdges( lowEndEdges ) = PAD_CADENCES + 1;
    transitEdges( highEndEdges ) = nCadences - PAD_CADENCES;

    % pad the transits on both sides
    for i=1:length(transitEdges)
        inTransit(transitEdges(i)-PAD_CADENCES:transitEdges(i)+PAD_CADENCES) = true;
    end


    % save design matrix and planet fit parameters
    whitenerResultStruct.designMatrix           = designMatrix;
    whitenerResultStruct.fineDesignMatrix       = fineDesignMatrix;
    whitenerResultStruct.validDesignColumn      = validDesignColumn;
    whitenerResultStruct.epochBjd               = epochBjd;
    whitenerResultStruct.epochUncertaintyBjd    = epochUncertaintyBjd;
    whitenerResultStruct.periodDays             = periodDays;
    whitenerResultStruct.periodUncertaintyDays  = periodUncertaintyDays;
    whitenerResultStruct.durationDays           = durationDays;
    whitenerResultStruct.durationUncertaintyDays= durationUncertaintyDays;
    whitenerResultStruct.depthPpm               = depthPpm;
    whitenerResultStruct.depthUncertaintyPpm    = depthUncertaintyPpm;
    whitenerResultStruct.inTransit              = inTransit;

else
    % load previous design matrix and planet fit parameters needed in iterative whitening
    whitenerResultStruct        = previousWhitenerResultsStruct;
    whitenerResultStruct.ra     = tempStruct;
    whitenerResultStruct.dec    = tempStruct;
    
    designMatrix            = whitenerResultStruct.designMatrix;
    durationDays            = whitenerResultStruct.durationDays;
    inTransit               = whitenerResultStruct.inTransit;    
end



% ~~~~~~~~~~~~~~~~~~~ % perform iterative whitening
% first pass = ra centroids, second = dec centroids

for pass = 1:2
    if pass == 1
        centroidDim = 'ra';
    elseif pass == 2
        centroidDim = 'dec';
    end
    
    if (strcmpi(centroidType,'none') && strcmpi(centroidDim,'ra')) ||...
            strcmpi(centroidType,'prf') || strcmpi(centroidType,'fluxWeighted')
        
        % load correct flavor of centroid data
        centroidTimeSeries = centroidStruct.(centroidDim);
        validCentroids = ~centroidTimeSeries.gapIndicators;
        validUncertainties = centroidStruct.(centroidDim).uncertainties > 0;
        
        % seed the valid whitenedDesignMatrix columns (under ra and dec) from overall validDesignColumns one level up
        validDesignColumn = whitenerResultStruct.validDesignColumn;
        
        % require design matrix column for valid centroid cadences to be non-zero for at least one cadence
        validDesignColumn = validDesignColumn & any(abs(designMatrix(validCentroids,:)) > SMALL_VALUE)';
        
        
        if any(validDesignColumn)           
            
            % Process centroid data if enough data points are available.
            % Require MIN_PTS_PER_PLANET both in and out of transit.
            if numel(find( validCentroids & inTransit & validUncertainties)) > MIN_PTS_PER_PLANET * nPlanets &&...
                    numel(find( validCentroids & ~inTransit & validUncertainties)) > MIN_PTS_PER_PLANET * nPlanets
                
                % calculate robust mean out of transit centroid and the propagated variance
                outOfTransitCentroids = centroidTimeSeries.values( validCentroids & ~inTransit & validUncertainties );
                outOfTransitUncertainties = centroidTimeSeries.uncertainties( validCentroids & ~inTransit & validUncertainties);
                
                [meanOutOfTransitCentroid, sdOutOfTransitCentroids, inlierMask] = robust_mean_std( outOfTransitCentroids );
                nValidCentroids = numel(find(inlierMask));
                CmeanOutOfTransitCentroid = sum( outOfTransitUncertainties(inlierMask).^2 ) / nValidCentroids.^2;
                
                % fill any gaps in centroid timeseries
                if any(centroidTimeSeries.gapIndicators)
                    t0 = clock;
                    gapFilledCentroids = ...
                        fill_data_gaps_interp_long(centroidTimeSeries,...
                        detrendParamStruct.gapFillConfigurationStruct,...
                        targetStruct.debugLevel);
                    t1 = clock;
                    disp(['     Gaps filled in ',num2str(etime(t1,t0)),' seconds']);
                else
                    gapFilledCentroids = centroidTimeSeries;
                end
                
                % initialize fit products and loop variables
                nIter = 0;
                oldCoeffs = zeros( nPlanets, 1 );
                oldCovariance = zeros( nPlanets );
                oldRobustChiSquared = 0;
                converged = false;
                
                % iterate
                while nIter < iterationLimit && ~converged 
                    nIter = nIter + 1;
                    
                    if floor((nIter-1)/ITER_INC) * ITER_INC == nIter-1
                        disp(['     iteration = ',num2str(nIter)]);
                    end
                    
                    % test for timeout in whitener loop
                    if etime(clock,testStartTimeSeconds) > tLimitSecs
                        disp(['Timeout of ',num2str(tLimitSecs),' seconds reached.']);
                        whitenerResultStruct.timeoutTriggered = true;
                        break;
                    end
                    
                    % start with gap filled centroid time series
                    residualCentroids = gapFilledCentroids;
                    
                    % form the residual timeseries
                    if nIter == 1
                        t0 = clock;
                        % if the first iteration, gap transits and re-fill
                        residualCentroids.gapIndicators = residualCentroids.gapIndicators | inTransit;
                        residualCentroids = ...
                            fill_data_gaps_interp_long(residualCentroids,...
                            detrendParamStruct.gapFillConfigurationStruct,...
                            targetStruct.debugLevel);
                        t1 = clock;
                        disp(['     Gaps filled in ',num2str(etime(t1,t0)),' seconds']);
                    end
                    
                    % Remove fitted transit signatures and mean out of transit value, propagate uncertainties.
                    % Note on nIter=1 all oldCoeffs=0 so there is no contribution from the
                    % fitted transit signature correction.
                    residualCentroids.values = ...
                        residualCentroids.values -...
                        designMatrix(:,validDesignColumn) * oldCoeffs(validDesignColumn) -...
                        meanOutOfTransitCentroid(:);
                    
                    % We cannot propagate uncertainties using standard POU due to memory constraints
                    % but we can perform the matrix multiplications piece-wise and pick off only
                    % diagonal terms at the final multiplication since those are the only ones
                    % we are interested in.
                    % e.g.
                    % propagatedCovariance = A * Cv * A'
                    %                      = A * (Cv * A')
                    % Then the diagonal elements of the propagated covariance are picked off in a loop.
                    % for i=1:size(A,1)
                    %   diagonalElements(i,i) = A(i,:) * (Cv * A')(:,i);
                    % end
                    
                    
                    % piece-wise POU
                    CvxA = oldCovariance(validDesignColumn,validDesignColumn) * designMatrix(:,validDesignColumn)';
                    diagonalElements = zeros(size(residualCentroids.uncertainties));
                    for iPoint = 1:length(residualCentroids.uncertainties)
                        diagonalElements(iPoint) = designMatrix(iPoint,validDesignColumn) * CvxA(:,iPoint);
                    end
                    
                    residualCentroids.uncertainties = ...
                        sqrt( residualCentroids.uncertainties.^2 + ...
                        diagonalElements + ...
                        CmeanOutOfTransitCentroid );
                    
                    %                    % full POU (for reference)
                    %                    residualCentroids.uncertainties = ...
                    %                        sqrt( residualCentroids.uncertainties.^2 + ...
                    %                                diag( designMatrix(:,validDesignColumn)*...
                    %                                oldCovariance(validDesignColumn,validDesignColumn)*...
                    %                                designMatrix(:,validDesignColumn)' ) + ...
                    %                                CmeanOutOfTransitCentroid );
                    
                    
                    
                    
                    % Construct whitening filter object based on the gap filled
                    % residual. Use longest fitted transit duration as pulse duration
                    % parameter.
                    trialTransitPulseDuration = max( durationDays .* HOURS_PER_DAY ) ;
                    whiteningFilterModel = ...
                        generate_whitening_filter_model(residualCentroids.values, ...
                        false(size(residualCentroids.values)),...
                        trialTransitPulseDuration, ...
                        detrendParamStruct.gapFillConfigurationStruct, ...
                        detrendParamStruct.tpsConfigurationStruct, ...
                        cadenceQuarterLabels) ;
                    
                    whiteningFilterObject = whiteningFilterClass( whiteningFilterModel ) ;
                    
                    % whiten design matrix of transit models column by column
                    whitenedDesignMatrix = zeros( size( designMatrix) );
                    for iPlanet = 1:nPlanets
                        [dummyResidual, whitenedModel] = whiten_time_series( whiteningFilterObject, designMatrix( :, iPlanet ) );                         %#ok<*ASGLU>
                        whitenedDesignMatrix( :, iPlanet ) = whitenedModel(:);
                    end
                    
                    % whiten original gap filled centroids
                    [dummyResidual, whitenedCentroids, whitenerScaleFactor] = ...
                        whiten_time_series( whiteningFilterObject, gapFilledCentroids.values - meanOutOfTransitCentroid );
                    
                    % form whitened uncertainties by applying scaling factor to the quadrature sum
                    % of the original uncertainties and meanCentroid uncertainty (sqrt(var))
                    whitenedUncertainties = sqrt( CmeanOutOfTransitCentroid + gapFilledCentroids.uncertainties.^2 ).* whitenerScaleFactor;
                    
                    % perform robust fit in the whitened domain in order to get the robust weights
                    [fitCoeffs, stats] = robustfit( whitenedDesignMatrix(validCentroids,validDesignColumn),...
                        whitenedCentroids(validCentroids),...
                        'bisquare',...
                        1,...
                        'off');
                    
                    % If robustfit reduces the design matrix dimension because of rank deficiency it will populate the corresponding columns
                    % in the correlation matrix with NaNs. Note fitCoeffs contains the same number of coefficients as the original design
                    % matrix (with the reduced dimension coeff set to zero) while stats.covb contains only entries corresponding to the
                    % valid dimensions of the design matrix. This is a bug in MATLAB. The following block of code is a work around to this bug.
                    % We don't expect robustfit to have to reduce the dimension of the design matrix since we are now checking for zero
                    % columns but we might as well take the belt and suspender approach here.
                    % See KSOC-2426.
                    
                    % build covariance matrix of the correct size using info in stats
                    fitCovariance = zeros(length(fitCoeffs));
                    validCovarianceEntries = ~isnan(stats.coeffcorr);
                    if all(size(fitCovariance(validCovarianceEntries)) == size(stats.covb(:))) || ...
                            (isempty(fitCovariance(validCovarianceEntries)) && isempty(stats.covb(:)))
                        fitCovariance(validCovarianceEntries) = stats.covb;
                    elseif all(size(stats.covb) == size(validCovarianceEntries))
                        fitCovariance(validCovarianceEntries) = stats.covb(validCovarianceEntries);
                    else
                        error('centroidTestIterativeWhitener: dimension mismatch in covariance returned from robustfit');
                    end
                    
                    % make weight vector for all centroids (both valid and ~valid) from robust fit weights
                    w = zeros(size(whitenedCentroids));
                    w(validCentroids) = stats.w;
                    
                    whitenedResidual = whitenedCentroids - whitenedDesignMatrix(:,validDesignColumn) * fitCoeffs;
                    robustChiSquared = sum( w .* whitenedResidual.^2 );
                    
                    fracCoeffDiff = abs((fitCoeffs - oldCoeffs(validDesignColumn))./fitCoeffs);
                    chiSquaredDiff = abs(robustChiSquared - oldRobustChiSquared);
                    
                    % check convergence criteria
                    converged = all( fracCoeffDiff < tolerance ) || chiSquaredDiff < chiSquaredTolerance * robustChiSquared;
                    
                    % update results struct
                    tempStruct.whitenedCentroid         = whitenedCentroids;
                    tempStruct.whitenedUncertainties    = whitenedUncertainties;
                    tempStruct.whitenedGaps             = ~validCentroids;
                    tempStruct.whitenedResidual         = whitenedResidual;
                    tempStruct.whitenedDesignMatrix     = whitenedDesignMatrix;
                    tempStruct.whitenerScaleFactor      = whitenerScaleFactor;
                    tempStruct.whitenedResidualChiSquared = robustChiSquared;
                    
                    tempStruct.coefficients(validDesignColumn)                          = fitCoeffs;
                    tempStruct.covarianceMatrix(validDesignColumn,validDesignColumn)    = fitCovariance;
                    
                    tempStruct.robustWeights                = w;
                    tempStruct.converged                    = converged;
                    tempStruct.nIterations                  = nIter;
                    tempStruct.meanOutOfTransitCentroid     = meanOutOfTransitCentroid;
                    tempStruct.sdOutOfTransitCentroids      = sdOutOfTransitCentroids;
                    tempStruct.CmeanOutOfTransitCentroid    = CmeanOutOfTransitCentroid;
                    tempStruct.residualCentroids            = residualCentroids;
                    tempStruct.rmsResidual                  = stats.ols_s;
                    
                    % save the updated fit values
                    oldCoeffs = tempStruct.coefficients;
                    oldCovariance = tempStruct.covarianceMatrix;
                    oldRobustChiSquared = tempStruct.whitenedResidualChiSquared;
                    
                    % use original gaps for the residual timeseries
                    tempStruct.residualCentroids.gapIndicators = ~validCentroids;
                end                
                
                if nIter == iterationLimit && ~converged
                    message = ['All fit coefficients fractional change not < ',num2str(tolerance),' in ', num2str(iterationLimit),' iterations'];
                    if strcmpi(centroidType,'none')
                        disp(['     ',message,' for ',typeNoneIdentifier]);
                        alertsOnly = add_dv_alert(alertsOnly, 'Pixel correlation test', 'warning',...
                            [message,' for ',typeNoneIdentifier],targetStruct.targetIndex, targetStruct.keplerId);
                    else
                        disp(['     ',message,' for ',centroidDim,' centroids.']);
                        alertsOnly = add_dv_alert(alertsOnly, ['Centroid test, centroidType=',centroidType], 'warning',...
                            [message,' for ',centroidDim,' centroids.'],targetStruct.targetIndex, targetStruct.keplerId);
                    end
                elseif ~whitenerResultStruct.timeoutTriggered
                    disp(['    Whitening complete in ',num2str(nIter),' iterations']);
                end
                
                % adjust validDesignColumns for any reduced dimensionality where the fit coefficient has been set to zero
                % See KSOC-2445.
                validDesignColumn(oldCoeffs == 0) = false;
                tempStruct.validDesignColumn = validDesignColumn;                
                
            else
                message = ['Fewer than ',num2str(MIN_PTS_PER_PLANET * nPlanets),...
                    ' valid points in and out of transit. Iterative whitening not performed'];
                if strcmpi(centroidType,'none')
                    disp(['     ',message,' for ',typeNoneIdentifier]);
                    alertsOnly = add_dv_alert(alertsOnly,'Pixel correlation test', 'warning',...
                        [message,' for ',typeNoneIdentifier],targetStruct.targetIndex, targetStruct.keplerId);
                else
                    disp(['     ',message,' for ',centroidDim,' centroids.']);
                    alertsOnly = add_dv_alert(alertsOnly, ['Centroid test, centroidType=',centroidType], 'warning',...
                        [message,' for ',centroidDim,' centroids.'],...
                        targetStruct.targetIndex, targetStruct.keplerId);
                end
            end
        else
            message = 'No valid transit models in design matrix. Iterative whitening not performed';
            if strcmpi(centroidType,'none')
                disp(['     ',message,' for ',typeNoneIdentifier]);
                alertsOnly = add_dv_alert(alertsOnly,'Pixel correlation test', 'warning',...
                    [message,' for ',typeNoneIdentifier],targetStruct.targetIndex, targetStruct.keplerId);
            else
                disp(['     ',message,' for ',centroidDim,' centroids.']);
                alertsOnly = add_dv_alert(alertsOnly, ['Centroid test, centroidType=',centroidType], 'warning',...
                    [message,' for ',centroidDim,' centroids.'],...
                    targetStruct.targetIndex, targetStruct.keplerId);
            end
        end
    end
    
    % break out of for-loop if timeout occurred
    if whitenerResultStruct.timeoutTriggered
        break;
    end
    
    % load fit results for this centroid type into output struct
    whitenerResultStruct.(centroidDim) = tempStruct;
    
end

