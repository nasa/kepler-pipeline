function [indexInToHuffmanTable, failedToDecodeStreamFlag, bitStream]  = walk_huffman_tree_and_decode_bit_stream(huffmanMatFileName, bitStream)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function indexInToHuffmanTable  =
% walk_huffman_tree_and_decode_bit_stream(huffmanMatFileName, bitStream)
%
% This function takes each bit from the bit stream and walks down the
% huffman tree taking the right or left branch according to '1' or  '0'in the
% current bit. Once a code word is identified, it is removed from the bit
% stream and its index in the table is added to the output array. This
% process is repeated till the entire bit stream is decoded.
%
% generate_length_limited_huffman_code_fast function creates the codewords
% for each symbol located at the terminal nodes (leaves) by tracing parent
% nodes all the way up to the root of the tree. Each left child is given a
% '0' code string and the right child is assigned a '1' code string.
% Starting from the terminal node, if the symbol happens to be a left child
% it picks up a '0'; if its parent happens to be a right child, a '1' is
% added infront and the code string grows till the root node is reached. At
% which point, we have the codeword for the symbol we started out with.
%
% Inputs: (1) binaryNodesStruct (an array of structures)
%          For example,
%                 binaryNodesStruct(1) has the following fields:
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
%
%           (2) symbolDepths - a vector of double containing the depth at
%           which each leaf resides in the tree. [nsymbols x 1 double]
%
%  Outputs:
%           (1) huffmanCodeStrings: a cell array of strings containing
%               variable length huffman codewords
%           (2) huffmanCodeLengths: an array containing the lengths of each
%               code in the huffmanCodeStrings
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% huffmanResultsStruct.binaryNodesStruct(1023)
% ans =
%                  nodeValue: 1
%                  nodeDepth: 0
%       leftChildProbability: 0.5000
%              leftChildType: 1
%             leftChildDepth: 1
%      rightChildProbability: 0.5000
%             rightChildType: 0
%            rightChildDepth: 1
%      leftChildSymbolNumber: -1
%     rightChildSymbolNumber: 1024
%        leftChildNodeNumber: 1022
%       rightChildNodeNumber: -1
%           parentNodeNumber: -1
%bitStream = fliplr(bitStream);
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

if(exist(huffmanMatFileName, 'file'))
    load(huffmanMatFileName);
else
    error('file does not exist');
end

binaryNodesStruct = huffmanResultsStruct.binaryNodesStruct;
huffmanCodeStrings = huffmanResultsStruct.huffmanCodeStrings;

nBinaryNodes = length(binaryNodesStruct);

indexInToHuffmanTable = zeros(length(bitStream),1);

nCountCodeWords = 0;

failedToDecodeStreamFlag = false;

while (~isempty(bitStream))

    notYetReachedLeafFlag = true;

    bitStreamPosition = 0;
    currentNode = nBinaryNodes;

    while(notYetReachedLeafFlag)

        bitStreamPosition = bitStreamPosition + 1;
        if( bitStreamPosition > length(bitStream))
            failedToDecodeStreamFlag = true;
            break; % need 2 breaks to completely break free of 2 while loops
        end;



        if(bitStream(bitStreamPosition)== '1') % bitStream(bitStreamPosition)  = 1, search right branch of the binary tree

            if(binaryNodesStruct(currentNode).rightChildNodeNumber == -1) % right child is a leaf
                notYetReachedLeafFlag = false;
            else
                % right child is node
                currentNode = binaryNodesStruct(currentNode).rightChildNodeNumber;
            end;

        else  % bitStream(bitStreamPosition)  = 0, search left branch of the binary tree
            if(binaryNodesStruct(currentNode).leftChildNodeNumber == -1) % left child is a leaf
                notYetReachedLeafFlag = false;
            else
                % left child is node
                currentNode = binaryNodesStruct(currentNode).leftChildNodeNumber;
            end;

        end;

        if(~notYetReachedLeafFlag)
            break;
        end;
    end;


    if( bitStreamPosition > length(bitStream))
        failedToDecodeStreamFlag = true;
        break;
    end;


    % look up huffman table and get the index

    codeWord = bitStream(1:bitStreamPosition);
    nCountCodeWords = nCountCodeWords + 1;


    % look for match in a subset of huffmanCodeStrings that have the same
    % length as the identified codeword in the bit stream

    indexSubset = find(huffmanResultsStruct.huffmanCodeLengths == length(codeWord));
    index = strmatch(codeWord, huffmanCodeStrings(indexSubset), 'exact');

    index = indexSubset(index);

    if(~isempty(index))
        indexInToHuffmanTable(nCountCodeWords) = index;
    else
        error('Could not match bit stream code word to huffman table codewords');
    end;

    bitStream = bitStream(bitStreamPosition+1:end); % remove that part of the stream that has just been decoded

end

indexInToHuffmanTable = indexInToHuffmanTable(1:nCountCodeWords);





return;