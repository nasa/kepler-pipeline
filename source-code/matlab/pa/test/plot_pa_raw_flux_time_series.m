function F = plot_pa_raw_flux_time_series(inputsStruct, outputsStruct)
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



WAIT_TIME = 0.0;
PLOTS_ON = true;

cmObject = configMapClass(inputsStruct.spacecraftConfigMap);
F0 = inputsStruct.fcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND;
cadenceType = inputsStruct.cadenceType;

if( strcmpi(cadenceType, 'long' ) )
    numExposuresPerCadence = get_number_of_exposures_per_long_cadence_period(cmObject(1));
else
    numExposuresPerCadence = get_number_of_exposures_per_short_cadence_period(cmObject(1));
end

exposureTime = get_exposure_time(cmObject(1));

T = exposureTime * numExposuresPerCadence;

    
mod = inputsStruct.ccdModule;
out = inputsStruct.ccdOutput;

clear inputsStruct


M = [outputsStruct.targetStarResultsStruct.keplerMag];
ID = [outputsStruct.targetStarResultsStruct.keplerId];
fluxSeries = [outputsStruct.targetStarResultsStruct.fluxTimeSeries]; 

clear outputsStruct

flux = [fluxSeries.values];
unc = [fluxSeries.uncertainties];
gaps = [fluxSeries.gapIndicators];

flux(gaps) = NaN;
unc(gaps) = NaN;

% compute flux std dev
stdFlux = nanstd(flux);

% flag negative flux and replace w/NaN
% --> don't inculde negative flux values in statistics generation
negFluxIdx = find(any(flux<0));
flux(flux<0) = NaN;
if( ~isempty(negFluxIdx) )
    disp(['Negative flux for target index: ',num2str(negFluxIdx)]);
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

 
F.ccdModule                 = mod;
F.ccdOutput                 = out;
F.negativeFluxIdx           = negFluxIdx;
F.negativeFluxKeplerId      = ID(negFluxIdx);
F.negativeFluxKeplerMag     = M(negFluxIdx);
F.normalizedFlux            = nanmedian(flux)./expectedFlux;
F.uncertaintyOverShotNoise  = nanmedian(unc./sqrt(flux));
F.uncertaintyOverStdDev     = nanmedian(unc)./stdFlux;


if( PLOTS_ON)

    figure(1);

    for i=1:nTargets
        ax(1) = subplot(3,1,1);
        plot(idx,flux(:,i)./expectedFlux(i));
        grid;
        ylabel('\bf\fontsize{11}raw/expected flux');
        title(['\bf\fontsize{13}mod.out ',num2str(mod),'.',num2str(out),' - Target Index = ',num2str(i),' - Kepler ID = ',num2str(ID(i)),' - KepMag = ',num2str(M(i)) ]);

        ax(2) = subplot(3,1,2);
        plot(idx,unc(:,i)./sqrt(flux(:,i)));
        grid;
        ylabel('\fontsize{13}\bfuncertainty/shot noise');

        ax(3) = subplot(3,1,3);
        plot(idx,unc(:,i)./stdFlux(i));
        grid;
        ylabel('\fontsize{11}\bf uncertainty/std dev');
        xlabel('\fontsize{11}\bfrelative cadence #');

        linkaxes(ax,'x');

        if( WAIT_TIME > 0 )
            pause(WAIT_TIME);
        else
            pause;
        end
    end
    

    if( strcmpi(cadenceType, 'long' ) )    
        figure(2);
        hist(F.normalizedFlux,max(nTargets/5,31));
        title(['\fontsize{12}\bfmod.out ',num2str(mod),'.',num2str(out),' - Median Flux Normalized to Expected Per Kepler Mag']);
        ylabel('\bf\fontsize{11}# observed');
        xlabel('\bf\fontsize{11}flux/expected flux');

        figure(3);
        hist(F.uncertaintyOverShotNoise,max(nTargets/5,31));
        title(['\bf\fontsize{12}mod.out ',num2str(mod),'.',num2str(out),' - Median Uncertainty Normalized to Shot Noise']);
        ylabel('\bf\fontsize{11}# observed');
        xlabel('\bf\fontsize{11}uncertainty/shot noise');

        figure(4);
        hist(F.uncertaintyOverStdDev,max(nTargets/5,31));
        title(['\bf\fontsize{12}mod.out ',num2str(mod),'.',num2str(out),' - Median Uncertainty Normalized to Standard Deviation']);
        ylabel('\bf\fontsize{11}# observed');
        xlabel('\bf\fontsize{11}uncertainty/std dev');
    end
    
end
