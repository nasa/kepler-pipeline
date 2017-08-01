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

package gov.nasa.kepler.dv.io;

import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * Abstract container of target table meta-data for a single CCD module output.
 * 
 * @author Forrest Girouard
 */
public abstract class DvAbstractTargetTableData implements Persistable {

    private int ccdModule;
    private int ccdOutput;
    private int endCadence;
    private int quarter;
    private int startCadence;
    private int targetTableId;

    /**
     * Creates a {@link DvAbstractTargetTableData}. For use only by
     * serialization, mock objects, and Hibernate.
     */
    public DvAbstractTargetTableData() {
    }

    /**
     * Creates a new {@link DvAbstractTargetTableData} from the given object.
     */
    public DvAbstractTargetTableData(Builder builder) {
        targetTableId = builder.targetTableId;
        ccdModule = builder.ccdModule;
        ccdOutput = builder.ccdOutput;
        quarter = builder.quarter;
        startCadence = builder.startCadence;
        endCadence = builder.endCadence;
    }

    /**
     * Creates a new immutable {@link DvAbstractTargetTableData} object, for use
     * by subclasses only.
     */
    protected DvAbstractTargetTableData(int targetTableId, int ccdModule,
        int ccdOutput, int startCadence, int endCadence, int quarter) {

        this.targetTableId = targetTableId;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.quarter = quarter;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public int getQuarter() {
        return quarter;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public int getTargetTableId() {
        return targetTableId;
    }

    /**
     * Used to construct a {@link DvAbstractTargetTableData} object. To use this
     * class, a {@link Builder} object is created with the required parameter
     * pipelineTask. Then non-null fields are set using the available builder
     * methods. Finally, a {@link DvAbstractTargetTableData} object is created
     * using the build method, implemented by sub-classes. For example:
     * 
     * <pre>
     * DvSubClass subClassObject = new DvSubClass.Builder(targetTableId).ccdModule(2)
     *     .ccdOutput(1)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Forrest Girouard
     */
    public static abstract class Builder {
        private int targetTableId;
        private int ccdModule;
        private int ccdOutput;
        private int quarter;
        private int startCadence;
        private int endCadence;

        /**
         * Creates a {@link Builder} object with the given required parameters.
         * 
         * @param targetTableId the target table ID
         */
        public Builder(int targetTableId) {
            this.targetTableId = targetTableId;
        }

        public Builder ccdModule(int ccdModule) {
            this.ccdModule = ccdModule;
            return this;
        }

        public Builder ccdOutput(int ccdOutput) {
            this.ccdOutput = ccdOutput;
            return this;
        }

        public Builder quarter(int quarter) {
            this.quarter = quarter;
            return this;
        }

        public Builder startCadence(int startCadence) {
            this.startCadence = startCadence;
            return this;
        }

        public Builder endCadence(int endCadence) {
            this.endCadence = endCadence;
            return this;
        }
    }

}
