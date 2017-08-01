function extract_etem_ground_truth_for_dv(etemRunDirPath, dvDirPath)
%
% function to extract the ground truth from etem run directories for each
% dv input struct.
%
%
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



if nargin == 0

    % etemRunDirPath = '/path/to/matlab/dv/etem_pipeline_runs';
    % etemRunDirPath = '/path/to/matlab/dv/etem_pipeline_runs/run_long_m2o4s1/';

    etemRunDirPath = '/path/to/dev-pipeline/30Aug2009/etem/long/';

    dvDirPath = '/path/to/dev-pipeline/30Aug2009/'; 
end

cd(etemRunDirPath)


%--------------------------------------------------------------------------
% extract etem ground truth for all mod/outs, save for all Kepler IDs
% (takes too long to keep reloading matfiles for each individual Kepler ID)
%--------------------------------------------------------------------------
etemRuns = dir('run_long*');

numEtemRuns = length(etemRuns);



keplerIdList = repmat(struct('backgroundBinaryKeplerIDs', [], 'targetListKeplerIDs', []), numEtemRuns, 1);

for i = 1:numEtemRuns

    dirString = etemRuns(i).name;

    cd(etemRunDirPath)
    cd(dirString)

    display('Loading etem2 ground truth data');

    display(['Loading scienceTargetList for input struct  ' num2str(i) ' of ' num2str(numEtemRuns)]);
    load scienceTargetList.mat


    %----------------------------------------------------------------------
    %  scienceTargetList.mat:
    %----------------------------------------------------------------------
    %
    %  planeStars                   1x1                 310192  struct
    %  runStartTime                 1x1                      8  double
    %
    %  backgroundBinaryList     1x20 struct array
    %
    %     ex. backgroundBinaryList(1)
    %
    %         initialData:      [1x1 struct]
    %         object:           []
    %         targetKeplerId:   8429566
    %        *lightCurve:       [2016x1 double]
    %        *timeVector:       [2016x1 double]
    %        *lightCurveData:   [1x1 struct]
    %
    %
    %
    %  targetList               1x2007 struct array
    %
    %     ex. targetList(1)
    %
    %         keplerId:             8234611
    %         lightCurveList:       [1x1 struct]
    %         lightCurveData:       []
    %        *compositeLightCurve:  [2016x1 double]
    %         keplerMagnitude:      12.9890
    %         ra:                   292.2815
    %         dec:                  44.1043
    %         logSurfaceGravity:    4.3310
    %         logMetallicity:       -0.3750
    %         effectiveTemperature: 6052
    %         flux:                 8.6103e+04
    %         row:                  216
    %         column:               424
    %         rowFraction:          10
    %         columnFraction:       2
    %         visiblePixelIndex:    421060
    %         subPixelIndex:        20
    %         initialData:          [1x1 struct]
    %
    %
    %
    %   targetScienceProperties      1x10 struct array
    %
    %      ex. targetScienceProperties(1)
    %
    %         description: 'SOHO-based stellar variability'
    %         keplerId: [1x2007 double]
    %
    %         targetScienceProperties(2)
    %
    %         description: 'Short Period Transiting Earths'
    %         keplerId: [1x20 double]
    %
    %----------------------------------------------------------------------


    keplerIdList(i).backgroundBinaryKeplerIDs  = [backgroundBinaryList.targetKeplerId]';

    keplerIdList(i).targetListKeplerIDs        = [targetList.keplerId]';

    
    backgroundBinaryList1     = backgroundBinaryList;
    targetList1               = targetList;


    display(['Loading targetScienceManagerData for input struct  ' num2str(i) ' of ' num2str(numEtemRuns)]);
    load targetScienceManagerData



    %----------------------------------------------------------------------
    % targetScienceManagerData.mat
    %----------------------------------------------------------------------
    %
    %             targetSpecifiction: [1x10 struct]
    %  backgroundBinarySpecification: [1x1 struct]
    %                     targetList: [1x2007 struct]
    %           backgroundBinaryList: [1x20 struct]
    %
    %
    %     REDUNDANT
    %     %     targetList    1x2007 struct array
    %     %
    %     %        ex.  targetScienceManagerData.targetList(1)
    %     %
    %     %             keplerId:            8234611
    %     %             lightCurveList:      [1x1 struct]
    %     %             lightCurveData:      []
    %     %             compositeLightCurve: []
    %     %             keplerMagnitude:     12.9890
    %     %             ra:                  292.2815
    %     %             dec:                 44.1043
    %     %             logSurfaceGravity:   4.3310
    %     %             logMetallicity:      -0.3750
    %     %             effectiveTemperature: 6052
    %     %             flux:                8.6103e+04
    %     %             row:                 216
    %     %             column:              424
    %     %             rowFraction:         10
    %     %             columnFraction:      2
    %     %             visiblePixelIndex:   421060
    %     %             subPixelIndex:       20
    %     %             initialData:         [1x1 struct]
    %
    %
    %
    %     targetSpecifiction     1x10 struct array
    %
    %       ex. targetScienceManagerData.targetSpecifiction(1)
    %
    %             description:             'SOHO-based stellar variability'
    %             selectionType:           'all'
    %             lightCurveData:          [1x1 struct]
    %             selectionNumber:         []
    %             selectionOn:             []
    %             selectionMagnitudeRange: []
    %             selectionEffTempRange:   []
    %             selectionlogGRange:      []
    %             object:                  [1x1 struct]
    %
    %
    %
    %     backgroundBinaryList  1x20 struct array            REDUNDANT
    %
    %        ex. targetScienceManagerData.backgroundBinaryList(1)
    %
    %             initialData:        [1x1 struct]
    %             object:             [1x1 struct]
    %             targetKeplerId:     8429566
    %
    %                 ex. backgroundBinaryList(1).object
    %
    %                       className: 'backgroundBinaryData'
    %                       classType: 'local'
    %                       effectiveTemperatureRange: [4800 6500]
    %                       logGRange: [3 5]
    %                       orbitalPeriodRange: [10 20]
    %                       orbitalPeriodUnits: 'day'
    %                       periCenterDateRange: [54466 54831]
    %                       minimumImpactParameterRange: [0 0.7000]
    %                       pixelOffsetRange: [0.5000 1.5000]
    %                       magnitudeOffsetRange: [5 7]
    %                       transitingStarObject: [1x1 struct]
    %                       subRow: 4
    %                       subCol: 7
    %                       row: 782
    %                       column: 776
    %                       magnitude: 21.4981
    %                       flux: 33.9907
    %                       targetData: [1x1 struct]
    %                       pixelPolyCoefs: []
    %                       bgBinPixelPoiPixelIndex: []
    %                       bgBinPixelIndexInPoi: []
    %                       bgBinPixelIndexInCcd: []
    %                       runParamsClass: [1x1 struct]
    %
    %
    %
    %     backgroundBinarySpecification(1)
    %
    %             selectionType:              'random'
    %             selectionNumber:            20
    %             selectionOn:                'properties'
    %             selectionMagnitudeRange:    [9 15]
    %             selectionEffTempRange:      [5240 6530]
    %             selectionlogGRange:         [4 5]
    %             backgroundBinaryData:       [1x1 struct]
    %             magnitudeOffsetRange:       [2 7]
    %
    %----------------------------------------------------------------------


    backgroundBinaryList2  = targetScienceManagerData.backgroundBinaryList;
    targetList2            = targetScienceManagerData.targetList;
    backgroundBinarySpec   = targetScienceManagerData.backgroundBinarySpecification;
    targetSpec             = targetScienceManagerData.targetSpecifiction;

    groundTruth.backgroundBinaryList1 = backgroundBinaryList1;
    groundTruth.targetList1           = targetList1;
    groundTruth.backgroundBinaryList2 = backgroundBinaryList2;
    groundTruth.targetList2           = targetList2;
    groundTruth.backgroundBinarySpec  = backgroundBinarySpec;
    groundTruth.targetSpec            = targetSpec;

    
    eval(['save ' dvDirPath 'groundTruth_' num2str(i) '.mat  groundTruth'])
    

    
end






%--------------------------------------------------------------------------
% loop though each dv input struct and save inputs with ground truth
%--------------------------------------------------------------------------

cd(dvDirPath)

dvInputs = dir('dv-*');

numInputs = length(dvInputs);


for i = 1:numInputs

    dirString = dvInputs(i).name;

    cd(dirString)

    display(['Loading DV input struct  ' num2str(i) ' of ' num2str(numInputs)]);

    load dv-inputs-0.mat inputsStruct

    % extract mod/out
    ccdModule = inputsStruct.targetTableDataStruct.ccdModule;
    ccdOutput = inputsStruct.targetTableDataStruct.ccdOutput;

    %channel = convert_from_module_output(ccdModule, ccdOutput);

    keplerId = [inputsStruct.targetStruct.keplerId];

    % compare to ground truth keplerIdList
    %for k = 1:length(keplerId)


    backgroundBinaryKeplerIDs = keplerIdList(i).backgroundBinaryKeplerIDs;


    keplerIdsOfBckgdBinaries = intersect(keplerId, backgroundBinaryKeplerIDs);

    display(['Kepler IDs for background binaries in DV inputs: ' mat2str(keplerIdsOfBckgdBinaries')])


    targetListKeplerIDs = keplerIdList(i).targetListKeplerIDs;


    keplerIdsOfTCEs = intersect(keplerId, targetListKeplerIDs);


    display(['Kepler IDs for TCEs in DV inputs: ' mat2str(keplerIdsOfTCEs')])

    cd(dvDirPath)


    eval(['save keplerIdsOfTCEs_mod' num2str(ccdModule)  '_out' num2str(ccdOutput)   '.mat  keplerIdsOfTCEs(:) keplerIdsOfBckgdBinaries(:)'])

    %end
end

return;
