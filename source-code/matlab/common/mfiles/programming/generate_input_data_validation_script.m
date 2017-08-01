%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function generate_input_data_validation_script(s, structureName, fileName)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Decription:
% This function writes the data check code (code to verify the presence of
% fields in the input structure, their valid data range which usually forms
% the first part of any 'CSCI'Class.m script (pdcClass.m, pdqScienceClass.m
% etc.)
%
% Inputs:
%       s - structure whose fields need to be validated
%       structureName - name of the structure
%       fileName - name of the file to which the validation script will be
%       written
%
% Outputs:
%        m file with the name fileName
%
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

function generate_input_data_validation_script(s, structureName, fileName)
clc;

if(~exist('fileName', 'var'))
    fileName = '';
end
if(isempty(fileName) )
    fileName = [structureName '_validate.m'];
else
    if (length(fileName) > 1)
        if (~any(strcmp(fileName(end-1:end), '.m')))
            fileName = [fileName '.m'];
        end
    else
        fileName = [fileName '.m'];

    end
end;


fid = fopen(fileName, 'wt');

if(~fid)
    error('Unable to open file\n');
end;


fprintf('%% %s\n\n', fileName);
fprintf(fid,'%% %s\n\n', fileName);


fprintf(fid,'%% This is an auto-generated script. Modify if needed.\n');
fprintf('%% This is an auto-generated script. Modify if needed.\n');
fprintf('%%------------------------------------------------------------\n');
fprintf(fid, '%%------------------------------------------------------------\n');



print_fields_bounds_statements(s, structureName, fid);
fclose all;
return



function print_fields_bounds_statements(s, structureName, fid)
nFields = length(fieldnames(s));
namesOfFields = fieldnames(s);


fprintf('fieldsAndBounds = cell(%d,4);\n', nFields);
fprintf(fid,'fieldsAndBounds = cell(%d,4);\n',nFields);


for i =1:nFields
    fprintf('fieldsAndBounds(%d,:)  = { ''%s''; []; []; []};\n', i, namesOfFields{i});
    fprintf(fid, 'fieldsAndBounds(%d,:)  = { ''%s''; []; []; []};\n', i, namesOfFields{i});
end;


fprintf('\n');
fprintf(fid, '\n');



nStructs = length(s);
%if(nStructs > 1)

%
if(~isempty(strfind(structureName,'(i)')))

    iLocation = strfind(structureName,'_');
    kStructs = str2num(structureName(iLocation+1:end));

    structureName = structureName(1:iLocation-1);

    jLocation = strfind(structureName,'(i)');
    higherStructureName = structureName(1:jLocation-1);
    str = ['length(', higherStructureName,');'];

    fprintf('kStructs = %s\n', str);
    fprintf(fid, 'kStructs = %s\n', str);



    fprintf('for i = 1:kStructs\n');
    fprintf(fid, 'for i = 1:kStructs\n');

    if(nStructs > 1)
        fprintf(['nStructures = length(' structureName ');\n\n']);
        fprintf(fid, ['nStructures = length(' structureName ');\n\n']);



        fprintf('for j = 1:nStructures\n');
        fprintf(fid, 'for j = 1:nStructures\n');


        str = ['\t\tvalidate_structure(' structureName '(j), fieldsAndBounds,''' structureName, ''');\n'];


        fprintf(str);
        fprintf(fid, str);
        fprintf('\tend\n\n');
        fprintf(fid, '\tend\n\n');
    else
        str = ['\tvalidate_structure(' structureName ', fieldsAndBounds,''' structureName, ''');\n'];

        fprintf(str);
        fprintf(fid, str);
        fprintf('\n');
        fprintf(fid, '\n');
    end

    fprintf('end\n\n');
    fprintf(fid, 'end\n\n');

else


    if(nStructs > 1)
        fprintf(['nStructures = length(' structureName ');\n\n']);
        fprintf(fid, ['nStructures = length(' structureName ');\n\n']);



        fprintf('for j = 1:nStructures\n');
        fprintf(fid, 'for j = 1:nStructures\n');


        str = ['\tvalidate_structure(' structureName '(j), fieldsAndBounds,''' structureName, ''');\n'];


        fprintf(str);
        fprintf(fid, str);
        fprintf('end\n\n');
        fprintf(fid, 'end\n\n');
    else
        str = ['validate_structure(' structureName ', fieldsAndBounds,''' structureName, ''');\n'];

        fprintf(str);
        fprintf(fid, str);
        fprintf('\n');
        fprintf(fid, '\n');



    end
end;

fprintf('clear fieldsAndBounds;\n');
fprintf(fid, 'clear fieldsAndBounds;\n');

fprintf('%%------------------------------------------------------------\n');
fprintf(fid, '%%------------------------------------------------------------\n');



for i =1:nFields

    if(isstruct(s(1).(namesOfFields{i})))
        s1 = s(1).(namesOfFields{i});

        nStructs = length(s);
        if(nStructs == 1)
            structureName1 = [structureName '.' namesOfFields{i}];
        else
            structureName1 = [structureName '(i).' namesOfFields{i} '_' num2str(nStructs)];

        end
        print_fields_bounds_statements(s1, structureName1, fid);

    end;
end;
return;





