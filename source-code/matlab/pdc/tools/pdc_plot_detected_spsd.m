%NAME:
%  pdc_plot_detected_spsd.m
%PURPOSE:
%  display detected single-pixel sensitivity dropouts (SPSDs)
%CALLED BY:
%  none
%CALLS
%  plot_corrected_flux_showtransit_VV8p0
%INPUTS
%OUTPUTS
%  figures
%NOTES
%  Start in top directory
% Code Source: Jeff Van Cleve
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

set (0, 'DefaultFigurePosition', [50, 300, 1000, 600]);
load ~/flight/analysis/inventory/q10/Q10-LC_PID-5733_pdcTaskFiles.mat
load ~/flight/analysis/inventory/q7/KOI_VV8p0.mat
OutDir = '/path/to/dawg/VV8.1/spsd'
topDir = '/path/to/TEST/pipeline_results/photometry/lc/pdc/i5733-lc-pdc-ksop-1149-q10-8.1-release-test'
cd(topDir)
close all
testLabel = 'VV8.1-KSOP-1149'
figure(1)

%canonical list is [1 19 41 58].  Shorter lists may be used for debugging.
for iChan = [1 19 41 58]
    
    taskFileDirectory =  summaryStruct(find(([summaryStruct.ccdChannel] == iChan))).taskfileDirName
    [ccdModule ccdOutput] = convert_mod_out_to_from_channel(iChan)
    cd(taskFileDirectory)
    tic
    display('loading pdc-inputs-0.mat')
    load('pdc-inputs-0.mat')
    toc
    kepIds = [inputsStruct.targetDataStruct.keplerId];
    tic
    display('loading pdc-outputs-0.mat')
    load('pdc-outputs-0.mat')
    toc
    tic
    display('loading spsdCorrectedFluxObject_1.mat')
    load('spsdCorrectedFluxObject_1.mat')
    toc
    spsdCorrectedFluxStruct = spsdCorrectedFluxObject;
    clear spsdCorrectedFluxObject
    spsdCorrectedFluxObject = spsdCorrectedFluxClass.loadobj(spsdCorrectedFluxStruct);
    fullTargetList = [spsdCorrectedFluxObject.resultsStruct.spsds.index];
    if (length(fullTargetList) > 20)
        targetList = fullTargetList(randperm(20)) ;
    else
        targetList = fullTargetList;
    end
    spsdResults = spsdCorrectedFluxObject.get_results
    temp = [spsdResults.spsds.targets.cumulativeCorrection];
    [nCadences nTargetsWithDisc] = size(temp);
    normSPSD = temp./repmat(temp(end,:),nCadences,1);
    nPlots = ceil(nTargetsWithDisc/10);
    [Quarter Month] = quarter_lookup(median([inputsStruct.cadenceTimes.midTimestamps]));
    for iPlot = 1:nPlots
        
        plot(normSPSD(:,10*(iPlot - 1) + 1:min(iPlot*10,nTargetsWithDisc)))
        grid on
        axis([0 4500 -5 5])
        set(gca,'FontSize',11)
        title(['Normalized Cumulative SPSDs Q' num2str(Quarter) '-' num2str(ccdModule) '.' num2str(ccdOutput) ...
            ' Figure ' num2str(iPlot)],'FontSize',12)
        xlabel('Relative Cadence Index','FontSize',11)
        legend(str2mat(num2str(kepIds(fullTargetList(10*(iPlot - 1) + 1:min(iPlot*10,nTargetsWithDisc)))')),'Location','Best');
        outName = ['Q' num2str(Quarter) '-' num2str(ccdModule) '.' num2str(ccdOutput) ...
            '_' testLabel '_' num2str(ccdModule) '.' num2str(ccdOutput) ...
            '_cumulativeSPSD_Fig_' num2str(iPlot)]
        saveas(gcf,fullfile(OutDir,[outName '.fig']))
        set(gcf,'PaperPositionMode','auto')
        print('-djpeg','-r300',fullfile(OutDir,[outName '.jpg']))
        
    end
    %plot time series
    plot_corrected_flux_showtransit_VV8p0(inputsStruct,outputsStruct,...
        [],targetList,[],false,false,...
        true,testLabel,KOI,taskFileDirectory,OutDir,false)
    
    cd('..')
    
end
