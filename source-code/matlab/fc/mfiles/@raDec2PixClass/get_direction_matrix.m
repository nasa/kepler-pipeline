function [dcm11  dcm12  dcm13  dcm21  dcm22  dcm23  dcm31  dcm32  dcm33 ... 
          dcm11c dcm12c dcm13c dcm21c dcm22c dcm23c dcm31c dcm32c dcm33c ...
          nGmsInRange chipTrans chipOffset] = get_direction_matrix( ...
               raDec2PixObject, julianTime, seasonInt, drot1, rot2, rot3)
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
           

    % Determine the season and roll offset based on the julianTime.
    %
    mjds = julianTime - raDec2PixObject.mjdOffset;
    rollTimeModel = get(raDec2PixObject, 'rollTimeModel');
    rollTimeObject = rollTimeClass(rollTimeModel);
    rollTimeData = get_roll_time(rollTimeObject, mjds);
    rollOffset = rollTimeData(:, 2);
    seasonInt = rollTimeData(:, 3);

    deg2rad = pi/180.0;

    % Calculate the Direction Cosine Matrix to transform from RA and Dec to FPA coordinates 
    %
    rot1 = raDec2PixObject.NOMINAL_CLOCKING_ANGLE + rollOffset + seasonInt * 90.0;
    
    if size(rot1, 1) == size(drot1, 1) && size(rot1, 2) == size(drot1, 2) % same size
        rot1 = rot1 + drot1;  % add optional offset in X'-axis rotation
    elseif size(rot1, 1) == size(drot1, 2) && size(rot1, 2) == size(drot1, 1) % same size, transposed
        rot1 = rot1' + drot1;
    else
        error('MATLAB:@raDec2PixClass:get_direction_matrix %s %d %d %d %d', 'size error in rot1', size(rot1, 1), size(rot1, 2), size(drot1, 1), size(drot1, 2));
    end

    rot1 = rot1 + 180; % Need to account for 180 deg rotation of field due to imaging of mirror 
    
    rot1 = rem(rot1, 360); % make small if rot1 < -360 or rot1 > 360
    
    if length(rot1) ~= length(rot2) || length(rot1) ~= length(rot3)
        rot2 = repmat(rot2,size(rot1));
        rot3 = repmat(rot3,size(rot1));
    end
    
    srac  = sin(rot3*deg2rad); % sin phi 3 rotation 
    crac  = cos(rot3*deg2rad); % cos phi 
    sdec  = sin(rot2*deg2rad); % sin theta 2 rotation Note 2 rotation is negative of dec in right hand sense 
    cdec  = cos(rot2*deg2rad); % cos theta 
    srotc = sin(rot1*deg2rad); % sin psi 1 rotation 
    crotc = cos(rot1*deg2rad); % cos psi 

    % Extract the focal plane geometry constants from FC.  The quarter is
    %    calculated from the julian time.
    %
%     if doGetGeometry
%         [nGmsInRange chipTrans chipOffset] = get_geometry_constants(julianTime);
%     end
    geometryObject = geometryClass(get(raDec2PixObject, 'geometryModel'));

    %nGmsInRange = length(get(geometryObject, 'mjds'));
    %constants = get(geometryObject, 'constants');
    %for ii = 1:nGmsInRange
    %    chipTrans( :,:,ii) = reshape(constants(ii).array(  1:126), 3, 42)';
    %    chipOffset(:,:,ii) = reshape(constants(ii).array(127:252), 3, 42)';
    %end
    mjds = get(geometryObject, 'mjds');
    nGmsInRange = length(mjds);
    for ii = 1:nGmsInRange
        constants = get_geometry(geometryObject, mjds(ii));
        chipTrans( :,:,ii) = reshape(constants(  1:126), 3, 42)';
        chipOffset(:,:,ii) = reshape(constants(127:252), 3, 42)';
    end
    
    % 	dcm for a 3-2-1 rotation, Wertz p764
    dcm11 =  cdec.*crac;
    dcm12 =  cdec.*srac;
    dcm13 = -sdec;
    dcm21 = -crotc.*srac+srotc.*sdec.*crac;
    dcm22 =  crotc.*crac+srotc.*sdec.*srac;
    dcm23 =  srotc.*cdec;
    dcm31 =  srotc.*srac+crotc.*sdec.*crac;
    dcm32 = -srotc.*crac+crotc.*sdec.*srac;
    dcm33 =  crotc.*cdec;

    % 	Calculate dcm for each chip relative to center of FOV
    %
    nModules2 = raDec2PixObject.nModules * 2;
    dcm11c      = zeros(nModules2, nGmsInRange);
    dcm12c      = zeros(nModules2, nGmsInRange);
    dcm13c      = zeros(nModules2, nGmsInRange);
    dcm21c      = zeros(nModules2, nGmsInRange);
    dcm22c      = zeros(nModules2, nGmsInRange);
    dcm23c      = zeros(nModules2, nGmsInRange);
    dcm31c      = zeros(nModules2, nGmsInRange);
    dcm32c      = zeros(nModules2, nGmsInRange);
    dcm33c      = zeros(nModules2, nGmsInRange);

    for i=1:nModules2 % step through each chip
        srac  = sin(deg2rad*squeeze(chipTrans(i,1,:))); % sin phi 3 rotation 
        crac  = cos(deg2rad*squeeze(chipTrans(i,1,:))); % cos phi 
        sdec  = sin(deg2rad*squeeze(chipTrans(i,2,:))); % sin theta 2 rotation 
        cdec  = cos(deg2rad*squeeze(chipTrans(i,2,:))); % cos theta 
        srotc = sin(deg2rad*squeeze(chipTrans(i,3,:)+chipOffset(i,1,:))); % sin psi 1 rotation includes rotation offset 
        crotc = cos(deg2rad*squeeze(chipTrans(i,3,:)+chipOffset(i,1,:))); % cos psi 

        % dcm for a 3-2-1 rotation, Wertz p762 
        dcm11c(i,:) = cdec.*crac;
        dcm12c(i,:) = cdec.*srac;
        dcm13c(i,:) =-sdec;
        dcm21c(i,:) =-crotc.*srac + srotc.*sdec.*crac;
        dcm22c(i,:) = crotc.*crac + srotc.*sdec.*srac;
        dcm23c(i,:) = srotc.*cdec;
        dcm31c(i,:) = srotc.*srac + crotc.*sdec.*crac;
        dcm32c(i,:) =-srotc.*crac + crotc.*sdec.*srac;
        dcm33c(i,:) = crotc.*cdec;
    end
return
