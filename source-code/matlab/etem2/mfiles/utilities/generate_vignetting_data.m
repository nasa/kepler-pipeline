function generate_vignetting_data(outputFilePath)

% List of unique outputs due to rotational symmetry
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
error('this code is out of date, I hope you still have the previously generated data');

out_vec = [6 7 9 10 11 12 22 23 25 26 27 28 42];  % only unique ones

% define map of outputs to unique outputs
outputMap = Output_Map(); % function lower in this file
save(outputFilePath, 'outputMap');
for i = 1:length(out_vec)

    % Compute the vignetting given the output
    v = Compute_for_Output(out_vec(i));
    
    vString = ['vignettingShape' num2str(out_vec(i))];
    
    % Move "v" into "v24" or "v11" etc.
    eval([vString ' = v;'])

    % Generate the string of the concatination of v and the output number
    savestr = ['v' num2str(out_vec(i))];

    % Save the vignetting matrix variable to the file 
    eval(['save(' outputFilePath ', ' vString ', -append);']);

    % Clear the variable
    eval(['clear ' vString]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v_mat = Compute_for_Output(out_num)
% Convert deg to rad & back.
r2d = 180/pi;
d2r = pi/180;

% Center of the FOV
C_ra  = 15*(19 + 22/60 + 40/3600);  % 19h 22m 40s
C_dec = 44.5;  % 44deg 30 min 00 sec

%FOV center in cartesian coordinates
[Cx,Cy,Cz] = sph2cart(C_ra*d2r,C_dec*d2r,1);

% Quarter = 0 (doesn't matter since focal plane is symmetric)
quarter = 0;

% Allocate room for results
v_mat = zeros(1024,1100);

persistent vig_dist vigvector
if isempty(vigvector)
    % Convert to radians
    vig_dist = (0:.001:10) * d2r;
    % Pre-compute a vignetting vector
    vigvector = vignetting(vig_dist);
end

h = waitbar(0,['Computing Vignetting Information on output # ' num2str(out_num) '.']);

for row = 1:1024

    if ~mod(row,8),waitbar(row/1024);end
 
    for col = 1:1100

        % What is the RA/Dec of that pixel?
        [ra,dec] = Pix2RaDec(out_num,row,col,quarter);

        % Convert that RA/Dec to spherical
        [Mx,My,Mz] = sph2cart(ra*d2r,dec*d2r,1);

        % The angle between two vectors is given by the formula
        % cos(theta) = v dot u / ( norm(v) * norm(u) )
        % Since norm(v) and norm(u) are 1 (see calls to cart2sph),
        % this reduces to theta = acos(u dot v)
        % or specifically theta = acos(Mx*Cx+My*Cy+Mz*Cz)
        theta = acos(Mx*Cx+My*Cy+Mz*Cz);

        % if theta is 0 k is 1 if theta is 0.08*pi/180 then k is 9
        % so k is an index into vigvector for how much the point on the
        % focal plane is vignetted at this angle, theta
        k = round(1000*theta*r2d+0.5);

        % so then the vignetting matrix is appropriately filled
        v_mat(row,col) = vigvector(k);

    end
end
close(h)

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% I'm basically instantiating this from the vignetting work I have
% previously done so it is here. JJG
%
function Ared  =  vignetting(phi,L,Rp,Rc)
% function Ared  =  vignetting(phi,L,Rp,Rc)
%
% computes vignetting for a telescope with distance L between primary and
% corrector, and with primary and corrector radii Rp and Rc, respectively
% (all distances/lengths same units, but nominally meters), and for angle(s)
% phi (in radians).

if nargin == 0, phi = (0:.001:10)'*pi/180; end
if nargin < 2,  L   = 1.4;    end% meters
if nargin < 3,  Rp  = 1.4/2;  end %meters
if nargin < 4,  Rc  = 0.95/2; end% meters

% offset in meters on focal plane for angle phi
D      = 2*L*tan(phi) + eps; % avoid divide by zero by adding epsilon. Added 2/14/05

% intersection of primary and corrector discs
xc     = 1/2./D.*(Rp^2 - Rc^2 + D.^2);
y      = real(sqrt(Rp^2 - xc.^2));

% angle in corrector disk in intersection of two disc areas
thetac = atan2(y,D-xc);

% angle in primary mirror disc in intersection of two disc areas
thetap = atan2(y,xc);

% area of intersection
Ain    = thetap*Rp^2 + thetac*Rc^2 - D.*y;

% fraction reduction in intensity
Ared   = Ain/(pi*Rc^2);

%plot(phi*180/pi,Ain/(pi*Rc^2)),grid

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vm = Output_Map

vm = [
    1 10
    2 9
    3 12
    4 11
    5 6
    6 6
    7 7
    8 7
    9 9
    10 10
    11 11
    12 12
    13 9
    14 10
    15 11
    16 12
    17 25
    18 26
    19 27
    20 28
    21 22
    22 22
    23 23
    24 23
    25 25
    26 26
    27 27
    28 28
    29 10
    30 9
    31 12
    32 11
    33 6
    34 6
    35 7
    36 7
    37 22
    38 22
    39 23
    40 23
    41 42
    42 42
    43 42
    44 42
    45 22
    46 22
    47 23
    48 23
    49 6
    50 6
    51 7
    52 7
    53 10
    54 9
    55 12
    56 11
    57 25
    58 26
    59 27
    60 28
    61 22
    62 22
    63 23
    64 23
    65 25
    66 26
    67 27
    68 28
    69 9
    70 10
    71 11
    72 12
    73 9
    74 10
    75 11
    76 12
    77 6
    78 6
    79 7
    80 7
    81 10
    82 9
    83 12
    84 11];
