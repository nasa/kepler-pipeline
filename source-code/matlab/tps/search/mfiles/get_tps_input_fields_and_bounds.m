function fieldsAndBounds = get_tps_input_fields_and_bounds( structName )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function fieldsAndBounds = get_tps_input_fields_and_bounds( structName )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function loads the fieldsAndBounds for the structure specified in
% structName
% 
% Inputs: structName - a string specifying the structure to return the
%                      fields and bounds for
% Outputs: fieldsAndBounds - an output cell array containing the fields and
%                            the bounds in the usual format
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

% determine and set appropriate fieldsAndBounds

switch structName
    case 'inputsStruct'
        
        fieldsAndBounds = cell(8,4);
        fieldsAndBounds(1,:)  = { 'tpsModuleParameters'; []; []; []};
        fieldsAndBounds(2,:)  = { 'gapFillParameters'; []; []; []};
        fieldsAndBounds(3,:)  = { 'harmonicsIdentificationParameters'; []; []; []};
        fieldsAndBounds(4,:)  = { 'tpsTargets'; []; []; []};
        fieldsAndBounds(5,:)  = { 'rollTimeModel'; []; []; []};
        fieldsAndBounds(6,:)  = { 'cadenceTimes'; []; []; []};
        fieldsAndBounds(7,:)  = { 'taskTimeoutSecs' ; '>0' ; '<=1e6' ; []} ;
        fieldsAndBounds(8,:)  = { 'tasksPerCore' ; '>0' ; '<=10' ; []} ;
        
    case 'tpsModuleParametersLite'
        
        fieldsAndBounds = cell(19,4);
        fieldsAndBounds(1,:)  = { 'debugLevel'; []; []; '[-1:3]'''};
        fieldsAndBounds(2,:)  = { 'requiredTrialTransitPulseInHours'; '> 0'; '<= 72'; []};
        fieldsAndBounds(3,:)  = { 'searchPeriodStepControlFactor'; []; []; []};
        fieldsAndBounds(4,:)  = { 'varianceWindowLengthMultiplier'; '> 0'; '<=100'; []};
        fieldsAndBounds(5,:)  = { 'minimumSearchPeriodInDays'; []; []; []};
        fieldsAndBounds(6,:)  = { 'maximumSearchPeriodInDays'; []; []; []};
        fieldsAndBounds(7,:)  = { 'searchTransitThreshold'; []; []; [] }; % in units of sigma
        fieldsAndBounds(8,:)  = { 'waveletFamily'; []; []; {'haar'; 'daub'; 'morlet'; 'coiflet'; 'meyer'; 'gauss'; 'mexhat'}};
        fieldsAndBounds(9,:)  = { 'waveletFilterLength'; []; []; '[2:2:128]'''};
        fieldsAndBounds(10,:)  = { 'tpsLiteEnabled'; []; []; [true, false]};
        fieldsAndBounds(11,:)  = { 'superResolutionFactor'; []; []; []};
        fieldsAndBounds(12,:)  = { 'minTrialTransitPulseInHours' ; '>=-1' ; '<=100'; []} ;
        fieldsAndBounds(13,:)  = { 'maxTrialTransitPulseInHours' ; '>=-1' ; '<=100'; []} ;
        fieldsAndBounds(14,:)  = { 'searchTrialTransitPulseDurationStepControlFactor' ; '> 0' ; '< 0.95'; []} ;
        fieldsAndBounds(15,:)  = { 'maxFoldingsInPeriodSearch' ; [] ; []; []} ;
        fieldsAndBounds(16,:)  = { 'performQuarterStitching' ; [] ; []; [true, false]} ;
        fieldsAndBounds(17,:)  = { 'deweightReactionWheelZeroCrossingCadences' ; [] ; []; [true, false]} ;
        fieldsAndBounds(18,:)  = { 'usePolyFitTransitModel' ; [] ; []; [true, false]} ;
        fieldsAndBounds(19,:)  = { 'noiseEstimationByQuarterEnabled' ; [] ; []; [true, false]} ;
        
    case 'tpsModuleParameters'
        
        fieldsAndBounds = cell(47,4);
        fieldsAndBounds(1,:)  = { 'debugLevel'; []; []; '[-1:3]'''};
        fieldsAndBounds(2,:)  = { 'requiredTrialTransitPulseInHours'; '> 0'; '<= 72'; []};
        fieldsAndBounds(3,:)  = { 'searchPeriodStepControlFactor'; '> 0'; '< 1'; []};
        fieldsAndBounds(4,:)  = { 'varianceWindowLengthMultiplier'; '> 0'; '<=100'; []};
        fieldsAndBounds(5,:)  = { 'minimumSearchPeriodInDays'; '> 0'; '<= 3650'; []};
        fieldsAndBounds(6,:)  = { 'maximumSearchPeriodInDays'; '>= -1'; '<= 3650'; []};
        fieldsAndBounds(7,:)  = { 'searchTransitThreshold'; '>=0'; '<=8'; []}; % in units of sigma
        fieldsAndBounds(8,:)  = { 'waveletFamily'; []; []; {'haar'; 'daub'; 'morlet'; 'coiflet'; 'meyer'; 'gauss'; 'mexhat'}};
        fieldsAndBounds(9,:)  = { 'waveletFilterLength'; []; []; '[2:2:128]'''};
        fieldsAndBounds(10,:)  = { 'tpsLiteEnabled'; []; []; [true, false]};
        fieldsAndBounds(11,:)  = { 'superResolutionFactor'; []; [];'[1:10]'''};
        fieldsAndBounds(12,:)  = { 'deemphasizePeriodAfterSafeModeInDays'; '>=0'; '<=10';[]};
        fieldsAndBounds(13,:)  = { 'deemphasizePeriodAfterTweakInCadences'; '>=0'; '<=100';[]};
        fieldsAndBounds(14,:)  = { 'minTrialTransitPulseInHours' ; '>=-1' ; '<=100'; []} ;
        fieldsAndBounds(15,:)  = { 'maxTrialTransitPulseInHours' ; '>=-1' ; '<=100'; []} ;
        fieldsAndBounds(16,:)  = { 'searchTrialTransitPulseDurationStepControlFactor' ; '> 0' ; '< 0.95'; []} ;
        fieldsAndBounds(17,:)  = { 'maxFoldingsInPeriodSearch' ; '>= -1' ; '<= 1e6'; []} ;
        fieldsAndBounds(18,:)  = { 'performQuarterStitching' ; [] ; []; [true, false]} ;
        fieldsAndBounds(19,:)  = { 'pixelSensitivityDropoutThreshold' ; '>=5' ; [] ; []} ;
        fieldsAndBounds(20,:)  = { 'clusterProximity' ; '>=0' ; '<=50'; []} ;
        fieldsAndBounds(21,:)  = { 'medfiltWindowLengthDays' ; '>=0.5' ; '<=10'; []} ;
        fieldsAndBounds(22,:)  = { 'medfiltStandoffDays' ; '>=1' ; '<=5'; []} ;
        fieldsAndBounds(23,:)  = { 'robustStatisticThreshold' ; '>=-1' ; '<=8' ; []} ; % in units of sigma
        fieldsAndBounds(24,:)  = { 'robustWeightGappingThreshold' ; '>=0' ; '<=100' ; []} ;
        fieldsAndBounds(25,:)  = { 'robustStatisticConvergenceTolerance' ; '>=0' ; '<=1' ; []} ;
        fieldsAndBounds(26,:)  = { 'minSesInMesCount' ; [] ; [] ; '[2:10]'''} ;
        fieldsAndBounds(27,:)  = { 'maxDutyCycle' ; '>0' ; '<=0.5' ; []} ;
        fieldsAndBounds(28,:)  = { 'applyAttitudeTweakCorrection' ; [] ; [] ; [true,false]} ;
        fieldsAndBounds(29,:)  = { 'chiSquare2Threshold' ; '>=-1' ; '<=1000' ; []} ;
        fieldsAndBounds(30,:)  = { 'chiSquareGofThreshold' ; '>=-1' ; '<=1000' ; []} ;
        fieldsAndBounds(31,:)  = { 'maxRemovedFeatureCount' ; '>=0' ; '<=1000' ; []} ;
        fieldsAndBounds(32,:)  = { 'deweightReactionWheelZeroCrossingCadences' ; [] ; [] ; [true,false]} ;
        fieldsAndBounds(33,:)  = { 'maxFoldingLoopCount' ; ['>0'] ; [] ; [] } ;
        fieldsAndBounds(34,:)  = { 'weakSecondaryPeakRangeMultiplier' ; '>=0' ; '<=100' ; []} ;
        fieldsAndBounds(35,:)  = { 'positiveOutlierHaircutEnabled'; [] ; [] ; [true,false]} ;
        fieldsAndBounds(36,:)  = { 'looperMaxWallTimeFraction'; '>0' ; '<=1' ; []} ;
        fieldsAndBounds(37,:)  = { 'usePolyFitTransitModel' ; [] ; []; [true, false]} ;
        fieldsAndBounds(38,:)  = { 'maxPeriodParameter' ; '>0' ; '<=0.5' ; []} ;
        fieldsAndBounds(39,:)  = { 'mesHistogramMinMes' ; '>=-200' ; '<=0' ; []} ;
        fieldsAndBounds(40,:)  = { 'mesHistogramMaxMes' ; '>=0' ; '<=200' ; []} ;
        fieldsAndBounds(41,:)  = { 'mesHistogramBinSize' ; '>0' ; '<=10' ; []} ;
        fieldsAndBounds(42,:)  = { 'performWeakSecondaryTest' ; []; []; [true,false]} ;
        fieldsAndBounds(43,:)  = { 'bootstrapGaussianEquivalentThreshold' ; '>=-1' ; '<=1000' ; []} ;
        fieldsAndBounds(44,:)  = { 'bootstrapLowMesCutoff' ; '>=-1' ; '<=100' ; []} ;
        fieldsAndBounds(45,:)  = { 'bootstrapThresholdReductionFactor' ; '>=-1' ; '<=1000' ; []} ;
        fieldsAndBounds(46,:)  = { 'noiseEstimationByQuarterEnabled'; [] ; [] ; [true,false]} ;
        fieldsAndBounds(47,:)  = { 'positiveOutlierHaircutThreshold'; '>=-1' ; '<=1000' ; []} ;
        
    case 'gapFillParameters'
        
        fieldsAndBounds = cell(11,4);
        fieldsAndBounds(1,:)  = { 'madXFactor'; '> 0'; '<= 100'; []};
        fieldsAndBounds(2,:)  = { 'maxGiantTransitDurationInHours'; '> 0' ; '< 24*5'; []};
        fieldsAndBounds(3,:)  = { 'maxDetrendPolyOrder'; []; []; '[1:25]'''}; 
        fieldsAndBounds(4,:)  = { 'maxArOrderLimit'; []; []; '[1:25]'''}; 
        fieldsAndBounds(5,:)  = { 'maxCorrelationWindowXFactor'; '> 0'; '<= 25'; []};
        fieldsAndBounds(6,:)  = { 'gapFillModeIsAddBackPredictionError'; []; []; [true, false]};
        fieldsAndBounds(7,:)  = { 'waveletFamily'; []; []; {'haar'; 'daub'; 'morlet'; 'coiflet'; 'meyer'; 'gauss'; 'mexhat'}};
        fieldsAndBounds(8,:)  = { 'waveletFilterLength'; []; []; '[2:2:128]'''};
        fieldsAndBounds(9,:)  = { 'giantTransitPolyFitChunkLengthInHours'; '> 0'; '< 24*30'; []};
        fieldsAndBounds(10,:)  = { 'removeEclipsingBinariesOnList'; [] ; []; [true, false]} ;
        fieldsAndBounds(11,:)  = { 'arAutoCorrelationThreshold'; '>= 0'; '<= 1'; []};
        
    case 'harmonicsIdentificationParameters'
        
        fieldsAndBounds = cell(8,4) ;
        fieldsAndBounds(1,:) = { 'medianWindowLengthForTimeSeriesSmoothing', '>=1', '<=10000', [] } ;
        fieldsAndBounds(2,:) = { 'medianWindowLengthForPeriodogramSmoothing', '>=1', '<=10000', [] } ;
        fieldsAndBounds(3,:) = { 'movingAverageWindowLength', '>=1', '<=10000', [] } ;
        fieldsAndBounds(4,:) = { 'falseDetectionProbabilityForTimeSeries', '>=0','<=1', [] } ;
        fieldsAndBounds(5,:) = { 'minHarmonicSeparationInBins', '>=1', '<=10000', [] } ;
        fieldsAndBounds(6,:) = { 'maxHarmonicComponents', '>=0', '<=10000', [] } ;
        fieldsAndBounds(7,:) = { 'timeOutInMinutes', '>=0', '<=10000', [] } ;
        fieldsAndBounds(8,:) = { 'retainFrequencyCombsEnabled', [], [], [true, false] } ;
        
    case 'bootstrapParameters'
        
        fieldsAndBounds = cell(18,4);
        fieldsAndBounds(1,:)  = { 'skipCount'; '> 0'; '< 1000'; []};                         
        fieldsAndBounds(2,:)  = { 'autoSkipCountEnabled'; []; []; [true; false]};
        fieldsAndBounds(3,:)  = { 'maxIterations'; '>= 1e3'; '<= 1e12'; []};                 
        fieldsAndBounds(4,:)  = { 'maxNumberBins'; '>= 10'; '<= 1e8'; []};                  
        fieldsAndBounds(5,:)  = { 'histogramBinWidth'; '> 0'; '< 1'; []};                    
        fieldsAndBounds(6,:)  = { 'binsBelowSearchTransitThreshold'; '>= 0'; '< 10'; []};    
        fieldsAndBounds(7,:)  = { 'upperLimitFactor'; '>=1'; '<= 100'; []};                  
        fieldsAndBounds(8,:)  = { 'useTceTrialPulseOnly'; []; []; [true; false]};
        fieldsAndBounds(9,:)  = { 'maxAllowedMes'; '>=-1'; '<= 1e12'; []};       
        fieldsAndBounds(10,:) = { 'maxAllowedTransitCount'; '>=-1'; '<= 1e12'; []};       
        fieldsAndBounds(11,:) = { 'convolutionMethodEnabled'; []; []; [true; false]};
        fieldsAndBounds(12,:) = { 'deemphasizeQuartersWithoutTransits'; []; []; [true; false]};
        fieldsAndBounds(13,:) = { 'sesZeroCrossingWidthDays'; '>=0'; '<=50'; []};   
        fieldsAndBounds(14,:) = { 'sesZeroCrossingDensityFactor'; '>0'; '<=1000'; []};   
        fieldsAndBounds(15,:) = { 'nSesPeaksToRemove'; '>=0'; '<=50'; []};   
        fieldsAndBounds(16,:) = { 'sesPeakRemovalThreshold'; '>=0'; '<=1e12'; []};   
        fieldsAndBounds(17,:) = { 'sesPeakRemovalFloor'; '>=-1'; '<=10'; []};   
        fieldsAndBounds(18,:) = { 'bootstrapResolutionFactor'; '>=1'; '<=131072'; []};   
        
    case 'tpsTargetsGross'
        
        fieldsAndBounds = cell(9,4);
        fieldsAndBounds(1,:)  = { 'keplerId'; '>= 0'; [] ; []};
        fieldsAndBounds(2,:)  = { 'diagnostics'; []; []; []};
        fieldsAndBounds(3,:)  = { 'fluxValue'; []; []; []}; 
        fieldsAndBounds(4,:)  = { 'uncertainty'; []; []; []};
        fieldsAndBounds(5,:)  = { 'gapIndices'; []; []; []};
        fieldsAndBounds(6,:)  = { 'fillIndices';[]; []; []};
        fieldsAndBounds(7,:)  = { 'outlierIndices'; []; []; []};
        fieldsAndBounds(8,:)  = { 'discontinuityIndices'; []; []; []};
        fieldsAndBounds(9,:)  = { 'quarterGapIndicators' ; [] ; [] ; [] } ;
        
    case 'tpsTargetsFine'
        
        fieldsAndBounds = cell(8,4);
        fieldsAndBounds(1,:)  = { 'keplerId'; '>= 0'; [] ; []};
        fieldsAndBounds(2,:)  = { 'fluxValue'; '> -1e6'; ' < 1e12'; []};  
        fieldsAndBounds(3,:)  = { 'uncertainty'; '>= -1'; ' < 1e12'; []};
        fieldsAndBounds(4,:)  = { 'gapIndices'; [];[]; []};
        fieldsAndBounds(5,:)  = { 'fillIndices';[]; [] ; []};
        fieldsAndBounds(6,:)  = { 'outlierIndices'; [];[] ; []};
        fieldsAndBounds(7,:)  = { 'discontinuityIndices'; [];[] ; []};
        fieldsAndBounds(8,:)  = { 'quarterGapIndicators' ; [] ; [] ; [true, false] } ;
        
    case 'rollTimeModel'
        
        fieldsAndBounds = cell(6,4);
        fieldsAndBounds(1,:)  = { 'mjds'; []; []; []};
        fieldsAndBounds(2,:)  = { 'seasons'; []; []; []};
        fieldsAndBounds(3,:)  = { 'rollOffsets'; []; []; []};
        fieldsAndBounds(4,:)  = { 'fovCenterRas'; []; []; []};
        fieldsAndBounds(5,:)  = { 'fovCenterDeclinations'; []; []; []};
        fieldsAndBounds(6,:)  = { 'fovCenterRolls'; []; []; []};
        
    case 'cadenceTimes'
        
        fieldsAndBounds = cell(15,4);
        fieldsAndBounds(1,:)  = { 'startTimestamps'; '> 54500'; '< 70000'; []}; % 2/4/2008 to 7/13/2050
        fieldsAndBounds(2,:)  = { 'midTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
        fieldsAndBounds(3,:)  = { 'endTimestamps'; '> 54500'; '< 70000'; []};   % 2/4/2008 to 7/13/2050
        fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; [true; false]};
        fieldsAndBounds(5,:)  = { 'requantEnabled'; []; []; [true; false]};
        fieldsAndBounds(6,:)  = { 'cadenceNumbers'; '>= 0'; '< 2e7'; []};
        fieldsAndBounds(7,:)  = { 'isSefiAcc'; []; []; [true; false]};
        fieldsAndBounds(8,:)  = { 'isSefiCad'; []; []; [true; false]};
        fieldsAndBounds(9,:)  = { 'isLdeOos'; []; []; [true; false]};
        fieldsAndBounds(10,:) = { 'isFinePnt'; []; []; [true; false]};
        fieldsAndBounds(11,:) = { 'isMmntmDmp'; []; []; [true; false]};
        fieldsAndBounds(12,:) = { 'isLdeParEr'; []; []; [true; false]};
        fieldsAndBounds(13,:) = { 'isScrcErr'; []; []; [true; false]};
        fieldsAndBounds(14,:) = { 'quarters' ; '>=-1'; '<=100' ; [] };
        fieldsAndBounds(15,:) = { 'lcTargetTableIds' ; '>=0'; '<=256' ; [] };
        
        
    case 'dataAnomalyFlags'
        
        fieldsAndBounds = cell(6,4);
        fieldsAndBounds(1,:)  = { 'attitudeTweakIndicators';   []; []; [true ; false]}; 
        fieldsAndBounds(2,:)  = { 'safeModeIndicators';        []; []; [true ; false]};   
        fieldsAndBounds(3,:)  = { 'earthPointIndicators';      []; []; [true ; false]};   
        fieldsAndBounds(4,:)  = { 'coarsePointIndicators';     []; []; [true ; false]};
        fieldsAndBounds(5,:)  = { 'argabrighteningIndicators'; []; []; [true ; false]};
        fieldsAndBounds(6,:)  = { 'excludeIndicators';         []; []; [true ; false]};
        
    otherwise
        
        % throw an error if this function is called with an unkown string
        error('TPS:getTpsFieldsAndBounds', 'Unkown input argument - can''t proceed ...') ;
        
end


return
