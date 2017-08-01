function [pmdOutputStruct] = pmd_validate_output_structure(pmdOutputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  [pmdOutputStruct] = pmd_validate_output_structure(pmdOutputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function checks the fields in the output structure, and replaces NaNs with 0s or -1s.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% check pmdOutputStruct.outputTsData

if isfield(pmdOutputStruct, 'outputTsData')
    
    if isfield(pmdOutputStruct.outputTsData, 'backgroundLevel')
        pmdOutputStruct.outputTsData.backgroundLevel     = check_time_series_struct(pmdOutputStruct.outputTsData.backgroundLevel);
    end
    
    if isfield(pmdOutputStruct.outputTsData, 'centroidsMeanRow')
        pmdOutputStruct.outputTsData.centroidsMeanRow    = check_time_series_struct(pmdOutputStruct.outputTsData.centroidsMeanRow);
    end
    
    if isfield(pmdOutputStruct.outputTsData, 'centroidsMeanColumn')
        pmdOutputStruct.outputTsData.centroidsMeanColumn = check_time_series_struct(pmdOutputStruct.outputTsData.centroidsMeanColumn);
    end
    
    if isfield(pmdOutputStruct.outputTsData, 'plateScale')
        pmdOutputStruct.outputTsData.plateScale          = check_time_series_struct(pmdOutputStruct.outputTsData.plateScale);
    end
    
    if isfield(pmdOutputStruct.outputTsData, 'cdppMeasured')
        pmdOutputStruct.outputTsData.cdppMeasured        = check_cdpp_struct(pmdOutputStruct.outputTsData.cdppMeasured);
    end
    
    if isfield(pmdOutputStruct.outputTsData, 'cdppExpected')
        pmdOutputStruct.outputTsData.cdppExpected        = check_cdpp_struct(pmdOutputStruct.outputTsData.cdppExpected);
    end
    
    if isfield(pmdOutputStruct.outputTsData, 'cdppRatio')
        pmdOutputStruct.outputTsData.cdppRatio           = check_cdpp_struct(pmdOutputStruct.outputTsData.cdppRatio);
    end
    
    if isfield(pmdOutputStruct.outputTsData, 'cdppMmrMetrics')
        pmdOutputStruct.outputTsData.cdppMmrMetrics      = check_cdpp_mmr_metrics_struct(pmdOutputStruct.outputTsData.cdppMmrMetrics);
    end
    
end


% check pmdOutputStruct.report

if isfield(pmdOutputStruct, 'report')
    
    if isfield(pmdOutputStruct.report, 'blackLevel')
        pmdOutputStruct.report.blackLevel                       = check_pmd_report(pmdOutputStruct.report.blackLevel);
    end

    if isfield(pmdOutputStruct.report, 'smearLevel')
        pmdOutputStruct.report.smearLevel                       = check_pmd_report(pmdOutputStruct.report.smearLevel);
    end
    
    if isfield(pmdOutputStruct.report, 'darkCurrent')
        pmdOutputStruct.report.darkCurrent                      = check_pmd_report(pmdOutputStruct.report.darkCurrent);
    end

    if isfield(pmdOutputStruct.report, 'twoDBlack')
        for i = 1:length(pmdOutputStruct.report.twoDBlack)
            pmdOutputStruct.report.twoDBlack(i)                 = check_pmd_report(pmdOutputStruct.report.twoDBlack(i));
        end
    end
    
    if isfield(pmdOutputStruct.report, 'ldeUndershoot')
        for i = 1:length(pmdOutputStruct.report.ldeUndershoot)
            pmdOutputStruct.report.ldeUndershoot(i)             = check_pmd_report(pmdOutputStruct.report.ldeUndershoot(i));
        end
    end
    
    if isfield(pmdOutputStruct.report, 'theoreticalCompressionEfficiency')
        pmdOutputStruct.report.theoreticalCompressionEfficiency = check_pmd_report(pmdOutputStruct.report.theoreticalCompressionEfficiency);
    end
    
    if isfield(pmdOutputStruct.report, 'achievedCompressionEfficiency')
        pmdOutputStruct.report.achievedCompressionEfficiency    = check_pmd_report(pmdOutputStruct.report.achievedCompressionEfficiency);
    end
    
    if isfield(pmdOutputStruct.report, 'brightness')
        pmdOutputStruct.report.brightness                       = check_pmd_report(pmdOutputStruct.report.brightness);
    end

    if isfield(pmdOutputStruct.report, 'encircledEnergy')
        pmdOutputStruct.report.encircledEnergy                  = check_pmd_report(pmdOutputStruct.report.encircledEnergy);
    end
    
    if isfield(pmdOutputStruct.report, 'backgroundLevel')
        pmdOutputStruct.report.backgroundLevel                  = check_pmd_report(pmdOutputStruct.report.backgroundLevel);
    end
    
    if isfield(pmdOutputStruct.report, 'centroidsMeanRow')
        pmdOutputStruct.report.centroidsMeanRow                 = check_pmd_report(pmdOutputStruct.report.centroidsMeanRow);
    end

    if isfield(pmdOutputStruct.report, 'centroidsMeanColumn')
        pmdOutputStruct.report.centroidsMeanColumn              = check_pmd_report(pmdOutputStruct.report.centroidsMeanColumn);
    end
    
    if isfield(pmdOutputStruct.report, 'plateScale')
        pmdOutputStruct.report.plateScale                       = check_pmd_report(pmdOutputStruct.report.plateScale);
    end
    
    if isfield(pmdOutputStruct.report, 'blackCosmicRayMetrics')
        pmdOutputStruct.report.blackCosmicRayMetrics            = check_cosmic_ray_metric_report(pmdOutputStruct.report.blackCosmicRayMetrics);
    end

    if isfield(pmdOutputStruct.report, 'maskedSmearCosmicRayMetrics')
        pmdOutputStruct.report.maskedSmearCosmicRayMetrics      = check_cosmic_ray_metric_report(pmdOutputStruct.report.maskedSmearCosmicRayMetrics);
    end

    if isfield(pmdOutputStruct.report, 'virtualSmearCosmicRayMetrics')
        pmdOutputStruct.report.virtualSmearCosmicRayMetrics     = check_cosmic_ray_metric_report(pmdOutputStruct.report.virtualSmearCosmicRayMetrics);
    end
    
    if isfield(pmdOutputStruct.report, 'targetStarCosmicRayMetrics')
        pmdOutputStruct.report.targetStarCosmicRayMetrics       = check_cosmic_ray_metric_report(pmdOutputStruct.report.targetStarCosmicRayMetrics);
    end 
    
    if isfield(pmdOutputStruct.report, 'backgroundCosmicRayMetrics')
        pmdOutputStruct.report.backgroundCosmicRayMetrics       = check_cosmic_ray_metric_report(pmdOutputStruct.report.backgroundCosmicRayMetrics);
    end    
    
    if isfield(pmdOutputStruct.report, 'cdppMeasured')
        pmdOutputStruct.report.cdppMeasured                     = check_cdpp_report(pmdOutputStruct.report.cdppMeasured);
    end
    
    if isfield(pmdOutputStruct.report, 'cdppExpected')
        pmdOutputStruct.report.cdppExpected                     = check_cdpp_report(pmdOutputStruct.report.cdppExpected);
    end
    
    if isfield(pmdOutputStruct.report, 'cdppRatio')
        pmdOutputStruct.report.cdppRatio                        = check_cdpp_report(pmdOutputStruct.report.cdppRatio);
    end
    
end

return




function cdppStruct = check_cdpp_struct(cdppStruct)

if isfield(cdppStruct, 'mag9')
    cdppStruct.mag9  = check_cdpp_mag_struct(cdppStruct.mag9);
end
if isfield(cdppStruct, 'mag10')
    cdppStruct.mag10 = check_cdpp_mag_struct(cdppStruct.mag10);
end
if isfield(cdppStruct, 'mag11')
    cdppStruct.mag11 = check_cdpp_mag_struct(cdppStruct.mag11);
end
if isfield(cdppStruct, 'mag12')
    cdppStruct.mag12 = check_cdpp_mag_struct(cdppStruct.mag12);
end
if isfield(cdppStruct, 'mag13')
    cdppStruct.mag13 = check_cdpp_mag_struct(cdppStruct.mag13);
end
if isfield(cdppStruct, 'mag14')
    cdppStruct.mag14 = check_cdpp_mag_struct(cdppStruct.mag14);
end
if isfield(cdppStruct, 'mag15')
    cdppStruct.mag15 = check_cdpp_mag_struct(cdppStruct.mag15);
end

return




function cdppMagStruct = check_cdpp_mag_struct(cdppMagStruct)

if isfield(cdppMagStruct, 'threeHour')
    cdppMagStruct.threeHour  = check_time_series_struct(cdppMagStruct.threeHour);
end
if isfield(cdppMagStruct, 'sixHour')
    cdppMagStruct.sixHour    = check_time_series_struct(cdppMagStruct.sixHour);
end
if isfield(cdppMagStruct, 'twelveHour')
    cdppMagStruct.twelveHour = check_time_series_struct(cdppMagStruct.twelveHour);
end

return




function cdppMmrMetricsStruct = check_cdpp_mmr_metrics_struct(cdppMmrMetricsStruct)

if isfield(cdppMmrMetricsStruct, 'countOfStarsInMagnitude')
    cdppMmrMetricsStruct.countOfStarsInMagnitude = check_cdpp_mmr_field_struct(cdppMmrMetricsStruct.countOfStarsInMagnitude);
end

if isfield(cdppMmrMetricsStruct, 'medianCdpp')
    cdppMmrMetricsStruct.medianCdpp              = check_cdpp_mmr_field_struct(cdppMmrMetricsStruct.medianCdpp);
end

if isfield(cdppMmrMetricsStruct, 'tenthPercentileCdpp')
    cdppMmrMetricsStruct.tenthPercentileCdpp     = check_cdpp_mmr_field_struct(cdppMmrMetricsStruct.tenthPercentileCdpp);
end

if isfield(cdppMmrMetricsStruct, 'noiseModel')
    cdppMmrMetricsStruct.noiseModel              = check_cdpp_mmr_field_struct(cdppMmrMetricsStruct.noiseModel);
end

if isfield(cdppMmrMetricsStruct, 'percentBelowNoise')
    cdppMmrMetricsStruct.percentBelowNoise       = check_cdpp_mmr_field_struct(cdppMmrMetricsStruct.percentBelowNoise);
end

return




function cdppMmrFieldStruct = check_cdpp_mmr_field_struct(cdppMmrFieldStruct)

if isfield(cdppMmrFieldStruct, 'mag9')
    if isnan(cdppMmrFieldStruct.mag9)
        cdppMmrFieldStruct.mag9   = -1;
    end
end
if isfield(cdppMmrFieldStruct, 'mag10')
    if isnan(cdppMmrFieldStruct.mag10)
        cdppMmrFieldStruct.mag10  = -1;
    end
end
if isfield(cdppMmrFieldStruct, 'mag11')
    if isnan(cdppMmrFieldStruct.mag11)
        cdppMmrFieldStruct.mag11  = -1;
    end
end
if isfield(cdppMmrFieldStruct, 'mag12')
    if isnan(cdppMmrFieldStruct.mag12)
        cdppMmrFieldStruct.mag12  = -1;
    end
end
if isfield(cdppMmrFieldStruct, 'mag13')
    if isnan(cdppMmrFieldStruct.mag13)
        cdppMmrFieldStruct.mag13  = -1;
    end
end
if isfield(cdppMmrFieldStruct, 'mag14')
    if isnan(cdppMmrFieldStruct.mag14)
        cdppMmrFieldStruct.mag14  = -1;
    end
end
if isfield(cdppMmrFieldStruct, 'mag15')
    if isnan(cdppMmrFieldStruct.mag15)
        cdppMmrFieldStruct.mag15  = -1;
    end
end

return




function timeSeriesStruct = check_time_series_struct(timeSeriesStruct)

if isfield(timeSeriesStruct, 'values')
    timeSeriesStruct.values( isnan(timeSeriesStruct.values) )               =  0;
end
if isfield(timeSeriesStruct, 'uncertainties')
    timeSeriesStruct.uncertainties( isnan(timeSeriesStruct.uncertainties) ) = -1;
end

return




function cosmicRayMetricReport = check_cosmic_ray_metric_report(cosmicRayMetricReport)
    
    if isfield(cosmicRayMetricReport, 'hitRate')
        cosmicRayMetricReport.hitRate           = check_pmd_report(cosmicRayMetricReport.hitRate);
    end
    
    if isfield(cosmicRayMetricReport, 'meanEnergy')
        cosmicRayMetricReport.meanEnergy        = check_pmd_report(cosmicRayMetricReport.meanEnergy);
    end
    
    if isfield(cosmicRayMetricReport, 'energyVariance')
        cosmicRayMetricReport.energyVariance    = check_pmd_report(cosmicRayMetricReport.energyVariance);
    end
    
    if isfield(cosmicRayMetricReport, 'energySkewness')
        cosmicRayMetricReport.energySkewness    = check_pmd_report(cosmicRayMetricReport.energySkewness);
    end
    
    if isfield(cosmicRayMetricReport, 'energyKurtosis')
        cosmicRayMetricReport.energyKurtosis    = check_pmd_report(cosmicRayMetricReport.energyKurtosis);
    end
            
return




function cdppReport = check_cdpp_report(cdppReport)

if isfield(cdppReport, 'mag9')    
    cdppReport.mag9     = check_cdpp_mag_report(cdppReport.mag9);
end

if isfield(cdppReport, 'mag10')    
    cdppReport.mag10    = check_cdpp_mag_report(cdppReport.mag10);
end

if isfield(cdppReport, 'mag11')    
    cdppReport.mag11    = check_cdpp_mag_report(cdppReport.mag11);
end

if isfield(cdppReport, 'mag12')    
    cdppReport.mag12    = check_cdpp_mag_report(cdppReport.mag12);
end

if isfield(cdppReport, 'mag13')    
    cdppReport.mag13    = check_cdpp_mag_report(cdppReport.mag13);
end

if isfield(cdppReport, 'mag14')    
    cdppReport.mag14    = check_cdpp_mag_report(cdppReport.mag14);
end

if isfield(cdppReport, 'mag15')    
    cdppReport.mag15    = check_cdpp_mag_report(cdppReport.mag15);
end

return




function cdppMagReport = check_cdpp_mag_report(cdppMagReport)

if isfield(cdppMagReport, 'threeHour')
    cdppMagReport.threeHour     = check_pmd_report(cdppMagReport.threeHour);
end

if isfield(cdppMagReport, 'sixHour')
    cdppMagReport.sixHour       = check_pmd_report(cdppMagReport.sixHour);
end

if isfield(cdppMagReport, 'twelveHour')
    cdppMagReport.tweleHour     = check_pmd_report(cdppMagReport.twelveHour);
end

return




function pmdReport = check_pmd_report(pmdReport)

if isfield(pmdReport, 'time')
    if isnan(pmdReport.time)
        pmdReport.time                      = -1;
    end
end

if isfield(pmdReport, 'value')
    if isnan(pmdReport.value)
        pmdReport.value                     = -1;
    end
end

if isfield(pmdReport, 'meanValue')
    if isnan(pmdReport.meanValue)
        pmdReport.meanValue                 = -1;
    end
end

if isfield(pmdReport, 'uncertainty')
    if isnan(pmdReport.uncertainty)
        pmdReport.uncertainty               = -1;
    end
end

if isfield(pmdReport, 'adaptiveBoundsXFactor')
    if isnan(pmdReport.adaptiveBoundsXFactor)
        pmdReport.adaptiveBoundsXFactor     = -1;
    end
end

if isfield(pmdReport, 'adaptiveBoundsReport')
    pmdReport.adaptiveBoundsReport          = check_bound_report(pmdReport.adaptiveBoundsReport);
end

if isfield(pmdReport, 'fixedBoundsReport')
    pmdReport.fixedBoundsReport             = check_bound_report(pmdReport.fixedBoundsReport);
end

if isfield(pmdReport, 'trendReport')
    pmdReport.trendReport                   = check_trend_report(pmdReport.trendReport);
end

return




function boundReport = check_bound_report(boundReport)

if isfield(boundReport, 'upperBound')
    if isnan(boundReport.upperBound)
        boundReport.upperBound                                                              = -1;
    end
end

if isfield(boundReport, 'outOfUpperBoundsCount')
    if isnan(boundReport.outOfUpperBoundsCount)
        boundReport.outOfUpperBoundsCount                                                   = -1;
    end
end

if isfield(boundReport, 'outOfUpperBoundsTimes')
    boundReport.outOfUpperBoundsTimes(isnan(boundReport.outOfUpperBoundsTimes))             = -1;
end

if isfield(boundReport, 'outOfUpperBoundsValues')
    boundReport.outOfUpperBoundsValues(isnan(boundReport.outOfUpperBoundsValues))           = -1;
end

if isfield(boundReport, 'upperBoundsCrossingXFactors')
    boundReport.upperBoundsCrossingXFactors(isnan(boundReport.upperBoundsCrossingXFactors)) = -1;
end

if isfield(boundReport, 'lowerBound')
    if isnan(boundReport.lowerBound)
        boundReport.lowerBound                                                              = -1;
    end
end

if isfield(boundReport, 'outOfLowerBoundsCount')
    if isnan(boundReport.outOfLowerBoundsCount)
        boundReport.outOfLowerBoundsCount                                                   = -1;
    end
end

if isfield(boundReport, 'outOfLowerBoundsTimes')
    boundReport.outOfLowerBoundsTimes(isnan(boundReport.outOfLowerBoundsTimes))             = -1;
end

if isfield(boundReport, 'outOfLowerBoundsValues')
    boundReport.outOfLowerBoundsValues(isnan(boundReport.outOfLowerBoundsValues))           = -1;
end

if isfield(boundReport, 'lowerBoundsCrossingXFactors')
    boundReport.lowerBoundsCrossingXFactors(isnan(boundReport.lowerBoundsCrossingXFactors)) = -1;
end

if isfield(boundReport, 'crossingTime')
    if isnan(boundReport.crossingTime)
        boundReport.crossingTime                                                            = -1;
    end
end

return




function trendReport = check_trend_report(trendReport)

if isfield(trendReport, 'trendFitTime')
    if isnan(trendReport.trendFitTime)
        trendReport.trendFitTime    = -1;
    end
end

if isfield(trendReport, 'trendOffset')
    if isnan(trendReport.trendOffset)
        trendReport.trendOffset     = -1;
    end
end

if isfield(trendReport, 'trendSlope')
    if isnan(trendReport.trendSlope)
        trendReport.trendSlope      = -1;
    end
end

if isfield(trendReport, 'horizonTime')
    if isnan(trendReport.horizonTime)
        trendReport.horizonTime     = -1;
    end
end

return
