function [rowValue, rowUncertainty, columnValue, columnUncertainty, ...
rowColumnCovariance] = ...
transform_kic_position_to_fpa_coordinates(raDegrees, decDegrees, ...
motionPolyStruct, transformationCadenceIndices)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [rowValue, rowUncertainty, columnValue, columnUncertainty, ...
% rowColumnCovariance] = ...
% transform_kic_position_to_fpa_coordinates(raDegrees, decDegrees, ...
% motionPolyStruct, transformationCadenceIndices)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Estimate the mean CCD coordinates for a target with given RA and DEC (in
% units of degrees) by evaluating the motion polynomials on the given
% cadences. Set the uncertainty in the mean row and column coordinates to
% to be the RMS uncertainty of the evaluated row and column motion
% polynomials. Assume that there are no uncertainties in the KIC RA/DEC
% coordinates. Set default output values if the RA and or DEC are undefined
% or there are no cadence indices specified for the transformation.
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

% Set constant.
GAP_VALUE = -1;

% Evaluate the motion polynomials for the given cadences and compute the
% mean row/column position (one-based) of the target and the associated RMS
% uncertainty.
if ~isnan(raDegrees) && ~isnan(decDegrees) && ...
        ~isempty(transformationCadenceIndices)
    
    predictedRows = zeros([length(motionPolyStruct), 1]);
    predictedColumns = zeros([length(motionPolyStruct), 1]);
    predictedRowUncertainties = ...
        zeros([length(motionPolyStruct), 1]);
    predictedColumnUncertainties = ...
        zeros([length(motionPolyStruct), 1]);

    for iCadence = transformationCadenceIndices( : )'
        [predictedRows(iCadence), predictedRowUncertainties(iCadence)] = ...
            weighted_polyval2d(raDegrees, decDegrees, ...
            motionPolyStruct(iCadence).rowPoly);
        [predictedColumns(iCadence), predictedColumnUncertainties(iCadence)] = ...
            weighted_polyval2d(raDegrees, decDegrees, ...
            motionPolyStruct(iCadence).colPoly);
    end % for iCadence

    rowValue = mean(predictedRows(transformationCadenceIndices));
    columnValue = mean(predictedColumns(transformationCadenceIndices));
    rowUncertainty = ...
        sqrt(mean(predictedRowUncertainties(transformationCadenceIndices) .^ 2));
    columnUncertainty = ...
        sqrt(mean(predictedColumnUncertainties(transformationCadenceIndices) .^ 2));
    rowColumnCovariance = ...
        diag([rowUncertainty^2, columnUncertainty^2]);
    
else
    
    rowValue = 0;
    rowUncertainty = GAP_VALUE;
    columnValue = 0;
    columnUncertainty = GAP_VALUE;
    rowColumnCovariance = diag([GAP_VALUE, GAP_VALUE]);
    
end % if / else

% Return.
return
