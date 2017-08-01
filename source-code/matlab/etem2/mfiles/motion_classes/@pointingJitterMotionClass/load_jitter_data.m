function pointingJitterMotionObject = load_jitter_data(pointingJitterMotionObject, ccdObject)
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

runDurationDays = get(pointingJitterMotionObject.runParamsClass, 'runDurationDays');
runStartTime = get(pointingJitterMotionObject.runParamsClass, 'runStartTime');

sampleFrequency = pointingJitterMotionObject.sampleFrequency; % Hz

pointingJitterMotionObject.jitterLength = runDurationDays*24*3600*sampleFrequency; % desired number of jitter points at 2Hz

pixelWidth = get(pointingJitterMotionObject.runParamsClass, 'pixelWidth');
pixelAngle = get(pointingJitterMotionObject.runParamsClass, 'pixelAngle');
boresiteDec = get(pointingJitterMotionObject.runParamsClass, 'boresiteDec');

load(pointingJitterMotionObject.jitterFile);

% filter the jitter file if we're using observed PRFs, which already have
% the long cadence jitter built in
ccdPlaneObjectList = get(ccdObject, 'ccdPlaneObjectList');
psfObject = get(ccdPlaneObjectList(1), 'psfObject');
psfTimeWindow = get(psfObject, 'psfDuration');

if psfTimeWindow > 0 % we need to filter the jitter because the psf already has averaged jitter
    filterWindow = sampleFrequency*psfTimeWindow; % convert from seconds to jitter samples
    
    j = jitter_x;
    
    jitter_x = filter(ones(1, filterWindow)/filterWindow, 1, jitter_x);
    
    % plot the fft of j and jitter_x to compare
    fj = fft(j);
    fx = fft(jitter_x);
    fjp = fj.*conj(fj)/length(fj);
    fxp = fx.*conj(fx)/length(fx);
    freq = 2*(0:length(fj)-1)/length(fj);
    figure;
    % 
    % the PRFs are at 15-minute cadences
    plot(1./freq(2:fix(end/2))/psfTimeWindow, fjp(2:fix(end/2)), 1./freq(2:fix(end/2))/psfTimeWindow, fxp(2:fix(end/2)));
    axis([0 10 0 0.15]);
    legend('before filtering', 'after filtering');
    title('power spectra of jitter_x');
    xlabel('period in psfTimeWindow units');
    
    jitter_y = filter(ones(1, filterWindow)/filterWindow, 1, jitter_y);
end

pointingJitterMotionObject.radius = sqrt(max(power(jitter_x,2) ...
    + power(jitter_y,2)))/pixelWidth;
pointingJitterMotionObject.sampleFrequency = sampleFrequency; % Hz
pointingJitterMotionObject.jitterTimeLength = ...
    pointingJitterMotionObject.jitterLength/pointingJitterMotionObject.sampleFrequency; % Hz
        
pointingJitterMotionObject.jitterFilename = ...
    [get(pointingJitterMotionObject.runParamsClass, 'outputDirectory') filesep ...
    'jitterData.mat'];

if ~exist(pointingJitterMotionObject.jitterFilename, 'file')
	% seed the random number generator with a deterministic value characteristic of this run. Use runStartTime
	% first save current random state
    randomState = rand('twister');
    randomNState = randn('state');
    rand('twister', runStartTime);
	randn('state', runStartTime);
	
    % jitter_x and jitter_y are input as microns
    % convert to pixel coordinates
    jitterRa = generate_ar_timeseries(jitter_x/pixelWidth, 25, pointingJitterMotionObject.jitterLength);
    jitterDec = generate_ar_timeseries(jitter_y/pixelWidth, 25, pointingJitterMotionObject.jitterLength);
    jitterPhi = generate_ar_timeseries(jitter_y/pixelWidth, 25, pointingJitterMotionObject.jitterLength);
    
    % we compute the standard deviation of the original jitter series in
    % degrees of arc, given by
    %
    %       std of jitter in microns    pixel angle in seconds of arc
    %       ------------------------- * -----------------------------
    %       size of pixel in microns    seconds per degree
    %
    jitterSd = std(jitter_x)*pixelAngle/(pixelWidth*3600); % standard deviation of original jitter in microns
	
	% we want to scale the jitter so it has the requied standard deviation.
	% we want the RA jitter to have a standard deviation of equal 
    % to jitterSd/cos(boresite declination) to account for the variable
    % size of RA azimuthal degrees
	jitterRa = jitterRa*(jitterSd/cos(boresiteDec*pi/180))/std(jitterRa);
	% we want the dec jitter to have a standard deviation = jitterSd
	jitterDec = jitterDec*jitterSd/std(jitterDec);
	% we want the phi jitter to have a standard deviation of jitterSd/7 
    % since the fine guidance sensors are about 7 degrees from the center
    % so phi motion induces a maximum linear motion of 7tan(phi) ~ 7*phi
    % for small phi
	jitterPhi = jitterPhi*jitterSd/7;

    jitterTimes = (0:pointingJitterMotionObject.jitterLength-1)'...
        /pointingJitterMotionObject.sampleFrequency; % 2Hz time vector for jitter
    save(pointingJitterMotionObject.jitterFilename, 'jitterRa', 'jitterDec', 'jitterPhi', 'jitterTimes');
    
    % restore the random state
    rand('twister', randomState);
	randn('state', randomNState);
end
