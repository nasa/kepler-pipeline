%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
function  plot_noise_variances_for_various_data_types(requantizationMainStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% run colorPalette to get numerical values for different colors
%
figure;


SQRT_12 = sqrt(12);
xTable = requantizationMainStruct.mainTable;
stepSizes = abs(diff(xTable));

visibleLCNoiseSigmaVerifyFraction = stepSizes(requantizationMainStruct.visibleLCIndex -1)./(sqrt(requantizationMainStruct.visibleLCNoiseVarianceMin)*SQRT_12);
h1 =  plot(requantizationMainStruct.visibleLCIndex, visibleLCNoiseSigmaVerifyFraction, 'b');
hold on;
text(fix(mean(requantizationMainStruct.visibleLCIndex)), visibleLCNoiseSigmaVerifyFraction(fix(end/2)), ' \leftarrow ...........visible LC', 'color','b','fontweight', 'bold');


blackLCNoiseSigmaVerifyFraction = stepSizes(requantizationMainStruct.blackLCIndex-1)./(sqrt(requantizationMainStruct.blackLCNoiseVarianceMin)*SQRT_12);

h2 =  plot(requantizationMainStruct.blackLCIndex, blackLCNoiseSigmaVerifyFraction, 'k');
text(fix(mean(requantizationMainStruct.blackLCIndex)), blackLCNoiseSigmaVerifyFraction(fix(end/2)), ' \leftarrow ...........black LC','color','k','fontweight', 'bold');


vsmearLCNoiseSigmaVerifyFraction = stepSizes(requantizationMainStruct.vsmearLCIndex-1)./(sqrt(requantizationMainStruct.vsmearLCNoiseVarianceMin)*SQRT_12);

h3 =  plot(requantizationMainStruct.vsmearLCIndex,vsmearLCNoiseSigmaVerifyFraction, 'color', [0.48 0.06 0.89]);
text(fix(mean(requantizationMainStruct.vsmearLCIndex)), vsmearLCNoiseSigmaVerifyFraction(fix(end/2)), ' \leftarrow ...........vsmear LC','color', [0.48 0.06 0.89],'fontweight', 'bold');



msmearLCNoiseSigmaVerifyFraction = stepSizes(requantizationMainStruct.msmearLCIndex-1)./(sqrt(requantizationMainStruct.msmearLCNoiseVarianceMin)*SQRT_12);

h4 =  plot(requantizationMainStruct.msmearLCIndex, msmearLCNoiseSigmaVerifyFraction, 'r');
text(requantizationMainStruct.msmearLCIndex(end), msmearLCNoiseSigmaVerifyFraction(end),...
    ' \leftarrow ...........msmear LC','color','r','fontweight', 'bold');



visibleSCNoiseSigmaVerifyFraction = stepSizes(requantizationMainStruct.visibleSCIndex-1)./(sqrt(requantizationMainStruct.visibleSCNoiseVarianceMin)*SQRT_12);

h5 =  plot(requantizationMainStruct.visibleSCIndex,visibleSCNoiseSigmaVerifyFraction, 'color', [0.75 0 0.75], 'Marker','*', 'MarkerSize', 4);
text(requantizationMainStruct.visibleSCIndex(end), visibleSCNoiseSigmaVerifyFraction(end), ' \leftarrow ...........visible SC', 'color', [0.75 0 0.75],'fontweight', 'bold');



blackSCNoiseSigmaVerifyFraction = stepSizes(requantizationMainStruct.blackSCIndex-1)./(sqrt(requantizationMainStruct.blackSCNoiseVarianceMin)*SQRT_12);

h6 =  plot(requantizationMainStruct.blackSCIndex,blackSCNoiseSigmaVerifyFraction, 'color', [0.48 0.06 0.89],'Marker','v', 'MarkerSize', 4);
text(requantizationMainStruct.blackSCIndex(end), blackSCNoiseSigmaVerifyFraction(end), ' \leftarrow ...........black SC', 'color', [0.48 0.06 0.89],'fontweight', 'bold');


vsmearSCNoiseSigmaVerifyFraction = stepSizes(requantizationMainStruct.vsmearSCIndex -1)./(sqrt(requantizationMainStruct.vsmearSCNoiseVarianceMin)*SQRT_12);

h7 =  plot(requantizationMainStruct.vsmearSCIndex,vsmearSCNoiseSigmaVerifyFraction, 'color', [0.04 0.52 0.78], 'Marker','o', 'MarkerSize', 4);
text(fix(mean(requantizationMainStruct.vsmearSCIndex)), ...
    vsmearSCNoiseSigmaVerifyFraction(fix(end/2)), ' \leftarrow ...........vsmear SC', 'color', [0.04 0.52 0.78],'fontweight', 'bold');


msmearSCNoiseSigmaVerifyFraction = stepSizes(requantizationMainStruct.msmearSCIndex-1)./(sqrt(requantizationMainStruct.msmearSCNoiseVarianceMin)*SQRT_12);

h8 =  plot(requantizationMainStruct.msmearSCIndex,msmearSCNoiseSigmaVerifyFraction, 'color', [1 0.69 0.39], 'Marker','+', 'MarkerSize', 4);
text(requantizationMainStruct.msmearSCIndex(end), msmearSCNoiseSigmaVerifyFraction(end), ...
    ' \leftarrow ...........msmear SC', 'color', [1 0.69 0.39],'fontweight', 'bold');





vblackSCNoiseSigmaVerifyFraction = stepSizes(requantizationMainStruct.vblackSCIndex-1)./(sqrt(requantizationMainStruct.vblackSCNoiseVarianceMin)*SQRT_12);

h9 =  plot(requantizationMainStruct.vblackSCIndex,vblackSCNoiseSigmaVerifyFraction, 'color', [0.6 0.2 0], 'Marker','x', 'MarkerSize', 4);
text(fix(mean(requantizationMainStruct.vblackSCIndex)), vblackSCNoiseSigmaVerifyFraction(fix(end/2)),...
    ' \leftarrow ......................................virtual black SC', 'color', [0.6 0.2 0],'fontweight', 'bold');




mblackSCNoiseSigmaVerifyFraction = stepSizes(requantizationMainStruct.mblackSCIndex-1)./(sqrt(requantizationMainStruct.mblackSCNoiseVarianceMin)*SQRT_12);


h10 =  plot(requantizationMainStruct.mblackSCIndex,mblackSCNoiseSigmaVerifyFraction, 'color', 'g', 'Marker','p', 'MarkerSize', 4);
text(fix(mean(requantizationMainStruct.mblackSCIndex)), mblackSCNoiseSigmaVerifyFraction(fix(end/2))+2, ...
    ' \leftarrow .......................................................masked black SC', 'color', 'g','fontweight', 'bold');




legend([h1 h2 h3 h4 h5 h6 h7 h8 h9 h10],{'visible LC'; 'black LC'; 'virtual smear LC'; 'masked smear LC';...
    'visible SC'; 'black SC'; 'virtual smear SC'; 'masked smear SC'; 'virtual black SC';...
    'masked black SC'},'Location', 'Southeast', 'fontsize', 8);

xlabel('Requantization Table Entry Index')
ylabel('Requantization Noise Sigma/Intrinic Noise Sigma')
title('Requantization Table Validation (Requantization Noise Sigma/Intrinic Noise Sigma) ')
grid on;

isOrientationLandscapeFlag = true;
plot_to_file('requantization_table_verify_ratio_for_all_data_types', isOrientationLandscapeFlag);


return
