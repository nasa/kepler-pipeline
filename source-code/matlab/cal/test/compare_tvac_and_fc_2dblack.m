function compare_tvac_and_fc_2dblack(channel)
% function compare_tvac_and_fc_2dblack(channel)
%
% function to display and compare the 2D black arrays from raw TVAC ground
% test data and those stored in the FC model database
%
% INPUTS:
% channel    array of module/outputs (if not supplied, defaults to 1-84)
%
%
% OUTPUTS:
% figures can be saved to disk by enabling the plotToFileFlag
%
% **note this function should be run in directory with data:
%   /path/to/matlab/bart/ORT4b/TVAC/post-BZ1170-correction
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

%temp
plotToFileFlag = false;

if nargin == 0
    channel = 1:84;
end

aveDifference = zeros(length(channel));

for i = 1:length(channel)

    [ccdModule ccdOutput] = convert_to_module_output(channel(i));

    %--------------------------------------------------------------------------
    % load 2D black from TVAC ground tests
    %--------------------------------------------------------------------------
    twoDBlack_tvac_filename = ['twoDBlack_' num2str(channel(i))];
    load(twoDBlack_tvac_filename)

    twoDBlack_TVAC          = twoDBlack.blacks;
    %twoDBlackUncert_TVAC    = twoDBlack.deltaBlacks;

    %--------------------------------------------------------------------------
    % load 2D black model from FC
    %--------------------------------------------------------------------------
    twoDBlack_fc_filename = ['FC_twoDBlack_' num2str(channel(i))];
    load(twoDBlack_fc_filename)

    %[twoDBlack_FC twoDBlackUncert_FC] = extract_2d_black_array(ccdModule, ccdOutput);
    % save 2D black FC models
    % save(['FC_twoDBlack_' num2str(i) '.mat'], 'twoDBlack_FC');
    % save(['FC_twoDBlackUncert_' num2str(i) '.mat'], 'twoDBlackUncert_FC');

    figure
    imagesc(twoDBlack_FC - twoDBlack_TVAC)
    colorbar
    title(['FC minus TVAC 2D Black Data for mod ' num2str(ccdModule) ' out ' num2str(ccdOutput)]);
    xlabel('CCD Column Index');
    ylabel('CCD Row Index');

    aveDifference(i) = median(mean(twoDBlack_FC - twoDBlack_TVAC));

    [cmin cmax] = caxis;
    display(['The [min, max] of 2Dblack difference is ' mat2str([cmin cmax]) ', max diff = ' num2str(cmax-cmin) ', and median = ' num2str(aveDifference(i))]);
    caxis([-10 20])


    if plotToFileFlag
        fileNameStr = [ 'fc_minus_tvac_2dblack_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];
        paperOrientationFlag = false;
        includeTimeFlag = false;
        printJpgFlag = false;
        plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    end





    %     %--------------------------------------------------------------------------
    %     % show images of both side-by-side
    %     %--------------------------------------------------------------------------
    %     bdwidth = 5;
    %     topbdwidth = 5;
    %
    %     set(0,'Units','pixels')
    %     scnsize = get(0,'ScreenSize');
    %
    %     %     % use these positions for double screens
    %     %     position1  = [bdwidth,...
    %     %         2/3*scnsize(4) + bdwidth,...
    %     %         scnsize(3)/4 - 2*bdwidth,...
    %     %         scnsize(4)/1.5 - (topbdwidth + bdwidth)];
    %     %     position2 = [position1(1) + scnsize(3)/4,...
    %     %         position1(2),...
    %     %         position1(3),...
    %     %         position1(4)];
    %
    %     % use these positions for single screen
    %     position1  = [bdwidth,...
    %         2/3*scnsize(4) + bdwidth,...
    %         scnsize(3)/2 - 2*bdwidth,...
    %         scnsize(4)/1.5 - (topbdwidth + bdwidth)];
    %     position2 = [position1(1) + scnsize(3)/2,...
    %         position1(2),...
    %         position1(3),...
    %         position1(4)];
    %
    %
    %     figure('Position', position1)
    %     imagesc(twoDBlack_TVAC)
    %     colorbar
    %     title(['TVAC 2D Black for mod ' num2str(ccdModule) ' out ' num2str(ccdOutput)]);
    %     xlabel('CCD Column Index');
    %     ylabel('CCD Row Index');
    %
    %     if plotToFileFlag
    %         fileNameStr = [ 'tvac_fc_2dblack_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];
    %         paperOrientationFlag = false;
    %         includeTimeFlag = false;
    %         printJpgFlag = false;
    %         plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    %     end
    %
    %     figure('Position', position2)
    %     imagesc(twoDBlack_FC)
    %     colorbar
    %     title(['FC 2D Black for mod ' num2str(ccdModule) ' out ' num2str(ccdOutput)]);
    %     xlabel('CCD Column Index');
    %     ylabel('CCD Row Index');
    %
    %     if plotToFileFlag
    %         fileNameStr = [ 'fc_2dblack_mod'  num2str(ccdModule) '_out' num2str(ccdOutput) ];
    %         paperOrientationFlag = false;
    %         includeTimeFlag = false;
    %         printJpgFlag = false;
    %         plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    %     end

    pause

    close all
    %clear twoDBlack_TVAC twoDBlackUncert_TVAC twoDBlack_FC twoDBlackUncert_FC

end

figure;
plot(channel, aveDifference, 'x')
title('Average Value of 2D black (FC - TVAC) difference per Mod/Out');
xlabel('CCD Channel Index');
ylabel('Mean of 2Dblack diff');



return;
