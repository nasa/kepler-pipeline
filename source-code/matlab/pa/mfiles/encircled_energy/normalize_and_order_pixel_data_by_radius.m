function [ dataStruct, cadenceGapFlag ] = normalize_and_order_pixel_data_by_radius( dataStruct, encircledEnergyStruct )
%                                         
% function [ dataStruct, cadenceGapFlag ] = normalize_and_order_pixel_data_by_radius( dataStruct, encircledEnergyStruct )
%
% This function normalizes the input pixel data on a per target basis, then sorts the pixels by their respective distances
% from the target centroids. If it is not possible to find a resonable normalization factor for any target the pixels for 
% that target are removed from the data set. The final step is to renormalize the pixel data over all the targets together. 
% Outliers are identified using robust fit and removed from the data set. The normalized data is returned. If a positive
% normalization factor cannot be found at the cadence level (all targets normalized together) the gapFlag is set to true.
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

%% Unpack data

pixFlux         = dataStruct.pixFlux;
Cpixflux        = dataStruct.Cpixflux;
radius          = dataStruct.radius;
row             = dataStruct.row;
col             = dataStruct.col;
startTarget     = dataStruct.startTarget;
stopTarget      = dataStruct.stopTarget;
expectedFlux    = dataStruct.expectedFlux;

%% Constants - passed through encircledEnergyStruct
CONSTRAINED_COV_FACTOR      = encircledEnergyStruct.CONSTRAINED_COV_FACTOR;
ADDITIVE_WHITE_NOISE_SIGMA  = encircledEnergyStruct.ADDITIVE_WHITE_NOISE_SIGMA;
ROBUST_THRESHOLD            = encircledEnergyStruct.ROBUST_FIT_WEIGHT_THRESHOLD;
MAX_RADIUS                  = encircledEnergyStruct.MAX_RADIUS;                                                                       
TARGET_P_ORDER              = encircledEnergyStruct.TARGET_P_ORDER;
PLOTS_ON                    = encircledEnergyStruct.PLOTS_ON;
ROBUST_LIMIT_FLAG           = encircledEnergyStruct.ROBUST_LIMIT_FLAG;

polyOrder                   = encircledEnergyStruct.polyOrder;

%% normalize radius data to expected maximum R, seed fractionalFlux
if( MAX_RADIUS == 0 )
    % estimate maximium radius from the median value assuming even distribution of pixels over circular aperture
    % this should be robust to outliers at large radius
    maxR = sqrt(2) * median(radius);
else
    maxR = MAX_RADIUS;
end
radius = radius./maxR;
fractionalFlux = 0;

%% Normalize pixel data on a per target basis
        
% Initialize list of un-normalizable targets and the cadenceGapFlag
removeFlag = [];
cadenceGapFlag = false; 

for iTarget=1:length(startTarget) 

    %% GRAB DATA FOR THIS TARGET
    y = pixFlux( startTarget(iTarget) : stopTarget(iTarget) );
    x = radius(  startTarget(iTarget) : stopTarget(iTarget) );
    if( isvector(Cpixflux) )
        Cv = Cpixflux( startTarget(iTarget) : stopTarget(iTarget) );
    else
        Cv = Cpixflux( startTarget(iTarget) : stopTarget(iTarget), startTarget(iTarget) : stopTarget(iTarget) );
    end

    
    %% SORT DATA BY RADIUS
    [x,ix] = sort(x);
    y = y(ix);
    if(isvector(Cv)); Cv = Cv(ix); else Cv = Cv(ix,ix); end 
    
    %% trim to target data inside radius == 1;
    ox = find( x <= 1 );
    x = x(ox);
    y = y(ox);
    if( isvector(Cpixflux) )    
        Cv = Cv(ox);
        Cv = Cv(:);
    else
        Cv = Cpixflux(ox, ox);
    end
    
    %% GET NORMALIZATION FACTOR
    % If expectedFlux estimate is avaliable for this target, normalize pixel data for this target by the expectedFlux.
    % Otherwise fit the data to a low order polynomial use the integral of that polynomial from x=[0:1] as an estimate 
    % of the flux for this target. Numeric integration is used if this fit fails to provide a positive normalization 
    % factor or if not enough data is available. If numerical integration produces a negative results or if there are 
    % no data points inside the normalized radius, the target is flagged and removed from further encircled energy 
    % processing.
    % 
    
    normFactor = -1;
    if( expectedFlux(iTarget) > 0 )
        normFactor = expectedFlux(iTarget);
    elseif( ~isempty(x) )  
        % Estimate normalization factor
        
        %% CHECK FOR ZERO UNCERTAINTIES
        % If all zero uncertainties --> set all uncertainties to 1, add white noise to data
        if( all(all(Cv == 0)) )
            % if zeros, set equal to 1-vector (equivalent to no weighting in lscov)
            Cv=ones(length(y),1);
            % small amount of white noise required fitting on "perfect" data sets used in testing
            y = normrnd( y, ADDITIVE_WHITE_NOISE_SIGMA .* ones(size(y)) );
        end

        % If any uncertainties are zero, set those to eps(1)
        if(any(Cv==0))
            Cv(Cv==0) = eps(1);
        end
        
        %% CONSTRAIN POINT AT x=1 TO BE ZERO
        % If data exists at x=1, set y(1)=0 by removing bias from all data points, otherwise create point at x=1 and set y(1)=0. 
        % Constrian uncertainty on the point y(1) to CONSTRAINED_COV_FACTOR * mean(variance) in the covariance matrix (Cv)
        [xmax, ixmax] = max(x);
        if( xmax == 1 )
            y = y - y(ixmax);
            y(ixmax) = 0;
            if( isvector(Cv) )
                Cv(ixmax) = sqrt( CONSTRAINED_COV_FACTOR * mean(Cv.^2) );
                Cv = diag(Cv.^2);
            end
            Cv(:, ixmax) = zeros(size(Cv(:, ixmax)));
            Cv(ixmax, :) = zeros(size(Cv(ixmax, :)));
            Cv(ixmax, ixmax) = CONSTRAINED_COV_FACTOR * mean( diag(Cv) );                        
        else
            y = [y; 0]; x = [x; 1];                                         %#ok<AGROW>
            if( isvector(Cv) ); Cv = diag(Cv.^2); end
            [r, c] = size(Cv);
            constrainedValue = CONSTRAINED_COV_FACTOR * mean( diag(Cv) );
            Cv=[Cv           ,zeros(r,1);...
                zeros(1,c)   ,constrainedValue  ];                          %#ok<AGROW>            
        end

        %% ESTIMATE INTEGRAL
        % Normalize pixel data by integral of polynomial fit of order min([TARGET_P_ORDER, polyOrder + 2])
        % If fewer than TARGET_P_ORDER + 1 points available, normalize using cumtrapz method

        pOrder = min([TARGET_P_ORDER,polyOrder+2]); % select order of polynomial

        if(length(y)>TARGET_P_ORDER+1)            
            
            M=zeros(length(y),pOrder+1);            % build design matrix
            for n = 1:pOrder+1
                M(:,n) = x.^(pOrder+1-n);
            end
            
            c = lscov( M, y, Cv );                  % fit y = M*c            
            
            normFactor = polyval(polyint(c'),1);    % normalization factor is integrated fit at x =1 
            
            if(PLOTS_ON)
                figure(2);z=0:0.01:1;plot(z,polyval(c,z),'r');hold on;                        
                if(isvector(Cv)); errorbar(x,y,Cv,'o'); else  errorbar(x,y,sqrt(diag(Cv)),'o'); end
                hold off; grid on; aa=axis; axis([0,1,-0.3*aa(4),aa(4)]);
                xlabel('normalized radius'); ylabel('pixel data (counts)');
                title(['TARGET # ',num2str(iTarget),' - polynomial order = ',num2str(pOrder)]);
            end
        else
            % normalization factor is numerical integration using trapz + missing piece between x=0, x=min(x)
            [xmin, ixmin] = min(x);
            normFactor = trapz(x,y) + xmin * y(ixmin);
             if(PLOTS_ON)
                figure(2);
                if(isvector(Cv)); errorbar(x,y,Cv,'o'); else  errorbar(x,y,sqrt(diag(Cv)),'o'); end
                grid on; aa=axis; axis([0,1,-0.3*aa(4),aa(4)]);
                xlabel('normalized radius'); ylabel('pixel data (counts)');
                title(['TARGET # ',num2str(iTarget),' numerical integration']);
            end
        end
    end

    %% CHECK NORMALIZATION FACTOR AND NORMALIZE
    % flag targets with negative normalization factors for removal
    
    if(normFactor <= 0)
        removeFlag = [removeFlag; iTarget];                                                 %#ok<AGROW>
    else 
        % normalize pixFlux, Cpixflux for this target
        pixFlux(startTarget(iTarget):stopTarget(iTarget))...
            = pixFlux(startTarget(iTarget):stopTarget(iTarget)) ./ normFactor;
        if(isvector(Cpixflux))
            % uncertainties (e.g. sqrt(var) ) normalize by the same factor as the raw data
            Cpixflux(startTarget(iTarget):stopTarget(iTarget))...
                = Cpixflux(startTarget(iTarget):stopTarget(iTarget)) ./ normFactor;
        else
            % covariance matrices normalize by the factor^2
            Cpixflux(startTarget(iTarget):stopTarget(iTarget),startTarget(iTarget):stopTarget(iTarget))...
                = Cpixflux(startTarget(iTarget):stopTarget(iTarget),startTarget(iTarget):stopTarget(iTarget)) ./ (normFactor^2);
        end
    end
end

%% remove data flagged as unnormalizable
if( ~isempty(removeFlag) )
    for iTarget = 1:length(removeFlag)
        pixFlux     = remove_array_entries(pixFlux,  startTarget(removeFlag(iTarget)), stopTarget(removeFlag(iTarget)) ); 
        Cpixflux    = remove_array_entries(Cpixflux, startTarget(removeFlag(iTarget)), stopTarget(removeFlag(iTarget)) ); 
        radius      = remove_array_entries(radius,   startTarget(removeFlag(iTarget)), stopTarget(removeFlag(iTarget)) );
        row         = remove_array_entries(row,      startTarget(removeFlag(iTarget)), stopTarget(removeFlag(iTarget)) );
        col         = remove_array_entries(col,      startTarget(removeFlag(iTarget)), stopTarget(removeFlag(iTarget)) );
    end
end

%% sort the pixel data, uncertainties, row and col by radius   
[radius,sortIndex]  = sort(radius);     
pixFlux             = pixFlux(sortIndex);
row                 = row(sortIndex);                                                   %#ok<NASGU>
col                 = col(sortIndex);                                                   %#ok<NASGU>

if( isvector(Cpixflux) )    
    Cpixflux = Cpixflux(sortIndex);
    Cpixflux = Cpixflux(:);
else
    Cpixflux = Cpixflux(sortIndex, sortIndex);
end

%% trim to data inside radius == 1;
ox = find(radius<=1);
radius = radius(ox);
pixFlux = pixFlux(ox);
row = row(ox);
col = col(ox);
if( isvector(Cpixflux) )    
    Cpixflux = Cpixflux(ox);
    Cpixflux = Cpixflux(:);
else
    Cpixflux = Cpixflux(ox, ox);
end

        
%% fine tune the pixel normalization by renormalizing over all targets at once
        
% Need to get a good estimate of the integrated pixel data in order to
% get the correct nomalization factor, totFlux = int(pixFlux)|radius=1. Fit
% pixel data as a function of normalized radius to a polynomial of
% order polyOrder+2 (from the definition of p'(x))      

% If all zero uncertainties, add a small amount of white noise to the
% data. USED FOR UNIT TEST DATA.                
if( all(all(Cpixflux == 0)) )
    pixFlux = normrnd( pixFlux, ADDITIVE_WHITE_NOISE_SIGMA .* ones(size(pixFlux)) );
end

% MAKE pixFlux|radius=1 = 0
% If point exists at radius=1, remove this bias from data set. Otherwise, 
% add constrained point at radius=1 with value pixFlux=0. 
% Set covariance = constrianed value = CONSTRAINED_COV_FACTOR * mean(diag(Cpixflux)) for this point.
if( radius(end) == 1 )            
    pixFlux = pixFlux - pixFlux(end);        
else              
    radius = [radius;1];                                        %#ok<AGROW>
    pixFlux = [pixFlux;0];                                      %#ok<AGROW>
    row = [row;0];                                              % use dummy row and column 
    col = [col;0];
    if( isvector(Cpixflux) )    
        Cpixflux = [ Cpixflux; sqrt(CONSTRAINED_COV_FACTOR * mean(Cpixflux)) ];                
    else
        [r,c]=size(Cpixflux);
        Cpixflux = [ Cpixflux,  zeros(r,1);...
                    zeros(1,c), CONSTRAINED_COV_FACTOR * mean(diag(Cpixflux)) ];
    end
end        

% build design matrix for polyOrder + 2 fit
M = zeros(length(radius), polyOrder+3);
for n = 1:polyOrder+3
    M(:,n) = radius.^(polyOrder+3-n);
end

% Fit pixel data using robustfit rather than lscov --> any large outliers are effectively ignored in the fit.
% These data points are identified by the weights assigned in stats.w and are removed from the data set
% before it is returned from this function. If the iteration limit is exceeded, the cadence is marked as a data
% gap. The robustfit is unweighted and unconstrained. 

s = warning('query','stats:statrobustfit:IterationLimit');
warning('off','stats:statrobustfit:IterationLimit');

[c, stats] = robustfit(M,pixFlux,'',[],'off');

% Compute AIC quality of fit metric
% This definition of the AIC metric is consistent with that used in CAL and
% with AICc which includes a correction term for small sample size.
% See http://en.wikipedia.org/wiki/Akaike_information_criterion
nPoints = length(pixFlux);
nCoeffs = length(c);
RSS = sum(stats.resid.^2);

aic = 2*nCoeffs + nPoints*log(RSS/nPoints) + 2*nCoeffs*(nCoeffs + 1) / (nPoints - nCoeffs - 1);

if( ROBUST_LIMIT_FLAG && strcmp(lastwarn, 'Iteration limit reached.'))
    warning(['PA:encircledEnergy:',mfilename],'Robust fit iteration limit exceeded, cadence gap flag set.');
    cadenceGapFlag = true;
end

warning(s.state,'stats:statrobustfit:IterationLimit');

okIndices = find(stats.w > ROBUST_THRESHOLD); 
outlierIndices = find(stats.w <= ROBUST_THRESHOLD);

if(PLOTS_ON)
    figure(3); plot(1:length(stats.w),stats.w,'.',[0,length(stats.w)],[1,1].*ROBUST_THRESHOLD,'r');
    xlabel('Point #'); ylabel('weight');title(['ROBUST FIT WEIGHTS - outliers identified = ',num2str(length(outlierIndices))]);

    figure(4); X= 0:0.01:1; plot(radius,pixFlux,'o',X,polyval(c,X),'r');
    grid on; aa=axis; axis([-0.1, 1.1, -0.1, aa(4)]);
    xlabel('normalized radius'); ylabel('normalized pixel data');
    title(['ROBUST FIT - unconstrained - polynomial order = ',num2str(polyOrder+2)]);
end

if(~cadenceGapFlag)
    
    % Select only non-outliers for return data set
    pixFlux = pixFlux(okIndices);    
    radius = radius(okIndices);
    row = row(okIndices);
    col = col(okIndices);
    if(isvector(Cpixflux))
        Cpixflux = Cpixflux(okIndices);
    else
        Cpixflux = Cpixflux(okIndices,okIndices);
    end
    
    % If integral at radius=1 evaluates to a positive value, renormalize data. Otherwise set cadenceGapFlag.
    totFlux = polyval(polyint(c'),1);
    if( totFlux > 0  )
        % needed for next plot -----------------
        % numerically integrate using trapz + missing part r = [0,rmin] 
        % Normalize by above evaluated at r=rmax + missing part r = [rmax,1]
        
        fractionalFlux = polyval(polyint(c'),radius(1)) + cumtrapz(radius,pixFlux );
        integratedFlux = fractionalFlux(end);
        if( radius(end) ~= 1 )
            integratedFlux = integratedFlux + (polyval(polyint(c'),1) - polyval(polyint(c'),radius(end)));
        end
        fractionalFlux = fractionalFlux ./ integratedFlux; 
  
        pixFlux = pixFlux./totFlux;
        if(isvector(Cpixflux))
            % sqrt(var) normalize by same factor
            Cpixflux = Cpixflux./totFlux;
        else
            % covariance matrices get normalized by factor^2
            Cpixflux        = Cpixflux./(totFlux^2);
        end
        
    else
        cadenceGapFlag = true;   
    end
    
end

%% Package data for return

dataStruct.pixFlux        = pixFlux;
dataStruct.Cpixflux       = Cpixflux;
dataStruct.radius         = radius;
dataStruct.row            = row;
dataStruct.col            = col;
dataStruct.startTarget    = startTarget;
dataStruct.stopTarget     = stopTarget;
dataStruct.expectedFlux   = expectedFlux;
dataStruct.maxR           = maxR;
dataStruct.fractionalFlux = fractionalFlux;
dataStruct.aic            = aic;
