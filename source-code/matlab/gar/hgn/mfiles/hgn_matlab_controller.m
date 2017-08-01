function [hgnResultsStruct] = hgn_matlab_controller(hgnDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [hgnResultsStruct] = hgn_matlab_controller(hgnDataStruct)
%
% This function forms the MATLAB side of the science interface for Huffman
% histogram generation and computation of theoretical compression performance
% and data storage/transmission rate (in units of bits/pixel). The function
% receives input via the hgnDataStruct structure. It first calls the contructor
% for the hgnDataClass which validates the fields of the input structure. The
% method histogram_generator is then invoked on the new object to compile
% histograms for a single module output of the differences between the 16-bit
% pixel values (indices of the cadence pixel values in the requantization
% table) and baseline values for a range of baseline intervals.
%
% The uncompressed baseline overhead rate, theoretical compression rate and
% total storage rate are computed from the histogram generated for each
% baseline interval of interest and the best baseline interval/best total
% storage rate are determined.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure hgnDataStruct with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level:
%
%     hgnDataStruct contains the following fields:
%
%         hgnModuleParameters: [struct]  module parameters
%                 fcConstants: [struct]  Fc constants
%                      ccdModule: [int]  CCD module number
%                      ccdOutput: [int]  CCD output number
%         invocationCadenceStart: [int]  first cadence for this invocation
%           invocationCadenceEnd: [int]  last cadence for this invocation
%      firstMatlabInvocation: [logical]  flag to indicate initial run
%                requantTable: [struct]  requantization table
%         cadencePixels: [struct array]  requantized pixels for each cadence
%                      debugFlag: [int]  indicates debug level
%
%--------------------------------------------------------------------------
%   Second level
%
%     hgnDataStruct.hgnModuleParameters is a struct with the following
%     field:
%
%        baselineIntervals: [int array]  intervals for histogram generation
%
%--------------------------------------------------------------------------
%   Second level
%
%     hgnDataStruct.requantTable is a struct with the following fields:
%
%                     externalId: [int]  table ID
%                    startMjd: [double]  table start time, MJD
%           requantEntries: [int array]  requantization table entries
%         meanBlackEntries: [int array]  mean black table entries
%
%--------------------------------------------------------------------------
%   Second level
%
%     hgnDataStruct.cadencePixels is a struct array with the following 
%     fields:
%
%                        cadence: [int]  cadence of pixel values
%              pixelValues: [int array]  requantized pixel values
%        gapIndicators: [logical array]  missing pixel indicators
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:  A data structure hgnResultsStruct with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level:
%
%     hgnResultsStruct contains the following fields:
%
%                      ccdModule: [int]  CCD module number
%                      ccdOutput: [int]  CCD output number
%         invocationCadenceStart: [int]  first cadence for this invocation
%           invocationCadenceEnd: [int]  last cadence for this invocation
%            histograms: [struct array]  histograms for each baseline interval
%     modOutBestBaselineInterval: [int]  best interval for this module output (cadences)
%        modOutBestStorageRate: [float]  minimum storage rate of all intervals (bpp)
%
%--------------------------------------------------------------------------
%   Second level
%
%     hgnResultsStruct.histograms is a struct array with the following 
%     fields:
%
%                    baselineInterval: [int]  interval (cadences)
%  uncompressedBaselineOverheadRate: [float]  overhead for baseline storage (bpp)
%        theoreticalCompressionRate: [float]  entropy computed from histogram (bpp)
%                  totalStorageRate: [float]  storage requirement (bpp)
%                     histogram: [int array]  histogram for Huffman encoding
%
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

% Disable debug mode if flag is not set.
if (isfield(hgnDataStruct, 'debugFlag'))
    debugFlag = hgnDataStruct.debugFlag;
else
    debugFlag = 0;
end

% Check for the presence of expected fields in the input structure, check 
% whether each parameter is within the appropriate range, and create
% hgnDataClass object.
tic
hgnDataObject = hgnDataClass(hgnDataStruct);

duration = toc;
if (debugFlag) 
    display(['Fields validated and hgn object created: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
end

%--------------------------------------------------------------------------
% Generate Huffman histograms for all desired baseline intervals. If this
% is the first Matlab invocation for this module output, histogram values will
% first be initialized to zero. Otherwise, histograms (and other state variables)
% from the previous invocation will be reloaded from the hgn_state.mat file in
% the current working directory. Counts of new Huffman symbols for the current
% cadence range will then be added to the existing histogram values.
tic
[hgnResultsStruct] = histogram_generator(hgnDataObject);

duration = toc;
if (debugFlag) 
    display(['Huffman histograms generated: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
end

% Save the HGN data and results structures if the debugFlag is set. Time
% stamp the debug file.
if (debugFlag)
    dateStr = datestr(now);
    dateStr = strrep(dateStr, '-', '_');
    dateStr = strrep(dateStr, ' ', '_');
    dateStr = strrep(dateStr, ':', '_');
    debugFileName = ['hgn_debug_' dateStr '.mat'];
    save(debugFileName, 'hgnDataStruct', 'hgnResultsStruct');
end

return

