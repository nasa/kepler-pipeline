function [huffmanOutputStruct] = huffman_matlab_controller(huffmanInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [huffmanOutputStruct] =
% huffman_matlab_controller(huffmanInputStruct)
% This function forms the MATLAB side of the science interface and it
% receives inputs via the structure huffmanInputStruct. It first calls the
% constructor for the huffmanClass with huffmanInputStruct as input
% where the fields of the input structure are validated. Then it invokes
% the method generate_huffman_encoding_table on this object and obtains the
% huffman code table as an output. Relevant fields are copied to the
% huffmanResults structure and returned to the huffman_main which writes it
% as a binary file to be parsed by the Java side.
%
% Input: A structure 'huffmanInputStruct' with the fields
%
%               histogram: a vector (2^17-1 ) long
%
%      huffmanModuleParameters: [1x1 struct]
%   huffmanInputStruct.huffmanModuleParameters with the following fields
%    huffmanCodeWordLengthLimit  : 24, number of bits in the ADC
%                       debugFlag: 0
% Output: A structure 'huffmanOutputStruct' with the following fields:
%           huffmanCodeStrings.string: {26x1 cell}
%            huffmanCodeLengths.array: [26x1 double]
%          theoreticalCompressionRate: 2.6911
%            effectiveCompressionRate: 2.7207
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


huffmanEncoderObject  = huffmanEncoderClass(huffmanInputStruct);


huffmanOutputStruct = generate_length_limited_huffman_code_fast(huffmanEncoderObject);

% matlab version of the code  - use when huffmanTableLength  < 1000 or so
%huffmanOutputStruct = generate_length_limited_huffman_code(huffmanEncoderObject);

if(huffmanInputStruct.huffmanModuleParameters.debugFlag)

    dateString = datestr(now);
    dateString = strrep(dateString, '-', '_');
    dateString = strrep(dateString, ' ', '_');
    dateString = strrep(dateString, ':', '_');
    % time stamp the file
    fileName = ['huffman_run_' dateString '.mat'];

    save(fileName, 'huffmanInputStruct', 'huffmanOutputStruct');
    draw_huffman_code_tree(huffmanEncoderObject, huffmanOutputStruct);


    figure;

    hold on;
    symbolFrequencies(huffmanOutputStruct.sortOrder) = huffmanOutputStruct.symbolFrequencies;

    xValues = 1:length(symbolFrequencies);

    subplot(2,1,1);
    plot(xValues, huffmanOutputStruct.huffmanCodeLengths,'Color', 'm', 'Marker', '.');
    title('Huffman Code Word Length Vs. Huffman Table Entry');

    ylabel('Huffman Code Word Length');
    xlabel('Huffman Table Entry');
    % Next, create another axes at the same location as the first, placing
    % the x-axis on top and the y-axis on the right. Set the axes Color to
    % none to allow the first axes to be visible and color code the x- and
    % y-axis to match the data.

    subplot(2,1,2);
    %Draw the second set of data in the same color as the x- and y-axis.
    plot(xValues, symbolFrequencies./sum(symbolFrequencies),'Color','b', 'Marker', 'p');
    xlabel('Huffman Table Entry');
    ylabel('Symbol Probability');

    title('Symbol Probability Vs. Huffman Table Entry');

    isLandscapeFlag = false;
    plot_to_file('HuffmanTableCodeWordLength_Vs_Symbol_Probability',isLandscapeFlag);


end;


close all;
fclose all;



return;