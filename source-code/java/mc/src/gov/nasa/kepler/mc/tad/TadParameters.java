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

package gov.nasa.kepler.mc.tad;

import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.List;

/**
 * Contains the data needed to launch a TAD pipeline.
 * 
 * @author Miles Cote
 */
public class TadParameters implements Parameters {
    
    /**
     * e.g. "q0:q1,q2:q16,q17"
     */
    private String quarters = "";
    
    /**
     * This is the {@link TargetListSet} on which to run tad.
     * It is now a parallel array to the quarters field.
     * e.g. "suppTls1,suppTls2,suppTls3"
     */
    private String targetListSetName = "";

    /**
     * This field is only used if the targetListSetId is short cadence or
     * reference pixel. If the targetListSetId is long cadence, this field
     * should be set to null and will be ignored by tad.
     * It is now a parallel array to the quarters field.
     * e.g. "suppTls1,suppTls2,suppTls3"
     */
    private String associatedLcTargetListSetName = "";

    /**
     * If this {@link Parameters} instance is to be used for a supplemental tad
     * run, then this field should be set to the original {@link TargetListSet}
     * imported from flight ops.
     * It is now a parallel array to the quarters field.
     * e.g. "suppTls1,suppTls2,suppTls3"
     */
    private String supplementalFor = "";
    
    /**
     * Require that short cadence targets have associated long cadence targets in {@link CoaCommon#copyLcApertures()}.
     */
    private boolean lcTargetRequiredForScCopy = true;

    @ProxyIgnore
    private final TargetSelectionCrud targetSelectionCrud;
    @ProxyIgnore
    private final TargetCrud targetCrud;

    public TadParameters() {
        this(new TargetSelectionCrud(), new TargetCrud());
    }

    private TadParameters(TargetSelectionCrud targetSelectionCrud,
        TargetCrud targetCrud) {
        this.targetSelectionCrud = targetSelectionCrud;
        this.targetCrud = targetCrud;
    }

    public TadParameters(String targetListSetName,
        String associatedLcTargetListSetName) {
        this();
        this.targetListSetName = targetListSetName;
        this.associatedLcTargetListSetName = associatedLcTargetListSetName;
    }

    public TargetListSet targetListSet() {
        return targetSelectionCrud.retrieveTargetListSet(targetListSetName);
    }

    public TargetTable targetTable() {
        return targetListSet().getTargetTable();
    }

    public List<ObservedTarget> observedTargetsPlusRejected() {
        return targetCrud.retrieveObservedTargetsPlusRejected(targetTable());
    }

    public MaskTable maskTable() {
        return targetTable().getMaskTable();
    }

    public List<Mask> masks() {
        return targetCrud.retrieveMasks(maskTable());
    }

    public String getQuarters() {
        return quarters;
    }

    public void setQuarters(String quarters) {
        this.quarters = quarters;
    }

    public String getAssociatedLcTargetListSetName() {
        return associatedLcTargetListSetName;
    }

    public void setAssociatedLcTargetListSetName(
        String associatedLcTargetListSetName) {
        this.associatedLcTargetListSetName = associatedLcTargetListSetName;
    }

    public String getTargetListSetName() {
        return targetListSetName;
    }

    public void setTargetListSetName(String targetListSetName) {
        this.targetListSetName = targetListSetName;
    }

    public String getSupplementalFor() {
        return supplementalFor;
    }

    public void setSupplementalFor(String supplementalFor) {
        this.supplementalFor = supplementalFor;
    }

    public boolean isLcTargetRequiredForScCopy() {
        return lcTargetRequiredForScCopy;
    }

    public void setLcTargetRequiredForScCopy(boolean lcTargetRequiredForScCopy) {
        this.lcTargetRequiredForScCopy = lcTargetRequiredForScCopy;
    }
}
