function [kepidMapStruct]=make_kepid_mod_out_channel_skygroup_map(tadStructDirectoryPath, skyGroupMapFile, outputTextFileRootName)

% function [kepidMapStruct]=make_kepid_mod_out_channel_skygroup_map(tadStructDirectoryPath, skyGroupMapFile, outputTextFileRootName)
% author - Anima Sabale, Jennifer Campbell
%
% This function generates a mapping of Kepler ID to it's location on the
% focal plane: module, output, channel, and skygroup.
% 
% This function reads through files generated during target management, tadStruct*.mat,
% to retrieve KeplerId's from the structure, and assigns the corresponding module 
% and output values from the names of the files. 
%
% It loads the summary level target management structure, *trimmed_lc.mat, to map
% the Kepler IDs to their SkyGroup.
%
% The function uses a Channel <-> ModOut array to map the channel to the module
% output. This array remains constant. It excludes channels 5 and 21. 
%
% It then matches all 3 arrays (ModOuts, Channels, SkyGroups) and combines them 
% to produce a single *.txt and *mat file with Kepler IDs mapped to their 
% module, outputs, channels, and skyGroups.
%
% 
% Input Arguments:
%   tadStructDirectoryPath      (string) The full path to the directory
%                               with the target management tadStruct*.mat
%                               files. 
%                               Example: /path/to/c0/tad/c0_march2014/trimmed_v2/extract_tad_data
%   skyGroupMapFile             (string) The full path to the summary level
%                               target management *.mat file. 
%                               Example file name: c0_march2014_trimmed_v2_lc.mat
%   outputTextFileRootName      (string) The root name for the output *.txt
%                               and *.mat files. These files will be
%                               written to the tadStructDirectoryPath
%                               loction. 
%                               Example: c0_march2014_trimmed_v2_modOutChnlSG_map
%
% Output Arguments:
%   kepidMapStruct              (structure array) A structure array with
%                               the mapping of the Kepler ID to the module,
%                               output, channel, and skygroup. Elements of
%                               the array are: 
%                                   kepid: integer Kepler ID
%                                   module: integer Module number
%                                   output: integer Output number
%                                   channel: integer Channel number
%                                   skygroup: integer Skygroup number
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

% --------------------------------------------------------------- %
% Initialize some variables
chnlModOutArray = zeros(84,3);
kepidMapStruct = struct('kepid', [], 'module', [], 'output', [],'channel', [], 'skygroup', []);
kepIdSkygroupStruct = struct('kepid', [], 'skyGroup', []);

totalTargetKepid=0;
outputCounter=1;
moduleCounter=2;
targetCounter=1;
  
% --------------------------------------------------------------- %
% 1 - Generate the map of the Channel to Module & Output
for channelCounter=1:84              
	chnlModOutArray(channelCounter,1) = channelCounter;     % Channel
    chnlModOutArray(channelCounter,2) = moduleCounter;      % Module
    chnlModOutArray(channelCounter,3) = outputCounter;      % Output

    if outputCounter < 4
    	outputCounter=outputCounter+1;
    else outputCounter=1;
    	moduleCounter=moduleCounter+1;        
        if (moduleCounter==5 || moduleCounter==21 )
            % excluding Channels 5 & 21 (not science channels)
        	moduleCounter=moduleCounter+1;
        end
    end

end

% --------------------------------------------------------------- %
% 2 - Generate the array of skyGroups to kepids from the summary file
skygroupFile=load(skyGroupMapFile);
   
% count the nubmer of KeplerId and SG's in the summary file
for i = 1:length(skygroupFile.tad)
	k=skygroupFile.tad(i).kepid;
    s=skygroupFile.tad(i).skygroup;

    kepIdSkygroupStruct.kepid=cat(2,kepIdSkygroupStruct.kepid,k);
    kepIdSkygroupStruct.skyGroup=cat(2,kepIdSkygroupStruct.skyGroup,s);
        
end
totalkepIdSkygroupStruct=length(kepIdSkygroupStruct.kepid);
    
% --------------------------------------------------------------- %
% 3 - Open the *.txt file in the target management directory, tadStructDirectoryPath, for writting
outputTextFile=strcat(tadStructDirectoryPath, '/',outputTextFileRootName,'.txt');
fileID = fopen(outputTextFile, 'w');
% print a header
fprintf(fileID, 'KeplerID,Module,Output,Channel,SkyGroup\n' );   
fclose(fileID);


% --------------------------------------------------------------- %
% 4 - Get the list of tad files, tadStruct*lc*.mat. We only need the LC
%     file list because the SC and RP targets are also represented on the
%     LC list.
tadFiles=strcat(tadStructDirectoryPath , '/tadStruct*lc*.mat');
listOfFiles = dir(tadFiles);

% --------------------------------------------------------------- %
% 5 - Loop through the tadStruct*lc*.mat files
%     Strip the module and output numbers off from the file names
%     Create the arrays of the Kepler ID, Module, Output, and Channel.
%     Then map to the Skygroup
for fileCounter = 1:length(listOfFiles)
	filesList=listOfFiles(fileCounter).name;
    fprintf('Working on: %s\n',filesList)

    % Strip the module & output from the file name
    [str1,str2]=regexp(filesList, '.mat', 'split');     % split filename to get the first portion of the filename
    str=char(str1(1));                                  
    splittedStr=strread(str,'%s','delimiter','_');      % split first portion into pieces to get m10o1 for example
    modoutPosition = length(splittedStr);               % Jennifer Campbell added this line
    modout=char(splittedStr(modoutPosition));           % JC changed the hard coded 6 to the variable modutPosition
    module=str2num(strtok(modout,'mo'));                % stripping the module number out using the numbers between m and o (mo) in the file name   
    splitModOut=strread(modout, '%s', 'delimiter', 'o');
    out=char(splitModOut(2));                           % gives the output number
    output=str2num(out);
    tadFile=load(strcat(tadStructDirectoryPath,'/',filesList));
    matsize=length(tadFile.tadStruct.targets);          % targets in each tadStruct

    % Total number of targets (kepler IDs) in tadStruct:
    totalTargetKepid = totalTargetKepid + matsize;

    % Open the *.txt file for writing in append mode
    fileID = fopen(outputTextFile, 'a');   
      
    % Generate the kepidMapStruct, matching up the kepid, modouts
    %     and skygroups and assigning it to the structure

    for tadTargetCounter=1:matsize
    	kepidMapStruct(targetCounter).kepid = tadFile.tadStruct.targets(tadTargetCounter).keplerId;
        kepidMapStruct(targetCounter).module = module;
        kepidMapStruct(targetCounter).output = output;
        for skygroupCounter = 1:84
        	if (kepidMapStruct(targetCounter).module == chnlModOutArray(skygroupCounter,2)) ...
                    && (kepidMapStruct(targetCounter).output == chnlModOutArray(skygroupCounter,3))
            	kepidMapStruct(targetCounter).channel = chnlModOutArray(skygroupCounter,1);
                continue
            end
        end
                
        for sgTargetCounter=1:totalkepIdSkygroupStruct  
        	if kepIdSkygroupStruct.kepid(sgTargetCounter) == tadFile.tadStruct.targets(tadTargetCounter).keplerId
            	kepidMapStruct(targetCounter).skygroup = kepIdSkygroupStruct.skyGroup(sgTargetCounter);
                continue
            end
                
        end
                
        fprintf(fileID,'%i,%i,%i,%i,%i\n', ...
        	kepidMapStruct(targetCounter).kepid, ...
            kepidMapStruct(targetCounter).module, ...
            kepidMapStruct(targetCounter).output, ...
            kepidMapStruct(targetCounter).channel, ...
            kepidMapStruct(targetCounter).skygroup) ;
            if targetCounter <=totalTargetKepid
            	targetCounter=targetCounter+1; 
            end
    end 
end
outputMatFile = strcat(tadStructDirectoryPath, '/',outputTextFileRootName,'.mat');
save(outputMatFile, 'kepidMapStruct');

return
