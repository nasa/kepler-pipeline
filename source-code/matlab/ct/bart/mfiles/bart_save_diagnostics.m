function saveDiagnosticsStatus = bart_save_diagnostics(bartHistoryStruct, bartDiagnosticsStruct, destinationFolderName)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function bart_save_model(bartHistoryStruct, bartDiagnosticsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% packs the processing BartHistory in bartHistoryStruct with the diagnostics in
% bartDiagnosticsStruct and saves it into a mat file (for bart_visualize_diagnotics)
% called bart_mod#_out#_dateGenerated_Diagnostics.mat in the current directory
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  INPUT:
%
%          bartHistoryStruct: [struct] with the following fields -
%                               .module [int] the ccd module
%                               .output [int] the ccd output
%                               .midTime [struct] with fields .UTC and .MJD
%                               .fitsFilenames [cell] the filenames
%                               .temperature [double] avg temp for ea/ ffi
%                               .SWVersion [string] software version
%                               .dateGenerated [string] date the bart
%                                     model/diagnostics was generated
%
%         bartDiagnosticsStruct: [struct] with the following fields -
%                           .fitResiduals
%                           .fitWeights
%                           .weightedRmsResiduals
%                           .weightSum
%
%       destinationFolderDiagnostics: [string] destination of where to
%       place the saved mat files
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:
%
%     saveDiagnosticStatus: [logical] true if mat file is saved with populated fields
%           
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

% check that bartHistoryStruct is populated
if isempty(bartHistoryStruct.module) || ...
        isempty(bartHistoryStruct.output) || ...
        isempty(bartHistoryStruct.midTime) || ...
        isempty(bartHistoryStruct.fitsFilenames) || ...
        isempty(bartHistoryStruct.temperatureMnemonics) || ...
        isempty(bartHistoryStruct.temperature) || ...
        isempty(bartHistoryStruct.SWVersion) || ...
        isempty(bartHistoryStruct.dateGenerated)
    error('CT:BART:bart_save_diagnostics', 'BART processing BartHistory has at least one missing field')
end

% check that bartDiagnosticsStruct is also populated
if isempty(bartDiagnosticsStruct.fitResiduals) || ...
        isempty(bartDiagnosticsStruct.fitWeights) ||...
        isempty(bartDiagnosticsStruct.weightedRmsResiduals) ||...
        isempty(bartDiagnosticsStruct.weightSum)
    error('CT:BART:bart_save_diagnostics', 'BART diagnostics has at least one missing field')
end

% create string of mat file name
module = bartHistoryStruct.module;
output = bartHistoryStruct.output;
dateGenerated = bartHistoryStruct.dateGenerated;
mkdir(destinationFolderName, 'diagnostics')
matFileName = strcat('bart_mod', num2str(module), '_out', num2str(output), '_', dateGenerated, '_diagnostics', '.mat');

% create bartDiagnosticsFitStruct
bartDiagnosticsFitStruct = struct('module', [], 'output', [],...
    'fitResiduals', [], 'fitWeights', []);
bartDiagnosticsFitStruct.module = bartHistoryStruct.module;
bartDiagnosticsFitStruct.output = bartHistoryStruct.output;
bartDiagnosticsFitStruct.fitResiduals = bartDiagnosticsStruct.fitResiduals;
bartDiagnosticsFitStruct.fitWeights = bartDiagnosticsStruct.fitWeights;

% create bartDiagnosticsWeightStruct
bartDiagnosticsWeightStruct = struct('module', [], 'output', [],...
    'weightedRmsResiduals', [], 'weightSum', []);

bartDiagnosticsWeightStruct.module = bartHistoryStruct.module;
bartDiagnosticsWeightStruct.output = bartHistoryStruct.output;
bartDiagnosticsWeightStruct.weightedRmsResiduals = bartDiagnosticsStruct.weightedRmsResiduals;
bartDiagnosticsWeightStruct.weightSum = bartDiagnosticsStruct.weightSum;

% save three structures into mat file
string = ['save ', fullfile(destinationFolderName, 'diagnostics', matFileName) ,' bartHistoryStruct', ' bartDiagnosticsFitStruct', ' bartDiagnosticsWeightStruct'];
eval(string)


% check for existence of file
if exist(fullfile(destinationFolderName, 'diagnostics', matFileName), 'file') == 2
    saveDiagnosticsStatus = true;
else
    saveDiagnosticsStatus = false;
end
