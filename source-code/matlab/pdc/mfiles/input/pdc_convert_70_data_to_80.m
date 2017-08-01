%% pdc_convert_70_data_to_80
%
% function [pdcInputStruct] = pdc_convert_70_data_to_80(pdcInputStruct)
%
% Update 7.0-era PDC input structures to 8.0. This is useful when testing
% with existing data sets.
%%
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

function [pdcInputStruct] = pdc_convert_70_data_to_80(pdcInputStruct)

% First call all previous conversion files
% Theses should iteratively call each other on down
[pdcInputStruct] = pdc_convert_62_data_to_70(pdcInputStruct);

if ~isfield(pdcInputStruct.pdcModuleParameters,'mapEnabled')
    pdcInputStruct.pdcModuleParameters.mapEnabled  = false;
end % if

if ~isfield(pdcInputStruct.pdcModuleParameters,'harmonicsRemovalEnabled')
    pdcInputStruct.pdcModuleParameters.harmonicsRemovalEnabled  = false;
end % if

if ~isfield(pdcInputStruct.pdcModuleParameters,'preMapIterations')
    pdcInputStruct.pdcModuleParameters.preMapIterations  = 2;
end % if

if ~isfield(pdcInputStruct,'mapConfigurationStruct')
    % these are the correct default values, according to JCS (06/24/2011)
    pdcInputStruct.mapConfigurationStruct.fractionOfStarsToUseForSvd         = 0.5;
    pdcInputStruct.mapConfigurationStruct.useOnlyQuietStarsForSvd            = true;
    pdcInputStruct.mapConfigurationStruct.fractionOfStarsToUseForPriorPdf    = 1.0;
    pdcInputStruct.mapConfigurationStruct.useOnlyQuietStarsForPriorPdf       = true;
    pdcInputStruct.mapConfigurationStruct.numPointsForMaximizerFirstGuess    = 100;
    pdcInputStruct.mapConfigurationStruct.maxNumMaximizerIteration           = 10;
    pdcInputStruct.mapConfigurationStruct.maxTolerance                       = 1e-4;
    pdcInputStruct.mapConfigurationStruct.randomStreamSeed                   = int8(1);
    pdcInputStruct.mapConfigurationStruct.svdOrder                           = 8;
    pdcInputStruct.mapConfigurationStruct.svdOrderForReducedRobustFit        = 4;
    pdcInputStruct.mapConfigurationStruct.ditherFlux                         = true;
    pdcInputStruct.mapConfigurationStruct.ditherMagnitude                    = 0.05;
    pdcInputStruct.mapConfigurationStruct.variabilityCutoff                  = 1.3;
    pdcInputStruct.mapConfigurationStruct.coarseDetrendPolyOrder             = 3;
    pdcInputStruct.mapConfigurationStruct.priorPdfVariabilityWeight          = 2.0;
    pdcInputStruct.mapConfigurationStruct.priorPdfGoodnessWeight             = 1.0;
    pdcInputStruct.mapConfigurationStruct.priorWeightGoodnessCutoff          = 0.01;
    pdcInputStruct.mapConfigurationStruct.priorWeightVariabilityCutoff       = 0.5;
    pdcInputStruct.mapConfigurationStruct.priorGoodnessScalingFactor         = 10.0;
    pdcInputStruct.mapConfigurationStruct.priorGoodnessPowerFactor           = 3.0;
    pdcInputStruct.mapConfigurationStruct.priorKeplerMagnitudeScalingFactor  = 2.0;
    pdcInputStruct.mapConfigurationStruct.priorRaScalingFactor               = 1.0;
    pdcInputStruct.mapConfigurationStruct.priorDecScalingFactor              = 1.0;
    pdcInputStruct.mapConfigurationStruct.debugRun                           = false;
end % if

if ~isfield(pdcInputStruct,'spsdDetectorConfigurationStruct')
    % these are the correct default values, according to RM and JK (05/12/2011)
    pdcInputStruct.spsdDetectorConfigurationStruct.mode                  = 1;
    pdcInputStruct.spsdDetectorConfigurationStruct.windowWidth           = 193;
    pdcInputStruct.spsdDetectorConfigurationStruct.sgPolyOrder           = 3;
    pdcInputStruct.spsdDetectorConfigurationStruct.sgStepPolyOrder       = 2;
    pdcInputStruct.spsdDetectorConfigurationStruct.minWindowWidth        = 9;
    pdcInputStruct.spsdDetectorConfigurationStruct.shortWindowWidth      = 11;
    pdcInputStruct.spsdDetectorConfigurationStruct.shortSgPolyOrder      = 1;
    pdcInputStruct.spsdDetectorConfigurationStruct.shortSgStepPolyOrder  = 1;
end % if

if ~isfield(pdcInputStruct,'spsdDetectionConfigurationStruct')
    % these are the correct default values, according to RM and JK (05/12/2011)
    pdcInputStruct.spsdDetectionConfigurationStruct.falsePositiveRateLimit           = 0.005;
    pdcInputStruct.spsdDetectionConfigurationStruct.transitSpsdMinmaxDiscriminator   = 0.7;
    pdcInputStruct.spsdDetectionConfigurationStruct.discontinuityRatioTolerance      = 0.7;
    pdcInputStruct.spsdDetectionConfigurationStruct.validationSignificanceThreshold  = 3;
    pdcInputStruct.spsdDetectionConfigurationStruct.endpointFitWindowWidth           = 48;
    pdcInputStruct.spsdDetectionConfigurationStruct.useCentroids                     = false;
end % if

if ~isfield(pdcInputStruct,'spsdRemovalConfigurationStruct')
    % these are the correct default values, according to RM and JK (05/12/2011)
    pdcInputStruct.spsdRemovalConfigurationStruct.polyWindowHalfWidth        = 480;
    pdcInputStruct.spsdRemovalConfigurationStruct.recoveryWindowWidth        = 240;
    pdcInputStruct.spsdRemovalConfigurationStruct.bigPicturePolyOrder        = 6;
    pdcInputStruct.spsdRemovalConfigurationStruct.logTimeConstantStartValue  = -2;
    pdcInputStruct.spsdRemovalConfigurationStruct.logTimeConstantIncrement   = 1;
    pdcInputStruct.spsdRemovalConfigurationStruct.logTimeConstantMaxValue    = 0;
    pdcInputStruct.spsdRemovalConfigurationStruct.harmonicFalsePositiveRate  = 0.01;
    pdcInputStruct.spsdRemovalConfigurationStruct.useMapBasisVectors         = true;
end % if

if ~isfield(pdcInputStruct,'goodnessMetricConfigurationStruct')
    pdcInputStruct.goodnessMetricConfigurationStruct.coarseDetrendPolyOrder  = 3;
    pdcInputStruct.goodnessMetricConfigurationStruct.correlationScale        = 5e1;
    pdcInputStruct.goodnessMetricConfigurationStruct.variabilityScale        = 1e-2;
    pdcInputStruct.goodnessMetricConfigurationStruct.noiseScale              = 8e-5;
end

% Set up labels on which to base exclusion from PDC processing
% 'Kepler prime' and K2 targets are to be processed
% 'Kepler prime' targets have keplerId < 100M, and
% K2 targets have keplerId >= 201M
% LEGACY_CUSTOM and K2_LEGACY_CUSTOM targets are to be excluded
% LEGACY_CUSTOM targets have 100e6 <= keplerId < 200e6 
% K2_LEGACY_CUSTOM targets have 200e6 <= keplerId < 201e6 
if (isfield(pdcInputStruct, 'targetDataStruct') && ~isempty(pdcInputStruct.targetDataStruct))
    if ~isfield(pdcInputStruct.targetDataStruct(1),'labels')
        for i=1:length(pdcInputStruct.targetDataStruct)
            if (pdcInputStruct.targetDataStruct(i).keplerId<100e6||...
                    pdcInputStruct.targetDataStruct(i).keplerId>201e6)
                pdcInputStruct.targetDataStruct(i).labels = cell(0);
            elseif(pdcInputStruct.targetDataStruct(i).keplerId>=100e6&&...
                    pdcInputStruct.targetDataStruct(i).keplerId<200e6)
                pdcInputStruct.targetDataStruct(i).labels = {'LEGACY_CUSTOM'};
            elseif(pdcInputStruct.targetDataStruct(i).keplerId>=200e6&&...
                    pdcInputStruct.targetDataStruct(i).keplerId<201e6)
                pdcInputStruct.targetDataStruct(i).labels = {'K2_LEGACY_CUSTOM'};
            end
        end % for
    end % if
end % if

% KICs
if (isfield(pdcInputStruct, 'targetDataStruct') && ~isempty(pdcInputStruct.targetDataStruct))
    if ~isfield(pdcInputStruct.targetDataStruct(1),'kic')
        for i=1:length(pdcInputStruct.targetDataStruct)
            % dummy for now
            pdcInputStruct.targetDataStruct(i).kic.keplerId = pdcInputStruct.targetDataStruct(i).keplerId;
            pdcInputStruct.targetDataStruct(i).kic.skyGroupId = nan;
            pdcInputStruct.targetDataStruct(i).kic.keplerMag = struct('value',pdcInputStruct.targetDataStruct(i).keplerMag,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.ra = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.dec = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.radius = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.effectiveTemp = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.log10SurfaceGravity = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.log10Metallicity = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.raProperMotion = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.decProperMotion = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.totalProperMotion = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.parallax = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.uMag = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.gMag = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.rMag = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.iMag = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.zMag = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.gredMag = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.d51Mag = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.twoMassId = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.twoMassJMag = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.twoMassHMag = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.twoMassKMag = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.scpId = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.internalScpId = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.catalogId = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.alternateId = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.alternateSource = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.galaxyIndicator = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.blendIndicator = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.variableIndicator = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.ebMinusVRedding = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.avExtinction = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.photometryQuality = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.astrophysicsQuality = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.galacticLatitude = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.galacticLongitude = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.grColor = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.jkColor = struct('value',nan,'uncertainty',nan);
            pdcInputStruct.targetDataStruct(i).kic.gkColor = struct('value',nan,'uncertainty',nan);
        end % for
    end % if
    
end % if

% gapFillConfigurationStruct - parameter rename from removeShortPeriodEclipsingBinaries to removeEclipsingBinariesOnList
if (isfield(pdcInputStruct.gapFillConfigurationStruct,'removeShortPeriodEclipsingBinaries'))
    pdcInputStruct.gapFillConfigurationStruct.removeEclipsingBinariesOnList = pdcInputStruct.gapFillConfigurationStruct.removeShortPeriodEclipsingBinaries;
    pdcInputStruct.gapFillConfigurationStruct = rmfield(pdcInputStruct.gapFillConfigurationStruct,'removeShortPeriodEclipsingBinaries');
end % if


% excludeTargetLabels
if ~isfield(pdcInputStruct.pdcModuleParameters,'excludeTargetLabels')
    pdcInputStruct.pdcModuleParameters.excludeTargetLabels = cell(0);
end % if


return
