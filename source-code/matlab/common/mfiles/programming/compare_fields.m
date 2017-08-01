function [same, different, fieldsIn1NotIn2, fieldsIn2NotIn1] ...
    = compare_fields(s1, s2, precisionString, nameOfStruct1, nameOfStruct2)
%**************************************************************************
% function [same, different, fieldsIn1NotIn2, fieldsIn2NotIn1] ...
%    = compare_fields(s1, s2, precisionString, nameOfStruct1, nameOfStruct2)
%**************************************************************************
% Compare the fields of two structs and report differences. Especially
% useful for comparing the contents of .mat files.
%
% INPUTS
%     s1              : A structure.
%     s2              : A structure.
%     precisionString : 'single' or 'double'.
%     nameOfStruct1   : An optional string.
%     nameOfStruct2   : An optional string.
%
% OUTPUTS
%     same
%         The common fields of s1 and s2 that are identical within the
%         specified precision.
%     different
%         The common fields of s1 and s2 that are not identical within the
%         specified precision.
%     fieldsIn1NotIn2
%         A cell array containing the names of fields of s1 that are not
%         fields of s2. That is, the relative complement of field names of
%         s2 w.r.t. those of s1.  
%     fieldsIn2NotIn1
%         A cell array containing the names of fields of s2 that are not
%         fields of s1. That is, the relative complement of field names of
%         s1 w.r.t. those of s2.  
%
% USAGE EXAMPLE
%     >> s1 = load('statefile1.mat');
%     >> s2 = load('statefile2.mat');
%     >> compare_fields(s1, s2);
%
% NOTES
%     Comparisons of common fields that are themselves structures are made
%     by the function compare_structs_to_within_specified_precision(),
%     otherwise comparisons are made by isequalwithequalnans(). 
%**************************************************************************
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
    if ~(isstruct(s1) && isstruct(s2))
        error('Invalid argument. The first two arguments must be class ''struct''.');
    end
    if(~exist('nameOfStruct1', 'var'))
        nameOfStruct1 = 'firstStruct';
    end
    if(~exist('nameOfStruct2', 'var'))
        nameOfStruct2 = 'secondStruct';
    end
    if(~exist('precisionString', 'var'))
        precisionString = 'single';
    else
        validate_field(precisionString, { 'precisionString'; []; []; ...
                                          {'single' ; 'double'}}', '');
    end 
    
    same = {};
    different = {};
    
    fn1 = fieldnames(s1); 
    fn2 = fieldnames(s2); 
    
    % Determine common fields and relative complements.
    fieldsIn1NotIn2 = setdiff(fn1, fn2);
    fieldsIn2NotIn1 = setdiff(fn2, fn1);
    commonFields    = intersect(fn1, fn2);
    
    % Compare common fields
    for i = 1:numel(commonFields)
        name = commonFields{i};
        if isstruct(s1.(name)) && isstruct(s2.(name))
            result = compare_structs_to_within_specified_precision( ...
                s1.(name), s2.(name), precisionString, ...
                [nameOfStruct1, '.', name], [nameOfStruct2, '.', name] );
        else
            result = isequalwithequalnans(s1.(name), s2.(name));
        end

        if result == true
            same = [same, name];
        else
            different = [different, name];
        end
    end
    
    % Print report.
    fprintf('\n');
    fprintf('Fields in %s not present in %s:\n', nameOfStruct1, nameOfStruct2);
    for i = 1:numel(fieldsIn1NotIn2)
        fprintf('\t%s\n', fieldsIn1NotIn2{i});
    end
    fprintf('Fields in %s not present in %s:\n', nameOfStruct2, nameOfStruct1);
    for i = 1:numel(fieldsIn2NotIn1)
        fprintf('\t%s\n', fieldsIn2NotIn1{i});
    end
     fprintf('Identical fields (to within %s precision):\n', precisionString);
    for i = 1:numel(same)
        fprintf('\t%s\n', same{i});
    end
    fprintf('Non-identical fields:\n');
    for i = 1:numel(different)
        fprintf('\t%s\n', different{i});
    end

end