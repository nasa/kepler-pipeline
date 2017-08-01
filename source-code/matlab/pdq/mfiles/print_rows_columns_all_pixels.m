function print_rows_columns_all_pixels(pdqInputStruct, listOfModOuts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function print_rows_columns_all_pixels(pdqInputStruct)
%
% This script plots stellar pixels, background pixels, and collateral
% pixels on each mod out and provides a visual check of the data (this is
% more useful when ETEM2 parameters, data are still in flux)
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

% useful for EEIS data
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

fid = fopen('PDQ_Pixels_Rows_Columns_by_Module_Output.txt', 'wt');

for currentModOut = listOfModOuts

    j = currentModOut;

    [module, output] = convert_to_module_output(j);

    stellarIndex = find(stellarCcdModules == module & stellarCcdOutputs == output);

    if(isempty(stellarIndex))
        continue;
    end
    fprintf(fid, '|____________________________________________________________________________|\n');

    fprintf(fid, '|                                                                            |\n');
    fprintf(fid, '| Module = %2d        Output = %2d          ModOut = %2d                        |\n', module, output, currentModOut);
    fprintf(fid, '|____________________________________________________________________________|\n');


    fprintf('|____________________________________________________________________________|\n');
    fprintf( '|                                                                            |\n');
    fprintf( '| Module = %2d        Output = %2d          ModOut = %2d                        |\n', module, output, currentModOut);
    fprintf('|____________________________________________________________________________|\n');

    if(~isempty(stellarIndex))

        fprintf(fid, '|.........................STELLAR TARGETS....................................|\n');
        fprintf(fid, '|                                                                            |\n');

        fprintf( '|.........................STELLAR TARGETS....................................|\n');
        fprintf( '|                                                                            |\n');


        starsForThisModOut      = pdqInputStruct.stellarPdqTargets(stellarIndex);

        for k =1:length(stellarIndex)

            pixelsInMask = length(starsForThisModOut(k).referencePixels);
            pixelsInOptimalAperture = sum(cat(1,starsForThisModOut(k).referencePixels.isInOptimalAperture));

            targetRows = cat(1,starsForThisModOut(k).referencePixels.row);
            targetColumns = cat(1,starsForThisModOut(k).referencePixels.column);


            fprintf(fid, '| Star Magnitude |  Kepler Id  |   Pixels in Mask   |   in Optimal Aperture  |\n');
            fprintf( '| Star Magnitude |  Kepler Id  |   Pixels in Mask   |   in Optimal Aperture  |\n');
            fprintf(fid, '|      %5.2f     | %10d  |       %4d         |         %4d           |\n', ...
                starsForThisModOut(k).keplerMag, starsForThisModOut(k).keplerId, pixelsInMask, pixelsInOptimalAperture);

            fprintf('|      %5.2f     | %10d  |       %4d         |         %4d           |\n',...
                starsForThisModOut(k).keplerMag, starsForThisModOut(k).keplerId, pixelsInMask, pixelsInOptimalAperture);

            fprintf( fid,'|----------------------------------------------------------------------------|\n');
            fprintf( '|----------------------------------------------------------------------------|\n');

            fprintf(fid, '%4d\t', targetRows);
            fprintf('%4d\t', targetRows);
            fprintf( '\n');
            fprintf(fid, '\n');

            fprintf(fid, '%4d\t', targetColumns);
            fprintf('%4d\t', targetColumns);
            fprintf( '\n');
            fprintf(fid, '\n');

            fprintf( fid,'|----------------------------------------------------------------------------|\n');
            fprintf( '|----------------------------------------------------------------------------|\n');

        end
    end

    bkgdIndex = find(bkgdCcdModules == module & bkgdCcdOutputs == output);

    if(~isempty(bkgdIndex))


        bkgdsForThisModOut       = pdqInputStruct.backgroundPdqTargets(bkgdIndex);

        bkgdPixels = 0;

        for k =1:length(bkgdIndex)
            bkgdPixels = bkgdPixels + length(bkgdsForThisModOut(k).referencePixels);
        end

        fprintf(fid, '|                                                                            |\n');
        fprintf(fid, '|.........................BACKGROUND TARGETS.................................|\n');
        fprintf(fid, '|    Total number of background pixels = %d                                  |\n', bkgdPixels);

        fprintf('|                                                                            |\n');
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

            smearPixels = 0;
            for k =1:length(smearIndices)

                smearPixels = smearPixels + length( collateralsForThisModOut(smearIndices(k)).referencePixels);
            end
            fprintf(fid, '|    Total number of smear collateral pixels = %d                           |\n', smearPixels);
            fprintf('|    Total number of smear collateral pixels = %d                           |\n', smearPixels);
        end

    end

end
fprintf( '|----------------------------------------------------------------------------|\n');
fprintf( fid, '|----------------------------------------------------------------------------|\n');

fprintf( '\n\n');
fclose(fid);
return;



