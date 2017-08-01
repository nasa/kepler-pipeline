function paDataStruct = pa_convert_92_data_to_93(paDataStruct)
%
% function paDataStruct = pa_convert_92_data_to_93(paDataStruct)
%
% Update 9.2-era PA input structures to 9.3. This is useful when testing
% with existing data sets.
%
% INPUTS:       paDataStruct    = SOC 9.2 paInputsStruct
% OUTPUTS:      paDataStruct    = SOC 9.3 paInputsStruct
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
    % Set verbosity of assert_field()
    verbosity = false; 
    
    thisIsK2Data = paDataStruct.cadenceTimes.midTimestamps(find(~paDataStruct.cadenceTimes.gapIndicators,1))  > ...
                                paDataStruct.fcConstants.KEPLER_END_OF_MISSION_MJD;

    % add fcConstants KEPLER_END_OF_MISSION_MJD if missing
    if ~isfield(paDataStruct.fcConstants,'KEPLER_END_OF_MISSION_MJD')
        paDataStruct.fcConstants.KEPLER_END_OF_MISSION_MJD = 56444;
    end

    %----------------------------------------------------------------------
    % Add default PA-COA parameters, if missing.
    %----------------------------------------------------------------------  
    if ~isfield(paDataStruct,'paCoaConfigurationStruct')
        paDataStruct.paCoaConfigurationStruct = struct();
    end

    paDataStruct.paConfigurationStruct    = assert_field (paDataStruct.paConfigurationStruct,    'paCoaEnabled',                      false, verbosity);
    paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'cadenceStep',                       1, verbosity);
    paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'raDecFittingCadenceStep',           100, verbosity);
    paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'computeForSaturatedTargetsEnabled', false, verbosity);
    paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'numberOfHalosToAddToAperture',      2, verbosity);
    paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'cdppOptimizationEnabled',           true, verbosity);
    paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'cdppVsSnrStrengthFactor',           1.0, verbosity);
    paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'cdppSweepLength',                   100, verbosity);
    paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'cdppMedFiltSmoothLength',           100, verbosity);
    paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'trialTransitPulseDurationInHours',  6, verbosity);
    paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'usePolyFitTransitModel',            false, verbosity);
    paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'superResolutionFactor',             1, verbosity);
    paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'varianceWindowLengthMultiplier',    7, verbosity);
    paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'waveletFilterLength',               12, verbosity);

    % KSOC-4630 Protect apertures from overly aggressive PA-COA
    if (thisIsK2Data)
        paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'mnrBeta0',                            0.0,      verbosity);
        paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'mnrAddedFluxBeta',                    0.0,  verbosity);
        paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'mnrFractionalChangeInApertureBeta',   0.0,        verbosity);
        paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'mnrFractionalChangeInMedianFluxBeta', 0.0,     verbosity);
        paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'mnrMaskUsageRatioBeta',               0.0,     verbosity);
        paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'mnrDiscriminationThreshold',          2.0,        verbosity);
    else
        paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'mnrBeta0',                            7.888,      verbosity);
        paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'mnrAddedFluxBeta',                    1.412e-08,  verbosity);
        paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'mnrFractionalChangeInApertureBeta',   0.0,        verbosity);
        paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'mnrFractionalChangeInMedianFluxBeta', -7.414,     verbosity);
        paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'mnrMaskUsageRatioBeta',               -8.094,     verbosity);
        paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'mnrDiscriminationThreshold',          0.2,        verbosity);
    end

    % KSOC-4641: For K2 if the PA-COA aperture is smaller than TAD then just use the TAD aperture.
    if (thisIsK2Data)
        paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'revertToTadIfApertureShrank', true, verbosity);
    else
        paDataStruct.paCoaConfigurationStruct = assert_field (paDataStruct.paCoaConfigurationStruct, 'revertToTadIfApertureShrank', false, verbosity);
    end

    %----------------------------------------------------------------------
    % We need parameters that prior to 9.3 are in TAD-COA inputs. Specifically, we need spacecraftConfigurationStruct, gainModel, readNoiseModel, linearityModel 
    % It would make this function long if all the values in these structs were added here. So, instead a sample coaParameterStruct has been saved
    %----------------------------------------------------------------------

    loadCoaParameters = false;
    if ~isfield(paDataStruct,'gainModel')
        paDataStruct.gainModel = struct();
        loadCoaParameters = true;
    end
    if ~isfield(paDataStruct,'readNoiseModel')
        paDataStruct.readNoiseModel = struct();
        loadCoaParameters = true;
    end
    if ~isfield(paDataStruct,'linearityModel')
        paDataStruct.linearityModel = struct();
        loadCoaParameters = true;
    end

    if (paDataStruct.paConfigurationStruct.paCoaEnabled && loadCoaParameters)
        filename ='/path/to/ksoc-3891_ksoc-3929_pa-coa/running_pa/coaParameterStruct_Q15m2o1.mat'; 
        if (exist(filename, 'file'))
            S = load(filename);
        else
            S = [];
        end
        if (~isempty(S))
            paDataStruct.gainModel                      = S.coaParameterStruct.gainModel;
            paDataStruct.readNoiseModel                 = S.coaParameterStruct.readNoiseModel;
            paDataStruct.linearityModel                 = S.coaParameterStruct.linearityModel;
        else
            warning('Error loading coaParameterStruct. Turning off PA-COA');
            paDataStruct.paConfigurationStruct.paCoaEnabled = false;
        end
    end


    %----------------------------------------------------------------------  
    % Add default aperture modeling parameters, if missing.
    %----------------------------------------------------------------------      
    if ~isfield(paDataStruct,'apertureModelConfigurationStruct')
        paDataStruct.apertureModelConfigurationStruct = struct();
    end
    
    % Insert fields and default values into
    % apertureModelConfigurationStruct, if necessary. 
    paDataStruct.apertureModelConfigurationStruct = ...
        assert_field(paDataStruct.apertureModelConfigurationStruct, 'excludeSnrThreshold', 3.0, verbosity);
    paDataStruct.apertureModelConfigurationStruct = ...
        assert_field(paDataStruct.apertureModelConfigurationStruct, 'lockSnrThreshold', 4.0, verbosity);
    paDataStruct.apertureModelConfigurationStruct = ...
        assert_field(paDataStruct.apertureModelConfigurationStruct, 'amplitudeFitMethod', 'bbnnls', verbosity);
    paDataStruct.apertureModelConfigurationStruct = ...
        assert_field(paDataStruct.apertureModelConfigurationStruct, 'raDecFittingEnabled', false, verbosity);
    paDataStruct.apertureModelConfigurationStruct = ...
        assert_field(paDataStruct.apertureModelConfigurationStruct, 'raDecFitMethod', 'nlinfit', verbosity);
    paDataStruct.apertureModelConfigurationStruct = ...
        assert_field(paDataStruct.apertureModelConfigurationStruct, 'raDecMaxDeltaPixels', 5.0, verbosity);
    paDataStruct.apertureModelConfigurationStruct = ...
        assert_field(paDataStruct.apertureModelConfigurationStruct, 'raDecRestoringCoef', 1e8, verbosity);
    paDataStruct.apertureModelConfigurationStruct = ...
        assert_field(paDataStruct.apertureModelConfigurationStruct, 'raDecRepulsiveCoef', 1.0, verbosity);
    paDataStruct.apertureModelConfigurationStruct = ...
        assert_field(paDataStruct.apertureModelConfigurationStruct, 'raDecMaxIter', 100, verbosity);
    paDataStruct.apertureModelConfigurationStruct = ...
        assert_field(paDataStruct.apertureModelConfigurationStruct, 'raDecTolFun', 1e-8, verbosity);
    paDataStruct.apertureModelConfigurationStruct = ...
        assert_field(paDataStruct.apertureModelConfigurationStruct, 'raDecTolX', 1e-8, verbosity);
    paDataStruct.apertureModelConfigurationStruct = ...
        assert_field(paDataStruct.apertureModelConfigurationStruct, 'maxDeltaMagnitude', 1.0, verbosity);
    paDataStruct.apertureModelConfigurationStruct = ...
        assert_field(paDataStruct.apertureModelConfigurationStruct, 'maxNumStars', 30, verbosity);
    paDataStruct.apertureModelConfigurationStruct = ...
        assert_field(paDataStruct.apertureModelConfigurationStruct, 'ukirtMagnitudeThreshold', 18.0, verbosity);    


    %----------------------------------------------------------------------
    % Add KIC struct array to targetStarDataStruct elements, if missing. In
    % the absence of actual KIC data, we create a single entry for the
    % target star and populate it with only the fields required by
    % apertureModelClass. For custom targets we leave the kics field empty.
    %----------------------------------------------------------------------  
    if ~isempty(paDataStruct.targetStarDataStruct) && ...
       ~isfield(paDataStruct.targetStarDataStruct,'kics')
    
       valueStruct = struct('value', NaN, 'uncertainty', NaN);
       kicsStruct = struct( ...
           'keplerId',  int16(0), ... 
           'keplerMag', valueStruct, ...
           'ra',        valueStruct, ...
           'dec',       valueStruct);

       targetArray = paDataStruct.targetStarDataStruct;
       
       for iTarget = 1:numel(targetArray)
           if is_valid_id(targetArray(iTarget).keplerId, 'catalog')
               kicsStruct.keplerId        = targetArray(iTarget).keplerId;
               kicsStruct.keplerMag.value = targetArray(iTarget).keplerMag;
               kicsStruct.ra.value        = targetArray(iTarget).raHours;
               kicsStruct.dec.value       = targetArray(iTarget).decDegrees;
          
               paDataStruct.targetStarDataStruct(iTarget).kics = kicsStruct;
           else
               paDataStruct.targetStarDataStruct(iTarget).kics = [];
           end
       end
    end

    %----------------------------------------------------------------------  
    % We also need a new field called 'saturatedRowCount' which is 
    % generated in TAD-COA. Set to zero by default.
    %----------------------------------------------------------------------  
    if (~isempty(paDataStruct.targetStarDataStruct) && ...
        ~isfield(paDataStruct.targetStarDataStruct(1),'saturatedRowCount'))

       for iTarget = 1:length(paDataStruct.targetStarDataStruct)
           paDataStruct.targetStarDataStruct(iTarget).saturatedRowCount = 0;
       end
    end
    
    
    %----------------------------------------------------------------------  
    % Add parameters for aperture trimming in K2.
    %----------------------------------------------------------------------  
    paDataStruct.paConfigurationStruct = ...
        assert_field(paDataStruct.paConfigurationStruct, 'k2TrimAperturesEnabled', true, verbosity);
    paDataStruct.paConfigurationStruct = ...
        assert_field(paDataStruct.paConfigurationStruct, 'k2TrimRadiusInPrfWidths', 0.7, verbosity);
    paDataStruct.paConfigurationStruct = ...
        assert_field(paDataStruct.paConfigurationStruct, 'k2TrimMinSizeInPixels', 50, verbosity);

    %----------------------------------------------------------------------  
    % Add a default thrusterDataAncillaryEngineeringConfigurationStruct
    % and/or fields, if missing.
    %----------------------------------------------------------------------
    if ~isfield(paDataStruct,'thrusterDataAncillaryEngineeringConfigurationStruct')
        paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct = struct();
    end
    
    % Insert fields and default values into
    % thrusterDataAncillaryEngineeringConfigurationStruct, if necessary. 
    paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct = ...
        assert_field(paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct, ...
        'mnemonics', {}, verbosity);
    paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct = ...
        assert_field(paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct, ...
        'modelOrders', [], verbosity);
    paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct = ...
        assert_field(paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct, ...
        'interactions', [], verbosity);
    paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct = ...
        assert_field(paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct, ...
        'quantizationLevels', [], verbosity);
    paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct = ...
        assert_field(paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct, ...
        'intrinsicUncertainties', [], verbosity);
    paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct = ...
        assert_field(paDataStruct.thrusterDataAncillaryEngineeringConfigurationStruct, ...
        'thrusterFiringDataCadenceSeconds', 16.0, verbosity);
    
    
    %----------------------------------------------------------------------  
    % Add parameters to enable gapping of coarse-point and pre-tweak K2
    % data.
    %----------------------------------------------------------------------  
    paDataStruct.paConfigurationStruct = ...
        assert_field(paDataStruct.paConfigurationStruct, 'k2GapIfNotFinePntData', true, verbosity);
    paDataStruct.paConfigurationStruct = ...
        assert_field(paDataStruct.paConfigurationStruct, 'k2GapPreTweakData', true, verbosity);
    
    %----------------------------------------------------------------------  
    % We also need a new field called 'testPulseDurationLc' in the 
    % rollingBandArtifactFlags struct array. Set to one by default; this is
    % a valid value but is recognizable as a default because the Dynablack
    % pulse duration will never be one cadence.
    %----------------------------------------------------------------------  
    if (~isempty(paDataStruct.rollingBandArtifactFlags) && ...
        ~isfield(paDataStruct.rollingBandArtifactFlags(1),'testPulseDurationLc'))

       for iElement = 1:length(paDataStruct.rollingBandArtifactFlags)
           paDataStruct.rollingBandArtifactFlags(iElement).testPulseDurationLc = 1;
       end
    end
    
    %----------------------------------------------------------------------  
    % Add K2-specific cosmic ray cleaning parameters.
    %----------------------------------------------------------------------  
    paDataStruct.cosmicRayConfigurationStruct = ...
        assert_field(paDataStruct.cosmicRayConfigurationStruct, 'k2BackgroundCleaningEnabled', true, verbosity);
    paDataStruct.cosmicRayConfigurationStruct = ...
        assert_field(paDataStruct.cosmicRayConfigurationStruct, 'k2TargetCleaningEnabled', true, verbosity);
    paDataStruct.cosmicRayConfigurationStruct = ...
        assert_field(paDataStruct.cosmicRayConfigurationStruct, 'k2BackgroundThrusterFiringExcludeHalfWindow', 3, verbosity);
    paDataStruct.cosmicRayConfigurationStruct = ...
        assert_field(paDataStruct.cosmicRayConfigurationStruct, 'k2TargetThrusterFiringExcludeHalfWindow', 4, verbosity);
    
    %----------------------------------------------------------------------  
    % Add K2-specific motion poly fitting parameters.
    %----------------------------------------------------------------------  
    paDataStruct.motionConfigurationStruct = ...
        assert_field(paDataStruct.motionConfigurationStruct, 'k2PpaTargetRejectionEnabled', false, verbosity);    
end


