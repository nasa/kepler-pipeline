function correctionResultsStruct = correct_from_preloaded( obj , iDedStruct )
% function shortCadenceCorrection = correct_from_preloaded( obj , iDedStruct )
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

% generate a fake correctionResultsStruct from interpolated LC correction
% this is the designated 'quick fix' for SPSDs in SC targets

% * |correctionResultsStruct    	-| structure containing corrected timeseries information. 
% * |.correctedTimeSeries           -| timeseries with SPSDs removed 
% * |.PersistentStep                -| correction timeseries for persistent step 
% * |.RecoveryTerm                  -| correction timeseries for recovery 

% initialization
nCadences = length(obj.timeSeriesStruct(1).fluxResiduals);
correctionResultsStruct.correctedTimeSeries=zeros(iDedStruct.count,nCadences);
correctionResultsStruct.persistentStep=zeros(iDedStruct.count,nCadences);
correctionResultsStruct.recoveryTerm=zeros(iDedStruct.count,nCadences);

shortCadencePostCorrectionEnabled     = obj.correctionParamsStruct.shortCadencePostCorrectionEnabled;
shortCadencePostCorrectionLeftWindow  = obj.correctionParamsStruct.shortCadencePostCorrectionLeftWindow;
shortCadencePostCorrectionRightWindow = obj.correctionParamsStruct.shortCadencePostCorrectionRightWindow;
shortCadencePostCorrectionMethod      = obj.correctionParamsStruct.shortCadencePostCorrectionMethod;

% Get original flux time series with spsds SPSDs
dirtyTimeSeries = obj.timeSeriesStruct.fluxResiduals( iDedStruct.index , : );

% get cadence times from object (TODO: still have to be initialized there)
longCadenceTimes = obj.longCadenceTimes;
shortCadenceTimes = obj.shortCadenceTimes;
% spsdEventBlob = obj.preLoadedEvents;

for k = 1:iDedStruct.count

    %% define some useful short-cuts
    b = iDedStruct.spsdCadence(k);
    % We shift the correction by two cadences.
    % This was empirically found to avoid the spikes which can occur otherwise
    % Those (positive) spikes are probably due to the quickSpsd-Detector triggering
    % 1-2 cadences too early (for yet unexplored reasons)
    % This correction introduces the risk that a negative spike is injected. However,
    % that is not as bad as the positive spikes, as there is currently a residual
    % short exponential recovery (few cadences long) anyway. The reason for the latter
    % is probably that this high-frequency component of the recovery can not be identified
    % by the corrector in the LC time series.
    b = b+2;
    e = nCadences;
    
    %% get correction terms from object intermediate storage (set and updated by detect_from_preloaded())
    longCadencePersistentStep = obj.lcCorrectionPersistentStep(:,k);
    longCadenceRecovery = obj.lcCorrectionRecovery(:,k);
    
    %% trim cadence times structure
    trimmedShortCadenceTimes = extract_cadenceTimes_subregion( shortCadenceTimes , b , e );
    
    %% calculate SC recovery from interpolated LC recovery
    shortCadenceRecovery = zeros(nCadences,1);
    % do the interpolation
    [ shortCadenceRecovery(b:e) , syncFailed ] = pdc_synchronize_vectors( longCadenceRecovery , longCadenceTimes , trimmedShortCadenceTimes , 'spline' );
    if (syncFailed)
        error('ERROR: LC correction could not be synchronized to SC cadence times stamps. Not performing SPSD correction');
    end
    %  divide by 30 because it's electrons per cadence
    shortCadenceRecovery = shortCadenceRecovery /30;
    % there should not be any correction at the SPSD location
    shortCadenceRecovery(b) = 0; % ?? or b-1 ??
    
    
    %% calculate SC persistent step
    shortCadenceStep = zeros(nCadences,1);
    shortCadenceStep(b:e) = longCadencePersistentStep(end) /30;
    
    %% sum is final correction
%     shortCadenceCorrection = shortCadenceRecovery + shortCadenceStep;
    
    %% prepare outputs
    correctionResultsStruct.recoveryTerm(k,:) = shortCadenceRecovery';
    correctionResultsStruct.persistentStep(k,:) = shortCadenceStep';
    
    % original time series with spsd corrections applied
    correctionResultsStruct.correctedTimeSeries(k,:) = dirtyTimeSeries(k,:)-...
                                                correctionResultsStruct.recoveryTerm(k,:)- ...
                                                correctionResultsStruct.persistentStep(k,:);
                                            
    %% post-correction to remove sub-LC artifacts that can not be corrected with LC interpolation
    %  fixes spikes and short residual exponentials, see KSOC-2442
    %  three parameters are relevant for this:
    %  1. correctionParamsStruct.shortCadencePostCorrectionEnabled [ BOOLEAN ], determines whether or not post-correction
    %     is performed
    %  2. shortCadencePostCorrectionLeftWindow [ INT ], determines the number of cadences to fix before the SPSD
    %     (currently hardcoded)
    %  3. shortCadencePostCorrectionRightWindow [ INT ], determines the number of cadences to fix after the SPSD
    %     (currently hardcoded)
    %  4. shortCadencePostCorrectionMethod [ STRING ], determines the method ('gapfill','linearinterp')
    
    if (shortCadencePostCorrectionEnabled)
        fillWindowStart = max(1,b-shortCadencePostCorrectionLeftWindow);
        fillWindowEnd = min(nCadences,b+shortCadencePostCorrectionRightWindow);
        gapIndicators = false(nCadences,1);
        gapIndicators(fillWindowStart:fillWindowEnd) = true;
        % using column vectors here to make it cache-coherent. sad that the original spsd code isn't
        fluxIn = correctionResultsStruct.correctedTimeSeries(k,:)';
        fluxOut = fluxIn;
        % ========== BEGIN branch for different methods ==========
        % === gap filling ===
        if (strcmpi(shortCadencePostCorrectionMethod,'gapfill'))
            % the default gapFillConfigurationStruct parameters created in spsd_fill_gaps use
            % cadenceDurationInMinutes = 30 which is not correct for SC data. in some brief testing this did not seem
            % to negatively impact the correction quality, but this could easily be changed if necessary
            targetIndex = find([obj.inputTargetDataStruct(:).keplerId] == iDedStruct(k).keplerId);
            uncertainties = obj.inputTargetDataStruct(targetIndex).uncertainties;
            fluxOut = spsd_fill_gaps(fluxIn,uncertainties,gapIndicators);
        end        
        % === linear interpolation ===
        if (strcmpi(shortCadencePostCorrectionMethod,'linearinterp'))
            t = (1:nCadences)';
            idxNoGap = find(~gapIndicators);       
            p = regress (fluxIn(idxNoGap), [ones(length(idxNoGap),1) t(idxNoGap)]);
            fluxOut(gapIndicators) = p(1)+p(2).*t(gapIndicators);
        end
        % ========== END branch for different methods ============
        correctionResultsStruct.correctedTimeSeries(k,:) = fluxOut';   
        adjustment = fluxOut' - fluxIn';
        correctionResultsStruct.recoveryTerm = correctionResultsStruct.recoveryTerm - adjustment;
    end
    
end % for k=1:iDedStruct.count


end
