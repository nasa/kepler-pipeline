function [rot321] = quaternion_to_euler321(Q)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [rot321] = quaternion_to_euler321(Q)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Source:
% http://staff.ee.sun.ac.za/gwmilne/resources.html
% Produces Euler angle Array [Psi Theta Phi]'  (NASA 321 rotation) from
% Quaternion Q
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

% G.W. Milne 16 July 2000

% Reference - Pamadi (AIAA) P345 Eqn 4.221
% Note his Quaternian is written as [q4 q1 q2 q3 ]
%
% Jack B. Kuipers, "Quaternions and Rotation Sequences: A Primer with
% Applications to Orbits, Aerospace, and Virtual Reality," Page 167,
% Princeton University Press, 1999.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% From Kuipers, page 86
% The direction cosine matrix for the aerospace sequence is
% R = R^x_phi*R^y_theta*R^z_psi
%     |1      0        0    | |cos(theta)  0  -sin(theta)| | cos(psi) sin(psi) 0| 
%   = |0   cos(phi) sin(phi)|*|    0       1        0    |*|-sin(psi) cos(psi) 0|
%     |0   sin(ph)  cos(phi)| |sin(theta)  0   cos(theta)| |    0         0    1|
%
%     |cos(psi)cos(theta),                                   sin(psi)cos(theta),                -sin(theta)        |
%   = |cos(psi)sin(theta)sin(phi)-sin(psi)cos(phi), sin(psi)sin(theta)sin(phi)+cos(psi)cos(phi), cos(theta)sin(phi)|
%     |cos(psi)sin(theta)cos(phi)-sin(psi)sin(phi), sin(psi)sin(theta)cos(phi)+cos(psi)sin(phi), cos(theta)cos(phi)|
%
% and
%
% R(1,1) = 2*Q(4)^2 + 2*Q(1)^2 - 1;
% R(1,2) = 2*Q(1)*Q(2) + 2*Q(4)*Q(3);
% R(1,3) = 2*Q(1)*Q(3) - 2*Q(4)*Q(2);
% R(2,3) = 2*Q(2)*Q(3) + 2*Q(4)*Q(1);
% R(3,3) = 2*Q(4)^2 + 2*Q(3)^2 - 1;
%
% So we can solve for the euler angles from the elements of R noting that
% cos(theta)>0 and examining the signs of the direction cosine matrix elements.

Q = Q(:);

if size(Q)~=[4 1]
    error('Dimensions of Q must be [4 x 1]')
end

% Fill in elements of rotation matrix corresponding to quaternion
R11 = 2*Q(4)^2 + 2*Q(1)^2 - 1;
R12 = 2*Q(1)*Q(2) + 2*Q(4)*Q(3);
R13 = 2*Q(1)*Q(3) - 2*Q(4)*Q(2);
R23 = 2*Q(2)*Q(3) + 2*Q(4)*Q(1);
R33 = 2*Q(4)^2 + 2*Q(3)^2 - 1;

psi = atan2(R12,R11);

theta = asin(-R13);

phi = atan2(R23,R33);

psi = psi*rad2deg;

theta = theta*rad2deg;

phi = phi*rad2deg;

rot321 = [psi, theta, phi];

return
