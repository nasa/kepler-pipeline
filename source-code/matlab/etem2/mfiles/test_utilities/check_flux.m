function fluxStruct = check_flux(location, type, quantize)
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

if nargin < 3
    quantize = 1;
end
if nargin < 2
    type = 'targets';
end

cadenceType = strfind(location, 'short');
if isempty(cadenceType)
    % it's a long cadence
    pixelSeries = get_pixel_time_series(location, type, quantize);
    backgroundSeries = get_pixel_time_series(location, 'background', quantize);
    meanBackground = mean(mean(backgroundSeries));
else
    pixelSeries = get_short_cadence_time_series(location, quantize);
    % set the backgound to the dimmest pixel in the first series
    meanBackground = min(pixelSeries(1).pixelValues(1, :));
end

load([location filesep 'ETEM2_tad_inputs.mat']);
load([location filesep 'runParamsObject.mat']);
load([location filesep 'catalogData.mat']);
flux12 = get(runParamsObject, 'fluxOfMag12Star');
guardBandOffset = get(runParamsObject, 'guardBandOffset');
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');
integrationTime = get(runParamsObject, 'integrationTime');
electronsPerADU = get(runParamsObject, 'electronsPerADU');

targetDefs = amaResultStruct.targetDefinitions;
nTargets = length(targetDefs);
for t=1:nTargets
    % get the average measured flux from the time series
    fluxStruct(t).measuredFlux ...
        = mean(sum(pixelSeries(t).pixelValues - meanBackground, 2));
    catalogIndex = find([catalogData.kicId] == targetDefs(t).keplerId);
    kepMag = catalogData.keplerMagnitude(catalogIndex);
    fluxStruct(t).magnitude = kepMag;
    fluxStruct(t).predictedFlux ...
        = (flux12/electronsPerADU)*exposuresPerCadence*integrationTime*mag2b(kepMag - 12);
    fluxStruct(t).error ...
        = (fluxStruct(t).measuredFlux - fluxStruct(t).predictedFlux)/fluxStruct(t).predictedFlux;
    fluxStruct(t).ratio ...
        = fluxStruct(t).measuredFlux/fluxStruct(t).predictedFlux;
end