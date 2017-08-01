function [huffmanOutputStruct] = generate_length_limited_huffman_code(huffmanEncoderObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [huffmanOutputStruct] =
% generate_length_limited_huffman_code(huffmanEncoderObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function implements the optimal length limited huffman encoding
% algorithm as described in [1].
%
% The format for storing the variable length huffman code table limits each
% codeword to 24-bits but Huffman's algorithm may produce codewords that
% are longer than 24-bits since it is only guaranteed to produce optimal
% prefix free codes and is not constrained by codeword length.
%
% Larmore and Hirschnerg's algorithm constructs optimal Huffman codes for a
% weighted alphabet of size n (= 2^17 requantized values) where each
% codeword must have a length no greater than L ( = 24 bits).
%
% Huffman's original algorithm uses a greedy method. The items are sorted by
% weight (probability or frequency) and each item is cinsidered to be a
% tree of just one node. A 'combine' step is then executed n-1 times for an
% alphabet of size n. Each ''combine' stepdeletes the two trees os smallest
% weight from the sorted list and combines them to form one tree and then
% inserts the new tree (whose weight is the sum of the weight of the
% subtrees) in the proper place in the sorted order. After n-1 iterations,
% the list contains just one tree which is the Huffman tree. Its time
% complexity is linear O(n).
%
% Larmore and Hirschberg's Package-Merge Algorithm is an O(nL)-time
% algorithm for finding an optimal length-limited Huffman code for a given
% distribution of an alphabet of size n, where no code string is permitted
% to have length more than L. It too is a greedy algorithm which is a
% generalization of Huffman's original algorithm. Package-merge works by
% reducing restricted length Huffman coding problem to the binary Coin
% Collector's problem [1].
%
% The Coin Collector's Problem
% Suppose a coin collector has a number of coins of various denominations
% (face values), each of which has a numismatic value. Since the country he
% lives in has binary coinage, the denomination of esch coin is an integral
% power of 2 (that is, 1, 1/2, 1/4, etc. dollar)s. The collector is obliged
% to spend X dollars to buy groceries but the grocer refuses to accept any
% coin at other than its face value. How can the collector choose a set of
% coins of minimum total numismatic value whose total face value is X?
%
% Description of the Package-Merge Algorithm
% Assume that the largest denomination is 1 dollar, and that X is an
% integer. (The algorithm works even if these assumptions do not hold, by
% trivial modifications.) The coin collector first separates his coins into
% lists, one for each denomination, sorted by numismatic value. He then
% packages the smallest denomination coins in pairs, starting from the pair
% of smallest total numismatic value. If there is one coin left over, it
% will be the coin of highest numismatic value of that denomination, and it
% is set aside and ignored henceforth. These packages are then merged into
% the list of coins of the next smallest denomination, again in order of
% numismatic value. The items in that list are then packaged in pairs, and
% merged into the next smallest list, and so forth [3].
%
% Finally, there is a list of items, each of which is a 1 dollar coin or a
% package consisting of two or more smaller coins whose denominations total
% 1 dollar. They are also sorted in order of numismatic value. The coin
% collector then selects the least value N of them.
%
% Note that the time of the algorithm is linear in the number of coins.
%
%
% Reduction of Length-Limited Huffman Coding to the Coin Collector's Problem
% Let L be the maximum length of any code string is permitted to have. Let
% p1, ... pn be the frequencies of the symbols of the alphabet that needs
% to be encoded. We first sort the symbols so that pi <= pi+1. Create L
% coins for each symbol, of denominations 2^-1 ... 2^-L, each of numismatic
% value pi. Use the package-merge algorithm to select the set of coins of
% minimum numismatic value whose denominations total n-1. Let hi be the
% number of coins of numismatic value pi selected.
%
% The optimal length-limited Huffman code will encode symbol i with a bit
% string of length hi. The actual Huffman tree can easily be constructed by
% a simple bottom-up greedy method, given that the hi are known.
%
% References:
% [1] L. L. Larmore and D. S. Hirschberg, �A fast algorithm for optimal
% length-limited Huffman codes,� J. Assoc. Comput. Mach., vol. 37, no.
% 3, pp. 464�473, July 1990.
% [2] J. Katajainen, A. Moffat, and A. Turpin, �A fast and space-economical
% algorithm for length-limited coding,�  Lecture Notes In Computer
% Science; Vol. 1004 Proceedings of the 6th International Symposium on
% Algorithms and Computation Pages: 12 - 21 Year of Publication: 1995
% ISBN:3-540-60573-8
% [3] http://en.wikipedia.org/wiki/Package-merge_algorithm
%
%
%------------------------------ DMC-SOC ICD ----------------------------------------
% Data Management Center (DMC) to Science Operations Center (SOC) Interface
% Control Document - KDMC-10007
%
% 4.1.6	Compression Histograms
% 4.1.6.1	Purpose
% The DMC will generate a compression histogram with the processing of data
% for each contact.  The compression histogram will be used by the SOC to
% track the efficiency of the compression algorithm.
% 4.1.6.2	Composition
% FITS format 1-D array of long (unsigned 32-bit) integers containing the
% number of symbols per each requantized pixel value index over for each
% contact, so it's 2^17 elements (one for each possible requantized pixel
% value index).
% 4.1.6.3	Source
% DMC
% 4.1.6.4	Recipient
% SOC
% 4.1.6.5	Interface type
% Automatic file transfer at the completion of contact processing.
% 4.1.6.6	Naming Convention
% TBD
% 4.1.6.7	Conditions for Transfer
% The DMC will send the compression histogram to the SOC at the end of each
% contact processing.  The compression histogram will not be held for any
% missing cadences.
%------------------------------ SOC-MOC ICD ---------------------------------------------
% Science Operations Center (SOC) to Mission Operations Center (MOC)
% Interface Control Document KSOC-21171-001
%
% 4.1.3	Huffman Encoding Table
% 4.1.3.1	Purpose
% Used to encode the science data on the spacecraft before downlink, and to
% decode the data received on the ground.
% 4.1.3.2	Composition
% This table includes one record for each integer value from 0 to 131,070,
% with the following fields:
%--------------------------------------------------------------------------
% Field         Description                         Units
%--------------------------------------------------------------------------
% Value         The integer value to encode         Unsigned integer
% Bitstring     Encoded bit string                  Integer
%--------------------------------------------------------------------------
%
%
% Inputs:
%    (1) huffmanEncoderObject with members
%     A structure 'huffmanDataStruct' with the field
%               histogram: [131071x1 double]
%      huffmanModuleParameters: [1x1 struct]
%   huffmanInputStruct.huffmanModuleParameters with the following fields
%
%    huffmanCodeWordLengthLimit  : 24 (See KEPLER.DFM.FSW.076.pdf) another
%    constant defined in the  Focal Plane Characterization CSCI with a
%    value of 24 corresponding to the limit imposed by the Flight Segment
%    on the table format for storing variable length Huffman codewords
%                       debugFlag: 0
%
% Outputs: huffmanOutputStruct with the following fields:
%                  levelStruct: [1x9 struct]
%                 symbolDepths: [9x1 double]
%            binaryNodesStruct: [1x8 struct]
%                    sortOrder: [9x1 double]
%           huffmanCodeStrings: {9x1 cell}
%           huffmanCodeLengths: [9x1 double]
%              masterHistogram: [9x1 double]
%     theoreticalCompressionRate: 2.6911
%        effectiveCompressionRate: 2.7207
%        achievedCompressionRate: 2.7207
%
%       Further, levelStruct(1) has the following fields:
%                      treesList: [15x1 double]
%                        nodeType: [15x1 logical]
%                 packagePedigree: [6x4 double]
%                   nActiveLeaves: 0
%
%                and  binaryNodesStruct(1) has the following fields:
%                                  nodeValue: 0.2500
%                                  nodeDepth: 2
%                       leftChildProbability: 0.1250
%                              leftChildType: 0
%                             leftChildDepth: 3
%                      rightChildProbability: 0.1250
%                             rightChildType: 0
%                            rightChildDepth: 3
%                      leftChildSymbolNumber: 6
%                     rightChildSymbolNumber: 7
%                        leftChildNodeNumber: -1
%                       rightChildNodeNumber: -1
%                           parentNodeNumber: 6
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

% histogram size is symbols x numberOfContacts
histogram = huffmanEncoderObject.histogram;
huffmanCodeWordLengthLimit = huffmanEncoderObject.huffmanModuleParameters.huffmanCodeWordLengthLimit;
huffmanTableLength = huffmanEncoderObject.huffmanTableLength;

% set the count to 1 for symbols that didn't occur in all the histograms
histogram(~histogram) = 1;

% number of symbols in the input alphabet
nSymbols = length(histogram);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% step 1
% sort the frequencies/counts in ascending order
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[symbolFrequencies, sortOrder] = sort(histogram);

% from this point onward, the algorithm uses symbolFrequencies which are
% sorted in ascending order and not histogram.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% memory allocation for steps 2 and 3 that follow next
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

nNodes = 2*nSymbols-1; % number of nodes in the huffman tree
treesList = zeros(nNodes,1); % allocate maximum size expected
nodeType = false(nNodes,1); % 0 - leaf, 1 - package, largest size ever needed
packagePedigree = zeros(nSymbols, 4); % package value, both the parents from the previous level, its location in the current treeList


nActiveLeaves = 0;

% create an array of structure called 'levelStruct' of size
% 'huffmanCodeWordLengthLimit  '
% each structure has the following fields: 'treesList', 'nodeType',
% 'packagePedigree'
%
levelStruct = repmat(struct('treesList',treesList,'nodeType',nodeType,'packagePedigree',packagePedigree, ...
    'nActiveLeaves', nActiveLeaves),1,huffmanCodeWordLengthLimit  );

symbolTypes = zeros(nSymbols,1);


nodeNumbers = -1.*ones(nSymbols,1);
symbolNumbers = (1:1:nSymbols)';

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% step 2a
% apply package merge algorithm of Larmore and Hirschberg to build
% huffmanCodeWordLengthLimit   lists of trees
% Variable names used in this section actually follow the convention used
% in [2]
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
tic


levelStruct = apply_package_merge_algorithm(levelStruct,symbolFrequencies, huffmanCodeWordLengthLimit  );
fprintf('\n');
t1 = toc;
fprintf('Step 1: package-merge algorithm to generate trees list took %f seconds\n',t1);


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% step 2b
% count the depth of each leaf to get the codeword length of each symbol
%
% consider the first (2n-2) items in the last list; expand the packages in
% the last list and see how many items in the previous list contributed to
% this list's packages. Iterate all the up to the first list.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


tic
symbolDepths = get_symbolDepths_matlab(levelStruct,symbolFrequencies, huffmanCodeWordLengthLimit  );
if(any(~symbolDepths))
    % need an error message here
    error('GAR:huffmanEncoderClass:InvalidSymbolCodewordLength',...
        'Codeword can never be 0 long.')
end;

t2 = toc;
fprintf('Step 2: computing the symbol codeword length from the trees list took %f seconds\n',t2);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% step 3
% build huffman code binary tree
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
symbolProbabilities = 2.^-symbolDepths;
nodeDepths = symbolDepths;

tic
binaryNodesStruct = build_huffman_code_tree_matlab(symbolProbabilities, nodeDepths, symbolTypes, nodeNumbers, symbolNumbers);

t3 = toc;
fprintf('Step 3: creating the huffman code tree from the symbol depths took %f seconds\n',t3);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% step 4
% generate huffman codewords
% climb up the nodes and assemble the code string
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tic
[huffmanCodeStrings, huffmanCodeLengths] = assemble_huffman_code_strings(binaryNodesStruct, symbolDepths);
t4 = toc;
fprintf('Step 4: creating the huffman code string from the tree took %f seconds\n',t4);


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% step 5
% compute the theretical, effective, and achieved compression rates
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% compute theoretical versus achieved compression
% room for confusion - watch out
% masterHistogram is not sorted in ascending order
% all the other fields correspond to sorted symbol frequencies

symbolFrequencies  = histogram(sortOrder);
[effectiveCompressionRate, theoreticalCompressionRate] = compute_compression_rates(symbolFrequencies, huffmanCodeLengths);


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% step 6
% prepare output structure and copy the results to be returned
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
huffmanOutputStruct.huffmanCodeStrings = cell(nSymbols,1);
huffmanOutputStruct.huffmanCodeLengths = zeros(nSymbols,1);

huffmanOutputStruct.levelStruct = levelStruct;
huffmanOutputStruct.symbolDepths = symbolDepths;
huffmanOutputStruct.binaryNodesStruct = binaryNodesStruct;
huffmanOutputStruct.sortOrder = sortOrder;
huffmanOutputStruct.symbolFrequencies = symbolFrequencies;

% shuffle the current order so code strings correspond to the original
% unsorted order of the symbols
huffmanOutputStruct.huffmanCodeStrings(sortOrder) = huffmanCodeStrings;
huffmanOutputStruct.huffmanCodeLengths(sortOrder) = huffmanCodeLengths;
huffmanOutputStruct.theoreticalCompressionRate = theoreticalCompressionRate;
huffmanOutputStruct.effectiveCompressionRate = effectiveCompressionRate;


%--------------------------------------------------------------------------
% step 7
% validate the huffman codewords, huffman code tree, compression achieved
%--------------------------------------------------------------------------

verify_huffman_codewords(huffmanOutputStruct,huffmanTableLength ,huffmanCodeWordLengthLimit  );

verify_huffman_tree_is_full_binary_tree(huffmanOutputStruct,huffmanTableLength );





return;