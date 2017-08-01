function check_runParamsObject_inputs(runParamsData)
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
    % if no inputs generate an error
    error('ETEM2:runParamsClass:EmptyInputStruct',...
        'no input argument.');
else
    %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%

    % check for the presence of the field simulationData
    if(~isfield(runParamsData, 'simulationData'))
        error('ETEM2:runParamsClass:missingField:simulationData',...
            'simulationData: field not present in the input structure.')
    end
    % now check the fields of simulationData
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'numberOfTargetsRequested';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ',' <= 1e6 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'runDuration';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1e6 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'outputNumber';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 1 ', ' <= 4 '};
    check_struct(runParamsData.simulationData, ...
        fieldsAndBoundsStruct, 'ETEM2:runParamsClass:simulationData');
    
    startTime = datestr2mjd(runParamsData.simulationData.runStartDate);
    if(startTime < datestr2mjd('01-Jan-2008'))
        error('ETEM2:runParamsClass:rangeCheck:simulationData:runStartDate',...
            'simulationData: runStartDate is too early');
    end
    if(startTime > datestr2mjd('01-Jan-2030'))
        error('ETEM2:runParamsClass:rangeCheck:simulationData:runStartDate',...
            'simulationData: runStartDate is too late');
    end

    if ~(strcmp(runParamsData.simulationData.runDurationUnits, 'days') ...
            || strcmp(runParamsData.simulationData.runDurationUnits, 'cadences'))
        error('ETEM2:runParamsClass:rangeCheck:simulationData:runDurationUnits',...
            'simulationData: runDurationUnits must be days or cadences');
    end
    if ~(strcmp(runParamsData.simulationData.cadenceType, 'long') ...
            || strcmp(runParamsData.simulationData.cadenceType, 'short'))
        error('ETEM2:runParamsClass:rangeCheck:simulationData:cadenceType',...
            'simulationData: cadenceType must be days or cadences');
    end

    %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%

    % check for the presence of the field keplerData
    if(~isfield(runParamsData, 'keplerData'))
        error('ETEM2:runParamsClass:missingField:keplerData',...
            'keplerData: field not present in the input structure.')
    end
    % now check the fields of simulationData
    nfields = 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'exposuresPerShortCadence';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 1 ', ' <= 19 '}; % really >= 7, change to >= 1 for single exposure
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'shortsPerLongCadence';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 1 ', ' <= 120 '}; % really >= 15, change to >= 1 for single exposure
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'pixelWidth';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1e3 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'pixelAngle';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1e3 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'boresiteDec';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= -90 ', ' <= 90 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'numVisibleRows';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1e6 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'numVisibleCols';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1e6 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'numLeadingBlack';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1e6 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'numTrailingBlack';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1e6 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'numVirtualSmear';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1e6 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'numMaskedSmear';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 1e6 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'maskedSmearCoAddRows';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 1 ', ' <= 20 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'virtualSmearCoAddRows';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 1045 ', ' <= 1070 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'blackCoAddCols';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 1113 ', ' <= 1132 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'nSubPixelLocations';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 1 ', ' <= 100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'prfDesignRangeBuffer';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' >= 0 ', ' <= 100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'transferTime';
    fieldsAndBoundsStruct(nfields).binaryCompare = ...
        {' == 0.51895 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'wellCapacity';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 0 ', ' <= 1e12 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'readNoise';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 0 ', ' <= 1e6 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'numAtoDBits';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 1 ', ' <= 100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'parallelCTE';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 0 ', ' <= 1 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'serialCTE';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 0 ', ' <= 1 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'electronsPerADU';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 0 ', ' <= 1e6 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'saturationSpillUpFraction';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 0 ', ' <= 1 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'adcGuardBandFractionLow';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 0 ', ' <= 1 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'adcGuardBandFractionHigh';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 0 ', ' <= 1 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'fluxOfMag12Star';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 0 ', ' <= 1e12 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'simulationFramesPerExposure';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 1 ', ' <= 1e3 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'numChains';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 1 ', ' <= 1e3 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'motionPolyOrder';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 1 ', ' <= 20 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'dvaMeshOrder';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 1 ', ' <= 20 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'motionGridResolution';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 1 ', ' <= 100 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'numCadencesPerChunk';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 1 ', ' <= 1e9 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'targetImageSize';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 1 ', ' <= 2000 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'refPixCadenceInterval';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 1 ', ' <= 2000 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'refPixCadenceOffset';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= 0 ', ' <= 2000 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'raOffset';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= -360 ', ' <= 360 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'decOffset';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= -360 ', ' <= 360 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'phiOffset';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' >= -360 ', ' <= 360 '};
    nfields = nfields + 1;
    fieldsAndBoundsStruct(nfields).fieldName = 'integrationTime';
    fieldsAndBoundsStruct(nfields).wellCapacity = ...
        {' > 3 ', ' <= 8 '};
    
    check_struct(runParamsData.keplerData, ...
        fieldsAndBoundsStruct, 'ETEM2:runParamsClass:keplerData');
    
    % check the special cases in keplerData
    if ~(runParamsData.keplerData.intrapixWavelength == 500 ...
            || runParamsData.keplerData.intrapixWavelength == 800 )
        error('ETEM2:runParamsClass:rangeCheck:keplerData:intrapixWavelength',...
            'keplerData: intrapixWavelength must be 500 or 800');
    end
%     % allowed integration times: the following table is generated with the
%     % code sprintf('%0.6f\n', (2.490960/24)*(24:77)) based on
%     % Kepler.DFM.FPA.005B "Science and Fine Guidance CCD Timing"
%     % direct computation of this table has problems due to roundoff errors
%     %
%     allowedIntegrations = [ ...
%         2.490960
%         2.594750
%         2.698540
%         2.802330
%         2.906120
%         3.009910
%         3.113700
%         3.217490
%         3.321280
%         3.425070
%         3.528860
%         3.632650
%         3.736440
%         3.840230
%         3.944020
%         4.047810
%         4.151600
%         4.255390
%         4.359180
%         4.462970
%         4.566760
%         4.670550
%         4.774340
%         4.878130
%         4.981920
%         5.085710
%         5.189500
%         5.293290
%         5.397080
%         5.500870
%         5.604660
%         5.708450
%         5.812240
%         5.916030
%         6.019820
%         6.123610
%         6.227400
%         6.331190
%         6.434980
%         6.538770
%         6.642560
%         6.746350
%         6.850140
%         6.953930
%         7.057720
%         7.161510
%         7.265300
%         7.369090
%         7.472880
%         7.576670
%         7.680460
%         7.784250
%         7.888040
%         7.991830 ];
%     if ~ismember(runParamsData.keplerData.integrationTime, allowedIntegrations)
%         error('ETEM2:runParamsClass:rangeCheck:keplerData:integrationTime',...
%             'integrationTime: integrationTime not an allowed integration');
%     end
end
