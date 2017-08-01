function verify_116pa1(invocation,cadenceType)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_116pa1(invocation,cadenceType)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Plot the mean difference over all target flux time series for the
% specified invocation between the pipeline runs with zodi on (TC02) and
% zodi off (TC01).
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

% LC directory = /path/to/release-5.0/monthly/
% SC directory = TBD
LC_PATH = [filesep,'release-5.0',filesep,'monthly',filesep];
SC_PATH = 'TBD_SC_PC_PATH';

ZODI_OFF_TASK_DIR = ['TC01',filesep,'pa-matlab-33-2544'];
ZODI_ON_TASK_DIR  = ['TC02',filesep,'pa-matlab-34-2634'];

if ispc
    LC_PATH = [filesep,LC_PATH];
    SC_PATH = [filesep,SC_PATH];
end


if( strcmpi(cadenceType, 'long') )
    TCPATH = LC_PATH;
elseif( strcmpi(cadenceType, 'short') )
        TCPATH = SC_PATH;
else
    disp(['Cadence type ',cadenceType,' is invalid. Type must be *short* or *long*.']);
    return;
end


TC01DIR = [TCPATH,filesep,ZODI_OFF_TASK_DIR];
TC02DIR = [TCPATH,filesep,ZODI_ON_TASK_DIR];    

fileName = ['pa-inputs-', num2str(invocation), '.mat'];

cd(TC01DIR);
load(fileName);
zodiOffDataStruct = inputsStruct;

cd(TC02DIR);
load(fileName);
zodiOnDataStruct = inputsStruct;
clear inputsStruct

zodiOffPixelData = [zodiOffDataStruct.targetStarDataStruct.pixelDataStruct];
ccdRows = 1 + [zodiOffPixelData.ccdRow];
ccdColumns = 1 + [zodiOffPixelData.ccdColumn];
zodiOffPixelValues = [zodiOffPixelData.values];
clear zodiOffPixelData zodiOffDataStruct

zodiOnPixelData = [zodiOnDataStruct.targetStarDataStruct.pixelDataStruct];
zodiOnPixelValues = [zodiOnPixelData.values];
clear zodiOnPixelData zodiOnDataStruct

close all;
plot3(ccdColumns, ccdRows, mean(zodiOnPixelValues - zodiOffPixelValues)', '.')
title('[PA] Mean Difference in Pixel Time Series with Zodi On/Off');
xlabel('CCD Column');
ylabel('CCD Row');
zlabel('Pixel Difference (e-)');
pause
clear zodiOffPixelValues zodiOnPixelValues

fileName = ['pa-outputs-', num2str(invocation), '.mat'];

cd(TC01DIR);
load(fileName);
zodiOffResultsStruct = outputsStruct;

cd(TC02DIR);
load(fileName);
zodiOnResultsStruct = outputsStruct;
clear outputsStruct

zodiOffFluxTimeSeries = ...
    [zodiOffResultsStruct.targetStarResultsStruct.fluxTimeSeries];
zodiOffFluxValues = [zodiOffFluxTimeSeries.values];

zodiOnFluxTimeSeries = ...
    [zodiOnResultsStruct.targetStarResultsStruct.fluxTimeSeries];
zodiOnFluxValues = [zodiOnFluxTimeSeries.values];

close all;
plot(mean(zodiOnFluxValues - zodiOffFluxValues));
title('[PA] Mean Difference in Flux Time Series with Zodi On/Off');
xlabel('Target');
ylabel('Flux Difference (e-)');
grid

return
