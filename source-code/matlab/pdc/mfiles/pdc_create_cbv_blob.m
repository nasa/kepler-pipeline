
%%====================================================================================================
%%====================================================================================================
%%====================================================================================================
% function [] = pdc_create_cbv_blob (mapResultsObjectCoarse, shortmsMapResultsCell, mapresultsObjectNoBands, spsdBlob, pdcInputObject, ...
%                               gapFilledCadenceMidTimestamps, cbvBlobFileName, pdcBlobFileName )
%
% Creates and saves a blob for use by DV to do it's own cotrending with the MAP basis vectors.
%
% Also used by PDC to force MAP to use specific basis vector and prior PDFs.
%
% Inputs:
%   shortMapResultsStruct_Coarse  -- [shortMapResultsStruct] shortMapResultsStruct from coarse run, if [] then load from file
%   shortmsMapResultsCell      -- [cell array] cell array of mapResultsObject for each band
%   shortMapResultsStruct_no_BS -- [mapResultsObject] mapResultsObject from non-band-split run
%   spsdBlob                -- [spsdBlobStruct] for use with short cadence
%   pdcInputObject          -- [pdcInputClass] PDC inputs for ccdModule, configuration structs etc...
%   gapFilledCadenceMidTimestamps -- [float array] cadence mid-times with gaps filled via pdc_fill_gaps
%   cbvBlobFileName         -- [char] file name for blob
%   pdcBlobFileName         -- [char] file name for short cadence blob
%
% Outputs:
%   cbvBlobStruct saved to file (not returned) containing:
%      ccdModule                -- [char]
%      ccdOutput                -- [char]
%      mapFailedCoarse          -- [Logical]
%      mapFailedNoBands         -- [Logical]
%      mapFailedBandSplit       -- [Logical]
%      basisVectorsCoarse       -- [nCadences x nBasisVectors] From the coarse run
%      basisVectorsNoBands      -- [nCadences x nBasisVectors] From the final (nonbanded) run
%      basisVectorsBandSplit    -- [cell{nBands} nCadences x nBasisVectors] if empty then no bandsplitting run performed
%                                       Otherwise filled with basis vectors for each band
%      lesserBasisVectorsCoarse       -- [nCadences x nBasisVectors] These are the next set of singular vectors after the basis vectors used in MAP
%      lesserBasisVectorsNoBands      -- [nCadences x nBasisVectors]
%      lesserBasisVectorsBandSplit    -- [cell{nBands} nCadences x nBasisVectors] if empty then no bandsplitting run performed
%                                       Otherwise filled with basis vectors for each band
%      diagSCoarse                    -- [nSingularValues] the whole set of singular vectors from SVD
%      diagSNoBands                   -- [nSingularValues] the whole set of singular vectors from SVD
%      diagSBandSplit                 -- [nSingularValues] the whole set of singular vectors from SVD
%      robustFitCoefficientsCoarse    -- [nBasisVectors x nTargets]
%      robustFitCoefficientsNoBands   -- [nBasisVectors x nTargets]
%      robustFitCoefficientsBandSplit' -- [cell{nBands} nBasisVectors x nTargets] if empty then no bandsplitting run performed
%      priorPdfInfoCoarse       -- [struct] cintains prior PDF information
%      priorPdfInfoNoBands      -- [struct] cintains prior PDF information
%      priorPdfInfoBandSplit    -- [struct] cintains prior PDF information
%      startTimestamp           -- based on gapFilledCadenceMidTimeStamps
%      endTimestamp             -- based on gapFilledCadenceMidTimeStamps
%      startCadence             --
%      endCadence               --
%      gapFilledCadenceMidTimeStamps -- [float array]  cadence mid-times with gaps filled via pdc_fill_gaps
%      svdOrder                 -- [int array] First entry for non-band-split the rest for the bands
%      svdMaxOrder              -- [int array] First entry for non-band-split the rest for the bands
%      svdOrderForReducedRobustFit -- [int array] First entry for non-band-split the rest for the bands
%       
%
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

function [] = pdc_create_cbv_blob (shortMapResultsStruct_Coarse, shortmsMapResultsCell, shortMapResultsStruct_no_BS, spsdBlob, pdcInputObject, ...
                                    gapFilledCadenceMidTimestamps, cbvBlobFileName, pdcBlobFileName )

% We want to save the lesser singular vectors after the main basis vectors. How many do we save in total (greater+lesser)?
nLesserBasisVectors = 16;

%*********************************************
% Save blob file for SC
% Use regular MAP mapBlobStruct
blobStruct = struct ('mapBlobStruct', shortMapResultsStruct_no_BS.mapBlobStruct, ...
                     'spsdBlobStruct', spsdBlob );
save_struct_as_blob(blobStruct, pdcBlobFileName);
%*********************************************


% The Prior PDF information is a seperate struct for each target so collect these structs
% If mapFailed then there is no priorPdfInfo or robustFitCoefficients so just pass empty sets
nTargets = length(shortMapResultsStruct_no_BS.intermediateMapResults);
priorPdfInfoNoBands.priorPdfInfoArray = repmat(struct('priorPdfInfo', []), [nTargets, 1]);
priorPdfInfoCoarse.priorPdfInfoArray  = repmat(struct('priorPdfInfo', []), [nTargets, 1]);
if (~shortMapResultsStruct_no_BS.mapFailed)
    for iTarget = 1 : nTargets
        priorPdfInfoNoBands.priorPdfInfoArray(iTarget).priorPdfInfo = ...
                shortMapResultsStruct_no_BS.intermediateMapResults(iTarget).priorPdfInfo;
        priorPdfInfoCoarse.priorPdfInfoArray(iTarget).priorPdfInfo = ...
                shortMapResultsStruct_Coarse.intermediateMapResults(iTarget).priorPdfInfo;
    end
else
    for iTarget = 1 : nTargets
        priorPdfInfoNoBands.priorPdfInfoArray(iTarget).priorPdfInfo = [];
        priorPdfInfoCoarse.priorPdfInfoArray(iTarget).priorPdfInfo = [];
    end
end
mapFailedCoarse  = shortMapResultsStruct_Coarse.mapFailed;
mapFailedNoBands = shortMapResultsStruct_no_BS.mapFailed;

% Combine the band-split cbvs
% If band splitting not performed then empty set for basisVectorsBandSplit and robustFitCoefficientsBandSplit
if (pdcInputObject.pdcModuleParameters.bandSplittingEnabled && ~isempty(shortmsMapResultsCell))
    nBands = length(shortmsMapResultsCell);
    diagSBandSplit = repmat(struct('diagS', []), [nBands,1]);
    basisVectorsBandSplit = repmat(struct('basisVectors', []), [nBands,1]);
    lesserBasisVectorsBandSplit = repmat(struct('lesserBasisVectors', []), [nBands,1]);
    robustFitCoefficientsBandSplit =  repmat(struct('coeffs', []), [nBands,1]);
    priorPdfInfoBandSplit = repmat(struct('priorPdfInfoArray', []), [nBands,1]);
    for iBand = 1 : nBands
        diagSBandSplit(iBand).basisVectors = shortmsMapResultsCell{iBand}.diagS;
        basisVectorsBandSplit(iBand).basisVectors = shortmsMapResultsCell{iBand}.basisVectors;
        robustFitCoefficientsBandSplit(iBand).coeffs = ...
            [shortmsMapResultsCell{iBand}.intermediateMapResults.robustFitCoefficients];

        % Collect the prior PDF information which is a seperate struct for each target
        nTargets = length(shortmsMapResultsCell{iBand}.intermediateMapResults);
        priorPdfInfoBandSplit(iBand).priorPdfInfoArray = repmat(struct('priorPdfInfo', []), [nTargets, 1]);
        if (~shortmsMapResultsCell{iBand}.mapFailed)
            for iTarget = 1 : nTargets
                priorPdfInfoBandSplit(iBand).priorPdfInfoArray(iTarget).priorPdfInfo = ...
                        shortmsMapResultsCell{iBand}.intermediateMapResults(iTarget).priorPdfInfo;
            end
            if (~isempty(shortmsMapResultsCell{iBand}.uMatrix))
                lesserBasisVectorsBandSplit(iBand).lesserBasisVectors = ...
                    shortmsMapResultsCell{iBand}.uMatrix(:,length(shortmsMapResultsCell{iBand}.basisVectors(1,:))+1: ...
                                                min(length(shortmsMapResultsCell{iBand}.uMatrix(1,:)), nLesserBasisVectors));
            else
                lesserBasisVectorsBandSplit(iBand).lesserBasisVectors = [];
            end
        else
            for iTarget = 1 : nTargets
                priorPdfInfoBandSplit(iBand).priorPdfInfoArray(iTarget).priorPdfInfo = [];
            end
        end
        mapFailedBandSplit(iBand) = shortmsMapResultsCell{iBand}.mapFailed;
    end
else
    diagSBandSplit = [];
    basisVectorsBandSplit = [];
    lesserBasisVectorsBandSplit = [];
    robustFitCoefficientsBandSplit = [];
    priorPdfInfoBandSplit = [];
    mapFailedBandSplit = [];
end

if (~isempty(shortMapResultsStruct_Coarse.uMatrix))
    lesserBasisVectorsCoarse = shortMapResultsStruct_Coarse.uMatrix(:,length(shortMapResultsStruct_Coarse.basisVectors(1,:))+1: ...
                                                    min(length(shortMapResultsStruct_Coarse.uMatrix(1,:)), nLesserBasisVectors));
else
    lesserBasisVectorsCoarse  = [];
end

if (~isempty(shortMapResultsStruct_no_BS.uMatrix))
    lesserBasisVectorsNoBands = shortMapResultsStruct_no_BS.uMatrix(:,length(shortMapResultsStruct_no_BS.basisVectors(1,:))+1: ...
                                                    min(length(shortMapResultsStruct_no_BS.uMatrix(1,:)), nLesserBasisVectors));
else
    lesserBasisVectorsNoBands = [];
end

cbvBlobStruct = struct( 'ccdModule',           pdcInputObject.ccdModule, ...
                        'ccdOutput',           pdcInputObject.ccdOutput, ...
                        'mapFailedCoarse',     mapFailedCoarse, ...
                        'mapFailedNoBands',    mapFailedNoBands, ...
                        'mapFailedBandSplit',  mapFailedBandSplit, ...
                        'diagSCoarse',         shortMapResultsStruct_Coarse.diagS, ...
                        'diagSNoBands',        shortMapResultsStruct_no_BS.diagS, ...
                        'basisVectorsCoarse',  shortMapResultsStruct_Coarse.basisVectors, ...
                        'lesserBasisVectorsCoarse', lesserBasisVectorsCoarse, ...
                        'basisVectorsNoBands', shortMapResultsStruct_no_BS.basisVectors, ...
                        'lesserBasisVectorsNoBands', lesserBasisVectorsNoBands, ...
                        'basisVectorsBandSplit', basisVectorsBandSplit, ...
                        'diagSBandSplit',       diagSBandSplit, ...
                        'lesserBasisVectorsBandSplit', lesserBasisVectorsBandSplit, ...
                        'robustFitCoefficientsCoarse',  [shortMapResultsStruct_Coarse.intermediateMapResults.robustFitCoefficients], ...
                        'robustFitCoefficientsNoBands', [shortMapResultsStruct_no_BS.intermediateMapResults.robustFitCoefficients], ...
                        'robustFitCoefficientsBandSplit' ,robustFitCoefficientsBandSplit, ...
                        'priorPdfInfoCoarse',     priorPdfInfoCoarse, ...
                        'priorPdfInfoNoBands',    priorPdfInfoNoBands, ...
                        'priorPdfInfoBandSplit',  priorPdfInfoBandSplit, ...
                        'bandSplittingConfigurationStruct', pdcInputObject.bandSplittingConfigurationStruct, ...
                        'startTimestamp',        gapFilledCadenceMidTimestamps(1), ...
                        'endTimestamp',          gapFilledCadenceMidTimestamps(end), ...
                        'startCadence',         pdcInputObject.startCadence, ...
                        'endCadence',           pdcInputObject.endCadence, ...
                        'gapFilledCadenceMidTimeStamps', gapFilledCadenceMidTimestamps, ...
                        'svdOrder',            pdcInputObject.mapConfigurationStruct.svdOrder, ...
                        'svdMaxOrder',         pdcInputObject.mapConfigurationStruct.svdMaxOrder, ...
                        'svdOrderForReducedRobustFit', pdcInputObject.mapConfigurationStruct.svdOrderForReducedRobustFit);
                        
save_struct_as_blob(cbvBlobStruct, cbvBlobFileName);

end

