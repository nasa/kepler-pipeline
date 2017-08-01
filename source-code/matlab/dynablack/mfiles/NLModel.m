function estimatedValue = NLModel(b, X)
%{
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
NLModel -- a non-linear model for use with nlinfit routine 
           in the MATLAB statistics toolbox
 The nonlinear part of this model is for row dependence of serial pixels

     The predictor matrix X may have any number of columns with the
     following constraints:
        X(:,1) contains the row numbers, counting from 1, of each ARP or
               collateral datum.
        X(:,2) contains ones for all ARP and collateral data.
        X(:,3) contains ones for all ARP data and the number of 
               trailing black collateral columns selected in the S/C 
               configuration table.
        X(:,2:end) are all modeled linearly

     The coefficient vector b must have 2 more elements than X has columns. 
     The first 3 elements of b are nonlinear coefficients:
        b(1) is the scale factor for the low row exponential term.
        b(2) is the time constant in units of 1/rows for the low row 
             exponential term
        b(3) is the scale factor for the row logarithmic term. 
        b(4:end) are all linear coefficients for the predictors X(:,2:end)
%}
%   Revision History:
%
%       Version 0 - 9/10/09     released for review and comment
%{
Author Info LaTeX:
\author{JEFFERY J. KOLODZIEJCZAK}
\address{ NASA / Marshall Space Flight Center,
National Space Science and Technology Center\\
320 Sparkman Drive,
VP 62,
Huntsville, AL 35805\\
office: 256-961-7775\\
\texttt{Jeffery.Kolodziejczak-1@nasa.gov}}
%}

%   globals 

thermalRowOffset = 214;
minScienceRow = 21;

v0 = X(:,2:end)*b(4:end)'; % LINEAR TERMS
v1 = b(1).*X(:,3).*exp(-(X(:,1) - minScienceRow).*b(2)) + b(3).*X(:,3).*log((X(:,1)./thermalRowOffset) + 1); % NONLINEAR TERMS
 
% X(:,3) simply scales the terms to the appropriate number of pixels
% represented by the corresponding data (1 for ARP; nominally 14 for
% trailing black collateral)

estimatedValue = v0 + v1;

end
