function cbd_test_cases_gen(iBlackSlope, iCrossTalkExtra, twoDBlackDataOutputDestDir )
%% CBD test cases generation
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

% add ETEM path
MY_CODE_ROOT = '/path/to/code';
% My data destination directory
if nargin == 2
 twoDBlackDataOutputDestDir='/path/to/cbd_test_cases';
end


etemDir = fullfile(MY_CODE_ROOT, 'matlab/etem2/mfiles');
cd(etemDir);
set_paths;

cbdBlackTestDir = fullfile(MY_CODE_ROOT, 'matlab/ct/cbdt/mfiles/test_case_generation');
addpath(cbdBlackTestDir);

CCDFormatParams;    % default CCD parameters

FFI_ROWS = maskSmearSize + scienceImRowSize + virtualSmearSize;
FFI_COLS = leadBlackSize + scienceImColSize + trailBlackSize;

exposure        = 0.0;    % in seconds
numFFI          = 1;      % default value;
dark            = 3.57;   % use default value;
readNoise       = 0.0;    % skipped at this step by setting the value to 0, but will be added in ETEM
gain            = 88;     % use default value;

%crossTalkMag    = 3.0;   % exact value?

% load crosstalk location: variable xtalkImage

% this loads the real cross talk signals
xtalkSignals = fullfile(cbdBlackTestDir, 'xtalk_signals.mat');
load(xtalkSignals);
if ( ~exist('xtalkSignals', 'var') )
    error('Error: variable xtalkSignals is not found!');
end
% we can pick one or take the mean of all 4 xtalk signals
crossTalk = xtalkSignals(:, :, 1);

% No more input parameters from here

crossTalkRanges     = [0.0, -0.20, 0.20];     % up to 20% more of crosstalk
blackSlopeRanges    = [0.0, -0.25, 0.25];    % up to 20% of black slope in vertical direction
blackSlopeNominal   = 1 / 1070;             % nominal slope of the black background in vertical direction

rowCenter = FFI_ROWS / 2;
colCenter = FFI_COLS / 2;
NON_XTALK_PIXEL = 4;
numCoAddsNorm = 270;    % constant

etemTestCasesDir=fullfile(etemDir, 'cbd_test_cases/');  % temporary directory used by ETEM
etemTwoDBlackDataOutputDir=fullfile(etemTestCasesDir, 'output_black');
% if ( 7 == exist(etemTwoDBlackDataOutputDir) )
%     rmdir( fullfile(etemTwoDBlackDataOutputDir, '*'), 's' );  % removethe old stuff
% end

%if ( 7 == exist(twoDBlackDataOutputDestDir) )
%    rmdir( twoDBlackDataOutputDestDir, 's' );  % removethe old stuff
%end

%mkdir([twoDBlackDataOutputDestDir]);

% loop different levels of black slope
%%for iBlackSlope = blackSlopeRanges

    % generate 1D black levels
    blackCol = ([1:FFI_ROWS]' - rowCenter) * ( blackSlopeNominal * iBlackSlope ) + blackLevel;

    % extrude 2D black from 1D black column
    black2D = repmat(blackCol, 1, FFI_COLS);

    % loop different levels of crosstalk levels
%%    for iCrossTalkExtra = crossTalkRanges

        fprintf('black column slope: %f; crosstalk adjustment: %f\n', iBlackSlope, iCrossTalkExtra);

        % combine black and cross talk signals
        black2DInterim = black2D + crossTalk * ( 1.0 + iCrossTalkExtra );

        minBlack = min( black2DInterim(:));
        maxBlack = max( black2DInterim(:));
        % call Doug's function to add the effect of dark and shot noise
        myTwoDBlackData = generateDarkFrame(exposure, numFFI, dark, readNoise, gain, black2DInterim);

        if ( false )
            figure(10), subplot(2, 2, 1), imagesc( crossTalk, [-6, 0]); title('Cross talk levels'); colorbar;
            subplot(2, 2, 2), imagesc( black2DInterim, [minBlack, maxBlack]); title('2D black + crosstalk signals'); colorbar;
            subplot(2, 2, 3), imagesc( myTwoDBlackData, [minBlack, maxBlack]); title('2D black + crosstalk + dark + shot noise for ETEM'); colorbar;

            %subplot(2, 2, 4), imagesc( myTwoDBlackData, [minBlack, maxBlack]); title('2D black + crosstalk + dark + shot noise for ETEM'); colorbar;
        end

        % ETEM adds readout noise and cosmic rays
        %  + 1.0 and 1.20 times of nominal readout noise;
        %  + 1.0 and 5 times of nominal cosmic rays;
        disp('Going through ETEM chamber ...');

        save([fullfile(etemTestCasesDir, 'twoDBlackImage.mat')], 'myTwoDBlackData');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % call ETEM to add noise and other effects
        blackDataStruct = ETEM2_cbd_inputs_example();

        for channel=1:84
            [module, output] = convert_to_module_output( channel);

            % provide the input file name for loading
            blackDataStruct.blackDataDir = etemTestCasesDir;
            blackDataStruct.blackDataFilename = 'twoDBlackImage.mat';   % get from SBT! - Change!
            blackDataStruct.runParamsData.simulationData.moduleNumber = module; % which CCD module, ouput and season, legal values: 2-4, 6-20, 22-24
            blackDataStruct.runParamsData.simulationData.outputNumber = output; % legal values: 1-4

            % call the ETEM processor
            etem2_dark( blackDataStruct );
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Simulated missing pixels by removing chunks of pixels
            disp('Simulating missing pixels ...');

            % rename the file for later processing
            newFilename = strcat(num2str(iBlackSlope, 'slope_%+04.2f'), num2str(iCrossTalkExtra, '_xtalk_%+04.2f'));
            twoDBlackDataOutputDestFilename = fullfile(twoDBlackDataOutputDestDir, newFilename);
            
            disp([ fullfile(etemTwoDBlackDataOutputDir, '*') ',' num2str(channel) '=' num2str(module) '+' num2str(output) ',' twoDBlackDataOutputDestFilename] );
            
            
            if ( false )
                % display results
                oneSampleImageFilename = fullfile(twoDBlackDataOutputDestFilename, 'run_long_m16o1s1/ccdDarkImage_2.mat');

                disp(oneSampleImageFilename);
                load(oneSampleImageFilename);

                normFFI = ccdImage / numCoAddsNorm ;
                figure(21), subplot(2,2,1), imagesc( myTwoDBlackData ); title(' ETEM input Image'); colorbar;
                subplot(2,2,2), imagesc( normFFI ); title(' ETEM processed Image'); colorbar;
                subplot(2,2,3), plot( myTwoDBlackData(:, 500)); title(' ETEM input Image: column 500'); xlim([0, 1070]);
                subplot(2,2,4), plot( normFFI(:, 500) ); title(' ETEM processed Image: column 500'); xlim([0, 1070]);

            end
        end
	% move all the newly generated files in one go!
            movefile( fullfile(etemTwoDBlackDataOutputDir, '*'), twoDBlackDataOutputDestFilename, 'f' );
        disp('**** Next test case? Pause for a second before continuing ...');
        %pause(2);
%    end


%end

disp('*** All done!');




