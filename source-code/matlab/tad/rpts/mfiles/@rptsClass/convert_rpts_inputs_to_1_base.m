function [rptsModuleParametersStruct, stellarApertures, dynamicRangeApertures] = ...
    convert_rpts_inputs_to_1_base(rptsObject)
% function [rptsModuleParametersStruct, stellarApertures, dynamicRangeApertures] = ...
%          convert_rpts_inputs_to_1_base(rptsObject)
%
% Input arrays that include row/column indices must be converted from Java 0-base
% to Matlab 1-base
%
% Note: fields that are converted to 1-base herein are:
%
%    stellarApertures.referenceRow
%    stellarApertures.referenceColumn
%    dynamicRangeApertures.referenceRow
%    dynamicRangeApertures.referenceColumn
%    rptsModuleParametersStruct.smearRows
%    rptsModuleParametersStruct.blackColumns
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


% extract relevant fields from object
rptsModuleParametersStruct = rptsObject.rptsModuleParametersStruct;
stellarApertures = rptsObject.stellarApertures;
dynamicRangeApertures = rptsObject.dynamicRangeApertures;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% increase all row/column indices on non-empty arrays by 1

if (~isempty(rptsModuleParametersStruct.smearRows))
    rptsModuleParametersStruct.smearRows = rptsModuleParametersStruct.smearRows + 1;
    display('RPTS:convert_rpts_inputs_to_1_base: Smear input row indices converted to Matlab 1-based indexing. ');
end

if (~isempty(rptsModuleParametersStruct.blackColumns))
    rptsModuleParametersStruct.blackColumns = rptsModuleParametersStruct.blackColumns + 1;
    display('RPTS:convert_rpts_inputs_to_1_base: Black input column indices converted to Matlab 1-based indexing. ');
end

if (~isempty(stellarApertures))
    stellarRows = [stellarApertures.referenceRow] + 1;
    stellarColumns = [stellarApertures.referenceColumn] + 1;

    % convert 2D arrays to cell arrays, and deal back into struct arrays
    stellarRowsCellArray = num2cell(stellarRows);
    stellarColumnsCellArray = num2cell(stellarColumns);

    % save updated structure array fields
    [stellarApertures(1:length(stellarRowsCellArray)).referenceRow] = deal(stellarRowsCellArray{:});
    [stellarApertures(1:length(stellarColumnsCellArray)).referenceColumn] = deal(stellarColumnsCellArray{:});
    display('RPTS:convert_rpts_inputs_to_1_base: Stellar input reference row and column indices converted to Matlab 1-based indexing. ');
end

if (~isempty(dynamicRangeApertures))
    dynamicRows = [dynamicRangeApertures.referenceRow] + 1;
    dynamicColumns = [dynamicRangeApertures.referenceColumn] + 1;

    % convert 2D arrays to cell arrays, and deal back into struct arrays
    dynamicRowsCellArray = num2cell(dynamicRows);
    dynamicColumnsCellArray = num2cell(dynamicColumns);

    % save updated structure array fields
    [dynamicRangeApertures(1:length(dynamicRowsCellArray)).referenceRow] = deal(dynamicRowsCellArray{:});
    [dynamicRangeApertures(1:length(dynamicColumnsCellArray)).referenceColumn] = deal(dynamicColumnsCellArray{:});
    display('RPTS:convert_rpts_inputs_to_1_base: Dynamic range input reference row and column indices converted to Matlab 1-based indexing. ');
end

return