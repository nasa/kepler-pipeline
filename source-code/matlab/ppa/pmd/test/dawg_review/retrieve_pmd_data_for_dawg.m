function [pmdStructOutFile] = retrieve_pmd_data_for_dawg(rootDir)
% function [pmdStructOutFile] = retrieve_pmd_data_for_dawg(rootDir)
% This program collects PMD input and output structures of all module/outputs from the user defined folders
% The function generates a file that contains two structures:
%   pmdInputStructs
%   pmdOutputStructs
% These files are used by generate_ppa_dawg_figures to make PPA figures for
% DAWG review
% Inputs
%   rootDir - string containing the full path name to the
%           pmd-matlab-###-#### directories
%
% Outputs
%   pmdStructOutFile - full path name to the output file containing PMD
%           structs
%
% 12/12/2011 DAC: modified from Jie Lie's retrievePmdData.m script to be
% run as part of the DAWG report generation. Designed to be called by
% generate_ppa_dawg_figures.m
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


dd = dir([rootDir,filesep,'pmd-matlab-*']);
nChannels = length(dd);  % should be 80 after mod-3 failure in Q4
switch nChannels
    case {84,80}
        disp('Kepler data');
    case {76}
        disp('K2 data')
    otherwise
        warning(['Unexpected number of channels (',int2str(nChannels),') in PMD directory structure: ',rootDir]);

end

hw = waitbar(0,['fraction of channels completed']);

% Collect PMD input and output structures for all module/outputs
for iChannel=1:nChannels 
        
    % load the pmd directories
    load([rootDir,filesep,dd(iChannel).name,filesep,'pmd-inputs-0.mat'])
    load([rootDir,filesep,dd(iChannel).name,filesep,'pmd-outputs-0.mat'])
    
    
    pmdInputStructs(iChannel).cadenceTimes  = inputsStruct.cadenceTimes;
    pmdInputStructs(iChannel).inputTsData   = inputsStruct.inputTsData;
    pmdOutputStructs(iChannel).outputTsData = outputsStruct.outputTsData;
    
    clear inputsStruct outputsStruct
    waitbar(iChannel/nChannels,hw,[int2str(iChannel),' of ',int2str(nChannels),' complete']);
end

% Save the collected data of all module/outputs in a .mat file
save pmd_input_output_structs_dawg.mat pmdInputStructs pmdOutputStructs

pmdStructOutFile = [pwd,filesep,'pmd_input_output_structs_dawg.mat'];
close(hw)

