function  deltaQuaternion = get_delta_quaternion(actualRaDecPhi,desiredRaDecPhi, mjd, raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  deltaQuaternion = get_delta_quaternion(actualRaDecPhi,desiredRaDecPhi, mjd, raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% get_delta_quaternion() returns a rotation quaternion for Kepler
% representing the attitude tweak necessary to validate optimal apertures.
% Uses the ACTUAL spacecraft attitude (as determined  in PDQ) as well
% as the DESIRED attitude (as indicated by the Pointing model in  RaDec2Pix).
%
%
%   qA = actual attitude as a quaternion is determined relative to
%        spacecraft frame of reference
%
%   qD = desired attitude as a quaternion, is determined relative to
%        spacecraft frame of reference
%
%   deltaQ = delta quaternion to be sent to flight segment for attitude
%            tweaks. This is a rotation quaternion.
%
%
% The delta quaternion 'deltaQ' takes the unit quternion 'qA' (actual
% attitude quaternion) into 'qD' (desired attitude quaternion)
%
%       qA X deltaQ   = qD;
%
%       deltaQ =   (qA)* X qD   where '*' indicates quaternion conjugate and
%       'X' indicates quatenion product
%
%
% Remember that quaternions do not commute under multiplication.
%
% Also remember to ensure that the delta quaternion is computed for the
% photometer frame co-ordinates (which are in row, col)) as opposed to the
% raDec2Pix co-ordinates which are in (ra, dec). raDec2Pix frame of
% reference is at NOMINAL_CLOCKING_ANGLE (13deg) + NOMINAL_FIRST_ROLL +
% seasonInt *90 w.r.t photometer frame (row,col).
%
%
% The solution is to add this NOMINAL_CLOCKING_ANGLE (13deg) +
% NOMINAL_FIRST_ROLL + seasonInt *90 to the roll angle (computed by
% raDec2PixModel) in both the actual attitude and the desired attitude,
% which is accomplished by radecphi_to_quaternion.
%
%
% References:
%
% Jack B. Kuipers, "Quaternions and Rotation Sequences: A Primer with
% Applications to Orbits, Aerospace, and Virtual Reality," Page 167,180
% Princeton University Press, 1999.
%
% "Kepler Attitude Control Algorithm" (KEPLER.DFM.ACS.054) by Dustin
% Putnam, BATC dated 3/16/05
% 
% "ADCS SPAS Tool - Delta Quaternion Processing" (KEPLER.DFM.ACS.102) by
% Dustin Putnam, 1/17/08
% 
% 
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



% Quaternion for the DESIRED attitude
qDesired = radecphi_to_quaternion(desiredRaDecPhi, mjd, raDec2PixObject);


% Quaternion for the  ACTUAL attitude
qActual = radecphi_to_quaternion(actualRaDecPhi, mjd, raDec2PixObject);



% The deltaQuaternion transforms ACTUAL spacecraft attitude quaternion to
% the DESIRED spacecraft attitude quaternion

deltaQuaternion = quaternion_product(quaternion_conjugate(qActual), qDesired );


return


