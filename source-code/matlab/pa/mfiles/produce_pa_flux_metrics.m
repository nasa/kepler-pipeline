function fluxOutputStruct = produce_pa_flux_metrics( inputsStruct, outputsStruct )
%**************************************************************************
% function fluxOutputStruct = produce_pa_flux_metrics( ...
%     inputsStruct, outputsStruct )
%**************************************************************************
% Produce data validation summary metrics for the target flux time series.
%
% INPUTS:   
%           paDataStruct      = input structure used by the pa_matlab_controller
%           paResultsStruct   = output structure produced by the pa_matlab_controller
%
% The following field is no longer an input, but is derived from the
% subtas directory name. This is an inelegant solution to the problem,
% but is simplest for the time being - RLM 5/23/13:
%
%           subTaskNumber   = this is the label applied to the pa-outputs-#.mat
%                               e.g. the zero-based subtask number
% OUTPUTS:
%           fluxOutputStruct
%               ccdModule                  = ccd module number
%               ccdOutput                  = ccd output number
%               keplerMagnitude            = magnitude from KIC,[1xnTargets]
%               keplerId                   = id from KIC,[1xntargets]
%               normalizedFlux             = median over cadences of flux normalized to expected flux as determined by KIC paramters,[1xnTargets]
%               uncertaintyOverShotNoise   = median propagated uncertainty normalized to the square root of the flux,[1xnTargets]
%               uncertaintyOverStdDev      = median propagated uncertainty normalized to the standard deviation of the flux,[1xnTargets]
%               negativeFluxIndex          = indices into outputsStruct.targetResultsStruct of any targets with any
%                                            negative values in the flux time series
%               negativeFluxOutputFile     = invocation number corresponding to negative indices above
%               negativeFluxKeplerId       = kepler ID corresponding to negative indices above
%               negativeFluxKeplerMag      = kepler Mag corresponding to negative indices above
% 
% Plots are produced and saved to the local directory for any targets with
% negative flux.
%**************************************************************************
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

% Define constant.
CUSTOM_TARGET_DEFAULT_MAG = 29;

[~, name, ext] = fileparts(pwd);
currentSubTaskDir = strcat(name, ext);
fprintf('PA:Produce dawg metrics for target flux for subtask %s\n', ...
    currentSubTaskDir);

% Derive subtask number from subtask directory name.
[~, remain] = strtok(currentSubTaskDir, '-');
subTaskNumberString = strtok(remain, '-');
subTaskNumber = str2double(subTaskNumberString);

ccdModule = inputsStruct.ccdModule;
ccdOutput = inputsStruct.ccdOutput;
cadenceType = inputsStruct.cadenceType;
configMaps = inputsStruct.spacecraftConfigMap;
cadenceNumbers = inputsStruct.cadenceTimes.cadenceNumbers;

% order fields as was done in paDataClass so cmObject is formed with
% exactly the same input as when it is formed by accessing
% paDataObject.spacecraftConfigMap otherwise configMapClass will detect a
% change in field names. This will avoid "clear classes" errors.
cmObject = configMapClass( orderfields(configMaps) );
F0 = inputsStruct.fcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND;
M0 = 12;

if( strcmpi(cadenceType, 'LONG' ) )
    numExposuresPerCadence = get_number_of_exposures_per_long_cadence_period(cmObject(1));
elseif( strcmpi(cadenceType, 'SHORT' ) )
    numExposuresPerCadence = get_number_of_exposures_per_short_cadence_period(cmObject(1));
end

T = get_exposure_time(cmObject(1)) * numExposuresPerCadence;


if( ~isempty(outputsStruct.targetStarResultsStruct) )

    M = [outputsStruct.targetStarResultsStruct.keplerMag];
    ID = [outputsStruct.targetStarResultsStruct.keplerId];
    fluxSeries = [outputsStruct.targetStarResultsStruct.fluxTimeSeries];

    flux = [fluxSeries.values];
    unc = [fluxSeries.uncertainties];
    gaps = [fluxSeries.gapIndicators];
    
    % set magnitude for any custom target if not provided
    customWithoutMagIdx = find( is_valid_id(ID, 'custom') & isnan( M ) );
    if( ~isempty( customWithoutMagIdx ) )
        M( customWithoutMagIdx ) = CUSTOM_TARGET_DEFAULT_MAG;
    end

    flux(gaps) = NaN;
    unc(gaps)  = NaN;
    
    stdFlux = nanstd(flux);            

    % flag negative flux and replace w/NaN after plotting
    % --> don't inculde negative flux values in statistics generation
    negFluxIdx = find( any(flux < 0) );    
    if( ~isempty(negFluxIdx) )
        disp(['Negative flux for target index: ',num2str(negFluxIdx)]);
        negFluxPaInvocation = ones(1,length(negFluxIdx)).*subTaskNumber;
        
        % generate plots for the negative flux targets
        for iNegativeFlux = negFluxIdx(:)'
            h = figure;
            plot(cadenceNumbers,flux(:,iNegativeFlux),'o');
            title(['Mod/out(channel) = ',...
                    num2str(inputsStruct.ccdModule),'/',num2str(inputsStruct.ccdOutput),...
                    '(',num2str(convert_from_module_output(ccdModule,ccdOutput)),') ',...
                    'Subtask Directory = ',currentSubTaskDir,...
                    ', Target Idx = ',num2str(iNegativeFlux),...
                    ', Kepler ID = ',num2str(ID(iNegativeFlux))]);
            xlabel('cadence number');
            ylabel('flux (e-)');
            grid on;
            saveas(h,['negative_flux_',num2str(ID(iNegativeFlux))],'fig');
            close(h);
        end
    else
        negFluxPaInvocation = [];
    end
    flux(flux < 0) = NaN;  
    
    
    % To convert an astronomical magnitude to a flux value in
    % photoelectrons/second, start with the definition of delta magnitude:
    %     (M - M0) = -2.5 * log10 (F/F0)
    % Therfore,
    %     (F/F0 ) = 10 ^ ((M0 - M)/2.5), or
    %     F = F0 * 10 ^ ((M0 - M)/2.5), where 
    % Where:
    %         M = star magnitude
    %         M0 = reference star magnitude
    %         F =  star flux
    %         F0 - reference star flux
    % In this case, M0 = 12, F0 = values from fcConstants

    expectedFlux = T .* F0 .* 10.^( (M0 - M)./2.5 );

    % build output
    fluxOutputStruct.ccdModule                  = ccdModule;
    fluxOutputStruct.ccdOutput                  = ccdOutput;
    fluxOutputStruct.keplerMagnitude            = M;
    fluxOutputStruct.keplerId                   = ID;
    fluxOutputStruct.normalizedFlux             = nanmedian(flux)./expectedFlux;
    fluxOutputStruct.uncertaintyOverShotNoise   = nanmedian(unc./sqrt(flux));
    fluxOutputStruct.uncertaintyOverStdDev      = nanmedian(unc)./stdFlux;    
    fluxOutputStruct.negativeFluxIndex          = negFluxIdx;
    fluxOutputStruct.negativeFluxOutputFile     = negFluxPaInvocation;
    fluxOutputStruct.negativeFluxKeplerId       = ID(negFluxIdx);
    fluxOutputStruct.negativeFluxKeplerMag      = M(negFluxIdx);

end
  
