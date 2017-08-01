%*************************************************************************************************************
% function copy_pdc_input_files (copyToDirectory)
%
% This function will crawl through an OPS PDC processing run and copy the input files to a new direcotry tree. This is to be used if one wished to perform a
% local run on some PDC tasks.
%
% Run this function in the directory with all the pdc-matlab-* directories.
%
% Inputs:
%   copyToDirectory     -- [char] Directory path to copy to
%   quarterToCopy       -- [int32] Quarter to copy files from
%
% Ouputs:
%   none
%
%*************************************************************************************************************
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
function copy_pdc_input_files (copyToDirectory, quarterToCopy)

    if (~exist(copyToDirectory, 'dir'))
        mkdir(copyToDirectory);
    end
 
    dirNames = dir('pdc-matlab-*');

    if (length(dirNames) < 1)
        error ('There appears to be no task subdirectories in the current direcotry!');
    end

    
    for iDir = 1 : length(dirNames)
        display(['Working on task directory ', num2str(iDir), ' of ', num2str(length(dirNames))]);
 
        cd (dirNames(iDir).name);
        % Work through each 'st-*' subdirectory
        subDirNames = dir('st-*');
        nSubDirs = length(subDirNames);
        for iSubDir = 1 : nSubDirs
            cd (subDirNames(iSubDir).name);

            load 'pdc-inputs-0.mat'
 
            quarter = convert_from_cadence_to_quarter (inputsStruct.startCadence, inputsStruct.cadenceType);
            % quarter is the integer part
            quarter = quarter - rem(quarter,1);
            
            if (quarter == quarterToCopy)

                % Copy input files to a subdirectory of the same name.
                copyToThisSubDirectory = [copyToDirectory, '/', dirNames(iDir).name, '/',subDirNames(iSubDir).name];
                
                mkdir (copyToThisSubDirectory);
                
                copyfile('./blob*.mat', copyToThisSubDirectory);
                copyfile('./pdc-inputs-0.mat', copyToThisSubDirectory);
            end

            cd ..
        end

        cd ..

    end
             
 
