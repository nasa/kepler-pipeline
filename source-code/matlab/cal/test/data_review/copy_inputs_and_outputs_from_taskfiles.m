function copy_inputs_and_outputs_from_taskfiles(quarterString, cadenceTypeString, dataDir, figureDir)
%
% function to copy LC data from nfs to local directory for CAL testing (and
% to save disk space on nfs)
%
% INPUTS:
%
% dataDir  directory with all cal outputs from a pipeline run
% figureDir  output directory
%
%
% OUTPUTS (saved in outputPath):
% 
%  cal-inputs-0.mat 
%  cal-inputs-1.mat
%  cal-outputs-0.mat 
%  cal-outputs-1.mat
%
%--------------------------------------------------------------------------
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



if (strcmpi(quarterString, 'Q4') && strcmpi(cadenceTypeString, 'long') && nargin<3)

    dataDir             = '/path/to/pipeline_results/science_q4/q4_archive_ksop479/lc/';
    figureDir           = '/path/to/cal_Q4_data_review/lc_data/';

elseif (strcmpi(quarterString, 'Q4') && strcmpi(cadenceTypeString, 'short') && nargin<3)

    dataDir             = '/path/to/pipeline_results/science_q4/q4_archive_ksop479/sc/';
    figureDir           = '/path/to/cal_Q4_data_review/sc_data';

end


cd(dataDir)

runs = dir('cal-*');

numberOfDirs = length(runs);


for i = 1:numberOfDirs

    dirString = runs(i).name;

    cd(dataDir)
    cd(dirString)

    %-------------------------------------------------------------
    % make new directory and save only inputs and outputs
    %-------------------------------------------------------------

    eval(['!mkdir ' figureDir dirString])

    eval(['!cp cal-inputs-0.mat cal-inputs-1.mat ' figureDir dirString])
    eval(['!cp cal-outputs-0.mat cal-outputs-1.mat ' figureDir dirString])

    cd(dataDir)
end


return;

