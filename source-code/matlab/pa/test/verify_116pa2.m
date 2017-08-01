function verify_116pa2
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_116pa2
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the background polynomial fits for each cadence for the pipeline
% run with zodi on (TC02).
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

ZODI_ON_TASK_DIR  = ['TC02' filesep 'pa-matlab-34-2634'];
TCPATH = [filesep,'release-5.0',filesep,'monthly',filesep];

if ispc
    TCPATH = [filesep,TCPATH];
end

TC02DIR = [TCPATH,ZODI_ON_TASK_DIR];

invocation = 0;
fileName = ['pa-inputs-', num2str(invocation), '.mat'];

cd(TC02DIR);
load(fileName);
zodiOnDataStruct = inputsStruct;
clear inputsStruct

ccdRows = 1 + [zodiOnDataStruct.backgroundDataStruct.ccdRow];
ccdColumns = 1 + [zodiOnDataStruct.backgroundDataStruct.ccdColumn];
zodiOnBackgroundValues = [zodiOnDataStruct.backgroundDataStruct.values];
zodiOnGapArray = [zodiOnDataStruct.backgroundDataStruct.gapIndicators];

cadenceNumbers = [zodiOnDataStruct.cadenceTimes.cadenceNumbers];
nCadences = length(cadenceNumbers);

BACKGROUNDFILE = 'pa_background.mat';
load(BACKGROUNDFILE);
backgroundPolyStruct = inputStruct;
clear inputStruct;

close all;
for iCadence = 1 : nCadences
    backgroundValues = zodiOnBackgroundValues(iCadence, : )';
    gapIndicators = zodiOnGapArray(iCadence, : )';
    if ~all(gapIndicators)
        plot3(ccdColumns(~gapIndicators), ccdRows(~gapIndicators), ...
            backgroundValues(~gapIndicators), '.b');
        hold on
        [backgroundEstimates] = weighted_polyval2d(ccdRows, ccdColumns, ...
            backgroundPolyStruct(iCadence).backgroundPoly);
        plot3(ccdColumns(~gapIndicators), ccdRows(~gapIndicators), ...
            backgroundEstimates(~gapIndicators), '.r');
        hold off
        title(['[PA] Background Fit -- Cadence ', num2str(cadenceNumbers(iCadence)), ...
            ' / Order ', num2str(backgroundPolyStruct(iCadence).backgroundPoly.order)]);
        xlabel('CCD Column (1-based)');
        ylabel('CCD Row (1-based)');
        zlabel('Flux (e-)');
        pause(1)
    end
end

return
