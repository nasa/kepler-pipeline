function  h = compare_motion_polynomials( targetStarResultsStruct, mpStruct1, mpStruct2, centroidType )
%**************************************************************************
% h = compare_motion_polynomials( targetStarResultsStruct, mpStruct1, ...
%                                 mpStruct2, centroidType )
%**************************************************************************
% Compare two sets of motion polynomials.
%
% INPUTS
%     targetStarResultsStruct : A 1-based arra of target results, usually
%                               loaded from a pa_state.mat file.
%     mpStruct1               : An N-length array of motion polynomial
%                               structures.
%     mpStruct2               : An N-length array of motion polynomial
%                               structures.
%     centroidType            : Either 'prf' or 'fw' to indicate PRF or
%                               flux-weighted centroids are to be used. PRF
%                               centroids are usually preferred, but
%                               flux-weighted centroids are computed for
%                               all targets.
%    
% OUTPUTS
%     h                       : A figure handle.
%
% NOTES
%   - Assumes the row/column positions in targetStarResultsStruct are 1-BASED.
%**************************************************************************
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
    MARKER_SIZE = 200;
    
    if ~exist('centroidType', 'var')
        centroidType = 'fw';
    end
    
    
    %----------------------------------------------------------------------
    % Check MP comparability and identify gaps..
    %----------------------------------------------------------------------
    rowPolyStatus1 = [mpStruct1.rowPolyStatus];
    colPolyStatus1 = [mpStruct1.colPolyStatus];
    status1 = rowPolyStatus1 & colPolyStatus1;
    
    rowPolyStatus2 = [mpStruct2.rowPolyStatus];
    colPolyStatus2 = [mpStruct2.colPolyStatus];
    status2 = rowPolyStatus2 & colPolyStatus2;
    
    if length(status1) ~= length(status1) 
        fprintf('The two motion poly struct arrays have different lengths.\n');
        return
    end
    
    if nnz(status1) ~= nnz(status2)
        fprintf('The two arrays contain different numbers of valid structs.\n');
        return
    end
    
    status = status1 & status2;
    nValidPolys = nnz(status);
    
    %----------------------------------------------------------------------
    % Compute average residuals using both sets of motion polynomials.
    %----------------------------------------------------------------------
    [medianCentroidCol, medianCentroidRow, avgResidual1] = ...
        summarize_mp_centroid_residuals( mpStruct1, ...
            targetStarResultsStruct, 'isZeroBased', false, ...
            'centroidType', centroidType, 'residualFun', @(x)(sum(x, 1)/nValidPolys) );
        
    [~, ~, avgResidual2] = ...
        summarize_mp_centroid_residuals( mpStruct2, ...
            targetStarResultsStruct, 'isZeroBased', false, ...
            'centroidType', centroidType, 'residualFun', @(x)(sum(x, 1)/nValidPolys) );

    deltaResidual = avgResidual2 - avgResidual1;
    increaseIndicators = deltaResidual > 0;
    decreaseIndicators = deltaResidual <= 0;
    
    
    %----------------------------------------------------------------------
    % Plot the changes in average residual for each target.
    %----------------------------------------------------------------------
    h = scatter( medianCentroidCol(increaseIndicators), ...
                 medianCentroidRow(increaseIndicators), ...
                 MARKER_SIZE, deltaResidual(increaseIndicators), 'filled', ...
                 'marker', 'd', 'MarkerEdgeColor', 'k');
    grid on
    hold on
    scatter( medianCentroidCol(decreaseIndicators), ...
             medianCentroidRow(decreaseIndicators), ...
             MARKER_SIZE, deltaResidual(decreaseIndicators), 'filled', ...
             'marker', 'o', 'MarkerEdgeColor', 'k');

    cmap = bone;
    colormap(cmap);
    hcb = colorbar;
    colorTitleHandle = get(hcb,'Title');
    set(colorTitleHandle ,'String', {'\Delta residual', '(avg all cadences)'});

    title({'Comparison of Two Sets of Motion Polynomials', ...
           sprintf('change in average residual error (MP - %s centroid)', centroidType)}, ...
           'FontSize', 14, 'FontWeight', 'bold');

    xlabel('CCD Column', 'FontSize', 12, 'FontWeight', 'bold' );
    ylabel('CCD Row', 'FontSize', 12, 'FontWeight', 'bold' );
    legend({'Increased Error', 'Decreased Error'});
end