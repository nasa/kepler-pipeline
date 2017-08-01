function [alpha delta u v R RINV p un q vn] = arffi_wcs_nonlinear_raw_version_from_tom(testObject, motionPolyStruct)%motionPolyFile)
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

    %simple_wcs
    %
    %

%     %this array contains all the paths that I could find to where the motion
%     %polynomial structs and the map files are stored
%     paths =  {'/path/to/q0/pipeline_results/q0-for-public-2010-ksop435/lc/', ...
%         '/path/to/q1/pipeline_results/q1_archive_to_dmc_ksop435/lc/', ...
%         '/path/to/q2/pipeline_results/q2_archive_ksop516/lc/', ...
%         '/path/to/q3/pipeline_results/q3_archive_ksop400/lc/', ...
%         '/path/to/q4/pipeline_results/q4_archive_ksop479/lc/', ...
%         '/path/to/q5/pipeline_results/q5_archive_ksop568/lc/with-mpe/', ...
%         '/path/to/q6/pipeline_results/q6_archive_ksop652/lc/with-mpe/', ...
%         '/path/to/q7/pipeline_results/q7_archive_ksop752/lc/mpe_true/', ...
%         '/path/to/q8/pipeline_results/q8_archive_ksop836/lc/mpe_false/'};
% 
%     %this array contains the names of the files which map where to correct
%     %motion polynomials are stored
%     filenames = {'Q0_LC_KSOP-435_pa-task-to-modout-map.csv', ...
%         'Q1_KSOP435_LC_pa-task-to-modout-map.csv', ...
%         'Q2_KSOP516_LC_pa-task-to-mod-out-map.csv', ...
%         'Q3_KSOP400_LC-pa-task-to-mod-out-map.csv', ...
%         'Q4_KSOP479_LC_pa-task-to-mod-out-map.csv', ...
%         'Q5_LC_KSOP568_with-mpe_pa-task-to-mod-out-map.csv'...
%         'Q6_KSOP652_LC_with-mpe_pa-task-to-mod-out-map.csv', ...
%         'Q7_KSOP752_LC_pa_mpe-task-to-modout-map.csv', ...
%         'q8_ksop836_lc_pa-task-to-mod-out-map.csv'};
% 
%     %here is where the channel and quarter are given
%     channel = 41;
%     quarter = 5;
%     csciName = 'pa'; %motion polynomials are in pa
%     paTaskFilePath = char(paths(quarter + 1));
%     taskMappingFilename = char(filenames(quarter + 1));

%     %this line gives the correct path to the struct which contains motion
%     %polynomials
%     channelDir = get_taskfiles_from_modout(taskMappingFilename,...
%         csciName,channel,paTaskFilePath);
% 
%     paStructName = strcat(paTaskFilePath,channelDir,'/pa_state.mat');
%     %load the struct
%     load(char(paStructName), 'motionPolyStruct')

%     mps = load(motionPolyFile, 'motionPolyStruct');
%     motionPolyStruct = mps.motionPolyStruct;

    %define the module, output and date of the FFI which needs to have
    %header keywords
%     module = 13;
%     output = 1;
    mjd = 55370.6850;

    %find the motion polynomial closest in time to the FFI
    % this can be changed when motion polynomials are calculated 
    %for FFIs
    diffTimes = abs(mjd-[motionPolyStruct.mjdMidTime]);
    structInd = find(diffTimes == min(diffTimes));

    %define the coarseness of the grid
    %currently evaluates the motion polynomial every 20 pixels
    ustep = 20;
    vstep = 20;
    %define regions where the motion polynomial will be evaluated
    %u are pixels going to the 'x' cartesian direction and v in the 'y'
    %direction
    upix = 13:ustep:1100; %<- column
    vpix = 21:vstep:1044; %<- row

    %find the central pixel of the mod/out -> this will be our reference
    %pixel -> used for CRPIX1 and CRPIX2 in the FITS header
    %it doesn't have to be exactly in the centre
    ucent = floor(length(upix)/2);
    vcent = floor(length(vpix)/2);

    totalLength = length(upix) * length(vpix);

    u = zeros(totalLength,1);
    v = zeros(totalLength,1);
    alpha = zeros(totalLength,1);
    delta = zeros(totalLength,1);
    p = zeros(totalLength,1);
    q = zeros(totalLength,1);


    %loop to evaluate the motion polynomial at each point in u and v
    %alpha and delta are the ra and dec
    fcConstants = convert_fc_constants_java_2_struct();
    k = 0;
    for i = 1:length(vpix);
        for j = 1:length(upix);
            k = k + 1;
            u(k) = upix(j);
            v(k) = vpix(i);
            [alpha(k), delta(k)] = invert_motion_polynomial(vpix(i),upix(j),...
                motionPolyStruct(structInd),zeros(2,2),fcConstants);
        end
    end

    %centInd is the array index at the central pixel
    %used for CRPIX1, CRPIX2, CRVAL1 and CRVAL2
    centInd = find(u == upix(ucent) & v == vpix(vcent));

    %set the middle of the u,v plane to be at the reference pixel
    un = u - u(centInd);
    vn = v - v(centInd);

    %function performs the projection from spherical geometry to plane
    %projection coordinates, known as intermediate world coordinate in the
    %literature
    [xn,yn] = doproj(testObject,alpha,delta,centInd);

    %guess the intial values of the fit between un,vn and xn,yn
    yscale =  (yn(max(find(un == 0))) - yn(min(find(un == 0)))) / (vn(max(find(un == 0)))-vn(min(find(un == 0))));
    xscale =  (xn(max(find(vn == 0))) - xn(min(find(vn == 0)))) / (un(max(find(vn == 0)))-un(min(find(vn == 0))));

    %the array with the inital guess
    CO = [xscale 0.0 0.0 yscale ...
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 ...
        0.0 0.0 0.0 0.0 0.0 0.0 0.0];

    %put the values into a single array which is read by the fitting function
    t = [un vn xn yn];
    %define option for the fit
    options = optimset('MaxIter',50000.,'TolX',1e-7',...
        'MaxFunEvals',50000000.,'TolFun',1e-7);
    %perform the fit
    R = fminsearch(@(finp) funct(finp,t),CO,options);
    R(8:11) = 0.0;
    R(15:18) = 0.0;

    %this is the CD matrix used the in fits headers
    cd = [R(1) R(2);R(3) R(4)];

    %xcd and ycd are used for determining the goodness of the fit
    %(max(sqrt((xn-xcd).*(xn-xcd) + (yn-ycd).*(yn-ycd))) * 3600) gives the 
    %maximum deviation of the fit from the motion polynomials in arcsec
    %pcd = un + evalhigh(un,vn,R(5:11));
    %qcd = vn + evalhigh(un,vn,R(12:18));

    %xcd = cd(1,1).*pcd + cd(1,2).*qcd;
    %ycd = cd(2,1).*pcd + cd(2,2).*qcd;

    %we now need to perform the inverse fit so we can go back to u,v from x,y
    %calculate the inverse cd matrix
    invcd = inv(cd);

    %calculate the linear term to map xn,yn to un,vn
    p = invcd(1,1).*xn + invcd(1,2).*yn;
    q = invcd(2,1).*xn + invcd(2,2).*yn;

    D = -R;
    D(1:4) = 0.0;
    t = [un vn xn yn p q];
    options = optimset('TolX',1e-4','TolFun',1e-4);
    %the inverse fit
    RINV = fminsearch(@(finp) invfunct(finp,t),D,options);
    RINV(8:11) = 0.0;
    RINV(15:18) = 0.0;

    %check the difference between what we put in and what we get out using 
    % max(sqrt((un-uu).*(un-uu) + (vn-vv).*(vn-vv))) where the answer is in
    % pixels
    %uu = p + RINV(1).*p + RINV(2).*q + evalhigh(p,q,RINV(5:11));
    %vv = q + RINV(3).*p + RINV(4).*q + evalhigh(p,q,RINV(12:18));

    % %print out the FITS keywords 
    % fprintf('CTYPE1 = RA---TAN-SIP \n')
    % fprintf('CTYPE2 = DEC--TAN-SIP\n')
    % fprintf('CRVAL1 = %s \n',alpha(centInd))
    % fprintf('CRVAL2 = %s \n',delta(centInd))
    % fprintf('CRPIX1 = %i \n',u(centInd))
    % fprintf('CRPIX2 = %i \n',v(centInd))
    % 
    % fprintf('CD1_1 = %s \n',R(1))
    % fprintf('CD1_2 = %s \n',R(2))
    % fprintf('CD2_1 = %s \n',R(3))
    % fprintf('CD2_2 = %s \n',R(4))
    % 
    % fprintf('A_ORDER = %i \n',2)
    % fprintf('B_ORDER = %i \n',2)
    % fprintf('A_2_0 = %s \n',R(5))
    % fprintf('A_0_2 = %s \n',R(6))
    % fprintf('A_1_1 = %s \n',R(7))
    % fprintf('B_2_0 = %s \n',R(12))
    % fprintf('B_0_2 = %s \n',R(13))
    % fprintf('B_1_1 = %s \n',R(14))
    % fprintf('A_DMAX = %s \n',max(p-un))
    % fprintf('B_DMAX = %s \n',max(q-vn))
    % 
    % fprintf('AP_ORDER = %i \n',2)
    % fprintf('BP_ORDER = %i \n',2)
    % fprintf('AP_1_0 = %s \n',RINV(1))
    % fprintf('AP_0_1 = %s \n',RINV(2))
    % fprintf('BP_1_0 = %s \n',RINV(3))
    % fprintf('BP_0_1 = %s \n',RINV(4))
    % fprintf('AP_2_0 = %s \n',RINV(5))
    % fprintf('AP_0_2 = %s \n',RINV(6))
    % fprintf('AP_1_1 = %s \n',RINV(7))
    % fprintf('BP_2_0 = %s \n',RINV(12))
    % fprintf('BP_0_2 = %s \n',RINV(13))
    % fprintf('BP_1_1 = %s \n',RINV(14))
return

function sumsq = funct(C,uvxypq)
    sumsq = 0.0;
    ac = C(5:11);
    bc = C(12:18);
    val1 = evalhigh(uvxypq(:,1),uvxypq(:,2),ac);
    val2 = evalhigh(uvxypq(:,1),uvxypq(:,2),bc);
    pvar = uvxypq(:,1) + val1;
    qvar = uvxypq(:,2) + val2;
    %pvar = uvxypq(:,1);
    %qvar = uvxypq(:,2);
    xresid = uvxypq(:,3) - C(1).* pvar - C(2) .* qvar;
    yresid = uvxypq(:,4) - C(3) .* pvar - C(4) .* qvar;
    sumsq = sumsq  + (xresid .* xresid) + (yresid .* yresid);
    sumsq = sum(sumsq(isfinite(sumsq)));
end

function sumsq = invfunct(D,uvxypq)
    n = length(uvxypq);
    sumsq = 0.0;
    apc = D(5:11);
    bpc = D(12:18);
    uresid = uvxypq(:,1) - uvxypq(:,5)- D(1).* uvxypq(:,5) - D(2).* uvxypq(:,6) - evalhigh(uvxypq(:,5),uvxypq(:,6),apc);
    vresid = uvxypq(:,2) - uvxypq(:,6)- D(3).* uvxypq(:,5) - D(4).* uvxypq(:,6) - evalhigh(uvxypq(:,5),uvxypq(:,6),bpc);
    sumsq = sumsq  + uresid.*uresid + vresid.*vresid;
    sumsq = sum(sumsq);
end

function val = evalhigh(x,y, coeff)
%this function evaluates the higher order coefficients, currently only
%%evaluates a second order 2D polynomial

%val = 0.0;
%val = (coeff(1) .* x .* x) + (coeff(2) .* y .* y) + (coeff(3) .* x .*y) + ... 
%(coeff(4) .* x .* x .* x) + (coeff(5) .* y .* y .* y) + ... 
%(coeff(6) .* x .* x .* y) + (coeff(7) .* x .* y .* y);
val = (coeff(1) .* x .* x) + (coeff(2) .* y .* y) + (coeff(3) .* x .*y);
end

n [xn,yn] = doproj(alpha_deg,delta_deg,centInd)
%this function currently doesn't do anything, it just calls 
%projPlaneFromSky

[xn,yn] = projPlaneFromSky(alpha_deg,delta_deg,centInd);
end

function [i_deg,j_deg] = projPlaneFromSky(alpha_deg,delta_deg,centInd)
%this function takes as inputs the ra and dec in degrees and the array
%index which specifies the reference pixel
%the outputs are the projection plan coordinates used for fitting

[phi_rad,theta_rad] = relSkyFromSky(alpha_deg,delta_deg,centInd);
[i_deg,j_deg] = projPlaneFromRelSky(theta_rad,phi_rad);

end

function radians = degToRad(degrees)
    radians = degrees .* (pi/180.);
end

function degrees = radToDeg(radians)
    degrees = radians .* (180./pi);
end

function [phi_rad,theta_rad] = relSkyFromSky(alpha_deg,delta_deg,centInd)
    %this function converts from ra dec coords in degrees to relative sky
    %coordinates.
    %The calculation performs a rotation in spherical coordinates using Euler 
    %angles. The equations are taken from Section 2.3 of Calabretta and 
    %Greisen 2002, equation 5

    alpha_rad = degToRad(alpha_deg);
    delta_rad = degToRad(delta_deg);

    lonpole = 180.; %if CRVAL1 == 90, lonpole = 0 -> not an issue for Kepler
    phiPole_rad = degToRad(lonpole);

    alpha0 = alpha_rad(centInd);
    delta0 = delta_rad(centInd);

    sinD = sin(delta_rad);
    cosD = cos(delta_rad);
    sinD0 = sin(delta0);
    cosD0 = cos(delta0);
    sinADiff = sin(alpha_rad - alpha0);
    cosADiff = cos(alpha_rad - alpha0);

    a = sinD.*cosD0 - cosD.*sinD0.*cosADiff;
    b = -cosD.*sinADiff;

    phi_rad = phiPole_rad +atan2(b,a);
    theta_rad = asin(sinD.*sinD0 + cosD.*cosD0.*cosADiff);
end

function [i_deg,j_deg] = projPlaneFromRelSky(theta_rad,phi_rad)
    %fuction converts from tangent plane spherical coordinates to tangent plane
    %cartesian coordinates.
    %The equations are taken from Equs. 12, 13 and 54 of Calabretta and 
    %Greisen 2002

    %the i and j used here as called x and y in the paper but I found this
    %confusing when talking about this and CCD physical coords.

    Rtheta = radToDeg(1./tan(theta_rad));

    i_deg = Rtheta .* sin(phi_rad);
    j_deg = -Rtheta .* cos(phi_rad);
end

