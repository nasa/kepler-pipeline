function levelStruct = apply_package_merge_algorithm(levelStruct,symbolFrequencies, huffmanCodeWordLengthLimit  )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function levelStruct =
% apply_package_merge_algorithm(levelStruct,nSymbols,symbolFrequencies,
% huffmanCodeWordLengthLimit  )
% This algorithm of Larmore and Hirschberg huffmanCodeWordLengthLimit  
% lists of trees are developed, with each tree in each list having an
% associated weight. The first list is simply a list of nSymbols
% leaves(residual requantization values) and the weights are the counts in
% the histogram bins. The second list is then developed by merging, in
% increasing weight order, a copy of the first list  with a list of
% packages produced from the first list. Packages are produced from a list
% of trees by forming new trees by combining two trees at a time. the
% weight of the package is the sum of the weights of individual trees. This
% list is sorted in the order of weights. This process continues till all
% the lists are developed.
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
% Output: levelStruct - one of the inputs but all fields filled
% 
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

jLevelNumber = 1;
nSymbols = length(symbolFrequencies);
nActiveLeaves = zeros(huffmanCodeWordLengthLimit  ,1);

levelStruct(jLevelNumber).treesList = levelStruct(jLevelNumber).treesList(1:nSymbols); % trim to correct size for this level
levelStruct(jLevelNumber).treesList = symbolFrequencies;
levelStruct(jLevelNumber).nodeType = levelStruct(jLevelNumber).nodeType(1:nSymbols,1); % shrink allocated size, all leaves
levelStruct(jLevelNumber).packagePedigree = []; % no packages and thus no pedigree information

for jLevelNumber = 2:huffmanCodeWordLengthLimit  

    % create packages
    nPreviousLevelSymbols = length(levelStruct(jLevelNumber-1).treesList);
    nCurrentLevelPackages = fix(nPreviousLevelSymbols/2);
    levelStruct(jLevelNumber).packagePedigree = levelStruct(jLevelNumber).packagePedigree(1:nCurrentLevelPackages,4);

    % if nPreviousLevelSymbols is odd, use only the first
    % (nPreviousLevelSymbols -1) entries from the previous level
    if(mod(nPreviousLevelSymbols,2))
        nPreviousLevelSymbols = nPreviousLevelSymbols -1;
    end;
    nPackageCount = 0;
    for kTree = 1:2:nPreviousLevelSymbols
        nPackageCount = nPackageCount+1;
        levelStruct(jLevelNumber).packagePedigree(nPackageCount,1) = sum(levelStruct(jLevelNumber-1).treesList(kTree:kTree+1));
        levelStruct(jLevelNumber).packagePedigree(nPackageCount,2:3) = [kTree, kTree+1];
    end;

    % first, append all the newly formed packages to the end of the leaves
    levelStruct(jLevelNumber).treesList = [symbolFrequencies; levelStruct(jLevelNumber).packagePedigree(:,1)];
    levelStruct(jLevelNumber).nodeType = levelStruct(jLevelNumber).nodeType(1:nSymbols+nCurrentLevelPackages,1); %memory already allocated; shrink it to exact size;
    levelStruct(jLevelNumber).nodeType(nSymbols+1:end) = true;


    [levelStruct(jLevelNumber).treesList sortedIndex] = sort(levelStruct(jLevelNumber).treesList); % sort in place

    % sort the node type according to the sorted order of treesList
    levelStruct(jLevelNumber).nodeType = levelStruct(jLevelNumber).nodeType(sortedIndex);

    % need to add one more field/column to the package pedigree indicating
    % the location of the package in the current tree list
    packageIndex = find(sortedIndex > nSymbols);
    levelStruct(jLevelNumber).packagePedigree(:,4) = packageIndex;

    % see whether any of the packages are identical in values to leaves
    intersectList = intersect(symbolFrequencies, levelStruct(jLevelNumber).packagePedigree(:,1));
    if(~isempty(intersectList))
        nIntersectValues = length(intersectList);
        for mItemNumber = 1:nIntersectValues
            % complication .. if a package and a leaf has the same weight/value,
            % then the package comes first and then the leaf (left to right ordering
            % of the trees)
            iValue = intersectList(mItemNumber);
            iIndices = find(levelStruct(jLevelNumber).treesList == iValue);
            % see if one is a package
            if(any(levelStruct(jLevelNumber).nodeType(iIndices)))
                % force package first, leaf next
                indexOfIdenticalPackages = find(levelStruct(jLevelNumber).packagePedigree(:,1) == iValue);
                nIdenticalPackages = length(indexOfIdenticalPackages);
                nIdenticalSymbolFrequencies = length(find(symbolFrequencies == iValue));
                levelStruct(jLevelNumber).nodeType(iIndices) = [true(nIdenticalPackages,1); false(nIdenticalSymbolFrequencies,1)];
                levelStruct(jLevelNumber).packagePedigree(indexOfIdenticalPackages,4) = iIndices(1:nIdenticalPackages);

            end;
        end;
    end;
end;


nCurrentLastActiveLeaf  = 2*nSymbols - 2;
% packages appear in list 2 onwards - so the end limit for iteration is set
% to 2
for jLevelNumber = huffmanCodeWordLengthLimit  :-1:2
    nActiveLeaves(jLevelNumber) = nCurrentLastActiveLeaf;

    levelStruct(jLevelNumber).nActiveLeaves  = nActiveLeaves(jLevelNumber);
    % find the last package in the jth list and track its parents in
    % the previous list; their location marks the boundary of active
    % leaves in the (j-1)th list
    nLastPackage = find(levelStruct(jLevelNumber).nodeType(1:nActiveLeaves(jLevelNumber)) > 0, 1, 'last');
    if(~isempty(nLastPackage))
        % locate this in packagePedigree's 4th column
        indexOfPackage = find(levelStruct(jLevelNumber).packagePedigree(:,4) == nLastPackage);
        % find the parents
        nPreviousLastActiveLeaf = max(levelStruct(jLevelNumber).packagePedigree(indexOfPackage,2:3));
        nCurrentLastActiveLeaf = nPreviousLastActiveLeaf;
    else
        nCurrentLastActiveLeaf = 0;
    end;

end;
% the number of active leaves in the first list is determined by how many
% leaves contributed to the packages in the second level - that is in
% packagePedigree field of levelStruct
nActiveLeaves(1) = nCurrentLastActiveLeaf;
levelStruct(1).nActiveLeaves  = nActiveLeaves(1);

return;
