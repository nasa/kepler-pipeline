function self = test_ar_round_trip(self)
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
    [binDir binFiles] = get_bin_files_list();
    addpath(binDir);
    initialize_soc_variables();
    
    for binFile = binFiles
        % Read the inputs
        %
        is = read_ArchiveInputs(binFile{1});
        nCadences = length(is.cadenceTimesStruct.cadenceNumbers);

        % Fix the ephemeris file location:
        %
        is.raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');
        is.raDec2PixModel.spiceSpacecraftEphemerisFilename = 'spk_2010256000000_2010259185321_kplr.bsp';

        % Run the controller, and display the time it consumed:
        %
        disp('Running AR controller');
        tic
        os = ar_matlab_controller(is);
        timeElapsed = toc();
        fprintf('%f seconds to run file %s\n', timeElapsed, binFile{1});
        
        % Run the tests
        %
        background_tests(is, os);
        bary_tests(os, nCadences);
        dva_tests(os, nCadences);
        wcs_tests(os);

        % Tests the output write/read round trip:
        %
        outFile = 'outfile.bin';
        write_ArchiveOutputs(outFile, os);
        osread = read_ArchiveOutputs(outFile); %#ok<NASGU>
    end
    
    rmpath(binDir);
return

function background_tests(is, os)
        % Test the background data:
        %
        disp('ar background tests');
        
        backgroundFields = {'ccdRow', 'ccdColumn', 'background', 'backgroundGaps', 'backgroundUncertainties', 'backgroundUncertaintyGaps'};

        assert_equals(sum(isfield(os.background, backgroundFields)), length(backgroundFields));
        if ~isempty(os.background)
            for ii = 1:length(os)
                data = os.background(ii).background;
                uncert = os.background(ii).backgroundUncertainties;
                assert_equals(length(data), length(uncert));
            end
        end
        if ~isempty(os.background)
            % Test the input data and output data have the same length
            assert_equals(length(is.backgroundInputs.pixelCoordinates), length(os.background));
        end
return

function bary_tests(os, nCadences)
    % Test the barycentric data:
    %
    disp('ar bary tests');
    
    baryFields = {'barycentricTimeOffsets', 'barycentricGapIndicator', 'keplerId', 'raDecimalHours', 'decDecimalDegrees'};
    
    assert_equals(sum(isfield(os.barycentricOutputs, baryFields)), length(baryFields));
    if ~isempty(os.barycentricOutputs)
        for ii = 1:length(os)
            data = os.barycentricOutputs(ii).barycentricTimeOffsets;
            gaps = os.barycentricOutputs(ii).barycentricGapIndicator;
            assert_equals(length(data), length(gaps));
        end

        % Verify cadence number matches inputs:
        assert_equals(nCadences, length([os.barycentricOutputs.barycentricTimeOffsets]));
        assert_equals(nCadences, length([os.barycentricOutputs.barycentricGapIndicator]));
        assert(os.barycentricOutputs.raDecimalHours > 15 && os.barycentricOutputs.raDecimalHours < 25);
        assert(os.barycentricOutputs.decDecimalDegrees > 35 && os.barycentricOutputs.decDecimalDegrees < 65);
    end
return


function dva_tests(os, nCadences)
    % Test the DVA data:
    %
    disp('ar DVA tests');
    
    dvaFields = {'keplerId', 'rowDva', 'columnDva', 'rowGapIndicator', 'columnGapIndicator'};

    assert_equals(sum(isfield(os.targetDva, dvaFields)), length(dvaFields));
    if ~isempty(os.targetDva)
        % Verify cadence number matches inputs:
        assert_equals(nCadences, length([os.targetDva.rowDva]));
        for i=1:length(os.targetDva)
            assert_equals(length(os.targetDva(i).rowDva), length(os.targetDva(i).columnDva));
            assert_equals(length(os.targetDva(i).rowDva), length(os.targetDva(i).rowGapIndicator));
            assert_equals(length(os.targetDva(i).rowDva), length(os.targetDva(i).columnGapIndicator));
            assert(max(abs(os.targetDva(i).rowDva)) < 100);
            assert(max(abs(os.targetDva(i).columnDva)) < 100);
        end
    end
return

function wcs_tests(os)
    % Test the WCS data :
    %
    disp('ar WCS tests');
    
    wcsFields = { ...
        'keplerId', ...
        'outputRaDecsAreCalculated', ...
        'subimageReferenceColumn', ...
        'subimageReferenceRow', ...
        'originalImageReferenceColumn', ...
        'originalImageReferenceRow', ...
        'plateScaleColumn', ...
        'plateScaleRow', ...
        'subimageCoordinateSystemReferenceColumn', ...
        'subimageCoordinateSystemReferenceRow', ...
        'subimageReferenceRightAscension', ...
        'subimageReferenceDeclination', ...
        'unitMatrixDegreesPerPixelColumn', ...
        'unitMatrixDegreesPerPixelRow', ...
        'unitMatrixRotationMatrix11', ...
        'unitMatrixRotationMatrix12', ...
        'unitMatrixRotationMatrix21', ...
        'unitMatrixRotationMatrix22', ...
        'alternateRepresentationMatrix11', ...
        'alternateRepresentationMatrix12', ...
        'alternateRepresentationMatrix21', ...
        'alternateRepresentationMatrix22'};
    expectedWcsSubFields = { 'headerKeyword', 'value' };
    
    if ~isempty(os.targetWcs)
        assert_equals(sum(isfield(os.targetWcs, wcsFields)), length(wcsFields));
        for ifield = 1:length(os.targetWcs)
            internalFields = fields(os.targetWcs(ifield));
            for iinternal = 1:length(internalFields)
                switch internalFields{iinternal}
                    case {'keplerId', 'outputRaDecsAreCalculated'}
                         % do nothing
                    otherwise
                        assert_equals(sum(isfield(os.targetWcs(ifield).(internalFields{iinternal}), expectedWcsSubFields)), length(expectedWcsSubFields))
                end
            end
        end
    end
return
