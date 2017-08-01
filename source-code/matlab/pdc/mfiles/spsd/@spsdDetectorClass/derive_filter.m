function derive_filter(obj)
%%  init_filter 
% Initialized SPSD Detector Information.
% SPSD = Sudden Pixel Sensitivity Dropouts
% 
%   Revision History:
%
%       Version 0   - 3/14/11     released for Science Office use
%       Version 0.1 - 4/30/11     improved/corrected documentation
%                                 spsdDetectorStruct.kernels = kernel/weightSum in 3.4.3
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
% 
%%
% function spsdDetectorStruct= init_filter(spsdDetectorParams);
%% 1.0 ARGUMENTS
% 
% * Function returns:
% * |spsdDetectorStruct  -| structure containing input parameters. 
% * |.kernelLength       -| Length in LC of dtector kernel and Long design matrix
% * |.kernelCount   -| number of kernels produced
% * |.kernels       -| convolution kernels for SPSD detection
% * |.longModel        -| Long design matrix structure
% * |-.nComponents       -| component count
% * |-.designMatrix            -| components
% * |-.pseudoinverse            -| right inverse components
% * |.shortModel       -| Short design matrix structure
% * |-.nComponents       -| component count
% * |-.designMatrix            -| components
% * |-.pseudoinverse            -| right inverse components
%
% * Function arguments:SPSD Detector Parameters:
% * |spsdDetectorParams   -| structure containing control parameters.
% * |.mode        -|  1:S-G filter; 
%                       2:S-G filter w/ cotrend terms; 
%                       3:Phased piecewise polynomials; 
%                       4:phased piecewise polynomials w/ cotrend terms;
% * |.windowWidth            -| length of window; assumed odd
% * |.sgPolyOrder             -| Savitzky-Golay filter component order
% * |.sgStepPolyOrder  -| discontinuous polynomial order
% * |.cotrendVector.count      -| number of Uhat terms input
% * |.cotrendVector.dir        -| directory containing Uhat file
% * |.cotrendVector.file       -| Uhat file name
% * |.cotrendVector.fileColumns-| which columns in file contain Uhat vectors 
% * |.longModel.windowWidth     -| length of long design matri xwindow; assumed odd
% * |.longModel.sgPolyOrder      -| Savitzky-Golay filter component order
% * |.longModel.sgStepPolyOrder-| discontinuous polynomial order
% * |.shortModel.windowWidth    -| length of short design matrix window; assumed odd
% * |.shortModel.sgPolyOrder     -| Savitzky-Golay filter component order
% * |.shortModel.sgStepPolyOrder-| discontinuous polynomial order
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
    spsdDetectorParams =  struct(...
        'mode',                    obj.parameterStruct.mode, ... 
        'windowWidth',             obj.parameterStruct.windowWidth, ...
        'sgPolyOrder',             obj.parameterStruct.sgPolyOrder, ...
        'sgStepPolyOrder',         obj.parameterStruct.sgStepPolyOrder, ...
        'cotrendVector',           struct( ... % This field is currently unused.
                                        'count',        0, ...
                                        'dir',          ' ', ...
                                        'filename',     ' ', ...
                                        'fileColumns',  [0] ...
                                       ), ...
        'longModel',                   struct( ...
                                        'windowWidth',     obj.parameterStruct.windowWidth, ...
                                        'sgPolyOrder',     obj.parameterStruct.sgPolyOrder, ...
                                        'sgStepPolyOrder', obj.parameterStruct.sgStepPolyOrder ...
                                       ), ...
        'shortModel',                  struct( ...
                                        'windowWidth',     obj.parameterStruct.shortWindowWidth, ...
                                        'sgPolyOrder',     obj.parameterStruct.shortSgPolyOrder, ...
                                        'sgStepPolyOrder', obj.parameterStruct.shortSgStepPolyOrder ...
                                       ) ...
        );

%% 2.0 INITIALIZATION
%
MODE_SGFILT=1;               % DEFAULT only polynomial S-G filter terms in model
MODE_SGFILT_COTREND=2;       % Polynomial S-G filter + temporally local cotrend terms in model (TBD)
MODE_PIECEWISE=3;            % peicewise polymonial fits of the entire time series (TBD)
MODE_PIECEWISE_COTREND=4;    % peicewise polymonial + cotrend term fits of the entire time series (TBD)

%% 3.0 CHOOSE CASE BASED ON mode
%
switch obj.parameterStruct.mode

%% -> 3.1 S-G FILTER WITH GIVEN COTRENDING TERMS
% 
    case MODE_SGFILT_COTREND
        % TBD
 
%% -> 3.2 GLOBAL MODE_PIECEWISE POLYNOMIAL FIT
% 
    case MODE_PIECEWISE
        % TBD

%% -> 3.3 GLOBAL MODE_PIECEWISE POLYNOMIAL FIT WITH GIVEN COTRENDING TERMS
% 
    case MODE_PIECEWISE_COTREND;
        % TBD

%% -> 3.4 S-G FILTER (DEFAULT)
% generates a step detector convolution kernel based on S_G filter components
    otherwise % case MODE_SGFILT

%% --> 3.4.1 INITIALIZE PARAMETERS
%
        spsdDetectorStruct.kernelLength=obj.parameterStruct.windowWidth;
        spsdDetectorStruct.kernelCount= 1;
        spsdDetectorStruct.longModel     = obj.compute_full_model(spsdDetectorParams.longModel,spsdDetectorStruct.kernelLength);
        spsdDetectorStruct.shortModel    = obj.compute_full_model(spsdDetectorParams.shortModel,spsdDetectorStruct.kernelLength);

        polynomialOrder=obj.parameterStruct.sgPolyOrder;
        discontinuityOrder=obj.parameterStruct.sgStepPolyOrder;
        scale=spsdDetectorStruct.kernelLength;
        
%% --> 3.4.2 CREATE A SET OF MODELS AND INITIALIZE KERNEL WITH HIGHEST ORDER POLYNOMIALS 

        % Generate a set of vectors which measure the step hight for the
        % specified polynomial orders, and determine zero crossings
        % polynomial orders from polynomialOrder (>=2) down to 2nd order
        for k=polynomialOrder:-1:2; 
            % discontinuous polynomials order smaller of dord1 or
            % polynomial order
            ScaledDM{polynomialOrder+1-k} = obj.compute_model(scale,k,min(k,discontinuityOrder));
            % peaks of time domain lobes in step response correspond to
            % zeroes in convolution kernel that measures step height
            % this tells how many peaks of time domain lobes exist:
            lobeCount(polynomialOrder+1-k)=length(ScaledDM{polynomialOrder+1-k}.zeroCrossings);
        end
        
        % Initialize output with largest scale kernel based on input
        % parameters
        zeroCrossings=ScaledDM{1}.zeroCrossings; % zero-crossings
        kernel=ScaledDM{1}.pseudoinverse;  % kernel
        weightSum=1;             % weight
        zeroCrossingSign=(-1).^(1:length(zeroCrossings)); % positive or negative sense of zero-crossings 
        scaleFactor=1; % scale factor used to set the scale for each iteration
        
%% --> 3.4.3 PERFORM MULTISCALE LOBE REDUCTION
% Zeros of convolution kernel are lobe peaks in step response
% This algoorithm matches peaks and antipeaks in step responses at
% different scales  while weighting to keep error constant to make  
% step response as close to a delta function as possible

% Iterate, adding a weighted term to the kernel in each iteration, until: 
%   the desired scale becomes less than 2^(scaleFactor-1) the original scale OR
%   the desired scale becomes greater than the original scale OR
%   the desired scale becomes less the the smallest scale
        while scale>=spsdDetectorStruct.kernelLength/2^(scaleFactor-1) && scale<=spsdDetectorStruct.kernelLength && scale>2*obj.parameterStruct.minWindowWidth
            % Determine the reference polynomial order for this added term 
            %  >=2 but reduces as the sqrt of scale of the previous term
            polynomialOrder=max(2,ceil(obj.parameterStruct.sgPolyOrder*sqrt(scale/spsdDetectorStruct.kernelLength)));
            % Indices to models generated in 3.4.2
            % Index corresponding to model with current polynomialOrder
            idx1=obj.parameterStruct.sgPolyOrder+1-polynomialOrder;
            % Model corresponding to one lower order than polynomialOrder or lowest
            % order model (2nd)
            idx2=min(length(lobeCount),idx1+1);
            % Construct candidate scales which match lobe peaks of opposite sign.
            % scale1 is a matrix of candidate scales which match zeros of current
            %        kernel to zeros of model indexed by idx1. (negative
            %        values corespond to opposite peaks)
            scale1=floor(spsdDetectorStruct.kernelLength*(zeroCrossings.*zeroCrossingSign(1:length(zeroCrossings))')* ...
                (ones(1,lobeCount(idx1))./(ScaledDM{idx1}.zeroCrossings'.*zeroCrossingSign(1:lobeCount(idx1))))/2)*2+1;
            % scale2 is a matrix of candidate scales which match zeros of current
            %        kernel to zeros of model indexed by idx2. (negative
            %        values corespond to opposite peaks)
            scale2=floor(spsdDetectorStruct.kernelLength*(zeroCrossings.*zeroCrossingSign(1:length(zeroCrossings))')* ...
                (ones(1,lobeCount(idx2))./(ScaledDM{idx2}.zeroCrossings'.*zeroCrossingSign(1:lobeCount(idx2))))/2)*2+1;
            % Choose a scale from candidate scales. 
            % Select the least negative (maximum) of the negative values
            % which are less than the negative of the full detector length divided by 2^scaleFactor
            scale=-max([scale1(scale1<-spsdDetectorStruct.kernelLength/2^scaleFactor);scale2(scale2<-spsdDetectorStruct.kernelLength/2^scaleFactor)]);
            % If scale was selected from scale2 candidates, adjust polynomialOrder
            % and discontinuityOrder to new values.
            if ismember(scale,-scale2) && idx1~=idx2
                polynomialOrder=polynomialOrder-1;
                discontinuityOrder=min(discontinuityOrder,polynomialOrder);
            end
            % get the convolution kernel and zeroes for a model at the new
            % scale, polynomialOrder, and discontinuityOrder
            newDesignMatrix=obj.compute_model(scale,polynomialOrder,discontinuityOrder);
            % Step height error goes approx. as the sqrt of scale.
            % By weighting successive terms by weight, we maintain the SNR of
            % the original full scale while localizing the step response.
            weight=sqrt(scale/spsdDetectorStruct.kernelLength);
            % add weighted component, padded with zeroes on both sides to full scale
            kernel=kernel+obj.pad_and_weight(newDesignMatrix.pseudoinverse,spsdDetectorStruct.kernelLength,weight);
            % accumulate a sum of weights
            weightSum=weightSum+weight;
            % determine zero-crossings of the resulting kernel
            zeroCrossings=obj.find_zeros(kernel);
            % new directions of zero crossings
            zeroCrossingSign=(-1).^(1:length(zeroCrossings));
            % increment log_2 of the scale reduction factor for next iteration
            scaleFactor=scaleFactor+1;

        end
        
        %% Add a final term for the shortest time scale
        
        scale=obj.parameterStruct.minWindowWidth;
        % polynomial order=1, for both continuous and discontinuous terms
        newDesignMatrix=obj.compute_model(scale,1,1);
        % weight as above
        weight=sqrt(scale/spsdDetectorStruct.kernelLength);
        % add weighted component, padded with zeroes on both sides to full scale
        kernel=kernel+obj.pad_and_weight(newDesignMatrix.pseudoinverse,spsdDetectorStruct.kernelLength,weight);
        % accumulate a sum of weights
        weightSum=weightSum+weight;
        
        % normalize output so that convolution with data gives step height
        spsdDetectorStruct.kernels = kernel/weightSum ; 

%% --> 3.5 END OF SWITCH
% 
end

% Convert from Jeff's detector structure to object properties.
obj.filter = spsdDetectorStruct.kernels; % Currently only one kernel is returned, but this may not always be true. Ask Jeff what his plans are.
obj.longModel.nComponents = spsdDetectorStruct.longModel.nComponents;
obj.longModel.designMatrix = spsdDetectorStruct.longModel.designMatrix;
obj.longModel.pseudoinverse = spsdDetectorStruct.longModel.pseudoinverse;
obj.shortModel.nComponents = spsdDetectorStruct.shortModel.nComponents;
obj.shortModel.designMatrix = spsdDetectorStruct.shortModel.designMatrix;
obj.shortModel.pseudoinverse = spsdDetectorStruct.shortModel.pseudoinverse;

    
%% 4.0 RETURN
%
end


