function [cosmicRayMatrix] = compute_cosmic_rays( areaCm2, timeSec )
%
% compute_cosmic_rays -- generate cosmic ray events for use in Kepler Mission studies
%
% [cosmicRayMatrix] = compute_cosmic_rays( areaCm2, timeSec ) generates a matrix of cosmic
%    rays which will hit an area (given in cm^2 by argument areaCm2) in a given time
%    interval (given in seconds by argument timeSec).  The returned matrix,
%    cosmicRayMatrix, is a matrix of nRows x nColumns x nRays, where
%    cosmicRayMatrix(:,:,iRay) is the spatial distribution of intensity onto Kepler
%    pixels which surround the central impact pixel (the grid is nominally 13 x 13,
%    yielding added flux values for all pixels within +/- 6 rows or columns from the
%    impacted pixel).  The values in cosmicRayMatrix are in photoelectrons.  
%
% compute_cosmic_rays uses an algorithm for generation which is basically identical to
%    that used by ETEM.
%
% Version date:  2008-November-24.
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

% Modification History:
%
%=========================================================================================
    
% The cosmic ray rate is a constant, 5 CR per square cm per second

  crRate = 5 ;
  
% load the cosmic ray shapes file from ETEM

  currentDir = pwd ;
  socCodeRoot = getenv('SOC_CODE_ROOT') ;
  cd([socCodeRoot filesep 'matlab/etem2/mfiles/configuration_files']) ;
  load gcmshapes_03_16_2005 ;
  nShapes = size(gcmshapes,3) ;
  nRowsPerShape = size(gcmshapes,1) ;
  nColsPerShape = size(gcmshapes,2) ;
  
% go to the ETEM directory with the utilities for CR generation

  cd([socCodeRoot filesep 'matlab/etem2/mfiles/utilities']) ;
  
% load the cosmic ray distribution -- the intensity and probability of a cosmic ray

  [cosmicIntensity, cosmicProbability] = gcrpdf ;
  
% construct a piecewise-polynomial representation of the cumulative probability function

  cosmicCumProbPoly = mkppcdf( cosmicIntensity, cosmicProbability ) ;
  
% compute the number of cosmic rays expected; this is the product of the area in sq cm,
% the time in seconds, and the probability per unit area per unit time

  nCrExpected = crRate * areaCm2 * timeSec ;
  
% generate the actual number of cosmic rays; this is a Poisson-distributed random number
% with mean == nCrExpected

  nCrActual = round(randp_tfu(nCrExpected)) ;
  
% for each cosmic ray, generate a random shape and a random total intensity.  For shapes,
% this is done by picking a random pointer into the shapes matrix.  For intensity, it's
% done by inverting the cumulative probability polynomial, selecting random values between
% 0 and 1, and evaluating the inverted polynomial at those values.

  crShape = random_integer(nCrActual,1,1,nShapes) ;
%  crShape = ceil(rand(nCrActual,1)*nShapes) ;
  crIntensity = ppcdfinv( cosmicCumProbPoly, rand(nCrActual,1) ) ;
  
% Generate the cosmic ray matrix.  This is the ray-by-ray product of the intensity of each
% ray and its shape.  To make this work, we need to turn both the intensity and the shape
% into M x N x nCrActual matrices.

  cosmicRayMatrix = repmat(   reshape( crIntensity, [1,1,nCrActual] ), ...
                              [nRowsPerShape, nColsPerShape, 1]          ) ...
                              .* gcmshapes(:,:,crShape) ;
                          
% cleanup:  eliminate values of < 1 photoelectron

  cosmicRayMatrix = cosmicRayMatrix(:) ;
  lowValuePointer = find(cosmicRayMatrix < 1) ;
  cosmicRayMatrix(lowValuePointer) = 0 ;
  cosmicRayMatrix = reshape(cosmicRayMatrix, [nRowsPerShape, nColsPerShape, nCrActual] ) ;
                          
% cleanup:  go back to the original directory

  cd(currentDir) ;
    
return

% and that's it!

%
%
%

      