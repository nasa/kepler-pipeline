function [tpsInputStruct] = generate_random_plotter_inputs_SQ( numTargets, ...
    tpsDawgStruct, topDir )
%
% generate_random_plotter_inputs -- randomly select numTargets worth of
% inputs/outputs and concatenate them together so they can be used by the
% plotter functions for V&V.  This is only necessary when the results are
% produced by the NAS.
%
% Modification History:
%
%=========================================================================================
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

% first generate a random list of the task files - for NAS results, each
% task file has only a single target

numStars = length(tpsDawgStruct.taskfile);
randIndices = unique(randi(numStars,numTargets*3,1));
% pulled thrice what we needed to avoid duplicates so now truncate
randIndices = randIndices(1:numTargets);

% now loop over indices, read in task files and concatenate them together

for i=1:numTargets
    inputFile = char(strcat(topDir,'/tps-matlab-',tpsDawgStruct.taskfile(randIndices(i)),'/tps-inputs-0.bin'));
    %outputFile = char(strcat(topDir,'/tps-matlab',tpsDawgStruct.taskfile(randIndices(i)),'/tps-outputs-0.bin'));
    %diagnosticFile = char(strcat(topDir,'/tps-matlab',tpsDawgStruct.taskfile(randIndices(i)),'/tps-diagnostic-struct.mat'));
    if i==1
        tpsInputStruct = read_TpsInputs(inputFile);
        indexOfTarget = find([tpsInputStruct.tpsTargets.keplerId]==tpsDawgStruct.keplerId(randIndices(i)));
        tpsInputStruct.tpsTargets = tpsInputStruct.tpsTargets(indexOfTarget);
        %tpsOutputStruct = read_TpsOutputs(outputFile);
        %tpsOutputStruct.tpsResults=tpsOutputStruct.tpsResults(1);
        %load(diagnosticFile);
        %tpsOutputStruct.tpsResults.detrendedFluxTimeSeries = tpsDiagnosticStruct(1).detrendedFluxTimeSeries;
    else
        tempInput = read_TpsInputs(inputFile);
        indexOfTarget = find([tempInput.tpsTargets.keplerId]==tpsDawgStruct.keplerId(randIndices(i)));
        tempInput.tpsTargets = tempInput.tpsTargets(indexOfTarget);
        %tempOutput = read_TpsOutputs(outputFile);
        %tempOutput.tpsResults = tempOutput.tpsResults(1);
        %load(diagnosticFile);
        %tempOutput.tpsResults.detrendedFluxTimeSeries = tpsDiagnosticStruct(1).detrendedFluxTimeSeries;
        tpsInputStruct.tpsTargets(i) = tempInput.tpsTargets;
        %tpsOutputStruct.tpsResults(i) = tempOutput.tpsResults;
    end
    clear tempInput inputFile;
end

return
