function pos = get_kepler_position(barycentricTimeCorrectionObject, julianTimes)
% function pos = get_kepler_position(barycentricTimeCorrectionObject, julianTimes)
% pos in mks
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

keplerSpiceKernel = barycentricTimeCorrectionObject.keplerSpiceKernel;
planetEphemerisKernel = barycentricTimeCorrectionObject.planetEphemerisKernel;
leapsecondFilename = barycentricTimeCorrectionObject.leapsecondFilename;

keplerSpiceId = barycentricTimeCorrectionObject.keplerSpiceId;
spiceEpoch = barycentricTimeCorrectionObject.spiceEpoch;

nTimes = length(julianTimes);
pos = zeros(nTimes, 3);

maxTimeLength = barycentricTimeCorrectionObject.maxTimeLength;
if nTimes <= maxTimeLength
	for t=1:nTimes
		% 400 evaluations of the following takes about 2.3 seconds
		julianDateString = julian2datestr(julianTimes(t))';
		[pos(t, :) vel] = keplerStateVector(julianDateString, ...
    		keplerSpiceId, 'ssb', spiceEpoch, keplerSpiceKernel, ...
			planetEphemerisKernel, leapsecondFilename);
	end
else
	% it takes too long to evaluate each individual time, so subsample julianTimes
	% and build a polynomial
	
	nSampleGoal = fix(maxTimeLength/2);
	sampleInterval = fix(nTimes/nSampleGoal);
	sampleIndex = 1:sampleInterval:nTimes;
	% be sure to include endpoints
	if sampleIndex(end) ~= nTimes
		sampleIndex(end+1) = nTimes;
	end
	
	% get the spacecraft position relative to solar system barycenter
	nSamples = length(sampleIndex);
	samplePos = zeros(nSamples, 3);
	for t=1:nSamples
		julianDateString = julian2datestr(julianTimes(sampleIndex(t)))';
		[samplePos(t, :) vel] = keplerStateVector(julianDateString, ...
    		keplerSpiceId, 'ssb', spiceEpoch, keplerSpiceKernel, ...
			planetEphemerisKernel, leapsecondFilename);
	end
	
	sampleIndex = sampleIndex(:);
	julianTimes = julianTimes(:);
	polyOrder = barycentricTimeCorrectionObject.polyOrder;
	% build the polynomials
	[xPoly, S, xMu] = polyfit(julianTimes(sampleIndex), samplePos(:, 1), polyOrder);
	[yPoly, S, yMu] = polyfit(julianTimes(sampleIndex), samplePos(:, 2), polyOrder);
	[zPoly, S, zMu] = polyfit(julianTimes(sampleIndex), samplePos(:, 3), polyOrder);
	
	% evaluate it at the desired times
	pos(:,1) = polyval(xPoly, julianTimes, [], xMu);
	pos(:,2) = polyval(yPoly, julianTimes, [], yMu);
	pos(:,3) = polyval(zPoly, julianTimes, [], zMu);
end

% keplerStateVector returns its answer in kilometers, so convert to mks
pos = convert_to_mks(pos, 'kilometers');
