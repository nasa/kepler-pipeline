function [sceneDepTestResult,maskedSmearTestResult,virtualSmearTestResult,...
    numSceneDepRows,numMaskedBadCols,numVirtualBadCols] = ...
    test_scene_dependent_file_updates_K2(newCampaign)
% function [sceneDepTestResult,maskedSmearTestResult,virtualSmearTestResult,...
%     numSceneDepRows,numMaskedBadCols,numVirtualBadCols] = ...
%     test_scene_dependent_file_updates_K2(newCampaign)
%
% code to check scene dependent files for all channels for all K2 campaigns 
% Returns status flags for all three models and arrays of number bad
% rows/columns for each campaign
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

sceneDepTestResult =[];
maskedSmearTestResult = [];
virtualSmearTestResult = [];

campaignList = [0:newCampaign];
nCampaigns = length(campaignList);

channelList = [1:84];
nChannels = length(channelList);

numSceneDepRows = zeros(nChannels,nCampaigns);
numMaskedBadCols = zeros(nChannels,nCampaigns);
numVirtualBadCols = zeros(nChannels,nCampaigns);


% Scene dependent black test
display(['Performing Scene dependent black test for all channels, campaigns: ',...
    int2str(campaignList(1)),' - ',int2str(campaignList(end))])
    
campCounter = 0;
for icamp = campaignList(1):campaignList(end)
    campCounter = campCounter+1;
    for ich = 1:nChannels
        try 
            isSceneDep = scene_dependent_rows_K2(ich, icamp);
            numSceneDepRows(ich,campCounter) = length(find(isSceneDep));
        catch
            warning(['SCENE-DEPENDENT_BLACK: failed for campaign: ',...
                int2str(icamp),' channel: ',int2str(ich)])
            numSceneDepRows(ich,campCounter) = NaN;
            sceneDepTestResult = false;
        end
    end 
end
figure
imagesc(numSceneDepRows),colorbar
set(gca,'xtick',1:nCampaigns, 'xticklabel',[campaignList]);
xlabel('K2 Campaign #')
ylabel('Channel')
title('Scene Dependent Black')

if any(isnan(numSceneDepRows))
    sceneDepTestResult = false;
else
    sceneDepTestResult = true;
end

% masked smear test
display(['Performing Masked Semar test for all channels, campaigns: ',...
    int2str(campaignList(1)),' - ',int2str(campaignList(end))])
    
campCounter = 0;
for icamp = campaignList(1):campaignList(end)
    campCounter = campCounter+1;
    for ich = 1:nChannels
        try 
            smearColsToExclude = get_masked_smear_columns_to_exclude_K2(icamp,ich);
            numMaskedBadCols(ich,campCounter) = length(find(smearColsToExclude));
        catch
            warning(['MASKED_SMEAR_EXCLUDE: failed for campaign: ',...
                int2str(icamp),' channel: ',int2str(ich)])
            numMaskedBadCols(ich,campCounter) = NaN;
            maskedSmearTestResult = false;
        end
    end 
end
figure
imagesc(numMaskedBadCols),colorbar
set(gca,'xtick',1:nCampaigns, 'xticklabel',[campaignList]);
xlabel('K2 Campaign #')
ylabel('Channel')
title('Masked Smear Bad Columns')

if any(isnan(numMaskedBadCols))
    maskedSmearTestResult = false;
else
    maskedSmearTestResult = true;
end

% virtual smear test
display(['Performing Virtual Semar test for all channels, campaigns: ',...
    int2str(campaignList(1)),' - ',int2str(campaignList(end))])
    
campCounter = 0;
for icamp = campaignList(1):campaignList(end)
    campCounter = campCounter+1;
    for ich = 1:nChannels
        try 
            smearColsToExclude = get_virtual_smear_columns_to_exclude_K2(icamp,ich);
            numVirtualBadCols(ich,campCounter) = length(find(smearColsToExclude));
        catch
            warning(['VIRTUAL_SMEAR_EXCLUDE: failed for campaign: ',...
                int2str(icamp),' channel: ',int2str(ich)])
            numVirtualBadCols(ich,campCounter) = NaN;
            virtualSmearTestResult = false;
        end
    end 
end
figure
imagesc(numVirtualBadCols),colorbar
set(gca,'xtick',1:nCampaigns, 'xticklabel',[campaignList]);
xlabel('K2 Campaign #')
ylabel('Channel')
title('Virtual Smear Bad Columns')

if any(isnan(numVirtualBadCols))
    virtualSmearTestResult = false;
else
    virtualSmearTestResult = true;
end



