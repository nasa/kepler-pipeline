function [hacResultsStruct] = hac_matlab_controller(hacDataStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [hacResultsStruct] = hac_matlab_controller(hacDataStruct)
%
% This function forms the MATLAB side of the science interface for Huffman
% histogram accumulation and computation of theoretical compression performance
% and data storage/transmission rate (in units of bits/pixel). The function
% receives input via the hacDataStruct structure. It first calls the contructor
% for the hacDataClass which validates the fields of the input structure. The
% method histogram_accumulator is then invoked on the new object to accumulate
% histograms for all module outputs. This hac_matlab_controller function
% must be executed once for each module output.
%
% The uncompressed baseline overhead rate, theoretical compression rate and
% total storage rate are computed from the histogram accumulated for each
% baseline interval of interest and the best baseline interval/best total
% storage rate are determined.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure hacDataStruct with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level:
%
%     hacDataStruct contains the following fields:
%
%                 fcConstants: [struct]  Fc constants
%            invocationCcdModule: [int]  CCD module for this invocation
%            invocationCcdOutput: [int]  CCD output for this invocation
%                   cadenceStart: [int]  first cadence for histograms
%                     cadenceEnd: [int]  last cadence for histograms
%      firstMatlabInvocation: [logical]  flag to indicate initial run
%            histograms: [struct array]  histograms for each baseline interval
%                      debugFlag: [int]  indicates debug level
%
%--------------------------------------------------------------------------
%   Second level
%
%     hacDataStruct.histograms is a struct array with the following 
%     fields:
%
%                    baselineInterval: [int]  interval (cadences)
%  uncompressedBaselineOverheadRate: [float]  overhead for baseline storage (bpp)
%        theoreticalCompressionRate: [float]  entropy computed from histogram (bpp)
%                  totalStorageRate: [float]  total storage requirement (bpp)
%                     histogram: [int array]  histogram for Huffman encoding
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:  A data structure hacResultsStruct with the following fields.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level:
%
%     hacResultsStruct contains the following fields:
%
%            invocationCcdModule: [int]  CCD module for this invocation
%            invocationCcdOutput: [int]  CCD output for this invocation
%                   cadenceStart: [int]  first cadence for histograms
%                     cadenceEnd: [int]  last cadence for histograms
%            histograms: [struct array]  histograms for each baseline interval
%    overallBestBaselineInterval: [int]  best interval for all mod outputs (cadences)
%       overallBestStorageRate: [float]  minimum storage rate for all intervals (bpp)
%
%--------------------------------------------------------------------------
%   Second level
%
%     hacDataStruct.histograms is a struct array with the following 
%     fields:
%
%                    baselineInterval: [int]  interval (cadences)
%  uncompressedBaselineOverheadRate: [float]  overhead for baseline storage (bpp)
%        theoreticalCompressionRate: [float]  entropy computed from histogram (bpp)
%                  totalStorageRate: [float]  total storage requirement (bpp)
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
if (isfield(hacDataStruct, 'debugFlag'))
    debugFlag = hacDataStruct.debugFlag;
else
    debugFlag = 0;
end

% Check for the presence of expected fields in the input structure, check 
% whether each parameter is within the appropriate range, and create
% hacDataClass object.
tic
hacDataObject = hacDataClass(hacDataStruct);

duration = toc;
if (debugFlag) 
    display(['Fields validated and hac object created: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
end

%--------------------------------------------------------------------------
% Accumulate Huffman histograms for all desired baseline intervals. If this
% is the first Matlab invocation for this module output, accumulated histogram
% values will first be initialized to zero. Otherwise, accumulated histograms
% (and other state variables) from the previous invocation will be reloaded
% from the hac_state.mat file in the current working directory. New Huffman
% histograms for the current module output will then be added to the existing
% histogram values.
tic
[hacResultsStruct] = histogram_accumulator(hacDataObject);

duration = toc;
if (debugFlag) 
    display(['Huffman histograms accumulated: ' num2str(duration) ...
        ' seconds = '  num2str(duration/60) ' minutes']);
end

% Save the HAC data and results structures if the debugFlag is set. Time
% stamp the debug file.
if (debugFlag)
    dateStr = datestr(now);
    dateStr = strrep(dateStr, '-', '_');
    dateStr = strrep(dateStr, ' ', '_');
    dateStr = strrep(dateStr, ':', '_');
    debugFileName = ['hac_debug_' dateStr '.mat'];
    save(debugFileName, 'hacDataStruct', 'hacResultsStruct');
end

% Return.
return

