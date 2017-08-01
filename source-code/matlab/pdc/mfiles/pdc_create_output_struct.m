% function pdcOutputsStruct = pdc_create_output_struct (pdcInputObject, ...
%                                                       targetDataStruct, ...
%                                                       harmonicTimeSeries, ...
%                                                       outlieredFluxSeries, ...
%                                                       fluxCorrectionStruct, ...
%                                                       alerts, ...
%                                                       goodnessStruct, ...
%                                                       variabilityStruct, ...
%                                                       gapFilledCadenceMidTimestamps )
%
% Creates the pdcOutputsStruct structure for all final PDC results.
%
% This also saves the blob files
%
% Outputs:
%   pdcOutputsStruct -- [struct] with the following fields:
%       .pdcVersion                         -- [float] e.g. 8.3. 9.1 etc...
%       .cadenceType                        -- [char] {'LONG' | 'SHORT'}
%       .ccdModule                          -- [int] -1 if multichannel, otherwise, the the module for this single channel 
%       .ccdOutput                          -- [int] -1 if multichannel, otherwise, the the output for this single channel
%       .startCadence                       -- cadence index (NOT MJD)
%       .endCadence                         -- cadence index (NOT MJD)
%       .alerts(:)                          -- [struct array] all alert messages from PDC run (These are usefule, don't ignore them!)
%           .time                               [double]  alert time, MJD
%           .severity                           [string]  alert severity ('error' or 'warning')
%           .message                            [string]  alert message
%       .targetResultsStruct(:)             -- [struct array] target specific results
%           .keplerID                       -- [int]
%           .correctedFluxTimeSeries
%               .values
%               .uncertainties
%               .gapIndicators
%               .filledIndices              -- [int array] ***0-BASED***
%           .harmonicFreeCorrectedFluxTimeSeries
%               .values
%               .uncertainties
%               .gapIndicators
%               .filledIndices              -- [int array] ***0-BASED***
%           .outliers
%               .indices                    -- [int array] ***0-BASED***
%               .values
%               .uncertainties
%           .harmonicFreeOutliers
%               .indices                    -- [int array] ***0-BASED***
%               .values
%               .uncertainties
%           .discontinuityIndices           -- [int array] ***0-BASED***
%           .pdcProcessingStruct
%               .pdcMethod                  -- [char] {'multiScaleMap' | 'regularMap' | 'leastSquares' | robust | noFit...}
%               .numDiscontinutiesDetected  -- [int]
%               .numDiscontinutiesRemoved   -- [int]
%               .harmonicsFitted            -- [logical]
%               .harmonicsRestored          -- [logical]
%               .targetVariability          -- [double]
%               .bands                      -- [struct array] One for each MAP band processed for this target
%                   .fitType                -- [char] {'none' | 'prior' | 'robust' | ...}
%                   .priorWeight            -- [double]
%                   .priorGoodness          -- [double]
%           .pdcGoodnessMetric
%               .total                      -- [GoodnessStruct]
%                   .value                  -- [double]
%                   .percentile             -- [double] ranking WRT all non-custom targets
%               .correlation                -- [GoodnessStruct]
%               .deltaVariability           -- [GoodnessStruct]
%               .introducedNoise            -- [GoodnessStruct]
%               .earthPointRemoval          -- [GoodnessStruct]
%               .spikeRemoval               -- [GoodnessStruct]
%               .cdpp                       -- [GoodnessStruct]
%               .kepstddev                  -- [GoodnessStruct]
%       .channelDataStruct(:)               -- [channelDataStruct(nChannels)] If running PDC on a single channel then this is length of 1
%           .ccdModule   
%           .ccdOutput   
%           .pdcBlobFilename                -- [char] name to file that stores LC data for use with SC PDC
%           .cbvBlobFilename                -- [char] name to file that store basis vectors and priors for use with DV and special PDC runs
%       .thrusterFiringDataStruct           -- [struct] Trhuster firing information, only relevent for K2 data
%   
%----------------------------------------------------------------------------------------------------
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

function pdcOutputsStruct = pdc_create_output_struct(   ...
                                                        pdcInputObject, ...
                                                        targetDataStruct, ...
                                                        harmonicTimeSeries, ...
                                                        outlieredFluxSeries, ...
                                                        fluxCorrectionStruct, ...
                                                        alerts, ...
                                                        goodnessStruct, ...
                                                        variabilityStruct, ...
                                                        gapFilledCadenceMidTimestamps)


    nTargets = length(targetDataStruct);

% We need to load all kinds of data from files.
% NOTE: pdc_create_output_struct must be dispatched as well, otherwise we defeated the purpose of dispatching!

load 'shortMapResultsStruct_Coarse'
% no need to convert to object
if (~exist('shortMapResultsStruct_Coarse', 'var'))
    error('shortMapResultsStruct_Coarse does not seem to exist');
end
% delete Coarse mapResultsStruct, we don't want to save it
system('rm shortMapResultsStruct_Coarse.mat');

if (pdcInputObject.pdcModuleParameters.bandSplittingEnabled)
    load('shortMapResultsStruct_Band_1');
    shortmsMapResultsCell{1} = shortMapResultsStruct_Band_1;
    load('shortMapResultsStruct_Band_2');
    shortmsMapResultsCell{2} = shortMapResultsStruct_Band_2;
    load('shortMapResultsStruct_Band_3');
    shortmsMapResultsCell{3} = shortMapResultsStruct_Band_3;
    clear shortMapResultsStruct_Band_1 shortMapResultsStruct_Band_2 shortMapResultsStruct_Band_3;
    if (~exist('shortmsMapResultsCell', 'var'))
        error('shortmsMapResultsCell does not seem to exist');
    end
    system('rm shortMapResultsStruct_Band_1.mat');
    system('rm shortMapResultsStruct_Band_2.mat');
    system('rm shortMapResultsStruct_Band_3.mat');
elseif (any([fluxCorrectionStruct.multiscaleMapUsed]))
    error ('PDC bookkeeping error: fluxCorrectionStruct says msMAP was used but pdcInputObject saves bandsplitting not enabled');
else
    shortmsMapResultsCell = [];
end

load 'shortMapResultsStruct_no_BS'
if (~exist('shortMapResultsStruct_no_BS', 'var'))
    error('shortMapResultsStruct_no_BS does not seem to exist');
end
system('rm shortMapResultsStruct_no_BS.mat');

load 'spsdOutput'
if (~exist('spsdOutput', 'var'))
    error('spsdOutput does not seem to exist');
end

load 'spsdBlob'
if (~exist('spsdBlob', 'var'))
    error('spsdBlob does not seem to exist');
end


%----------------------------------------------------------------------------------------------------
% populate fields
%----------------------------------------------------------------------------------------------------

% fields that can simply be copied from the inputs
    pdcOutputsStruct.pdcVersion     = pdcInputObject.pdcVersion;
    pdcOutputsStruct.ccdModule      = pdcInputObject.ccdModule; % Keep these for bakcwards compatibility with old data structures
    pdcOutputsStruct.ccdOutput      = pdcInputObject.ccdOutput;
    pdcOutputsStruct.cadenceType    = pdcInputObject.cadenceType;
    pdcOutputsStruct.startCadence   = pdcInputObject.startCadence;
    pdcOutputsStruct.endCadence     = pdcInputObject.endCadence;
    pdcOutputsStruct.thrusterFiringDataStruct  = pdcInputObject.thrusterFiringDataStruct;
    
% the alerts which have been generated while running PDC
    pdcOutputsStruct.alerts = alerts;
    
% pdcBlobFileName
    pdcOutputsStruct.pdcBlobFileName = ''; % Blob information saved after execution of this function.

% targetDataStruct
    for iTarget=1:nTargets
        
        % keplerId
        pdcOutputsStruct.targetResultsStruct(iTarget).keplerId = targetDataStruct(iTarget).keplerId;
        
        % correctedFluxTimeSeries
        pdcOutputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.values           = targetDataStruct(iTarget).values;
        pdcOutputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.uncertainties    = targetDataStruct(iTarget).uncertainties;
        pdcOutputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.gapIndicators    = targetDataStruct(iTarget).gapIndicators;
        pdcOutputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.filledIndices    = targetDataStruct(iTarget).filledIndices;
        
        % harmonicFreeCorrectedFluxTimeSeries
        %    uncertainties, gapIndicators, filledIndices should be the same as above
        pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeCorrectedFluxTimeSeries.values           = targetDataStruct(iTarget).values - harmonicTimeSeries(iTarget).values;
        pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeCorrectedFluxTimeSeries.uncertainties    = targetDataStruct(iTarget).uncertainties;
        pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeCorrectedFluxTimeSeries.gapIndicators    = targetDataStruct(iTarget).gapIndicators;
        pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeCorrectedFluxTimeSeries.filledIndices    = targetDataStruct(iTarget).filledIndices;
        % ...
        
        % outliers -- what if Outliers are detected for the same target/cadence in multiple iterations ?
        idxOutliers = [];
        for iIter = 1:length(fluxCorrectionStruct(iTarget).outlierStruct) % is equal to nIterHdo
            idxOutliers = [ idxOutliers ; fluxCorrectionStruct(iTarget).outlierStruct{iIter}.indices ];
        end
        idxOutliers = sort(unique( idxOutliers ));
        pdcOutputsStruct.targetResultsStruct(iTarget).outliers.indices           = idxOutliers;
%       idxOutliers = find(targetDataStruct(iTarget).values~=outlieredFluxSeries(iTarget).values);
        pdcOutputsStruct.targetResultsStruct(iTarget).outliers.values            = outlieredFluxSeries(iTarget).values(idxOutliers);
        pdcOutputsStruct.targetResultsStruct(iTarget).outliers.uncertainties     = outlieredFluxSeries(iTarget).uncertainties(idxOutliers);

        % harmonicFreeOutliers
        pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeOutliers.values          = outlieredFluxSeries(iTarget).values(idxOutliers) - harmonicTimeSeries(iTarget).values(idxOutliers);
        pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeOutliers.uncertainties   = outlieredFluxSeries(iTarget).uncertainties(idxOutliers);
        pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeOutliers.indices         = idxOutliers;        
        % ...
        
        % add outlier indices to list of filledIndices
        pdcOutputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.filledIndices = ...
            sort( unique( union( ...
                   pdcOutputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.filledIndices , ...
                   pdcOutputsStruct.targetResultsStruct(iTarget).outliers.indices ...
                   ) ) );
        pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeCorrectedFluxTimeSeries.filledIndices = ...
            sort( unique( union( ...
                   pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeCorrectedFluxTimeSeries.filledIndices , ...
                   pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeOutliers.indices ...
                   ) ) );
        
        % discontinuityIndices
        pdcOutputsStruct.targetResultsStruct(iTarget).discontinuityIndices = [];
        for iIter = 1:length(spsdOutput) % is equal to nIterHdo
            if (isempty(spsdOutput{iIter}.spsds))
                % Then the old SPSD corrector was called
                [pdcOutputsStruct.targetResultsStruct(iTarget).discontinuityIndices] = ...
                                [ pdcOutputsStruct.targetResultsStruct(iTarget).discontinuityIndices [ spsdOutput{iIter}.discontinuityIndices{iTarget} ] ] ;
            elseif (spsdOutput{iIter}.spsds.count>0)
                % until 8.2, this also checked (~fluxCorrectionStruct(iTarget).uncorrectedSuspectedDiscontinuity).
                % See KSOC-1978
                pos = find( ismember( [ spsdOutput{iIter}.spsds.targets.index ] , iTarget ) );
                for j = pos  % use this instead if ~isempty to account for the case where one target has multiple occurrences in the spsd list
                    pdcOutputsStruct.targetResultsStruct(iTarget).discontinuityIndices = ...
                        [ pdcOutputsStruct.targetResultsStruct(iTarget).discontinuityIndices [ spsdOutput{iIter}.spsds.targets(j).spsdEvents.spsdCadence ] ];
                end
            end
        end                

        if (pdcInputObject.mapConfigurationStruct.quickMapEnabled)
            % Only one method if Quick Map is requested,
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.pdcMethod = 'quickMap';
        else
            % pdcProcessingStruct
            if (fluxCorrectionStruct(iTarget).multiscaleMapUsed)
                pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.pdcMethod = 'multiScaleMap';
            else
                pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.pdcMethod = 'regularMap';
            end
            % If method selected by 'noneRobustMap' then there are other options
            if (strcmp(pdcInputObject.pdcModuleParameters.mapSelectionMethod, 'noneRobustMap'))
                 pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.pdcMethod = fluxCorrectionStruct(iTarget).selectedFit;
            end
        end

        pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.numDiscontinuitiesDetected = ...
                                                length(pdcOutputsStruct.targetResultsStruct(iTarget).discontinuityIndices);
        if (~fluxCorrectionStruct(iTarget).uncorrectedSuspectedDiscontinuity)
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.numDiscontinuitiesRemoved = ...
                                                length(pdcOutputsStruct.targetResultsStruct(iTarget).discontinuityIndices);
        else
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.numDiscontinuitiesRemoved = 0;
        end
        pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.harmonicsFitted =  ~isempty([ fluxCorrectionStruct(iTarget).harmonics{:} ]);
        pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.harmonicsRestored =  ~isempty([ fluxCorrectionStruct(iTarget).harmonics{:} ]);
        pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.targetVariability = variabilityStruct.variability(iTarget);

        % number of bands for band-splitting
        if (~pdcInputObject.pdcModuleParameters.bandSplittingEnabled)
            nBands = 1;
        else
            nBands = pdcInputObject.bandSplittingConfigurationStruct.numberOfBands;
        end
        if (fluxCorrectionStruct(iTarget).multiscaleMapUsed)
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands = ...
                repmat(struct('fitType', [], 'priorWeight', [], 'priorGoodness', []), [nBands,1]);
            % multi-scale MAP was used
            for iBand = 1 : nBands
                if (shortmsMapResultsCell{iBand}.mapFailed)
                    % if MAP failed then there isn't any MAP information to put here. Use -1 to signify
                    % not-applicable information. NaN would be better but the Oracle database doesn't like NaNs.
                    pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(iBand).fitType = 'none';
                    pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(iBand).priorWeight = -1;
                    pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(iBand).priorGoodness = -1;
                else
                    pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(iBand).priorWeight = ...
                            shortmsMapResultsCell{iBand}.intermediateMapResults(iTarget).priorWeight;
                    pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(iBand).priorGoodness = ...
                            shortmsMapResultsCell{iBand}.intermediateMapResults(iTarget).priorGoodness;
                    if (shortmsMapResultsCell{iBand}.intermediateMapResults(iTarget).priorWeight ~= 0)
                        pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(iBand).fitType = 'prior';
                    else
                        pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(iBand).fitType = 'robust';
                    end
                end
            end
        else
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands = ...
                repmat(struct('fitType', [], 'priorWeight', [], 'priorGoodness', []), [1,1]);
            % Regular MAP was used
            if (shortMapResultsStruct_no_BS.mapFailed)
                % if MAP failed then there isn't any MAP information to put here. Use -1 to signify
                % not-applicable information. NaN would be better but the Oracle database doesn't like NaNs.
                pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(1).fitType = 'none';
                pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(1).priorWeight = -1;
                pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(1).priorGoodness = -1;
            else
                pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(1).priorWeight = ...
                        shortMapResultsStruct_no_BS.intermediateMapResults(iTarget).priorWeight;
                pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(1).priorGoodness = ...
                        shortMapResultsStruct_no_BS.intermediateMapResults(iTarget).priorGoodness;
                if (shortMapResultsStruct_no_BS.intermediateMapResults(iTarget).priorWeight ~= 0)
                    pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(1).fitType = 'prior';
                else
                    pdcOutputsStruct.targetResultsStruct(iTarget).pdcProcessingStruct.bands(1).fitType = 'robust';
                end
            end
        end

        % pdcGoodnessMetric
        if (fluxCorrectionStruct(iTarget).isFullyGapped)
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.total.value                   = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.total.percentile              = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.correlation.value             = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.correlation.percentile        = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.deltaVariability.value        = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.deltaVariability.percentile   = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.introducedNoise.value         = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.introducedNoise.percentile    = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.earthPointRemoval.value       = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.earthPointRemoval.percentile  = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.spikeRemoval.value            = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.spikeRemoval.percentile       = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.cdpp.value                    = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.cdpp.percentile               = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.rollTweak.value               = NaN; 
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.rollTweak.percentile          = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.kepstddev.value               = NaN;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.kepstddev.percentile          = NaN;
        else
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.total.value                   = goodnessStruct(iTarget).total.value;                
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.total.percentile              = goodnessStruct(iTarget).total.percentile;           
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.correlation.value             = goodnessStruct(iTarget).correlation.value;          
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.correlation.percentile        = goodnessStruct(iTarget).correlation.percentile;    
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.deltaVariability.value        = goodnessStruct(iTarget).deltaVariability.value;     
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.deltaVariability.percentile   = goodnessStruct(iTarget).deltaVariability.percentile;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.introducedNoise.value         = goodnessStruct(iTarget).introducedNoise.value ;     
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.introducedNoise.percentile    = goodnessStruct(iTarget).introducedNoise.percentile;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.earthPointRemoval.value       = goodnessStruct(iTarget).earthPointRemoval.value;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.earthPointRemoval.percentile  = goodnessStruct(iTarget).earthPointRemoval.percentile;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.spikeRemoval.value            = goodnessStruct(iTarget).spikeRemoval.value;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.spikeRemoval.percentile       = goodnessStruct(iTarget).spikeRemoval.percentile;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.cdpp.value                    = goodnessStruct(iTarget).cdpp.value;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.cdpp.percentile               = goodnessStruct(iTarget).cdpp.percentile;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.rollTweak.value               = goodnessStruct(iTarget).rollTweak.value;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.rollTweak.percentile          = goodnessStruct(iTarget).rollTweak.percentile;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.kepstddev.value               = goodnessStruct(iTarget).kepstddev.value;
            pdcOutputsStruct.targetResultsStruct(iTarget).pdcGoodnessMetric.kepstddev.percentile          = goodnessStruct(iTarget).kepstddev.percentile;
        end
    end

%----------------------------------------------------------------------------------------------------
% convert to 0-based
%----------------------------------------------------------------------------------------------------
    for iTarget=1:nTargets
        pdcOutputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.filledIndices = pdcOutputsStruct.targetResultsStruct(iTarget).correctedFluxTimeSeries.filledIndices - 1;
        pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeCorrectedFluxTimeSeries.filledIndices = pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeCorrectedFluxTimeSeries.filledIndices - 1;
        pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeOutliers.indices          = pdcOutputsStruct.targetResultsStruct(iTarget).harmonicFreeOutliers.indices - 1;
        pdcOutputsStruct.targetResultsStruct(iTarget).outliers.indices                      = pdcOutputsStruct.targetResultsStruct(iTarget).outliers.indices - 1;
        pdcOutputsStruct.targetResultsStruct(iTarget).discontinuityIndices                  = pdcOutputsStruct.targetResultsStruct(iTarget).discontinuityIndices - 1;
    end


%*************************************************************************************************************
% channelDataStruct

pdcOutputsStruct.channelDataStruct = pdcInputObject.channelDataStruct;

%*************************************************************************************************************
% now create the blob files

% Even if we are running multi-channel PDC the blobs generated are all the same for each channel

% pdc_blob is for short cadence
pdcBlobFileName = 'pdc_blob.mat';
nChannels = length(pdcInputObject.channelDataStruct);
for iChannel = 1 : nChannels
    pdcOutputsStruct.channelDataStruct(iChannel).pdcBlobFileName = pdcBlobFileName;
end

% Create and save blob with just cotrending basis vectors for use by DV
cbvBlobFileName = 'cbv_blob.mat';
if (~exist('shortmsMapResultsCell', 'var'));
    shortmsMapResultsCell = [];
end
pdc_create_cbv_blob (shortMapResultsStruct_Coarse, shortmsMapResultsCell, shortMapResultsStruct_no_BS, spsdBlob, pdcInputObject, ...
                        gapFilledCadenceMidTimestamps, cbvBlobFileName, pdcBlobFileName );
for iChannel = 1 : nChannels
    pdcOutputsStruct.channelDataStruct(iChannel).cbvBlobFileName = cbvBlobFileName;
end

end
