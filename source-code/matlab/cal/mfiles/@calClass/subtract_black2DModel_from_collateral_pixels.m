function [calObject, calIntermediateStruct, calTransformStruct] = ...
    subtract_black2DModel_from_collateral_pixels(calObject, calIntermediateStruct, ...
    twoDBlackArray, cadenceIndex, calTransformStruct)
% function [calObject, calIntermediateStruct, calTransformStruct] = ...
%     subtract_black2DModel_from_collateral_pixels(calObject, calIntermediateStruct, ...
%     twoDBlackArray, cadenceIndex, calTransformStruct)
%
% function to correct collateral pixels for 2D black level, which is extracted from FC on a per cadence basis.  Uncertainties are propagated
% if pouEnabled.
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

% get flags
pouEnabled  = calObject.pouModuleParametersStruct.pouEnabled;
isAvailableBlackPix         = calIntermediateStruct.dataFlags.isAvailableBlackPix;
isAvailableMaskedBlackPix   = calIntermediateStruct.dataFlags.isAvailableMaskedBlackPix;
isAvailableVirtualBlackPix  = calIntermediateStruct.dataFlags.isAvailableVirtualBlackPix;
isAvailableMaskedSmearPix   = calIntermediateStruct.dataFlags.isAvailableMaskedSmearPix;
isAvailableVirtualSmearPix  = calIntermediateStruct.dataFlags.isAvailableVirtualSmearPix;
processShortCadence         = calIntermediateStruct.dataFlags.processShortCadence;
dynamic2DBlackEnabled       = calIntermediateStruct.dataFlags.dynamic2DBlackEnabled;

% get exclusion rows from object and save to intermediateStruct
[blackRowsToExcludeInFit, chargeInjectionRows, frameTransferRows] = get_black_rows_to_exclude_for_1D_black_fit(calObject);
calIntermediateStruct.blackRowsToExcludeInFit   = blackRowsToExcludeInFit;
calIntermediateStruct.chargeInjectionRows       = chargeInjectionRows;
calIntermediateStruct.frameTransferRows         = frameTransferRows;

% extract number of exposures
numberOfExposures = calIntermediateStruct.numberOfExposures;
if numel(numberOfExposures) > 1
    numberOfExposures = numberOfExposures(cadenceIndex);
end

% need all rows in ccd to build "black correction" in dynamic 2D case
allRows = 1:calIntermediateStruct.nCcdRows;

% get black columns and smear rows that were summed onboard spacecraft
blackColumnStart = calIntermediateStruct.blackColumnStart;
blackColumnEnd   = calIntermediateStruct.blackColumnEnd;
mSmearRowStart   = calIntermediateStruct.mSmearRowStart;
mSmearRowEnd     = calIntermediateStruct.mSmearRowEnd;
vSmearRowStart   = calIntermediateStruct.vSmearRowStart;
vSmearRowEnd     = calIntermediateStruct.vSmearRowEnd;

if numel(blackColumnStart) > 1 && numel(blackColumnEnd) > 1
    blackColumns = blackColumnStart(cadenceIndex):blackColumnEnd(cadenceIndex);
else
    blackColumns = blackColumnStart:blackColumnEnd;
end

if numel(mSmearRowStart) > 1 && numel(mSmearRowEnd) > 1
    mSmearRows = mSmearRowStart(cadenceIndex):mSmearRowEnd(cadenceIndex);
else
    mSmearRows = mSmearRowStart:mSmearRowEnd;
end

if numel(vSmearRowStart) > 1 && numel(vSmearRowEnd) > 1
    vSmearRows = vSmearRowStart(cadenceIndex):vSmearRowEnd(cadenceIndex);
else
    vSmearRows = vSmearRowStart:vSmearRowEnd;
end


if pouEnabled
    % copy calTransformStruct into shorter temporary structure
    tStruct = calTransformStruct(:,cadenceIndex);
end


%--------------------------------------------------------------------------
% extract available collateral pixels
%--------------------------------------------------------------------------
if isAvailableBlackPix

    blackPixels = calIntermediateStruct.blackPixels(:, cadenceIndex); % nPixels x nCadences
    blackGaps   = calIntermediateStruct.blackGaps(:, cadenceIndex);   % nPixels x nCadences
    blackRows   = calIntermediateStruct.blackRows;                    % nPixels x 1
    % find valid pixel indices:
    validBlackPixelIndicators = ~blackGaps;
end

if isAvailableMaskedBlackPix

    mBlackPixels = calIntermediateStruct.mBlackPixels(cadenceIndex); % nCadences x 1
    mBlackGaps   = calIntermediateStruct.mBlackGaps(cadenceIndex);   % nCadences x 1
    % find valid pixel indices:
    validMblackPixelIndicators = ~mBlackGaps;
end

if isAvailableVirtualBlackPix
    vBlackPixels = calIntermediateStruct.vBlackPixels(cadenceIndex); % nCadences x 1
    vBlackGaps   = calIntermediateStruct.vBlackGaps(cadenceIndex);   % nCadences x 1
    % find valid pixel indices:
    validVblackPixelIndicators = ~vBlackGaps;
end

if (isAvailableMaskedSmearPix)
    mSmearPixels  = calIntermediateStruct.mSmearPixels(:, cadenceIndex); % nPixels x nCadences
    mSmearGaps    = calIntermediateStruct.mSmearGaps(:, cadenceIndex);   % nPixels x nCadences
    mSmearColumns = calIntermediateStruct.mSmearColumns;                 % nPixels x 1
    % find valid pixel indices:
    validMsmearPixelIndicators = ~mSmearGaps;
end

if (isAvailableVirtualSmearPix)
    vSmearPixels  = calIntermediateStruct.vSmearPixels(:, cadenceIndex); % nPixels x nCadences
    vSmearGaps    = calIntermediateStruct.vSmearGaps(:, cadenceIndex);   % nPixels x nCadences
    vSmearColumns = calIntermediateStruct.vSmearColumns;                 % nPixels x 1
    % find valid pixel indices:
    validVsmearPixelIndicators = ~vSmearGaps;
end


%--------------------------------------------------------------------------
% build blackCorrection from dynamic 2D black and attach to intermediate struct
%--------------------------------------------------------------------------
if dynamic2DBlackEnabled
    
    % black correction in this case is mean across coadded columns for all rows on ccd
    % this will be used for diagnostics only since this correction is already taken out
    % as part of the dynamic 2D black
    blackCorrection = numberOfExposures .* mean(twoDBlackArray(allRows,blackColumns),2);    
    calIntermediateStruct.blackCorrection(:,cadenceIndex) = blackCorrection(:);
end

%--------------------------------------------------------------------------
% correct black pixels for 2D black
%--------------------------------------------------------------------------
if isAvailableBlackPix && ~isempty(validBlackPixelIndicators)

    correctedPixels = correct_black_for_2Dblack(twoDBlackArray, full(blackPixels(validBlackPixelIndicators)), ...
        blackRows(validBlackPixelIndicators), blackColumns(:), numberOfExposures);
        
    
    if processShortCadence && dynamic2DBlackEnabled
        
        % estimate bias from black pixel residuals
        if length(correctedPixels) > 2
            [dynablackScBias, stdDynablackScBias] = robust_mean_std(correctedPixels);
        elseif length(correctedPixels) == 2
            dynablackScBias = mean(correctedPixels);
            stdDynablackScBias = std(correctedPixels);
        else
            dynablackScBias = 0;
            stdDynablackScBias = 0;
        end
        
        % remove bias from corrected pixels
        correctedPixels = correctedPixels - dynablackScBias; 
        
        % Add bias to 2D black array so all subsequent collateral pixel corrections will get this bias correction automatically
        % WAS: twoDBlackArray = twoDBlackArray - dynablackScBias; -- fix sign and per read normalization of bias term  
        twoDBlackArray = twoDBlackArray + dynablackScBias/numberOfExposures;
        
        % add bias to saved black correction
        calIntermediateStruct.blackCorrection(:,cadenceIndex) = calIntermediateStruct.blackCorrection(:,cadenceIndex) + dynablackScBias;
        
        % save bias in intermediate struct
        calIntermediateStruct.dynablackScBias(cadenceIndex) = dynablackScBias;
        calIntermediateStruct.CdynablackScBias(cadenceIndex) = stdDynablackScBias^2;
        
        % propagate covariance in bias term
        if pouEnabled
            
            % update the bias term
            tStruct = put_primitive_data(tStruct, 'fittedBlackBias', dynablackScBias, stdDynablackScBias^2, []);
            
            % expand bias term to full length of x vector
            tStruct = append_transformation(tStruct, 'userM', 'fittedBlackBias', [], ['ones(',num2str(length(validBlackPixelIndicators)),',1)']);

            % subtract bias term from 2D black black corrected pixels
            tStruct = append_transformation(tStruct, 'diffV', 'residualBlack', [], 'fittedBlackBias',[]);  
        end        
    end
    
    
    % save 2D black corrected black pixels
    calIntermediateStruct.blackPixels(validBlackPixelIndicators, cadenceIndex) = correctedPixels;
    
    
    % add residualBlack primitive data and gap list
    if pouEnabled
        
        % add bias back in for pou
        if processShortCadence && dynamic2DBlackEnabled
            correctedPixels = correctedPixels + dynablackScBias;
        end

        % need to include padding for all rows then seed with valid rows
        tempPixels = zeros(size(validBlackPixelIndicators));
        tempPixels(validBlackPixelIndicators) = correctedPixels;        
        gapList = [];

        tStruct = put_primitive_data(tStruct, 'residualBlack', tempPixels, [], gapList);
    end
    
else
    if pouEnabled
        % insert pou gaps
        tStruct = insert_POU_cadence_gaps(tStruct,{'residualBlack'});
        if processShortCadence && dynamic2DBlackEnabled
            tStruct = insert_POU_cadence_gaps(tStruct,{'fittedBlackBias'});
        end
    end
end

%--------------------------------------------------------------------------
% correct smear pixels for 2D black
%--------------------------------------------------------------------------
if isAvailableMaskedSmearPix && ~isempty(validMsmearPixelIndicators)

    correctedPixels = correct_smear_for_2Dblack(twoDBlackArray, full( mSmearPixels(validMsmearPixelIndicators) ),...
        mSmearRows(:), mSmearColumns(validMsmearPixelIndicators), numberOfExposures);
    
    % save 2D black corrected smear pixels
    calIntermediateStruct.mSmearPixels(validMsmearPixelIndicators, cadenceIndex) = correctedPixels;

    if pouEnabled
% -------------------------------------------
%   UNTESTED - Developed during KSOC-4941 but left untested due to limited scope of ticket
%   Code s/b added since we are estimating the scBias term from the dynablack corrected black collateral and using this to correct the dynamic 2D black array
%   See dynablack correction for black pixels above
%   See compute_collateral_raw_black_uncertainties.m for corresponding changes
%         % add bias back in for pou
%         if processShortCadence && dynamic2DBlackEnabled
%             correctedPixels = correctedPixels + dynablackScBias;
%         end            
% -------------------------------------------            
        % need to include padding for all columns then seed with valid columns
        tempPixels = zeros(size(validMsmearPixelIndicators));
        tempPixels(validMsmearPixelIndicators) = correctedPixels;

        CmSmearPixels = zeros(size(validMsmearPixelIndicators));        % TEMP DUMMY for primitive covariance
        gapList = [];

        %   Start transformation chain for mSmearEstimate with primitive data = mSmearPixels
        tStruct = append_transformation(tStruct, 'eye', 'mSmearEstimate', [],...
            tempPixels, CmSmearPixels.^2, gapList,[],[]);        
% -------------------------------------------
%   UNTESTED - Developed during KSOC-4941 but left untested due to limited scope of ticket
%   Code s/b added since we are estimating the scBias term from the dynablack corrected black collateral and using this to correct the dynamic 2D black array
%   See dynablack correction for black pixels above 
%   See compute_collateral_raw_black_uncertainties.m for corresponding changes
%         if processShortCadence && dynamic2DBlackEnabled
%             % start the bias term
%             tStruct = append_transformation(tStruct, 'eye', 'fittedMSmearBias', [], dynablackScBias, stdDynablackScBias^2, gapList, [], []); 
%             % expand bias term to full length of x vector
%             tStruct = append_transformation(tStruct, 'userM', 'fittedMSmearBias', [], ['ones(',num2str(length(validMsmearPixelIndicators)),',1)']); 
%             % subtract bias term from 2D black corrected pixels
%             tStruct = append_transformation(tStruct, 'diffV', 'mSmearEstimate', [], 'fittedMSmearBias',[]);
%         end      
% -------------------------------------------        
    end
    
else
    if pouEnabled
        tStruct = insert_POU_cadence_gaps(tStruct,{'mSmearEstimate'});
% -------------------------------------------   
%   UNTESTED - Developed during KSOC-4941 but left untested due to limited scope of ticket
%         if processShortCadence && dynamic2DBlackEnabled
%             tStruct = insert_POU_cadence_gaps(tStruct,{'fittedMSmearBias'});
%         end
% -------------------------------------------
    end
end


if isAvailableVirtualSmearPix && ~isempty(validVsmearPixelIndicators)

    correctedPixels = correct_smear_for_2Dblack(twoDBlackArray, full( vSmearPixels(validVsmearPixelIndicators) ),...
        vSmearRows(:), vSmearColumns(validVsmearPixelIndicators), numberOfExposures);
    
    % save 2D black corrected smear pixels
    calIntermediateStruct.vSmearPixels(validVsmearPixelIndicators, cadenceIndex) = correctedPixels;

    if pouEnabled
% -------------------------------------------      
%   UNTESTED - Developed during KSOC-4941 but left untested due to limited scope of ticket
%   Code s/b added since we are estimating the scBias term from the dynablack corrected black collateral and using this to correct the dynamic 2D black array
%   See dynablack correction for black pixels above
%   See compute_collateral_raw_black_uncertainties.m for corresponding changes
%         % add bias back in for pou
%         if processShortCadence && dynamic2DBlackEnabled
%             correctedPixels = correctedPixels + dynablackScBias;
%         end
% -------------------------------------------       
        % need to include padding for all columns then seed with valid columns
        tempPixels = zeros(size(validVsmearPixelIndicators));
        tempPixels(validVsmearPixelIndicators) = correctedPixels;

        CvSmearPixels = zeros(size(validVsmearPixelIndicators));   % TEMP DUMMY for primitive covariance
        gapList = [];

        % Start transformation chain for vSmearEstimate with primitive data = vSmearPixels
        tStruct = append_transformation(tStruct, 'eye', 'vSmearEstimate', [],...
            tempPixels, CvSmearPixels.^2, gapList,[],[]);        
% -------------------------------------------     
%   UNTESTED - Developed during KSOC-4941 but left untested due to limited scope of ticket
%   Code s/b added since we are estimating the scBias term from the dynablack corrected black collateral and using this to correct the dynamic 2D black array
%   See dynablack correction for black pixels above 
%   See compute_collateral_raw_black_uncertainties.m for corresponding changes
%         if processShortCadence && dynamic2DBlackEnabled
%             % start the bias term
%             tStruct = append_transformation(tStruct, 'eye', 'fittedVSmearBias', [], dynablackScBias, stdDynablackScBias^2, gapList, [], []);
%             % expand bias term to full length of x vector
%             tStruct = append_transformation(tStruct, 'userM', 'fittedVSmearBias', [], ['ones(',num2str(length(validVsmearPixelIndicators)),',1)']); 
%             % subtract bias term from 2D black corrected pixels
%             tStruct = append_transformation(tStruct, 'diffV', 'vSmearEstimate', [], 'fittedVSmearBias',[]);
%         end
% -------------------------------------------        
    end
    
else
    if pouEnabled
        tStruct = insert_POU_cadence_gaps(tStruct,{'vSmearEstimate'});
% -------------------------------------------     
%   UNTESTED - Developed during KSOC-4941 but left untested due to limited scope of ticket
%         if processShortCadence && dynamic2DBlackEnabled
%             tStruct = insert_POU_cadence_gaps(tStruct,{'fittedVSmearBias'});
%         end
% -------------------------------------------
    end
end



%--------------------------------------------------------------------------
% correct short cadence data for 2D black, if applicable
%--------------------------------------------------------------------------
if processShortCadence
    if isAvailableMaskedBlackPix && ~isempty(validMblackPixelIndicators)

        correctedPixels = correct_masked_and_virtual_black_for_2Dblack(twoDBlackArray, ...
            mBlackPixels(validMblackPixelIndicators), mSmearRows(:), blackColumns(:), numberOfExposures);
        
        % save 2D black corrected masked black pixels
        calIntermediateStruct.mBlackPixels(cadenceIndex) = correctedPixels;

        if pouEnabled
% -------------------------------------------
%   UNTESTED - Developed during KSOC-4941 but left untested due to limited scope of ticket
%   Code s/b added since we are estimating the scBias term from the dynablack corrected black collateral and using this to correct the dynamic 2D black array
%   See dynablack correction for black pixels above
%   See compute_collateral_raw_black_uncertainties.m for corresponding changes
%         % add bias back in for pou
%         if dynamic2DBlackEnabled
%             correctedPixels = correctedPixels + dynablackScBias;
%         end
% -------------------------------------------            
            % need to include padding for all rows then seed with valid rows
            tempPixels = zeros(size(validMblackPixelIndicators));
            tempPixels(validMblackPixelIndicators) = correctedPixels;
            gapList = [];
            
            tStruct = put_primitive_data(tStruct, 'mBlackEstimate', tempPixels, [], gapList);
% ------------------------------------------- 
%   UNTESTED - Developed during KSOC-4941 but left untested due to limited scope of ticket
%             % propagate covariance in bias term
%             if dynamic2DBlackEnabled            
%                 % update the bias term
%                 tStruct = put_primitive_data(tStruct, 'fittedMBlackBias', dynablackScBias, stdDynablackScBias^2, []);
%                 % expand bias term to full length of x vector
%                 tStruct = append_transformation(tStruct, 'userM', 'fittedMBlackBias', [], ['ones(',num2str(length(validMblackPixelIndicators)),',1)']);
%                 % subtract bias term from 2D black black corrected pixels
%                 tStruct = append_transformation(tStruct, 'diffV', 'mBlackEstimate', [], 'fittedMBlackBias',[]);  
%             end
% -------------------------------------------            
        end
        
    else
        if pouEnabled
            tStruct = insert_POU_cadence_gaps(tStruct,{'mBlackEstimate'});
% -------------------------------------------    
%   UNTESTED - Developed during KSOC-4941 but left untested due to limited scope of ticket
%             if dynamic2DBlackEnabled
%                 tStruct = insert_POU_cadence_gaps(tStruct,{'fittedMBlackBias'});
%             end
% -------------------------------------------
        end
    end


    if isAvailableVirtualBlackPix && ~isempty(validVblackPixelIndicators)

        correctedPixels = correct_masked_and_virtual_black_for_2Dblack(twoDBlackArray, ...
            vBlackPixels(validVblackPixelIndicators), vSmearRows(:), blackColumns(:), numberOfExposures);
        
        % save 2D black corrected virtual black pixels
        calIntermediateStruct.vBlackPixels(cadenceIndex) = correctedPixels;

        if pouEnabled
% -------------------------------------------   
%   UNTESTED - Developed during KSOC-4941 but left untested due to limited scope of ticket
%   Code s/b added since we are estimating the scBias term from the dynablack corrected black collateral and using this to correct the dynamic 2D black array
%   See dynablack correction for black pixels above
%   See compute_collateral_raw_black_uncertainties.m for corresponding changes
%         % add bias back in for pou
%         if dynamic2DBlackEnabled
%             correctedPixels = correctedPixels + dynablackScBias;
%         end
% -------------------------------------------
            % need to include padding for all rows then seed with valid rows
            tempPixels = zeros(size(validVblackPixelIndicators));
            tempPixels(validVblackPixelIndicators) = correctedPixels;
            gapList = [];
            
            tStruct = put_primitive_data(tStruct, 'vBlackEstimate', tempPixels, [], gapList);
% -------------------------------------------        
%   UNTESTED - Developed during KSOC-4941 but left untested due to limited scope of ticket
%             % propagate covariance in bias term
%             if dynamic2DBlackEnabled            
%                 % update the bias term
%                 tStruct = put_primitive_data(tStruct, 'fittedVBlackBias', dynablackScBias, stdDynablackScBias^2, []);
%                 % expand bias term to full length of x vector
%                 tStruct = append_transformation(tStruct, 'userM', 'fittedVBlackBias', [], ['ones(',num2str(length(validVblackPixelIndicators)),',1)']);
%                 % subtract bias term from 2D black black corrected pixels
%                 tStruct = append_transformation(tStruct, 'diffV', 'vBlackEstimate', [], 'fittedVBlackBias',[]);  
%             end            
% -------------------------------------------            
        end
        
    else
        if pouEnabled
            tStruct = insert_POU_cadence_gaps(tStruct,{'vBlackEstimate'});
% -------------------------------------------  
%   UNTESTED - Developed during KSOC-4941 but left untested due to limited scope of ticket
%             if dynamic2DBlackEnabled
%                 tStruct = insert_POU_cadence_gaps(tStruct,{'fittedVBlackBias'});
%             end
% -------------------------------------------
        end
    end
end


if pouEnabled
    % copy tStruct into calTransformStruct for return
    calTransformStruct(:,cadenceIndex) = tStruct;
end


return;

