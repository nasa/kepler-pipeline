function pseudoRandSeq = gen_CCSDS_pseudo_rand_seq(seqLengthInBytes)
% pseudoRandSeq = gen_CCSDS_pseudo_rand_seq(seqLengthInBytes)
% generates a pseudorandom sequence of length k according to CCSDS 101.0.B.3 blue book
% using the generating polynomial p(x) = x^8 + x^7 + x^5 + x^3 + x^1
% this code is predicated on diagram 6.5 in the reference, which also gives
% the first 40 bits of the 255-bit sequence as:
% 1111 1111 0100 1000 1110 1100 0000 1001 1010 ...
% Note that this sequence repeats after 255 bits
%%
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
a = uint8(255);
pseudoRandSeq = zeros(1,seqLengthInBytes,'uint8');

%%
byteArray = 2.^(7:-1:0);
pseudoRandByte = zeros(8,1);

i = 0; % counts total number of bits desired in output
j = 0; % counts number of bits in current byte

%%
while i<seqLengthInBytes*8

%%
    i = i+1; % increment the counter
    j = j+1; 
    % pull off first bit of a as the current bit of the pseudorandom sequence

    pseudoRandByte(j) = bitget(a,1); 
    
    % contruct the new bit8 for a by xor'ing bits 1, 4, 6, and 8
    newBit8 = xor( xor( xor( bitget(a,1), bitget(a,4)), bitget(a,6)), bitget(a,8));

    % shift a to the right by one, dropping the leftmost bit
    a = bitshift(a,-1);
    
    % if newBit8 ==1, set it
    if newBit8 == 1
        a = bitset(a,8);
    end
    
    if j==8 % byte boudary
        j = 0;
        pseudoRandSeq(i/8) = uint8(byteArray*pseudoRandByte);
    end
    
    %disp(bitget(a,8:-1:1)) % display the current state of a
%%

end

