function runParamsObject = runParamsClass(runParamsData)
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
if nargin == 0
    runParamsData.etemInformation = [];
    runParamsData.keplerData = [];
    runParamsData.simulationData = [];
    runParamsData.raDec2PixData = [];
else
    if ~isfield(runParamsData.keplerData, 'fcConstants')
        warning('runParamsClass: fcConstants not in runParamsData - getting from java');
        runParamsData.keplerData.fcConstants = fcConstants;
    end
    check_runParamsObject_inputs(runParamsData);
    % initialize file locations
    runParamsData.etemInformation.outputDirectory = ...
        [runParamsData.etemInformation.etem2OutputLocation filesep ...
        set_directory_name(runParamsData.simulationData.moduleNumber, ...
		runParamsData.simulationData.outputNumber, ...
		runParamsData.simulationData.observingSeason, ...
		runParamsData.simulationData.cadenceType)]; 

    % make backround due to dim stars by placing m_V = 22.5 mag star in each pixel (converted to e-/pixel/sec)
    runParamsData.keplerData.backgroundStarFlux = runParamsData.keplerData.fluxOfMag12Star ...
        * mag2b(22.5) / mag2b(12); 

    % initialized derived ccd quantities
    runParamsData.keplerData.numCcdRows = runParamsData.keplerData.numMaskedSmear...
        + runParamsData.keplerData.numVisibleRows ...
        + runParamsData.keplerData.numVirtualSmear;
    runParamsData.keplerData.numCcdCols = runParamsData.keplerData.numLeadingBlack ...
        + runParamsData.keplerData.numVisibleCols ...
        + runParamsData.keplerData.numTrailingBlack;
    runParamsData.keplerData.virtualSmearStart = runParamsData.keplerData.numMaskedSmear ...
        + runParamsData.keplerData.numVisibleRows + 1;
    runParamsData.keplerData.trailingBlackStart = runParamsData.keplerData.numLeadingBlack ...
        + runParamsData.keplerData.numVisibleCols + 1;

    % set up co-added collateral rows/cols
    runParamsData.keplerData.maskedSmearRows = runParamsData.keplerData.maskedSmearCoAddRows;
    runParamsData.keplerData.virtualSmearRows ...
        = runParamsData.keplerData.virtualSmearCoAddRows - runParamsData.keplerData.virtualSmearStart + 1;
    runParamsData.keplerData.blackCols ...
        = runParamsData.keplerData.blackCoAddCols - runParamsData.keplerData.trailingBlackStart + 1;

    % runParamsData.keplerData.electronsPerADU = ...
    %     ((1.00 * runParamsData.keplerData.wellCapacity) / 2^runParamsData.keplerData.numAtoDBits) ...                          % Corrected for guard bands...
    %     / (1 - runParamsData.keplerData.adcGuardBandFractionLow - runParamsData.keplerData.adcGuardBandFractionHigh); % was ~80 e- / bit

    exposureTotalTime = runParamsData.keplerData.integrationTime + runParamsData.keplerData.transferTime;
    runParamsData.keplerData.exposureTotalTime = exposureTotalTime;

    % derive the actual short and long cadence times.  Will be fixed to match
    % actual flight planning
    runParamsData.keplerData.shortCadenceDuration = runParamsData.keplerData.exposuresPerShortCadence*exposureTotalTime; % seconds
    runParamsData.keplerData.exposuresPerLongCadence ...
        = runParamsData.keplerData.exposuresPerShortCadence*runParamsData.keplerData.shortsPerLongCadence; % exposures / long; 
    runParamsData.keplerData.longCadenceDuration = runParamsData.keplerData.exposuresPerLongCadence*exposureTotalTime; % seconds

    runParamsData.keplerData.nCoefs = (runParamsData.keplerData.motionPolyOrder+1)*(runParamsData.keplerData.motionPolyOrder+2)/2;

    switch runParamsData.simulationData.cadenceType
        case 'long'
            runParamsData.keplerData.exposuresPerCadence = runParamsData.keplerData.exposuresPerLongCadence;
            % seconds per cadence
            runParamsData.keplerData.cadenceDuration = runParamsData.keplerData.longCadenceDuration;

        case 'short'
            runParamsData.keplerData.exposuresPerCadence = runParamsData.keplerData.exposuresPerShortCadence;
            % seconds per cadence
            runParamsData.keplerData.cadenceDuration = runParamsData.keplerData.shortCadenceDuration;

        otherwise 
            error('runParamsObject.cadenceType must be either <long> or <short>');
    end
    runParamsData.simulationData.endian = 'ieee-be';
    
    runParamsData.keplerData.cadencesPerDay = 3600*24/runParamsData.keplerData.cadenceDuration;
    switch runParamsData.simulationData.runDurationUnits
        case 'days'
            runParamsData.simulationData.runDurationDays = ...
                runParamsData.simulationData.runDuration;
            runParamsData.simulationData.runDurationCadences = ...
                ceil(runParamsData.simulationData.runDurationDays*runParamsData.keplerData.cadencesPerDay); % 30 minute cadences, fix later

        case 'cadences'
            runParamsData.simulationData.runDurationCadences = ...
                runParamsData.simulationData.runDuration; 
            runParamsData.simulationData.runDurationDays = ...
                runParamsData.simulationData.runDurationCadences/runParamsData.keplerData.cadencesPerDay; % 30 minute cadences, fix later

        otherwise
            error('runParamsData.runDurationUnits must be either <days> or <cadences>');
    end
    runParamsData.simulationData.runDurationSeconds = ...
        runParamsData.simulationData.runDurationCadences*runParamsData.keplerData.cadenceDuration;

    runParamsData.simulationData.runStartTime = datestr2mjd(runParamsData.simulationData.runStartDate);
    runParamsData.simulationData.runEndTime = ...
        runParamsData.simulationData.runStartTime + runParamsData.simulationData.runDurationDays;
    runParamsData.simulationData.firstExposureStartTime = datestr2mjd(runParamsData.simulationData.firstExposureStartDate);

    keplerInitialOrbitFilename = runParamsData.keplerData.keplerInitialOrbitFilename;
    keplerInitialOrbitFileLocation = runParamsData.keplerData.keplerInitialOrbitFileLocation;

    runParamsData.keplerData.orbitFile = ...
        [keplerInitialOrbitFileLocation filesep keplerInitialOrbitFilename];

    if runParamsData.simulationData.runDurationDays <= 1
        runParamsData.keplerData.timeVector = ...
            datestr2mjd(runParamsData.simulationData.runStartDate) + ...
            + [0, runParamsData.simulationData.runDurationDays];
    else
        runParamsData.keplerData.timeVector = ...
            datestr2mjd(runParamsData.simulationData.runStartDate) + ...
            + (0:runParamsData.simulationData.runDurationDays);
    end

	if ~isfield(runParamsData.keplerData, 'supressQuantizationNoise')
		% set the supressQuantizationNoise field if it's not already defined
		runParamsData.keplerData.supressQuantizationNoise = 0;
	end

    % instantiate the raDec2Pix object
    classString = ...
        ['runParamsData.raDec2PixObject = ' runParamsData.raDec2PixData.className ...
        '(runParamsData.raDec2PixData, runParamsData);'];
    classString
    eval(classString);

    % instantiate the barycentricTimeCorrection object
    classString = ...
        ['runParamsData.barycentricTimeCorrectionObject = ' ...
		runParamsData.barycentricTimeCorrectionData.className ...
        '(runParamsData.barycentricTimeCorrectionData, runParamsData);'];
    classString
    eval(classString);

end
runParamsObject = class(runParamsData, 'runParamsClass');
