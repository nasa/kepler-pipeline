function [xnew, ynew, znew] = vel_aber_inv(x, y, z, velocity, bRelativistic)
%
%function [xnew, ynew, znew] = vel_aber_inv(x, y, z, velocity, bRelativistic)
%
% Inputs:
%     x,y,z: Three vectors representing the actual direction to the star.  Need
%         not be normalized.
%
%     velocity:  a column of one or more three-vectors representing the
%         velocity of the observer, in meters per second.  Must have
%         the same dimensions as pt.
%
%     bRelativistic: A boolean flag to determine if the calculation is done
%         using the Newtonian or the relativistic form.  Defaults to 1.  The
%         Newtonian form may be faster.
%
% Output:
%     Three vectors with the same dimension as the inputs. The 3 vectors
%         are components of the unit vectors representing the true direction of
%         the star.
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

if 4 == nargin
    bRelativistic = 1;
elseif 5 ~= nargin
    error 'function [xnew, ynew, znew] = vel_aber ( x, y, z, velocity, bRelativistic )'
end

apparent_pt = [x y z];

lightspeed    = 2.99792458e8;
vel           = velocity ./ lightspeed;
beta = magvec( vel );

% angle between velocity vector and apparent direction -- NB that this calculation is of
% limited and possibly unacceptable accuracy for alpha prime within ~1 degree of zero.
alpha_prime = acos( sum( apparent_pt.*unitv( velocity ),2));

% initialize solution: set actual angle to apparent angle:
alpha = alpha_prime;

alpha_old = alpha+1; % initialize to get into loop

if bRelativistic

    while any(abs(alpha-alpha_old)>1e-12)
        alpha_old = alpha;
        dalpha = (tan(alpha_prime).*cos(alpha)+beta.*tan(alpha_prime)-sqrt(1-beta.^2).*sin(alpha))./...
            (tan(alpha_prime).*sin(alpha)+sqrt(1-beta.^2).*cos(alpha));

        alpha=alpha+dalpha;
    end


else

    while any(abs(alpha-alph_aold)>1e-12)
        alpha_old = alpha;

        dalpha = (tan(alpha_prime).*cos(alpha)+beta.*tan(alpha_prime)-sin(alpha))./...
            (tan(alpha_prime).*sin(alpha)+cos(alpha));

        alpha = alpha+dalpha;
    end

    apparent_pt = NormPt + vel;

    warning 'using newtonian velocity aberration calc';

end

% find normal to velocity vector
unit_vel=unitv(vel);

normal = uxv(unit_vel,apparent_pt); % out of paper vector
normal = unitv(uxv(normal,unit_vel));

pt = repmat(cos(alpha),1,3).*unit_vel+repmat(sin(alpha),1,3).*normal;
pt = unitv( pt );

xnew = pt(:,1);
ynew = pt(:,2);
znew = pt(:,3);
return
