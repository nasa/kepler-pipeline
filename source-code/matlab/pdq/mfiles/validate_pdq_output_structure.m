function validate_pdq_output_structure(pdqOutputStruct)

% set warnings instead of errors as instructed by JJ
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
warningInsteadOfErrorFlag = true;

%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values';  '> -1e4'; '< 1e9'; []}; %-1 if unavailable, may be -ve depending on the black2D model
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= -1'; '<= 1e5'; []};

kStructs = length(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData);
for i = 1:kStructs
    validate_time_series_structure(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).blackLevels, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).blackLevels',warningInsteadOfErrorFlag);

end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= -1e4 '; '< 1e9'; []}; % -1 if unavailable
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 1e5'; []};

kStructs = length(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData);
for i = 1:kStructs
    validate_time_series_structure(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).smearLevels, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).smearLevels',warningInsteadOfErrorFlag);

end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values';  '>-1e4'; '<= 1e9'; []}; %-1 if unavailable
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= -1'; '<= 1e5'; []};

kStructs = length(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData);
for i = 1:kStructs
    validate_time_series_structure(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).darkCurrents, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).darkCurrents',warningInsteadOfErrorFlag);

end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values';  '> -1e5'; '< 1e9'; []}; % may be -ve too ...
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 1e5'; []};

kStructs = length(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData);
for i = 1:kStructs
    validate_time_series_structure(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).backgroundLevels, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).backgroundLevels',warningInsteadOfErrorFlag);

end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= -1'; '<= 1e13'; []}; %result in ADUs (use max value ADU for upper bound), -1 if unavailable
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  []; []; []}; % no uncertainties for dynamic ranges

kStructs = length(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData);
for i = 1:kStructs
    validate_time_series_structure(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).dynamicRanges, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).dynamicRanges',warningInsteadOfErrorFlag);

end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= -1'; '<= 2'; []}; % normalized flux, -1 if unavailable
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 0.5'; []};

kStructs = length(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData);
for i = 1:kStructs
    validate_time_series_structure(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).meanFluxes, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).meanFluxes',warningInsteadOfErrorFlag);

end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>=- 10'; '<= 10 '; []}; % units of pixels, very broad range
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 1'; []};

kStructs = length(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData);
for i = 1:kStructs
    validate_time_series_structure(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).centroidsMeanRows, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).centroidsMeanRows',warningInsteadOfErrorFlag);

end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>=-10'; '<=10 '; []}; % units of pixels
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 1'; []};

kStructs = length(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData);
for i = 1:kStructs
    validate_time_series_structure(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).centroidsMeanCols, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).centroidsMeanCols',warningInsteadOfErrorFlag);

end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 0'; '< 10'; []}; % units of pixels, -1 if unavailable
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= -1'; '<= 10'; []};% fix for ORT1 error message thrown


kStructs = length(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData);
for i = 1:kStructs
    validate_time_series_structure(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).encircledEnergies, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).encircledEnergies',warningInsteadOfErrorFlag);

end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= -1 '; '<= 10'; []}; % close to 4, -1 if unavailable
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= -1'; '<= 1e-1'; []};

kStructs = length(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData);
for i = 1:kStructs
    validate_time_series_structure(pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).plateScales, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(i).plateScales',warningInsteadOfErrorFlag);

end

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 285'; '<= 295'; []};  % stricter range since the telescope is never going to be far off from ..
fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties'; '>= 0'; '<= 1e-2'; []};

validate_time_series_structure(pdqOutputStruct.outputPdqTsData.attitudeSolutionRa, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.attitudeSolutionRa',warningInsteadOfErrorFlag);

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values';  '>= 40'; '<= 50'; []}; % broad ranges still
fieldsAndBounds(2,:)  = { 'gapIndicators'; []; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties'; '>= 0'; '<= 1e-2'; []};

validate_time_series_structure(pdqOutputStruct.outputPdqTsData.attitudeSolutionDec, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.attitudeSolutionDec',warningInsteadOfErrorFlag);

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= -5'; '<= 5'; []};
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 1e-2'; []};

validate_time_series_structure(pdqOutputStruct.outputPdqTsData.attitudeSolutionRoll, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.attitudeSolutionRoll',warningInsteadOfErrorFlag);

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 285'; '<= 295'; []};
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 1e-2'; []};

validate_time_series_structure(pdqOutputStruct.outputPdqTsData.desiredAttitudeRa, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.desiredAttitudeRa',warningInsteadOfErrorFlag);

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= 40'; '<= 50'; []}; % broad ranges still
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 1e-2'; []};
validate_time_series_structure(pdqOutputStruct.outputPdqTsData.desiredAttitudeDec, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.desiredAttitudeDec',warningInsteadOfErrorFlag);

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= -5'; '<= 5'; []};
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 1e-2'; []};

validate_time_series_structure(pdqOutputStruct.outputPdqTsData.desiredAttitudeRoll, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.desiredAttitudeRoll',warningInsteadOfErrorFlag);

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= -3600'; '<= 3600'; []};
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 36'; []};

validate_time_series_structure(pdqOutputStruct.outputPdqTsData.deltaAttitudeRa, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.deltaAttitudeRa',warningInsteadOfErrorFlag);

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= -3600'; '<= 3600'; []}; % broad ranges still
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 36'; []};

validate_time_series_structure(pdqOutputStruct.outputPdqTsData.deltaAttitudeDec, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.deltaAttitudeDec',warningInsteadOfErrorFlag);

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>= -3600'; '<= 3600'; []};
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 36'; []};

validate_time_series_structure(pdqOutputStruct.outputPdqTsData.deltaAttitudeRoll, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.deltaAttitudeRoll',warningInsteadOfErrorFlag);

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'values'; '>=0'; '< 20'; []}; % units of pixels, tighten the bounds later on
fieldsAndBounds(2,:)  = { 'gapIndicators';[]; []; [true, false]};
fieldsAndBounds(3,:)  = { 'uncertainties';  '>= 0'; '<= 20'; []};

validate_time_series_structure(pdqOutputStruct.outputPdqTsData.maxAttitudeResidualInPixels, fieldsAndBounds,'pdqOutputStruct.outputPdqTsData.maxAttitudeResidualInPixels',warningInsteadOfErrorFlag);

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(1,4);
fieldsAndBounds(1,:)  = { 'quaternion'; '>= -1-1e-7'; '<= 1+1e-7'; []}; % unit quaternion

nStructures = length(pdqOutputStruct.attitudeAdjustments);

for j = 1:nStructures
    validate_structure(pdqOutputStruct.attitudeAdjustments(j), fieldsAndBounds,'pdqOutputStruct.attitudeAdjustments',warningInsteadOfErrorFlag);
end

for j = 1:nStructures

    % check to see whether this is a unit quaternion

    deltaQuaternion = single(pdqOutputStruct.attitudeAdjustments(j).quaternion);

    if(all(deltaQuaternion == -1))
        warning('PDQ:validate_pdq_output_structure', ...
            ['can''t validate delta quaternion for cadence ' num2str(j) ' as the attitude solution is unavailable'] );
        continue;
    end

    qNorm = sqrt( sum(deltaQuaternion .* deltaQuaternion)) ;

    % equal to 1 within eps
    if(abs(qNorm-1) > eps('single')) % sanity check; issue warning rather than error as instructed by JJ

%         error('PDQ:outputStructureValidation:deltaQuaternion', ...
%             'computed delta quaternion is not a unit quaternion');
        warning('PDQ:validate_pdq_output_structure', ...
            ['computed delta quaternion for cadence ' num2str(j) ' is not a unit quaternion'] );
    end

end

clear fieldsAndBounds;
%------------------------------------------------------------
