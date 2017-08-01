function validate_requantization_table_using_monte_carlo_data(requantizationOutputStruct)

% requantizationOutputStruct.requantizationMainStruct
%                           quantizationFraction: 0.20402
%                         maxExpectedRangeStruct: [1x1 struct]
%                                      mainTable: [65305x1 double]
%                mainTableIntrinsicNoiseVariance: [65304x1 double]
%     mainTableOriginalQuantizationNoiseVariance: [65304x1 double]
%         maxPositiveDeviationFromMeanBlackTable: 1755
%         maxNegativeDeviationFromMeanBlackTable: 4523
%                        nominalHighShortCadence: 568607
%                         nominalHighLongCadence: 4623400
%                                mainTableLength: 65305
%                                   lastStepSize: 132
%                                  firstStepSize: 3
%                                 visibleLCIndex: [64550x1 double]
%                              visibleLCStepSize: [64550x1 double]
%                      visibleLCNoiseVarianceMin: [64550x1 double]
%                                   blackLCIndex: [1927x1 double]
%                                blackLCStepSize: [1927x1 double]
%                        blackLCNoiseVarianceMin: [1927x1 double]
%                                  vsmearLCIndex: [28419x1 double]
%                               vsmearLCStepSize: [28419x1 double]
%                       vsmearLCNoiseVarianceMin: [28419x1 double]
%                                  msmearLCIndex: [28419x1 double]
%                               msmearLCStepSize: [28419x1 double]
%                       msmearLCNoiseVarianceMin: [28419x1 double]
%                                 visibleSCIndex: [12258x1 double]
%                              visibleSCStepSize: [12258x1 double]
%                      visibleSCNoiseVarianceMin: [12258x1 double]
%                                   blackSCIndex: [1570x1 double]
%                                blackSCStepSize: [1570x1 double]
%                        blackSCNoiseVarianceMin: [1570x1 double]
%                                  vsmearSCIndex: [5269x1 double]
%                               vsmearSCStepSize: [5269x1 double]
%                       vsmearSCNoiseVarianceMin: [5269x1 double]
%                                  msmearSCIndex: [5269x1 double]
%                               msmearSCStepSize: [5269x1 double]
%                       msmearSCNoiseVarianceMin: [5269x1 double]
%                                  vblackSCIndex: [987x1 double]
%                               vblackSCStepSize: [987x1 double]
%                       vblackSCNoiseVarianceMin: [987x1 double]
%                                  mblackSCIndex: [987x1 double]
%                               mblackSCStepSize: [987x1 double]
%                       mblackSCNoiseVarianceMin: [987x1 double]
% colors
% 'm'
% 'g'
% 'b'
% 'k'
% 'r'
% 'c'
% [0.48 0.06 0.89]);
% [0.75 0 0.75]
% [0.04 0.52 0.78]
% [1 0.69 0.39],
% [0.6 0.2 0]
%
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
if(~exist('requantizationOutputStruct', 'var'))

    if ispc
        load \path\to\matlab\gar\requantization\requantizationOutputStruct.mat;

    else
        load /path/to/matlab/gar/requantization/requantizationOutputStruct.mat;
    end
end

close all;

requantizationMainStruct = requantizationOutputStruct.requantizationMainStruct;
requantizationTable = requantizationOutputStruct.requantizationTable;

nRealizations = 100;
nSamplesPerRealization = 1e4;
requantTableLength = length(requantizationTable);

numberOfTests = 100;

% do this for each data type

%--------------------------------------------------------------------------
% 1. visible short cadence
%--------------------------------------------------------------------------
figure;
hold on;

indexTested = fix(linspace(1,length(requantizationMainStruct.visibleSCNoiseVarianceMin), numberOfTests));
entriesTested = requantizationMainStruct.visibleSCIndex(indexTested);
k = 0;
for j = entriesTested'

    meanValue = requantizationMainStruct.mainTable(j);
    k = k+1;

    stdOfIntrinsicNoise = sqrt(requantizationMainStruct.visibleSCNoiseVarianceMin(indexTested(k)));

    monteCarloDataUnrequantized = meanValue + stdOfIntrinsicNoise* randn(nSamplesPerRealization,nRealizations);

    indexInToRequantTable = interp1(requantizationTable,(1:requantTableLength),monteCarloDataUnrequantized(:),'near');

    monteCarloDataRequantized = reshape(requantizationTable(indexInToRequantTable), nSamplesPerRealization,nRealizations);

    quantizationNoiseSigma = std( monteCarloDataRequantized - monteCarloDataUnrequantized);

    plot(repmat(meanValue,nRealizations,1), quantizationNoiseSigma./std(monteCarloDataUnrequantized), 'b.')

end

ylabel('QuantizationNoiseSigma/IntrinsicNoiseSigma');
xlabel('Requantization Table Entries Applicable to Visible SC');
title('Monte Carlo Results Requantization Table Entries Applicable to Visible SC');
grid on;
paperOrientationFlag = true;
fileNameStr = 'VisibleSC_MonteCarlo';
plot_to_file(fileNameStr, paperOrientationFlag);
close all;

%--------------------------------------------------------------------------
% 2. masked smear short cadence
%--------------------------------------------------------------------------
figure;
hold on;

indexTested = fix(linspace(1,length(requantizationMainStruct.msmearSCNoiseVarianceMin), numberOfTests));
entriesTested = requantizationMainStruct.msmearSCIndex(indexTested);
k = 0;

for j = entriesTested'

    meanValue = requantizationMainStruct.mainTable(j);
    k = k+1;

    stdOfIntrinsicNoise = sqrt(requantizationMainStruct.msmearSCNoiseVarianceMin(indexTested(k)));

    monteCarloDataUnrequantized = meanValue + stdOfIntrinsicNoise* randn(nSamplesPerRealization,nRealizations);

    indexInToRequantTable = interp1(requantizationTable,(1:requantTableLength),monteCarloDataUnrequantized(:),'near');

    monteCarloDataRequantized = reshape(requantizationTable(indexInToRequantTable), nSamplesPerRealization,nRealizations);

    quantizationNoiseSigma = std( monteCarloDataRequantized - monteCarloDataUnrequantized);

    plot(repmat(meanValue,nRealizations,1), quantizationNoiseSigma./std(monteCarloDataUnrequantized), 'b.')

    fprintf('');

end
ylabel('QuantizationNoiseSigma/IntrinsicNoiseSigma');
xlabel('Requantization Table Entries Applicable to Masked Smear SC');
title('Monte Carlo Results Requantization Table Entries Applicable to Masked Smear SC');
grid on;
paperOrientationFlag = true;
fileNameStr = 'MSmearSC_MonteCarlo';
plot_to_file(fileNameStr, paperOrientationFlag);
close all;


%--------------------------------------------------------------------------
% 3. virtual smear short cadence
%--------------------------------------------------------------------------
figure;
hold on;

indexTested = fix(linspace(1,length(requantizationMainStruct.vsmearSCNoiseVarianceMin), numberOfTests));
entriesTested = requantizationMainStruct.vsmearSCIndex(indexTested);
k = 0;

for j = entriesTested'

    meanValue = requantizationMainStruct.mainTable(j);
    k = k+1;

    stdOfIntrinsicNoise = sqrt(requantizationMainStruct.vsmearSCNoiseVarianceMin(indexTested(k)));

    monteCarloDataUnrequantized = meanValue + stdOfIntrinsicNoise* randn(nSamplesPerRealization,nRealizations);

    indexInToRequantTable = interp1(requantizationTable,(1:requantTableLength),monteCarloDataUnrequantized(:),'near');

    monteCarloDataRequantized = reshape(requantizationTable(indexInToRequantTable), nSamplesPerRealization,nRealizations);

    quantizationNoiseSigma = std( monteCarloDataRequantized - monteCarloDataUnrequantized);

    plot(repmat(meanValue,nRealizations,1), quantizationNoiseSigma./std(monteCarloDataUnrequantized), 'b.')

    fprintf('');

end
ylabel('QuantizationNoiseSigma/IntrinsicNoiseSigma');
xlabel('Requantization Table Entries Applicable to Virtual Smear SC');
title('Monte Carlo Results Requantization Table Entries Applicable to Virtual Smear SC');
grid on;
paperOrientationFlag = true;
fileNameStr = 'VSmearSC_MonteCarlo';
plot_to_file(fileNameStr, paperOrientationFlag);
close all;

%--------------------------------------------------------------------------
% 4. black short cadence
%--------------------------------------------------------------------------
figure;
hold on;

indexTested = fix(linspace(1,length(requantizationMainStruct.blackSCNoiseVarianceMin), numberOfTests));
entriesTested = requantizationMainStruct.blackSCIndex(indexTested);
k = 0;

for j = entriesTested'

    meanValue = requantizationMainStruct.mainTable(j);
    k = k+1;

    stdOfIntrinsicNoise = sqrt(requantizationMainStruct.blackSCNoiseVarianceMin(indexTested(k)));

    monteCarloDataUnrequantized = meanValue + stdOfIntrinsicNoise* randn(nSamplesPerRealization,nRealizations);

    indexInToRequantTable = interp1(requantizationTable,(1:requantTableLength),monteCarloDataUnrequantized(:),'near');

    monteCarloDataRequantized = reshape(requantizationTable(indexInToRequantTable), nSamplesPerRealization,nRealizations);

    quantizationNoiseSigma = std( monteCarloDataRequantized - monteCarloDataUnrequantized);

    plot(repmat(meanValue,nRealizations,1), quantizationNoiseSigma./std(monteCarloDataUnrequantized), 'b.')

    fprintf('');

end
ylabel('QuantizationNoiseSigma/IntrinsicNoiseSigma');
xlabel('Requantization Table Entries Applicable to Black SC');
title('Monte Carlo Results Requantization Table Entries Applicable to Black SC');
grid on;
paperOrientationFlag = true;
fileNameStr = 'BlackSC_MonteCarlo';
plot_to_file(fileNameStr, paperOrientationFlag);
close all;

%--------------------------------------------------------------------------
% 5. virtual black short cadence
%--------------------------------------------------------------------------
figure;
hold on;

indexTested = fix(linspace(1,length(requantizationMainStruct.vblackSCNoiseVarianceMin), numberOfTests));
entriesTested = requantizationMainStruct.vblackSCIndex(indexTested);
k = 0;

for j = entriesTested'

    meanValue = requantizationMainStruct.mainTable(j);
    k = k+1;

    stdOfIntrinsicNoise = sqrt(requantizationMainStruct.vblackSCNoiseVarianceMin(indexTested(k)));

    monteCarloDataUnrequantized = meanValue + stdOfIntrinsicNoise* randn(nSamplesPerRealization,nRealizations);

    indexInToRequantTable = interp1(requantizationTable,(1:requantTableLength),monteCarloDataUnrequantized(:),'near');

    monteCarloDataRequantized = reshape(requantizationTable(indexInToRequantTable), nSamplesPerRealization,nRealizations);

    quantizationNoiseSigma = std( monteCarloDataRequantized - monteCarloDataUnrequantized);

    plot(repmat(meanValue,nRealizations,1), quantizationNoiseSigma./std(monteCarloDataUnrequantized), 'b.')

    fprintf('');

end
ylabel('QuantizationNoiseSigma/IntrinsicNoiseSigma');
xlabel('Requantization Table Entries Applicable to Virtual Black SC');
title('Monte Carlo Results Requantization Table Entries Applicable to Virtual Black SC');
grid on;
paperOrientationFlag = true;
fileNameStr = 'VirtualBlackSC_MonteCarlo';
plot_to_file(fileNameStr, paperOrientationFlag);
close all;

%--------------------------------------------------------------------------
% 6. masked black short cadence
%--------------------------------------------------------------------------
figure;
hold on;

indexTested = fix(linspace(1,length(requantizationMainStruct.mblackSCNoiseVarianceMin), numberOfTests));
entriesTested = requantizationMainStruct.mblackSCIndex(indexTested);
k = 0;

for j = entriesTested'

    meanValue = requantizationMainStruct.mainTable(j);
    k = k+1;

    stdOfIntrinsicNoise = sqrt(requantizationMainStruct.mblackSCNoiseVarianceMin(indexTested(k)));

    monteCarloDataUnrequantized = meanValue + stdOfIntrinsicNoise* randn(nSamplesPerRealization,nRealizations);

    indexInToRequantTable = interp1(requantizationTable,(1:requantTableLength),monteCarloDataUnrequantized(:),'near');

    monteCarloDataRequantized = reshape(requantizationTable(indexInToRequantTable), nSamplesPerRealization,nRealizations);

    quantizationNoiseSigma = std( monteCarloDataRequantized - monteCarloDataUnrequantized);

    plot(repmat(meanValue,nRealizations,1), quantizationNoiseSigma./std(monteCarloDataUnrequantized), 'b.')

    fprintf('');

end
ylabel('QuantizationNoiseSigma/IntrinsicNoiseSigma');
xlabel('Requantization Table Entries Applicable to Masked Black SC');
title('Monte Carlo Results Requantization Table Entries Applicable to Masked Black SC');
grid on;
paperOrientationFlag = true;
fileNameStr = 'MaskedBlackSC_MonteCarlo';
plot_to_file(fileNameStr, paperOrientationFlag);
close all;

%--------------------------------------------------------------------------
% 7. visible long cadence
% --------------------------------------------------------------------------
figure;
hold on;

indexTested = fix(linspace(1,length(requantizationMainStruct.visibleLCNoiseVarianceMin), numberOfTests));
entriesTested = requantizationMainStruct.visibleLCIndex(indexTested);
k = 0;

for j = entriesTested'

    meanValue = requantizationMainStruct.mainTable(j);
    k = k+1;

    stdOfIntrinsicNoise = sqrt(requantizationMainStruct.visibleLCNoiseVarianceMin(indexTested(k)));

    monteCarloDataUnrequantized = meanValue + stdOfIntrinsicNoise* randn(nSamplesPerRealization,nRealizations);

    indexInToRequantTable = interp1(requantizationTable,(1:requantTableLength),monteCarloDataUnrequantized(:),'near');

    monteCarloDataRequantized = reshape(requantizationTable(indexInToRequantTable), nSamplesPerRealization,nRealizations);

    quantizationNoiseSigma = std( monteCarloDataRequantized - monteCarloDataUnrequantized);

    plot(repmat(meanValue,nRealizations,1), quantizationNoiseSigma./std(monteCarloDataUnrequantized), 'b.')

    fprintf('');

end
ylabel('QuantizationNoiseSigma/IntrinsicNoiseSigma');
xlabel('Requantization Table Entries Applicable to Visible LC');
title('Monte Carlo Results Requantization Table Entries Applicable to Visible LC');
grid on;
paperOrientationFlag = true;
fileNameStr = 'VisibleLC_MonteCarlo';
plot_to_file(fileNameStr, paperOrientationFlag);

close all;


%--------------------------------------------------------------------------
% 8. black long cadence
% %--------------------------------------------------------------------------
figure;
hold on;

indexTested = fix(linspace(1,length(requantizationMainStruct.blackLCNoiseVarianceMin), numberOfTests));
entriesTested = requantizationMainStruct.blackLCIndex(indexTested);
k = 0;

for j = entriesTested'

    meanValue = requantizationMainStruct.mainTable(j);
    k = k+1;

    stdOfIntrinsicNoise = sqrt(requantizationMainStruct.blackLCNoiseVarianceMin(indexTested(k)));

    monteCarloDataUnrequantized = meanValue + stdOfIntrinsicNoise* randn(nSamplesPerRealization,nRealizations);

    indexInToRequantTable = interp1(requantizationTable,(1:requantTableLength),monteCarloDataUnrequantized(:),'near');

    monteCarloDataRequantized = reshape(requantizationTable(indexInToRequantTable), nSamplesPerRealization,nRealizations);

    quantizationNoiseSigma = std( monteCarloDataRequantized - monteCarloDataUnrequantized);

    plot(repmat(meanValue,nRealizations,1), quantizationNoiseSigma./std(monteCarloDataUnrequantized), 'b.')

    fprintf('');

end
ylabel('QuantizationNoiseSigma/IntrinsicNoiseSigma');
xlabel('Requantization Table Entries Applicable to Black LC');
title('Monte Carlo Results Requantization Table Entries Applicable to Black LC');
grid on;
paperOrientationFlag = true;
fileNameStr = 'BlackLC_MonteCarlo';
plot_to_file(fileNameStr, paperOrientationFlag);
close all;

%--------------------------------------------------------------------------
% 9. Msmear long cadence
% %--------------------------------------------------------------------------
figure;
hold on;

indexTested = fix(linspace(1,length(requantizationMainStruct.msmearLCNoiseVarianceMin), numberOfTests));
entriesTested = requantizationMainStruct.msmearLCIndex(indexTested);
k = 0;

for j = entriesTested'

    meanValue = requantizationMainStruct.mainTable(j);
    k = k+1;

    stdOfIntrinsicNoise = sqrt(requantizationMainStruct.msmearLCNoiseVarianceMin(indexTested(k)));

    monteCarloDataUnrequantized = meanValue + stdOfIntrinsicNoise* randn(nSamplesPerRealization,nRealizations);

    indexInToRequantTable = interp1(requantizationTable,(1:requantTableLength),monteCarloDataUnrequantized(:),'near');

    monteCarloDataRequantized = reshape(requantizationTable(indexInToRequantTable), nSamplesPerRealization,nRealizations);

    quantizationNoiseSigma = std( monteCarloDataRequantized - monteCarloDataUnrequantized);

    plot(repmat(meanValue,nRealizations,1), quantizationNoiseSigma./std(monteCarloDataUnrequantized), 'b.')

    fprintf('');

end
ylabel('QuantizationNoiseSigma/IntrinsicNoiseSigma');
xlabel('Requantization Table Entries Applicable to Masked Smear LC');
title('Monte Carlo Results Requantization Table Entries Applicable to MSmear LC');
grid on;
paperOrientationFlag = true;
fileNameStr = 'MSmearLC_MonteCarlo';
plot_to_file(fileNameStr, paperOrientationFlag);
close all;

%--------------------------------------------------------------------------
% 10. Vsmear long cadence
%--------------------------------------------------------------------------
figure;
hold on;

indexTested = fix(linspace(1,length(requantizationMainStruct.vsmearLCNoiseVarianceMin), numberOfTests));
entriesTested = requantizationMainStruct.vsmearLCIndex(indexTested);
k = 0;

for j = entriesTested'

    meanValue = requantizationMainStruct.mainTable(j);
    k = k+1;

    stdOfIntrinsicNoise = sqrt(requantizationMainStruct.vsmearLCNoiseVarianceMin(indexTested(k)));

    monteCarloDataUnrequantized = meanValue + stdOfIntrinsicNoise* randn(nSamplesPerRealization,nRealizations);

    indexInToRequantTable = interp1(requantizationTable,(1:requantTableLength),monteCarloDataUnrequantized(:),'near');

    monteCarloDataRequantized = reshape(requantizationTable(indexInToRequantTable), nSamplesPerRealization,nRealizations);

    quantizationNoiseSigma = std( monteCarloDataRequantized - monteCarloDataUnrequantized);

    plot(repmat(meanValue,nRealizations,1), quantizationNoiseSigma./std(monteCarloDataUnrequantized), 'b.')

    fprintf('');

end

ylabel('QuantizationNoiseSigma/IntrinsicNoiseSigma');
xlabel('Requantization Table Entries Applicable to Virtual Smear LC');
title('Monte Carlo Results Requantization Table Entries Applicable to VSmear LC');
grid on;
paperOrientationFlag = true;
fileNameStr = 'VSmearLC_MonteCarlo';
plot_to_file(fileNameStr, paperOrientationFlag);
close all;

fprintf('');