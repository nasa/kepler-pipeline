function kernel = compute_dog_filter(kernelWidth, params)
%**************************************************************************
% kernel = compute_dog_filter(kernelWidth, params)
%**************************************************************************
% Compute a difference of Gaussians (DoG) filter.
%
% INPUTS
%    params  : A 6- or 8-element parameter vector.
%              params(1) Mixing coefficient for the two Gaussians.
%              params(2) Standard deviation of g1 in the row direction.
%              params(3) Standard deviation of g1 in the column direction.
%              params(4) Proportionality constant determining standard
%                        deviation of g2 in the row direction.
%              params(5) Proportionality constant determining standard
%                        deviation of g2 in the column direction.
%              params(6) Correlation coefficient in the range [-1.0, 1.0].
%                        Same for both g1 and g2.
%              params(7) Fractional row position of the centroid (OPTIONAL)
%              params(8) Fractional column position of the centroid (OPTIONAL)
%
% OUTPUTS
%     kernel : A kernelWidth-by-kernelWidth matrix containing the
%              difference of two sampled 2D Gaussian functions.
%
%              kernel(r,c) = (a + 1) * g1(r,c) - a * g2(r,c)   
%
%              
%              g1(v) = b(C1) * exp(-0.5 * (v - mu)' * inv(C1) * (v - mu))
%              g2(v) = b(C2) * exp(-0.5 * (v - mu)' * inv(C2) * (v - mu))
%                            
%              b(C) = 1 / (2 * pi * sqrt( det(C) ) )
%
%              C1 = [ stdRow^2,          p*stdRow*stdCol ]
%                   [ p*stdRow*stdCol,   stdCol^2        ]
%
%              C2 = K .* C1
%
%              K  = [ kRow^2,      kRow*kCol ]
%                   [ kRow*kCol,   kCol^2    ]
%              
%              a      : Mixing coefficient for the two Gaussians.
%              v      : A (row, col) vector
%              mu     : The mean (row,col) position vector
%              C1     : Covariance matrix of g1.
%              C2     : Covariance matrix of g2.
%              stdRow : Standard deviation of g1 in the row direction.
%              stdCol : Standard deviation of g1 in the column direction.
%              kRow   : Proportionality constant relating the standard
%                       deviation of g2 in the row direction to that of g1.
%              kCol   : Proportionality constant relating the standard
%                       deviation of g2 in the column direction to that of
%                       g1. 
%              p      : Correlation coefficient in the range [-1.0, 1.0].
%                       Same for both g1 and g2.
%
%              Rows and column variables are assumed to be continuous and
%              real-valued unless otherwise stated.
%**************************************************************************
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
    a      = params(1); % Mixing coefficient for the two Gaussians.
    stdRow = params(2); % Standard deviation of g1 in the row direction.
    stdCol = params(3); % Standard deviation of g1 in the column dir
    kRow   = params(4); % Proportionality constant.
    kCol   = params(5); % Proportionality constant.
    p      = params(6); % Correlation coefficient in the range [-1.0, 1.0].

    if length(params) > 6
        centerRow = params(7);
    else
        centerRow = ceil(kernelWidth/2);
    end

    if length(params) > 7
        centerCol = params(8);
    else
        centerCol = ceil(kernelWidth/2); 
    end
    
    g1 = staticKernelClass.compute_gaussian_filter(kernelWidth, ...
        [stdRow, stdCol, p, centerRow, centerCol]);
    g2 = staticKernelClass.compute_gaussian_filter(kernelWidth, ...
        [kRow*stdRow, kCol*stdCol, p, centerRow, centerCol]);
    kernel = (a+1) * g1 - a * g2;
    
end
%********************************** EOF ***********************************

