function [calObject, calIntermediateStruct, calTransformStruct] = ...
    correct_collateral_pix_undershoot(calObject, calIntermediateStruct, calTransformStruct)
% function [calObject, calIntermediateStruct, calTransformStruct] = ...
%     correct_collateral_pix_undershoot(calObject, calIntermediateStruct, calTransformStruct)
%
% This calClass method corrects for undershoot/overshoot artifacts caused by the LDE electronics chain.  Based on Ball tests, these
% artifacts can be modeled as a linear, shift-invariant (LSI) distortion (see notes by J.Jenkins in svn). The undershoot model is extracted
% from FC for all cadences, and an inverse filter is applied to the pixel rows of interest.
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


%--------------------------------------------------------------------------
% extract parameters and timestamps
%--------------------------------------------------------------------------
% extract stuff from calObject
smearBlob   = calObject.smearBlob;
pouEnabled  = calObject.pouModuleParametersStruct.pouEnabled;
enableLcInformSmear = calObject.moduleParametersStruct.enableLcInformSmear;
cadenceType = calObject.cadenceType;
ccdModule   = calObject.ccdModule;
ccdOutput   = calObject.ccdOutput;
configMap   = calObject.spacecraftConfigMap;

% get timestamps and cadence numbers
cadenceTimes    = calObject.cadenceTimes;
timestamp       = cadenceTimes.timestamp;
timeGaps        = cadenceTimes.gapIndicators;
cadenceNumbers  = cadenceTimes.cadenceNumbers;
nCadences       = length(cadenceNumbers);

% interpolate timestamps to fill gaps (gaps contain zeros) 
if any( timeGaps )    
    if ~all(timeGaps) && numel(find(~timeGaps)) > 2
        timestamp(timeGaps) = interp1(cadenceNumbers(~timeGaps),timestamp(~timeGaps),cadenceNumbers(timeGaps),'linear','extrap');
    else
        error('Less than 2 valid timestamps in UOW. Cannot interpolate timestamps over gaps.');
    end
end

% extract ccd col information for re-constructing pixel rows
nCcdColumns = calIntermediateStruct.nCcdColumns;
ccdColumns  = (1:nCcdColumns)';

%--------------------------------------------------------------------------
% retrieve undershoot model
%--------------------------------------------------------------------------
undershootModel = calObject.undershootModel;

% create the undershoot object
undershootObject  = undershootClass(undershootModel);

% get the coefficients of the undershoot filter
undershootCoeffts = get_undershoot_CAL(undershootObject, timestamp, ccdModule, ccdOutput);

%--------------------------------------------------------------------------
% unpack smear pixel data
%--------------------------------------------------------------------------
% extract smear pixels which have already been black corrected and linearity corrected
mSmearPixels  = calIntermediateStruct.mSmearPixels;
mSmearColumns = calIntermediateStruct.mSmearColumns;
mSmearGaps    = calIntermediateStruct.mSmearGaps;
vSmearPixels  = calIntermediateStruct.vSmearPixels;
vSmearColumns = calIntermediateStruct.vSmearColumns;
vSmearGaps    = calIntermediateStruct.vSmearGaps;

%--------------------------------------------------------------------------
% extract lc smear data from smear blob if needed
%--------------------------------------------------------------------------
if strcmpi(cadenceType,'SHORT') && enableLcInformSmear
    
    if ~isempty(smearBlob)
    
        % extract LC smear data
        smearCorrectionStructLC = smearBlob.smearCorrectionStructLC;
        lcMjd    = smearCorrectionStructLC.mjd;
        lcMsVals = smearCorrectionStructLC.mSmearPixels;
        lcMsGaps = smearCorrectionStructLC.mSmearGaps;
        lcMsCols = smearCorrectionStructLC.mSmearColumns;
        lcVsVals = smearCorrectionStructLC.vSmearPixels;
        lcVsGaps = smearCorrectionStructLC.vSmearGaps;
        lcVsCols = smearCorrectionStructLC.vSmearColumns; 
        clear smearBlob smearCorrectionStructLC

        % get scaling per sc timestamps from config map and set up scale arrays
        cmObject = configMapClass(configMap);
        readsPerSc = get_number_of_exposures_per_short_cadence_period(cmObject, timestamp);

        if all_rows_equal(readsPerSc)
            readsPerScMs = readsPerSc(1);
            readsPerScVs = readsPerSc(1);
        else
            readsPerScMs = repmat(readsPerSc(:)',size(lcMsVals,1),1);
            readsPerScVs = repmat(readsPerSc(:)',size(lcMsVals,1),1);
        end    

        % scale per read lc smear pixel data to sc
        lcMsVals = lcMsVals .* readsPerScMs;
        lcVsVals = lcVsVals .* readsPerScVs;

        % find common sc/lc columns
        commonMsCols = intersect(lcMsCols,mSmearColumns);
        commonVsCols = intersect(lcVsCols,vSmearColumns);
        
        % get rid of any zero column markers
        commonMsCols = commonMsCols(commonMsCols~=0);
        commonVsCols = commonVsCols(commonVsCols~=0);
        
        % exclude any lc pixels gapped for all cadences (e.g. bleeding columns)
        allMsGaps = find(all(lcMsGaps'));
        allVsGaps = find(all(lcVsGaps'));
        commonMsCols = setdiff(commonMsCols, allMsGaps);
        commonVsCols = setdiff(commonVsCols, allVsGaps);
        
        % interpolate lc smear over time into lc gaps using nearest neighbor
        for iPixel = 1:size(lcMsVals,1)
            if  any(lcMsGaps(iPixel,:)) && ~all(lcMsGaps(iPixel,:))
                pixelVals = lcMsVals(iPixel,:);
                pixelVals(lcMsGaps(iPixel,:)) = interp1(find(~lcMsGaps(iPixel,:)), pixelVals(~lcMsGaps(iPixel,:)), find(lcMsGaps(iPixel,:)) , 'nearest', 'extrap');
                lcMsVals(iPixel,:) = pixelVals;
            end
        end
        
        for iPixel = 1:size(lcVsVals,1)
            if  any(lcVsGaps(iPixel,:)) && ~all(lcVsGaps(iPixel,:))
                pixelVals = lcVsVals(iPixel,:);
                pixelVals(lcVsGaps(iPixel,:)) = interp1(find(~lcVsGaps(iPixel,:)), pixelVals(~lcVsGaps(iPixel,:)), find(lcVsGaps(iPixel,:)) , 'nearest', 'extrap');
                lcVsVals(iPixel,:) = pixelVals;
            end
        end
    else
        enableLcInformSmear = false;
    end    
end


%--------------------------------------------------------------------------
% calibrate masked smear pixels for under/overshoot
%--------------------------------------------------------------------------
for cadenceIndex = 1:nCadences

    % correct only for cadences with valid pixels
    missingCadences = calIntermediateStruct.missingMsmearCadences;

    if isempty(missingCadences) || (~isempty(missingCadences) && ~any(ismember(missingCadences, cadenceIndex)))

        allPixels = full( mSmearPixels(:, cadenceIndex) );
        
        validPixelIndicators = ~mSmearGaps(:, cadenceIndex);
        validPixels   = allPixels(validPixelIndicators);
        validColumns  = full( mSmearColumns(validPixelIndicators) );

        if isempty(validPixels) || length(validPixels) < 2
            warning('CAL:correct_collateral_pix_undershoot:NotEnoughValidData', ...
                ['Less than two valid masked smear pixels are available; cannot perform undershoot correction for cadence = ' num2str(cadenceIndex)]);

            % POU: Disable transformations
            % disableLevel = 3 --> transformation = I for both x and Cx
            disableLevel = 3;
            validColumns = ccdColumns;
            interpColumns = ccdColumns;

        else

            % POU: Operate on underlying data only
            % disableLevel = 1 --> transformation = I for Cx
            disableLevel = 1;

            % prep for default nearset neighbor gap filling
            % reconstruct row to account for any spatial gaps, and interpolate
            % this clips the columns to range of populated ones
            interpColumns = max(min(ccdColumns, max(validColumns)), min(validColumns));
            interpColumns = interpColumns(:);
            
            % if flag enabled fill sc gapped pixels from lc smear + bias
            if strcmpi(cadenceType,'SHORT') && enableLcInformSmear && ~isempty(commonMsCols)
                
                %-------------------------------------------------------------------------------------------------
                % use scaled LC smear pixels + bias to fill gaps in SC smear pixels before passing through filter
                %-------------------------------------------------------------------------- ----------------------             
                                
                % interpolate lc common pixels onto sc timestamp for cadence
                lcCommonValsAtScMjd = interp1(lcMjd(:), lcMsVals(commonMsCols,:)', timestamp(cadenceIndex), 'linear','extrap');
                                
                % estimate bias from pixels in common between lc and sc
                bias = robust_mean_std(allPixels(commonMsCols) - lcCommonValsAtScMjd(:));
                
                % interpolate lc data + bias onto sc missing pixels for this cadence
                entireRowInterp = allPixels;
                theseGaps = mSmearGaps(:,cadenceIndex);
                entireRowInterp(theseGaps) = bias + interp1(lcMjd(:), lcMsVals(theseGaps,:)', timestamp(cadenceIndex), 'linear','extrap');
                
                % if any of the sc gaps were filled with all gapped (LC) columns go back and fill them now by nearest neighbor
                if any( theseGaps(allMsGaps) )
                    allColLogical = false(size(ccdColumns));
                    allColLogical(allMsGaps) = true;
                    gapsToFill = allColLogical & theseGaps;
                    validDataLogical = true(size(ccdColumns)) & ~gapsToFill;
                    
                    % interpolate over pixels with nearest neighbor
                    entireRowInterp(gapsToFill) = interp1(find(validDataLogical), entireRowInterp(validDataLogical), find(gapsToFill), 'nearest', 'extrap');
                end
                
            else            
                % fill gaps by nearest neighbor interpolation
                entireRowInterp = interp1(validColumns, validPixels, interpColumns, 'linear');
            end
            
            % apply undershoot correction filter to row
            undershootCorrectedRow = filter(1, undershootCoeffts(cadenceIndex, :), entireRowInterp);

            % save corrected pixels
            calIntermediateStruct.mSmearPixels(validPixelIndicators, cadenceIndex) = undershootCorrectedRow(validPixelIndicators);

        end

        if pouEnabled
            % copy calTransformStruct into shorter temporary structure
            tStruct = calTransformStruct(:,cadenceIndex);

            % select valid data
            tStruct = append_transformation(tStruct, 'selectIndex', 'mSmearEstimate', disableLevel,...
                validColumns);

            % fill gaps using interp1 with linear method
            tStruct = append_transformation(tStruct, 'interpLinear', 'mSmearEstimate', disableLevel,...
                validColumns, interpColumns);

            % mSmearPixels =  filter(b, a, vSmearPixels)  --> type 'filter'
            tStruct = append_transformation(tStruct, 'filter', 'mSmearEstimate', disableLevel,...
                1, undershootCoeffts(cadenceIndex, :));

            % copy  shorter temporary structure into calTransformStruct
            calTransformStruct(:,cadenceIndex) = tStruct;
        end

    end
end


%--------------------------------------------------------------------------
% calibrate virtual smear pixels for under/overshoot
%--------------------------------------------------------------------------
for cadenceIndex = 1:nCadences

    % correct only for cadences with valid pixels
    missingCadences = calIntermediateStruct.missingVsmearCadences;

    if isempty(missingCadences) || (~isempty(missingCadences) && ~any(ismember(missingCadences, cadenceIndex)))

        allPixels = full( vSmearPixels(:, cadenceIndex) );
        
        validPixelIndicators = ~vSmearGaps(:, cadenceIndex);
        validPixels  = allPixels(validPixelIndicators);
        validColumns = full( vSmearColumns(validPixelIndicators) );

        if isempty(validPixels) || length(validPixels) < 2
            warning('CAL:correct_collateral_pix_undershoot:NotEnoughValidData', ...
                ['Less than two valid virtual smear pixels are available; cannot perform undershoot correction for cadence = ' num2str(cadenceIndex)]);

            % POU: Disable transformations
            % disableLevel = 3 --> transformation = I for both x and Cx
            disableLevel = 3;
            validColumns = ccdColumns;
            interpColumns = ccdColumns;

        else

            % POU: Operate on underlying data only
            % disableLevel = 1 --> transformation = I for Cx
            disableLevel = 1;
            
            % prep for default nearset neighbor gap filling
            % reconstruct row to account for any spatial gaps, and interpolate
            % this clips the columns to range of populated ones
            interpColumns = max(min(ccdColumns, max(validColumns)), min(validColumns));
            interpColumns = interpColumns(:);

            % if flag enabled fill sc gapped pixels from lc smear + bias
            if strcmpi(cadenceType,'SHORT') && enableLcInformSmear && ~isempty(commonVsCols)
                
                %-------------------------------------------------------------------------------------------------
                % use scaled LC smear pixels + bias to fill gaps in SC smear pixels before passing through filter
                %-------------------------------------------------------------------------- ----------------------                
                
                % interpolate lc common pixels onto sc timestamp for cadence
                lcCommonValsAtScMjd = interp1(lcMjd(:), lcVsVals(commonVsCols,:)', timestamp(cadenceIndex), 'linear','extrap');
                                
                % estimate bias from pixels in common between lc and sc
                bias = robust_mean_std(allPixels(commonVsCols) - lcCommonValsAtScMjd(:));
                
                % interpolate lc data + bias onto sc missing pixels for this cadence
                entireRowInterp = allPixels;
                theseGaps = vSmearGaps(:,cadenceIndex);
                entireRowInterp(theseGaps) = bias + interp1(lcMjd(:), lcVsVals(theseGaps,:)', timestamp(cadenceIndex), 'linear','extrap');                
                
                % if any of the sc gaps were filled with all gapped (LC) columns go back and fill them now by nearest neighbor
                if any( theseGaps(allVsGaps) )
                    allColLogical = false(size(ccdColumns));
                    allColLogical(allVsGaps) = true;
                    gapsToFill = allColLogical & theseGaps;
                    validDataLogical = true(size(ccdColumns)) & ~gapsToFill;
                    
                    % interpolate over pixels with nearest neighbor
                    entireRowInterp(gapsToFill) = interp1(find(validDataLogical), entireRowInterp(validDataLogical), find(gapsToFill), 'nearest', 'extrap');
                end
                
            else            
                % fill gaps by nearest neighbor interpolation
                entireRowInterp = interp1(validColumns, validPixels, interpColumns, 'linear');
            end

            % apply undershoot correction filter to row
            undershootCorrectedRow = filter(1, undershootCoeffts(cadenceIndex, :), entireRowInterp);

            % save corrected pixels
            calIntermediateStruct.vSmearPixels(validPixelIndicators, cadenceIndex) = undershootCorrectedRow(validPixelIndicators);

        end

        if pouEnabled
            % copy calTransformStruct into shorter temporary structure
            tStruct = calTransformStruct(:,cadenceIndex);

            % select valid data
            tStruct = append_transformation(tStruct, 'selectIndex', 'vSmearEstimate', disableLevel,...
                validColumns);

            % fill gaps using interp1 with linear method
            tStruct = append_transformation(tStruct, 'interpLinear', 'vSmearEstimate', disableLevel,...
                validColumns, interpColumns);

            % mSmearPixels =  filter(b, a, vSmearPixels)  --> type 'filter'
            tStruct = append_transformation(tStruct, 'filter', 'vSmearEstimate', disableLevel,...
                1, undershootCoeffts(cadenceIndex, :));

            % copy  shorter temporary structure into calTransformStruct
            calTransformStruct(:,cadenceIndex) = tStruct;
        end
    end
end

%-------------------------------------------------------------------------------------------------
% make smearCorrectionStructLC if processing LC data and attach to output
%-------------------------------------------------------------------------- ----------------------
if strcmpi(cadenceType,'LONG') 
    
    % convert lc pixel value to 'per exposure' before storing
    cmObject = configMapClass(configMap);    
    readsPerLc = get_number_of_exposures_per_long_cadence_period(cmObject, timestamp);
    
    if all_rows_equal(readsPerLc)
        mScale = readsPerLc(1);
        vScale = readsPerLc(1);
    else
        mScale = repmat(readsPerLc(:)',size(mSmearPixels,1),1);
        vScale = repmat(readsPerLc(:)',size(vSmearPixels,1),1);
    end
    
    % this is the smear pixel data prior to the undershoot correction
    smearCorrectionStructLC = struct('mjd',timestamp,...
                                     'mSmearPixels',mSmearPixels./mScale,...
                                     'mSmearGaps',mSmearGaps,...
                                     'mSmearColumns',mSmearColumns,...
                                     'vSmearPixels',vSmearPixels./vScale,...
                                     'vSmearGaps',vSmearGaps,...
                                     'vSmearColumns',vSmearColumns);
else
    smearCorrectionStructLC = [];
end

calIntermediateStruct.smearCorrectionStructLC = smearCorrectionStructLC;

return;
