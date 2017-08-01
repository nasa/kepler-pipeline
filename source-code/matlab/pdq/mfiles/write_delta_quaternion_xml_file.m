function write_delta_quaternion_xml_file( pdqOutputStruct, pdqTimestampSeries )
%**************************************************************************
% write_delta_quaternion_xml_file( pdqOutputStruct, pdqTimestampSeries )
%**************************************************************************
% Generate a delta quaternion XML file.
%
% INPUTS
%
%     pdqOutputStruct   
%     pdqTimestampSeries : An array of structs containing MJD timestamps.
%                          Taken from the PDQ input struct.
%
% OUTPUTS
%
%     Writes an XML file in the following format:
%
%         <?xml version="1.0" encoding="UTF-8"?>
%         <att:attitude-adjustment timeGenerated="2012005184108" xmlns:att="http://kepler.nasa.gov/pdq/attitude-adjustment">
%           <att:delta-quaternion startTime="2012005144315">
%             <att:x>1.6196136083945767E-6</att:x>
%             <att:y>1.8598689399684787E-7</att:y>
%             <att:z>-4.0886624924109383E-7</att:z>
%             <att:w>0.9999999999985876</att:w>
%           </att:delta-quaternion>
%         </att:attitude-adjustment>
%     
%     where
%         timeGenerated is local time in DMC format.
%
%         startTime is the start time (UTC) of the long cadence from which 
%             the attitude solution was generated, expressed in DMC format.
%
%         x, y, z, and w are taken in order from the 4-element array 
%             pdqOutputStruct.attitudeAdjustments(end).quaternion
%
%     and DMC format refers to 'YYYYDDDHHMMSS'.
%
%
% NOTES
%
%     If multiple cadences were processed, then there will multiple
%     attitude adjustments in the output struct. This function writes the
%     last (most recent) attitude adjustment to the output file.
%
%**************************************************************************
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
    WHITE_SPACE = '  ';
    X_INDEX = 1;
    Y_INDEX = 2;
    Z_INDEX = 3;
    W_INDEX = 4;    
    MJD_2_JD_OFFSET = 2400000.5; % Add this constant to a Modified Julian 
                                 % Date (MJD) to obtain the equivalent
                                 % Julian Day (JD). 
    
    % Express the current local time as a string in DMC format.
    dmcNowString = get_dmc_string(clock);
    
    % Open the output file for writing in text mode.
    fid = fopen(sprintf('kplr%s_delta_quaternion.xml', dmcNowString), 'wt');

    % Express the reference cadence MJD as a UTC time string in DMC format.
    dmcStartString = get_dmc_string( datevec( julian2datestr( ...
        pdqTimestampSeries.startTimes(end) + MJD_2_JD_OFFSET) ) );
    
    % If the output struct contains more than one attitude adjustment, use
    % the last one, assumed to be most recent.
    quaternion = pdqOutputStruct.attitudeAdjustments(end).quaternion(:);

    % Print to the file.
    fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?>');
    fprintf(fid, '\n');

    fprintf(fid, '<att:attitude-adjustment timeGenerated="%s" xmlns:att="http://kepler.nasa.gov/pdq/attitude-adjustment">', dmcNowString);
    fprintf(fid, '\n');

        fprintf(fid, WHITE_SPACE);
        fprintf(fid, '<att:delta-quaternion startTime="%s">', dmcStartString);
        fprintf(fid, '\n');

            fprintf(fid, [WHITE_SPACE, WHITE_SPACE]);
            fprintf(fid, '<att:x>%.16E</att:x>', quaternion(X_INDEX));
            fprintf(fid, '\n');

            fprintf(fid, [WHITE_SPACE, WHITE_SPACE]);
            fprintf(fid, '<att:y>%.16E</att:y>', quaternion(Y_INDEX));
            fprintf(fid, '\n');

            fprintf(fid, [WHITE_SPACE, WHITE_SPACE]);
            fprintf(fid, '<att:z>%.16E</att:z>', quaternion(Z_INDEX));
            fprintf(fid, '\n');

            fprintf(fid, [WHITE_SPACE, WHITE_SPACE]);
            fprintf(fid, '<att:w>%.16E</att:w>', quaternion(W_INDEX));
            fprintf(fid, '\n');

        fprintf(fid, WHITE_SPACE);
        fprintf(fid, '</att:delta-quaternion>');
        fprintf(fid, '\n');

    fprintf(fid, '</att:attitude-adjustment>');
    fprintf(fid, '\n');

    % Close the file.
    fclose(fid);
end

%**************************************************************************
% dmcString = get_dmc_string(dateVector)
%**************************************************************************
function dmcString = get_dmc_string(dateVector)
    dayOfYear = floor(datenum(dateVector) - datenum(dateVector(1),1,0,0,0,0));
    dmcString = sprintf('%s%03d%s',datestr(dateVector,'yyyy'), dayOfYear,  ...
        datestr(dateVector, 'HHMMSS'));
end

