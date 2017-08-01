function degrees = angular_separation_degrees( raDec1, raDec2 )
%**************************************************************************
% Compute the angular separation (degrees) between two points on the unit
% celestial sphere given in degrees. 
%
% INPUTS
%     raDec1  : A Nx2 matrix with RA in the first column and Dec in the
%               second, both in degrees.
%     raDec2  : A Nx2 matrix with RA in the first column and Dec in the
%               second, both in degrees.
% OUTPUTS
%     degrees : An Nx1 array containing the angular separation in degrees
%               bewteen each pair of points in the inputs, raDec1(iPoint,:)
%               and raDec2(iPoint,:).  
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
    xyz1 = convert_ra_dec_to_xyz( raDec1 );
    xyz2 = convert_ra_dec_to_xyz( raDec2 );

    dotProd = dot(xyz1, xyz2, 2); % Dot products of row vectors
    dotProd(dotProd > 1.0) = 1; % Clamp values before calling acos()
    dotProd(dotProd < -1.0) = -1;

    degrees = acosd(dotProd);
end


function xyz = convert_ra_dec_to_xyz( raDec )
%**************************************************************************
% Convert from celestial to cartesian coordinates.
% raDec is in degrees.
% xyz is in a right-handed coord system with:
%     +x toward RA = Dec = 0
%     +z toward celestial north pole
%**************************************************************************
    ra  = (pi/180)*raDec(:,1);
    dec = (pi/180)*raDec(:,2);
    xyz = [ cos( ra ).*cos( dec ), cos( dec ).*sin( ra ), sin( dec ) ];
end