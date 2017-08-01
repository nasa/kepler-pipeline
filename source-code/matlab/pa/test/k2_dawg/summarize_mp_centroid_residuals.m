function  [medianCentroidCol, medianCentroidRow, fOfResidual] = summarize_mp_centroid_residuals( motionPolyStruct, targetStarResultsStruct, varargin )
%**************************************************************************
% [medianCentroidCol, medianCentroidRow, fOfResidual] = ...
%     summarize_mp_centroid_residuals( motionPolyStruct, ...
%         targetStarResultsStruct, varargin )
%**************************************************************************
% Compute an arbitrary function of the residual errors between motion
% polynomial-predicted centroid positions and the centroid positions
% determined by either PRF fitting or spatial averaging of observed flux.
%
% INPUTS
%
%     motionPolyStruct           
%     targetStarResultsStruct
%
%     All remaining inputs are optional attribute/value pairs. Valid
%     attributes and values are: 
%    
%     Attribute             Value
%     ---------             -----
%     'isZeroBased'         If true, convert CCD coordinates in
%                           targetStarResultsStruct from 0-based to 1-based
%                           (default = false). Data from the pa_state.mat
%                           file is 1-based, so typically this parameter is
%                           allowed to default.
%     'centroidType'        A string, either 'prf' or 'fw', specifying the
%                           type of centroid to use in the residual error
%                           calculation. The default value is 'fw' since
%                           flux-weighted centroids are computed for all
%                           targets, but PRF centroids provide more
%                           reliable measure of error, so they should be
%                           used if available.
%     'residualFun'         A function handle. The function must accept a
%                           nCadences-by-nTargets matrix of residual
%                           values (default: @(x)median(x) ). The output
%                           fOfResidual is the result of this function
%                           applied to the residuals.
%     'cadenceIndicators'   An optional logical array indicating cadences
%                           to use in the calculation (default =
%                           true(nCadences, 1) ).
%
% OUTPUTS
%     medianCentroidCol     An nTargets-by-1 array of 1-based CCD column
%                           cooridnates.
%     medianCentroidRow     An nTargets-by-1 array of 1-based CCD row
%                           cooridnates.
%     fOfResidual           The output of 'residualFun' applied to the
%                           nCadences-by-nTargets matrix of residual
%                           values. 
%
% NOTES
%     Residuals are computed for each target at each cadence as the
%     distance in pixels between the motion poly-predicted position and the
%     PRF or flux-weighted centroid position.
% 
% USAGE EXAMPLES
%    >> load('pa_state.mat', 'motionPolyStruct', 'ppaTargetStarResultsStruct')
%    >> [medianCentroidCol, medianCentroidRow, fOfResidual] = ...
%       summarize_mp_centroid_residuals( motionPolyStruct, ...
%       ppaTargetStarResultsStruct, 'centroidType', 'prf', ...
%       'residualFun', @(x)sum(x, 1) );
% 
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
    DEGREES_PER_HOUR = 360 / 24;
    
    %----------------------------------------------------------------------
    % Parse and validate arguments.
    %----------------------------------------------------------------------
    parser = inputParser;
    parser.addRequired('motionPolyStruct',             @(s)isstruct(s)                     );
    parser.addRequired('targetStarResultsStruct',      @(s)isstruct(s)                     );
    parser.addParamValue('isZeroBased',         false, @(x)islogical(x) && length(x) == 1  );
    parser.addParamValue('centroidType',         'fw', @(x)any(strcmpi(x, {'fw', 'prf'})) );
    parser.addParamValue('residualFun',       @median, @(x)isa(x, 'function_handle')       );
    parser.addParamValue('cadenceIndicators',      [], @(x)islogical(x)                    );
    parser.parse(motionPolyStruct, targetStarResultsStruct, varargin{:});
    
    centroidType      = parser.Results.centroidType;
    f                 = parser.Results.residualFun;
    cadenceIndicators = colvec(parser.Results.cadenceIndicators);
    
    if numel(motionPolyStruct) ~= length(targetStarResultsStruct(1).fluxWeightedCentroids.rowTimeSeries.values);
        error('The number of cadences in motion polys and target results do not agree.');
    end

    nCadences = numel(motionPolyStruct);
    nTargets  = numel(targetStarResultsStruct);

    if strcmp(centroidType, 'fw')
        centroidFieldName = 'fluxWeightedCentroids';
    else
        centroidFieldName = 'prfCentroids';        
    end

    if length(cadenceIndicators) ~= nCadences
        cadenceIndicators = true(nCadences, 1);
    end
    
    raDegrees  = colvec([targetStarResultsStruct.raHours] * DEGREES_PER_HOUR); 
    decDegrees = colvec([targetStarResultsStruct.decDegrees]); 
    centroidRow = zeros(nCadences, nTargets);
    centroidCol = zeros(nCadences, nTargets);
    mpRow       = zeros(nCadences, nTargets);
    mpCol       = zeros(nCadences, nTargets);
    mpGaps      =  ~colvec([motionPolyStruct.rowPolyStatus]) | ...
                   ~colvec([motionPolyStruct.colPolyStatus]);
    gaps        = false(nCadences, nTargets);
    
    %----------------------------------------------------------------------
    % Get centroid time series for every target.
    %----------------------------------------------------------------------
    for iTarget = 1:nTargets
        centroidRow(:, iTarget) = targetStarResultsStruct(iTarget).(centroidFieldName).rowTimeSeries.values;
        centroidCol(:, iTarget) = targetStarResultsStruct(iTarget).(centroidFieldName).columnTimeSeries.values;
        centroidGaps = ...
            targetStarResultsStruct(iTarget).(centroidFieldName).rowTimeSeries.gapIndicators | ...
            targetStarResultsStruct(iTarget).(centroidFieldName).columnTimeSeries.gapIndicators;
        gaps(:, iTarget) = mpGaps | centroidGaps | ~cadenceIndicators;
    end
            
    %----------------------------------------------------------------------
    % Evaluate MPs for all targets at each cadence.
    %----------------------------------------------------------------------
    % Determine row & column coordinates of target centroids.
    for iCadence = 1:nCadences
        % returns 1-based row positions
        mpRow(iCadence,:) = weighted_polyval2d(raDegrees, decDegrees, ...
            motionPolyStruct(iCadence).rowPoly); 
                             
        % returns 1-based column positions           
        mpCol(iCadence,:) = weighted_polyval2d(raDegrees, decDegrees, ...
            motionPolyStruct(iCadence).colPoly); 
    end

    %----------------------------------------------------------------------
    % Compute median centroid positions and residual summary for each
    % target.
    %----------------------------------------------------------------------
    % Compute median centroid positions.
    medianCentroidRow = nan(nTargets, 1);
    medianCentroidCol = nan(nTargets, 1);
    
    for iTarget = 1:nTargets
        validCadences = ~gaps(:, iTarget);   
        if any(validCadences)
            medianCentroidRow(iTarget) = median(centroidRow(validCadences, iTarget), 1);
            medianCentroidCol(iTarget) = median(centroidCol(validCadences, iTarget), 1);
        end
    end
    
    rowResidual = mpRow - centroidRow;
    colResidual = mpCol - centroidCol;
    residual    = sqrt(rowResidual .^ 2 + colResidual .^ 2); 
    fOfResidual = nan(nTargets, 1);
    
    for iTarget = 1:nTargets
        validCadences = ~gaps(:, iTarget);  
        if any(validCadences)
            fOfResidual(iTarget) = f(residual(validCadences, iTarget));
        end
    end    
end

