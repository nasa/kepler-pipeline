function ccd = spill_saturation(ccdObject, ccd, numExposures)
%function ccd = spillsat(ccd, wellCapacity, saturationSpillUpFraction)
%
% spills excess charge along columns of ccd image ccd (dimension 2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function Name: spillsat
%
% Modification History - This can be managed by a revision control system
%
% Software level: Research Code
%
% Description: Takes excess charge in pixels over a certain saturation
% value and spreads it up and down the column of the array
%
% Input: ccd:  the ccd array with (possibly) over-saturated pixels
%        wellCapacity:  the maximum 'allowed' value of a  pixel
%
% Output: ccd:  the ccd array with properly 'spilled' charge
%
% Question:  what happens when it 'spills' off the edge of the array?
%
% Notes/errata: "Up" is toward 1 and "Down" is toward mccd
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

if nargin < 3
	numExposures = 1;
end

% wellCapacity = get(ccdObject.runParamsClass, 'wellCapacity')*numExposures;
wellCapacity = get(ccdObject.electronsToAduObject, 'maxElectronsPerExposure')*numExposures;
saturationSpillUpFraction = get(ccdObject.runParamsClass, 'saturationSpillUpFraction');


% number of rows in the array
mccd = size(ccd,1);

% Find row (isat) and column (jsat) of all saturated pixels
[isat, jsat] = find(ccd > wellCapacity);

% Do the biggest baddest saturatedest pixels first
% Find absolute index
ksat = sub2ind(size(ccd),isat,jsat);

% Sort
[tmp,ksort] = sort(ccd(ksat));

% Re-order isat, jsat and the rest is automatic.
isat = isat(ksort(end:-1:1));
jsat = jsat(ksort(end:-1:1));

% how many were over saturation?
nsat = length(isat);

% Loop over each saturated pixel one at a time
for k = 1:nsat
    
    % spill sat charge up column until depleted
    satchargeup          = (ccd(isat(k),jsat(k))-wellCapacity) *      saturationSpillUpFraction;  % spill half of excess up column
    satchargedn          = (ccd(isat(k),jsat(k))-wellCapacity) * (1 - saturationSpillUpFraction); % spill half of excess down column

    % Set the over-saturated pixel to the saturation value
    ccd(isat(k),jsat(k)) = wellCapacity;
    
    % for ease of use set j = jsat(k) and i = isat(k)
    j = jsat(k);
    i = isat(k);
    
    % While you're still on the row (i>1) and there is charge left to spill
    % (satchargeup > 0) keep 'spilling'
    while i > 1 && satchargeup > 0 
    
        % Next pixel 'up'
        i = i - 1;
        
        % spill only if charge 'room' is available
        % the amount is nonzero only if ccd(i,j) < wellCapacity.  That term
        % behaves as a boolean '0 or 1' in the multiplication below.
        chargetospill  = (wellCapacity - ccd(i,j)) * (ccd(i,j) < wellCapacity);
       
        % Either spill the amount of 'room' available or spill all you have
        % left to spill...whichever is smaller
        chargetospill  = min(chargetospill,satchargeup);
        
        % Add the charge to the ccd pixel
        ccd(i,j) = ccd(i,j)    + chargetospill;
        
        % Reduce the charge left to spill by the amount spilled
        satchargeup    = satchargeup - chargetospill;
    end
    
    % again for ease of use set j = jsat(k) and i = isat(k)
    j = jsat(k);
    i = isat(k);
    
    % While you're still on the row (i < mccd) and there is charge left to spill
    % (satchargedn > 0) keep 'spilling'
    while i < mccd && satchargedn > 0

        % Next pixel 'down'
        i = i + 1;
        
        % spill only if charge 'room' is available
        % the amount is nonzero only if ccd(i,j) < wellCapacity.  That term
        % behaves as a boolean '0 or 1' in the multiplication below.
        chargetospill  = (wellCapacity - ccd(i,j)) * (ccd(i,j) < wellCapacity);
        
        % Either spill the amount of 'room' available or spill all you have
        % left to spill...whichever is smaller
        chargetospill  = min(chargetospill, satchargedn);
        
        % Add the charge to the ccd pixel
        ccd(i,j) = ccd(i,j)    + chargetospill;
        
        % Reduce the charge left to spill by the amount spilled
        satchargedn    = satchargedn - chargetospill;
    end
    
end % loop over all pixels in excess of max charge level.

return
