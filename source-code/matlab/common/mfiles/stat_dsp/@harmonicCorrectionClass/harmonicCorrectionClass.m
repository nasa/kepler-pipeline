classdef harmonicCorrectionClass < handle
% 
% harmonicCorrectionClass -- class for removal of narrow-band harmonics from a time
% series.  This is a handle class, so you can modify it without forcing any of the methods
% to return the object.  Watch out!
%
% Constructor syntax:  obj = harmonicCorrectionClass( harmonicIdentificationParameters ),
%   where harmonicCorrectionParameters is the standard SOC struct of parameters used to
%   manage the execution of harmonic correction.
%
% Methods:
%
%   set_time_series( timeSeries, sampleIntervalSeconds, gapFillIndicators ) -- set the 
%      original time series from which harmonics will be removed
%
%   harmonicTimeSeries = get_harmonic_time_series( scaleHarmonics ) -- return the time 
%      series which is produced when the existing harmonics are evaluated
%
%   cleanedTimeSeries = get_harmonic_free_time_series( scaleHarmonics ) -- return the time 
%      series which is produced when the existing harmonics are removed from the original
%      time series; if scaleHarmonics is true, the harmonics will be rescaled such that,
%      instead of achieving a zero amplitude, they achieve an amplitude which is
%      approximately equal to the broadband background noise at the frequencies of the
%      harmonics (default is false)
%
%   set_protected_frequency( protectedPeriodInSamples ) -- determine the frequencies which
%      are not to be fitted because they are "protected" (typically this means frequency
%      of a known EB), given the period which is to be protected (in samples)
%
%   harmonicsAdded = add_harmonics -- iterate the process of identifying strong harmonics
%      and adding them to the list of frequencies which are fitted; returns a logical
%      indicating whether additional harmonics were added or not
%
%   fit_harmonics -- perform a least-squares fit of the selected harmonics to the time
%      series, preserving the fitted amplitudes and phases
%
%   copy_frequencies( obj2 ) -- copy the frequencies from one object of the class to 
%      another, taking into account the different frequency spacings in the two objects
%
%   combsRemoved = remove_combs -- identify frequency combs and remove them from the set
%      of identified frequencies; returns a logical indicating whether any combs were
%      identified and removed
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

%=========================================================================================

    properties (GetAccess = 'public', SetAccess = 'protected')
        
        originalFluxTimeSeries           = [] ;
        gapOrFillIndicators              = [] ;
        sampleIntervalSeconds            = [] ;
        harmonicIdentificationParameters = [] ;
        protectedIndices                 = [] ;
        fourierComponentStruct           = [] ;
        
    end
    
    methods
        
%       constructor

        function obj = harmonicCorrectionClass( harmonicIdentificationParameters )
            obj.harmonicIdentificationParameters = harmonicIdentificationParameters ;
        end
        
%       all other methods are in separate files in the @harmonicCorrectionClass folder

        harmonicTimeSeries = get_harmonic_time_series( obj, scaleHarmonics ) ;
        cleanedTimeSeries  = get_harmonic_free_time_series( obj, scaleHarmonics ) ;
        harmonicsAdded     = add_harmonics( obj, centerFrequenciesHz ) ;
        combsRestored      = restore_combs( obj ) ;
        frequenciesHz      = get_central_frequencies( obj ) ;
        
        set_protected_frequency( obj, protectedPeriodInSamples ) ;
        set_time_series( obj, timeSeries, sampleIntervalSeconds, gapOrFillIndicators ) ;
        
    end
    
%   here's methods which are only for internal use
    
    methods (Access = 'private')
        
        powerSpectrum                  = get_psd( obj, subtractFittedHarmonics ) ;
        noiseFloor                     = get_background_psd( obj, subtractFittedHarmonics ) ;
        timeSeconds                    = get_sample_times( obj ) ;
        timeSeries                     = evaluate_harmonics( obj ) ;
        timeSeries                     = remove_protected_frequencies_from_time_series( ...
                                            obj, timeSeries ) ;
        [cosTimeSeries, sinTimeSeries] = expand_time_series( obj ) ;
        [cosTimeSeries, sinTimeSeries] = expand_protected_frequencies( obj ) ;
        [cosTimeSeries, sinTimeSeries] = get_sine_waves( obj, freqHz ) ;
        freqHz                         = get_psd_frequencies( obj ) ;
        nPointFft                      = get_fft_length( obj ) ;
                                         fit_harmonics( obj ) ;

        
    end
    
%   here's a static method, since it doesn't actually need any of the object's information

    methods (Static)
        fourierComponentStruct = get_fourier_component_struct_array( ...
            centerFreqHz, centerIndex, nFrequencies ) ;
    end
    
end

