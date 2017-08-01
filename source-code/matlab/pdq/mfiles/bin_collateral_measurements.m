function pdqTempStruct = bin_collateral_measurements(pdqTempStruct, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct = bin_collateral_measurements(pdqTempStruct, cadenceIndex)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description:
%   This function bins the black pixels (if they come from more than one
%   column) and virtual smear and masked smear (if they come from more than
%   one row) into one column or one row as the case may be. Propagates
%   uncertainty from raw black measurements to binned black measurements.
%
% Inputs:
% pdqTempStruct = (only relevant fields are listed)
%                      bkgdPixels: [100x4 double]
%                   bkgdPixelRows: [100x1 double]
%                bkgdPixelColumns: [100x1 double]
%                   bkgdFlatField: [100x4 double]
%               bkgdGapIndicators: [100x4 logical]
%                     blackPixels: [362x4 double]
%                       blackRows: [362x1 double]
%                    blackColumns: [362x1 double]
%              blackGapIndicators: [362x4 logical]
%                    msmearPixels: [370x4 double]
%                      msmearRows: [370x1 double]
%                   msmearColumns: [370x1 double]
%             msmearGapIndicators: [370x4 logical]
%                    vsmearPixels: [370x4 double]
%                      vsmearRows: [370x1 double]
%                   vsmearColumns: [370x1 double]
%             vsmearGapIndicators: [370x4 logical]
%
% pdqTempStruct = (added fields only..)
%                        binnedBlackPixels: [362x4 double]
%                      blackPixelsInRowBin: [362x4 double]
%                 binnedBlackGapIndicators: [362x4 double]
%                          binnedBlackRows: [362x4 double]
%                        binnedBlackColumn: [4x1 double]
%                       binnedMsmearPixels: [370x4 double]
%                  msmearPixelsInColumnBin: [370x4 double]
%                binnedMsmearGapIndicators: [370x4 double]
%                          binnedMsmearRow: [4x1 double]
%                      binnedMsmearColumns: [370x4 double]
%                 numberOfMsmearRowsBinned: [1 1 1 1]
%                       binnedVsmearPixels: [370x4 double]
%                  vsmearPixelsInColumnBin: [370x4 double]
%                binnedVsmearGapIndicators: [370x4 double]
%                          binnedVsmearRow: [4x1 double]
%                      binnedVsmearColumns: [370x4 double]
%                 numberOfVsmearRowsBinned: [1 1 1 1]
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


pdqTempStruct = bin_black_measurements(pdqTempStruct, cadenceIndex);

pdqTempStruct = bin_smear_measurements(pdqTempStruct, cadenceIndex);


%validBlackPixelIndices = find(~pdqTempStruct.blackGapIndicators(:,cadenceIndex), 1);



% if(~isempty(validBlackPixelIndices))
%     pdqTempStruct = bin_black_measurements(pdqTempStruct, cadenceIndex);
% end




% validMsmearPixelIndices = find(~pdqTempStruct.msmearGapIndicators(:,cadenceIndex), 1);
% validVsmearPixelIndices = find(~pdqTempStruct.vsmearGapIndicators(:,cadenceIndex), 1);
% 
% 
% if(~isempty(validMsmearPixelIndices) || ~isempty(validVsmearPixelIndices))
%     pdqTempStruct = bin_smear_measurements(pdqTempStruct, cadenceIndex);
% end

return

