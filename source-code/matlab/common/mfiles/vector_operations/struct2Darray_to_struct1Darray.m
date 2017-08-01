function B = struct2Darray_to_struct1Darray(A)
%
% function B = struct2Darray_to_struct1Darray(inputStruct)
%
% Consolidate a 2D array of structures with fields containing 1D arrays into 
% a 1D array of structures where the fields now contain 2Darrays. This
% function works only if the structure fields contain 1D or 2D arrays. The
% resulting nxm arrays are dimensioned such that the row dimension = the
% column dimension of the original array of structures for the 1D array case.
% The 2D array case will stack the transposed souce arrays per cadence.
%
% Example:
%     A = 15x30 struct array with fields:
%                 variableName
%                 xPrimitive
%                 CxPrimitive
%                 row
%                 col
%                 gapList
%                 transformStructArray
% and:
%     A(1,1) =  
%                     variableName: 'residualBlack'
%                       xPrimitive: [1070x1 double]
%                      CxPrimitive: [1070x1 double]
%                              row: []
%                              col: []
%                          gapList: [0x1 int16]
%             transformStructArray: [1x1 struct]
%
% consolidates to
%        B = 15x1 struct array with fields:
%                 variableName
%                 xPrimitive
%                 CxPrimitive
%                 row
%                 col
%                 gapList
%                 transformStructArray
% and:
%        B(1,1) =  
%                     variableName: [30x13 char]
%                       xPrimitive: [30x1070 double]
%                      CxPrimitive: [30x1070 double]
%                              row: []
%                              col: []
%                          gapList: [0x30 int16]
%             transformStructArray: [1x30 struct]
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

[rows, cols]=size(A);
B = A;

if( rows>0 && cols>0 )
    if( isstruct(A) );        
        names = fieldnames(A);        
        B = A(:,1);
        
        for n=1:length(names)
            
            for r=1:rows
                
                if( isstruct(A(r,1).(names{n})) ) 
                    B(r).(names{n}) = struct2Darray_to_struct1Darray( [A(r,:).(names{n})] );                    
                else
                    if( isrowvector(A(r,1).(names{n})) )
                        B(r).(names{n}) = cell2mat({A(r,:).(names{n})}');
                    else                        
                        B(r).(names{n}) = cell2mat({A(r,:).(names{n})})';
                    end
                end
                
            end
            
        end
        
    end
end