function overlay_pdq_targets_on_coa_image()



%targetLists = retrieve_target_list_sets;
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


for currentModOut = 1:84

    [module, output] = convert_to_module_output(currentModOut);

    tadStruct = retrieve_tad(module, output,'a-rp-v2');


    sFileName = ['pdqTempStruct_' num2str(currentModOut) '.mat'];

    % check to see the existence ofthe .mat file

    if(~exist(sFileName, 'file'))
        continue;
    end

    load(sFileName, 'pdqTempStruct');

    ccdModule = pdqTempStruct.ccdModule;
    ccdOutput = pdqTempStruct.ccdOutput;
    currentModOut = pdqTempStruct.currentModOut;

    brows = pdqTempStruct.bkgdPixelRows;
    bcols = pdqTempStruct.bkgdPixelColumns;
    %%
    colormap hot;
    imagesc(tadStruct.coaImage,[min(min(tadStruct.coaImage)),max(max(tadStruct.coaImage))/50]);
    axis ij
    hold on


    hh = plot(bcols,brows,'go');

    trows = pdqTempStruct.targetPixelRows;
    tcols = pdqTempStruct.targetPixelColumns;

    hh = plot(bcols,brows,'go');
    hht = plot(tcols,trows,'m.','markersize',6);


    isInOpt = pdqTempStruct.isInOptimalAperture;

    hhtinopt = plot(tcols(isInOpt)+.1,trows(isInOpt)+.1,'bp','markersize',6);

    fileNameStr = ['PDQ targets ovelaid on COA image for module '  num2str(ccdModule) ' output ' num2str(ccdOutput) ' modout ' num2str(currentModOut)];
    title(fileNameStr);
    paperOrientationFlag = false;
    includeTimeFlag = false;
    printJpgFlag = false;
    fileNameStr = ['pdq_targets_pixels_overlaid_on_coa_image_for_module_'  num2str(ccdModule) '_output_' num2str(ccdOutput) '_modout_' num2str( currentModOut) ];
    %%
    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    close all;




end