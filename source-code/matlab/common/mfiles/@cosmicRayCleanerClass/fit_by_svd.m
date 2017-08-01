function X = fit_by_svd(A, Y)
%**************************************************************************
% function X = fit_by_svd(A, Y)
%**************************************************************************
% Explicitly use singular value decomposition to fit a design matrix to
% data in the least squares sense. 
%
% INPUTS:
%     A : An MxN design matrix of basis (column) vectors.
%     Y : An MxP matrix of column vectors containing the data to be fit.
%
% OUTPUTS:
%     X : The NxP least squares solution to the equation Y = AX. Elements  
%         of X are set to zeros if A has insufficent rank or no good
%         singular vectors. 
%
% NOTES:
%     This code was borrowed from weighted_polyfit.m
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
    nBasisVectors = size(A,2);
    nDataVectors  = size(Y,2);

    [U S V] = svd(A, 0);
    S = diag(S);
    Si = zeros(size(S));
    if max(S) > 0
        good_sv_index = find(S/max(S)>1e-9); % find good singular values
    else
        % if there are no entries bail with an invalid polynomial
        %message = 'empty diagonal matrix in SVD';
        X = zeros(nBasisVectors, nDataVectors);
        return;
    end
    % check the rank
    rankA = length(good_sv_index);
    % if the rank is less than the degrees of freedom bail out with an
    % invalid polynomial
    if rankA < size(A, 2)
        %message = 'rank less than degrees of freedom';
        X = zeros(nBasisVectors, nDataVectors);
        return;
    end
    if ~isempty(S(good_sv_index))
        Si(good_sv_index) = 1./S(good_sv_index); % invert the good singular 
                                                 % values.
    else
        error('cosmicRayCleanerClass:fit_by_svd', ...
              'S(good_sv_index) is empty');
    end
    X = V*diag(Si)*U'*Y;
end

%********************************** EOF ***********************************