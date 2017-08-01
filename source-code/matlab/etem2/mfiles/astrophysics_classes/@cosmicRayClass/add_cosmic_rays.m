function ccd = add_cosmic_rays(cosmicRayObject, ccd, time_interval, kcare)
%function ccd = addcosmicrays(ccd, time_interval, kcare, gcm_filename, run_params)
%
% adds cosmic rays to a ccd during a time interval time_interval (sec)
% if kcare is passed, cosmic rays are constrained to hit only the pixels
% specified by index kcare
%
% kcare must be defined in the context of the size of "ccd" so that functions
% like sub2ind and ind2sub address the i and j index of ccd appropriately.
%
% if "run_params" is unspecified, default values of pixelwidth, gcmrate,
% and min_gcm_to_consider are used.  Otherwise these values and the
% gcm_filename are pulled from the parameter structure.
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

% Size of the ccd: rows & columns
[Rccd,Cccd] = size(ccd);

persistent ppcdfgcm gcmshapes nshapes mgcm mgcmh gcmrate pixelwidth nlibrary gcmcharge_library

pixelwidth          = get(cosmicRayObject.runParamsClass, 'pixelWidth')*1e-4;          % cm  % SIZE OF A PIXEL is 27x27um
gcmrate             = cosmicRayObject.gcmRate;             % 5 cosmic rays per cm^2 per second^2 (cm^-2 s^-2)
min_gcm_to_consider = cosmicRayObject.minGcmCount; % 1 e-
gcm_filename        = [cosmicRayObject.cosmicRayLocation filesep cosmicRayObject.cosmicRayFilename];

% "fill in" the persistent variables ONCE.
if isempty(ppcdfgcm)

    % distribution of cosmic ray charge deposited per hit
    [gcrval, gcrfrac] = gcrpdf;

    % Normalize & make piecewise poly cdf
	ppcdfgcm = mkppcdf(gcrval,gcrfrac);

    %load the cosmic ray 'shapes'
	load(gcm_filename,'gcmshapes');  %gcmshapes is 13x13x6097 and represents
                                     % on what pixels a CR deposits charge.

    % number of cosmic ray shape realizations
	nshapes = size(gcmshapes,3); %#ok

    % aperture size for cosmic ray shapes (diameter)
    mgcm = size(gcmshapes,1);  % nominally this is 13

    % Half-aperture size (radius)
	mgcmh = (mgcm-1)/2;  % so nominally this is 6

    % reverse-engineer the "random" charge based upon a random location on the cdf
    nlibrary = 10000; % number of hits in library of total charge
    gcmcharge_library = ppcdfinv(ppcdfgcm, rand(nlibrary,1));


end

% If you want cosmic rays on ALL pixels on the ccd
if isempty(kcare)
    
    % How many cosmic rays will hit the ccd in the allotted time?
	nhits = round(randp_tfu(gcmrate * pixelwidth^2 * Rccd * Cccd * time_interval));

    % Select a random row & column to get hit.
	ihits = ceil(rand(nhits,1) * Rccd);
	jhits = ceil(rand(nhits,1) * Cccd);
    
else % Only put cosmic rays on the "pixels of interest"
    
	% How many cosmic rays will hit the ccd in the allotted time?
	nhits = round(randp_tfu(gcmrate * pixelwidth^2 * length(kcare) * time_interval));

    % Select a random index to get hit
    khits = kcare(ceil(rand(nhits,1) * length(kcare)));
    
    % convert the index to a row & column
	[ihits, jhits] = ind2sub([Rccd Cccd], khits);
end

if nhits == 0
    return;
end

% Choose a random shape index for each hit
krays = ceil(rand(nhits,1)*nshapes);

% reverse-engineer the "random" charge based upon a random location on the cdf
kcharge = ceil(rand(nhits,1)*nlibrary);
%gcmcharge = ppcdfinv(ppcdfgcm, rand(nhits,1));

% gcm will be the product of the cosmic ray charge and the charge "mask"
gcm = repmat(reshape(gcmcharge_library(kcharge),[1,1,nhits]),[mgcm,mgcm,1]).*gcmshapes(:,:,krays);
%gcm = repmat(reshape(gcmcharge,[1,1,nhits]),[mgcm,mgcm,1]).*gcmshapes(:,:,krays);

% jj is a 13x13 matrix with columns of integers from -6 to 6
% ii is a 13x13 matrix with rows    of integers from -6 to 6
[jj,ii] = meshgrid(-mgcmh:mgcmh);

% ii and jj get offset by the "ihits" and "jhits" previously computed
% iccd and jccd now index the ccd row/column of the 13x13 mask where cosmic
% ray charge will be deposited onto the ccd "image"
iccd  = repmat(ii,[1,1,nhits])+repmat(reshape(ihits,[1,1,nhits]),[mgcm,mgcm,1]);
jccd  = repmat(jj,[1,1,nhits])+repmat(reshape(jhits,[1,1,nhits]),[mgcm,mgcm,1]);

% Make them columns in case they are rows...
iccd = iccd(:);
jccd = jccd(:);
gcm  = gcm(:);

% Eliminate small charge distributions because they're not worth modeling
% also only keep those with valid locations on active pixels
gcm = round(gcm);
ikeep = find(gcm > min_gcm_to_consider);
ikeep = ikeep(find(iccd(ikeep)>=1));
ikeep = ikeep(find(jccd(ikeep)>=1));
ikeep = ikeep(find(iccd(ikeep)<=Rccd));
ikeep = ikeep(find(jccd(ikeep)<=Cccd));

gcm = gcm(ikeep);
iccd = iccd(ikeep);
jccd = jccd(ikeep);

clear ikeep

% This is a mex-file that Jon has.  The code later on does the same thing.
% ccd = addpix(ccd,gcm(:),iccd(:),jccd(:)); %return

% Compute the absolute index into the ccd
% Can't use "sub2ind" because some are out of range due to the -6 to +6 above
kccd = iccd + (jccd-1) * Rccd;

% kk goes from 1 to the min of [1e6,length(kccd)]; either 1e6 or all of kccd
kk = 1:min(1e6, length(kccd));

% While the last element of kk <= length(kccd) 
while kk(end) <= length(kccd)  % while loop breaks when kk is empty.
    
    % redefine kk if needed (technically only needed for last loop)
    kk = kk(1):min(kk(end),length(kccd));
    
    % take the first million (or the last length(kccd)) entries
    kccdi = kccd(kk);
    gcmi  = gcm(kk);
    iccdi = iccd(kk);
    jccdi = jccd(kk);
    
    % Now the remaining indices (kccdi gcmi) are valid ccd locations &
    % charge values to be deposited (added to the image).
    
    % kccdi is an aggregation of 13x13 index 'clumps' randomly distributed
    % across the ccd.  Sorting probably helps with the 'while' statement.
    [kccdi, is] = sort(kccdi);  
    % re-order gmci according to the new sort: speeds up "unique"ish calls below
    gcmi = gcmi(is);
    
    % ii is the indices of NOT duplicate kccdi values (i.e. only 1 hit on that
    % pixel OR the first ONLY of duplicates) 1e10 ensures last element, if
    % repeated, will get "found".
    ii = find(diff([kccdi; 1e10])~=0);  % faster than 'unique' if sorted
    %[tmp,ii]=unique(kccdi);  THE PREVIOUS LINE BETTER EQUAL THIS ONE!
    
    while ~isempty(ii)
        % Add the gcr 'charge' from those hits
        ccd(kccdi(ii)) = ccd(kccdi(ii)) + gcmi(ii);
        
        % Clear the ones that have been added
        kccdi(ii) = [];
        gcmi(ii)  = [];
        
        % Repeat; find the "unique" set.  I had to add the trailing 1e10 in
        % the event that the last element is a repeated one.
        % This makes sure kccdi is empty when this while loop ends
        ii = find(diff([kccdi; 1e10])~=0);
        %[tmp,ii]=unique(kccdi); THE PREVIOUS LINE IS A "QUICK & DIRTY" UNIQUE
    end

    % Do the next million cosmic ray pixels.  Add 1e6 to indices; trimed to
    % size as needed on the last loop immediately after the outer 'while' loop.
    kk = kk + 1e6;
end

return