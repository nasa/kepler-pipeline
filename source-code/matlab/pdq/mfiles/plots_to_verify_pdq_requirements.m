% pdqOutputStruct
%
% pdqOutputStruct =
%
%                       outputPdqTsData: [1x1 struct]
%                   attitudeAdjustments: [1x200 struct]
%                pdqModuleOutputReports: [84x1 struct]
%                   pdqFocalPlaneReport: [1x1 struct]
%                      attitudeSolution: [200x3 double]
%     attitudeSolutionUncertaintyStruct: [200x1 struct]
%
% pdqOutputStruct.outputPdqTsData
%
% ans =
%
%             pdqModuleOutputTsData: [84x1 struct]
%                      cadenceTimes: [200x1 double]
%                attitudeSolutionRa: [1x1 struct]
%               attitudeSolutionDec: [1x1 struct]
%              attitudeSolutionRoll: [1x1 struct]
%                 desiredAttitudeRa: [1x1 struct]
%                desiredAttitudeDec: [1x1 struct]
%               desiredAttitudeRoll: [1x1 struct]
%                   deltaAttitudeRa: [1x1 struct]
%                  deltaAttitudeDec: [1x1 struct]
%                 deltaAttitudeRoll: [1x1 struct]
%     maxAttitudeResidualInPixels: [1x1 struct]
%
% pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(1)
%
% ans =
%
%             ccdModule: 2
%             ccdOutput: 1
%           blackLevels: [1x1 struct]
%           smearLevels: [1x1 struct]
%          darkCurrents: [1x1 struct]
%      backgroundLevels: [1x1 struct]
%         dynamicRanges: [1x1 struct]
%            meanFluxes: [1x1 struct]
%     centroidsMeanRows: [1x1 struct]
%     centroidsMeanCols: [1x1 struct]
%     encircledEnergies: [1x1 struct]
%           plateScales: [1x1 struct]
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

clc;
close all;
% only the following modouts are present
% modoutsProcessed = [ 1    10    15    20    25    32    35    40    50    56    60    65    71    74    84]';

modoutsProcessed = 1;

for j=1:length(modoutsProcessed)

    dirName = ['modOut_' num2str(modoutsProcessed(j))];

    if(~exist(dirName,'dir'))
        mkdir(dirName);
    end

    cd(dirName);


    %--------------------------------------------------------------------------
    labelX = 'Monte Carlo Run Number';
    labelY = 'Scatter from Mean';
    legend1 = 'Scatter from Mean across Runs';
    legend2 = 'Predicted Uncertainty';
    [module, output] = convert_to_module_output(modoutsProcessed(j));


    %--------------------------------------------------------------------------

    titleStr = ['centroidsMeanRows Metric for {' num2str(module) ',' num2str(output) '} [' num2str(modoutsProcessed(j)) ']'];

    plot_metric_time_series(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(modoutsProcessed(j)).centroidsMeanRows,...
        labelX, labelY, legend1, legend2, titleStr);
    close all;


    %--------------------------------------------------------------------------

    titleStr = ['centroidsMeanCols Metric for {' num2str(module) ',' num2str(output) '} [' num2str(modoutsProcessed(j)) ']'];

    plot_metric_time_series(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(modoutsProcessed(j)).centroidsMeanCols,...
        labelX, labelY, legend1, legend2, titleStr);
    close all;



    %--------------------------------------------------------------------------
















    cd ..

    fprintf('');



end




