function [calOutputStruct, calTransformStruct, compressedData ] = update_uncertainties_in_cal_outputs(calObject, calOutputStruct, calTransformStruct, compressedData)
%
% function [calOutputStruct, calTransformStruct, compressedData ] = update_uncertainties_in_cal_outputs(calObject, calOutputStruct, calTransformStruct, compressedData)
% 
% This calDataClass method returns unaltered inputs (calOutputStruct, calTransformStruct, compressedData) if pouEnabled = false. Otherwise it
% updates the calOutputStruct with uncertainties propagated from primitive data using the calTransformStruct. If compressionEnabled = true
% it compresses the calTransformStruct and saves the compressed data in the compressedData struct. If this is the last call calTransformStruct
% and compressedData from all invocations are read from local files and concatenated and the structures representing cal pou for the full
% unit of work are returned. Otherwise the calTransformStruct and compressedData for this invoaction are written to a local file.
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



% start clock
tic;
metricsKey = metrics_interval_start;

% extract things from the calObject
pouParameterStruct  = calObject.pouModuleParametersStruct;
localFilenames      = calObject.localFilenames;
firstCall           = calObject.firstCall;
lastCall            = calObject.lastCall;
invocation          = calObject.calInvocationNumber;
dataFlags           = calObject.dataFlags;
pouEnabled          = pouParameterStruct.pouEnabled;
compressFlag        = pouParameterStruct.compressionEnabled;
startVariableIndex  = pouParameterStruct.startVariableIndex;
maxSvdOrder         = pouParameterStruct.maxSvdOrder;
pouRootFilename     = localFilenames.pouRootFilename;
stateFilePath       = localFilenames.stateFilePath;

moduleParametersStruct  = calObject.moduleParametersStruct;
enableExcludeIndicators = moduleParametersStruct.enableExcludeIndicators;
enableExcludePreserve   = moduleParametersStruct.enableExcludePreserve;
excludeIndicators       = calObject.cadenceTimes.dataAnomalyFlags.excludeIndicators;


if pouEnabled
    
    % find the index of the last entry in the structure
    [~, variableList] = iserrorPropStructVariable(calTransformStruct(:,1),'');
%     % matlab-2007a version
%     [dummy, variableList] = iserrorPropStructVariable(calTransformStruct(:,1),'');
    endVariableIndex = length(variableList);
    
    % update cadence gaps based on exclude indicators
    if enableExcludeIndicators && enableExcludePreserve
        calTransformStruct(startVariableIndex:endVariableIndex,:) = ...
            set_cadence_gaps_in_calTransformStruct(calTransformStruct(startVariableIndex:endVariableIndex,:), excludeIndicators);
    end
    
    % fill any cadence gaps
    calTransformStruct(startVariableIndex:endVariableIndex,:) = ...
        fill_cadence_gaps_in_calTransformStruct(calTransformStruct(startVariableIndex:endVariableIndex,:));
    
    if firstCall
        % calculate collateral variance
        display('CAL:cal_matlab_controller: Calculating collateral variances from POU struct...');
        collateralVarStruct = get_collateral_data_variance_struct(calTransformStruct, pouParameterStruct);
        
        % use uncertainty = sqrt(variance) on the output
        calOutputStruct = update_calOutput_w_collateral_variance(calOutputStruct, collateralVarStruct);
    else
        % make a working copy of calTransformStruct
        tempStruct = calTransformStruct;
        
        if compressFlag
            % save a copy of calTransformStruct so it can be restored after it is overwritten
            savedStruct = calTransformStruct;
            
            % load existing compressed calTransformStruct and compressedData
            % insert compressed collateral calTransformStruct elements into working copy of calTransformStruct
            load( [stateFilePath, localFilenames.pouRootFilename, '_0.mat'] );
            tempStruct(1:endVariableIndex-1,1) = calTransformStruct(1:endVariableIndex-1);
            
            % restore calTransformStruct
            calTransformStruct = savedStruct;
        end
        
        % calculate photometric variance
        display('CAL:cal_matlab_controller: Calculating photometric variances from POU struct...');
        photoVarStruct = get_photometric_data_variance_struct(tempStruct, compressedData, pouParameterStruct);
        clear tempStruct savedStruct
        
        % use uncertainty = sqrt(variance) on the output
        calOutputStruct = update_calOutput_w_photometric_variance(calOutputStruct, photoVarStruct);
    end
    
    % extract range of variable indices for this invocation
    a = startVariableIndex;
    b = endVariableIndex;
        
    if compressFlag        
        display('CAL:cal_matlab_controller: Compressing error propagation struct...');    
        
        % minimize the current working subset of calTransformStruct - e.g. struct across all cadences for variables a:b
        tempStruct = minimize_errorPropStructArray(calTransformStruct(a:b,:));
        
        if firstCall
            % compress collateral data using SVD
            [compressedData, tempStruct] = compress_collateral_errorPropStruct(tempStruct, maxSvdOrder, dataFlags);
            calTransformStruct = calTransformStruct(:,1);
            calTransformStruct(a:b) = tempStruct;
        else
            % compress photometric data using SVD
            [compressedPhotometricData, tempStruct] = compress_photometric_errorPropStruct(tempStruct, maxSvdOrder, invocation, dataFlags);            
            % concatenate compressed data array
            compressedData = compressedPhotometricData;
            calTransformStruct = tempStruct;
        end
    else
        % don't compress 
        compressedData = [];
        % save the whole of calTransformStruct for the collateral invocation but
        % save only the part of calTransformStruct for the current photometric invocation
        if ~firstCall
            calTransformStruct = calTransformStruct(a:b,:);
        end
    end
        
    % concatenate errorPropStructs and compressedData on last call and prepare to write pou blob
    if lastCall
        
        % If the aggregated pou state file already exists just load it.
        % This condition should only occur if the lastCall invocation crashed on the previous attempt after
        % the state file was written in this method and it is now being re-run
        
        if exist([stateFilePath,pouRootFilename,'.mat'],'file') == 2 
            
            load([stateFilePath,pouRootFilename,'.mat']);
            
        else
        
            % save data structs from current invocation
            tempS = calTransformStruct;
            tempC = compressedData;

            % start with collateral invocation
            load( [stateFilePath, localFilenames.pouRootFilename, '_0.mat'] );           % loads 'calTransformStruct', 'compressedData'

            % make a working copy of data
            sPou = calTransformStruct;
            sComp = compressedData;

            % get the length of the collateral transformStruct elements
            [~, collateralVariables] = iserrorPropStructVariable(sPou,'');
    %         % matlab-2007a version
    %         [dummy, collateralVariables] = iserrorPropStructVariable(sPou,'');
            nCollateralVariables = length(collateralVariables);

            % pre-allocate by initializing the last compressed element
            if compressFlag
                nCollateralCompressed = length(sComp);
                sComp( nCollateralCompressed + invocation ) = empty_compressedDataStruct;
            end

            % add on from all previous photometric invocations
            display(['     Concatenating pou struct for ',num2str(invocation + 1),' invocations ...']);
            for i = 1:invocation - 1            
                display(['     Loading ',[pouRootFilename,'_',num2str(i), '.mat'],' ...']);  

                load( [stateFilePath, pouRootFilename,'_',num2str(i), '.mat'] );        % loads 'calTransformStruct', 'compressedData'

                % insert the data
                sPou( nCollateralVariables + i, : ) = calTransformStruct;
                if compressFlag
                    sComp( nCollateralCompressed + i ) = compressedData;
                end
            end

            % add current photometric invocation
            display(['     Adding invocation ',num2str(invocation),' ...']);  
            sPou( nCollateralVariables + invocation, : ) = tempS( 1, : );
            if compressFlag
                sComp( nCollateralCompressed + invocation ) = tempC;
            end

            % trim and copy to calTransformStruct
            calTransformStruct = sPou( 1:(nCollateralVariables + invocation),:);

            % copy compressedData struct (it's already the right size)
            compressedData = sComp;
            
            % save errorPropStruct and compressed data for all invocations
            intelligent_save( [stateFilePath,pouRootFilename,'.mat'], 'calTransformStruct', 'compressedData' );

            % clear temp and working data structs
            clear sPou sComp tempS tempC 
        end
        
    else
        % save errorPropStruct and compressed data for this invocation
        intelligent_save( [stateFilePath,pouRootFilename,'_',num2str(invocation),'.mat'], 'calTransformStruct', 'compressedData' );
    end    
end


display_cal_status('CAL:cal_matlab_controller: Calibrated pixel uncertainties updated', 1);
metrics_interval_stop('cal.update_uncertainties_in_cal_outputs.execTimeMillis',metricsKey);

