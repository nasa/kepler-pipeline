function filteredMat = padded_median_filter( columnVectorMat, filterLength )
%**************************************************************************  
% function [startIndices, gapLengths] = find_gaps( gapIndicators, roi )
%**************************************************************************  
% We extend the time series prior to median filtering in order to mitigate
% edge effects. In the future a more sophisticated approach may yield
% better results. A periodic extension (reflect and flip) might work well.
%
% INPUTS:
%     columnVectorMat : A matrix of column vectors.
%
% OUTPUTS:
%     filteredMat     : A matrix of median-filtered columns.
%
%**************************************************************************  
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
    padLen = fix(filterLength/2);
    topPad = repmat(columnVectorMat(1,:),[padLen 1]);
    bottomPad = repmat(columnVectorMat(end,:),[padLen 1]);
    filteredMat = medfilt1([topPad; columnVectorMat; bottomPad], ...
                     filterLength);
    filteredMat = filteredMat(padLen+1:end-padLen,:);
    
%     % The following code avoids using padding by shortening the window over
%     % which the median is computed as we approach the edges.
%     filteredMat = medfilt1(columnVectorMat, filterLength);
%     edgeLength = fix(filterLength/2);
%     for i = 1:edgeLength
%         filteredMat(i+1,:) = median(columnVectorMat(1:2*i+1, :));
%         filteredMat(end-i,:) = median(columnVectorMat(end-2*i:end,:));
%     end
%     
%     if size(filteredMat,1) >= 2
%         filteredMat(1,:) = filteredMat(2,:);
%         filteredMat(end,:) = filteredMat(end-1,:);
%     end
end


%********************************** EOF ***********************************

