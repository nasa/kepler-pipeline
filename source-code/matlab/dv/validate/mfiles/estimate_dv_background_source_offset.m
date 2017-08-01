function [targetResults, alertsOnly] = ...
                    estimate_dv_background_source_offset(targetStruct,...
                                                            targetResults,...
                                                            whitenerResultsStruct,...
                                                            centroidType,...
                                                            centroidTestConfigurationStruct,...
                                                            alertsOnly)
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
%
% function [targetResults, alertsOnly] = ...
%                     estimate_dv_background_source_offset(targetStruct,...
%                                                             targetResults,...
%                                                             whitenerResultsStruct,...
%                                                             centroidType,...
%                                                             centroidTestConfigurationStruct,...
%                                                             alertsOnly)
%
% This function uses the results of the centroid test iterative whitener provided in whitenerResultsStruct to estimate the absolute ra and dec
% position of a background source corresponding to transit features in the centroid time series. For details of the background source
% position estimate see KADN-26083, sections 2-3. 


disp('DV:CentroidTest:Estimating background source offset');

% units conversion
HOURS_PER_DAY = get_unit_conversion('day2hour');
MINUTES_PER_HOUR = get_unit_conversion('hour2min');
SECONDS_PER_MINUTE = get_unit_conversion('min2sec');
DEGREES_PER_DAY = 360;
DEGREES_TO_ARCSEC = MINUTES_PER_HOUR * SECONDS_PER_MINUTE;
DEGREES_TO_HOURS = HOURS_PER_DAY / DEGREES_PER_DAY;

% unpack parameters
MAXIMUM_SOURCE_RA_DEC_OFFSET_ARCSEC = centroidTestConfigurationStruct.maximumSourceRaDecOffsetArcsec;
motionResultsString = [centroidType,'MotionResults'];
nPlanets = length( targetResults.planetResultsStruct );

targetRaDegrees  = targetStruct.raHours.value / DEGREES_TO_HOURS;
CtargetRaDegrees  = (targetStruct.raHours.uncertainty / DEGREES_TO_HOURS)^2;
targetDecDegrees = targetStruct.decDegrees.value;
CtargetDecDegrees = targetStruct.decDegrees.uncertainty^2;

iPlanet = 0;
while(iPlanet<nPlanets)
    iPlanet = iPlanet + 1;

    % Since the transit model is a negative deflection from zero, a
    % positive centroid shift will have a negative fit coefficient.
    % But the source offsets are the negative of the whitened centroid
    % offsets so they are just the fit amplitudes in whitened domain.
    sourceRaOffset      =  whitenerResultsStruct.ra.coefficients(iPlanet);
    CsourceRaOffset     =  whitenerResultsStruct.ra.covarianceMatrix(iPlanet,iPlanet);
    sourceDecOffset     =  whitenerResultsStruct.dec.coefficients(iPlanet);
    CsourceDecOffset    =  whitenerResultsStruct.dec.covarianceMatrix(iPlanet,iPlanet);

    % absolute target ra and dec are the mean out of transit centroid from whitener output
    meanTargetRa    = whitenerResultsStruct.ra.meanOutOfTransitCentroid;
    CmeanTargetRa   = whitenerResultsStruct.ra.CmeanOutOfTransitCentroid;
    meanTargetDec   = whitenerResultsStruct.dec.meanOutOfTransitCentroid;
    CmeanTargetDec  = whitenerResultsStruct.dec.CmeanOutOfTransitCentroid;
    
    % add source ra and dec offset to mean target centroid ra and
    % dec to get source ra and dec location
    sourceRa    = meanTargetRa + sourceRaOffset;
    sourceDec   = meanTargetDec + sourceDecOffset;
    CsourceRa   = CmeanTargetRa + CsourceRaOffset;
    CsourceDec  = CmeanTargetDec + CsourceDecOffset;
    
    % redefine the source offset with respect to the target location rather
    % than the out of transit centroid
    sourceRaOffset = sourceRa - targetRaDegrees;
    sourceDecOffset = sourceDec - targetDecDegrees;
    
    % adding propagation of uncertainty of KIC RA/Dec w/NaN checking
    if ~isnan(CtargetRaDegrees)
        CsourceRaOffset = CsourceRa + CtargetRaDegrees;
    else
        CsourceRaOffset = CsourceRa;
    end
    if ~isnan(CtargetDecDegrees)
        CsourceDecOffset = CsourceDec + CtargetDecDegrees;
    else
        CsourceDecOffset = CsourceDec;
    end
    
    % consistent with estimate_dv_centroid_offset we include the cos(dec)
    % correction in the raOffset term and its uncertainty
    sourceRaOffset = sourceRaOffset * cosd(targetDecDegrees);
    CsourceRaOffset = CsourceRaOffset * cosd(targetDecDegrees)^2;

    % save mean out of transit centroid fields
    if ( CmeanTargetRa >= 0 )
        targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).outOfTransitCentroidRaHours.value = ...
            meanTargetRa * DEGREES_TO_HOURS;
        targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).outOfTransitCentroidRaHours.uncertainty = ...
            sqrt(CmeanTargetRa) * DEGREES_TO_HOURS;
    end
    
    if ( CmeanTargetDec >= 0 )
        targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).outOfTransitCentroidDecDegrees.value = ...
            meanTargetDec;
        targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).outOfTransitCentroidDecDegrees.uncertainty = ...
            sqrt(CmeanTargetDec);
    end
    
    % ~~~~~~~~~~~~~~~~~~~~~~~ update source ra offset fields if whitener results for offsets are available
    if( CsourceRaOffset < 0 )
        disp(['     Iterative whitener results unavailable. Cannot estimate background source ra offset.'...
                ' Using default values for planet ',num2str(iPlanet),'.']);
        alertsOnly = add_dv_alert(alertsOnly, ['Centroid test',centroidType], 'warning',...
                        ['Iterative whitener results unavailable. Cannot estimate background source ra offset.'...
                        ' Using default values for planet ',num2str(iPlanet),'.'],...
                        targetStruct.targetIndex, targetStruct.keplerId,iPlanet);
    else        
        % save source ra offset results
        targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).sourceRaOffset.value = ...
            sourceRaOffset * DEGREES_TO_ARCSEC;        
        targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).sourceRaOffset.uncertainty = ...
            sqrt( CsourceRaOffset ) * DEGREES_TO_ARCSEC;   
    end
    
    % ~~~~~~~~~~~~~~~~~~~~~~~ update source dec offset fields if whitener results for offsets are available
    if( CsourceDecOffset < 0 )
        disp(['     Iterative whitener results unavailable. Cannot estimate background source dec offset.'...
                ' Using default values for planet ',num2str(iPlanet),'.']);
        alertsOnly = add_dv_alert(alertsOnly, ['Centroid test',centroidType], 'warning',...
                        ['Iterative whitener results unavailable. Cannot estimate background source dec offset.'...
                        ' Using default values for planet ',num2str(iPlanet),'.'],...
                        targetStruct.targetIndex, targetStruct.keplerId,iPlanet);
    else
        % save source dec offset results
        targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).sourceDecOffset.value = ...
            sourceDecOffset * DEGREES_TO_ARCSEC;        
        targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).sourceDecOffset.uncertainty = ...
            sqrt( CsourceDecOffset ) * DEGREES_TO_ARCSEC;        
    end
    
    
    % ~~~~~~~~~~~~~~~~~~~~~~~ update source ra dec fields if whitener results for offsets are available
    if( CsourceRaOffset < 0 || CsourceDecOffset < 0 )
        disp(['     Iterative whitener results unavailable. Cannot estimate background source ra and dec.'...
                        ' Using default values for planet ',num2str(iPlanet),'.']);
        alertsOnly = add_dv_alert(alertsOnly, ['Centroid test',centroidType], 'warning',...
                        ['Iterative whitener results unavailable. Cannot estimate background source ra and dec.'...
                        ' Using default values for planet ',num2str(iPlanet),'.'],...
                        targetStruct.targetIndex, targetStruct.keplerId,iPlanet);          
    else
        
        % update results struct with source ra/dec if calculated source offset is within MAXIMUM_SOURCE_RA_DEC_OFFSET_ARCSEC
        if( sourceRaOffset * DEGREES_TO_ARCSEC < MAXIMUM_SOURCE_RA_DEC_OFFSET_ARCSEC &&...
                sourceDecOffset * DEGREES_TO_ARCSEC < MAXIMUM_SOURCE_RA_DEC_OFFSET_ARCSEC )

            % save results in raHours and decDegrees
            targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).sourceRaHours.value    = ...
                sourceRa * DEGREES_TO_HOURS;
            targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).sourceDecDegrees.value = ...
                sourceDec;
            targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).sourceRaHours.uncertainty = ...
                sqrt(CsourceRa) * DEGREES_TO_HOURS ;
            targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).sourceDecDegrees.uncertainty = ...
                sqrt(CsourceDec);
            
            % update source offset
            sourceRaOffsetArcSec = sourceRaOffset * DEGREES_TO_ARCSEC;
            sourceRaOffsetArcSecUnc = sqrt(CsourceRaOffset) * DEGREES_TO_ARCSEC;
            sourceDecOffsetArcSec = sourceDecOffset * DEGREES_TO_ARCSEC;
            sourceDecOffsetArcSecUnc = sqrt(CsourceDecOffset) * DEGREES_TO_ARCSEC;
            
            % include cod(dec) correction to the deltRa^2 term
            sourceOffsetArcSec = sqrt(sourceRaOffsetArcSec^2 + sourceDecOffsetArcSec^2);
            if sourceOffsetArcSec ~= 0
                sourceOffsetArcSecUnc = (1/sourceOffsetArcSec) * sqrt(sourceRaOffsetArcSec^2 * sourceRaOffsetArcSecUnc^2 +...
                                                                        sourceDecOffsetArcSec^2 * sourceDecOffsetArcSecUnc^2);
            else
                sourceOffsetArcSecUnc = sqrt(sourceRaOffsetArcSecUnc^2 + sourceDecOffsetArcSecUnc^2);
            end
                        
            targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).sourceOffsetArcSec.value       = sourceOffsetArcSec;
            targetResults.planetResultsStruct(iPlanet).centroidResults.(motionResultsString).sourceOffsetArcSec.uncertainty = sourceOffsetArcSecUnc;

        else
            disp(['     Background source location more than ',num2str(MAXIMUM_SOURCE_RA_DEC_OFFSET_ARCSEC),' arc-sec from target centroid.',...
                            ' Using default source ra and dec for planet ',num2str(iPlanet),'.']);
            alertsOnly = add_dv_alert(alertsOnly, ['Centroid test',centroidType], 'warning',...
                            ['Background source location more than ',num2str(MAXIMUM_SOURCE_RA_DEC_OFFSET_ARCSEC),' arc-sec from target centroid.',...
                            ' Using default source ra and dec for planet ',num2str(iPlanet),'.'],...
                            targetStruct.targetIndex, targetStruct.keplerId,iPlanet); 
        end
    end
end


