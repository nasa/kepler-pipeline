function A = condense_field_arrays(A,varargin)
%
% function A = condense_field_arrays(A,varargin)
%
% This function examines the 2D arrays contained in each field of structure
% A and checks if they are simply repetitions of the same row or column. 
% If they are, the contents of this field in the output structure is only a
% single representative row or column. If they are not, the contents of the
% field are left unchanged. The original size for all arrays is stored in 
% an attached field under array fieldname as a 1x2 vector.  
% e.g. A.size.(fieldName) = [n m]
%
% INPUT     A           = 1D array of errorPropStruct from CAL
%           varargin    = {1} == mode;  0 == condense both rows and columns (default)
%                                       1 == condense rows only
%                                       2 == condense columns only
%                                       
% OUTPUT    A           = 1D array of errorPropStruct from CAL with
%                         condensed arrays and size fields filled in
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

% get variable argument
mode = 0;
if(nargin > 1)
    mode = varargin{1};
end

[row, col] = size(A);

if(row>0 && col>0)
    if( isstruct(A) );
        names = fieldnames(A);
        for i=1:length(names)
            
            % step through array A using linear indexing
            for j=1:row*col
                if( isstruct(A(j).(names{i})) ) 
                    if(~strcmp(names{i},'size'))
                        if(strcmp(names{i},'originalShape'))
                            newmode = 1;
                        else
                            newmode = 0;
                        end
                        A(j).(names{i}) = condense_field_arrays( A(j).(names{i}), newmode );
                    end
                else
                    if( ~isempty(A(j).(names{i})) )
                        % save pre-condensed size
                        if( isfield(A(j),'size') )
                            A(j).size.(names{i}) = size(A(j).(names{i}));
                        end
                       
                        % condense identical rows
                        if(  (mode == 0 || mode == 1) && all_rows_equal(A(j).(names{i})) )                        
                            A(j).(names{i}) = A(j).(names{i})(1,:);                    
                        end
                        % condense identical columns
                        if( (mode == 0 || mode == 2) && all_columns_equal(A(j).(names{i})) )                        
                            A(j).(names{i}) = A(j).(names{i})(:,1);                    
                        end
                        
                    end                    
                end                
            end
            
        end
    end                 
end

