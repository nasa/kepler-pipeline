function [ebInputStruct ebOutputStruct] = generate_random_eb_inputs( nTargets, tpsDawgStruct)


% load the catalog
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
EBCatalog = load_eclipsing_binary_catalog();
randomIndex = randperm(length(EBCatalog));
randomIndex = randomIndex(1:nTargets);
EBCatalog = EBCatalog(randomIndex,:);
topDir = tpsDawgStruct.topDir;


for i=1:nTargets
    index = find(tpsDawgStruct.keplerId == EBCatalog(i,1));
    inputFile = char(strcat(topDir,'/tps-matlab',tpsDawgStruct.taskfile(index),'/tps-inputs-0.mat'));
    outputFile = char(strcat(topDir,'/tps-matlab',tpsDawgStruct.taskfile(index),'/tps-outputs-0.mat'));
    diagnosticFile = char(strcat(topDir,'/tps-matlab',tpsDawgStruct.taskfile(index),'/tps-diagnostic-struct.mat'));
    if i==1
        load(inputFile);
        load(outputFile);
        ebInputStruct = inputsStruct;
        ebOutputStruct = outputsStruct;
        ebOutputStruct.tpsResults=ebOutputStruct.tpsResults(1);
        load(diagnosticFile);
        ebOutputStruct.tpsResults.detrendedFluxTimeSeries = tpsDiagnosticStruct(1).detrendedFluxTimeSeries;

    else
        load(inputFile);
        tempInput = inputsStruct;
        load(diagnosticFile);
        ebInputStruct.tpsTargets(i) = tempInput.tpsTargets;
        ebOutputStruct.tpsResults(i).detrendedFluxTimeSeries = tpsDiagnosticStruct(1).detrendedFluxTimeSeries;
    end
    clear tpsDiagnosticStruct tempInput inputFile diagnosticFile inputsStruct outputsStruct;
end



return;