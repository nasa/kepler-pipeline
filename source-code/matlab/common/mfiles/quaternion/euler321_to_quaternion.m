function qzyx = euler321_to_quaternion(rot321)
%--------------------------------------------------------------------------
% function qzyx = euler321_to_quaternion(rot321)
%--------------------------------------------------------------------------
% Calculates and returns a quaternion for the aerospace euler angle
% sequence 321 (3x1) array (in degrees) for rot123 = [rot3, rot2, rot1]
%
% Jack B. Kuipers, "Quaternions and Rotation Sequences: A Primer with
% Applications to Orbits, Aerospace, and Virtual Reality," Page 167,
% Princeton University Press, 1999.
%
%--------------------------------------------------------------------------
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

% need some error checking ....

rot3 = deg2rad(rot321(1));

rot2 = deg2rad(rot321(2));

rot1 = deg2rad(rot321(3));


qZ      = [ 0; 0; sin(1/2 * rot3 ); cos(1/2 * rot3 )];

qY      = [ 0; sin(1/2 * rot2 ); 0; cos(1/2 * rot2 )];

qX      = [sin(1/2 * rot1 ); 0; 0;  cos(1/2 * rot1 )];

qzyx      = quaternion_product(qZ, quaternion_product(qY, qX));


% check using the second method


% q0 = cos(rot3)*cos(rot2/2)*cos(rot1/2) + sin(rot3/2)*sin(rot2/2)*sin(rot1/2);
% 
% q1 = cos(rot3/2)*cos(rot2/2)*sin(rot1/2) - sin(rot3/2)*sin(rot2/2)*cos(rot1/2);
% 
% q2 = cos(rot3/2)*sin(rot2/2)*cos(rot1/2) + sin(rot3/2)*cos(rot2/2)*sin(rot1/2);
% 
% q3 = sin(rot3/2)*cos(rot2/2)*cos(rot1/2) - cos(rot3/2)*sin(rot2/2)*sin(rot1/2);

qzyx = qzyx(:);

% q = [ q1 q2 q3 q0]'
%
% qzyx



return

