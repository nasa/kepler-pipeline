% function jd=yymmdd2julian(year,month,day);
%
% Creator: Michael McIntyre 2/17/98
%
% This mfile calculates the julian day from the input in mean Greenwich time. 
%
% For example:
%       1/01/85 at noon		julian(1985,1,1.5)
%       4/17/85 at 6am		julian(1985,4,17.25)
%       4/17 in 2345 BC at 6am	julian(-2344,4,17.25)
% Inputs:
%   year,month,day - numerical values in UTC [vectors]
% Outputs:
%   jd - julian day number [vector]
%
% The algorithm is from J. Meuss, "Astronomical Algorithms," (Richmond, VA:
% William Bell Inc), 1991, chpt. 7.  It is correct for both positive and
% negative (BCE) years after -4712, but the MATLAB implementation only 
% works for years greater than 0000.
% VULCAN code
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

function [JD]=yymmdd2julian(year,month,day);

flag=0;
if (year > 1582)
  flag=1;
elseif (year == 1582)
  if (month > 10)
    flag=1;
  elseif ((month == 10) & (day >= 15))
    flag=1;
  end
end

if (month==1 | month==2),
  year=year-1;
  month=month+12;
end

if (flag)
  A=floor(year/100);
  B=2-A+floor(A/4);
else
  A=floor(year/100);
  B=0;
end

if (year < 0)
  C=floor((365.25*year)-0.75);
else
  C=floor(365.25*year);
end

D=floor(30.6001*(month+1));

JD=B+C+D+day+1720994.5;
