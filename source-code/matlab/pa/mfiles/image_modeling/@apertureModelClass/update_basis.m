function update_basis(obj)
%**************************************************************************
% function update_basis(obj)
%**************************************************************************
% Update the basis vectors for the aperture model if necessary. If
% contributing star centroids are out of date, they are updated first.
%
% If basis vectors are out of date, fresh ones are derived in one of two
% ways: 
%
% 1) By computing the PRFs from scratch given the star's centroid position
%    at each cadence. 
% 2) By taking the stored, subsampled static PRFs for each star at each
%    cadence and applying the linear corrective model.
%
% NOTES
%      For the special case in which the set of contributing stars is the
%      null set, do nothing.
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

    % If prf model has been updated or if star centroid positions are out
    % of date, re-evaluate the prf models for each star.
    if obj.basisOutOfDate && obj.get_num_contributing_stars() > 0

        % If motion model has been updated since the centroids were last
        % computed, use it to estiamte new centroid locations. 
        if obj.centroidsOutOfDate
            obj.compute_contributing_star_centroids();
        end

        validCadenceIndicators = ~( obj.get_motion_gap_indicators() ...
            | obj.get_all_pixels_gapped_indicators() );
        
        for iStar = 1:obj.get_num_contributing_stars()
            
%            fprintf('Updating basis for star %d of %d contributing stars...\n', ...
%                iStar, obj.get_num_contributing_stars());
           
           for iCadence = 1:obj.get_num_cadences()
                if validCadenceIndicators(iCadence)
                    
                    % Contributing star centroid coordinates on this cadence.
                    starRow = obj.contributingStars(iStar).centroidRow(iCadence);
                    starCol = obj.contributingStars(iStar).centroidCol(iCadence);

                    obj.basisVectors(:, iStar, iCadence) = ...
                        obj.prfModelHandle.evaluate( starRow, starCol, ...
                            obj.pixelRows, obj.pixelColumns, iCadence);
                end
            end
        end 
        
        % The basis is now up to date.
        obj.clear_basis_out_of_date();
    end
end

%********************************** EOF ***********************************

