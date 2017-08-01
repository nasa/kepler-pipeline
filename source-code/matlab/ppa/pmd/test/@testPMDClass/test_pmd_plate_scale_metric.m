function self = test_pmd_plate_scale_metric(self)
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

    fprintf('\nTest PMD: plate scale metrics\n');

    initialize_soc_variables;
    pmdTestDataRoot = fullfile(socTestDataRoot, 'ppa', 'MATLAB', 'unit-tests', 'pmd');
    addpath(pmdTestDataRoot);
    load pmdInputStruct.mat;
    pmdScienceObject = pmdScienceClass(pmdInputStruct);
    plateScaleReport = calculate_plate_scale_metric(pmdScienceObject);

    % Check that there are the same number of elements in each bin:
    %
    check_lengths(plateScaleReport);

    % Check that data is right type
    %
    check_datatypes(plateScaleReport);
    
    % Check that the data is in a sensible range:
    %
    check_data_range(plateScaleReport);

    % Check that a bad object will be detected:
    %
    check_bad_data();
    
    rmpath(pmdTestDataRoot);
return

function check_lengths(plateScaleReport)
    
    % Check that there are the same number of elements in each bin:
    %
    dataLengths = [];
    
    dataLengths(1) = length(plateScaleReport.values);
    dataLengths(2) = length(plateScaleReport.uncertainties);
    dataLengths(3) = length(plateScaleReport.gapIndicators);
    
    assert_equals(length(unique(dataLengths)), 1);
    
    % Check that there is data in the outputs:
    %
    assert_equals(dataLengths(1) > 0, true);
return

function check_datatypes(plateScaleReport);
    % The .values and .uncertainties fields s/b double, the .gapIndicators s/b boolean.
    %
    assert_equals(all(isfloat(plateScaleReport.values)), 1);
    assert_equals(all(isfloat(plateScaleReport.uncertainties)), 1);
    assert_equals(all(islogical(plateScaleReport.gapIndicators)), 1);
return

function check_data_range(plateScaleReport)
    assert_equals(all(plateScaleReport.values > 0 & plateScaleReport.values < 2.0), true);
    assert_equals(all(islogical(plateScaleReport.gapIndicators)), true);
return

function check_bad_data()
    try 
        load pmdInputStruct.mat;
        pmdScienceObject = pmdScienceClass(pmdInputStruct);
        cdppReportBad = calculate_plate_scale_metric(pmdScienceObjectBad);
        assert_equals(true, false);
    catch
        assert_equals(true, true);
    end
return
