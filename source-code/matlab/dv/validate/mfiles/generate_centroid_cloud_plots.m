function generate_centroid_cloud_plots(centroidStruct,...
                                        targetStruct,...
                                        targetResults,...
                                        whitenerResultsStruct,...
                                        normalizedTargetFlux,...                                        
                                        centroidType,...
                                        centroidTestConfigurationStruct,...
                                        debugLevel)
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
% function generate_centroid_cloud_plots(centroidStruct,...
%                                         targetStruct,...
%                                         targetResults,...
%                                         whitenerResultsStruct,...
%                                         normalizedTargetFlux,...                                        
%                                         centroidType,...
%                                         centroidTestConfigurationStruct,...
%                                         debugLevel)
%
% This DV function plots the normalized target flux as a function of 
% ra and dec centroid. The centroid and flux data is median filter
% detrended such that the longest fitted transit duration is preserved.
% The plots are saved to the current target directory under the
% 'summary-plots' sub-directory.
%

disp('DV:CentroidTest:Generating cloud plots');

% unpack parameters
RA_SYMBOL                               = centroidTestConfigurationStruct.cloudPlotRaMarker;
DEC_SYMBOL                              = centroidTestConfigurationStruct.cloudPlotDecMarker;
MEDIAN_FILTER_FACTOR                    = centroidTestConfigurationStruct.transitDurationFactorForMedianFilter;
DEFAULT_MAX_TRANSIT_DURATION_CADENCES   = centroidTestConfigurationStruct.defaultMaxTransitDurationCadences;
MADS_TO_CLIP_FOR_CLOUD_PLOT             = centroidTestConfigurationStruct.madsToClipForCloudPlot;
MINUTES_PER_CADENCE                     = centroidTestConfigurationStruct.minutesPerCadence;

% unit conversion
DEGREES_TO_MARCSEC = 60*60*1000;
DEGREES_TO_HOURS = 24/360;

% locate text box on plot
annotationPosition   = [.002 .001 .3 .06];       

unwhitenedCaption = ['KeplerId ',num2str(targetResults.keplerId),...
                        ', KeplerMag ',num2str(targetStruct.keplerMag.value),' - ',...
                        ' This figure shows median detrended flux as a function of median',...
                        ' detrended centroids for both ra and dec on the sky. Transit',...
                        ' features above the noise jitter are seen as scatter outside the',...
                        ' central cloud.  Features in the flux time series are seen in the',...
                        ' vertical direction while features in the centroid time series are',...
                        ' seen in the horizontal direction. Any tilt to the out-of-cloud scatter',...
                        ' indicates correlation between transit features in the flux and centroid',...
                        ' time series. The out of transit mean and standard deviation (SD)',...
                        ' indicated in the lower left-hand corner are robust values.'];

% find maximumum fitted transit durations for this target
if( ~all(~whitenerResultsStruct.validDesignColumn) )
    maxTransitDuration = ...
        max( whitenerResultsStruct.durationDays(whitenerResultsStruct.validDesignColumn)) * 24 * 60 / MINUTES_PER_CADENCE;
else
    maxTransitDuration = DEFAULT_MAX_TRANSIT_DURATION_CADENCES;
end

% set median filt order = odd number of cadences covering maximum duration * factor
medfiltOrder = ceil(maxTransitDuration * MEDIAN_FILTER_FACTOR );
if( floor(medfiltOrder/2)*2 == medfiltOrder )
    medfiltOrder = medfiltOrder + 1;
end

% create data index logicals
idxRa = ~centroidStruct.ra.gapIndicators & ~normalizedTargetFlux.gapIndicators;
idxDec = ~centroidStruct.dec.gapIndicators & ~normalizedTargetFlux.gapIndicators;

% unpack data
standardFlux = normalizedTargetFlux.values;
centroidRa = centroidStruct.ra.values(idxRa);
centroidDec = centroidStruct.dec.values(idxDec);

% set up annotation strings with mean out of transit centroid value
centroidStatsAvailable = true(4,1);
if( whitenerResultsStruct.ra.meanOutOfTransitCentroid > 0 )
    raMeanString = num2str(whitenerResultsStruct.ra.meanOutOfTransitCentroid *DEGREES_TO_HOURS ,'%4.8f');
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
    decMeanString = num2str(whitenerResultsStruct.dec.meanOutOfTransitCentroid,'%4.6f');
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

% detrend using median filtering
if( medfiltOrder > 1 )
    detrendedStandardFlux   = standardFlux - medfilt1_soc(standardFlux, medfiltOrder);
    detrendedCentroidRa     = centroidRa - medfilt1_soc(centroidRa, medfiltOrder);
    detrendedCentroidDec    = centroidDec - medfilt1_soc(centroidDec, medfiltOrder);
else
    detrendedStandardFlux   = standardFlux;
    detrendedCentroidRa     = centroidRa;
    detrendedCentroidDec    = centroidDec;
end

deltaFluxRaPpm = 1e6.*detrendedStandardFlux(idxRa);
deltaFluxDecPpm = 1e6.*detrendedStandardFlux(idxDec);
deltaRaArcs = DEGREES_TO_MARCSEC.*detrendedCentroidRa;
deltaDecArcs = DEGREES_TO_MARCSEC.*detrendedCentroidDec;

% only create figure if there is some ra or dec centroid data to plot
if( any(idxRa) || any(idxDec) )
    
    % make figure for this target
    h = figure;
    set(h,'Visible','off');
    
    hold on;
    
    if( any(idxRa) )
        plot(deltaRaArcs,deltaFluxRaPpm,RA_SYMBOL);
        medRa = nanmedian(deltaRaArcs);
        madRa = mad(deltaRaArcs,1);
        medRaFlux = nanmedian(deltaFluxRaPpm);
        madRaFlux = mad(deltaFluxRaPpm,1);
    end
    
    if( any(idxDec) )
        plot(deltaDecArcs,deltaFluxDecPpm,DEC_SYMBOL);
        medDec = nanmedian(deltaDecArcs);
        madDec = mad(deltaDecArcs,1);
        medDecFlux = nanmedian(deltaFluxDecPpm);
        madDecFlux = mad(deltaFluxDecPpm,1);
    end
    
    hold off;
    
    
    % in case of extreme outliers, clip axis to MADS_TO_CLIP_FOR_CLOUD_PLOT * mads
    aa =axis;
    
    % clip both sides for delta centroid
    xmin = max([min([medRa-MADS_TO_CLIP_FOR_CLOUD_PLOT*madRa, medDec-MADS_TO_CLIP_FOR_CLOUD_PLOT*madDec]), min([min(deltaRaArcs), min(deltaDecArcs)])]);
    xmax = min([max([medRa+MADS_TO_CLIP_FOR_CLOUD_PLOT*madRa, medDec+MADS_TO_CLIP_FOR_CLOUD_PLOT*madDec]), max([max(deltaRaArcs), max(deltaDecArcs)])]);
    
    % clip only positive outliers for delta flux
    ymin = aa(3);
    ymax = min([max([medRaFlux+MADS_TO_CLIP_FOR_CLOUD_PLOT*madRaFlux, medDecFlux+MADS_TO_CLIP_FOR_CLOUD_PLOT*madDecFlux]), max([max(deltaFluxRaPpm), max(deltaFluxDecPpm)])]);
    
    % make the x-axis (delta ra and dec) limits symmetric for aesthetics
    axis([-max([abs(xmin), abs(xmax)]), max([abs(xmin), abs(xmax)]), ymin, ymax]);
    
    grid;    
    xlabel('\Delta Detrended Centroid (marc-sec)');
    ylabel('\Delta Normalized Flux (ppm)');    
    title([centroidType,'Centroids, Unwhitened Cloud Plot']);
    legend('Ra','Dec','Location','Best');

    % annotate figure with centroid robust mean and sd if available
    if(any(centroidStatsAvailable))
        textBoxString = cell(3,1);
        textBoxString{1} = '\itOut of Transit Centroid';
        textBoxString{2} = raString;
        textBoxString{3} = decString;
        textBoxHandle = annotation( 'textbox', annotationPosition );
        set(textBoxHandle,'String',textBoxString);
        set(textBoxHandle,'HorizontalAlignment','left');
        set(textBoxHandle,'VerticalAlignment','middle');
        set(textBoxHandle,'BackgroundColor','none');
        set(textBoxHandle,'LineStyle','none');
        set(textBoxHandle,'FontWeight','bold');
        set(textBoxHandle,'FontSize',10);
    end
    
    % set caption
    set(h,'UserData',unwhitenedCaption);
    
    % set path and filename
    figurePath = ['.', filesep, targetResults.dvFiguresRootDirectory,...
                    filesep, 'summary-plots', filesep];
    figureFilename = [num2str(targetResults.keplerId,'%09d'),'-',...
                        num2str(0,'%02d'),'-',...
                        centroidType,'-centroids-cloud.fig'];

    % format and save figure to file
    set(h,'Visible','on');
    format_graphics_for_dv_report(h);
    saveas(h,[figurePath,figureFilename],'fig');
    
    % either close figures or keep displayed
    if( debugLevel==0 )
        close( h );
    else
        drawnow;
    end    
end
