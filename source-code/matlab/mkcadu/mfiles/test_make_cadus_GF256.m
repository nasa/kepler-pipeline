function status = test_make_cadus()
% test_make_cadus
%
% executes a number of unit tests to validate the output of make_cadus
%
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

%% Set up parameters
interleavingFactor = 5;

rsCodeBlockLength = 255; % number of symbols per codeblock
rsInfoBlockLength = 223; % number of RS information symbols per codeblock

vcduBlockLength = interleavingFactor*rsCodeBlockLength; % bytes
vcduInfoBlockLength = rsInfoBlockLength*interleavingFactor;
caduBlockLength = vcduBlockLength + 4; % 4 bytes for the ASM

%%
status = 0; % groovy

%% set up RS stuff
RSstruct = setupRS(GF256);

G = RSstruct.G;
alphaToTheN = RSstruct.alphaToTheN;
%RS_to_berlekamp = RSstruct.RS_to_berlekamp;
%berlekamp_to_RS = RSstruct.berlekamp_to_RS;
logAlphaOfWord = RSstruct.logAlphaOfWord;

%% test to see that the berlekamp_to_RS and RS_to_berlekamp are correct
% also tests that the alphaToTheN table is correctly generated
status = confirm_RS_berlekamp_mapping;

ii256 = GF256(0:255);
test = berlekamp_to_RS(RS_to_berlekamp(ii256));
if all(ii256==test)
    disp('Success: berlekamp_to_RS and RS_to_berlekamp are inverses')
else
    disp('Disaster: berlekamp_to_RS and RS_to_berlekamp are NOT inverses')
    status = -1;
end

%% test G by generating roots explicitly
% g(x) = prod((x-alpha^11j)) for j = 112 to 143

Groots = GF256(2).^(11*(112:143));
nRoots = length(Groots);

% test that the generated roots are the roots of G(x)
GofGroots = polyval(GF256(G),GF256(Groots));
    
if all(GofGroots==0)
    disp('Success! The roots of G are really the roots of G!')
else
    disp('Disaster! The roots of G are not roots of G!')
    status = -1;
end

% try to reconstruct G(x) from its roots (generated here)
Gtest = GF256(1);
for i=1:nRoots
    Gtest = conv(Gtest, [GF256(1),Groots(i)]);
end

if all(G==Gtest)
    disp('Success: We reconstructed G from its roots!')
else
    disp('Disaster: We didn''t reconstruct G from its roots!')
    status = -1;
end

%% test pseudo random sequence against CCSDS 101.0-B-3
pseudoRandSeq = gen_CCSDS_pseudo_rand_seq(caduBlockLength-4);
pseudoRandSeqReference =['11111111';'01001000';'00001110';'11000000';'10011010']; % from CCSDS 101.0-B-3
pseudoRandSeqString = dec2bin(pseudoRandSeq);
if all(pseudoRandSeqReference == pseudoRandSeqString(1:5,:))
    disp('Success: first 40 bits of pseudorandom sequence match CCSDS 101.0-B-3!')
else
    disp('Disaster: first 40 bits of pseudorandom sequence don''t match CCSDS 101.0-B-3!')
end

%% generate test vcdus and test whether the cadus have valid codewords
nTestBlocks = 100;
vcduBlockLength = 1115;
caduBlockLength = vcduBlockLength+160+4;
rand('seed',0); % reset rand
vcdus = uint8(floor(rand(1,vcduBlockLength*nTestBlocks)*256));

%% make cadus
cadus = make_cadus_GF256(vcdus);

%% reshape cadus to strip ASMs and de-randomize
nCaduBlocks = length(cadus)/caduBlockLength;
if nCaduBlocks~=fix(nCaduBlocks)
    disp('error: cadu blocks not correct length')
    status = -1;
end

cadus = reshape(cadus,caduBlockLength,nCaduBlocks)';

%% Test ASMS for correctness
ASMs = cadus(:,1:4);

ASM = setup_ASM;

if all(repmat(ASM,size(cadus,1),1)==ASMs)
  disp('success: ASMs added correctly')
else
  disp('disaster: ASMS not added correctly')
  status = -1;
end

%%
ASMreference = ['00011010';
                '11001111';
                '11111100';
                '00011101'];
ASMstring = display_bits(GF256(ASM));

if all(ASMreference==ASMstring)
    disp('Success: ASM matches CCSDS 101.0-B-3!')
else
    disp('Disaster: ASM matches CCSDS 101.0-B-3!')
    status = -1;Success
end

%% remove ASMs
cadusMinusASMs = cadus(:,5:end);

%% derandomize

cadusMinusASMsDerandomized = ...
  GF256(cadusMinusASMs)+repmat(pseudoRandSeq,size(cadus,1),1);

%% map to RS basis
cadusMinusASMsDerandomizedRS = ...
    berlekamp_to_RS(cadusMinusASMsDerandomized);

%% interleave
RSwords = [cadusMinusASMsDerandomizedRS(:,1:5:end);...
           cadusMinusASMsDerandomizedRS(:,2:5:end);...
           cadusMinusASMsDerandomizedRS(:,3:5:end);...
           cadusMinusASMsDerandomizedRS(:,4:5:end);...
           cadusMinusASMsDerandomizedRS(:,5:5:end)];
 
%% calculate syndromes and test that they are zero for all blocks
RSwords = GF256(RSwords);
Groots = GF256(Groots);
syndromes = polyval(RSwords,Groots(:)');

if all(syndromes==0)
    disp('success: all syndromes = 0!')
else
    disp('disaster: some syndromes ~= 0!') 
    status = -1;
end

%% test interleaving
testVcdu = (1:1115*2);
numVcduBlocks = 2;
testVcduInterleaved = interleave_vcdus(testVcdu,rsInfoBlockLength, interleavingFactor);

%%
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function status = confirm_RS_berlekamp_mapping()

status = 0; % groovy!

%% load in material from CCSDS 301.B.1.3
temp = load('RsBerlekampMapping.txt');
alphaPowereedSolomon1 = temp(:,1);
reedSolomonReference1 = temp(:,2);
berlekampReference1 = temp(:,3);
alphaPowereedSolomon2 = temp(:,4);
reedSolomonReference2 = temp(:,5);
berlekampReference2 = temp(:,6);
alphaPower = [alphaPowereedSolomon1;alphaPowereedSolomon2];
reedSolomonReference = [reedSolomonReference1;reedSolomonReference2];
berlekampReference = [berlekampReference1;berlekampReference2];

clear alphaPowereedSolomon1 alphaPowereedSolomon2 reedSolomonReference1 reedSolomonReference2
clear berlekampReference1 berlekampReference2

[alphaPowerReference, isort] = sort(alphaPower);
reedSolomonReference = reedSolomonReference(isort);
berlekampReference = berlekampReference(isort);


reedSolomonReferenceString = reshape(sprintf('%8i',reedSolomonReference),8,256)';
reedSolomonReferenceString(reedSolomonReferenceString==' ')='0';

berlekampReferenceString = reshape(sprintf('%8i',berlekampReference),8,256)';
berlekampReferenceString(berlekampReferenceString==' ')='0';

%% now get our version
RSstruct = setupRS;
alphaToTheN = GF256([0,RSstruct.alphaToTheN(:)']);
alphaToTheNstring = display_bits(alphaToTheN);
berlekamp = RS_to_berlekamp(alphaToTheN);
berlekampString = display_bits(berlekamp);

%% compare the two versions
alphaToTheNerror = abs(reedSolomonReferenceString)-abs(alphaToTheNstring);

berlekampError = abs(berlekampReferenceString)-abs(berlekampString);

if all(alphaToTheNerror==0)
    disp('Success: alphaToTheN matches CCSDS 101.0-B-3!')
else
    disp('Disaster: alphaToTheN doesn''t match CCSDS 101.0-B-3!')
    status = -1;
end

if all(berlekampError==0)
    disp('Success: berlekamp matches CCSDS 101.0-B-3!')
else
    disp('Disaster: berlekamp doesn''t match CCSDS 101.0-B-3!')
    status = -1;
end

