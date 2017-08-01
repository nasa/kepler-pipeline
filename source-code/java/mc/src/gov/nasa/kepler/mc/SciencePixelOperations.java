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

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Operations on targets for a single CCD module output for a given
 * {@link TargetTable} to get all the associated science pixel {@link FsId}s and
 * {@link TimeSeries}.
 * 
 * @author Sean McCauliff
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class SciencePixelOperations extends TimeSeriesOperations {

    private static final Log log = LogFactory.getLog(SciencePixelOperations.class);

    private final TargetTable targetTable;
    private final TargetTable bgTargetTable;
    private final int ccdModule;
    private final int ccdOutput;
    private TargetCrud targetCrud = new TargetCrud();

    private int targetCount = -1;
    private Pair<List<Set<FsId>>, List<Set<FsId>>> allFsIdsPerTarget;

    /** The non-background pixels. */
    private final Set<Pixel> targetPixels = new HashSet<Pixel>();
    private final Set<Pixel> backgroundPixels = new HashSet<Pixel>();

    /** This is used to generate log statements. */
    private final Map<Pixel, Pixel> pixelByPixel = new HashMap<Pixel, Pixel>();

    /**
     * Creates a {@link SciencePixelOperations} object which can be used to
     * access {@link FsId}s and {@link TimeSeries} associated with the given
     * parameters.
     */
    public SciencePixelOperations(TargetTable targetTable,
        TargetTable bgTargetTable, int ccdModule, int ccdOutput) {

        this.targetTable = targetTable;
        this.bgTargetTable = bgTargetTable;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
    }

    /**
     * FsIds grouped by target. Each set has distinct ids, but the ids may not
     * be globally distinct. Targets are not returned in any particular order.
     * 
     * @return A non-null list of sets of ids per target.
     */
    public List<Set<FsId>> getFsIdsPerTarget() {
        if (allFsIdsPerTarget == null) {
            allFsIdsPerTarget = generatePixelsAndIds();
        }

        return allFsIdsPerTarget.left;
    }

    public List<Set<FsId>> getMjdFsIdsPerTarget() {
        if (allFsIdsPerTarget == null) {
            allFsIdsPerTarget = generatePixelsAndIds();
        }

        return allFsIdsPerTarget.right;
    }

    /**
     * Called once per target to update the internal pixel sets. Subclasses can
     * determine if the target is of interest and do additional bookkeeping as
     * necessary. The default implementation always returns true.
     * 
     * @param type
     * @param ccdModule
     * @param ccdOutput
     * @param target
     * @param pixels
     * @return true if the target should be included
     */
    protected boolean processTarget(TargetType type, int ccdModule,
        int ccdOutput, ObservedTarget target, Set<Pixel> pixels) {

        // update pixel sets
        if (target.getTargetTable()
            .getType() == TargetType.BACKGROUND) {
            backgroundPixels.addAll(pixels);
        } else {
            targetPixels.addAll(pixels);
        }
        // always accept the target to continue processing
        return true;
    }

    private Pair<List<Set<FsId>>, List<Set<FsId>>> generatePixelsAndIds() {

        // Retrieve the targets in this target table.
        List<ObservedTarget> targets = Collections.emptyList();
        if (targetTable != null) {
            targets = targetCrud.retrieveObservedTargets(targetTable,
                ccdModule, ccdOutput);
            log.info(String.format("targetTable: externalId=%d"
                + "; targetType=%s" + "; targetCount=%d",
                targetTable.getExternalId(), targetTable.getType(),
                targets != null ? targets.size() : 0));
        }

        // Retrieve the targets in the background target table (not for short
        // cadence).
        List<ObservedTarget> backgroundTargets = Collections.emptyList();
        if (bgTargetTable != null) {
            backgroundTargets = targetCrud.retrieveObservedTargets(
                bgTargetTable, ccdModule, ccdOutput);
            log.info(String.format("backgroundTargetTable: externalId=%d"
                + "; targetType=%s" + "; targetCount=%d",
                bgTargetTable.getExternalId(), bgTargetTable.getType(),
                backgroundTargets != null ? backgroundTargets.size() : 0));
        }

        List<ObservedTarget> allTargets = new ArrayList<ObservedTarget>(
            targets.size() + backgroundTargets.size());
        allTargets.addAll(targets);
        allTargets.addAll(backgroundTargets);

        targetCount = allTargets.size();

        // Reset accumulators.
        targetPixels.clear();
        backgroundPixels.clear();
        pixelByPixel.clear();

        List<Set<FsId>> targetFsIds = new ArrayList<Set<FsId>>(targetCount);
        List<Set<FsId>> targetMjdFsIds = new ArrayList<Set<FsId>>(targetCount);

        for (ObservedTarget target : allTargets) {
            Set<Pixel> targetPixels = loadTargetPixels(target, ccdModule,
                ccdOutput);

            if (log.isDebugEnabled()) {
                log.debug(String.format("target: keplerId=%d"
                    + "; totalPixelCount=%d" + "; badPixelCount=%d",
                    target.getKeplerId(), targetPixels.size(),
                    target.getBadPixelCount()));
            }

            if (processTarget(target.getTargetTable()
                .getType(), ccdModule, ccdOutput, target, targetPixels)) {

                Set<FsId> fsIds = new HashSet<FsId>(targetPixels.size());
                Set<FsId> mjdFsIds = new HashSet<FsId>(targetPixels.size());
                for (Pixel pixel : targetPixels) {
                    fsIds.addAll(pixel.getFsIds());
                    mjdFsIds.addAll(pixel.getMjdFsIds());
                }
                targetFsIds.add(fsIds);
                targetMjdFsIds.add(mjdFsIds);
            }
        }

        if (targets.size() > 0) {
            DatabaseServiceFactory.getInstance()
                .evictAll(targets);
        }
        if (backgroundTargets.size() > 0) {
            DatabaseServiceFactory.getInstance()
                .evictAll(backgroundTargets);
        }

        return Pair.of(targetFsIds, targetMjdFsIds);
    }

    /**
     * 
     * @return non-null
     */
    public Set<Pixel> getPixels() {
        if (allFsIdsPerTarget == null) {
            allFsIdsPerTarget = generatePixelsAndIds();
        }

        int setCapacity = (int) ((backgroundPixels.size() + targetPixels.size()) * 1.3);
        if (setCapacity < 10) {
            setCapacity = 10;
        }
        Set<Pixel> pixels = new HashSet<Pixel>(setCapacity);
        pixels.addAll(targetPixels);
        pixels.addAll(backgroundPixels);

        return pixels;
    }

    /**
     * The background pixels. May be duplicates of pixels returned by
     * getTargetPixles()
     * 
     * @return non-null
     */
    public Set<Pixel> getBackgroundPixels() {
        if (allFsIdsPerTarget == null) {
            allFsIdsPerTarget = generatePixelsAndIds();
        }

        return backgroundPixels;
    }

    /**
     * The non-background pixels. May be duplicates of pixels returned by
     * getBackgroundPixels()
     * 
     * @return non-null
     */
    public Set<Pixel> getTargetPixels() {
        if (allFsIdsPerTarget == null) {
            allFsIdsPerTarget = generatePixelsAndIds();
        }
        return targetPixels;
    }

    protected Pixel buildPixel(TargetType targetType, int ccdModule,
        int ccdOutput, int row, int column) {

        return buildPixel(targetType, ccdModule, ccdOutput, row, column, false);
    }

    protected Pixel buildPixel(TargetType targetType, int ccdModule,
        int ccdOutput, int row, int column, boolean inOptimalAperture) {

        FsId fsId = DrFsIdFactory.getSciencePixelTimeSeries(
            DrFsIdFactory.TimeSeriesType.ORIG, targetType, ccdModule,
            ccdOutput, row, column);
        return new Pixel(row, column, fsId, inOptimalAperture);
    }

    /**
     * Returns a list of pixels and FsIds for a given target.
     * 
     * @param target the target.
     * @param ccdModule the module.
     * @param ccdOutput the output.
     * @param targetDefinitionsByOriginPixel a map of pixels their target
     * definition which can be used to find overlapping target definitions (but
     * only at debug log level).
     * @return a non-{@code null} list of {@link FsId}s.
     * @throws PipelineException if there was an error creating an {@link FsId}.
     */
    public Set<Pixel> loadTargetPixels(ObservedTarget target, int ccdModule,
        int ccdOutput) {

        Set<Pixel> optimalAperturePixels = Collections.emptySet();
        Aperture optimalAperture = target.getAperture();
        if (optimalAperture != null && optimalAperture.getOffsets() != null) {
            optimalAperturePixels = new HashSet<Pixel>(
                optimalAperture.getOffsets()
                    .size());
            int referenceRow = optimalAperture.getReferenceRow();
            int referenceColumn = optimalAperture.getReferenceColumn();
            for (Offset offset : optimalAperture.getOffsets()) {
                int row = referenceRow + offset.getRow();
                int column = referenceColumn + offset.getColumn();
                optimalAperturePixels.add(new Pixel(row, column));
            }
        }

        Set<Pixel> pixelsForThisTarget = new HashSet<Pixel>();
        Collection<TargetDefinition> definitions = target.getTargetDefinitions();
        TargetType targetType = target.getTargetTable()
            .getType();

        for (TargetDefinition targetDefinition : definitions) {
            Collection<Offset> offsets = targetDefinition.getMask()
                .getOffsets();

            int startRow = targetDefinition.getReferenceRow();
            int startColumn = targetDefinition.getReferenceColumn();
            for (Offset offset : offsets) {
                int row = startRow + offset.getRow();
                int column = startColumn + offset.getColumn();
                Pixel maskPixel = new Pixel(row, column);
                Pixel pixel = buildPixel(targetType, ccdModule, ccdOutput, row,
                    column, optimalAperturePixels.contains(maskPixel));
                pixelsForThisTarget.add(pixel);
            }
            if (offsets.size() > 0) {
                DatabaseServiceFactory.getInstance()
                    .evictAll(offsets);
            }
        }
        if (definitions.size() > 0) {
            DatabaseServiceFactory.getInstance()
                .evictAll(definitions);
        }

        return pixelsForThisTarget;
    }

    /**
     * Sets the {@link TargetCrud} for this object. This method is typically
     * only needed for testing.
     * 
     * @param targetCrud the {@link TargetCrud} object.
     */
    public void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    protected int getTargetCount() {
        return targetCount;
    }

    protected TargetTable getTargetTable() {
        return targetTable;
    }

    protected int getCcdModule() {
        return ccdModule;
    }

    protected int getCcdOutput() {
        return ccdOutput;
    }

    public static void main(String[] args) {
        if (args.length != 5) {
            System.out.println("Usage: SciencePixelOperations externalId "
                + "{ bgp | lct | sct | rpt } "
                + "{ UNLOCKED | LOCKED | TAD_COMPLETED | UPLINKED | REVISED } "
                + "ccdModule ccdOutput");
            System.exit(args.length == 0 ? 0 : 1);
        }
        int externalId = Integer.valueOf(args[0]);
        TargetType targetType = TargetTable.TargetType.valueOfShortName(args[1]);
        ExportTable.State state = ExportTable.State.valueOf(args[2].toUpperCase());
        int ccdModule = Integer.valueOf(args[3]);
        int ccdOutput = Integer.valueOf(args[4]);

        class PixelDumpOperations extends SciencePixelOperations {

            public PixelDumpOperations(TargetTable targetTable,
                TargetTable bgTargetTable, int ccdModule, int ccdOutput) {

                super(targetTable, bgTargetTable, ccdModule, ccdOutput);
            }

            @Override
            protected boolean processTarget(final TargetType type,
                final int ccdModule, final int ccdOutput,
                final ObservedTarget target, final Set<Pixel> pixels) {

                log.info(String.format("target: keplerId=%d"
                    + "; totalPixelCount=%d"
                    + "; targetType=%s; ccdModule=%d; ccdOutput=%d\n",
                    target.getKeplerId(), pixels.size(), type.name(),
                    ccdModule, ccdOutput));
                for (Pixel pixel : pixels) {
                    log.info(String.format("pixel: row=%d; column=%d\n",
                        pixel.getRow(), pixel.getColumn()));
                }

                return super.processTarget(type, ccdModule, ccdOutput, target,
                    pixels);
            }
        }

        TargetCrud targetCrud = new TargetCrud();
        TargetTable table = targetCrud.retrieveTargetTable(externalId,
            targetType, state);
        log.info(String.format("table: externalId=%d; targetType=%s; state=%s\n",
            externalId, targetType, state.name()));

        PixelDumpOperations pixelDumpOperations = new PixelDumpOperations(
            table, null, ccdModule, ccdOutput);
        pixelDumpOperations.getPixels();
    }
}
