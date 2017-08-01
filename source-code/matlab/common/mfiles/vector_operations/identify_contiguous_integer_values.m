%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [chunkArray, chunkIndices] =
% identify_contiguous_integer_values(inputVector)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
% This function takes an input vector of semi-contiguous integers and 
% splits it up into cells of an array at the discontinuities.
%
% Inputs:
%         1. inputVector -  A row or column vector containing semi-
%         contiguous integer values
%         
% Output:
%         1. chunkArray - Cell array containing the vector chunks after
%         fragmenting at discontinuity locations.  Size is 1 x nChunks for
%         an input row vector and nChunks x 1 for an input column vector.
%         Each cell contains either a column vector or row vector chunk.
%         2. chunkIndices - An nChunks x 2 matrix containing the indices of
%         inputVector corresponding to the start and end of the chunks. The
%         first column is the start indices of the chunks and the second
%         column is the end indices.
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
function [chunkArray, chunkIndices] =  identify_contiguous_integer_values(inputVector)

% nominal case:  argument is not empty

if ~isempty(inputVector)
    
    % Check input
    if ~isvector( inputVector ) 
          error('identifyContiguousIntegerValues:inputNotAVector', ...
              'identify_contiguous_integer_values:  argument inputVector must be a vector') ;
    end

    if ~isequal( 0, sum(inputVector-round(inputVector)) ) 
          error('identifyContiguousIntegerValues:inputNotInteger', ...
              'identify_contiguous_integer_values:  argument inputVector must have only integer values') ;
    end

    if isequal(size(inputVector,1),1)
        % The input is a row vector
        chunkStartIndices = [0 find(diff(inputVector)>1) size(inputVector,2)];
        chunkArray = mat2cell(inputVector,1,diff(chunkStartIndices));
        chunkStartIndices = chunkStartIndices(1:end-1) + 1;
        chunkEndIndices = [chunkStartIndices(2:end)-1 size(inputVector,2)];
        chunkIndices = [chunkStartIndices' chunkEndIndices'];
    else
        % The input is a column vector
        chunkStartIndices = vertcat(0, find(diff(inputVector)>1), size(inputVector,1));
        chunkArray = mat2cell(inputVector,diff(chunkStartIndices),1);
        chunkStartIndices = chunkStartIndices(1:end-1) + 1;
        chunkEndIndices = vertcat(chunkStartIndices(2:end)-1, size(inputVector,1));
        chunkIndices = [chunkStartIndices chunkEndIndices];
    end

else % corner-case:  empty input
    
    chunkArray = {} ;
    chunkIndices = [] ;
    
end

return