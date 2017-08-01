function pre_transform_conditioning(obj,targetIndex)

%     VERBOSE = 1;
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

    % loop over all targets - NO
%     for n=1:obj.nTargets
        n = targetIndex;
        

	% do this for values as well as uncertainties (by a 1:2 loop) 
    % !!!!! Note that uncertainty timeseries have regularly space spikes !!!!!
    % May want to check this out later
    for s = [1 2]
        
        % fork for values or uncertainties
        switch (s)
            case 1
                inputSignal = obj.inputTargetDataStruct(n).values;
            case 2
                inputSignal = obj.inputTargetDataStruct(n).uncertainties;
        end        
        % everything the same again after here
        
        len = obj.nCadences;
        t = (1:len)';

        % for simpler access
        extrapRange = obj.configStruct.edgeEffectMitigationExtrapolationRange;
        aeeMethod = obj.configStruct.edgeEffectMitigationMethod;
        % hfigExtendedLightCurve = obj.diagnosticData.hfigExtendedLightCurve;
        % tailLen is limited by data length
        tailLen = min(extrapRange,len);
       
        detrendOutputStruct = struct('groupingMethod' , obj.configStruct.groupingMethod, ...
                                     'removedTrend' , [] ,...
                                     'detrendCoeff' , [] ,...
                                     'signalBegin' , 1, ...
                                     'signalEnd' , len );

        switch (aeeMethod)
            case 'none'
                detrendedSignal = inputSignal;
                detrendOutputStruct.signalBegin = 1;
                detrendOutputStruct.signalEnd = length(inputSignal);
                
            case 'zeropad'
                part1 = zeros(ceil(len/2),1);
                part2 = inputSignal;
                part3 = part1;
                detrendedSignal = [ part1 ; part2 ; part3 ];
                detrendOutputStruct.signalBegin = length(part1)+1;
                detrendOutputStruct.signalEnd = length(part1)+length(part2);
               
            case 'level'
                % linearly shear the signal so that signal(1)==signal(end
                detrendOutputStruct.removedTrend = linspace(inputSignal(1),inputSignal(end),len)';
                detrendOutputStruct.detrendCoeff = [ (inputSignal(end)-inputSignal(1))/len inputSignal(1)];
                detrendedSignal = inputSignal - detrendOutputStruct.removedTrend;
                
            case 'polyfit'
                % fit a polynom of order fitOrder to the signal and substract that
                % use different methods for 0 and 1 to speed things up
                switch (detrendInputStruct.fitOrder)
                    case 0
                        r = mean(inputSignal);
                        detrendOutputStruct.detrendCoeff = r;
                        detrendOutputStruct.removedTrend = ones(size(inputSignal)) * r;
                    case 1
                        r = regress(inputSignal,[ones(size(inputSignal)) t]);
                        detrendOutputStruct.detrendCoeff = [r(2) r(1)];
                        detrendOutputStruct.removedTrend = polyval(detrendOutputStruct.detrendCoeff,t);
                    otherwise
                        r = polyfit(t,inputSignal,detrendInputStruct.fitOrder);
                        detrendOutputStruct.detrendCoeff = r;
                        detrendOutputStruct.removedTrend = polyval(detrendOutputStruct.detrendCoeff,t);
                end
                detrendedSignal = inputSignal - detrendOutputStruct.removedTrend;
                
            case 'expointmirror'
                % extrapolate by pointmirroring:
                % transpose and flip signal such that there is point symmetry
                % at signal(1) and signal(end) (including doubling the end-points)
                % an offset can be calculated over the tails of the signal specified by extrapRange
                % -- this is the old code for offset calculation, just averaging
                % fittedBegin = mean(inputSignal(1:detrendInputStruct.extrapRange));
                % fittedEnd = mean(inputSignal(len-detrendInputStruct.extrapRange+1:len));
                % the new version does a linear extrapolation
                pf = polyfit(1:tailLen,inputSignal(1:tailLen)',1);
                fittedBegin = polyval(pf,1);
                pf = polyfit(len-tailLen+1:len,inputSignal(len-tailLen+1:len)',1);
                fittedEnd = polyval(pf,len+1);
                flippedSignal = flipud(inputSignal) - fittedEnd; % was inputSignal(end);
                part1 = -(flippedSignal-flippedSignal(end)) + fittedBegin ; % was inputSignal(1);
                part1 = part1((floor(len/2)+1):end);
                part2 = inputSignal;
                part3 = -flippedSignal+inputSignal(end);
                part3 = part3(1:ceil(len/2));
                detrendedSignal = [ part1 ; part2 ; part3 ];
                detrendOutputStruct.signalBegin = length(part1)+1;
                detrendOutputStruct.signalEnd = length(part1)+length(part2);
                
            case 'exlinear'
                % extrapolate linearly
                % the range of the linear fit is specified by extrapRange
                pf = polyfit(1:tailLen,inputSignal(1:tailLen)',1);
                part1 = polyval(pf,-len+1:0)';
                part1 = part1((floor(len/2)+1):end);
                part2 = inputSignal;
                pf = polyfit(length(part1)+length(part2)-tailLen+1:length(part1)+length(part2),inputSignal(len-tailLen+1:len)',1);
                part3 = polyval(pf,length(part1)+len+1:length(part1)+2*len);
                part3 = part3(1:ceil(len/2))';
                detrendedSignal = [ part1 ; part2 ; part3 ];
                detrendOutputStruct.signalBegin = length(part1)+1;
                detrendOutputStruct.signalEnd = length(part1)+length(part2);
                
            case 'exsym'
                % join input with reflected input at boundaries
                % called 'symmetric padding'
                part1 = flipud(inputSignal);
                part2 = inputSignal;
                part3 = flipud(inputSignal);
                detrendedSignal = [ part1 ; part2 ; part3 ];
                detrendOutputStruct.signalBegin = length(part1)+1;
                detrendOutputStruct.signalEnd = length(part1)+length(part2);
                
            case 'exsymtaper'
                % symmetric padding at boundaries, taper with periodic extension (as done in TPS, according to JJ)
                % Discontinuities:
                % extension at signal(1) is signal(end)
                % extension at signal(end) is signal(1)
                taper = linspace(0,1,length(inputSignal))';
                part1 = flipud(inputSignal) .* taper + inputSignal .* (1-taper);
                part2 = inputSignal;
                part3 = inputSignal .* taper +  flipud(inputSignal) .* (1-taper);
                detrendedSignal = [ part1 ; part2 ; part3 ];
                detrendOutputStruct.signalBegin = length(part1)+1;
                detrendOutputStruct.signalEnd = length(part1)+length(part2);
                
            case 'expointmirrortaper'
                % Extrapolate by pointmirroring:
                % Calculate offsets over the tails of the signal
                % specified by extrapRange: 
                %   fittedBegin is the linearly extrapolated value 
                %       at the first cadence *before* inputSignal 
                %       (using the first extrapRange samples of inputSignal). 
                %   fittedEnd is the linearly extrapolated value at the 
                %       next cadence *after* inputSignal
                %       (using the last extrapRange samples of inputSignal). 
                % Create extensions to the left (part1) and to the right
                % (part3) that join smoothly to the input signal (part2)
                % by adding the [negative time reversed input signal 
                % (with an added offset) weighted by a linear taper from 0 to 1]
                % to the [input signal weighted by (1 minus the linear taper)]
                taper = linspace(0,1,length(inputSignal))';
                
                % Could gap the earth-points and fill using pchip interpolation
                % But to use the function below, you need the cadenceTimes
                % struct as an input, and that's not currently part of the
                % bsDataObject.
                % maskWindow = 150;
                % gapIndicators = pdc_mas_recovery_regions(inputGaps, cadenceTimes, maskWindow);
                
                % offsetMethod is 'E' for original extrapolation method,
                % 'N' for no extrapolation, 'S' for savitzky-golay
                offsetMethod = 'E';
                switch offsetMethod
                    case 'E'
                        % Original version of Martin's default method 
                        % Extrapolate via linear fit at beginning and end of the signal
                        % to find offsets.
                        % Extrapolate to the point x = 0. See
                        % comments on part1, below.
                        pf = polyfit(1:tailLen,inputSignal(1:tailLen)',1);
                        fittedBegin = polyval(pf,0);
                        % Extrapolate to the next point after inputSignal(end)
                        pf = polyfit(len-tailLen+1:len,inputSignal(len-tailLen+1:len)',1);
                        fittedEnd = polyval(pf,len+1);
                        delta1 = 0;
                        delta3 = 0;
                    case 'N'
                        % Linear extrapolation is often not so good,
                        % because it introduces small steps at boundaries.
                        fittedBegin = inputSignal(1);
                        fittedEnd = inputSignal(end);
                        delta1 = 0;
                        delta3 = 0;
                    case 'S'
                        % No extrapolation doesn't work well for signals
                        % dominated by high-frequency noise.
                        % So: to get better offsets -- Implement 3rd order
                        % sgolayfilt to estimate the offsets at the edges,
                        % without extrapolation.
                        % The third input to sgolayfilt is frame length, which must be odd
                        sgOrder = 3;
                        frameLength = 2*floor(tailLen/2)+1;
                        y=sgolayfilt(inputSignal',sgOrder,frameLength);
                        fittedBegin = y(1);
                        fittedEnd = y(end);
                        
                        % Offsets for matching left and right extensions: 
                        % delta1 is the offset between the beginning of the
                        % input signal and the beginning of the 'modeled'
                        % input signal
                        % We want to offset the negative time-reversed copy so that
                        % its right end is as far above/below the estimated
                        % beginning point fittedBegin as inputSignal(1) is below/above
                        % it. In other words,
                        % the right end of part1 should be
                        % symmetrically reflected about fittedBegin
                        % as compared to inputSignal(1)
                        delta1 = inputSignal(1) - fittedBegin;
                       
                        % delta3 is the offset between the end of the input
                        % signal and the end of the 'modeled'
                        % input signal.
                        % We want to offset the negative time-reversed copy so that its left end
                        % is as far above/below the estimated endpoint
                        % fittedEnd as inputSignal(end) is below/above it. 
                        % In other words, the left end of part3 should be
                        % symmetrically reflected about fittedEnd as
                        % compared to inputSignal(end)
                        delta3 = inputSignal(end) - fittedEnd;
                        
                        skip = 1;
                        if(~skip)
                            figure
                            hold on
                            plot(inputSignal,'b')
                            plot(1:tailLen,y(1:tailLen),'r')
                            plot(len-tailLen+1:len,y(len-tailLen+1:len),'r')
                        end
                        
                end
                
                % Subtract fittedEnd from the time-reversed signal, to pin
                % the left end to inputSignal(end) - fittedEnd.
                % timeReversedSignal = flipud(inputSignal);
                flippedSignalMinusOffset = flipud(inputSignal) - fittedEnd; % was inputSignal(end);
                
                % Negative of the time-reversed signal, with with the right end pinned to the fitted value fittedBegin 
                part1 = -(flippedSignalMinusOffset-flippedSignalMinusOffset(end)) + fittedBegin - delta1; % was inputSignal(1);
                
                % Sum of the input signal weighted by (1-taper) and the
                % negative of the time-reversed signal (plus an appropriate offset) weighted by taper. 
                % Has values of inputSignal(1) at left end and fittedBegin at right end.  
                part1 = part1 .* taper + inputSignal .* (1-taper);
                
                % Part 1 is  the right half of the above signal
                % The last point of part1 has the value fittedBegin; if
                % part1 is to smoothly join at the left side of 
                % input signal, then fittedBegin should be the fit to x =
                % 0, not the fit to x = 1.
                part1 = part1((floor(len/2)+1):end);
                
                % Part 2 is the input signal itself
                part2 = inputSignal;
                
                % Negative of the time-reversed signal, with the left end
                % pinned to the fitted value fittedEnd
                % part3 = -flippedSignalMinusOffset+inputSignal(end);
                
                part3 = -flippedSignalMinusOffset + inputSignal(end) - delta3;
                
                
                % Sum of the input signal weighted by taper and the
                % negative of the time-reversed signal weighted by (1-taper)
                part3 = inputSignal .* taper + part3 .* (1-taper);
                
                % Part 3 is the left half of the above signal
                part3 = part3(1:ceil(len/2));
                
                % Extended signal is composed of the 3 parts joined
                % together
                detrendedSignal = [ part1 ; part2 ; part3 ];
                
                % End points of the original input signal
                detrendOutputStruct.signalBegin = length(part1)+1;
                detrendOutputStruct.signalEnd = length(part1)+length(part2);
                
            case 'reflection'
                part1 = [];
                part2 = inputSignal;
                part3 = flipud(inputSignal);
                
                 % Extended signal is composed of the 3 parts joined
                % together
                detrendedSignal = [ part1 ; part2 ; part3 ];
                
                % End points of the original input signal
                detrendOutputStruct.signalBegin = length(part1)+1;
                detrendOutputStruct.signalEnd = length(part1)+length(part2);
                
       end % switch

        % make time series even length (only in extension, does not affect final signal, but is required for transform)
        if (mod(length(detrendedSignal),2)==1)
            detrendedSignal(end+1) = detrendedSignal(end);
        end        
        % prepare outputs for this target
        outputSignal = detrendedSignal;
        

        % fork for values or uncertainties
        switch (s)
            case 1
                obj.intermediateFlux(:,targetIndex) = outputSignal;
                % obj.intermediateFlux = outputSignal;
            case 2
                obj.intermediateFluxUncertainties(:,targetIndex) = outputSignal;
                % obj.intermediateFluxUncertainties = outputSignal;
        end % switch
         % everything the same again after here
                

        % Diagnostic Plotting
        if ( (obj.diagnosticStruct.plotFigures) && (any(obj.diagnosticStruct.targetsToMonitor==n)) && (s==1) )
        % !!!!! if(s==1&&offsetMethod=='X')    
        % figure(hfigExtendedLightCurve);
            figure
            switch (aeeMethod)
                % plot without extensions
                case {'none','level','polyfit'}                    
                        figure; % need to re-use (and init) figure handles
                        subplot(2,1,1);
                        plot(inputSignal);
                        title(['input signal  (target ' int2str(n) ')']);
                        subplot(2,1,2);
                        plot(detrendedSignal,'r');
                        title(['conditioned signal  (target ' int2str(n) ')']);
                % plot with extension
                case {'expointmirror','exlinear','exsym','exsymtaper','expointmirrortaper'}
                        subplot(2,1,1);
                        plot(inputSignal);
                        title(['input signal  (target ' int2str(n) ')']);
                        subplot(2,1,2);
                        cla;
                        plot(detrendedSignal,'Color','y','LineWidth',5);
                        hold on;
                        plot(1:length(part1) , part1 , 'k.');
                        plot((length(part1)+1):(length(part1)+length(part2)), part2 , 'r.');
                        plot((length(part1)+length(part2)+1):(length(part1)+length(part2)+length(part3)) , part3 , 'k.');
                        % plot savitzky-golay filtered flux
                        plot((length(part1)+1):(length(part1)+length(part2)),y,'b')
                        title(['conditioned signal  (target ' int2str(n) ')']);
            end % switch
        end % if (obj.diagnosticStruct.plotFigures)
        
%     end % for n=1:length(nTargets)

    end % for s = [1 2] (loop signal values and uncertainties)
    
    % prepare general output
    % conditioningStruct could also contain more data, e.g. the detrending polynomial, or offsets (not required now)
    obj.conditioningStruct.signalBegin = detrendOutputStruct.signalBegin;
    obj.conditioningStruct.signalEnd = detrendOutputStruct.signalEnd;
    
end % function

