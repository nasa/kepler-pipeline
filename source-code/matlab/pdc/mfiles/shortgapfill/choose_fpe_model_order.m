%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [modelOrderFPE, FPE, g, e] = choose_fpe_model_order( inputTimeSeries,maxAROrder)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This function implements the Akaike's AR Model selection based on the Final
% Prediction Error
%
% Reference: Peter J. Brockwell and Richard A. Davis, "Introduction to Time
% Series and Forecasting ", Springer, 2002 pages 170 -171
%
% The FPE criterion was developed by Akaike (1969) to select the
% appropriate order p of an AR process to fit a time series[x1, x2, ..xn].
% Instead of trying to choose p to make the estimated white noise variance
% as small as possible, the idea is to choose the model for {Xn} in such a
% way as to minimize the one-step MSE when the model fitted to {Xn} is used
% to predict an independent realization {Yn} of the same process that
% generated {Xn}.
%
% Inputs:
%       modelOrderAR - choose AR model order for the input
%       maxAROrder - maximum AR model order that an independent realization
%                    will be fitted with
% Outputs:
%       modelOrderFPE - model order based on minimum mean FPE
%       FPE - final mean square one step prediction error averaged over the
%             ensemble, a vector of length maxAROrder
%       g   - reflection coefficients for AR models up to maxAROrder
%       e   - original modeling error from autoregressburg_modified (one
%             for each order)
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
function [modelOrderFPE, FPE, g, e] = choose_fpe_model_order( inputTimeSeries,maxAROrder)


inputTimeSeries = inputTimeSeries - mean(inputTimeSeries);
nLength = length(inputTimeSeries);


%   ARBURG   AR parameter estimation via Burg method.
%   A = ARBURG(X,ORDER) returns the polynomial A corresponding to the AR
%   parametric signal model estimate of vector X using Burg's method.
%   ORDER is the model order of the AR system.
%
%   [A,E] = ARBURG(...) returns the final prediction error E (the variance
%   estimate of the white noise input to the AR model).


[a, e, g] = autoregressburg_modified(inputTimeSeries,maxAROrder); % invoke the modified built-in function



e = e(2:end)';


% FPE(p) is the one-step prediction error we would see on an
% independent realization generated when a white noise process (mean 0,
% var = e) is filtered by an AR(p) process. For derivation, see
% reference listed above.

FPE = e.*(nLength+(1:maxAROrder)')./(nLength-(1:maxAROrder)');



[val, modelOrderFPE] = min(FPE);


return;

