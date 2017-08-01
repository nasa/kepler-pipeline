function [paDataObject, paResultsStruct] = input_simulated_transits(paDataObject, paResultsStruct)
%**************************************************************************
% function [paDataObject, paResultsStruct] = input_simulated_transits( ...
%     paDataObject, paResultsStruct)
%**************************************************************************
% This paDataClass method injects simulated transits into the target pixels
% using transit model parameters selected from a pre-defined distribution
% (TIP).
%**************************************************************************
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


% get flags from object
cadenceType = paDataObject.cadenceType;
if strcmpi(cadenceType, 'long')
    processLongCadence = true;
else
    processLongCadence = false;
end

% extract target data
targetDataStruct = paDataObject.targetStarDataStruct;

% extract cadence times and estimate timestamps in gaps
cadenceTimes = estimate_timestamps(paDataObject.cadenceTimes);
nCadences    = length(cadenceTimes.midTimestamps);

% extract target ids
keplerIds = [targetDataStruct.keplerId];
nTargets = length(targetDataStruct);

% build transit injection parameters struct for all available targets
transitInjectionParametersFileName = paDataObject.paFileStruct.transitInjectionParametersFilename;
simulatedTransitsStruct = build_simulated_transits_struct_from_tip_text_file(transitInjectionParametersFileName, keplerIds);


% if simulation parameters are found for any target the retrieve other
% channel dependent parameters.
% if there are no transit injection parameters available for any target
% return without altering paDataObject.
if ~isempty( simulatedTransitsStruct )     
    
    % extract configMap and fcConstant info
    configMapObject = configMapClass(paDataObject.spacecraftConfigMap);
    exposureTimePerRead = median(get_exposure_time(configMapObject));
    
    if strcmpi(  cadenceType, 'long' )
        exposuresPerCadence = median(get_number_of_exposures_per_long_cadence_period(configMapObject));
    elseif strcmpi(  cadenceType, 'short' )
        exposuresPerCadence = median(get_number_of_exposures_per_short_cadence_period(configMapObject));
    else
        error(['Cadence type is ',cadenceType,'. Must be either "long" or "short" to inject simulated transits.']);
    end
    
    % calculate total integration time per cadence as CADENCE_DURATION_SEC
    CADENCE_DURATION_SEC = exposureTimePerRead * exposuresPerCadence;
    MAG12_E_PER_S = paDataObject.fcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND;

    % add target independent info to simulatedTransitsStruct
    simulatedTransitsStruct.CADENCE_DURATION_SEC = CADENCE_DURATION_SEC;
    simulatedTransitsStruct.MAG12_E_PER_S = MAG12_E_PER_S;
    
    % add prf object if available - must extract from blob first
    prfStruct = blob_to_struct(paDataObject.prfModel.blob);
    if ~ isempty(prfStruct)
        if isfield(prfStruct, 'c');
            % it's a single prf model
            prfModel.polyStruct = prfStruct;
        else
            prfModel = prfStruct;
        end
        simulatedTransitsStruct.prfObject = prfCollectionClass(prfModel, paDataObject.fcConstants);
        clear prfStruct prfModel
    end
    
    % add motion polys if available
    motionPolyStruct = paDataObject.motionPolyStruct;
    if ~isempty(motionPolyStruct)
        rowPolyStatus    = logical([motionPolyStruct.rowPolyStatus]);
        colPolyStatus    = logical([motionPolyStruct.colPolyStatus]);
        polyStatus       = rowPolyStatus & colPolyStatus;        
        % interpolate polynomials if any motion polys are missing
        if ~all( polyStatus ) || length( motionPolyStruct ) < nCadences
            disp(['Interpolating motion polynomials through ',num2str(numel(find(~polyStatus))),' gapped cadences']);
            motionPolyStruct = interpolate_motion_polynomials(motionPolyStruct, cadenceTimes, processLongCadence);
        end        
        simulatedTransitsStruct.motionPolyStruct = motionPolyStruct;
    end
    
    % add background polys if available
    backgroundPolyStruct = paDataObject.backgroundPolyStruct;
    if ~isempty(backgroundPolyStruct)
        polyStatus = logical([backgroundPolyStruct.backgroundPolyStatus]);
        % interpolate polynomials if any background polys are missing
        if ~all( polyStatus ) || length( backgroundPolyStruct ) < nCadences
            disp(['Interpolating background polynomials through ',num2str(numel(find(~polyStatus))),' gapped cadences']);
            backgroundPolyStruct = interpolate_background_polynomials(backgroundPolyStruct, cadenceTimes, processLongCadence);
        end        
        simulatedTransitsStruct.backgroundPolyStruct = backgroundPolyStruct;
    end   
    
    % add cadence times struct
    simulatedTransitsStruct.cadenceTimes = cadenceTimes;
    
else     
    return;
end


% allocate space to save some transit model parameters
fractionSignalSubtracted    = nan(nCadences,nTargets);
cadenceModified             = false(nCadences,nTargets);
prfFailed                   = true(nCadences,nTargets);
transitParameterStructArray = repmat(struct('keplerId',[],...
                                        'appliedRa',[],...
                                        'appliedDec',[],...
                                        'magnitudeOffset',[],...
                                        'medianPhotocurrentAdded',[],...
                                        'fluxAddedToOptimalAperture',[],...
                                        'originalFluxTimeSeries',[]),1,nTargets);
                                    

% loop through the targets building transits consistent with simulation
% parameters read from tip text file
injectedTransitCount = 0;
for i = 1:nTargets

    % build transit injection inputs for this target
    transitInjectionInputs = build_pa_transit_injection_struct(paDataObject, paResultsStruct, i, simulatedTransitsStruct);

    if ~isempty(transitInjectionInputs)

        injectedTransitCount = injectedTransitCount + 1;

        % inject transits
        transitInjectionOutputs = inject_transits_into_target_pixels( transitInjectionInputs );

        % parse transit injection outputs
        pixelValues                     = transitInjectionOutputs.pixelValues;
        pixelGaps                       = transitInjectionOutputs.pixelGaps;
        prfFailed(:,i)                  = transitInjectionOutputs.prfFailed;
        cadenceModified(:,i)            = transitInjectionOutputs.cadenceModified;
        fractionSignalSubtracted(:,i)   = transitInjectionOutputs.fractionSignalSubtracted;

        % save outputs
        tempStruct.keplerId = transitInjectionOutputs.keplerId;
        tempStruct.appliedRa = transitInjectionOutputs.appliedRa(:)';
        tempStruct.appliedDec = transitInjectionOutputs.appliedDec(:)';
        tempStruct.magnitudeOffset = transitInjectionOutputs.magnitudeOffset(:)';
        tempStruct.medianPhotocurrentAdded = transitInjectionOutputs.medianPhotocurrentAdded(:)';
        tempStruct.fluxAddedToOptimalAperture = transitInjectionOutputs.fluxAddedToOptimalAperture(:)';
        tempStruct.originalFluxTimeSeries = transitInjectionOutputs.originalFluxTimeSeries;
        transitParameterStructArray(injectedTransitCount) = tempStruct;

        % write the pixel values and gaps back to the paDataObject if any
        % cadences were modified
        if any(cadenceModified(:,i))
            disp(['Transits injected for target index ',num2str(i),' - keplerId ',num2str(keplerIds(i))]);
            numPixels = size(pixelValues,2);
            for k = 1:numPixels
                paDataObject.targetStarDataStruct(i).pixelDataStruct(k).values = pixelValues(:,k);
                paDataObject.targetStarDataStruct(i).pixelDataStruct(k).gapIndicators = pixelGaps(:,k);
            end
        end
        
        % KSOC-3215
        % update medianPhotocurrentAdded field for target in paResultsStruct
        paResultsStruct.targetStarResultsStruct(i).medianPhotocurrentAdded = tempStruct.medianPhotocurrentAdded;        
        
    end
end


% trim parameter array
transitParameterStructArray = transitParameterStructArray(1:injectedTransitCount);

% update the simulated transits state file variables
simulatedTransitsStateFile = paDataObject.paFileStruct.paSimulatedTransitsFileName;

if exist(simulatedTransitsStateFile,'file');
    s = load(simulatedTransitsStateFile);
    
    % append state variables to existing ones
    transitParameterStructArray = [s.transitParameterStructArray, transitParameterStructArray];     %#ok<NASGU>    
    cadenceModified             = [s.cadenceModified, cadenceModified];                             %#ok<NASGU>
    fractionSignalSubtracted    = [s.fractionSignalSubtracted, fractionSignalSubtracted];           %#ok<NASGU>
    keplerIds                   = [s.keplerIds, keplerIds];                                         %#ok<NASGU>
    prfFailed                   = [s.prfFailed, prfFailed];                                         %#ok<NASGU>
end

% save the state variables, transit models and parameters plus
% configuration struct
save(simulatedTransitsStateFile, 'keplerIds', 'fractionSignalSubtracted', 'cadenceModified',...
    'prfFailed', 'transitParameterStructArray');


