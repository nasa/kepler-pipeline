function returnObject = get(runParamsObject, propName)
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

switch propName
    case 'className' 
        returnObject = dvaMotionObject.className;

    % etemInformation
    case 'etem2Location' 
        returnObject = runParamsObject.etemInformation.etem2Location;
    case 'etem2OutputLocation' 
        returnObject = runParamsObject.etemInformation.etem2OutputLocation;
    case 'outputDirectory' 
        returnObject = runParamsObject.etemInformation.outputDirectory;
        
    % simulationData
    case 'numberOfTargetsRequested'
        returnObject = runParamsObject.simulationData.numberOfTargetsRequested;
    case 'runStartDate'
        % text date string
        returnObject = runParamsObject.simulationData.runStartDate;
    case 'runDurationDays'
        returnObject = runParamsObject.simulationData.runDurationDays;
    case 'runDurationCadences'
        returnObject = runParamsObject.simulationData.runDurationCadences;
    case 'runStartTime'
        % time in modified julian days
        returnObject = runParamsObject.simulationData.runStartTime;
    case 'runEndTime'
        % time in modified julian days
        returnObject = runParamsObject.simulationData.runEndTime;
	case 'firstExposureStartTime' 
        returnObject = runParamsObject.simulationData.firstExposureStartTime;
    case 'initialScienceRun'
        returnObject = runParamsObject.simulationData.initialScienceRun;
    case 'firstRollDate'
        returnObject = runParamsObject.simulationData.firstRollDate;
    case 'moduleNumber'
        returnObject = runParamsObject.simulationData.moduleNumber;
    case 'outputNumber'
        returnObject = runParamsObject.simulationData.outputNumber;
    case 'observingSeason'
        returnObject = runParamsObject.simulationData.observingSeason;
    case 'cadenceType'
        returnObject = runParamsObject.simulationData.cadenceType;
    case 'endian'
        returnObject = runParamsObject.simulationData.endian;
    case 'cleanOutput' 
        returnObject = runParamsObject.simulationData.cleanOutput;
        
    % general data about Kepler
    case 'orbitFile'
        returnObject = runParamsObject.keplerData.orbitFile;
	case 'boresiteDec' 
        returnObject = runParamsObject.keplerData.boresiteDec;
	case 'boresiteRa' 
        returnObject = runParamsObject.keplerData.boresiteRa;
	case 'fcConstants' 
        returnObject = runParamsObject.keplerData.fcConstants;

    % ccdCharacteristics
	case 'pixelWidth' 
        returnObject = runParamsObject.keplerData.pixelWidth;
	case 'pixelAngle' 
        returnObject = runParamsObject.keplerData.pixelAngle;
	case 'intrapixWavelength' 
        returnObject = runParamsObject.keplerData.intrapixWavelength;
        
    case 'numVisibleRows'
        returnObject = runParamsObject.keplerData.numVisibleRows;
    case 'numVisibleCols'
        returnObject = runParamsObject.keplerData.numVisibleCols;
    case 'numMaskedSmear'
        returnObject = runParamsObject.keplerData.numMaskedSmear;
    case 'numVirtualSmear'
        returnObject = runParamsObject.keplerData.numVirtualSmear;
    case 'numLeadingBlack'
        returnObject = runParamsObject.keplerData.numLeadingBlack;
    case 'numTrailingBlack'
        returnObject = runParamsObject.keplerData.numTrailingBlack;
    case 'numCcdRows'
        returnObject = runParamsObject.keplerData.numCcdRows;
    case 'numCcdCols'
        returnObject = runParamsObject.keplerData.numCcdCols;
    case 'virtualSmearStart'
        returnObject = runParamsObject.keplerData.virtualSmearStart;
    case 'trailingBlackStart'
        returnObject = runParamsObject.keplerData.trailingBlackStart;
    % the masked smear rows to use for binning
    case 'maskedSmearRows'
        returnObject = runParamsObject.keplerData.maskedSmearRows;
    % the virtual smear rows to use for binning
    case 'virtualSmearRows'
        returnObject = runParamsObject.keplerData.virtualSmearRows;
    % the leading black columns to use for binning
    case 'blackCols'
        returnObject = runParamsObject.keplerData.blackCols;

    case 'raOffset'
        returnObject = runParamsObject.keplerData.raOffset;
    case 'decOffset'
        returnObject = runParamsObject.keplerData.decOffset;
    case 'phiOffset'
        returnObject = runParamsObject.keplerData.phiOffset;
        
    case 'electronsPerADU'
        returnObject = runParamsObject.keplerData.electronsPerADU;
    case 'wellCapacity'
        returnObject = runParamsObject.keplerData.wellCapacity;
    case 'readNoise'
        returnObject = runParamsObject.keplerData.readNoise;
    case 'parallelCTE'
        returnObject = runParamsObject.keplerData.parallelCTE;
    case 'serialCTE'
        returnObject = runParamsObject.keplerData.serialCTE;
    case 'saturationSpillUpFraction'
        returnObject = runParamsObject.keplerData.saturationSpillUpFraction;
    case 'numAtoDBits'
        returnObject = runParamsObject.keplerData.numAtoDBits;
    case 'numMemoryBits'
        returnObject = runParamsObject.keplerData.numMemoryBits;
    case 'simulationFramesPerExposure'
        returnObject = runParamsObject.keplerData.simulationFramesPerExposure;
    case 'adcGuardBandFractionLow'
        returnObject = runParamsObject.keplerData.adcGuardBandFractionLow;
    case 'adcGuardBandFractionHigh'
        returnObject = runParamsObject.keplerData.adcGuardBandFractionHigh;
    case 'guardBandOffset'
        returnObject = runParamsObject.keplerData.guardBandOffset;
    case 'numChains'
        returnObject = runParamsObject.keplerData.numChains;
    case 'motionPolyOrder'
        returnObject = runParamsObject.keplerData.motionPolyOrder;
    case 'nCoefs'
        returnObject = runParamsObject.keplerData.nCoefs;
    case 'motionGridResolution'
        returnObject = runParamsObject.keplerData.motionGridResolution;
    case 'dvaMeshOrder'
        returnObject = runParamsObject.keplerData.dvaMeshOrder;
    case 'fluxOfMag12Star'
        returnObject = runParamsObject.keplerData.fluxOfMag12Star;
    case 'chargeDiffusionSigma'
        returnObject = runParamsObject.keplerData.chargeDiffusionSigma;
    case 'chargeDiffusionArraySize'
        returnObject = runParamsObject.keplerData.chargeDiffusionArraySize;

    case 'badFitTolerance'
        returnObject = runParamsObject.keplerData.badFitTolerance;
    case 'saturationBoxSize'
        returnObject = runParamsObject.keplerData.saturationBoxSize;
    case 'transitTimeBuffer'
        returnObject = runParamsObject.keplerData.transitTimeBuffer;

    case 'rowCorrection'
        returnObject = runParamsObject.keplerData.rowCorrection;
    case 'colCorrection'
        returnObject = runParamsObject.keplerData.colCorrection;

    case 'refPixCadenceInterval'
        returnObject = runParamsObject.keplerData.refPixCadenceInterval;
    case 'refPixCadenceOffset'
        returnObject = runParamsObject.keplerData.refPixCadenceOffset;
	
    case 'requantizationTableId'
        returnObject = runParamsObject.keplerData.requantizationTableId;
    case 'requantTableLcFixedOffset'
        returnObject = runParamsObject.keplerData.requantTableLcFixedOffset;
    case 'requantTableScFixedOffset'
        returnObject = runParamsObject.keplerData.requantTableScFixedOffset;
		
    case 'targetListSetName'
        returnObject = runParamsObject.keplerData.targetListSetName;
		

    % diagnostic settings
	case 'supressAllMotion'
        returnObject = runParamsObject.keplerData.supressAllMotion;
	case 'supressAllStars'
        returnObject = runParamsObject.keplerData.supressAllStars;
	case 'supressSmear'
        returnObject = runParamsObject.keplerData.supressSmear;
	case 'supressQuantizationNoise'
        returnObject = runParamsObject.keplerData.supressQuantizationNoise;
	case 'useMeanBias'
        returnObject = runParamsObject.keplerData.useMeanBias;
		
        % exposure and cadence timing
	case 'integrationTime' 
        returnObject = runParamsObject.keplerData.integrationTime;
	case 'transferTime' 
        returnObject = runParamsObject.keplerData.transferTime;
	case 'exposureTotalTime' 
        returnObject = runParamsObject.keplerData.exposureTotalTime;
	case 'exposuresPerShortCadence' 
        returnObject = runParamsObject.keplerData.exposuresPerShortCadence;
	case 'shortsPerLongCadence' 
        returnObject = runParamsObject.keplerData.shortsPerLongCadence;
    case 'shortCadenceDuration'
        returnObject = runParamsObject.keplerData.shortCadenceDuration;
	case 'exposuresPerLongCadence' 
        returnObject = runParamsObject.keplerData.exposuresPerLongCadence;
    case 'longCadenceDuration'
        returnObject = runParamsObject.keplerData.longCadenceDuration;
	case 'exposuresPerCadence' 
        returnObject = runParamsObject.keplerData.exposuresPerCadence;
    case 'cadenceDuration'
        returnObject = runParamsObject.keplerData.cadenceDuration;
    case 'timeVector'
        returnObject = runParamsObject.keplerData.timeVector;

    % simulationGeometry
    case 'nSubPixelLocations'
        returnObject = runParamsObject.keplerData.nSubPixelLocations;
    case 'prfDesignRangeBuffer'
        returnObject = runParamsObject.keplerData.prfDesignRangeBuffer;
    case 'targetImageSize'
        returnObject = runParamsObject.keplerData.targetImageSize;    

    case 'raDec2PixObject'
        returnObject = runParamsObject.raDec2PixObject;    
    case 'barycentricTimeCorrectionObject'
        returnObject = runParamsObject.barycentricTimeCorrectionObject;    

    otherwise
        error([propName,' Is not a valid runParamsObject property']);
end
