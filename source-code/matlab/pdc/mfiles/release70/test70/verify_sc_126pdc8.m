function verify_sc_126pdc8(flightDataDirString)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_sc_126pdc8
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% SOC126
%   The SOC shall generate a quarterly Corrected Flux Time Series for each
%   target star with systematic errors removed.
%
% 126.PDC.8
%   PDC shall be capable of utilizing ancillary data with variable sample rate.
%
%
% Generate ancillary engineering data with a range of sample rates. Run the
% PDC matlab controller, and the load the conditioned ancillary engineering
% data from the pdc_cads.mat file. Plot the original and conditioned
% version of each engineering time series.
%
%
% flightDataDirString
%
% ex. /path/to/flight/q2/i956/pdc-matlab-956-22686
%     /path/to/flight/q2/i956/pdc-matlab-956-22692
%     /path/to/flight/q2/i956/pdc-matlab-956-22703
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


SCRATCHDIR = '/path/to/matlab/pdc/test/';
cd(SCRATCHDIR);

invocation = 0;
fileName = ['pdc-inputs-', num2str(invocation), '.mat'];

if nargin==1
    cd(flightDataDirString);
    load(fileName);
    cd(SCRATCHDIR);
else
    load(fileName);
end


pdcDataStruct = inputsStruct;
clear inputsStruct

cadenceTimes = pdcDataStruct.cadenceTimes;
cadenceTimestamps = cadenceTimes.startTimestamps;
nCadences = length(cadenceTimestamps);

ancillaryEngineeringDataStruct(1).mnemonic = 'ENG_SIN_5_MIN';
nSamples = (30/5) * nCadences;
timestamps = cadenceTimestamps(1) + (0 : nSamples-1)' * 5 / 1440 - 0.5;
ancillaryEngineeringDataStruct(1).timestamps = timestamps;
ancillaryEngineeringDataStruct(1).values = sin(2 * pi * timestamps / 50 - pi / 6) + ...
    0.01 * rand(size(timestamps));

ancillaryEngineeringDataStruct(2).mnemonic = 'ENG_SIN_1_MIN';
nSamples = (30/1) * nCadences;
timestamps = cadenceTimestamps(2) + (0 : nSamples-1)' * 1 / 1440 - 0.5;
ancillaryEngineeringDataStruct(2).timestamps = timestamps;
ancillaryEngineeringDataStruct(2).values = sin(2 * pi * timestamps / 35 - pi / 3) + ...
    5 + 0.01 * rand(size(timestamps));

ancillaryEngineeringDataStruct(3).mnemonic = 'ENG_SIN_20_SEC';
nSamples = (30/(1/3)) * nCadences;
timestamps = cadenceTimestamps(3) + (0 : nSamples-1)' * (1/3) / 1440 - 0.5;
ancillaryEngineeringDataStruct(3).timestamps = timestamps;
ancillaryEngineeringDataStruct(3).values = sin(2 * pi * timestamps / 20 + pi / 3) + ...
    2 + 0.01 * rand(size(timestamps));

ancillaryEngineeringConfigurationStruct.mnemonics = ...
    {'ENG_SIN_5_MIN', 'ENG_SIN_1_MIN','ENG_SIN_20_SEC'};
ancillaryEngineeringConfigurationStruct.modelOrders = [1; 1; 1]';
ancillaryEngineeringConfigurationStruct.interactions = {};
ancillaryEngineeringConfigurationStruct.intrinsicUncertainties = [0.01; 0.01; 0.01]';
ancillaryEngineeringConfigurationStruct.quantizationLevels = [0; 0; 0]';

pdcDataStruct.ancillaryEngineeringConfigurationStruct = ...
    ancillaryEngineeringConfigurationStruct;
pdcDataStruct.ancillaryEngineeringDataStruct = ...
    ancillaryEngineeringDataStruct;

cd(SCRATCHDIR);

[pdcResultsStruct] = pdc_matlab_controller(pdcDataStruct);
clear pdcResultsStruct

load('pdc_cads.mat', 'conditionedAncillaryDataStruct');

cadenceTimestamps = cadenceTimes.midTimestamps;


% save environment
save sc_req_126pdc8_results_to_plot


% create figures
printJpgFlag = false;
paperOrientationFlag = false;
includeTimeFlag      = false;

for iChannel = 1 : 3
    plot(ancillaryEngineeringDataStruct(iChannel).timestamps, ...
        ancillaryEngineeringDataStruct(iChannel).values, '.-b');
    hold on
    plot(cadenceTimestamps, ...
        conditionedAncillaryDataStruct(iChannel).ancillaryTimeSeries.values, '.-r');
    hold off
    title('[PDC] Original and Conditioned Ancillary Engineering Data');
    xlabel('Timestamp (MJD)');
    ylabel('Engineering Value');
    legend('Original Data', 'Conditioned Data');
    grid

    fileNameStr = ['sc_req_126pdc8_figure' num2str(iChannel)];
    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
end

return
