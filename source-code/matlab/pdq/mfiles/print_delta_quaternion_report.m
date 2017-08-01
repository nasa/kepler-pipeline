% write a text report of delta quaternion computed so it can be imported into PDQ report
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
function print_delta_quaternion_report(pdqOutputStruct, pdqScienceObject)


computedPointing = pdqOutputStruct.attitudeSolution;


nominalPointing = cat(1, pdqOutputStruct.attitudeSolutionUncertaintyStruct.nominalPointing);

tweakInArcsec =  pdqOutputStruct.tweakInArcsec;

offsetInPixelUnitsAtEdgeOfFocalPlane =  pdqOutputStruct.offsetInPixelUnitsAtEdgeOfFocalPlane;


fid = fopen('PDQ_Timestamps_Report.txt', 'wt');

mjds = pdqOutputStruct.outputPdqTsData.cadenceTimes;
utcStrs = mjd_to_utc(mjds);



fprintf(fid, 'Timestamps in the reference pixel files received to date\n');
fprintf(fid, '|-------------------------------------------------------------------------|\n');
fprintf(fid, '| Cadence | day of year |      MJD        |                 UTC           |\n');
fprintf(fid, '|-------------------------------------------------------------------------|\n');

for j =1:length(mjds)

    firstDayOfYear = datenum(['1-1-' utcStrs(j,8:11)]);
    lastDayOfYear = datenum(['12-31-' utcStrs(j,8:11)]);
    daysInYear = lastDayOfYear - firstDayOfYear +1 ;

    currentDayOfYear =  datenum(utcStrs(j,1:11));
    dayOfYear = fix(currentDayOfYear - firstDayOfYear + 1);

    fprintf(fid, '|   %3d   |   %3d/%3d   | %15.9f |   %s      |\n', j, dayOfYear, daysInYear,  mjds(j), utcStrs(j,:));
end

fprintf(fid, '|-------------------------------------------------------------------------|\n');

fprintf(fid, '\n\n');
fclose (fid);



fid = fopen('PDQ_Quaternion_Report.txt', 'wt');

mjds = cat(1,pdqOutputStruct.attitudeSolutionUncertaintyStruct.cadenceTime);
utcStrs = mjd_to_utc(mjds);



fprintf(fid, 'Timestamps in the latest contact reference pixel file\n');
fprintf(fid, '|-------------------------------------------------------------------------|\n');
fprintf(fid, '| Cadence | day of year |      MJD        |                 UTC           |\n');
fprintf(fid, '|-------------------------------------------------------------------------|\n');

for j =1:length(mjds)

    firstDayOfYear = datenum(['1-1-' utcStrs(j,8:11)]);
    lastDayOfYear = datenum(['12-31-' utcStrs(j,8:11)]);
    daysInYear = lastDayOfYear - firstDayOfYear +1 ;

    currentDayOfYear =  datenum(utcStrs(j,1:11));
    dayOfYear = fix(currentDayOfYear - firstDayOfYear + 1);

    fprintf(fid, '|   %3d   |   %3d/%3d   | %15.9f |   %s      |\n', j, dayOfYear, daysInYear,  mjds(j), utcStrs(j,:));
end

fprintf(fid, '|-------------------------------------------------------------------------|\n');

fprintf(fid, '\n\n');


fprintf(fid, ' Delta Quaternion                                 \n');


fprintf(fid, '|-----------------------------------------------------------------------------|\n');
fprintf(fid, '| Cadence |       q1       |       q2       |      q3        |     q4         |\n');
fprintf(fid, '|-----------------------------------------------------------------------------|\n');


for j=1:length(pdqOutputStruct.attitudeAdjustments)

    quaternion = pdqOutputStruct.attitudeAdjustments(j).quaternion(:);


    fprintf(fid, '| %3d     | %+12.7e | %+12.7e | %+12.7e | %+12.7e |\n', ...
        j, quaternion(1), quaternion(2), quaternion(3),quaternion(4) );

end
fprintf(fid, '|-----------------------------------------------------------------------------|\n');
fprintf(fid, '\n\n');



fprintf(fid, ' Rotation angle represented by delta quaternion\n');
fprintf(fid, ' ----------------------------------------------\n');
% a brief description of what this rotation angle means or represents...
fprintf(fid, ' The delta quaternion dQ is a unit quaternion and can be represented in terms of an \n');
fprintf(fid, ' angle  ''theta'' and a unit vector ''U'' as                                         \n');
fprintf(fid, ' dQ = cos(theta) + U sin(theta)                                                      \n');
fprintf(fid, ' Since this delta quaternion dQ is applied as a correction to the computed attitude\n');
fprintf(fid, ' quaternion to reorient the spacecraft along the nominal attitude, we can think of \n');
fprintf(fid, ' this angle theta as representing the required rotation of the photometer frame of \n');
fprintf(fid, ' reference by the angle theta.\n\n');

fprintf(fid, '|-----------------------------------------------------------|\n');
fprintf(fid, '| Cadence    |         Rotation angle  in arcsec            |\n');
fprintf(fid, '|-----------------------------------------------------------|\n');


for j=1:length(pdqOutputStruct.attitudeAdjustments)

    % U is a unit vector, Q represents the vector part of a quaternion comprising the first 3
    % elements
    % quaternion = q4 + Q = cos(alpha/2) + U*sin(alpha/2);


    rotationAngle = acos(pdqOutputStruct.attitudeAdjustments(j).quaternion(4))*2*rad2deg(3600);

    fprintf(fid, '| %3d        |           %12.8f                       |\n', ...
        j, rotationAngle );

end
fprintf(fid, '|-----------------------------------------------------------|\n');
fprintf(fid, '\n\n');


fprintf(fid, ' Maximum attitude residual in pixels                         \n');

fprintf(fid, ' ----------------------------------------------\n');
% a brief description of what this totation angle means or represents...
fprintf(fid, ' The maximum attitude residual in pixel units is computed for each time stamp as follows:\n');
fprintf(fid, ' 1. Define artificial stars on the extreme corners of the focal plane and map these\n');
fprintf(fid, '    stars onto sky using pix2RaDec and nominal attitude.                              \n');
fprintf(fid, ' 2. Using raDec2Pix and the computed attitude, map these artificial stars back onto \n');
fprintf(fid, '    the focal plane. \n');
fprintf(fid, ' 3. Compute the distance each ''star'' moved in row, column space and obtain the maximum \n');
fprintf(fid, '    distance moved as the maximum attitude residual in pixel units.\n\n');


fprintf(fid, '|-----------------------------------------------------------|\n');
fprintf(fid, '| Cadence    |         Max attitude residual in pixels      |\n');
fprintf(fid, '|-----------------------------------------------------------|\n');


newCadenceIndex = get_new_cadence_index_in_sorted_cadence_times(pdqScienceObject);


for j=1:length(newCadenceIndex)

    fprintf(fid, '| %3d        |           %12.8f                       |\n', ...
        j, pdqOutputStruct.outputPdqTsData.maxAttitudeResidualInPixels.values(newCadenceIndex(j)) );

end
fprintf(fid, '|-----------------------------------------------------------|\n');


fprintf(fid, '\n\n');






% % % repeat mjd, UTC timestamp information here....
% %
% fprintf(fid, 'Timestamps in the latest contact reference pixel file\n');
% fprintf(fid, '|-------------------------------------------------------------------------|\n');
% fprintf(fid, '| Cadence | day of year |      MJD        |                 UTC           |\n');
% fprintf(fid, '|-------------------------------------------------------------------------|\n');
%
% for j =1:length(mjds)
%
%     firstDayOfYear = datenum(['1-1-' utcStrs(j,8:11)]);
%     lastDayOfYear = datenum(['12-31-' utcStrs(j,8:11)]);
%     daysInYear = lastDayOfYear - firstDayOfYear +1 ;
%
%     currentDayOfYear =  datenum(utcStrs(j,1:11));
%     dayOfYear = fix(currentDayOfYear - firstDayOfYear + 1);
%
%     fprintf(fid, '|    %3d   |   %3d/%3d   | %15.9f |   %s      |\n', j, dayOfYear, daysInYear,  mjds(j), utcStrs(j,:));
% end
%
% fprintf(fid, '|-------------------------------------------------------------------------|\n');
% fprintf(fid, '\n\n');
%



fprintf(fid, ' Computed Pointing (Spacecraft Attitude Solution)   (in degrees) \n');
fprintf(fid, '|----------------------------------------------------------------|\n');
fprintf(fid, '| Cadence |   RA            |        DEC      |       ROLL       |\n');
fprintf(fid, '|----------------------------------------------------------------|\n');

nCadences = size(computedPointing,1);
for j=1:nCadences

    ra = computedPointing(j,1);
    dec = computedPointing(j,2);
    roll = computedPointing(j,3);

    fprintf(fid, '| %3d     |   %12.8f  |  %12.8f   | %12.8f     |\n', j, ra, dec, roll );

end

fprintf(fid, '|----------------------------------------------------------------|\n');
fprintf(fid, '\n\n');



fprintf(fid, ' Nominal Pointing (Expected Spacecraft Attitude)    (in degrees)\n');
fprintf(fid, '|----------------------------------------------------------------|\n');
fprintf(fid, '| Cadence |   RA            |        DEC      |       ROLL       |\n');
fprintf(fid, '|----------------------------------------------------------------|\n');

for j=1:nCadences

    ra = nominalPointing(j,1);
    dec = nominalPointing(j,2);
    roll = nominalPointing(j,3);

    fprintf(fid, '| %3d     |   %12.8f  |  %12.8f   | %12.8f     |\n', j, ra, dec, roll );

end

fprintf(fid, '|----------------------------------------------------------------|\n');
fprintf(fid, '\n\n');


fprintf(fid, ' delta RA (in arcsec) =\n');
fprintf(fid, ' (nominalPointing.ra - computedPointing.ra)*cos(nominalPointing.dec)*3600\n');
fprintf(fid, ' delta DEC (in arcsec) = (nominalPointing.dec - computedPointing.dec)*3600\n');
fprintf(fid, ' delta ROLL (in arcsec) = (nominalPointing.roll - computedPointing.roll)*3600\n');
fprintf(fid, '|----------------------------------------------------------------|\n');
fprintf(fid, '| Cadence |  delta RA       |  delta DEC      |  delta ROLL      |\n');
fprintf(fid, '|----------------------------------------------------------------|\n');

for j=1:nCadences

    ra = tweakInArcsec(j,1);
    dec = tweakInArcsec(j,2);
    roll = tweakInArcsec(j,3);

    fprintf(fid, '| %3d     |   %12.8f  |  %12.8f   | %12.8f     |\n', j, ra, dec, roll );

end

fprintf(fid, '|----------------------------------------------------------------|\n');
fprintf(fid, '\n\n');





fprintf(fid, ' Angle offset in pixel units at the edge of the focal plane\n');
fprintf(fid, ' ----------------------------------------------------------\n');
fprintf(fid, ' along x-axis (Ra direction) is computed as deltaRa/median(plate scale)\n');
fprintf(fid, ' along y-axis (Dec direction) is computed as deltaDec/median(plate scale)\n');
fprintf(fid, ' along z-axis (Roll direction) is computed as: \n');
fprintf(fid, '       deltaRoll*sin(~7*180/pi)/median(plate scale)\n');
fprintf(fid, '|----------------------------------------------------------------|\n');
fprintf(fid, '| Cadence |  along RA (x)   |  along DEC (y)  |  along ROLL (z)  |\n');
fprintf(fid, '|----------------------------------------------------------------|\n');

for j=1:nCadences

    ra = offsetInPixelUnitsAtEdgeOfFocalPlane(j,1);
    dec = offsetInPixelUnitsAtEdgeOfFocalPlane(j,2);
    roll = offsetInPixelUnitsAtEdgeOfFocalPlane(j,3);

    fprintf(fid, '| %3d     |   %12.8f  |  %12.8f   | %12.8f     |\n', j, ra, dec, roll );

end

fprintf(fid, '|----------------------------------------------------------------|\n');
fprintf(fid, '\n\n');

fclose(fid);

return