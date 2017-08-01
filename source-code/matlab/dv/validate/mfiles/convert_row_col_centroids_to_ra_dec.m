function raDecCentroids = convert_row_col_centroids_to_ra_dec(targetStruct,...
                                                                motionPolynomials,...
                                                                fcConstants)
%
% function raDecCentroids = convert_row_col_centroids_to_ra_dec(targetStruct,...
%                                                                 motionPolynomials,...
%                                                                 fcConstants)
%
%
%
% Transform the raw centroid data from row/column coordinates (1-based
% pixels) into ra/dec coordinates (degrees) using inverse motion
% polynomials. There must be one motion polynomial element for every
% cadence in the UOW. The incoming raw centroid timeseries are parsed from
% the targetStruct and the converted timeseries are returned in
% raDecCentroids as:
%
% raDecCentroids.prf.ra.values
%                      .uncertainties
%                      .gapIndicators
% raDecCentroids.prf.dec.values
%                       .uncertainties
%                       .gapIndicators
% raDecCentroids.fluxWeighted.ra.values
%                               .uncertainties
%                               .gapIndicators
% raDecCentroids.fluxWeighted.dec.values
%                                .uncertainties
%                                .gapIndicators
%
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
prfRowVal = targetStruct.centroids.prfCentroids.rowTimeSeries.values;
prfRowUnc = targetStruct.centroids.prfCentroids.rowTimeSeries.uncertainties;
prfRowGap = targetStruct.centroids.prfCentroids.rowTimeSeries.gapIndicators;

prfColVal = targetStruct.centroids.prfCentroids.columnTimeSeries.values;
prfColUnc = targetStruct.centroids.prfCentroids.columnTimeSeries.uncertainties;
prfColGap = targetStruct.centroids.prfCentroids.columnTimeSeries.gapIndicators;

fluxWeightedRowVal = targetStruct.centroids.fluxWeightedCentroids.rowTimeSeries.values;
fluxWeightedRowUnc = targetStruct.centroids.fluxWeightedCentroids.rowTimeSeries.uncertainties;
fluxWeightedRowGap = targetStruct.centroids.fluxWeightedCentroids.rowTimeSeries.gapIndicators;

fluxWeightedColVal = targetStruct.centroids.fluxWeightedCentroids.columnTimeSeries.values;
fluxWeightedColUnc = targetStruct.centroids.fluxWeightedCentroids.columnTimeSeries.uncertainties;
fluxWeightedColGap = targetStruct.centroids.fluxWeightedCentroids.columnTimeSeries.gapIndicators;

nCadences = length(prfRowVal);


% allocate memory
prfRaVal = zeros(nCadences,1);
prfRaUnc = zeros(nCadences,1);
prfDecVal = zeros(nCadences,1);
prfDecUnc = zeros(nCadences,1);
fluxWeightedRaVal = zeros(nCadences,1);
fluxWeightedRaUnc = zeros(nCadences,1);
fluxWeightedDecVal = zeros(nCadences,1);
fluxWeightedDecUnc = zeros(nCadences,1);


% select cadences with valid motion polys and valid row and column centroids
validPrfCentroid = colvec([motionPolynomials.rowPolyStatus]) & ~prfRowGap(:) & ~prfColGap(:);
validFluxWeightedCentroid = colvec([motionPolynomials.rowPolyStatus]) & ~fluxWeightedRowGap(:) & ~fluxWeightedColGap(:);


% convert prf centroids
% Unavoidable loop - the motion polynomial inverter only takes one polynomial at a time
for ii=1:nCadences
    if( validPrfCentroid(ii) )
        % invert
        [ ra, dec, CraDec ] = ...
            invert_motion_polynomial( prfRowVal(ii), prfColVal(ii), motionPolynomials(ii), [prfRowUnc(ii),0;0,prfColUnc(ii)], fcConstants );

        % check for valid output
        if( ra == -1 || dec == -1 )
            disp(['     Motion polynomial could not be inverted for cadence ',num2str(ii),'.']);
            validPrfCentroid(ii) = false;
        else
            prfRaVal(ii) = ra;
            prfDecVal(ii) = dec;
            prfRaUnc(ii) = sqrt(CraDec(1,1));
            prfDecUnc(ii) = sqrt(CraDec(1,1));
        end
    end
end                          


% convert flux weighted centroids
% Unavoidable loop - the motion polynomial inverter only takes one polynomial at a time
for ii=1:nCadences
    if( validFluxWeightedCentroid(ii) )
        % invert
        [ ra, dec, CraDec ] = ...
            invert_motion_polynomial( fluxWeightedRowVal(ii), fluxWeightedColVal(ii), motionPolynomials(ii), [fluxWeightedRowUnc(ii),0;0,fluxWeightedColUnc(ii)], fcConstants );

        % check for valid output
        if( ra == -1 || dec == -1 )
            disp(['     Motion polynomial could not be inverted for cadence ',num2str(ii),'.']);
            validFluxWeightedCentroid(ii) = false;
        else
            fluxWeightedRaVal(ii) = ra;
            fluxWeightedDecVal(ii) = dec;
            fluxWeightedRaUnc(ii) = sqrt(CraDec(1,1));
            fluxWeightedDecUnc(ii) = sqrt(CraDec(2,2));
        end
    end
end   


% package results into time series for output
raDecCentroids.prf.ra.values = prfRaVal;
raDecCentroids.prf.ra.uncertainties = prfRaUnc;
raDecCentroids.prf.ra.gapIndicators = ~validPrfCentroid;

raDecCentroids.prf.dec.values = prfDecVal;
raDecCentroids.prf.dec.uncertainties = prfDecUnc;
raDecCentroids.prf.dec.gapIndicators = ~validPrfCentroid;

raDecCentroids.fluxWeighted.ra.values = fluxWeightedRaVal;
raDecCentroids.fluxWeighted.ra.uncertainties = fluxWeightedRaUnc;
raDecCentroids.fluxWeighted.ra.gapIndicators = ~validFluxWeightedCentroid;

raDecCentroids.fluxWeighted.dec.values = fluxWeightedDecVal;
raDecCentroids.fluxWeighted.dec.uncertainties = fluxWeightedDecUnc;
raDecCentroids.fluxWeighted.dec.gapIndicators = ~validFluxWeightedCentroid;

