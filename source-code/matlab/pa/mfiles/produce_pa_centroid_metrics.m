function F = produce_pa_centroid_metrics( outputsStruct )
%**************************************************************************
% function F = produce_pa_centroid_metrics( outputsStruct )
%**************************************************************************
% Produce data validation summary metrics for the centorid time series.
%
% INPUTS:   
%           paDataStruct      = input structure used by the pa_matlab_controller
%           paResultsStruct   = output structure produced by the pa_matlab_controller
% OUTPUTS:
%           centroidOutputStruct
%               .ccdModule      = ccd module number
%               .ccdOutput      = ccd output number
%               .keplerId       = id from KIC,[1xntargets]
%               .keplerMag      = magnitude from KIC,[1xnTargets]
%               .rowStdFw       = flux weighted row centroid standard deviation,[1xnTargets]
%               .colStdFw       = flux weighted column centroid standard deviation,[1xnTargets]
%               .rowUncRmsFw    = flux weighted row centroid rms uncertainty,[1xnTargets]
%               .colUncRmsFw    = flux weighted column centroid rms uncertainty,[1xnTargets]
%               .rowStdPrf      = prf row centroid standard deviation,[1xnTargets]
%               .colStdPrf      = prf column centroid standard deviation,[1xnTargets]
%               .rowUncRmsPrf   = prf row centroid rms uncertainty,[1xnTargets]
%               .colUncRmsPrf   = prf column centroid rms uncertainty,[1xnTargets]
% 
% Standard deviations are estimated from the mads in three windows of
% length 0.10 * maxCadences centered at 0.25, 0.50 and 0.75 maxCadences
% assuming white Gaussian noise. Robust linear detrending is performed
% within the windows before calculating the mad.
%
% The RMS uncertainties are an average of the rms of the propagated
% unceratinties computed from the data in the same three windows used for
% the standard deviation.
%
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

[~, name, ext] = fileparts(pwd);
currentSubTaskDir = strcat(name, ext);
fprintf('PA:Produce dawg metrics for target centroids for subtask %s\n', ...
    currentSubTaskDir);

halfWindowSize = 0.05;
windowCenter = [0.25 .50 0.75];
madToStdev = 1.4826;

fwCentroids = [outputsStruct.targetStarResultsStruct.fluxWeightedCentroids];
prfCentroids = [outputsStruct.targetStarResultsStruct.prfCentroids];
mod = outputsStruct.ccdModule;
out = outputsStruct.ccdOutput;


F.ccdModule = mod;
F.ccdOutput = out;
F.keplerId = [outputsStruct.targetStarResultsStruct.keplerId];
F.keplerMag = [outputsStruct.targetStarResultsStruct.keplerMag];


fwRow = [fwCentroids.rowTimeSeries];    
fwRowVal = [fwRow.values];
fwRowUnc = [fwRow.uncertainties];
fwRowGap = [fwRow.gapIndicators];

fwCol = [fwCentroids.columnTimeSeries];
fwColVal = [fwCol.values];
fwColUnc = [fwCol.uncertainties];
fwColGap = [fwCol.gapIndicators];

[nCadencesFw, nTargetsFw] = size(fwRowVal);

if( ~all(all(fwRowGap)) || ~all(all(fwColGap)) )
    
    fwRowVal(fwRowGap) = NaN;
    fwRowUnc(fwRowGap) = NaN;
        
    fwColVal(fwColGap) = NaN;
    fwColUnc(fwColGap) = NaN;    
    
    rowMads = zeros(length(windowCenter),nTargetsFw);
    colMads = zeros(length(windowCenter),nTargetsFw);
    rowUncRms = zeros(length(windowCenter),nTargetsFw);
    colUncRms = zeros(length(windowCenter),nTargetsFw);
    
    idxStart = floor( nCadencesFw .* windowCenter - nCadencesFw * halfWindowSize );
    idxEnd = ceil( nCadencesFw .* windowCenter + nCadencesFw * halfWindowSize );
    
    idxStart(idxStart < 1) = 1;
    idxEnd(idxEnd > nCadencesFw) = nCadencesFw;
    
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
    F.rowStdFw = nanmean(rowMads).*madToStdev;
    F.colStdFw = nanmean(colMads).*madToStdev;
    F.rowUncRmsFw = nanmean(rowUncRms);
    F.colUncRmsFw = nanmean(colUncRms);
    
else
    F.rowStdFw = zeros(1,nTargetsFw);
    F.colStdFw = zeros(1,nTargetsFw);
    F.rowUncRmsFw = zeros(1,nTargetsFw);
    F.colUncRmsFw = zeros(1,nTargetsFw);    
end



prfRow = [prfCentroids.rowTimeSeries];    
prfRowVal = [prfRow.values];
prfRowUnc = [prfRow.uncertainties];
prfRowGap = [prfRow.gapIndicators];

prfCol = [prfCentroids.columnTimeSeries];
prfColVal = [prfCol.values];
prfColUnc = [prfCol.uncertainties];
prfColGap = [prfCol.gapIndicators];

[nCadencesPrf, nTargetsPrf] = size(prfRowVal);

if( ~all(all(prfRowGap)) || ~all(all(prfColGap)) )
    
    prfRowVal(prfRowGap) = NaN;
    prfRowUnc(prfRowGap) = NaN;   
           
    prfColVal(prfColGap) = NaN;
    prfColUnc(prfColGap) = NaN;    
    
    rowMads = zeros(length(windowCenter),nTargetsPrf);
    colMads = zeros(length(windowCenter),nTargetsPrf);
    rowUncRms = zeros(length(windowCenter),nTargetsPrf);
    colUncRms = zeros(length(windowCenter),nTargetsPrf);
    
    idxStart = floor( nCadencesPrf .* windowCenter - nCadencesPrf * halfWindowSize );
    idxEnd = ceil( nCadencesPrf .* windowCenter + nCadencesPrf * halfWindowSize );    
    
    idxStart(idxStart < 1) = 1;
    idxEnd(idxEnd > nCadencesPrf) = nCadencesPrf;
    
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
    F.rowStdPrf = nanmean(rowMads).*madToStdev;
    F.colStdPrf = nanmean(colMads).*madToStdev;
    F.rowUncRmsPrf = nanmean(rowUncRms);
    F.colUncRmsPrf = nanmean(colUncRms);
    
else
    F.rowStdPrf = zeros(1,nTargetsPrf);
    F.colStdPrf = zeros(1,nTargetsPrf);
    F.rowUncRmsPrf = zeros(1,nTargetsPrf);
    F.colUncRmsPrf = zeros(1,nTargetsPrf);    
end
    
