function brokenPeriodStruct = find_timezone_converter_broken_days( year )
%
% find_timezone_converter_broken_days -- find the days (in Matlab datenum format)
% corresponding to days when the timezone converter is broken
%
% brokenPeriodStruct = find_timezone_converter_broken_days( year ) returns a struct with
% fields:
%
%    springPeriodStart
%    springPeriodEnd
%    fallPeriodStart
%    fallPeriodEnd
%
% which are the days (in Matlab datenum format) which begin and end the 2 periods when the
% Matlab time zone converter between local and UTC time may be broken.  Those dates are
% the second Sunday in March, the first Sunday in April, the last Sunday in October, and
% the first Sunday in November, respectively.
%
% Version date:  2009-march-12.
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
%=========================================================================================

% Find the first Sunday in March and add 7 days to get the second Sunday in March

  dateVector = [year 03 01 00 00 00] ;
  for iDay = 1:7
      dateVector(3) = iDay ;
      if strcmpi(datestr(dateVector,8),'sun')
          dateVectorSpringPeriodStart = dateVector ;
          dateVectorSpringPeriodStart(3) = dateVectorSpringPeriodStart(3) + 7 ;
      end
  end
  
  brokenPeriodStruct.springPeriodStart = ...
      datenum(dateVectorSpringPeriodStart) ;
  
% find the first Sunday in April

  dateVector = [year 04 01 00 00 00] ;
  for iDay = 1:7
      dateVector(3) = iDay ;
      if strcmpi(datestr(dateVector,8),'sun')
          dateVectorSpringPeriodEnd = dateVector ;
      end
  end

  brokenPeriodStruct.springPeriodEnd = ...
      datenum(dateVectorSpringPeriodEnd) ;

% find the first Sunday in November

  dateVector = [year 11 01 00 00 00] ;
  for iDay = 1:7
      dateVector(3) = iDay ;
      if strcmpi(datestr(dateVector,8),'sun')
          dateVectorFallPeriodEnd = dateVector ;
      end
  end

  brokenPeriodStruct.fallPeriodEnd = ...
      datenum(dateVectorFallPeriodEnd) ;

% the last Sunday in October is 7 days prior to the first Sunday in November

  brokenPeriodStruct.fallPeriodStart = brokenPeriodStruct.fallPeriodEnd - 7 ;
  
% and that's it!

%
%
%
