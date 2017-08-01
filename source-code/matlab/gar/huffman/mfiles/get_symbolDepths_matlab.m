function symbolDepths = get_symbolDepths_matlab(levelStruct,symbolFrequencies, huffmanCodeWordLengthLimit  )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function symbolDepths =
% get_symbolDepths_matlab(levelStruct,symbolFrequencies,
% huffmanCodeWordLengthLimit  )
% 
% This algorithm is a continuation of apply_package_merge_algorithm and we
% continue from where we left off. 
% Define the active leaves to be the leaves of the first (2n-2) trees of
% the last list. Extracting the codeword length for each symbol from
% huffmanCodeWordLengthLimit   lists in levelStruct is achieved by
% processing these active leaves - each active leaf corresponds to exactly
% one of the original symbols. Every time the i-th symbol is found in the
% active leaves of each list, increment its codeword length by1. By
% examining all the active leaves in each list, codeword length for each
% and every symbol is computed.
%
% References:
% [1] L. L. Larmore and D. S. Hirschberg, “A fast algorithm for optimal
% length-limited Huffman codes,” J. Assoc. Comput. Mach., vol. 37, no.
% 3, pp. 464–473, July 1990.
% [2] J. Katajainen, A. Moffat, and A. Turpin, “A fast and space-economical
% algorithm for length-limited coding,”  Lecture Notes In Computer
% Science; Vol. 1004 Proceedings of the 6th International Symposium on
% Algorithms and Computation Pages: 12 - 21 Year of Publication: 1995
% ISBN:3-540-60573-8
% 
% 
% Inputs: 
%       (1) levelStruct (an array of structures)
%           For example, levelStruct(1) has the following fields:
%                      treesList: [15x1 double]
%                        nodeType: [15x1 logical]
%                 packagePedigree: [6x4 double]
%                   nActiveLeaves: 0
%       (2) symbolFrequencies - a vector of length = length of the
%       histogram (refer to huffman_code_matlab_controller.m)
%       (3) huffmanCodeWordLengthLimit   - another constant defined in the
%       Focal Plane Characterization CSCI with a value of 24 corresponding to
%       the limit imposed by the Flight Segment on the table format for storing
%       variable length Huffman codewords
% 
% Output: symbolDepths - a vector of length  nSymbols containing the
% codeword lengths of symbols.
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
nSymbols = length(symbolFrequencies);
symbolDepths = zeros(nSymbols,1);
nActiveLeaves = cat(1, levelStruct.nActiveLeaves);

for j= 1:nSymbols % for each symbol

    for k=1:huffmanCodeWordLengthLimit   % look in each level

        % there could be duplicate frequencies
        idx =  find( levelStruct(k).treesList(1:nActiveLeaves(k)) ==  symbolFrequencies(j) );
        if(~isempty(idx))

            if(any(~levelStruct(k).nodeType(idx))) % any leaf ?

                znodeType = double(levelStruct(k).nodeType(1:nActiveLeaves(k)));
                idz = find(znodeType > 0);
                if(~isempty(idz))
                    znodeType(idz) = -1;
                end;
                idz = find(znodeType >= 0);
                if(~isempty(idz))
                    znodeType(idz) = 1:1:length(idz);
                end;
                % if(~isempty(find(znodeType(idx) == j)))
                % replacing the above line with 
                if(any(~(znodeType(idx)- j)))
                    symbolDepths(j) = symbolDepths(j) + 1;
                end;

            end;
        end;
    end;
end;
