function [meanBlack, deltaBlack] = generate_2Dblack_from_TVAC_data(channel)
%
% function [meanBlack, deltaBlack] = generate_2Dblack_from_TVAC_data(channel)
%
% Generate 2D black image and uncertainty image from thermal vac FITS
% files. The current working directory must contain these raw data FITS
% files. Input is the channel number.
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


% Hard coded constants --------
nRows = 1070;
nCols = 1132;
chargeInjectionRows = 1060:1064;
lowInjectionBuffer = 0;
highInjectionBuffer = 1;
nReads = 270;
outlierThresholdSigmas = 3;                 % threshhold in sigma to reject temporal outliers
tooManyImages = 40;                         % WAG at number of images that can be stored in memory

clockStateFITSFile = '/path/to/matlab/ct/tcat/mfiles/clock_state_mask_KADN-26205_20081218.fits';
clockState = fitsread(clockStateFITSFile);
noClockXtalkState = 96;

% -----------------------------

% get FITS filenames
D = dir('*.fits');
filenames = {D.name}';
nImages = length(filenames);

% initialize image storage
A = zeros(nRows,nCols,nImages);

if(nImages < tooManyImages)

    % calculate robust mean and error
    
    disp('Loading files...');
    for i=1:nImages
        disp(filenames{i});
        B = fitsread(filenames{i},'Image',channel);
        A(:,:,i) = B;
    end
    
    % calculate mean and standard deviation
    disp('Calculate mean black and standard deviation ...');
    meanBlack = mean(A,3);
    deltaBlack = std(A,1,3);
    
    % find outliers
    disp('Find outliers...');
    fullMeanBlack = reshape(repmat(meanBlack,1,nImages),nRows,nCols,nImages);
    fullDeltaBlack = reshape(repmat(deltaBlack,1,nImages),nRows,nCols,nImages);
    
    outlierIndicator = abs(A - fullMeanBlack) > fullDeltaBlack.*outlierThresholdSigmas;
        
    % calculate mean across nImages excluding outliers
    disp('Remove outliers and recalculate mean black and standard deviation ...');
    meanBlack = sum((~outlierIndicator).*A,3)./(nImages - sum(outlierIndicator,3));
    fullMeanBlack = reshape(repmat(meanBlack,1,nImages),nRows,nCols,nImages);
    
    % calculate standard deviation across nImages excluding outliers
    deltaBlack = sqrt(sum((~outlierIndicator).*(A - fullMeanBlack).^2,3)./(nImages - sum(outlierIndicator,3) - 1));
    
    % calculate standard deviation of the mean
    deltaBlack = deltaBlack./sqrt(nImages - sum(outlierIndicator,3));
    
    % clear memory
    clear fullMeanBlack fullDeltaBlack outlierIndicator   

else
    
    % calculate simple mean and error w/o outlier rejection
    
    meanBlack = zeros(nRows,nCols);

    disp('Perform simple mean black calculation...');

    % sum images
    for i=1:nImages
        disp(['Doing file ',filenames{i},' ...']);
        A = fitsread(filenames{i},'Image',channel);    
        meanBlack = meanBlack + A;
    end

    % calculate simple mean black per cadence
    meanBlack = meanBlack./nImages;

    deviationsSquared = zeros(nRows,nCols);
    disp('Perform simple delta black calculation...');

    % sum deviations from simple mean squared
    for i=1:nImages
        disp(['Doing file ',filenames{i},' ...']);
        A = fitsread(filenames{i},'Image',channel); 
        deviationsSquared = deviationsSquared + (A - meanBlack).^2;
    end

    % calculate standard deviation of data set
    % This should agree with the standard deviation of the underlying sample
    % distribution e.g. the read noise + 12-bit A/D quantization noise scaled
    % for number of temporal coadds (nReads)
    deltaBlack = sqrt(deviationsSquared./(nImages - 1));

                        % OUTLIER REMOVAL ON THE FLY e.g. file-by-file -
                        % NOT READY FOR PRIME TIME YET
                            
                        %     % check for temporal outliers (across nImages)
                        %     % recalculate mean removing outliers
                        %     nonOutlierCount = ones(nRows,nCols).*nImages;
                        %     oldMeanBlack = meanBlack;
                        %     disp('Remove outliers from mean black...');
                        %     for i=1:nImages
                        %         disp(['Doing file ',filenames{i},' ...']);
                        %         A = fitsread(filenames{i},'Image',channel);
                        % 
                        %         % identify outliers
                        %         outlierIndicator = abs(A - meanBlack) > deltaBlack.*outlierThresholdSigmas;
                        % 
                        %         if(any(any(outlierIndicator)))
                        %             % adjust meanBlack excluding outliers
                        %             meanBlack = (meanBlack.*nonOutlierCount - outlierIndicator.*A)./nonOutlierCount;
                        % 
                        %             % update count of non-outliers
                        %             nonOutlierCount = nonOutlierCount - double(outlierIndicator);  
                        %         end    
                        %     end
                        % 
                        %     % recalculate delta black using new mean and removing outliers
                        %     disp('Remove outliers from delta black...');
                        %     deviationsSquared = zeros(nRows,nCols);
                        % 
                        %     % sum deviations from updated (robust) mean squared
                        %     for i=1:nImages
                        %         disp(['Doing file ',filenames{i},' ...']);
                        %         A = fitsread(filenames{i},'Image',channel);
                        % 
                        %         % identify outliers using oldmean black
                        %         outlierIndicator = abs(A - oldMeanBlack) > deltaBlack.*outlierThresholdSigmas;  
                        % 
                        %         % include only non-outliers in sum
                        %         deviationsSquared = deviationsSquared + ~outlierIndicator.*(A - meanBlack).^2;
                        %     end

                        %     % compute standard deviation of modified data set
                        %     deltaBlack = sqrt(deviationsSquared./(nonOutlierCount - 1));
                        % 
                        %     % calculate standard error of robust mean black
                        %     deltaBlack = deltaBlack./sqrt(nonOutlierCount);

end
    

% Scale meanBlack and deltaBlack to DN per read.
% Since the same twoDBlack model will be applied for each read, the black
% model is perfectly correlated between reads. This means the scaling
% between the per coadd variance and the per read variance is:
% variance per coadd = variance per read * (nCoadds)^2 so
% deltaBlack_per_read = deltaBlack_per_coadd / nReads
meanBlack = meanBlack./nReads;
deltaBlack = deltaBlack./nReads;


% Interpolate across charge injection rows.
% Interpolate between row just below charge injection rows minus low buffer 
% the and row just above charge injection rows plus high buffer to fill 
% meanBlack in charge injection rows. For columns that contain FSG
% xtalk signature move to the next row down/up.
% 

disp('Interpolate across charge injection rows...');

columnPool = 1:nCols;
a = min(chargeInjectionRows) - 1 - lowInjectionBuffer;
b = max(chargeInjectionRows) + 1 + highInjectionBuffer;

moveLowRow = true;

while(~isempty(columnPool))
    
    lowCols = columnPool(clockState(a,columnPool) == noClockXtalkState);
    highCols = columnPool(clockState(b,columnPool) == noClockXtalkState);
    commonCols = intersect(lowCols, highCols);

    % interpolate blacks
    meanBlack(chargeInjectionRows,commonCols) =...
        interp1([a,b], meanBlack([a,b],commonCols), chargeInjectionRows, 'linear', 'extrap');
    
    % interpolate deltaBlack^2 to get an approximation of deltaBlack in the
    % interpolated region
    deltaBlack(chargeInjectionRows,commonCols) =...
        sqrt(interp1([a,b], deltaBlack([a,b],commonCols).^2, chargeInjectionRows, 'linear', 'extrap'));    

    columnPool = setdiff( columnPool, commonCols);
    
    if(moveLowRow)
        a = a - 1;
    else
        b = b + 1;
    end
    
    moveLowRow = ~moveLowRow;
    
end


        
        
        
        


