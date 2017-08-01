Copyright 2017 United States Government as represented by the
Administrator of the National Aeronautics and Space Administration.
All Rights Reserved.

NASA acknowledges the SETI Institute's primary role in authoring and
producing the Kepler Data Processing Pipeline under Cooperative
Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
NNX11AI14A, NNX13AD01A & NNX13AD16A.

This file is available under the terms of the NASA Open Source Agreement
(NOSA). You should have received a copy of this agreement with the
Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.

No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
AND DISTRIBUTES IT "AS IS."

Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
TERMINATION OF THIS AGREEMENT.

README.txt

Length Limited Huffman encoding:

For LINUX OS:

1. Check out the directory 'huffman' from subversion
2. Compile the .c files from within MATLAB (use following commands)
	(a) mex -setup 
	(b) mex -g -v get_symbol_depths.c
	(c) mex -g -v build_huffman_code_tree.c
3. Make sure the compiled files (*.mexglx) files are put in 'mfiles' directory.

4. To run the length limited huffman encoding component:

    huffmanData.histogramsInEffect = fix(10000*rand(50,1))+1; 
    huffmanData.lastHistogram = []
    huffmanData.lastHistogramCodeWordLengths = []
    huffmanData.lengthOfHuffmanTable = 50
    huffmanData.HUFFMAN_TABLE_LENGTH = 50
    huffmanData.HUFFMAN_CODEWORD_LENGTH_LIMIT = 6;

	[huffmanResults] = huffman_matlab_controller(huffmanData);

5. Once the script finishes, type the following:

	draw_huffman_code_tree(huffmanResults);

6. There is a plot of a full binary tree (since symbols are equiprobable) on the screen and a .jpg image in the present working directory.

7. To run the length limited huffman encoding component in the unconstrained (regular huffman) mode

    huffmanData.HUFFMAN_CODEWORD_LENGTH_LIMIT = 15;
	[huffmanResults] = huffman_matlab_controller(huffmanData);
