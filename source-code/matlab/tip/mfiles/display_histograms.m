function result = display_histograms(tipData, dvData, doFigure12, saveFiguresAsJpegs)

% initialize result
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
result = true;

% hard coded params for displaying histgrams
nSIGMA = 10;                        % formatting constant for the distrubution plots
binFraction = 0.05;                 % formatting constant for the distrubution plots

figureTitles = {'DV Depth Difference from Transit Model Truth',...
                'DV Duration Difference from Transit Model Truth',...
                'DV Period Difference from Transit Model Truth',...
                'DV rOverRStar Difference from Transit Model Truth',...
                'DV aOverRStar Difference from Transit Model Truth',...
                'DV Impact Param Difference from Transit Model Truth',...
                'DV Source Offset (FW Centroid) Difference from TIP Truth',...
                'DV Source Offset (MQ Diff Image) Difference from TIP Truth',...
                'DV Source Offset (MQ Diff Image) Difference from DV FW Centroid',...
                'DV Source Offset (FW Centroid) Difference from MQ Diff Image',...
                'DV Epoch Difference from Transit Model Truth',...
                'DV Mes Difference from windowedMes over windowedMes'};


% break out parameters for TIP
tipDepth        = tipData.transitDepthPpm(tipData.tipMatchIdx);                      %#ok<*NASGU>
tipDuration     = tipData.transitDurationHours(tipData.tipMatchIdx);    
tipPeriod       = tipData.orbitalPeriodDays(tipData.tipMatchIdx);
tipEpoch        = tipData.epochBjd(tipData.tipMatchIdx);
tipOffset       = tipData.transitOffsetArcsec(tipData.tipMatchIdx);
tipaOverRStar   = tipData.semiMajorAxisOverRstar(tipData.tipMatchIdx);
tiprOverRStar   = tipData.RplanetOverRstar(tipData.tipMatchIdx);
tipImpactParam  = tipData.impactParameter(tipData.tipMatchIdx);

tipModelDepthPpm = tipData.transitModelDepthPpm(tipData.tipMatchIdx);  
tipModelDuration = tipData.transitModelDurationHours(tipData.tipMatchIdx);

% break out parameters for dv including propagated uncertainty
dvDepth             = dvData.allTransitsFit.transitDepthPpm.value(dvData.dvMatchIdx);
CdvDepth            = dvData.allTransitsFit.transitDepthPpm.uncertainty(dvData.dvMatchIdx);
dvDuration          = dvData.allTransitsFit.transitDurationHours.value(dvData.dvMatchIdx);
CdvDuration         = dvData.allTransitsFit.transitDurationHours.uncertainty(dvData.dvMatchIdx);
dvPeriod            = dvData.allTransitsFit.orbitalPeriodDays.value(dvData.dvMatchIdx);
CdvPeriod           = dvData.allTransitsFit.orbitalPeriodDays.uncertainty(dvData.dvMatchIdx);
dvEpoch             = dvData.allTransitsFit.transitEpochBkjd.value(dvData.dvMatchIdx);
CdvEpoch            = dvData.allTransitsFit.transitEpochBkjd.uncertainty(dvData.dvMatchIdx);
dvOffsetMqDiff      = dvData.centroidResults.differenceImageMotionResults.mqKicCentroidOffsets.meanSkyOffset.value(dvData.dvMatchIdx);
CdvOffsetMqDiff     = dvData.centroidResults.differenceImageMotionResults.mqKicCentroidOffsets.meanSkyOffset.uncertainty(dvData.dvMatchIdx);
dvOffsetFwMotion    = dvData.centroidResults.fluxWeightedMotionResults.sourceOffsetArcSec.value(dvData.dvMatchIdx);
CdvOffsetFwMotion   = dvData.centroidResults.fluxWeightedMotionResults.sourceOffsetArcSec.uncertainty(dvData.dvMatchIdx);
dvaOverRStar        = dvData.allTransitsFit.ratioSemiMajorAxisToStarRadius.value(dvData.dvMatchIdx);
CdvaOverRStar       = dvData.allTransitsFit.ratioSemiMajorAxisToStarRadius.uncertainty(dvData.dvMatchIdx);
dvrOverRStar        = dvData.allTransitsFit.ratioPlanetRadiusToStarRadius.value(dvData.dvMatchIdx);
CdvrOverRStar       = dvData.allTransitsFit.ratioPlanetRadiusToStarRadius.uncertainty(dvData.dvMatchIdx);
dvImpactParam       = dvData.allTransitsFit.minImpactParameter.value(dvData.dvMatchIdx);
CdvImpactParam      = dvData.allTransitsFit.minImpactParameter.uncertainty(dvData.dvMatchIdx);

% generate some histograms showing how DV results compare with TIP truth
h = zeros(12,1);
h(1) = make_histogram(tipModelDepthPpm, CdvDepth,       dvDepth,       nSIGMA, binFraction, {figureTitles{1},'sigma','count'});
h(2) = make_histogram(tipModelDuration, CdvDuration,    dvDuration,    nSIGMA, binFraction, {figureTitles{2},'sigma','count'});
h(3) = make_histogram(tipPeriod,        CdvPeriod,      dvPeriod,      nSIGMA, binFraction, {figureTitles{3},'sigma','count'});
h(4) = make_histogram(tiprOverRStar,    CdvrOverRStar,  dvrOverRStar,  nSIGMA, binFraction, {figureTitles{4},'sigma','count'});
h(5) = make_histogram(tipaOverRStar,    CdvaOverRStar,  dvaOverRStar,  nSIGMA, binFraction, {figureTitles{5},'sigma','count'});
h(6) = make_histogram(tipImpactParam,   CdvImpactParam, dvImpactParam, nSIGMA, binFraction, {figureTitles{6},'sigma','count'});

h(7) = make_histogram(tipOffset, CdvOffsetFwMotion, dvOffsetFwMotion,        nSIGMA, binFraction, {figureTitles{7},'sigma','count'});
h(8) = make_histogram(tipOffset,   CdvOffsetMqDiff,   dvOffsetMqDiff,        nSIGMA, binFraction, {figureTitles{8},'sigma','count'});
h(9) = make_histogram(dvOffsetFwMotion,   CdvOffsetMqDiff,   dvOffsetMqDiff, nSIGMA, binFraction, {figureTitles{9},'sigma','count'});
h(10) = make_histogram(dvOffsetMqDiff, CdvOffsetFwMotion, dvOffsetFwMotion,   nSIGMA, binFraction, {figureTitles{10},'sigma','count'});

h(11) = make_histogram(mod(tipEpoch,tipPeriod), CdvEpoch, mod(dvEpoch + kjd_offset_from_mjd,tipPeriod), nSIGMA, binFraction, {figureTitles{11},'sigma','count'});

if doFigure12
    tipMes = tipData.windowedMesMean(tipData.tipMatchIdx);
    dvMes = dvData.planetCandidate.maxMultipleEventSigma(dvData.dvMatchIdx);
    h(12) = make_histogram(tipMes, tipMes, dvMes, 1, binFraction, {figureTitles{12},'','count'});
else
    h(12) = nan;
end

if saveFiguresAsJpegs
    for iHandle = 1: length(h)
        if ~isnan(h(iHandle))
            print(h(iHandle),'-djpeg','-r300',replace_token_in_string(figureTitles{iHandle},' ','_'));
        end
    end        
end    


return;




function handle = make_histogram(truth, unc, data, sigmas, fractionalBins, tStrings)

% trival case of no data input returns null handle
if isempty(truth) || isempty(data)
    disp(['No data to plot for ',tStrings{1}]);
    handle = nan;
    return;
end

% hard coded constants
robustMinDataPts = 3;

% hard coded edge trim (%)
edgeTrim = 5;

data = colvec(data);
unc = colvec(unc);
truth = colvec(truth);
normDelta = (truth - data)./unc;

% trim to data within sigmas 
logicalIdx = abs(normDelta) < sigmas;
if ~isempty(find(logicalIdx, 1))
    normDelta = normDelta(logicalIdx);
end
bins = max([floor(fractionalBins * numel(normDelta)), 1]);

% make histogram
[n,x] = hist(normDelta, bins);

% plot histogram and fit
handle = figure;
bar(x,n);
grid;

% overlay normal if enough data is available to fit
trimDelta = normDelta(normDelta > prctile(normDelta,edgeTrim) & normDelta < prctile(normDelta,100 - edgeTrim));
enoughData = length(trimDelta) > robustMinDataPts;
if enoughData
    % make normal based on edgeTrim data    
    [mean, std] = robust_mean_std(trimDelta);
    y = normpdf(x,mean,std);    
    % fit normal to histogram
    c = n/y;
    % plot normal values at bin in red
    hold on;
    plot(x,y.*c,'or');
    hold off;
end


% add axis labels and titles
title(tStrings{1});
xlabel(tStrings{2});
ylabel(tStrings{3});

return;





