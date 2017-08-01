function  print_structure_memory_size(s, nameOfStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function print_structure_memory_size(s, nameOfStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Decription:
% This function prints the size in bytes of a given structure. This
% function is useful if the structure is deeply nested as Matlab does not
% provide the size information  for nested strucures by typing 'whos'
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

%
% Inputs:
%       s - input structure 
%       nameOfStruct - the name by which s will be known inside the function and
%       is optional.
%
% Outputs:
%       size information currently displayed on the screen
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if(~exist('nameOfStruct', 'var'))
    nameOfStruct = 's';
end

print_structure_size(s,nameOfStruct);

return



function print_structure_size(s, nameOfStruct)

nFields = length(fieldnames(s));
namesOfFields = fieldnames(s);

nStructs = length(s);

whosStruct = whos('s');
fprintf(' Name\t\t\t\tSize\t\tBytes\t\tClass\t\tAttributes\n');
fprintf('%s\t [%d %d] \t %d\t %s\n\n', nameOfStruct, whosStruct.size(1), whosStruct.size(2), whosStruct.bytes , whosStruct.class);

for j =1:nStructs

    if(nStructs > 1)
    tempStruct = s(j);

    whosStruct = whos('tempStruct');
    fprintf(' Name\t\t\t\tSize\t\tBytes\t\tClass\t\tAttributes\n');
    fprintf('%s\t [%d %d] \t %d\t %s\n\n', nameOfStruct, whosStruct.size(1), whosStruct.size(2), whosStruct.bytes , whosStruct.class);
    end



    for k = 1:nFields

        if(~isstruct(s(j).(namesOfFields{k})))
            continue;
        else

            newNameOfStruct = [nameOfStruct '(' num2str(j) ').' (namesOfFields{k})];
            tempStruct = s(j).(namesOfFields{k});

            whosStruct = whos('tempStruct');
            fprintf(' Name\t\t\t\tSize\t\tBytes\t\tClass\t\tAttributes\n');
            fprintf('%s\t [%d %d] \t %d\t %s\n\n', newNameOfStruct, whosStruct.size(1), whosStruct.size(2), whosStruct.bytes , whosStruct.class);


            print_structure_size(tempStruct, newNameOfStruct);
        end;

    end


end

return





