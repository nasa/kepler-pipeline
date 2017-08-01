function [rowMotion, colMotion] = get_motion(dvaMotionObject, row, column, time)
% input time is in days
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

moduleNumber = get(dvaMotionObject.runParamsClass, 'moduleNumber');
outputNumber = get(dvaMotionObject.runParamsClass, 'outputNumber');
dvaTimeVector = get(dvaMotionObject.runParamsClass, 'timeVector');
numCcdCols = get(dvaMotionObject.runParamsClass, 'numCcdCols');
numVisibleCols = get(dvaMotionObject.runParamsClass, 'numVisibleCols');
numLeadingBlack = get(dvaMotionObject.runParamsClass, 'numLeadingBlack');
raDec2PixObject = get(dvaMotionObject.runParamsClass, 'raDec2PixObject');
centerTimeIndex = get(raDec2PixObject, 'centerTimeIndex');

% % get initial aberrated ra and dec of the intput row and column
[unaberratedInitialRa, unaberratedInitialDec] = ...
    unaberrate_pix_to_ra_dec(raDec2PixObject, moduleNumber, outputNumber, row, column, ...
    dvaTimeVector(1));

% use polynomial method
dvaTimeVectorRange = max(dvaTimeVector) - min(dvaTimeVector);
normalizedDvaTimeVector = (dvaTimeVector(:) - dvaTimeVector(1))...
    /dvaTimeVectorRange;
polyFitOrder = min(10, length(dvaTimeVector)-1);
r = zeros(size(normalizedDvaTimeVector));
c = zeros(size(normalizedDvaTimeVector));
for t=1:length(dvaTimeVector)
    % Convert the aberrated RA/Dec to pixels
    [m, o, r(t), c(t)] = ra_dec_to_pix( raDec2PixObject, ...
        unaberratedInitialRa, unaberratedInitialDec, dvaTimeVector(t));
    if o ~= outputNumber
        c(t) = 2*numVisibleCols - c(t) + 2*numLeadingBlack;
    end
end

rowPoly = polyfit(normalizedDvaTimeVector, r - r(centerTimeIndex), polyFitOrder);
colPoly = polyfit(normalizedDvaTimeVector, c - c(centerTimeIndex), polyFitOrder);

% now evaluate the output time series
% the input time is 0-based, assume it starts at the same time as the
% time vector.  
normalizedTime = (time(:) - dvaTimeVector(1))/dvaTimeVectorRange;
rowMotion = polyval(rowPoly, normalizedTime);
colMotion = polyval(colPoly, normalizedTime);

