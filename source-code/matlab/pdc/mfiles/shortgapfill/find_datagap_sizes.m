%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [gapSize, dataBlockSize, gapLocations] = ...
% find_datagap_sizes(dataGapIndicators)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
%     This function determines the size of the data gap a missing sample is
%     located; it also determines the size of the data block an available
%     sample is located in.
%
% Input: 
%       dataGapIndicators - a logical array with 1's indicating location of
%       the data gaps
% 
% Output:
%       gapSize - an array of the same size as the number of missing
%       samples, each value indicating the size of the data gap for that
%       index 
%       dataBlockSize - an array of the same size as the number of
%       available samples, each value indicating the size of the data block
%       for that index
%       gapLocations - a matrix with two columns x number of data
%       gaps, indicating the beginning and the end of each gap  
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

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [gapSize, dataBlockSize, gapLocations] = ...
find_datagap_sizes(dataGapIndicators)


% find gap sizes
indexOfUnavailable = find(dataGapIndicators);

% handle the case of no data gaps
if(isempty(indexOfUnavailable))
    gapSize = [];
    dataBlockSize = 1:length(dataGapIndicators);
    gapLocations = [];
    return;
    
end;


numberOfUnavailable = length(indexOfUnavailable);



indexOfGapEndings = find(diff([indexOfUnavailable; indexOfUnavailable(end)]) > 1); % location of gap endings
indexOfGapEndings  = [0;indexOfGapEndings; numberOfUnavailable];
gapSize = zeros(length(indexOfUnavailable),1);

gapLocations = zeros(length(indexOfGapEndings)-1, 2);

% computing the size of each gap, once the locations of gap ends are known,
% is trivial
for k = 1:length(indexOfGapEndings)-1
    if(indexOfGapEndings(k) ~= 0)
        iGapStart = indexOfUnavailable(indexOfGapEndings(k)+1);
    else
        iGapStart = indexOfUnavailable(1);
    end;
    iGapEnd = indexOfUnavailable(indexOfGapEndings(k+1));
    indexStart = indexOfGapEndings(k);
    indexEnd = indexOfGapEndings(k+1);

    gapSize(indexStart+1:indexEnd) = iGapEnd -iGapStart + 1;
    gapLocations(k,1) = iGapStart;
    gapLocations(k,2) = iGapEnd;
end;

% find data block size

indexOfAvailable = find(~dataGapIndicators);
numberOfAvailable = length(indexOfAvailable);
indexOfDataBlockEndings = find(diff([indexOfAvailable; indexOfAvailable(end)]) > 1); % location of data block endings
indexOfDataBlockEndings  = [0;indexOfDataBlockEndings; numberOfAvailable];
dataBlockSize = zeros(length(indexOfAvailable),1);



for k = 1:length(indexOfDataBlockEndings)-1
    if(indexOfDataBlockEndings(k) ~= 0)
        iDataStart = indexOfAvailable(indexOfDataBlockEndings(k)+1);
    else
        iDataStart = indexOfAvailable(1);
    end;
    iDataEnd = indexOfAvailable(indexOfDataBlockEndings(k+1));
    indexStart = indexOfDataBlockEndings(k);
    indexEnd = indexOfDataBlockEndings(k+1);

    dataBlockSize(indexStart+1:indexEnd) = iDataEnd -iDataStart + 1;
end;

return;