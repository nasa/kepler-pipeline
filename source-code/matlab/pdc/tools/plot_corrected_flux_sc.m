% function [] = plot_corrected_flux_sc (dirBrackets)
%
% This functions works through all SC task directories and plots all SC targets!
%
% Call this function from the task directory top level directory. It must load the inputs and outputs for each
% task directory so it is slow to run. But it's SC data so the task files aren't THAT big.
%
% WARNING: There is nothing in the function that forces this to be called on short cadence data. You can run
% it on long cadence. It will just take a REALLY LONG TIME since all >160,000 argets are plotted!
%
% Inputs:
%   dirBrackets -- [int array(2)] first and last channels to plot targets for. If not present the you will be prompted for input 
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

function [] = plot_corrected_flux_sc (dirBrackets)

    display('This function will plot ALL targets in all task directories. Is this what you want?');

    dirNames = dir('pdc-matlab-*');
    if (isempty(dirNames))
        % Then in uow directory
        usingUowDir = true;
        dirNames = dir('pdc-*');
    else
        usingUowDir = false;
    end

    if (length(dirNames) < 1)
        error ('There appears to be no task subdirectories!');
    end

    figureHandles = [];
    nDirs = length(dirNames);
    % Allow user to specfiy range of directories to be examined
    if (~exist('dirBrackets', 'var'))
        if usingUowDir
            searchString = input(['',num2str(nDirs,'%d'),' directories; enter the search string fo the directories', ...
                'to step through, eg ''*q10m1*'' (<Enter> for all dirs)-- ']);
            dirNames = dir(searchString);
            nDirs = length(dirNames);
            dirBrackets = [];
        else
            dirBrackets = input( ...
                ['',num2str(nDirs,'%d'),' directories; enter the indexes of the directories to step through, eg [41 80] (<Enter> for all dirs)-- ']);
        end
    end
    if (isempty(dirBrackets))
        dirBrackets = [1 nDirs];
    end
    for iDir = dirBrackets(1) : dirBrackets(2)
        cd (dirNames(iDir).name);
        if (~usingUowDir)
            % Work through each 'st-*' subdirectory
            subDirNames = dir('st-*');
            nSubDirs = length(subDirNames);
            for iSubDir = 1 : nSubDirs
                cd (subDirNames(iSubDir).name);
         
                display(['Plotting task directory ', num2str(iDir), ' of ', num2str(nDirs)]);
         
                % If no outputs then move on, presumably no targets.
                if (~exist('pdc-outputs-0.mat', 'file'))
                    cd ../..
                    continue
                end
         
                % plot the corrected flux for each target in this task
                figureHandles = plot_corrected_flux_from_this_task_directory ('all', [], 0, figureHandles);
         
                cd ../..
            end
        else

            display(['Plotting task directory ', num2str(iDir), ' of ', num2str(nDirs)]);
         
            % If no outputs then move on, presumably no targets.
            if (~exist('pdc-outputs-0.mat', 'file'))
                 cd ../../uow
                 continue
            end
         
            % plot the corrected flux for each target in this task
            figureHandles = plot_corrected_flux_from_this_task_directory ('all', [], 0, figureHandles);
         
            cd ../../uow
        end

    end


