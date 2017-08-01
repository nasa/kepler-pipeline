% function [] = pdc_find_failed_entropy_cleaner_tasks ()
%
% Works through all tasks files and finds which the entropy failed on.
%
% Call this function from the task directory top level directory. It must load the outputs for each
% task directory so it is slow to run.
%
%************************************************************************************************************
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

function [cleanerFailedStruct ] = pdc_find_failed_entropy_cleaner_tasks ()

    display('This function will load ALL outputsStruct in all tasks directories and is slow! Is this what you want?');

    topLevelDirNames = dir('pdc-matlab-*');

    if (length(topLevelDirNames) < 1)
        error ('There appears to be no task subdirectories!');
    end

    nTopLevelDirs = length(topLevelDirNames);

    % Count number of total second level directories
    nModOuts = 0;
    for iTopLevelDir = 1 : nTopLevelDirs
        if(~isdir(topLevelDirNames(iTopLevelDir).name));
            continue;
        end
        cd (topLevelDirNames(iTopLevelDir).name);
        secondLevelDirNames = dir('st-*');
        nModOuts = nModOuts + length(secondLevelDirNames );
        cd ..
    end

    cleanerFailedStruct = repmat(struct('module', 0, 'output', 0, 'quarter', [], ...
                                'noBSFailed', false, ...
                                'noBSMaxIterations', false, ...
                                'band1Failed', false, ...
                                'band1MaxIterations', false, ...
                                'band2Failed', false, ...
                                'band2MaxIterations', false, ...
                                'band3Failed', false), [nModOuts,1]);

    % Work through each top level directory and subdirectory to search for failed entropy cleaner tasks.
    modOutIndex = 1;
    for iTopLevelDir = 1 : nTopLevelDirs
        cd (topLevelDirNames(iTopLevelDir).name);
        secondLevelDirNames = dir('st-*');
        for iModOut = 1 : length(secondLevelDirNames);
            cd (secondLevelDirNames(iModOut).name);
         
            display(['Checking task directory ', num2str(modOutIndex), ' of ', num2str(nModOuts)]);
         
            % If no outputs then move on, presumably no targets.
            if (~exist('pdc-outputs-0.mat', 'file'))
                cd ..
                continue;
            end
         
            % only need outputsStruct
            load('pdc-outputs-0.mat');
         
            cleanerFailedStruct(modOutIndex).module = outputsStruct.ccdModule;
            cleanerFailedStruct(modOutIndex).output = outputsStruct.ccdOutput;
            cadenceType = outputsStruct.cadenceType;
            cleanerFailedStruct(modOutIndex).quarter = convert_from_cadence_to_quarter (outputsStruct.startCadence, cadenceType);
         
            % Find tasks where entropy cleaner failed. Look at alerts for the appropriate message.
            if (~isempty(outputsStruct.alerts))
                if (~isempty(strfind([outputsStruct.alerts.message], 'Band_1: Entropy cleaning appears to have kept too few targets')))
                    cleanerFailedStruct(modOutIndex).band1Failed = true;
                end
                if (~isempty(strfind([outputsStruct.alerts.message], 'Band_1: Max iterations reached while entropy cleaning basis vectors')))
                    cleanerFailedStruct(modOutIndex).band1MaxIterations= true;
                end
         
                if (~isempty(strfind([outputsStruct.alerts.message], 'Band_2: Entropy cleaning appears to have kept too few targets')))
                    cleanerFailedStruct(modOutIndex).band2Failed = true;
                end
                if (~isempty(strfind([outputsStruct.alerts.message], 'Band_2: Max iterations reached while entropy cleaning basis vectors')))
                    cleanerFailedStruct(modOutIndex).band2MaxIterations= true;
                end
         
                if (~isempty(strfind([outputsStruct.alerts.message], 'Band_3: Entropy cleaning appears to have kept too few targets')))
                    cleanerFailedStruct(modOutIndex).band3Failed = true;
                end
         
                if (~isempty(strfind([outputsStruct.alerts.message], 'no_BS: Entropy cleaning appears to have kept too few targets')))
                    cleanerFailedStruct(modOutIndex).noBSFailed = true;
                end
                if (~isempty(strfind([outputsStruct.alerts.message], 'no_BS: Max iterations reached while entropy cleaning basis vectors')))
                    cleanerFailedStruct(modOutIndex).noBSMaxIterations= true;
                end
            end
            modOutIndex = modOutIndex + 1;
            cd ..
        end

        cd ..

    end


    % display results
    display('***************************************************************************************');
    display(['Band 1 failed indices: ', num2str(find([cleanerFailedStruct.band1Failed]))]);
    display('***************************************************************************************');
    display(['Band 1 max Iterations indices: ', num2str(find([cleanerFailedStruct.band1MaxIterations]))]);
    display('***************************************************************************************');
    display(['Band 2 failed indices: ', num2str(find([cleanerFailedStruct.band2Failed]))]);
    display('***************************************************************************************');
    display(['Band 2 max Iterations indices: ', num2str(find([cleanerFailedStruct.band2MaxIterations]))]);
    display('***************************************************************************************');
    display(['Band 3 failed indices: ', num2str(find([cleanerFailedStruct.band3Failed]))]);
    display('***************************************************************************************');
    display(['No BS  failed indices: ', num2str(find([cleanerFailedStruct.noBSFailed]))]);
    display('***************************************************************************************');
    display(['No BS max Iterations indices: ', num2str(find([cleanerFailedStruct.noBSMaxIterations]))]);

return
