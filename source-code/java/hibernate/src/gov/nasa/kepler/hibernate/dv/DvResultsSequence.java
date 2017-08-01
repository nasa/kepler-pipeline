/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 * 
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */

package gov.nasa.kepler.hibernate.dv;

import java.util.List;

import javax.xml.bind.annotation.XmlRootElement;

/**
 * A place holder class that wraps multiple DvPlanetResults so it can be
 * exported via JAXB.
 * 
 * This probably should have been called DvTargetResults since anything added to
 * the persistable DvTargetResults that is destined for the database/XML will
 * need to be added here also.
 * 
 * @author Sean McCauliff
 * @author Forrest Girouard
 */
@XmlRootElement
public class DvResultsSequence {

    private List<DvPlanetResults> planetResults;

    private List<DvLimbDarkeningModel> limbDarkeningModels;

    private List<DvTargetResults> targetResults;

    private DvExternalTceModelDescription externalTceModelDescription;

    private DvTransitModelDescriptions transitModelDescriptions;

    public DvResultsSequence() {
    }

    /**
     * @param planetResults
     */
    public DvResultsSequence(List<DvPlanetResults> planetResults,
        List<DvLimbDarkeningModel> limbDarkeningModels,
        List<DvTargetResults> targetResults,
        DvExternalTceModelDescription externalTceModelDescription,
        DvTransitModelDescriptions transitModelDescriptions) {

        this.planetResults = planetResults;
        this.limbDarkeningModels = limbDarkeningModels;
        this.targetResults = targetResults;
        this.externalTceModelDescription = externalTceModelDescription;
        this.transitModelDescriptions = transitModelDescriptions;
    }

    public DvExternalTceModelDescription getExternalTceModelDescription() {
        return externalTceModelDescription;
    }

    public void setExternalTceModelDescription(
        DvExternalTceModelDescription externalTceModelDescription) {
        this.externalTceModelDescription = externalTceModelDescription;
    }

    public List<DvLimbDarkeningModel> getLimbDarkeningModels() {
        return limbDarkeningModels;
    }

    public void setLimbDarkeningModels(
        List<DvLimbDarkeningModel> limbDarkeningModels) {
        this.limbDarkeningModels = limbDarkeningModels;
    }

    public List<DvPlanetResults> getPlanetResults() {
        return planetResults;
    }

    public void setPlanetResults(List<DvPlanetResults> planetResults) {
        this.planetResults = planetResults;
    }

    public List<DvTargetResults> getTargetResults() {
        return targetResults;
    }

    public void setTargetResults(List<DvTargetResults> targetResults) {
        this.targetResults = targetResults;
    }

    public DvTransitModelDescriptions getTransitModelDescriptions() {
        return transitModelDescriptions;
    }

    public void setTransitModelDescriptions(
        DvTransitModelDescriptions transitModelDescriptions) {
        this.transitModelDescriptions = transitModelDescriptions;
    }

}
