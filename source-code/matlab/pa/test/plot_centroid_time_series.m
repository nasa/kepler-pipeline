function F = plot_centroid_time_series(outputsStruct, WAIT_TIME, PLOTS_ON)
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


madSeparationFactor = 0;                % madSeparationFactor = 0 --> overlay detrended centroids to identify out of family targets
halfWindowSize = 0.05;
windowCenter = [0.25 .50 0.75];
madToStdev = 1.4826;


LC_PERIOD_MINUTES = 30;
SC_PERIOD_MINUTES = 1;

if( isempty(outputsStruct.targetStarResultsStruct) )
    return;
end

fwCentroids = [outputsStruct.targetStarResultsStruct.fluxWeightedCentroids];
prfCentroids = [outputsStruct.targetStarResultsStruct.prfCentroids];
mod = outputsStruct.ccdModule;
out = outputsStruct.ccdOutput;
cadenceType = outputsStruct.cadenceType;

F.ccdModule                 = mod;
F.ccdOutput                 = out;

F.keplerId = [outputsStruct.targetStarResultsStruct.keplerId];
F.keplerMag = [outputsStruct.targetStarResultsStruct.keplerMag];

clear outputsStruct

fwRow = [fwCentroids.rowTimeSeries];    
fwRowVal = [fwRow.values];
fwRowUnc = [fwRow.uncertainties];
fwRowGap = logical([fwRow.gapIndicators]);

fwCol = [fwCentroids.columnTimeSeries];
fwColVal = [fwCol.values];
fwColUnc = [fwCol.uncertainties];
fwColGap = logical([fwCol.gapIndicators]);


if ~all(all(fwRowGap)) || ~all(all(fwColGap))
    
    
    [nCadencesFw, nTargetsFw] = size(fwRowVal);
    
    fwRowVal(fwRowGap) = NaN;
    fwRowUnc(fwRowGap) = NaN;
    
    madFwRowVal = mad(fwRowVal,1);
    madFwRowUnc = mad(fwRowUnc,1);    
        
    fwColVal(fwColGap) = NaN;
    fwColUnc(fwColGap) = NaN;    
    
    madFwColVal = mad(fwColVal,1);
    madFwColUnc = mad(fwColUnc,1);
    
    rowMads = zeros(length(windowCenter),nTargetsFw);
    colMads = zeros(length(windowCenter),nTargetsFw);
    rowUncRms = zeros(length(windowCenter),nTargetsFw);
    colUncRms = zeros(length(windowCenter),nTargetsFw);
    
    idxStart = floor( nCadencesFw .* windowCenter - nCadencesFw * halfWindowSize );
    idxEnd = ceil( nCadencesFw .* windowCenter + nCadencesFw * halfWindowSize );    
    
    for j=1:length(windowCenter)
        
        % detrend windowed data and get mad
        fwRowSample = fwRowVal(idxStart(j):idxEnd(j),:);
        fwRowSample = nandetrend(fwRowSample);
        rowMads(j,:) = mad(fwRowSample,1);
        
        fwColSample = fwColVal(idxStart(j):idxEnd(j),:);
        fwColSample = nandetrend(fwColSample);
        colMads(j,:) = mad(fwColSample,1);
                
        % calculate rms uncertainty in window
        rowUncRms(j,:) = sqrt(nanmean(fwRowUnc(idxStart(j):idxEnd(j),:).^2));
        colUncRms(j,:) = sqrt(nanmean(fwColUnc(idxStart(j):idxEnd(j),:).^2));
    end
    
    % take means and convert mad to std
    F.rowStdFw = mean(rowMads).*madToStdev;
    F.colStdFw = mean(colMads).*madToStdev;
    F.rowUncRmsFw = mean(rowUncRms);
    F.colUncRmsFw = mean(colUncRms);
    
else
    F.rowStdFw = [];
    F.colStdFw = [];
    F.rowUncRmsFw = [];
    F.colUncRmsFw = [];    
end



prfRow = [prfCentroids.rowTimeSeries];    
prfRowVal = [prfRow.values];
prfRowUnc = [prfRow.uncertainties];
prfRowGap = logical([prfRow.gapIndicators]);

prfCol = [prfCentroids.columnTimeSeries];
prfColVal = [prfCol.values];
prfColUnc = [prfCol.uncertainties];
prfColGap = logical([prfCol.gapIndicators]);

if( ~all(all(prfRowGap)) || ~all(all(prfColGap)) )
    
    [nCadencesPrf, nTargetsPrf] = size(prfRowVal);
    
    prfRowVal(prfRowGap) = NaN;
    prfRowUnc(prfRowGap) = NaN;   
    
    madPrfRowVal = mad(prfRowVal,1);
    madPrfRowUnc = mad(prfRowUnc,1);
        
    prfColVal(prfColGap) = NaN;
    prfColUnc(prfColGap) = NaN;    
    
    madPrfColVal = mad(prfColVal,1);
    madPrfColUnc = mad(prfColUnc,1);     
    
    rowMads = zeros(length(windowCenter),nTargetsPrf);
    colMads = zeros(length(windowCenter),nTargetsPrf);
    rowUncRms = zeros(length(windowCenter),nTargetsPrf);
    colUncRms = zeros(length(windowCenter),nTargetsPrf);
    
    idxStart = floor( nCadencesPrf .* windowCenter - nCadencesPrf * halfWindowSize );
    idxEnd = ceil( nCadencesPrf .* windowCenter + nCadencesPrf * halfWindowSize );    
    
    for j=1:length(windowCenter)
        
        % detrend windowed data and get mad
        prfRowSample = prfRowVal(idxStart(j):idxEnd(j),:);
        prfRowSample = nandetrend(prfRowSample);
        rowMads(j,:) = mad(prfRowSample,1);
        
        prfColSample = prfColVal(idxStart(j):idxEnd(j),:);
        prfColSample = nandetrend(prfColSample);
        colMads(j,:) = mad(prfColSample,1);
                
        % calculate rms uncertainty in window
        rowUncRms(j,:) = sqrt(nanmean(prfRowUnc(idxStart(j):idxEnd(j),:).^2));
        colUncRms(j,:) = sqrt(nanmean(prfColUnc(idxStart(j):idxEnd(j),:).^2));
    end
    
    % take means and convert mad to std
    F.rowStdPrf = mean(rowMads).*madToStdev;
    F.colStdPrf = mean(colMads).*madToStdev;
    F.rowUncRmsPrf = mean(rowUncRms);
    F.colUncRmsPrf = mean(colUncRms);
    
else
    F.rowStdPrf = [];
    F.colStdPrf = [];
    F.rowUncRmsPrf = [];
    F.colUncRmsPrf = [];    
end
    


if( PLOTS_ON )    

    if( ~all(all(fwRowGap)) || ~all(all(fwColGap)) )
        

        idxDays = 0:nCadencesFw - 1;
        if( strcmpi(cadenceType,'long') )
            idxDays = idxDays .* LC_PERIOD_MINUTES ./ (24 * 60) ;
        elseif( strcmpi(cadenceType,'short') )
            idxDays = idxDays .* SC_PERIOD_MINUTES ./ (24 * 60) ;
        end

        h1 = figure(1);        
        ax(1) = subplot(2,2,1);
        plot(idxDays,fwRowVal - ones(nCadencesFw,1)*nanmedian(fwRowVal) + ones(nCadencesFw,1)*((0:nTargetsFw-1).*max(madFwRowVal).*madSeparationFactor));
        grid;
        ylabel('centroids (pix)');
        xlabel('days');
        title(['mod.out ',num2str(mod),'.',num2str(out),': Flux Weighted Row Centroids: ',cadenceType,' cadence']);
        ax(2) = subplot(2,2,2);
        plot(idxDays,fwRowUnc + ones(nCadencesFw,1)*((0:nTargetsFw-1).*max(madFwRowUnc).*madSeparationFactor));
        grid;
        ylabel('uncertainties (pix)');
        xlabel('days');
        ax(3) = subplot(2,2,3);
        plot(idxDays,fwColVal - ones(nCadencesFw,1)*nanmedian(fwColVal) + ones(nCadencesFw,1)*((0:nTargetsFw-1).*max(madFwColVal).*madSeparationFactor));
        grid;
        ylabel('centroids (pix)');
        xlabel('days');
        title(['mod.out ',num2str(mod),'.',num2str(out),': Flux Weighted Column Centroids: ',cadenceType,' cadence']);
        ax(4) = subplot(2,2,4);
        plot(idxDays,fwColUnc + ones(nCadencesFw,1)*((0:nTargetsFw-1).*max(madFwColUnc).*madSeparationFactor));
        grid;        
        ylabel('uncertainties (pix)');
        xlabel('days');        
        
        linkaxes(ax,'x');
        
        figureFilename = ['fluxWeightedCentroids_mod-out_',num2str(mod),'-',num2str(out)];
        saveas(h1,figureFilename);
        saveas(h1,[figureFilename,'.jpg'],'jpg');
    end
    
    
    if( ~all(all(prfRowGap)) || ~all(all(prfColGap)) )

        idxDays = 0:nCadencesPrf - 1;
        if( strcmpi(cadenceType,'long') )
            idxDays = idxDays .* LC_PERIOD_MINUTES ./ (24 * 60) ;
        elseif( strcmpi(cadenceType,'short') )
            idxDays = idxDays .* SC_PERIOD_MINUTES ./ (24 * 60) ;
        end


        h2 = figure(2);
        ax(1) = subplot(2,2,1);
        plot(idxDays,prfRowVal - ones(nCadencesPrf,1)*nanmedian(prfRowVal) + ones(nCadencesPrf,1)*((0:nTargetsPrf-1).*max(madPrfRowVal).*madSeparationFactor));
        grid;
        ylabel('centroids (pix)');
        xlabel('days');
        title(['mod.out ',num2str(mod),'.',num2str(out),': PRF Row Centroids: ',cadenceType,' cadence']);
        ax(2) = subplot(2,2,2);
        plot(idxDays,prfRowUnc + ones(nCadencesPrf,1)*((0:nTargetsPrf-1).*max(madPrfRowUnc).*madSeparationFactor));
        grid;
        ylabel('uncertainties (pix)');
        xlabel('days');
        ax(3) = subplot(2,2,3);
        plot(idxDays,prfColVal - ones(nCadencesPrf,1)*nanmedian(prfColVal) + ones(nCadencesPrf,1)*((0:nTargetsPrf-1).*max(madPrfColVal).*madSeparationFactor));
        grid;
        ylabel('centroids (pix)');
        xlabel('days');
        title(['mod.out ',num2str(mod),'.',num2str(out),': PRF Column Centroids: ',cadenceType,' cadence']);
        ax(4) = subplot(2,2,4);
        plot(idxDays,prfColUnc + ones(nCadencesPrf,1)*((0:nTargetsPrf-1).*max(madPrfColUnc).*madSeparationFactor));
        grid;
        ylabel('uncertainties (pix)');
        xlabel('days');

        linkaxes(ax,'x');
        
        figureFilename = ['prfCentroids_mod-out_',num2str(mod),'-',num2str(out)];
        saveas(h2,figureFilename);
        saveas(h2,[figureFilename,'.jpg'],'jpg');
    end
  

    if( WAIT_TIME > 0 )
        pause(WAIT_TIME);
    else
        disp(' <--------------- HIT ANY KEY --------------------->  ');
        pause;
    end
end
