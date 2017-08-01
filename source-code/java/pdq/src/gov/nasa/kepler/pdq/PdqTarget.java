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

package gov.nasa.kepler.pdq;

import static gov.nasa.kepler.mc.refpixels.RefPixelFileReader.GAP_INDICATOR_VALUE;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.mc.refpixels.RefPixelDescriptor;
import gov.nasa.kepler.mc.refpixels.TimeSeriesBuffer;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * A PDQ background or collateral target, contains all the information necessary
 * for PDQ to process this target.
 * 
 * @author Forrest Girouard
 * 
 */
public class PdqTarget implements Persistable {

    /**
     * The CCD module for this target.
     */
    private int ccdModule;

    /**
     * The CCD output for this target.
     */
    private int ccdOutput;

    /**
     * Labels whose values indicate characteristic properties of this target.
     * See {@link gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel}.
     */
    private String[] labels = new String[0];

    /**
     * List of pixels including their time series data and associated gap
     * indicators.
     */
    private List<PdqPixelTimeSeries> referencePixels;

    public PdqTarget() {
    }

    /**
     * Constructs a PDQ target from the given observed target and its associated
     * target definitions. The target definitions are retrieved externally and
     * passed in here so that they can be retained for later use.
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param target
     * @param targetDefs
     */
    PdqTarget(final int ccdModule, final int ccdOutput,
        final ObservedTarget target) {
        this(ccdModule, ccdOutput, target, target.getTargetDefinitions());
    }

    /**
     * Constructs a PDQ target from the given observed target and its associated
     * target definitions. The target definitions are retrieved externally and
     * passed in here so that they can be retained for later use.
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param target
     * @param targetDefs
     */
    PdqTarget(final int ccdModule, final int ccdOutput,
        final ObservedTarget target,
        final Collection<TargetDefinition> targetDefs) {
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;

        Set<String> labelSet = new HashSet<String>();
        for (String label : target.getLabels()) {
            if (label.startsWith("PDQ")) {
                labelSet.add(label);
            }
        }

        if (!labelSet.isEmpty()) {
            labels = new String[labelSet.size()];
            int index = 0;
            for (String label : labelSet) {
                labels[index++] = label;
            }
        }
        createPixelTimeSeries(target, targetDefs);
    }

    /**
     * Extracts the pixels from the given observed target and associated target
     * definitions.
     * 
     * @param target
     * @param targetDefs
     */
    private void createPixelTimeSeries(final ObservedTarget target,
        final Collection<TargetDefinition> targetDefs) {
        referencePixels = new ArrayList<PdqPixelTimeSeries>();

        Set<Offset> absAperturePixels = new HashSet<Offset>();
        Aperture aperture = target.getAperture();

        // aperture is null for supermask targets because they don't have
        // optimal apertures.
        if (aperture != null) {
            for (Offset offset : aperture.getOffsets()) {
                absAperturePixels.add(new Offset(offset.getRow()
                    + aperture.getReferenceRow(), offset.getColumn()
                    + aperture.getReferenceColumn()));
            }
        }

        for (TargetDefinition targetDefinition : targetDefs) {
            int referenceRow = targetDefinition.getReferenceRow();
            int referenceColumn = targetDefinition.getReferenceColumn();
            List<Offset> pixels = targetDefinition.getMask()
                .getOffsets();
            for (Offset pixel : pixels) {
                int ccdRow = referenceRow + pixel.getRow();
                int ccdColumn = referenceColumn + pixel.getColumn();
                PdqPixelTimeSeries pdqPixelTimeSeries = new PdqPixelTimeSeries(
                    ccdRow, ccdColumn, absAperturePixels.contains(new Offset(
                        ccdRow, ccdColumn)));
                referencePixels.add(pdqPixelTimeSeries);
            }
        }
    }

    /**
     * Updates each of the reference pixels associated with this PDQ target by
     * extracting the approprate time series data from the given buffer.
     * 
     * @param targetTableId
     * @param data
     */
    public void setTimeSeries(final int targetTableId,
        final TimeSeriesBuffer data) {
        RefPixelDescriptor rpd = new RefPixelDescriptor(targetTableId,
            ccdModule, ccdOutput, 0, 0);
        for (PdqPixelTimeSeries pixel : referencePixels) {
            rpd.setCcdColumn(pixel.getColumn());
            rpd.setCcdRow(pixel.getRow());
            int[] values = data.getTimeSeriesData()
                .get(rpd);
            if (values != null) {
                boolean[] gapIndicators = new boolean[values.length];
                for (int i = 0; i < gapIndicators.length; i++) {
                    if (values[i] == GAP_INDICATOR_VALUE) {
                        gapIndicators[i] = true;
                    }
                }
                pixel.setTimeSeries(values);
                pixel.setGapIndicators(gapIndicators);
            }
        }
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + ccdModule;
        result = PRIME * result + ccdOutput;
        result = PRIME * result + Arrays.hashCode(labels);
        result = PRIME * result
            + (referencePixels == null ? 0 : referencePixels.hashCode());
        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final PdqTarget other = (PdqTarget) obj;
        if (ccdModule != other.ccdModule) {
            return false;
        }
        if (ccdOutput != other.ccdOutput) {
            return false;
        }
        if (!Arrays.equals(labels, other.labels)) {
            return false;
        }
        if (referencePixels == null) {
            if (other.referencePixels != null) {
                return false;
            }
        } else if (!referencePixels.equals(other.referencePixels)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("ccdModule", ccdModule)
            .append("ccdOutput", ccdOutput)
            .append("labels", labels)
            .append("referencePixels.size",
                referencePixels != null ? referencePixels.size() : 0)
            .toString();
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public List<PdqPixelTimeSeries> getReferencePixels() {
        return referencePixels;
    }

    public void setCcdModule(final int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public void setCcdOutput(final int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    public void setReferencePixels(
        final List<PdqPixelTimeSeries> referencePixels) {
        this.referencePixels = referencePixels;
    }

    public String[] getLabels() {
        return Arrays.copyOf(labels, labels.length);
    }

}
