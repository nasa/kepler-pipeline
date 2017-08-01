function ancillaryDataStruct = inspect_ancillary_data_for_large_gaps(ancillaryDataStruct, cadenceTimes)

%---------------------------------------------------------------------
% step 1d: decide which ancillary data set to discard based on the gaps
%---------------------------------------------------------------------
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

nAncillaryDataSets = length(ancillaryDataStruct);
hoursInDay = 24;

for j = 1:nAncillaryDataSets

    % if the ancillary data timestamps do not cover the same time range as
    % cadence time stamps, then too discard that particular ancillary
    % engnieering time series

    ancillaryDataStruct(j).discardAncillaryDataSetIndicator = false;

    if(~isempty(ancillaryDataStruct(j).timestamps)) % set the time stamps

        gapSizeInTheBeginining = max((cadenceTimes(1) - ancillaryDataStruct(j).timestamps(1)), 0);% MJD
        gapSizeInTheBegininingInHours = gapSizeInTheBeginining*hoursInDay;% hours
        gapSizeInTheEnd = max((cadenceTimes(end) - ancillaryDataStruct(j).timestamps(end)), 0);% MJD
        gapSizeInTheEndInHours = gapSizeInTheEnd*hoursInDay;


        if((gapSizeInTheBegininingInHours >  ancillaryDataStruct(j).maxAcceptableGapInHours )...
                ||(gapSizeInTheEndInHours > ancillaryDataStruct(j).maxAcceptableGapInHours))

            if(ancillaryDataStruct(j).isAncillaryEngineeringData)
                fprintf('Ancillary engineering data set %s  available over the period [%f %f] does not cover the same time frame as the pixel time series [%f %f]\n',...
                    ancillaryDataStruct(j).mnemonic,  [ancillaryDataStruct(j).timestamps(1) ancillaryDataStruct(j).timestamps(end)],...
                    [cadenceTimes(1), cadenceTimes(end)]);
            else

                fprintf('Ancillary data set %s  available over the period [%f %f] does not cover the same time frame as the pixel time series [%f %f]\n',...
                    ancillaryDataStruct(j).mnemonic,  [ancillaryDataStruct(j).timestamps(1) ancillaryDataStruct(j).timestamps(end)],...
                    [cadenceTimes(1), cadenceTimes(end)]);
            end

            ancillaryDataStruct(j).discardAncillaryDataSetIndicator = true;

        end


        % deduce gaps from timestamps
        % if there are huge gaps, discard those ancillary engineering data time
        % series

        ancillaryDataTimeStamps = ancillaryDataStruct(j).timestamps;
        largestGap = max(diff(ancillaryDataTimeStamps));
        largestGapInHours = (max((largestGap - ancillaryDataStruct(j).maxAcceptableGapInHours),0))* hoursInDay;
        if(largestGapInHours > ancillaryDataStruct(j).maxAcceptableGapInHours)
            ancillaryDataStruct(j).discardAncillaryDataSetIndicator = true;
        end;

    end

end

return