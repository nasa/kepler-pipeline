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

package gov.nasa.kepler.mc;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Characterizes the processing of the flux results.
 * 
 * @author Forrest Girouard
 */
public class PdcProcessingCharacteristics implements Persistable {

    private String pdcMethod = "";

    private int numDiscontinuitiesDetected;

    private int numDiscontinuitiesRemoved;

    /**
     * Harmonics were fitted if {@code true}. This means that if this value is
     * {@code false}, the harmonic free time series will be the same as the
     * corrected time series.
     */
    private boolean harmonicsFitted;

    /**
     * The harmonic content was restored if harmonics had been fit and the
     * cotrending was good (uncorrectedSystematics = false). This means that the
     * corrected flux time series and the harmonic free corrected flux time
     * series should be the same for all targets where harmonicsRestored =
     * false.
     */
    private boolean harmonicsRestored;

    private float targetVariability;

    private List<PdcBand> bands = new ArrayList<PdcBand>();

    /**
     * Creates a empty {@link PdcProcessingCharacteristics} object.
     */
    public PdcProcessingCharacteristics() {
    }

    /**
     * Creates a {@link PdcProcessingCharacteristics} object.
     * 
     * @param bitmask the bitmask used to seed the object
     */
    public PdcProcessingCharacteristics(String pdcMethod,
        int numDiscontinuitiesDetected, int numDiscontinuitiesRemoved,
        boolean harmonicsFitted, boolean harmonicsRestored,
        float targetVariability, List<PdcBand> bands) {

        if (pdcMethod == null) {
            throw new IllegalArgumentException("pdcMethod can't be null");
        }
        this.pdcMethod = pdcMethod;
        this.numDiscontinuitiesDetected = numDiscontinuitiesDetected;
        this.numDiscontinuitiesRemoved = numDiscontinuitiesRemoved;
        this.harmonicsFitted = harmonicsFitted;
        this.harmonicsRestored = harmonicsRestored;
        this.targetVariability = targetVariability;
        this.bands = bands;
    }

    public PdcProcessingCharacteristics(
        gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristics ppc) {

        if (ppc.getPdcMethod() == null) {
            throw new IllegalArgumentException(
                "ppc.getPdcMethod() can't be null");
        }
        pdcMethod = ppc.getPdcMethod();
        numDiscontinuitiesDetected = ppc.getNumDiscontinuitiesDetected();
        numDiscontinuitiesRemoved = ppc.getNumDiscontinuitiesRemoved();
        harmonicsFitted = ppc.isHarmonicsFitted();
        harmonicsRestored = ppc.isHarmonicsRestored();
        targetVariability = ppc.getTargetVariability();
        bands = new ArrayList<PdcBand>();
        for (gov.nasa.kepler.hibernate.pdc.PdcBand pdcBand : ppc.getBands()) {
            bands.add(new PdcBand(pdcBand));
        }
    }

    public gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristics getDbInstance(
        long pipelineTaskId, FluxType fluxType, CadenceType cadenceType,
        int keplerId, int startCadence, int endCadence) {

        List<gov.nasa.kepler.hibernate.pdc.PdcBand> pdcBands = new ArrayList<gov.nasa.kepler.hibernate.pdc.PdcBand>();
        for (PdcBand band : bands) {
            pdcBands.add(band.getDbInstance());
        }
        gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristics pdcProcessingCharacteristics = new gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristics.Builder(
            pipelineTaskId, fluxType, cadenceType, keplerId).startCadence(
            startCadence)
            .endCadence(endCadence)
            .pdcMethod(getPdcMethod())
            .numDiscontinuitiesDetected(numDiscontinuitiesDetected)
            .numDiscontinuitiesRemoved(numDiscontinuitiesRemoved)
            .harmonicsFitted(harmonicsFitted)
            .harmonicsRestored(harmonicsRestored)
            .targetVariability(targetVariability)
            .bands(pdcBands)
            .build();

        return pdcProcessingCharacteristics;
    }

    public String getPdcMethod() {
        return pdcMethod;
    }

    public void setPdcMethod(String pdcMethod) {
        this.pdcMethod = pdcMethod;
    }

    public int getNumDiscontinuitiesDetected() {
        return numDiscontinuitiesDetected;
    }

    public void setNumDiscontinuitiesDetected(int numDiscontinuitiesDetected) {
        this.numDiscontinuitiesDetected = numDiscontinuitiesDetected;
    }

    public int getNumDiscontinuitiesRemoved() {
        return numDiscontinuitiesRemoved;
    }

    public void setNumDiscontinuitiesRemoved(int numDiscontinuitiesRemoved) {
        this.numDiscontinuitiesRemoved = numDiscontinuitiesRemoved;
    }

    public boolean isHarmonicsFitted() {
        return harmonicsFitted;
    }

    public void setHarmonicsFitted(boolean harmonicsFitted) {
        this.harmonicsFitted = harmonicsFitted;
    }

    public boolean isHarmonicsRestored() {
        return harmonicsRestored;
    }

    public void setHarmonicsRestored(boolean harmonicsRestored) {
        this.harmonicsRestored = harmonicsRestored;
    }

    public float getTargetVariability() {
        return targetVariability;
    }

    public void setTargetVariability(float targetVariability) {
        this.targetVariability = targetVariability;
    }

    public List<PdcBand> getBands() {
        return bands;
    }

    public void setBands(List<PdcBand> bands) {
        this.bands = bands;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (bands == null ? 0 : bands.hashCode());
        result = prime * result + (harmonicsFitted ? 1231 : 1237);
        result = prime * result + (harmonicsRestored ? 1231 : 1237);
        result = prime * result + numDiscontinuitiesDetected;
        result = prime * result + numDiscontinuitiesRemoved;
        result = prime * result
            + (pdcMethod == null ? 0 : pdcMethod.hashCode());
        result = prime * result + Float.floatToIntBits(targetVariability);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof PdcProcessingCharacteristics)) {
            return false;
        }
        PdcProcessingCharacteristics other = (PdcProcessingCharacteristics) obj;
        if (bands == null) {
            if (other.bands != null) {
                return false;
            }
        } else if (!bands.equals(other.bands)) {
            return false;
        }
        if (harmonicsFitted != other.harmonicsFitted) {
            return false;
        }
        if (harmonicsRestored != other.harmonicsRestored) {
            return false;
        }
        if (numDiscontinuitiesDetected != other.numDiscontinuitiesDetected) {
            return false;
        }
        if (numDiscontinuitiesRemoved != other.numDiscontinuitiesRemoved) {
            return false;
        }
        if (pdcMethod != other.pdcMethod) {
            return false;
        }
        if (Float.floatToIntBits(targetVariability) != Float.floatToIntBits(other.targetVariability)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ReflectionToStringBuilder(this).toString();
    }
}
