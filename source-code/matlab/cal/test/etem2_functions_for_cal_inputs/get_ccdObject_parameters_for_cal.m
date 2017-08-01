function s = get_ccdObject_parameters_for_cal(ccdObject)
%
% function to extract parameters used by etem (currently only parameters 
% relevant to CAL are extracted for inputs to avoid discrepancies in FC models
% and config map parameters)
%
% In each etem2 output directory (run*/), this function loads
% ccdObject.mat, which contains the following information:
%
% ccdObject =
%
%                              dvaMotionData: []
%                           jitterMotionData: []
%                             motionDataList: []
%                  visibleBackgroundDataList: []
%                    pixelBackgroundDataList: []
%                          flatFieldDataList: []
%                             blackLevelData: []
%                        pixelEffectDataList: []
%                         electronsToAduData: []
%                     wellDepthVariationData: []
%                         pixelNoiseDataList: []
%                  electronicsEffectDataList: []
%                          readNoiseDataList: []
%                           ccdPlaneDataList: []
%                              cosmicRayData: []
%                   targetScienceManagerData: []
%                                  className: 'ccdClass'
%                            dvaMotionObject: [1x1 struct]
%                         jitterMotionObject: [1x1 struct]
%                           motionObjectList: []
%                visibleBackgroundObjectList: []
%                  pixelBackgroundObjectList: {[1x1 struct]}
%                        flatFieldObjectList: []
%                       electronsToAduObject: [1x1 struct]
%                           blackLevelObject: [1x1 struct]
%                   wellDepthVariationObject: [1x1 struct]
%                      pixelEffectObjectList: []
%                       pixelNoiseObjectList: {[1x1 struct]}
%                electronicsEffectObjectList: []
%                        readNoiseObjectList: {[1x1 struct]}
%                         ccdPlaneObjectList: [1x1 struct]
%                            cosmicRayObject: []
%                          cadenceDataObject: [1x1 struct]
%                        requantizationTable: [65536x1 double]
%                  requantTableLcFixedOffset: 419405
%                  requantTableScFixedOffset: 419405
%                    requantizationMeanBlack: 722
%                       targetDefinitionSpec: [1x1 struct]
%                     apertureDefinitionSpec: [1x1 struct]
%                             dataBufferSize: 1000000
%                              motionGridRow: [5x5 double]
%                              motionGridCol: [5x5 double]
%                          badFitPixelStruct: [1x18 struct]
%                 targetScienceManagerObject: [1x1 struct]
%                           ccdImageFilename: [1x90 char]
%                                poiFilename: [1x98 char]
%                      ccdTimeSeriesFilename: [1x95 char]
%                  ccdTimeSeriesNoCrFilename: [1x99 char]
%                  badFitPixelStructFilename: [1x99 char]
%                         ssrOutputDirectory: 'ssrOutput'
%                 apertureDefinitionFilename: [1x111 char]
%                   targetDefinitionFilename: [1x109 char]
%       backgroundApertureDefinitionFilename: [1x115 char]
%         backgroundTargetDefinitionFilename: [1x113 char]
%     referencePixelTargetDefinitionFilename: [1x115 char]
%                     scienceCadenceFilename: [1x110 char]
%                 scienceCadenceNoCrFilename: [1x114 char]
%                   quantizedCadenceFilename: [1x112 char]
%               quantizedCadenceNoCrFilename: [1x116 char]
%                 requantizedCadenceFilename: [1x114 char]
%             requantizedCadenceNoCrFilename: [1x118 char]
%                                ffiFilename: [1x99 char]
%                             refPixFilename: [1x107 char]
%                         refPixNoCrFilename: [1x111 char]
%                             runParamsClass: [1x1 struct]
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

%clear classes
%load ccdObject.mat

etem2_outputDir         = ccdObject.runParamsClass.etemInformation.outputDirectory;
% ex: ./cal_2DblkOn_starsOn_smearOn_darkOn_readQuantShotNoiseOn_dir/run_long_m7o3s1
s.etem2_outputDir       = etem2_outputDir;

etem2_outputLocation    = ccdObject.runParamsClass.etemInformation.etem2OutputLocation;
% ex: ./cal_2DblkOn_starsOn_smearOn_darkOn_readQuantShotNoiseOn_dir
s.etem2_outputLocation  = etem2_outputLocation;

%--------------------------------------------------------------------------
% cadence information
%--------------------------------------------------------------------------
etem2_numCadences   = ccdObject.runParamsClass.simulationData.runDuration;   % 100
s.etem2_numCadences = etem2_numCadences;

etem2_startMjd      = ccdObject.runParamsClass.simulationData.runStartTime;  % 54922
s.etem2_startMjd    = etem2_startMjd;

etem2_endMjd        = ccdObject.runParamsClass.simulationData.runEndTime;  % 5.4924e+04
s.etem2_endMjd      = etem2_endMjd;

etem2_cadencesPerDay    = ccdObject.runParamsClass.keplerData.cadencesPerDay;  %    48.9389
s.etem2_cadencesPerDay  = etem2_cadencesPerDay;


%--------------------------------------------------------------------------
% nonlinearity flag and gain
%--------------------------------------------------------------------------
if strcmpi(ccdObject.electronsToAduObject.className, 'nonlinearEtoAduClass')

    etem2_nonlinearityEnabled = true;
    s.etem2_nonlinearityEnabled = etem2_nonlinearityEnabled;

    etem2_gain = ccdObject.electronsToAduObject.gain;    
    s.etem2_gain    = etem2_gain;

    etem2_nonlinCoeffts = ccdObject.electronsToAduObject.polyStruct.coeffs;
    s.etem2_nonlinCoeffts = etem2_nonlinCoeffts;
    
else  % linearEtoAduClass

    etem2_nonlinearityEnabled = false;
    s.etem2_nonlinearityEnabled = etem2_nonlinearityEnabled;

    etem2_gain      = ccdObject.electronsToAduObject.electronsPerADU; % 116 or retrieved
    s.etem2_gain    = etem2_gain;
end



%--------------------------------------------------------------------------
% read noise in electrons and adu
%--------------------------------------------------------------------------
if ~isempty(ccdObject.readNoiseObjectList)

    etem2_readNoiseInElectrons      = ccdObject.readNoiseObjectList{1}.readNoise;     % 89.668 or retrieved
    s.etem2_readNoiseInElectrons    = etem2_readNoiseInElectrons;

    etem2_readNoiseInADU        = etem2_readNoiseInElectrons ./ etem2_gain;
    s.etem2_readNoiseInADU      = etem2_readNoiseInADU;
end

%--------------------------------------------------------------------------
% mean black and fixed offset
%--------------------------------------------------------------------------
etem2_meanBlack     = ccdObject.requantizationMeanBlack;   % scalar, 722
s.etem2_meanBlack   = etem2_meanBlack;

etem2_fixedOffsetLC     = ccdObject.requantTableLcFixedOffset;   % 419405
s.etem2_fixedOffsetLC   = etem2_fixedOffsetLC;

etem2_fixedOffsetSC     = ccdObject.requantTableScFixedOffset;   % 419405
s.etem2_fixedOffsetSC   = etem2_fixedOffsetSC;


%--------------------------------------------------------------------------
% requant table and table ID
%--------------------------------------------------------------------------
etem2_requantTableId    = ccdObject.runParamsClass.keplerData.requantizationTableId;  % 175
s.etem2_requantTableId  = etem2_requantTableId;

etem2_requantTable      = ccdObject.requantizationTable;   % 65536 x 1
s.etem2_requantTable    = etem2_requantTable;

%--------------------------------------------------------------------------
% 2D black enabled flag and values
%--------------------------------------------------------------------------
etem2_2dBlackEnabled    = ~isempty(ccdObject.runParamsClass.keplerData.useMeanBias);
s.etem2_2dBlackEnabled  = etem2_2dBlackEnabled;

if etem2_2dBlackEnabled
    etem2_2DBlackArrayInAdu     = ccdObject.blackLevelObject.blackArrayAdu;   % [1070x1132 double]
    s.etem2_2DBlackArrayInAdu   = etem2_2DBlackArrayInAdu;
end



%--------------------------------------------------------------------------
% undershoot enabled flag
%--------------------------------------------------------------------------
etem2_undershootEnabled     = ~isempty(ccdObject.electronicsEffectObjectList);
s.etem2_undershootEnabled   = etem2_undershootEnabled;

if (etem2_undershootEnabled)
    etem2_undershootCoeffs = ccdObject.electronicsEffectObjectList{1}.filterCoeff;
    s.etem2_undershootCoeffs = etem2_undershootCoeffs;
end

%--------------------------------------------------------------------------
% shot noise enabled
%--------------------------------------------------------------------------
etem2_shotNoiseEnabled      = ~isempty(ccdObject.pixelNoiseObjectList);
s.etem2_shotNoiseEnabled    = etem2_shotNoiseEnabled;

%--------------------------------------------------------------------------
% smear enabled flag
%--------------------------------------------------------------------------
etem2_smearEnabled      = ~ccdObject.runParamsClass.keplerData.supressSmear;
s.etem2_smearEnabled    = etem2_smearEnabled;


%--------------------------------------------------------------------------
% dark current enabled flag, and value if enabled
%--------------------------------------------------------------------------
etem2_darkCurrentEnabled    = ~isempty(ccdObject.pixelBackgroundObjectList);
s.etem2_darkCurrentEnabled  = etem2_darkCurrentEnabled;

if etem2_darkCurrentEnabled
    etem2_darkCurrentValue  = ccdObject.pixelBackgroundObjectList{1}.darkCurrentValue;
else
    etem2_darkCurrentValue  = 0;
end
s.etem2_darkCurrentValue    = etem2_darkCurrentValue;


%--------------------------------------------------------------------------
% flat field enabled flag
%--------------------------------------------------------------------------
etem2_flatFieldEnabled      = ~isempty(ccdObject.flatFieldObjectList);
s.etem2_flatFieldEnabled    = etem2_flatFieldEnabled;

if (etem2_flatFieldEnabled) 
    etem2_flatField = ccdObject.flatFieldObjectList{1}.flat;  % 1024 x 1100;
    s.etem2_flatField = etem2_flatField;
end

%--------------------------------------------------------------------------
% cosmic ray enabled flag
%--------------------------------------------------------------------------
etem2_cosmicRayEnabled      = ~isempty(ccdObject.cosmicRayObject);
s.etem2_cosmicRayEnabled    = etem2_cosmicRayEnabled;


%--------------------------------------------------------------------------
% suppress motion flag
%--------------------------------------------------------------------------
etem2_suppressMotionFlag    = ccdObject.runParamsClass.keplerData.supressAllMotion;
s.etem2_suppressMotionFlag  = etem2_suppressMotionFlag;


%--------------------------------------------------------------------------
% suppress stars flag
%--------------------------------------------------------------------------
etem2_suppressStarsFlag     = ccdObject.runParamsClass.keplerData.supressAllStars;
s.etem2_suppressStarsFlag   = etem2_suppressStarsFlag;


%--------------------------------------------------------------------------
% quantization noise enabled flag
%--------------------------------------------------------------------------
etem2_quantNoiseEnabled     = ~(ccdObject.runParamsClass.keplerData.supressQuantizationNoise);
s.etem2_quantNoiseEnabled   = etem2_quantNoiseEnabled;


%save etem2_used_parameters_struct.mat s



return;




