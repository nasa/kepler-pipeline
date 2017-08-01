%*************************************************************************************************************
%% function map_propagation_of_uncertainties (mapData, mapInput)
%*************************************************************************************************************
%
% Propagates uncertainties through MAP using pdc_perform_svd_cotrending_pou. This function in turn assumes a
% least-squares fit to the basis vectors. This is only an approximation.
%
% See pdc_perform_svd_cotrending_pou for details.
%
% The propagation is performed in the normalized basis.
%
%*************************************************************************************************************
% Outputs:
%  mapData.normTargetDataStruct.uncertainties -- updated uncertainties
%
%%*************************************************************************************************************
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

function map_propagation_of_uncertainties (mapData, mapInput)

component = 'pou';

 pouMethod = 'leastsquares';
%pouMethod = 'analytical';

targetIndicesToAnalyze = find(mapInput.debug.targetsToAnalyze);
if (mapInput.debug.query_do_plot(component));
    pou_fig = mapInput.debug.create_figure;
end

if (mapInput.debug.query_do_plot(component));
    % If we are plottong then save raw uncertainties for plotting other method(s)
    rawUncertaintiesSave = [mapData.normTargetDataStruct.uncertainties];
end
for iTarget=1:mapData.nTargets
    % Only propagate uncertainties for targets MAP applied to
    if (mapInput.debug.applyMapToAllTargets || ...
            (~mapInput.debug.applyMapToAllTargets && any(iTarget == targetIndicesToAnalyze)))
        switch strtrim(pouMethod)
        case 'leastsquares'
            U = mapData.basisVectors;
            % Uncertainties have been normalized so get raw uncertainties
            rawUncertainties = mapData.normTargetDataStruct(iTarget).uncertainties;
            [~, Ccot] = pdc_perform_svd_cotrending_pou(U,rawUncertainties);
        case 'analytical'
            Ccot = perform_analytical_map_pou (mapInput, mapData, iTarget);
        otherwise
            error('map_propagation_of_uncertainties: Unknown POU method');
        end
        % Do not update uncertainties within gaps
        gaps = mapInput.targetDataStruct(iTarget).gapIndicators;
        mapData.normTargetDataStruct(iTarget).uncertainties(~gaps) = sqrt(abs(Ccot(~gaps)));

        % plotting
        if (mapInput.debug.query_do_plot(component));
            if (any(iTarget == targetIndicesToAnalyze))
                % If use leastsquares above then compute analytical here for comparison
                switch strtrim(pouMethod)
                case 'leastsquares'
                    error ('Due to peculiarites in structure, can only plot right now is pouMethod = anlytical');
                   %CcotLeastSquares = perform_analytical_map_pou (mapInput, mapDataSave, iTarget);
                    otherUncertainties = sqrt(CcotLeastSquares(~gaps));
                case 'analytical'
                    U = mapData.basisVectors;
                    % Uncertainties have been normalized so get raw uncertainties
                    rawUncertainties = rawUncertaintiesSave(:,iTarget);
                    [~, CcotAnalytical] = pdc_perform_svd_cotrending_pou(U,rawUncertainties);
                    otherUncertainties = sqrt(CcotAnalytical(~gaps));
                otherwise
                    error('map_propagation_of_uncertainties: Unknown POU method');
                end
                mapInput.debug.select_figure(pou_fig);
                plot(mapInput.cadenceTimestamps(~gaps), rawUncertainties(~gaps), '-b');
                hold on;
                plot(mapInput.cadenceTimestamps(~gaps), mapData.normTargetDataStruct(iTarget).uncertainties(~gaps), '-r')
                plot(mapInput.cadenceTimestamps(~gaps), otherUncertainties, '-m')
                keplerId = mapData.kic.keplerId(iTarget);
                title(['Propagation of Uncertainties through MAP; TargetID = ', num2str(iTarget), ...
                        ' Kepler ID = ', num2str(keplerId)]);
                switch strtrim(pouMethod)
                case 'leastsquares'
                    legend('Raw Uncertainty', 'Propagated Least Squares Uncertainty', 'Propagated Analytical Uncertainty');
                case 'analytical'
                    legend('Raw Uncertainty', 'Propagated Analytical Uncertainty', 'Propagated Least Squares Uncertainty');
                end
                ylabel('Uncertainty [normalized]');
                xlabel('Cadence');
                hold off;
                filename = ['pou_keplerID_', num2str(keplerId)];
                string = ['Displaying target ', num2str(find(iTarget==targetIndicesToAnalyze)), ' of ', ...
                            num2str(mapInput.debug.nTargetsToAnalyze)];
                mapInput.debug.pause(string);
                mapInput.debug.save_figure(pou_fig , component, filename);
            end
        end
    end
end
if (mapInput.debug.query_do_plot(component));
    clear rawUncertaintiesSave;
end
        
return
%*************************************************************************************************************
%


function [Ccot] = perform_analytical_map_pou (mapInput, mapData, iTarget)

    H = mapData.basisVectors;
    flux = mapData.normTargetDataStruct(iTarget).values;
    % NaN gaps
    flux(mapData.normTargetDataStruct(iTarget).gapIndicators) = NaN;

    % Observation noise
    sigma = nanstd(flux);

   %fluxFirstDifferences = diff(flux);
   %sigma = nanstd(fluxFirstDifferences);

    uncertainties = mapData.normTargetDataStruct(iTarget).uncertainties;
    % NaN gaps
   %uncertainties(mapData.normTargetDataStruct(iTarget).gapIndicators) = NaN;
    Cflux = uncertainties' .^ 2;
 

    Ccot = zeros(mapData.nCadences,1);
    % Find the covariance of the basis vectors coefficients (theta)
    % TODO: make this ra/dec/kepmag aware
    robustCoeffs = [mapData.robustFit.coefficients];
    C_theta = cov(robustCoeffs');
 
    alpha = inv(H' * H + sigma^2 * inv(C_theta));
   %alpha = eye(8);
 
    beta = H * alpha * H';

    I = blkdiag(ones([mapData.nCadences]));
 
    % Must expand for Matland to properly evaulate
    %Ccot = (I - H * alpha * H') * Cflux * (I - H * alpha * H')';
   %Ccot = Cflux - beta * Cflux - Cflux * beta' + beta * Cflux * beta'; 

   %Ccot = Cflux - beta * Cflux' - Cflux * beta' + scalerow(Cflux, beta) * beta'; 

    Ccot = abs(Cflux - 2 * Cflux * beta' + (beta * Cflux')' * beta'); 

return
