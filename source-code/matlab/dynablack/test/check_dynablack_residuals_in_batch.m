function outputsStruct = check_dynablack_residuals_in_batch(rootPath)
% function outputsStruct = check_dynablack_residuals_in_batch(rootPath)
%
% function to check dynablack residuals on all task file directories under rootPath. Produces outputsStruct with summary metrics and some
% summary plots.
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


taskFileMask = 'dynablack-matlab-*';
% rootPath = '/path/to/TEST/pipeline_results/photometry/lc/dynablack/ksop-1522-dynablack-lc-q4/';

D = dir([rootPath,taskFileMask]);
numDirs = length(D);

% initialize some storage
outputsStruct = repmat(struct('mod',0,...
                                'out',0,...
                                'channel',0,...
                                'robustRms',0,...
                                'regressRms',0,...
                                'robustStdRms',0,...
                                'regressStdRms',0,...
                                'robustNumOverThreshold',0,...
                                'regressNumOverThreshold',0,...
                                'bestCoeffType','robust',...
                                'selectDynablack',true),numDirs,1);


for i = 1:numDirs
    
    fileToGet = [rootPath,D(i).name,'/dynablack_blob.mat'];

    if exist(fileToGet,'file')

        display(['i = ',num2str(i),': Doing blob for ',D(i).name,' ...']);

        % load the blob
        warning('off','all');
        load(fileToGet);
        warning('on','all');

        outputsStruct(i).mod = inputStruct.ccdModule;
        outputsStruct(i).out = inputStruct.ccdOutput;
        outputsStruct(i).channel = convert_from_module_output(inputStruct.ccdModule, inputStruct.ccdOutput);


        if inputStruct.validDynablackFit

            % check rms residuals of dynablack fit for all pixels over full dynablack unit of work
            blackResidualsThresholdDnPerRead = 5;
            blackResidualsStdDevThresholdDnPerRead = 0.15;
            numBlackPixelsAboveThreshold = 10;

            dynablackReadsPerCadence = inputStruct.A2ModelDump.Constants.readsPerLongCadence;            
            
            a1ResidRegress = inputStruct.A1_fit_residInfo.LC.fitpix_xLC.regress_resid;
            a1ResidRobust = inputStruct.A1_fit_residInfo.LC.fitpix_xLC.robust_resid;
            
            % trailing collateral pixels occupy the last nCollatRows pixels in both the robust and regress models
            collatRows = inputStruct.A1ModelDump.ROI.trailingCollat.Rows;
            nCollatRows = length(collatRows);
            
            robustResidualsPerRead  = a1ResidRobust(:,end-nCollatRows+1:end)./dynablackReadsPerCadence;
            regressResidualsPerRead = a1ResidRegress(:,end-nCollatRows+1:end)./dynablackReadsPerCadence;
            
            
            % rms over pixels and cadences gives an estimate of the mean bias of the fit - sanity check
            robustRms = sqrt(nanmean(robustResidualsPerRead(:).^2));
            regressRms = sqrt(nanmean(regressResidualsPerRead(:).^2));
            
            % std over cadences per pixel gives an estimate of the variation by pixel
            stdDnPerReadRobust = nanstd(robustResidualsPerRead);
            stdDnPerReadRegress = nanstd(regressResidualsPerRead);
            
            rmsStdRobust = sqrt(nanmean(stdDnPerReadRobust.^2));
            rmsStdRegress = sqrt(nanmean(stdDnPerReadRegress.^2));
            
            regressStdOverThreshold = numel(find(stdDnPerReadRegress > blackResidualsStdDevThresholdDnPerRead));
            robustStdOverThreshold = numel(find(stdDnPerReadRobust > blackResidualsStdDevThresholdDnPerRead));
                        
            outputsStruct(i).robustRms                  = robustRms;
            outputsStruct(i).regressRms                 = regressRms;            
            outputsStruct(i).robustStdRms               = rmsStdRobust;
            outputsStruct(i).regressStdRms              = rmsStdRegress;            
            outputsStruct(i).robustNumOverThreshold     = robustStdOverThreshold;
            outputsStruct(i).regressNumOverThreshold    = regressStdOverThreshold;


            % sanity check on rms fit residuals
            regressRmsHigh = regressRms > blackResidualsThresholdDnPerRead;
            robustRmsHigh = robustRms > blackResidualsThresholdDnPerRead;
            
            % check on variations of fit residuals
            regressSdHigh = regressStdOverThreshold > numBlackPixelsAboveThreshold;
            robustSdHigh  = robustStdOverThreshold > numBlackPixelsAboveThreshold;
            regressInvald = regressRmsHigh || regressSdHigh;
            robustInvalid = robustRmsHigh || robustSdHigh;
            
            
            
            % check validity of A1 fit            
            if regressInvald && robustInvalid
                outputsStruct(i).selectDynablack = false;
                outputsStruct(i).bestCoeffType = [];
                
            elseif regressInvald
                % check robust fit
                if ~robustSdHigh && ~robustRmsHigh
                    % defaults are already correct
                end
                
            elseif robustInvalid
                % check regress fit
                if ~regressSdHigh && ~regressRmsHigh
                    outputsStruct(i).bestCoeffType = 'regress';
                else
                    outputsStruct(i).selectDynablack = false;
                    outputsStruct(i).bestCoeffType = [];
                end
                
            else
                % determine best fit type
                if regressStdOverThreshold < robustStdOverThreshold
                    % fewest points over threshold
                    outputsStruct(i).bestCoeffType = 'regress';
                elseif regressStdOverThreshold == 0 && robustStdOverThreshold == 0
                    % lowest on average std
                    if rmsStdRegress < rmsStdRobust
                        outputsStruct(i).bestCoeffType = 'regress';
                    end
                end
            end
        else
            outputsStruct(i).selectDynablack = false;
            outputsStruct(i).bestCoeffType = [];
        end
    end
end



% produce some summary figures
mod = [outputsStruct.mod];
out = [outputsStruct.out];
channel = [outputsStruct.channel];

% dbSelect = [outputsStruct.selectDynablack];
reg = false(size(channel));
rob = false(size(channel));
for i=1:length(channel)
    if strcmp(outputsStruct(i).bestCoeffType,'regress')
        reg(i) = true;
    end
    if strcmp(outputsStruct(i).bestCoeffType,'robust')
        rob(i) = true;
    end
end

robustRms = [outputsStruct.robustRms];
regressRms = [outputsStruct.regressRms];
robustStdRms = [outputsStruct.robustStdRms];
regressStdRms = [outputsStruct.regressStdRms];
robustNumOverThreshold = [outputsStruct.robustNumOverThreshold];
regressNumOverThreshold = [outputsStruct.regressNumOverThreshold];

figure;
pad_draw_ccd(1:42);
colour_my_mod_out( mod(reg), out(reg), 'g' );
colour_my_mod_out( mod(rob), out(rob), 'r' );

% add channel numbers
% get x and y cordinates for approximate center of each mod out
[x,y] = morc_to_focal_plane_coords( mod(:), out(:), 535.*ones(size(mod(:))), 566.*ones(size(mod(:))), 'one-based' );
for iChannel = 1:length(channel)
    text(x(iChannel),y(iChannel),num2str(channel(iChannel)));
end
title('Dynablack Coefficient Type - RED == Robust, GREEN == Regress, UNCOLORED == invalid fit');

figure;
plot(channel,robustStdRms,'o');
hold on;
plot(channel,regressStdRms,'r.');
hold off;
grid;
xlabel('channel');
ylabel('DN/read coadded over 14 columns');
legend('robust','regress');
title('RMS over pixels of standard deviation over cadences of Dynablack residuals');

figure;
plot(channel,robustNumOverThreshold,'o');
hold on;
plot(channel,regressNumOverThreshold,'r.');
hold off;
grid;
xlabel('channel');
ylabel('number of pixels');
legend('robust','regress');
title('number of pixels with standard deviation over cadences over threshold');

figure;
plot(channel,robustRms,'o');
hold on;
plot(channel,regressRms,'r.');
hold off;
grid;
xlabel('channel');
ylabel('DN/read coadded over 14 columns');
legend('robust','regress');
title('RMS over pixels and cadences of Dynablack residuals');
