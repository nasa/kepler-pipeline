%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function haloAp = make_halo(aperture)
%
% makes the halo aperture out of an input aperture
% A pixel is contained in the halo aperture if it or any of 9 neighbors 
% are on in the optimal aperture.
%
%   inputs: 
%       aperture input aperture from which to generate halo ap
%
%   output: 
%       haloAp halo aperture
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
function haloAp = make_halo(aperture)
% create image of the right size
haloAp = zeros(size(aperture, 1)+2, size(aperture, 2)+2);
% imbed the input aperture in the halo as a start to the halo ap
haloAp(2:end-1, 2:end-1) = aperture;
% make a copy of the halo aperture so we can appropriately test each pixel
bigAp = haloAp; 
% get the linear dimensions of the halo ap
ni = size(haloAp, 1);
nj = size(haloAp, 2);
% loop through for each pixel
for i=1:ni
    for j=1:nj
        if haloAp(i,j) == 0 % if the pixel's not already turned on
            % set im, ip, jm, jp to be indices of neighboring pixels
            % truncated to legal values
            im = i-1; 
            if im < 1 
                im = 1; 
            end
            ip = i+1; 
            if ip > ni 
                ip = ni; 
            end
            jm = j-1; 
            if jm < 1 
                jm = 1; 
            end
            jp = j+1; 
            if jp > nj 
                jp = nj; 
            end
            
            % test the current pixel by doing logical or with neighbors
            haloAp(i,j) = bigAp(im, jm) | bigAp(i, jm) ...
                | bigAp(ip, jm) | bigAp(im, j) | bigAp(ip, j) ...
                | bigAp(im, jp) | bigAp(i, jp) | bigAp(ip, jp);
        end
    end
end
