function save_dv_output_matrix(dvDataObject, dvResultsStruct)
%
%  This function saves a matrix dvOutputMatrixTarget and a cell array dvOutputMatrixColumns in a file.
%  Each line of the matrix dvOutputMatrixTarget includes the DV output data of a planet candidate of a target. 
%  The element of the cell array dvOutputMatrixColumns defines the data in each column of dvOutputMatrixTarget.
%
%  Version date:  2015-January-14.
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

%  Modification History:
%
%    2015-January-14, JL:
%        Add fields: bootstrapMesMean, bootstrapMesStd
%    2014-May-09, JT:
%        Add fields: coreApertureCorrelationStatistic, haloApertureCorrelationStatistic
%    2014-March-10, JL:
%        Add field: planetCandidate.trialTransitPulseDuration
%    2013-December-12, JL:
%        Add fields: effectiveStellarFlux of all/odd/even transits fits
%    2013-December-11, JT:
%        Add fields: geometricAlbedo, planetEffectiveTemp,
%                    albedoComparisonStatistic, tempComparisonStatistic
%    2013-November-27, JT:
%        Add fields: rollingBandContaminationHistogram.transitFraction_level0-4
%    2013-November-15, JL:
%        Add fields: transitIngreeTimeHours, inclinationDegrees 
%                    eccentricity, longitudeOfPeriDegrees of all/odd/even transits fits
%    2013-November-14, JL:
%        Add fields: skyGroupId, targetKoiId, planetKoiId, planetKoiCorrelation
%    2013-August-14, JL:
%        When number of reducedParameterFits is less than or equal to 5, save the fit results;
%        otherwise, display a warning message.
%    2013-August-08, JL:
%        Add fields: modelDegreesOfFreedom of all/odd/even transits fits and reducedParameterFits
%                    statistic values of centroid tests and binary discrimination tests
%    2013-March-28, JL:
%        Add fileds maxMes, maxMesPhaseInDays, minMes, minMesPhaseInDays,
%        mesMad of planetCandidate.weakSecondaryStruct in
%        dvOutputMatrixTarget
%    2013-March-27, JL:
%        Initial release.
%
%=========================================================================================


% Define the file name 
dvDataFileName  = 'dvOutputMatrixTarget.mat';

% Initialize dvOutputMatrixTarget and dvOutputMatrixColumns
counter               = 0;
dvOutputMatrixTarget  = [];
nColumns              = 293;
dvOutputMatrixColumns = cell(nColumns, 1);

% Define the cell array dvOutputMatrixColumns
dvOutputMatrixColumns{  1} = 'taskFileId';
dvOutputMatrixColumns{  2} = 'targetIndexNumber';
dvOutputMatrixColumns{  3} = 'keplerId';
dvOutputMatrixColumns{  4} = 'numberOfPlanets';
dvOutputMatrixColumns{  5} = 'planetIndexNumber';
dvOutputMatrixColumns{  6} = 'numberOfAlerts';
dvOutputMatrixColumns{  7} = 'planetCandidate.maxSingleEventSigma';
dvOutputMatrixColumns{  8} = 'planetCandidate.maxMultipleEventSigma';
dvOutputMatrixColumns{  9} = 'planetCandidate.suspectedEclipsingBinary';
dvOutputMatrixColumns{ 10} = 'planetCandidate.statisticRatioBelowThreshold';
dvOutputMatrixColumns{ 11} = 'allTransitsFit.modelChiSquare';
dvOutputMatrixColumns{ 12} = 'allTransitsFit_numberOfModelParameters';
dvOutputMatrixColumns{ 13} = 'allTransitsFit_transitDepthPpm_value';
dvOutputMatrixColumns{ 14} = 'allTransitsFit_transitDepthPpm_uncertainty';
dvOutputMatrixColumns{ 15} = 'allTransitsFit_transitDepthPpm_fitted';
dvOutputMatrixColumns{ 16} = 'allTransitsFit_orbitalPeriodDays_value';
dvOutputMatrixColumns{ 17} = 'allTransitsFit_orbitalPeriodDays_uncertainty';
dvOutputMatrixColumns{ 18} = 'allTransitsFit_orbitalPeriodDays_fitted';
dvOutputMatrixColumns{ 19} = 'allTransitsFit_transitEpochBkjd_value';
dvOutputMatrixColumns{ 20} = 'allTransitsFit_transitEpochBkjd_uncertainty';
dvOutputMatrixColumns{ 21} = 'allTransitsFit_transitEpochBkjd_fitted';
dvOutputMatrixColumns{ 22} = 'allTransitsFit_transitDurationHours_value';
dvOutputMatrixColumns{ 23} = 'allTransitsFit_transitDurationHours_uncertainty';
dvOutputMatrixColumns{ 24} = 'allTransitsFit_transitDurationHours_fitted';
dvOutputMatrixColumns{ 25} = 'allTransitsFit_planetRadiusEarthRadii_value';
dvOutputMatrixColumns{ 26} = 'allTransitsFit_planetRadiusEarthRadii_uncertainty';
dvOutputMatrixColumns{ 27} = 'allTransitsFit_planetRadiusEarthRadii_fitted';
dvOutputMatrixColumns{ 28} = 'allTransitsFit_starRadiusSolarRadii_value';
dvOutputMatrixColumns{ 29} = 'allTransitsFit_starRadiusSolarRadii_uncertainty';
dvOutputMatrixColumns{ 30} = 'allTransitsFit_starRadiusSolarRadii_fitted';
dvOutputMatrixColumns{ 31} = 'allTransitsFit_semiMajorAxisAu_value';
dvOutputMatrixColumns{ 32} = 'allTransitsFit_semiMajorAxisAu_uncertainty';
dvOutputMatrixColumns{ 33} = 'allTransitsFit_semiMajorAxisAu_fitted';
dvOutputMatrixColumns{ 34} = 'allTransitsFit_minImpactParameter_value';
dvOutputMatrixColumns{ 35} = 'allTransitsFit_minImpactParameter_uncertainty';
dvOutputMatrixColumns{ 36} = 'allTransitsFit_minImpactParameter_fitted';
dvOutputMatrixColumns{ 37} = 'oddTransitsFit.modelChiSquare';
dvOutputMatrixColumns{ 38} = 'oddTransitsFit_numberOfModelParameters';
dvOutputMatrixColumns{ 39} = 'oddTransitsFit_transitDepthPpm_value';
dvOutputMatrixColumns{ 40} = 'oddTransitsFit_transitDepthPpm_uncertainty';
dvOutputMatrixColumns{ 41} = 'oddTransitsFit_transitDepthPpm_fitted';
dvOutputMatrixColumns{ 42} = 'oddTransitsFit_orbitalPeriodDays_value';
dvOutputMatrixColumns{ 43} = 'oddTransitsFit_orbitalPeriodDays_uncertainty';
dvOutputMatrixColumns{ 44} = 'oddTransitsFit_orbitalPeriodDays_fitted';
dvOutputMatrixColumns{ 45} = 'oddTransitsFit_transitEpochBkjd_value';
dvOutputMatrixColumns{ 46} = 'oddTransitsFit_transitEpochBkjd_uncertainty';
dvOutputMatrixColumns{ 47} = 'oddTransitsFit_transitEpochBkjd_fitted';
dvOutputMatrixColumns{ 48} = 'oddTransitsFit_transitDurationHours_value';
dvOutputMatrixColumns{ 49} = 'oddTransitsFit_transitDurationHours_uncertainty';
dvOutputMatrixColumns{ 50} = 'oddTransitsFit_transitDurationHours_fitted';
dvOutputMatrixColumns{ 51} = 'oddTransitsFit_planetRadiusEarthRadii_value';
dvOutputMatrixColumns{ 52} = 'oddTransitsFit_planetRadiusEarthRadii_uncertainty';
dvOutputMatrixColumns{ 53} = 'oddTransitsFit_planetRadiusEarthRadii_fitted';
dvOutputMatrixColumns{ 54} = 'oddTransitsFit_starRadiusSolarRadii_value';
dvOutputMatrixColumns{ 55} = 'oddTransitsFit_starRadiusSolarRadii_uncertainty';
dvOutputMatrixColumns{ 56} = 'oddTransitsFit_starRadiusSolarRadii_fitted';
dvOutputMatrixColumns{ 57} = 'oddTransitsFit_semiMajorAxisAu_value';
dvOutputMatrixColumns{ 58} = 'oddTransitsFit_semiMajorAxisAu_uncertainty';
dvOutputMatrixColumns{ 59} = 'oddTransitsFit_semiMajorAxisAu_fitted';
dvOutputMatrixColumns{ 60} = 'oddTransitsFit_minImpactParameter_value';
dvOutputMatrixColumns{ 61} = 'oddTransitsFit_minImpactParameter_uncertainty';
dvOutputMatrixColumns{ 62} = 'oddTransitsFit_minImpactParameter_fitted';
dvOutputMatrixColumns{ 63} = 'evenTransitsFit.modelChiSquare';
dvOutputMatrixColumns{ 64} = 'evenTransitsFit_numberOfModelParameters';
dvOutputMatrixColumns{ 65} = 'evenTransitsFit_transitDepthPpm_value';
dvOutputMatrixColumns{ 66} = 'evenTransitsFit_transitDepthPpm_uncertainty';
dvOutputMatrixColumns{ 67} = 'evenTransitsFit_transitDepthPpm_fitted';
dvOutputMatrixColumns{ 68} = 'evenTransitsFit_orbitalPeriodDays_value';
dvOutputMatrixColumns{ 69} = 'evenTransitsFit_orbitalPeriodDays_uncertainty';
dvOutputMatrixColumns{ 70} = 'evenTransitsFit_orbitalPeriodDays_fitted';
dvOutputMatrixColumns{ 71} = 'evenTransitsFit_transitEpochBkjd_value';
dvOutputMatrixColumns{ 72} = 'evenTransitsFit_transitEpochBkjd_uncertainty';
dvOutputMatrixColumns{ 73} = 'evenTransitsFit_transitEpochBkjd_fitted';
dvOutputMatrixColumns{ 74} = 'evenTransitsFit_transitDurationHours_value';
dvOutputMatrixColumns{ 75} = 'evenTransitsFit_transitDurationHours_uncertainty';
dvOutputMatrixColumns{ 76} = 'evenTransitsFit_transitDurationHours_fitted';
dvOutputMatrixColumns{ 77} = 'evenTransitsFit_planetRadiusEarthRadii_value';
dvOutputMatrixColumns{ 78} = 'evenTransitsFit_planetRadiusEarthRadii_uncertainty';
dvOutputMatrixColumns{ 79} = 'evenTransitsFit_planetRadiusEarthRadii_fitted';
dvOutputMatrixColumns{ 80} = 'evenTransitsFit_starRadiusSolarRadii_value';
dvOutputMatrixColumns{ 81} = 'evenTransitsFit_starRadiusSolarRadii_uncertainty';
dvOutputMatrixColumns{ 82} = 'evenTransitsFit_starRadiusSolarRadii_fitted';
dvOutputMatrixColumns{ 83} = 'evenTransitsFit_semiMajorAxisAu_value';
dvOutputMatrixColumns{ 84} = 'evenTransitsFit_semiMajorAxisAu_uncertainty';
dvOutputMatrixColumns{ 85} = 'evenTransitsFit_semiMajorAxisAu_fitted';
dvOutputMatrixColumns{ 86} = 'evenTransitsFit_minImpactParameter_value';
dvOutputMatrixColumns{ 87} = 'evenTransitsFit_minImpactParameter_uncertainty';
dvOutputMatrixColumns{ 88} = 'evenTransitsFit_minImpactParameter_fitted';
dvOutputMatrixColumns{ 89} = 'centroidResults.prfMotionResults.motionDetectionStatistic.significance';
dvOutputMatrixColumns{ 90} = 'centroidResults.fluxWeightedMotionResults.motionDetectionStatistic.significance';
dvOutputMatrixColumns{ 91} = 'binaryDiscriminationResults.oddEvenTransitDepthComparisonStatistic.significance';
dvOutputMatrixColumns{ 92} = 'binaryDiscriminationResults.oddEvenTransitEpochComparisonStatistic.significance';
dvOutputMatrixColumns{ 93} = 'binaryDiscriminationResults.shorterPeriodComparisonStatistic.significance';
dvOutputMatrixColumns{ 94} = 'binaryDiscriminationResults.longerPeriodComparisonStatistic.significance';
dvOutputMatrixColumns{ 95} = 'bootstrap_falseAlarmRate';
dvOutputMatrixColumns{ 96} = 'allTransitsFit_ratioPlanetRadiusToStarRadius_value';
dvOutputMatrixColumns{ 97} = 'allTransitsFit_ratioPlanetRadiusToStarRadius_uncertainty';
dvOutputMatrixColumns{ 98} = 'allTransitsFit_ratioPlanetRadiusToStarRadius_fitted';
dvOutputMatrixColumns{ 99} = 'allTransitsFit_ratioSemiMajorAxisToStarRadius_value';
dvOutputMatrixColumns{100} = 'allTransitsFit_ratioSemiMajorAxisToStarRadius_uncertainty';
dvOutputMatrixColumns{101} = 'allTransitsFit_ratioSemiMajorAxisToStarRadius_fitted';
dvOutputMatrixColumns{102} = 'oddTransitsFit_ratioPlanetRadiusToStarRadius_value';
dvOutputMatrixColumns{103} = 'oddTransitsFit_ratioPlanetRadiusToStarRadius_uncertainty';
dvOutputMatrixColumns{104} = 'oddTransitsFit_ratioPlanetRadiusToStarRadius_fitted';
dvOutputMatrixColumns{105} = 'oddTransitsFit_ratioSemiMajorAxisToStarRadius_value';
dvOutputMatrixColumns{106} = 'oddTransitsFit_ratioSemiMajorAxisToStarRadius_uncertainty';
dvOutputMatrixColumns{107} = 'oddTransitsFit_ratioSemiMajorAxisToStarRadius_fitted';
dvOutputMatrixColumns{108} = 'evenTransitsFit_ratioPlanetRadiusToStarRadius_value';
dvOutputMatrixColumns{109} = 'evenTransitsFit_ratioPlanetRadiusToStarRadius_uncertainty';
dvOutputMatrixColumns{110} = 'evenTransitsFit_ratioPlanetRadiusToStarRadius_fitted';
dvOutputMatrixColumns{111} = 'evenTransitsFit_ratioSemiMajorAxisToStarRadius_value';
dvOutputMatrixColumns{112} = 'evenTransitsFit_ratioSemiMajorAxisToStarRadius_uncertainty';
dvOutputMatrixColumns{113} = 'evenTransitsFit_ratioSemiMajorAxisToStarRadius_fitted';
dvOutputMatrixColumns{114} = 'stNumber';
dvOutputMatrixColumns{115} = 'allTransitsFit.fullConvergence';
dvOutputMatrixColumns{116} = 'allTransitsFit.modelFitSnr';
dvOutputMatrixColumns{117} = 'oddTransitsFit.fullConvergence';
dvOutputMatrixColumns{118} = 'oddTransitsFit.modelFitSnr';
dvOutputMatrixColumns{119} = 'evenTransitsFit.fullConvergence';
dvOutputMatrixColumns{120} = 'evenTransitsFit.modelFitSnr';
dvOutputMatrixColumns{121} = 'planetCandidate.epochMjd';
dvOutputMatrixColumns{122} = 'planetCandidate.orbitalPeriod';
dvOutputMatrixColumns{123} = 'centroidResults.differenceImageMotionResults.mqKicCentroidOffsets.meanSkyOffset.value';
dvOutputMatrixColumns{124} = 'centroidResults.differenceImageMotionResults.mqKicCentroidOffsets.meanSkyOffset.uncertainty';
dvOutputMatrixColumns{125} = 'centroidResults.differenceImageMotionResults.mqControlCentroidOffsets.meanSkyOffset.value';
dvOutputMatrixColumns{126} = 'centroidResults.differenceImageMotionResults.mqControlCentroidOffsets.meanSkyOffset.uncertainty';
dvOutputMatrixColumns{127} = 'centroidResults.pixelCorrelationMotionResults.mqKicCentroidOffsets.meanSkyOffset.value';
dvOutputMatrixColumns{128} = 'centroidResults.pixelCorrelationMotionResults.mqKicCentroidOffsets.meanSkyOffset.uncertainty';
dvOutputMatrixColumns{129} = 'centroidResults.pixelCorrelationMotionResults.mqControlCentroidOffsets.meanSkyOffset.value';
dvOutputMatrixColumns{130} = 'centroidResults.pixelCorrelationMotionResults.mqControlCentroidOffsets.meanSkyOffset.uncertainty';
dvOutputMatrixColumns{131} = 'centroidResults.differenceImageMotionResults.mqKicCentroidOffsets.singleFitSkyOffset.value';
dvOutputMatrixColumns{132} = 'centroidResults.differenceImageMotionResults.mqKicCentroidOffsets.singleFitSkyOffset.uncertainty';
dvOutputMatrixColumns{133} = 'centroidResults.differenceImageMotionResults.mqControlCentroidOffsets.singleFitSkyOffset.value';
dvOutputMatrixColumns{134} = 'centroidResults.differenceImageMotionResults.mqControlCentroidOffsets.singleFitSkyOffset.uncertainty';
dvOutputMatrixColumns{135} = 'centroidResults.pixelCorrelationMotionResults.mqKicCentroidOffsets.singleFitSkyOffset.value';
dvOutputMatrixColumns{136} = 'centroidResults.pixelCorrelationMotionResults.mqKicCentroidOffsets.singleFitSkyOffset.uncertainty';
dvOutputMatrixColumns{137} = 'centroidResults.pixelCorrelationMotionResults.mqControlCentroidOffsets.singleFitSkyOffset.value';
dvOutputMatrixColumns{138} = 'centroidResults.pixelCorrelationMotionResults.mqControlCentroidOffsets.singleFitSkyOffset.uncertainty';
dvOutputMatrixColumns{139} = 'allTransitsFit_equilibriumTempKelvin_value';
dvOutputMatrixColumns{140} = 'allTransitsFit_equilibriumTempKelvin_uncertainty';
dvOutputMatrixColumns{141} = 'reducedParameterFits_1.fullConvergence';
dvOutputMatrixColumns{142} = 'reducedParameterFits_1.modelChiSquare';
dvOutputMatrixColumns{143} = 'reducedParameterFits_2.fullConvergence';
dvOutputMatrixColumns{144} = 'reducedParameterFits_2.modelChiSquare';
dvOutputMatrixColumns{145} = 'reducedParameterFits_3.fullConvergence';
dvOutputMatrixColumns{146} = 'reducedParameterFits_3.modelChiSquare';
dvOutputMatrixColumns{147} = 'reducedParameterFits_4.fullConvergence';
dvOutputMatrixColumns{148} = 'reducedParameterFits_4.modelChiSquare';
dvOutputMatrixColumns{149} = 'reducedParameterFits_5.fullConvergence';
dvOutputMatrixColumns{150} = 'reducedParameterFits_5.modelChiSquare';
dvOutputMatrixColumns{151} = 'planetCandidate.chiSquare1';
dvOutputMatrixColumns{152} = 'planetCandidate.chiSquareDof1';
dvOutputMatrixColumns{153} = 'planetCandidate.chiSquare2';
dvOutputMatrixColumns{154} = 'planetCandidate.chiSquareDof2';
dvOutputMatrixColumns{155} = 'planetCandidate.modelChiSquare2';
dvOutputMatrixColumns{156} = 'planetCandidate.modelChiSquareDof2';
dvOutputMatrixColumns{157} = 'planetCandidate.weakSecondaryStruct.maxMes';
dvOutputMatrixColumns{158} = 'planetCandidate.weakSecondaryStruct.maxMesPhaseInDays';
dvOutputMatrixColumns{159} = 'radius.value';
dvOutputMatrixColumns{160} = 'effectiveTemp.value';
dvOutputMatrixColumns{161} = 'log10SurfaceGravity.value';
dvOutputMatrixColumns{162} = 'log10Metallicity.value';
dvOutputMatrixColumns{163} = 'centroidResults.differenceImageMotionResults.summaryQualityMetric.numberOfAttempts';
dvOutputMatrixColumns{164} = 'centroidResults.differenceImageMotionResults.summaryQualityMetric.numberOfMetrics';
dvOutputMatrixColumns{165} = 'centroidResults.differenceImageMotionResults.summaryQualityMetric.numberOfGoodMetrics';
dvOutputMatrixColumns{166} = 'centroidResults.differenceImageMotionResults.summaryQualityMetric.fractionOfGoodMetrics';
dvOutputMatrixColumns{167} = 'centroidResults.prfMotionResults.sourceOffsetArcSec.value';
dvOutputMatrixColumns{168} = 'centroidResults.prfMotionResults.sourceOffsetArcSec.uncertainty';
dvOutputMatrixColumns{169} = 'centroidResults.fluxWeightedMotionResults.sourceOffsetArcSec.value';
dvOutputMatrixColumns{170} = 'centroidResults.fluxWeightedMotionResults.sourceOffsetArcSec.uncertainty';
dvOutputMatrixColumns{171} = 'planetCandidate.weakSecondaryStruct.minMes';
dvOutputMatrixColumns{172} = 'planetCandidate.weakSecondaryStruct.minMesPhaseInDays';
dvOutputMatrixColumns{173} = 'planetCandidate.weakSecondaryStruct.mesMad';
dvOutputMatrixColumns{174} = 'allTransitsFit.modelDegreesOfFreedom';
dvOutputMatrixColumns{175} = 'oddTransitsFit.modelDegreesOfFreedom';
dvOutputMatrixColumns{176} = 'evenTransitsFit.modelDegreesOfFreedom';
dvOutputMatrixColumns{177} = 'reducedParameterFits_1.modelDegreesOfFreedom';
dvOutputMatrixColumns{178} = 'reducedParameterFits_2.modelDegreesOfFreedom';
dvOutputMatrixColumns{179} = 'reducedParameterFits_3.modelDegreesOfFreedom';
dvOutputMatrixColumns{180} = 'reducedParameterFits_4.modelDegreesOfFreedom';
dvOutputMatrixColumns{181} = 'reducedParameterFits_5.modelDegreesOfFreedom';
dvOutputMatrixColumns{182} = 'centroidResults.prfMotionResults.motionDetectionStatistic.value';
dvOutputMatrixColumns{183} = 'centroidResults.fluxWeightedMotionResults.motionDetectionStatistic.value';
dvOutputMatrixColumns{184} = 'binaryDiscriminationResults.oddEvenTransitDepthComparisonStatistic.value';
dvOutputMatrixColumns{185} = 'binaryDiscriminationResults.oddEvenTransitEpochComparisonStatistic.value';
dvOutputMatrixColumns{186} = 'binaryDiscriminationResults.shorterPeriodComparisonStatistic.value';
dvOutputMatrixColumns{187} = 'binaryDiscriminationResults.longerPeriodComparisonStatistic.value';
dvOutputMatrixColumns{188} = 'skyGroupId';
dvOutputMatrixColumns{189} = 'targetKoiId';
dvOutputMatrixColumns{190} = 'planetKoiId';
dvOutputMatrixColumns{191} = 'planetKoiCorrelation';
dvOutputMatrixColumns{192} = 'allTransitsFit_transitIngressTimeHours_value';
dvOutputMatrixColumns{193} = 'allTransitsFit_transitIngressTimeHours_uncertainty';
dvOutputMatrixColumns{194} = 'allTransitsFit_transitIngressTimeHours_fitted';
dvOutputMatrixColumns{195} = 'oddTransitsFit_transitIngressTimeHours_value';
dvOutputMatrixColumns{196} = 'oddTransitsFit_transitIngressTimeHours_uncertainty';
dvOutputMatrixColumns{197} = 'oddTransitsFit_transitIngressTimeHours_fitted';
dvOutputMatrixColumns{198} = 'evenTransitsFit_transitIngressTimeHours_value';
dvOutputMatrixColumns{199} = 'evenTransitsFit_transitIngressTimeHours_uncertainty';
dvOutputMatrixColumns{200} = 'evenTransitsFit_transitIngressTimeHours_fitted';
dvOutputMatrixColumns{201} = 'allTransitsFit_inclinationDegrees_value';
dvOutputMatrixColumns{202} = 'allTransitsFit_inclinationDegrees_uncertainty';
dvOutputMatrixColumns{203} = 'allTransitsFit_inclinationDegrees_fitted';
dvOutputMatrixColumns{204} = 'oddTransitsFit_inclinationDegrees_value';
dvOutputMatrixColumns{205} = 'oddTransitsFit_inclinationDegrees_uncertainty';
dvOutputMatrixColumns{206} = 'oddTransitsFit_inclinationDegrees_fitted';
dvOutputMatrixColumns{207} = 'evenTransitsFit_inclinationDegrees_value';
dvOutputMatrixColumns{208} = 'evenTransitsFit_inclinationDegrees_uncertainty';
dvOutputMatrixColumns{209} = 'evenTransitsFit_inclinationDegrees_fitted';
dvOutputMatrixColumns{210} = 'allTransitsFit_eccentricity_value';
dvOutputMatrixColumns{211} = 'allTransitsFit_eccentricity_uncertainty';
dvOutputMatrixColumns{212} = 'allTransitsFit_eccentricity_fitted';
dvOutputMatrixColumns{213} = 'oddTransitsFit_eccentricity_value';
dvOutputMatrixColumns{214} = 'oddTransitsFit_eccentricity_uncertainty';
dvOutputMatrixColumns{215} = 'oddTransitsFit_eccentricity_fitted';
dvOutputMatrixColumns{216} = 'evenTransitsFit_eccentricity_value';
dvOutputMatrixColumns{217} = 'evenTransitsFit_eccentricity_uncertainty';
dvOutputMatrixColumns{218} = 'evenTransitsFit_eccentricity_fitted';
dvOutputMatrixColumns{219} = 'allTransitsFit_longitudeOfPeriDegrees_value';
dvOutputMatrixColumns{220} = 'allTransitsFit_longitudeOfPeriDegrees_uncertainty';
dvOutputMatrixColumns{221} = 'allTransitsFit_longitudeOfPeriDegrees_fitted';
dvOutputMatrixColumns{222} = 'oddTransitsFit_longitudeOfPeriDegrees_value';
dvOutputMatrixColumns{223} = 'oddTransitsFit_longitudeOfPeriDegrees_uncertainty';
dvOutputMatrixColumns{224} = 'oddTransitsFit_longitudeOfPeriDegrees_fitted';
dvOutputMatrixColumns{225} = 'evenTransitsFit_longitudeOfPeriDegrees_value';
dvOutputMatrixColumns{226} = 'evenTransitsFit_longitudeOfPeriDegrees_uncertainty';
dvOutputMatrixColumns{227} = 'evenTransitsFit_longitudeOfPeriDegrees_fitted';
dvOutputMatrixColumns{228} = 'rollingBandContaminationHistogram.transitFraction_level0';
dvOutputMatrixColumns{229} = 'rollingBandContaminationHistogram.transitFraction_level1';
dvOutputMatrixColumns{230} = 'rollingBandContaminationHistogram.transitFraction_level2';
dvOutputMatrixColumns{231} = 'rollingBandContaminationHistogram.transitFraction_level3';
dvOutputMatrixColumns{232} = 'rollingBandContaminationHistogram.transitFraction_level4';
dvOutputMatrixColumns{233} = 'secondaryEventResults.planetParameters.geometricAlbedo.value';
dvOutputMatrixColumns{234} = 'secondaryEventResults.planetParameters.geometricAlbedo.uncertainty';
dvOutputMatrixColumns{235} = 'secondaryEventResults.planetParameters.planetEffectiveTemp.value';
dvOutputMatrixColumns{236} = 'secondaryEventResults.planetParameters.planetEffectiveTemp.uncertainty';
dvOutputMatrixColumns{237} = 'secondaryEventResults.comparisonTests.albedoComparisonStatistic.value';
dvOutputMatrixColumns{238} = 'secondaryEventResults.comparisonTests.albedoComparisonStatistic.significance';
dvOutputMatrixColumns{239} = 'secondaryEventResults.comparisonTests.tempComparisonStatistic.value';
dvOutputMatrixColumns{240} = 'secondaryEventResults.comparisonTests.tempComparisonStatistic.significance';
dvOutputMatrixColumns{241} = 'allTransitsFit_effectiveStellarFlux_value';
dvOutputMatrixColumns{242} = 'allTransitsFit_effectiveStellarFlux_uncertainty';
dvOutputMatrixColumns{243} = 'allTransitsFit_effectiveStellarFlux_fitted';
dvOutputMatrixColumns{244} = 'oddTransitsFit_effectiveStellarFlux_value';
dvOutputMatrixColumns{245} = 'oddTransitsFit_effectiveStellarFlux_uncertainty';
dvOutputMatrixColumns{246} = 'oddTransitsFit_effectiveStellarFlux_fitted';
dvOutputMatrixColumns{247} = 'evenTransitsFit_effectiveStellarFlux_value';
dvOutputMatrixColumns{248} = 'evenTransitsFit_effectiveStellarFlux_uncertainty';
dvOutputMatrixColumns{249} = 'evenTransitsFit_effectiveStellarFlux_fitted';
dvOutputMatrixColumns{250} = 'centroidResults.differenceImageMotionResults.summaryOverlapMetric.imageCount';
dvOutputMatrixColumns{251} = 'centroidResults.differenceImageMotionResults.summaryOverlapMetric.imageCountNoOverlap';
dvOutputMatrixColumns{252} = 'centroidResults.differenceImageMotionResults.summaryOverlapMetric.imageCountFractionNoOverlap';
dvOutputMatrixColumns{253} = 'planetCandidate.chiSquareGof';
dvOutputMatrixColumns{254} = 'planetCandidate.chiSquareGofDof';
dvOutputMatrixColumns{255} = 'planetCandidate.modelChiSquareGof';
dvOutputMatrixColumns{256} = 'planetCandidate.modelChiSquareGofDof';
dvOutputMatrixColumns{257} = 'planetCandidate.trialTransitPulseDuration';
dvOutputMatrixColumns{258} = 'ghostDiagnosticResults.coreApertureCorrelationStatistic_value';
dvOutputMatrixColumns{259} = 'ghostDiagnosticResults.coreApertureCorrelationStatistic_significance';
dvOutputMatrixColumns{260} = 'ghostDiagnosticResults.haloApertureCorrelationStatistic_value';
dvOutputMatrixColumns{261} = 'ghostDiagnosticResults.haloApertureCorrelationStatistic_significance';
dvOutputMatrixColumns{262} = 'trapezoidalFit.fullConvergence';
dvOutputMatrixColumns{263} = 'trapezoidalFit.modelChiSquare';
dvOutputMatrixColumns{264} = 'trapezoidalFit.modelDegreesOfFreedom';
dvOutputMatrixColumns{265} = 'trapezoidalFit.modelFitSnr';
dvOutputMatrixColumns{266} = 'trapezoidalFit_numberOfModelParameters';
dvOutputMatrixColumns{267} = 'trapezoidalFit_transitDepthPpm_value';
dvOutputMatrixColumns{268} = 'trapezoidalFit_transitDepthPpm_fitted';
dvOutputMatrixColumns{269} = 'trapezoidalFit_orbitalPeriodDays_value';
dvOutputMatrixColumns{270} = 'trapezoidalFit_orbitalPeriodDays_fitted';
dvOutputMatrixColumns{271} = 'trapezoidalFit_transitEpochBkjd_value';
dvOutputMatrixColumns{272} = 'trapezoidalFit_transitEpochBkjd_fitted';
dvOutputMatrixColumns{273} = 'trapezoidalFit_transitDurationHours_value';
dvOutputMatrixColumns{274} = 'trapezoidalFit_transitDurationHours_fitted';
dvOutputMatrixColumns{275} = 'trapezoidalFit_transitIngressTimeHours_value';
dvOutputMatrixColumns{276} = 'trapezoidalFit_transitIngressTimeHours_fitted';
dvOutputMatrixColumns{277} = 'trapezoidalFit_minImpactParameter_value';
dvOutputMatrixColumns{278} = 'trapezoidalFit_minImpactParameter_fitted';
dvOutputMatrixColumns{279} = 'trapezoidalFit_ratioPlanetRadiusToStarRadius_value';
dvOutputMatrixColumns{280} = 'trapezoidalFit_ratioPlanetRadiusToStarRadius_fitted';
dvOutputMatrixColumns{281} = 'trapezoidalFit_ratioSemiMajorAxisToStarRadius_value';
dvOutputMatrixColumns{282} = 'trapezoidalFit_ratioSemiMajorAxisToStarRadius_fitted';
dvOutputMatrixColumns{283} = 'planetCandidate.expectedTransitCount';
dvOutputMatrixColumns{284} = 'planetCandidate.observedTransitCount';
dvOutputMatrixColumns{285} = 'planetCandidate.thresholdForDesiredPfa';
dvOutputMatrixColumns{286} = 'planetCandidate.bootstrapThresholdForDesiredPfa';
dvOutputMatrixColumns{287} = 'planetCandidate.weakSecondaryStruct.medianMes';
dvOutputMatrixColumns{288} = 'planetCandidate.weakSecondaryStruct.nValidPhases';
dvOutputMatrixColumns{289} = 'planetCandidate.weakSecondaryStruct.robustStatistic';
dvOutputMatrixColumns{290} = 'planetCandidate.weakSecondaryStruct.depthPpm.value';
dvOutputMatrixColumns{291} = 'planetCandidate.weakSecondaryStruct.depthPpm.uncertainty';
dvOutputMatrixColumns{292} = 'planetCandidate.bootstrapMesMean';
dvOutputMatrixColumns{293} = 'planetCandidate.bootstrapMesStd';

% taskId and stNumber are unavailable in the pipeline
taskId   = -1;    
stNumber = -1;

% Retrieve the DV output data
for j1=1:length(dvResultsStruct.targetResultsStruct)
    
    for j2=1:length(dvResultsStruct.targetResultsStruct(j1).planetResultsStruct)
        
        counter = counter + 1;
        dvOutputMatrixTarget(counter, 1) = taskId;
        dvOutputMatrixTarget(counter, 2) = j1;
        
        dvOutputMatrixTarget(counter, 3) = dvResultsStruct.targetResultsStruct(j1).keplerId;
        dvOutputMatrixTarget(counter, 4) = length(dvResultsStruct.targetResultsStruct(j1).planetResultsStruct);
        dvOutputMatrixTarget(counter, 5) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetNumber;
        dvOutputMatrixTarget(counter, 6) = length(dvResultsStruct.alerts);
        
        dvOutputMatrixTarget(counter, 7) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.maxSingleEventSigma;
        dvOutputMatrixTarget(counter, 8) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.maxMultipleEventSigma;
        dvOutputMatrixTarget(counter, 9) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.suspectedEclipsingBinary;
        dvOutputMatrixTarget(counter,10) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.statisticRatioBelowThreshold;
        
        dvOutputMatrixTarget(counter,11) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelChiSquare;
        lengthParameters = length(dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters);
        dvOutputMatrixTarget(counter,12) = lengthParameters;
        if (lengthParameters==16)
            dvOutputMatrixTarget(counter, 13) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(10).value;           % transitDepth
            dvOutputMatrixTarget(counter, 14) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(10).uncertainty;
            dvOutputMatrixTarget(counter, 15) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(10).fitted;
            dvOutputMatrixTarget(counter, 16) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(11).value;           % orbitalPeriod
            dvOutputMatrixTarget(counter, 17) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(11).uncertainty;
            dvOutputMatrixTarget(counter, 18) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(11).fitted;
            dvOutputMatrixTarget(counter, 19) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 1).value;           % transitEpoch
            dvOutputMatrixTarget(counter, 20) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 1).uncertainty;
            dvOutputMatrixTarget(counter, 21) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 1).fitted;
            dvOutputMatrixTarget(counter, 22) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 8).value;           % transitDuration
            dvOutputMatrixTarget(counter, 23) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 8).uncertainty;
            dvOutputMatrixTarget(counter, 24) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 8).fitted;
            dvOutputMatrixTarget(counter, 25) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 4).value;           % planetRadius
            dvOutputMatrixTarget(counter, 26) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 4).uncertainty;
            dvOutputMatrixTarget(counter, 27) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 4).fitted;
            dvOutputMatrixTarget(counter, 28) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 7).value;           % starRadius
            dvOutputMatrixTarget(counter, 29) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 7).uncertainty;
            dvOutputMatrixTarget(counter, 30) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 7).fitted;
            dvOutputMatrixTarget(counter, 31) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 5).value;           % semiMajorAxis
            dvOutputMatrixTarget(counter, 32) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 5).uncertainty;
            dvOutputMatrixTarget(counter, 33) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 5).fitted;
            dvOutputMatrixTarget(counter, 34) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 6).value;           % minImpactParameter
            dvOutputMatrixTarget(counter, 35) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 6).uncertainty;
            dvOutputMatrixTarget(counter, 36) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 6).fitted;
            dvOutputMatrixTarget(counter, 96) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(12).value;           % ratioPlanetRadiusToStarRadius
            dvOutputMatrixTarget(counter, 97) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(12).uncertainty;
            dvOutputMatrixTarget(counter, 98) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(12).fitted;
            dvOutputMatrixTarget(counter, 99) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(13).value;           % ratioSemiMajorAxisToStarRadius
            dvOutputMatrixTarget(counter,100) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(13).uncertainty;
            dvOutputMatrixTarget(counter,101) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(13).fitted;
            dvOutputMatrixTarget(counter,139) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(15).value;           % equilibriumTempKelvin
            dvOutputMatrixTarget(counter,140) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(15).uncertainty;
            dvOutputMatrixTarget(counter,192) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 9).value;           % transitIngressTimeHours
            dvOutputMatrixTarget(counter,193) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 9).uncertainty;
            dvOutputMatrixTarget(counter,194) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 9).fitted;
            dvOutputMatrixTarget(counter,201) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(14).value;           % inclinationDegrees
            dvOutputMatrixTarget(counter,202) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(14).uncertainty;
            dvOutputMatrixTarget(counter,203) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(14).fitted;
            dvOutputMatrixTarget(counter,210) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 2).value;           % eccentricity
            dvOutputMatrixTarget(counter,211) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 2).uncertainty;
            dvOutputMatrixTarget(counter,212) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 2).fitted;
            dvOutputMatrixTarget(counter,219) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 3).value;           % longitudeOfPeriDegrees
            dvOutputMatrixTarget(counter,220) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 3).uncertainty;
            dvOutputMatrixTarget(counter,221) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters( 3).fitted;
            dvOutputMatrixTarget(counter,241) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(16).value;           % effectiveStellarFlux
            dvOutputMatrixTarget(counter,242) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(16).uncertainty;
            dvOutputMatrixTarget(counter,243) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelParameters(16).fitted;
        else
            dvOutputMatrixTarget(counter, 13) = -1;
            dvOutputMatrixTarget(counter, 14) = -1;
            dvOutputMatrixTarget(counter, 15) = -1;
            dvOutputMatrixTarget(counter, 16) = -1;
            dvOutputMatrixTarget(counter, 17) = -1;
            dvOutputMatrixTarget(counter, 18) = -1;
            dvOutputMatrixTarget(counter, 19) = -1;
            dvOutputMatrixTarget(counter, 20) = -1;
            dvOutputMatrixTarget(counter, 21) = -1;
            dvOutputMatrixTarget(counter, 22) = -1;
            dvOutputMatrixTarget(counter, 23) = -1;
            dvOutputMatrixTarget(counter, 24) = -1;
            dvOutputMatrixTarget(counter, 25) = -1;
            dvOutputMatrixTarget(counter, 26) = -1;
            dvOutputMatrixTarget(counter, 27) = -1;
            dvOutputMatrixTarget(counter, 28) = -1;
            dvOutputMatrixTarget(counter, 29) = -1;
            dvOutputMatrixTarget(counter, 30) = -1;
            dvOutputMatrixTarget(counter, 31) = -1;
            dvOutputMatrixTarget(counter, 32) = -1;
            dvOutputMatrixTarget(counter, 33) = -1;
            dvOutputMatrixTarget(counter, 34) = -1;
            dvOutputMatrixTarget(counter, 35) = -1;
            dvOutputMatrixTarget(counter, 36) = -1;
            dvOutputMatrixTarget(counter, 96) = -1;
            dvOutputMatrixTarget(counter, 97) = -1;
            dvOutputMatrixTarget(counter, 98) = -1;
            dvOutputMatrixTarget(counter, 99) = -1;
            dvOutputMatrixTarget(counter,100) = -1;
            dvOutputMatrixTarget(counter,101) = -1;
            dvOutputMatrixTarget(counter,139) = -1;
            dvOutputMatrixTarget(counter,140) = -1;
            dvOutputMatrixTarget(counter,192) = -1;
            dvOutputMatrixTarget(counter,193) = -1;
            dvOutputMatrixTarget(counter,194) = -1;
            dvOutputMatrixTarget(counter,201) = -1;
            dvOutputMatrixTarget(counter,202) = -1;
            dvOutputMatrixTarget(counter,203) = -1;
            dvOutputMatrixTarget(counter,210) = -1;
            dvOutputMatrixTarget(counter,211) = -1;
            dvOutputMatrixTarget(counter,212) = -1;
            dvOutputMatrixTarget(counter,219) = -1;
            dvOutputMatrixTarget(counter,220) = -1;
            dvOutputMatrixTarget(counter,221) = -1;
            dvOutputMatrixTarget(counter,241) = -1;
            dvOutputMatrixTarget(counter,242) = -1;
            dvOutputMatrixTarget(counter,243) = -1;
        end
        
        dvOutputMatrixTarget(counter,37) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelChiSquare;
        lengthParameters = length(dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters);
        dvOutputMatrixTarget(counter,38) = lengthParameters;
        if (lengthParameters==16)
            dvOutputMatrixTarget(counter, 39) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(10).value;           % transitDepth
            dvOutputMatrixTarget(counter, 40) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(10).uncertainty;
            dvOutputMatrixTarget(counter, 41) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(10).fitted;
            dvOutputMatrixTarget(counter, 42) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(11).value;           % orbitalPeriod
            dvOutputMatrixTarget(counter, 43) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(11).uncertainty;
            dvOutputMatrixTarget(counter, 44) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(11).fitted;
            dvOutputMatrixTarget(counter, 45) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 1).value;           % transitEpoch
            dvOutputMatrixTarget(counter, 46) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 1).uncertainty;
            dvOutputMatrixTarget(counter, 47) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 1).fitted;
            dvOutputMatrixTarget(counter, 48) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 8).value;           % transitDuration
            dvOutputMatrixTarget(counter, 49) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 8).uncertainty;
            dvOutputMatrixTarget(counter, 50) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 8).fitted;
            dvOutputMatrixTarget(counter, 51) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 4).value;           % planetRadius
            dvOutputMatrixTarget(counter, 52) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 4).uncertainty;
            dvOutputMatrixTarget(counter, 53) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 4).fitted;
            dvOutputMatrixTarget(counter, 54) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 7).value;           % starRadius
            dvOutputMatrixTarget(counter, 55) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 7).uncertainty;
            dvOutputMatrixTarget(counter, 56) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 7).fitted;
            dvOutputMatrixTarget(counter, 57) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 5).value;           % semiMajorAxis
            dvOutputMatrixTarget(counter, 58) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 5).uncertainty;
            dvOutputMatrixTarget(counter, 59) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 5).fitted;
            dvOutputMatrixTarget(counter, 60) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 6).value;           % minImpactParameter
            dvOutputMatrixTarget(counter, 61) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 6).uncertainty;
            dvOutputMatrixTarget(counter, 62) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 6).fitted;
            dvOutputMatrixTarget(counter,102) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(12).value;           % ratioPlanetRadiusToStarRadius
            dvOutputMatrixTarget(counter,103) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(12).uncertainty;
            dvOutputMatrixTarget(counter,104) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(12).fitted;
            dvOutputMatrixTarget(counter,105) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(13).value;           % ratioSemiMajorAxisToStarRadius
            dvOutputMatrixTarget(counter,106) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(13).uncertainty;
            dvOutputMatrixTarget(counter,107) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(13).fitted;
            dvOutputMatrixTarget(counter,195) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 9).value;           % transitIngressTimeHours
            dvOutputMatrixTarget(counter,196) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 9).uncertainty;
            dvOutputMatrixTarget(counter,197) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 9).fitted;
            dvOutputMatrixTarget(counter,204) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(14).value;           % inclinationDegrees
            dvOutputMatrixTarget(counter,205) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(14).uncertainty;
            dvOutputMatrixTarget(counter,206) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(14).fitted;
            dvOutputMatrixTarget(counter,213) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 2).value;           % eccentricity
            dvOutputMatrixTarget(counter,214) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 2).uncertainty;
            dvOutputMatrixTarget(counter,215) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 2).fitted;
            dvOutputMatrixTarget(counter,222) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 3).value;           % longitudeOfPeriDegrees
            dvOutputMatrixTarget(counter,223) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 3).uncertainty;
            dvOutputMatrixTarget(counter,224) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters( 3).fitted;
            dvOutputMatrixTarget(counter,244) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(16).value;           % effectiveStellarFlux
            dvOutputMatrixTarget(counter,245) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(16).uncertainty;
            dvOutputMatrixTarget(counter,246) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelParameters(16).fitted;
       else
            dvOutputMatrixTarget(counter, 39) = -1;
            dvOutputMatrixTarget(counter, 40) = -1;
            dvOutputMatrixTarget(counter, 41) = -1;
            dvOutputMatrixTarget(counter, 42) = -1;
            dvOutputMatrixTarget(counter, 43) = -1;
            dvOutputMatrixTarget(counter, 44) = -1;
            dvOutputMatrixTarget(counter, 45) = -1;
            dvOutputMatrixTarget(counter, 46) = -1;
            dvOutputMatrixTarget(counter, 47) = -1;
            dvOutputMatrixTarget(counter, 48) = -1;
            dvOutputMatrixTarget(counter, 49) = -1;
            dvOutputMatrixTarget(counter, 50) = -1;
            dvOutputMatrixTarget(counter, 51) = -1;
            dvOutputMatrixTarget(counter, 52) = -1;
            dvOutputMatrixTarget(counter, 53) = -1;
            dvOutputMatrixTarget(counter, 54) = -1;
            dvOutputMatrixTarget(counter, 55) = -1;
            dvOutputMatrixTarget(counter, 56) = -1;
            dvOutputMatrixTarget(counter, 57) = -1;
            dvOutputMatrixTarget(counter, 58) = -1;
            dvOutputMatrixTarget(counter, 59) = -1;
            dvOutputMatrixTarget(counter, 60) = -1;
            dvOutputMatrixTarget(counter, 61) = -1;
            dvOutputMatrixTarget(counter, 62) = -1;
            dvOutputMatrixTarget(counter,102) = -1;
            dvOutputMatrixTarget(counter,103) = -1;
            dvOutputMatrixTarget(counter,104) = -1;
            dvOutputMatrixTarget(counter,105) = -1;
            dvOutputMatrixTarget(counter,106) = -1;
            dvOutputMatrixTarget(counter,107) = -1;
            dvOutputMatrixTarget(counter,195) = -1;
            dvOutputMatrixTarget(counter,196) = -1;
            dvOutputMatrixTarget(counter,197) = -1;
            dvOutputMatrixTarget(counter,204) = -1;
            dvOutputMatrixTarget(counter,205) = -1;
            dvOutputMatrixTarget(counter,206) = -1;        
            dvOutputMatrixTarget(counter,213) = -1;
            dvOutputMatrixTarget(counter,214) = -1;
            dvOutputMatrixTarget(counter,215) = -1;
            dvOutputMatrixTarget(counter,222) = -1;
            dvOutputMatrixTarget(counter,223) = -1;
            dvOutputMatrixTarget(counter,224) = -1;
            dvOutputMatrixTarget(counter,244) = -1;
            dvOutputMatrixTarget(counter,245) = -1;
            dvOutputMatrixTarget(counter,246) = -1;
        end
        
        dvOutputMatrixTarget(counter,63) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelChiSquare;
        lengthParameters = length(dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters);
        dvOutputMatrixTarget(counter,64) = lengthParameters;
        if (lengthParameters==16)
            dvOutputMatrixTarget(counter, 65) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(10).value;           % transitDepth
            dvOutputMatrixTarget(counter, 66) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(10).uncertainty;
            dvOutputMatrixTarget(counter, 67) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(10).fitted;
            dvOutputMatrixTarget(counter, 68) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(11).value;           % orbitalPeriod
            dvOutputMatrixTarget(counter, 69) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(11).uncertainty;
            dvOutputMatrixTarget(counter, 70) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(11).fitted;
            dvOutputMatrixTarget(counter, 71) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 1).value;           % transitEpoch
            dvOutputMatrixTarget(counter, 72) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 1).uncertainty;
            dvOutputMatrixTarget(counter, 73) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 1).fitted;
            dvOutputMatrixTarget(counter, 74) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 8).value;           % transitDuration
            dvOutputMatrixTarget(counter, 75) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 8).uncertainty;
            dvOutputMatrixTarget(counter, 76) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 8).fitted;
            dvOutputMatrixTarget(counter, 77) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 4).value;           % planetRadius
            dvOutputMatrixTarget(counter, 78) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 4).uncertainty;
            dvOutputMatrixTarget(counter, 79) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 4).fitted;
            dvOutputMatrixTarget(counter, 80) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 7).value;           % starRadius
            dvOutputMatrixTarget(counter, 81) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 7).uncertainty;
            dvOutputMatrixTarget(counter, 82) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 7).fitted;
            dvOutputMatrixTarget(counter, 83) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 5).value;           % semiMajorAxis
            dvOutputMatrixTarget(counter, 84) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 5).uncertainty;
            dvOutputMatrixTarget(counter, 85) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 5).fitted;
            dvOutputMatrixTarget(counter, 86) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 6).value;           % minImpactParameter
            dvOutputMatrixTarget(counter, 87) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 6).uncertainty;
            dvOutputMatrixTarget(counter, 88) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 6).fitted;
            dvOutputMatrixTarget(counter,108) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(12).value;           % ratioPlanetRadiusToStarRadius
            dvOutputMatrixTarget(counter,109) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(12).uncertainty;
            dvOutputMatrixTarget(counter,110) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(12).fitted;
            dvOutputMatrixTarget(counter,111) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(13).value;           % ratioSemiMajorAxisToStarRadius
            dvOutputMatrixTarget(counter,112) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(13).uncertainty;
            dvOutputMatrixTarget(counter,113) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(13).fitted;
            dvOutputMatrixTarget(counter,198) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 9).value;           % transitIngressTimeHours
            dvOutputMatrixTarget(counter,199) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 9).uncertainty;
            dvOutputMatrixTarget(counter,200) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 9).fitted;
            dvOutputMatrixTarget(counter,207) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(14).value;           % inclinationDegrees
            dvOutputMatrixTarget(counter,208) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(14).uncertainty;
            dvOutputMatrixTarget(counter,209) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(14).fitted;
            dvOutputMatrixTarget(counter,216) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 2).value;           % eccentricity
            dvOutputMatrixTarget(counter,217) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 2).uncertainty;
            dvOutputMatrixTarget(counter,218) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 2).fitted;
            dvOutputMatrixTarget(counter,225) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 3).value;           % longitudeOfPeriDegrees
            dvOutputMatrixTarget(counter,226) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 3).uncertainty;
            dvOutputMatrixTarget(counter,227) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters( 3).fitted;
            dvOutputMatrixTarget(counter,247) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(16).value;           % effectiveStellarFlux
            dvOutputMatrixTarget(counter,248) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(16).uncertainty;
            dvOutputMatrixTarget(counter,249) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelParameters(16).fitted;
       else
            dvOutputMatrixTarget(counter, 65) = -1;
            dvOutputMatrixTarget(counter, 66) = -1;
            dvOutputMatrixTarget(counter, 67) = -1;
            dvOutputMatrixTarget(counter, 68) = -1;
            dvOutputMatrixTarget(counter, 69) = -1;
            dvOutputMatrixTarget(counter, 70) = -1;
            dvOutputMatrixTarget(counter, 71) = -1;
            dvOutputMatrixTarget(counter, 72) = -1;
            dvOutputMatrixTarget(counter, 73) = -1;
            dvOutputMatrixTarget(counter, 74) = -1;
            dvOutputMatrixTarget(counter, 75) = -1;
            dvOutputMatrixTarget(counter, 76) = -1;
            dvOutputMatrixTarget(counter, 77) = -1;
            dvOutputMatrixTarget(counter, 78) = -1;
            dvOutputMatrixTarget(counter, 79) = -1;
            dvOutputMatrixTarget(counter, 80) = -1;
            dvOutputMatrixTarget(counter, 81) = -1;
            dvOutputMatrixTarget(counter, 82) = -1;
            dvOutputMatrixTarget(counter, 83) = -1;
            dvOutputMatrixTarget(counter, 84) = -1;
            dvOutputMatrixTarget(counter, 85) = -1;
            dvOutputMatrixTarget(counter, 86) = -1;
            dvOutputMatrixTarget(counter, 87) = -1;
            dvOutputMatrixTarget(counter, 88) = -1;
            dvOutputMatrixTarget(counter,108) = -1;
            dvOutputMatrixTarget(counter,109) = -1;
            dvOutputMatrixTarget(counter,110) = -1;
            dvOutputMatrixTarget(counter,111) = -1;
            dvOutputMatrixTarget(counter,112) = -1;
            dvOutputMatrixTarget(counter,113) = -1;
            dvOutputMatrixTarget(counter,198) = -1;
            dvOutputMatrixTarget(counter,199) = -1;
            dvOutputMatrixTarget(counter,200) = -1;
            dvOutputMatrixTarget(counter,207) = -1;
            dvOutputMatrixTarget(counter,208) = -1;
            dvOutputMatrixTarget(counter,209) = -1;
            dvOutputMatrixTarget(counter,216) = -1;
            dvOutputMatrixTarget(counter,217) = -1;
            dvOutputMatrixTarget(counter,218) = -1;
            dvOutputMatrixTarget(counter,225) = -1;
            dvOutputMatrixTarget(counter,226) = -1;
            dvOutputMatrixTarget(counter,227) = -1;
            dvOutputMatrixTarget(counter,247) = -1;
            dvOutputMatrixTarget(counter,248) = -1;
            dvOutputMatrixTarget(counter,249) = -1;
        end
        
        
        dvOutputMatrixTarget(counter, 89) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.prfMotionResults.motionDetectionStatistic.significance;
        dvOutputMatrixTarget(counter, 90) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.fluxWeightedMotionResults.motionDetectionStatistic.significance;
        
        dvOutputMatrixTarget(counter, 91) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).binaryDiscriminationResults.oddEvenTransitDepthComparisonStatistic.significance;
        dvOutputMatrixTarget(counter, 92) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).binaryDiscriminationResults.oddEvenTransitEpochComparisonStatistic.significance;
        dvOutputMatrixTarget(counter, 93) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).binaryDiscriminationResults.shorterPeriodComparisonStatistic.significance;
        dvOutputMatrixTarget(counter, 94) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).binaryDiscriminationResults.longerPeriodComparisonStatistic.significance;
        
        dvOutputMatrixTarget(counter, 95) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.significance;
        
        dvOutputMatrixTarget(counter,114) = stNumber;
        
        dvOutputMatrixTarget(counter,115) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.fullConvergence;
        dvOutputMatrixTarget(counter,116) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelFitSnr;
        dvOutputMatrixTarget(counter,117) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.fullConvergence;
        dvOutputMatrixTarget(counter,118) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelFitSnr;
        dvOutputMatrixTarget(counter,119) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.fullConvergence;
        dvOutputMatrixTarget(counter,120) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelFitSnr;
        dvOutputMatrixTarget(counter,121) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.epochMjd;
        dvOutputMatrixTarget(counter,122) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.orbitalPeriod;
        
        dvOutputMatrixTarget(counter,123) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.mqKicCentroidOffsets.meanSkyOffset.value;
        dvOutputMatrixTarget(counter,124) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.mqKicCentroidOffsets.meanSkyOffset.uncertainty;
        dvOutputMatrixTarget(counter,125) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.mqControlCentroidOffsets.meanSkyOffset.value;
        dvOutputMatrixTarget(counter,126) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.mqControlCentroidOffsets.meanSkyOffset.uncertainty;
        dvOutputMatrixTarget(counter,127) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.pixelCorrelationMotionResults.mqKicCentroidOffsets.meanSkyOffset.value;
        dvOutputMatrixTarget(counter,128) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.pixelCorrelationMotionResults.mqKicCentroidOffsets.meanSkyOffset.uncertainty;
        dvOutputMatrixTarget(counter,129) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.pixelCorrelationMotionResults.mqControlCentroidOffsets.meanSkyOffset.value;
        dvOutputMatrixTarget(counter,130) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.pixelCorrelationMotionResults.mqControlCentroidOffsets.meanSkyOffset.uncertainty;
        
        dvOutputMatrixTarget(counter,131) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.mqKicCentroidOffsets.singleFitSkyOffset.value;
        dvOutputMatrixTarget(counter,132) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.mqKicCentroidOffsets.singleFitSkyOffset.uncertainty;
        dvOutputMatrixTarget(counter,133) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.mqControlCentroidOffsets.singleFitSkyOffset.value;
        dvOutputMatrixTarget(counter,134) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.mqControlCentroidOffsets.singleFitSkyOffset.uncertainty;
        dvOutputMatrixTarget(counter,135) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.pixelCorrelationMotionResults.mqKicCentroidOffsets.singleFitSkyOffset.value;
        dvOutputMatrixTarget(counter,136) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.pixelCorrelationMotionResults.mqKicCentroidOffsets.singleFitSkyOffset.uncertainty;
        dvOutputMatrixTarget(counter,137) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.pixelCorrelationMotionResults.mqControlCentroidOffsets.singleFitSkyOffset.value;
        dvOutputMatrixTarget(counter,138) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.pixelCorrelationMotionResults.mqControlCentroidOffsets.singleFitSkyOffset.uncertainty;
        
        dvOutputMatrixTarget(counter,141) = -1;
        dvOutputMatrixTarget(counter,142) = -1;
        dvOutputMatrixTarget(counter,143) = -1;
        dvOutputMatrixTarget(counter,144) = -1;
        dvOutputMatrixTarget(counter,145) = -1;
        dvOutputMatrixTarget(counter,146) = -1;
        dvOutputMatrixTarget(counter,147) = -1;
        dvOutputMatrixTarget(counter,148) = -1;
        dvOutputMatrixTarget(counter,149) = -1;
        dvOutputMatrixTarget(counter,150) = -1;
        dvOutputMatrixTarget(counter,177) = -1;
        dvOutputMatrixTarget(counter,178) = -1;
        dvOutputMatrixTarget(counter,179) = -1;
        dvOutputMatrixTarget(counter,180) = -1;
        dvOutputMatrixTarget(counter,181) = -1;
        nReducedParameterFits = length(dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).reducedParameterFits);
        if nReducedParameterFits>0
            if nReducedParameterFits<=5
                for j3=1:nReducedParameterFits
                    dvOutputMatrixTarget(counter,141+2*(j3-1)) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).reducedParameterFits(j3).fullConvergence;
                    dvOutputMatrixTarget(counter,142+2*(j3-1)) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).reducedParameterFits(j3).modelChiSquare;
                    dvOutputMatrixTarget(counter,177+  (j3-1)) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).reducedParameterFits(j3).modelDegreesOfFreedom;
                end
            else
                disp(['Warning: There are ' num2str(nReducedParameterFits) ' reduced parameter fit results for target ' num2str(j1) ' planet ' num2str(j2) '. Only first 5 fit results are saved in dvOutputMatrix.']);
            end
        end
        
        dvOutputMatrixTarget(counter,151) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.chiSquare1;
        dvOutputMatrixTarget(counter,152) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.chiSquareDof1;
        dvOutputMatrixTarget(counter,153) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.chiSquare2;
        dvOutputMatrixTarget(counter,154) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.chiSquareDof2;
        dvOutputMatrixTarget(counter,155) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.modelChiSquare2;
        dvOutputMatrixTarget(counter,156) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.modelChiSquareDof2;
        dvOutputMatrixTarget(counter,157) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.weakSecondaryStruct.maxMes;
        dvOutputMatrixTarget(counter,158) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.weakSecondaryStruct.maxMesPhaseInDays;
        
        dvOutputMatrixTarget(counter,159) = dvResultsStruct.targetResultsStruct(j1).radius.value;
        dvOutputMatrixTarget(counter,160) = dvResultsStruct.targetResultsStruct(j1).effectiveTemp.value;
        dvOutputMatrixTarget(counter,161) = dvResultsStruct.targetResultsStruct(j1).log10SurfaceGravity.value;
        dvOutputMatrixTarget(counter,162) = dvResultsStruct.targetResultsStruct(j1).log10Metallicity.value;
        
        dvOutputMatrixTarget(counter,163) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.summaryQualityMetric.numberOfAttempts;
        dvOutputMatrixTarget(counter,164) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.summaryQualityMetric.numberOfMetrics;
        dvOutputMatrixTarget(counter,165) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.summaryQualityMetric.numberOfGoodMetrics;
        dvOutputMatrixTarget(counter,166) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.summaryQualityMetric.fractionOfGoodMetrics;
        
        dvOutputMatrixTarget(counter,167) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.prfMotionResults.sourceOffsetArcSec.value;
        dvOutputMatrixTarget(counter,168) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.prfMotionResults.sourceOffsetArcSec.uncertainty;
        dvOutputMatrixTarget(counter,169) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.fluxWeightedMotionResults.sourceOffsetArcSec.value;
        dvOutputMatrixTarget(counter,170) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.fluxWeightedMotionResults.sourceOffsetArcSec.uncertainty;
        
        dvOutputMatrixTarget(counter,171) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.weakSecondaryStruct.minMes;
        dvOutputMatrixTarget(counter,172) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.weakSecondaryStruct.minMesPhaseInDays;
        dvOutputMatrixTarget(counter,173) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.weakSecondaryStruct.mesMad;
        
        dvOutputMatrixTarget(counter,174) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).allTransitsFit.modelDegreesOfFreedom;
        dvOutputMatrixTarget(counter,175) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).oddTransitsFit.modelDegreesOfFreedom;
        dvOutputMatrixTarget(counter,176) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).evenTransitsFit.modelDegreesOfFreedom;
        
        dvOutputMatrixTarget(counter,182) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.prfMotionResults.motionDetectionStatistic.value;
        dvOutputMatrixTarget(counter,183) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.fluxWeightedMotionResults.motionDetectionStatistic.value;
        dvOutputMatrixTarget(counter,184) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).binaryDiscriminationResults.oddEvenTransitDepthComparisonStatistic.value;
        dvOutputMatrixTarget(counter,185) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).binaryDiscriminationResults.oddEvenTransitEpochComparisonStatistic.value;
        dvOutputMatrixTarget(counter,186) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).binaryDiscriminationResults.shorterPeriodComparisonStatistic.value;
        dvOutputMatrixTarget(counter,187) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).binaryDiscriminationResults.longerPeriodComparisonStatistic.value;
        dvOutputMatrixTarget(counter,188) = dvResultsStruct.skyGroupId;
        
        targetKoiIdStr = dvResultsStruct.targetResultsStruct(j1).koiId;
        planetKoiIdStr = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).koiId;
        if length(targetKoiIdStr) > 1
            dvOutputMatrixTarget(counter,189) = str2num(targetKoiIdStr(2:end));
        else
            dvOutputMatrixTarget(counter,189) = -1;
        end
        if length(planetKoiIdStr) > 1
            dvOutputMatrixTarget(counter,190) = str2num(planetKoiIdStr(2:end));
        else
            dvOutputMatrixTarget(counter,190) = -1;
        end
        
        dvOutputMatrixTarget(counter,191) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).koiCorrelation;
        
        dvOutputMatrixTarget(counter,228) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).imageArtifactResults.rollingBandContaminationHistogram.transitFractions(1);
        dvOutputMatrixTarget(counter,229) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).imageArtifactResults.rollingBandContaminationHistogram.transitFractions(2);
        dvOutputMatrixTarget(counter,230) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).imageArtifactResults.rollingBandContaminationHistogram.transitFractions(3);
        dvOutputMatrixTarget(counter,231) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).imageArtifactResults.rollingBandContaminationHistogram.transitFractions(4);
        dvOutputMatrixTarget(counter,232) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).imageArtifactResults.rollingBandContaminationHistogram.transitFractions(5);
        
        dvOutputMatrixTarget(counter,233) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).secondaryEventResults.planetParameters.geometricAlbedo.value;
        dvOutputMatrixTarget(counter,234) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).secondaryEventResults.planetParameters.geometricAlbedo.uncertainty;
        dvOutputMatrixTarget(counter,235) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).secondaryEventResults.planetParameters.planetEffectiveTemp.value;
        dvOutputMatrixTarget(counter,236) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).secondaryEventResults.planetParameters.planetEffectiveTemp.uncertainty;
        dvOutputMatrixTarget(counter,237) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).secondaryEventResults.comparisonTests.albedoComparisonStatistic.value;
        dvOutputMatrixTarget(counter,238) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).secondaryEventResults.comparisonTests.albedoComparisonStatistic.significance;
        dvOutputMatrixTarget(counter,239) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).secondaryEventResults.comparisonTests.tempComparisonStatistic.value;
        dvOutputMatrixTarget(counter,240) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).secondaryEventResults.comparisonTests.tempComparisonStatistic.significance;
        
        dvOutputMatrixTarget(counter,250) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.summaryOverlapMetric.imageCount;
        dvOutputMatrixTarget(counter,251) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.summaryOverlapMetric.imageCountNoOverlap;
        dvOutputMatrixTarget(counter,252) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).centroidResults.differenceImageMotionResults.summaryOverlapMetric.imageCountFractionNoOverlap;
        
        dvOutputMatrixTarget(counter,253) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.chiSquareGof;
        dvOutputMatrixTarget(counter,254) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.chiSquareGofDof;
        dvOutputMatrixTarget(counter,255) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.modelChiSquareGof;
        dvOutputMatrixTarget(counter,256) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.modelChiSquareGofDof;
        dvOutputMatrixTarget(counter,257) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.trialTransitPulseDuration;
        
        dvOutputMatrixTarget(counter,258) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).ghostDiagnosticResults.coreApertureCorrelationStatistic.value;
        dvOutputMatrixTarget(counter,259) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).ghostDiagnosticResults.coreApertureCorrelationStatistic.significance;
        dvOutputMatrixTarget(counter,260) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).ghostDiagnosticResults.haloApertureCorrelationStatistic.value;
        dvOutputMatrixTarget(counter,261) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).ghostDiagnosticResults.haloApertureCorrelationStatistic.significance;
 
        dvOutputMatrixTarget(counter,262) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.fullConvergence;
        dvOutputMatrixTarget(counter,263) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelChiSquare;
        dvOutputMatrixTarget(counter,264) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelDegreesOfFreedom;
        dvOutputMatrixTarget(counter,265) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelFitSnr;
        lengthParameters = length(dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters);
        dvOutputMatrixTarget(counter,266) = lengthParameters;
        if (lengthParameters==16)
            dvOutputMatrixTarget(counter,267) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters(10).value;           % transitDepth
            dvOutputMatrixTarget(counter,268) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters(10).fitted;
            dvOutputMatrixTarget(counter,269) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters(11).value;           % orbitalPeriod
            dvOutputMatrixTarget(counter,270) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters(11).fitted;
            dvOutputMatrixTarget(counter,271) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters( 1).value;           % transitEpoch
            dvOutputMatrixTarget(counter,272) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters( 1).fitted;
            dvOutputMatrixTarget(counter,273) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters( 8).value;           % transitDuration
            dvOutputMatrixTarget(counter,274) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters( 8).fitted;
            dvOutputMatrixTarget(counter,275) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters( 9).value;           % transitIngressTimeHours
            dvOutputMatrixTarget(counter,276) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters( 9).fitted;
            dvOutputMatrixTarget(counter,277) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters( 6).value;           % minImpactParameter
            dvOutputMatrixTarget(counter,278) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters( 6).fitted;
            dvOutputMatrixTarget(counter,279) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters(12).value;           % ratioPlanetRadiusToStarRadius
            dvOutputMatrixTarget(counter,280) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters(12).fitted;
            dvOutputMatrixTarget(counter,281) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters(13).value;           % ratioSemiMajorAxisToStarRadius
            dvOutputMatrixTarget(counter,282) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).trapezoidalFit.modelParameters(13).fitted;
        else
            dvOutputMatrixTarget(counter,267) = -1;
            dvOutputMatrixTarget(counter,268) = -1;
            dvOutputMatrixTarget(counter,269) = -1;
            dvOutputMatrixTarget(counter,270) = -1;
            dvOutputMatrixTarget(counter,271) = -1;
            dvOutputMatrixTarget(counter,272) = -1;
            dvOutputMatrixTarget(counter,273) = -1;
            dvOutputMatrixTarget(counter,274) = -1;
            dvOutputMatrixTarget(counter,275) = -1;
            dvOutputMatrixTarget(counter,276) = -1;
            dvOutputMatrixTarget(counter,277) = -1;
            dvOutputMatrixTarget(counter,278) = -1;
            dvOutputMatrixTarget(counter,279) = -1;
            dvOutputMatrixTarget(counter,280) = -1;
            dvOutputMatrixTarget(counter,281) = -1;
            dvOutputMatrixTarget(counter,282) = -1;
        end
        
        dvOutputMatrixTarget(counter,283) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.expectedTransitCount;
        dvOutputMatrixTarget(counter,284) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.observedTransitCount;
        dvOutputMatrixTarget(counter,285) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.thresholdForDesiredPfa;
        dvOutputMatrixTarget(counter,286) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.bootstrapThresholdForDesiredPfa;
        dvOutputMatrixTarget(counter,287) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.weakSecondaryStruct.medianMes;
        dvOutputMatrixTarget(counter,288) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.weakSecondaryStruct.nValidPhases;
        dvOutputMatrixTarget(counter,289) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.weakSecondaryStruct.robustStatistic;
        dvOutputMatrixTarget(counter,290) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.weakSecondaryStruct.depthPpm.value;
        dvOutputMatrixTarget(counter,291) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.weakSecondaryStruct.depthPpm.uncertainty;
        dvOutputMatrixTarget(counter,292) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.bootstrapMesMean;
        dvOutputMatrixTarget(counter,293) = dvResultsStruct.targetResultsStruct(j1).planetResultsStruct(j2).planetCandidate.bootstrapMesStd;
        
    end
    
end

% Save dvOutputMatrixTarget and dvOutputMatrixColumns in the file
eval(['save ' dvDataFileName ' dvOutputMatrixTarget dvOutputMatrixColumns']);
