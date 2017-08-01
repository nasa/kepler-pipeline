% This program generates data for the unit test of eclipsing binary discrimanation (EBD)
% The genarated data are stored in targetResultsStruct.mat file.
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

clear;
close all;

statisticStruct             = struct('value', 0, 'significance', -1);
periodStatisticStruct       = struct('planetNumber', 0, 'value', 0, 'significance', -1);

binaryDiscriminationResults = struct('oddEvenTransitDepthComparisonStatistic',   statisticStruct, ...
                                     'oddEvenTransitEpochComparisonStatistic',   statisticStruct, ...
                                     'singleTransitDepthComparisonStatistic',    statisticStruct, ...
                                     'singleTransitDurationComparisonStatistic', statisticStruct, ...
                                     'singleTransitEpochComparisonStatistic',    statisticStruct, ...
                                     'shorterPeriodComparisonStatistic',         periodStatisticStruct, ...
                                     'longerPeriodComparisonStatistic',          periodStatisticStruct);

epochValue          = 0.5;      % MJD
depthValue          = 20;       % ppm
durationValue       = 10;       % hour

deltaDepthValue     = 1; 

periodUncertainty   = 1.24;
epochUncertainty    = 1.13;
depthUncertainty    = 1.26;
durationUncertainty = 1.17;

keplerId = 10001;
dvResultsStruct.targetResultsStruct.keplerId = keplerId;
dvResultsStruct.targetResultsStruct.dvFiguresRootDirectory = sprintf('target-%09d', keplerId);

nPlanets = 5;
for jPlanet = 1:nPlanets
    
    planetNumber        = jPlanet;

    periodValue         = 10 + 2*planetNumber;
    oddPeriodValue      = periodValue;
    evenPeriodValue     = periodValue;

    oddEpochValue       = epochValue;
    evenEpochValue      = oddEpochValue + periodValue;

    oddDepthValue       = depthValue;
    evenDepthValue      = oddDepthValue;

    allModelParameters(1)  = struct('name', 'transitDepthPpm',      'value', depthValue,      'uncertainty', depthUncertainty*(1+0.2*rand(1)),    'fitted', true);
    allModelParameters(2)  = struct('name', 'transitEpochBkjd',     'value', epochValue,      'uncertainty', epochUncertainty*(1+0.2*rand(1)),    'fitted', true);
    allModelParameters(3)  = struct('name', 'orbitalPeriodDays',    'value', periodValue,     'uncertainty', periodUncertainty*(1+0.2*rand(1)),   'fitted', true);
    allModelParameters(4)  = struct('name', 'transitDurationHours', 'value', durationValue,   'uncertainty', durationUncertainty*(1+0.2*rand(1)), 'fitted', true);

    oddModelParameters(1)  = struct('name', 'transitDepthPpm',      'value', oddDepthValue,   'uncertainty', depthUncertainty*(1+0.2*rand(1)),    'fitted', true);
    oddModelParameters(2)  = struct('name', 'transitEpochBkjd',     'value', oddEpochValue,   'uncertainty', epochUncertainty*(1+0.2*rand(1)),    'fitted', true);
    oddModelParameters(3)  = struct('name', 'orbitalPeriodDays',    'value', oddPeriodValue,  'uncertainty', periodUncertainty*(1+0.2*rand(1)),   'fitted', true);
    oddModelParameters(4)  = struct('name', 'transitDurationHours', 'value', durationValue,   'uncertainty', durationUncertainty*(1+0.2*rand(1)), 'fitted', true);

    evenModelParameters(1) = struct('name', 'transitDepthPpm',      'value', evenDepthValue,  'uncertainty', depthUncertainty*(1+0.2*rand(1)),    'fitted', true);
    evenModelParameters(2) = struct('name', 'transitEpochBkjd',      'value', evenEpochValue,  'uncertainty', epochUncertainty*(1+0.2*rand(1)),    'fitted', true);
    evenModelParameters(3) = struct('name', 'orbitalPeriodDays',    'value', evenPeriodValue, 'uncertainty', periodUncertainty*(1+0.2*rand(1)),   'fitted', true);
    evenModelParameters(4) = struct('name', 'transitDurationHours', 'value', durationValue,   'uncertainty', durationUncertainty*(1+0.2*rand(1)), 'fitted', true);

    oneModelParameters(1)  = struct('name', 'transitDepthPpm',      'value', depthValue,      'uncertainty', depthUncertainty,                    'fitted', true);
    oneModelParameters(2)  = struct('name', 'transitEpochBkjd',     'value', epochValue,      'uncertainty', epochUncertainty,                    'fitted', true);
    oneModelParameters(3)  = struct('name', 'orbitalPeriodDays',    'value', periodValue,     'uncertainty', periodUncertainty,                   'fitted', true);
    oneModelParameters(4)  = struct('name', 'transitDurationHours', 'value', durationValue,   'uncertainty', durationUncertainty,                 'fitted', true);

    allTransitsFit         = struct('keplerId',        keplerId,                                  ...
                                    'planetNumber',    planetNumber,                              ...
                                    'modelParameters', allModelParameters );

    oddTransitsFit         = struct('keplerId',        keplerId,                                  ...
                                    'planetNumber',    planetNumber,                              ...
                                    'modelParameters', oddModelParameters );

    evenTransitsFit        = struct('keplerId',        keplerId,                                  ...
                                    'planetNumber',    planetNumber,                              ...
                                    'modelParameters', evenModelParameters );
                                
    oneTransitFit          = struct('keplerId',        keplerId,                                  ...
                                    'planetNumber',    planetNumber,                              ...
                                    'modelParameters', oneModelParameters );
    singleTransitFits      = repmat(oneTransitFit, 1, jPlanet+3);

    dvResultsStruct.targetResultsStruct.planetResultsStruct(jPlanet) = struct(  'keplerId',                     keplerId, ...
                                                                                'planetNumber',                 planetNumber, ...
                                                                                'allTransitsFit',               allTransitsFit, ...
                                                                                'oddTransitsFit',               oddTransitsFit, ...
                                                                                'evenTransitsFit',              evenTransitsFit, ...
                                                                                'singleTransitFits',            singleTransitFits, ...
                                                                                'binaryDiscriminationResults',  binaryDiscriminationResults );
    
    for iTransit = 1:length(singleTransitFits)
            
        dvResultsStruct.targetResultsStruct.planetResultsStruct(jPlanet).singleTransitFits(iTransit).modelParameters(1).value        = depthValue + (iTransit-1)*deltaDepthValue;
            
        dvResultsStruct.targetResultsStruct.planetResultsStruct(jPlanet).singleTransitFits(iTransit).modelParameters(2).value        = epochValue + (iTransit-1)^2*periodValue;

        dvResultsStruct.targetResultsStruct.planetResultsStruct(jPlanet).singleTransitFits(iTransit).modelParameters(1).uncertainty  = depthUncertainty*(1+0.2*rand(1));
        dvResultsStruct.targetResultsStruct.planetResultsStruct(jPlanet).singleTransitFits(iTransit).modelParameters(2).uncertainty  = epochUncertainty*(1+0.2*rand(1));
        dvResultsStruct.targetResultsStruct.planetResultsStruct(jPlanet).singleTransitFits(iTransit).modelParameters(3).uncertainty  = periodUncertainty*(1+0.2*rand(1));
        dvResultsStruct.targetResultsStruct.planetResultsStruct(jPlanet).singleTransitFits(iTransit).modelParameters(4).uncertainty  = durationUncertainty*(1+0.2*rand(1));
           
    end

end

dvResultsStruct.alerts = [];

save dvResultsStruct.mat dvResultsStruct

