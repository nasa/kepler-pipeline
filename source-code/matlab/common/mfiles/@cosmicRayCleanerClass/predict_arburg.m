function [y_predicted, x, outliers, deltaSigma] = predict_arburg( obj, ...
                                                             y, p, t, gaps)
%**************************************************************************
% [y_predicted, x, outliers, deltaSigma] = predict_arburg( obj, ...
%                                                          y, p, t, gaps)
%**************************************************************************
% Fit an autoregressive (AR) model to the input time series.
%
% INPUTS
%     y  : A time series *dominated* by a WSS process.
%     p  : The order p of the AR model.
%     t  : The decision threshold (standard deviations). 
%
% OUTPUTS
%     y_predicted : The predicted time series upon completion of the 
%                   backward pass.
%     x           : The (ideally) white innovation.
%     outliers    : A logical array indicating identified outliers (i.e.
%                   significant departures from the estimated AR model).
%                   These may be either positive or negative and are not
%                   necessarily the result of cosmic ray hits.
%     deltaSigma  : Fractional reduction in the estimated standard
%                   deviation of x. 
%
%                       (sigma_out - sigma_in) / sigma_in
%
%                   where  sigma_in  is estimated std of x upon input.
%                          sigma_out is estimated std of x upon output.
%
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
    if ~exist('gaps','var')
        gaps = false(size(y));
    end
    
    y = y(:);        % Force y to be a column vector.
    y_unaltered = y; % Keep a copy of the input time series for plotting
     
    %----------------------------------------------------------------------
    % Do forward prediction
    %----------------------------------------------------------------------

    %**
    % Estimate the AR(p) model coefficients a[k], normalized to a(1), using
    % Burg's algorithm 
    %
    %         p
    % x[n] = SUM a[k+1] y[n-k]
    %        k=0
    %
    % where x[n] is a (white) innovation process and y[n] is the observed
    % time series. (NOTE that the Matlab documentation for this function
    % contains an indexing error. a(1)=1.0 is the coefficient of y(n),
    % though the equation in the documentation would suggest otherwise.)
    [a, x_var] = arburg(y, p);
    x_sigma_fwd = sqrt(x_var);
    x_mean = 0; % The innovation process x[n] is assumed to be zero-mean WGN.
    
    %**
    % Estimate the innovation process from the prediction error.
    % 
    % All sources of random noise in the Kepler photometer are modeled as
    % Gaussian [KADN-26185]. Although photon noise is Poisson-distributed,
    % the central limit theorem tells us that the signal resulting from
    % coadding many short (iid) exposures approaches a Gaussian
    % distribution.
    x = zeros(size(y));
    cadences = (p+1):length(x);
    outliers = false(size(y));
    y_predicted = y;
    
    for n = cadences

        %**
        % Predict the current value using the expected value of the
        % innovation (zero).
        %
        % ^              p
        % y[n] = x[n] - SUM a[k+1] y[n-k]
        %               k=1
        y_predicted(n) = x_mean - a(2:p+1) * y(n-1:-1:n-p);
        
        % Identify outliers in the innovation process. Replace outliers
        % with the predicted value.
        x(n) = y(n) - y_predicted(n);
        if abs(x(n)) > t * x_sigma_fwd
            y(n) = y_predicted(n);
            x(n) = x_mean;
            
            % Flag any values replaced as outliers, unless they're gaps.
            if gaps(n) ~= true
                outliers(n) = true;
            end
        end
        
    end
    
    %----------------------------------------------------------------------
    % Do backward prediction
    %----------------------------------------------------------------------
    
    % flip time series. This preserves the results of forward processing
    % at the end of the time series.
    x = x(end:-1:1);                     
    y = y(end:-1:1);                    
    y_predicted = y_predicted(end:-1:1);
    outliers = outliers(end:-1:1);
    gaps = gaps(end:-1:1);
    
    % Re-estimate the model params for backward prediction and re-estimate
    % sigma.
    [a, x_var] = arburg(y, p);
    x_sigma_bwd = sqrt(x_var);
      
    % Repeat the prediction / cleaning process. Re-estimate the innovation
    % process.
    for n = cadences
        y_predicted(n) = x_mean - a(2:p+1) * y(n-1:-1:n-p);
        x(n) = y(n) - y_predicted(n);
        if abs(x(n)) > t * x_sigma_bwd
            y(n) = y_predicted(n);
            x(n) = x_mean;
            
            if gaps(n) ~= true
                outliers(n) = true;
            end
        end
    end
    
    %----------------------------------------------------------------------
    % Prepare prediction and recovered innovation for output.
    %----------------------------------------------------------------------
    y_predicted = y_predicted(end:-1:1);
    x           = x(end:-1:1);
    x_sigma     = std(x);
    deltaSigma  = (x_sigma - x_sigma_fwd) / x_sigma_fwd;
    outliers    = outliers(end:-1:1);
    
    %----------------------------------------------------------------------
    % Plot results
    %----------------------------------------------------------------------
    if obj.debugStruct.flags.plotEstimatedSignalComponents
        NPLOTS = 3;
        INPUT_COLOR = 'b';
        INNOV_COLOR = [0 128 102]/255;
        PREDICTED_COLOR = 'g';
        CR_COLOR = 'r';
        GAP_COLOR = [0.7 0.7 0.7];
        TITLE_FONTSIZE = 12;
        LABEL_FONTSIZE = 10;

        fHandle = figure(1);

        % Retrieve outlier signal
        outlierSignal = zeros(size(y_unaltered));
        outlierSignal(outliers) = y_unaltered(outliers) - y_predicted(outliers);

        % Estimate cosmic ray signal
        c = outlierSignal; 
        c(c<0) = 0;

        gaps = gaps(end:-1:1);

        % Plot input time series and mark cosmic rays.
        ha(1) = subplot(NPLOTS,1,1);
        hp(1) = plot(cadences, y_unaltered(cadences), ...
            'color', INPUT_COLOR, 'linewidth', 1, 'linestyle','-');
        hold on
        hp(end+1) = plot(cadences, y_predicted(cadences), ...
            'color', PREDICTED_COLOR, 'linewidth', 1.5, 'linestyle','-');        
        hold off
        title(ha(1),'Prediction Result','fontsize',TITLE_FONTSIZE);
        ylabel('Flux (e-)','fontsize',LABEL_FONTSIZE);
        legend({'Input Time Series', 'Prediction'});
        
        line(xlim(ha(end)), [0, 0], 'LineStyle','-','Color', 'k', 'LineWidth', 1);
        mark_cadences_with_lines(ha(1), find(gaps), GAP_COLOR, '-', 1);
        
        % Plot x process.
        ha(end+1) = subplot(NPLOTS,1,2);
        hp(end+1) = plot(cadences, x(cadences), 'Color', INNOV_COLOR);
        title(ha(end),'Estimated Innovation Process', ...
            'fontsize',TITLE_FONTSIZE);
        ylabel('Flux (e-)','fontsize',LABEL_FONTSIZE);

        % Show decision threshold on innovation plot.
        line(xlim(ha(end)), [t * x_sigma_fwd, t * x_sigma_fwd], ...
            'LineStyle','--','Color', 'r', 'LineWidth', 1);
        line(xlim(ha(end)), [t * x_sigma_bwd, t * x_sigma_bwd], ...
            'LineStyle','--','Color', 'g', 'LineWidth', 1);
        line(xlim(ha(end)), [x_sigma,     x_sigma],     ...
            'LineStyle','--','Color', 'k', 'LineWidth', 1);
        legend({'Estiamted Innovation Process', 'Outlier Threshold (fwd pass)', ...
            'Outlier Threshold (bwd pass)', 'Innovation Standard Dev.'});
        
        line(xlim(ha(end)), [0, 0], 'LineStyle','-','Color', 'k', 'LineWidth', 1);
        mark_cadences_with_lines(ha(2), find(gaps), GAP_COLOR, '-', 1);

        % Plot outlier process.
        ha(end+1) = subplot(NPLOTS,1,3);
        hp(end+1) = plot(cadences, outlierSignal(cadences), 'Color', CR_COLOR);
        title(ha(end),'Outliers', ...
            'fontsize', TITLE_FONTSIZE);
        xlabel('Cadence','fontsize',LABEL_FONTSIZE);
        ylabel('Flux (e-)','fontsize',LABEL_FONTSIZE);

        mark_cadences_with_lines(ha(3), find(gaps), GAP_COLOR, '-', 1);

        linkaxes(ha,'x');
 
        % Show innovation histogram.
%         fHandle(2) = figure(2);
%         hist(x, fix(length(x)/20));
        
        pause
    end
end

%********************************** EOF ***********************************