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

package gov.nasa.kepler.systest.sbt.data;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.pdc.PdcBand;
import gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristics;

import java.util.ArrayList;
import java.util.List;

/**
 * This class contains data processing characteristics for a cadence range.
 * 
 * @author Miles Cote
 * 
 */
public class SbtPdcProcessingCharacteristics implements SbtDataContainer {

    private FluxType fluxType = FluxType.SAP;
    private CadenceType cadenceType = CadenceType.LONG;
    private int startCadence;
    private int endCadence;
    private int keplerId;

    private String pdcMethod = "";
    private int numDiscontinuitiesDetected;
    private boolean harmonicsFitted;
    private boolean harmonicsRestored;
    private float targetVariability = Float.NaN;
    private List<SbtPdcBand> bands = newArrayList();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {

        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("fluxType", new SbtString(
            fluxType.toString()).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "cadenceType",
            new SbtString(cadenceType.toString()).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("startCadence",
            new SbtNumber(startCadence).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("endCadence", new SbtNumber(
            endCadence).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("keplerId", new SbtNumber(
            keplerId).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("pdcMethod", new SbtString(
            pdcMethod).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "numDiscontinuitiesDetected", new SbtNumber(
                numDiscontinuitiesDetected).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("targetVariability",
            new SbtNumber(targetVariability).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("bands",
            new SbtList(bands).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtPdcProcessingCharacteristics() {
    }

    public SbtPdcProcessingCharacteristics(int keplerId, int startCadence,
        int endCadence,
        PdcProcessingCharacteristics pdcProcessingCharacteristics) {

        if (keplerId != pdcProcessingCharacteristics.getKeplerId()) {
            throw new IllegalArgumentException(String.format(
                "keplerId %d does not match %d", keplerId,
                pdcProcessingCharacteristics.getKeplerId()));
        }
        if (pdcProcessingCharacteristics.getEndCadence() < startCadence) {
            throw new IllegalArgumentException(String.format(
                "endCadence %d not in range (%d, %d)",
                pdcProcessingCharacteristics.getEndCadence(), startCadence,
                endCadence));
        }
        if (pdcProcessingCharacteristics.getStartCadence() > endCadence) {
            throw new IllegalArgumentException(String.format(
                "startCadence %d not in range (%d, %d)",
                pdcProcessingCharacteristics.getStartCadence(), startCadence,
                endCadence));
        }

        fluxType = pdcProcessingCharacteristics.getFluxType();
        cadenceType = pdcProcessingCharacteristics.getCadenceType();
        this.keplerId = pdcProcessingCharacteristics.getKeplerId();
        this.startCadence = pdcProcessingCharacteristics.getStartCadence();
        this.endCadence = pdcProcessingCharacteristics.getEndCadence();

        pdcMethod = pdcProcessingCharacteristics.getPdcMethod();
        numDiscontinuitiesDetected = pdcProcessingCharacteristics.getNumDiscontinuitiesDetected();
        harmonicsFitted = pdcProcessingCharacteristics.isHarmonicsFitted();
        harmonicsRestored = pdcProcessingCharacteristics.isHarmonicsRestored();
        targetVariability = pdcProcessingCharacteristics.getTargetVariability();
        bands = new ArrayList<SbtPdcBand>();
        for (PdcBand pdcBand : pdcProcessingCharacteristics.getBands()) {
            bands.add(new SbtPdcBand(pdcBand));
        }
    }

    public FluxType getFluxType() {
        return fluxType;
    }

    public void setFluxType(FluxType fluxType) {
        this.fluxType = fluxType;
    }

    public CadenceType getCadenceType() {
        return cadenceType;
    }

    public void setCadenceType(CadenceType cadenceType) {
        this.cadenceType = cadenceType;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public void setKeplerId(int keplerId) {
        this.keplerId = keplerId;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
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

    public List<SbtPdcBand> getBands() {
        return bands;
    }

    public void setBands(List<SbtPdcBand> bands) {
        this.bands = bands;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (bands == null ? 0 : bands.hashCode());
        result = prime * result
            + (cadenceType == null ? 0 : cadenceType.hashCode());
        result = prime * result + endCadence;
        result = prime * result + (harmonicsFitted ? 1231 : 1237);
        result = prime * result + (harmonicsRestored ? 1231 : 1237);
        result = prime * result + numDiscontinuitiesDetected;
        result = prime * result
            + (pdcMethod == null ? 0 : pdcMethod.hashCode());
        result = prime * result + startCadence;
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
        if (!(obj instanceof SbtPdcProcessingCharacteristics)) {
            return false;
        }
        SbtPdcProcessingCharacteristics other = (SbtPdcProcessingCharacteristics) obj;
        if (bands == null) {
            if (other.bands != null) {
                return false;
            }
        } else if (!bands.equals(other.bands)) {
            return false;
        }
        if (cadenceType != other.cadenceType) {
            return false;
        }
        if (endCadence != other.endCadence) {
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
        if (pdcMethod != other.pdcMethod) {
            return false;
        }
        if (startCadence != other.startCadence) {
            return false;
        }
        if (Float.floatToIntBits(targetVariability) != Float.floatToIntBits(other.targetVariability)) {
            return false;
        }
        return true;
    }
}
