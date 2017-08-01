function [F, summary] = plot_pa_raw_flux_all( taskDirectoryPath, WAIT_TIME, PLOTS_ON )


% WAIT_TIME = 0;
% PLOTS_ON = true;
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
P1 = [1156   180   715   920];
LOTS_O_BYTES = 5e8;
tempInputFilename = 'tempInputFile.mat';

stateFilename = 'pa_state.mat';
outputFileRoot = 'pa-outputs-';

% set up output structures
summary = struct('ccdModule',[],...
                    'ccdOutput',[],...
                    'taskFileDirectory',taskDirectoryPath,...
                    'nTargets',[],...
                    'negativeFluxIndex',[],...
                    'negativeFluxKeplerId',[],...
                    'negativeFluxKeplerMag',[],...
                    'negativeFluxOutputFile',[],...
                    'normalizedFlux',[],...
                    'uncertaintyOverShotNoise',[],...
                    'uncertaintyOverStdDev',[]);

 F = struct('ccdModule',[],...
            'ccdOutput',[],...
            'normalizedFlux',[],...
            'uncertaintyOverShotNoise',[],...
            'uncertaintyOverStdDev',[]);

if( ~exist([taskDirectoryPath,filesep,stateFilename],'file') || ~exist([taskDirectoryPath,filesep,'pa-inputs-0.mat'],'file') )
    return;
end

% get config map for this task directory from inputs then discard
load([taskDirectoryPath,filesep,stateFilename],'nInvocations');
load([taskDirectoryPath,filesep,'pa-inputs-0.mat']);

cadenceType = inputsStruct.cadenceType;
configMaps = inputsStruct.spacecraftConfigMap;

cmObject = configMapClass(orderfields(configMaps));
F0 = inputsStruct.fcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND;

if( strcmpi(cadenceType, 'long' ) )
    numExposuresPerCadence = get_number_of_exposures_per_long_cadence_period(cmObject(1));
    startInvocationLabel = 1;     
else
    numExposuresPerCadence = get_number_of_exposures_per_short_cadence_period(cmObject(1));
    % SC has no background pixels --> invocation0 == target pixels
    startInvocationLabel = 0;   
end

endInvocationLabel = nInvocations - 1;
nFiles = endInvocationLabel - startInvocationLabel + 1;

exposureTime = get_exposure_time(cmObject(1));

T = exposureTime * numExposuresPerCadence;


mod = inputsStruct.ccdModule;
out = inputsStruct.ccdOutput;

clear inputsStruct

% allocate output array
F.ccdModule = mod;
F.ccdOutput = out;

F = repmat(F,1,nFiles);

disp(['Processing mod.out ',num2str(mod),'.',num2str(out)']);

iFile = 0;
for iInvocation = startInvocationLabel:endInvocationLabel

    iFile = iFile + 1;

    filename = [outputFileRoot,num2str(iInvocation),'.mat'];

    D = dir([taskDirectoryPath,filesep,filename]);

    if( ~isempty(D) && D.bytes  )
        
        if( D.bytes > LOTS_O_BYTES )                       
            infile = [taskDirectoryPath,filesep,filename];
            disp([num2str(iInvocation),' - Copying    ',taskDirectoryPath,filesep,filename,' ...']);
            system(['cp ',infile,' ',tempInputFilename]);
            tempInputWritten = true;
            disp([num2str(iInvocation),' - Loading    ',taskDirectoryPath,filesep,filename,' ...']);
            load(tempInputFilename);
            disp([num2str(iInvocation),' - Processing ',taskDirectoryPath,filesep,filename,' ...']);            
        else
            disp([num2str(iInvocation),' - Processing ',taskDirectoryPath,filesep,filename,' ...']);
            load([taskDirectoryPath,filesep,filename]);
            tempInputWritten = false;
        end
       
        if( ~isempty(outputsStruct.targetStarResultsStruct) )

            M = [outputsStruct.targetStarResultsStruct.keplerMag];
            ID = [outputsStruct.targetStarResultsStruct.keplerId];
            fluxSeries = [outputsStruct.targetStarResultsStruct.fluxTimeSeries];

            clear outputsStruct

            flux = [fluxSeries.values];
            unc = [fluxSeries.uncertainties];
            gaps = [fluxSeries.gapIndicators];

            flux(gaps) = NaN;
            unc(gaps) = NaN;

            stdFlux = nanstd(flux);            
            
            % flag negative flux and replace w/NaN
            % --> don't inculde negative flux values in statistics generation
            negFluxIdx = find(any(flux<0));
            flux(flux<0) = NaN;  
            if( ~isempty(negFluxIdx) )
                disp(['Negative flux for target index: ',num2str(negFluxIdx)]);
                negFluxOutputFile = ones(1,length(negFluxIdx)).*iInvocation;
            else
                negFluxOutputFile = [];
            end

            [nCadences, nTargets] = size(flux);
            idx = 1:nCadences;


            % Converts an astronomical magnitude to a flux value using the definition
            %     (M - M0) = -2.5 * log10 (F/F0), or
            %     (F/F0 ) = 10 ^ ((M0 - M)/2.5), where
            %         M = star magnitude
            %         M0 = reference star magnitude
            %         F =  star flux
            %         F0 - reference star flux
            %

            expectedFlux = T .* F0 .* 10.^((12-M)./2.5);


            % build output

            F(iFile).negativeFluxIndex         = negFluxIdx;
            F(iFile).negativeFluxOutputFile    = negFluxOutputFile;
            F(iFile).negativeFluxKeplerId      = ID(negFluxIdx);
            F(iFile).negativeFluxKeplerMag     = M(negFluxIdx);
            F(iFile).normalizedFlux            = nanmedian(flux)./expectedFlux;
            F(iFile).uncertaintyOverShotNoise  = nanmedian(unc./sqrt(flux));
            F(iFile).uncertaintyOverStdDev     = nanmedian(unc)./stdFlux;
            

            % plot each target
            if( PLOTS_ON)
                for i=1:nTargets
                    figure(1);
                    set(gcf,'Position',P1);
                    ax(1) = subplot(3,1,1);
                    plot(idx,flux(:,i)./expectedFlux(i));
                    grid;
                    ylabel('\fontsize{11}\bfraw/expected flux');
                    title(['\fontsize{13}\bfmod.out:',num2str(mod),'.',num2str(out),' / outputFile:',filename,...
                        ' / targetIndex:',num2str(i),' / keplerId:',num2str(ID(i))]);

                    ax(2) = subplot(3,1,2);
                    plot(idx,unc(:,i)./sqrt(flux(:,i)));
                    grid;
                    ylabel('\fontsize{11}\bfuncertainty/shot noise');

                    ax(3) = subplot(3,1,3);
                    plot(idx,unc(:,i)./stdFlux(i));
                    grid;
                    ylabel('\fontsize{11}\bfuncertainty/std dev');
                    xlabel('\fontsize{11}\bfrelative cadence #');

                    linkaxes(ax,'x');

                    if( WAIT_TIME > 0 )
                        pause(WAIT_TIME);
                    else
                        disp(' <----------------- HIT ANY KEY TO CONTINUE -------------------------->');
                        pause;
                    end
                end
            end

            % clean up variables for next load (which may be large)
            disp('Clearing large workspace variables ...');
            clear M ID fluxSeries flux unc gaps stdFlux expectedFlux

        end
                
        % remove temporary file
        if( tempInputWritten )                       
            disp(['Removing ',tempInputFilename,' ...']);
            delete(tempInputFilename); 
        end
    end
end
    

    
% generate summary statistics
summary.ccdModule = mod;
summary.ccdOutput = out;
summary.taskFileDirectory = taskDirectoryPath;
summary.nTargets = length([F.normalizedFlux]);
summary.negativeFluxIndex = [F.negativeFluxIndex];
summary.negativeFluxKeplerId = [F.negativeFluxKeplerId];
summary.negativeFluxKeplerMag = [F.negativeFluxKeplerMag];
summary.negativeFluxOutputFile = [F.negativeFluxOutputFile];

% clean up F output - no need to duplicate data
F = rmfield(F,'negativeFluxIndex');
F = rmfield(F,'negativeFluxKeplerId');
F = rmfield(F,'negativeFluxKeplerMag');
F = rmfield(F,'negativeFluxOutputFile');

summary.normalizedFlux.median = nanmedian([F.normalizedFlux]);
summary.normalizedFlux.mad = mad([F.normalizedFlux],1);
summary.normalizedFlux.max = max([F.normalizedFlux]);
summary.normalizedFlux.min = min([F.normalizedFlux]);

summary.uncertaintyOverShotNoise.median = nanmedian([F.uncertaintyOverShotNoise]);
summary.uncertaintyOverShotNoise.mad = mad([F.uncertaintyOverShotNoise],1);
summary.uncertaintyOverShotNoise.max = max([F.uncertaintyOverShotNoise]);
summary.uncertaintyOverShotNoise.min = min([F.uncertaintyOverShotNoise]);

summary.uncertaintyOverStdDev.median = nanmedian([F.uncertaintyOverStdDev]);
summary.uncertaintyOverStdDev.mad = mad([F.uncertaintyOverStdDev],1);    
summary.uncertaintyOverStdDev.max = max([F.uncertaintyOverStdDev]);
summary.uncertaintyOverStdDev.min = min([F.uncertaintyOverStdDev]);


if( strcmpi(cadenceType, 'long' ) )

    [nCadences, nTargets] = size([F.normalizedFlux]);                                                                                               %#ok<ASGLU>

    % make summary plots
    
    [N, X] = hist([F.normalizedFlux],min(ceil(nTargets/5),100));

    if( PLOTS_ON )
        figure(2);
        bar(X,N);
        title(['\fontsize{13}\bfmod.out ',num2str(mod),'.',num2str(out),' - Median Flux Normalized to Expected Per Kepler Mag']);
        ylabel('\fontsize{11}\bf# observed');
        xlabel('\fontsize{11}\bfmeasured/expected flux');
        grid on;
    end

    summary.normalizedFlux.histogram.amplitudes = N;
    summary.normalizedFlux.histogram.binCenters = X;

    
    [N, X] = hist([F.uncertaintyOverShotNoise],min(ceil(nTargets/5),100));

    if( PLOTS_ON )
        figure(3);
        bar(X,N);
        title(['\fontsize{13}\bfmod.out ',num2str(mod),'.',num2str(out),' - Median Uncertainty Normalized to Shot Noise']);
        ylabel('\fontsize{11}\bf# observed');
        xlabel('\fontsize{11}\bfuncertainty/shot noise');
        grid on;
    end

    summary.uncertaintyOverShotNoise.histogram.amplitudes = N;
    summary.uncertaintyOverShotNoise.histogram.binCenters = X;


    
    [N, X] = hist([F.uncertaintyOverStdDev],min(ceil(nTargets/5),100));

    if( PLOTS_ON )
        figure(4);
        bar(X,N);
        title(['\fontsize{13}\bfmod.out ',num2str(mod),'.',num2str(out),' - Median Uncertainty Normalized to Standard Deviation']);
        ylabel('\fontsize{11}\bf# observed');
        xlabel('\fontsize{11}\bfuncertainty/std dev');
        grid on;
    end

    summary.uncertaintyOverStdDev.histogram.amplitudes = N;
    summary.uncertaintyOverStdDev.histogram.binCenters = X;
end