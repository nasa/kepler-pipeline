function [outDir] = generate_ppa_dawg_figures(rootDir, pdqDir)
% function [outDir] = generate_ppa_dawg_figures(rootDir, pdqDir)
%
% function to generate PPA DAWG figures from the PPA results in the
% directory "rootDir" where the PPA pipeline results live
% Creates a number of figures in the current working directory
% Inputs:
%   rootDir: location of PPA pipeline results, may either be the location 
%       of all pmd-matlab-* pad-matlab-* pag-matlab-* directories, of may
%       contain /pmd, /pad, /pag directories
%   pdqDir:  location of Quarter long PDQ results (last run of quarter)
%       input an empty string '' to skip pdq comparision
% Output:
%   outDir:  location where figures are written
%
% 13.12.11 DAC: written to better automate DAWG prep
% 15.02.25 DAC: modified to allow for alternate directory structure where 
%       pmd/ pad/ and pag/ results are in their own directories
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

% check for directory structure
dirList = dir(rootDir);
% default to all results in rootDir
pmdRootDir = rootDir;
pagRootDir = rootDir;
padRootDir = rootDir;

% check for alternate structure
for i = 1:length(dirList)
    if (strncmp('pag',dirList(i).name,3) & length(dirList(i).name)==3)
        pagRootDir = [rootDir,filesep,'pag',filesep];
    end
    if (strncmp('pad',dirList(i).name,3) & length(dirList(i).name)==3)
        padRootDir = [rootDir,filesep,'pad',filesep];
    end
    if (strncmp('pmd',dirList(i).name,3) & length(dirList(i).name)==3)
        pmdRootDir = [rootDir,filesep,'pmd',filesep];
    end
end

        
% first collect the PMD data for the metrics, this takes awhile
[pmdStructFile ] = retrieve_pmd_data_for_dawg([pmdRootDir]);

% now make the figures using plot_pmd_dawg_data.m
% edit that file to change which figures are generated/saved by default
[outDir] = plot_pmd_dawg_data(pmdStructFile);

% run comparision of PPA attitude with PDQ attitude
if ~isempty(pdqDir)
    dd = dir([padRootDir,'pad-matlab*']);
    padDir = [padRootDir,dd(1).name];
    [outDir] = compare_pad_pdq_attitude(padDir,pdqDir);
end

% cp the png versions of pag compression figures to the local directory,
% first we need to get the path to the files, whose name changes
dd = dir([pagRootDir,'pag-matlab-*']);
dd2 = dir([pagRootDir,dd.name,filesep,'pag-*Z']);
ddTheo = dir([pagRootDir,dd.name,filesep,dd2.name,filesep,'*theoretical*']);
ddAch = dir([pagRootDir,dd.name,filesep,dd2.name,filesep,'*achieved*']);

% cp the files giving them a generic name so the LaTeX script will find
% them
system(['cp ',[pagRootDir,dd.name,filesep,dd2.name,filesep,ddTheo.name],' pag_theoretical_compression_efficiency.png']);
system(['cp ',[pagRootDir,filesep,dd.name,filesep,dd2.name,filesep,ddAch.name],' pag_achieved_compression_efficiency.png']);



% finito
end


