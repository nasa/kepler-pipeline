%%  remove_harmonics 
% Detects and removes harmonics from time series with step
% 
%   Revision History:
%
%       Version 0 - 3/14/11     released for Science Office use
%       Version 0.1 - 4/30/11     improved/corrected documentation
%                                 replaced some enumerated values with
%                                 variable names
%                                 changed sub-harmonic count calculation
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
% 
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
function [ timeSeriesOut removedHarmonics stepVector ] = remove_harmonics(obj, timeSeriesIn, roi,stepIndex )
%% 1.0 ARGUMENTS
% 
% Function returns:
%
% * |timeSeriesOut    -| Output time series with harmonics removed
% * |removedHarmonics        -| The set of vectors representing removed harmonics
% * |stepVector        -| A vector representing the step discontinuity
%
% Function Arguments:
%
% * |timeSeriesIn    -| Input time series
% * |roi     -| Region of interest for harmonic removal (window around step)
% * |stepIndex -| Location of SPSD, to be modeled as step discontinuity
%
%% 2.0 CODE
%
%% 2.1 INITIALIZATION
%

% anonymous function
stdRobust=@(x) (quantile(x,.977)-quantile(x,.023))/4.0;

% 
falsePositiveRate= obj.correctionParamsStruct.harmonicFalsePositiveRate; %.01; % false positive rate
iterMax=3;  % max. number of harmonic families
windowHalfWidthF=50; % validation window half width
nCadences=length(timeSeriesIn);
removedHarmonics=[];
stepVector=zeros(nCadences,1);
iterCtr=0; %iteration counter
nRoi=length(roi);
minFftBin=ceil(nCadences/nRoi); % added  v0.1
subHarmonicMax=3; % added  v0.1

% threshold for full time series range
cdfFull       = (1-cdf('norm',0.01:0.01:7,0,1).^nCadences);
threshold     = find(cdfFull < falsePositiveRate,1,'first')*0.01;

% threshold for window
cdfWindow       = (1-cdf('norm',0.01:0.01:7,0,1).^(2*windowHalfWidthF));
threshold2     = find(cdfWindow < falsePositiveRate,1,'first')*0.01;

%% 2.2 IDENTIFY NARROW SPECTRAL FEATURES IN FOURIER SPECTRUM
%
% Initialize timeSeries
timeSeries=timeSeriesIn;

% simple fft
timeSeriesFFT=abs(fft(timeSeries));

% first differences of single-sided amplitude spectrum, excluding DC term
firstDiff=diff(timeSeriesFFT(2:floor(nCadences/2)));

% standard deviation
%stdevFirstDiff=std(firstDiff);
stdevFirstDiff=stdRobust(firstDiff);

% candidates
candidates0=find(firstDiff/stdevFirstDiff>threshold);

% exclude FFT bins below minFftBin (1 cycle in roi)
candidates1=candidates0(candidates0>=minFftBin); % changed  v0.1

% candidate count
nCandidates1=length(candidates1);

% validation basd on local criterion

for k=1:nCandidates1,
    % standard deviation in window
    %stdevFirstDiff=std(firstDiff(max(1,candidates1(k)-windowHalfWidthF):min(floor(nCadences/2)-2,candidates1(k)+windowHalfWidthF)));
    stdevFirstDiff=stdRobust(firstDiff(max(1,candidates1(k)-windowHalfWidthF):min(floor(nCadences/2)-2,candidates1(k)+windowHalfWidthF)));
    
    % remove from candidate list if below threshold
    if(firstDiff(candidates1(k))/stdevFirstDiff<threshold2)
        candidates1(k)=0;
    end
end
% remove zeros from candidate list
candidates=candidates1(candidates1>=minFftBin); % changed  v0.1

% revised candidate count
nCandidates=length(candidates); 

try
%% 2.3 MODEL HARMONIC FAMILY + CONSTANT + STEP
%
while nCandidates>0 & iterCtr<iterMax,
    
%% 2.3.1 BUILD A BANK OF DESIGN MATRICES OVER INITIAL FREQUENCY RANGE
%
    % define fundamental frequency as candidate with largest SNR
    bestCandidate=find(firstDiff(candidates)==max(firstDiff(candidates)),1,'first');
    
    % min, max, delta, range, and count for frequency scan
    freqLo=(candidates(bestCandidate)-1.0)/nCadences; % 1 fft bin below fundamental
    freqHi=(candidates(bestCandidate)+2.0)/nCadences; % 2 fft bins above fundamental
    dfreq=(freqHi-freqLo)/25.;
    freqRange0=(freqLo:dfreq:freqHi)';
    nFreq=length(freqRange0);
    
    % Number of fit harmonics includes all that are within the full range over which candidate
    % frequencies were identified
    nHarmonics=ceil(candidates0(end)/candidates(bestCandidate));
    
    % Number of fit subharmonics includes all that are within the
    % range from minFftBin/nCadences to the fundamental frequency but not more than subHarmonicMax
    nSubharmonics= min(subHarmonicMax, floor(candidates(bestCandidate)/minFftBin/2));   % added  v0.1
    % pre V0.1: nSubharmonics=min(round(log2(candidates(bestCandidate)))-1,floor(candidates(bestCandidate)/3));
    
    % Build design matrix
    harmonics=zeros(nFreq,(nHarmonics+nSubharmonics)*2+2,nCadences);
    
    % Design Matrix Component #1: Constant
    harmonics(:,1,:)=ones(nFreq,1,nCadences);
    
    % Design Matrix Components # 2 to 2*nSubharmonics+1: Subharmonics of fundamental frequencies
    for k=1:nSubharmonics
        
        % set of subharmonics corresponding to scanned fundamental frequency range
        freqRange=freqRange0/(k+1);
        
        %generate complex wave form
        sampledHarmonicFunc=exp(2*pi*1i*freqRange*[1]*(0:nCadences-1));
        
        %separate wave form into real and imaginary parts
        % harmonics dimensions: 
        %   1- fundamental frequency scan range
        %   2- harmonic or subharmonic range: [freqRange0/(2:(nSubharmonics+1)), freqRange0*(1:nHarmonics)]
        %   3- time: 0:nCadences-1
        harmonics(:,k*2,:)=real(sampledHarmonicFunc);
        harmonics(:,1+k*2,:)=imag(sampledHarmonicFunc);
    end
    
    % Design Matrix Components # 2*nSubharmonics+2 to 2*(nSubharmonics+nHarmonics)+1: Subharmonics of fundamental frequencies
    for k=1:nHarmonics

        %set of harmonics corresponding to scanned fundamental frequency range
        freqRange=freqRange0*k;

        %generate complex wave form
        sampledHarmonicFunc=exp(2*pi*1i*freqRange*[1]*(0:nCadences-1));
            
        %separate wave form into real and imaginary parts
        % harmonics dimensions: 
        %   1- fundamental frequency scan range
        %   2- harmonic or subharmonic range: [freqRange0/(2:(nSubharmonics+1)), freqRange0*(1:nHarmonics)]
        %   3- time: 0:nCadences-1            
        harmonics(:,(nSubharmonics+k)*2,:)=real(sampledHarmonicFunc);
        harmonics(:,1+(nSubharmonics+k)*2,:)=imag(sampledHarmonicFunc);
    end
    
    % Design Matrix Components # 2*(nSubharmonics+nHarmonics)+2: Step at SPSD location
    harmonics(:,end,:)=repmat(shiftdim([zeros(1,stepIndex),ones(1,nCadences-stepIndex)],-1),[nFreq,1,1]);
        
    % initilize array for RMS residuals of fits
    rmsResidual=zeros(nFreq,1);
    
%% 2.3.2 FITS OVER INITIAL FREQUENCY RANGE
%    
    for k=1:nFreq
        % fit each fundamental frequency in range
        [~,~,r,~] = regress(timeSeries(roi)',squeeze(harmonics(k,:,roi))');
        % robust RMS residuals
        rmsResidual(k)=mad(r,1)/.6745;
    end
    
    % frequency with minimum RMS residuals
    minResidualInd=find(rmsResidual==min(rmsResidual));

    
    for k2=1:6 % frequency refinement loop
    
%% 2.3.3 BUILD A BANK OF DESIGN MATRICES OVER SUCCESSIVELY REFINED FREQUENCY RANGES
%    

        % min, max, delta, range, and count for frequency scan
        freqLo=freqRange0(max(1,minResidualInd-1)); %1-min RMS residual frequency
        freqHi=freqRange0(min(nFreq,minResidualInd+1)); %1+min RMS residual frequency
        dfreq=(freqHi-freqLo)/20.;
        freqRange0=(freqLo:dfreq:freqHi)';
        nFreq=length(freqRange0);
        
        % Build design matrix
        harmonics=zeros(nFreq,(nHarmonics+nSubharmonics)*2+2,nCadences);
        
        % Design Matrix Component #1: Constant
        harmonics(:,1,:)=ones(nFreq,1,nCadences);
        
        % Design Matrix Components # 2 to 2*nSubharmonics+1: Subharmonics of fundamental frequencies
        for k=1:nSubharmonics
            
            %set of subharmonics corresponding to scanned fundamental frequency range
            freqRange=freqRange0/(k+1);  
            
            %generate complex wave form
            sampledHarmonicFunc=exp(2*pi*1i*freqRange*[1]*(0:nCadences-1));
            
            %separate wave form into real and imaginary parts
            % harmonics dimensions: 
            %   1- fundamental frequency scan range
            %   2- harmonic or subharmonic range: [freqRange0/(2:(nSubharmonics+1)), freqRange0*(1:nHarmonics)]
            %   3- time: 0:nCadences-1
            harmonics(:,k*2,:)=real(sampledHarmonicFunc);
            harmonics(:,1+k*2,:)=imag(sampledHarmonicFunc); 
        end
        
        % Design Matrix Components # 2*nSubharmonics+2 to 2*(nSubharmonics+nHarmonics)+1: Subharmonics of fundamental frequencies
        for k=1:nHarmonics

            %set of harmonics corresponding to scanned fundamental frequency range
            freqRange=freqRange0*k;
            
            %generate complex wave form
            sampledHarmonicFunc=exp(2*pi*1i*freqRange*[1]*(0:nCadences-1));
            
            %separate wave form into real and imaginary parts
            % harmonics dimensions: 
            %   1- fundamental frequency scan range
            %   2- harmonic or subharmonic range: [freqRange0/(2:(nSubharmonics+1)), freqRange0*(1:nHarmonics)]
            %   3- time: 0:nCadences-1            
            harmonics(:,(nSubharmonics+k)*2,:)=real(sampledHarmonicFunc);
            harmonics(:,1+(nSubharmonics+k)*2,:)=imag(sampledHarmonicFunc);
        end
        
        % Design Matrix Components # 2*(nSubharmonics+nHarmonics)+2: Step at SPSD location
        harmonics(:,end,:)=repmat(shiftdim([zeros(1,stepIndex),ones(1,nCadences-stepIndex)],-1),[nFreq,1,1]);
        
        % initilize array for RMS residuals of fits
        rmsResidual=zeros(nFreq,1);
    
%% 2.3.4 FITS OVER SUCCESSIVELY REFINED FREQUENCY RANGES
%    
        for k=1:nFreq
            % fit each fundamental frequency in range
            [~,~,r,~] = regress(timeSeries(roi)',squeeze(harmonics(k,:,roi))');
            % robust RMS residuals 
            rmsResidual(k)=mad(r,1)/.6745;
        end
        
        % frequency with minimum RMS residuals
        minResidualInd=find(rmsResidual==min(rmsResidual));
        
    end % end of successive refinement loop
        
%% 2.3.5 REMOVE HARMONIC TERMS
%    
    % final fit
    finalFit = regress(timeSeries(roi)',squeeze(harmonics(minResidualInd(1),:,roi))');
    
    % calculate residuals and revise time series
    timeSeries1=timeSeries-finalFit'*squeeze(harmonics(minResidualInd,:,:));
    timeSeries=timeSeries1;
    
        
%% 2.4 IDENTIFY NARROW SPECTRAL FEATURES IN FOURIER SPECTRUM OF CORRECTED TIME SERIES
%   
    % simple fft
    timeSeriesFFT=abs(fft(timeSeries));
    
    % first differences of single-sided amplitude spectrum, excluding DC term
    firstDiff=diff(timeSeriesFFT(2:floor(nCadences/2)));
    
    % robust standard deviation
    %stdevFirstDiff=std(firstDiff);
    stdevFirstDiff=stdRobust(firstDiff);
    
    % candidates
    candidates0=find(firstDiff/stdevFirstDiff>threshold);
    
    % exclude first FFT bin
    candidates1=candidates0(candidates0>=minFftBin); % changed  v0.1
    
    % candidate count
    nCandidates1=length(candidates1);
    
    % validation basd on local criterion
    for k=1:nCandidates1,
        % robust standard deviation in window
        %stdevFirstDiff=std(firstDiff(max(1,candidates1(k)-windowHalfWidthF):min(floor(nCadences/2)-2,candidates1(k)+windowHalfWidthF)));
        stdevFirstDiff=stdRobust(firstDiff(max(1,candidates1(k)-windowHalfWidthF):min(floor(nCadences/2)-2,candidates1(k)+windowHalfWidthF)));
        
        % remove from candidate list if below threshold
        if(firstDiff(candidates1(k))/stdevFirstDiff<threshold2)
            candidates1(k)=0;
        end
    end
    % remove zeros from candidate list
    candidates=candidates1(candidates1>=minFftBin); % changed  v0.1
    
    % revised candidate count
    nCandidates=length(candidates);
            
%% 2.5 UPDATE OUTPUTS AND INTERATION COUNTER
    removedHarmonics=[removedHarmonics;squeeze(harmonics(minResidualInd,1:end-1,roi))]; % append harmonic terms
    stepVector=stepVector+finalFit(end)*squeeze(harmonics(minResidualInd,end,:));  % accumulate step discontinuity
    iterCtr=iterCtr+1; % count iterations

end % end of harmonic family correction loop

catch
    foo=1;
end

%% 2.6 Output time series
%
timeSeriesOut=timeSeries;

end

