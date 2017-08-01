function dateStringLocal = utc_to_local_time( dateVectorUtc, format )
%
% utc_to_local_time -- convert UTC to local time/date.
%
% dateStringLocal = utc_to_local_time( dateVectorUtc ) converts a vector of UTC
%    date/time information to local dates and times.  The format of dateVectorLocal must
%    be a vector of Matlab date vectors (ie, N x 6, for example [2008 10 22 13 41 00 ;
%    2008 10 22 13 41 12]).  The time/date values will be converted to local time and
%    returned in 'dd-mmm-yyyy HH:MM:SS' format.
%
% dateStringlocal = utc_to_local_time( dateVectorUtc, format ) returns the local time / 
%    date values in a format specified by numeric argument format.  The format values
%    match those used by the Matlab datestr function.  Supported formats are as follows:
%
%    Number           String                   Example
%    ===========================================================================
%       0             'dd-mmm-yyyy HH:MM:SS'   01-Mar-2000 15:45:17 
%      13             'HH:MM:SS'               15:45:17     
%      15             'HH:MM'                  15:45        
%      21             'mmm.dd,yyyy HH:MM:SS'   Mar.01,2000 15:45:17 
%      30 (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517 
%      31             'yyyy-mm-dd HH:MM:SS'    2000-03-01 15:45:17 
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
%        definitions.  
%    2008-November-12, PT:
%        switch to use of Java methods and eliminate conditional on unix (since Java runs
%        correctly anywhere).
%
%=========================================================================================

% check that the format number is supported

  if ( nargin == 1)
      format = 0 ;
  end
  supportedFormats = [0 13 15 21 30 31] ;
  if ~ischar(format) && ~ismember(format,supportedFormats)
      error('common:utcToLocalTime:unsupportedFormat' , ...
          'utc_to_local_time:  unsupported format requested' ) ;
  end
  
% call the converter vector

  dateVectorLocal = utc_date_vector_to_local( dateVectorUtc ) ;
  
% convert the date vectors to the desired format

  dateStringLocal = datestr(dateVectorLocal,format) ;
  stringLength = size(dateStringLocal,2) ;
  nStrings = size(dateStringLocal,1) ;
    
return  
  
% and that's it!

%
%
%

%=========================================================================================

% subfunction which converts a Matlab date vector in UTC to one in local time

function dateVectorLocal = utc_date_vector_to_local( dateVectorUtc )
      
  nDates = size(dateVectorUtc,1) ;
  dateVectorLocal = zeros(nDates,6) ;
  
% import the Java classes needed for the conversion and construct an appropriate
% SimpleDateFormat object in local time zone

  import java.text.SimpleDateFormat ;
  import java.util.Date ;
  import java.util.Calendar ;
  import java.util.TimeZone ;
  
  localFormatObject = SimpleDateFormat('yyyy-MM-dd HH:mm:ss') ;
  
% construct an appropriate calendar instance in UTC

  utcCalendarObject = Calendar.getInstance(TimeZone.getTimeZone('UTC')) ;
      
% loop over date strings 

  for iDate = 1:nDates

      dateVec = dateVectorUtc(iDate,:) ;
      
%     construct a Java Date object in UTC from the UTC dateVec object.  Note that Java's
%     month is zero-based.  Note further that, to define a date in UTC, we actually need
%     to use a Calendar object instance defined above

      utcCalendarObject.set( dateVec(1), dateVec(2)-1, dateVec(3), ...
          dateVec(4), dateVec(5), dateVec(6) ) ;
      utcDateObject = utcCalendarObject.getTime() ;
      
%     construct a local time string from the UTC date object

      dateStringNew = char(localFormatObject.format(utcDateObject)) ;
          
%     pick through the resulting string and extract the data we want, converting to
%     numbers as we go

      dateVectorLocal(iDate,1) = str2num(dateStringNew(1:4)) ;
      dateVectorLocal(iDate,2) = str2num(dateStringNew(6:7)) ;
      dateVectorLocal(iDate,3) = str2num(dateStringNew(9:10)) ;
      dateVectorLocal(iDate,4) = str2num(dateStringNew(12:13)) ;
      dateVectorLocal(iDate,5) = str2num(dateStringNew(15:16)) ;
      dateVectorLocal(iDate,6) = str2num(dateStringNew(18:19)) ;

%     if the local version of Matlab has the obsolete timezone definitions, and the date
%     vector is in the period when conversion is affected, adjust the dateVec

      dateVectorLocal = compensate_for_java_timezone_bug( dateVectorLocal, ...
          char(utcDateObject) ) ;      
      
  end % loop over dates
            
return

%=========================================================================================

% subfunction which handles compensation / correcton for java timezone bug -- checks to
% see if this version of Java has its DST switchover on the wrong days, if so adjusts the
% time in the dateVec by 1 hour so that UTC comes out correct.

function dateVec = compensate_for_java_timezone_bug( dateVec, dateStringJava )

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
      
%     find the timezone token in the Java date string, and find its middle letter ("S" for
%     "Standard time" or "D" for DST)

      dsj = dateStringJava ;
      for iToken = 1:5
          [token, dateStringJava] = strtok(dateStringJava) ;
      end
      if strcmp(token(2),'D')
          isStdTime = false ;
      else
          isStdTime = true ;
      end
      
%     If the date falls between 2 AM of the start of the Spring broken period and 2 AM of
%     the end of the Spring broken period, then add an hour and convert back to a date
%     vector 

      if ( dateNumber >= brokenPeriodStruct.springPeriodStart + 2*daysPerHour ) && ...
         ( dateNumber < brokenPeriodStruct.springPeriodEnd + 2*daysPerHour ) 
          dateVec = datevec(dateNumber + daysPerHour) ;
      end
      
%     if the date falls between 1 AM of the start of the Fall broken period and 1 AM of
%     the end of the Fall broken period, AND isstdTime is true then add an hour and
%     convert back to a date vector (need to check DST because 1 AM - 2 AM DST is not the
%     same time as 1 AM to 2 AM Standard time)

      if ( dateNumber >= brokenPeriodStruct.fallPeriodStart + 1*daysPerHour ) && ...
         ( dateNumber < brokenPeriodStruct.fallPeriodEnd + 1*daysPerHour ) && isStdTime
          dateVec = datevec(dateNumber + daysPerHour) ;
      end
      
  end % isBroken conditional
  
return
