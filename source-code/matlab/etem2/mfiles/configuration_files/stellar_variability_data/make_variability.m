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
clear
fid = fopen('betaCep.pow');
powerSpectrum = fscanf(fid, '%g %g', [2,inf]);
fclose(fid);
N = size(powerSpectrum, 1);
freq = powerSpectrum(1,:)/1e3;
a = sqrt(powerSpectrum(2,:));
a0 = a(1);
a = a(2:end);
freq = 2*pi*freq(2:end);
aOverf = a./freq;
cadenceTime = 30*60; % seconds
t = 0:cadenceTime:3600*24*30; % 30 days of seconds
phase = 2*pi*rand(size(powerSpectrum(1,:)));
phase2 = phase(2:end);
% phase = 0;
for i=1:length(t)-1
    timeSeries(i) = a0*cadenceTime + sum(aOverf.*(sin(freq*t(i+1) + phase2) - sin(freq*t(i) + phase2)));
end

if 1
	t2 = 0:60:3600*24*30;
	a = sqrt(powerSpectrum(2,:));
	freq = powerSpectrum(1,:)/1e3;
	for i=1:length(t2)
    	timeSeries2(i) = sum(a.*cos(2*pi*freq*t2(i) + phase));
	end

	figure(1);
	plot(t(1:length(t)-1) + cadenceTime/2,timeSeries(1:length(t)-1)/cadenceTime, t2, timeSeries2);
else
	figure(1);
	plot(t(1:length(t)-1) + cadenceTime/2,timeSeries(1:length(t)-1)/cadenceTime);
end
