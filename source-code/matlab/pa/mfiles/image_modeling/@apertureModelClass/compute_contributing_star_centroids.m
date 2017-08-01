function compute_contributing_star_centroids(obj, useZeroBased)
%**************************************************************************  
% function [centroidRowPositions, centroidColPositions] = ...
%    ra_dec_to_centroid_time_series(raDegrees, decDegrees, ...
%        motionPolyStruct, useZeroBased)
%**************************************************************************  
% Use the current motion model to derive row and column centroid position
% time series for each contributing star. 
%
% INPUTS
%     raDegrees        : An N-by1 array of right ascension values (degrees).
%     decDegrees       : An N-by1 array of declination values (degrees).
%     motionPolyStruct : 
%     useZeroBased     : If true, row and column centroid positions are
%                        returned in zero-based coordiantes (default 
%                        = false).
% OUTPUTS
%     rowPosition      : nCadences-by-nStars array of fractional CCD row
%                        coordinates to which the motion polynomials map
%                        the corresponding sky coordinates (RA, Dec).  
%     colPosition      : nCadences-by-nStars array of fractional CCD
%                        column coordinates to which the motion polynomials
%                        map the corresponding sky coordinates (RA, Dec).
%     rowUncertainty   : nCadences-by-nStars array of CCD row
%                        uncertainties. 
%     colUncertainty   : nCadences-by-nStars array of CCD column
%                        uncertainties.
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

    if ~exist('useZeroBased', 'var')
        useZeroBased = false;
    end
       
    nStars    = numel(obj.contributingStars);
    nCadences = obj.get_num_cadences();

    rowPosition    = zeros(nCadences, nStars);
    colPosition    = zeros(nCadences, nStars);
    rowUncertainty = zeros(nCadences, nStars);
    colUncertainty = zeros(nCadences, nStars);
        
    raDegrees  = colvec([obj.contributingStars.raDegrees]); 
    decDegrees = colvec([obj.contributingStars.decDegrees]); 

    % Determine row & column coordinates of target centroids.
    for iCadence = 1:nCadences
        % returns 1-based row positions
        [rowPosition(iCadence,:), rowUncertainty(iCadence,:)] ...
            = weighted_polyval2d(raDegrees, ...
                                 decDegrees, ...
                                 obj.motionModelHandle.motionPolyStruct(iCadence).rowPoly); 
                             
        % returns 1-based column positions                     
        [colPosition(iCadence,:), colUncertainty(iCadence,:)] ...
            = weighted_polyval2d(raDegrees, ...
                                 decDegrees, ...
                                 obj.motionModelHandle.motionPolyStruct(iCadence).colPoly); 
    end
    
    if useZeroBased
        rowPosition = rowPosition - 1; % convert to 0-based row positions
        colPosition = colPosition - 1; % convert to 0-based col positions
    end
    
    for iStar = 1:nStars
        obj.contributingStars(iStar).centroidRow = rowPosition(:, iStar);
        obj.contributingStars(iStar).centroidCol = colPosition(:, iStar);
    end
    
    % The centroids are now up to date.
    obj.clear_centroids_out_of_date();
end

%********************************** EOF ***********************************
