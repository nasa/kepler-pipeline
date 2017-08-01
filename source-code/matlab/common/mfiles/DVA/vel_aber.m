function [xnew, ynew, znew] = vel_aber(x, y, z, velocity)
%
% function [xnew, ynew, znew] = vel_aber(x, y, z, velocity)
%
% Inputs:
%     x, y, z: Row vectors of the cartesian vectors towards nStars stars, where
%              nStars is the number of columns in the vectors.  These x,y,z 
%              triplets need not be normalized.
%
%     velocity:  A matrix of nTimes rows by 3 columns.  Each row represents
%                the spacecraft velocity in in meters per second at that
%                point in time.
%
% Output:
%     Three matricies representing the cartesian direction towards nStars
%     stars.  Each matrix will be nTimes rows x nStars columns, and the
%     triplet x(iTime, iStar), y(iTime, iStar), z(iTime, iStar) is the
%     apperent position of star iStar at time iTime.
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

%     pt = [x; y; z];
% 
%     lightspeed    = 2.99792458e8;  % meters/second
%     vel           = velocity ./ lightspeed;
%     pt            = unitv( pt );
% 
%     one_over_beta = sqrt( 1 - udotv( vel, vel ) );
%     pdotv = udotv( pt, vel );
% 
%     k1 = one_over_beta;
%     k2 = 1 + pdotv ./ ( 1 + one_over_beta );
%     k3 = 1 ./ ( 1 + pdotv );
% 
%     nStars = size( pt, 1 );
%     tmp1 = repmat(k1, 1, 3) .* pt;
%     if (size(vel, 2) == 3 && size(vel, 1) ~= 1)
%         tmp2 = repmat(k2, 1, 3) .* vel;
%         %         elseif (size(vel, 2) == 3 && size(vel, 1) == 1)
%         %             tmp2 = repmat(k2, 1, 3) .* repmat(vel, nStars, 1);
%         %         else
%         %             error('MATLAB:FC:RADEC2PIX', 'bad vel size in vel_aber');
%         %         end
%         tmp3 = repmat(k3, 1, 3);
% 
%         apparent_pt = tmp3 .* (tmp1 + tmp2);
% 
%     apparent_pt = unitv( apparent_pt );
%     
%     xnew = apparent_pt(:,1)';
%     ynew = apparent_pt(:,2)';
%     znew = apparent_pt(:,3)';

    nStars = length(x);
    nTimes = size(velocity, 1);
    pt = [x(:), y(:), z(:)];
    pt = unitv(pt);

    lightspeed    = 2.99792458e8;  % meters/second
    vel           = velocity ./ lightspeed;

    % Black magic from Jon to to reshape bigVel into
    % the same format as bigPt
    %
    bigPt  = repmat(pt, nTimes, 1);
    bigVel = repmat(vel,[1,1,nStars]);
    bigVel = permute(bigVel,[3,1,2]);
    bigVel = reshape(bigVel,nTimes*nStars,3);

    oneOverBeta = sqrt(1 - sum(bigVel .* bigVel, 2));
    pDotV       = sum(bigPt  .* bigVel, 2);

    k1 = repmat(oneOverBeta,                    1, 3);
    k2 = repmat(1 + pDotV ./ (1 + oneOverBeta), 1, 3);
    k3 = repmat(1 ./ (1 + pDotV),               1, 3);

    apparentPt = k3 .* (k1 .* bigPt + k2 .* bigVel);
    apparentPt = unitv(apparentPt);
    
    xnew = reshape(apparentPt(:,1), nStars, nTimes)';
    ynew = reshape(apparentPt(:,2), nStars, nTimes)';
    znew = reshape(apparentPt(:,3), nStars, nTimes)';
return

