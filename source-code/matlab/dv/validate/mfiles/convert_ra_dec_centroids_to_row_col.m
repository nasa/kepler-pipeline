function rowColCentroids = convert_ra_dec_centroids_to_row_col(raDecCentroids, motionPolynomials)                                                      
% function rowColCentroids = convert_ra_dec_centroids_to_row_col(raDecCentroids, motionPolynomials)  
%
% Transform centroid data in ra/dec coordinates into row/column
% coordinates using motion polynomials. There must be one motion polynomial
% element for every cadence in the UOW. The uncertainties in row and column
% are derived only from the motion polynomial covariance. That is, the
% input ra and dec uncertainties are not propagated.
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


% unpack time series
prfRaVal = raDecCentroids.prf.ra.values;
prfRaGap = raDecCentroids.prf.ra.gapIndicators;
prfDecVal = raDecCentroids.prf.dec.values;
prfDecGap = raDecCentroids.prf.dec.gapIndicators;
fluxWeightedRaVal = raDecCentroids.fluxWeighted.ra.values;
fluxWeightedRaGap = raDecCentroids.fluxWeighted.ra.gapIndicators;
fluxWeightedDecVal = raDecCentroids.fluxWeighted.dec.values;
fluxWeightedDecGap = raDecCentroids.fluxWeighted.dec.gapIndicators;
nCadences = length(prfRaVal);


% allocate memory
prfRowVal = zeros(nCadences,1);
prfRowUnc = zeros(nCadences,1);
prfColVal = zeros(nCadences,1);
prfColUnc = zeros(nCadences,1);
fluxWeightedRowVal = zeros(nCadences,1);
fluxWeightedRowUnc = zeros(nCadences,1);
fluxWeightedColVal = zeros(nCadences,1);
fluxWeightedColUnc = zeros(nCadences,1);


% select cadences with valid motion polys and valid ra and dec centroids
validPrfCentroid = colvec([motionPolynomials.rowPolyStatus]) & colvec([motionPolynomials.colPolyStatus]) & ~prfRaGap(:) & ~prfDecGap(:);
validFluxWeightedCentroid = colvec([motionPolynomials.rowPolyStatus]) & colvec([motionPolynomials.rowPolyStatus]) & ~fluxWeightedRaGap(:) & ~fluxWeightedDecGap(:);

% Unavoidable loops - the motion polynomials only takes one polynomial at a time
% convert prf centroids
for ii=1:nCadences
    if( validPrfCentroid(ii) )        
        [prfRowVal, prfRowUnc] = weighted_polyval2d(prfRaVal,prfDecVal,motionPolynomials(ii).rowPoly);
        [prfColVal, prfColUnc] = weighted_polyval2d(prfRaVal,prfDecVal,motionPolynomials(ii).colPoly);        
    end
end                          

% convert flux weighted centroids
for ii=1:nCadences
    if( validFluxWeightedCentroid(ii) )        
        [fluxWeightedRowVal, fluxWeightedRowUnc] = weighted_polyval2d(fluxWeightedRaVal,fluxWeightedDecVal,motionPolynomials(ii).rowPoly);
        [fluxWeightedColVal, fluxWeightedColUnc] = weighted_polyval2d(fluxWeightedRaVal,fluxWeightedDecVal,motionPolynomials(ii).colPoly);       
    end
end   


% package results into time series for output
rowColCentroids.prf.row.values = prfRowVal;
rowColCentroids.prf.row.uncertainties = prfRowUnc;
rowColCentroids.prf.row.gapIndicators = ~validPrfCentroid;
rowColCentroids.prf.col.values = prfColVal;
rowColCentroids.prf.col.uncertainties = prfColUnc;
rowColCentroids.prf.col.gapIndicators = ~validPrfCentroid;
rowColCentroids.fluxWeighted.row.values = fluxWeightedRowVal;
rowColCentroids.fluxWeighted.row.uncertainties = fluxWeightedRowUnc;
rowColCentroids.fluxWeighted.row.gapIndicators = ~validFluxWeightedCentroid;
rowColCentroids.fluxWeighted.col.values = fluxWeightedColVal;
rowColCentroids.fluxWeighted.col.uncertainties = fluxWeightedColUnc;
rowColCentroids.fluxWeighted.col.gapIndicators = ~validFluxWeightedCentroid;
