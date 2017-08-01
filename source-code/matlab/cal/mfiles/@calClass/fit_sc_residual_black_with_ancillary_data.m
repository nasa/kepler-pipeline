function [calObject, calIntermediateStruct, calTransformStruct] = ...
    fit_sc_residual_black_with_ancillary_data(calObject, calIntermediateStruct, cadenceIndex, blackCorrectionCoeffs, calTransformStruct)
%[calObject, calIntermediateStruct] = ...
%        fit_sc_residual_black_with_ancillary_data(calObject, calIntermediateStruct, cadenceIndex);
%
% function to compute the black level correction (a 1D array) for the input cadence.
% The function fits the trailing black data for each cadence in two
% segments, masked smear and science pixels. It fits a constant and a
% linear term to the masked smear, and a constant, exponential in time and
% logarithmic in temperature terms to the science pixels.
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

%--------------------------------------------------------------------------
% extract flags and parameters
%--------------------------------------------------------------------------
pouEnabled  = calObject.pouModuleParametersStruct.pouEnabled;
ccdModule   = calObject.ccdModule;
ccdOutput   = calObject.ccdOutput;
season      = calObject.season;
campaign    = calObject.k2Campaign;
channel     = convert_from_module_output(ccdModule, ccdOutput);
fcConstants = calObject.fcConstants;
ccdRows     = 1:fcConstants.CCD_ROWS;


%--------------------------------------------------------------------------
% parse POU struct from intermediateStruct
%--------------------------------------------------------------------------
if pouEnabled
    % copy calTransformStruct into shorter temporary structure
    tStruct = calTransformStruct(:,cadenceIndex);
else
    tStruct = [];
end


%--------------------------------------------------------------------------
% extract data
%--------------------------------------------------------------------------
blackPixelValues = calIntermediateStruct.blackPixels(:, cadenceIndex); % nCcdRows x 1
blackPixelGaps   = calIntermediateStruct.blackGaps(:, cadenceIndex);   % nCcdRows x 1
validBlackPixelIndices  = find(~blackPixelGaps);                       %#ok<EFIND> % may be < (nPixels x 1)
validRowIndices         = ccdRows;


%--------------------------------------------------------------------------
% set up model, estimate 1d black, and propagate uncertainties
%--------------------------------------------------------------------------

% if there are no valid black pixels, set values to -1
if isempty(validBlackPixelIndices)
    
    calIntermediateStruct.blackAvailable(cadenceIndex)                              = false;
    calIntermediateStruct.blackCorrection(validRowIndices, cadenceIndex)            = -1;
    
    if pouEnabled
        tStruct = insert_POU_cadence_gaps(tStruct,{'fittedBlack'});
    else
        calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).bestBlackPolyOrder   = -1;
        calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).CblackPolyFit        = [];
        calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).bestPolyCoeffts      = [];         
    end
    
else
    
    %--------------------------------------------------------------------------
    %  set up model
    %--------------------------------------------------------------------------
    CONTROLS = ...
        struct('parallel_pixel_select', [565 566 1:40], ...
               'frame_pixel_select',    1:16);
    
    BOUNDS = ...
        struct('trailing_collat', struct('Rmin', calIntermediateStruct.mSmearRowStart,...
                                         'Rmax', calIntermediateStruct.vSmearRowEnd,...
                                         'Cmin', calIntermediateStruct.blackColumnStart,...
                                         'Cmax', calIntermediateStruct.blackColumnEnd));
    OneDBlack_Inputs = ...
        struct('season_num',            season,...
               'quarter_num',           campaign,... 
               'channel',               channel,...
               'TrBlkRange',            1:size(calIntermediateStruct.blackRows),...
               'controls',              CONTROLS,...
               'bounds',                BOUNDS,...
               'maxMaskedSmearRow',     fcConstants.MASKED_SMEAR_END + 1,...
               'minVirtualSmearRow',    fcConstants.VIRTUAL_SMEAR_START + 1,...
               'null',                  []);
    
    % recreate model here
    Init_Info1  = initialize_1dblack_model(OneDBlack_Inputs, calIntermediateStruct);
    
    % Shorten variable names
    Constants   = Init_Info1.Constants;
    ROI         = Init_Info1.ROI;
    FCLC_Model  = Init_Info1.FCLC_Model;
    clear('Init_Info1');
        
    oneDBlackModelStruct = ...
        struct('TrailingBlackCollat', blackPixelValues', ...
               'Models',              struct('collat', struct('ROI',                      ROI, ...
                                                              'FGSFree_SelectRows',       ismember(1:1070, ROI.trailing_collat.Rows)', ...
                                                              'SceneDepFree_SelectRows',  FCLC_Model.rows.Subset_datum_index', ...
                                                              'row_time_constant',        FCLC_Model.row_time_constants, ...
                                                              'model_matrix',             squeeze(FCLC_Model.rows.Matrix), ...
                                                              'model_matrix_allRows',     squeeze(FCLC_Model.rows.Matrix0))),...
                                       'constants',           Constants,...
                                       'ccdRows',             ccdRows);
    
    %--------------------------------------------------------------------------
    %  estimate 1D black
    %--------------------------------------------------------------------------
    [calObject, calIntermediateStruct, tStruct] = ...
        estimate_sc_1dblack(calObject, oneDBlackModelStruct, calIntermediateStruct, cadenceIndex, blackCorrectionCoeffs, tStruct);
    
end


if pouEnabled
    % copy tStruct into calTransformStruct for return
    calTransformStruct(:,cadenceIndex) = tStruct;
end

return;
