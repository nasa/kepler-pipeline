function browse_flux_compare(inputsStruct1,outputsStruct1,outputsStruct2,title1,title2,varargin)
% function browse_flux_compare(inputsStruct1,outputsStruct1,outputsStruct2,title1,title2,varargin)
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

    XLINKING  = 1;
    YSCALING  = 1;
    NANGAPS   = 1;
    LINESTYLE = 'b-';
    PLOTGAPS  = 0;
    
	n = length(inputsStruct1.targetDataStruct);
	f_ = figure;
    set(f_,'position',[2000 680 1600 900]);
    
    if (~isempty(varargin))
        targetlist = varargin{1};
    else
        targetlist = 1:n;
    end
    
    kIds1 = [ inputsStruct1.targetDataStruct().keplerId ];
    kIds2 = [ outputsStruct2.targetResultsStruct().keplerId ];
	
% 	for k=[ 611 452 1465 ]  % bad cases with MAP
% 	for k=[ 790 827 760 1027 466 ] % transits
%     for k=[11 12 23 27 37 56 76] % MAP better
%     for k=[4 5 8 19 22 57 81] % similar performance
%    for k=1:100
    i = 1;
    fSTOP = 0;
    while (~fSTOP)
        k = targetlist(i);
        % find index for second output
        kId = kIds1(k);
        k2 = find(kIds2==kId);
        if (~isempty(k2))
            % -- common --
            q = pdcToolsClass.quarter_lookup(inputsStruct1.cadenceTimes.midTimestamps(1));
            str = [ '   Target: ' int2str(k) '   Quarter: ' int2str(q) '   Mod.Out: ' int2str(inputsStruct1.ccdModule) '.' int2str(inputsStruct1.ccdOutput) '   KeplerId: ' int2str(inputsStruct1.targetDataStruct(k).keplerId) ];
%             str = [ '   Target: ' int2str(k) '   Quarter: ' int2str(q) '   Mod.Out: ' int2str(inputsStruct1.ccdModule) '.' int2str(inputsStruct1.ccdOutput) ];
            gaps = inputsStruct1.targetDataStruct(k).gapIndicators;
            t = 1:length(inputsStruct1.targetDataStruct(k).values);
            % -- INPUT --
            a_(1) = subplot(3,1,1);
            cla;
            if (NANGAPS)
                x = t;
                x(gaps) = nan;
                y = inputsStruct1.targetDataStruct(k).values;
                y(gaps) = nan;
            else
                x = t(~gaps);
                y = inputsStruct1.targetDataStruct(k).values(~gaps);
            end
            plot( x , y , LINESTYLE );
            title(['INPUT' str]);  
            box on;
            axis tight;
            % -- OUTPUT 1 --
            a_(2) = subplot(3,1,2);
            cla;
            hold on;
            if (NANGAPS)
                x = t;
                x(gaps) = nan;
                y = outputsStruct1.targetResultsStruct(k).correctedFluxTimeSeries.values;
                y(gaps) = nan;
            else
                x = t(~gaps);
                y = outputsStruct1.targetResultsStruct(k).correctedFluxTimeSeries.values(~gaps);
            end
            plot( x , y , LINESTYLE );
            if (PLOTGAPS)
                x = t(gaps);
                y = outputsStruct1.targetResultsStruct(k).correctedFluxTimeSeries.values(gaps);
                plot( x , y , 'r.' );
            end
            title([title1 str]);
            box on;
            axis tight;
            % -- OUTPUT 2 --
            a_(3) = subplot(3,1,3);
            cla;
            hold on;
            if (NANGAPS)
                x = t;
                x(gaps) = nan;
                y = outputsStruct2.targetResultsStruct(k).correctedFluxTimeSeries.values;
                y(gaps) = nan;
            else
                x = t(~gaps);
                y = outputsStruct2.targetResultsStruct(k).correctedFluxTimeSeries.values(~gaps);
            end
            plot( x , y , LINESTYLE );
            if (PLOTGAPS)
                x = t(gaps);
                y = outputsStruct2.targetResultsStruct(k).correctedFluxTimeSeries.values(gaps);
                plot( x , y , 'r.' );
            end
            title([title2 str]);
            box on;
            axis tight;
            % -- common --
            if (YSCALING)
                ylim2 = get(a_(2),'ylim');
                ylim3 = get(a_(3),'ylim');
                ylim(1) = min([ylim2(1) ylim3(1)]);
                ylim(2) = max([ylim2(2) ylim3(2)]);
                for j=2:3
                    set(a_(j),'ylim',ylim);
                end
            end
            if (XLINKING)
                linkaxes(a_,'x');
            end

            % Display diagnostic information
            pdc_display_target_diagnostics(k, outputsStruct1, outputsStruct2);

            % key input for navigation
            w = waitforbuttonpress;
            if (w)
                key = get(f_,'CurrentCharacter');
                keycode = uint8(key);
                switch(keycode)
                    case {28,30}      % CRSR_LEFT, CRSR_UP
                        % go backward
                        i = i - 1;
                    case {113,27}    % q, ESC
                        fSTOP = 1;
                    otherwise
                        % go forward
                        i = i + 1;
                end
                if ((i<1)||(i>length(targetlist)))
                    fSTOP = 1;
                end
            end
            
%             pause;
        else
            disp(['no data found for target ' int2str(k) ' in second dataset.']);
        end
	end;

end
