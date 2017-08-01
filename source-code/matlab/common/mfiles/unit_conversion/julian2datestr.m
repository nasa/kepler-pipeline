function [time]=julian2datestr(julday)
% function [time]=julian2datestr(julday)
%
% JULIAN2DATESTR converts julian day to MATLAB datestring,
% using algorithms from Meeus, "Astronomical Algorithms," chpt 7.
% This MATLAB implementation is valid only for julian days greater 
% than 1721057.5, corresponding to '01-Jan-0000 00:00:00'
% Inputs:
%   julday - vector of julian day numbers [ntimes,1]
% Outputs:
%   time - vector of times in MATLAB formatted date-strings [ntimes,20]
% Calls:
%   MATLAB functions datenum(), datestr()
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


mjd = julday +0.5;

z = fix(mjd);
f = mjd-z;
	% initialize
a=zeros(size(julday));
mon=zeros(size(julday));
year=zeros(size(julday));


lz =  z < 2299161;   % two cases of low & high z values
	a(lz)=z(lz);  % low-z

	alpha = fix( (z(~lz)-1867216.25)/36524.25);	% high-z
	a(~lz) = z(~lz) + 1 + alpha - fix(alpha/4);


b = a + 1524;
c = fix((b-122.1)/365.25);
d = fix(365.25 * c);
e = fix((b-d)/30.6001);

dom = b - d - fix(30.6001 * e) + f;     % decimal day of month

le = e<14;	% month number
	mon(le) = e(le)-1;	% low month number
	mon(~le) = e(~le)-13;	% high-e

hm =   mon>2;	% year
	year(hm) = c(hm) - 4716;
	year(~hm) = c(~hm) - 4715;

	% get time from dom
t = dom - fix(dom);
hf = 24*t;
h = fix(hf);
mf = hf-fix(hf);
min =fix(mf*60);
sec = (mf*60-min)*60;

dn_truncated = datenum(year,mon,fix(dom),h,min,fix(sec));
time = datestr(dn_truncated, 0);

% The variable 'time' is yyyy-mmm-dd HH:MM:SS (seconds values are truncated).
% Append second fraction as ".xxxxxxxxx" decimal to the time string, so it is
% the decimal seconds value:
%
dn_raw = datenum(year,mon,fix(dom),h,min,sec);
dn_diff = (dn_raw(:) - dn_truncated(:))';
secs_diff = dn_diff * 86400; %TODO: leap seconds?
secs_diff_str = reshape(num2str(secs_diff, '%.10f'), 12, size(time, 1))';
timeout = [time secs_diff_str(:,2:end)];
time = timeout;

