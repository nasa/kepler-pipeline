function inputsStruct = inject_cosmic_rays_into_PA_input_data(inputsStruct, cosmicRayStruct)
%
% function inputsStruct = inject_cosmic_rays_into_PA_input_data(inputsStruct, cosmicRayStruct)
%
% Injects cosmic rays by hand into CAL input data.
% inputsStruct = CAL input struct
% 
% Here's an example of a cosmic ray struct:
% cosmicRayStruct = 
% 
%          cadenceList: [100 300 1200 1500 2500]
%              madList: [200 50 100 20 25]
%              rowList: [592 1025 177]
%              colList: [190 289 760]
%            blackList: [1039 588]
%      maskedSmearList: [185 759]
%     virtualSmearList: 759
%      maskedBlackFlag: 1
%     virtualBlackFlag: 1
% 
% 
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


% only need to check the row and col lists for PA --> target and background pixels

if( ~isempty(cosmicRayStruct.rowList) && ~isempty(cosmicRayStruct.colList) )

    % do background pixels
    if( ~isempty(inputsStruct.backgroundDataStruct) )
        % step through the targets
        for i=1:length(inputsStruct.backgroundDataStruct)

            if(ismember([inputsStruct.backgroundDataStruct(i).ccdRow ,...
                    inputsStruct.backgroundDataStruct(i).ccdColumn],...
                    [cosmicRayStruct.rowList(:), cosmicRayStruct.colList(:)], 'rows' ) )

                madForThisPixel = mad(inputsStruct.backgroundDataStruct(i).values);

                % step through the cadence list
                for k=1:length(cosmicRayStruct.cadenceList)

                    % add the cosmic ray
                    newPixelValue = ...
                        inputsStruct.backgroundDataStruct(i).values(cosmicRayStruct.cadenceList(k)) +...
                        cosmicRayStruct.madList(k).*madForThisPixel;

                    inputsStruct.backgroundDataStruct(i).values(cosmicRayStruct.cadenceList(k)) = ...
                        newPixelValue;
                end

            end
        end
    end

    % do target pixels
    if( ~isempty(inputsStruct.targetStarDataStruct) )
        % step through the targets
        for i=1:length(inputsStruct.targetStarDataStruct)
            % step through the pixels
            for j=1:length(inputsStruct.targetStarDataStruct(i).pixelDataStruct)

                if(ismember([inputsStruct.targetStarDataStruct(i).pixelDataStruct(j).ccdRow ,...
                        inputsStruct.targetStarDataStruct(i).pixelDataStruct(j).ccdColumn],...
                        [cosmicRayStruct.rowList(:), cosmicRayStruct.colList(:)], 'rows' ) )

                    madForThisPixel = mad(inputsStruct.targetStarDataStruct(i).pixelDataStruct(j).values);

                    % step through the cadence list
                    for k=1:length(cosmicRayStruct.cadenceList)

                        % add the cosmic ray
                        newPixelValue = ...
                            inputsStruct.targetStarDataStruct(i).pixelDataStruct(j).values(cosmicRayStruct.cadenceList(k)) +...
                            cosmicRayStruct.madList(k).*madForThisPixel;

                        inputsStruct.targetStarDataStruct(i).pixelDataStruct(j).values(cosmicRayStruct.cadenceList(k)) = ...
                            newPixelValue;
                    end
                end
            end
        end
    end
end

    



