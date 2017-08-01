function chiSquareResultsStruct = compute_chisquare_veto( superResolutionObject, ...
    nCadences, validSesIndex, deemphasisWeights, deemphasisWeightsSuperResolution, ...
    chiSquareResultsStruct )

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [tpsResults,chiSquare1Ok,chiSquare2Ok] = compute_chisquare_veto( tpsResults, ...
%    tpsModuleParameters, foldingParameterStruct, multipleEventStatistic )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Decription: This function computes various chi-square vetos and applies
%             thresholds to veto or pass the event in tpsResults.
% 
%
% Inputs:
%
% Outputs:
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

% initialize output if necessary
if ~exist('chiSquareResultsStruct', 'var') || isempty(chiSquareResultsStruct)
    chiSquareResultsStruct = struct('chiSquare1', [], 'chiSquare2', [], 'chiSquare3', ...
        [], 'chiSquare4', [], 'chiSquare5', [], 'chiSquare6', [], 'chiSquare7', [], ...
        'chiSquare8', [], 'chiSquare9', [], 'chiSquare10', [], 'chiSquareGof', [], ...
        'chiSquareDof1', [], 'chiSquareDof2', [], 'chiSquareDof3', [], 'chiSquareDof4', ...
        [], 'chiSquareDof5', [], 'chiSquareDof6', [], 'chiSquareDof7', [], 'chiSquareDof8', ...
        [], 'chiSquareDof9', [], 'chiSquareDof10', [], 'chiSquareGofDof', [], ...
        'normCompSum', [], 'zCompSum', [], 'sesProbability', [], 'sesProbabilityDof', ...
        [], 'fittedDepthChi', [] );
end

% hardcode the mismatch for DOF correction of chiSquare2
epsilon = 0.04;

% unpack inputs
waveletObject = get(superResolutionObject, 'waveletObject') ;
mScale = get( waveletObject, 'filterScale' ) ;
nTransits = length(validSesIndex) ;

% compute the statistics
[corrComponentsHiRes, normComponentsHiRes, corrComponentsSinglePulseHiRes, ...
    normComponentsSinglePulseHiRes, corrComponentsTimeDomain, normComponentsTimeDomain, ...
    xTimeDomain, sTimeDomain, inTransitWeights] =  ...
    compute_hires_statistics_components( superResolutionObject, validSesIndex, ...
    nCadences, deemphasisWeightsSuperResolution, deemphasisWeights) ;
  
% compute the chi square statistics

% chi1
zComponents = bsxfun(@rdivide,corrComponentsHiRes,sqrt(sum(normComponentsHiRes,2)));
qComponents = bsxfun(@rdivide,normComponentsHiRes,sum(normComponentsHiRes,2));
deltaZ = zComponents - bsxfun(@times,qComponents,sum(zComponents,2));
chiSquare = (deltaZ.^2)./qComponents;
chiSquareResultsStruct.chiSquare1 = sum(chiSquare(:)); % P(M-1)

% chi2
zComponents = sum(corrComponentsTimeDomain,1)/sqrt(sum(normComponentsTimeDomain(:)));
qComponents = sum(normComponentsTimeDomain,1)/sum(normComponentsTimeDomain(:));
deltaZ = zComponents - qComponents*sum(zComponents);
chiSquare = (deltaZ.^2)./qComponents;
chiSquareResultsStruct.chiSquare2 = sum(chiSquare); % P-1

% chi3
zComponents = sum(corrComponentsHiRes,1)/sqrt(sum(normComponentsHiRes(:)));
qComponents = sum(normComponentsHiRes,1)/sum(normComponentsHiRes(:));
deltaZ = zComponents - qComponents*sum(zComponents);
chiSquare = (deltaZ.^2)./qComponents;
chiSquareResultsStruct.chiSquare3 = sum(chiSquare); % M-1

% chi4
zComponents = bsxfun(@rdivide, corrComponentsTimeDomain ,sqrt(sum(normComponentsTimeDomain,1)));
qComponents = bsxfun(@rdivide, normComponentsTimeDomain ,sum(normComponentsTimeDomain,1));
deltaZ = zComponents - bsxfun(@times,qComponents,sum(zComponents,1));
chiSquare = (deltaZ.^2)./qComponents;
chiSquare(isnan(chiSquare)) = 0;
chiSquareResultsStruct.chiSquare4 = sum(chiSquare(:)); % P(D-1)

% chi5
zComponents = bsxfun(@rdivide,sum(corrComponentsSinglePulseHiRes,1) ,sqrt(sum(sum(normComponentsSinglePulseHiRes,1),3)));
qComponents = bsxfun(@rdivide,sum(normComponentsSinglePulseHiRes,1) ,sum(sum(normComponentsSinglePulseHiRes,1),3));
deltaZ = zComponents - bsxfun(@times,qComponents,sum(zComponents,3));
chiSquare = (deltaZ.^2)./qComponents;
chiSquare(isnan(chiSquare)) = 0;
chiSquareResultsStruct.chiSquare5 = sum(chiSquare(:)); % P(M-1)

% chi6
zComponents = bsxfun(@rdivide, corrComponentsTimeDomain ,sqrt(sum(normComponentsTimeDomain,2)));
qComponents = bsxfun(@rdivide, normComponentsTimeDomain ,sum(normComponentsTimeDomain,2));
deltaZ = zComponents - bsxfun(@times,qComponents,sum(zComponents,2));
chiSquare = (deltaZ.^2)./qComponents;
chiSquare(isnan(chiSquare)) = 0;
chiSquareResultsStruct.chiSquare6 = sum(chiSquare(:)); % D(P-1)

% chi7
zComponents = bsxfun(@rdivide,sum(corrComponentsSinglePulseHiRes,2) ,sqrt(sum(sum(normComponentsSinglePulseHiRes,2),3)));
qComponents = bsxfun(@rdivide,sum(normComponentsSinglePulseHiRes,2) ,sum(sum(normComponentsSinglePulseHiRes,2),3));
deltaZ = zComponents - bsxfun(@times,qComponents,sum(zComponents,3));
chiSquare = (deltaZ.^2)./qComponents;
chiSquare(isnan(chiSquare)) = 0;
chiSquareResultsStruct.chiSquare7 = sum(chiSquare(:)); % D(M-1)

% chi8
zComponents = bsxfun(@rdivide,sum(corrComponentsSinglePulseHiRes,2) ,sqrt(sum(sum(normComponentsSinglePulseHiRes,2),1)));
qComponents = bsxfun(@rdivide,sum(normComponentsSinglePulseHiRes,2) ,sum(sum(normComponentsSinglePulseHiRes,2),1));
deltaZ = zComponents - bsxfun(@times,qComponents,sum(zComponents,1));
chiSquare = (deltaZ.^2)./qComponents;
chiSquare(isnan(chiSquare)) = 0;
chiSquareResultsStruct.chiSquare8 = sum(chiSquare(:)); % M(D-1)

% chi9
zComponents = bsxfun(@rdivide,sum(corrComponentsSinglePulseHiRes,1) ,sqrt(sum(sum(normComponentsSinglePulseHiRes,1),2)));
qComponents = bsxfun(@rdivide,sum(normComponentsSinglePulseHiRes,1) ,sum(sum(normComponentsSinglePulseHiRes,1),2));
deltaZ = zComponents - bsxfun(@times,qComponents,sum(zComponents,2));
chiSquare = (deltaZ.^2)./qComponents;
chiSquare(isnan(chiSquare)) = 0;
chiSquareResultsStruct.chiSquare9 = sum(chiSquare(:)); % M(P-1)

% chi10
zComponents = sum(corrComponentsTimeDomain,2)/sqrt(sum(normComponentsTimeDomain(:)));
qComponents = sum(normComponentsTimeDomain,2)/sum(normComponentsTimeDomain(:));
zComponents = zComponents( qComponents ~= 0 );
qComponents = qComponents( qComponents ~= 0 );
deltaZ = zComponents - qComponents*sum(zComponents);
chiSquare = (deltaZ.^2)./qComponents;
chiSquareResultsStruct.chiSquare10 = sum(chiSquare); % D-1

% goodness of fit version of the chi-square
chiSquareResultsStruct.chiSquareGof = xTimeDomain' * xTimeDomain - ( xTimeDomain' * sTimeDomain / norm(sTimeDomain) )^2;

% get the correlation/normalization sums
corrComponentsTimeDomain = ( sum(corrComponentsTimeDomain,1) )';
normComponentsTimeDomain = ( sum(normComponentsTimeDomain,1) )';
chiSquareResultsStruct.normCompSum = sum(normComponentsTimeDomain);
zCompSum = sum(sum(corrComponentsTimeDomain,1)/sqrt(sum(normComponentsTimeDomain(:))));
chiSquareResultsStruct.zCompSum = zCompSum;

% compute the ndof values and put into results
nCadencesInTransit1 = sum(sum(corrComponentsSinglePulseHiRes,3) ~= 0, 1) ;
nCadencesInTransit2 = sum(sum(corrComponentsSinglePulseHiRes,3) ~= 0, 2) ;
nCadencesInTransit3 = sum(sum(corrComponentsSinglePulseHiRes,2) ~= 0,3) ;
nCadencesInTransit4 = sum(squeeze(sum(corrComponentsSinglePulseHiRes,2)) ~= 0, 1) ;

chiSquareResultsStruct.chiSquareDof1 = nTransits * (mScale - 1) ;
chiSquareResultsStruct.chiSquareDof2 = nTransits - 1 + epsilon * (2 - epsilon)/((1-epsilon)^2) * zCompSum^2 ;
chiSquareResultsStruct.chiSquareDof3 = mScale - 1 ;
chiSquareResultsStruct.chiSquareDof4 = sum( nCadencesInTransit1 - 1 ) ; 
chiSquareResultsStruct.chiSquareDof5 = nTransits * (mScale - 1) ;
chiSquareResultsStruct.chiSquareDof6 = sum( nCadencesInTransit2 - 1 ) ;
chiSquareResultsStruct.chiSquareDof7 = sum( nCadencesInTransit3 - 1 ) ;
chiSquareResultsStruct.chiSquareDof8 = sum( nCadencesInTransit4 - 1 ) ;
chiSquareResultsStruct.chiSquareDof9 = mScale * (nTransits - 1) ;
chiSquareResultsStruct.chiSquareDof10 = mean(nCadencesInTransit1) - 1 ;
chiSquareResultsStruct.chiSquareGofDof = sum( inTransitWeights ~= 0 ) - 1;

% compute the sesProbability and store it    
validSes2 = corrComponentsTimeDomain./sqrt(normComponentsTimeDomain) ;
fittedDepthChi = sum(corrComponentsTimeDomain)/sum(normComponentsTimeDomain);
validSesDelta = validSes2 - fittedDepthChi * sqrt(normComponentsTimeDomain) ;
validSesDelta = sum( (validSesDelta.^2)./( fittedDepthChi * sqrt(normComponentsTimeDomain) ) );

chiSquareResultsStruct.sesProbability = validSesDelta ;  
chiSquareResultsStruct.sesProbabilityDof = nTransits - 1 ;
chiSquareResultsStruct.fittedDepthChi = fittedDepthChi;

return