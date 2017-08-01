function A = pad_field_arrays_in_struct_array(A)
%
% function A = pad_field_arrays_in_struct_array(A)
%
% This function examines the arrays in the fields of the input array of
% structures (A) and pads any arrays that are smaller than the largest 
% array. Arrays are evaluated across the column direction (DIM=2) of the 
% array of structs. The modified array of structs is returned in A.
%
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

NUMERIC_PAD = 0;
STRING_PAD = ' ';

if( isstruct(A) );        
    names = fieldnames(A);
    [rows, cols] = size(A);
    
    if( rows>0 && cols>0 )
        
        for r=1:rows           
            
            for n=1:length(names)
                
                if( isstruct(A(r,1).(names{n})) )

                    subStructArray = [A(r,:).(names{n})];                    
                    subStructArray = pad_field_arrays_in_struct_array( subStructArray );

                    % "deal" these across columns of the source 1 x n array of struct
                    for c=1:cols
                        A(r,c).(names{n}) = subStructArray(:,c);
                    end
                    
                else
                    
                    % find the largest 2D matrix across columns
                    maxSize = [0,0];                    
                    for c=1:cols
                        currSize = size(A(r,c).(names{n}));
                        if( any(currSize > maxSize))
                            maxSize = max( [maxSize; currSize] );
                        end
                    end
                
                    % pad arrays with approriate token to MaxSize
                    for c=1:cols
                        tokenClass = class(A(r,c).(names{n}));
                        if( ischar(A(r,c).(names{n})) )
                            token = STRING_PAD; 
                        else
                            token = NUMERIC_PAD;
                        end
                        token = cast(token, tokenClass);
                        A(r,c).(names{n}) =  pad_2Darray(A(r,c).(names{n}), maxSize, token);
                    end
                end
                
            end
        end
    end
end
