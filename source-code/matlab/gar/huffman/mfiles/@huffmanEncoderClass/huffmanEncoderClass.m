function  huffmanEncoderObject = huffmanEncoderClass(huffmanInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  huffmanEncoderObject = huffmanEncoderClass(huffmanInputStruct);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% huffmanEncoderClass.m - Class Constructor
% This function first checks for the presence of expected fields in the
% input structure and then implements the constructor for the
% huffmanEncoderClass using the input data structure as the template for
% the class. Once the class is created, the data members are type cast to
% double and each parameter is checked to see whether is is within
% appropriate range.
%
% Inputs:
%       (1) A structure 'huffmanDataStruct' with the field
%               histogram: [131071x1 double]
%      huffmanModuleParameters: [1x1 struct]
%   huffmanInputStruct.huffmanModuleParameters with the following fields
%    huffmanCodeWordLengthLimit  : 24 (See KEPLER.DFM.FSW.076.pdf)
%                       debugFlag: 0
% Output: An object 'huffmanEncoderObject' of class 'huffmanEncoderClass'
% containing the above fields and the computed field 'huffmanTableLength' as data memebers.
%
% Comments: This function generates an error under the following scenarios:
%          (1) when invoked with no inputs
%          (2) when any of the fields are missing
%          (3) when any of the fields are NaNs/Infs or outside the
%          appropriate bounds
%          (4) when the histogram bins have fractional or non-integer values
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
if nargin == 0
    % generate error and return
    error('GAR:huffmanEncoderClass:EmptyInputStruct',...
        'The constructor must be called with an input structure.')
end

% need to separate the constants in the huffmanModuleParameters structure
huffmanInputStruct = validate_huffman_input_structure(huffmanInputStruct);

if(huffmanInputStruct.huffmanModuleParameters.debugFlag)
    % need to control printing to the console, don't want to print 2^17 entries
    % print to console all the fields for a visual check
    fprintf('Length of Huffman Table = %d\n', huffmanInputStruct.huffmanTableLength);
end


% to avoid getting error message like Error: Error using ==> class Field
% names and parent classes for class huffmanEncoderClass cannot be
% changed without clear classes - order the fields
huffmanInputStruct = orderfields(huffmanInputStruct);



%  input validation successfully completed! instantiate class
%  obj = class(s, 'class_name') creates an object of MATLAB class 'class_name' using structure s as a template.
huffmanEncoderObject = class(huffmanInputStruct, 'huffmanEncoderClass');

return
