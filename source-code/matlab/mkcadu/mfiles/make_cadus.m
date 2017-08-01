function cadus = make_cadus(vcdus)
% cadus = ccsds_vcdu(vcdus)
% returns CADUs that have had Reed Solomon checkbits added
% "randomization" applied, and the ASM word attached
% according to CCSDS standards Blue Book 131.0-B-1
% The input VCDUs are assumed to be all of length 1275-160 = 1115 bytes
% except possibly the last one, corresponding to 5x223 bytes. vcdus should 
% be a row vector. if vcdus is not an integral number of 1115 byte-length 
% segments, then  the last is treated as a short frame and a shortened 
% RS code is generated.
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

persistent pseudoRandSeq RSstruct ASM

%% Set up parameters
interleavingFactor = 5;

rsCodeBlockLength = 255; % number of symbols per codeblock
rsInfoBlockLength = 223; % number of RS information symbols per codeblock
numCheckBytes = rsCodeBlockLength - rsInfoBlockLength;

vcduBlockLength = interleavingFactor*rsCodeBlockLength; % bytes
vcduInfoBlockLength = rsInfoBlockLength*interleavingFactor;
caduBlockLength = vcduBlockLength + 4; % 4 bytes for the ASM

%% Data specific information
nVcdusInBytes = length(vcdus);

numVcduBlocks = ceil(nVcdusInBytes/vcduInfoBlockLength);

shortFrameFlag = (numVcduBlocks*vcduInfoBlockLength ~= nVcdusInBytes);

% pad out vcdus to be an integral number of full-size blocks
% extra bytes will be added to the short vcdu which are stripped before 
% transmitting the data
if shortFrameFlag
    missingBytes = numVcduBlocks*vcduInfoBlockLength - nVcdusInBytes;
    
    vcdus = [vcdus(1:vcduInfoBlockLength*(numVcduBlocks-1)),...
        zeros(1,missingBytes,'uint8'),...
        vcdus(vcduInfoBlockLength*(numVcduBlocks-1)+1:end)];
    
end


%% Set up Reed Solomon Coding, pseudo random sequence and ASM
if isempty(RSstruct)
    RSstruct = setupRS;
end

%% set up pseudo random sequence
%  of compatible length for the vcdu blocks
if isempty(pseudoRandSeq)
    pseudoRandSeq = gen_CCSDS_pseudo_rand_seq(vcduBlockLength);
end

%% set up ASM (Attached Sync Word)
if isempty(ASM)
    ASM = setup_ASM;
end

%% Take input VCDUs and reshape them to allow for interleaving
% reshape as a 2-D array to allow for vectorization of RS code

vcdusInterleaved = ...
    interleave_vcdus(vcdus, rsInfoBlockLength, interleavingFactor);
    
%% tranform input information from dual basis into conventional basis

vcdusInRS = RSstruct.berlekamp_to_RS(uint16(vcdusInterleaved)+1); % +1 necessary for 1-based indexing

%% generate checkbits
RScheckbits = generate_rs_checkbits(vcdusInRS, RSstruct);

%% tranform Checkbits back to dual basis
checkbits = RSstruct.RS_to_berlekamp(uint16(RScheckbits)+1);

%% construct cadus from vcdus and RScheckBits
%cadus = [vcdusInterleaved,checkbits];

% reshape vcdus to be numVcduBlocks x 1115
vcdusReshaped = reshape(vcdus,vcduInfoBlockLength,numVcduBlocks)';

% deinterleave checkbits
checkbitsDeinterleaved = deinterleave_cadus(checkbits, numCheckBytes, interleavingFactor);

cadusDeinterleaved = [vcdusReshaped, checkbitsDeinterleaved];
 
%% randomize cadu contents
% generate a periodic index vector of the vcdu block length with
% a period equal to that of the pseudorandom sequence
cadusRandomized = bitxor(cadusDeinterleaved,...
    repmat(pseudoRandSeq,size(cadusDeinterleaved,1),1)); % randomize here

% add the ASM to each vcdu
cadusPlusASM = [repmat(ASM,numVcduBlocks,1),cadusRandomized];

% reshape to be a row vector
cadus = cadusPlusASM';

cadus = cadus(:)'; % turn into a row vector

%% Deal with short (last) frame
if shortFrameFlag
    % remove "missing" bytes
    cadus = [cadus(1:(numVcduBlocks-1)*caduBlockLength),cadus(end-caduBlockLength+1+missingBytes:end)];
    
end

%%
return

