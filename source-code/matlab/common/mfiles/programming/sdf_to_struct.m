function [s dd] = sdf_to_struct(filename, debugLevelInput)
% function s = sdf_to_struct(filename)
%
% Build and return a MATLAB struct from the specified .sdf file.
%
% The SFD (Self-Describing Format) is a generic format used to convert an
% arbitrary Java object tree to a MATLAB struct for use by various sandbox
% tools.
%
% See gov.nasa.kepler.common.persistable.SdfPersistableOutputStream for
% details on the file format.
%
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

debugLevel = 0;

if(nargin > 1)
    debugLevel = debugLevelInput;
end

import gov.nasa.kepler.common.persistable.SdfDataDictionary;

BOOLEAN_TYPE =        SdfDataDictionary.BOOLEAN_TAG;
BYTE_TYPE =           SdfDataDictionary.BYTE_TAG;
SHORT_TYPE =          SdfDataDictionary.SHORT_TAG;
INT_TYPE =            SdfDataDictionary.INT_TAG;
LONG_TYPE =           SdfDataDictionary.LONG_TAG;
FLOAT_TYPE =          SdfDataDictionary.FLOAT_TAG;
DOUBLE_TYPE =         SdfDataDictionary.DOUBLE_TAG;
STRING_TYPE =         SdfDataDictionary.STRING_TAG;
CHAR_TYPE =           SdfDataDictionary.CHAR_TAG;
DATE_TYPE =           SdfDataDictionary.DATE_TAG;
ENUM_TYPE =           SdfDataDictionary.ENUM_TAG;
LAST_PRIMITIVE_TYPE = SdfDataDictionary.LAST_PRIMITIVE_TAG;

import java.lang.Integer;
import java.lang.Long;
import java.lang.Float;
import java.lang.Double;

EMPTY_BOOLEAN = 2;
EMPTY_INT = Integer.MAX_VALUE;
EMPTY_LONG = Long.MAX_VALUE;
EMPTY_FLOAT = Float.MAX_VALUE;
EMPTY_DOUBLE = Double.MAX_VALUE;

primitiveTypes = cell(9,1);
primitiveTypes{BOOLEAN_TYPE}    = 'uint8';
primitiveTypes{BYTE_TYPE}       = '*uint8';
primitiveTypes{SHORT_TYPE}      = 'int16';
primitiveTypes{INT_TYPE}        = 'int32';
primitiveTypes{LONG_TYPE}       = 'int64';
primitiveTypes{FLOAT_TYPE}      = 'float32';
primitiveTypes{DOUBLE_TYPE}     = 'double';
primitiveTypes{STRING_TYPE}     = 'string';
primitiveTypes{CHAR_TYPE}       = 'uint8';
primitiveTypes{DATE_TYPE}       = 'string';
primitiveTypes{ENUM_TYPE}       = 'string';

fd = fopen(filename, 'rb');
if(fd == -1)
    error(['sdf_to_struct: Unable to open file: ' filename ]);
end;

%
% Header
% 

magic = fread(fd, 1, 'int32');

if(magic ~= 42042)
    error(['sdf_to_struct: Not a valid .sdf file: ' filename...
        '.  Magic number found (' num2str(magic) ') does not match']);
end;

dd = read_data_dictionary();

topLevelType = fread(fd, 1, 'int32');

%
% Body 
%

s = read_struct(topLevelType);

fclose(fd);

return

%
% Begin nested functions
%

    %
    % Read the data dictionary from the header
    %
    function dd = read_data_dictionary()

        numClasses = fread(fd, 1, 'int32');

        dd.classes = repmat(struct('type',[],'fields',[]), 1, numClasses);

        for c = 1:numClasses
            dd.classes(c).type = fread(fd, 1, 'int32');
            dd.classes(c).name = read_string;

            numFields = fread(fd, 1, 'int32');
            dd.classes(c).fields = repmat(struct('name',[],'type',[],'dimensions',[]), 1, numFields);

            if(debugLevel > 0)
                fprintf(1,'class name=%s, type=%d, numFields=%d\n',...
                    dd.classes(c).name, dd.classes(c).type, numFields);
            end
            
            for f = 1:numFields
                dd.classes(c).fields(f).name = read_string();
                dd.classes(c).fields(f).type = fread(fd, 1, 'int32');
                dd.classes(c).fields(f).dimensions = fread(fd, 1, 'int32');
            end
        end
    end

    %
    % Read a struct from the file.
    % This function will be called recursively for fields of the struct that
    % are also structs
    %
    function s = read_struct(type)
        
        c = dd.classes(type - LAST_PRIMITIVE_TYPE); % class types start here

        if(debugLevel > 0)
            fprintf(1,'Reading struct, class name=%s, type=%d\n',...
                c.name, c.type);
        end
        
        s = struct;

        for f = 1:length(c.fields)
            field = c.fields(f);
            
            if(debugLevel > 0)
                fprintf(1,'  Reading field, name=%s\n', field.name);
            end

            if(field.type <= LAST_PRIMITIVE_TYPE)
                % primitive                
                if(field.type == STRING_TYPE || field.type == ENUM_TYPE || field.type == DATE_TYPE)
                    if(field.dimensions == 0)
                        v = read_string();
                    else
                        v = read_string_array(field.dimensions);
                    end
                else
                    % non-string primitive
                    if(field.dimensions == 0)
                        v = read_primitive(field.type);
                    else
                        v = read_primitive_array(field.type, field.dimensions);
                    end
                end
            else
                % non-primitive
                if(field.dimensions == 0)
                    % single, not an array
                    v = read_struct(field.type);
                else
                    % array of 1 or more dimensions
                    v = read_struct_array(field.type, field.dimensions);
                end
            end

            if(debugLevel > 1 && isempty(v))
                fprintf(1,'    (empty)\n');
            end
            
            s.(field.name) = v;
        end
    end

    %
    % Read an array of structs from the file
    %
    function s = read_struct_array(type, dimensions)
        len = fread(fd, 1, 'int32');
                    
        if(debugLevel > 1)
            fprintf(1,'    read_struct_array, len=%d\n', len);
        end

        if(len == 0)
            s = [];
        else
            if(dimensions > 1)
                s = struct('array',[]);
            else
                s = make_struct_prototype(type);
            end

            s = repmat(s, 1, len);

            for i = 1:len
                if(dimensions > 1)
                    s(i).array = read_struct_array(type, dimensions - 1);
                else
                    s(i) = read_struct(type);
                end
            end
        end
    end
    
    %
    % Make an empty struct containing the fields specified by the entry in
    % the data dictionary that corresponds to 'type'.  Used for repmat-ing
    function prototype = make_struct_prototype(type)
        c = dd.classes(type - LAST_PRIMITIVE_TYPE); % class types start here
        prototype = struct;

        for f = 1:length(c.fields)
            field = c.fields(f);
            prototype.(field.name) = [];
        end
    end

    %
    % Read a primitive or array or primitives from the file
    %
    function v = read_primitive(type)
        v = fread(fd, 1, primitiveTypes{type});
        
        if(isempty(v) && feof(fd))
            error('premature EOF');
        end
        if((type == BOOLEAN_TYPE) && (v == EMPTY_BOOLEAN))
            v = [];
        elseif((type == INT_TYPE) && (v == EMPTY_INT))
            v = [];
        elseif((type == LONG_TYPE) && (v == EMPTY_LONG))
            v = [];
        elseif((type == FLOAT_TYPE) && (v == EMPTY_FLOAT))
            v = [];
        elseif((type == DOUBLE_TYPE) && (v == EMPTY_DOUBLE))
            v = [];
        elseif(type == CHAR_TYPE)
            v = char(v);
        elseif(type == BOOLEAN_TYPE)
            v = logical(v);
        end
    end

    %
    % Read a primitive or array or primitives from the file
    %
    function v = read_primitive_array(type, dimensions)
        len = fread(fd, 1, 'int32');

        if(debugLevel > 1)
            fprintf(1,'    read_primitive_array, len=%d\n',...
                len);
        end

        if(len == 0)
            v = [];
        else
            if(dimensions > 1)
                v = struct('array',[]);
                v = repmat(v, 1, len);

                for i = 1:len
                    v(i).array = read_primitive_array(type, dimensions - 1);
                end
            else
                v = fread(fd, len, primitiveTypes{type});
                if(type == CHAR_TYPE)
                    v = char(v');
                elseif(type == BOOLEAN_TYPE)
                    v = logical(v);
                end
            end
        end
    end

    %
    % Read a string from the file
    %
    function s = read_string()
        len = fread(fd, 1, 'int32');

        if(debugLevel > 1)
            fprintf(1,'    read_string, len=%d\n',...
                len);
        end

        if(len == 0)
            s = [];
        else
            s = fread(fd, len, 'char');
            s = char(s');
        end
    end

    function s = read_string_array(dimensions)
        len = fread(fd, 1, 'int32');

        if(debugLevel > 1)
            fprintf(1,'    read_string_array, len=%d\n',...
                len);
        end

        if(len == 0)
            s = [];
        else
            if(dimensions > 1)
                s = cell(1,len);

                for i = 1:len
                    s{i} = read_string_array(dimensions - 1);
                end
            else
                for i = 1:len
                    s{i} = read_string();
                end
            end
        end
    end
end
















