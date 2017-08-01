function cadenceLogs = retrieve_cadence_logs(isLongCadence, startInterval, endInterval, isInputCadenceNumber)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function cadenceLogs = retrieve_cadence_logs(isLongCadence)
% or 
% function cadenceLogs = retrieve_cadence_logs(isLongCadence, startInterval, endInterval, isInputCadenceNumber)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Retrieve the long/short cadence pixel logs within a time interval specified by the start and end cadence numbers or MJD start and end time.
% 
% Inputs:
%   isLongCadence                                       Flag indicating the cadence type of the retrieved pixel logs is long/short when it is 1/0.
%   startInterval                                       Optional. Start cadence number or MJD start time of the specified time interval.
%   endInterval                                         Optional. End cadence number or MJD end time of the specified time interval.
%   isInputCadenceNumber                                Optional. Flag indicating the inputs 'startInterval' and 'endInterval' are cadence numbers/MJDs  
%                                                       when it is 1/0. 
%                                                       If isInputCadenceNumber is not specified, startInterval is set to 54000, endInterval is set
%                                                       to 64000 and isInputCadenceNumber is set to 0.
%                                                       When isInputCadenceNumber is 0, startInterval is set to 54000 when not specified and endInterval
%                                                       is set to 64000 when not specified. 
%                                                       When isInputCadenceNumber is 1, startInterval is set to 0 when not specified and endInterval
%                                                       is set to 1e7 when not specified. 
%
% Output:
%   cadenceLogs                                         1 x nPixelLogs array of structures describing the pixel logs. 
%                                                       nPixelLogs is the number of long/short cadence pixel logs within the specified time interval.
%                                                       The structure contains the following fields:
%       .cadenceNumber                                  Cadence number.  
%       .cadenceType                                    A string describing the cadence type. It can be either member of the set 
%                                                       {   'SHORT'
%                                                           'LONG'          }.
%       .dataSetType                                    A string describing the data set type. It can be any member of the set 
%                                                       {   'Target'
%                                                           'Background'
%                                                           'Collateral'    }.
%       .dispatcherType                                 A string describing the dispatcher type. It can be any member of the following set
%                                                       {   'LONG_CADENCE_PIXEL'
%                                                           'SHORT_CADENCE_PIXEL'
%                                                           'GAP_REPORT'
%                                                           'CONFIG_MAP'
%                                                           'REF_PIXEL'
%                                                           'LONG_CADENCE_TARGET_PMRF'
%                                                           'SHORT_CADENCE_TARGET_PMRF'
%                                                           'BACKGROUND_PRMF'
%                                                           'LONG_CADENCE_COLLATERAL_PMRF'
%                                                           'SHORT_CADENCE_COLLATERAL_PMRF'
%                                                           'HISTOGRAM'
%                                                           'ANCILLARY'
%                                                           'SPACECRAFT_EPHEMERIS'
%                                                           'PLANETARY_EPHEMERIS' 
%                                                           'LEAP_SECONDS'
%                                                           'SCLK'
%                                                           'CRCT'
%                                                           'FFI'
%                                                           'HISTORY'	
%                                                           'TARGET_LIST'
%                                                           'TARGET_LIST_SET'
%                                                           'MASK_TABLE'        }.
%       .fitsFilename                                   A string describing the FITS file name.
%       .dataSetName                                    A string describing the data set name.
%       .mjdStartTime                                   MJD start time of the data.
%       .mjdEndTime                                     MJD end time of the data.
%       .mjdMidTime                                     MJD mid-point time of the data.
%       .spacecraftConfigId                             Spacecraft configuration ID.
%       .lcTargetTableId                                Long cadence target table ID.
%       .scTargetTableId                                Short cadence target table ID.
%       .backTargetTableId                              Background target table ID.
%       .targetApertureTableId                          Target aperture table ID.
%       .backApertureTableId                            Background aperture table ID.
%       .compressionTableId                             Compression table ID. Same ID is used for requatization and Huffman tables.
%       .isDataRequantizedForDownlink                   Flag indicating the data is/isn't requantized for downlink when it is 1/0.
%       .isDataEntropicCompressedForDownlink            Flag indicating the data is/isn't entropic compressed for downlink when it is 1/0.
%       .isDataOriginatedAsBaselineImage                Flag indicating the data is/isn't originated as baseline image when it is 1/0.
%       .isBaselineCreatedFromResidualBaselineImage     Flag indicating the baseline is/isn't created from residual baseline image when it is 1/0.
%       .isReverseClockingInEffect                      Flag indicating the reverse clocking is/isn't in effect when it is 1/0.      
%       .baselineImageRootname                          A string describing the baseline image rootname.
%       .residualBaselineImageRootname                  A string describing the residual baseline image rootname.
%       
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
import gov.nasa.kepler.systest.sbt.SandboxTools;
SandboxTools.displayDatabaseConfig;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Validity check on inputs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if ~( nargin==1 || nargin==4 )
    error('MATLAB:SBT:wrapper:retrieve_pixel_log:wrongNumberOfInputs', 'MATLAB:SBT:wrapper:retrieve_pixel_log: must be called with 1 or 4 input arguments.');
end

if(isLongCadence ~= 0 && isLongCadence ~= 1)
    error('MATLAB:SBT:wrapper:retrieve_pixel_log:invalidInput', 'Valid value of isLongCadence should be 1 or 0.');
end

if ( ~exist('isInputCadenceNumber', 'var') || isempty(isInputCadenceNumber) )
    startInterval = 54000;
    endInterval   = 64000;
    isInputCadenceNumber = 0;
%     disp(['startInterval is set to ' num2str(startInterval) '. endInterval is set to ' num2str(endInterval) ...
%         '. isInputCadenceNumber is set to ' num2str(isInputCadenceNumber)]);
elseif ( isInputCadenceNumber==0 )
    if ( ~exist('startInterval', 'var') || isempty(startInterval) )
        startInterval = 54000;
        disp(['startInterval is set to ' num2str(startInterval)]);
    end
    if ( ~exist('endInterval', 'var') || isempty(endInterval) )
        endInterval = 64000;
        disp(['endInterval is set to ' num2str(endInterval)]);
    end
elseif ( isInputCadenceNumber==1 )
    if ( ~exist('startInterval', 'var') || isempty(startInterval) )
        startInterval = 0;
        disp(['startInterval is set to ' num2str(startInterval)]);
    end
    if ( ~exist('endInterval', 'var') || isempty(endInterval) )
        endInterval = 1e7;
        disp(['endInterval is set to ' num2str(endInterval)]);
    end
else
    error('MATLAB:SBT:wrapper:retrieve_pixel_log:invalidInput', 'Valid value of isInputCadenceNumber should be 1 or 0.');
end

sbt_validate_time_interval(startInterval, endInterval, isInputCadenceNumber, 'MATLAB:SBT:wrapper:retrieve_pixel_log:invalidInput');

if(isLongCadence==1)
    cadenceType = 'LONG';
else
    cadenceType = 'SHORT';
end

import gov.nasa.kepler.systest.sbt.SbtRetrieveCadenceLogs;

if(isInputCadenceNumber==0)
    % Java code:
    % Class: gov.nasa.kepler.systest.sbt.SbtRetrieveCadenceLogs
    % API: public static String retrieveCadenceLogsByMjd(double startMjd,
    %      double endMjd, String cadenceType)
    startMjd = double(startInterval);
    endMjd   = double(endInterval);
    
    sbt = SbtRetrieveCadenceLogs;
    pathJava = sbt.retrieveCadenceLogsByMjd(startMjd,...
        endMjd, cadenceType);
else % by cadence
    % Java code:
    % Class: gov.nasa.kepler.systest.sbt.SbtRetrieveCadenceLogs
    % API:   public static String retrieveCadenceLogsByCadence(int
    %        startCadence, int endCadence, String cadenceType)
    startCadence = int32(startInterval);
    endCadence   = int32(endInterval);

    sbt = SbtRetrieveCadenceLogs;
    pathJava = sbt.retrieveCadenceLogsByCadence(startCadence,...
        endCadence, cadenceType);
end

path = pathJava.toCharArray()';

cadenceLogs = sbt_sdf_to_struct(path);
cadenceLogs = cadenceLogs.pixelLogs;

SandboxTools.close;
