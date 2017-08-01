function test_intelligent_save( testDir )
%******************************************************************************
% Test function for intelligent_save.m 
%******************************************************************************
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
    GB =  1024 ^ 3;
    BYTES_PER_DOUBLE = 8;
    doLargeVariableTests = true;
    
    testFileName = 'intelligent_save_test.mat';
    
    if ~exist('testDir', 'var')
        testDir = '~/tmp';
    end
    
    %----------------------------------------------------------------------
    % Test basic functionality: handling of arguments, corner cases, etc.
    %----------------------------------------------------------------------
    a = rand(10);
    b = rand(10);

    % Test save with no args.
    originalDir = cd(testDir);
    success = intelligent_save();
    cd(originalDir)
    if success
        resultStr = 'PASSED';
    else
        resultStr = 'FAILED';
    end
    fprintf('No arguments test: %s\n', resultStr);
    if ~success
        error('');
    end
    delete(fullfile(testDir, 'matlab.mat'));
    
    % Test with one argument.
    success = intelligent_save(fullfile(testDir, testFileName));
    if success
        resultStr = 'PASSED';
    else
        resultStr = 'FAILED';
    end
    fprintf('One argument test: %s\n', resultStr);
    if ~success
        error('');
    end
    delete(fullfile(testDir, testFileName));
    
    % Test with empty args.
    success = intelligent_save(fullfile(testDir, testFileName), '', '-v7', 'a', '');
    if success
        resultStr = 'PASSED';
    else
        resultStr = 'FAILED';
    end
    fprintf('Empty argument test: %s\n', resultStr);
    if ~success
        error('');
    end
    
    % Test appending with jumbled arguments.
    success = intelligent_save(fullfile(testDir, testFileName), '-append', 'b', '-v7');
    if success
        resultStr = 'PASSED';
    else
        resultStr = 'FAILED';
    end
    fprintf('Append test: %s\n', resultStr);
    
    % Test saving a structure's fields.
    delete(fullfile(testDir, testFileName));
    testStruct = struct('a', rand(10), 'b', rand(10));
    success = intelligent_save(fullfile(testDir, testFileName), ...
        '-struct', 'testStruct', 'a', 'b');
    if success
        resultStr = 'PASSED';
    else
        resultStr = 'FAILED';
    end
    fprintf('Struct fields test: %s\n', resultStr);
    
    % Test use of format specifiers.
    success = intelligent_save(fullfile(testDir, testFileName), 'b', '-ascii', '-tabs');
    if success
        resultStr = 'PASSED';
    else
        resultStr = 'FAILED';
    end
    fprintf('Format specifier test: %s\n', resultStr);
    
    
    % Test saving with different versions.
    success = intelligent_save(fullfile(testDir, testFileName), 'a', '-v7');
    if success
        resultStr = 'PASSED';
    else
        resultStr = 'FAILED';
    end
    fprintf('v7 test: %s\n', resultStr);
    
    success = intelligent_save(fullfile(testDir, testFileName), 'a', '-v4');
    if success
        resultStr = 'PASSED';
    else
        resultStr = 'FAILED';
    end
    fprintf('v4 test: %s\n', resultStr);
    
    success = intelligent_save(fullfile(testDir, testFileName), 'a', '-v6');
    if success
        resultStr = 'PASSED';
    else
        resultStr = 'FAILED';
    end
    fprintf('v6 test: %s\n', resultStr);
    
    success = intelligent_save(fullfile(testDir, testFileName), 'a', '-v7.3');
    if success
        resultStr = 'PASSED';
    else
        resultStr = 'FAILED';
    end
    fprintf('v7.3 test: %s\n', resultStr);

    % Note that this test should cause an error, but not before the call to
    % save(). We therefore print the error message.
    try
        intelligent_save(fullfile(testDir, testFileName), 'a', '-v1.0');
    catch
        errorThrown = lasterror;
        success = ~isempty(strfind(errorThrown.message, 'Error using ==> save'));
    end
    
    if success
        resultStr = 'PASSED';
    else
        resultStr = 'FAILED';
    end
    fprintf('Bad version test: %s\n', resultStr);
    
    %----------------------------------------------------------------------
    % Test with large variables (NOTE that this requires both some time and
    % more than 2GB of free disk space).
    %----------------------------------------------------------------------
    if doLargeVariableTests
        b = rand(2 * GB / BYTES_PER_DOUBLE + 1000, 1);

        % Make sure the size of 'b' exceeds the 2GB threshold.
        s = whos('b');
        if s.bytes > 2* GB
            display('Variable b > 2GB.');
        else
            error('Variable b < 2GB.');
        end

        % Test saving a large variable with -v7 format specifier.
        S = warning('off', 'all');
        lastwarn(''); % reset the warning message.
        save(fullfile(testDir, testFileName), 'b', '-v7');
        saveStatus = isempty(lastwarn);
        warning(S);   % restore warning state
        
        isaveStatus = intelligent_save(fullfile(testDir, testFileName), 'b', '-v7');
        if saveStatus == false && isaveStatus == true
            resultStr = 'PASSED';
        else
            resultStr = 'FAILED';
        end
        fprintf('Test saving a large variable with -v7 format specifier: %s\n', resultStr);
        delete(fullfile(testDir, testFileName));

        % Test appending a large variable to an existing v7.3 file.
        intelligent_save(fullfile(testDir, testFileName), 'a', '-v7.3');
        success = intelligent_save(fullfile(testDir, testFileName), 'b', '-append', '-v7.3');
        if success
            resultStr = 'PASSED';
        else
            resultStr = 'FAILED';
        end
        fprintf('Test appending a large variable to an existing v7.3 file: %s\n', resultStr);
        delete(fullfile(testDir, testFileName));

        % Test appending a large variable to an existing v7 file (should
        % throw an error).
        try
            intelligent_save(fullfile(testDir, testFileName), 'a', '-v7');
            intelligent_save(fullfile(testDir, testFileName), 'b', '-append', '-v7.3');
        catch
            errorThrown = lasterror;
            success = ~isempty(strfind(errorThrown.message, 'intelligent_save: Error saving file. No file saved!'));
        end
        if success
            resultStr = 'PASSED';
        else
            resultStr = 'FAILED';
        end
        fprintf('Test appending a large variable to an existing v7 file: %s\n', resultStr);
        delete(fullfile(testDir, testFileName));
    end
end

