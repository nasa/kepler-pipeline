% write_pdc_flux_timeseries_to_text_files.m
% pdcResultsStruct
%
% pdcResultsStruct =
%
% ccdModule: 12
% ccdOutput: 1
% targetResultsStruct: [1x1998 struct]
%
% pdcResultsStruct.targetResultsStruct(1).correctedFluxTimeSeries
%
% ans =
%
% values: [4454x1 double]
% uncertainties: [4454x1 double]
% filledIndices: [44x1 double]
%
% pdcResultsStruct.targetResultsStruct(1)
%
% ans =
%
% keplerId: 1000001
% correctedFluxTimeSeries: [1x1 struct]
% outliers: [1x1 struct]
%
% keplerMag              1998x1
%
% cadenceEndTimes        4454x1                   35632  double
% cadenceStartTimes      4454x1                   35632  double
% dx                     4454x1                   35632  double
% dy                     4454x1                   35632  double
% fluxTimeSeries         4454x1998             71192736  double
% h1                        1x1                       8  double
% h2                        1x1                       8  double
% j                         1x1                       8  double
% k                         1x1                       8  double
% keplerMag              1998x1                   15984  double
% m                         1x1                       8  double
% mjd                       1x1                       8  double
% mjdTimestamps          4454x1                   35632  double
% moduleNumber              1x1                       8  double
% observingSeason           1x1                       8  double
% outputNumber              1x1                       8  double
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
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

% keplerMag keplerId tadCrowdingMetric fluxTimeSeries dx dy runStartTime runEndTime moduleNumber outputNumber observingSeason;

load pdcResults
load pdc

[nCadences, nStars] = size(fluxTimeSeries);


sFilename = ['flux-' num2str(observingSeason) '.txt'];
fid = fopen(sFilename, 'wt');


for j = 1: nStars

    fprintf(fid, '%d|', pdcResultsStruct.targetResultsStruct(j).keplerId);
    fprintf(fid, '%10.2f|', keplerMag(j));
    fprintf(fid, '%10.2f|', tadCrowdingMetric(j));

    % add back the mean as PDC should return calibrated, raw flux
    meanFlux = mean(fluxTimeSeries(:,j));

    fprintf(fid, '%20.8f|', pdcResultsStruct.targetResultsStruct(j).correctedFluxTimeSeries.values(1:end-1) + meanFlux );
    fprintf(fid, '%20.8f', pdcResultsStruct.targetResultsStruct(j).correctedFluxTimeSeries.values(end) + meanFlux);
    fprintf(fid, '\n');

    if(length(pdcResultsStruct.targetResultsStruct(j).correctedFluxTimeSeries.filledIndices) > 1)

        filledIndices = pdcResultsStruct.targetResultsStruct(j).correctedFluxTimeSeries.filledIndices;

        % don't know why some of th eindices are coming out as 0 from
        % pdc....
        zeroIndex = find(filledIndices == 0);
        filledIndices(zeroIndex) = 1;

        fprintf(fid, '%d|', filledIndices(1:end-1));
        fprintf(fid, '%d', filledIndices(end));

    elseif(length(pdcResultsStruct.targetResultsStruct(j).correctedFluxTimeSeries.filledIndices) == 1)

        fprintf(fid, '%d', pdcResultsStruct.targetResultsStruct(j).correctedFluxTimeSeries.filledIndices(end));

    end

    fprintf(fid,'\n');


end

%%

sFilename = ['timestamps-' num2str(observingSeason) '.txt'];
fid = fopen(sFilename, 'wt');

for j = 1:length(mjdTimestamps)
    fprintf(fid, '%20.12f|%20.12f|%20.12f', cadenceStartTimes(j), mjdTimestamps(j), cadenceEndTimes(j));
    fprintf(fid,'\n');

end



