% show p-modes injected into a short-cadence time series
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
fid = fopen('configuration_files/stellar_variability_data/solarlike3.dat');
modulationData = fscanf(fid, '%g %g', [2,inf]);
fclose(fid);
modulation = modulationData(2,:);

nModCadences = length(modulation);
modCadenceTime = 60; % seconds
modFreq = (0:nModCadences-1)/(nModCadences*modCadenceTime);
FfiModulation = fft(modulation);
PffiModulation = FfiModulation.*conj(FfiModulation)/length(FfiModulation);
PffiModulation(1) = 0;

figure(1);
plot(modFreq(1:end/2), PffiModulation(1:end/2));

pixStruct = get_short_cadence_time_series('output/pmodes2/run_short_m12o1s1', 1);
load output/pmodes2/run_short_m12o1s1/runParamsObject.mat;
shortCadenceDuration = runParamsObject.keplerData.shortCadenceDuration;
nCadences = length(pixStruct(1).pixelValues(:,1));
pixFreq = (0:nCadences-1)/(nCadences*shortCadenceDuration);
for t=1:length(pixStruct)
    black = mean(mean(pixStruct(t).blackValues))/5;
    background = min(min(pixStruct(t).pixelValues));
	pixStruct(t).flux = sum(pixStruct(t).pixelValues - background, 2);
	pixStruct(t).FfiFlux = fft(pixStruct(t).flux);
	pixStruct(t).PffiFlux = pixStruct(t).FfiFlux.*conj(pixStruct(t).FfiFlux)/length(pixStruct(t).FfiFlux);
	pixStruct(t).PffiFlux(1) = 0;
	figure
	plot(pixFreq(1:end/2), pixStruct(t).PffiFlux(1:end/2));
end

