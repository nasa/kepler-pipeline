function dvResultStruct = retrieve_dv_results(keplerIds)
%
% dvResultStruct = retrieve_dv_results(keplerIds)
% 
% DESCRIPTION:
%     The SBT function retrieve_dv_results returns the the results of DV in a convenient native-MATLAB format.
%
% INPUTS:
%     keplerIds: a vector of Kepler IDs 
%
% OUTPUTS:
%     dvPlanetResultsStruct, a 1xn struct array with the following fields:
%         keplerId
%         planetNumber
%         planetCandidate
%         centroidResults
%         binaryDiscriminationResults
%         allTransitsFit
%         evenTransitsFit
%         oddTransitsFit
%         flux_type
%         singleTransitFitsJava, a 1xm struc array with the following fields:
%             keplerId                 Kepler ID of this transit's target.
%             planetNumber             Number of planets in this transit fit.
%             modelChiSquare       retrieve_dv_results    Chi-squared value for this fit.
%             transitModelName         Transit model name (string).
%             limbDarkeningModelName   Limb darkening model name (string).
%             modelParameterCovariance The covaiance matrix of the model's parameters.
%             robustWeights            Vector of robust weights.
%             planetModelFitType       Planet model fit type (string).
%             
%             modelParameters, a 1xk struct array with fields:
%                 name        This parameter's name (string).
%                 value       The value of this parameter.
%                 uncertainty The uncertainty in this parameter's value.
%                 isFitted    Is this parameter a fitted parameter (boolean)?
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
    import gov.nasa.kepler.systest.sbt.SandboxTools;
    SandboxTools.displayDatabaseConfig;

    if nargin > 1
        error('MATLAB:SBT:wrapper:retrieve_dv_results', ...
              '%d arguments were given, only one or zero args are supported.  See helptext.', nargin);
    end

    import gov.nasa.kepler.hibernate.dv.DvCrud;
    import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;

    dbInstance = DatabaseServiceFactory.getInstance();
    dvCrud = DvCrud(dbInstance);

    mainTic = tic();
    disp('Retrieving dv java results... ');
    if nargin ~= 1
        error('MATLAB:SBT:wrapper:retrieve_dv_results', ...
            '%d arguments were given, only one or zero args are supported.  See helptext.', nargin);
    end
    
    % Convert the vector of keplerIds into an ArrayList, per the
    % dvCrud.retrieveLatestPlanetResults input requirements:
    %
    import java.util.ArrayList
    keplerIdsList = ArrayList();
    for id = keplerIds
        keplerIdsList.add(int32(id));
    end
    dvPlanetResults = dvCrud.retrieveLatestPlanetResults(keplerIdsList);
    
    disp('Done dv java results.');
    toc(mainTic)

    dvResultStruct = convert_dv_planet_results_list(dvPlanetResults);
    
    dbInstance.clear();
    SandboxTools.close;
return

function dvPlanetResultsStruct = convert_dv_planet_results_list(dvPlanetResults)

    if isempty(dvPlanetResults)
        dvPlanetResultsStruct = [];
    end

    dvPlanetResultsStruct = repmat(struct('keplerId', [], 'planetNumber', [], 'pipelineId', [], 'planetCandidate', [], 'centroidResults', [], 'binaryDiscriminationResults', [], 'allTransitsFit', [], 'evenTransitsFit', [], 'oddTransitsFit', [], 'flux_type', '', 'singleTransitFits', []), dvPlanetResults.size(), 1);

    numDv = dvPlanetResults.size
    for ii = 1:numDv
        tic
        msg = sprintf('converting %d of %d', ii, numDv);
        disp(msg);

        result = dvPlanetResults.get(ii-1);
        
        dvPlanetResultsStruct(ii).keplerId     = result.getKeplerId();
        dvPlanetResultsStruct(ii).planetNumber = result.getPlanetNumber();
        dvPlanetResultsStruct(ii).pipelineId   = result.getPipelineTask.getPipelineInstance.getId;
        dvPlanetResultsStruct(ii).planetCandidate = convert_planet_candidate(result.getPlanetCandidate());
        dvPlanetResultsStruct(ii).centroidResults = convert_dv_centroid_results(result.getCentroidResults());
        dvPlanetResultsStruct(ii).binaryDiscriminationResults = convert_binary_discrimination_results(result.getBinaryDiscriminationResults());
        dvPlanetResultsStruct(ii).allTransitsFit  = convert_transit_fit(result.getAllTransitsFit());
        dvPlanetResultsStruct(ii).evenTransitsFit = convert_transit_fit(result.getEvenTransitsFit());
        dvPlanetResultsStruct(ii).oddTransitsFit  = convert_transit_fit(result.getOddTransitsFit());
        
        dvPlanetResultsStruct(ii).flux_type = char(result.getFluxType());
        
        singleTransitFitsJava = result.getSingleTransitFits();
        singleTransitFits = [];
        for jj = 1:singleTransitFitsJava.size()
            sft = singleTransitFitsJava(jj);

            singleTransitFits(jj).keplerId                 =      sft.getKeplerId();
            singleTransitFits(jj).planetNumber             =      sft.getPlanetNumber();
            singleTransitFits(jj).modelChiSquare           =      sft.getModelChiSquare();
            singleTransitFits(jj).transitModelName         = char(sft.getTransitModelName());
            singleTransitFits(jj).limbDarkeningModelName   = char(sft.getLimbDarkeningModelName());

            singleTransitFits(jj).modelParameterCovariance =      sft.getModelParameterCovariance().toArray();
            singleTransitFits(jj).robustWeights            =      sft.getRobustWeights().toArray();

            singleTransitFits(jj).planetModelFitType       = char(sft.getType());
            
            modelParameters =  List<DvModelParameter> sft.getModelParameters().toArray();
            for kk = 1:length(modelParameters)
                singleTransitFits(jj).modelParameters(kk).name  =  char(modelParameters(kk).getName());
                singleTransitFits(jj).modelParameters(kk).value =       modelParameters(kk).getValue();
                singleTransitFits(jj).modelParameters(kk).uncertainty = modelParameters(kk).getUncertainty();
                singleTransitFits(jj).modelParameters(kk).isFitted =    logical(modelParameters(kk).isFitted());
            end

        end
        dvPlanetResultsStruct(ii).singleTransitFits = singleTransitFits;
        toc
    end

return

function planetCandidate = convert_planet_candidate(planetCandidateJava) 
    planetCandidate.planetNumber         = planetCandidateJava.getPlanetNumber();
    planetCandidate.expectedTransitCount = planetCandidateJava.getExpectedTransitCount();
    planetCandidate.observedTransitCount = planetCandidateJava.getObservedTransitCount();
    planetCandidate.significance         = planetCandidateJava.getSignificance();

    bsHist = planetCandidateJava.getBootstrapHistogram();
    stats = bsHist.getStatistics().toArray();
    probs = bsHist.getStatistics().toArray();
    planetCandidate.bootstrapHistogram = struct('statistics', stats, 'probabilities', probs, 'finalSkipCount', bsHist.getFinalSkipCount);
    
return

function result = convert_dv_centroid_results(resultJava)
    result = struct();
    
    fwmr = resultJava.getFluxWeightedMotionResults();
    result.fluxWeightedCentroid.sourceRaHours.Value                   = fwmr.getSourceRaHours().getValue();
    result.fluxWeightedCentroid.sourceRaHours.Uncertainty             = fwmr.getSourceRaHours().getUncertainty();
    result.fluxWeightedCentroid.sourceDecDegrees.Value                = fwmr.getSourceDecDegrees().getValue();
    result.fluxWeightedCentroid.sourceDecDegrees.Uncertainty          = fwmr.getSourceDecDegrees().getUncertainty();
    result.fluxWeightedCentroid.sourceRaOffset.Value                  = fwmr.getSourceRaOffset().getValue();
    result.fluxWeightedCentroid.sourceRaOffset.Uncertainty            = fwmr.getSourceRaOffset().getUncertainty();
    result.fluxWeightedCentroid.sourceDecOffset.Value                 = fwmr.getSourceDecOffset().getValue();
    result.fluxWeightedCentroid.sourceDecOffset.Uncertainty           = fwmr.getSourceDecOffset().getUncertainty();
    result.fluxWeightedCentroid.peakRaOffset.Value                    = fwmr.getPeakRaOffset().getValue();
    result.fluxWeightedCentroid.peakRaOffset.Uncertainty              = fwmr.getPeakRaOffset().getUncertainty();
    result.fluxWeightedCentroid.peakDecOffset.Value                   = fwmr.getPeakDecOffset().getValue();
    result.fluxWeightedCentroid.peakDecOffset.Uncertainty             = fwmr.getPeakDecOffset().getUncertainty();
    result.fluxWeightedCentroid.motionDetectionStatistic.Value        = fwmr.getMotionDetectionStatistic().getValue();
    result.fluxWeightedCentroid.motionDetectionStatistic.Significance = fwmr.getMotionDetectionStatistic().getSignificance();

    prfmr = resultJava.getPrfMotionResults();
    result.prfCentroid.sourceRaHours.value                   = prfmr.getSourceRaHours().getValue();
    result.prfCentroid.sourceRaHours.uncertainty             = prfmr.getSourceRaHours().getUncertainty();
    result.prfCentroid.sourceDecDegrees.value                = prfmr.getSourceDecDegrees().getValue();
    result.prfCentroid.sourceDecDegrees.uncertainty          = prfmr.getSourceDecDegrees().getUncertainty();
    result.prfCentroid.sourceRaOffset.value                  = prfmr.getSourceRaOffset().getValue;
    result.prfCentroid.sourceRaOffset.uncertainty            = prfmr.getSourceRaOffset().getUncertainty();
    result.prfCentroid.sourceDecOffset.value                 = prfmr.getSourceDecOffset().getValue();
    result.prfCentroid.sourceDecOffset.uncertainty           = prfmr.getSourceDecOffset().getUncertainty();
    result.prfCentroid.peakRaOffset.value                    = prfmr.getPeakRaOffset().getValue();
    result.prfCentroid.peakRaOffset.uncertainty              = prfmr.getPeakRaOffset().getUncertainty();
    result.prfCentroid.peakDecOffset.value                   = prfmr.getPeakDecOffset().getValue();
    result.prfCentroid.peakDecOffset.uncertainty             = prfmr.getPeakDecOffset().getUncertainty();
    result.prfCentroid.motionDetectionStatistic.value        = prfmr.getMotionDetectionStatistic().getValue();
    result.prfCentroid.motionDetectionStatistic.significance = prfmr.getMotionDetectionStatistic().getSignificance();
return

function result = convert_binary_discrimination_results(resultJava)
    result = struct();
    
    result.oddEvenTransitEpochComparisonStatistic.value          = resultJava.getOddEvenTransitEpochComparisonStatistic().getValue();
    result.oddEvenTransitEpochComparisonStatistic.significance   = resultJava.getOddEvenTransitEpochComparisonStatistic().getSignificance();
    result.oddEvenTransitDepthComparisonStatistic.value          = resultJava.getOddEvenTransitDepthComparisonStatistic().getValue();
    result.oddEvenTransitDepthComparisonStatistic.significance   = resultJava.getOddEvenTransitDepthComparisonStatistic().getSignificance();
    result.singleTransitDepthComparisonStatistic.value           = resultJava.getSingleTransitDepthComparisonStatistic().getValue();
    result.singleTransitDepthComparisonStatistic.significance    = resultJava.getSingleTransitDepthComparisonStatistic().getSignificance();
    result.singleTransitDurationComparisonStatistic.value        = resultJava.getSingleTransitDurationComparisonStatistic().getValue();
    result.singleTransitDurationComparisonStatistic.significance = resultJava.getSingleTransitDurationComparisonStatistic().getSignificance();
    result.singleTransitEpochComparisonStatistic.value           = resultJava.getSingleTransitEpochComparisonStatistic().getValue();
    result.singleTransitEpochComparisonStatistic.significance    = resultJava.getSingleTransitEpochComparisonStatistic().getSignificance();
    result.shorterPeriodComparisonStatistic.value                = resultJava.getShorterPeriodComparisonStatistic().getValue();
    result.shorterPeriodComparisonStatistic.significance         = resultJava.getShorterPeriodComparisonStatistic().getSignificance();
    result.shorterPeriodComparisonStatistic.planetNumber         = resultJava.getShorterPeriodComparisonStatistic().getPlanetNumber();
    result.longerPeriodComparisonStatistic.value                 = resultJava.getLongerPeriodComparisonStatistic().getValue();
    result.longerPeriodComparisonStatistic.significance          = resultJava.getLongerPeriodComparisonStatistic().getSignificance();
    result.longerPeriodComparisonStatistic.planetNumber          = resultJava.getLongerPeriodComparisonStatistic().getPlanetNumber();
return

function transitFit = convert_transit_fit(transitFitJava)
    transitFit = struct();
    transitFit.keplerId                 =        transitFitJava.getKeplerId();
    transitFit.planetNumber             =        transitFitJava.getPlanetNumber();
    transitFit.modelChiSquare           =        transitFitJava.getModelChiSquare();
    transitFit.transitModelName         = char(  transitFitJava.getTransitModelName());
    transitFit.limbDarkeningModelName   = char(  transitFitJava.getLimbDarkeningModelName());
    transitFit.modelParameterCovariance = double(array_to_vector(transitFitJava.getModelParameterCovariance().toArray()));

    transitFit.planetModelType          = char(transitFitJava.getType());

    modelParamsJava = transitFitJava.getModelParameters().toArray();
    for im = 1:length(modelParamsJava)
        transitFit.modelParameters(im).name        = char(   modelParamsJava(im).getName());
        transitFit.modelParameters(im).value       =         modelParamsJava(im).getValue();
        transitFit.modelParameters(im).uncertainty =         modelParamsJava(im).getUncertainty();
        transitFit.modelParameters(im).fitted      = logical(modelParamsJava(im).isFitted());
    end
return

function vector = array_to_vector(array)
    vector = zeros(array.size());
    for ii = 1:array.size()
        vector(ii) = array(ii);
    end
return
