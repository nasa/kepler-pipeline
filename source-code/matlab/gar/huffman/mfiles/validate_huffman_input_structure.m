function huffmanInputStruct  = validate_huffman_input_structure(huffmanInputStruct)

%------------------------------------------------------------
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
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'huffmanModuleParameters'; []; []; []};

% I think the the histogram_accumulator.m is artificially truncating the counts to uint32. 
% 
% % Cast the new histogram values to uint32. newHistograms = uint32(newHistograms);
% 
% The worst case scenario is all the pixels in all the modouts crashing into 1 bin - this gives us
% what is possible in the worst case
% 
% For the monthly run, assuming an average target aperture of 80 pixels, an average number of
% targets to be ~2000, about ~4000 background pixels per modout, the maximum number of counts in an
% bin is given by
% 
% >> log2((2000*80 + 4000)*48*30*84) ans =
%          34.207506808388
% So set the upper validation limit in validate_huffman_input_structure to 2^36.

fieldsAndBounds(2,:)  = { 'histogram'; ' >= 0'; '<= 2^36'; []};

validate_structure(huffmanInputStruct, fieldsAndBounds,'huffmanInputStruct');

clear fieldsAndBounds;
%------------------------------------------------------------
fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'huffmanCodeWordLengthLimit';  []; []; '[1:1000]''';}; % this also ensures that this is an integer in the range of 1 through 1e3.
fieldsAndBounds(2,:)  = { 'debugFlag'; '>=0'; '<= 3'; []};

validate_structure(huffmanInputStruct.huffmanModuleParameters, fieldsAndBounds,'huffmanInputStruct.huffmanModuleParameters');

clear fieldsAndBounds;
%------------------------------------------------------------
[huffmanInputStruct.huffmanTableLength, numberOfColumns] = size(huffmanInputStruct.histogram);

if(numberOfColumns > 1)
    % generate error and return
    error('GAR:huffmanEncoderClass:histogram','GAR:huffman:validate_huffman_input_structure:histogram contains multiple columns.')

end


% check for failure case
if(huffmanInputStruct.huffmanModuleParameters.huffmanCodeWordLengthLimit    < log2(huffmanInputStruct.huffmanTableLength))
    % need an error message here
    error('GAR:huffmanEncoderClass:InvalidhuffmanCodeWordLengthLimit',...
        'GAR:huffmanEncoderClass:InvalidhuffmanCodeWordLengthLimitMaximum code length can''t be < log2(length(histogram)).')
end;



return;