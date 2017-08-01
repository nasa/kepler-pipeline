function vcdusReshaped = ...
    interleave_vcdus(vcdus, rsInfoBlockLength, interleavingFactor)
% vcdusReshaped = ...
%     interleave_vcdus(vcdus, interleavingFactor, ...
%     rsInfoBlockLength, numVcduBlocks)
% reshape vcdus as a 2-D array to allow for vectorization of RS code
%
% if the input vcdus were a row vector of 1:3*1115 with an interleavingFactor
% of 5, and an rsInfoBlockLength of 223 the output should be an array with 
% 15 112-length rows, and it appear as:
%   Columns 1 through 9
%            1           6          11          16          21          26          31          36          41
%            2           7          12          17          22          27          32          37          42
%            3           8          13          18          23          28          33          38          43
%            4           9          14          19          24          29          34          39          44
%            5          10          15          20          25          30          35          40          45
%         1116        1121        1126        1131        1136        1141        1146        1151        1156
%         1117        1122        1127        1132        1137        1142        1147        1152        1157
%         1118        1123        1128        1133        1138        1143        1148        1153        1158
%         1119        1124        1129        1134        1139        1144        1149        1154        1159
%         1120        1125        1130        1135        1140        1145        1150        1155        1160
%         2231        2236        2241        2246        2251        2256        2261        2266        2271
%         2232        2237        2242        2247        2252        2257        2262        2267        2272
%         2233        2238        2243        2248        2253        2258        2263        2268        2273
%         2234        2239        2244        2249        2254        2259        2264        2269        2274
%         2235        2240        2245        2250        2255        2260        2265        2270        2275
% etc.
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

if size(vcdus,1) ~=1
    error('vcdus must be a row vector')
end

numVcduBlocks = size(vcdus,2)/rsInfoBlockLength/interleavingFactor;

vcdus = reshape(vcdus,[interleavingFactor,rsInfoBlockLength,numVcduBlocks]);

vcdus = permute(vcdus,[2,1,3]); % for convenience

vcdus = reshape(vcdus,[rsInfoBlockLength,interleavingFactor*numVcduBlocks]);

vcdus = vcdus'; % now there are interleavingFactor*numVcduBlocks rows, each
%                 of length 223 (rsInfoBlockLength)
vcdusReshaped = vcdus;
return
