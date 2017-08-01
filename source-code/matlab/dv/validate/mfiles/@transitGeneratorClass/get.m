function returnObject = get(transitModelObject, memberName)
%
% get -- accessor method for transitGeneratorClass
%
% member = get( transitModelObject, memberName ) returns the requested
% member of the transitModelClass object.
%
% memberList = get( transitModelObject, '?' ) or memberList = get( transitModelObject, 'help'
% ) returns a list of valid members of the class.
%
% memberStruct = get( transitModelObject, '*' ) returns all of the members of the
%    transitModelClass object as a struct.
%
% Version date:  2012-August-23.
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

% Modification History:
%
% 2012-August-23, JL:
%     due to addition of stellar parameter structs, do not retrieve second
%     level fields
% 2009-August-17, PT:
%     add cadenceDurationDays as returnable value.
% 2009-August-03, PT:
%     add modelNamesStruct, transitModelName, and limbDarkeningModelName
%     as returnable values.
%
% 2009-July-22, PT:
%     change from use of inclinationDegrees to minImpactParameter in
%     planetModel.
%
% 2009-October-7, EQ:
%     added [help, ?, and *] options
%     changed function to retrieve all available fields to make more robust,
%     rather than hard coding object fields/structs.  There are still several
%     fields that are computed here (planet parameters in MKS units) that
%     were added for convenience, and only these need to be maintained if
%     the object members change.
%
%==========================================================================


%--------------------------------------------------------------------------
% before extracting all available fields from object, compute the following
% to add to this get function for convenience:
%
%   'planetRadiusMeters'
%   'semiMajorAxisMeters'
%   'starRadiusMeters'
%   'cadenceDurationDays'
%--------------------------------------------------------------------------

planetModel            = transitModelObject.planetModel;
timeParametersStruct   = transitModelObject.timeParametersStruct;


% compute additional parameters to mks units for output
transitModelName = transitModelObject.modelNamesStruct.transitModelName;

if strcmpi(transitModelName, 'mandel-agol_transit_model')
    
    earthRadius2meter  = get_unit_conversion('earthRadius2meter');
    planetRadiusMeters = planetModel.planetRadiusEarthRadii * earthRadius2meter;
    
    au2meter = get_unit_conversion('au2meter');
    semiMajorAxisMeters = planetModel.semiMajorAxisAu * au2meter;
else
    planetRadiusMeters  = [];
    semiMajorAxisMeters = [];
end

solarRadius2meter  = get_unit_conversion('solarRadius2meter');
starRadiusMeters   = planetModel.starRadiusSolarRadii * solarRadius2meter;

sec2day = get_unit_conversion('sec2day');
cadenceDurationDays =  (timeParametersStruct.exposureTimeSec + ...
    timeParametersStruct.readoutTimeSec) * ...
    timeParametersStruct.numExposuresPerCadence * sec2day;

% concatenate new fields
computedFields = struct('planetRadiusMeters',   planetRadiusMeters,     ...
                        'semiMajorAxisMeters',  semiMajorAxisMeters,    ... 
                        'starRadiusMeters',     starRadiusMeters,       ...
                        'cadenceDurationDays',  cadenceDurationDays);


computedFieldNames  = fieldnames(computedFields);
computedFieldValues = struct2cell(computedFields);


%--------------------------------------------------------------------------
% collect top level object members
%--------------------------------------------------------------------------

topLevelFieldNames = fieldnames(transitModelObject);
topLevelFieldValues = struct2cell(transitModelObject);

allFieldNames   = cat(1, topLevelFieldNames,  computedFieldNames);
allFieldValues  = cat(1, topLevelFieldValues, computedFieldValues);
allFieldsStruct = cell2struct(allFieldValues, allFieldNames, 1);



%--------------------------------------------------------------------------
% handle the case of a '?' or 'help' first
%--------------------------------------------------------------------------

if ( (strcmp(memberName, '?')) || (strcmpi(memberName, 'help')) )
    
    returnObject = allFieldNames ;
    
    
    %--------------------------------------------------------------------------
    % now handle the case of a "give me everything" request
    %--------------------------------------------------------------------------
    
elseif ( strcmp(memberName, '*') )
    
    returnObject = allFieldsStruct;
    
    %--------------------------------------------------------------------------
    % now handle the case of a particular field name
    %--------------------------------------------------------------------------
    
else
    
    if ~any(strcmp(allFieldNames, memberName))
        error('dv:transitGeneratorClass:get:badFieldName', ...
            'transitGeneratorClass get method:  invalid field name') ;
    else
        
        returnObject = allFieldsStruct.(memberName);
    end
end


return;

