%--------------------------------------------------------------------------
% Jon's quick analysis using 1 day ETEM2 run using new requantization table
%
% based on the histogram computes the theoretical compression rate in bits
% per pixel
%--------------------------------------------------------------------------
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
clc;
load /path/to/newRequantTables/requantizationTable.mat;

pathName = '/path/to/matlab/etem2/mfiles/output/run_long_m12o1s1/ssrOutput/';
fid = fopen([pathName 'requantizedCadenceData.dat'], 'r', 'ieee-be');

x = fread(fid, inf, 'uint32');

% number of cadences in the file 49
xi = interp1(requantizationTable,(1:length(requantizationTable)),x,'near');

x = reshape(x,53047,97);

xi = reshape(xi,53047,97);

plot(xi(1,:))
plot(xi(1:100,:)')

nCadences = 97;

baselineInterval = 48;

xiResidual = xi;

baselineCadence = 1;
baselineIntervalIndex = (1:baselineInterval)';
for i = 1:floor(nCadences/baselineInterval);

    xiResidual(:,baselineIntervalIndex) = xi(:,baselineIntervalIndex)-repmat(xi(:,baselineCadence),1,baselineInterval); % subtracting baseline
    baselineIntervalIndex = baselineIntervalIndex + baselineInterval;
    baselineCadence = baselineCadence + baselineInterval;
    
end

[nn,xx] = hist(colvec(xiResidual(:,setdiff(1:nCadences,[1:baselineInterval:nCadences]))),(-2^16:2^16)); % ignore the first baseline cadence

freqSymbols = nn/sum(nn);
theoreticalEntropy =  -sum(freqSymbols(freqSymbols>0).*log2(freqSymbols(freqSymbols>0)));

 maxPossibleCompression =   (96*theoreticalEntropy + 16)/96; % 16 bits are required to encode the baseline pixel

%(48*5+16)/48

semilogy(xx,nn)
