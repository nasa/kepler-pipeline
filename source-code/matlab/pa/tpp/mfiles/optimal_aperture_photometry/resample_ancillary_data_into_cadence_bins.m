function ancillaryDataStruct = resample_ancillary_data_into_cadence_bins(ancillaryDataStruct, cadenceTimes, gapFillParametersStruct)
% resample/bin
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

% ancillaryDataStruct.uncertainties is a time series even all the values
% are the same
nAncillaryDataSets = length(ancillaryDataStruct);
nCadences = length(cadenceTimes);


for j = 1:nAncillaryDataSets


    if(~ancillaryDataStruct(j).discardAncillaryDataSetIndicator)

        if(~isempty(ancillaryDataStruct(j).timestamps))
            ancillaryDataTimestamps = ancillaryDataStruct(j).timestamps;

            meanCadenceInterval = mean(abs(diff(cadenceTimes)));
            cadenceBinEdges = [max((cadenceTimes(1)-meanCadenceInterval),0); cadenceTimes(:) ];

            [nCount, binAssignment] =  histc(ancillaryDataTimestamps, cadenceBinEdges); % number of bins = nCadences


            ancillaryDataStruct(j).dataGapIndicators = false(nCadences,1);


            ancillaryDataStruct(j).binnedValues = zeros(nCadences,1);
            ancillaryDataStruct(j).uncertaintyInBinnedValues = zeros(nCadences,1);

            for iCadence = 1:nCadences

                indexOfSamplesInBin = find(binAssignment == iCadence);
                if(~isempty(indexOfSamplesInBin))
                    ancillaryDataStruct(j).binnedValues(iCadence) = mean(ancillaryDataStruct(j).values(indexOfSamplesInBin));
                ancillaryDataStruct(j).uncertaintyInBinnedValues(iCadence) = ...
                    norm(ancillaryDataStruct(j).values(indexOfSamplesInBin))/sqrt(length(indexOfSamplesInBin)); % rms of uncertainties of the samples that went into the bin
                end

            end



            binsWithData = unique(binAssignment);
            binsWithData = binsWithData(binsWithData > 0);
            gapList = setxor(binsWithData, (1:nCadences)');

            if(~isempty(gapList))

                ancillaryDataStruct(j).dataGapIndicators(gapList) = true;
                % bins that don't have any values are data gaps
                
                % remember to propagate uncertainties to the filled-in
                % values

                ancillaryTimeSeriesWithGaps = ancillaryDataStruct(j).binnedValues;
                ancillaryTimeSeriesWithGaps(gapList) = 0;
                
                ancillaryTimeSeriesWithUncertainties = ancillaryDataStruct(j).uncertaintyInBinnedValues;
                
                dataGapIndicators =  ancillaryDataStruct(j).dataGapIndicators;

                [ancillaryTimeSeriesWithGapsFilled, ancillaryTimeSeriesWithUncertainties]  = ...
                    fill_short_data_gaps(ancillaryTimeSeriesWithGaps, dataGapIndicators,gapFillParametersStruct,ancillaryTimeSeriesWithUncertainties);

                ancillaryDataStruct(j).binnedValues(gapList) = ancillaryTimeSeriesWithGapsFilled(gapList);
                ancillaryDataStruct(j).uncertaintyInBinnedValues(gapList) = ancillaryTimeSeriesWithUncertainties(gapList);

            end;

        else

            ancillaryDataStruct(j).binnedValues = ancillaryDataStruct(j).values;
        end



    end


end