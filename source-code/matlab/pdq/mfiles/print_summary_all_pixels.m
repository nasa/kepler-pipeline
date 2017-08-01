function print_summary_all_pixels(pdqInputStruct, listOfModOuts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function print_summary_all_pixels(pdqInputStruct)
%
% This script plots stellar pixels, background pixels, and collateral
% pixels on each mod out and provides a visual check of the data (this is
% more useful when ETEM2 parameters, data are still in flux)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


% ccd = zeros(1070,1132);
% for j =106:112,
%     rows = cat(1,s.stellarPdqTargets(j).referencePixels.row);
%     cols = cat(1,s.stellarPdqTargets(j).referencePixels.column);
%     vals = cat(2,s.stellarPdqTargets(j).referencePixels.timeSeries);
%     vals = vals';
%
%     % convert to linear index
%
%     index = sub2ind(size(ccd), rows,cols);
%
%     ccd(index) = vals(:,1);
% end;
% imagesc(ccd, [1.8e5 4e5]);
% colormap('hot')



stellarCcdModules =cat(1,pdqInputStruct.stellarPdqTargets.ccdModule);
stellarCcdOutputs =cat(1,pdqInputStruct.stellarPdqTargets.ccdOutput);

bkgdCcdModules =cat(1,pdqInputStruct.backgroundPdqTargets.ccdModule);
bkgdCcdOutputs =cat(1,pdqInputStruct.backgroundPdqTargets.ccdOutput);

collateralCcdModules =cat(1,pdqInputStruct.collateralPdqTargets.ccdModule);
collateralCcdOutputs =cat(1,pdqInputStruct.collateralPdqTargets.ccdOutput);


if(~exist('listOfModOuts', 'var'))
    listOfModOuts = (1:84);
end


% plot one modout at a time

fid = fopen('PDQ_Pixels_Summary_by_Module_Output.txt', 'wt');

for currentModOut = listOfModOuts

    j = currentModOut;

    [module, output] = convert_to_module_output(j);

    stellarIndex = find(stellarCcdModules == module & stellarCcdOutputs == output);

    if(isempty(stellarIndex))
        continue;
    end

    fprintf(fid, '|----------------------------------------------------------------------------|\n');
    fprintf(fid, '| Module = %2d        Output = %2d          ModOut = %2d                        |\n', module, output, currentModOut);
    fprintf(fid, '|----------------------------------------------------------------------------|\n');


    fprintf( '|----------------------------------------------------------------------------|\n');
    fprintf( '| Module = %2d        Output = %2d          ModOut = %2d                        |\n', module, output, currentModOut);
    fprintf( '|----------------------------------------------------------------------------|\n');

    if(~isempty(stellarIndex))

        fprintf(fid, '|.........................STELLAR TARGETS....................................|\n');
        fprintf(fid, '| Star Magnitude |  Kepler Id  |   Pixels in Mask   |   in Optimal Aperture  |\n');

        fprintf( '|.........................STELLAR TARGETS....................................|\n');
        fprintf( '| Star Magnitude |  Kepler Id  |   Pixels in Mask   |   in Optimal Aperture  |\n');


        starsForThisModOut      = pdqInputStruct.stellarPdqTargets(stellarIndex);

        for k =1:length(stellarIndex)

            pixelsInMask = length(starsForThisModOut(k).referencePixels);
            pixelsInOptimalAperture = sum(cat(1,starsForThisModOut(k).referencePixels.isInOptimalAperture));

            fprintf(fid, '|      %5.2f     | %10d  |       %4d         |         %4d           |\n', ...
                starsForThisModOut(k).keplerMag, starsForThisModOut(k).keplerId, pixelsInMask, pixelsInOptimalAperture);

            fprintf('|      %5.2f     | %10d  |       %4d         |         %4d           |\n',...
                starsForThisModOut(k).keplerMag, starsForThisModOut(k).keplerId, pixelsInMask, pixelsInOptimalAperture);
        end
    end

    bkgdIndex = find(bkgdCcdModules == module & bkgdCcdOutputs == output);

    if(~isempty(bkgdIndex))


        bkgdsForThisModOut       = pdqInputStruct.backgroundPdqTargets(bkgdIndex);

        bkgdPixels = 0;

        for k =1:length(bkgdIndex)
            bkgdPixels = bkgdPixels + length(bkgdsForThisModOut(k).referencePixels);
        end

        fprintf(fid, '|.........................BACKGROUND TARGETS.................................|\n');
        fprintf(fid, '|    Total number of background pixels = %d                                  |\n', bkgdPixels);

        fprintf('|.........................BACKGROUND TARGETS.................................|\n');
        fprintf('|    Total number of background pixels = %d                                  |\n', bkgdPixels);

    end

    collateralIndex = find(collateralCcdModules == module & collateralCcdOutputs == output);

    if(~isempty(collateralIndex))

        fprintf(fid, '|.........................COLLATERAL TARGETS.................................|\n');
        fprintf( '|.........................COLLATERAL TARGETS.................................|\n');

        collateralsForThisModOut  = pdqInputStruct.collateralPdqTargets(collateralIndex);

        labels      = cat(1,collateralsForThisModOut.labels);
        blackIndices  = find(strcmp(labels, 'PDQ_BLACK_COLLATERAL'));


        if(~isempty( blackIndices))

            blackPixels = 0;
            for k =1:length(blackIndices)

                blackPixels = blackPixels + length( collateralsForThisModOut(blackIndices(k)).referencePixels);
            end

            fprintf(fid, '|    Total number of black collateral pixels = %d                           |\n', blackPixels);
            fprintf('|    Total number of black collateral pixels = %d                           |\n', blackPixels);
        end

        smearIndices  = find(strcmp(labels, 'PDQ_SMEAR_COLLATERAL'));


        if(~isempty( smearIndices))

            vsmearPixels = 0;
            msmearPixels = 0;

            for k =1:length(smearIndices)
                if(all(cat(1,collateralsForThisModOut(smearIndices(k)).referencePixels.row) > 1000))
                    vsmearPixels = vsmearPixels + length( collateralsForThisModOut(smearIndices(k)).referencePixels);

                else
                    msmearPixels = msmearPixels + length( collateralsForThisModOut(smearIndices(k)).referencePixels);

                end

            end
            fprintf(fid, '|    Total number of virtual smear collateral pixels = %d                   |\n', vsmearPixels);
            fprintf('|    Total number of virtual smear collateral pixels = %d                   |\n', vsmearPixels);
            fprintf(fid, '|    Total number of masked smear collateral pixels = %d                    |\n', msmearPixels);
            fprintf('|    Total number of masked smear collateral pixels = %d                    |\n', msmearPixels);
        end

    end

end
fprintf( '|----------------------------------------------------------------------------|\n');
fprintf( fid, '|----------------------------------------------------------------------------|\n');

fprintf( '\n\n');
fclose(fid);
return;



