%**
% Facilitates existing pipeline input validation method
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
function fieldsAndBounds = get_correction_fields_and_bounds(paramStruct)
    MIN_POLY_ORDER            = 1;
    MAX_POLY_ORDER            = 10;
    MAX_WINDOW_WIDTH          = 1001;
    MAX_NUM_EXPONENTIAL_TERMS = 100; % Maximum number of exponential terms allowable in the recovery model.

    if nargin >0
        minTcHighBoundString = ['>= ' num2str(paramStruct.logTimeConstantStartValue)];
        maxTcLowBoundString  = ['<= ' num2str(min(paramStruct.logTimeConstantMaxValue, 0))];
        range          = max(0, paramStruct.logTimeConstantMaxValue - paramStruct.logTimeConstantStartValue);
        minTcIncrement = max(eps, range/MAX_NUM_EXPONENTIAL_TERMS);
    else
        minTcHighBoundString = '>= -Inf';
        maxTcLowBoundString  = '<= 0';
        minTcIncrement = eps;
    end

    fieldsAndBounds = cell(7,4);
    fieldsAndBounds(1,:)  = { 'bigPicturePolyOrder';       ['>= ' num2str(MIN_POLY_ORDER)]; ['<= ' num2str(MAX_POLY_ORDER)]; []};
    fieldsAndBounds(2,:)  = { 'harmonicFalsePositiveRate'; ['>= 0'];                        ['<= 1'];                        []};
    fieldsAndBounds(3,:)  = { 'logTimeConstantIncrement';  ['>= ' num2str(minTcIncrement)]; ['<= Inf'];                      []};
    fieldsAndBounds(4,:)  = { 'logTimeConstantMaxValue';   [minTcHighBoundString];          ['<= 0'];                        []};
    fieldsAndBounds(5,:)  = { 'logTimeConstantStartValue'; ['>= -Inf'];                     [maxTcLowBoundString];           []};
    fieldsAndBounds(6,:)  = { 'polyWindowHalfWidth';       [];                              [];                              ['[1:' num2str(MAX_WINDOW_WIDTH) ']']};
    fieldsAndBounds(7,:)  = { 'recoveryWindowWidth';       [];                              [];                              ['[1:' num2str(MAX_WINDOW_WIDTH) ']']};
    fieldsAndBounds(8,:)  = { 'useMapBasisVectors';        [];                              [];                              ['[true; false]']};
    fieldsAndBounds(9,:)  = { 'shortCadencePostCorrectionEnabled';     [];                  [];                              ['[true; false]']};
    fieldsAndBounds(10,:) = { 'shortCadencePostCorrectionMethod';      [];                  [];                              {'gapfill'; 'linear'}};
    fieldsAndBounds(11,:) = { 'shortCadencePostCorrectionLeftWindow';  ['>= 0'];            ['<= Inf'];                      []};
    fieldsAndBounds(12,:) = { 'shortCadencePostCorrectionRightWindow'; ['>= 0'];            ['<= Inf'];                      []};
end

