function [ fullSpatialModelA spatialModelA ] = change_time_constant( fullSpatialModelA, rowTimeConstant, Inputs )
%
% function [ fullSpatialModelA spatialModelA ] = change_time_constant( fullSpatialModelA, rowTimeConstant, Inputs )
% 
% This function updates the exponential term of the serial (row) model component with a new exponential time constant for a specified channel.
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

disp(['     Rebuilding spatial models with rowTimeConstant = ',num2str(rowTimeConstant)]);

maxMaskedSmearRow = Inputs.constants.maxMaskedSmearRow;
minScienceRow = maxMaskedSmearRow + 1;

rowModel              = Inputs.row_model;
leadingArp            = Inputs.ROI.leadingArp;
trailingArp           = Inputs.ROI.trailingArp;
trailingArpUndershoot = Inputs.ROI.trailingArpUs;
trailingCollateral    = Inputs.ROI.trailingCollat;

allpix_const = [leadingArp.Rows' > maxMaskedSmearRow ...
                trailingArp.Rows' > maxMaskedSmearRow ...
                trailingArpUndershoot.Rows' > maxMaskedSmearRow ...
                (trailingCollateral.Rows' > maxMaskedSmearRow) .* trailingCollateral.Column_count];

allPixelsExponentialRow   = [exp(-(leadingArp.Rows' - minScienceRow)./rowTimeConstant) ...
                                exp(-(trailingArp.Rows' - minScienceRow)./rowTimeConstant) ...
                                exp(-(trailingArpUndershoot.Rows' - minScienceRow)./rowTimeConstant) ...
                                exp(-(trailingCollateral.Rows' - minScienceRow)./rowTimeConstant)].*allpix_const;
                            
leadingPixelsExponentialRow  = [exp( -(leadingArp.Rows' - minScienceRow)./rowTimeConstant ) ...
                                  zeros( 1, trailingArp.Datum_count) ...
                                  zeros( 1, trailingArpUndershoot.Datum_count) ... 
                                  zeros( 1, trailingCollateral.Datum_count)].*allpix_const;
                            
                            
rowPredictorRange = 1:rowModel.Predictor_count;
allExponentialRowIndicator = rowPredictorRange(rowModel.Subset_predictor_index) == 5;       % 5th column is base exponential term
leadingExponentialRowIndicator = rowPredictorRange(rowModel.Subset_predictor_index) == 8;   % 8th column is leading-trailing delta

fullSpatialModelA(:,allExponentialRowIndicator) = allPixelsExponentialRow';
fullSpatialModelA(:,leadingExponentialRowIndicator) = leadingPixelsExponentialRow';

spatialModelA = fullSpatialModelA(rowModel.Subset_datum_index,:);
