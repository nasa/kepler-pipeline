function bootstrapResultsStruct = create_bootstrapResultsStruct(bootstrapObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function bootstrapResultsStruct = create_bootstraResultsStruct(bootstrapObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Creates a bootstrapResultsStruct structure to allocate bootstrap results
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  
%  bootstrapResultsStruct has the following fields:
%
%        finalSkipCount: [int]  Final value used for bootstrapping. 
%  statistics:   [float array]  In sigma, or the x axis for the histograms.
% probabilities: [float array]  False alarm probabilities for the 
%                               associated statistics.                                                              
%        significance: [float]  False alarm at the search transit threshold.
%                               
%    histogramStruct: [struct]  contains the following the fields:
%                                       
%              trialTransitPulseDuration: [float]   Indicates whether the
%                                                   histogram counts are 
%                                                   coming from a 3, 6, 12,
%                                                   etc hour pulse.
%                                 counts:   [int]   Counts generated after 
%                                                   bootstrapping.
%                         isHistSmooth: [logical]   If the histogram is 
%                                                   gaussian shaped.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

histogramBinWidth = bootstrapObject.histogramBinWidth;
nullTailMinSigma = bootstrapObject.nullTailMinSigma;
nullTailMaxSigma = bootstrapObject.nullTailMaxSigma;
convolutionMethodEnabled = bootstrapObject.convolutionMethodEnabled;

if convolutionMethodEnabled
    nPulses = 1;
    bootstrapResultsStruct = initialize_bootstrap_results_struct(nPulses, histogramBinWidth);
    bootstrapResultsStruct.histogramStruct.trialTransitPulseDuration = ...
        bootstrapObject.singleEventStatistics.trialTransitPulseDuration;
else
    nPulses = bootstrapObject.numberPulseWidths;
    bootstrapResultsStruct = initialize_bootstrap_results_struct(nPulses, histogramBinWidth);
    bootstrapResultsStruct.statistics = (nullTailMinSigma:histogramBinWidth:nullTailMaxSigma)';
    for iPulse = 1:nPulses
        bootstrapResultsStruct.histogramStruct(iPulse).trialTransitPulseDuration = ...
            bootstrapObject.degappedSingleEventStatistics(iPulse).trialTransitPulseDuration;  
    end
end



return

%==========================================================================
% initialize_bootstrap_results_struct
%==========================================================================

function bootstrapResultsStruct = initialize_bootstrap_results_struct(nPulses, histogramBinWidth)

bootstrapResultsStruct = struct('histogramStruct', ...
    repmat(struct('trialTransitPulseDuration', 0, 'probabilities', [], ...
    'iterationsActual', 0, 'iterationsEstimate', 0, 'finalSkipCount', -1, ...
    'isHistSmooth', false), 1, nPulses), ...
    'statistics', [], 'histogramBinWidth', histogramBinWidth, ...
    'probabilities', [], ...
    'significance', -1, ...
    'bootstrapThresholdForDesiredPfa', -1, ...
    'bootstrapMesMean', -1, ...
    'bootstrapMesStd', -1);

return

