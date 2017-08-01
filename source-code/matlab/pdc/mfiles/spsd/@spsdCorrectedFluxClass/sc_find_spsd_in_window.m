function spsdLocation = sc_find_spsd_in_window( obj , targetIndex , spsdScWindowStart , spsdScWindowEnd , filterKernel )
% function spsdLocation = sc_find_spsd_in_window( obj , targetIndex , spsdScWindowStart , spsdScWindowEnd , filterKernel )
%
%     called by sc_locate_spsds()
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
    VERBOSE = 0;      % diagnostic plotting
    WINDOWLENGTH = 5; % currently hard-coded parameter for outlier removal

    values = obj.timeSeriesStruct.fluxResiduals(targetIndex,:)';
    gaps = obj.timeSeriesStruct.gaps(targetIndex,:)';
    
    % running median to get rid of outliers
    valuesFiltered = moving_filter( values , WINDOWLENGTH , 'median' );
    
    % calculate filter response
    filterResponse = conv( valuesFiltered , filterKernel , 'same' );
    
    % exclude gaps
    filterResponse(gaps) = nan;
    
    % we only look in the relevant window of 60 SCs (2 LCs) (or as specified in compile_spsd_blob())
    filterResponseInWindow = filterResponse(spsdScWindowStart:spsdScWindowEnd);
    
    % locate maximum
    filterResponseMax = find(abs(filterResponseInWindow)==max(abs(filterResponseInWindow)));
    
    % output position with correct offset - and per definition the index of the cadence before the SPSD
    spsdLocation = filterResponseMax + spsdScWindowStart - 2;
    
    % If the SPSD cannot be located set to -1
    if (isempty(spsdLocation) || spsdLocation < spsdScWindowStart || spsdLocation > spsdScWindowEnd)
        spsdLocation = -1;
    end
    
    if (VERBOSE)
        % plot flux time series
        figure;
        subplot(2,1,1);
        plot(values);
        hold on;
        plot(spsdLocation,values(spsdLocation),'ro');
        plot(spsdLocation+1,values(spsdLocation+1),'ro');
        set(gca,'xlim',[spsdScWindowStart-100 spsdScWindowEnd+100]);
        ylim = get(gca,'ylim');
        plot([ spsdLocation spsdLocation ] , ylim , 'k--');
        title('values');
        % plot filter response
        subplot(2,1,2);
        plot(filterResponse);
        hold on;
        set(gca,'xlim',[spsdScWindowStart-100 spsdScWindowEnd+100]);
        ylim = get(gca,'ylim');
        plot([ spsdLocation+1 spsdLocation+1 ] , ylim , 'k--');  % draw filter response maximum where it's really at
        title('filter response');
    end
end