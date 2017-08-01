function RSstruct = setupRS()

%% generate table of alpha^n for n=0:254
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
alphaToTheN = zeros(255,1,'uint8');
alphaToTheN(1) = 1;
for i=2:8
    alphaToTheN(i,:) = 2*alphaToTheN(i-1,:);
end
for i = 9:255
    alphaToTheN(i) = bitxor(bitxor(bitxor(alphaToTheN(i-1,:),...
        alphaToTheN(i-6)),alphaToTheN(i-7)),alphaToTheN(i-8));
end
alphaToTheN = alphaToTheN';

%% create the antilog table
[temp, logAlphaOfWord] = sort(alphaToTheN(1:end));
logAlphaOfWord = logAlphaOfWord - 1; % to compensate for 1-based indexing
%logAlphaOfWord = uint8(logAlphaOfWord); % convert to uint8

%% Set up Tranformation matrices from the conventional RS coder to the dual
%% basis
T = [1 0 0 0 1 1 0 1;
     1 1 1 0 1 1 1 1;
     1 1 1 0 1 1 0 0;
     1 0 0 0 0 1 1 0;
     1 1 1 1 1 0 1 0;
     1 0 0 1 1 0 0 1;
     1 0 1 0 1 1 1 1;
     0 1 1 1 1 0 1 1];
 
%%
Tinv = [1 1 0 0 0 1 0 1;
        0 1 0 0 0 0 1 0;
        0 0 1 0 1 1 1 0;
        1 1 1 1 1 1 0 1;
        1 1 1 1 0 0 0 0;
        0 1 1 1 1 0 0 1;
        1 0 1 0 1 1 0 0;
        1 1 0 0 1 1 0 0];

    %% generate table of Berlekamp representation values for each possible
%% uint8 value
alphaToTheNToBerlekamp = transform_word(alphaToTheN,T);

RS_to_berlekamp = transform_word(uint8(0:255),T);

berlekamp_to_RS = transform_word(uint8(0:255),Tinv);

%% /*** g[ ] are the coefficients of the generating polynomial ****/
logG = [0,249,59,66,4,43,126,251,97,30,3,213,50,66,170,5,24];
logG = [logG,logG(end-1:-1:1)];

G = alphaToTheN(logG+1);


%% set up RSstruct
RSstruct.alphaToTheN = alphaToTheN;
RSstruct.logAlphaOfWord = logAlphaOfWord;
RSstruct.berlekamp_to_RS = berlekamp_to_RS;
RSstruct.RS_to_berlekamp = RS_to_berlekamp;
RSstruct.G = G;
RSstruct.logG = logG;

return
