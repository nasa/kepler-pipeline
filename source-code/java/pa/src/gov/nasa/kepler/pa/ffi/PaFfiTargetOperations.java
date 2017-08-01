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

package gov.nasa.kepler.pa.ffi;

import static com.google.common.collect.Lists.newArrayListWithExpectedSize;
import static com.google.common.collect.Sets.newHashSet;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.CalibratedPixelOperations;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.pa.PaTarget;

import java.util.Collections;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class provides targets with calibrated pixel time series and their
 * associated uncertainties where as the superclass deals solely with raw pixel
 * time series.
 * 
 * @author Forrest Girouard
 */
public class PaFfiTargetOperations extends CalibratedPixelOperations {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(PaFfiTargetOperations.class);

    private static final int DEFAULT_PPA_TARGET_COUNT = 512;

    private final List<PaTarget> ppaTargets = newArrayListWithExpectedSize(DEFAULT_PPA_TARGET_COUNT);
    private List<PaTarget> stellarTargets = Collections.emptyList();
    private List<PaTarget> allTargets = Collections.emptyList();

    /**
     * Creates a {@link PaFfiTargetOperations} object which can be used to
     * acquire the {@link PaTarget}s associated with the given parameters.
     */
    public PaFfiTargetOperations(final TargetTable targetTable,
        final TargetTable bgTargetTable, final int ccdModule,
        final int ccdOutput) {

        super(targetTable, bgTargetTable, ccdModule, ccdOutput);
    }

    @Override
    protected boolean processTarget(final TargetType type, final int ccdModule,
        final int ccdOutput, final ObservedTarget target,
        final Set<Pixel> pixels) {

        if (type != TargetType.BACKGROUND
            && target.containsLabel(TargetLabel.PPA_STELLAR)) {
            PaTarget paTarget = new PaTarget(target.getKeplerId(),
                target.getAperture()
                    .getReferenceRow(), target.getAperture()
                    .getReferenceColumn(), target.getLabels()
                    .toArray(new String[target.getLabels()
                        .size()]), (float) target.getFluxFractionInAperture(),
                        (float) target.getSignalToNoiseRatio(),
                        (float) target.getCrowdingMetric(),
                        (float) target.getSkyCrowdingMetric(),
                        target.getSaturatedRowCount(), 
                type, pixels);
            ppaTargets.add(paTarget);
        }

        return super.processTarget(type, ccdModule, ccdOutput, target, pixels);
    }

    @Override
    public Set<Pixel> loadTargetPixels(ObservedTarget target, int ccdModule,
        int ccdOutput) {

        if (target.containsLabel(TargetLabel.PPA_STELLAR)
            || target.getTargetTable()
                .getType() == TargetType.BACKGROUND) {
            return super.loadTargetPixels(target, ccdModule, ccdOutput);
        }

        return newHashSet();
    }

    public List<PaTarget> getAllTargets() {
        if (allTargets.isEmpty()) {
            getAllTargetsIntern();
        }
        return allTargets;
    }

    public List<PaTarget> getPpaTargets() {
        if (allTargets.isEmpty()) {
            getAllTargetsIntern();
        }
        return ppaTargets;
    }

    public List<PaTarget> getStellarTargets() {
        if (allTargets.isEmpty()) {
            getAllTargetsIntern();
        }
        return stellarTargets;
    }

    private void getAllTargetsIntern() {

        // force superclass to process target table
        getPixels();

        // concatenate the two lists such that PPA labeled targets are first
        allTargets = newArrayListWithExpectedSize(ppaTargets.size()
            + stellarTargets.size());
        allTargets.addAll(ppaTargets);
        allTargets.addAll(stellarTargets);
    }
}
