function split_into_bands(obj,targetIndex)
% function split_into_bands(obj,targetIndex)
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

    % mother wavelet filter coeffients
    motherWavelet = obj.motherWavelet;
    maxScale = obj.maxScale;
        
    % n = targetIndex; % no loop here, to save memory

    % ----------------------------------------------------------------------------
    % splitting with overcomplete wavelet transform
    % ----------------------------------------------------------------------------
    if (strcmpi(obj.configStruct.splittingMethod,'wavelet'))
        % === VALUES ===
        % the actual transform, calculate the wavelet coefficients for [scale,shift]
        waveletCoefficients = overcomplete_wavelet_transform( obj.intermediateFlux(:,targetIndex) , motherWavelet , maxScale );
        obj.waveletCoefficients{targetIndex} = waveletCoefficients;
                
        % the multi-level reconstruction of the signal
        allBands = reconstruct_multiresolution_timeseries( waveletCoefficients , motherWavelet );

        % invert allBands, to have 1st column as lowest, last column as highest frequency (i.e. scales)
        obj.allBands{targetIndex} = fliplr(allBands);

        % === UNCERTAINTIES ===
        % the actual transform, calculate the wavelet coefficients for [scale,shift]
        waveletCoefficientsUncertainties = overcomplete_wavelet_transform( obj.intermediateFluxUncertainties(:,targetIndex) , motherWavelet , maxScale );
        obj.waveletCoefficientsUncertainties{targetIndex} = waveletCoefficientsUncertainties;
        
        % the multi-level reconstruction of the signal
        allBandsUncertainties = reconstruct_multiresolution_timeseries( waveletCoefficientsUncertainties , motherWavelet );

        % invert allBands, to have 1st column as lowest, last column as highest frequency (i.e. scales)
        obj.allBandsUncertainties{targetIndex} = fliplr(allBandsUncertainties);
    end
    
    % ----------------------------------------------------------------------------
    % splitting with any other simple filter
    % ----------------------------------------------------------------------------
    if (~strcmpi(obj.configStruct.splittingMethod,'wavelet'))
        % === VALUES ===
        obj.allBands = simple_filter_split( obj.intermediateFlux(:,targetIndex) , obj.configStruct.splittingMethod , obj.configStruct.groupingManualBandBoundaries );
        % === UNCERTAINTIES ===        
        obj.allBandsUncertainties = simple_filter_split( obj.intermediateFluxUncertainties(:,targetIndex) , obj.configStruct.splittingMethod , obj.configStruct.groupingManualBandBoundaries );
    end  
    
end

% =====================================================================
% Helper Function for simple filters
% =====================================================================
function Y = simple_filter_split( X , method , scales )
% function Y = simple_filter_split( X , method , scales )

    scales = scales+1; % to make them even (UNCLEAN - should do proper range check, but this is for testing now only anyway)
    N = length(scales);
    T = X;
    switch(lower(method))
        % === MEDIAN ===
        case 'median'
            for i=1:N
                windowSize = scales(i);
                Y(:,i) = medfilt1(T,windowSize);
                T = T - Y(:,i);
            end
            Y(:,N+1) = T;
        % === MEAN ===
        case 'mean'
            for i=1:N
                windowSize = scales(i);
                kernel = ones(1,windowSize)/windowSize;
                tmp = [ ones(windowSize-1,1)*T(1) ; T ; ones(windowSize-1,1)*T(end) ];
                tmp_fil = filter(kernel,1,tmp);
                Y(:,i) = tmp_fil(windowSize:end-windowSize+1);
                T = T - Y(:,i);
            end
            Y(:,N+1) = T;
        % === GAUSSIAN ===
        case 'gaussian'
            for i=1:N
                windowSize = scales(i);
                sigma = windowSize/2;
                kernel = pdf('normal',sigma-1:sigma+1,0,sigma);
                kernel = kernel' / (sum(kernel));
                tmp = [ ones(windowSize-1,1)*T(1) ; T ; ones(windowSize-1,1)*T(end) ];
                tmp_fil = filter(kernel,1,tmp);
                Y(:,i) = tmp_fil(windowSize:end-windowSize+1);
                T = T - Y(:,i);
            end
            Y(:,N+1) = T;
        % === GAUSSIAN ===
        case 'sgolay'
            for i=1:N
                windowSize = scales(i)-1;
                tmp = [ ones(windowSize-1,1)*T(1) ; T ; ones(windowSize-1,1)*T(end) ];
                tmp_fil = sgolayfilt(tmp,2,windowSize);
                Y(:,i) = tmp_fil(windowSize:end-windowSize+1);
                T = T - Y(:,i);
            end
            Y(:,N+1) = T;
        % ================
        otherwise
            disp('unknown filter method')
        % ================
    end

end