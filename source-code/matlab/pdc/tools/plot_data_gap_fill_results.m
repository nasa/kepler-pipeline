%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function plot_data_gap_fill_results(dataIndicators, timeSeriesTrue,
% timeSeriesWithGaps, timeSeriesWithGapsFilled)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Description: This function plots the time series with data gaps.
%
% Inputs:
%         dataIndicators = a logical array with 1's indicating available samples and 0's indicating data gap
%         timeSeriesTrue = time series with all the samples
%         timeSeriesWithGaps = time series into which data gaps have been
%         introduced
%         timeSeriesWithGapsFilled = time series where data gaps have been filled with estimated samples
%
% Output:
%         Plot of 3 time series
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
function [h1 h2 h3] =  plot_data_gap_fill_results(dataIndicators, timeSeriesTrue, timeSeriesWithGaps, timeSeriesWithGapsFilled)

indexAvailable = find(dataIndicators==1);
indexUnavailable = find(dataIndicators==0);

figure;
h1 = plot(timeSeriesTrue,'b.:');
hold on;


while(true)

    if(isempty(indexAvailable) && isempty(indexUnavailable))
        break;
    end;

    if(~isempty(indexAvailable))
        startIndex = indexAvailable(1);
    else
        startIndex =  length(timeSeriesWithGaps);
    end;



    if(~isempty(indexUnavailable))
        endIndex = indexUnavailable(1);
    else
        endIndex = length(timeSeriesWithGaps);
    end


    % gap occurs even before the first available data sample
    if(startIndex > endIndex)

        startIndex = indexUnavailable(1);

        if(~isempty(indexAvailable))
            endIndex = indexAvailable(1);
        else
            endIndex = length(timeSeriesWithGaps);
        end


        indexInBlock = max(startIndex-1,1):endIndex;
        h3 = plot(indexInBlock, timeSeriesWithGapsFilled(indexInBlock),'ro-');
        indexUnavailable = indexUnavailable(indexUnavailable > endIndex);

    else

        indexInBlock = startIndex:endIndex-1;
        h2 = plot(indexInBlock, timeSeriesWithGaps(indexInBlock),'bx-');
        indexAvailable = indexAvailable(indexAvailable > endIndex);

    end;

end;
legend([h1 h2 h3],{'Original Signal','Signal with gaps','Signal with gaps filled' });
set(gca,'fontsize',7);
hold off;

return;
