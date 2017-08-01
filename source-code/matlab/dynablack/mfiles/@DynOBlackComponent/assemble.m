%% assemble
% assembles dynamic 2D black values to have a one-to-one correspondence to requested
% pixels list from a list of unique values.  This is a method of DynOBlackComponent-class objects.
%
%   Revision History:
%
%       Version 0 - 2/9/10      released for review and comment
%       Version 1 - 4/19/10     Modified classes for pre-MATLAB V7.6
%
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
%
%%
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
function obj = assemble(obj, valueListxLC, errorListxLC)
%% ARGUMENTS
% 
% * Function returns: obj - object of class DynOBlackComponent to which function is applied.
% * Function arguments:
% * |valueListxLC    -| unique list of black level DN/read values for the set of parameters defined in object properties
% * |errorListxLC    -| unique list of black level error DN/read values for the set of parameters defined in object properties
% * 3 cases driven by the values of obj.unique_count and obj.full_count defined in DynOBlackComponent which are obvious from code.
%%
    if nargin > 0

        if obj.unique_count==0
            obj.values = valueListxLC;
            obj.errors = errorListxLC;
        elseif obj.full_count==0
            obj.unique_values = valueListxLC;
            obj.unique_errors = errorListxLC;
        else
            obj.unique_values = valueListxLC;
            obj.unique_errors = errorListxLC;
            for k=1:obj.unique_count
                kth_index = obj.full_list==obj.unique_list(k);
                index_count = sum(kth_index);
                obj.values( kth_index, 1:obj.lc_count) = ones(index_count,1)*obj.unique_values(k, 1:obj.lc_count);
                obj.errors( kth_index, 1:obj.lc_count) = ones(index_count,1)*obj.unique_errors(k, 1:obj.lc_count);
            end
        end

    end
end % assemble
