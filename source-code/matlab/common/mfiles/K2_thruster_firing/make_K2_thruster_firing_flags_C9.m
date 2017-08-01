% make_K2_thruster_firing_flags_C9.m
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

% This is a driver script to run process_K2_thruster_firing_data_TFR.m
% directly on the data from the thruster firing data report provided by OPS.

% Produces the .csv output file for nexsci and writes it directly into the
% archive directory specified by KSOP-2678
% This file has three columns:
% column 1: cadenceTimes.cadenceNumbers
%   short or long cadence number; In some cases there might be missing cadences.
% column 2: thrusterFiringEvents.definiteThrusterActivityIndicators
%   logical indicator for known thruster firing activity during this cadence
% column 3: thrusterFiringEvents.possibleThrusterActivityIndicators];
%   logical indicator for possible thruster firing activity during this
%   cadence -- i.e. thruster firing activity can't be ruled out.

% Also produces .mat archive file that contains 
% thrusterFiringDataStruct, 
% thrusterFiringEvents, and
% cadenceTimes. See the code process_K2_thruster_firing_data_TFR.m for a
% complete description of these fields.

% Adapted from make_K2_thruster_firing_flags.m, which was used to produce
% output .csv files for C1 and C2 that were delivered to nexsci and are
% archived at http://archive.stsci.edu/missions/k2/thruster_firings/

% Note: If PA or PDC is available, we use cadenceTimes from PA or PDC.
% If not, cadenceTimes data is taken from the header files, posted
% on the KSOC ticket by OPS.

% For C9 we don't run PA or PDC, so we must get the cadence data from
% the header files, posted by OPS on the ticket KSOC-4994.

%==========================================================================

% !!!!! Run this script and write output files in the data directory
dataDir = '/codesaver/work/thruster_firing_data/ksoc-4994/';

% Output files will be delivered to this directory
archiveDir = '/path/to/K2thrusterfiring/';

% Loop over selected datasets; for each dataset, create the flags and archive in a file to
% be delivered to SO
campaignIdRange = {'C9a-LC','C9b-LC','C9a-SC','C9b-SC'};
for selectedCampaign = campaignIdRange
    
    % Convert cell to string
    iCampaign = selectedCampaign{:};
    
    % Header check filename
    switch iCampaign
        case 'C9a-LC'
            headerCheckFile = strcat(iCampaign,'-header-check-20160601.txt');
        case 'C9a-SC'
            headerCheckFile = strcat(iCampaign,'-header-check-20160601.txt');
        case 'C9b-LC'
            headerCheckFile = strcat(iCampaign,'-header-check-ksop2673-20160707.txt');
        case 'C9b-SC'
            headerCheckFile = strcat(iCampaign,'-header-check-ksop2673-20160707.txt');
    end
    
    % Make a campaignSubId string
    % C9a and C9b have to be delivered as C91 and C92
    campaignType = iCampaign(end-1:end);
    campaignSubId0 = iCampaign(3);
    switch campaignSubId0
        case 'a'
            campaignSubId = '1';
        case 'b'
            campaignSubId = '2';
    end
    switch campaignType
        case 'LC'
            campaignTypeString = 'Long Cadence';
            cadenceLabel = 'lc';
        case 'SC'
            campaignTypeString = 'Short Cadence';
            cadenceLabel = 'sc';
    end
    % Get information for header and filename
    campaignString = strcat('Campaign ',iCampaign(2),campaignSubId);
    campaignLabel = strcat('c9',campaignSubId);
    dateVector = datestr(now,'yyyy-mm-dd');
    campaignRoot = strcat(campaignLabel,'_',cadenceLabel);
    
    % 1. Get the cadence data from the header check file
    % LC header check file has 17 entries, but SC header check file has an extra entry
    % for SC_inter
    if(strcmp(iCampaign(end-1:end),'LC'))
        formatSpec = '%s%s%s%f%f%d%s%f%f%f%c%c%c%c%c%c%c';
        T = readtable(headerCheckFile,'Delimiter',',','Format',formatSpec);
        startTime = T.START_TIME;
        endTime = T.END_TIME;
        cadenceNumber = T.LC_INTER;
        
    elseif(strcmp(iCampaign(end-1:end),'SC'))
        formatSpec = '%s%s%s%f%f%d%d%s%f%f%f%c%c%c%c%c%c%c';
        T = readtable(headerCheckFile,'Delimiter',',','Format',formatSpec);
        startTime = T.START_TIME;
        endTime = T.END_TIME;
        cadenceNumber = T.SC_INTER;
    end
        
    % 2. Process the thruster firing data and make the .mat archive file
    % skip=true;
    % if(~skip)
        
        % Process the campaign, create the thruster firing flags
        fprintf('\nMaking thruster flags for campaign %s\n',iCampaign)
        [thrusterFiringDataStruct, thrusterFiringEvents, cadenceTimes] = process_K2_thruster_firing_data_TFR(iCampaign);
        
        % Save the .mat archive file
        fprintf('Saving thruster flags for campaign %s\n\n',iCampaign)
        archiveFileName = strcat('thruster_firing_flags_',iCampaign,'.mat');
        save(archiveFileName,'thrusterFiringDataStruct','thrusterFiringEvents','cadenceTimes');
        
    % end
    
    % Load the .mat archive file
    % archiveFileName = strcat('thruster_firing_flags_',iCampaign,'.mat');
    % load(archiveFileName)
    
    % 3. Create and save the csv output file
    % column1 is (short or long) cadence numbers
    % column2 is definiteThrusterActivityIndicators
    % column3 is possibleThrusterActivityIndicators
    fprintf('In campaign %s, there were %d definite and %d possible thruster firing activity indicators\n',iCampaign,sum(thrusterFiringEvents.definiteThrusterActivityIndicators),sum(thrusterFiringEvents.possibleThrusterActivityIndicators))
    csvFileName = strcat(archiveDir,'thruster_firing_flags_',campaignRoot,'.csv');
    fprintf('Writing .csv output file %s ...\n',csvFileName);
    if(exist(csvFileName,'file'))
        delete(csvFileName);
    end
    
    % Print the 9 header lines, as was done for C1 and C2 delivery
    % http://archive.stsci.edu/missions/k2/thruster_firings/thruster_firing_flags_c1_lc.csv
    % #K2 Thruster Firing Flags
    % #Campaign 1
    % #Long Cadence
    % #Col 1: Cadence Number
    % #Col 2: Definite Thruster Firing
    % #Col 3: Possible Thruster Firing
    % #Ticket KSOC-4850
    % #Created on 2015-08-19
    % #
    fid = fopen(csvFileName,'w');
    fprintf(fid,'#K2 Thruster Firing Flags\n');
    fprintf(fid,'#%s\n',campaignString);
    fprintf(fid,'#%s\n',campaignTypeString);
    fprintf(fid,'#Col 1: Cadence Number\n');
    fprintf(fid,'#Col 2: Definite Thruster Firing\n');
    fprintf(fid,'#Col 3: Possible Thruster Firing\n');
    fprintf(fid,'#Ticket KSOC-4994\n');
    fprintf(fid,'#Created on %s\n',dateVector);
    fprintf(fid,'#\n');
  
    % Append the thruster firing data
    outputData = [cadenceTimes.cadenceNumbers, thrusterFiringEvents.definiteThrusterActivityIndicators, thrusterFiringEvents.possibleThrusterActivityIndicators];
    dlmwrite(csvFileName,outputData,'precision',9,'-append');
    fclose('all');
    
    % Prepare for the next data set
    clear thrusterFiringDataStruct
    clear thrusterFiringEvents
    clear cadenceTimes
    clear outputData
    
end
