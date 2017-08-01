% This is used to analyze the perofrmance of the new PA-COA in CDPP compared to the standard TAD apertures.
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

function [tadCdpp, paCoaCdpp, cdppRelDiff, paCoaUsed] = post_analyze_pa_results_for_cdpp ()

tadRunDir = '/path/to/ksoc-3891_pixel_weighted_photometry/pa_run_no_pa_coa';
paCoaRunDir = '/path/to/ksoc-3891_pixel_weighted_photometry/pa_run_with_pa_coa_take_2';

load([tadRunDir, '/st-3/pa-inputs-0.mat'], 'inputsStruct');
load([tadRunDir, '/pa_state.mat'], 'paTargetStarResultsStruct');
tadResultsStruct = paTargetStarResultsStruct;
load([paCoaRunDir, '/pa_state.mat'], 'paTargetStarResultsStruct');
paCoaResultsStruct = paTargetStarResultsStruct;
clear paTargetStarResultsStruct;

nTargets = length(tadResultsStruct);

if (length(paCoaResultsStruct) ~= nTargets)
    error('The TAD and pa-COA data do not appear to be from the same run!');
end

gapFilledTimestamps  = pdc_fill_cadence_times (inputsStruct.cadenceTimes);

% Find CDPP for each light curve
tadCdpp   = zeros(nTargets,1);
paCoaCdpp = zeros(nTargets,1);

paCoaUsed = false(nTargets,1);

for iTarget = 1 : nTargets

    tadFlux = tadResultsStruct(iTarget).fluxTimeSeries.values;
    tadGaps = tadResultsStruct(iTarget).fluxTimeSeries.gapIndicators;

    [tadCdpp(iTarget)] = calculate_cdpp (tadFlux, tadGaps, gapFilledTimestamps, inputsStruct.gapFillConfigurationStruct);

    paCoaFlux = paCoaResultsStruct(iTarget).fluxTimeSeries.values;
    paCoaGaps = paCoaResultsStruct(iTarget).fluxTimeSeries.gapIndicators;

    [paCoaCdpp(iTarget)] = calculate_cdpp (paCoaFlux, paCoaGaps, gapFilledTimestamps, inputsStruct.gapFillConfigurationStruct);

    % Count fraction that revert to TAD-COA
    if (isfield(paCoaResultsStruct(iTarget).optimalAperture, 'apertureUpdatedWithPaCoa') && ...
            paCoaResultsStruct(iTarget).optimalAperture.apertureUpdatedWithPaCoa)
        paCoaUsed(iTarget) = true;
    end
            
    display(['Finished target ', num2str(iTarget), ' of ', num2str(nTargets)]);
  
end

medianTadCdpp = median(tadCdpp);
medianPaCoaCdpp = median(paCoaCdpp);

figure;
plot(tadCdpp, '*b');
hold on;
plot(paCoaCdpp, '*r');
title('Light curve CDPP');
xlabel('Target Index');
L = legend(['TAD-COA CDPP Median = ', num2str(medianTadCdpp)], ...
           ['PA-COA  CDPP Median = ', num2str(medianPaCoaCdpp)]);
set(L,'FontName','FixedWidth')

figure;
x = [10:10:10000];
hist(tadCdpp, x);
hold on;
hist(paCoaCdpp, x);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w');
title ('Histogram of TAD-COA and PA-COA results CDPP');
xlabel('Quasi-CDPP');

% Histogram of relative imporvement
figure;
cdppRelDiff = (paCoaCdpp - tadCdpp) ./ tadCdpp;
hist(cdppRelDiff, [-1:0.005:1]);
title('Relative Improvement inCDPP from TAD-COA and PA-COA, Kepler Prime PA V&V 9.2 data Q15 2.1');
xlabel('Relative change in CDPP from TAD-COA to PA-COA');

end

%*************************************************************************************************************
% function [cdpp] = calculate_cdpp (flux, gaps)
%
% Calculates the CDPP for the given flux.
%
% Inputs:
%   flux    -- [double array(nCadences)] The light curve
%   gaps    -- [double array(nCadences)] The light curve gaps
%
% Outputs:
%   cdpp    -- [struct]
%       .values -- [double array(nCadences)] The CDPP per cadence
%       .rms    -- [doube] The CDPP RMS
%
%*************************************************************************************************************
function [cdppRms] = calculate_cdpp (flux, gaps, gapFilledTimestamps, gapFillConfigurationStruct)

    cdppMedFiltSmoothLength = 100;

    %***
    % Massage the data to be ready for CDPP
    flux(gaps) = nan;

    % The mean flux values can be dramatically different since different number of pixels are added together. We need to normalize the mean flux values
    flux   = mapNormalizeClass.normalize_value (flux, nanmedian(flux), [], [], [], 'median');
 
    % NaNs will "NaN" the medfilt1 values within cdppMedFiltSmoothLength cadences from each NaNed cadence, so we need to simply fill the gaps
    % Further down we fill gaps better
    if (~isempty(flux(~gaps)))
        flux(gaps)   = interp1(gapFilledTimestamps (~gaps), flux(~gaps), gapFilledTimestamps (gaps), 'pchip');
    end
 
    fluxDetrended  = flux - medfilt1(flux, cdppMedFiltSmoothLength);
 
    % Need
    % maxCorrelationWindowLimit           = maxCorrelationWindowXFactor * maxArOrderLimit;
    % To be larger than the largest gap
    gapFillConfigurationStruct.maxCorrelationWindowXFactor = 300 / gapFillConfigurationStruct.maxArOrderLimit;
 
    [fluxDetrended] = fill_short_gaps(fluxDetrended, gaps, [], false, gapFillConfigurationStruct, [], zeros(length(fluxDetrended),1));
 
    %***
    % Compute the current CDPP
    trialTransitPulseDurationInHours = 6;
    tpsModuleParameters.usePolyFitTransitModel  = false;
    tpsModuleParameters.superResolutionFactor  = 1;
    tpsModuleParameters.varianceWindowLengthMultiplier = 7;
    tpsModuleParameters.waveletFilterLength = 12;
    cadencesPerHour = 1 / (median(diff(gapFilledTimestamps))*24);
 
    if (~isnan(fluxDetrended))
        % Ignore the edge effects by only looking at the center portion
        fluxTimeSeries.values = fluxDetrended(cdppMedFiltSmoothLength:end-cdppMedFiltSmoothLength);
        cdpp = calculate_cdpp_wrapper (fluxTimeSeries, cadencesPerHour, trialTransitPulseDurationInHours, tpsModuleParameters);
        cdppRms = cdpp.rms;
    else
        cdppRms = nan;
    end

end % calculate_cdpp

