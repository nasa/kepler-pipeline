function spsdEventsBlob = sc_locate_spsds(obj , spsdEventsBlob , filterKernel )

% this function only updates the spsdEventsBlob with the scCadences field
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
    
% loop over targets
    nTargets = obj.timeSeriesStruct.parameters.nTargets;
    nEvents = length(spsdEventsBlob);

    if (nEvents>0)
        for i=1:nTargets
            k = find(obj.timeSeriesStruct.parameters.keplerId(i) == [spsdEventsBlob.keplerId]);        
            if (~isempty(k))
                nSpsds = length(spsdEventsBlob(k).lcCadences);
                for j=1:nSpsds
                    % locate the SC range where the SPSD is located
                    [ spsdScWindowStart , spsdScWindowEnd , isInRange ] = obj.sc_determine_spsd_window( spsdEventsBlob(k) , j );
                    % find the SPSD cadence in that window
                    if (isInRange)
                        targetIndex = i;
                        spsdLocation = obj.sc_find_spsd_in_window( targetIndex, ...      % index in current timeSeriesStruct
                                                               spsdScWindowStart, ...
                                                               spsdScWindowEnd, ...
                                                               filterKernel );
                    else
                        spsdLocation = -1;
                    end
                    % we simply add a field with the SC cadence index to the blob here
                    spsdEventsBlob(k).scCadences(j) = spsdLocation;

                    % diagnostic plotting stuff
                    if (VERBOSE)
                        fluxValues = obj.timeSeriesStruct.fluxResiduals(i,:);
                        figure;
                        plot( fluxValues );
                        hold on;
                        plot(spsdScWindowStart:spsdScWindowStart+29,fluxValues(spsdScWindowStart:spsdScWindowStart+29),'g');
                        plot(spsdScWindowStart+30:spsdScWindowEnd,fluxValues(spsdScWindowStart+30:spsdScWindowEnd),'r');
                        set(gca,'xlim',[ spsdScWindowStart-300 spsdScWindowEnd+300 ]);
                        title(['SPSD in target ' int2str(i) ' Kepler Id ' int2str(spsdEventsBlob(k).keplerId)]);
                    end
                end % for j=1:nSpsds
            end % if (~isempty(k))
        end % lfor i=1:nTargets
    end % if (nEvents>0)
    
end % function
