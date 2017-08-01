function [rowPositionMat, colPositionMat] ...
    = derive_motion_time_series_matrices(targetArray, motionPolyStruct)
%**************************************************************************  
% function derive_motion_time_series_matrices(obj, motionPolyStruct)
%**************************************************************************  
% Derive variance-normalized row and column centroid position time series
% for each target from the motion polynomial struct and lightly detrend the
% result with a median filter.
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
    medianFilterLength = 49; %7; % <<<< SHOULD BE A MODULE PARAMETER
    
    % Retrieve the RA and Dec of each target.
    raDegrees  = [targetArray.raHours] * 360/24;
    decDegrees = [targetArray.decDegrees];
    nTargets   = numel(targetArray);
    nCadences  = length(targetArray(1).pixelDataStruct(1).values);

    rowPosition = zeros(nCadences,nTargets);
    colPosition = zeros(nCadences,nTargets);
    rowUncertainty = zeros(nCadences,nTargets);
    colUncertainty = zeros(nCadences,nTargets);
        
    % Determine row & column coordinates of target centroids.
    for n = 1:nCadences
        % returns 1-based row positions
        [rowPosition(n,:), rowUncertainty(n,:)] ...
            = weighted_polyval2d(raDegrees, ...
                                 decDegrees, ...
                                 motionPolyStruct(n).rowPoly); 
                             
        % returns 1-based column positions                     
        [colPosition(n,:), colUncertainty(n,:)] ...
            = weighted_polyval2d(raDegrees, ...
                                 decDegrees, ...
                                 motionPolyStruct(n).colPoly); 
    end
    
    rowPosition = rowPosition - 1; % 0-based row positions
    colPosition = colPosition - 1; % 0-based col positions
    
    % Detrend. 
    % We extend the time series prior to median filtering in order to
    % mitigate edge effects. In the future a more sophisticated approach
    % may yield better results. A periodic extension (reflect and flip)
    % might work well.    
    rowPositionMat ...
        = rowPosition - cosmicRayCleanerClass.padded_median_filter( ...
        rowPosition, medianFilterLength);
        
    colPositionMat ...
        = colPosition - cosmicRayCleanerClass.padded_median_filter( ...
        colPosition, medianFilterLength);
    
    % Normalize variance (approximately). It doesn't matter that we do this
    % after detrending since we're throwing away the trend anyway. Estimate
    % standard deviations from MAD of each column. 
    sigma = 1.4826*mad(rowPositionMat, 1); % 
    rowPositionMat ...
        = rowPositionMat ./ repmat(sigma, [nCadences, 1]);

    sigma = 1.4826*mad(colPositionMat, 1); 
    colPositionMat ...
        = colPositionMat ./ repmat(sigma, [nCadences, 1]);    
end

%********************************** EOF ***********************************
