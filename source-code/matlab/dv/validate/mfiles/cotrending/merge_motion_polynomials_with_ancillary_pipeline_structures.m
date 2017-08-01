function [ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct] = ...
merge_motion_polynomials_with_ancillary_pipeline_structures( ...
cadenceTimes, motionPolyStruct, ...
ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct] = ...
% merge_motion_polynomials_with_ancillary_pipeline_structures( ...
% cadenceTimes, motionPolyStruct, ...
% ancillaryPipelineConfigurationStruct, ancillaryPipelineDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Create a time series for each of the row and column motion polynomial
% coefficients and merge them with the ancillary pipeline data and
% configuration structures.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


% Set model order.
MODEL_ORDER = 1;

% Check if the motion polynomials are valid.
if ~isempty(motionPolyStruct) && any([motionPolyStruct.rowPolyStatus])
    
    % Get motion polynomial gap indicators and interpolate the motion
    % polynomials if necessary.
    gapIndicators = ~logical([motionPolyStruct.rowPolyStatus]');
    
    if any(gapIndicators)
        [motionPolyStruct] = ...
            interpolate_motion_polynomials(motionPolyStruct, cadenceTimes);
    end % if
    
    % Get the mid-cadence timestamps.
    timestamps = [motionPolyStruct.mjdMidTime]';
    
    % Create arrays of motion polynomial coefficients and covariance
    % matrices.
    rowPolys = [motionPolyStruct.rowPoly];
    rowCoeffs = [rowPolys.coeffs]';
    rowCovariances = cat(3, rowPolys.covariance);
    
    colPolys = [motionPolyStruct.colPoly];
    colCoeffs = [colPolys.coeffs]';
    colCovariances = cat(3, colPolys.covariance);
    clear rowPolys colPolys
    
    % Create ancillary time series for each of the motion polynomial
    % coefficients and append them to the ancillary pipeline data
    % structure. Also create arrays of the mnemonics and interactions.
    % These will later be appended to the ancillary pipeline configuration
    % structure.
    nRowCoeffs = size(rowCoeffs, 2);
    nColCoeffs = size(colCoeffs, 2);
    
    mnemonics = {};
    
    ancillaryDataStruct.timestamps = timestamps;
    
    for iCoeff = 1 : nRowCoeffs
        
        mnemonic = ['SOC_MP_COEFF_ROW_', num2str(iCoeff)];
        ancillaryDataStruct.mnemonic = mnemonic;
        ancillaryDataStruct.values = rowCoeffs( : , iCoeff);
        ancillaryDataStruct.uncertainties = ...
            sqrt(squeeze(rowCovariances(iCoeff, iCoeff, : )));
        ancillaryPipelineDataStruct = ...
            [ancillaryPipelineDataStruct, ancillaryDataStruct];                                 %#ok<AGROW>
        
        mnemonics = [mnemonics, mnemonic];                                                      %#ok<AGROW>
        
    end % for iCoeff
    
    for iCoeff = 1 : nColCoeffs
        
        mnemonic = ['SOC_MP_COEFF_COL_', num2str(iCoeff)];
        ancillaryDataStruct.mnemonic = mnemonic;
        ancillaryDataStruct.values = colCoeffs( : , iCoeff);
        ancillaryDataStruct.uncertainties = ...
            sqrt(squeeze(colCovariances(iCoeff, iCoeff, : )));
        ancillaryPipelineDataStruct = ...
            [ancillaryPipelineDataStruct, ancillaryDataStruct];                                 %#ok<AGROW>
        
        mnemonics = [mnemonics, mnemonic];                                                      %#ok<AGROW>
        
    end % for iCoeff
    
    % Append the configuration parameters to the ancillary pipeline data
    % structure.
    modelOrders = repmat(MODEL_ORDER, [nRowCoeffs + nColCoeffs, 1]);
    
    ancillaryPipelineConfigurationStruct.mnemonics = ...
        horzcat(ancillaryPipelineConfigurationStruct.mnemonics, ...
        mnemonics);
    ancillaryPipelineConfigurationStruct.modelOrders = ...
        vertcat(ancillaryPipelineConfigurationStruct.modelOrders, ...
        modelOrders);
    
end % if

% Return.
return
