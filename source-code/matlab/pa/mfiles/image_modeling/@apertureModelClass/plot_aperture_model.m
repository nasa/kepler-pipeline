function plot_aperture_model(apertureModelObject, cadence)        
%**************************************************************************
% Plot the static model and observed values on the current figure. 
%
% plot_aperture_model(apertureModelObject, groupArray, cadence)
% plot_aperture_model(hfig, apertureModelObject, groupArray, cadence)
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
    
    pixRows = apertureModelObject.pixelRows;
    pixCols = apertureModelObject.pixelColumns;
    
    scrsz = get(0,'ScreenSize');
    set(gcf, 'Position',[1 scrsz(4) 0.7*scrsz(3) scrsz(4)]);    
    ha(1) = subplot(3, 3, 1);
    ha(2) = subplot(3, 3, 2);
    ha(3) = subplot(3, 3, 3);
    ha(4) = subplot(3, 3, [4,5,6]);
    ha(5) = subplot(3, 3, [7,8,9]);
    
    modelPixels    = apertureModelObject.evaluate(cadence);
    observedPixels = apertureModelObject.get_observed_values_and_sigmas(cadence);

    %----------------------------------------------------------------------
    % Display aperture images.
    %----------------------------------------------------------------------
    axes(ha(1));
    display_pixel_image(observedPixels, pixRows, pixCols, 'Observed');

    axes(ha(2));
    display_pixel_image(modelPixels, pixRows, pixCols, 'Model');

    axes(ha(3));
    display_pixel_image(observedPixels - modelPixels, pixRows, pixCols, ...
        'Observed - Modeled');
            
    %----------------------------------------------------------------------
    % Plot flux.
    %----------------------------------------------------------------------
    axes(ha(4));
    hold(ha(4), 'off');
    plot(ha(4), observedPixels(:), 'b');
    hold(ha(4), 'on');
    plot(ha(4), modelPixels(:), 'r');

    title( sprintf('Observed vs. modeled pixel flux (cadence %d)', cadence), ...
        'FontSize', 14, 'FontWeight', 'bold' );
    xlabel('pixel');
    ylabel('flux');
    legend({'observed flux', 'modeled flux'});

    %----------------------------------------------------------------------
    % Plot residuals.
    %----------------------------------------------------------------------
    axes(ha(5));
    plot(ha(5), observedPixels(:) - modelPixels(:), 'k');

    title( sprintf('Residual (observed - modeled) pixel flux (cadence %d)', cadence), ...
        'FontSize', 14, 'FontWeight', 'bold' );
    xlabel('pixel');
    ylabel('residual');

    linkaxes(ha(4:5), 'x');

end

function img = display_pixel_image(pixVals, pixRows, pixCols, titleStr)
    if ~exist('titleStr', 'var')
        titleStr = '';
    end

    ccdRows     = colvec( min(pixRows) : max(pixRows) );
    ccdColumns  = colvec( min(pixCols) : max(pixCols) );

    M = length(ccdRows);
    N = length(ccdColumns);

    img = zeros(M, N);
    ind = sub2ind( size(img), pixRows-min(pixRows) + 1, pixCols-min(pixCols) + 1);
    img(ind) = pixVals;
    imagesc(img);
    title(titleStr, 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('pixel column');
    ylabel('pixel row');
    axis xy
    set(gca, 'XTickLabel', ccdColumns );
    set(gca, 'YTickLabel', ccdRows );
end