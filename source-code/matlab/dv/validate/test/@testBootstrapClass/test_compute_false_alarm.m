%% test_compute_false_alarm
%
% function self = test_compute_false_alarm(self)
%
% This function tests bootstrap's compute_false_alarm.m.
% 
% Run with:
%   run(text_test_runner, testBootstrapClass('test_compute_false_alarm'));
%%
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
function self = test_compute_false_alarm(self)

fprintf('\nTesting test compute_false_alarm.m...\n\n');

% TODO Update test data, which is sorely out of date, and remove this guard
% clause
if (true)
    fprintf('SKIPPING TEST. TEST DATA TOO FAR OUT OF DATE.\n');
    return;
end

% Add test-meta-data path.
% TODO Move files from verification to unit-tests.
initialize_soc_variables;
testDataRoot = fullfile(socTestDataRoot, 'dv', 'verification', 'bootstrap');
addpath(testDataRoot);

% Load dvDataObject and dvResultsStruct (with fitter data) of a
% super-earth.
load 'kepId_5530076.mat';

% Until kepId_5530076.mat is updated (and renamed to kepId-005530076.mat,
% update old-style data.
dvDataObject_kepId5530076 = dv_convert_62_data_to_70(dvDataObject_kepId5530076); %#ok<NODEF>
dvResultsStruct_kepId5530076.targetResultsStruct(1).dvFiguresRootDirectory = 'target-005530076';

if (~isobject(dvDataObject_kepId5530076))
   dvDataObject_kepId5530076 = dvDataClass(dvDataObject_kepId5530076);
end

% Create figure directories expected by bootstrap.
mkdir(fullfile('target-005530076', 'planet-01', 'bootstrap-results'));
mkdir(fullfile('target-005530076', 'summary-plots'));

% The MES that triggered this in TPS is 12.8408.
% Perform bootstrap and print out significance.
fprintf('Performing bootstrap with maxMultipleEventSigma that triggered this event in TPS\n');
compute_false_alarm_with_mes(dvDataObject_kepId5530076, dvResultsStruct_kepId5530076, ...
    1, dvResultsStruct_kepId5530076.targetResultsStruct.planetResultsStruct.planetCandidate.maxMultipleEventSigma);
compute_false_alarm_with_mes(dvDataObject_kepId5530076, dvResultsStruct_kepId5530076, 1, 8.4);
compute_false_alarm_with_mes(dvDataObject_kepId5530076, dvResultsStruct_kepId5530076, 1, 8.25);
compute_false_alarm_with_mes(dvDataObject_kepId5530076, dvResultsStruct_kepId5530076, 1, 7.95);

% Load dvDataObject and dvResultsStruct (with fitter data) 2 Jupiters
load 'kepId_5270106.mat'

% Until kepId_5270106.mat is updated (and renamed to kepId-005270106.mat,
% update old-style data.
dvDataObject_kepId5270106 = dv_convert_62_data_to_70(dvDataObject_kepId5270106); %#ok<NODEF>
dvResultsStruct_kepId5270106.targetResultsStruct(1).dvFiguresRootDirectory = 'target-005270106';

if (~isobject(dvDataObject_kepId5270106))
   dvDataObject_kepId5270106 = dvDataClass(dvDataObject_kepId5270106);
end

% Create figure directories expected by bootstrap.
mkdir(fullfile('target-005270106', 'planet-01', 'bootstrap-results'));
mkdir(fullfile('target-005270106', 'planet-02', 'bootstrap-results'));
mkdir(fullfile('target-005270106', 'summary-plots'));

fprintf('Performing bootstrap with maxMultipleEventSigma that triggered this event in TPS\n');
compute_false_alarm_with_mes(dvDataObject_kepId5270106, dvResultsStruct_kepId5270106, ...
    2, dvResultsStruct_kepId5270106.targetResultsStruct.planetResultsStruct(2).planetCandidate.maxMultipleEventSigma);
compute_false_alarm_with_mes(dvDataObject_kepId5270106, dvResultsStruct_kepId5270106, 2, 9.2);
compute_false_alarm_with_mes(dvDataObject_kepId5270106, dvResultsStruct_kepId5270106, 2, 9.0);
compute_false_alarm_with_mes(dvDataObject_kepId5270106, dvResultsStruct_kepId5270106, 2, 8.85);
compute_false_alarm_with_mes(dvDataObject_kepId5270106, dvResultsStruct_kepId5270106, 2, 7.55);
compute_false_alarm_with_mes(dvDataObject_kepId5270106, dvResultsStruct_kepId5270106, 2, 9.2);

rmpath(testDataRoot);

end

function compute_false_alarm_with_mes(dvDataObject, dvResultsStruct, planet, maxMultipleEventSigma)

target = dvResultsStruct.targetResultsStruct.keplerId;
dvFiguresRootDirectory = dvResultsStruct.targetResultsStruct.dvFiguresRootDirectory;

fprintf ('Running bootstrap with maxMultipleEventSigma=%1.2f\n', maxMultipleEventSigma);
dvResultsStruct.targetResultsStruct.planetResultsStruct(planet).planetCandidate.maxMultipleEventSigma = ...
    maxMultipleEventSigma;
[dvResultsStruct] = perform_dv_bootstrap(dvDataObject, dvResultsStruct);
fprintf('Significance = %1.4e\n', ...
    dvResultsStruct.targetResultsStruct.planetResultsStruct(planet).planetCandidate.significance);

originalBasename = sprintf('%s/planet-%02d/bootstrap-results/%09d-%02d-bootstrap-false-alarm', ...
    dvFiguresRootDirectory, planet, target, planet);
originalFilename = [originalBasename '.fig'];
newFilename = sprintf('%s-mes-%03d.fig', originalBasename, floor(10*maxMultipleEventSigma));
open(originalFilename);
saveas(gcf, newFilename);
close(gcf);
delete(originalFilename);

filename = sprintf('%s/planet-%02d/bootstrap-results/dvResultsStruct-sig-at-mes-%03d.mat', ...
    dvFiguresRootDirectory, planet, floor(10*maxMultipleEventSigma));
save(filename, 'dvResultsStruct');
end
