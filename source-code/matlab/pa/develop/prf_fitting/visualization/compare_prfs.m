function compare_prfs(modelStruct1, modelStruct2, cadence, labels)        
%**************************************************************************
% Compare corresponding PRFs in two models of the same aperture.   
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

    if ~exist('cadence', 'var')
        cadence = 1;
    end

    if ~exist('labels', 'var')
        labels = {'PRF_1', 'PRF_2'};
    end

    % Make sure aperture models are comparable (i.e. same pixels and same
    % stars).
    unmatchedPixels = ...
        setxor([modelStruct1.ccdRow(:), modelStruct1.ccdCol(:)], ...
               [modelStruct2.ccdRow(:), modelStruct2.ccdCol(:)], 'rows');
           
    unmatchedStars = ...
            setxor([modelStruct1.stars.keplerId], ...
                   [modelStruct2.stars.keplerId]);

    if ~isempty(unmatchedPixels) || ~isempty(unmatchedStars)
        error('Aperture models are not comparable.');
    end
    
    nContributingStars = numel(modelStruct1.stars);
    nCadences = size(modelStruct1.coefs, 1);
    
    if cadence < 1 || cadence > nCadences
        error('The specified cadence is out of range.');        
    end
    
    scrsz = get(0,'ScreenSize');
    set(gcf, 'Position',[1 scrsz(4) 0.9*scrsz(3) 0.5*scrsz(4)]);    
    ha(1) = subplot(1, 2, 1);
    ha(2) = subplot(1, 2, 2);

    pixelRows = modelStruct1.ccdRow;
    pixelCols = modelStruct1.ccdCol;
   
    for iStar = 1:nContributingStars
        kid = modelStruct1.stars(iStar).keplerId;
        pixelValues = modelStruct1.stars(iStar).prf(:, cadence);
        prf1 = get_pixel_image(pixelValues, pixelRows, pixelCols);
        
        starIndex2 = find([modelStruct1.stars.keplerId] == kid);

        pixelValues = modelStruct2.stars(starIndex2).prf(:, cadence);
        prf2 = get_pixel_image(pixelValues, pixelRows, pixelCols);
        
        % Makes sure both PRFs are normalized.
        prf1 = prf1 / sum(prf1(:));
        prf2 = prf2 / sum(prf2(:));
        
        % Plot the difference
        axes(ha(1));
        mesh(prf1 - prf2);
        
        title( sprintf('%s - %s (cadence %d)', labels{1}, labels{2}, cadence) );
        xlabel('column');
        ylabel('row');

        axes(ha(2));
        imagesc(prf1 - prf2);
        colorbar
        title( sprintf('%s - %s (cadence %d)', labels{1}, labels{2}, cadence) );
        xlabel('column');
        ylabel('row');

        pause
    end

end