function dateStringUtc = local_time_to_utc( dateVectorLocal, format )
%
% local_time_to_utc -- convert local time/date information to UTC.
%
% dateStringUtc = local_time_to_utc( dateVectorLocal ) converts a vector of local
%    date/time information to UTC dates and times.  The format of dateVectorLocal can be
%    either Matlab datenumbers (N x 1 or 1 x N) or else a vector of Matlab date vectors
%    (ie, N x 6, for example [2008 10 22 13 41 00 ; 2008 10 22 13 41 12]).  The time/date
%    values will be converted to UTC and returned in 'dd-mmm-yyyy HH:MM:SS Z' format.
%
% dateStringUtc = local_time_to_utc( dateVectorLocal, format ) returns the UTC time / date
%    values in a format specified by numeric argument format.  The format values match
%    those used by the Matlab datestr function.  Supported formats are as follows:
%
%    Number           String                     Example
%    ===========================================================================
%       0             'dd-mmm-yyyy HH:MM:SS Z'   01-Mar-2000 15:45:17 Z
%      13             'HH:MM:SS Z'               15:45:17 Z    
%      15             'HH:MM Z'                  15:45 Z       
%      21             'mmm.dd,yyyy HH:MM:SS Z'   Mar.01,2000 15:45:17 Z
%      30 (ISO 8601)  'yyyymmddTHHMMSSZ'         20000301T154517Z 
%      31             'yyyy-mm-dd HH:MM:SS Z'    2000-03-01 15:45:17 Z
%
% The format argument can also be a string, such as 'yyyymmdd'.  See MATLAB help for
%    DATESTR for description of the use of free-form date format strings.  In this case, a
%    Z will be postpended with no space if the format string does not contain whitespace
%    characters; if the format string contains whitespace characters, the Z will be
%    postpended with a space.
%
% Version date:  2010-November-03.
%
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

% Modification History:
%
%    2010-November-03, PT:
%        accept free form date format string for format argument.
%    2009-March-12, PT:
%        add patch to correct for Java bug in timezone conversion due to change in US DST
%        definitions.  Clean up old text displays used for debugging in pipeline.
%    2008-November-12, PT:
%        switch to use of Java methods and eliminate check for unix vs PC (java methods
%        work on all platforms).
%    2008-November-10, PT:
%        added a bunch of disp statements which should help diagnose mysterious smoke test
%        failures in PMD and PA.
%
%=========================================================================================

% arguments -- if the argument is a vector of datenums, convert to a vector of time/date
% vectors

  if ( size(dateVectorLocal,2) ~= 6 || max(dateVectorLocal(:,2)) > 12 )
      dateVectorLocal = datevec(dateVectorLocal) ;
  end
  
% check that the format number is supported

  if ( nargin == 1)
      format = 0 ;
  end
  supportedFormats = [0 13 15 21 30 31] ;
  if ~ischar(format) && ~ismember(format,supportedFormats)
      error('common:localTimeToUtc:unsupportedFormat' , ...
          'local_time_to_utc:  unsupported format requested' ) ;
  end
  
% call the converter vector

  dateVectorUtc = local_date_vector_to_utc( dateVectorLocal ) ;
  
% convert the date vectors to the desired format

  dateStringUtc = datestr(dateVectorUtc,format) ;
  stringLength = size(dateStringUtc,2) ;
  nStrings = size(dateStringUtc,1) ;
  
% append the 'Z' 

  dateStringUtc = append_z_to_date_string( dateStringUtc, format ) ;
  
return  
  
% and that's it!

%
%
%

%=========================================================================================

% subfunction which converts a Matlab date vector in local time to one in UTC

function dateVectorUtc = local_date_vector_to_utc( dateVectorLocal )
      
  nDates = size(dateVectorLocal,1) ;
  dateVectorUtc = zeros(nDates,6) ;

% import the Java classes needed for this process

  import java.text.SimpleDateFormat ;
  import java.util.Date ;
  import java.util.TimeZone ;
  
% instantiate a SimpleDateFormat object with a fixed time/date format and UTC time zone

  utcFormatObject = SimpleDateFormat('yyyy-MM-dd HH:mm:ss') ;
  utcFormatObject.setTimeZone(TimeZone.getTimeZone('UTC')) ;
      
% loop over date strings

  for iDate = 1:nDates

      dateVec = dateVectorLocal(iDate,:) ;

%     if the local version of Matlab has the obsolete timezone definitions, and the date
%     vector is in the period when conversion is affected, adjust the dateVec

      dateVec = compensate_for_java_timezone_bug( dateVec ) ;
      
%     instantiate a Java Date class object with the local time.  Note that Java year is
%     year since 1900, and Java month is zero-based
      
      localDateObject = Date(dateVec(1)-1900, dateVec(2)-1, dateVec(3), ...
                             dateVec(4), dateVec(5), dateVec(6)) ;                        
                         
%     convert the date object to a string in the correct format and in UTC

      dateStringUtc = char(utcFormatObject.format(localDateObject)) ;
         
%     pick through the resulting string and extract the data we want, converting to
%     numbers as we go

      dateVectorUtc(iDate,1) = str2num(dateStringUtc(1:4)) ;
      dateVectorUtc(iDate,2) = str2num(dateStringUtc(6:7)) ;
      dateVectorUtc(iDate,3) = str2num(dateStringUtc(9:10)) ;
      dateVectorUtc(iDate,4) = str2num(dateStringUtc(12:13)) ;
      dateVectorUtc(iDate,5) = str2num(dateStringUtc(15:16)) ;
      dateVectorUtc(iDate,6) = str2num(dateStringUtc(18:19)) ;
          
  end % loop over dates
      
return

%=========================================================================================

% subfunction which handles compensation / correcton for java timezone bug -- checks to
% see if this version of Java has its DST switchover on the wrong days, if so adjusts the
% time in the dateVec by 1 hour so that UTC comes out correct.

function dateVec = compensate_for_java_timezone_bug( dateVec )

% constant definitions:  number of days per hour 

  daysPerHour = 1 / 24 ;
  
% Do we need to do anything?  Only if Java is broken and the year of request is after
% 2006, so figure that out first

  isBroken = is_timezone_converter_broken( dateVec(1) ) ;
  
  if (isBroken) 
      
%     get the dates which start and end the broken period

      brokenPeriodStruct = find_timezone_converter_broken_days( dateVec(1) ) ;
      
%     convert the dateVec to a Matlab date number
 
      dateNumber = datenum(dateVec) ;
      
%     If the date falls between 3 AM of the start of the Spring broken period and 3 AM of
%     the end of the Spring broken period, then subtract an hour and convert back to a
%     date vector

      if ( dateNumber >= brokenPeriodStruct.springPeriodStart + 3*daysPerHour ) && ...
         ( dateNumber < brokenPeriodStruct.springPeriodEnd + 3*daysPerHour )
          dateVec = datevec(dateNumber - daysPerHour) ;
      end
      
%     if the date falls between 1 AM of the start of the Fall broken period and 1 AM of
%     the end of the Fall broken period, then subtract an hour and convert back to a date
%     vector

      if ( dateNumber >= brokenPeriodStruct.fallPeriodStart + 1*daysPerHour ) && ...
         ( dateNumber < brokenPeriodStruct.fallPeriodEnd + 1*daysPerHour )
          dateVec = datevec(dateNumber - daysPerHour) ;
      end
      
  end % isBroken conditional
  
return
