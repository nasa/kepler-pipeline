function Q = J20002Q(x,y,z)
% Q = J20002Q(x,y,z)
% returns the quaternians for J2000 axes specified by row vectors x, y and z,
% each of which can be a time series. In this case, each of x, y and z
% would be arrays where time runs down the columns.
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

nTimes  =  size(z,1);

Q = zeros(nTimes,4);

% Now construct A matrix for each point and construct Q
% We need to be aware of possible singularities and "skirt" around them if
% necessary in solving the quadratic equations.

for i = 1:nTimes,
    A = [x(i,:);y(i,:);z(i,:)];
    if 1+A(1,1)+A(2,2)+A(3,3)>.9,
        q4 = .5*sqrt(1+A(1,1)+A(2,2)+A(3,3));
        q1 = (A(2,3)-A(3,2))/4/q4;
        q2 = (A(3,1)-A(1,3))/4/q4;
        q3 = (A(1,2)-A(2,1))/4/q4;
    elseif 1-A(1,1)-A(2,2)+A(3,3)>.9,
        q3 = .5*sqrt(1-A(1,1)-A(2,2)+A(3,3));
        q1 = (A(3,1)+A(1,3))/4/q3;
        q2 = (A(2,3)+A(3,2))/4/q3;
        q4 = (A(1,2)-A(2,1))/4/q3;
    elseif 1-A(1,1)+A(2,2)-A(3,3)>.9,
        q2 = .5*sqrt(1-A(1,1)+A(2,2)-A(3,3));
        q1 = (A(1,2)+A(2,1))/4/q2;
        q3 = (A(2,3)+A(3,2))/4/q2;
        q4 = (A(3,1)-A(1,3))/4/q2;
    elseif 1+A(1,1)-A(2,2)-A(3,3)>.9,
        q1 = .5*sqrt(1+A(1,1)-A(2,2)-A(3,3));
        q2 = (A(1,2)+A(2,1))/4/q1;
        q3 = (A(3,1)+A(1,3))/4/q1;
        q4 = (A(2,3)-A(3,2))/4/q1;
    end

    Q(i,:) = [q1 q2 q3 q4];
    
    if i>1,
      if Q(i-1,:)*Q(i,:)'<0, 
          Q(i,:) = -Q(i,:); 
      end 
    end

end

