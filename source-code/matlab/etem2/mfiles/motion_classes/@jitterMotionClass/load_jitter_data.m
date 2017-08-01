function jitterMotionObject = load_jitter_data(jitterMotionObject, ccdObject)
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

runDurationDays = get(jitterMotionObject.runParamsClass, 'runDurationDays');
jitterMotionObject.jitterLength = runDurationDays*24*3600*2; % desired number of jitter points at 2Hz

pixelWidth = get(jitterMotionObject.runParamsClass, 'pixelWidth');

load(jitterMotionObject.jitterFile);
jitterMotionObject.radius = sqrt(max(power(jitter_x,2) ...
    + power(jitter_y,2)))/pixelWidth;
jitterMotionObject.sampleFrequency = 2; % Hz
jitterMotionObject.jitterTimeLength = ...
    jitterMotionObject.jitterLength/jitterMotionObject.sampleFrequency; % Hz
        
jitterMotionObject.jitterFilename = ...
    [get(jitterMotionObject.runParamsClass, 'outputDirectory') filesep ...
    'jitterData.mat'];

if ~exist(jitterMotionObject.jitterFilename, 'file')
    % jitter_x and jitter_y are input as microns
    % convert to pixel coordinates
    jitterX = generate_ar_timeseries(jitter_x/pixelWidth, 25, jitterMotionObject.jitterLength);
    jitterY = generate_ar_timeseries(jitter_y/pixelWidth, 25, jitterMotionObject.jitterLength);

    jitterTimes = (0:jitterMotionObject.jitterLength-1)'...
        /jitterMotionObject.sampleFrequency; % 2Hz time vector for jitter
    save(jitterMotionObject.jitterFilename, 'jitterX', 'jitterY', 'jitterTimes');
end
