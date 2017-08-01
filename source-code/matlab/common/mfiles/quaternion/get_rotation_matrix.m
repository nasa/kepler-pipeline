function rotmat = get_rotation_matrix( raDecPhi )

%--------------------------------------------------------------------------
% function rotmat = get_rotation_matrix( raDecPhi )
%--------------------------------------------------------------------------
% Calculates and returns a 3 x 3 Direction Cosine Matrix to transform from
% RA, Dec, and Roll to spacecraft attitude. This matrix is used by J20002Q
% to get the delta quaternion
%--------------------------------------------------------------------------
%
% Adopted from getDirectionMatrix() originally written by Dave Koch
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

rotation3Psi    = raDecPhi(1); % ra
rotation2Theta  = raDecPhi(2); % dec
rotation1Phi    = raDecPhi(3); % phi

sinPsi          = sin(rotation3Psi*deg2rad); % sin phi 3 rotation */
cosPsi          = cos(rotation3Psi*deg2rad); % cos phi */
sinTheta        = sin(rotation2Theta*deg2rad); % sin theta 2 rotation Note 2 rotation is negative of dec in right hand sense */
cosTheta        = cos(rotation2Theta*deg2rad); % cos theta */
sinPhi          = sin(rotation1Phi*deg2rad); % sin psi 1 rotation */
cosPhi          = cos(rotation1Phi*deg2rad); % cos psi */

% DCM for a 3-2-1 rotation, Wertz p764 , Kuiper page 86
DCM11           =  cosTheta.*cosPsi;
DCM12           =  cosTheta.*sinPsi;
DCM13           = -sinTheta;
DCM21           = -cosPhi.*sinPsi + sinPhi.*sinTheta.*cosPsi;
DCM22           =  cosPhi.*cosPsi + sinPhi.*sinTheta.*sinPsi;
DCM23           =  sinPhi.*cosTheta;
DCM31           =  sinPhi.*sinPsi + cosPhi.*sinTheta.*cosPsi;
DCM32           = -sinPhi.*cosPsi + cosPhi.*sinTheta.*sinPsi;
DCM33           =  cosPhi.*cosTheta;

rotmat          = [DCM11 DCM12 DCM13; DCM21 DCM22 DCM23; DCM31 DCM32 DCM33];

return