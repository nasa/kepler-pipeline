% plot_effects_of_pdc.m
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
clc;
close all;
% dirNames = dir('tps-matlab*')
% runDirNames = {dirNames.name}
% load tpsModuleParameters



dirNames = dir('pdc-matlab*')
runDirNames = {dirNames.name}';



% run first 14

baseDir = pwd;

for jModOut = 1:84
    %    load tpsModuleParameters;

    eval(['cd ' runDirNames{jModOut}]);

    disp(pwd)


    currentDir = pwd;

    load pdc-inputs-0;


    nTargets = length(inputsStruct.targetDataStruct);

    for jTarget = 1:nTargets,
        inputsStruct.targetDataStruct(jTarget).gapIndicators([136 281 383]) = true; % momentum desat cadences
        inputsStruct.targetDataStruct(jTarget).values([136 281 383]) = NaN; % momentum desat cadences
    end

    load  pdcOutputStruct ;

    %load tpsOutputStruct;
    delete *_PDC.jpg
    delete *_PDC.fig
    load tpsOutputStruct_short_transit.mat;


    % lower the transit search threshold here....
    ispIndex = find([tpsOutputStruct.tpsResults.maxMultipleEventStatistic] > 5.0);

    isPlanetACandidate = false(length(tpsOutputStruct.tpsResults),1);
    isPlanetACandidate(ispIndex) = true;

    for k =1:length(tpsOutputStruct.tpsResults)

        tpsOutputStruct.tpsResults(k).isPlanetACandidate = isPlanetACandidate(k);
    end


    isLandscapeOrientationFlag = true;
    includeTimeFlag = false;
    printJpgFlag = true;
    close all;

    isp = find([tpsOutputStruct.tpsResults.isPlanetACandidate]);
    isp = unique(mod(isp,nTargets));

    ispResetIndex = find(isp == 0);

    if(~isempty(ispResetIndex))
        isp(ispResetIndex) = nTargets;

    end



    nCadences = length(inputsStruct.cadenceTimes.cadenceNumbers);

    for j = 1:length(isp),

        xaxisInDays = (1:nCadences)./48.939;

        subplot(2,1,1);

        plot(xaxisInDays, inputsStruct.targetDataStruct(isp(j)).values, '.-'),
        keplerId = inputsStruct.targetDataStruct(isp(j)).keplerId;
        keplerMag = inputsStruct.targetDataStruct(isp(j)).keplerMag;



        titleStr1 = ['keplerId = ' num2str(keplerId) 'keplerMag = ' num2str(keplerMag)];
        titleStr2 = ['input to PDC (Pre-Search Data Conditioning'];


        xlabel('in days (48.939 cadences /day)');
        ylabel('in photo electrons');

        titleStr = [num2str(keplerId) '_PDC'];
        title({titleStr1;titleStr2 });

        subplot(2,1,2);

        plot(xaxisInDays, pdcOutputStruct.targetResultsStruct(isp(j)).correctedFluxTimeSeries.values, '.-'),

        titleStr1 = ['keplerId = ' num2str(keplerId) 'keplerMag = ' num2str(keplerMag)];
        titleStr2 = ['output of PDC (Pre-Search Data Conditioning'];

        title({titleStr1;titleStr2 });



        xlabel('in days (48.939 cadences /day)');
        ylabel('in photo electrons');

        plot_to_file(titleStr, isLandscapeOrientationFlag, includeTimeFlag, printJpgFlag);

    end
    close all;


    % copy figs to nfs


    dirNameStr = ['/path/to/c043-tps-results-shorter-transits/' runDirNames{jModOut}]


    if(~exist(dirNameStr, 'dir'))
        eval(['mkdir ' dirNameStr])
    end

    sourceFileStr = '*.fig';
    eval(['dirStruct = dir(''' sourceFileStr ''');'])

    if(~isempty(dirStruct))
        eval(['copyfile '''  sourceFileStr '''  ' dirNameStr ' ' '''f''']);
    end

    sourceFileStr = '*.jpg';
    eval(['dirStruct = dir(''' sourceFileStr ''');'])

    if(~isempty(dirStruct))
        eval(['copyfile '''  sourceFileStr '''  ' dirNameStr ' ' '''f''']);
    end

    dirNameStr = '/path/to/c043-tps-results-shorter-transits/jpg-images/' ;

    sourceFileStr = '*.jpg';
    eval(['dirStruct = dir(''' sourceFileStr ''');'])

    if(~isempty(dirStruct))
        eval(['copyfile '''  sourceFileStr '''  ' dirNameStr ' ' '''f''']);
    end


    eval(['cd ' baseDir])

    clear pdcOutputStruct tpsOutputStruct;

end