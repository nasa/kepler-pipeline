function self = test_pmd_cdpp_metric(self)
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

    fprintf('\nTest PMD: CDPP metrics\n');

    initialize_soc_variables;
    pmdTestDataRoot = fullfile(socTestDataRoot, 'ppa', 'MATLAB', 'unit-tests', 'pmd');
    addpath(pmdTestDataRoot);
    load pmdInputStruct.mat;
    % Add surface gravity
    for i=1:length(pmdInputStruct.cdppTsData), pmdInputStruct.cdppTsData(i).log10SurfaceGravity = 12.0*rand(1); end
    pmdScienceObject = pmdScienceClass(pmdInputStruct);
    cdppReport = calculate_cdpp_metric(pmdScienceObject);

    % Check that there are the same number of elements in each bin:
    %
    check_lengths(cdppReport);

    % Check that data is right type
    %
    check_datatypes(cdppReport);

    % Check that the data is in a sensible range:
    %
    check_data_range(cdppReport);

    % Check that a bad object will be detected:
    %
    check_bad_data();

    isCdppMmrStructuredCorrectly = cdpp_mmr_is_structured_correctly(cdppReport);
    assert(isCdppMmrStructuredCorrectly, true)
    
    rmpath(pmdTestDataRoot);
return

function check_lengths(cdppReport)
    dataLengths = [];
    
    reports = {'measured' 'expected' 'ratio'};
    for irep = 1:length(reports)
        report = reports{irep};

        mags = fieldnames(cdppReport.(report));
        for imag = 1:length(mags)
            mag = mags{imag};
            
            hours = fieldnames(cdppReport.(report).(mag));
            for ihour = 1:length(hours)
                hour = hours{ihour};
                
                dataLengths(end+1) = length(cdppReport.(report).(mag).(hour).values);
                dataLengths(end+1) = length(cdppReport.(report).(mag).(hour).uncertainties);
                dataLengths(end+1) = length(cdppReport.(report).(mag).(hour).gapIndicators);
            end
        end
    end
    uniqLengths = unique(dataLengths);
    numUniqLengths = length(uniqLengths);
    assert_equals(numUniqLengths, 1);

    % Check that there is data in the outputs:
    %
    assert_equals(dataLengths(1) > 0, true);
return

function check_datatypes(cdppReport)
    % The .values and .uncertainties fields s/b double, the .gapIndicators s/b boolean.
    %
    reports = {'measured' 'expected' 'ratio'};
    for irep = 1:length(reports)
        report = reports{irep};

        mags = fieldnames(cdppReport.(report));
        for imag = 1:length(mags)
            mag = mags{imag};

            hours = fieldnames(cdppReport.(report).(mag));
            for ihour = 1:length(hours)
                hour = hours{ihour};

                assert_equals(all(isfloat(  cdppReport.(report).(mag).(hour).values)), 1);
                assert_equals(all(isfloat(  cdppReport.(report).(mag).(hour).uncertainties)), 1);
                assert_equals(all(islogical(cdppReport.(report).(mag).(hour).gapIndicators)), 1);
            end
        end
    end
            
return

function check_data_range(cdppReport)
    reports = {'measured' 'expected' 'ratio'};
    for irep = 1:length(reports)
        report = reports{irep};

        mags = fieldnames(cdppReport.(report));
        for imag = 1:length(mags)
            mag = mags{imag};

            hours = fieldnames(cdppReport.(report).(mag));
            for ihour = 1:length(hours)
                hour = hours{ihour};
                
                assert_equals(all(cdppReport.(report).(mag).(hour).values >= -1), true)
            end
        end
    end         
return

function check_bad_data()
    try 
        load pmdInputStruct.mat;
        pmdScienceObject = pmdScienceClass(pmdInputStruct);
        cdppReportBad = calculate_cdpp_metric(pmdScienceObject);
        assert_equals(true, false);
    catch
        assert_equals(true, true);
    end
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
