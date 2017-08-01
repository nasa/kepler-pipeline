function [ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct] = ...
merge_star_positions_with_ancillary_pipeline_structures( ...
ancillaryTargetConfigurationStruct, attitudeSolutionStruct, ...
ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct, ...
ccdModule, ccdOutput, longCadenceTimes, fcConstants, raDec2PixModel)
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct] = ...
% merge_star_positions_with_ancillary_pipeline_structures( ...
% ancillaryTargetConfigurationStruct, attitudeSolutionStruct, ...
% ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct, ...
% ccdModule, ccdOutput, longCadenceTimes, fcConstants, raDec2PixModel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Define course grid of reference stars on module output and identify their
% ra and dec coordinates. Use absolute raDec2Pix with attitude solution to
% trace paths of reference stars on CCD over course of unit of work. Merge
% time series for each star with ancillary pipeline data and configuration
% structures. Propagate the uncertainties in the attitude solution to the
% uncertainties in the positions of the reference stars.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Set the aberrate flag.
ABERRATE_FLAG = 1;

% Define default values.
SMOOTHING_ENABLED = true;
SG_POLY_ORDER = 2;
SG_FRAME_SIZE = 145;

% Check if the attitude solution is populated.
if ~isempty(attitudeSolutionStruct) && ...
        ~isempty(attitudeSolutionStruct.gapIndicators)
    
    % Instantiate a raDec2Pix object.
    raDec2PixObject = raDec2PixClass(raDec2PixModel, 'one-based');

    % Get the ancillary target parameters.
    if ~isfield(ancillaryTargetConfigurationStruct, 'smoothingEnabled')
        smoothingEnabled = SMOOTHING_ENABLED;
    else
        smoothingEnabled = ...
            ancillaryTargetConfigurationStruct.smoothingEnabled;
    end
    
    if ~isfield(ancillaryTargetConfigurationStruct, 'sgPolyOrder')
        sgPolyOrder = SG_POLY_ORDER;
    else
        sgPolyOrder = ...
            ancillaryTargetConfigurationStruct.sgPolyOrder;
    end
    
    if ~isfield(ancillaryTargetConfigurationStruct, 'sgFrameSize')
        sgFrameSize = SG_FRAME_SIZE;
    else
        sgFrameSize = ...
            ancillaryTargetConfigurationStruct.sgFrameSize;
    end
    
    gridSize = ancillaryTargetConfigurationStruct.gridSize;
    modelOrder = ancillaryTargetConfigurationStruct.modelOrder;
    interactionEnabled = ...
        ancillaryTargetConfigurationStruct.interactionEnabled;
    
    % Define course grid of reference stars.
    nTargets = gridSize^2;
    
    nRowsImaging = fcConstants.nRowsImaging;
    nColsImaging = fcConstants.nColsImaging;
    nMaskedSmear = fcConstants.nMaskedSmear;
    nLeadingBlack = fcConstants.nLeadingBlack;
    
    rowSpacing = nRowsImaging / gridSize;
    gridRows = 1 + nMaskedSmear + ...
        round(((1 : gridSize)' - 0.5) * rowSpacing);
    
    columnSpacing = nColsImaging / gridSize;
    gridColumns = 1 + nLeadingBlack + ...
        round(((1 : gridSize)' - 0.5) * columnSpacing);
    
    [column, row] = meshgrid(gridColumns, gridRows);
    row = row( : );
    column = column( : );
    
    % Get the mid-cadence timestamps and attitude solution gap indicators.
    timestamps = longCadenceTimes.midTimestamps;
    gapIndicators = attitudeSolutionStruct.gapIndicators;
    
    % Get the sky coordinates for the reference stars at the first cadence.
    timestamps = timestamps(~gapIndicators);
    raPointing = attitudeSolutionStruct.ra(~gapIndicators);
    decPointing = attitudeSolutionStruct.dec(~gapIndicators);
    rollPointing = attitudeSolutionStruct.roll(~gapIndicators);
    
    [raStars, decStars] = pix_2_ra_dec_absolute(raDec2PixObject, ...
        repmat(ccdModule, size(row)), repmat(ccdOutput, size(row)), ...
        row, column, timestamps(1), raPointing(1), decPointing(1), ...
        rollPointing(1), ABERRATE_FLAG);
    
    % Now get the predicted star positions for the given module output for
    % each valid timestamp in the unit of work.
    [predictedRows, predictedColumns, TpredRowsStruct, TpredColsStruct] = ...
        get_predicted_star_positions_II(raDec2PixObject, ccdModule, ccdOutput, ...
        raStars, decStars, timestamps, raPointing, decPointing, rollPointing, ...
        ABERRATE_FLAG);

    % Propagate the uncertainties in the attitude solution to the
    % uncertainties in the predicted rows and columns for each valid
    % cadence.
    predictedRowUncertainties = zeros(size(predictedRows));
    predictedColumnUncertainties = zeros(size(predictedColumns));
    
    covarianceMatrix11 = ...
        attitudeSolutionStruct.covarianceMatrix11(~gapIndicators);
    covarianceMatrix12 = ...
        attitudeSolutionStruct.covarianceMatrix12(~gapIndicators);
    covarianceMatrix13 = ...
        attitudeSolutionStruct.covarianceMatrix13(~gapIndicators);
    covarianceMatrix22 = ...
        attitudeSolutionStruct.covarianceMatrix22(~gapIndicators);
    covarianceMatrix23 = ...
        attitudeSolutionStruct.covarianceMatrix23(~gapIndicators);
    covarianceMatrix33 = ...
        attitudeSolutionStruct.covarianceMatrix33(~gapIndicators);
    
    for iCadence = 1 : length(timestamps)
        
        attitudeCovariance(1, 1) = covarianceMatrix11(iCadence);
        attitudeCovariance(1, 2) = covarianceMatrix12(iCadence);
        attitudeCovariance(1, 3) = covarianceMatrix13(iCadence);
        attitudeCovariance(2, 2) = covarianceMatrix22(iCadence);
        attitudeCovariance(2, 3) = covarianceMatrix23(iCadence);
        attitudeCovariance(3, 3) = covarianceMatrix33(iCadence);
        
        attitudeCovariance(2, 1) = attitudeCovariance(1, 2);
        attitudeCovariance(3, 1) = attitudeCovariance(1, 3);
        attitudeCovariance(3, 2) = attitudeCovariance(2, 3);
        
        Trow = TpredRowsStruct(iCadence).TpointingToPredRows;
        predictedRowUncertainties( : , iCadence) = ...
            sqrt(diag(Trow * attitudeCovariance * Trow'));
        
        Tcol = TpredColsStruct(iCadence).TpointingToPredCols;
        predictedColumnUncertainties( : , iCadence) = ...
            sqrt(diag(Tcol * attitudeCovariance * Tcol'));
        
    end % for iCadence
    
    % Smooth the row and column motion time series for all of the reference
    % stars if smoothing is enabled. First identify and remove any outliers
    % with the cosmic ray outlier identifier. PROPAGATION OF UNCERTAINTIES
    % SHOULD BE REVISITED AT SOME POINT. FOR NOW THE COTRENDING DOES NOT
    % EMPLOY THE UNCERTAINTIES IN THE ANCILLARY DATA ANYWAY.
    if smoothingEnabled
        
        motionArray = [predictedRows', predictedColumns'];
        [correctedMotionArray, outlierIndicators] = ...
            clean_cosmic_rays_mad(motionArray, false(size(motionArray)), ...
            2, 25, 20, 1, true, true);
        
        isBadCadence = any(outlierIndicators, 2);
        timestamps = timestamps(~isBadCadence);
        predictedRows = predictedRows( : , ~isBadCadence);
        predictedColumns = predictedColumns( : , ~isBadCadence);
        predictedRowUncertainties = ...
            predictedRowUncertainties( : , ~isBadCadence);
        predictedColumnUncertainties = ...
            predictedColumnUncertainties( : , ~isBadCadence);
        
        if sgFrameSize > length(timestamps)
            sgFrameSize = length(timestamps);
        end
        if mod(sgFrameSize, 2) == 0
            sgFrameSize = sgFrameSize - 1;
        end
        
        predictedRows = ...
            sgolayfilt(predictedRows, sgPolyOrder, sgFrameSize, [], 2);
        predictedColumns = ...
            sgolayfilt(predictedColumns, sgPolyOrder, sgFrameSize, [], 2);
        
    end % if smoothingEnabled
    
    % Create ancillary time series for each of the reference stars and
    % append them to the ancillary pipeline data structure. Also create
    % arrays of the mnemonics and interactions. These will later be
    % appended to the ancillary pipeline configuration structure.
    ancillaryDataStruct.timestamps = timestamps;
    
    mnemonics = {};
    interactions = {};
    
    for iTarget = 1 : nTargets
        
        mnemonic1 = ['SOC_PDC_PSEUDO_STAR_ROW_', num2str(iTarget)];
        ancillaryDataStruct.mnemonic = mnemonic1;
        ancillaryDataStruct.values = ...
            predictedRows(iTarget, : )';
        ancillaryDataStruct.uncertainties = ...
            predictedRowUncertainties(iTarget, : )';
        ancillaryPipelineDataStruct = ...
            [ancillaryPipelineDataStruct, ancillaryDataStruct];                                                      %#ok<AGROW>
        
        mnemonic2 = ['SOC_PDC_PSEUDO_STAR_COL_', num2str(iTarget)];
        ancillaryDataStruct.mnemonic = mnemonic2;
        ancillaryDataStruct.values = ...
            predictedColumns(iTarget, : )';
        ancillaryDataStruct.uncertainties = ...
            predictedColumnUncertainties(iTarget, : )';
        ancillaryPipelineDataStruct = ...
            [ancillaryPipelineDataStruct, ancillaryDataStruct];                                                      %#ok<AGROW>
        
        mnemonics = [mnemonics, mnemonic1, mnemonic2];                                          %#ok<AGROW>
        
        if interactionEnabled
            interactions = [interactions, [mnemonic1, '|', mnemonic2]];                         %#ok<AGROW>
        end
        
    end % for iTarget
    
    % Append the configuration parameters to the ancillary pipeline data
    % structure.
    modelOrders = repmat(modelOrder, [2*nTargets, 1]);
    
    ancillaryPipelineConfigurationStruct.mnemonics = ...
        horzcat(ancillaryPipelineConfigurationStruct.mnemonics, ...
        mnemonics);
    ancillaryPipelineConfigurationStruct.modelOrders = ...
        vertcat(ancillaryPipelineConfigurationStruct.modelOrders, ...
        modelOrders);
    ancillaryPipelineConfigurationStruct.interactions = ...
        horzcat(ancillaryPipelineConfigurationStruct.interactions, ...
        interactions);
    
end % if

% Return.
return
