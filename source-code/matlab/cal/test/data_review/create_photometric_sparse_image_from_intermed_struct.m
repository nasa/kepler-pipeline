function create_photometric_sparse_image_from_intermed_struct(calIntermediateStruct, oneOrZeroBaseString, plotFlag)
%
% function to create 2D image of available target pixels from a CAL
% intermediateStruct
%
% example:
% create_photometric_sparse_image_from_intermed_struct(inputsStruct, 'oneBase', true)
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


inputTargetPixels = calIntermediateStruct.photometricPixels;
inputTargetGaps   = calIntermediateStruct.photometricGaps;

if strcmpi(oneOrZeroBaseString, 'oneBase')
    
    targetCols = calIntermediateStruct.photometricColumns;
    targetRows = calIntermediateStruct.photometricRows;
else    
    targetCols = calIntermediateStruct.photometricColumns+1;
    targetRows = calIntermediateStruct.photometricRows+1;
end


cadences   = calIntermediateStruct.nCadences;



% set gaps to nans to take nanmedian
inputTargetPixelsGapNans = inputTargetPixels;

inputTargetPixelsGapNans(inputTargetGaps)=nan;

medianInputTargetPixelsGapNans = nanmedian(inputTargetPixelsGapNans);


% % set nans to zeros
% medianInputTargetPixelsGapZeros = medianInputTargetPixelsGapNans;
% medianInputTargetPixelsGapZeros(medianInputTargetPixelsGapZeros==nan) = 0;

if strcmpi(oneOrZeroBaseString, 'oneBase')
    sparseInputPixels = sparse(targetRows,targetCols,medianInputTargetPixelsGapNans, max(targetRows), 1132);
else
    sparseInputPixels = sparse(targetRows,targetCols,medianInputTargetPixelsGapNans, max(targetRows)+1, 1132);
end


figure; imagesc(sparseInputPixels)
colorbar
title(['Channel ' num2str(channel) ': Target Pixels (med over time)'])
ylabel('Row Index')
xlabel('Column Index')

if plotFlag
    dateString = datestr(now);
    dateString = strrep(dateString, '-', '_');
    dateString = strrep(dateString, ' ', '_');
    dateString = strrep(dateString, ':', '_');
    
    plot_to_file(['~/inputTargets_' dateString], false);
end


return;
