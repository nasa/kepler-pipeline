function [calObject, calIntermediateStruct, tStruct ] = ...
                estimate_sc_1dblack(calObject, oneDBlackModelStruct, calIntermediateStruct, cadenceIndex, blackCorrectionCoeffs, tStruct)
% function [calObject, calIntermediateStruct, tStruct ] = ...
%                estimate_sc_1dblack(calObject, oneDBlackModelStruct, calIntermediateStruct, cadenceIndex, blackCorrectionCoeffs, tStruct))
%
% This function fits the short cadence black collateral data for one
% cadence to the two-exponential model results from long cadence plus a
% bias term and attaches the results to the calIntermediateStruct. Results
% include the modeled black (black correction) plus intermediate
% diagnostics.   
%
% INPUT:        oneDBlackModelStruct        Structure containing two-exponential fit model and parameters
%               calObject                   CAL input object - currently unused
%               calIntermediateStruct       Structure containing intermediate data products
%               cadenceIndex                Index of current cadence in current unit of work
%               blackCorrectionCoeffs       Structure containing coefficients from long cadence 1D black fit, interpolated and
%                                           scaled for short cadence
%               tStruct                     pou struct for a single cadence
% OUTPUT:       calObject                   CAL input object - currently unused
%               calIntermediateStruct       Structure containing intermediate data products with black correction and associated
%                                           data products updated
%               tStruct                     modified pou struct for a single cadence
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
pouEnabled = calObject.pouModuleParametersStruct.pouEnabled;

% build up logical indices
ccdRows = 1:calIntermediateStruct.nCcdRows;
blackGapIndicators = calIntermediateStruct.blackGaps(:,cadenceIndex);                   % logical into ccdRows
fgsFreeRowsIndicators = oneDBlackModelStruct.Models.collat.FGSFree_SelectRows;          % logical into ccdRows
SceneDepFree_SelectRows = oneDBlackModelStruct.Models.collat.SceneDepFree_SelectRows;   % logical into only the FGS free rows!

% build sceneDependentFreeRowsIndicators
fgsFreeRows = ccdRows(fgsFreeRowsIndicators);                                           % get FGS free row numbers which are the indices into ccdRow
sceneDependentFreeRowsIndicators = false(size(fgsFreeRowsIndicators));
sceneDependentFreeRowsIndicators(fgsFreeRows(SceneDepFree_SelectRows)) = true;

% build valid row indicators
modelValidRows = ~blackGapIndicators & fgsFreeRowsIndicators & sceneDependentFreeRowsIndicators;

% check that enough data is valid to take robust mean and reduce criteria if needed
nValidRows = numel(find(modelValidRows));
if nValidRows < 3
    modelValidRows = ~blackGapIndicators & fgsFreeRowsIndicators;
    nValidRows = numel(find(modelValidRows));    
    if nValidRows < 3
        modelValidRows = ~blackGapIndicators;
        nValidRows = numel(find(modelValidRows));
    end
end


% get the model for all rows
blackModel = oneDBlackModelStruct.Models.collat.model_matrix_allRows';

% get the fit coefficients - interpolated for LC fit
blackFitCoeffs = blackCorrectionCoeffs.original(cadenceIndex,:)';

% get collateral black data
blackPixelData = colvec(oneDBlackModelStruct.TrailingBlackCollat);

% evaluate the model and find residuals at only the valid rows
% fit a bias term to the residuals at the ungapped rows using robust fit if enough data is available
% if no valid pixels are available set bias to zero
if nValidRows > 0
    blackResiduals = blackPixelData(modelValidRows) - blackModel(modelValidRows,:) * blackFitCoeffs;        
    if( nValidRows > 2 )
        [biasTerm, biasTermStd] = robust_mean_std(blackResiduals);
    else
        biasTerm = mean(blackResiduals);
        biasTermStd = std(blackResiduals);
    end
else
    % no valid black pixels available - should never happen
    biasTerm = 0;
    biasTermStd = 0;
end


% write expanded model, fit coefficient and covariance
expandedModel = [blackModel, ones(length(ccdRows),1)];
expandedCoeffs = [blackFitCoeffs; biasTerm];
CexpandedCoeffs = zeros(length(expandedCoeffs));
CexpandedCoeffs(1:end-1,1:end-1) = squeeze(blackCorrectionCoeffs.originalCovariance(cadenceIndex,:,:));
CexpandedCoeffs(end,end) = biasTermStd ^ 2;

% create the black correction for all rows from the expanded model
calIntermediateStruct.blackCorrection(:, cadenceIndex) = expandedModel * expandedCoeffs;

if ~pouEnabled
    calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).bestPolyCoeffts      = expandedCoeffs;
    calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).CblackPolyFit        = CexpandedCoeffs;
    calIntermediateStruct.blackUncertaintyStruct(cadenceIndex).bestBlackPolyOrder   = [];                           % no longer relevant    
else
    
    %--------------------------------------------------------------------------
    % propagate uncertainties
    %--------------------------------------------------------------------------
        
    % primitives for fitted black correction are fit coefficients and covariance
    % NOTE: additional bias term has been added for short cadence so remove it here

    tStruct = append_transformation(tStruct, 'eye', 'fittedBlack', [], expandedCoeffs(1:end-1), CexpandedCoeffs(1:end-1,1:end-1) ,[],[],[]);

    % set up transformation parameters for custom01_calFitted1DBlack
    K = oneDBlackModelStruct.Models.collat.row_time_constant;
    mSmearRows = oneDBlackModelStruct.constants.maskedSmearRowRange;
    startScienceRow = oneDBlackModelStruct.constants.scipix_start;
    maxMaskedSmearRow = oneDBlackModelStruct.constants.maxMaskedSmearRow;

    % write xVector as a string to save space:  xVector = [ccdRows(1):ccdRows(end)];
    xVector = ['[',num2str(ccdRows(1)),':',num2str(ccdRows(end)),']'];

    % apply custom01_calFitted1DBlack to the fitCoeffs to get fitted black correction
    tStruct = append_transformation(tStruct, 'custom01_calFitted1DBlack', 'fittedBlack', [],...
                                        K, xVector, mSmearRows, startScienceRow, maxMaskedSmearRow );   

    % set up bias term as additional variable
    biasTerm = expandedCoeffs(end);
    CvBias = CexpandedCoeffs(end,end);    

    tStruct = append_transformation(tStruct, 'eye', 'fittedBlackBias', [], biasTerm, CvBias ,[],[],[]);

    % expand bias term to full length of x vector
    tStruct = append_transformation(tStruct, 'userM', 'fittedBlackBias', [], ['ones(',num2str(oneDBlackModelStruct.ccdRows(end)),',1)']);

    % add bias term to fitted black correction
    tStruct = append_transformation(tStruct, 'addV', 'fittedBlack', [], 'fittedBlackBias',[]);        
                                        
end



