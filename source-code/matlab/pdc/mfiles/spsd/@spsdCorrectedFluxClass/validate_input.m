function isValid = validate_input(detectorStruct, detectionStruct, correctionStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function isValid = validate_inputs(detectorStruct, detectionStruct, ...
%                                    correctionStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Validate the configuration structures. The other inputs to the
% constructor (target data and map basis vectors) are validated elsewhere. 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
MIN_POLY_ORDER            = 1;
MAX_POLY_ORDER            = 10;
MAX_WINDOW_WIDTH          = 1001;
MAX_NUM_EXPONENTIAL_TERMS = 100; % Maximum number of exponential terms 
                                 % allowable in the recovery model.
isValid = true;

%--------------------------------------------------------------------------
% Validate detector configuration structure
%--------------------------------------------------------------------------
if ~spsdDetectorClass.validate_input(detectorStruct)
    isValid = false;
    return
end

%--------------------------------------------------------------------------
% Validate detection configuration structure
%--------------------------------------------------------------------------
detectionStructFieldnames = { 'discontinuityRatioTolerance'; ...
                              'endpointFitWindowWidth'; ... 
                              'excludeWindowHalfWidth'; ...
                              'falsePositiveRateLimit'; ...
                              'harmonicsRemovalEnabled'; ...
                              'quickSpsdEnabled'; ...
                              'transitSpsdMinmaxDiscriminator'; ...
                              'useCentroids'; ... 
                              'validationSignificanceThreshold'; ...
                              'maxDetectionIterations'};
                          
for n = 1:numel(detectionStructFieldnames)
    if(~isfield(detectionStruct, detectionStructFieldnames{n}))
        isValid = false;  
        return
    end
end

if    detectionStruct.discontinuityRatioTolerance       < 0 ...
   || ~ismember(detectionStruct.endpointFitWindowWidth, 1:MAX_WINDOW_WIDTH) ... % DOES THIS WINDOW WIDTH NEED TO BE ODD ???
   || detectionStruct.falsePositiveRateLimit            < 0 ...
   || detectionStruct.falsePositiveRateLimit            > 1 ...
   || detectionStruct.transitSpsdMinmaxDiscriminator    < 0 ...
   || ~ismember(detectionStruct.useCentroids,           [true; false]) ...
   || detectionStruct.validationSignificanceThreshold   < 0 ...
   || detectionStruct.maxDetectionIterations         < 1 ...
   || detectionStruct.maxDetectionIterations         > 20 ...

    isValid = false;
    return
end

%--------------------------------------------------------------------------
% Validate correction configuration structure
%--------------------------------------------------------------------------
correctionStructFieldnames = { 'bigPicturePolyOrder'; ...
                               'harmonicFalsePositiveRate'; ...  
                               'logTimeConstantIncrement'; ...  
                               'logTimeConstantMaxValue'; ...
                               'logTimeConstantStartValue'; ... 
                               'polyWindowHalfWidth'; ...
                               'recoveryWindowWidth'; ...
                               'useMapBasisVectors'};
                          
for n = 1:numel(correctionStructFieldnames)
    if(~isfield(correctionStruct, correctionStructFieldnames{n}))
        isValid = false;  
        return
    end
end

range          = max(0, correctionStruct.logTimeConstantMaxValue ...
                     - correctionStruct.logTimeConstantStartValue);
minTcHighBound = correctionStruct.logTimeConstantStartValue;
maxTcLowBound  = min(correctionStruct.logTimeConstantMaxValue, 0);
minTcIncrement = max(eps, range/MAX_NUM_EXPONENTIAL_TERMS);

if    correctionStruct.bigPicturePolyOrder            < MIN_POLY_ORDER ...
   || correctionStruct.bigPicturePolyOrder            > MAX_POLY_ORDER ...
   || correctionStruct.harmonicFalsePositiveRate      < 0 ... 
   || correctionStruct.harmonicFalsePositiveRate      > 1 ... 
   || correctionStruct.logTimeConstantIncrement       < minTcIncrement ...
   || correctionStruct.logTimeConstantMaxValue        < minTcHighBound ...
   || correctionStruct.logTimeConstantMaxValue        > 0 ...
   || correctionStruct.logTimeConstantStartValue      > maxTcLowBound ...
   || ~ismember(correctionStruct.polyWindowHalfWidth, 1:MAX_WINDOW_WIDTH) ...
   || ~ismember(correctionStruct.recoveryWindowWidth, 1:MAX_WINDOW_WIDTH) ...
   || ~ismember(correctionStruct.useMapBasisVectors,  [true; false])

    isValid = false;
    return
end

end


