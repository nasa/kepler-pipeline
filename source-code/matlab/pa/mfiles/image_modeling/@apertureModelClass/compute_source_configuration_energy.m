function w = compute_source_configuration_energy(ra, dec, ...
    catalogRa, catalogDec, restoringCoef, repulsiveCoef, noPenaltyRadius)
%**************************************************************************
% w = compute_source_configuration_energy(ra, dec, catalogRa, catalogDec)
%**************************************************************************
% Given catalog positions of a set of stars along with hypothetical new
% locations, compute a measure of the "energy" required to change the
% catalog configuration to the hypothetical one. 
%
% INPUTS
%     ra            : An nStars-length array of hypothetical new right 
%                     ascension values for each star.
%     dec           : An nStars-length array of hypothetical new
%                     declination values for each star.
%     catalogRa     : An nStars-length array of catalog right ascension
%                     values for each star. 
%     catalogDec    : An nStars-length array of catalog declination values
%                     for each star. 
%     restoringCoef : (default = 1e8)
%     repulsiveCoef : (default = 1.0)
%     noPenaltyRadius : Radius (degrees) within which a star's position may
%                     change without the "restoration force" adding to the
%                     energy. (default = DEGREES_PER_PIXEL *
%                     NO_PENALTY_RADIUS_PIXELS)   
%
% OUTPUTS
%     w             : A value in the range [MIN_CONFIGURATION_WEIGHT, 
%                     MAX_CONFIGURATION_WEIGHT].
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

    if ~exist('restoringCoef', 'var')
        restoringCoef = 1e8;
    end
    if ~exist('repulsiveCoef', 'var')
        repulsiveCoef = 1.0;
    end
    if ~exist('noPenaltyRadius', 'var')
        noPenaltyRadius = apertureModelClass.DEGREES_PER_PIXEL * ...
            apertureModelClass.NO_PENALTY_RADIUS_PIXELS;
    end
    
    ra         = colvec(ra);
    dec        = colvec(dec);
    catalogRa  = colvec(catalogRa);
    catalogDec = colvec(catalogDec);
    nStars     = length(catalogRa);
    
    %----------------------------------------------------------------------                
    % Compute energy due to a "restoring force" (PE = k * r^2).
    %----------------------------------------------------------------------                
    distanceSquared = (ra  - catalogRa ).^2 + (dec - catalogDec).^2;
    
    % Apply the no-penalty radius
    if noPenaltyRadius > 0
        newDistance = sqrt(distanceSquared) - noPenaltyRadius;
        newDistance(newDistance < 0) = 0;
        distanceSquared = newDistance.^2;
    end
    
    totalRestoringEnergy = sum(distanceSquared);
    
    %----------------------------------------------------------------------                
    % Compute the change in energy due to a "repulsive force" (PE = k / r).
    % We compute the PE for each pair of points and sum the total.    
    %----------------------------------------------------------------------     
    
% THIS IS THE CORRECT FUNCTION CALL, BUT THE ERROR WAS CAUGHT AFTER THE
% OPPORTUNITY TO FIX IT HAD PASSED: 
%    distanceMat = compute_angular_separation_matrix(catalogRa, catalogDec);  

    distanceMat = euclidian_distance_matrix(catalogRa, catalogDec);  % Distances in degrees.
    triuIndicators = triu(true(size(distanceMat)), 1); % Upper triangular portion.
    initialRepulsiveEnergy = sum(1 ./ distanceMat(triuIndicators)); 
    
    distanceMat = euclidian_distance_matrix(ra, dec); % Distances in degrees.
    currentRepulsiveEnergy = sum(1 ./ distanceMat(triuIndicators));
    deltaRepulsiveEnergy = currentRepulsiveEnergy - initialRepulsiveEnergy;
    repulsiveEnergyIncrease = deltaRepulsiveEnergy;
    repulsiveEnergyIncrease(deltaRepulsiveEnergy < 0) = 0; 
    
    %----------------------------------------------------------------------                
    % The weight is the average "energy" per star. We use the average
    % rather than the total because we don't want to penalize motion in an
    % aperture simply because it has more contributing stars.
    %----------------------------------------------------------------------                
    w = (restoringCoef*totalRestoringEnergy + ...
         repulsiveCoef*repulsiveEnergyIncrease) / nStars;
    
    %----------------------------------------------------------------------  
    % Limit the output to the range [MIN_CONFIGURATION_WEIGHT, 
    % MAX_CONFIGURATION_WEIGHT].
    %----------------------------------------------------------------------                
    if w < 0 
        w = 0;
    end
    w = w + apertureModelClass.MIN_CONFIGURATION_WEIGHT;
    
    if w > apertureModelClass.MAX_CONFIGURATION_WEIGHT
        w = apertureModelClass.MAX_CONFIGURATION_WEIGHT;
    end
end

%**************************************************************************
% separationMat = compute_angular_separation_matrix(raDegrees, decDegrees)
%**************************************************************************
% Return the upper tiangular matrix whose elements contain the angular
% distances (degrees) between points on the celestial sphere.
% 
% INPUTS
%     raDegrees  : An nPoints-length array of right ascensions (degrees).
%     decDegrees : An nPoints-length array of declinations (degrees).
% 
% OUTPUTS
%     separationMat : An nPoints-by-nPoints matrix. The the (i,j)th element
%                     of the uppertriangular portion contains the angular
%                     distance in degrees between points 
%                     <raDegrees(i), decDegrees(i)> and 
%                     <raDegrees(j), decDegrees(j)>
%**************************************************************************
function separationMat = compute_angular_separation_matrix(raDegrees, decDegrees)
    raDec = [colvec(raDegrees),colvec(decDegrees)];
    nPoints = length(raDegrees);
    separationMat = zeros(nPoints);
    for i = 1:nPoints-1
        for j = i+1:nPoints
            separationMat(i, j) = ...
                apertureModelClass.angular_separation_degrees( ...
                    raDec(i, :), raDec(j, :) ); 
        end
    end
end

%**************************************************************************
% Return the upper tiangular matrix whose values give the distances between
% each pair of points x(n), y(n) and x(k), y(k).
% 
% NOTE THAT THIS FUNCTION DOES NOT CORRECTLY COMPUT ANGULAR DISTANCES!
% Leaving it here was an oversight. The correct distance matrix is computed
% by the function compute_angular_separation_matrix().
function distanceMat = euclidian_distance_matrix(x, y)
    x = colvec(x);
    y = colvec(y);
    n = length(x);
    xDiffMat = zeros(n);
    yDiffMat = zeros(n);
    for i = 1:n-1
        xDiffMat(i, :) = x - circshift(x, i); 
        yDiffMat(i, :) = y - circshift(y, i); 
    end
    xDiffMat = triu(xDiffMat, 1);
    yDiffMat = triu(yDiffMat, 1);
    
    distanceMat = sqrt(xDiffMat.^2 + yDiffMat.^2);
end
