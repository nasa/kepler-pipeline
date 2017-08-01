function [effectiveCompressionRate, theoreticalCompressionRate] = compute_compression_rates(symbolFrequencies, symbolCodeWordLengths)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [theoreticalCompressionRate, effectiveCompressionRate] =
% compute_compression_rates(symbolFrequencies, symbolCodeWordLengths)
% 
% This function computes the theoretical compression rate (it is an average
% with units of bits/symbol and this average bit rate is the maximum
% achievable) and the effective compression rate (the best possible
% compression that can be achieved based on restricted length Huffman
% codewords).
% 
% Inputs: 
%   symbolFrequencies:  a vector (of length 2^17 - 1) containing the frequencies of symbols 
%   symbolCodeWordLengths:  a vector (of length 2^17 - 1) containing the
%   length of codes associated with the symbols
% 
% Outputs:
%   theoreticalCompressionRate: a scalar, computed as
%   -sum(probabilityOfSymbols.*log2(probabilityOfSymbols)) according to 
%   Shannon's entropy equation
%   effectiveCompressionRate: a scalar computed as
%   sum(probabilityOfSymbols.*symbolCodeWordLengths)
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

% compute theoretical versus achieved compression
% basic data checks, since this function will be called by other CSCIs (PPA
% in particular)
% (1) both arrays must contain positive integers
% (2) symbolFrequencies can conatin zeros, but symbolCodeWordLengths can
% not.
% (3) No upper limit checking available as a library function.
% (4) No tailored error messages from this function should any of the data
% checks fail.

% additional check on the histogram field to exclude
% negative or all zeros/fractional values
if(any(symbolFrequencies < 0)  || any(symbolCodeWordLengths < 0))
    error('Negative values in the inputs')
end;


% check for the presence of fractions and all zeros
if(~any(fix(symbolFrequencies)) || ~any(fix(symbolCodeWordLengths)))
    error('input contains zeros or all fractions ')
end;
% check for the presence of non-integer values
if(any(symbolFrequencies - fix(symbolFrequencies) ))
    error('input contains non integer values ')
end;

if(any(symbolCodeWordLengths - fix(symbolCodeWordLengths) ))
    error('input contains non integer values ')
end;

probabilityOfSymbols = symbolFrequencies./sum(symbolFrequencies);
theoreticalCompressionRate = -sum(probabilityOfSymbols.*log2(probabilityOfSymbols));
effectiveCompressionRate = sum(probabilityOfSymbols.*symbolCodeWordLengths);

return;

