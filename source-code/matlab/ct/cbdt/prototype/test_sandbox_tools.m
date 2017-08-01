%% PROTOTYPE CODE FOR TESTING FFI IMAGE IO FROM 21 MODULES
%%
% March 29, 2008 by Gary Zhang
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

clear;

% test
runStartMjd = datestr2mjd('July 1 2010');
runEndMjd = runStartMjd + 1;


strTitleFigure = 'Module: XX; Output: YY';
blackArrayAdu = zeros(1070, 1132);

nModule = 21;
listModule = [2:4,6:20,22:24];
nOutput = 4;

% looping through each module
for k=1:nModule
    
    iModule = listModule(k);
    
    strModule = num2str(iModule, '%2d'); % module index as string
    strModuleTitleFigure = strrep(strTitleFigure, 'XX', strModule);
    
    for iOutput = 1:nOutput;

        % retrive an 2D black object from the SandBox
        blackObject = twoDBlackClass(...
            retrieve_two_d_black_model(iModule, iOutput, runStartMjd, runEndMjd));

        % call method to get the FFI
        [blackArrayAdu, blackArrayAduStd] = get_two_d_black(blackObject, runStartMjd);
        
        % gain array for 84 modouts
        gainObject = retrieve_gain_model(runStartMjd, runEndMjd);
        gainModout = gainObject.constants(1).array;
        % no gain uncertainty
        
        % bad pixels: not working
        %badPixelObject = retrieve_invalid_pixels_model(iModule, iOutput, runStartMjd, runEndMjd);
        
        % noise: 
        noiseObject = retrieve_read_noise_model(runStartMjd, runEndMjd);
        noiseModout = noiseObject.constants.array;
        
        % display black FFI images
        figure(1),      
        subplot(2, 2, iOutput), imagesc( blackArrayAdu ); 
        title(strrep(strModuleTitleFigure, 'YY', num2str(iOutput, '%2d') ) ); 
        colormap('default');
    end

    strOutput=num2str(iOutput, '%2d');   % output index as string
    
    fprintf('Module %2d\n', iModule);
    
    % waiting for user to respond or continuing after a short pause
    pause(0.5);
    
end