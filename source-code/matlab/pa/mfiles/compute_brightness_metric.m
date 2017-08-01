function brightnessTimeSeries = ...
    compute_brightness_metric( targetStarDataStruct, targetStarResultsStruct, varargin )
%**************************************************************************
% function brightnessTimeSeries = compute_brightness_metric( ...
%     targetStarDataStruct, targetStarResultsStruct, brightnessParamStruct) 
%**************************************************************************
% This function generates the brightness metric timeseries in PA given 
% input of a targetStarDataStruct array, the corresponding 
% targetStarResultsStruct (after the generation of flux time series) and 
% optionally, the brightParamStruct containing parameters used in this 
% calculation. The brightness metric is the mean of the measured flux 
% after it has been normalized by the expected flux for that target over
% all labeled targets. The outliers are identified using robustfit and
% removed prior to averaging. The expected flux for a target is estimated
% from the Kepler magnitude and the expected flux fraction in the target 
% aperature. Zeros are returned for both the metric and it's uncertainty 
% for any cadence where less than minimumBrightTargets are ungapped 
% non-outliers. The gap indicator is also set. Empty arrays are returned 
% if the targetStarData list is empty.
%
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
% INPUT:
%     targetStarDataStruct:     array of structs with the following fields:
%         keplerMag:                [float]         target magnitude
%         labels:                   [string array]  target labels
%         fluxFractionInAperture:   [float]         fraction of flux in aperture for brightness metric
%     targetStarResultsStruct:  array of structs with the following fields:
%         fluxTimeSeries:           [struct]    target flux time series structure with the following fields:
%             values:                   [float array]       data values
%             uncertainties:            [float array]       uncertainties in data values
%             gapIndicators:            [logical array]     data gap indicators
%     ---------  VARIABLE INPUTS ----------------
%     brightParamStruct:        structure with the following fields
%             standardMag12Flux         [float]             expected flux from magnitude 12 target
%             brightnessLabel           [string]            label identifying brightness metric targets
%             brightRobustThreshold     [float]             threshold weight below which outliers are rejected in robust fit
%             minimumBrightTargets      [int]               minimum number of bright targets needed to compute brightness metric
% OUTPUT:
%     brightnessTimeSeries:     structure with the following fields  
%         values:                 [float array]	nCadences x 1 brightness metric
%         uncertainties:          [float array]	nCadences x 1 uncertainty of brightness metric
%         gapIndicators:          [logical array] nCadences x 1 gap indicator
%
%**************************************************************************

% DEFAULT BRIGHTNESS STRUCT PARAMETERS - PARAM STRUCT may BE PASSED AS VARIABLE ARGUMENT
MAG12 = 2.09e7;             % expected integrated flux from magnitude 12 target per long cadence in photoelectrons
%MAG12 = 3.85e8;            % value from fcConstants converted to 30 minute cadence rate
LABEL = 'brightTarget';     % label identifying brightness metric targets
ROBUST_THRESHOLD = 0.05;    % threshold weight below which outliers are rejected in robust fit
MIN_TARGETS = 10;           % minimum number of bright targets needed to compute brightness metric

% initialize outputs
brightMetric = [];
CbrightMetric = [];
brightnessGaps = [];
validInputStructs = false;

% load parameters from brightParamStruct input as variable argument of set defaults
if(nargin>2 && isstruct(varargin{1}))
    brightParamStruct = varargin{1};
    
    if(isfield(brightParamStruct,'standardMag12Flux'))
        standardMag12Flux = brightParamStruct.standardMag12Flux;
    else
        standardMag12Flux = MAG12;
    end
    
    if(isfield(brightParamStruct,'brightnessLabel'))
        brightnessLabel = brightParamStruct.brightnessLabel;
    else
        brightnessLabel = LABEL;
    end   

    if(isfield(brightParamStruct,'brightRobustThreshold'))
        brightRobustThreshold = brightParamStruct.brightRobustThreshold;
    else
        brightRobustThreshold = ROBUST_THRESHOLD;
    end   

    if(isfield(brightParamStruct,'minimumBrightTargets'))
        minimumBrightTargets = brightParamStruct.minimumBrightTargets;
    else
        minimumBrightTargets = MIN_TARGETS;
    end  
else
    standardMag12Flux = MAG12;
    brightnessLabel = LABEL;
    brightRobustThreshold = ROBUST_THRESHOLD;         
    minimumBrightTargets = MIN_TARGETS;
end

% check input data structures
if(isstruct(targetStarDataStruct) && isstruct(targetStarResultsStruct))
    if(isfield(targetStarDataStruct,'keplerMag') &&...
            isfield(targetStarDataStruct,'labels') &&...
            isfield(targetStarDataStruct,'fluxFractionInAperture'))
        if(isfield(targetStarResultsStruct,'fluxTimeSeries'))
            if(~isempty(targetStarDataStruct) && length(targetStarDataStruct) == length(targetStarResultsStruct))
                if(isstruct(targetStarResultsStruct(1).fluxTimeSeries))
                    if(isfield(targetStarResultsStruct(1).fluxTimeSeries,'values') &&...
                            isfield(targetStarResultsStruct(1).fluxTimeSeries,'uncertainties') &&...
                            isfield(targetStarResultsStruct(1).fluxTimeSeries,'gapIndicators'))
                        if(iscolvector(standardMag12Flux) &&...
                                ischar(brightnessLabel) &&...
                                isscalar(brightRobustThreshold) &&...
                                isscalar(minimumBrightTargets))
                          validInputStructs = true;
                        end
                    end
                end
            end
        end
    end
end


if(validInputStructs)
    
    % select target indices with brightnessLabel
    brightIndices = false(length(targetStarDataStruct),1);
    for i=1:length(targetStarDataStruct)
        brightIndices(i) = any(ismember(targetStarDataStruct(i).labels, brightnessLabel));
    end

    % if no targets were labeled process all targets in list
    if(~any(brightIndices))
        brightIndices = true(size(brightIndices));
    end

    % select only brightIndices for fields of interest
    keplerMag = [targetStarDataStruct(brightIndices).keplerMag];
    fluxFractionInAperture = [targetStarDataStruct(brightIndices).fluxFractionInAperture];
    fluxTimeSeries = [targetStarResultsStruct(brightIndices).fluxTimeSeries];
    
    % assemble measured data arrays - nCadences x nTargets
    measuredFlux = [fluxTimeSeries.values];
    CmeasuredFlux = [fluxTimeSeries.uncertainties];
    fluxGapIndicators = [fluxTimeSeries.gapIndicators];  

    % release memory
    clear fluxTimeSeries

    if(any(brightIndices))

        [nCadences, nTargets] = size(measuredFlux);

        % pre-allocate array space for results
        brightMetric = zeros(nCadences,1);
        CbrightMetric = zeros(nCadences,1);
        brightnessGaps = true(nCadences,1);

        % compute expected flux for all targets as nCadences x nTargets matrix
        if( isscalar(standardMag12Flux) )
            expectedFlux = ( standardMag12Flux .* ones(nCadences,1) ) * ( mag2b(keplerMag-12) .* fluxFractionInAperture );
        else
            expectedFlux = standardMag12Flux * ( mag2b(keplerMag-12) .* fluxFractionInAperture );
        end

        % compute normalized brightness
        brightRatio = ~fluxGapIndicators .* measuredFlux ./ expectedFlux; 
        CbrightRatio = ~fluxGapIndicators .* CmeasuredFlux ./ expectedFlux;
        
        % release memory
        clear measuredFlux CmeasuredFlux expectedFlux

        % determine robust mean cadence-by-cadence
        for i=1:nCadences

            ungappedTargets = find( fluxGapIndicators(i,:) == false );

            if( length(ungappedTargets) >= minimumBrightTargets )

                % use robust fit to identify outliers
                [robustMean, stats] = robustfit(ones(length(ungappedTargets),1),brightRatio(i,ungappedTargets)',[],[],'off');
                notOutliers = ungappedTargets(stats.w > brightRobustThreshold);

                % use unweighted mean of non-outliers to generate metric
                % uncertainties are propagated assuming the measured flux
                % uncertainties are uncorrelated
                if(~isempty(notOutliers))
                    brightMetric(i) = mean(brightRatio(i,notOutliers));
                    CbrightMetric(i) = sqrt(sum(CbrightRatio(i,notOutliers).^2)) / length(notOutliers);
                    brightnessGaps(i) = false;
                end
            else
                warning('Unable to compute brightness metric: number of available targets < %d.', minimumBrightTargets)
            end
        end
    end
end

brightnessTimeSeries.values = brightMetric;
brightnessTimeSeries.uncertainties = CbrightMetric;
brightnessTimeSeries.gapIndicators = brightnessGaps;

