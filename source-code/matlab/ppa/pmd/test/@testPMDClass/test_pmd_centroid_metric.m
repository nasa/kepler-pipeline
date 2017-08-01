function self = test_pmd_centroid_metric(self)
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

    fprintf('\nTest PMD: centroid metrics\n');

    initialize_soc_variables;
    pmdTestDataRoot = fullfile(socTestDataRoot, 'ppa', 'MATLAB', 'unit-tests', 'pmd');
    addpath(pmdTestDataRoot);
    load pmdInputStruct.mat;
    pmdScienceObject = pmdScienceClass(pmdInputStruct);
    centroidReport = calculate_centroid_metric(pmdScienceObject);

    % Check that there are the same number of elements in each bin:
    %
    check_lengths(centroidReport);

    % Check that data is right type
    %
    check_datatypes(centroidReport);
    
    % Check that the data is in a sensible range:
    %
    check_data_range(centroidReport);

    % Check that a bad object will be detected:
    %
    check_bad_data();
    
    rmpath(pmdTestDataRoot);
return

function check_lengths(centroidReport)
    % Check that there are the same number of elements in each bin:
    %
    dataLengths = [];
    
    dataLengths(1) = length(centroidReport.centroidsMeanRow.values);
    dataLengths(2) = length(centroidReport.centroidsMeanRow.uncertainties);
    dataLengths(3) = length(centroidReport.centroidsMeanRow.gapIndicators);
    dataLengths(4) = length(centroidReport.centroidsMeanColumn.values);
    dataLengths(5) = length(centroidReport.centroidsMeanColumn.uncertainties);
    dataLengths(6) = length(centroidReport.centroidsMeanColumn.gapIndicators);
    
    assert_equals(length(unique(dataLengths)), 1);

    % Check that there is data in the outputs:
    %
    assert_equals(dataLengths(1) > 0, true);
return

function check_datatypes(centroidReport)
    % The .values and .uncertainties fields s/b double, the .gapIndicators s/b boolean.
    %
    assert_equals(all(isfloat(centroidReport.centroidsMeanRow.values)), true);
    assert_equals(all(isfloat(centroidReport.centroidsMeanRow.uncertainties)), true);
    assert_equals(all(islogical(centroidReport.centroidsMeanRow.gapIndicators)), true);
            
    assert_equals(all(isfloat(centroidReport.centroidsMeanColumn.values)), true);
    assert_equals(all(isfloat(centroidReport.centroidsMeanColumn.uncertainties)), true);
    assert_equals(all(islogical(centroidReport.centroidsMeanColumn.gapIndicators)), true);
return

function check_data_range(centroidReport)
    assert_equals(all(centroidReport.centroidsMeanRow.values    >= -100 & centroidReport.centroidsMeanRow.values    < 100), true);
    assert_equals(all(centroidReport.centroidsMeanColumn.values >= -100 & centroidReport.centroidsMeanColumn.values < 100), true);
    
    assert_equals(all(islogical(centroidReport.centroidsMeanRow.gapIndicators)), true);
    assert_equals(all(islogical(centroidReport.centroidsMeanColumn.gapIndicators)), true);
return

function check_bad_data()
    try 
        load pmdInputStruct.mat;
        pmdScienceObject = pmdScienceClass(pmdInputStruct);
        cdppReportBad = calculate_centroid_metric(pmdScienceObjectBad);
        assert_equals(true, false);
    catch
        assert_equals(true, true);
    end
return
