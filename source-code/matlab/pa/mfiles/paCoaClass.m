% paCoaClass
%
% This class contains the algorithm to find the optimal apertures using image fits to the PRF model. This uses the pa/mfiles/image_modelling code to 
% fit the PRF to each image and refind the target center, RA and Dec, along with the background objects.
%
% This functionality is executed with the static function find_optimal_aperture. It is called in perform_simple_aperture_photometry. 
%
% Diagnostic plots are generated for each processed target and saved in ./pa_coa_plots. Plotting always occurs. However, if
% debugEnabled = true then a pause occurs after each plot for interactive viewing.
%
% To run call:
%
% [resultsStruct] = find_optimal_aperture ...
%            (paDataObject, backgroundRemovedPixelDataStruct, backgroundPixelValues, backgroundPixelUncertainties, iTarget)
%
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

classdef paCoaClass

properties(Constant)
    debugEnabled = false; % Used for diagnostics and testing, if false then plotting still occurs but no pauses.
    doPlotImagePerCadence = false; % Plot a scene image per cadence
    doPlotPrfModelFitting = true; % plots apertureModelObjectForRaDecFit.plot_star_locations_on_image(firstCadence)
    doLoadCatalogFile = false; %load in full catalog from file or sandbox, this is for testing purposes.
    catalogFilename = '/path/to/latestCleanKic.mat';
    k2CatalogFilename = './k2Epic.mat';
    useMaxDeltaMagnitudeToRevertToCatalogModel = true; % see KSOC-4721; If the fit Mag drifts too far away from the catalog then revert to the catalog value
    chosenApertureOptions = {'TAD', 'TAD; MNR Chosen', 'SNR', 'CDPP', 'Union', 'Haloed'};
end

% These are the main products of the aperture calculation.
% However you actually get what they want in the resultsStruct (see paCoaClass.populate_results_Struct)
properties(GetAccess = 'public', SetAccess = 'private')
    revertToTadAperture = false % If true then PA-COA determiend the TAD-COA aperture to be supperior
    selectedAperture = [] % [char] the selected aperture {TAD, SNR, CDPP, Union, Haloed}.
    mnrChosenRevertToTad = false; % If tru the the logistical regression discriminator identified this target ad poor and should revert to TAD.
    paCoaApertureShrankSoRevertedToTad = false; % if true then the PA-COA aperture was smaller than TAD and so we reverted to TAD.
    inOptimalAperture = []; % (nPixel) The found optimal the corresponds to selectedAperture
    inOptimalAperturePerCadence = []; % (nCadences, nPixel) The found optimal per cadence using the SNR test
    inOptimalApertureMedian = []; % The median aperture from inOptimalAperturePerCadence (using SNR test)
    inOptimalApertureUnion = []; % The union aperture from inOptimalAperturePerCadence (using SNR test)
    inOptimalApertureMedianCdppOptimized = []; % The aperture found using the CDPP optimizer
    inOptimalApertureHaloed = []; % The aperture found by adding a halo around the TAD aperture
    pixelAddingOrder = []; % [int32 array(nCadences, nPixels)] A linear ranking of the pixels in the mask
    pixelAddingOrderMedian = []; %[int32 array(nPixels)] Median of the above pixel adding order.  [aperture = ~pixelAddingOrder(1:sum(inOptimalApertureMedian)]
    fluxFractionTimeSeries = []; % [double array(nCadences)] Flux Fraction per cadence
    crowdingMetricTimeSeries = []; % [double array(nCadences)] Crowding Metric per cadence
    skyCrowdingMetricTimeSeries = []; % [double array(nCadences)] Crowding Metric per cadence
    prfModelPixelDataStruct = []; % from the PRF model fit (see the function  pa_coa_aperture_model.m)
    prfModelTargetStarStruct = []; % from the PRF model fit (see the function  pa_coa_aperture_model.m)
    prfModelBackgroundStarStruct = []; % from the PRF model fit, the background fit objects (see the function  pa_coa_aperture_model.m)
    apertureModelObjectForRaDecFit = [] % The returned object from the PRF modelling code
end

properties(GetAccess = 'public', SetAccess = 'immutable')
    keplerId = []; % The target under study
    cadencesToFind  = []; % [logial array] indices of cadences to evaulate the PRF model on
    cadencesForRaDecFitting  = []; % [logial array] indices of cadences to use for finding Ra and Dec (if enabled)
    isK2Data = false; 
end
properties(GetAccess = 'public', SetAccess = 'immutable')
    ccdModule = [];
    ccdOutput = [];
    nTargets = [];
    iTarget  = []; % This method is called inside a target loop by default so it only operates on one taregt at a time.
    nCadences = [];
    nPixels = [];
    gapFilledTimestamps = [];
    withBackgroundTargetDataStruct = [];
    backgroundRemovedPixelDataStruct = [];
    backgroundPixelValues = [];
    backgroundPixelUncertainties = [];
    prfModel = [];
    fcConstants = [];
    cadenceTimes = [];
    motionPolyStruct = [];
    cadenceType = [];
    paConfigurationStruct = [];
    paCoaConfigurationStruct = [] % [struct] the input configuration struct to configure PA-COA
    apertureModelConfigurationStruct = [];
    gapFillConfigurationStruct = [];
    spacecraftConfigurationStruct = [];
    gainModel = [];
    readNoiseModel = [];
    linearityModel = [];
    catalog = []; % This is used for testing purposes, contains the full catalog.
    apertureFigureHandle = []; % For diagnostic figure
    curveFigureHandle = []; % For diagnostic figure
    prfModelFigureHandle = []; % For the PRF imaging model plot
    doPlotFigure = []; % For diagnostic figure
    doSaveFigure = []; % For diagnostic figure
end

properties(GetAccess = 'public', SetAccess = 'private')
    nRows = [];
    nColumns = [];
    inMaskRow = []; % Row indices for the pixels in the mask
    inMaskColumn = []; % Column indices for the pixels in the mask
    pixelDataStructPixelMapping = [] % [int array] mapping between the orginal pixel order and the square grid order
    missingPixelIndices = [] % [int array] indices in the square grid of the pixels missing in the original mask
    snrPerPixel = [] % [double arra(nCadences, nPixels) the snr value as a function of number of pixel in aperture per cadence
    snrMedian   = [] % [double arra(nPixels) the median snr value as a function of number of pixel in aperture
end

% Light curves and CDPP values
properties(GetAccess = 'public', SetAccess = 'private')
    tadFlux     = [];  % gaps-filled with NaNs 
    paSnrFlux   = [];  
    paCdppFlux  = [];  
    paUnionFlux = [];  
    haloedFlux = [];  
    tadCdpp     = [];  % both time series and rms
    paSnrCdpp   = [];  
    paCdppCdpp  = [];  
    paUnionCdpp = [];  
    haloedCdpp = [];  
end



%*************************************************************************************************************
%*************************************************************************************************************
%*************************************************************************************************************
% These are the static methods

methods (Static=true)

%*************************************************************************************************************
% 
% function [resultsStruct] = find_optimal_aperture ...
%            (paDataObject, backgroundRemovedPixelDataStruct, backgroundPixelValues, backgroundPixelUncertainties, iTarget)
%
% This is the static function to call to have paCoaClass do its thing and find the optimal aperture.
%
% Inputs:
%   paDataObject    -- [paDataClass] the main paDataClass with background STILL in pixels. Uses old-school Matlab
%                       classes so the data in here that is needed is copied over locally into the paCoaObject.
%   backgroundRemovedPixelDataStruct -- [pixelDataStruct] Pixels from paDataObject except with background removed
%   backgroundPixelValues            -- [float array(nCadences, nPixels)] background values removed in backgroundRemovedPixelDataStruct 
%   backgroundPixelUncertainties     -- [float array(nCadences, nPixels)] background uncertainties
%   iTarget                          -- [int] Index of target under study in paDataObject 
%   figureHandles                    -- [int array(2)] Figure Handles for diagnostic figures (empty means no figure)
%
% Outputs:
%   resultsStruct                    -- [resultsStruct] All important results (see populate_results_struct)
%
%*************************************************************************************************************
function [resultsStruct] = find_optimal_aperture ...
            (paDataObject, backgroundRemovedPixelDataStruct, backgroundPixelValues, backgroundPixelUncertainties, iTarget, figureHandles)

    % Create a paCoaClass object
    paCoaObject = paCoaClass(paDataObject, backgroundRemovedPixelDataStruct, backgroundPixelValues, backgroundPixelUncertainties, iTarget, figureHandles);

    if (paCoaClass.debugEnabled)
        display(['Working on computing aperture for target ', num2str(iTarget), ' of ', num2str(paCoaObject.nTargets), '...']);
    end

    if (~paCoaObject.paConfigurationStruct.paCoaEnabled)
        warning('Calling paCoaClass.find_optimal_aperture but paCoaEnabled is false! Nothing will happen.');
        paCoaObject.revertToTadAperture = true;
        resultsStruct = paCoaObject.populate_results_struct();
        return;
    end

    % Custom targets come with pre-specified apertures. Do not compute apertures for cutom targets
    if( is_valid_id(paCoaObject.keplerId, 'custom') )
        paCoaObject.revertToTadAperture = true;
        resultsStruct = paCoaObject.populate_results_struct();
        return;
    end

    % If this is a saturated target then do not attempt to find aperture. 
    % ...Unless we are forcing it to compute via computeForSaturatedTargetsEnabled
    % Or, for K2 data we take the TAD aperture and add N halos, if N is zero then revert to TAD
    if (paCoaObject.withBackgroundTargetDataStruct.saturatedRowCount > 0)
        if (paCoaObject.isK2Data && paCoaObject.paCoaConfigurationStruct.numberOfHalosToAddToAperture > 0)
            % Add a halo to the TAD aperture
            apertureToUse = [paCoaObject.backgroundRemovedPixelDataStruct.inOptimalAperture];
            paCoaObject = paCoaObject.add_halo_to_aperture(apertureToUse);
            % Now we need to compute Flux Fraction in Aperture and Crowding Metric for this new bigger aperture
            paCoaObject = paCoaObject.find_prf_model_but_do_not_find_new_aperture();
            % If the PRF image moddeling code failed then we need to revert to the TAD aperture with no halo added
            if (isempty(paCoaObject.prfModelTargetStarStruct))
                paCoaObject.revertToTadAperture = true;
                resultsStruct = paCoaObject.populate_results_struct();
                return;
            end
            paCoaObject = paCoaObject.find_flux_fraction_and_crowding_metric ();
            resultsStruct = paCoaObject.populate_results_struct();
            paCoaObject.generate_plots_and_save_diagnostic_data ()
        elseif (~paCoaObject.paCoaConfigurationStruct.computeForSaturatedTargetsEnabled)
            paCoaObject.revertToTadAperture = true;
            resultsStruct = paCoaObject.populate_results_struct();
        end
        return;
    end

    % Find the optimal aperture per cadence using an SNR test and the average found aperture
    paCoaObject = paCoaObject.find_optimal_aperture_per_cadence_using_snr();

    % If the found aperture is zero then a problem occured so do not perform any more calculations
    if (~any(paCoaObject.inOptimalApertureMedian))
        paCoaObject.revertToTadAperture = true;
        resultsStruct = paCoaObject.populate_results_struct();
        return;
    end

    % Optimize the found optimal aperture using an estimated CDPP
    if (paCoaObject.paCoaConfigurationStruct.cdppOptimizationEnabled)
        paCoaObject = paCoaObject.optimize_aperture_with_cdpp ();
    end

    % Make sure aperture is contiguous
    paCoaObject = paCoaObject.force_contiguous_aperture();

    % Compare the found apertures to the TAD aperture. Pick the one that is better.
    paCoaObject = paCoaObject.select_best_aperture();

    % Find Flux Fraction and Crowding Metric
    paCoaObject = paCoaObject.find_flux_fraction_and_crowding_metric ();

    resultsStruct = paCoaObject.populate_results_struct();
    
    paCoaObject.generate_plots_and_save_diagnostic_data ()

    if (paCoaClass.debugEnabled)
        display(['Finished computing aperture for target ', num2str(iTarget), ' of ', num2str(paCoaObject.nTargets)]);
        pause;
    end

end % find_optimal_aperture 

%*************************************************************************************************************
% function targetStarResultsStruct = update_targetStarResultsStruct(resultsStruct, targetStarResultsStruct, paDataObject)
%
% Updates paResultsStruct.targetStarResultsStruct with the results of PA-COA. 
%
% All results from PA-COA are passed through this static function.
%
% The Java Exporter does not like empty set or NaNs. All these values should be real numbers or logicals.
% 
% Inputs:
%   resultsStruct   -- [paCoaResultsStruct] the results from PA-COA to be passed into targetStarResultsStruct 
%   targetStarResultsStruct -- [targetStarResultsStruct] the outputs in paResultsStruct
%
% Outputs:
%   targetStarResultsStruct -- [targetStarResultsStruct] the outputs in paResultsStruct but with new fields added
%
%*************************************************************************************************************
function targetStarResultsStruct = update_targetStarResultsStruct(resultsStruct, targetStarResultsStruct, paDataObject)

    paDataStruct = struct(paDataObject);

    % all values need to be something that Java can handle. So, no empty sets or NaNs

    targetStarResultsStruct.signalToNoiseRatioTimeSeries.values         = resultsStruct.snrTimeSeries;
    targetStarResultsStruct.signalToNoiseRatioTimeSeries.gapIndicators  = resultsStruct.gapIndicators;

    targetStarResultsStruct.fluxFractionInApertureTimeSeries.values         = resultsStruct.fluxFractionTimeSeries;
    targetStarResultsStruct.fluxFractionInApertureTimeSeries.gapIndicators  = resultsStruct.gapIndicators;

    targetStarResultsStruct.crowdingMetricTimeSeries.values         = resultsStruct.crowdingMetricTimeSeries;
    targetStarResultsStruct.crowdingMetricTimeSeries.gapIndicators  = resultsStruct.gapIndicators;

    targetStarResultsStruct.skyCrowdingMetricTimeSeries.values         = resultsStruct.skyCrowdingMetricTimeSeries;
    targetStarResultsStruct.skyCrowdingMetricTimeSeries.gapIndicators  = resultsStruct.gapIndicators;

    optimalAperture.keplerId                = targetStarResultsStruct.keplerId;
    optimalAperture.signalToNoiseRatio      = median(resultsStruct.snrTimeSeries(~resultsStruct.gapIndicators));
    optimalAperture.fluxFractionInAperture  = median(resultsStruct.fluxFractionTimeSeries(~resultsStruct.gapIndicators));
    optimalAperture.crowdingMetric          = median(resultsStruct.crowdingMetricTimeSeries(~resultsStruct.gapIndicators));
    optimalAperture.skyCrowdingMetric       = median(targetStarResultsStruct.skyCrowdingMetricTimeSeries.values(~resultsStruct.gapIndicators));
    optimalAperture.badPixelCount           = 0; % This is identically zero in TAD-COA (see extract_optimal_aperture)
    optimalAperture.referenceRow            = targetStarResultsStruct.referenceRow;
    optimalAperture.referenceColumn         = targetStarResultsStruct.referenceColumn;
    optimalAperture.saturatedRowCount       = paDataStruct.targetStarDataStruct(resultsStruct.iTarget).saturatedRowCount;
    optimalAperture.apertureUpdatedWithPaCoa = resultsStruct.apertureUpdated;
    optimalAperture.offsets                 = [];

    % In certain cases where PA-COA cannot be performed we revert to the TAD aperture (Satruated targets is an example)
    % For these cases, SNR, flux Fraction and crowding metric are not computed. We need to revert to the TAD values 
    % from the PA inputsStruct
    % Note that in other cases we choose to use the TAD aperture after performing PA-COA. In these cases new values can 
    % be computed and so only revert to the input values if the values found above are zero (which implies they were not computed).
    if (~optimalAperture.apertureUpdatedWithPaCoa)
        if (optimalAperture.fluxFractionInAperture == 0)
            optimalAperture.fluxFractionInAperture = paDataStruct.targetStarDataStruct(resultsStruct.iTarget).fluxFractionInAperture;
        end
        if (optimalAperture.crowdingMetric == 0)
            % These fields needed to be added to the inputsStruct (see KSOC-3930) so, they are not necessarily their for old data
            if (isfield(paDataStruct.targetStarDataStruct(resultsStruct.iTarget), 'crowdingMetric'))
                optimalAperture.crowdingMetric = paDataStruct.targetStarDataStruct(resultsStruct.iTarget).crowdingMetric;
            end
        end
        if (optimalAperture.skyCrowdingMetric == 0)
            if (isfield(paDataStruct.targetStarDataStruct(resultsStruct.iTarget), 'skyCrowdingMetric'))
                optimalAperture.skyCrowdingMetric = paDataStruct.targetStarDataStruct(resultsStruct.iTarget).skyCrowdingMetric;
            end
        end
        if (optimalAperture.signalToNoiseRatio == 0)
            if (isfield(paDataStruct.targetStarDataStruct(resultsStruct.iTarget), 'signalToNoiseRatio'))
                optimalAperture.signalToNoiseRatio = paDataStruct.targetStarDataStruct(resultsStruct.iTarget).signalToNoiseRatio;
            end
        end
    end

    pixelCounter = 1;
    for iPixel = 1 : length(targetStarResultsStruct.pixelApertureStruct)
        if (resultsStruct.inOptimalAperture(iPixel))
            optimalAperture.offsets(pixelCounter).row    = ...
                    targetStarResultsStruct.pixelApertureStruct(iPixel).ccdRow    - targetStarResultsStruct.referenceRow;
            optimalAperture.offsets(pixelCounter).column = ...
                    targetStarResultsStruct.pixelApertureStruct(iPixel).ccdColumn - targetStarResultsStruct.referenceColumn;
            pixelCounter  = pixelCounter + 1;
        end
    end

    %***
    % All this to calculate distanceFromEdge
    if (~isempty(optimalAperture.offsets))
        maskedSmear  = paDataStruct.fcConstants.nMaskedSmear;
        leadingBlack = paDataStruct.fcConstants.nLeadingBlack;
        nRowPix = paDataStruct.fcConstants.nRowsImaging;
        nColPix = paDataStruct.fcConstants.nColsImaging;
        
        
        apertureRows = optimalAperture.referenceRow     + [optimalAperture.offsets.row]     - maskedSmear;
        apertureCols = optimalAperture.referenceColumn  + [optimalAperture.offsets.column]  - leadingBlack;
        rowDistanceFromEdge = min([min(apertureRows) - 1, nRowPix - max(apertureRows)]);
        colDistanceFromEdge = min([min(apertureCols) - 1, nColPix - max(apertureCols)]);
        optimalAperture.distanceFromEdge = min(rowDistanceFromEdge, colDistanceFromEdge);
        clear paDataStruct;
    else
        % Aperture is empty so just fill with some value that Java will accept (So, no NaNs)
        optimalAperture.distanceFromEdge = 0;
    end
    %***

    targetStarResultsStruct.optimalAperture = optimalAperture;

end % update_targetStarResultsStruct

%*************************************************************************************************************
% gapIndicators = gap_not_fine_point (gapIndicators, cadenceTimes)
%
% Until PA is fixed to gap no fine point from the beginning we will have a function here to ensure only fine point data is used.
%
%*************************************************************************************************************
function gapIndicators = gap_not_fine_point (gapIndicators, cadenceTimes)

    gapIndicators = gapIndicators | ~cadenceTimes.isFinePnt;

end

%*************************************************************************************************************
% function targetStarResultsStruct = set_optimalAperture_with_TAD_values(targetStarResultsStruct, paDataObject, iTarget)
%
% Sets paResultsStruct.targetStarResultsStruct.optimalAperture with the input TAD values. 
%
% This is for when paCoaEnabled = false and yet we still want to have the fields in optimalAperture to be accurate to the TAD values.
%
% The Java Exporter does not like empty set or NaNs. All these values should be real numbers or logicals.
% 
% Inputs:
%   targetStarResultsStruct -- [targetStarResultsStruct] the outputs in paResultsStruct
%   paDataObject            -- 
%   iTarget
%
% Outputs:
%   targetStarResultsStruct -- [targetStarResultsStruct] the outputs in paResultsStruct but with new fields added
%
%*************************************************************************************************************
function targetStarResultsStruct = set_optimalAperture_with_TAD_values(targetStarResultsStruct, paDataObject, iTarget)

    paDataStruct = struct(paDataObject);

    % all values need to be something that Java can handle. So, no empty sets or NaNs

    % These values are not known or computed.
    targetStarResultsStruct.signalToNoiseRatioTimeSeries.values = 0;       
    targetStarResultsStruct.signalToNoiseRatioTimeSeries.gapIndicators = 0;        

    targetStarResultsStruct.fluxFractionInApertureTimeSeries.values = 0;               
    targetStarResultsStruct.fluxFractionInApertureTimeSeries.gapIndicators = 0;         

    targetStarResultsStruct.crowdingMetricTimeSeries.values = 0;               
    targetStarResultsStruct.crowdingMetricTimeSeries.gapIndicators = 0;        

    targetStarResultsStruct.skyCrowdingMetricTimeSeries.values = 0;               
    targetStarResultsStruct.skyCrowdingMetricTimeSeries.gapIndicators = 0;        

    optimalAperture.keplerId                = targetStarResultsStruct.keplerId;
    optimalAperture.signalToNoiseRatio      = paDataStruct.targetStarDataStruct(iTarget).signalToNoiseRatio;
    optimalAperture.fluxFractionInAperture  = paDataStruct.targetStarDataStruct(iTarget).fluxFractionInAperture;
    optimalAperture.crowdingMetric          = paDataStruct.targetStarDataStruct(iTarget).crowdingMetric;
    optimalAperture.skyCrowdingMetric       = paDataStruct.targetStarDataStruct(iTarget).skyCrowdingMetric;
    optimalAperture.badPixelCount           = 0; % This is identically zero in TAD-COA (see extract_optimal_aperture)
    optimalAperture.referenceRow            = paDataStruct.targetStarDataStruct(iTarget).referenceRow;
    optimalAperture.referenceColumn         = paDataStruct.targetStarDataStruct(iTarget).referenceColumn;
    optimalAperture.saturatedRowCount       = paDataStruct.targetStarDataStruct(iTarget).saturatedRowCount;
    optimalAperture.apertureUpdatedWithPaCoa = false;
    optimalAperture.offsets                 = [];

    pixelCounter = 1;
    inOptimalApertureArray = [paDataStruct.targetStarDataStruct(iTarget).pixelDataStruct.inOptimalAperture];
    for iPixel = 1 : length(targetStarResultsStruct.pixelApertureStruct)
        if (inOptimalApertureArray(iPixel))
            optimalAperture.offsets(pixelCounter).row    = ...
                    targetStarResultsStruct.pixelApertureStruct(iPixel).ccdRow    - targetStarResultsStruct.referenceRow;
            optimalAperture.offsets(pixelCounter).column = ...
                    targetStarResultsStruct.pixelApertureStruct(iPixel).ccdColumn - targetStarResultsStruct.referenceColumn;
            pixelCounter  = pixelCounter + 1;
        end
    end

    %***
    % All this to calculate distanceFromEdge
    if (~isempty(optimalAperture.offsets))
        maskedSmear  = paDataStruct.fcConstants.nMaskedSmear;
        leadingBlack = paDataStruct.fcConstants.nLeadingBlack;
        nRowPix = paDataStruct.fcConstants.nRowsImaging;
        nColPix = paDataStruct.fcConstants.nColsImaging;
        
        
        apertureRows = optimalAperture.referenceRow     + [optimalAperture.offsets.row]     - maskedSmear;
        apertureCols = optimalAperture.referenceColumn  + [optimalAperture.offsets.column]  - leadingBlack;
        rowDistanceFromEdge = min([min(apertureRows) - 1, nRowPix - max(apertureRows)]);
        colDistanceFromEdge = min([min(apertureCols) - 1, nColPix - max(apertureCols)]);
        optimalAperture.distanceFromEdge = min(rowDistanceFromEdge, colDistanceFromEdge);
        clear paDataStruct;
    else
        % Aperture is empty so just fill with some value that Java will accept (So, no NaNs)
        optimalAperture.distanceFromEdge = 0;
    end
    %***

    targetStarResultsStruct.optimalAperture = optimalAperture;

end % set_optimalAperture_with_TAD_values

end % static methods

%*************************************************************************************************************
%*************************************************************************************************************
%*************************************************************************************************************
methods (Access = 'public')

%*************************************************************************************************************
% Constructor, also does all the processing to find the optimal apertures
%
% Inputs:
%   paDataStruct    -- [struct] the background has not yet been removed form the pixel data

function obj = paCoaClass (paDataObject, backgroundRemovedPixelDataStruct, backgroundPixelValues, backgroundPixelUncertainties, iTarget, figureHandles)

    % Get fields from input object
    % paDataObject is an "old-school" Matlab object. So can only access its fields inside it's methods, so... convert to a struct!
    paDataStruct = struct(paDataObject);

    % Check if this is K2 data.
    obj.isK2Data = paDataStruct.cadenceTimes.midTimestamps(find(~paDataStruct.cadenceTimes.gapIndicators,1))  > ...
                                paDataStruct.fcConstants.KEPLER_END_OF_MISSION_MJD;

    obj.keplerId = paDataStruct.targetStarDataStruct(iTarget).keplerId;

    obj.apertureModelConfigurationStruct = paDataStruct.apertureModelConfigurationStruct;

    obj.paConfigurationStruct = paDataStruct.paConfigurationStruct;

    obj.paCoaConfigurationStruct = paDataStruct.paCoaConfigurationStruct;

    obj.gapFilledTimestamps  = pdc_fill_cadence_times (paDataStruct.cadenceTimes);

    obj.nTargets = length(paDataStruct.targetStarDataStruct);
    obj.nCadences = length(obj.gapFilledTimestamps);
    obj.iTarget = iTarget;

    obj.ccdModule       = paDataStruct.ccdModule;
    obj.ccdOutput       = paDataStruct.ccdOutput;
    obj.cadenceType     = paDataStruct.cadenceType;
    obj.prfModel        = paDataStruct.prfModel;
    obj.fcConstants     = paDataStruct.fcConstants;
    obj.cadenceTimes    = paDataStruct.cadenceTimes;
    obj.motionPolyStruct = paDataStruct.motionPolyStruct;

    obj.gapFillConfigurationStruct = paDataStruct.gapFillConfigurationStruct;
    obj.spacecraftConfigurationStruct   = paDataStruct.spacecraftConfigurationStruct;
    obj.gainModel                       = paDataStruct.gainModel;
    obj.readNoiseModel                  = paDataStruct.readNoiseModel;
    obj.linearityModel                  = paDataStruct.linearityModel;
    % if the above TAD-COA parameters are not available then get default values

    obj.withBackgroundTargetDataStruct =  paDataStruct.targetStarDataStruct(iTarget);
    obj.nPixels = length(obj.withBackgroundTargetDataStruct.pixelDataStruct);

    obj.backgroundRemovedPixelDataStruct = backgroundRemovedPixelDataStruct;
    obj.backgroundPixelValues = backgroundPixelValues;
    obj.backgroundPixelUncertainties = backgroundPixelUncertainties;

    % perform_simple_aperture_photomety is awkwardly written. Make sure the proper pixelDataStruct were passed to create this object
    % Parity check: withBackgroundValue = background + backgroundRemovedValue
    tolerance = 1e-6;
    difference = obj.withBackgroundTargetDataStruct.pixelDataStruct(1).values(1) ...
        - obj.backgroundRemovedPixelDataStruct(1).values(1) - obj.backgroundPixelValues(1,1);
    if (abs(difference) > tolerance)
        error ('Looks like the correct values were not passed for the varies pixel values!');
    end

    % TEMP: gap all not fine point
   %for iPixel = 1 : obj.nPixels
   %    obj.withBackgroundTargetDataStruct.pixelDataStruct(iPixel).gapIndicators = paCoaClass.gap_not_fine_point ...
   %            (obj.withBackgroundTargetDataStruct.pixelDataStruct(iPixel).gapIndicators, obj.cadenceTimes);
   %    obj.backgroundRemovedPixelDataStruct(iPixel).gapIndicators = paCoaClass.gap_not_fine_point ...
   %            (obj.backgroundRemovedPixelDataStruct(iPixel).gapIndicators, obj.cadenceTimes);
   %end

    obj.cadencesToFind = false(obj.nCadences,1);
    obj.cadencesToFind(1:obj.paCoaConfigurationStruct.cadenceStep:end) = true;

    % This is for whcih cadences are used to fit RA and Dec (if enabled)
    obj.cadencesForRaDecFitting = false(obj.nCadences,1);
    obj.cadencesForRaDecFitting(1:obj.paCoaConfigurationStruct.raDecFittingCadenceStep:end) = true;

    if (~isempty(figureHandles))
        obj.doPlotFigure = true;
        obj.doSaveFigure = true;
        obj.apertureFigureHandle    = figureHandles(1);
        obj.curveFigureHandle       = figureHandles(2);
        if (paCoaClass.doPlotPrfModelFitting)
            obj.prfModelFigureHandle    = figureHandles(3);
        end
    else
        obj.doPlotFigure = false;
        obj.doSaveFigure = false;
    end

    % Load in Catalog from file, if asked
    if (~isdeployed && obj.doLoadCatalogFile)
        if (obj.isK2Data) 
            S = load(obj.k2CatalogFilename);
            obj.catalog = S.catalog;
            clear S;
        else
            % Kepler Prime data.
            % use big file
            S = load(obj.catalogFilename);
            obj.catalog = S.kic;
            clear S;
        end
        obj.catalog = convert_catalog_to_pa_format(obj.catalog);
    end

    clear paDataStruct;

end

end % public methods

%*************************************************************************************************************
%*************************************************************************************************************
%*************************************************************************************************************
methods (Access = 'private')

%*************************************************************************************************************
% This is the main workhorse of this class. Here we use an SNR test to find the optimal aperture. The SNR numerator is from the model fit to the pixel data but
% the denominator is from the real data (with non-shot noise added in).
%
% Pixel flux values should be in e- per cadence.
%
% Outputs:
%   inOptimalAperturePerCadence  -- [float array(nCadences, nPixels)] The optimial aperture per found cadence
%   pixelAddingOrder   -- [float array(nCadences, nPixels)] The pixel adding order per cadence
%

function obj = find_optimal_aperture_per_cadence_using_snr(obj)

    withBackgroundPixelDataStruct = obj.withBackgroundTargetDataStruct.pixelDataStruct;
    withBackgroundValues    = [withBackgroundPixelDataStruct.values];
    gaps   =  [withBackgroundPixelDataStruct.gapIndicators];

    backgroundRemovedValues = [obj.backgroundRemovedPixelDataStruct.values];
    
    % We need to create a square grid for the sake of the aperture finding algorith.
    % This function finds the mapping
    obj = obj.find_square_grid_parameters ();

    % Get the PRF pixel values for each cadence
    % Find PRF model pixel values from image_modelling code

    % We want the background removed when finding the image so construct a paDataStruct with background removed
    backgroundRemovedTargetStarDataStruct = obj.withBackgroundTargetDataStruct;
    backgroundRemovedTargetStarDataStruct.pixelDataStruct = obj.backgroundRemovedPixelDataStruct;
    paDataStruct = struct('prfModel', obj.prfModel, 'fcConstants', obj.fcConstants, 'cadenceTimes', obj.cadenceTimes, 'targetStarDataStruct', ...
            backgroundRemovedTargetStarDataStruct, 'motionPolyStruct', obj.motionPolyStruct, 'cadenceType', obj.cadenceType, ...
            'apertureModelConfigurationStruct', obj.apertureModelConfigurationStruct, 'paConfigurationStruct', obj.paConfigurationStruct);

    % We are constructing a paDataStruct with only one target so
    targetIndex = 1;
    if (isfield (backgroundRemovedTargetStarDataStruct, 'kics'))
        catalog = backgroundRemovedTargetStarDataStruct.kics;
    elseif (~isdeployed && obj.doLoadCatalogFile)
        catalog = obj.catalog;
        % fill in missing ra and dec in targetStarDataStruct (bug in PaInputsStruct)
        if (isempty(paDataStruct(1).targetStarDataStruct.decDegrees) || paDataStruct(1).targetStarDataStruct.decDegrees == 0)
            targetLocation = find(catalog.kepid == paDataStruct(1).targetStarDataStruct.keplerId);
            if (isempty(targetLocation))
                % Target not found in Catalog. Cannot run if RA, Dec kepmag are empty!
                obj.inOptimalAperturePerCadence = false(obj.nCadences, obj.nPixels); % For all cadences
                obj.inOptimalApertureMedian = false(obj.nPixels,1);
                return;
            end
            paDataStruct(1).targetStarDataStruct.decDegrees = catalog.dec(targetLocation);
            paDataStruct(1).targetStarDataStruct.raHours   = catalog.ra(targetLocation);
            paDataStruct(1).targetStarDataStruct.keplerMag  = catalog.kepmag(targetLocation);
            paDataStruct(1).targetStarDataStruct.kics(1).keplerMag.value = catalog.kepmag(targetLocation);
            paDataStruct(1).targetStarDataStruct.kics(1).ra.value = catalog.ra(targetLocation);
            paDataStruct(1).targetStarDataStruct.kics(1).dec.value = catalog.dec(targetLocation);
        end
    else
        catalog = [];
    end
    fittingEnabled = true;
    [obj.prfModelPixelDataStruct, contributingStarStruct, obj.apertureModelObjectForRaDecFit] = pa_coa_fit_aperture_model(paDataStruct, targetIndex, ...
            obj.cadencesToFind, obj.cadencesForRaDecFitting, fittingEnabled, catalog);

    % If contrubutingStarStruct is empty then pa_coa_fit_aperture_model failed for one reason or another
    if (isempty(contributingStarStruct))
        obj.inOptimalAperturePerCadence = false(obj.nCadences, obj.nPixels); % For all cadences
        obj.inOptimalApertureMedian = false(obj.nPixels,1);
        return;
    else
        % Find the target in the contributingStarStruct
        targetIndex = [contributingStarStruct.keplerId] == obj.withBackgroundTargetDataStruct.keplerId;
        if(isempty(targetIndex) || all(~targetIndex))
            warning('PA-COA: find_prf_pixel_values: could not find the target star in contributingStarStruct!');
            obj.inOptimalAperturePerCadence = false(obj.nCadences, obj.nPixels); % For all cadences
            obj.inOptimalApertureMedian = false(obj.nPixels,1);
            return;
        end
        obj.prfModelTargetStarStruct = contributingStarStruct(targetIndex);
        % Remove the target from the contributing star struct
        obj.prfModelBackgroundStarStruct = contributingStarStruct;
        obj.prfModelBackgroundStarStruct(targetIndex) = [];
    end
    
    % Check if the target magnitude changed by greater than maxDeltaMagnitude   
    if (obj.useMaxDeltaMagnitudeToRevertToCatalogModel && ...
                abs(obj.prfModelTargetStarStruct.updatedMag - paDataStruct(1).targetStarDataStruct.keplerMag) > ...
                        paDataStruct.apertureModelConfigurationStruct.maxDeltaMagnitude)
        % Revert to the catlog target and background values
        targetIndexInPaDataStruct = 1;
        fittingEnabled = false;
        [obj.prfModelPixelDataStruct, contributingStarStruct, obj.apertureModelObjectForRaDecFit] = pa_coa_fit_aperture_model(paDataStruct, ...
            targetIndexInPaDataStruct, obj.cadencesToFind, [], fittingEnabled, catalog);
        
        % If contrubutingStarStruct is empty then pa_coa_fit_aperture_model failed for one reason or another
        if (isempty(contributingStarStruct))
            obj.inOptimalAperturePerCadence = false(obj.nCadences, obj.nPixels); % For all cadences
            obj.inOptimalApertureMedian = false(obj.nPixels,1);
            return;
        else
            % Find the target in the contributingStarStruct
            targetIndex = [contributingStarStruct.keplerId] == obj.withBackgroundTargetDataStruct.keplerId;
            if(isempty(targetIndex) || all(~targetIndex))
                warning('PA-COA: find_prf_pixel_values: could not find the target star in contributingStarStruct!');
                obj.inOptimalAperturePerCadence = false(obj.nCadences, obj.nPixels); % For all cadences
                obj.inOptimalApertureMedian = false(obj.nPixels,1);
                return;
            end
            obj.prfModelTargetStarStruct = contributingStarStruct(targetIndex);
            % Remove the target from the contributing star struct
            obj.prfModelBackgroundStarStruct = contributingStarStruct;
            obj.prfModelBackgroundStarStruct(targetIndex) = [];
        end
    end

    clear backgroundRemovedTargetStarDataStruct paDataStruct;

    %***
    % Loop through each cadence finding the optimal aperture
    obj.snrPerPixel = nan(obj.nCadences, obj.nPixels + length(obj.missingPixelIndices));
    obj.inOptimalAperturePerCadence = false(obj.nCadences, obj.nPixels); % For all cadences
    obj.pixelAddingOrder  = nan(obj.nCadences, obj.nPixels); % For all cadences
    cadenceIndex = 0;
    for iCadence = 1 : obj.nCadences

        if (~obj.cadencesToFind(iCadence))
            continue;
        end

        prfTargetFlux     = zeros(obj.nPixels,1);
        prfOtherFlux      = zeros(obj.nPixels,1);
        prfBackgroundFlux = zeros(obj.nPixels,1);

        cadenceIndex = cadenceIndex + 1;

       %display(['Working on Cadence ', num2str(iCadence), ' of ', num2str(nCadences), ' for target ', num2str(iTarget), ' of ', num2str(nTargets), '.']);

        % Skip cadence gaps
        if (obj.cadenceTimes.gapIndicators(iCadence))
            continue;
        elseif (all(gaps(iCadence,:)))
            continue;
        end

        %********************
        % Collect the relevant data for this cadence
        thisCadenceWithBackgroundValues     = withBackgroundValues(iCadence,:)';
        thisCadenceGaps                     = gaps(iCadence,:)';
        thisCadenceBackgroundRemovedValues  = backgroundRemovedValues(iCadence,:)';
        thisCadenceBackgroundValues         = obj.backgroundPixelValues(iCadence,:)';
        thisCadenceBackgroundUncertainties  = obj.backgroundPixelUncertainties(iCadence,:)';

        thisCadenceWithBackgroundValues(thisCadenceGaps)    = nan;
        thisCadenceBackgroundRemovedValues(thisCadenceGaps) = nan;
        thisCadenceBackgroundValues(thisCadenceGaps)        = nan;
        thisCadenceBackgroundUncertainties(thisCadenceGaps) = nan;

        %***
        % Get the fit PRF flux values for this cadence
        prfTargetFlux     = zeros(obj.nPixels,1);
        prfOtherFlux      = zeros(obj.nPixels,1);
        prfBackgroundFlux = zeros(obj.nPixels,1);
        for iPixel = 1 : obj.nPixels
            prfTargetFlux(iPixel)     = obj.prfModelPixelDataStruct(iPixel).targetFluxEstimates(iCadence );
            prfOtherFlux(iPixel)      = obj.prfModelPixelDataStruct(iPixel).bgStellarFluxEstimates(iCadence );
            prfBackgroundFlux(iPixel) = obj.prfModelPixelDataStruct(iPixel).bgConstFluxEstimates(iCadence );
        end

        % Find the center pixel
        centerRow = obj.prfModelTargetStarStruct.centroidRow(cadenceIndex);
        centerColumn = obj.prfModelTargetStarStruct.centroidCol(cadenceIndex);
        thisCadenceCenterPixelIndex = find(obj.inMaskColumn == round(centerColumn) & obj.inMaskRow == round(centerRow));
        if (isempty(thisCadenceCenterPixelIndex))
            % Center of Target is outside of the mask!
            continue;
        end


        %********************
        % We need to create a square grid for the sake of the aperture finding algorith
        % Fill missing pixels so that we have a true nxm grid
        % Also sort the pixels in proper sub2ind order

        thisCadenceWithBackgroundValues(obj.pixelDataStructPixelMapping) = thisCadenceWithBackgroundValues; % Sort
        thisCadenceWithBackgroundValues(obj.missingPixelIndices) = 0.0;

        thisCadenceBackgroundRemovedValues(obj.pixelDataStructPixelMapping) = thisCadenceBackgroundRemovedValues; % Sort
        thisCadenceBackgroundRemovedValues(obj.missingPixelIndices) = 0.0;
        thisCadenceCenterPixelIndex = obj.pixelDataStructPixelMapping(thisCadenceCenterPixelIndex);
        
        thisCadenceBackgroundValues(obj.pixelDataStructPixelMapping) = thisCadenceBackgroundValues; % Sort
        thisCadenceBackgroundValues(obj.missingPixelIndices) = 0.0;
        
        thisCadenceBackgroundUncertainties(obj.pixelDataStructPixelMapping) = thisCadenceBackgroundUncertainties; % Sort
        thisCadenceBackgroundUncertainties(obj.missingPixelIndices) = 0.0;
        
        %***
        % We also need to order outputs to the PRF fitting
        prfTargetFlux(obj.pixelDataStructPixelMapping) = prfTargetFlux; % Sort
        prfTargetFlux(obj.missingPixelIndices) = 0.0;
        prfOtherFlux(obj.pixelDataStructPixelMapping) = prfOtherFlux; % Sort
        prfOtherFlux(obj.missingPixelIndices) = 0.0;
        prfBackgroundFlux(obj.pixelDataStructPixelMapping) = prfBackgroundFlux; % Sort
        prfBackgroundFlux(obj.missingPixelIndices) = 0.0;
        
        %********************

        % Now formulate the SNR

        numeratorPixelValues    = prfTargetFlux;
        denominatorPixelValues  = thisCadenceWithBackgroundValues;
        

        %********************** 
        % If using a prf model then the model pixel values can approach the background values. When this happens the SNR test becomes unreliable because we are
        % comparing two numbers, one with noise (real pixel values) and the other without (PRF values). If the PRF value is larger than the value of the real
        % pixel value in the denominator then the SNR is artificailly inflated. What we should do is zero the PRF values when they approcah the background noise
        % values.  The real question is when do we "approach" the background values?
        
        %The median value of all background median pixel values
        medianBackgroundValue = median(thisCadenceBackgroundValues(thisCadenceBackgroundValues ~= 0.0));
        medianBackgroundUncertainties = median(thisCadenceBackgroundUncertainties(thisCadenceBackgroundUncertainties ~= 0.0));
        
        % The threshold is 2 sigma in background uncertainty above the background level
        % TODO: make the threshold an input parameter?
        backgroundNoiseThreshold = medianBackgroundValue + 2 * medianBackgroundUncertainties ;
        
        % Zero all PRF values below the background noise threshold
        numeratorPixelValues(numeratorPixelValues < backgroundNoiseThreshold) = 0.0;

        if (all(numeratorPixelValues == 0.0))
            % All PRF model pixel values are below the background!
           %warning('For Kepler Id ', num2str(obj.keplerId), ' all PRF model pixel values are below background! Aperture cannot be found!')
            continue;
        end

        %**********************
       %% Flux, and variance of first (center) pixel
       %centerFlux = numeratorPixelValues(thisCadenceCenterPixelIndex);
       %% Component of variance due to shot noise.
       %% Use the non background corrected flux so that the background shot noise in included
       %centerVariance = denominatorPixelValues(thisCadenceCenterPixelIndex);
        
        % Variance due to non-shot noise terms
        [readNoiseSquared, quantizationNoiseSquared] = obj.find_non_shot_variance (iCadence);
        
        nonShotVariance = readNoiseSquared + quantizationNoiseSquared;


        %**********************
        % Now find the pixel adding order using the SNR test
        % Pick each successive Pixel that maximizes the SNR.
        
        [thisCadencePixelAddingOrder] = obj.find_pixel_adding_order (numeratorPixelValues, denominatorPixelValues, nonShotVariance, thisCadenceCenterPixelIndex);
        
        % Cumulative mean flux
        cumFluxContig=cumsum(numeratorPixelValues(thisCadencePixelAddingOrder));
        
        % Cumulative mean variance estimate: note read noise and quantization noise terms. 
        % TODO: Should add calibration noise terms (from black & smear)
        cumVarContig = cumsum(denominatorPixelValues(thisCadencePixelAddingOrder) + nonShotVariance);
        
        % Compute snr
        obj.snrPerPixel(iCadence, :) = cumFluxContig./sqrt(cumVarContig);
        
        % Locate peak in SNR curve
        [snrPeakIndex] = obj.find_snr_peak (obj.snrPerPixel(iCadence, :));

        % Just in case it picks more pixels then there are real pixels in pixelDataStruct, the max to pick is is nPixels
        snrPeakIndex = min(snrPeakIndex,obj.nPixels);
        
        % Set aperture out to the maximum SNR point
        thisCadenceInOptimalAperture = false(length(numeratorPixelValues),1);
        thisCadenceInOptimalAperture(thisCadencePixelAddingOrder(1:snrPeakIndex)) = true;

        % Remove inserted missing pixels and convert back to pixelDataStruct pixel order
        [obj.inOptimalAperturePerCadence(iCadence,:), obj.pixelAddingOrder(iCadence,:)]= obj.convert_to_pixelDataStruct_indexing ...
                        (thisCadenceInOptimalAperture, thisCadencePixelAddingOrder);

    end % cadence loop
        
    
    % The found optimal aperture is the median aperture found at each cadence
    gaps   =  [obj.withBackgroundTargetDataStruct.pixelDataStruct.gapIndicators];
    starFluxGaps = all(gaps,2);
    if (all(starFluxGaps(obj.cadencesToFind)))
        % all data gapped cannot perform PA-COA
        obj.inOptimalAperturePerCadence = false(obj.nCadences, obj.nPixels); % For all cadences
        obj.inOptimalApertureMedian = false(obj.nPixels,1);
        return;
    end

    % Also find the union of all optimal apertures.
    % Actually, take the 95th percentile union. I.e if less than 5% of cadences use the pixel then don't include in aperture
    obj.inOptimalApertureUnion = false(obj.nPixels,1);
    for iPixel = 1 : obj.nPixels
        if (sum(obj.inOptimalAperturePerCadence((~starFluxGaps & obj.cadencesToFind),iPixel)) > ...
                        floor(0.05 * length(obj.inOptimalAperturePerCadence((~starFluxGaps & obj.cadencesToFind),iPixel))))
            obj.inOptimalApertureUnion(iPixel) = true;
        end
    end

    obj.inOptimalApertureMedian = logical(nanmedian(obj.inOptimalAperturePerCadence((~starFluxGaps & obj.cadencesToFind),:),1)');

    % We can have a situation on some cadences where only some pixels are gapped. The policy is to remove pixels from the aperture if they are gapped on any of
    % these cadences.
    partiallyGappedPixels = false(obj.nPixels,1);
    for iPixel = 1 : obj.nPixels
        partiallyGappedPixels(iPixel) = any(gaps(obj.cadencesToFind & ~starFluxGaps,iPixel));
    end
    obj.inOptimalApertureMedian(partiallyGappedPixels) = false;
    obj.inOptimalApertureUnion(partiallyGappedPixels) = false;

    % If the found optimal aperture is zero then nothing left to do so just return.
    if (~any(obj.inOptimalApertureMedian))
        return;
    end

    % Find the averaged pixel adding order
    % Use the mode, which is like the median but forces it to pick one of the values.
    % We need to make sure there are no duplicates. So, we need to sequentially find the most common entry starting with the first in order, then remove that
    % entry from all subsequent pixels orders
    truncatedPixelAddingOrder = obj.pixelAddingOrder((~starFluxGaps & obj.cadencesToFind),:);
    for iPixel = 1 : obj.nPixels
        obj.pixelAddingOrderMedian(iPixel) = mode(truncatedPixelAddingOrder(:,iPixel));
        % Remove the pixel found for the first in order
        % mode ignored NaNs so replace the already found pixel with NaNs
        % However, if all elements are now nan for this pixel then we have a problem. In this case search for a remaining pixel with the lowest ranking.
        if (isnan(obj.pixelAddingOrderMedian(iPixel)))
            lowestSurvivingRanking =  find(any(~isnan(truncatedPixelAddingOrder)), 1,'first');
            % Take the mode of all entried in this ranking
            obj.pixelAddingOrderMedian(iPixel) = mode(truncatedPixelAddingOrder(:,lowestSurvivingRanking ));
        end
        truncatedPixelAddingOrder(truncatedPixelAddingOrder == obj.pixelAddingOrderMedian(iPixel)) = nan;
    end

    % Calculate averaged snrPerPixel
    obj.snrMedian = nanmedian(obj.snrPerPixel(obj.cadencesToFind,:),1)';

    snrError = nanstd(obj.snrPerPixel(obj.cadencesToFind,:),1)';

    if (obj.doPlotFigure)

        nPixelsInAperture = sum(obj.inOptimalApertureMedian);

        % Plot the found peak
        figure(obj.curveFigureHandle)
        subplot(2,2,2);
        title('Averaged SNR Test over all Computed Cadences');
       %plot(obj.snrMedian, '-*b');
        errorbar(obj.snrMedian, snrError, '-*b');
        hold on;
        plot(nPixelsInAperture,    obj.snrMedian(nPixelsInAperture), 'or', 'MarkerSize',10);
        hold off;
        title(['SNR vs Pixel Number in Aperture for Kepler ID ', num2str(obj.keplerId)]);
        legend('SNR', 'Optimal Aperture', 'Location', 'Best')
        xlabel('Number of pixels in aperture');
        ylabel('SNR')
        grid on;
        hold off;
    end


end % find_optimal_aperture_per_cadence_using_snr

%*************************************************************************************************************
% Used to convert a pixel mask array into a square grid. Locates missing pixels and creates mapping array
%
% Outputs:
%   obj.pixelDataStructPixelMapping = [] % [int array] mapping between the orginal pixel order and the square grid order
%   obj.missingPixelIndices = [] % [int array] indices in the square grid of the pixels missing in the original mask
% 

function obj = find_square_grid_parameters (obj)

    withBackgroundPixelDataStruct = obj.withBackgroundTargetDataStruct.pixelDataStruct;
    obj.inMaskRow     = [withBackgroundPixelDataStruct.ccdRow]';
    obj.inMaskColumn  = [withBackgroundPixelDataStruct.ccdColumn]';

    minRow = min(obj.inMaskRow);
    maxRow = max(obj.inMaskRow);
    minCol = min(obj.inMaskColumn);
    maxCol = max(obj.inMaskColumn);
    obj.nRows       = maxRow - minRow + 1;
    obj.nColumns    = maxCol - minCol + 1;
    rowOffset       = minRow - 1;
    columnOffset    = minCol - 1;

    pixelDataStructAperture         = zeros(obj.nRows, obj.nColumns);
    obj.pixelDataStructPixelMapping = sub2ind([obj.nRows,obj.nColumns],obj.inMaskRow - rowOffset, obj.inMaskColumn - columnOffset);
    pixelDataStructAperture(obj.pixelDataStructPixelMapping) = 1;
    missingPixels                   = ~pixelDataStructAperture;
    obj.missingPixelIndices         = find(missingPixels);

end % create_square_grid

%*************************************************************************************************************
% This function calculates the Read Noise and the quantization noise based on the method as used in TAD-COA coa_matlab_controller
%
%*************************************************************************************************************
function [readNoiseSquared, quantizationNoiseSquared] = find_non_shot_variance (obj, cadenceIndex)

    startMjd = obj.cadenceTimes.midTimestamps(cadenceIndex);

    exposuresPerCadence = obj.spacecraftConfigurationStruct.numExposuresPerCadence;

    % read noise is in ADU, convert to electrons% make a gain object
    gainObject = gainClass(obj.gainModel);
    % gain is electrons per ADU
    gain = get_gain(gainObject, startMjd, obj.ccdModule, obj.ccdOutput);


    % make a read noise object
    noiseObject = readNoiseClass(obj.readNoiseModel);
    % read noise is in ADU, convert to electrons
    readNoisePerExposure = gain*get_read_noise(noiseObject, startMjd, obj.ccdModule, obj.ccdOutput);

    readNoiseSquared = readNoisePerExposure^2 * exposuresPerCadence;

    % make linearity object
    linearityObject = linearityClass(obj.linearityModel);
    polyStruct = get_weighted_polyval_struct(linearityObject, startMjd, obj.ccdModule, obj.ccdOutput);
    maxDnPerExposure = double(get_max_domain(linearityObject, startMjd, obj.ccdModule, obj.ccdOutput));
    wellCapacity = maxDnPerExposure .* gain .* weighted_polyval(maxDnPerExposure, polyStruct);

    BITS_IN_ADC = obj.fcConstants.BITS_IN_ADC;

    quantizationNoiseSquared = ( wellCapacity / (2^BITS_IN_ADC-1))^2 / 12 * exposuresPerCadence;

end % find_non_shot_variance 

%************************************************************************************************************
% Finds the pixel adding order base don a SNR test. The numerator is based on a fit to the PRF model with known background objects removed.
%

function [pixelAddingOrder] = find_pixel_adding_order (obj, numeratorPixelValues, denominatorPixelValues, nonShotVariance, centerPixelIndex)  

    % TODO: Make sure pixelAddingOrder corresponds to workingApertureModel
    
    nTotPixels = length(numeratorPixelValues);

    % convolution mask for selecting contiguous pixels; use cross to prohibit diagonal-only contiguity
    mask = [0,1,0;1,1,1;0,1,0];  

    % Starting values for cumulative flux and variance is the center pixel
    sumFlux = numeratorPixelValues(centerPixelIndex);
    sumVar = denominatorPixelValues(centerPixelIndex) + nonShotVariance;

    % WorkingApertureModel is the aperture model as we add pixels
    workingApertureModel = zeros(obj.nRows, obj.nColumns);
    % Beginning aperture for just the center pixel
    workingApertureModel(centerPixelIndex) = 1;

    % Keep track of the order of pixels as we add them to the optimal aperture
    % We begin with the center pixel
    pixelAddingOrder = zeros(nTotPixels , 1, 'int32');
    pixelAddingOrder(1) = centerPixelIndex;
    
    % Add in each neighboring pixel that increases SNR by the most amount. 
    % Sequentially add all pixels.
    % After the loop we pick the cutoff
    for iPixel = 2 : nTotPixels 
        % Select neigbors of current pixels
        pixelNeighbors = conv2(workingApertureModel,mask,'same');  % pixels contiguous with current aperture
        % Find the new pixels under consideration using linear indexing
        newPotentialPixels = setdiff(find(pixelNeighbors),find(workingApertureModel));

        % Construct arrays of the current signal and variance plus each of the neighboring pixels
        signalArray = sumFlux + numeratorPixelValues(newPotentialPixels);
        varArray    = sumVar + denominatorPixelValues(newPotentialPixels) + nonShotVariance;
        snrArray    = (signalArray)./sqrt(varArray);
        % Pick the pixel that maximizes the SNR
        [~,maxSnrIndex]=max(snrArray);
        bestPixelIndex = newPotentialPixels(maxSnrIndex);
        workingApertureModel(bestPixelIndex) = 1;
        
        % Update running signal & variance totals
        sumFlux = sumFlux + numeratorPixelValues(bestPixelIndex);
        sumVar  = sumVar  + denominatorPixelValues(bestPixelIndex) + nonShotVariance;

        pixelAddingOrder(iPixel) = bestPixelIndex;
    end % loop over pixels
    
end

%************************************************************************************************************
%       [snrPeakIndex] = find_snr_peak_or_inflection (snrContig);
%
% Finds the SNR peak. This is right now a REALLY simple function that just finds the peak value in the snrContig courve.
%
% It could be much more complex. Maybe apply some type of Akaike Information Criterion to pick the best number of pixels. Or, just smooth the curve to remove
% noise?
%
% Inputs:
%   snrContig       -- the contiguous cumulative sum SNR as each pixel is added.
% Outputs:
%   snrPeakIndex    -- Index of peak pixel
%

function [snrPeakIndex] = find_snr_peak (obj, snrContig)

    [~,snrPeakIndex] = max(snrContig);

    % Peak should not be greater than the number of pixels in mask
    snrPeakIndex = min(snrPeakIndex, obj.nPixels);


end % find_snr_peak

%*************************************************************************************************************
%
% The pixelDataStruct is in some odd order. It's not a typical nxm matrix indexing. This function converts from matrix indexing to the pixelDataStruct order. It
% uses the obj.pixelDataStructPixelMapping map to convert to the proper order and obj.missingPixelIndices to remove the pixel in the square grid that are not in
% pixelDataStruct.
%

function [inOptimalAperture, pixelAddingOrder]= convert_to_pixelDataStruct_indexing (obj, thisCadenceInOptimalAperture, thisCadencePixelAddingOrder)

    % Convert to the PixelDataStruct pixel order
    inOptimalAperture = thisCadenceInOptimalAperture(obj.pixelDataStructPixelMapping);

    [~,addingOrderLoc] = ismember(thisCadencePixelAddingOrder, obj.pixelDataStructPixelMapping);

    % Remove missing pixels
    pixelAddingOrder = addingOrderLoc(addingOrderLoc~=0);

end % convert_to_pixelDataStruct_indexing 

%*************************************************************************************************************
% Takes the current found optimal aperture as the starting point then adjusts the aperture based on <pixeAddingOrdeer> while monitoring the CDPP computed by
% calculate_cdpp_wrapper. Stops when minimum CDPP is found.
%
% Outputs:
%   obj.inOptimalApertureMedianCdppOptimized 
%
%*************************************************************************************************************
function obj = optimize_aperture_with_cdpp (obj)

    backgroundRemovedValues = [obj.backgroundRemovedPixelDataStruct.values]';
    gaps                    = [obj.backgroundRemovedPixelDataStruct.gapIndicators]';

    % Summing flux so zero gaps
    backgroundRemovedValues(gaps) = 0.0;

    % The initial number of pixels in aperture
    nPixelsInitial = sum(obj.inOptimalApertureMedian);

    % Sweep through all pixels lengths and calculate CDPP
    cdpp = nan(obj.nPixels,1);
    startNPixels = max(nPixelsInitial - obj.paCoaConfigurationStruct.cdppSweepLength,1);
    endNPixels   = min(nPixelsInitial + obj.paCoaConfigurationStruct.cdppSweepLength,obj.nPixels);
    prfOtherFlux      = zeros(obj.nCadences,1);
    for nPixels = startNPixels : endNPixels 
    
        currentFlux = sum(backgroundRemovedValues(obj.pixelAddingOrderMedian(1:nPixels),:),1)';

        currentGaps = any(gaps(obj.pixelAddingOrderMedian(1:nPixels),:),1)';

        cdppTemp = obj.calculate_cdpp (currentFlux, currentGaps);

        cdpp(nPixels) = cdppTemp.rms;

    end

    %***
    % Create a smoothed CDPP
    if (obj.isK2Data)
        medianWindow = round(length(cdpp(~isnan(cdpp))) / 10);
        medianWindow = max(medianWindow, 5); % Filter no less than 5
        smoothedCdpp = medfilt1_soc(cdpp, medianWindow);
    else
        sgPolyOrder = 3;
        % window must be larger than sgPolyOrder
        sgWindow = round(max(sgPolyOrder+1, length(cdpp(~isnan(cdpp))) / 5));
        % window must be odd
        if (mod(sgWindow,2) == 0)
            sgWindow = sgWindow + 1;
        end
        smoothedCdpp = sgolayfilt(cdpp, sgPolyOrder, sgWindow);
    end


    % Minimize the product of the CDPP and the SNR
    % The combination of the two protects the routine from engulfing background objects.
    snrMedianNormalized = obj.snrMedian(1:obj.nPixels) - nanmean(obj.snrMedian(1:obj.nPixels));
    snrRange = range(snrMedianNormalized);
    cdppRange = range(smoothedCdpp);
    snrMedianNormalized = snrMedianNormalized / snrRange * cdppRange;
    adjustedCdppCurve = smoothedCdpp - (snrMedianNormalized * obj.paCoaConfigurationStruct.cdppVsSnrStrengthFactor);
    [cdppMin, cdppMinLoc] = min(adjustedCdppCurve);

   % Remove long term trend with smoothed curve in order to capture noise
    cdppDetrended = cdpp - smoothedCdpp;

    % Only look at real CDPP values (no NaNs)
    realCdppLocs = find(~isnan(cdppDetrended));
    cdppDetrended = cdppDetrended(realCdppLocs);

    % Note this is actually the RMS on the CDPP RMS!
    cdppRms = norm(cdppDetrended) / sqrt(length(realCdppLocs));

    % Estimate the spread in the CDPP curve.

    % If the found CDPP minimum is within the CDPP noise spread of the initial CDPP then keep the initial.
    if (cdppMin > cdpp(nPixelsInitial) - cdppRms)
        cdppMinLoc = nPixelsInitial;
    end

    % TODO: if cdppmin is the last value in the adjustedCdppCurve then we are probably doing something wrong and maybe engulfing a background object. 
    % In this case keep the initial aperture from the SNR test.
    
    obj.inOptimalApertureMedianCdppOptimized  = false(obj.nPixels,1);
    obj.inOptimalApertureMedianCdppOptimized (obj.pixelAddingOrderMedian(1:cdppMinLoc)) = true;

    if (obj.doPlotFigure)
        figure(obj.curveFigureHandle);
        subplot(2,2,4);
        plot(cdpp,'*');
        hold on;
        plot(smoothedCdpp,'-m');
        plot(adjustedCdppCurve, '-c');
        plot(nPixelsInitial, adjustedCdppCurve(nPixelsInitial), 'or', 'MarkerSize', 10);
        plot(cdppMinLoc, adjustedCdppCurve(cdppMinLoc), 'ok', 'MarkerSize', 12);
        grid on;
        legend('CDPP', 'Smoothed CDPP', 'Smoothed Adjusted CDPP', 'SNR-Based Aperture', 'CDPP-Based Aperture', 'Location', 'North');
        title(['CDPP vs Pixel Number in Aperture for Target ', num2str(obj.iTarget)]);
        xlabel('Number of pixels in aperture');
        ylabel('Quasi-CDPP RMS');
        maxRange =  find(~isnan(cdpp), 1, 'last');
        xlim([0 maxRange]);
        hold off
    end

end % optimize_aperture_with_cdpp 

%*************************************************************************************************************
% Calculates the Fluc Fraction and Crowding Metric based in the PRF model image fit per cadence
%
% If reverting to TAd aperture then this will still compute the flux fraction and crowding metric for the TAD aperture.
%
% Outputs:
%   obj.fluxFractionTimeSeries      -- [float array(nCadences)] only set for obj.cadencesToFind cadences, otherwise, set to zeros
%   obj.crowdingMetricTimeSeries    -- [float array(nCadences)] only set for obj.cadencesToFind cadences, otherwise, set to zeros
%   obj.skyCrowdingMetricTimeSeries -- [float array(nCadences)] only set for obj.cadencesToFind cadences, otherwise, set to zeros
%
%*************************************************************************************************************

function obj = find_flux_fraction_and_crowding_metric (obj)

    obj.fluxFractionTimeSeries = nan(obj.nCadences,1);
    obj.crowdingMetricTimeSeries = nan(obj.nCadences,1);
    obj.skyCrowdingMetricTimeSeries = nan(obj.nCadences,1);

    cadenceIndexInContributingStarStruct = 0;
    for iCadence = 1 : obj.nCadences

        if (~obj.cadencesToFind(iCadence))
            continue;
        end

        cadenceIndexInContributingStarStruct = cadenceIndexInContributingStarStruct + 1;

        % Find the calculated flux in the aperture from the target and from the background
        inApertureFromTarget     = 0.0;   
        inApertureFromBackground = 0.0;
        totalFluxFromTarget     = 0.0;   
        totalFluxFromBackground = 0.0;
        for iPixel = 1 : length(obj.prfModelPixelDataStruct)
            if (obj.inOptimalAperture(iPixel))
                inApertureFromTarget     = inApertureFromTarget     + obj.prfModelPixelDataStruct(iPixel).targetFluxEstimates(iCadence);
                inApertureFromBackground = inApertureFromBackground + obj.prfModelPixelDataStruct(iPixel).bgStellarFluxEstimates(iCadence);
            end
            totalFluxFromTarget     = totalFluxFromTarget     + obj.prfModelPixelDataStruct(iPixel).targetFluxEstimates(iCadence);
            totalFluxFromBackground = totalFluxFromBackground + obj.prfModelPixelDataStruct(iPixel).bgStellarFluxEstimates(iCadence);
        end
        
        targetStarFlux = obj.prfModelTargetStarStruct.totalFlux(cadenceIndexInContributingStarStruct);
        
        obj.fluxFractionTimeSeries(iCadence) = inApertureFromTarget / targetStarFlux;

        % Actually check if fraction is greater than 1.001 to account for potential uncertainty error.
        if (obj.fluxFractionTimeSeries(iCadence) > 1.001)
            display(['Flux Fraction greater than 1.0 for target index ', num2str(obj.iTarget)]);
        end
        
        obj.crowdingMetricTimeSeries(iCadence)    = inApertureFromTarget / (inApertureFromBackground + inApertureFromTarget);
        obj.skyCrowdingMetricTimeSeries(iCadence) = totalFluxFromTarget / (totalFluxFromBackground + totalFluxFromTarget);

        if (obj.crowdingMetricTimeSeries(iCadence) > 1.001)
            display(['Crowding Metric greater than 1.0 for target index ', num2str(obj.iTarget)]);
        end
        
        if (obj.skyCrowdingMetricTimeSeries(iCadence) > 1.001)
            display(['Sky Crowding Metric greater than 1.0 for target index ', num2str(obj.iTarget)]);
        end
        

    end

    % Plot the Flux Fraction and Crowding Metric
    if (obj.doPlotFigure)
        figure(obj.curveFigureHandle);
        subplot(5,2,[7 9]);
        if (~all(obj.cadencesToFind))
            hold off
            plot(obj.fluxFractionTimeSeries,    '-*k')
            hold on;
            plot(obj.crowdingMetricTimeSeries,  '-*m')
        else
            hold off
            plot(obj.fluxFractionTimeSeries,    '-k')
            hold on;
            plot(obj.crowdingMetricTimeSeries,  '-m')
        end
        title('Flux Fraction and Crowding Metric');
        legend('Flux Fraction', 'Crowding Metric');
        xlabel('Cadences Index');
        ylabel('Flux Fraction or Crowding Metric');
        hold off
    end
    
    % Zero the Nans for the benefit of the archiver
    obj.fluxFractionTimeSeries(isnan(obj.fluxFractionTimeSeries)) = 0;
    obj.crowdingMetricTimeSeries(isnan(obj.crowdingMetricTimeSeries)) = 0;
    obj.skyCrowdingMetricTimeSeries(isnan(obj.skyCrowdingMetricTimeSeries)) = 0;


end % find_flux_fraction_and_crowding_metric 

%*************************************************************************************************************
% Plots the mean pixel values for an aperture. 
%
% Plots the TAD optimal aperture and the new found optimal aperture. Plots the backgroudn removed pixel values as the backdrop.
%
% Also plot the found center.
%
% Since the aperture is found for each cadence what is plotted here is actually the median flux and found apertures
%
% If target is saturated then plot the log10 of the median
%
%*************************************************************************************************************

function [] = plot_pixel_array (obj)

    if (~obj.doPlotFigure)
        return;
    end

    if (obj.withBackgroundTargetDataStruct.saturatedRowCount > 0)
        isSaturatedTarget = true;
    else
        isSaturatedTarget = false;
    end

    tadOptimalAperture      = [obj.backgroundRemovedPixelDataStruct.inOptimalAperture];
    paOptimalAperture       = obj.inOptimalApertureMedian;
    paUnionOptimalAperture  = obj.inOptimalApertureUnion;
    cdppOptimalAperture     = obj.inOptimalApertureMedianCdppOptimized;

    backgroundRemovedPixelValues        = [obj.backgroundRemovedPixelDataStruct.values]';
    gaps                                = [obj.backgroundRemovedPixelDataStruct.gapIndicators]';
    % Gap all cadences not finding aperture on
    gaps = gaps | repmat(~obj.cadencesToFind',[obj.nPixels,1]);

    % Taking median so nan gaps
    backgroundRemovedPixelValues(gaps)  = nan;
    backgroundRemovedPixelValuesMedian  = nanmedian(backgroundRemovedPixelValues,2);

    prfModelPixelValues = zeros(obj.nPixels,1);
    for iPixel = 1 : obj.nPixels
       prfModelPixelValues(iPixel)     = nanmedian(obj.prfModelPixelDataStruct(iPixel).targetFluxEstimates(obj.cadencesToFind));
    end

    minRow = min(obj.inMaskRow);
    maxRow = max(obj.inMaskRow);
    minCol = min(obj.inMaskColumn);
    maxCol = max(obj.inMaskColumn);
    aperturePixelValues = zeros([obj.nRows, obj.nColumns]);
    aperturePixelIndices = sub2ind([obj.nRows, obj.nColumns], obj.inMaskRow - minRow + 1, obj.inMaskColumn - minCol + 1);
    aperturePixelValues(aperturePixelIndices) = backgroundRemovedPixelValuesMedian  ;

    prfPixelValuesGrid = zeros([obj.nRows, obj.nColumns]);
    if (isSaturatedTarget)
        prfModelPixelValues(prfModelPixelValues<1.0) = 1.0;
        prfPixelValuesGrid(aperturePixelIndices) = abs(log10(prfModelPixelValues));
    else
        prfPixelValuesGrid(aperturePixelIndices) = prfModelPixelValues;
    end

    figure(obj.apertureFigureHandle)

    hold off;
    if (isSaturatedTarget)
        aperturePixelValues(aperturePixelValues<1.0) = 1.0;
        imagesc([minCol; maxCol], [minRow; maxRow], abs(log10(aperturePixelValues)));
    else
        imagesc([minCol; maxCol], [minRow; maxRow], aperturePixelValues);
    end
    set(gca,'YTick',[minRow:maxRow]);
    set(gca,'XTick',[minCol:maxCol]);
    set(gca, 'YDir', 'normal');
    colorbar;
    if (obj.mnrChosenRevertToTad)
        title(['Median Raw Pixel Values (Background Removed) for Target ', num2str(obj.iTarget), '; Chosen Aperture = ', obj.selectedAperture, '; MNR Chosen']);
    elseif (isSaturatedTarget)
        title(['Median Log10 Raw Pixel Values (Background Removed) for Target ', num2str(obj.iTarget), '; Chosen Aperture = ', obj.selectedAperture]);
    else
        title(['Median Raw Pixel Values (Background Removed) for Target ', num2str(obj.iTarget), '; Chosen Aperture = ', obj.selectedAperture]);
    end
    xlabel('CCD Column (1-based)');
    ylabel('CCD Row (1-based)');

    hold on;

    % plot the target pixel model (PRF model values)
    contour([minCol: maxCol], [minRow: maxRow], prfPixelValuesGrid, 'LineColor', 'black');

    % Plot the center
   %centerRow       = nanmedian(obj.prfModelTargetStarStruct.centroidRow);
   %centerColumn    = nanmedian(obj.prfModelTargetStarStruct.centroidCol);
   %plot(centerColumn, centerRow, '*w', 'MarkerSize',10);

    % Track the center
    centerRow       = obj.prfModelTargetStarStruct.centroidRow;
    centerColumn    = obj.prfModelTargetStarStruct.centroidCol;
    % Remove gapped pixels, The centroids are interpolated.
    starFluxGaps = any(gaps,1);
    centerRow(starFluxGaps(obj.cadencesToFind)) = [];
    centerColumn(starFluxGaps(obj.cadencesToFind)) = [];
    plot(centerColumn, centerRow, '.w', 'MarkerSize',20);
        
    % plot the median center of the background objects
    backgroundMedianCenterRow    = nanmedian([obj.prfModelBackgroundStarStruct.centroidRow]);
    backgroundMedianCenterColumn = nanmedian([obj.prfModelBackgroundStarStruct.centroidCol]);
    plot(backgroundMedianCenterColumn, backgroundMedianCenterRow, '.k', 'MarkerSize',20);

    % Plot the median pixel adding order
    textOffset = 0.3; % in units of pixels
    for iPixel = 1 : length(obj.pixelAddingOrderMedian)
        text(obj.inMaskColumn(obj.pixelAddingOrderMedian(iPixel)) + textOffset, obj.inMaskRow(obj.pixelAddingOrderMedian(iPixel))+textOffset, num2str(iPixel), ...
                                    'HorizontalAlignment', 'left', 'BackgroundColor', 'w', 'FontSize', 7);
    end

    % Plot the TAD Optimal Aperture
    plot(obj.inMaskColumn(tadOptimalAperture), obj.inMaskRow(tadOptimalAperture), '+w', 'MarkerSize',15, 'MarkerEdgeColor','w');

    % Plot the Found Optimal Aperture
    if (strcmp(obj.selectedAperture, 'Haloed'))
        plot(obj.inMaskColumn(obj.inOptimalApertureHaloed), obj.inMaskRow(obj.inOptimalApertureHaloed), 'sw', 'MarkerSize',25, 'MarkerEdgeColor','w');
        if (isempty(backgroundMedianCenterColumn))
            legendHandle = legend('PRF Model Values', 'Found Center', 'TAD Optimal Aperture', 'TAD Haloed Optimal Aperture');
        else
            legendHandle = legend('PRF Model Values', 'Found Center', 'Background Median Centers', 'TAD Optimal Aperture', 'TAD Haloed Optimal Aperture');
        end
    else
        plot(obj.inMaskColumn(paOptimalAperture), obj.inMaskRow(paOptimalAperture), 'xw', 'MarkerSize',25, 'MarkerEdgeColor','w');
        plot(obj.inMaskColumn(cdppOptimalAperture), obj.inMaskRow(cdppOptimalAperture), 'ow', 'MarkerSize',25, 'MarkerEdgeColor','w');
        plot(obj.inMaskColumn(paUnionOptimalAperture), obj.inMaskRow(paUnionOptimalAperture), 'dw', 'MarkerSize',25, 'MarkerEdgeColor','w');
        if (isempty(backgroundMedianCenterColumn))
            legendHandle = legend('PRF Model Values', 'Found Center', 'TAD Optimal Aperture', 'PA SNR Optimal Aperture', ...
                            'PA CDPP Optimal Aperture', 'PA Union Aperture');
        else
            legendHandle = legend('PRF Model Values', 'Found Center', 'Background Median Centers', 'TAD Optimal Aperture', 'PA SNR Optimal Aperture', ...
                            'PA CDPP Optimal Aperture', 'PA Union Aperture');
        end
    end

    hold off;

    set(legendHandle, 'Color', [0.45, 0.45, 0.45])

    % Plot the PRF modelling fitting if asked to do so
    % Plot the middle cadence
    if (obj.doPlotPrfModelFitting)
        figure(obj.prfModelFigureHandle)
        obj.apertureModelObjectForRaDecFit.plot_star_locations_on_image(round(sum(obj.cadencesForRaDecFitting)/2), obj.keplerId);
    end


end

%*************************************************************************************************************
% Plot the scene for each evaluated cadence.
%
% For diagnostic purposes, not for standard runs.
%
%*************************************************************************************************************
function [] = plot_pixel_array_per_cadence (obj)

    if (~obj.doPlotFigure || ~obj.doPlotImagePerCadence)
        return;
    end

    tadOptimalAperture      = [obj.backgroundRemovedPixelDataStruct.inOptimalAperture];
    paUnionOptimalAperture  = obj.inOptimalApertureUnion;
    cdppOptimalAperture     = obj.inOptimalApertureMedianCdppOptimized;

    backgroundRemovedPixelValues        = [obj.backgroundRemovedPixelDataStruct.values]';
    gaps                                = [obj.backgroundRemovedPixelDataStruct.gapIndicators]';
    % Gap all cadences not finding aperture on
    gaps = gaps | repmat(~obj.cadencesToFind',[obj.nPixels,1]);

    minRow = min(obj.inMaskRow);
    maxRow = max(obj.inMaskRow);
    minCol = min(obj.inMaskColumn);
    maxCol = max(obj.inMaskColumn);
    aperturePixelValues = zeros([obj.nRows, obj.nColumns]);
    aperturePixelIndices = sub2ind([obj.nRows, obj.nColumns], obj.inMaskRow - minRow + 1, obj.inMaskColumn - minCol + 1);

    prfArrayPixelIndices = 1:sum(obj.cadencesToFind);
    cadenceCount = 0;
    for iCadence = 1 : obj.nCadences

        if (~obj.cadencesToFind(iCadence))
            continue;
        end
        cadenceCount = cadenceCount + 1;

        if (obj.cadenceTimes.gapIndicators(iCadence))
            continue;
        elseif (all(gaps(:, iCadence)))
            continue;
        end

        paPerCadenceOptimalAperture = obj.inOptimalAperturePerCadence(iCadence,:);
        if (all(~paPerCadenceOptimalAperture))
            continue;
        end
        prfModelPixelValues = zeros(obj.nPixels,1);
        for iPixel = 1 : obj.nPixels
            prfModelPixelValues(iPixel)     = obj.prfModelPixelDataStruct(iPixel).targetFluxEstimates(iCadence);
        end
        aperturePixelValues(aperturePixelIndices) = backgroundRemovedPixelValues(:,iCadence);

        prfPixelValuesGrid = zeros([obj.nRows, obj.nColumns]);
        prfPixelValuesGrid(aperturePixelIndices) = prfModelPixelValues;

        figure(obj.apertureFigureHandle)

        hold off;
        imagesc([minCol; maxCol], [minRow; maxRow], aperturePixelValues);
        set(gca,'YTick',[minRow:maxRow]);
        set(gca,'XTick',[minCol:maxCol]);
        set(gca, 'YDir', 'normal');
        colorbar;
        title(['Pixel Values (Background Removed) for Target ', num2str(obj.iTarget), '; For Cadence ', num2str(iCadence), ' of ' num2str(obj.nCadences)]);
        xlabel('CCD Column (1-based)');
        ylabel('CCD Row (1-based)');
        
        hold on;
        
        % plot the target pixel model (PRF model values)
        contour([minCol: maxCol], [minRow: maxRow], prfPixelValuesGrid, 'LineColor', 'black');
        
        % plot the center
        centerRow       = obj.prfModelTargetStarStruct.centroidRow(prfArrayPixelIndices(cadenceCount));
        centerColumn    = obj.prfModelTargetStarStruct.centroidCol(prfArrayPixelIndices(cadenceCount));
        plot(centerColumn, centerRow, '*w', 'MarkerSize',10);
            
        % Plot the TAD Optimal Aperture
       %plot(obj.inMaskColumn(tadOptimalAperture), obj.inMaskRow(tadOptimalAperture), '+w', 'MarkerSize',15, 'MarkerEdgeColor','w');
        
        % Plot the Found Optimal Aperture
        plot(obj.inMaskColumn(paPerCadenceOptimalAperture), obj.inMaskRow(paPerCadenceOptimalAperture), 'xw', 'MarkerSize',25, 'MarkerEdgeColor','w');
       %plot(obj.inMaskColumn(cdppOptimalAperture), obj.inMaskRow(cdppOptimalAperture), 'ow', 'MarkerSize',25, 'MarkerEdgeColor','w');
       %plot(obj.inMaskColumn(paUnionOptimalAperture), obj.inMaskRow(paUnionOptimalAperture), 'dw', 'MarkerSize',25, 'MarkerEdgeColor','w');
        
        textOffset = 0.3; % in units of pixels
        for iPixel = 1 : obj.nPixels
            text(obj.inMaskColumn(obj.pixelAddingOrder(iCadence, iPixel)) + textOffset, ...
                 obj.inMaskRow   (obj.pixelAddingOrder(iCadence, iPixel)) + textOffset, num2str(iPixel), ...
                                        'HorizontalAlignment', 'left', 'BackgroundColor', 'w');
        end
        
        hold off;
        
        legendHandle = legend('PRF Model Values', 'Found Center', 'PA SNR Optimal Aperture');
       %legendHandle = legend('PRF Model Values', 'Found Center', 'TAD Optimal Aperture', 'PA SNR Optimal Aperture', 'PA CDPP Optimal Aperture');
        set(legendHandle, 'Color', [0.45, 0.45, 0.45])

        pause;
    end

end

%*************************************************************************************************************
% Plots the resultant light curves from 1) TAD-COA, 2) PA-COA from SNR and 3) PA-COA from CDPP
%
%*************************************************************************************************************

function [] = plot_light_curve (obj)

    if (~obj.doPlotFigure)
        return;
    end

    % The mean flux values can be dramatically different since different number of pixels are added together. 
    % We need to normalize the mean flux values before plotting (calculate_cdpp normalizes internally)
    tadFluxNorm         = mapNormalizeClass.normalize_value (obj.tadFlux,       nanmedian(obj.tadFlux), [], [], [], 'median');

    figure(obj.curveFigureHandle)
    subplot(5,2,[1 3 5]);
    hold off;
    plot(tadFluxNorm, '-b');
    hold on;
    if (strcmp(obj.selectedAperture, 'Haloed'))
        haloedFluxNorm      = mapNormalizeClass.normalize_value (obj.haloedFlux,    nanmedian(obj.haloedFlux), [], [], [], 'median');
        % We simply added a Halo around the TAD aperture
        plot(haloedFluxNorm, '-g');
        L = legend( ['TAD SAP quasi-CDPP rms                  = ', num2str(obj.tadCdpp.rms, '%5.5g')], ...
                    ['Haloed TAD SAP quasi-CDPP rms           = ', num2str(obj.haloedCdpp.rms, '%5.5g')], ...
                    'Location', 'SouthOutside');
    else
        paSnrFluxNorm       = mapNormalizeClass.normalize_value (obj.paSnrFlux,     nanmedian(obj.paSnrFlux), [], [], [], 'median');
        paCdppFluxNorm      = mapNormalizeClass.normalize_value (obj.paCdppFlux,    nanmedian(obj.paCdppFlux), [], [], [], 'median');
        paUnionFluxNorm     = mapNormalizeClass.normalize_value (obj.paUnionFlux,   nanmedian(obj.paUnionFlux), [], [], [], 'median');
        plot(paSnrFluxNorm, '-r');
        plot(paCdppFluxNorm, '-c');
        plot(paUnionFluxNorm, '-k');
        L = legend( ['TAD SAP quasi-CDPP rms                  = ', num2str(obj.tadCdpp.rms, '%5.5g')], ...
                    ['PA SAP quasi-CDPP rms                   = ', num2str(obj.paSnrCdpp.rms, '%5.5g')], ...
                    ['PA SAP CDPP Optimized quasi-CDPP rms    = ', num2str(obj.paCdppCdpp.rms, '%5.5g')], ...
                    ['PA Union SAP quasi-CDPP rms             = ', num2str(obj.paUnionCdpp.rms, '%5.5g')], ...
                    'Location', 'SouthOutside');
    end
    set(L,'FontName','FixedWidth')
    if (obj.mnrChosenRevertToTad)
        title (['Median Normalized Flux Values. Target index ', num2str(obj.iTarget), '; Chosen Aperture = ', obj.selectedAperture, '; MNR Chosen']);
    else
        title (['Median Normalized Flux Values. Target index ', num2str(obj.iTarget), '; Chosen Aperture = ', obj.selectedAperture]);
    end
    xlabel('Cadences Index');
    ylabel('Flux [Median Normalized]');

end % plot_light_curve

%*************************************************************************************************************
function [] = save_figure (obj, figureHandle, figureType)

    % Do nothing if figures are turned off
    if (~obj.doSaveFigure)
        return;
    end

    % check if path exist, if not create it
   %directory = fullfile(obj.saveFigureDirectory, ['map_plots/', obj.runLabel, '/']);
    directory = 'pa_coa_plots';
    if (~exist(directory, 'dir'))
        mkdir(directory);
    end
    filename = ['pa_coa_target_', num2str(obj.iTarget), '_', figureType];
    fullFilename = fullfile(directory, filename);
    saveas (figureHandle, fullFilename, 'fig');
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
function [cdpp] = calculate_cdpp (obj, flux, gaps)

    %***
    % Massage the data to be ready for CDPP
    flux(gaps) = nan;

    % The mean flux values can be dramatically different since different number of pixels are added together. We need to normalize the mean flux values
    flux   = mapNormalizeClass.normalize_value (flux, nanmedian(flux), [], [], [], 'median');
 
    % NaNs will "NaN" the medfilt1 values within obj.paCoaConfigurationStruct.cdppMedFiltSmoothLength cadences from each NaNed cadence, so we need to simply fill the gaps
    % Further down we fill gaps better
    if (~isempty(flux(~gaps)))
        flux(gaps)   = interp1(obj.gapFilledTimestamps (~gaps), flux(~gaps), obj.gapFilledTimestamps (gaps), 'pchip');
    end
 
    fluxDetrended  = flux - medfilt1_soc(flux, obj.paCoaConfigurationStruct.cdppMedFiltSmoothLength);
 
    % Need
    % maxCorrelationWindowLimit           = maxCorrelationWindowXFactor * maxArOrderLimit;
    % To be larger than the largest gap
    % Make local copy of gapFillConfigurationStruct so we can edit it
    gapFillConfigurationStruct = obj.gapFillConfigurationStruct;
    gapFillConfigurationStruct.maxCorrelationWindowXFactor = 300 / gapFillConfigurationStruct.maxArOrderLimit;
 
    % Ignore any leading gaps, the gap filler does not like it.
    firstNonGappedCadence = find(~gaps,1);
    [fluxDetrended] = fill_short_gaps(fluxDetrended(firstNonGappedCadence:end), gaps(firstNonGappedCadence:end), 0, false, gapFillConfigurationStruct, []);

    %******
    % TODO: TEST! REMNOVE!!!!!!!!
   %fluxDetrended = pdc_fill_data_gaps(fluxDetrended, gaps, 0, [], gapFillConfigurationStruct, false, 0);
    %******
    % TODO: TEST! REMNOVE!!!!!!!!


    %***
    % Compute the current CDPP
    tpsModuleParameters.usePolyFitTransitModel  = obj.paCoaConfigurationStruct.usePolyFitTransitModel ;
    tpsModuleParameters.superResolutionFactor  = obj.paCoaConfigurationStruct.superResolutionFactor ;
    tpsModuleParameters.varianceWindowLengthMultiplier = obj.paCoaConfigurationStruct.varianceWindowLengthMultiplier;
    tpsModuleParameters.waveletFilterLength = obj.paCoaConfigurationStruct.waveletFilterLength;
    cadencesPerHour = 1 / (median(diff(obj.gapFilledTimestamps))*24);
 
    if (~isnan(fluxDetrended))
        % Ignore the edge effects by only looking at the center portion
        fluxTimeSeries.values = fluxDetrended(max(firstNonGappedCadence, obj.paCoaConfigurationStruct.cdppMedFiltSmoothLength): ...
                                                end-obj.paCoaConfigurationStruct.cdppMedFiltSmoothLength);
        cdpp = calculate_cdpp_wrapper (fluxTimeSeries, cadencesPerHour, obj.paCoaConfigurationStruct.trialTransitPulseDurationInHours, tpsModuleParameters);
    else
        cdpp.values = 0.0;
        cdpp.rms = nan;
    end

end % calculate_cdpp

%*************************************************************************************************************
% function populate_results_Struct ()
%
% This returns the results struct with all the wanted fields:
%
% Outputs:
%   
%   resultsStruct   -- [struct] WIth the following fields:
%       .iTarget            -- [int] index of target under study in inputsStruct.targetStarDataStruct
%       .apertureUpdated    -- [logical] True if PA-COA found a new aperture
%       .inOptimalAperture  -- [logical array(nPixels)] which pixels in the newely found optimal aperture
%       .inOptimalApertureMedian    -- [logical array(nPixels)] the optimal aperture found using the SNR test
%       .inOptimalApertureMedianCdppOptimized -- [logical array(nPixels)] the optimal aperture found using the CDPP optimizer
%       .inOptimalApertureUnion    -- [logical array(nPixels)] the optimal aperture found as the union of the SNR test for each cadence
%       .fluxFractionTimeSeries     -- [double array(nCadences)] The flux fraction in aperture
%       .crowdingMetricTimeSeries   -- [double array(nCadences)] The crowding metric
%       .skyCrowdingMetricTimeSeries   -- [double array(nCadences)] The sky crowding metric
%       .snrTimeSeries              -- [double array(nCadences)] the SNR for the found aperture per cadence (if using CDPP optimizer then uses that aperture)
%       .gapIndicators              -- [logical array(nCadences)] gap indicators for the above time series
%       .selectedAperture       -- [char] the selected aperture {'TAD', 'SNR', 'CDPP', 'Union', maybe add others...}
%       .apertureModelObjectForRaDecFit    -- [apertureModelObjectForRaDecFit] The object from the PRF image fitting 
%
%*************************************************************************************************************
function resultsStruct = populate_results_struct (obj)

    resultsStruct = struct(...
        'iTarget', obj.iTarget, ...
        'apertureUpdated', false, ...
        'inOptimalAperture', [], ...
        'inOptimalApertureMedian', [], ...
        'inOptimalApertureMedianCdppOptimized', [], ...
        'fluxFractionTimeSeries', [], ...
        'crowdingMetricTimeSeries', [], ...
        'skyCrowdingMetricTimeSeries', [], ...
        'snrTimeSeries', [], ...
        'gapIndicators', []);


    resultsStruct.inOptimalApertureMedian               = obj.inOptimalApertureMedian;
    resultsStruct.inOptimalApertureMedianCdppOptimized  = obj.inOptimalApertureMedianCdppOptimized;
    resultsStruct.inOptimalApertureUnion                = obj.inOptimalApertureUnion;
    resultsStruct.selectedAperture                      = obj.selectedAperture;
    resultsStruct.inOptimalAperture                     = obj.inOptimalAperture;

    % Just in case we are seperately requesting to revert...
    if (obj.revertToTadAperture)
        resultsStruct.inOptimalAperture = [obj.backgroundRemovedPixelDataStruct.inOptimalAperture];
        resultsStruct.selectedAperture = 'TAD';
    end

    % If the found optimal aperture is not empty then we found a new aperture (assume empty is bad)
    if (any(resultsStruct.inOptimalAperture) && ~obj.revertToTadAperture)
        resultsStruct.apertureUpdated = true;
    else
        obj.revertToTadAperture = true;
        resultsStruct.apertureUpdated = false;
        resultsStruct.inOptimalAperture = [obj.backgroundRemovedPixelDataStruct.inOptimalAperture];
        resultsStruct.selectedAperture = 'TAD';
    end

    % The SNR for the found aperture as a function of cadence
    numPixels = sum(resultsStruct.inOptimalAperture);
    resultsStruct.snrTimeSeries = zeros(obj.nCadences,1);
    if (~isempty(obj.snrPerPixel))
        if (numPixels > 0)
            for iCadence = 1 : obj.nCadences
                if (obj.cadencesToFind(iCadence))
                    resultsStruct.snrTimeSeries(iCadence) = obj.snrPerPixel(iCadence,numPixels);
                end
            end
        end
    end
    % The Java exporter does not like NaNs
    resultsStruct.snrTimeSeries(isnan(resultsStruct.snrTimeSeries)) = 0;
    
    gaps   =  [obj.withBackgroundTargetDataStruct.pixelDataStruct.gapIndicators];
    starFluxGaps = any(gaps,2);
    resultsStruct.gapIndicators = starFluxGaps | ~obj.cadencesToFind;
    
    if (isempty(obj.fluxFractionTimeSeries))
        resultsStruct.fluxFractionTimeSeries = zeros(obj.nCadences,1);
    else
        resultsStruct.fluxFractionTimeSeries = obj.fluxFractionTimeSeries;
    end

    if (isempty(obj.crowdingMetricTimeSeries))
        resultsStruct.crowdingMetricTimeSeries = zeros(obj.nCadences,1);
    else
        resultsStruct.crowdingMetricTimeSeries = obj.crowdingMetricTimeSeries;
    end

    if (isempty(obj.skyCrowdingMetricTimeSeries))
        resultsStruct.skyCrowdingMetricTimeSeries = zeros(obj.nCadences,1);
    else
        resultsStruct.skyCrowdingMetricTimeSeries = obj.skyCrowdingMetricTimeSeries;
    end

    resultsStruct.apertureModelObjectForRaDecFit = obj.apertureModelObjectForRaDecFit;

end % populate_results_struct

%*************************************************************************************************************
function obj = add_halo_to_aperture (obj, apertureToUse)

    % All neighboring pixels
    mask = [1,1,1;1,1,1;1,1,1];  

    obj = find_square_grid_parameters (obj);

    % start with the apertureToUse and Map to a square grid
    workingApertureLinear(obj.pixelDataStructPixelMapping) = apertureToUse;

    workingApertureModel= zeros(obj.nRows, obj.nColumns);
    workingApertureModel(workingApertureLinear) = 1;

    for iHalo = 1 : obj.paCoaConfigurationStruct.numberOfHalosToAddToAperture
        % Add halos
        pixelNeighbors = conv2(workingApertureModel,mask,'same');  % pixels contiguous with current aperture
        workingApertureModel(find(pixelNeighbors)) = 1;
    end

    obj.inOptimalAperture = false(obj.nPixels,1);
    % Convert to the PixelDataStruct pixel order
    obj.inOptimalAperture = logical(workingApertureModel(obj.pixelDataStructPixelMapping));
    obj.inOptimalApertureHaloed = obj.inOptimalAperture;

    obj.selectedAperture = 'Haloed';

end % add_halo_to_aperture

%*************************************************************************************************************
% function obj = force_contiguous_aperture ()
%
% We want our apertures to be contiguous. When taking the average aperture and there is large motion then the averaged aperture can be non-contiguous. This
% function will remove the non-contiguous pixels in obj.inOptimalApertureMedian, obj.inOptimalApertureMedianCdppOptimized and obj.inOptimalApertureUnion . 
%
% Outputs:
%   obj.inOptimalApertureMedian                         -- [logical array(nPixels)] non-contiguous pixels removed
%   obj.inOptimalApertureUnion                          -- [logical array(nPixels)] non-contiguous pixels removed
%   obj.inOptimalApertureMedianCdppOptimized            -- [logical array(nPixels)] non-contiguous pixels removed
%
%*************************************************************************************************************

function obj = force_contiguous_aperture (obj)

    %***
    % This is all for the median and CDPP apertures

    removedNonContiguousApertureMedian = false(obj.nPixels,1);
    removedNonContiguousApertureCdpp = false(obj.nPixels,1);

    % We need to first map the pixels to a square grid
    orderedOptimalApertureMedian(obj.pixelDataStructPixelMapping) = obj.inOptimalApertureMedian;
    orderedOptimalApertureMedian(obj.missingPixelIndices) = false;
    orderedOptimalApertureCdpp(obj.pixelDataStructPixelMapping) = obj.inOptimalApertureMedianCdppOptimized;
    orderedOptimalApertureCdpp(obj.missingPixelIndices) = false;
    
    orderedPixelAddingOrder = obj.pixelDataStructPixelMapping(obj.pixelAddingOrderMedian);

    % Find pixels that are non contiguous
    % Only do this if there is more than one pixel in aperture

    for iPixel  = 2 : length(orderedPixelAddingOrder)
        % work on pixels in pixel adding order
        pixelIndex = orderedPixelAddingOrder(iPixel);

        % This is for the median aperture
        if (orderedOptimalApertureMedian(pixelIndex))
            % Check if there is at least one solid edge neighboring pixel also in the aperture
            % And that the neighboring pixels are of a smaller adding order (so we don't keep multi-pixel islands)
            workingApertureModel= false(obj.nRows, obj.nColumns);
            workingApertureModel(orderedPixelAddingOrder(1:iPixel)) = true;
            % Remove the already removed pixels!
            workingApertureModel(obj.pixelDataStructPixelMapping(removedNonContiguousApertureMedian)) = false;
            [I,J] = ind2sub(size(workingApertureModel),pixelIndex);
            if (    (~(I-1 >= 1)                                   || ~workingApertureModel(I-1,J)) && ...
                    (~(I+1 <= length(workingApertureModel(:,1)))   || ~workingApertureModel(I+1,J)) && ...
                    (~(J-1 >= 1)                                   || ~workingApertureModel(I,J-1)) && ...
                    (~(J+1 <= length(workingApertureModel(1,:)))   || ~workingApertureModel(I,J+1)) )
                obj.inOptimalApertureMedian(obj.pixelAddingOrderMedian(iPixel)) = false;
                removedNonContiguousApertureMedian(obj.pixelAddingOrderMedian(iPixel)) = true;

            end
        end

        if (orderedOptimalApertureCdpp(pixelIndex))
            % Check if there is at least one solid edge neighboring pixel also in the aperture
            % And that the neighboring pixels are of a smaller adding order (so we don't keep multi-pixel islands)
            workingApertureModel= false(obj.nRows, obj.nColumns);
            workingApertureModel(orderedPixelAddingOrder(1:iPixel)) = true;
            % Remove the already removed pixels!
            workingApertureModel(obj.pixelDataStructPixelMapping(removedNonContiguousApertureCdpp)) = false;
            [I,J] = ind2sub(size(workingApertureModel),pixelIndex);
            if (    (~(I-1 >= 1)                                   || ~workingApertureModel(I-1,J)) && ...
                    (~(I+1 <= length(workingApertureModel(:,1)))   || ~workingApertureModel(I+1,J)) && ...
                    (~(J-1 >= 1)                                   || ~workingApertureModel(I,J-1)) && ...
                    (~(J+1 <= length(workingApertureModel(1,:)))   || ~workingApertureModel(I,J+1)) )
                obj.inOptimalApertureMedianCdppOptimized(obj.pixelAddingOrderMedian(iPixel)) = false;
                removedNonContiguousApertureCdpp(obj.pixelAddingOrderMedian(iPixel)) = true;

            end
        end
    end

    %***
    % This is for the Union aperture

    % Find the center pixel
    centerRow       = nanmedian(obj.prfModelTargetStarStruct.centroidRow);
    centerColumn    = nanmedian(obj.prfModelTargetStarStruct.centroidCol);
    centerPixelIndex = find(obj.inMaskColumn == round(centerColumn) & obj.inMaskRow == round(centerRow));
    centerPixelIndex = obj.pixelDataStructPixelMapping(centerPixelIndex);

    % We need to first map the pixels to a square grid
    orderedOptimalApertureUnion(obj.pixelDataStructPixelMapping) = obj.inOptimalApertureUnion;
    orderedOptimalApertureUnion(obj.missingPixelIndices) = false;
    initialApertureModel= false(obj.nRows, obj.nColumns);
    initialApertureModel(orderedOptimalApertureUnion) = true;
    workingApertureModel= zeros(obj.nRows, obj.nColumns);
    workingApertureModel(centerPixelIndex) = 1;

    % convolution mask for selecting contiguous pixels; use cross to prohibit diagonal-only contiguity
    mask = [0,1,0;1,1,1;0,1,0];  
    % Keep all pixels that are connected to the center.
    for iPixel  = 2 : length(orderedOptimalApertureUnion)
        % Pixels contiguous with current aperture
        pixelNeighbors = conv2(workingApertureModel,mask,'same');
        % Add those that are in the initial aperture
        workingApertureModel = double(workingApertureModel | (pixelNeighbors & initialApertureModel));
    end

    linearWorkingApertureModel = logical(workingApertureModel(:));
    % Convert to the PixelDataStruct pixel order
    obj.inOptimalApertureUnion = linearWorkingApertureModel(obj.pixelDataStructPixelMapping);



end % force_contiguous_aperture

%*************************************************************************************************************
% function paCoaObject = paCoaObject.select_best_aperture()
%
% Compares the CDPP from the found aperture and the TAD aperture. Chooses the one that is better (lower CDPP).
%
% This function then uses a logistic regression fit predictor to identify the small number of cases where reverting to TAD should occur due to a poorly found
% new aperture, despite the lower CDPP. See KSOC-4639 for details.
% 
% paCoaClass.populate_results_struct populates inOptimalAperture based on the results of this function.
%
% Outputs:
%   obj.revertToTadAperture -- [logical]
%
%*************************************************************************************************************
function obj = select_best_aperture(obj)

    % Some big number to signify an error in the CDPP calculation
    BIGNUMBER = 1e10;

    tadOptimalAperture = [obj.backgroundRemovedPixelDataStruct.inOptimalAperture];

    paCdppOptimalAperture = obj.inOptimalApertureMedianCdppOptimized;

    paSnrOptimalAperture = obj.inOptimalApertureMedian;

    paUnionOptimalAperture = obj.inOptimalApertureUnion;

    % If all the newely found apertures are all empty then revert to TAD.
    if (~any(paSnrOptimalAperture) && ~any(paCdppOptimalAperture) && ~any(paUnionOptimalAperture))
        obj.revertToTadAperture = true;
        obj.selectedAperture = 'TAD';
        return;
    end

    backgroundRemovedPixelValues        = [obj.backgroundRemovedPixelDataStruct.values]';
    gaps                                = [obj.backgroundRemovedPixelDataStruct.gapIndicators]';
    % Summing so zero gaps
    backgroundRemovedPixelValues(gaps)  = 0.0;

    obj.tadFlux     = sum(backgroundRemovedPixelValues(tadOptimalAperture,:),1)';
    obj.paSnrFlux   = sum(backgroundRemovedPixelValues(paSnrOptimalAperture,:),1)';
    obj.paCdppFlux  = sum(backgroundRemovedPixelValues(paCdppOptimalAperture,:),1)';
    obj.paUnionFlux = sum(backgroundRemovedPixelValues(paUnionOptimalAperture,:),1)';

    tadGaps     = any(gaps(tadOptimalAperture,:),1)';
    paSnrGaps   = any(gaps(paSnrOptimalAperture,:),1)';
    paCdppGaps  = any(gaps(paCdppOptimalAperture,:),1)';
    paUnionGaps = any(gaps(paUnionOptimalAperture,:),1)';

    obj.tadFlux(tadGaps)         = nan;
    obj.paSnrFlux(paSnrGaps)     = nan;
    obj.paCdppFlux(paCdppGaps)   = nan;
    obj.paUnionFlux(paUnionGaps) = nan;

    % Find the CDPP for each light curve
    obj.tadCdpp     = obj.calculate_cdpp (obj.tadFlux, tadGaps);
    obj.paSnrCdpp   = obj.calculate_cdpp (obj.paSnrFlux, paSnrGaps);
    obj.paCdppCdpp  = obj.calculate_cdpp (obj.paCdppFlux, paCdppGaps);
    obj.paUnionCdpp = obj.calculate_cdpp (obj.paUnionFlux, paUnionGaps);

    % Find the uncertainty in the CDPP calculation
    cdpp = obj.paSnrCdpp.values;
    sgPolyOrder = 3;
    % window must be larger than sgPolyOrder
    sgWindow = round(max(sgPolyOrder+1, length(cdpp(~isnan(cdpp))) / 5));
    % window must be odd
    if (mod(sgWindow,2) == 0)
        sgWindow = sgWindow + 1;
    end
    smoothedCdpp = sgolayfilt(cdpp, sgPolyOrder, sgWindow);
    % Remove long term trend with smoothed curve in order to capture noise
    cdppDetrended = cdpp - smoothedCdpp;

    % Only look at real CDPP values (no NaNs)
    realCdppLocs = find(~isnan(cdppDetrended));
    cdppDetrended = cdppDetrended(realCdppLocs);

    cdppNoise = norm(cdppDetrended) / sqrt(length(realCdppLocs));

    % In certain circumstances the measured CDPP can be zero (NaNs or zero flux, for example)
    % Very large <BIGNUMBER> CDPP signifies an error. We should not pick the corresponding aperture.
    if (isnan(obj.tadCdpp.rms) || ~isreal(obj.tadCdpp.rms) || isinf(obj.tadCdpp.rms) || obj.tadCdpp.rms == 0)
        obj.tadCdpp.rms = BIGNUMBER;
    end
    if (isnan(obj.paSnrCdpp.rms) || ~isreal(obj.paSnrCdpp.rms) || isinf(obj.paSnrCdpp.rms) || obj.paSnrCdpp.rms == 0)
        obj.paSnrCdpp.rms = BIGNUMBER;
    end
    if (isnan(obj.paCdppCdpp.rms) || ~isreal(obj.paCdppCdpp.rms) || isinf(obj.paCdppCdpp.rms) || obj.paCdppCdpp.rms == 0)
        obj.paCdppCdpp.rms = BIGNUMBER;
    end
    if (isnan(obj.paUnionCdpp.rms) || ~isreal(obj.paUnionCdpp.rms) || isinf(obj.paUnionCdpp.rms) || obj.paUnionCdpp.rms == 0)
        obj.paUnionCdpp.rms = BIGNUMBER;
    end

    % Pick the aperture with lowest CDPP
    
    % Add in the cdppNoise into the TAD CDPP value so that there is a bias toward the new PA-COA
    [minCdppValue, minCdppMethod] = min([obj.tadCdpp.rms + cdppNoise, obj.paSnrCdpp.rms, obj.paCdppCdpp.rms, obj.paUnionCdpp.rms]);

    obj.revertToTadAperture = false;
    if      (minCdppMethod == 1)
        obj.selectedAperture = 'TAD';
        obj.revertToTadAperture = true;
        obj.inOptimalAperture = [obj.backgroundRemovedPixelDataStruct.inOptimalAperture];
    elseif  (minCdppMethod == 2)
        obj.selectedAperture = 'SNR';
        obj.inOptimalAperture = obj.inOptimalApertureMedian;
    elseif  (minCdppMethod == 3)
        obj.selectedAperture = 'CDPP';
        obj.inOptimalAperture = obj.inOptimalApertureMedianCdppOptimized;
    elseif  (minCdppMethod == 4)
        obj.selectedAperture = 'Union';
        obj.inOptimalAperture = obj.inOptimalApertureUnion;
    else
        error ('select_best_aperture: Internal logical error');
    end

    % KSOC-4639
    % Now identify the small number of cases where the new aperture is poor despite the lower CDPP
    betaStruct.mnrBeta0                             = obj.paCoaConfigurationStruct.mnrBeta0;
    betaStruct.mnrAddedFluxBeta                     = obj.paCoaConfigurationStruct.mnrAddedFluxBeta;
    betaStruct.mnrFractionalChangeInApertureBeta    = obj.paCoaConfigurationStruct.mnrFractionalChangeInApertureBeta;
    betaStruct.mnrFractionalChangeInMedianFluxBeta  = obj.paCoaConfigurationStruct.mnrFractionalChangeInMedianFluxBeta;
    betaStruct.mnrMaskUsageRatioBeta                = obj.paCoaConfigurationStruct.mnrMaskUsageRatioBeta;
    betaStruct.mnrDiscriminationThreshold           = obj.paCoaConfigurationStruct.mnrDiscriminationThreshold;

    % Collect the predictors
    [fractionalChangeInAperture fractionalChangeInMedianFlux addedFlux, maskUsageRatio] = paCoaClass.get_fractional_change_in_aperture ...
        (obj.backgroundRemovedPixelDataStruct, obj.inOptimalAperture);

    prediction = paCoaClass.poor_aperture_selection_prediction(betaStruct, addedFlux, fractionalChangeInAperture, ...
                                                    fractionalChangeInMedianFlux, maskUsageRatio);

    if (prediction)
        obj.selectedAperture = 'TAD';
        obj.revertToTadAperture = true;
        obj.inOptimalAperture = [obj.backgroundRemovedPixelDataStruct.inOptimalAperture];
        obj.mnrChosenRevertToTad  = true;
    end
    
    % KSOC-4641: For K2 if the PA-COA aperture is smaller than TAD then just use the TAD aperture.
    if (obj.paCoaConfigurationStruct.revertToTadIfApertureShrank && fractionalChangeInAperture < 0)
        obj.selectedAperture = 'TAD';
        obj.revertToTadAperture = true;
        obj.inOptimalAperture = [obj.backgroundRemovedPixelDataStruct.inOptimalAperture];
        obj.paCoaApertureShrankSoRevertedToTad = true;
    end

end % select_best_aperture

%*************************************************************************************************************
% function [] = save_diagnostic_data (obj)
%
% Saves a bunch of diagnostic data in a struct is a file in the task directory. File name is 'paCoaDiagnosticStruct.mat'
%
% Outputs:
%    paCoaDiagnosticStruct(obj.iTarget)
%       .tadFlux                -- [double array(nCadences)] NaN-Gap filled
%       .paSnrFlux
%       .paCdppFlux
%       .paUnionFlux
%       .tadCdpp                -- [double] just the rms value (to save disk space)
%       .paSnrCdpp
%       .paCdppCdpp
%       .paUnionCdpp
%       .selectedAperture       --  [char] the selected aperture {TAD, SNR, CDPP, Union}.
%       .mnrChosenRevertToTad   -- [logical] If true then the logistical regression discriminator identified this target ad poor and should revert to TAD.
%       .revertToTadAperture    -- [logical] If true then PA-COA determiend the TAD-COA aperture to be supperior
%       .inOptimalAperture      -- [logcial array(nPixel)] The found optimal the corresponds to selectedAperture
%
%*************************************************************************************************************
function [] = save_diagnostic_data (obj)

    filename = 'paCoaDiagnosticStruct.mat';

    if (~exist(filename, 'file'));
        error(['PA-COA: ', filename, ' Does not exist in the task directory']);
    end

    load (filename);

    paCoaDiagnosticStruct(obj.iTarget).tadFlux              = obj.tadFlux;
    paCoaDiagnosticStruct(obj.iTarget).paSnrFlux            = obj.paSnrFlux;
    paCoaDiagnosticStruct(obj.iTarget).paCdppFlux           = obj.paCdppFlux;
    paCoaDiagnosticStruct(obj.iTarget).paUnionFlux          = obj.paUnionFlux;
    paCoaDiagnosticStruct(obj.iTarget).tadCdpp.rms          = obj.tadCdpp.rms;
    paCoaDiagnosticStruct(obj.iTarget).paSnrCdpp.rms        = obj.paSnrCdpp.rms;
    paCoaDiagnosticStruct(obj.iTarget).paCdppCdpp.rms       = obj.paCdppCdpp.rms;
    paCoaDiagnosticStruct(obj.iTarget).paUnionCdpp.rms      = obj.paUnionCdpp.rms;
    paCoaDiagnosticStruct(obj.iTarget).selectedAperture     = obj.selectedAperture;
    paCoaDiagnosticStruct(obj.iTarget).mnrChosenRevertToTad = obj.mnrChosenRevertToTad;
    paCoaDiagnosticStruct(obj.iTarget).revertToTadAperture  = obj.revertToTadAperture;
    paCoaDiagnosticStruct(obj.iTarget).inOptimalAperture    = obj.inOptimalAperture;

   save(filename, 'paCoaDiagnosticStruct');

end % save_diagnostic_data

%*************************************************************************************************************
% function obj = paCoaObject.find_prf_model_but_do_not_find_new_aperture();
%
% For saturated targets for K2 we are adding halos to the TAD aperture. We still need to recompute the flux fraction and crowding metric since the TAD values
% will be for a smaller aperture. This function is to find the PRF model but not compute a new aperture (as is done in 
% find_optimal_aperture_per_cadence_using_snr).
%
% This will also not fit RA/Dec or Kepler mag, basically, it will just evaluate the PRF model liek in TAD.
% 
%*************************************************************************************************************
function obj = find_prf_model_but_do_not_find_new_aperture(obj)

    % Get the PRF pixel values for each cadence
    % Find PRF model pixel values from image_modelling code

    %****************
    %****************
    % We want the background removed when finding the image so construct a paDataStruct with background removed
    backgroundRemovedTargetStarDataStruct = obj.withBackgroundTargetDataStruct;
    backgroundRemovedTargetStarDataStruct.pixelDataStruct = obj.backgroundRemovedPixelDataStruct;
    paDataStruct = struct('prfModel', obj.prfModel, 'fcConstants', obj.fcConstants, 'cadenceTimes', obj.cadenceTimes, 'targetStarDataStruct', ...
            backgroundRemovedTargetStarDataStruct, 'motionPolyStruct', obj.motionPolyStruct, 'cadenceType', obj.cadenceType, ...
            'apertureModelConfigurationStruct', obj.apertureModelConfigurationStruct, 'paConfigurationStruct', obj.paConfigurationStruct);

    % We are constructing a paDataStruct with only one target so
    targetIndex = 1;

    if (isfield (backgroundRemovedTargetStarDataStruct, 'kics'))
        catalog = backgroundRemovedTargetStarDataStruct.kics;
    elseif (~isdeployed && obj.doLoadCatalogFile)
        error('PA-COA: doLoadCatalogFile is not supported for saturated targets');
    else
        catalog = [];
    end
    
    % We want to turn off RA/Dec fitting and Magnitude fitting
    paDataStruct.apertureModelConfigurationStruct.raDecFittingEnabled = false;
    paDataStruct.apertureModelConfigurationStruct.maxDeltaMagnitude   = 0;
    % We want to use the catalog RA/Dec and Magnitude
    fittingEnabled = false;

    [obj.prfModelPixelDataStruct, contributingStarStruct, obj.apertureModelObjectForRaDecFit] = pa_coa_fit_aperture_model(paDataStruct, targetIndex, ...
            obj.cadencesToFind, [], fittingEnabled, catalog);

    % If contrubutingStarStruct is empty then pa_coa_fit_aperture_model failed for one reason or another
    if (isempty(contributingStarStruct))
        obj.inOptimalAperturePerCadence = false(obj.nCadences, obj.nPixels); % For all cadences
        obj.inOptimalApertureMedian = false(obj.nPixels,1);
        return;
    else
        % Find the target in the contributingStarStruct
        targetIndex = [contributingStarStruct.keplerId] == obj.withBackgroundTargetDataStruct.keplerId;
        if(isempty(targetIndex) || all(~targetIndex))
            warning('PA-COA: find_prf_pixel_values: could not find the target star in contributingStarStruct!');
            obj.inOptimalAperturePerCadence = false(obj.nCadences, obj.nPixels); % For all cadences
            obj.inOptimalApertureMedian = false(obj.nPixels,1);
            return;
        end
        obj.prfModelTargetStarStruct = contributingStarStruct(targetIndex);
        % Remove the target from the contributing star struct
        obj.prfModelBackgroundStarStruct = contributingStarStruct;
        obj.prfModelBackgroundStarStruct(targetIndex) = [];
    end
    %****************
    %****************

    % Compute the light curves and CDPP

    tadOptimalAperture = [obj.backgroundRemovedPixelDataStruct.inOptimalAperture];

    % These should all be empty sets
    paCdppOptimalAperture = obj.inOptimalApertureMedianCdppOptimized;
    paSnrOptimalAperture = obj.inOptimalApertureMedian;
    paUnionOptimalAperture = obj.inOptimalApertureUnion;

    backgroundRemovedPixelValues        = [obj.backgroundRemovedPixelDataStruct.values]';
    gaps                                = [obj.backgroundRemovedPixelDataStruct.gapIndicators]';
    % Summing so zero gaps
    backgroundRemovedPixelValues(gaps)  = 0.0;

    obj.tadFlux     = sum(backgroundRemovedPixelValues(tadOptimalAperture,:),1)';
    obj.paSnrFlux   = nan(obj.nCadences,1);
    obj.paCdppFlux  = nan(obj.nCadences,1);
    obj.paUnionFlux = nan(obj.nCadences,1);
    obj.haloedFlux  = sum(backgroundRemovedPixelValues(obj.inOptimalApertureHaloed,:),1)';

    tadGaps     = any(gaps(tadOptimalAperture,:),1)';
    haloedGaps  = any(gaps(obj.inOptimalApertureHaloed,:),1)';

    obj.tadFlux(tadGaps)    = nan;
    obj.haloedFlux(tadGaps) = nan;

    % Find the CDPP for each light curve
    obj.tadCdpp     = obj.calculate_cdpp (obj.tadFlux, tadGaps);
    obj.paSnrCdpp.rms   = 0.0;
    obj.paCdppCdpp.rms  = 0.0;
    obj.paUnionCdpp.rms = 0.0;
    obj.haloedCdpp     = obj.calculate_cdpp (obj.haloedFlux, haloedGaps);


end % find_prf_model_but_do_not_find_new_aperture

%*************************************************************************************************************
% These functions are called twice so should be placed in a function

function [] = generate_plots_and_save_diagnostic_data (obj)

    obj.plot_light_curve;
    obj.plot_pixel_array_per_cadence;
    obj.plot_pixel_array;

    obj.save_figure (obj.apertureFigureHandle, 'aperture');
    obj.save_figure (obj.curveFigureHandle, 'curves');
    if (obj.doPlotPrfModelFitting)
        obj.save_figure (obj.prfModelFigureHandle, 'prf');
    end

    obj.save_diagnostic_data;

end

end % private methods

%*************************************************************************************************************
%*************************************************************************************************************
%*************************************************************************************************************
% These are diagnostic and V&V methods. They are static.

methods (Static=true)

%*************************************************************************************************************
% function [paCoaSummaryStruct] =  examine_performance_for_one_task (nRandomeTargetsToPlotPerSubtask, plottingEnabled, ...
%                                       doPickPoorApertures, betaStruct, plotMNRChosenTargets)
%
% This function is to test the performance of PA from a full task run. It will crawl through each subtask and plot a random selection of targets and then plot
% the overall CDPP metric for both the improved PA-COA apertures and the original TAD-COA apertures.
%
% Note: this function dynamically increases the length of tadCDPP and paCDPP. One could load the pa_state to get the total number of targets but it's such a big
% file that it's probably faster to just increase the struct size dynamically!
%
% Note: The output statistics do NOT contain custom targets. These always revert to TAD apertures. Custom target come with predefined apertures so
% it would be a disservice to recompute them.
%
% Inputs:
%   nRandomeTargetsToPlotPerSubtask -- [int] Number of random targets to plot per subtask. If 0 then plot none but still generate statistics
%   plottingEnabled                 -- [logical] Plots the figures, default = true, If false then only return CDPP values
%   doPickPoorApertures             -- [logical] examine apertures and pick when the aperture was poorly chosen then select the proper aperture
%   betaStruct      --  [struct] The four model coefficients plus the descrimination threshold. If not provided then the values in inputsStruct will be used
%       .mnrBeta0                               -- [double] constant offset
%       .mnrAddedFluxBeta                       -- [double]
%       .mnrFractionalChangeInApertureBeta      -- [double]
%       .mnrFractionalChangeInMedianFluxBeta    -- [double]
%       .mnrMaskUsageRatioBeta                  -- [double]
%       .mnrDiscriminationThreshold             -- [double] Threshold value to returning a true prediction
%   plotMNRChosenTargets            -- [logical] Plot targets that had reverted to TAD from the MNR Logical Regression test
%   excludeCustomTargets            -- [logical] If true, custom targets are excluded from all calculations (default = false).
%
% Outputs:
%   paCoaSummaryStruct              -- [struct]
%     .fractionRevertedToTad          -- [double] fraction of targets that reverted to the TAD apertures [0,1], This number excludes custom targets and saturated
%                                        targets which always revert to TAD.
%     .quarter                        -- [int]
%     .ccdModule                      -- [int] This CCD Module index
%     .ccdOutput                      -- [int] This CCD Output index
%     .targetData                     -- [struct(nTotalTargets)]
%       .keplerId                       -- [int]
%       .keplerMag                      -- [double]
%       .raHours                        -- [double]
%       .decDegrees                     -- [double]
%       .tadCDPP                        -- [double] returns an array of the TAD-COA CDPP values for all targets in this task
%       .paCDPP                         -- [double] returns an array of the PA-COA  CDPP values for all targets in this task
%       .fractionalChangeInAperture     -- [double] fracitonal change in aperture between TAD and PA
%       .maskUsageRatio                 -- [double] fraction of mask in new PA aperture
%       .fractionalChangeInMedianFlux   -- [double] fracitonal change in Flux between TAD and PA
%       .addedFlux                      -- [double] The amount of flux (absolute) added with the new aperture
%       .rssFluxDiff                    -- [double] RSS of the difference between the TAD and PA light curves
%       .revertedToTad                  -- [logical] Target aperture reverted to TAD
%       .isCustomTarget                 -- [logical]
%       .isSaturatedTarget              -- [logical]
%       .targetIndex                    -- [int] this target index in the subtask
%       .taskDir                        -- [char] task directory path for this target
%       .figuresCreated                 -- [logcial] If the figures were created. Impies PA-COA ran to completion for this target.
%       .chosenAperture                 -- [char] The chosen aperture
%       .predictedPoorChoice            -- [double] Result of the logistical regression analysis on each target for reverting to TAD
%       .diagnosticPlotsShown           -- [logical] true if this target's diagnostic plots were selected to be shown
%       .incorrectlyChoseAperture       -- [logical] a flag to indicate the incorrect aperture was chosen (based on visual inspection)
%       .theCorrectAperture             -- [char] on visual inspection, the correct aperture {'TAD', 'SNR', 'CDPP', 'Union'}
% 
%*************************************************************************************************************

function [paCoaSummaryStruct] = examine_performance_for_one_task (nRandomeTargetsToPlotPerSubtask, plottingEnabled, ...
                                        doPickPoorApertures, betaStruct, plotMNRChosenTargets, excludeCustomTargets)

    apertureOptions = {'TAD', 'SNR', 'CDPP', 'Union'};

    % Begin with default values if PA-COA did not run on a target
    perTargetDataStruct = struct('keplerId', [], 'tadCDPP', NaN, 'paCDPP', NaN, 'fractionalChangeInAperture', 0, 'maskUsageRatio', 0, 'keplerMag', NaN, ...
                                 'raHours', [], 'decDegrees', [], ...
                                 'fractionalChangeInMedianFlux', 0, 'addedFlux', 0.0, 'rssFluxDiff', 0, ...
                                 'revertedToTad', true, 'isCustomTarget', [], 'isSaturatedTarget', [], 'targetIndex', NaN, ...
                                 'taskDir', [], 'figuresCreated', false, 'chosenAperture', 'TAD', 'predictedPoorChoice', -1, 'diagnosticPlotsShown', false, ...
                                 'incorrectlyChoseAperture', false, 'theCorrectAperture', []);
    paCoaSummaryStruct = struct('targetData', perTargetDataStruct, 'fractionRevertedToTad', [], 'ccdModule', [], 'ccdOutput', [], 'quarter', []); 

    % Find all subtasks
    dirNames = dir('st-*');
    nDirs = length(dirNames);

    if (length(dirNames) < 1)
        error ('There appears to be no sub-task directories!');
    end

    % This is optional if it's fast enough
    % Get the total number of targets
    %paTargetStarResultsStruct = load('pa_state.mat', 'paTargetStarResultsStruct');
    %nTotTargets =  length(paTargetStarResultsStruct.paTargetStarResultsStruct);
    nTempTargets  = 2; % Just enough to create the struct

    if (~exist('plotMNRChosenTargets'))
        plotMNRChosenTargets = false;
    end

    if (~exist('plottingEnabled'))
        plottingEnabled = true;
    end

    if (~exist('excludeCustomTargets', 'var'))
        excludeCustomTargets = false;
    end
    
    % Collect light curves for CDPP comparison
    iTotTarget = 1;
    % Plot some aperture figures
    
    firstSubTask = true;
    aperturePosition = [];
    for iDir = 1 : nDirs
        cd (dirNames(iDir).name);

        % Only process "TARGETS" subtasks
        if (~exist('processingState_TARGETS.mat', 'file'))
            cd ../
            continue;
        end

        % Get the mod.out and number of targets
        outputsStruct = load('pa-outputs-0.mat');
        outputsStruct = outputsStruct.outputsStruct;
        inputsStruct = load('pa-inputs-0.mat');
        inputsStruct = inputsStruct.inputsStruct;
        nTargetsThisSubTask = length(outputsStruct.targetStarResultsStruct);
        if (firstSubTask)
            % Determine if this is K2 data
            thisIsK2Data = inputsStruct.cadenceTimes.midTimestamps(find(~inputsStruct.cadenceTimes.gapIndicators,1))  > ...
                                inputsStruct.fcConstants.KEPLER_END_OF_MISSION_MJD;
            paCoaSummaryStruct.ccdModule = outputsStruct.ccdModule;
            paCoaSummaryStruct.ccdOutput = outputsStruct.ccdOutput;
            if (~thisIsK2Data)  
                % TODO: get convert_from_cadence_to_quarter working with K2 data
                paCoaSummaryStruct.quarter = convert_from_cadence_to_quarter(inputsStruct.startCadence, inputsStruct.cadenceType);
            else
                paCoaSummaryStruct.quarter = 0;
            end
            display(['Working on Quarter ', num2str(paCoaSummaryStruct.quarter), '; mod.out ', ...
                    num2str(paCoaSummaryStruct.ccdModule), '.', num2str(paCoaSummaryStruct.ccdOutput)]);
            firstSubTask = false;
        else
            % Parity check
            % TODO: get convert_from_cadence_to_quarter working with K2 data
            if (~thisIsK2Data && ((paCoaSummaryStruct.ccdModule ~= outputsStruct.ccdModule) || (paCoaSummaryStruct.ccdOutput ~= outputsStruct.ccdOutput) || ...
                (paCoaSummaryStruct.quarter ~= convert_from_cadence_to_quarter(inputsStruct.startCadence, inputsStruct.cadenceType))))
                error('There appears to be more than one quarter or mod.out in this task directory!');
            end
        end

        display(['Working on subtask ', dirNames(iDir).name, '; subtask index ', num2str(iDir), ' of ', num2str(nDirs), '.']); 

        if (plottingEnabled)
            targetsToPlotLocations = randperm(nTargetsThisSubTask);
            targetsToPlotLocations = targetsToPlotLocations(1:min(nRandomeTargetsToPlotPerSubtask,nTargetsThisSubTask));
            targetsToPlot = false(nTargetsThisSubTask,1);
            targetsToPlot(targetsToPlotLocations) = true;
            nPlotTargets = sum(targetsToPlot);
            iPlotTarget = 0;
        end

        % Move into plot sub directory, if it exists. If it doesn't then PA-COA did not perform
        if (exist('pa_coa_plots', 'dir'))
            cd pa_coa_plots
            inPlotDirectory = true;
        else
            inPlotDirectory = false;
        end

        % Plot random targets
        for iTarget = 1 : nTargetsThisSubTask

            % Collect the CDPP information from each figure, irrespective of if we are displaying the plots or not
            % I should have recorded this information in a .mat file in the task directory. Oh, well, get it for the next release
            % For now, find the information in the figure

            isCustomTarget = is_valid_id(outputsStruct.targetStarResultsStruct(iTarget).keplerId, 'custom');
            if excludeCustomTargets && isCustomTarget
                continue;
            end
            
            % Set default values for targetData
            paCoaSummaryStruct.targetData(iTotTarget) = perTargetDataStruct;

            paCoaSummaryStruct.targetData(iTotTarget).isCustomTarget    = isCustomTarget;
            paCoaSummaryStruct.targetData(iTotTarget).isSaturatedTarget = outputsStruct.targetStarResultsStruct(iTarget).optimalAperture.saturatedRowCount > 0;
            paCoaSummaryStruct.targetData(iTotTarget).targetIndex       = iTarget;
            paCoaSummaryStruct.targetData(iTotTarget).taskDir           = pwd;
            paCoaSummaryStruct.targetData(iTotTarget).keplerId          = inputsStruct.targetStarDataStruct(iTarget).keplerId;
            paCoaSummaryStruct.targetData(iTotTarget).keplerMag         = inputsStruct.targetStarDataStruct(iTarget).keplerMag;
            paCoaSummaryStruct.targetData(iTotTarget).raHours           = inputsStruct.targetStarDataStruct(iTarget).raHours;
            paCoaSummaryStruct.targetData(iTotTarget).decDegrees        = inputsStruct.targetStarDataStruct(iTarget).decDegrees;

            % Find the fractional difference in the aperture
            [paCoaSummaryStruct.targetData(iTotTarget).fractionalChangeInAperture paCoaSummaryStruct.targetData(iTotTarget).fractionalChangeInMedianFlux ...
                paCoaSummaryStruct.targetData(iTotTarget).addedFlux, paCoaSummaryStruct.targetData(iTotTarget).maskUsageRatio] = ...
                    paCoaClass.get_fractional_change_in_aperture ...
                (inputsStruct.targetStarDataStruct(iTarget).pixelDataStruct, outputsStruct.targetStarResultsStruct(iTarget).optimalAperture);

            % Logistical Regression model to find when target should revert to TAD
            if (isempty(betaStruct))
                % Try to use inputsStruct values
                if (isfield(inputsStruct.paCoaConfigurationStruct, 'mnrBeta0'))
                    betaStruct.mnrBeta0                            = inputsStruct.paCoaConfigurationStruct.mnrBeta0;                           
                    betaStruct.mnrAddedFluxBeta                    = inputsStruct.paCoaConfigurationStruct.mnrAddedFluxBeta;                   
                    betaStruct.mnrFractionalChangeInApertureBeta   = inputsStruct.paCoaConfigurationStruct.mnrFractionalChangeInApertureBeta;  
                    betaStruct.mnrFractionalChangeInMedianFluxBeta = inputsStruct.paCoaConfigurationStruct.mnrFractionalChangeInMedianFluxBeta;
                    betaStruct.mnrMaskUsageRatioBeta               = inputsStruct.paCoaConfigurationStruct.mnrMaskUsageRatioBeta;              
                    betaStruct.mnrDiscriminationThreshold          = inputsStruct.paCoaConfigurationStruct.mnrDiscriminationThreshold;         
                end
            end
            if (~isempty(betaStruct))
                [prediction paCoaSummaryStruct.targetData(iTotTarget).predictedPoorChoice] = paCoaClass.poor_aperture_selection_prediction (betaStruct, ...
                                                        paCoaSummaryStruct.targetData(iTotTarget).addedFlux, ...
                                                        paCoaSummaryStruct.targetData(iTotTarget).fractionalChangeInAperture, ...
                                                        paCoaSummaryStruct.targetData(iTotTarget).fractionalChangeInMedianFlux, ...
                                                        paCoaSummaryStruct.targetData(iTotTarget).maskUsageRatio);
            end

            % Find the CDPP and chosen aperture from figure
            fileName = ['pa_coa_target_', num2str(iTarget), '_curves.fig'];
            if (exist(fileName, 'file'));
                % Crawl through the figure data to find the legend CDPP values and flux difference RSS
                [paCoaSummaryStruct.targetData(iTotTarget).tadCDPP paCoaSummaryStruct.targetData(iTotTarget).paCDPP ...
                    paCoaSummaryStruct.targetData(iTotTarget).rssFluxDiff paCoaSummaryStruct.targetData(iTotTarget).revertedToTad ...
                    paCoaSummaryStruct.targetData(iTotTarget).figuresCreated paCoaSummaryStruct.targetData(iTotTarget).chosenAperture] = ...
                        paCoaClass.find_cdpp_values_and_flux_from_figure(fileName);

                % Display the figures if this is one of the random ones to display
                if (plotMNRChosenTargets && strcmp(paCoaSummaryStruct.targetData(iTotTarget).chosenAperture, 'TAD; MNR Chosen'))
                    plotThisMNRTarget = true;
                else
                    plotThisMNRTarget = false;
                end
                if (plottingEnabled && (targetsToPlot(iTarget) || plotThisMNRTarget))
                    paCoaSummaryStruct.targetData(iTotTarget).diagnosticPlotsShown = true;
                    curvesFig = openfig(['pa_coa_target_', num2str(iTarget), '_curves.fig']);
                    prfFig = openfig(['pa_coa_target_', num2str(iTarget), '_prf.fig']);
                    apertureFig = openfig(['pa_coa_target_', num2str(iTarget), '_aperture.fig']);
                    % Move figure locations to that of previous figures
                    if (~isempty(aperturePosition))
                        set(apertureFig, 'Position', aperturePosition);
                        set(curvesFig,   'Position', curvesPosition);
                        set(prfFig,      'Position', prfPosition);
                    end
                    
                    iPlotTarget = iPlotTarget + 1;
                    display(['Ploting ', num2str(iPlotTarget), ' of ', num2str(nPlotTargets), '.']);
                    
                    % Display Target info
                    display('*** Target Information ***');
                    paCoaSummaryStruct.targetData(iTotTarget)
                    display('*** Target Information ***');

                    if (doPickPoorApertures)
                        userResponse = input('Enter proper aperture {''TAD'', ''SNR'', ''CDPP'', ''Union''} [ENTER => selected is good]:', 's');
                        if (~isempty(userResponse))
                            betterAperture = find(ismember(apertureOptions, userResponse));
                            while (isempty(betterAperture) && ~isempty(userResponse))
                                display('Invalid aperture choice!');
                                userResponse = input('Enter proper aperture {''TAD'', ''SNR'', ''CDPP'', ''Union''} [ENTER => selected is good]:', 's');
                                betterAperture = find(ismember(apertureOptions, userResponse));
                            end
                        end
                        if (isempty(userResponse))
                            paCoaSummaryStruct.targetData(iTotTarget).incorrectlyChoseAperture = false;
                            paCoaSummaryStruct.targetData(iTotTarget).theCorrectAperture = paCoaSummaryStruct.targetData(iTotTarget).chosenAperture;
                        else
                            paCoaSummaryStruct.targetData(iTotTarget).incorrectlyChoseAperture = true;
                            paCoaSummaryStruct.targetData(iTotTarget).theCorrectAperture = apertureOptions{betterAperture};
                        end
                    else
                        pause;
                    end

                    % Get location of figures, so the next figures will be placed in the same locations
                    aperturePosition = get(apertureFig, 'Position');
                    curvesPosition   = get(curvesFig, 'Position');
                    prfPosition      = get(prfFig, 'Position');
                    
                    close(apertureFig);
                    close(curvesFig);
                    close(prfFig);
                end
            else
                % If there is no figure then PA-COA did not run.
                % Therefore make sure the aperture did not change if this is Kepler data.
                % For K2 data saturated targets a halo is added
                if (~thisIsK2Data && paCoaSummaryStruct.targetData(iTotTarget).fractionalChangeInAperture ~= 0)
                    error('The aperture appears to have changed but PA-COA appears to not have run!');
                end
                % If no figures were created then we reverted to TAD automaticall so set predictedPoorChoise to -1
                prediction = false;
                paCoaSummaryStruct.targetData(iTotTarget).chosenAperture = 'TAD';
                paCoaSummaryStruct.targetData(iTotTarget).predictedPoorChoice = 0;
                
            end

            % If reverted to TAD then we do not want to see fully used apertures.
            if (paCoaSummaryStruct.targetData(iTotTarget).revertedToTad)
                paCoaSummaryStruct.targetData(iTotTarget).maskUsageRatio = NaN;
            end

            iTotTarget = iTotTarget + 1;
        end

        if (inPlotDirectory)
            cd ../..
        else
            cd ..
        end

    end
    
    % Calculate the fraction of (non-custom) targets for which the PA-COA
    % aperture was abandoned in favor of the original TAD aperture. Note
    % that we ALWAYS exclude custom targets from this calculation.
    isCustomIndicators = [paCoaSummaryStruct.targetData.isCustomTarget];
    revertedToTad = [paCoaSummaryStruct.targetData.revertedToTad];
    paCoaSummaryStruct.fractionRevertedToTad = sum(revertedToTad(~isCustomIndicators)) / nnz(~isCustomIndicators);

    % Generate CDPP statistics plot

    if (plottingEnabled)

        modOutString = ['; mod.out ', num2str(paCoaSummaryStruct.ccdModule), '.', num2str(paCoaSummaryStruct.ccdOutput)];
        tadCDPP         = [paCoaSummaryStruct.targetData.tadCDPP];
        paCDPP          = [paCoaSummaryStruct.targetData.paCDPP];
        keplerMag       = [paCoaSummaryStruct.targetData.keplerMag];

        cdppRelDiff = (paCDPP - tadCDPP) ./ tadCDPP;

        % Plot histrograms of the CDPPs
       %maxCdppToPlot = max([prctile(tadCDPP, 95) prctile(paCDPP,95) 400]);
       %reducedTadCDPP = tadCDPP(tadCDPP < maxCdppToPlot );
       %reducedPaCDPP = paCDPP(tadCDPP < maxCdppToPlot );
       %x = [10:10:maxCdppToPlot ];
       %figure;
       %hist(reducedTadCDPP, x);
       %h = findobj(gca,'Type','patch');
       %set(h,'FaceColor','r','EdgeColor','w','facealpha',0.75)
       %hold on;
       %hist(reducedPaCDPP, x);
       %h1 = findobj(gca,'Type','patch');
       %set(h1,'facealpha',0.75);
       %title ('Histogram of TAD-COA and PA-COA results CDPP');
       %legend('TAD CDPP', 'PA-COA CDPP');
       %xlabel('Quasi-CDPP');

        % Plot CDPP vs KeplerMag for TAD and PA-COA and CDPP improvement
        figure;
        subplot(2,1,1)
        plot(keplerMag, tadCDPP, 'b*');
        hold on
        plot(keplerMag, paCDPP, 'r*');
        legend('TAD Aperture', 'PA-COA Aperture');
        title(['CDPP vs Kepler Mag; Tad vs PA-COA apertures', modOutString]);
        xlabel('Kepler Magnitude');
        ylabel('CDPP')
        subplot(2,1,2)
        plot(keplerMag, cdppRelDiff, 'm*');
        title('Relative CDPP Improvement vs Kepler Mag');
        xlabel('Kepler Magnitude');
        ylabel('Relative CDPP Improvement')
        
        % Histogram of relative improvement
        figure;
        hist(cdppRelDiff, [-1:0.005:1]);
        grid on;
        title(['Relative Improvement inCDPP from TAD-COA and PA-COA; Fraction reverted to TAD = ', ...
                    num2str(paCoaSummaryStruct.fractionRevertedToTad), modOutString]);
        xlabel('Relative change in CDPP from TAD-COA to PA-COA');

        % Plot relative change in CDPP
        figure;
        plot(cdppRelDiff, '*')
        title(['Relative Change in CDPP between TAD and PA-COA', modOutString])
        xlabel('Target Index in paCoaSummaryStruct');
        ylabel('Relative Change in CDPP');

        % Plot RSS of flux difference
       %rssFluxDiff = [paCoaSummaryStruct.targetData.rssFluxDiff];
       %figure;
       %plot(rssFluxDiff, '*')
       %title(['RSS of Flux Difference between TAD and PA-COA aperture [Median normalized]', modOutString])
       %xlabel('Target Index in paCoaSummaryStruct');
       %ylabel('RSS [Median normalized]');

        % Plot relative change in aperture
        apertureDiff = [paCoaSummaryStruct.targetData.fractionalChangeInAperture];
        figure;
        plot(apertureDiff, '*')
        title(['Relative Change in Aperture between TAD and PA-COA', modOutString])
        xlabel('Target Index in paCoaSummaryStruct');
        ylabel('Relative Change in Aperture');

        % Plot mask usage ratio
        maskUsageRatio = [paCoaSummaryStruct.targetData.maskUsageRatio];
        figure;
        plot(maskUsageRatio, '*')
        title(['Ratio of Mask in PA Aperture', modOutString])
        xlabel('Target Index in paCoaSummaryStruct');
        ylabel('Ratio of Mask in PA Aperture');

        % Plot relative change in flux
        fluxDiff = [paCoaSummaryStruct.targetData.fractionalChangeInMedianFlux];
        figure;
        plot(fluxDiff, '*')
        title(['Relative Change in Median Flux between TAD and PA-COA', modOutString])
        xlabel('Target Index in paCoaSummaryStruct');
        ylabel('Relative Change in Flux');

        % Plot added flux
        addedFlux = [paCoaSummaryStruct.targetData.addedFlux];
        figure;
        plot(addedFlux, '*')
        title(['Absolute added flux from TAD to PA-COA', modOutString])
        xlabel('Target Index in paCoaSummaryStruct');
        ylabel('Absolute change in flux');

        % Predicted Poor Choice based on Logistical Regressive Model
        if (~isempty(betaStruct))
            predictedPoorChoice = [paCoaSummaryStruct.targetData.predictedPoorChoice];
            figure;
            plot(predictedPoorChoice, '*')
            hold on
            plot([1:length(predictedPoorChoice)], betaStruct.mnrDiscriminationThreshold, '-r');
            legend('Predicted Poor Choice', 'Discrimination threshold');
            title(['Predicted Poor Choice Based on Logistical Regressive Model', modOutString])
            xlabel('Target Index in paCoaSummaryStruct');
            ylabel('Prediction Value');
        end


        % Pie Chart of chosen aperture
        paCoaClass.create_chosenAperture_pie_chart (paCoaSummaryStruct, []);
    end

end % function examine_performance_for_one_task 
         
%*************************************************************************************************************
% function [fractionalChangeInAperture fractionalChangeInFlux] = get_fractional_change_in_aperture (inputPixelDataStruct, outputOptimalAperture)
%
% Looks at the input optimal aperture (from TAD) and the output optimal aperture (either PA-COA or reverted to TAD) and finds the fractional difference in the
% aperture. For example, if the aperture contains the same number of pixels but is offset then the new pixels added in and the old pixel taken out will both
% count toward the fractional change in the aperture. 
%
% The input optimal aperture is stored in a different format than the output optimal aperture. This is unfortunate.
%
% Inputs:
%   inputPixelDataStruct    -- [struct] The inputsStruct pixel data with the logical inOptimalAperture
%   outputOptimalAperture   -- [struct] The output optimalAperture struct in a different format than the input if calling on a completed PA task!
%                               -- OR ---
%                           -- [logical array] if run within PA-COA then the optimal aperture is a logical array
%
% Outputs:
%   fractionalChangeInAperture  -- [double] The fractional chaneg in aperture relative to the TAD aperture
%   fractionalChangeInFlux      -- [double] The median fractional change in flux due to the new aperture relative to the TAD flux
%   addedFlux                   -- [double] The amount of flux (absolute) added with the new aperture
%   maskUsageRatio              -- [double] The ratio of the mask that is in the found optimal aperture
%
%*************************************************************************************************************
function [fractionalChangeInAperture fractionalChangeInFlux addedFlux maskUsageRatio] = ...
                    get_fractional_change_in_aperture (inputPixelDataStruct, outputOptimalAperture)

    % Convert the two optimal aperture into the same format!

    % These are logical arrays of length number of pixels. Order in unimportant for our measurement
    inputInOptimalAperture = [inputPixelDataStruct.inOptimalAperture]';

    if (isstruct(outputOptimalAperture))
        % This is only executed if we care calling this function on outputsStruct
        outputInOptimalAperture = false(1, length(inputInOptimalAperture));
        
        % Use the input pixel order so that the two aperture arrays are in the same order.
        for iPixel = 1 : length(inputPixelDataStruct)
            if (~isempty(outputOptimalAperture.offsets))
                % The input apertures are 0-Based
                outputPixelIndex = find( ...
                    (inputPixelDataStruct(iPixel).ccdRow    ==  outputOptimalAperture.referenceRow    + [outputOptimalAperture.offsets.row]) & ...
                    (inputPixelDataStruct(iPixel).ccdColumn ==  outputOptimalAperture.referenceColumn + [outputOptimalAperture.offsets.column]));
                if (length(outputPixelIndex) > 1)
                    error ('Error finding output optimal aperture from input aperture');
                end
            else
                outputPixelIndex = [];
            end
        
            if (~isempty(outputPixelIndex))
                outputInOptimalAperture(iPixel) = true;
            else
                outputInOptimalAperture(iPixel) = false;
            end
        end
    else
        outputInOptimalAperture = outputOptimalAperture;
    end
    if (~iscolumn(outputInOptimalAperture ))
        outputInOptimalAperture  = outputInOptimalAperture';
    end

    % Calculate fractional change
    % Negative sign means aperture shrank
    fractionalChangeInAperture = sign(sum(outputInOptimalAperture) - sum(inputInOptimalAperture)) * ...
                                    sum(xor(inputInOptimalAperture, outputInOptimalAperture))/ sum(inputInOptimalAperture);

    if (~any(inputInOptimalAperture) && ~any(outputInOptimalAperture))
        fractionalChangeInAperture = 0.0;
    end

    %***
    % Median fracitonal change in flux

    % Zero Gaps for the sake of this sum
    for iPixel = 1 : length(inputPixelDataStruct)
        inputPixelDataStruct(iPixel).values(inputPixelDataStruct(iPixel).gapIndicators) = 0.0;
    end

    fluxOriginalAperture = median(sum([inputPixelDataStruct(inputInOptimalAperture).values], 2));

    fluxNewAperture      = median(sum([inputPixelDataStruct(outputInOptimalAperture).values], 2));

    fractionalChangeInFlux = (fluxNewAperture - fluxOriginalAperture) / fluxOriginalAperture;

    addedPixels = outputInOptimalAperture & ~inputInOptimalAperture;

    if (all(~addedPixels))
        addedFlux = 0;
    else
        addedFlux   = median(sum([inputPixelDataStruct(addedPixels).values], 2));
    end

    % Mask pixel utilization ratio
    maskUsageRatio = sum(outputInOptimalAperture) / length(outputInOptimalAperture);

end

%*************************************************************************************************************
% function [tadCDPP paChosenCDPP rssFluxDiff revertedToTad] = find_cdpp_values_and_flux_from_figure(fileName)
%
% The CDPP data is not saved to the task directory. It is in the 'curves' figure. So, we need to crawl through the figures to find the text that gives the CDPP
% values. 
%
% We also need to find the TAD and chosen PA light curve so that we can find the flux difference RSS
%
% TODO: Save the CDPP values in the task directory!
%
% Inputs:
%   fileName    -- [char] file name for the pa_coa_target_#_curves.fig figure
%
% Outputs:
%   tadCDPP         -- [double] The TAD-COA CDPP value from the figure
%   paChosenCDPP    -- [double] The PA-COA CDPP value from the figure
%   rssFluxDiff     -- [double] RSS of flux difference between TAd and PA-COA apertures.
%   revertedToTad   -- [logcial] True if the chosen aperture was TAD 
%   figuresCreated  -- [logical] If the PA-COA figures were created. Implies PA-COA ran to completion
%   chosenAperture  -- [char] The chosen aperture
%
%*************************************************************************************************************

function [tadCDPP paChosenCDPP rssFluxDiff revertedToTad figuresCreated chosenAperture] = find_cdpp_values_and_flux_from_figure(fileName)

    tadString    = 'TAD SAP quasi-CDPP rms                  = ';
    snrString    = 'PA SAP quasi-CDPP rms                   = ';
    cdppString   = 'PA SAP CDPP Optimized quasi-CDPP rms    = ';
    unionString  = 'PA Union SAP quasi-CDPP rms             = ';
    haloedString = 'Haloed TAD SAP quasi-CDPP rms           = ';
    tadStringLength    = length(tadString);
    snrStringLength    = length(snrString);
    cdppStringLength   = length(cdppString);
    unionStringLength  = length(unionString);
    haloedStringLength = length(haloedString);

    chosenString = 'Chosen Aperture = ';
    chosenStringLength = length(chosenString);

    tadFlux = 0;
    snrFlux = 0;
    cdppFlux = 0;
    unionFlux = 0;
    haloedFlux = 0;
    chosenFlux = 0;

    try
        % open figure as a MAT-file
        figureData = load(fileName, '-mat');
    catch
        warning('Error opening figure file. No data loaded')
        tadCDPP = NaN;
        paChosenCDPP = NaN;
        rssFluxDiff = NaN;
        % If not figures then presumably reverted to TAD
        revertedToTad = true;
        figuresCreated = false;
        return;
    end

    figuresCreated = true;

    fieldNames = fieldnames(figureData);
    if (length(fieldNames) ~= 1)
        error('The figure data has more than one field name. I don''t know what to do!');
    end

    figureData = figureData.(fieldNames{1});

    numberOfMasterChildren = length(figureData.children);

    tadCDPP    = [];
    snrCDPP    = [];
    cdppCDPP   = [];
    unionCDPP  = [];
    haloedCDPP = [];
    chosenAperture = [];

    for iMasterChild = 1 : numberOfMasterChildren

        numberOfGrandChildren = length(figureData.children(iMasterChild).children);

        for iGrandChild = 1 : numberOfGrandChildren

            % Find the proper text strings for CDPP and the light curves
            if (isfield(figureData.children(iMasterChild).children(iGrandChild).properties, 'DisplayName'))
                displayName = figureData.children(iMasterChild).children(iGrandChild).properties.DisplayName;
                if (strncmp(tadString, displayName, tadStringLength))
                    % Extract the CDPP number
                    tadCDPP = str2double(displayName(tadStringLength+1:end));
                    % Extract the light curve
                    tadFlux = figureData.children(iMasterChild).children(iGrandChild).properties.YData;
                elseif (strncmp(snrString, displayName, snrStringLength))
                    snrCDPP = str2double(displayName(snrStringLength+1:end));
                    snrFlux = figureData.children(iMasterChild).children(iGrandChild).properties.YData;
                elseif (strncmp(cdppString, displayName, cdppStringLength))
                    cdppCDPP = str2double(displayName(cdppStringLength+1:end));
                    cdppFlux = figureData.children(iMasterChild).children(iGrandChild).properties.YData;
                elseif (strncmp(unionString, displayName, unionStringLength))
                    unionCDPP = str2double(displayName(unionStringLength+1:end));
                    unionFlux = figureData.children(iMasterChild).children(iGrandChild).properties.YData;
                elseif (strncmp(haloedString, displayName, haloedStringLength))
                    haloedCDPP = str2double(displayName(haloedStringLength+1:end));
                    haloedFlux = figureData.children(iMasterChild).children(iGrandChild).properties.YData;
                end
            end

            % Find the chosen aperture
            if( isfield(figureData.children(iMasterChild).children(iGrandChild).properties, 'String'))
                stringIndex = strfind( figureData.children(iMasterChild).children(iGrandChild).properties.String, chosenString);
                if (~isempty(stringIndex))
                    chosenAperture = figureData.children(iMasterChild).children(iGrandChild).properties.String(stringIndex+chosenStringLength:end);
                end
            end

        end
    end

    if(isempty(tadCDPP))
        error('tadCDPP is empty!');
    end

    if (isempty(chosenAperture))
        error('Could not find the chosen aperture in the figure!');
    end

    % Save the CDPP for the chosen aperture
    revertedToTad = false;
    switch chosenAperture
        case 'TAD'
            paChosenCDPP  = tadCDPP;
            revertedToTad = true;
            chosenFlux    = tadFlux;
        case 'TAD; MNR Chosen'
            paChosenCDPP  = tadCDPP;
            revertedToTad = true;
            chosenFlux    = tadFlux;
        case 'SNR'
            if(isempty(snrCDPP))
                error('snrCDPP is empty!');
            end
            paChosenCDPP = snrCDPP;
            chosenFlux   = snrFlux;
        case 'CDPP'
            if(isempty(cdppCDPP))
                error('cdppCDPP is empty!');
            end
            paChosenCDPP = cdppCDPP;
            chosenFlux   = cdppFlux;
        case 'Union'
            if(isempty(unionCDPP))
                error('unionCDPP is empty!');
            end
            paChosenCDPP = unionCDPP;
            chosenFlux   = unionFlux;
        case 'Haloed'
            if(isempty(haloedCDPP))
                error('haloedCDPP is empty!');
            end
            paChosenCDPP = haloedCDPP;
            chosenFlux   = haloedFlux;
        otherwise
            error('Unknown Chosen Aperture');
    end

    % Compute the RSS
    rssFluxDiff = nansum((tadFlux-chosenFlux).^2);

end % find_cdpp_values_from_legend

%*************************************************************************************************************
% function [] = create_choseAperture_pie_chart (paCoaSummaryStruct)
%
% Create a Pie Chart showing the proportion of choice in aperture
%
% The input can be either a single UOW paCoaSummaryStruct or a full FOV cdppFOVStruct. In the case of the latter, the generated pie chart is for all targets in
% the FOV.
% 
% <quarter> is optional, if not given then statistics compiled over all quarters.
%
%*************************************************************************************************************

function [] = create_chosenAperture_pie_chart (paCoaSummaryStruct, quarter)

    tadChosen = 0;
    tadMnrChosen = 0;
    snrChosen = 0;
    cdppChosen = 0;
    unionChosen = 0;
    haloedChosen = 0;
    customTargets = 0;

    for iUOW = 1 : length(paCoaSummaryStruct)

        if (~isempty(quarter))
            if (paCoaSummaryStruct(iUOW).quarter ~= quarter)
                continue;
            end
        end

        nTargets = length(paCoaSummaryStruct(iUOW).targetData);
        for iTarget = 1 : nTargets
            
            switch paCoaSummaryStruct(iUOW).targetData(iTarget).chosenAperture
                case 'TAD'
                    tadChosen = tadChosen + 1;
                case 'TAD; MNR Chosen'
                    tadMnrChosen = tadMnrChosen + 1;
                case 'SNR'
                    snrChosen = snrChosen + 1;
                case 'CDPP'
                    cdppChosen = cdppChosen + 1;
                case 'Union'
                    unionChosen = unionChosen + 1;
                case 'Haloed'
                    haloedChosen = haloedChosen + 1;
            end

            if (paCoaSummaryStruct(iUOW).targetData(iTarget).isCustomTarget)
                customTargets = customTargets + 1;
            end
        end
    end

    total = sum([tadChosen tadMnrChosen snrChosen cdppChosen unionChosen haloedChosen]);
    tadPrc      = 100 * tadChosen / total;
    tadMnrPrc   = 100 * tadMnrChosen / total;
    snrPrc      = 100 * snrChosen / total;
    cdppPrc     = 100 * cdppChosen / total;
    unionPrc    = 100 * unionChosen / total;
    haloedPrc   = 100 * haloedChosen / total;
    customPrc   = 100 * customTargets / total;

    display(['Custom targets = ', num2str(customPrc), '% of ', num2str(total) ' targets.']);

    figure;
    pie([tadChosen tadMnrChosen snrChosen cdppChosen unionChosen haloedChosen], {['TAD = ', num2str(tadPrc, 2), '%'], ['TAD MNR = ', num2str(tadMnrPrc, 2), '%'], ...
    ['SNR = ', num2str(snrPrc, 2), '%'], ['CDPP = ', num2str(cdppPrc, 2), '%'], ['Union = ', num2str(unionPrc, 2), '%'], ['Haloed = ', num2str(haloedPrc, 2), '%']});
    title('The Chosen Aperture Statistics');

end

%*************************************************************************************************************
% function [cdppStruct, figureHandleArray] = compile_FOV_statistics (quarter, topLevelDirectory)
% 
% This static function should be called in the top-level PA task run drerectory. That is, the directory with all the pa-matlab-###-###### directories
% The function will then crawl through all the subtasks and find all the statistics values for each target. It will then generate a plot giving a 
% summary of the statistics.
%
% Since there is no easy way to know the total number of tasks before hand, this function will dynamicall increase the length of cdppStruct.
%
% Inputs:
%   quarter             -- [int] quarter to plot. Specify quarter=0 for K2.
%   topLevelDirectory   -- [the top level PA task directory] empty means use current directory
%   excludeCustomTargets -- [logical] If true, custom targets are excluded from all calculations (default = false).
%
% Outputs:
%   cdppFOVStruct       -- A struct containing the compiles statistics.
%   figureHandleArray   -- An array of handles for the figures created.
%
%*************************************************************************************************************

function [cdppFOVStruct, figureHandleArray] = compile_FOV_statistics (quarter, topLevelDirectory, excludeCustomTargets)

    taskPlottingEnabled = false;

    % Define the FOV summary struct
    % This comes from examine_performance_for_one_task 
    perTargetDataStruct = struct('keplerId', [], 'tadCDPP', NaN, 'paCDPP', NaN, 'fractionalChangeInAperture', 0, 'maskUsageRatio', 0, ...
                                 'fractionalChangeInMedianFlux', 0, 'addedFlux', 0.0, 'rssFluxDiff', 0, ...
                                 'revertedToTad', true, 'isCustomTarget', [], 'isSaturatedTarget', [], 'targetIndex', NaN, 'keplerMag', NaN, ...
                                 'taskDir', [], 'figuresCreated', false, 'chosenAperture', 'TAD');
    paCoaSummaryStruct = struct('targetData', perTargetDataStruct, 'fractionRevertedToTad', [], 'ccdModule', [], 'ccdOutput', [], 'quarter', []); 
    cdppFOVStruct = repmat(paCoaSummaryStruct, [2,1]);
    figureHandleArray = [];
    currentDirectory = pwd;

    if ~exist('topLevelDirectory', 'var') || isempty(topLevelDirectory)
        topLevelDirectory = pwd;
    end
    
    if ~exist('excludeCustomTargets', 'var')
        excludeCustomTargets = false;
    end

    % Get a list of group directories for the specified quarter.
    channels = colvec([1:84]);
    if quarter == 0
        ggdQuarterArg = []; % Select the earliest quarter or campaign under topLevelDirectory.
    else
        ggdQuarterArg = quarter;
    end
    groupDirCellArray = get_group_dir( 'PA', channels, ...
            'rootPath', topLevelDirectory, 'quarter', ggdQuarterArg);
    isValidGroupDir = cellfun(@(x)~isempty(x), groupDirCellArray);
    if ~any(isValidGroupDir)
        return
    end
    groupDirCellArray = groupDirCellArray(isValidGroupDir);
    
    % Collect dta from each of the group directories.
    iStruct = 1;
    for iGroup = 1:numel(groupDirCellArray)        
        cd(groupDirCellArray{iGroup});

        % Call the routine to collect the CDPP values from this task
        [cdppFOVStruct(iStruct)] = ...
            paCoaClass.examine_performance_for_one_task(0, taskPlottingEnabled, false, [], false, excludeCustomTargets);
        
        iStruct = iStruct + 1;
        display(sprintf('Finished task %d of %d.', iGroup, numel(groupDirCellArray)));
    end
    cd(currentDirectory);

    
    %***
    % Plot the FOV results

    % Get median improvement for all targets plus some other statistics
    chosenApertureNumArray = [];
    tadCDPP = [];
    paCDPP  = [];
    module  = [];
    output  = [];
    fractionalChangeInAperture = [];
    raHours = [];
    decDegrees = [];
    iIndex = 1;
    for iTask = 1 : length(cdppFOVStruct)
        if (cdppFOVStruct(iTask).quarter == quarter)
            figuresCreated  = [cdppFOVStruct(iTask).targetData.figuresCreated];
            tadCDPP = [tadCDPP  [cdppFOVStruct(iTask).targetData(figuresCreated).tadCDPP]];
            paCDPP  = [paCDPP   [cdppFOVStruct(iTask).targetData(figuresCreated).paCDPP]];
            module  = [module   repmat(cdppFOVStruct(iTask).ccdModule, [1,sum(figuresCreated)])];
            output  = [output   repmat(cdppFOVStruct(iTask).ccdOutput, [1,sum(figuresCreated)])];
            fractionalChangeInAperture  = [fractionalChangeInAperture   [cdppFOVStruct(iTask).targetData(figuresCreated).fractionalChangeInAperture]];

            % Create these for all targets, not just those with figures created
            raHours = [raHours  [cdppFOVStruct(iTask).targetData.raHours]];
            decDegrees = [decDegrees  [cdppFOVStruct(iTask).targetData.decDegrees]];
            for iTarget = 1 : length(cdppFOVStruct(iTask).targetData)
                chosenApertureNumArray(iIndex) = find(strcmp(cdppFOVStruct(iTask).targetData(iTarget).chosenAperture, paCoaClass.chosenApertureOptions));
                if (chosenApertureNumArray(iIndex) == 0)
                    error('Unknown chosen aperture');
                end
                iIndex = iIndex + 1;
            end

        end
    end
    clear iIndex;

    cdppImprovement = -(paCDPP - tadCDPP) ./ tadCDPP;

    % get median fractional change in aperture and CDPP for each channel
    % We do it this way because more than one task could correspond to one channel
    medianCdppImprovement               = NaN(84,1);
    tenthPrctlCDPPImprovement           = NaN(84,1);
    thisModule                          = NaN(84,1);
    thisOutput                          = NaN(84,1);
    tenthPrctileFractionalChangeInAperture    = NaN(84,1);
    ninetiethPrctileFractionalChangeInAperture= NaN(84,1);
    fractionOnThisChannel               = NaN(84,1);
    tadFraction                         = [cdppFOVStruct.fractionRevertedToTad];
    for iChannel = 1 : 84
        [thisModule(iChannel) thisOutput(iChannel)]  = convert_to_module_output (iChannel);
        targetsOnThisChannel = [module == thisModule(iChannel) & output == thisOutput(iChannel)];
        medianCdppImprovement(iChannel) = median(cdppImprovement(targetsOnThisChannel));
        tenthPrctlCDPPImprovement(iChannel) = prctile(cdppImprovement(targetsOnThisChannel), 90);
        tenthPrctileFractionalChangeInAperture(iChannel) = prctile(fractionalChangeInAperture(targetsOnThisChannel), 10);
        ninetiethPrctileFractionalChangeInAperture(iChannel) = prctile(fractionalChangeInAperture(targetsOnThisChannel), 90);

        tasksOnThisChannel = [[cdppFOVStruct.ccdModule] == thisModule(iChannel) & [cdppFOVStruct.ccdOutput] == thisOutput(iChannel)];
        fractionOnThisChannel(iChannel) = median(tadFraction(tasksOnThisChannel));
    end

    % CDPP improvement
    fovFigureHandle = fovPlottingClass.plot_on_modout(thisModule, thisOutput, medianCdppImprovement);
    fovFigureHandle = fovPlottingClass.make_ccd_legend_plot(fovFigureHandle);
    colorbar;
    colormap('Cool');
    title ('Median CDPP Improvement over the FOV [positive means greater improvement]');

    % 10th percentile CDPP improvement
    fovTenthFigureHandle = fovPlottingClass.plot_on_modout(thisModule, thisOutput, tenthPrctlCDPPImprovement);
    fovTenthFigureHandle = fovPlottingClass.make_ccd_legend_plot(fovTenthFigureHandle);
    colorbar;
    colormap('Cool');
    title ('10th Percentile Greatest CDPP Improvement over the FOV [positive means greater improvement]');

    % 10th Percentile Fractional Change in Aperture
    apertureTenthFigureHandle = fovPlottingClass.plot_on_modout(thisModule, thisOutput, tenthPrctileFractionalChangeInAperture);
    apertureTenthFigureHandle = fovPlottingClass.make_ccd_legend_plot(apertureTenthFigureHandle);
    colorbar;
    colormap('Hot');
    title ('10th Percentile Fractional Change In Aperture over the FOV [negative means deccrease in aperture]');

    % 90th Percentile Fractional Change in Aperture
    apertureNinetiethFigureHandle = fovPlottingClass.plot_on_modout(thisModule, thisOutput, ninetiethPrctileFractionalChangeInAperture);
    apertureNinetiethFigureHandle = fovPlottingClass.make_ccd_legend_plot(apertureNinetiethFigureHandle);
    colorbar;
    colormap('Cool');
    title ('90th Percentile Fractional Change In Aperture over the FOV [positive means increase in aperture]');

    %***
    % Fraction reverted to TAD
    fractionFigureHandle = fovPlottingClass.plot_on_modout(thisModule, thisOutput, fractionOnThisChannel);
    fractionFigureHandle = fovPlottingClass.make_ccd_legend_plot(fractionFigureHandle);
    colorbar;
    colormap('Cool');
    title ('Fraction of targets that reverted to the TAD aperture');

    %***
    % chosenAperture scatter plot
    chosenApertureFigureHandle = figure;
    colorOrder = {'r', 'k', 'g', 'c', 'm', 'k'};
    if (length(paCoaClass.chosenApertureOptions) > length(colorOrder))
        error('Add another color!');
    end
    raDegrees = raHours * 15;
    scatter(raDegrees, decDegrees, 20, chosenApertureNumArray)
    set(gca,'XDir','reverse');
    colormap(jet(length(colorOrder)));
    hcb = colorbar('YTickLabel', paCoaClass.chosenApertureOptions);
    set(hcb,'YTickMode','manual');
    set(hcb,'YTick',[1 : length(colorOrder)])
    hold off;
    xlabel('RA [Degrees]');
    ylabel('Declination [Degrees]');
    title('Chosen Aperture vs. Ra/Dec');
    

    figureHandleArray = [ ...
        fovFigureHandle; ...
        fovTenthFigureHandle; ...
        apertureTenthFigureHandle; ...
        apertureNinetiethFigureHandle; ...
        fractionFigureHandle; ...
        chosenApertureFigureHandle];
    
end % compile_FOV_CDPP_improvement 

%*************************************************************************************************************
%
% Displays the figures for the selected target indices <index> and prompts the user to select whcih aperture was best
%
% {''TAD'', ''SNR'', ''CDPP'', ''Union''} [ENTER => selected is good]
%
%*************************************************************************************************************
function [paCoaSummaryStruct] = set_correct_aperture (paCoaSummaryStruct, index)

    persistent aperturePosition curvesPosition prfPosition;

    for iIndex = 1 : length(index)

        thisIndex = index(iIndex);

        if (~paCoaSummaryStruct.targetData(thisIndex).figuresCreated)
            display('***');
            display('***');
            display('***');
            display('Figures not created for this target. It reverted to TAD');
            display('***');
            continue;
        end
        
        apertureOptions = {'TAD', 'SNR', 'CDPP', 'Union'};
        
        cd  (paCoaSummaryStruct.targetData(thisIndex).taskDir);
        
        targetIndex = paCoaSummaryStruct.targetData(thisIndex).targetIndex;
        
        curvesFig = openfig(['pa_coa_target_', num2str(targetIndex), '_curves.fig']);
        prfFig = openfig(['pa_coa_target_', num2str(targetIndex), '_prf.fig']);
        apertureFig = openfig(['pa_coa_target_', num2str(targetIndex), '_aperture.fig']);
        % Move figure locations to that of previous figures
        if (~isempty(aperturePosition))
            set(apertureFig, 'Position', aperturePosition);
            set(curvesFig,   'Position', curvesPosition);
            set(prfFig,      'Position', prfPosition);
        end
        
        paCoaSummaryStruct.targetData(thisIndex).diagnosticPlotsShown = true;
        
        
        % Display Target info
        display('*** Target Information ***');
        paCoaSummaryStruct.targetData(thisIndex)
        display('*** Target Information ***');

        userResponse = input('Enter proper aperture {''TAD'', ''SNR'', ''CDPP'', ''Union''} [ENTER => selected is good]:', 's');
        if (~isempty(userResponse))
            betterAperture = find(ismember(apertureOptions, userResponse));
            while (isempty(betterAperture) && ~isempty(userResponse))
                display('Invalid aperture choice!');
                userResponse = input('Enter proper aperture {''TAD'', ''SNR'', ''CDPP'', ''Union''} [ENTER => selected is good]:', 's');
                betterAperture = find(ismember(apertureOptions, userResponse));
            end
        end
        if (isempty(userResponse))
            paCoaSummaryStruct.targetData(thisIndex).incorrectlyChoseAperture = false;
            paCoaSummaryStruct.targetData(thisIndex).theCorrectAperture = paCoaSummaryStruct.targetData(thisIndex).chosenAperture;
        else
            paCoaSummaryStruct.targetData(thisIndex).incorrectlyChoseAperture = true;
            paCoaSummaryStruct.targetData(thisIndex).theCorrectAperture = apertureOptions{betterAperture};
        end
        
        
        cd ../..
        
        % Get location of figures, so the next figures will be placed in the same locations
        aperturePosition = get(apertureFig, 'Position');
        curvesPosition   = get(curvesFig, 'Position');
        prfPosition      = get(prfFig, 'Position');
                         
        close(apertureFig);
        close(curvesFig);
        close(prfFig);

    end

end

%*************************************************************************************************************
% function prediction = poor_aperture_selection_prediction(betaStruct, addedFlux, fractionalChangeInAperture, ...
%                                                                           fractionalChangeInMedianFlux, maskUsageRatio)
%
% Using a logistic regression model will return the prediction for a poor aperture selection based on the three predictor. The descriminationValue is used to
% set the threshold where a poor aperture is predicted
%
% Inputs: 
%   betaStruct      --  [struct] The four model coefficients plus the descrimination threshold
%       .mnrBeta0                               -- [double] constant offset
%       .mnrAddedFluxBeta                       -- [double]
%       .mnrFractionalChangeInApertureBeta      -- [double]
%       .mnrFractionalChangeInMedianFluxBeta    -- [double]
%       .mnrMaskUsageRatioBeta                  -- [double]
%       .mnrDiscriminationThreshold             -- [double] Threshold value to returning a true prediction
%   addedFlux                   -- [double array(nTargets)] The added Flux value array
%   fractionChangeInMedianFlux  -- [double array(nTargets)] The added Flux value array
%   maskUsageRatio              -- [double array(nTargets)] The added Flux value array
%
% Outputs:
%   prediction          -- [logical array(nTargets)] True if target should revert to TAD aperture
%   predictionStatistic -- [double [0,1] array(nTargets)]  Prediction Statistic if target should revert to TAD aperture
%*************************************************************************************************************

function [prediction predictionStatistic] = poor_aperture_selection_prediction(betaStruct, addedFlux, fractionalChangeInAperture, ...
                                                fractionalChangeInMedianFlux, maskUsageRatio)

    betaArray = [betaStruct.mnrBeta0 betaStruct.mnrAddedFluxBeta betaStruct.mnrFractionalChangeInApertureBeta ...
                    betaStruct.mnrFractionalChangeInMedianFluxBeta betaStruct.mnrMaskUsageRatioBeta]';

    if (~iscolumn(addedFlux))
        addedFlux = addedFlux';
    end
    if (~iscolumn(fractionalChangeInAperture))
        fractionalChangeInAperture = fractionalChangeInAperture';
    end
    if (~iscolumn(fractionalChangeInMedianFlux))
        fractionalChangeInMedianFlux = fractionalChangeInMedianFlux';
    end
    if (~iscolumn(maskUsageRatio))
        maskUsageRatio = maskUsageRatio';
    end

    predictionStatistic = mnrval(betaArray, [addedFlux, fractionalChangeInAperture, fractionalChangeInMedianFlux, maskUsageRatio]);
    predictionStatistic = predictionStatistic(:,2);

    prediction = predictionStatistic > betaStruct.mnrDiscriminationThreshold;

end

end % Diagnostic static methods

end % classdef paCoaClass
