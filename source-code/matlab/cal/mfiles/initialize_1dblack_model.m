function [Init_Info] = initialize_1dblack_model( Inputs, calIntermediateStruct )
%
% Initializes linear fit parameters for vertical spatial fitting.
%
%
% * Function returns:
% * |Init_Info -| - structure ontaining initialized information.
% * |Constants      -| structure containing Constants.
% * |ROI            -| structure containing region of interest information (includes a DataSubset-class object).
% * |FCLC_Model     -| structure containing row-wise model information. (includes a ModelComponent-class object).
% * |Coeff_Model    -| structure containing coefficient model information.
% * Function arguments:
% * |Inputs -| structure containing input parameters (see OneDBlack_main)
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

%% EXTRACT VALUES FROM Inputs

channel = Inputs.channel;
season = Inputs.season_num;
campaign = Inputs.quarter_num;

TrBlkRange = Inputs.TrBlkRange;
maxMaskedSmearRow = Inputs.maxMaskedSmearRow;
minVirtualSmearRow = Inputs.minVirtualSmearRow;

controls = Inputs.controls;
frame_pixel_select = controls.frame_pixel_select;
parallel_pixel_select = controls.parallel_pixel_select;

trailing_collat = Inputs.bounds.trailing_collat;
Rmin = trailing_collat.Rmin;
Rmax = trailing_collat.Rmax;
Cmin = trailing_collat.Cmin;
Cmax = trailing_collat.Cmax;

%% EXTRACT VALUES FROM calIntermediateStruct

enableSceneDependentRowMap = calIntermediateStruct.enableSceneDependentRowMap;
mSmearRowStart = calIntermediateStruct.mSmearRowStart;
mSmearRowEnd = calIntermediateStruct.mSmearRowEnd;
isK2UnitOfWork = calIntermediateStruct.dataFlags.isK2UnitOfWork;
numCcdRows = calIntermediateStruct.nCcdRows;

%% LOAD TABULAR INFORMATION

% Loads variable: row_time_constants;
rowTimeConstants = load_row_time_constants();

% Loads variable: SCENE_OK_Select;
if enableSceneDependentRowMap
    if isK2UnitOfWork
        sceneDepFree = ~scene_dependent_rows_K2(channel, campaign);        
    else
        sceneDepFree = ~scene_dependent_rows(channel, season);        
    end
else
    sceneDepFree = true(1,numCcdRows);
end

%% INITIALIZE CONSTANTS

% hard coded
rowPredictorCount = 6;

% derived from inputs
maskedSmearRowRange = mSmearRowStart:mSmearRowEnd;
scipix_start = maxMaskedSmearRow + 1;
scipix_end = minVirtualSmearRow - 1;

% save in structure for output
Constants = struct( 'row_predictor_count', rowPredictorCount, ...
                    'maskedSmearRowRange', maskedSmearRowRange, ...
                    'maxMaskedSmearRow',   maxMaskedSmearRow,...
                    'scipix_start',        scipix_start, ...
                    'scipix_end',          scipix_end);

%% DEFINE REGIONS OF INTEREST (ROI)

% Regions of interest are rectangular regions of an image
% which have information which is useful to the fit algorithm.
% Also, a three character identifier is specified for each ROI.

ROI = struct( 'trailing_collat', dataSubsetClass( Rmin, Rmax, Cmin, Cmax, 'TC1' ));
%% INITIALIZE SPATIAL CONTANTS

% FGS_States function produces 2 images containing,frame & parallel clock state sequence numbers, respectively.
% FITS file contains target pixel list for LCs (counts are the same for all channels so only channel 1 is required to determine pixel counts for all ROI).
% row_time_constant initialized to input

FGS_Clock_States1 = get_fgs_clock_states( );

%% INITIALIZE TRAILING BLACK COLLATERAL ROI

%  Determines pixel count in ROI and initilizes arrays (to zeros)

% Determine which collateral rows contain FGS pixels in the selected ranges
% (these are excluded since they are displaced from the smooth curve)
frame_pixel_image2 = FGS_Clock_States1.Frame;
frame_pixel_image3 = frame_pixel_image2(ROI.trailing_collat.Row_min:ROI.trailing_collat.Row_max, ROI.trailing_collat.Column_min:ROI.trailing_collat.Column_max);
anyfgs_row_index_frame = all(~ismember(frame_pixel_image3,frame_pixel_select),2);

parallel_pixel_image2 = FGS_Clock_States1.Parallel;
parallel_pixel_image3 = parallel_pixel_image2(ROI.trailing_collat.Row_min:ROI.trailing_collat.Row_max, ROI.trailing_collat.Column_min:ROI.trailing_collat.Column_max);
anyfgs_row_index_parallel = all(~ismember(parallel_pixel_image3,parallel_pixel_select),2);

anyfgs_row_index = min(anyfgs_row_index_frame, anyfgs_row_index_parallel);

% Initialize
ROI.trailing_collat = initialize(ROI.trailing_collat, 1, length(find(anyfgs_row_index==1)), 0);


%% INITIALIZE MODEL COMPONENTS

% Creates a structure of ModelComponent-class objects representing distinct
% model elements. A 2 character identifier is assigned to each element.

% Determine total number of pixels+collateral points in modeled LC regions (datum = pixels or collateral point)
datCount = ROI.trailing_collat.Datum_count;
rowCount = length(TrBlkRange);

% Initialize elements of LC model into FCLC_Model structure
FCLC_Model = struct('datum_count',          datCount, ...
                    'full_count',           rowCount, ...
                    'row_time_constants',   rowTimeConstants(channel,2:3), ...
                    'rows',                 modelComponentClass(rowPredictorCount, datCount, rowCount, 1, 'RW'));

%% INITIALIZE ROI INDICES, ROWS & COLUMNS FOR LCs
% Sets ModelComponent-class object values

% Determine index for collateral files (channel-independent)
ROI.trailing_collat.Index = find(anyfgs_row_index'==1) + ROI.trailing_collat.Row_min - 1;

% ROI.trailing_collat.Columns is not needed
ROI.trailing_collat.Rows=ROI.trailing_collat.Index';

%% INITIALIZE ROW DEPENDENCE FOR ALL ROWS IN MODEL
% Sets ModelComponent-class object values.
% Model includes all-row terms plus a delta term for differences
% between masked smear and sciece pixel levels.
% Note: allRow tag all rows *except* masked smear rows
% maskedSmearRow tag denotes only the masked smear rows

masksmear_select = TrBlkRange <= maxMaskedSmearRow;
allRow_const = ones(1,rowCount);
allRow_const(masksmear_select) = 0;
allRow_linear = ((1:rowCount) - (rowCount-mod(rowCount,2))/2)/((rowCount-mod(rowCount,2))/2);
allRow_linear(masksmear_select) = 0;

maskedSmearRow_constDelta = masksmear_select;
maskedSmearRow_linearDelta0 = TrBlkRange .* masksmear_select;
maskedSmearRow_linearDelta = (maskedSmearRow_linearDelta0 - mean(maskedSmearRow_linearDelta0(ismember(TrBlkRange,maskedSmearRowRange)))) .* masksmear_select ;

row_time_constant = FCLC_Model.row_time_constants;
row_time_constant_short = row_time_constant(2);
row_time_constant_long = row_time_constant(1);

allRow_exprow0_short = exp(-TrBlkRange/row_time_constant_short).* (~masksmear_select);
allRow_exprow_short = allRow_exprow0_short/allRow_exprow0_short(scipix_start);

allRow_exprow0_long = exp(-TrBlkRange/row_time_constant_long).* (~masksmear_select);
allRow_exprow_long = allRow_exprow0_long/allRow_exprow0_long(scipix_start);

FCLC_Model.rows.Matrix0(1,:,:) = [ allRow_const; ...
                                    allRow_linear; ...
                                    allRow_exprow_long; ...
                                    allRow_exprow_short; ...
                                    maskedSmearRow_constDelta; ...
                                    maskedSmearRow_linearDelta];

FCLC_Model.rows.Matrix(1,:,:) = FCLC_Model.rows.Matrix0(1,:,ROI.trailing_collat.Rows');

%% DETERMINE POTENTIALLY SCENE-DEPENDENT-ARTIFACT-AFFECTED ROWS FOR CHANNEL LIST
sceneDepFree = sceneDepFree(ROI.trailing_collat.Rows);

%% INITIALIZE INDICES TO EXCLUDE SCENE DEPENDENT ROWS IN MODELS
%  Calling model_subset ensures that no model predictor columns are all zero.
%  Does not yet preclude rank deficency.

FCLC_Model.rows = model_subset(FCLC_Model.rows, 1, sceneDepFree);

%% ASSEMBLE RETURNED DATA STRUCTURE

Init_Info.Constants = Constants;
Init_Info.ROI = ROI;
Init_Info.FCLC_Model = FCLC_Model;


return;

