% pdc_check_band_utilization ()
% 
% Crawls through each task directory and checks to confirm the proper bands
% ran or didn't run. The check simply looks in the map_plots/Band_*
% directories to see if the 'basis_vectors.fig' file was created. This only
% occurs if MAP in the band was actually performed.
%
% Call this function from the task directory top level directory. It's very fast since no files are actually
% loaded.
%
% THIS FUNCTION MUST BE CUSTOM EDITED WHEN THE BAND STRUCTURE IS CHANGED!
% It's hard coded in!
%
% Outputs:
%   band1NotRun -- [char struct] Directory names for tasks where band 1 was NOT run
%   band2NotRun -- [char struct] Directory names for tasks where band 2 was NOT run
%   band3NotRun -- [char struct] Directory names for tasks where band 3 was NOT run
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

function [band1NotRun band2NotRun, band3NotRun] = pdc_check_band_utilization ()

    dirNames = dir('pdc-matlab-*');

    if (length(dirNames) < 1)
        error ('There appears to be no task subdirectories!');
    end

    band1NotRun = []; 
    band2NotRun = []; 
    band3NotRun = []; 
    
    band1Index = 1;
    band2Index = 1;
    band3Index = 1;
    for iDir = 1 : length(dirNames)
        cd (dirNames(iDir).name);
        % Work through each 'st-*' subdirectory
        subDirNames = dir('st-*');
        nSubDirs = length(subDirNames);
        for iSubDir = 1 : nSubDirs
            cd (subDirNames(iSubDir).name);
         
            % Check if band 1 was run (based on a figure only generated when the band is run)
            if (~exist('map_plots/Band_1/prior_pdf_goodness.fig', 'file'))
                band1NotRun{band1Index} = pwd;
                band1Index = band1Index + 1;
            end
            
            % Check if band 2 was run 
            if (~exist('map_plots/Band_2/prior_pdf_goodness.fig', 'file'))
                band2NotRun{band2Index} = pwd;
                band2Index = band2Index + 1;
            end
            
            % Check if band 3 was run 
            if (~exist('map_plots/Band_3/prior_pdf_goodness.fig', 'file'))
                band3NotRun{band3Index} = pwd;
                band3Index = band3Index + 1;
            end
            
            cd ..
        end
        cd ..
    end
    
    nBand1NotRun = length(band1NotRun);
    nBand2NotRun = length(band2NotRun);
    nBand3NotRun = length(band3NotRun);

    display('**********************************');
    if (nBand1NotRun > 0)
        display([num2str(nBand1NotRun), ' mod.outs where band 1 was NOT run!']);
    else
        display('Band 1 was run for all mod.outs');
    end

    display('**********************************');
    if (nBand2NotRun > 0)
        display([num2str(nBand2NotRun), ' mod.outs where band 2 was NOT run!']);
    else
        display('Band 2 was run for all mod.outs');
    end

    display('**********************************');
    if (nBand3NotRun > 0)
        display([num2str(nBand3NotRun), ' mod.outs where band 3 was NOT run!']);
    else
        display('Band 3 was run for all mod.outs');
    end

