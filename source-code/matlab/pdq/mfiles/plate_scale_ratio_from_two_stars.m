function ratio = plate_scale_ratio_from_two_stars(catalogRa, catalogDec, predictedRa, predictedDec)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plateScale = plate_scale_ratio_from_two_stars(catalogRa, catalogDec,
%                                                 predictedRa, predictedDec) 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Determine a scaling factor, M, to be applied to a nominal plate scale. M
% is computed from the predicted and catalog positions of two stars and is
% the ratio of the angular separationof the former to that of the latter.  
% The current plate scale is then
%
%     Current Plate Scale = M x (Nominal Plate Scale)
%
% Plate scale is defined as the ratio of the angular separation between two
% points on the celestial sphere to the euclidean distance in pixels
% between the centroids of their images on the focal plane.  
%
% Inputs:
%     catalogRa : a 2-element vector of catalog right-ascension values
%                   in degrees. 
%     catalogDec : a 2-element vector of catalog declination values in
%                   degrees. 
%     predictedRa  : a 2-element vector of PREDICTED right-ascension values
%                   in degrees. 
%     predictedDec : a 2-element vector of PREDICTED declination values in
%                   degrees. 
%
% Outputs:
%     ratio : the ratio of the apparent angular separation of two stars to
%             the angular separation of their catalog positions.
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
catalogRaDec1   = [ catalogRa(1), catalogDec(1) ];
catalogRaDec2   = [ catalogRa(2), catalogDec(2) ];
predictedRaDec1 = [ predictedRa(1), predictedDec(1) ];
predictedRaDec2 = [ predictedRa(2), predictedDec(2) ];

ratio = angular_separation(predictedRaDec1, predictedRaDec2) ...
        / angular_separation(catalogRaDec1, catalogRaDec2);
return


function degrees = angular_separation( raDec1, raDec2 )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute the angular separation (degrees) between two points on the
% unit celestial sphere given in degrees.
%
% Inputs:
%     raDec1 : a Nx2 matrix with RA in the first column and Dec in the
%              second, both in degrees.
%     raDec2 : a Nx2 matrix with RA in the first column and Dec in the
%              second, both in degrees.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
xyz1 = convert_ra_dec_to_xyz( raDec1 );
xyz2 = convert_ra_dec_to_xyz( raDec2 );

dotProd = dot(xyz1, xyz2, 2); % Dot products of row vectors
dotProd(dotProd > 1.0) = 1; % Clamp values before calling acos()
dotProd(dotProd < -1.0) = -1;

degrees = acosd(dotProd);
return


function xyz = convert_ra_dec_to_xyz( raDec )
% Convert from celestial to cartesian coordinates.
% raDec is in degrees.
% xyz is in a right-handed coord system with:
%     +x toward RA = Dec = 0
%     +z toward celestial north pole
ra  = (pi/180)*raDec(:,1);
dec = (pi/180)*raDec(:,2);
xyz = [ cos( ra ).*cos( dec ), cos( dec ).*sin( ra ), sin( dec ) ];
return
