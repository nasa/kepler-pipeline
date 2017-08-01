% collect_cdpp_for_tps_sc_from_pdc.m
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

dirNames = dir('pdc-matlab*');
runDirNames = {dirNames.name}';

% run first 14

baseDir = pwd;


nCount = 0;
scLcCdpp = repmat(struct('keplerId', -1, 'keplerMag', -1, 'ccdModule', -1, 'ccdOutput', -1, 'cdppSc6hrTimeSeries',[], 'cdppSc6hrRms', -1, ...
    'cdppLc6hrTimeSeries', [], 'cdppLc6hrRms', -1, 'fluxTimeSeriesSc', [], 'gapIndicesSc', [],...
    'fluxTimeSeriesLc', [], 'gapIndicesLc', []), 500,1);


for j = 1:length(runDirNames)


    eval(['cd ' runDirNames{j}]);

    load tpsInputStruct.mat
    load tpsOutputStruct.mat
    load pdc-inputs-0.mat

    disp(pwd)

    currentDir = pwd;

    nTargets = length(tpsInputStruct.tpsTargets);

    for k=1:nTargets

        nCount = nCount+1;


        scLcCdpp(nCount).keplerId = tpsInputStruct.tpsTargets(k).keplerId;
        scLcCdpp(nCount).keplerMag = tpsInputStruct.tpsTargets(k).kepMag;

        scLcCdpp(nCount).ccdModule = inputsStruct.ccdModule;
        scLcCdpp(nCount).ccdOutput = inputsStruct.ccdOutput;

        scLcCdpp(nCount).fluxTimeSeriesSc = tpsInputStruct.tpsTargets(k).fluxValue;
        scLcCdpp(nCount).gapIndicesSc = tpsInputStruct.tpsTargets(k).gapIndices+1;


        scLcCdpp(nCount).cdppSc6hrTimeSeries = tpsOutputStruct.tpsResults(nTargets+k).cdppTimeSeries;
        scLcCdpp(nCount).cdppSc6hrRms = tpsOutputStruct.tpsResults(nTargets+k).rmsCdpp;


    end


    eval(['cd ' baseDir])

    disp(pwd)

end


scLcCdpp(nCount+1:end) = [];

save scLcCdpp.mat scLcCdpp;

