function print_gap_summary_all_pixels(pdqInputStruct, listOfModOuts)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function print_gap_summary_all_pixels(pdqInputStruct)
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

fid = fopen('PDQ_Pixels_Gap_Summary_by_Module_Output.txt', 'wt');

nCadences = length(pdqInputStruct.cadenceTimes);

mjds = pdqInputStruct.cadenceTimes;

utcStrings =  mjd_to_utc(mjds);
for iCadence = 1:nCadences

    modOutHeaderPrintedFlag = false;
    fprintf(fid, 'MJD:  %f  UTC: %s ',  mjds(iCadence), utcStrings(iCadence,:));
    fprintf('MJD:  %f  UTC: %s ',  mjds(iCadence), utcStrings(iCadence,:));
    for currentModOut = listOfModOuts
        
        % Initialize pixel tallys.
        nPixelsInMask = 0;
        nPixelsInGap = 0;
        nBkgdPixels = 0;
        nBkgdPixelsInGap = 0;
        nBlackPixels = 0;
        nBlackPixelsInGap = 0;
        nVsmearPixels = 0;
        nVsmearPixelsInGap = 0;
        nMsmearPixels = 0;
        nMsmearPixelsInGap = 0;
        
        
        j = currentModOut;

        [module, output] = convert_to_module_output(j);

        stellarIndex = find(stellarCcdModules == module & stellarCcdOutputs == output);

        if(isempty(stellarIndex))
            continue;
        end



        starsForThisModOut  = pdqInputStruct.stellarPdqTargets(stellarIndex);



        nPixelsInMask = 0;
        nPixelsInGap = 0;

        if(~isempty(stellarIndex))
            for k =1:length(stellarIndex)

                nPixelsInMask = nPixelsInMask + length(starsForThisModOut(k).referencePixels);

                refPixels  = starsForThisModOut(k).referencePixels;
                gapsForThisTarget = (cat(2, refPixels.gapIndicators))';

                nPixelsInGap = nPixelsInGap + sum(gapsForThisTarget(:,iCadence));
            end
        end



        bkgdIndex = find(bkgdCcdModules == module & bkgdCcdOutputs == output);

        if(~isempty(bkgdIndex))


            bkgdsForThisModOut       = pdqInputStruct.backgroundPdqTargets(bkgdIndex);

            nBkgdPixels = 0;
            nBkgdPixelsInGap = 0;

            for k =1:length(bkgdIndex)

                nBkgdPixels = nBkgdPixels + length(bkgdsForThisModOut(k).referencePixels);

                refPixels  = bkgdsForThisModOut(k).referencePixels;
                gapsForThisBkgd = (cat(2, refPixels.gapIndicators))';

                nBkgdPixelsInGap = nBkgdPixelsInGap + sum(gapsForThisBkgd(:,iCadence));

            end


        end

        collateralIndex = find(collateralCcdModules == module & collateralCcdOutputs == output);

        if(~isempty(collateralIndex))


            collateralsForThisModOut  = pdqInputStruct.collateralPdqTargets(collateralIndex);

            labels      = cat(1,collateralsForThisModOut.labels);
            blackIndices  = find(strcmp(labels, 'PDQ_BLACK_COLLATERAL'));

            nBlackPixels = 0;
            nBlackPixelsInGap = 0;

            if(~isempty( blackIndices))

                for k =1:length(blackIndices)


                    nBlackPixels = nBlackPixels + length(collateralsForThisModOut(blackIndices(k)).referencePixels);

                    refPixels  = collateralsForThisModOut(blackIndices(k)).referencePixels;
                    gapsForThisBlackTarget = (cat(2, refPixels.gapIndicators))';

                    nBlackPixelsInGap = nBlackPixelsInGap + sum(gapsForThisBlackTarget(:,iCadence));

                end

            end

            smearIndices  = find(strcmp(labels, 'PDQ_SMEAR_COLLATERAL'));


            if(~isempty( smearIndices))

                nVsmearPixels = 0;
                nVsmearPixelsInGap = 0;
                nMsmearPixels = 0;
                nMsmearPixelsInGap = 0;

                for k =1:length(smearIndices)

                    if(all(cat(1,collateralsForThisModOut(smearIndices(k)).referencePixels.row) > 1000))


                        nVsmearPixels = nVsmearPixels  + length(collateralsForThisModOut(smearIndices(k)).referencePixels);

                        refPixels  = collateralsForThisModOut(smearIndices(k)).referencePixels;
                        gapsForThisVsmearTarget = (cat(2, refPixels.gapIndicators))';

                        nVsmearPixelsInGap = nVsmearPixelsInGap + sum(gapsForThisVsmearTarget(:,iCadence));


                    else
                        nMsmearPixels = nMsmearPixels  + length(collateralsForThisModOut(smearIndices(k)).referencePixels);

                        refPixels  = collateralsForThisModOut(smearIndices(k)).referencePixels;
                        gapsForThisMsmearTarget = (cat(2, refPixels.gapIndicators))';

                        nMsmearPixelsInGap = nMsmearPixelsInGap + sum(gapsForThisMsmearTarget(:,iCadence));

                    end

                end
            end

        end % END: for currentModOut = listOfModOuts

        gapsForThisModOut = nPixelsInGap+nBkgdPixelsInGap+nBlackPixelsInGap+nVsmearPixelsInGap+nMsmearPixelsInGap;
        pixelsForThisModOut = nPixelsInMask+nBkgdPixels+nBlackPixels+nVsmearPixels+nMsmearPixels;


        % |-------  Mod/Out -----------|------------------ Pixel Type (gaps/total) ---------|
        % | Module | Output | Mod /Out |    All   |Stellar| Bkgd  | Black | Vsmear | Msmear |
        % |---------------------------------------------------------------------------------|
        % |    2   |    4   |     4   |  14/1640| 14/550|  0/ 25|  0/385|  0/340 |  0/340 |
        % |   3 |   1 |   5 |   5/1303|  5/398|  0/ 20|  0/315|  0/285 |  0/285 |
        % |   4 |   3 |  11 |  10/1660| 10/550|  0/ 25|  0/355|  0/365 |  0/365 |
        if(gapsForThisModOut > 0)
            if(~modOutHeaderPrintedFlag)

                fprintf(fid, '\n|-------  Mod/Out ----------|------------------- Pixel Type (gaps/total) --------|\n');
                fprintf(fid,   '| Module | Output | Mod/Out |    All   |Stellar| Bkgd  | Black | Vsmear | Msmear |\n');
                fprintf(fid,   '|--------------------------------------------------------------------------------|\n');

                fprintf(    '\n|-------  Mod/Out ----------|------------------ Pixel Type (gaps/total) ---------|\n');
                fprintf(      '| Module | Output | Mod/Out |    All   |Stellar| Bkgd  | Black | Vsmear | Msmear |\n');
                fprintf(      '|--------------------------------------------------------------------------------|\n');

                modOutHeaderPrintedFlag = true;
            end


            fprintf(fid, '|   %3d  |   %3d  |   %3d   |%4d/%4d |%3d/%3d|%3d/%3d|%3d/%3d|%3d/%3d |%3d/%3d |\n', ...
                module, output, currentModOut, gapsForThisModOut,pixelsForThisModOut, nPixelsInGap, nPixelsInMask,  nBkgdPixelsInGap, nBkgdPixels, nBlackPixelsInGap, nBlackPixels,...
                nVsmearPixelsInGap,nVsmearPixels, nMsmearPixelsInGap, nMsmearPixels);

            fprintf('|   %3d  |   %3d  |   %3d   |%4d/%4d |%3d/%3d|%3d/%3d|%3d/%3d|%3d/%3d |%3d/%3d |\n', ...
                module, output, currentModOut, gapsForThisModOut,pixelsForThisModOut, nPixelsInGap, nPixelsInMask,  nBkgdPixelsInGap, nBkgdPixels, nBlackPixelsInGap, nBlackPixels,...
                nVsmearPixelsInGap,nVsmearPixels, nMsmearPixelsInGap, nMsmearPixels);
        end


    end % modout loop
    if(~modOutHeaderPrintedFlag) % header was never printed because none of the mod/outs had any gaps

        fprintf(fid, 'No gaps on any mod/out\n' );
        fprintf('No gaps on any mod/out\n' );
    else
        fprintf(fid,   '|--------------------------------------------------------------------------------|\n\n');
        fprintf(       '|--------------------------------------------------------------------------------|\n\n');


    end


end % cadence loop

fprintf( '\n\n');
fclose(fid);
return;



