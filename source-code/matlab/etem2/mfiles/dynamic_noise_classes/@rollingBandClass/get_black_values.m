function rollingBandBlack = get_black_values(rollingBandObject, temperature, t)
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

runParamsObject = rollingBandObject.runParamsClass;
module = get(runParamsObject, 'moduleNumber');
output = get(runParamsObject, 'outputNumber');
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');

channel = convert_from_module_output(module, output);

A0p = rollingBandObject.rbModelData(channel, 10);
A1p = rollingBandObject.rbModelData(channel, 11);
A2p = rollingBandObject.rbModelData(channel, 12);
A0m = rollingBandObject.rbModelData(channel, 13);
A1m = rollingBandObject.rbModelData(channel, 14);
A2m = rollingBandObject.rbModelData(channel, 15);

K1 = rollingBandObject.rbModelData(channel, 1);
DT1 = rollingBandObject.rbModelData(channel, 2);
T01 = rollingBandObject.rbModelData(channel, 3);
K2 = rollingBandObject.rbModelData(channel, 4);
DT2 = rollingBandObject.rbModelData(channel, 5);
T02 = rollingBandObject.rbModelData(channel, 6);

row = 1:1070;

if DT1 ~= 0
    r0p = K1*DT1*(mod((temperature - T01)/DT1, 1) - 0.5) + 535;
else
    r0p = 535;
end
if DT2 ~= 0
    r0m = K2*DT2*(mod((temperature - T02)/DT2, 1) - 0.5) + 535;
else
    r0m = 535;
end

r0p = repmat(r0p', 1, length(row));
r0m = repmat(r0m', 1, length(row));

rowValues = zeros(size(row));
if A2p ~= 0
    rowValues = rowValues + A0p*exp(-((row - r0p).^2)/(A2p.^2));
end
if A2m ~= 0
    rowValues = rowValues + A0m*exp(-((row - r0m).^2)/(A2m.^2));
end
rowValues = rowValues*exposuresPerCadence;
rollingBandBlack = repmat(rowValues', 1, 1132);
