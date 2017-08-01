% script to confirm sc zodi requirement
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

pathname = [filesep,'soc',filesep,'matlab',filesep,'cal-pa-vandv'];
%pathname = ['F:',filesep,'cal-pa-vandv'];


% load the background polynomial struct from zodi off LC
%load /path/to/matlab/cal-pa-vandv/tc01/lc/pa-matlab-8-68/pa_background.mat
load([pathname,filesep,'tc01',filesep,'lc',filesep,'pa-matlab-8-68',filesep,'pa_background.mat']);
inputStruct1 = inputStruct;

% load the background polynomial struct from zodi on LC
%load /path/to/matlab/cal-pa-vandv/tc02/lc/pa-matlab-8-68/pa_background.mat
load([pathname,filesep,'tc02',filesep,'lc',filesep,'pa-matlab-8-68',filesep,'pa_background.mat']);
inputStruct2 = inputStruct;
clear inputStruct

% load the original ETEM zodi off SC data set
%load /path/to/matlab/cal-pa-vandv/tc01/sc/pa-matlab-10-80/pa-inputs-0.mat
load([pathname,filesep,'tc01',filesep,'sc',filesep,'pa-matlab-10-80',filesep,'pa-inputs-0.mat']);
zodiOffInputs = inputsStruct;
zodiOffInputs.raDec2PixModel.spiceFileDir = './';
clear inputsStruct


% add to the non-zodi target pixels a zodi contribution equal to the median (over time) 
% of the difference of the LC background fits - e.g. zodi on - zodi off
% save in a temporary struct
tempStruct = add_zodi_to_target_pixels(zodiOffInputs, inputStruct1, inputStruct2);


% load the original ETEM zodi on SC data set
%load /path/to/matlab/cal-pa-vandv/tc02/sc/pa-matlab-10-80/pa-inputs-0.mat
load([pathname,filesep,'tc02',filesep,'sc',filesep,'pa-matlab-10-80',filesep,'pa-inputs-0.mat']);
zodiOnInputs = inputsStruct;

% replace the zodi on target struct with the one containing original pixels
% w/zodi added manually
zodiOnInputs.targetStarDataStruct = tempStruct.targetStarDataStruct;
zodiOnInputs.raDec2PixModel.spiceFileDir = './';
clear inputsStruct tempStruct

% run PA for our new zodi off and zodi on cases
zodiOffOutputs = pa_matlab_controller(zodiOffInputs);
zodiOnOutputs = pa_matlab_controller(zodiOnInputs);

% display the difference in the output flux time seris
fluxZodiOff = [zodiOffOutputs.targetStarResultsStruct.fluxTimeSeries];
fluxZodiOn = [zodiOnOutputs.targetStarResultsStruct.fluxTimeSeries];
figure;
plot([fluxZodiOn.values]-[fluxZodiOff.values]);
grid;
xlabel('cadence #');
ylabel('( e- )');
title('Difference in Target Flux : Zodi On - Zodi Off');








