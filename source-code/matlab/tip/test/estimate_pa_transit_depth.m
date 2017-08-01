function [outputStruct] = estimate_pa_transit_depth( P, paDataStruct, simulatedTransitsStruct )


% In this function we are updating paDataStruct so these are the kepler ids to use as a base
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
keplerId = paDataStruct.keplerId;
nTargets = length(keplerId);
nCadences = size(P.cadenceModified,1);
tpsPulseDurations = paDataStruct.tpsPulseDurations;

% initialize output
paTransitDepthPpm = nan(nTargets,1);
paMeanTransitDepthPpm = nan(nTargets,1);
% paTransitDepthPpmTps = nan(nTargets,1);
paMeanTransitDepthPpmTps = nan(nTargets,1);
tpsDurationHours  = nan(nTargets,1);
nTransitsInt = nan(nTargets,1);
inTransitNormalized = zeros(nCadences, nTargets);
inTransitNormalizedTps = zeros(nCadences, nTargets);
barycentricTimestamps = nan(nCadences, nTargets);
paMedianFlux = nan(nTargets, 1);
centralTransitLogical = false(nCadences, nTargets);


% extract injected flux time series - this struct only contains elements for targets with injected transits
T = P.transitParameterStructArray;
F = [T.originalFluxTimeSeries];
V = [F.values];
G = [F.gapIndicators];
V(G) = NaN;

% find which targets were injected
injectedKeplerIds = [T.keplerId];



% step through the target ids and estimate the average fractional flux added in transit
for iTarget = 1:length(keplerId)
    
    % extract fractional flux added for keplerId
    idx = P.keplerIds == keplerId(iTarget);
    fractionalFlux = P.fractionSignalSubtracted(:,idx);
    cadenceModified = P.cadenceModified(:,idx);
    
    % it could be that the fractional flux is complex valued if the transit model contains non-physical parameters
    % if this is the case, punt
    if all(isreal(fractionalFlux))
        
        % extract barycentric timestamps for keplerId
        idx = simulatedTransitsStruct.keplerId == keplerId(iTarget);
        barycentricTimestamps(:,iTarget) = simulatedTransitsStruct.transitModelStructArray(idx).cadenceTimes;
        
        % Since the barycentric time stamps are not evenly spaced, calculate median spacing in days
        baryDaysPerCadence = median(diff(barycentricTimestamps(:,iTarget)));
        
        % predict where transits will fall from TIP parameters
        epochDays = paDataStruct.tipEpochBjd(iTarget);
        periodDays = paDataStruct.tipPeriodDays(iTarget);
        durationDays = paDataStruct.transitModelDurationHours(iTarget) / 24;        
        
        % find the pulse duration closest to the modeled duration (hours)
        [~, closestPulseIdx] = min( abs( tpsPulseDurations - durationDays * 24 ));
        tpsDurationHours(iTarget) = tpsPulseDurations(closestPulseIdx);
        tpsDays = tpsDurationHours(iTarget) / 24;
        
        if durationDays > 0
        
            % start by setting inTransitNormalized array for target - 0 == out-of-transit, 1 == in-transit
            % assumes epoch is at the midway point of the transit
            inTransitNormalized(:,iTarget) = double(abs(mod(barycentricTimestamps(:,iTarget) - (epochDays - durationDays/2), periodDays)) <= durationDays);
            % do this for both the modeled duration and the closet tps pulse duration
            inTransitNormalizedTps(:,iTarget) = double(abs(mod(barycentricTimestamps(:,iTarget) - (epochDays - tpsDays/2), periodDays)) <= tpsDays);            

            % count the number of whole transits (nTransitsInt) - partial transits don't count (i.e. where either ingress or egress fall outside the unit of work)
            diffInTransit = diff(inTransitNormalized(:,iTarget));
            ingressIdx = find(diffInTransit > 0);
            egressIdx = find(diffInTransit < 0);

            % check precidence of transits
            if ~isempty(ingressIdx) && ~isempty(egressIdx)
                validEgressIdx = egressIdx > ingressIdx(1);
                validIngressIdx = ingressIdx < egressIdx(end);
                ingressIdx = ingressIdx(validIngressIdx);
                egressIdx = egressIdx(validEgressIdx);
            else
                ingressIdx = [];
                egressIdx = [];
            end
            nIngress = length(ingressIdx);
            nEgress = length(egressIdx);
            if nIngress ~= nEgress
                % these should be equal now or else there is a problem
                error(['A problem ocurred counting whole transits for target ',num2str(keplerId(iTarget))]);
            else
                % count interger number of transits
                nTransitsInt(iTarget) = nIngress;           

                % require the transit was actually injected in PA - this will capture any cadence gaps since cadenceModifed = false in PA gaps
                inTransitNormalized(:,iTarget) = inTransitNormalized(:,iTarget) .* double(cadenceModified);
                
                % set central transit flags
                centralTransitLogical(ceil(ingressIdx + (egressIdx - ingressIdx)/2),iTarget) = true;
            end

            % use modeled and tps pulse duration in days to normalized inTransit booleans
            cadencesPerDuration = durationDays / baryDaysPerCadence;
            cadencesPerDurationTps = tpsDays / baryDaysPerCadence;
            
            inTransitNormalized(:,iTarget) = inTransitNormalized(:,iTarget) ./ cadencesPerDuration;
            inTransitNormalizedTps(:,iTarget) = inTransitNormalizedTps(:,iTarget) ./ cadencesPerDurationTps;

            if any(inTransitNormalized(:,iTarget)) && any(~inTransitNormalized(:,iTarget))

                % fractional depth is in transit minimum - median out of transit value fractional flux added (use median since we don't want to
                % include fractional flux values that fall in PA gaps)
                minInTransit = min(fractionalFlux(logical(inTransitNormalized(:,iTarget))));
                medianOutOfTransit = nanmedian(fractionalFlux(~logical(inTransitNormalized(:,iTarget))));
                paTransitDepthPpm(iTarget) = 1e6 .* (medianOutOfTransit - minInTransit);                                         % in ppm

                % mean transit depth is the out of transit median - inTransit mean fractional flux added - modeled duration
                meanInTransit = nanmean(fractionalFlux(logical(inTransitNormalized(:,iTarget))));
                paMeanTransitDepthPpm(iTarget) = 1e6 .* (medianOutOfTransit - meanInTransit);                                 % in ppm
                
                % mean transit depth is the out of transit median - inTransit mean fractional flux added - tps pulse duration
                meanInTransitTps = nanmean(fractionalFlux(logical(inTransitNormalizedTps(:,iTarget))));
                paMeanTransitDepthPpmTps(iTarget) = 1e6 .* (medianOutOfTransit - meanInTransitTps);                           % in ppm

                % find median flux for this target
                idx = find(injectedKeplerIds == keplerId(iTarget), 1, 'first');
                paMedianFlux(iTarget) = nanmedian(V(:,idx));            
            end
            
        else            
            disp(['Modeled duration = 0 for target ',num2str(keplerId(iTarget)),'. Setting PA transit depth to NaN.']);            
        end        
    else
        disp(['Complex fractional flux for target ',num2str(keplerId(iTarget)),'. Setting PA transit depth to NaN.']);
    end
end

% set these equal until we figure out what the difference is
paTransitDepthPpmTps = paTransitDepthPpm;

    
% generate fractional number of transits seen by PA
nTransitsFrac = sum(inTransitNormalized)';
nTransitsFracTps = sum(inTransitNormalizedTps)';

if any( paTransitDepthPpm == 0 )
    display('The PA transit depth equals zero for the following keplerIds:');
    disp( keplerId( paTransitDepthPpm == 0 ) );
end

outputStruct = struct('paTransitDepthPpm',paTransitDepthPpm,...
                        'paMeanTransitDepthPpm',paMeanTransitDepthPpm,...
                        'paTransitDepthPpmTps',paTransitDepthPpmTps,...
                        'paMeanTransitDepthPpmTps',paMeanTransitDepthPpmTps,...
                        'inTransitNormalized',inTransitNormalized,...
                        'inTransitNormalizedTps',inTransitNormalizedTps,...
                        'paMedianFlux',paMedianFlux,...
                        'barycentricTimestamps',barycentricTimestamps,...
                        'nTransitsInt',nTransitsInt,...
                        'nTransitsFrac',nTransitsFrac,...
                        'nTransitsFracTps',nTransitsFracTps,...
                        'tpsDurationHours',tpsDurationHours,...
                        'centralTransitLogical',centralTransitLogical);
