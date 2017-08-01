function [calIntermediateStruct, tStruct] = ...
    estimate_lc_1dblack(calObject, oneDBlackModelStruct, calIntermediateStruct, cadenceIndex, tStruct)
% function [calIntermediateStruct] = ...
%    estimate_lc_1dblack(calObject, oneDBlackModelStruct, calIntermediateStruct, cadenceIndex, tStruct)
%
% This function performs a robust fit of the long cadence black collateral
% data for a single cadence to  the 'two-exponential model' as define by
% the incoming oneDBlackModelStruct. The black correction, fit coefficients
% and intermediate diagnostics are returned in the calIntermediateStruct.
%
% INPUT:        oneDBlackModelStruct        Structure defining 1D black model
%               calObject                   CAL input data object
%               calIntermediateStruct       Structure containing intermediate data products
%               cadenceIndex                relative cadence index
%               tStruct                     pou struct for this cadence
% OUTPUT:       calIntermediateStruct       Structure containing fit coefficients, intermediate data
%                                           products and black correction for each row
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

% hard coded
numCoeffs = 6;          % number of coefficients in 1D black model
ROBUST_TUNE = 4.685;    % robustfit tuning parameter

% extract channel, season and flags
ccdModule   = calObject.ccdModule;
ccdOutput   = calObject.ccdOutput;
channel     = convert_from_module_output(ccdModule, ccdOutput);
season_num  = calObject.season;

pouEnabled      = calIntermediateStruct.pouEnabled;
enableOverrides = calIntermediateStruct.enableBlackCoefficientOverrides;
isK2UnitOfWork  = calIntermediateStruct.dataFlags.isK2UnitOfWork;

% get collateral black data and uncertainties
blackPixelValues = colvec(oneDBlackModelStruct.TrailingBlackCollat);

if pouEnabled
    [~, Cblack] = get_primitive_data(tStruct,'residualBlack');
    rawBlackUncertainties = sqrt(Cblack);
else
    rawBlackUncertainties = calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).deltaRawBlack;
end

% get the model for all rows
oneDBlackModel = oneDBlackModelStruct.Models.collat.model_matrix_allRows';

% if there are any overrides, get fixed coefficient values and variance and correct the pixels for those now
% there are no overrides available for K2 yet
if enableOverrides && ~isK2UnitOfWork
    
    % load table and extract values for channel and season
    [Coeff_Overrides, CoeffFlags, CoeffValues, CoeffVars] = load_coeff_overrides_table;
    TheseCoeffs = Coeff_Overrides((channel-1)*4 + (season_num+1),:);

    % These variables contain column indices into Coeff_Overrides
    % CoeffFlags  = [3 6 9 12 15 18];
    % CoeffValues = [4 7 10 13 16 19];
    % CoeffVars   = [5 8 11 14 17 20];

    CoeffsToFix = logical(TheseCoeffs(CoeffFlags));
    FixedCoeffs = TheseCoeffs(CoeffValues)';
    FixedVars = TheseCoeffs(CoeffVars);

    % correct pixels for only fixed coefficients    
    blackPixelValues = blackPixelValues - oneDBlackModel*FixedCoeffs;
    
    % display this message only on first cadence processed - all other cadences will also use overrides
    if( any(CoeffsToFix) && ~calIntermediateStruct.oneDBlackFitStruct.overrideCoeffsUsed )
        display('CAL:estimate_lc_1dblack: Using hard-coded 1D black fit coefficients for at least one of the six');
        calIntermediateStruct.oneDBlackFitStruct.overrideCoeffsUsed = true;
    end
  
else
    % fix none of the coefficients
    CoeffsToFix = false(numCoeffs,1);
    FixedCoeffs = zeros(numCoeffs,1);
    FixedVars = zeros(numCoeffs,1);
end


% build up logical indices
ccdRows = 1:calIntermediateStruct.nCcdRows;
blackGapIndicators = calIntermediateStruct.blackGaps(:,cadenceIndex);                   % logical into ccdRows
fgsFreeRowsIndicators = oneDBlackModelStruct.Models.collat.FGSFree_SelectRows;          % logical into ccdRows
SceneDepFree_SelectRows = oneDBlackModelStruct.Models.collat.SceneDepFree_SelectRows;   % logical into only the FGS free rows!

% build sceneDependentFreeRowsIndicators
fgsFreeRows = ccdRows(fgsFreeRowsIndicators);                                           % get FGS free row numbers which are the indices into ccdRow
sceneDependentFreeRowsIndicators = false(size(fgsFreeRowsIndicators));
sceneDependentFreeRowsIndicators(fgsFreeRows(SceneDepFree_SelectRows)) = true;

% build valid row indicators for model
modelValidRows = ~blackGapIndicators & fgsFreeRowsIndicators & sceneDependentFreeRowsIndicators;


% get 2D black covariance matrix for this cadence
Cblack2D = get_Cblack2D(calObject, calIntermediateStruct, cadenceIndex, tStruct);

% standard POU gives covariance of 2D black subtracted black pixels
CblackPixelValues = diag(rawBlackUncertainties.^2) + Cblack2D;
clear Cblack2D;

% perform robust fit to get robust weights
[robust_coefficient_list, robust_stats] = ...
    robustfit(oneDBlackModel(modelValidRows,~CoeffsToFix), blackPixelValues(modelValidRows), ...
    'bisquare', ROBUST_TUNE, 'off');        %#ok<ASGLU>

% extract weights from robust fit
robustWeights = sqrt(robust_stats.w);


%----------------------------------------------------------------------
% estimate black correction coefficients and covariance using lscov w/robust weighting
% in order to propagate the pixel covariance into the fit
%----------------------------------------------------------------------

% scale design matrix, black pixel data and covariance with robust weights
Arobust = scalecol(robustWeights, oneDBlackModel(modelValidRows,~CoeffsToFix));
bRobust = robustWeights .* blackPixelValues(modelValidRows);
Crobust = scalecol(robustWeights.^2,CblackPixelValues(modelValidRows,modelValidRows));

% use only weights > 0 in lscov to avoid all zero rows in design matrix
validWeights = robustWeights > 0;

% perform weighted lscov fit
[expCoeffts, std, mse, CblackExpCoeffts] = ...
    lscov(Arobust(validWeights,:),bRobust(validWeights), Crobust(validWeights,validWeights));                                           %#ok<ASGLU>

% ensure covariance is consistent with mse (see MATLAB help: lscov)
CblackExpCoeffts   = CblackExpCoeffts ./ mse;
clear Arobust bRobust Crobust;


% evaluate black correction all valid rows
allCoeffs = [expCoeffts; FixedCoeffs(CoeffsToFix)];
CoeffIndices = [1 2 3 4 5 6];
allIndices = [CoeffIndices(~CoeffsToFix) CoeffIndices(CoeffsToFix)];

[~, sortedIndices] = sort(allIndices);
allCoeffs = allCoeffs(sortedIndices);


% pad covariance matrix out with zeros for fixed coefficients
CblackExpCoefftsFull = zeros(numCoeffs);
joffset = int8(0);

for j = 1:6    
    if CoeffsToFix(j)
        CblackExpCoefftsFull(:,j) = 0;
        joffset = joffset+1;
    else        
        ioffset = int8(0);
        for i = 1:6
            if CoeffsToFix(i)
                CblackExpCoefftsFull(i,j) = 0;
                ioffset = ioffset + 1;
            else
                CblackExpCoefftsFull(i,j) = CblackExpCoeffts(i-ioffset,j-joffset);
            end
        end
    end
end

% set diagonal elements equal to override variances
for i = 1:6
    if CoeffsToFix(i)
        CblackExpCoefftsFull(i,i) = FixedVars(i);
    end
end

% save black correction to calIntermediateStruct
CblackExpCoeffts = CblackExpCoefftsFull;
blackCorrection = oneDBlackModel * allCoeffs;
calIntermediateStruct.blackCorrection(:, cadenceIndex) = blackCorrection;

if ~pouEnabled
    calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).bestPolyCoeffts    = allCoeffs;
    calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).CblackPolyFit      = CblackExpCoeffts;
    calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).bestBlackPolyOrder = [];                       % not relevant for two-exponential fit    
else
    
    %--------------------------------------------------------------------------
    % propagate uncertainties
    %--------------------------------------------------------------------------

    % primitives for fitted black correction are fit coefficients and covariance        
    tStruct = append_transformation(tStruct, 'eye', 'fittedBlack', [], allCoeffs, CblackExpCoeffts ,[],[],[]);

    % set up transformation parameters for custom01_calFitted1DBlack
    K = oneDBlackModelStruct.Models.collat.row_time_constant;
    mSmearRows = oneDBlackModelStruct.constants.maskedSmearRowRange;
    startScienceRow = oneDBlackModelStruct.constants.scipix_start;
    maxMaskedSmearRow = oneDBlackModelStruct.constants.maxMaskedSmearRow;

    % write xVector as a string to save space:  xVector = [ccdRows(1):ccdRows(end)];
    xVector = ['[',num2str(oneDBlackModelStruct.ccdRows(1)),':',num2str(oneDBlackModelStruct.ccdRows(end)),']'];

    % apply custom01_calFitted1DBlack to the fitCoeffs to get fitted black correction
    tStruct = append_transformation(tStruct, 'custom01_calFitted1DBlack', 'fittedBlack', [],...
                                            K, xVector, mSmearRows, startScienceRow, maxMaskedSmearRow );
    
end



clear CblackFitted;

return;

