% pdcValidRangeClass is for specifying ranges for fields in a struct to be validated with pdc_validate_fields.
% 
% Syntax : canonicalStruct.fieldToValidate = pdcValidRangeClass(low, high, isLogical, isChar, characterOptions, canBeEmpty, mustBeScalar, mustBeOfLength, arrayLength)
%
% Where
%   low              -- [int or float] the low range for the field value
%   high             -- [int or float] the high range for the field value
%   isLogical        -- [char OPTIONAL] if passed then the field is a logical (and can be either true or false)
%   isChar           -- [char OPTIONAL] if passed then the field is a char (and can be any length)
%   charOptions      -- [char cell array OPTIONAL] The char options of the char field (e.g. In TESS CadenceType can be {'TARGET', 'FFI'}
%   canBeEmpty       -- [char OPTIONAL] If passed then field can be empty
%   canBeNan         -- [char OPTIONAL] If passed then field can be NaN
%   mustBeScalar     -- [char OPTIONAL] If passed then field must be a scaler (E.g. array of length 1)
%   mustBeOfLength   -- [char OPTIONAL] If passed then field must be an array of length set in arrayLength
%   arrayLength      -- [int array(nDimensions)] if mustBeOfLength is true then this is the length the array must be, NaN means any length
%                                                   (I.e. [4 NaN] means first dinmension is 4 but second can be anything
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


classdef pdcValidRangeClass < classIoTools

    properties(GetAccess = 'public', SetAccess = 'immutable')
        high = [];
        low = [];
        isLogical = false;
        isChar = false;
        charOptions = [];
        canBeEmpty = false;
        canBeNan = false;
        mustBeScalar = false;
        mustBeOfLength  = false;
        arrayLength = 0;
    end

    %*******************
    methods
        function obj = pdcValidRangeClass (low, high, varargin)

            obj.high = high;
            obj.low = low;

            nOptionalArguments = nargin - 2;
            if (nOptionalArguments > 0)
                moreArguments = true;
            else
                moreArguments = false;
            end
            while(moreArguments)
                switch varargin{1}
                
                case 'isLogical'
                    obj.isLogical = true;

                case 'isChar'
                    obj.isChar = true;

                case 'charOptions'
                    if (length(varargin) < 2)
                        error(' ''charOptions'' must be followed by a cell array of valid char strings');
                    end
                    obj.charOptions = varargin{2};
                    %remove one of the extra arguments
                    varargin = varargin(2:end);

                case 'mustBeOfLength'
                    if (length(varargin) < 2)
                        error(' ''mustBeOfLength'' must be followed by an ineteger of the desired length');
                    end
                    if (~isnumeric(varargin{2}))
                        error('<arrayLength> must be an ineteger');
                    end

                    obj.mustBeOfLength = true;
                    obj.arrayLength = round(varargin{2});

                    %remove one of the extra arguments
                    varargin = varargin(2:end);

                case 'canBeEmpty'
                    obj.canBeEmpty = true;

                case 'canBeNan'
                    obj.canBeNan = true;

                case 'mustBeScalar'
                    obj.mustBeScalar = true;

                otherwise
                    error ('Unknown optional argument');

                end % switch

                if length(varargin) > 1;
                    varargin = varargin(2:end);
                else
                    moreArguments = false;
                end

            end

            % Check for consistency 

            if (obj.isLogical && obj.isChar)
                error('Cannot specify both isLogical and isChar');
            end

            if (obj.isLogical && obj.canBeNan)
                error('Cannot specify both isLogical and canBeNan');
            end

            if (obj.isChar && obj.canBeNan)
                error('Cannot specify both isChar and canBeNan');
            end

            if (obj.mustBeScalar && obj.mustBeOfLength)
                error('Cannot specify both mustBeScalar and mustBeOfLength');
            end

        end % constructor
        
    end
end

