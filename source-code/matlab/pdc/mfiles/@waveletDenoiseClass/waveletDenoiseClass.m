%==========================================================================
% waveletDenoiseClass
%==========================================================================
% This class implements a simple wavelet denoising technique for one-dimensional
% functions, which removes noise, yielding a smooth estimate of the input function.
% The steps are as follows:
% (1)  Compute an overcomplete wavelet transformation of the function, which yields a set of wavelet coefficients at all relevant scales.
%      The function is first extended by reflection to mitigate boundary
%      effects
% (2)  Apply a 'universal hard threshold' citep{Donoho94} to the wavelet coefficients at each scale. 
%      Denoising is accomplished in the wavelet domain by the following procedure:
%      Coefficients with values below the threshold are presumed to be noise, and are therefore replaced with zeros.
% (3)  Apply the inverse overcomplete wavelet transformation to the 'thresholded' wavelet coefficients to estimate the denoised function.
% Reference: 
% Donoho D. L. & Johnstone I. M. (1994). "Ideal Denoising In an Orthonormal Basis
% Chosen From A Library of Bases", Comptes Rendus De L Academie Des Sciences
% Serie I-Mathematique, Vol. 319, No. 12, (December 1994), pp. 1317-1322, ISSN 0764-
% 4442 
%==========================================================================
% The input data to be processed is signalArray, an array of column vectors containing the 1-D signals that are to be denoised
% The main output is denoisedSignalArray, an array of column vectors containing the denoised signals
%==========================================================================
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
classdef waveletDenoiseClass < handle
    
    % Properties
    properties(GetAccess = 'public', SetAccess = 'public')
        
        % threshold type (universal or SURE)
        thresholdType = [];
        
        % threshold method (hard or soft)
        thresholdMethod = [];
             
        % Array of column vector signals to be denoised
        signalArray = [];
        
        % Switch to determine if the universal threshold is to be saved
        saveUniversalThreshold = [];
        
        % Switch to determine if the universal threshold is to be retrieved
        retrieveUniversalThreshold = [];
        
        % Band to use for noise estimation
        noiseEstimationSubband = [];
        
        % Extend column vectors by reflection
        signalArrayExtended = [];
        
        % Beginning and ending indices of signalArray
        iBegin = [];
        iEnd = [];
        
        % Length of the signal to be denoised
        nCadences = [];
        
        % Length of the signal to be denoised
        nCadencesExtended = [];
        
        % Number of column vectors in signalArray
        nSignals = [];
        
        % Maximum scale for the wavelet decomposition
        maxScale = [];
        
        % Number of wavelet scales
        nScales = [];
        
        % Scaling filter (also called the mother wavelet)
        scalingFilter = [];
        
        % Length of wavelet scaling filter
        scalingFilterLength = [];
        
        % Denoised signal
        denoisedSignalArray = [];
        denoisedSignalResidualsArray = [];
        denoisedSignalRmsResidual = [];        
        
        % Reconstructed signal (for diagnostics)
        reconstructedSignalArray = [];
        reconstructedSignalResidualsArray = [];
        reconstructedSignalRmsResidual = [];
        
        % Struct for wavelet transform
        waveletDataStruct = struct();
        
        % Struct for signal
        multiResolutionDataStruct = struct();
        
        % Threshold
        thresholds = struct();
        
        % Current signal
        iCurrentSignal = [];
        
    end % properties
    
    % Methods
    methods(Access = 'public')
        
        %*****************************************************************************************************
        % Constructor:
        % function obj = waveletDenoiseClass(thresholdMethod,thresholdType,scalingFilterLength,varargin)
        %==================================================================
        % Inputs: 
        % thresholdMethod        -- [char] method of thresholding 'universal' or 'sure'. Only the 'universal' threshold method is currently implemented.
        % thresholdType          -- [char] type of threshold 'soft' or 'hard'. Only the 'hard' threshold is currently implemented.
        % scalingFilterLength    -- [int (OPTIOONAL)] the length of the scaling filter, or 'mother wavelet' (integer). The default used throughout PDC is 12,
        %                                   other values have not been tested for denoising.
        % signalArray            -- [double matrix(nCadences,nSignals) (OPTIONAL)] the input array of 1D column vector signals to be denoised
        % noiseEstimationSubband -- [int (OPTIONAL)] the number of the subband to use for noise estimation, nominally the shortest-scale subband 
        %                                   within the band. (E.g. For band 3, it's subband 1; for band 2, it's subband 3.)
        %==================================================================
        % Outputs:
        % waveletDenoiseObject
        %   .denoisedSignalArray    -- [double array(size(SignalsArray))] this is the array of denoised signals.
        %   .signalArrayExtended    -- [double] signals extended by reflection to mitigate edge effects (double).
        %                               This is a simpler method than that used in bandsplitting.
        %   .waveletDataStruct      -- [double] has the wavelet coefficients and
        %                               the thresholded wavelet coefficients (double) for each input signal. 
        %                               These arrays are [nCadencesExtended x nScales]. nScales is the
        %                               number of scales of the wavelet transform, computed below, and
        %                               nCadencesExtended is twice nCadences.        
        %   ...Plus other undocumented outputs....
        %*****************************************************************************************************
        
        function obj = waveletDenoiseClass(thresholdMethod,thresholdType,scalingFilterLength,varargin)
            
            % Check that scaling filter is even
            assert(mod(scalingFilterLength,2)==0,'waveletDenoiseClass:inputParameters','Input error -- scalingFilterLength must be an even number!') 
            
            % Scaling filter length
            obj.scalingFilterLength = scalingFilterLength;
                        
            % Create scaling filter, also called mother wavelet
            obj.scalingFilter = daubechies_low_pass_scaling_filter(obj.scalingFilterLength);
            
            % Thresholding specification
            obj.thresholdType = thresholdType;
            obj.thresholdMethod = thresholdMethod;
            
            % Input signal
            if(nargin >= 4)
                
                % The input array of signals to be denoised is provided in
                % the first extra input argument.
                obj.signalArray = varargin{1};
                
                % Noise estimation subband is the second extra input
                % argument.
                obj.noiseEstimationSubband = varargin{2};
                
                % Switch to save threshold (logical) is the third extra
                % input argument.
                obj.saveUniversalThreshold = varargin{3};
                
                % Switch to retrieve threshold (logical) is the fourth
                % extra input argument.
                obj.retrieveUniversalThreshold = varargin{4};
                                
                % Number of column vectors in signalArray
                obj.nSignals = size(obj.signalArray,2);
                
                % Length of each signal to be denoised
                obj.nCadences = size(obj.signalArray,1);
                
                % Extend the signal array by reflection to mitigate edge effects
                obj.signalArrayExtended = [obj.signalArray;flipud(obj.signalArray)];
                obj.nCadencesExtended = size(obj.signalArrayExtended,1);
                              
                % Begin and end indices of the signal in extendedSignalArray
                obj.iBegin = 1;
                obj.iEnd = obj.nCadences;
                
                % Compute the maximum scale, using the rule of thumb formula
                % from Wavelet Methods for Time Series Analysis, Percival, D.B. & Walden A.T. (2000, Cambridge University Press), p. 200
                % Using ceil instead of floor, a bit less conservative
                obj.maxScale = ceil( log2(obj.nCadences/(obj.scalingFilterLength-1) + 1) );
                
                % Number of wavelet scales is maxScale + 1
                obj.nScales = obj.maxScale + 1;
                
                % This is the denoising step
                % If noiseEstimationSubband == 0, bypass denoising, just copy the input
                % signal into the denoised signal. (This is done only for
                % band 1).
                if(obj.noiseEstimationSubband > 0)
                    
                    % Apply overcomplete wavelet transform to extended input flux
                    % to mitigate edge effects
                    % Populate a struct waveletDataStruct of length nSignals; the
                    % fields are coefficients (nScales x nCadences) and coefficientsExtended (nScales x nCadences)
                    obj.waveletDataStruct = struct('waveletCoefficientsExtended',zeros(obj.nCadencesExtended,obj.nScales), ...
                        'thresholdedWaveletCoefficientsExtended',zeros(obj.nCadencesExtended,obj.nScales) );
                    obj.waveletDataStruct = repmat(obj.waveletDataStruct,1,obj.nSignals);
                    % Populate a struct multiresolutionSignal of length nSignals;
                    % the fields are signalAtAllScales (nScales x nCadences),
                    % denoisedSignalAtAllScales (nScales x nCadences), reconstructedSignal (nCadences x 1), denoisedSignal (nCadences x 1)
                    obj.multiResolutionDataStruct = struct('signalAtAllScales',zeros(obj.nCadences,obj.nScales), ...
                        'denoisedSignalAtAllScales',zeros(obj.nCadences,obj.nScales), ...
                        'signalAtAllScalesExtended',zeros(obj.nCadencesExtended,obj.nScales), ...
                        'denoisedSignalAtAllScalesExtended',zeros(obj.nCadencesExtended,obj.nScales));
                    obj.thresholds = struct('values',zeros(1,obj.nScales));
                    obj.thresholds = repmat(obj.thresholds,1,obj.nSignals);
                    for iSignal = 1:obj.nSignals
                        % Current signal
                        obj.iCurrentSignal = iSignal;
                        % Wavelet coefficients for extended signal
                        obj.waveletDataStruct(iSignal).waveletCoefficientsExtended = ...
                            overcomplete_wavelet_transform(obj.signalArrayExtended(:,iSignal),obj.scalingFilter,obj.maxScale);
                        % Threshold the extended wavelet coefficients
                        obj.threshold_wavelet_coefficients;
                        % Apply the inverse overcomplete wavelet transform to the
                        % wavelet coefficients to form the
                        % multiresolution analysis of the extended signal (this is for diagnostics,
                        % not really necessary)
                        obj.multiResolutionDataStruct(iSignal).signalAtAllScalesExtended = ...
                            reconstruct_multiresolution_timeseries(obj.waveletDataStruct(iSignal).waveletCoefficientsExtended,obj.scalingFilter);
                        % Apply the inverse overcomplete wavelet transform to the
                        % thresholded wavelet coefficients to form the
                        % multiresolution analysis of the extended denoised signal
                        obj.multiResolutionDataStruct(iSignal).denoisedSignalAtAllScalesExtended = ...
                            reconstruct_multiresolution_timeseries(obj.waveletDataStruct(iSignal).thresholdedWaveletCoefficientsExtended,obj.scalingFilter);
                        % Truncate the reconstructed signals to the length of
                        % the input signal  (i.e. trim away the extension)
                        obj.multiResolutionDataStruct(iSignal).signalAtAllScales = ...
                            obj.multiResolutionDataStruct(iSignal).signalAtAllScalesExtended(obj.iBegin:obj.iEnd,:);
                        obj.multiResolutionDataStruct(iSignal).denoisedSignalAtAllScales = ...
                            obj.multiResolutionDataStruct(iSignal).denoisedSignalAtAllScalesExtended(obj.iBegin:obj.iEnd,:);
                    end
                    
                    % Denoised signal is the sum of the multiResolutionSignal over all scales
                    obj.denoisedSignalArray = zeros(obj.nCadences,obj.nSignals);
                    obj.reconstructedSignalArray = zeros(obj.nCadences,obj.nSignals);
                    for iSignal = 1:obj.nSignals
                        obj.denoisedSignalArray(:,iSignal) = sum(obj.multiResolutionDataStruct(iSignal).denoisedSignalAtAllScales,2);
                        obj.reconstructedSignalArray(:,iSignal) = sum(obj.multiResolutionDataStruct(iSignal).signalAtAllScales,2);
                    end
                    
                elseif(obj.noiseEstimationSubband == 0)
                    
                    % In this case (used only for band 1), denoising is not performed, and the output
                    % denoised signal is just a copy of the input signal.
                    obj.denoisedSignalArray = obj.signalArray;
                    obj.reconstructedSignalArray = obj.signalArray;
                end
                
                % Residuals of reconstructed signal and of denoised signal
                % with input signal -- for diagnostics
                obj.reconstructedSignalResidualsArray = obj.signalArray - obj.reconstructedSignalArray;
                obj.reconstructedSignalRmsResidual = sqrt(mean(obj.reconstructedSignalResidualsArray.^2));
                obj.denoisedSignalResidualsArray = obj.signalArray - obj.denoisedSignalArray;
                obj.denoisedSignalRmsResidual = sqrt(mean(obj.denoisedSignalResidualsArray.^2));
                
            end % if(nargin >= 4)
            
        end % constructor
        
        %*****************************************************************************************************
        
        % Other methods
        
        % These functions are in the @waveletDenoiseClass directory
        threshold_wavelet_coefficients(obj)
        sure_threshold(obj)
        
        % These functions are in the /path/to/matlab/common/mfiles/wavelet directory
        daubcqf(obj)
        daubechies_low_pass_scaling_filter(obj)
        reconstruct_multiresolution_timeseries(obj)
        overcomplete_wavelet_transform(obj)
        
    end % methods
    
end % classdef

