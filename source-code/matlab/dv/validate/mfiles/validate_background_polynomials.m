function [] = validate_background_polynomials(backgroundPolyStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [] = validate_background_polynomials(backgroundPolyStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function validates background polynomials for a given target table.
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

% Validate the background polynomials for the given target table.
fieldsAndBounds = cell(8,4);
fieldsAndBounds(1,:)  = { 'cadence'; '>= 0'; '< 5e5'; []};
fieldsAndBounds(2,:)  = { 'mjdStartTime'; '> 54500'; '< 70000'; []};        % 2/4/2008 to 7/13/2050
fieldsAndBounds(3,:)  = { 'mjdMidTime'; '> 54500'; '< 70000'; []};          % 2/4/2008 to 7/13/2050
fieldsAndBounds(4,:)  = { 'mjdEndTime'; '> 54500'; '< 70000'; []};          % 2/4/2008 to 7/13/2050
fieldsAndBounds(5,:)  = { 'module'; []; []; '[2:4, 6:20, 22:24]'''};
fieldsAndBounds(6,:)  = { 'output'; []; []; '[1 2 3 4]'''};
fieldsAndBounds(7,:)  = { 'backgroundPoly'; []; []; []};
fieldsAndBounds(8,:)  = { 'backgroundPolyStatus'; []; []; '[0:1]'''};

if isfield(backgroundPolyStruct, 'backgroundPolyStatus')
    backgroundPolyGapIndicators = ...
        ~logical([backgroundPolyStruct.backgroundPolyStatus]');
    backgroundPolyStruct = backgroundPolyStruct(~backgroundPolyGapIndicators);
end % if / else

nStructures = length(backgroundPolyStruct);

for iStructure = 1 : nStructures
    validate_structure(backgroundPolyStruct(iStructure), fieldsAndBounds, ...
        'backgroundPolyStruct()');
end % for iStructure

clear fieldsAndBounds

fieldsAndBounds = cell(13,4);
fieldsAndBounds(1,:)  = { 'offsetx'; []; []; '0'};
fieldsAndBounds(2,:)  = { 'scalex'; '>= 0'; []; []};
fieldsAndBounds(3,:)  = { 'originx'; []; []; []};
fieldsAndBounds(4,:)  = { 'offsety'; []; []; '0'};
fieldsAndBounds(5,:)  = { 'scaley'; '>= 0'; []; []};
fieldsAndBounds(6,:)  = { 'originy'; []; []; []};
fieldsAndBounds(7,:)  = { 'xindex'; []; []; '-1'};
fieldsAndBounds(8,:)  = { 'yindex'; []; []; '-1'};
fieldsAndBounds(9,:)  = { 'type'; []; []; {'standard'}};
fieldsAndBounds(10,:) = { 'order'; '>= 0'; '< 10'; []};
fieldsAndBounds(11,:) = { 'message'; []; []; {}};
fieldsAndBounds(12,:) = { 'coeffs'; []; []; []};                            % TBD
fieldsAndBounds(13,:) = { 'covariance'; []; []; []};                        % TBD

for iStructure = 1 : nStructures
    validate_structure(backgroundPolyStruct(iStructure).backgroundPoly, ...
        fieldsAndBounds, 'backgroundPolyStruct().backgroundPoly');
end % for iStructure

clear fieldsAndBounds

% Return.
return
