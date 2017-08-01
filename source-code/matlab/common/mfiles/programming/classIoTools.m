% classdef classIoTools < handle 
%
% This class contains some useful methods for creating and saving object to/from structs
%
% It has the handle property so that classes that are handles can use this.
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

classdef classIoTools < handle

methods
    function obj = classIoTools ()
    end
end

methods

%********************************************************************************
% function obj = assert_property (obj, inStruct, fieldName, defaultValues, verbosity)
%
% Note: For some reason this function must be in the inheriting class and
% not this superclass. I don't know why. But placing here as a reference.
% Add this to your inhereting class.
%
% This is used to assert the values of struct properties in an object. For example, if new configuration 
% parameters are created in a configuration struct then thsi
% tool can be used to set the new parameters to default values if they do not exist in an obl object struct.
%
% Inputs:
%   inStruct        -- [struct, or object] The struct (object) to find the field in
%   fieldName       -- [string] The name of the field to check for
%   defaultValue    -- [variable Type] The default value, type does not need to be specified
%   verbose         -- [logical (optional)] turn on verbosity; Default = false
%
% Outputs:
%   obj       -- [struct] The input object but with the field asserted.
%
%********************************************************************************

%function obj = assert_property (obj, struct, field, value, verbosity)

%    struct = assert_field (struct, field, value, verbosity);

%    obj.(field) = struct.(field);

%end


%********************************************************************************
% function [outStruct] = convert_to_struct(obj)
%
% Converts the properties of the object to a struct. This allows for example saving the object properties to a
% file. If saving and then loading an object matlab uses the current class definition when loading in the
% object. This can cause problems when the class definition saved but you still want access to the old object
% properties. So, save it as a struct.
%
%********************************************************************************
% Inputs:
%   NONE        -- Uses all object properties
%
%********************************************************************************
% Outputs:
%   outStruct      -- [struct] The struct whos fields are the properties of the object
%
%********************************************************************************


function [outStruct] = convert_to_struct(obj)
    
    % Matlab warns us that converting an object to a struct prevents the object from hiding its
    % implementation. I agree, but we only want to save the properties from the object so that changes to the
    % object class in the future limit out ability to view previously save properties from the object.
    warningState = warning('query', 'all');
    warning off all;
    outStruct = struct(obj);
    warning(warningState);

    % Recrusively convert sub-objects
    structFieldNames = fieldnames(outStruct);
    for structFieldIndex = 1: length(structFieldNames)
        if (isobject(getfield(outStruct, structFieldNames{structFieldIndex})))
            subObject = getfield(outStruct, structFieldNames{structFieldIndex});
            % We can only recurse if classIoTools is a superclass to this subObject. If not then keep the
            % subobject as an object.
            if (ismethod(subObject, 'convert_to_struct'))
                subStruct = subObject.convert_to_struct;
                outStruct = setfield(outStruct, structFieldNames{structFieldIndex}, subStruct);
            end
        end
    end
    
end


%********************************************************************************
% function object = set_properties_with_struct_values (inStruct, object)
%********************************************************************************
%
% Transfers the <struct> field values to the corresponding <object> properties. If an object property by the
% same name does not exist then a warning is displayed. Likewise, a warning is displayed if any object
% properties do not exist in the struct.
%
% This function will only update the object properties with corresponding names in the struct. Those
% without corresponding names are left alone.
%
% Any properties that are constant or where the setAcces is not public will not be set.
% This is a bit unfortunate. Matlab should allow superclasses to set properties with the "protected" property.
%
% The reason this function is not static and used to also construct the object is because some object
% constructors require input arguments. So, construct the object on your own then call this function to
% populate the properties.
%
%********************************************************************************
% Inputs:
%   inStruct      -- [struct] The struct with the values to populate the object with
%
%********************************************************************************
% Outputs:
%   object      -- [object] The object whos properties will be updated.
%
%********************************************************************************

function object = set_properties_with_struct_values (object, inStruct)

    structFieldNames = fieldnames(inStruct);
    objectFieldNames = fieldnames(object);

    % Get the meta properties for the object
    metaObject = metaclass(object);

    for structFieldIndex = 1: length(structFieldNames)
        objectFieldIndex = find(strcmp(structFieldNames{structFieldIndex}, objectFieldNames));

        if (isempty(objectFieldIndex))
            display(['Field <', structFieldNames{structFieldIndex}, '> does not exist in the object.']);
        elseif(isobject(getfield(object, objectFieldNames{objectFieldIndex})) && ...
                ~isobject(getfield(inStruct, structFieldNames{structFieldIndex})))
                % Recrusively set sub-objects, unless the struct field is also an object. In which case just
                % copy over the sub-object
            subObject = getfield(object, objectFieldNames{objectFieldIndex});
            object = setfield(object, objectFieldNames{objectFieldIndex}, ...
                        subObject.set_properties_with_struct_values(getfield(inStruct, structFieldNames{structFieldIndex})));
        elseif(~metaObject.Properties{objectFieldIndex}.Constant && ...
                        any(strcmp(metaObject.Properties{objectFieldIndex}.SetAccess, ...
                                        {'none', 'public'})))
            % Only set the property if it is not constant and setAccess is public (or not set)
            object = setfield(object, objectFieldNames{objectFieldIndex}, ...
                        getfield(inStruct, structFieldNames{structFieldIndex}));
        end
    end

    % Find object properties not existent in struct and display warning
    for objectFieldIndex = 1: length(objectFieldNames)
        structFieldIndex = find(strcmp(objectFieldNames{objectFieldIndex}, structFieldNames));
        if (isempty(objectFieldIndex))
            display(['Property <', objectFieldNames{objectFieldIndex}, '> does not exist in the struct.']);
        end
    end
end % populate_object_with_struct_field_values

end % Static methods

end % classdef
