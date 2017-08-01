function [calObject, calIntermediateStruct] = ...
    compute_smear_and_dark_uncertainties(calObject, calIntermediateStruct, calTransformStruct)
%function [calObject, calIntermediateStruct] = ...
%    compute_smear_and_dark_uncertainties(calObject, calIntermediateStruct, calTransformStruct)
%
% This function computes the uncertainties in the raw collateral smear
% pixels.
%
% Note (7/12/10)
%   This function is no longer used in production (Pipeline) code.
% 
%--------------------------------------------------------------------------
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

debugLevel = calObject.debugLevel;

% extract timestamp (mjds)
cadenceTimes = calObject.cadenceTimes;
timestamp    = cadenceTimes.timestamp;
nCadences    = length(timestamp);
pouEnabled   = calObject.pouModuleParametersStruct.pouEnabled;

% check for availability of any masked/virtual smear pixels
isAvailableMaskedSmearPix  = calObject.dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix = calObject.dataFlags.isAvailableVirtualSmearPix;

if (isAvailableMaskedSmearPix)
    mSmearGaps    = calIntermediateStruct.mSmearGaps;
    mSmearColumns = calIntermediateStruct.mSmearColumns;
end

if (isAvailableVirtualSmearPix)
    vSmearGaps    = calIntermediateStruct.vSmearGaps;
    vSmearColumns = calIntermediateStruct.vSmearColumns;
end

% extract logical arrays which indicate valid smear/dark current columns
validSmearColumns = [calIntermediateStruct.validSmearColumns];

%--------------------------------------------------------------------------
% Step 1: compute raw smear pixel uncertainties for all cadences:
%         deltaRawMsmear and deltaRawVsmear
%--------------------------------------------------------------------------
tic
[calObject, calIntermediateStruct] = ...
    compute_collateral_raw_smear_uncertainties(calObject, calIntermediateStruct);

display_cal_status('CAL:compute_smear_and_dark_uncertainties: Raw smear uncertainties computed', 1);


if (debugLevel > 2)
    %--------------------------------------------------------------------------
    % compute smear/dark transformations, calculated on a per-cadence basis, and
    % saved for propagation of uncertainties
    %--------------------------------------------------------------------------
    tic
    [calObject, calIntermediateStruct] = compute_collateral_smear_and_dark_transformations(calObject, calIntermediateStruct);

    display_cal_status('CAL:compute_smear_and_dark_uncertainties: Smear and dark transformations computed', 1);


    %--------------------------------------------------------------------------
    % Step 2: construct raw masked and raw virtual smear pixel uncertainties
    %         covariance matrix, and set data gaps equal to zero
    %--------------------------------------------------------------------------
    tic
    lastDuration = 0;

    % compute only for cadences with valid pixels
    missingMsmearCadences = calIntermediateStruct.missingMsmearCadences;
    missingVsmearCadences = calIntermediateStruct.missingVsmearCadences;
    missingCadences = union(missingMsmearCadences, missingVsmearCadences);

    for cadenceIndex = 1:nCadences

        if (isempty(missingCadences)) || (~isempty(missingCadences) && ~any(ismember(missingCadences, cadenceIndex)))

            %--------------------------------------------------------------------------
            % extract covariance and best polynomial order from black polynomial fit
            bestBlackPolyOrder = calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).bestBlackPolyOrder;
            CblackPolyFit      = calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).CblackPolyFit;


            % concatenate transform structs into arrays
            TrawMsmearTo2Dcorrected = calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).TrawMsmearTo2Dcorrected;
            TrawVsmearTo2Dcorrected = calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).TrawVsmearTo2Dcorrected;
            TcorrMsmearToEstSmear   = calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).TcorrMsmearToEstSmear;
            TcorrVsmearToEstSmear   = calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).TcorrVsmearToEstSmear;


            if (isAvailableMaskedSmearPix)

                % delta will be empty if no data is available for a cadence
                deltaRawMsmear = calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).deltaRawMsmear;
                validMsmearPixelIndicators = ~mSmearGaps(:, cadenceIndex);

                if (~isempty(deltaRawMsmear))
                    % set the data gaps to zero
                    deltaRawMsmear(~validMsmearPixelIndicators) = 0;
                end

                CmSmearRaw =  sparse(diag(deltaRawMsmear.^2));

                % save covariance matrix to intermediate struct
                if (debugLevel >= 2)
                    if ~pouEnabled
                        calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).CmSmearRaw = CmSmearRaw;
                    end
                end
            end

            if (isAvailableVirtualSmearPix)

                % delta will be empty if no data is available for a cadence
                deltaRawVsmear = calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).deltaRawVsmear;
                validVsmearPixelIndicators = ~vSmearGaps(:, cadenceIndex);

                if (~isempty(deltaRawVsmear))
                    % set the data gaps to zero
                    deltaRawVsmear(~validVsmearPixelIndicators) = 0;
                end

                CvSmearRaw =  sparse(diag(deltaRawVsmear.^2));

                % save covariance matrix to intermediate struct
                if (debugLevel >= 2)
                    if ~pouEnabled
                        calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).CvSmearRaw = CvSmearRaw;
                    end
                end
            end

            if (isAvailableMaskedSmearPix)
                %----------------------------------------------------------------------
                % Step 3: compute 2D black corrected masked smear pixel uncertainties cov matrix
                %----------------------------------------------------------------------
                CmSmear2Dcorrected = TrawMsmearTo2Dcorrected * CmSmearRaw * TrawMsmearTo2Dcorrected';

                clear CmSmearRaw
                %----------------------------------------------------------------------
                % Step 4: compute black corrected masked smear pixel uncertainties cov matrix
                %----------------------------------------------------------------------
                A = weighted_design_matrix(mSmearColumns(:), 1, bestBlackPolyOrder, 'standard');

                CblackPolyFitForMsmear = A* CblackPolyFit *A';

                CmSmearBlackCorrected = CblackPolyFitForMsmear + CmSmear2Dcorrected;

                if (debugLevel >= 2)
                    save CmSmearBlackCorrected.mat CmSmearBlackCorrected
                end

                CmSmear = CmSmearBlackCorrected;

                clear CmSmear2Dcorrected CblackPolyFitForMsmear CmSmearBlackCorrected

                %--------------------------------------------------------------------------
                % Step 5: compute nonlinearity corrected masked smear pixel uncertainties
                % cov matrix if linearityCorrectionEnabled
                %--------------------------------------------------------------------------
                if (calObject.moduleParametersStruct.linearityCorrectionEnabled)

                    TBlkCorrMsmearToNonlinCorrMsmear = ...
                        calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).TBlkCorrMsmearToNonlinCorrMsmear;

                    Ctmp = scalecol(TBlkCorrMsmearToNonlinCorrMsmear, CmSmear);  % CmSmear is = CmSmearBlackCorrected

                    CmSmearLinearityCorrected = scalerow(TBlkCorrMsmearToNonlinCorrMsmear', Ctmp);

                    if (debugLevel >= 2)
                        save CmSmearLinearityCorrected.mat CmSmearLinearityCorrected
                    end

                    CmSmear = CmSmearLinearityCorrected;

                    clear Ctmp CmSmearLinearityCorrected

                end

                %--------------------------------------------------------------------------
                % Step 6: compute gain corrected masked smear pixel uncertainties cov matrix
                %--------------------------------------------------------------------------
                TgainCorrMsmear = calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).TgainCorrMsmear;

                CmSmearGainCorrected = TgainCorrMsmear* CmSmear * TgainCorrMsmear'; % CmSmear is either CmSmearBlackCorrected or CmSmearLinearityCorrected

                if (debugLevel >= 2)
                    save CmSmearGainCorrected.mat CmSmearGainCorrected
                end

                CmSmear = CmSmearGainCorrected;

                clear CmSmearGainCorrected

                %--------------------------------------------------------------------------
                % Step 7: compute undershoot corrected masked smear pixel uncertainties cov matrix
                %--------------------------------------------------------------------------
                % Note: undershoot correction uncertainties are currently neglected; see CAL SDD
            end


            if (isAvailableVirtualSmearPix)
                %--------------------------------------------------------------------------
                % Step 3: compute 2D black corrected virtual smear pixel uncertainties cov matrix
                %--------------------------------------------------------------------------
                CvSmear2Dcorrected = TrawVsmearTo2Dcorrected * CvSmearRaw * TrawVsmearTo2Dcorrected';

                clear CvSmearRaw

                %--------------------------------------------------------------------------
                % Step 4: compute black corrected virtual smear pixel uncertainties covariance matrix
                %--------------------------------------------------------------------------
                A = weighted_design_matrix(vSmearColumns(:), 1, bestBlackPolyOrder, 'standard');

                CblackPolyFitForVsmear = A* CblackPolyFit *A';

                CvSmearBlackCorrected = CblackPolyFitForVsmear + CvSmear2Dcorrected;

                if (debugLevel >= 2)
                    save CvSmearBlackCorrected.mat CvSmearBlackCorrected
                end

                CvSmear = CvSmearBlackCorrected;

                clear CvSmear2Dcorrected CblackPolyFitForVsmear CvSmearBlackCorrected

                %--------------------------------------------------------------------------
                % Step 5: compute nonlinearity corrected virtual smear pixel uncertainties covariance matrix
                %--------------------------------------------------------------------------
                if (calObject.moduleParametersStruct.linearityCorrectionEnabled)

                    TBlkCorrVsmearToNonlinCorrVsmear = ...
                        calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).TBlkCorrVsmearToNonlinCorrVsmear;

                    Ctmp = scalecol(TBlkCorrVsmearToNonlinCorrVsmear, CvSmear);  % CvSmear is = CvSmearBlackCorrected

                    CvSmearLinearityCorrected = scalerow(TBlkCorrVsmearToNonlinCorrVsmear', Ctmp);

                    if (debugLevel >= 2)
                        save CvSmearLinearityCorrected.mat CvSmearLinearityCorrected
                    end

                    CvSmear = CvSmearLinearityCorrected;

                    clear Ctmp CvSmearLinearityCorrected
                end

                %--------------------------------------------------------------------------
                % Step 6: compute gain corrected virtual smear pixel uncertainties covariance matrix
                %--------------------------------------------------------------------------
                TgainCorrVsmear = calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).TgainCorrVsmear;

                CvSmearGainCorrected = TgainCorrVsmear* CvSmear * TgainCorrVsmear'; % CvSmear is either CvSmearBlackCorrected or CvSmearLinearityCorrected

                if (debugLevel >= 2)
                    save CvSmearGainCorrected.mat CvSmearGainCorrected
                end

                CvSmear = CvSmearGainCorrected;

                clear CvSmearGainCorrected

                %--------------------------------------------------------------------------
                % Step 7: compute undershoot corrected virtual smear pixel uncertainties covariance matrix
                %--------------------------------------------------------------------------
                % Note: undershoot correction uncertainties are currently neglected; see CAL SDD (TBD)
            end

            %--------------------------------------------------------------------------
            % Step 8: compute smear level estimate cov and dark current uncertainties cov matrices
            %--------------------------------------------------------------------------
            validSmearColumnsForThisCadence = validSmearColumns(:, cadenceIndex);

            if any(validSmearColumnsForThisCadence)

                CsmearEstimate = TcorrMsmearToEstSmear * CmSmear * TcorrMsmearToEstSmear' + ...
                    TcorrVsmearToEstSmear * CvSmear * TcorrVsmearToEstSmear';
            else
                % uncertainty on the median value (metric)
                % CdarkSubtraction = darkCurrentsUncertainty(cadenceIndex).^2;

                % CsmearEstimate = CmSmearGainCorrected  + CdarkSubtraction; %uncomment after fixing darkCurrentsUncertainty extraction
                CsmearEstimate = CmSmear;
            end

            validDarkColumnsForThisCadence = validSmearColumns(:, cadenceIndex);

            if any(validDarkColumnsForThisCadence)

                CdarkCorrection = CmSmear + CvSmear;
            else  % no virtual smear
                CdarkCorrection = [];
            end

            %--------------------------------------------------------------------------
            % Compute uncertainties in mean metrics and save for compute_collateral_metrics
            %--------------------------------------------------------------------------
            if ~isempty(CsmearEstimate)
                Csmear = ...
                    CsmearEstimate(validSmearColumnsForThisCadence, validSmearColumnsForThisCadence);
                calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).meanSmearLevelUncertainty = ...
                    sqrt(mean(mean(Csmear)));
            else
                calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).meanSmearLevelUncertainty = [];
            end

%             if ~isempty(CdarkCorrection)
%                 Cdark = ...
%                     CdarkCorrection(validDarkColumnsForThisCadence, validDarkColumnsForThisCadence);
% %                 calIntermediateStruct.darkCurrentUncertaintyStruct(cadenceIndex).meanDarkLevelUncertainty = ...
% %                     sqrt(mean(mean(Cdark)));
%             else
% %                 calIntermediateStruct.darkCurrentUncertaintyStruct(cadenceIndex).meanDarkLevelUncertainty = [];
%             end
%             clear Csmear Cdark            
            clear Csmear

            % check for NaNs
            if (any(any(isnan(CsmearEstimate))))
                error('CAL:compute_smear_and_dark_uncertainties:CsmearEstimate', ...
                    'CsmearEstimate: presence of NaNs');
            end

            if (any(any(isnan(CdarkCorrection))))
                error('CAL:compute_smear_and_dark_uncertainties:CdarkCorrection', ...
                    'CdarkCorrection: presence of NaNs');
            end

            %--------------------------------------------------------------------------
            % save covariance matrices for later analysis

            if (debugLevel >= 2)
                save  CsmearEstimate.mat CsmearEstimate
                save  CdarkCorrection.mat CdarkCorrection
            end
            clear CsmearEstimate CdarkCorrection


            duration = toc;
            if (duration > 10+lastDuration)
                lastDuration = duration;
                display(['CAL:compute_smear_and_dark_uncertainties: Covariance CsmearEstimate and CdarkCorrection computed for cadence ' num2str(cadenceIndex) ': ' num2str(duration/60, '%10.2f') ' minutes']);
            end
        end
    end
end

return;
