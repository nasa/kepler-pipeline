function [targetResults, alertsOnly] = estimate_dv_centroid_offset(centroidStruct,...
                                                                    targetStruct,...
                                                                    targetResults,...
                                                                    whitenerResultsStruct,...
                                                                    normalizedTargetFlux,...
                                                                    centroidType,...
                                                                    centroidTestConfigurationStruct,...
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
% function [targetResults, alertsOnly] = estimate_dv_centroid_offset(centroidStruct,...
%                                                                     targetStruct,...
%                                                                     targetResults,...
%                                                                     whitenerResultsStruct,...
%                                                                     normalizedTargetFlux,...
%                                                                     centroidType,...
%                                                                     centroidTestConfigurationStruct,...
%                                                                     alertsOnly)
%
% This DV function estimates the peak in-transit offset of the centroid time series in right ascension and declination angle on the sky due
% to each detected planet and returns the values in the targetResults. The magnitude of the centroid offset is also computed and returned in
% the targetResults. The fit coefficients from the centroid test iterative whitener as well as the fractional transit depth from the transit
% model fitter are provided in the whitenerResultsStruct. Plots of the corrected flux time series and the detrended ra and dec centroid time
% series are provided in both folded and unfolded versions. The fits determined from the centroid test iterative whitener are overlayed on
% the centroid plots. Peak centroid offsets and 1-sigma propagated uncertainties are indicated.

disp('DV:CentroidTest:Estimating centroid offset');

% hard coded
MAD_TO_SIGMA = 1.4826;                  % 1 sigma = 1.4826 MAD for a normal distribution

% unpack parameters
motionResultsString = [centroidType,'MotionResults'];
nPlanets = length( targetResults.planetResultsStruct );
targetDecDegrees = targetStruct.decDegrees.value;

FOLDED_TRANSIT_DURATIONS_SHOWN              = centroidTestConfigurationStruct.foldedTransitDurationsShown;
TRANSIT_DURATIONS_MASKED                    = centroidTestConfigurationStruct.transitDurationsMasked;                                       %#ok<NASGU>
TRANSIT_DURATION_FACTOR_FOR_MEDIAN_FILTER   = centroidTestConfigurationStruct.transitDurationFactorForMedianFilter;
PLOT_OUTLIER_THRESHOLD_IN_SIGMA             = centroidTestConfigurationStruct.plotOutlierThesholdInSigma;
MINUTES_PER_CADENCE                         = centroidTestConfigurationStruct.minutesPerCadence;
MAXIMUM_TRANSIT_DURATION_IN_CADENCES        = centroidTestConfigurationStruct.maximumTransitDurationCadences;

% unit conversions
HOURS_PER_DAY = get_unit_conversion('day2hour');
MINUTES_PER_HOUR = get_unit_conversion('hour2min');
SECONDS_PER_MINUTE = get_unit_conversion('min2sec');
DEGREES_PER_DAY = 360;
DEGREES_TO_ARCSEC = MINUTES_PER_HOUR * SECONDS_PER_MINUTE;
DEGREES_TO_MARCSEC = 1000 * DEGREES_TO_ARCSEC;
DEGREES_TO_HOURS = HOURS_PER_DAY / DEGREES_PER_DAY;

% retrieve transit model variables from whitener results
t                   = whitenerResultsStruct.t;
quarters            = whitenerResultsStruct.quarters;
tFineMesh           = whitenerResultsStruct.tFineMesh;
fineDesignMatrix    = whitenerResultsStruct.fineDesignMatrix;
validDesignColumn   = whitenerResultsStruct.validDesignColumn;
durationDays        = whitenerResultsStruct.durationDays;
periodDays          = whitenerResultsStruct.periodDays;
epochBjd            = whitenerResultsStruct.epochBjd;

% retrieve in-transit mask (true == any planet in transit)
inTransit = whitenerResultsStruct.inTransit;

% plot relative to 12:00 Jan-1-2009 (KJD). Since all barycentric timestamps
% in DV are now in BKJD, this makes t0 = 0 (for now!).
t0 = 0;

% initialize transit minima time cell array
tTransitMinima = cell(1,nPlanets);

% ~~~~~~~~~~~~ generate transit center times from fine mesh models
iPlanet = 0;
while( iPlanet < nPlanets )
    iPlanet = iPlanet + 1;
    if( validDesignColumn(iPlanet) )
        
        % generate unique sorted list of barycentric transit center times
        expectedTransitCenters = [(epochBjd(iPlanet):-periodDays(iPlanet):t(1)),(epochBjd(iPlanet):periodDays(iPlanet):t(end))];
        
        % in case epoch is outside unit of work, select only centers in unit of work
        inUowIndicator = expectedTransitCenters > t(1) & expectedTransitCenters < t(end);
        expectedTransitCenters = expectedTransitCenters(inUowIndicator);
        
        % sort and don't double count
        tTransitMinima{iPlanet} = unique( expectedTransitCenters );
        
        % use the fine mesh model to find the timestamps of model minima for each transit
        nTransits = length(tTransitMinima{iPlanet});
        
        % replace transit center time with model minima time for each transit
        for iTransit = 1:nTransits
            tTransit = tTransitMinima{iPlanet}(iTransit);
            inTransitModel  = fineDesignMatrix(tFineMesh > (tTransit-durationDays(iPlanet)) & tFineMesh < (tTransit+durationDays(iPlanet)),iPlanet);
            inTransitTime   = tFineMesh(tFineMesh > (tTransit-durationDays(iPlanet)) & tFineMesh < (tTransit+durationDays(iPlanet)) );
            [dummy, t0_new_idx] = min( inTransitModel );                                                                                                %#ok<*ASGLU>
            tTransitMinima{iPlanet}(iTransit) = inTransitTime(t0_new_idx);
        end
    else
        tTransitMinima{iPlanet} = [];
    end
end


% ~~~~~~~~~~~~~~~~~ % estimate in-transit centroid offset from iterative whitener results
pass = 0;
while( pass < 2 )
    pass = pass + 1;
    if( pass == 1 )
        dim = 'ra';
    else
        dim = 'dec';
    end

    for iPlanet = 1:nPlanets
        if( validDesignColumn(iPlanet) && whitenerResultsStruct.(dim).converged )

            % Since the transit model is a negative deflection from zero, a
            % positive centroid shift will have a negative fit coefficient.
            % So the amplitude of the centroid shift is the negative of the
            % fit coefficient scaled by transitdepth/(1 - transitdepth)) ~ transitdepth.
            transitDepth = whitenerResultsStruct.depthPpm(iPlanet) / 1e6;
            transitDepthUnc = whitenerResultsStruct.depthUncertaintyPpm(iPlanet) / 1e6;
            CtransitDepth = transitDepthUnc^2;
            amplitude = -whitenerResultsStruct.(dim).coefficients(iPlanet);
            Camplitude = whitenerResultsStruct.(dim).covarianceMatrix(iPlanet,iPlanet);

            % calculate peak centroid offset in the unwhitened domain from
            % the peak centroid offset in the whitened domain
            
%             peakOffset = amplitude * transitDepth;
             
            % 6/19/12 - Update to use exact formula for transit source location. See KSOC-1897
            peakOffset = amplitude * ( transitDepth/(1 -  transitDepth) );

%             % propagate uncertainties
%             if( transitDepthUnc < 0 )
%                 peakOffsetUncertainty = sqrt( Camplitude * transitDepth^2 );
%             else
%                 % I DON"T UNDERSTAND THE FACTOR OF 4 IN THE DENOMINATOR HERE  !!!!!   ( 20120524 -- BC )
%                 % s/b peakOffsetUncertainty = sqrt( Camplitude * transitDepth^2 + amplitude^2 * CtransitDepth );
%                 peakOffsetUncertainty = sqrt( (Camplitude * transitDepth^2 + amplitude^2 * CtransitDepth)/4 );
%             end
            
            % 6/19/12 - Update propagation of uncertainties to use exact formula for transit source location. See KSOC-1897
            if( transitDepthUnc < 0 )
                peakOffsetUncertainty = sqrt( Camplitude * transitDepth^2 / ( 1 - transitDepth )^2 );
            else
                peakOffsetUncertainty = sqrt( Camplitude * (transitDepth/( 1 - transitDepth ))^2 +...
                    CtransitDepth * transitDepth^2 / (1 - transitDepth)^4 );
            end
            

            % update results structure
            if( strcmp(dim,'ra') )
                % correct for cos(dec)
                targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).peakRaOffset.value =...
                    peakOffset * DEGREES_TO_ARCSEC * cosd(targetDecDegrees);
                targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).peakRaOffset.uncertainty =...
                    peakOffsetUncertainty * DEGREES_TO_ARCSEC * cosd(targetDecDegrees);
            elseif( strcmpi(dim,'dec') )
                targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).peakDecOffset.value =...
                    peakOffset * DEGREES_TO_ARCSEC;
                targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).peakDecOffset.uncertainty =...
                    peakOffsetUncertainty * DEGREES_TO_ARCSEC;
            end            

        else
            if( ~validDesignColumn(iPlanet))
                disp(['     Transit model not available. Cannot solve for ',dim,...
                    ' centroid offset. Using default values for planet ',num2str(iPlanet),'.']);
                alertsOnly = add_dv_alert(alertsOnly, ['Centroid test ',centroidType], 'warning',...
                    ['Transit model not available. Cannot solve for ',dim,...
                    ' centroid offset. Using default values for planet ',num2str(iPlanet),'.'],...
                    targetStruct.targetIndex, targetStruct.keplerId, iPlanet);
            elseif( ~whitenerResultsStruct.(dim).converged )
                disp(['     Iterative whitener did not converge. Cannot solve for ',dim,...
                    ' centroid offset. Using default values for planet ',num2str(iPlanet),'.']);
                alertsOnly = add_dv_alert(alertsOnly, ['Centroid test ',centroidType], 'warning',...
                    ['Iterative whitener did not converge. Cannot solve for ',dim,...
                    ' centroid offset. Using default values for planet ',num2str(iPlanet),'.'],...
                    targetStruct.targetIndex, targetStruct.keplerId, iPlanet);
            end
        end
        
        % if both ra and dec peak offset were updated then update peak offset
        raOffset    = targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).peakRaOffset.value;
        raOffsetUnc = targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).peakRaOffset.uncertainty;
        decOffset   = targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).peakDecOffset.value;
        decOffsetUnc = targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).peakDecOffset.uncertainty;
        
        % compute offset magnitude and its uncertainty
        if raOffsetUnc ~= -1 && decOffsetUnc ~= -1
            offsetArcSec = sqrt(raOffset^2 + decOffset^2);
            if offsetArcSec ~= 0
                offsetArcSecUnc = (1/offsetArcSec) * sqrt(raOffset^2 * raOffsetUnc^2  +  decOffset^2 * decOffsetUnc^2 );
            else
                offsetArcSecUnc = sqrt( raOffset^2 + decOffsetUnc^2 );
            end
            targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).peakOffsetArcSec.value       = offsetArcSec;
            targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).peakOffsetArcSec.uncertainty = offsetArcSecUnc;                    
        end        
    end
end



% ~~~~~~~~~~~~~~~~~ % plot unfolded and folded results
% find quarter indices spanning the unit of work
quarterIndex = unique(quarters);

iPlanet = 0;
while( iPlanet < nPlanets )
    iPlanet = iPlanet + 1;

    % calculate transit duration in number of cadences
    transitDurationCadences = MAXIMUM_TRANSIT_DURATION_IN_CADENCES;
    if( durationDays(iPlanet) > 0 )
        transitDurationCadences = durationDays(iPlanet) * MINUTES_PER_HOUR * HOURS_PER_DAY / MINUTES_PER_CADENCE;
    end

    % set median filt order = odd number of cadences covering duration * factor
    medfiltOrder = ceil(transitDurationCadences * TRANSIT_DURATION_FACTOR_FOR_MEDIAN_FILTER );
    if( floor(medfiltOrder/2)*2 == medfiltOrder )
        medfiltOrder = medfiltOrder + 1;
    end

    % median filter detrending of relative flux
    relativeFlux = normalizedTargetFlux.values - medfilt1_soc(normalizedTargetFlux.values,medfiltOrder);

    % k = 0 --> unfolded plots, k = 1 --> folded plots
    for k = 0:1        
        % set up appropriate time vectors and plot
        if( k==0 )
            for iQuarter = rowvec(quarterIndex) 
                
                % plot unfolded data by quarter
                tOffset = t0;
                validForQuarter = (quarters == iQuarter);
                tmin = min(t(validForQuarter));
                tmax = max(t(validForQuarter));
                transitMark = tTransitMinima{iPlanet};
                transitMark = transitMark( transitMark >= tmin & transitMark <= tmax );
                
                % build unfolded time vectors and logical indices
                tPlot = t;
                tFinePlot = tFineMesh;
                validFoldedIdx = validForQuarter;
                validFoldedFineIdx = tFinePlot >= tmin & tFinePlot <= tmax;
                fineMeshIdx = 1:length(tFinePlot);
                
                % set up plot strings
                titleString = [centroidType,'Centroids, Planet ',num2str(iPlanet),' of ',num2str(nPlanets),...
                                ', Quarter ',num2str(iQuarter)];
                xLabelString = ['BJD - ',num2str(kjd_offset_from_jd),' (days)'];           

                % call plotting sub-function
                plot_flux_and_centroids_over_time;
            end
        else
            if( ~isempty(tTransitMinima{iPlanet}) )
                
                % plot folded data
                tOffset = 0;                
                transitMark = tTransitMinima{iPlanet};
                                                
                % build folded time vectors and logical indices
                tPlot = mod( t - transitMark(1) + periodDays(iPlanet)/2, periodDays(iPlanet) ) - periodDays(iPlanet)/2;
                [tFinePlot, fineMeshIdx] = ...
                    sort( mod( tFineMesh - transitMark(1) + periodDays(iPlanet)/2, periodDays(iPlanet) ) - periodDays(iPlanet)/2 );

                % only plot data within FOLDED_TRANSIT_DURATIONS_SHOWN/2 of transit center
                validFoldedIdx = abs(tPlot) <= (FOLDED_TRANSIT_DURATIONS_SHOWN/2) * durationDays(iPlanet);
                validFoldedFineIdx = abs(tFinePlot) <= (FOLDED_TRANSIT_DURATIONS_SHOWN/2) * durationDays(iPlanet);                
                tmin = min(tPlot(validFoldedIdx));
                tmax = max(tPlot(validFoldedIdx));               
                                
                % folded plots time units (days)
                tOffset = tOffset .* HOURS_PER_DAY;
                tPlot = tPlot .* HOURS_PER_DAY;
                tFinePlot = tFinePlot .* HOURS_PER_DAY;                
                transitMark = transitMark .* HOURS_PER_DAY;
                tmin = tmin .* HOURS_PER_DAY;
                tmax = tmax .* HOURS_PER_DAY;
                
                % set up plot strings
                titleString = [centroidType,'Centroids, Planet ',num2str(iPlanet),' of ',num2str(nPlanets)];
                xLabelString = 'Orbital Phase (hours)';
                
                % call plotting sub-function
                plot_flux_and_centroids_over_time;
            end
        end
    end
end

return;



% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% use nested function plot_flux_and_centroids_over_time to make the code above more readable
    function plot_flux_and_centroids_over_time

        % plot formatting parameters
        TEXTBOX_BACKGROUND_COLOR = 'yellow';
        FOLDED_PERIOD_TEXTBOX_LOCATION  = [0.138 0.72 0.120 0.050];
        ANNOTATION_POSITION = [.002 .001 .3 .06];
        FLUX_LEGEND_LOCATION = [.480 .636 .08 .03];
        CENTROID_LEGEND_LOCATION = [.480 .336 .08 .03];
        FIGURE_POSITION = [565 315 970 780];
        
        TRANSIT_MARKER_STRING = 'o-r';

        centroidLegend = {'detrended centroid','fit to transit model','peak offset'};

        unfoldedCaption = ['KeplerId ',num2str(targetStruct.keplerId,'%8i'),...
            ', KeplerMag ',num2str(targetStruct.keplerMag.value,'%2.2f'),' - UNFOLDED FLUX AND CENTROIDS -',...
            ' This figure shows detrended flux and centroid data over the full time',...
            ' range of the data set. The top panel shows the change in corrected flux for this',...
            ' target, normalized to the median out of transit value, median detrended',...
            ' with the median out of transit value removed. The bottom two panels show',...
            ' the corresponding change in the centroid in right ascension (RA) and declination (DEC)',...
            ' angles on the sky. The centroids are detrended against ancillary data and have the',...
            ' mean out-of-transit value removed. The scaled transit model fit to the target flux is',...
            ' shown on the centroid plots in red. The peak fitted offset from the out of',...
            ' transit centroid is indicated by the solid black horizontal line. One',...
            ' sigma error bars are indicated with dashed black horizontal lines. Red circles',...
            ' and vertical lines mark the fitted transit centers. In-transit data points for',...
            ' any other planets identified for this target have been gapped. ',...
            ' The out-of-transit mean and standard deviation (SD) indicated in the lower',...
            ' left-hand corner are robust estimates.'];

        foldedCaption = ['KeplerId ',num2str(targetStruct.keplerId,'%8i'),...
            ', KeplerMag ',num2str(targetStruct.keplerMag.value,'%2.2f'),' - FOLDED FLUX AND CENTROIDS -',...
            ' This figure shows detrended flux and centroid data folded at the fitted orbital',...
            ' period and centered on the fitted transit over a few fitted transit durations.',...
            ' The top panel shows the change in corrected flux for this',...
            ' target, normalized to the median out of transit value, median detrended',...
            ' with the median out of transit value removed. The bottom two panels show',...
            ' the corresponding change in the centroid in right ascension (RA) and declination (DEC)',...
            ' angles on the sky. The centroids are detrended against ancillary data and have the',...
            ' mean out-of-transit value removed. The scaled transit model fit',...
            ' to the target flux is shown on the centroid plots in red. The peak fitted',...
            ' offset from the out-of-transit centroid is indicated by the solid black',...
            ' horizontal line. One sigma error bars are indicated with dashed black',...
            ' horizontal lines. In-transit data points for any other planets identified',...
            ' for this target have been gapped. The out-of-transit mean and standard',...
            ' deviation (SD) indicated in the lower left-hand corner are robust estimates.'];

        % declare subfigure handle array
        ax = [0,0,0];

        % require valid transit model for all panels of folded plots
        if( k==0 || (k==1 && validDesignColumn(iPlanet)) && ~isempty(transitMark) )

            % ~~~~~~~~~~~~~~~~~~~~~~~ make figure for this planet
            h = figure;
            set(h,'Position',FIGURE_POSITION);
            set(h,'Visible','off');
            panelPlotted = false(3,1);
            % ~~~~~~~~~~~~~~~~~~~~~~~ make flux subplot
            ax(1) = subplot(3,1,1);
            hold on;
            
            validIndices = ~normalizedTargetFlux.gapIndicators & validFoldedIdx;
            
            % use whitened residuals of centroid time series to identify
            % outlier indices in flux time series
            if( ~isempty(whitenerResultsStruct.ra.whitenedResidual) )
                validIndices = validIndices & abs(whitenerResultsStruct.ra.whitenedResidual) < PLOT_OUTLIER_THRESHOLD_IN_SIGMA;
            end
            if( ~isempty(whitenerResultsStruct.dec.whitenedResidual) )
                validIndices = validIndices & abs(whitenerResultsStruct.dec.whitenedResidual) < PLOT_OUTLIER_THRESHOLD_IN_SIGMA;
            end
            
            % use MAD of flux time series to further identify outliers on
            % set of out of transit points
            if( ~all(~inTransit) )
                validIndices(~inTransit) = validIndices(~inTransit) & ...
                     abs(relativeFlux(~inTransit)) < mad(relativeFlux(~inTransit),1) * MAD_TO_SIGMA * PLOT_OUTLIER_THRESHOLD_IN_SIGMA;
            end
            
            % plot flux data if available
            if ( ~isempty(relativeFlux(validIndices)) )
                
                % model all planets but this planet
                if( ~isempty( whitenerResultsStruct.designMatrix ) )
                    modelMask = validDesignColumn;
                    modelMask(iPlanet) = false;
                    modeledResidual = whitenerResultsStruct.designMatrix * modelMask;
                else
                    modeledResidual = zeros(size(relativeFlux));
                end
                % valid residual in ppm
                modeledResidual = 1e6 .* modeledResidual(validIndices);
                
                % relative time and data in ppm
                time = tPlot(validIndices) - tOffset;                
                data = 1e6.*(relativeFlux(validIndices));
                
                % plot flux less all other planets
                plot(time, data - modeledResidual, 'bx');
                panelPlotted(1) = true;

                % mark transits on unfolded plots only
                if( k==0 && ~isempty(transitMark) )
                    vline(transitMark - tOffset,TRANSIT_MARKER_STRING);
                    set(ax(1),'yLimMode','manual');
                end
                l = legend('detrended flux','Orientation','Horizontal');
                set(l,'Position',FLUX_LEGEND_LOCATION);
            end
            grid on;
            ylabel('\Delta flux (ppm)');
            title(titleString);
            

            
            % ~~~~~~~~~~~~~~~~~~~~~~~ make ra subplot
            ax(2) = subplot(3,1,2);
            hold on;
            raLegendLogicalIdx = false(3,1);
            
            centroid = centroidStruct.ra.values;
            validIndices = ~centroidStruct.ra.gapIndicators & validFoldedIdx;

            % use whitened residuals to identify outliers            
            if( ~isempty(whitenerResultsStruct.ra.whitenedResidual) )
                validIndices = validIndices & abs(whitenerResultsStruct.ra.whitenedResidual) < PLOT_OUTLIER_THRESHOLD_IN_SIGMA;
            else
                if( ~isempty(centroid(validIndices)) )
                    % use MAD of time series to identify outliers
                    validIndices = validIndices & abs(centroid - median(centroid(validIndices))) < ...
                        mad(centroid(validIndices),1) * MAD_TO_SIGMA * PLOT_OUTLIER_THRESHOLD_IN_SIGMA;
                end
            end
                        
            % plot ra data if available
            if ( ~isempty(centroid(validIndices)) )
                
                % set up raw data to plot
                time = tPlot(validIndices) - tOffset;
                % correct for cos(dec)
                data = cosd(targetDecDegrees) .* DEGREES_TO_MARCSEC .* centroid(validIndices);
                
                % model all planets but this planet + bias
                if ( whitenerResultsStruct.ra.converged )                    
                    R0 = whitenerResultsStruct.ra.meanOutOfTransitCentroid;
                    modelMask = whitenerResultsStruct.ra.coefficients;
                    modelMask(iPlanet) = 0;
                    modeledResidual = whitenerResultsStruct.designMatrix * modelMask;
                else
                    R0 = mean(centroid(validIndices));                    
                    modeledResidual = zeros(size(centroid));
                end
                % correct for cos(dec)
                modeledResidual = cosd(targetDecDegrees) .* DEGREES_TO_MARCSEC .* (modeledResidual(validIndices) + R0);
                
                % plot detrended centroid timeseries delta from bias less modeled residual
                
                plot( time, data - modeledResidual,'bo');
                panelPlotted(2) = true;
                raLegendLogicalIdx(1) = true;
                                
                % overlay fit results if available
                if ( validDesignColumn(iPlanet) && whitenerResultsStruct.ra.converged )
                    
                    % correct ra model for cos(dec)
                    modeledPlanet = cosd(targetDecDegrees) .* DEGREES_TO_MARCSEC .* ...
                        whitenerResultsStruct.fineDesignMatrix(fineMeshIdx(validFoldedFineIdx),iPlanet) .* ...
                        whitenerResultsStruct.ra.coefficients(iPlanet);
                                        
                    time = tFinePlot(validFoldedFineIdx) - tOffset;
                    
                    % get offsets from results struct (in arc-sec)
                    peakOffset = targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).peakRaOffset.value;
                    peakOffsetUncertainty = targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).peakRaOffset.uncertainty;
                    
                    % overlay fitted model
                    plot( time, modeledPlanet, '-r', 'LineWidth', 1);
                    raLegendLogicalIdx(2) = true;
                    
                    % overlay peak offset, fitted model and peak offset error bars
                    aa = axis;
                    plot( aa(1:2), 1000.*peakOffset.*[1, 1], '->k', 'LineWidth', 1);
                    raLegendLogicalIdx(3) = true;
                    
                    % overlay peak offset error bars
                    plot( aa(1:2), 1000.*(peakOffset + peakOffsetUncertainty).*[1, 1], '--k');
                    plot( aa(1:2), 1000.*(peakOffset - peakOffsetUncertainty).*[1, 1], '--k');
                end
                
                % mark transits on unfolded plots only
                if( k==0 && ~isempty(transitMark) )
                    vline(transitMark - tOffset,TRANSIT_MARKER_STRING);
                    set(ax(2),'yLimMode','manual');
                end
                grid on;
            end
            hold off;
            ylabel('\Delta RA (marc-sec)');


            % ~~~~~~~~~~~~~~~~~~~~~~~ make dec subplot
            ax(3) = subplot(3,1,3);
            hold on;
            decLegendLogicalIdx = false(3,1); 
            
            centroid = centroidStruct.dec.values;
            validIndices = ~centroidStruct.dec.gapIndicators & validFoldedIdx;
            
            % use whitened residuals to identify outliers            
            if( ~isempty(whitenerResultsStruct.dec.whitenedResidual) )
                validIndices = validIndices & abs(whitenerResultsStruct.dec.whitenedResidual) < PLOT_OUTLIER_THRESHOLD_IN_SIGMA;
            else
                if( ~isempty(centroid(validIndices)) )
                    % use MAD of time series to identify outliers
                    validIndices = validIndices & abs(centroid - median(centroid(validIndices))) < ...
                        mad(centroid(validIndices),1) * MAD_TO_SIGMA * PLOT_OUTLIER_THRESHOLD_IN_SIGMA;
                end
            end

            
            % plot dec data if available
            if ( ~isempty(centroid(validIndices)) )
                
                % set up raw data to plot
                time = tPlot(validIndices) - tOffset;
                data = DEGREES_TO_MARCSEC .* centroid(validIndices);
                
                % model all planets but this planet + bias
                if ( whitenerResultsStruct.dec.converged )                    
                    R0 = whitenerResultsStruct.dec.meanOutOfTransitCentroid;
                    modelMask = whitenerResultsStruct.dec.coefficients;
                    modelMask(iPlanet) = 0;
                    modeledResidual = whitenerResultsStruct.designMatrix * modelMask;
                else
                    R0 = mean(centroid(validIndices));                    
                    modeledResidual = zeros(size(centroid));
                end
                modeledResidual = DEGREES_TO_MARCSEC .* (modeledResidual(validIndices) + R0);
                
                % plot detrended centroid timeseries delta from bias less modeled residual
                plot( time, data - modeledResidual,'bo');
                panelPlotted(2) = true;
                decLegendLogicalIdx(1) = true;
                                
                % overlay fit results if available
                if ( validDesignColumn(iPlanet) && whitenerResultsStruct.dec.converged )
                    
                    modeledPlanet = DEGREES_TO_MARCSEC .* ...
                        whitenerResultsStruct.fineDesignMatrix(fineMeshIdx(validFoldedFineIdx),iPlanet) .* ...
                        whitenerResultsStruct.dec.coefficients(iPlanet);
                                        
                    time = tFinePlot(validFoldedFineIdx) - tOffset;
                    
                    % get offsets from results struct (in arc-sec)
                    peakOffset = targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).peakDecOffset.value;
                    peakOffsetUncertainty = targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).peakDecOffset.uncertainty;
                    
                    % overlay fitted model
                    plot( time, modeledPlanet, '-r', 'LineWidth', 1);
                    decLegendLogicalIdx(2) = true;
                    
                    % overlay peak offset, fitted model and peak offset error bars
                    aa = axis;
                    plot( aa(1:2), 1000.*peakOffset.*[1, 1], '->k', 'LineWidth', 1);
                    decLegendLogicalIdx(3) = true;
                    
                    % overlay peak offset error bars
                    plot( aa(1:2), 1000.*(peakOffset + peakOffsetUncertainty).*[1, 1], '--k');
                    plot( aa(1:2), 1000.*(peakOffset - peakOffsetUncertainty).*[1, 1], '--k');
                end
                
                % mark transits on unfolded plots only
                if( k==0 && ~isempty(transitMark) )
                    vline(transitMark - tOffset,TRANSIT_MARKER_STRING);
                    set(ax(3),'yLimMode','manual');
                end
                grid on;
            end
            hold off;
            ylabel('\Delta DEC (marc-sec)');
            xlabel(xLabelString);
            if( any(raLegendLogicalIdx | decLegendLogicalIdx) )
                l = legend(centroidLegend{ raLegendLogicalIdx | decLegendLogicalIdx }, ...
                    'Orientation','Horizontal');
                set(l,'Position',CENTROID_LEGEND_LOCATION);
            end
            if( k==1 )
                foldedTextBoxHandle = annotation('textbox',FOLDED_PERIOD_TEXTBOX_LOCATION);
                set(foldedTextBoxHandle,'BackgroundColor',TEXTBOX_BACKGROUND_COLOR);
                set(foldedTextBoxHandle,'LineStyle','none');
                set(foldedTextBoxHandle,'String',['FOLDED\newlineperiod ',num2str(periodDays(iPlanet),'%3.2f'),' d']);
            end
            
            % ~~~~~~~~~~~~~~~~~~~~~~~ set up annotation strings with mean out of transit centroid value
            centroidStatsAvailable = true(4,1);
            if( whitenerResultsStruct.ra.meanOutOfTransitCentroid > 0 )
                raMeanString = num2str(whitenerResultsStruct.ra.meanOutOfTransitCentroid * DEGREES_TO_HOURS,'%4.8f');
            else
                raMeanString = 'N/A';
                centroidStatsAvailable(1) = false;
            end
            if( whitenerResultsStruct.ra.sdOutOfTransitCentroids > 0 )
                raSdString = num2str(whitenerResultsStruct.ra.sdOutOfTransitCentroids * DEGREES_TO_HOURS,'%1.2e');
            else
                raSdString = 'N/A';
                centroidStatsAvailable(2) = false;
            end
            if( whitenerResultsStruct.dec.meanOutOfTransitCentroid > 0 )
                decMeanString = num2str(whitenerResultsStruct.dec.meanOutOfTransitCentroid,'%4.8f');
            else
                decMeanString = 'N/A';
                centroidStatsAvailable(3) = false;
            end
            if( whitenerResultsStruct.dec.sdOutOfTransitCentroids > 0 )
                decSdString = num2str(whitenerResultsStruct.dec.sdOutOfTransitCentroids,'%1.2e');
            else
                decSdString = 'N/A';
                centroidStatsAvailable(4) = false;
            end
            raString = ['ra(hours): mean ',raMeanString,', SD ',raSdString];
            decString = ['dec(degrees): mean ',decMeanString,', SD ',decSdString];

            % annotate figure with centroid robust mean and sd if available
            if(any(centroidStatsAvailable))
                textBoxString = cell(3,1);
                textBoxString{1} = '\itOut of Transit Centroid';
                textBoxString{2} = raString;
                textBoxString{3} = decString;
                textBoxHandle = annotation( 'textbox', ANNOTATION_POSITION );
                set(textBoxHandle,'String',textBoxString);
                set(textBoxHandle,'HorizontalAlignment','left');
                set(textBoxHandle,'VerticalAlignment','middle');
                set(textBoxHandle,'BackgroundColor','none');
                set(textBoxHandle,'LineStyle','none');
                set(textBoxHandle,'FontWeight','bold');
                set(textBoxHandle,'FontSize',10);
            end
                        
            % set caption and filename
            if( k==0 )
                figureFilename = [num2str(targetStruct.keplerId,'%09d'),'-',...
                                    num2str(iPlanet,'%02d'),'-',...
                                    'transit-fit-',centroidType,'-centroids-',...
                                    num2str(iQuarter,'%02d'),...
                                    '.fig'];
                set(h,'UserData',unfoldedCaption);
            else
                figureFilename = [num2str(targetStruct.keplerId,'%09d'),'-',...
                                    num2str(iPlanet,'%02d'),'-',...
                                    'folded-transit-fit-',centroidType,'-centroids.fig'];
                set(h,'UserData',foldedCaption);
            end

            % save figure output only if at least one of the panels contains plotted data
            if( any(panelPlotted) )    
                % set path and filename
                figurePath = ['.', filesep, targetResults.dvFiguresRootDirectory,...
                    filesep, 'planet-', num2str(iPlanet, '%02d'), filesep,...
                    'centroid-test-results', filesep];
                % format and save figure to file
                linkaxes(ax(:),'x');
                aa = axis;
                axis([[tmin, tmax] - tOffset,aa(3:4)]);
                set(h,'Visible','on');
                format_graphics_for_dv_report(h);
                saveas(h,[figurePath,figureFilename],'fig');
            else
                disp(['     All ',centroidType,' centroid and flux data gapped. ',figureFilename,' not saved.']);
%                 alertsOnly = add_dv_alert(alertsOnly, ['Centroid test ',centroidType], 'warning',...
%                     ['All centroid and flux data gapped. ',figureFilename,' not saved.'],...
%                     targetStruct.targetIndex, targetStruct.keplerId, iPlanet);
            end

            % either close figures or display
            % debugLevel ~= 0 keeps figures displayed on the screen
            if( targetStruct.debugLevel == 0 )
                close( h );
            else
                drawnow;
            end

        end
    end % subfunction plot_flux_and_centroids_over_time

end % function estimate_dv_centroid_offset


