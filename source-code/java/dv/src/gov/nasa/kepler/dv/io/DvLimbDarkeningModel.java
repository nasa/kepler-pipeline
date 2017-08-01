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

import gov.nasa.spiffy.common.pi.Parameters;

/**
 * 
 * @author Forrest Girouard
 */
public class DvLimbDarkeningModel extends DvAbstractTargetTableData implements
    Parameters {

    private int keplerId;
    private String modelName;
    private float coefficient1;
    private float coefficient2;
    private float coefficient3;
    private float coefficient4;

    public DvLimbDarkeningModel() {
    }

    /**
     * Creates a new immutable {@link DvLimbDarkeningModel} object.
     */
    public DvLimbDarkeningModel(Builder builder) {
        super(builder);
        keplerId = builder.keplerId;
        modelName = builder.modelName;
        coefficient1 = builder.coefficient1;
        coefficient2 = builder.coefficient2;
        coefficient3 = builder.coefficient3;
        coefficient4 = builder.coefficient4;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public void setKeplerId(int keplerId) {
        this.keplerId = keplerId;
    }

    public String getModelName() {
        return modelName;
    }

    public void setModelName(String modelName) {
        this.modelName = modelName;
    }

    public float getCoefficient1() {
        return coefficient1;
    }

    public void setCoefficient1(float coefficient1) {
        this.coefficient1 = coefficient1;
    }

    public float getCoefficient2() {
        return coefficient2;
    }

    public void setCoefficient2(float coefficient2) {
        this.coefficient2 = coefficient2;
    }

    public float getCoefficient3() {
        return coefficient3;
    }

    public void setCoefficient3(float coefficient3) {
        this.coefficient3 = coefficient3;
    }

    public float getCoefficient4() {
        return coefficient4;
    }

    public void setCoefficient4(float coefficient4) {
        this.coefficient4 = coefficient4;
    }

    /**
     * Used to construct an immutable {@link DvLimbDarkeningModel} object. To
     * use this class, a {@link Builder} object is created and then non-null
     * fields are set using the available builder methods. Finally, a
     * {@link DvLimbDarkeningModel} object is created using the {@code build}
     * method. For example:
     * 
     * <pre>
     * DvLimbDarkeningModel limbDarkeningModel = new DvLimbDarkeningModel.Builder().coefficient1(
     *     coefficient1)
     *     .coefficient2(coefficient2)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Forrest Girouard
     */
    public static class Builder extends DvAbstractTargetTableData.Builder {

        private int keplerId;
        private String modelName;
        private float coefficient1;
        private float coefficient2;
        private float coefficient3;
        private float coefficient4;

        public Builder(int targetTableId, int keplerId) {
            super(targetTableId);
            this.keplerId = keplerId;
        }

        @Override
        public Builder ccdModule(int ccdModule) {
            super.ccdModule(ccdModule);
            return this;
        }

        @Override
        public Builder ccdOutput(int ccdOutput) {
            super.ccdOutput(ccdOutput);
            return this;
        }

        @Override
        public Builder quarter(int quarter) {
            super.quarter(quarter);
            return this;
        }

        @Override
        public Builder startCadence(int startCadence) {
            super.startCadence(startCadence);
            return this;
        }

        @Override
        public Builder endCadence(int endCadence) {
            super.endCadence(endCadence);
            return this;
        }

        public Builder modelName(String modelName) {
            this.modelName = modelName;
            return this;
        }

        public Builder coefficient1(float coefficient1) {
            this.coefficient1 = coefficient1;
            return this;
        }

        public Builder coefficient2(float coefficient2) {
            this.coefficient2 = coefficient2;
            return this;
        }

        public Builder coefficient3(float coefficient3) {
            this.coefficient3 = coefficient3;
            return this;
        }

        public Builder coefficient4(float coefficient4) {
            this.coefficient4 = coefficient4;
            return this;
        }

        public DvLimbDarkeningModel build() {
            return new DvLimbDarkeningModel(this);
        }
    }
}
