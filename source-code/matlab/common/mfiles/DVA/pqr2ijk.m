function [ijk] = pqr2ijk(pqr,Omega,w_peri,inc)
% function [ijk] = pqr2ijk(pqr,Omega,w_peri,inc)
%
% pqr2ijk() converts a vector in perifocal coordinates (P, Q, R)
% to a vector in ecliptic coordinates (I, J, K). The coordinate systems are
% related by the orbital elements. The vector pqr is transformed to
% the vector ijk
% 
% Inputs:
%       pqr - three-vector in the perifocal coordinate system
%               pqr can either be 3x1, or a row vector or array of row
%               vectors (1x3, Nx3)
%       Omega - longitude of ascending node (dgrees)
%       w_peri - argument of periapsis (degrees)
%       inc - inclination angle (degrees)
% Outputs:
%       ijk - transformed vector in the I,J,K coordinate system
%               size of ijk matches input pqr:   3x1, or 1x3...Nx3
% See Bate, R. R., "Fundamentals of Astrodynamics," chpt. 2 for details of
% the transformation
%
% Software level: Prototype code - coordinate tranform utility
%
% Modification History: written by Doug Caldwell 14 Jan 2004
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

% check for row or column vectors
[r,c]=size(pqr);
if (r~=3 & c~=3)
    error('Input pqr must be a 3-component vector');
else  % assumes a row vector, or array of row vectors
    if (r~=3) % it either a column vector, or an array of column vectors
        pqr=pqr';
        c=r;
    end
end

% convert input angles to radians
om = Omega*pi/180;
w = w_peri*pi/180;
i = inc*pi/180;

% define components of transformation matrix (Bate, p. 82)
R11 = cos(om)*cos(w) - sin(om)*sin(w)*cos(i);
R12 = -cos(om)*sin(w) - sin(om)*cos(w)*cos(i);
R13 = sin(om)*sin(i);

R21 = sin(om)*cos(w) + cos(om)*sin(w)*cos(i);
R22 = -sin(om)*sin(w) + cos(om)*cos(w)*cos(i);
R23 = -cos(om)*sin(i);

R31 = sin(w)*sin(i);
R32 = cos(w)*sin(i);
R33 = cos(i);

R = [[R11, R12, R13];...
        [R21, R22, R23];...
        [R31, R32, R33]];
    
for n=1:c,  %do the math, looping over array 
    ijk(:,n) = R*pqr(:,n);
end

if (r~=3)  % tranform back to input format if needed
    ijk=ijk';
end

