function browse_flux(inputsStruct,outputsStruct,varargin)
% function browse_flux(inputsStruct,outputsStruct,indices)
%   inputsStruct:  obvious
%   outputsStruct: obvious
%   indices:       indices of targets to plot [OPTIONAL]
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

    STYLE = '-';
    
	n = length(inputsStruct.targetDataStruct);

    if (isempty(varargin))
        targetlist = 1:n;
    else
        targetlist = varargin{1};
    end

	f_ = figure;
	
    i = 1;
    fSTOP = 0;
    while (~fSTOP)
% 	for i = 1:length(targetlist)
        k = targetlist(i);
		% -- common --
                q = pdcToolsClass.quarter_lookup(inputsStruct.cadenceTimes.midTimestamps(1));
		str = [ '   Target: ' int2str(k) '   Quarter: ' int2str(q) '   Mod.Out: ' int2str(inputsStruct.ccdModule) '.' int2str(inputsStruct.ccdOutput) '   KeplerId: ' int2str(inputsStruct.targetDataStruct(k).keplerId) ];
		gaps = inputsStruct.targetDataStruct(k).gapIndicators;
		t = 1:length(inputsStruct.targetDataStruct(k).values);
		% -- INPUT --
		a_(1) = subplot(2,1,1);
        cla;
		plot( t(~gaps) , inputsStruct.targetDataStruct(k).values(~gaps) , ['b' STYLE] );
		title(['INPUT' str]);  
		box on;
		axis tight;
		% -- OUTPUT --
		a_(2) = subplot(2,1,2);
        cla;
		hold on;
		plot( t(~gaps) , outputsStruct.targetResultsStruct(k).correctedFluxTimeSeries.values(~gaps) , ['b' STYLE] );
% 		plot( t(gaps) , outputsStruct.targetResultsStruct(k).correctedFluxTimeSeries.values(gaps) , 'r.' );
		title(['OUTPUT' str]);
		box on;
		axis tight;
		% -- common --
		linkaxes(a_,'x');

            % Display diagnostic information
            pdc_display_target_diagnostics(k, outputsStruct);

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
% 		pause;
    end

end
