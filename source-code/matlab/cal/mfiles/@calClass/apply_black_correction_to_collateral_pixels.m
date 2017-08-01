function [calObject, calIntermediateStruct, calTransformStruct] = ...
    apply_black_correction_to_collateral_pixels(calObject, calIntermediateStruct, ...
    cadenceIndex, calTransformStruct)
% function [calObject, calIntermediateStruct, calTransformStruct] = ...
%     apply_black_correction_to_collateral_pixels(calObject, calIntermediateStruct, ...
%     cadenceIndex, calTransformStruct)
%
% function to apply black correction to all collateral pixel data.  The
% black-corrected smear pixels are output and calibrated further, whereas the
% black-corrected black pixels (residuals) are saved for the final cal output
% structure for analysis and are no longer used in CAL.  
%
% INPUT:
%   calObject
%   calIntermediateStruct
%   cadenceIndex
%   nearestAvailableCadence  [integer] to indicate the nearest valid cadence
%                            to use for the case of a missing cadence (used
%                            for figures)
%
% OUTPUT:
%    calObject
%    calIntermediateStruct
%    calTransformStruct
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


% extract data flags
pouEnabled                 = calObject.pouModuleParametersStruct.pouEnabled;
processShortCadence        = calObject.dataFlags.processShortCadence;
isAvailableBlackPix        = calObject.dataFlags.isAvailableBlackPix;
isAvailableMaskedBlackPix  = calObject.dataFlags.isAvailableMaskedBlackPix;
isAvailableVirtualBlackPix = calObject.dataFlags.isAvailableVirtualBlackPix;
isAvailableMaskedSmearPix  = calObject.dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix = calObject.dataFlags.isAvailableVirtualSmearPix;

if pouEnabled
    % copy calTransformStruct into shorter temporary structure
    tStruct = calTransformStruct(:,cadenceIndex);
end


% extract flag that indicates whether black pixels were available for each
% cadence (if false, black correction has been set equal to -1)
blackAvailable = calIntermediateStruct.blackAvailable(cadenceIndex);

% black correction from polynomial fit
blackCorrection = calIntermediateStruct.blackCorrection(:, cadenceIndex);

% get smear rows that were summed onboard spacecraft
mSmearRowStart   = calIntermediateStruct.mSmearRowStart;
mSmearRowEnd     = calIntermediateStruct.mSmearRowEnd;
vSmearRowStart   = calIntermediateStruct.vSmearRowStart;
vSmearRowEnd     = calIntermediateStruct.vSmearRowEnd;

if numel(mSmearRowStart) > 1 && numel(mSmearRowEnd) > 1
    mSmearRows = mSmearRowStart(cadenceIndex):mSmearRowEnd(cadenceIndex);
    mSmearRowsString = [num2str(mSmearRowStart(cadenceIndex)),':',num2str(mSmearRowEnd(cadenceIndex))];                 %#ok<*NASGU>
else
    mSmearRows = mSmearRowStart:mSmearRowEnd;
    mSmearRowsString = [num2str(mSmearRowStart),':',num2str(mSmearRowEnd)];
end

if numel(vSmearRowStart) > 1 && numel(vSmearRowEnd) > 1
    vSmearRows = vSmearRowStart(cadenceIndex):vSmearRowEnd(cadenceIndex);
    vSmearRowsString = [num2str(vSmearRowStart(cadenceIndex)),':',num2str(vSmearRowEnd(cadenceIndex))];
else
    vSmearRows = vSmearRowStart:vSmearRowEnd;
    vSmearRowsString = [num2str(vSmearRowStart),':',num2str(vSmearRowEnd)];
end





if isAvailableMaskedSmearPix && blackAvailable
    
    % extract black 2D corrected masked smear pixels to correct:
    mSmearPixels = calIntermediateStruct.mSmearPixels(:, cadenceIndex);
    
    % find valid pixel indices:
    mSmearGaps = calIntermediateStruct.mSmearGaps(:, cadenceIndex);
    validMsmearPixelIndicators = find(~mSmearGaps);
    
    %--------------------------------------------------------------------------
    % correct masked smear pixels
    %--------------------------------------------------------------------------
    if ~isempty(validMsmearPixelIndicators)
        
        msmearBlackCorrection = mean(blackCorrection(mSmearRows));  %scalar
        
        correctedMsmearPixels = mSmearPixels(validMsmearPixelIndicators) - msmearBlackCorrection;
        
        if pouEnabled
            
            % get variable name index if it exists
            varIdx = iserrorPropStructVariable( tStruct, 'meanBlackmSmear'); 
            
            if ~varIdx                
                % doesn't exist - start new transformation chain for meanBlackvSmear with fittedBlack
                tStruct = append_transformation(tStruct, 'eye', 'meanBlackmSmear', [], 'fittedBlack',[],[],[],[]);
            else
                % it exists but was gapped on first pass - set primitives and clear gapped cadence indicator
                tStruct = put_primitive_data(tStruct, 'meanBlackmSmear', 'fittedBlack', []);
                tStruct(varIdx).cadenceGapped = false;
            end
            
            % take mean value over masked pixel rows only
            weights = ismember(1:length(blackCorrection),mSmearRows);
            
%             % replace above line with text version to save ~1kbyte per cadence but pay for it in processing time when evaluating
%             % uncertainties
%             weights = ['ismember(1:',num2str(length(blackCorrection)),',',mSmearRowsString,')'];
            
            tStruct = append_transformation(tStruct, 'wSum', 'meanBlackmSmear', [], weights);
            scale = 1/length(mSmearRows);
            tStruct = append_transformation(tStruct, 'scale', 'meanBlackmSmear', [], scale);
            
            % expand meanBlackmSmear which is now a scalar into vector the size of mSmearPixels using;
            % M = (column of ones) --> M * meanBlackvSmear = meanBlackvSmear .* (column of ones)
            % write M as string to save space: M = ones(length(mSmearPixels),1);
            M = ['ones(',num2str(length(mSmearPixels)),',1)'];
            tStruct = append_transformation(tStruct, 'userM', 'meanBlackmSmear', [], M);
            
            % mSmearPixels = mSmearPixels - blackCorrection
            tStruct = append_transformation(tStruct, 'diffV', 'mSmearEstimate', [], 'meanBlackmSmear', []);
        end
        
        % save black corrected masked smear pixels
        calIntermediateStruct.mSmearPixels(validMsmearPixelIndicators, cadenceIndex) = correctedMsmearPixels;
    else
        if pouEnabled
            tStruct = insert_POU_cadence_gaps(tStruct,{'meanBlackmSmear'});
        end
    end
else
    if pouEnabled
        tStruct = insert_POU_cadence_gaps(tStruct,{'meanBlackmSmear'});
    end
end

if isAvailableVirtualSmearPix && blackAvailable
    
    % extract black 2D corrected  virtual smear pixels to correct:
    vSmearPixels = calIntermediateStruct.vSmearPixels(:, cadenceIndex);
    
    % find valid pixel indices:
    vSmearGaps = calIntermediateStruct.vSmearGaps(:, cadenceIndex);
    validVsmearPixelIndicators = find(~vSmearGaps);
    
    %--------------------------------------------------------------------------
    % correct virtual smear pixels
    %--------------------------------------------------------------------------
    if ~isempty(validVsmearPixelIndicators)
        
        vsmearBlackCorrection = mean(blackCorrection(vSmearRows));  % scalar
        
        correctedVsmearPixels = vSmearPixels(validVsmearPixelIndicators) - vsmearBlackCorrection;
        
        if pouEnabled
            
            % get variable name index if it exists
            varIdx = iserrorPropStructVariable( tStruct, 'meanBlackvSmear'); 
            
            if ~varIdx                
                % doesn't exist - start new transformation chain for meanBlackvSmear with fittedBlack
                tStruct = append_transformation(tStruct, 'eye', 'meanBlackvSmear', [], 'fittedBlack',[],[],[],[]);
            else
                % it exists but was gapped on first pass - set primitives and clear gapped cadence indicator
                tStruct = put_primitive_data(tStruct, 'meanBlackvSmear', 'fittedBlack', []);
                tStruct(varIdx).cadenceGapped = false;
            end
            
            % take mean value over masked pixel rows only
            weights = ismember(1:length(blackCorrection),vSmearRows);
            
%             % replace above line with text version to save ~1kbyte per cadence but pay for it in processing time when evaluating
%             % uncertainties
%             weights = ['ismember(1:',num2str(length(blackCorrection)),',',vSmearRowsString,')'];
                        
            tStruct = append_transformation(tStruct, 'wSum', 'meanBlackvSmear', [], weights);
            scale = 1/length(vSmearRows);
            tStruct = append_transformation(tStruct, 'scale', 'meanBlackvSmear', [], scale);
            
            % expand meanBlackvSmear which is now a scalar into vector the size of vSmearPixels using;
            % M = (column of ones) --> M * meanBlackvSmear = meanBlackvSmear .* (column of ones)
            % write M as string to save space: M = ones(length(vSmearPixels),1);
            M = ['ones(',num2str(length(vSmearPixels)),',1)'];
            tStruct = append_transformation(tStruct, 'userM', 'meanBlackvSmear', [], M);
            
            % vSmearPixels = vSmearPixels - blackCorrection
            tStruct = append_transformation(tStruct, 'diffV', 'vSmearEstimate', [], 'meanBlackvSmear', []);
        end
        
        
        % save black corrected virtual smear pixels
        calIntermediateStruct.vSmearPixels(validVsmearPixelIndicators, cadenceIndex) = correctedVsmearPixels;
    else
        if pouEnabled
            tStruct = insert_POU_cadence_gaps(tStruct,{'meanBlackvSmear'});
        end
    end
else
    if pouEnabled
        tStruct = insert_POU_cadence_gaps(tStruct,{'meanBlackvSmear'});
    end
end


%--------------------------------------------------------------------------
% save black corrected black pixel residuals for calibratedCollateralPixels
% struct in final CAL output.  Create figures of the correction over the
% pixels for diagnostics
%--------------------------------------------------------------------------
if isAvailableBlackPix
    
    blackPixels = calIntermediateStruct.blackPixels(:, cadenceIndex);
    blackGaps = calIntermediateStruct.blackGaps(:, cadenceIndex);
    
    % find valid pixel indices:
    validBlackPixelIndicators = ~blackGaps;
    
    if any(validBlackPixelIndicators)
        
        correctedBlackPixels = blackPixels(validBlackPixelIndicators) - blackCorrection(validBlackPixelIndicators);
        
        % Add correct propagation of uncertainties. residualBlack must include transformation which removes fitted black (blackCorrection).
        if pouEnabled
            % add transformation: blackResidual - fittedBlack
            tStruct = append_transformation(tStruct, 'diffV', 'residualBlack', [], 'fittedBlack', []);
        end
        
        % save black corrected black pixels
        calIntermediateStruct.blackPixels(validBlackPixelIndicators, cadenceIndex) = correctedBlackPixels;
        
    end
end


if processShortCadence
    
    if isAvailableMaskedBlackPix
        
        mBlackPixels = calIntermediateStruct.mBlackPixels(cadenceIndex); % scalar
        mBlackGaps = calIntermediateStruct.mBlackGaps(cadenceIndex);     % scalar
        
        % find valid pixel indices:
        validMblackPixelIndicators = ~mBlackGaps;
        
        if validMblackPixelIndicators
            
            mBlackCorrection = mean(blackCorrection(mSmearRows));        % scalar
            
            correctedMblackPixel = mBlackPixels(validMblackPixelIndicators) - mBlackCorrection; % scalar
            
            %  Add correct propagation of uncertainties. mBlackEstimate must include
            %  transformation which removes mean of fitted black (blackCorrection) over
            %  the coadded rows.
            if pouEnabled
                
                % get variable name index if it exists
                varIdx = iserrorPropStructVariable( tStruct, 'meanBlackmBlack'); 

                if ~varIdx                
                    % doesn't exist - start new transformation chain for meanBlackvSmear with fittedBlack
                    tStruct = append_transformation(tStruct, 'eye', 'meanBlackmBlack', [], 'meanBlackmSmear',[],[],[],[]);
                else
                % it exists but was gapped on first pass - set primitives and clear gapped cadence indicator
                tStruct = put_primitive_data(tStruct, 'meanBlackmBlack', 'meanBlackmSmear', []);
                tStruct(varIdx).cadenceGapped = false;
                end
                
                % make this vector of length(mSmearPixels) identical values back into a scalar
                weights = ['ones(',num2str(length(mSmearPixels)),',1)'];
                tStruct = append_transformation(tStruct, 'wMean', 'meanBlackmBlack', [], weights);
                
                % mBlackEstimate = mBlackEstimate - mean(mBlackCorrection);
                tStruct = append_transformation(tStruct, 'diffV', 'mBlackEstimate', [], 'meanBlackmBlack', []);
            end
            
            % save black corrected masked black pixels
            calIntermediateStruct.mBlackPixels(cadenceIndex) = correctedMblackPixel;
        else
            if pouEnabled
                tStruct = insert_POU_cadence_gaps(tStruct,{'meanBlackmBlack'});
            end
        end
    else
        if pouEnabled
            tStruct = insert_POU_cadence_gaps(tStruct,{'meanBlackmBlack'});
        end
    end
    
    if isAvailableVirtualBlackPix
        
        vBlackPixels = calIntermediateStruct.vBlackPixels(cadenceIndex); % scalar
        vBlackGaps = calIntermediateStruct.vBlackGaps(cadenceIndex);     % scalar
        
        % find valid pixel indices:
        validVblackPixelIndicators = ~vBlackGaps;
        
        if validVblackPixelIndicators
            
            vBlackCorrection = mean(blackCorrection(vSmearRows));        % scalar
            correctedVblackPixel = vBlackPixels(validVblackPixelIndicators) - vBlackCorrection; % scalar
            
            
            % Add correct propagation of uncertainties. vBlackEstimate must include
            % transformation which removes mean of fitted black (blackCorrection) over
            % the coadded rows.
            if pouEnabled
                
                % get variable name index if it exists
                varIdx = iserrorPropStructVariable( tStruct, 'meanBlackvBlack'); 

                if ~varIdx                
                    % doesn't exist - start new transformation chain for meanBlackvSmear with fittedBlack
                    tStruct = append_transformation(tStruct, 'eye', 'meanBlackvBlack', [], 'meanBlackvSmear',[],[],[],[]);
                else
                % it exists but was gapped on first pass - set primitives and clear gapped cadence indicator
                tStruct = put_primitive_data(tStruct, 'meanBlackvBlack', 'meanBlackvSmear', []);
                tStruct(varIdx).cadenceGapped = false;
                end
                
                % make this vector of length(vSmearPixels) identical values back into a scalar
                weights = ['ones(',num2str(length(vSmearPixels)),',1)'];
                tStruct = append_transformation(tStruct, 'wMean', 'meanBlackvBlack', [], weights);
                
                % vBlackEstimate = vBlackEstimate - mean(vBlackCorrection);
                tStruct = append_transformation(tStruct, 'diffV', 'vBlackEstimate', [], 'meanBlackvBlack', []);
            end
            
            
            % save black corrected virtual black pixels
            calIntermediateStruct.vBlackPixels(cadenceIndex) = correctedVblackPixel;
        else
            if pouEnabled
                tStruct = insert_POU_cadence_gaps(tStruct,{'meanBlackvBlack'});
            end
        end
    else
        if pouEnabled
            tStruct = insert_POU_cadence_gaps(tStruct,{'meanBlackvBlack'});
        end
    end
end

if pouEnabled
    % copy tStruct into calTransformStruct for return
    calTransformStruct(:,cadenceIndex) = tStruct;
end

return;
