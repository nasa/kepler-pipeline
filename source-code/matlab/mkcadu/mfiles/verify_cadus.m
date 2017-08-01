function status = verify_cadus(vcduFile, caduFile, numWorkingBlocks, debugFlag)
% verify_cadus
%
% opens and reads in a vcdu file and a cadu file and checks to see that
% the cadu file is valid and matches the expected cadus in the vcdu file.
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

if nargin<3
    numWorkingBlocks = 1000;
end

if nargin<4
    debugFlag = 0;
end

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

%% set up roots of generating polynomial
% g(x) = prod((x-alpha^11j)) for j = 112 to 143

Groots = GF256(2).^(11*(112:143));
nRoots = length(Groots);


%% set up ASM
ASM = setup_ASM;


%% gernerate pseudo random sequence
pseudoRandSeq = gen_CCSDS_pseudo_rand_seq(caduBlockLength-4);

%% open files and set up some parameters for reading them

fidVcdus = fopen(vcduFile,'r');
fseek(fidVcdus,0,'eof');
nBytesInVcduFile = ftell(fidVcdus);
numBlocksTotal = nBytesInVcduFile/vcduInfoBlockLength;
frewind(fidVcdus);

fidCadus = fopen(caduFile,'r');
fseek(fidCadus,0,'eof');
nBytesInCaduFile = ftell(fidCadus);
numCaduBlocksTotal = nBytesInCaduFile/caduBlockLength;
frewind(fidCadus);

if numBlocksTotal~=numCaduBlocksTotal
    warning('VERIFY_CADUS:NumberOfVcdusNeNumberOfCadus','number of cadus doesn''t match number of vcdus!')
end

%% 

numReads = fix(numBlocksTotal/numWorkingBlocks);
count = 0;

if debugFlag
    h = waitbar(count/numReads);
end

while ~feof(fidVcdus)

    count = count+1;
    
    % read in block of vcdu data
    vcdus =fread(fidVcdus,[1, vcduInfoBlockLength*numWorkingBlocks],'uint8=>uint8');
    cadus =fread(fidCadus,[1, caduBlockLength*numWorkingBlocks],'uint8=>uint8');

    % reset numWorkingBlocks if we have a short chunck at the end
    numWorkingBlocks = length(vcdus)/vcduInfoBlockLength;
    
    % generate cadus from vcdus
    cadusFromVcdus = make_cadus(vcdus);
    
    if any(cadus~=cadusFromVcdus)
        warning('cadus generated from vcdus don''t match cadus in file')
        status = -1;
    end
    
    % reshape vcdus and cadus
    vcdus = reshape(vcdus,vcduInfoBlockLength,numWorkingBlocks)';
    cadus = reshape(cadus,caduBlockLength,numWorkingBlocks)';
    cadusFromVcdus= reshape(cadusFromVcdus,caduBlockLength,numWorkingBlocks)';
    
    % strip of ASMS from cadus
    ASMs = cadus(:,1:4);
    cadusMinusASMs = cadus(:,5:end);
    
    if ~all(all(ASMs == repmat(ASM,numWorkingBlocks,1)))
        error('ASM not attached to cadus correctly')
    end
    
    % derandomize cadu contents
    cadusDerandomized = bitxor(cadusMinusASMs,repmat(pseudoRandSeq,numWorkingBlocks,1));
    
    % strip out information words from derandomized cadus
    % these should match vcdus exactly
    % this is redundant
    vcdusFromCadus = cadusDerandomized(:,1:vcduInfoBlockLength);
    
    % check data content of cadus against original vcdus
    if any(vcdus~=vcdusFromCadus)
        warning('vcdus don''t match content of cadus')
        status = -1;
    end
    
%%    %% compute syndromes and test whether they are all 0 as expected
    % first reshape cadus
    RSwords = [cadusDerandomized(:,1:5:end);...
               cadusDerandomized(:,2:5:end);...
               cadusDerandomized(:,3:5:end);...
               cadusDerandomized(:,4:5:end);...
               cadusDerandomized(:,5:5:end)];
    
    % then transform from dual basis to RS basis
    RSwords = berlekamp_to_RS(GF256(RSwords));
    
    syndromes = polyval(RSwords, Groots);
    
    if ~all(all(syndromes==0))
        warning('syndromes not unanimously 0')
        status = -1;
    end

    if debugFlag
        waitbar(count/numReads)
    end
    
end

if debugFlag
    close(h);
end

return

