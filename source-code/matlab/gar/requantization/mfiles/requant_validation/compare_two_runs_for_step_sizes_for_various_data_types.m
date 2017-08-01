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
function  compare_two_runs_for_step_sizes_for_various_data_types(requantizationMainStruct1, requantizationMainStruct2)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% run colorPalette to get numerical values for different colors
%

% requantizationMainStruct =
%                                      mainTable: [51192x1 double]
%                mainTableIntrinsicNoiseVariance: [51191x1 double]
%     mainTableOriginalQuantizationNoiseVariance: [51191x1 double]
%         maxPositiveDeviationFromMeanBlackTable: 1139
%         maxNegativeDeviationFromMeanBlackTable: 4623
%                        nominalHighShortCadence: 567991
%                         nominalHighLongCadence: 4622784
%                                mainTableLength: 51192
%                           quantizationFraction: 0.2500
%                                   lastStepSize: 162
%                                  firstStepSize: 4
%                                 visibleLCIndex: [42747x1 double]
%                              visibleLCStepSize: [42747x1 double]
%                      visibleLCNoiseVarianceMin: [42747x1 double]
%                                   blackLCIndex: [15513x1 double]
%                                blackLCStepSize: [15513x1 double]
%                        blackLCNoiseVarianceMin: [15513x1 double]
%                                  vsmearLCIndex: [35857x1 double]
%                               vsmearLCStepSize: [35857x1 double]
%                       vsmearLCNoiseVarianceMin: [35857x1 double]
%                                  msmearLCIndex: [35857x1 double]
%                               msmearLCStepSize: [35857x1 double]
%                       msmearLCNoiseVarianceMin: [35857x1 double]
%                                 visibleSCIndex: [19925x1 double]
%                              visibleSCStepSize: [19925x1 double]
%                      visibleSCNoiseVarianceMin: [19925x1 double]
%                                   blackSCIndex: [15502x1 double]
%                                blackSCStepSize: [15502x1 double]
%                        blackSCNoiseVarianceMin: [15502x1 double]
%                                  vsmearSCIndex: [17754x1 double]
%                               vsmearSCStepSize: [17754x1 double]
%                       vsmearSCNoiseVarianceMin: [17754x1 double]
%                                  msmearSCIndex: [17754x1 double]
%                               msmearSCStepSize: [17754x1 double]
%                       msmearSCNoiseVarianceMin: [17754x1 double]
%                                  vblackSCIndex: [14832x1 double]
%                               vblackSCStepSize: [14832x1 double]
%                       vblackSCNoiseVarianceMin: [14832x1 double]
%                                  mblackSCIndex: [14832x1 double]
%                               mblackSCStepSize: [14832x1 double]
%                       mblackSCNoiseVarianceMin: [14832x1 double]


figure;
h1 =  plot(requantizationMainStruct1.visibleLCIndex, requantizationMainStruct1.visibleLCStepSize, 'b');
hold on;
text(fix(mean(requantizationMainStruct1.visibleLCIndex)), requantizationMainStruct1.visibleLCStepSize(fix(end/2)), ' \leftarrow ...........visible LC', 'color','b','fontweight', 'bold');

h2 =  plot(requantizationMainStruct1.blackLCIndex, requantizationMainStruct1.blackLCStepSize, 'k');
text(fix(mean(requantizationMainStruct1.blackLCIndex)), requantizationMainStruct1.blackLCStepSize(fix(end/2)), ' \leftarrow ...........black LC','color','k','fontweight', 'bold');

h3 =  plot(requantizationMainStruct1.vsmearLCIndex, requantizationMainStruct1.vsmearLCStepSize, 'color', [0.48 0.06 0.89]);
text(fix(mean(requantizationMainStruct1.vsmearLCIndex)), requantizationMainStruct1.vsmearLCStepSize(fix(end/2)), ' \leftarrow ...........vsmear LC','color', [0.48 0.06 0.89],'fontweight', 'bold');

h4 =  plot(requantizationMainStruct1.msmearLCIndex, requantizationMainStruct1.msmearLCStepSize, 'r');
text(requantizationMainStruct1.msmearLCIndex(end), requantizationMainStruct1.msmearLCStepSize(end),...
    ' \leftarrow ...........msmear LC','color','r','fontweight', 'bold');


h5 =  plot(requantizationMainStruct1.visibleSCIndex,requantizationMainStruct1.visibleSCStepSize, 'color', [0.75 0 0.75], 'Marker','*', 'MarkerSize', 4);
text(requantizationMainStruct1.visibleSCIndex(end), requantizationMainStruct1.visibleSCStepSize(end), ' \leftarrow ...........visible SC', 'color', [0.75 0 0.75],'fontweight', 'bold');

h6 =  plot(requantizationMainStruct1.blackSCIndex, requantizationMainStruct1.blackSCStepSize, 'color', [0.68 0.47 0],'Marker','v', 'MarkerSize', 4);
text(requantizationMainStruct1.blackSCIndex(end), requantizationMainStruct1.blackSCStepSize(end), ' \leftarrow ...........black SC', 'color', [0.68 0.47 0],'fontweight', 'bold');


h7 =  plot(requantizationMainStruct1.vsmearSCIndex, requantizationMainStruct1.vsmearSCStepSize, 'color', [0.04 0.52 0.78], 'Marker','o', 'MarkerSize', 4);
text(fix(mean(requantizationMainStruct1.vsmearSCIndex)), ...
    requantizationMainStruct1.vsmearSCStepSize(fix(end/2)), ' \leftarrow ...........vsmear SC', 'color', [0.04 0.52 0.78],'fontweight', 'bold');

h8 =  plot(requantizationMainStruct1.msmearSCIndex, requantizationMainStruct1.msmearSCStepSize, 'color', [1 0.69 0.39], 'Marker','+', 'MarkerSize', 4);
text(requantizationMainStruct1.msmearSCIndex(end), requantizationMainStruct1.msmearSCStepSize(end), ...
    ' \leftarrow ...........msmear SC', 'color', [1 0.69 0.39],'fontweight', 'bold');

h9 =  plot(requantizationMainStruct1.vblackSCIndex,requantizationMainStruct1.vblackSCStepSize, 'color', [0.6 0.2 0], 'Marker','x', 'MarkerSize', 4);
text(fix(mean(requantizationMainStruct1.vblackSCIndex)), requantizationMainStruct1.vblackSCStepSize(fix(end/2)),...
    ' \leftarrow ......................................virtual black SC', 'color', [0.6 0.2 0],'fontweight', 'bold');

h10 =  plot(requantizationMainStruct1.mblackSCIndex,requantizationMainStruct1.mblackSCStepSize, 'color', 'g', 'Marker','p', 'MarkerSize', 4);
text(fix(mean(requantizationMainStruct1.mblackSCIndex)), requantizationMainStruct1.mblackSCStepSize(fix(end/2))+2, ...
    ' \leftarrow .......................................................masked black SC', 'color', 'g','fontweight', 'bold');



h11 =  plot(requantizationMainStruct2.visibleLCIndex, requantizationMainStruct2.visibleLCStepSize, 'bx');
hold on;
text(fix(mean(requantizationMainStruct2.visibleLCIndex)), requantizationMainStruct2.visibleLCStepSize(fix(end/2)), ' \leftarrow ...........visible LC', 'color','b','fontweight', 'bold');

h12 =  plot(requantizationMainStruct2.blackLCIndex, requantizationMainStruct2.blackLCStepSize, 'kx');
text(fix(mean(requantizationMainStruct2.blackLCIndex)), requantizationMainStruct2.blackLCStepSize(fix(end/2)), ' \leftarrow ...........black LC','color','k','fontweight', 'bold');

h13 =  plot(requantizationMainStruct2.vsmearLCIndex, requantizationMainStruct2.vsmearLCStepSize, 'color', [0.48 0.06 0.89]);
text(fix(mean(requantizationMainStruct2.vsmearLCIndex)), requantizationMainStruct2.vsmearLCStepSize(fix(end/2)), ' \leftarrow ...........vsmear LC','color', [0.48 0.06 0.89],'fontweight', 'bold');

h14 =  plot(requantizationMainStruct2.msmearLCIndex, requantizationMainStruct2.msmearLCStepSize, 'rx');
text(requantizationMainStruct2.msmearLCIndex(end), requantizationMainStruct2.msmearLCStepSize(end),...
    ' \leftarrow ...........msmear LC','color','r','fontweight', 'bold');


h15 =  plot(requantizationMainStruct2.visibleSCIndex,requantizationMainStruct2.visibleSCStepSize, 'color', [0.75 0 0.75], 'Marker','o', 'MarkerSize', 4);
text(requantizationMainStruct2.visibleSCIndex(end), requantizationMainStruct2.visibleSCStepSize(end), ' \leftarrow ...........visible SC', 'color', [0.75 0 0.75],'fontweight', 'bold');

h16 =  plot(requantizationMainStruct2.blackSCIndex, requantizationMainStruct2.blackSCStepSize, 'color', [0.68 0.47 0],'Marker','p', 'MarkerSize', 4);
text(requantizationMainStruct2.blackSCIndex(end), requantizationMainStruct2.blackSCStepSize(end), ' \leftarrow ...........black SC', 'color', [0.68 0.47 0],'fontweight', 'bold');


h17 =  plot(requantizationMainStruct2.vsmearSCIndex, requantizationMainStruct2.vsmearSCStepSize, 'color', [0.04 0.52 0.78], 'Marker','x', 'MarkerSize', 4);
text(fix(mean(requantizationMainStruct2.vsmearSCIndex)), ...
    requantizationMainStruct2.vsmearSCStepSize(fix(end/2)), ' \leftarrow ...........vsmear SC', 'color', [0.04 0.52 0.78],'fontweight', 'bold');

h18 =  plot(requantizationMainStruct2.msmearSCIndex, requantizationMainStruct2.msmearSCStepSize, 'color', [1 0.69 0.39], 'Marker','^', 'MarkerSize', 4);
text(requantizationMainStruct2.msmearSCIndex(end), requantizationMainStruct2.msmearSCStepSize(end), ...
    ' \leftarrow ...........msmear SC', 'color', [1 0.69 0.39],'fontweight', 'bold');

h19 =  plot(requantizationMainStruct2.vblackSCIndex,requantizationMainStruct2.vblackSCStepSize, 'color', [0.6 0.2 0], 'Marker','s', 'MarkerSize', 4);
text(fix(mean(requantizationMainStruct2.vblackSCIndex)), requantizationMainStruct2.vblackSCStepSize(fix(end/2)),...
    ' \leftarrow ......................................virtual black SC', 'color', [0.6 0.2 0],'fontweight', 'bold');

h20 =  plot(requantizationMainStruct2.mblackSCIndex,requantizationMainStruct2.mblackSCStepSize, 'color', 'g', 'Marker','*', 'MarkerSize', 4);
text(fix(mean(requantizationMainStruct2.mblackSCIndex)), requantizationMainStruct2.mblackSCStepSize(fix(end/2))+2, ...
    ' \leftarrow .......................................................masked black SC', 'color', 'g','fontweight', 'bold');





legend([h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13 h14 h15 h16 h17 h18 h19 h20],{'visible LC1'; 'black LC1'; 'virtual smear LC1'; 'masked smear LC1';...
    'visible SC1'; 'black SC1'; 'virtual smear SC1'; 'masked smear SC1'; 'virtual black SC1';'masked black SC1';'visible LC2'; 'black LC2'; 'virtual smear LC2'; 'masked smear LC2';...
    'visible SC2'; 'black SC2'; 'virtual smear SC2'; 'masked smear SC2'; 'virtual black SC2';'masked black SC2'},'Location', 'Southeast', 'fontsize', 8);

xlabel('Requantization Table Entry Index')
ylabel('Step size in ADU')
title('Requantization Table Step Sizes for Various Data Types')
grid on;

isOrientationLandscapeFlag = true;
plot_to_file('requantization_table_step_sizes_comparison', isOrientationLandscapeFlag);


return
