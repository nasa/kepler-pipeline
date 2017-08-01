function  verify_huffman_codewords(huffmanOutputStruct, huffmanTableLength, huffmanCodeWordLengthLimit)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function verify_huffman_codewords(huffmanOutputStruct, huffmanTableLength ,
% huffmanCodeWordLengthLimit)
% This function verifies that the generated Huffman codewords are
% valid codewords containing 0's and 1's, are prefix free, are unique,
% their lengths are <= huffmanCodeWordLengthLimit  , and the compression
% achieved is close to that predicted by theory.
% 
% If any of the checks fail, an error condition occurs.
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
sortOrder = huffmanOutputStruct.sortOrder;

% remember huffmanCodeStrings are for the symbols which are unsorted by
% frequency.
huffmanCodeStrings = huffmanOutputStruct.huffmanCodeStrings(sortOrder);



% huffmanOutputStruct =
%                  levelStruct: [1x9 struct]
%                 symbolDepths: [9x1 double]
%            binaryNodesStruct: [1x8 struct]
%                    sortOrder: [9x1 double]
%           huffmanCodeStrings: {9x1 cell}
%           huffmanCodeLengths: [9x1 double]
%     theoreticalCompressionRate: 2.6911
%        effectiveCompressionRate: 2.7207
%--------------------------------------------------------------------------
% Step 1: This test checks to see whether all the huffman codes are unique
%--------------------------------------------------------------------------

numberOfUniqueCodeWords = length(unique(huffmanCodeStrings));

% you can only check whether the number of unique codewords match the table
% length ( = number of symbols)

if(numberOfUniqueCodeWords  ~= huffmanTableLength )
    % need an error message here
    error('GAR:verifyHuffmanCodewords:NonUniqueCodewords',...
        'Duplicate Huffman codewords detected!')
end;


%--------------------------------------------------------------------------
% Step 2: This test checks to see whether huffman code lengths equal the
% symbol depths computed by packagae-merge algorithm
% also checks whether any of the codewords exceed the stipulated length
%--------------------------------------------------------------------------
nSymbols = length(huffmanOutputStruct.symbolDepths);
lengthOfCodeWords = huffmanOutputStruct.huffmanCodeLengths(sortOrder);

% you can only check whether the number of unique codewords match the table
% length ( = number of symbols)
if(huffmanOutputStruct.symbolDepths ~= lengthOfCodeWords)
    % need an error message here
    error('GAR:verifyHuffmanCodewords:IncorrectLength',...
        'Length of generated Huffman codes do not match the lengths assigned by the package-merge algorithm')
end;

anyExceedMaxLength = any(lengthOfCodeWords > huffmanCodeWordLengthLimit  );
if(anyExceedMaxLength)
    % need an error message here
    error('GAR:verifyHuffmanCodewords:LengthLimitExceeded',...
        'Length limited Huffman code words exceed the stipulated length limit')
end;

%--------------------------------------------------------------------------
% Step 3: This test checks to see whether huffman code words contain only
% '0's and '1's
%--------------------------------------------------------------------------

checkString = false(nSymbols,1);
for j = 1:nSymbols
    checkString(j) = strcmp(unique(huffmanCodeStrings{j}),'01');
    % it is possible for codewords to be all 0's or all 1's too!
    if(~checkString(j))
        checkString(j) = strcmp(unique(huffmanCodeStrings{j}),'0');
    end;
    if(~checkString(j))
        checkString(j) = strcmp(unique(huffmanCodeStrings{j}),'1');
    end;
end;

% you can only check whether the number of unique codewords match the table
% length ( = number of symbols)
if(any(~checkString))
    % need an error message here
    error('GAR:verifyHuffmanCodewords:LengthLimitExceeded',...
        'Generated Huffman codes strings contain characters other than ''0'' and ''1''')
end;


%--------------------------------------------------------------------------
% Step 4: This test checks to see whether the generated code words are
% prefix free
%--------------------------------------------------------------------------
nCodeWords = length(huffmanCodeStrings);

prefixFreeTestPassed = true;

for j = nCodeWords:-1:2

    prefixCodeWord = huffmanCodeStrings{j};
    prefixCodeWordLength = length(prefixCodeWord);

    remainingCodeWords = huffmanCodeStrings(j-1:-1:1);
    isPreFix = strncmp(prefixCodeWord, remainingCodeWords,prefixCodeWordLength);

    if(any(isPreFix))
        prefixFreeTestPassed = false;
        break;
    end;
end;
if(~prefixFreeTestPassed)
    % need an error message here
    error('GAR:verifyHuffmanCodewords:NotPrefixFree',...
        'Generated Huffman codes strings are not prefix free!')
end;
%--------------------------------------------------------------------------
% Step 5: This test checks to see whether the achieved compression is close
% to the theoretical compression in terms of bits/symbol
%--------------------------------------------------------------------------

effectiveCompression = fix(huffmanOutputStruct.effectiveCompressionRate);
predictedCompression = fix(huffmanOutputStruct.theoreticalCompressionRate);

% how close is the bit rate? within a bit perhaps??
% this kind of check is valid for unrestricted Huffman encoding case where
% the lower bound for is Shannon's entropy and upper bound is (lower
% bound + 1)
if(~(effectiveCompression <= predictedCompression+1)) % do not simplify this logic 
    % need an error message here
    error('GAR:verifyHuffmanCodewords:failureToCompress',...
        'Achieved bits/symbols (compression) is not within 1 bit of the theoretically predicted compression!')
end;

return;
