function self = test_pmd_cdpp_mmr(self)
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

    files = {'pmd-inputs-01.mat' 'pmd-inputs-02.mat' 'pmd-inputs-03.mat'};

    for ifile = 1:length(files)
        msg=sprintf('Running test file %d of %d for test_pmd_cdpp_mmr', ifile, length(files));
        fileDir = files{ifile};
        test_input_file_for_cdpp(fileDir);
    end 
return

function test_input_file_for_cdpp(file)
    prevDir = pwd();
    initialize_soc_variables();
    cd(fullfile(socTestDataRoot, 'ppa', 'MATLAB', 'unit-tests', 'pmd'));

    load(file);
    inputsStruct.raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');
    pmdScienceObject = pmdScienceClass(inputsStruct);
    cdppMetrics = calculate_cdpp_metric(pmdScienceObject);
    assert(cdpp_mmr_is_structured_correctly(cdppMetrics));
    cd(prevDir);
return

function isCdppMmrStructuredCorrectly = cdpp_mmr_is_structured_correctly(cdppReport)
    isCdppMmrStructuredCorrectly = isfield(cdppReport, 'mmrMetrics') && ...
                                   isfield(cdppReport.mmrMetrics, 'countOfStarsInMagnitude') && ...
                                   isfield(cdppReport.mmrMetrics, 'medianCdpp') && ...
                                   isfield(cdppReport.mmrMetrics, 'tenthPercentileCdpp') && ...
                                   isfield(cdppReport.mmrMetrics, 'noiseModel') && ...
                                   isfield(cdppReport.mmrMetrics, 'percentBelowNoise') && ...
                                   isfield(cdppReport.mmrMetrics.noiseModel, 'mag9') && ...
                                   isfield(cdppReport.mmrMetrics.noiseModel, 'mag10') && ...
                                   isfield(cdppReport.mmrMetrics.noiseModel, 'mag11') && ...
                                   isfield(cdppReport.mmrMetrics.noiseModel, 'mag12') && ...
                                   isfield(cdppReport.mmrMetrics.noiseModel, 'mag13') && ...
                                   isfield(cdppReport.mmrMetrics.noiseModel, 'mag14') && ...
                                   isfield(cdppReport.mmrMetrics.noiseModel, 'mag15');
return
