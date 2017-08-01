function firstPlotDone = plot_fitted_data(dataStruct, encircledEnergyStruct, firstPlotDone)
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

if(encircledEnergyStruct.PLOTS_ON)
    % Plot data and fits for 1) normalized pixel data and 2) numerically
    % integrated normalized pixel data. 

    pixFlux         = dataStruct.pixFlux;
    radius          = dataStruct.radius;
    q               = dataStruct.q;
    r0              = dataStruct.r0;
    maxR            = dataStruct.maxR;
    fractionalFlux  = dataStruct.fractionalFlux;

    polyOrder   = encircledEnergyStruct.polyOrder;
    eeFraction  = encircledEnergyStruct.eeFraction;


    figure(5); tempX = 0:0.01:1; plot(radius,pixFlux,'bo',tempX,ee_derivative_fit(q,tempX),'r');
    grid on; aa=axis; axis([-0.1 1.1 -0.1 aa(4)]);
    xlabel('normalized radius'); ylabel('normalized pixel data');
    title(['constrained polynomial order = ',num2str(polyOrder+2)]);

    figure(6); plot(radius,fractionalFlux,'o',...
                    tempX,ee_integral_fit(q,tempX),'r',...
                    [-0.1,1.1],[1,1].*eeFraction,'k',...
                    [1,1].*r0,[-0.1,1.1],'g');
    grid on; axis([-0.1 1.1 -0.1 1.1]);
    xlabel('normalized radius'); ylabel('integrated normalized pixel data');
    title(['constrained polynomial order = ',num2str(polyOrder+3)]);
    text( 1.1*r0, eeFraction/2, ['R0= ',num2str(r0)] );
    text( 1.1*r0, eeFraction/4, ['Rmax= ',num2str(maxR)] );

    if( ~firstPlotDone )
        tile_ee_plots;
        firstPlotDone = true;
    end
end
