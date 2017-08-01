function infoStruct = vacuum_dv_log_info( topDir, koiKepIds, falseAlarmKepIds )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Vacuum useful diagnostic information out of the DV log files
%
% Inputs:
%        topDir: Top directory where all the dv Files are, the directory 
%                that contains all the dv-matlab-* sub directories
%        koiKepIds: A vector of kepler Ids that are on the KOI list.  This
%                   is used to generate a boolean vector to mark which
%                   tasks in the infoStruct are KOIs.  If empty, the
%                   boolean vector will all be false.
%        falseAlarmKepIds: A vector of kepler Ids that identify targets
%                          that appear to be outliers on the skyline or
%                          cadence histogram plot generated after the
%                          TPS run.  A struct containing these kepler
%                          IDs is easily generated using
%                          construct_cadence_histogram in
%                          tps/search/test .  This requires the
%                          tceStruct.  Turn this off by specifying an
%                          empty vector.
%
% Outputs:
%         infoStruct
%
%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

%topDir = '/path/to/TEST/pipeline_results/planet-search/lc/dv/i6514';
dirListLevel1 = dir( [ topDir, '/dv-matlab-*' ] ) ;

% drill down to the first of these and see whether it has a directory tree structure
% within it; here we assume that either ALL of the tps-matlab-* directories have
% substructs, or NONE of them do.  So we will start to scroll through the directories, and
% if there are no subdirs in the first one we will break out of the loop

% count the number of tasks
numDirs = 0;
for iDirLevel1 = 1:length(dirListLevel1)
  dirListLevel2 = dir( [ topDir, '/', dirListLevel1(iDirLevel1).name, '/st-*' ] ) ;
  numDirs = numDirs + length(dirListLevel2);
end

progressVect = (1:250:numDirs)';

% allocate the struct
infoStruct = struct('keplerId', [], 'taskFile',[], 'numPlanets', [], 'preFitOverhead', [], 'fitterTimes', [], ...
    'allTransitFitIterations', [], 'oddEvenTransitFitIterations', [], ...
    'totalFitterTime',[], 'fitterFailFlag', [], 'tpsSearchTimes', [], 'totalTpsTime', [], 'totalPlanetSearchTime', [], ...
    'differenceImageTime', [], 'centroidTestTime', [], 'pixelCorrelationTestTime', [], ...
    'binaryDiscriminationTestTime', [], 'bootstrapTestTime', [], 'bootstrapIterationsEstimate', [], ...
    'bootstrapIterationsActual', [], 'ghostDiagnosticTestTime', [], 'reportGenTime', [], 'dataValidationTime', [], ...
    'timeOutFlag', [], 'koiFlag', [], 'falseAlarmFlag', [], 'failIndicator', []);
infoStruct = repmat(infoStruct, numDirs,1);

counter = 1;
for iDirLevel1 = 1:length(dirListLevel1)
    dirListLevel2 = dir( [ topDir, '/', dirListLevel1(iDirLevel1).name, '/st-*' ] ) ;
    for iDirLevel2 = 1:length(dirListLevel2)
        tempLogCreated = false;
      
        % print progress info
        if ismember(counter,progressVect)
            fprintf('Vacuuming up task %d out of %d\n',counter,numDirs);
        end

        fullDir = strcat(dirListLevel1(iDirLevel1).name,'/',dirListLevel2(iDirLevel2).name);
        fileName = strcat(topDir, '/',dirListLevel1(iDirLevel1).name,'/',dirListLevel2(iDirLevel2).name,'/',dirListLevel1(iDirLevel1).name,'-',dirListLevel2(iDirLevel2).name,'.log');
        infoStruct(counter).taskFile = fullDir;
        % grep the log for useful info
        
        % check for .FAILED file and set indicator
        failFile = strcat(topDir,'/',dirListLevel1(iDirLevel1).name,'/',dirListLevel2(iDirLevel2).name,'/.FAILED');
        if exist(failFile,'file')
            infoStruct(counter).failIndicator = true ;
        else         
            infoStruct(counter).failIndicator = false ;
        end
        
        try
            % check for log with multiple starts
            unixCommand = ['cat ' fileName, ' | grep "found system property: config.propfile" | wc -l'];
            [flag,result]=unix(unixCommand);
            if isequal(flag,0) && str2num(result) > 1
                % get the line number of the final run start
                unixCommand = ['cat ' fileName, ' | grep -n "found system property: config.propfile"'];
                [flag,result]=unix(unixCommand);
                startChars = findstr(result,':201');
                endLines = regexp(result,'\n');
                startLines =[1,endLines(1:end-1)+1];
                startChars = startChars(startChars>startLines(end) & startChars<endLines(end));
                startChars = startChars(1);
                startLineNum = strread(result(startLines(end):startChars(end)-1),'%d');

                % make a temp log file
                unixCommand = ['tail -n +',num2str(startLineNum),' ',fileName,' > temp.log'];
                [flag,result]=unix(unixCommand);
                if isequal(flag,0)
                    tempLogCreated = true;
                    fileName = strcat(topDir, '/',dirListLevel1(iDirLevel1).name,'/',dirListLevel2(iDirLevel2).name,'/','temp.log');
                    infoStruct(counter).failIndicator = false ;
                end
            end
        catch
            infoStruct(counter).failIndicator = true ;
        end
        
        
        % get the kepler Id one way or another
        unixCommand = ['cat ', fileName, ' | grep "keplerId:"'];
        [flag,result]=unix(unixCommand);
        if isequal(flag,0)
            % if its in the log then grab it there
            startIndex = findstr(result,'keplerId:');
            startIndex = startIndex + 10;
            startIndex = startIndex(1);
            endIndex = findstr(result,')');
            endIndex = endIndex-1;
            endIndex = endIndex(1);
            infoStruct(counter).keplerId = strread(result(startIndex:endIndex),'%d');
        else
            % kepler Id is not in the log so it failed prior to
            % conduct_additional_planet_search - get it from the dv input
            inputFileName = strcat(topDir, '/',dirListLevel1(iDirLevel1).name,'/',dirListLevel2(iDirLevel2).name,'/dv-inputs-0.mat');
            try
                load(inputFileName);
                infoStruct(counter).keplerId = inputsStruct.targetStruct.keplerId;
                clear inputsStruct inputFileName;
            catch
                infoStruct(counter).keplerId = 0;
            end
        end
        
        try
            % get the pre-fit time
            unixCommand = ['head -1 ', fileName];
            [flag,result] = unix(unixCommand);
            if isequal(flag,0)
                startTime = datevec(result(1:19));
                unixCommand = ['cat ', fileName, ' | grep "data_validation: performing dv planet search and model fitting"'];
                [flag,result] = unix(unixCommand);
                if isequal(flag,0)
                    fitterStartTime = datevec(result(1:19));
                    infoStruct(counter).preFitOverhead = etime(fitterStartTime,startTime);
                else
                    infoStruct(counter).preFitOverhead = 0;
                end
            else
                infoStruct(counter).preFitOverhead = 0;
            end

            % record conduct_additional_planet search info
            unixCommand = ['cat ', fileName, ' | grep "conduct_additional_planet_search completed in"'];
            [flag,result]=unix(unixCommand);
            if isequal(flag,0)
                startIndex = findstr(result,'completed in');
                startIndex = startIndex + 13;
                endIndex = findstr(result,'seconds');
                endIndex = endIndex(2:2:length(endIndex));
                tempVect = zeros(length(startIndex),1);
                for i=1:length(startIndex)
                    tempVect(i) = strread(result(startIndex(i):endIndex(i)-2),'%f');
                end
                infoStruct(counter).tpsSearchTimes = tempVect;
                infoStruct(counter).numPlanets = length(tempVect);
                infoStruct(counter).totalTpsTime = sum(tempVect);
            else
                infoStruct(counter).tpsSearchTimes = 0;
                infoStruct(counter).totalTpsTime = 0;
                unixCommand2 = ['cat ', fileName, ' | grep "really and truly done"'];
                [flag2,result2]=unix(unixCommand2);
                if isequal(flag2,0)
                    % fit one planet but timed out in follow-up search
                    infoStruct(counter).numPlanets = 1;
                else
                    % didnt fit any planets
                    infoStruct(counter).numPlanets = 0;
                end
            end

            % record fitter times
            unixCommand = ['cat ', fileName, ' | grep "Starting fit process"'];
            unixCommand2 = ['cat ', fileName, ' | grep "really and truly done"'];
            [flag,result]=unix(unixCommand);
            [flag2,result2]=unix(unixCommand2);
            if isequal(flag2,0)
                startIndex = findstr(result,'refTime');
                startIndex = startIndex + 8;
                endIndex = findstr(result,'seconds');
                startIndex2 = findstr(result2,'refTime');
                startIndex2 = startIndex2 + 8;
                endIndex2 = findstr(result2,'seconds');
                if ~isequal(length(startIndex),length(startIndex2))
                    if (length(startIndex) < length(startIndex2))
                        % BUS error, so just set to zero rather than try anything
                        % fancy to split the log
                        infoStruct(counter).fitterFailFlag = false;
                        infoStruct(counter).fitterTimes = 0;
                        infoStruct(counter).totalFitterTime = 0;
                        infoStruct(counter).tpsSearchTimes = 0;
                        infoStruct(counter).numPlanets = 0;
                        infoStruct(counter).totalTpsTime = 0;
                    else
                        infoStruct(counter).fitterFailFlag = true;
                        % if we failed in the fitter then lop off the last fit
                        startIndex = startIndex(1:end-1);
                        tempVect = zeros(length(startIndex),1);
                        tempVect2 = zeros(length(startIndex2),1);
                        for i=1:length(startIndex)
                            tempVect(i) = strread(result(startIndex(i):endIndex(i)-2),'%f');
                            tempVect2(i) = strread(result2(startIndex2(i):endIndex2(i)-2),'%f');
                        end
                        infoStruct(counter).fitterTimes = tempVect2 - tempVect;
                        infoStruct(counter).totalFitterTime = sum(tempVect2-tempVect);
                    end
                else
                    tempVect = zeros(length(startIndex),1);
                    tempVect2 = zeros(length(startIndex2),1);
                    infoStruct(counter).fitterFailFlag = false;
                    for i=1:length(startIndex)
                        tempVect(i) = strread(result(startIndex(i):endIndex(i)-2),'%f');
                        tempVect2(i) = strread(result2(startIndex2(i):endIndex2(i)-2),'%f');
                    end
                    infoStruct(counter).fitterTimes = tempVect2 - tempVect;
                    infoStruct(counter).totalFitterTime = sum(tempVect2-tempVect);
                end
            elseif isequal(flag,0)
                % started the fit process but never finished since flag2~=0
                infoStruct(counter).fitterFailFlag = true;
                infoStruct(counter).fitterTimes = 0;
                infoStruct(counter).totalFitterTime = 0;
            else
                % didnt make it to the fit process
                infoStruct(counter).fitterFailFlag = false;
                infoStruct(counter).fitterTimes = 0;
                infoStruct(counter).totalFitterTime = 0;
            end


            % record the number of robust fit loops for allTransitsFit
            unixCommand = ['cat ', fileName, ' | grep -n "Starting all-transits fit of target"'];
            unixCommand2 = ['cat ', fileName, ' | grep -n ": all-transits fit of target"'];
            unixCommand3 = ['cat ', fileName, ' | grep -n "Converged on iteration"'];
            [flag,result]=unix(unixCommand);
            [flag2,result2]=unix(unixCommand2);
            [flag3,result3]=unix(unixCommand3);

            if isequal(flag2,0)

                startChars = findstr(result,':201');
                endLines = regexp(result,'\n');
                startLines =[1,endLines(1:end-1)+1];
                tempVect = zeros(length(endLines),1);
                for i=1:length(endLines)
                    tempVect(i) = strread(result(startLines(i):startChars(i)-1),'%d');
                end
                startChars2 = findstr(result2,':201');
                endLines = regexp(result2,'\n');
                startLines =[1,endLines(1:end-1)+1];
                tempVect2 = zeros(length(endLines),1);
                for i=1:length(endLines)
                    tempVect2(i) = strread(result2(startLines(i):startChars2(i)-1),'%d');
                end
                startChars3 = findstr(result3,':201');
                endLines = regexp(result3,'\n');
                startLines =[1,endLines(1:end-1)+1];
                tempVect3 = zeros(length(endLines),1);
                for i=1:length(endLines)
                    tempVect3(i) = strread(result3(startLines(i):startChars3(i)-1),'%d');
                end

                if ~isequal(length(startChars),length(startChars2))
                    if (length(startChars) < length(startChars2))
                        % BUS error, so just set to zero rather than try anything
                        % fancy to split the log
                        infoStruct(counter).allTransitFitIterations = 0;
                        %infoStruct(counter).oddEvenTransitFitIterations = 0;
                    else
                        % if we failed in the fitter then lop off the last fit
                        tempVect = tempVect(1:end-1,1);
                        tempIterations = zeros(length(tempVect),1);
                        for i=1:length(tempVect)
                            %find the correct result3 to pull from
                            iresult = find(tempVect3>tempVect(i) & tempVect3<tempVect2(i));
                            if ~isempty(iresult)
                                if iresult==1
                                    startIndex = findstr(result3(1:endLines(iresult)),'iteration ')+10;
                                    endIndex = findstr(result3(1:endLines(iresult)),'after')-2;
                                    tempStr = result3(1:endLines(iresult));
                                else
                                    startIndex = findstr(result3(endLines(iresult-1)+1:endLines(iresult)),'iteration ')+10;
                                    endIndex = findstr(result3(endLines(iresult-1)+1:endLines(iresult)),'after')-2;
                                    tempStr = result3(endLines(iresult-1)+1:endLines(iresult));
                                end
                                tempIterations(i) = strread(tempStr(startIndex:endIndex), '%d');
                            end
                        end
                        infoStruct(counter).allTransitFitIterations = tempIterations(tempIterations~=0) ;
                    end
                else
                    tempIterations = zeros(length(tempVect),1);
                    for i=1:length(tempVect)
                        %find the correct result3 to pull from
                        iresult = find(tempVect3>tempVect(i) & tempVect3<tempVect2(i));
                        if ~isempty(iresult)
                            if iresult==1
                                startIndex = findstr(result3(1:endLines(iresult)),'iteration ')+10;
                                endIndex = findstr(result3(1:endLines(iresult)),'after')-2;
                                tempStr = result3(1:endLines(iresult));
                            else
                                startIndex = findstr(result3(endLines(iresult-1)+1:endLines(iresult)),'iteration ')+10;
                                endIndex = findstr(result3(endLines(iresult-1)+1:endLines(iresult)),'after')-2;
                                tempStr = result3(endLines(iresult-1)+1:endLines(iresult));
                            end
                            tempIterations(i) = strread(tempStr(startIndex:endIndex), '%d');
                        end
                    end
                    infoStruct(counter).allTransitFitIterations = tempIterations(tempIterations~=0) ;
                end
            elseif isequal(flag,0)
                % started the fit process but never finished since flag2~=0
                infoStruct(counter).allTransitFitIterations = 0;
            else
                % didnt make it to the fit process
                infoStruct(counter).allTransitFitIterations = 0;
            end


            % record the number of robust fit loops for odd/even fit
            unixCommand = ['cat ', fileName, ' | grep -n "Starting odd-even-transits fit of target"'];
            unixCommand2 = ['cat ', fileName, ' | grep -n ": odd-even-transits fit of target"'];
            unixCommand3 = ['cat ', fileName, ' | grep -n "Converged on iteration"'];
            [flag,result]=unix(unixCommand);
            [flag2,result2]=unix(unixCommand2);
            [flag3,result3]=unix(unixCommand3);

            if isequal(flag2,0)

                startChars = findstr(result,':201');
                endLines = regexp(result,'\n');
                startLines =[1,endLines(1:end-1)+1];
                tempVect = zeros(length(endLines),1);
                for i=1:length(endLines)
                    tempVect(i) = strread(result(startLines(i):startChars(i)-1),'%d');
                end
                startChars2 = findstr(result2,':201');
                endLines = regexp(result2,'\n');
                startLines =[1,endLines(1:end-1)+1];
                tempVect2 = zeros(length(endLines),1);
                for i=1:length(endLines)
                    tempVect2(i) = strread(result2(startLines(i):startChars2(i)-1),'%d');
                end
                startChars3 = findstr(result3,':201');
                endLines = regexp(result3,'\n');
                startLines =[1,endLines(1:end-1)+1];
                tempVect3 = zeros(length(endLines),1);
                for i=1:length(endLines)
                    tempVect3(i) = strread(result3(startLines(i):startChars3(i)-1),'%d');
                end

                if ~isequal(length(startChars),length(startChars2))
                    if (length(startChars) < length(startChars2))
                        % BUS error, so just set to zero rather than try anything
                        % fancy to split the log
                        infoStruct(counter).oddEvenTransitFitIterations = 0;
                        %infoStruct(counter).oddEvenTransitFitIterations = 0;
                    else
                        % if we failed in the fitter then lop off the last fit
                        tempVect = tempVect(1:end-1,1);
                        tempIterations = zeros(length(tempVect),1);
                        for i=1:length(tempVect)
                            %find the correct result3 to pull from
                            iresult = find(tempVect3>tempVect(i) & tempVect3<tempVect2(i));
                            if ~isempty(iresult)
                                if iresult==1
                                    startIndex = findstr(result3(1:endLines(iresult)),'iteration ')+10;
                                    endIndex = findstr(result3(1:endLines(iresult)),'after')-2;
                                    tempStr = result3(1:endLines(iresult));
                                else
                                    startIndex = findstr(result3(endLines(iresult-1)+1:endLines(iresult)),'iteration ')+10;
                                    endIndex = findstr(result3(endLines(iresult-1)+1:endLines(iresult)),'after')-2;
                                    tempStr = result3(endLines(iresult-1)+1:endLines(iresult));
                                end
                                tempIterations(i) = strread(tempStr(startIndex:endIndex), '%d');
                            end
                            infoStruct(counter).oddEvenTransitFitIterations = tempIterations(tempIterations~=0) ;
                        end
                    end
                else
                    tempIterations = zeros(length(tempVect),1);
                    for i=1:length(tempVect)
                        %find the correct result3 to pull from
                        iresult = find(tempVect3>tempVect(i) & tempVect3<tempVect2(i));
                        if ~isempty(iresult)
                            if iresult==1
                                startIndex = findstr(result3(1:endLines(iresult)),'iteration ')+10;
                                endIndex = findstr(result3(1:endLines(iresult)),'after')-2;
                                tempStr = result3(1:endLines(iresult));
                            else
                                startIndex = findstr(result3(endLines(iresult-1)+1:endLines(iresult)),'iteration ')+10;
                                endIndex = findstr(result3(endLines(iresult-1)+1:endLines(iresult)),'after')-2;
                                tempStr = result3(endLines(iresult-1)+1:endLines(iresult));
                            end
                            tempIterations(i) = strread(tempStr(startIndex:endIndex), '%d');
                        end
                    end
                    infoStruct(counter).oddEvenTransitFitIterations = tempIterations(tempIterations~=0) ;
                end
            elseif isequal(flag,0)
                % started the fit process but never finished since flag2~=0
                infoStruct(counter).oddEvenTransitFitIterations = 0;
            else
                % didnt make it to the fit process
                infoStruct(counter).oddEvenTransitFitIterations = 0;
            end


            infoStruct(counter).totalPlanetSearchTime = infoStruct(counter).totalTpsTime + infoStruct(counter).totalFitterTime;

            % difference image time
            unixCommand = ['cat ', fileName, ' | grep "generate_dv_difference_images completed in"'];
            [flag,result]=unix(unixCommand);
            if isequal(flag,0)
                startIndex = findstr(result,'completed in');
                startIndex = startIndex + 13;
                endIndex = findstr(result,'seconds');
                endIndex = endIndex(2);
                infoStruct(counter).differenceImageTime = strread(result(startIndex:endIndex-2),'%f');
            else
                infoStruct(counter).differenceImageTime = 0;
            end

            % centroid test time
            unixCommand = ['cat ', fileName, ' | grep "perform_dv_centroid_tests completed in"'];
            [flag,result]=unix(unixCommand);
            if isequal(flag,0)
                startIndex = findstr(result,'completed in');
                startIndex = startIndex + 13;
                endIndex = findstr(result,'seconds');
                endIndex = endIndex(2);
                infoStruct(counter).centroidTestTime = strread(result(startIndex:endIndex-2),'%f');
            else
                infoStruct(counter).centroidTestTime = 0;
            end

            % pixel correlation test time
            unixCommand = ['cat ', fileName, ' | grep "perform_dv_pixel_correlation_tests completed in"'];
            [flag,result]=unix(unixCommand);
            if isequal(flag,0)
                startIndex = findstr(result,'completed in');
                startIndex = startIndex + 13;
                endIndex = findstr(result,'seconds');
                endIndex = endIndex(2);
                infoStruct(counter).pixelCorrelationTestTime = strread(result(startIndex:endIndex-2),'%f');
            else
                infoStruct(counter).pixelCorrelationTestTime = 0;
            end

            % binary discrimination test time
            unixCommand = ['cat ', fileName, ' | grep "perform_dv_binary_discrimination_tests completed in"'];
            [flag,result]=unix(unixCommand);
            if isequal(flag,0)
                startIndex = findstr(result,'completed in');
                startIndex = startIndex + 13;
                endIndex = findstr(result,'seconds');
                endIndex = endIndex(2);
                infoStruct(counter).binaryDiscriminationTestTime = strread(result(startIndex:endIndex-2),'%f');
            else
                infoStruct(counter).binaryDiscriminationTestTime = 0;
            end

            % bootstrap test
            unixCommand = ['cat ', fileName, ' | grep "perform_dv_bootstrap completed in"'];
            [flag,result]=unix(unixCommand);
            if isequal(flag,0)
                startIndex = findstr(result,'completed in');
                startIndex = startIndex + 13;
                endIndex = findstr(result,'seconds');
                endIndex = endIndex(2);
                infoStruct(counter).bootstrapTestTime = strread(result(startIndex:endIndex-2),'%f');
            else
                infoStruct(counter).bootstrapTestTime = 0;
            end

            % bootstrap estimate iterations
            unixCommand = ['cat ', fileName, ' | grep "Estimated number of iterations is"'];
            [flag,result]=unix(unixCommand);
            if isequal(flag,0)
                startIndex = findstr(result,'iterations is');
                startIndex = startIndex + 14;
                endIndex = findstr(result,'.');
                endIndex = endIndex(3);
                infoStruct(counter).bootstrapIterationsEstimate = strread(result(startIndex:endIndex-1),'%f');
            else
                infoStruct(counter).bootstrapIterationsEstimate = 0;
            end

            % bootstrap actual iterations
            unixCommand = ['cat ', fileName, ' | grep "Actual number of iterations="'];
            [flag,result]=unix(unixCommand);
            if isequal(flag,0)
                startIndex = findstr(result,'iterations=');
                startIndex = startIndex + 11;
                endIndex = startIndex+9;
                tempVect = zeros(length(startIndex),1);
                for i=1:length(startIndex)
                    tempVect(i) = strread(result(startIndex(i):endIndex(i)),'%f');
                end
                infoStruct(counter).bootstrapIterationsActual = tempVect;
            else
                infoStruct(counter).bootstrapIterationsActual = 0;
            end

            % ghost diagnostic test time
            unixCommand = ['cat ', fileName, ' | grep "perform_dv_ghost_diagnostic_tests completed in"'];
            [flag,result]=unix(unixCommand);
            if isequal(flag,0)
                startIndex = findstr(result,'completed in');
                startIndex = startIndex + 13;
                endIndex = findstr(result,'seconds');
                endIndex = endIndex(2);
                infoStruct(counter).ghostDiagnosticTestTime = strread(result(startIndex:endIndex-2),'%f');
            else
                infoStruct(counter).ghostDiagnosticTestTime = 0;
            end

            % report generation
            unixCommand = ['cat ', fileName, ' | grep "dv_generate_reports and dv_generate_report_summaries completed in"'];
            [flag,result]=unix(unixCommand);
            if isequal(flag,0)
                startIndex = findstr(result,'completed in');
                startIndex = startIndex + 13;
                endIndex = findstr(result,'seconds');ismember([infoStruct.keplerId], koiKepIds);
                endIndex = endIndex(2);
                infoStruct(counter).reportGenTime = strread(result(startIndex:endIndex-2),'%f');
            else
                infoStruct(counter).reportGenTime = 0;
            end

            % data validation run time
            unixCommand = ['cat ', fileName, ' | grep "data_validation completed in"'];
            [flag,result]=unix(unixCommand);
            if isequal(flag,0)
                startIndex = findstr(result,'completed in');
                startIndex = startIndex + 13;
                endIndex = findstr(result,'seconds');
                endIndex = endIndex(2);
                infoStruct(counter).dataValidationTime = strread(result(startIndex:endIndex-2),'%f');
            else
                infoStruct(counter).dataValidationTime = 0;
            end

            % time out flag
            unixCommand = ['cat ', fileName, ' | grep "timed out, killing"'];
            [flag,result]=unix(unixCommand);
            if isequal(flag,0)
                infoStruct(counter).timeOutFlag = true;
            else
                infoStruct(counter).timeOutFlag = false;
            end
        catch
            infoStruct(counter).failIndicator = true ;
        end
        
        % Add the optional outputs
        if ~isempty(koiKepIds)
            infoStruct(counter).koiFlag = ismember(infoStruct(counter).keplerId, koiKepIds);
        end
        if ~isempty(falseAlarmKepIds)
            infoStruct(counter).falseAlarmFlag = ismember(infoStruct(counter).keplerId, falseAlarmKepIds);
        end
        
        % update counter
        counter = counter + 1;
      
    end
    
end % loop over level-1 dirs

return




