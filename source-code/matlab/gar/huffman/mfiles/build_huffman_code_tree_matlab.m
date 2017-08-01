function binaryNodesStruct = build_huffman_code_tree_matlab(symbolProbabilities, nodeDepths, symbolTypes, nodeNumbers, symbolNumbers)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function binaryNodesStruct =
% build_huffman_code_tree_matlab(symbolProbabilities, nodeDepths,
% symbolTypes, nodeNumbers, symbolNumbers)
%
% This function build the full binary tree (huffman code tree)  from the
% symbol probabilities calculated from the the code word length for each
% symbol (symbolProbabilities = 2.^-symbolDepths). This step is identical
% to creating the traditional basic huffman code tree now that symbol probabilities
% have been recomputed to ensure length limited codewords.
%
%
% Inputs:
%           (1) symbolProbabilities - a vector nSymbols long; original
%           symbol probabilities have now been quantized to correspond to
%           their depths
%           (2) nodeDepths - a vector containg the symbol codeword lengths
%           (3) symbolTypes - a vector nSymbols long, initialized to 0
%           (4) nodeNumbers - a vector nSymbols long, initialized to -1
%           (5) symbolNumbers - - a vector nSymbols long, containing 1
%           through nSymbols
%  The input argument list identical to that used by the MEX version of
%  this function.
%
% Output: binaryNodesStruct  (an array of structures)  
%               For example,  binaryNodesStruct(1) has the following fields:
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


nSymbols = length(symbolProbabilities);
binaryNodesStruct = repmat(struct('nodeValue',0, 'nodeDepth',-1,...
    'leftChildProbability',0, 'leftChildType',-1,'leftChildDepth',-1, ...
    'rightChildProbability',0, 'rightChildType',-1,'rightChildDepth',-1,...
    'leftChildSymbolNumber',-1, 'rightChildSymbolNumber',-1,'leftChildNodeNumber',-1,...
    'rightChildNodeNumber',-1, 'parentNodeNumber',-1),1,nSymbols-1);

% symbolDepths is sorted in descending order
for j= 1:nSymbols-1
    % need to extract two nodes that are at the same level

    % for j = 1, first two combined are definitely leaves
    binaryNodesStruct(j).leftChildProbability = symbolProbabilities(1);
    binaryNodesStruct(j).leftChildType = symbolTypes(1); % lowest prob node or leaf
    binaryNodesStruct(j).leftChildDepth = nodeDepths(1);
    binaryNodesStruct(j).rightChildProbability = symbolProbabilities(2);
    binaryNodesStruct(j).rightChildType = symbolTypes(2);
    binaryNodesStruct(j).rightChildDepth = nodeDepths(2);
    binaryNodesStruct(j).nodeValue = sum(symbolProbabilities(1:2));

    if(binaryNodesStruct(j).leftChildType) % a node and not a leaf
        binaryNodesStruct(j).leftChildNodeNumber = nodeNumbers(1);
        binaryNodesStruct(j).leftChildSymbolNumber = -1;
    else
        binaryNodesStruct(j).leftChildNodeNumber = -1;
        binaryNodesStruct(j).leftChildSymbolNumber = symbolNumbers(1);
        symbolNumbers = symbolNumbers(2:end);
    end;
    binaryNodesStruct(j).nodeDepth = binaryNodesStruct(j).leftChildDepth-1;


    if(binaryNodesStruct(j).rightChildType) % a node and not a leaf
        binaryNodesStruct(j).rightChildNodeNumber = nodeNumbers(2);
        binaryNodesStruct(j).rightChildSymbolNumber = -1;
    else
        binaryNodesStruct(j).rightChildNodeNumber = -1;
        binaryNodesStruct(j).rightChildSymbolNumber = symbolNumbers(1);
        symbolNumbers = symbolNumbers(2:end);
    end;
    binaryNodesStruct(j).nodeDepth = binaryNodesStruct(j).rightChildDepth-1;
    % shrink and insert the new node value
    symbolTypes = symbolTypes(2:end);
    nodeDepths = nodeDepths(2:end);
    nodeNumbers = nodeNumbers(2:end);
    symbolProbabilities = symbolProbabilities(2:end);

    symbolProbabilities(1) = binaryNodesStruct(j).nodeValue;
    nodeDepths(1) = binaryNodesStruct(j).nodeDepth ;
    symbolTypes(1) = 1;
    nodeNumbers(1) = j;
    [symbolProbabilities, sortIndex] = sort(symbolProbabilities,'ascend');
    symbolTypes = symbolTypes(sortIndex);
    nodeDepths = nodeDepths(sortIndex);
    nodeNumbers = nodeNumbers(sortIndex);

end;


for j= 1:nSymbols-1

    if(binaryNodesStruct(j).leftChildType) % a node and not a leaf
        leftChildNodeNumber = binaryNodesStruct(j).leftChildNodeNumber;
        binaryNodesStruct(leftChildNodeNumber).parentNodeNumber = j;
    end;

    if(binaryNodesStruct(j).rightChildType) % a node and not a leaf
        rightChildNodeNumber = binaryNodesStruct(j).rightChildNodeNumber;
        binaryNodesStruct(rightChildNodeNumber).parentNodeNumber = j;
    end;
end;
return;

