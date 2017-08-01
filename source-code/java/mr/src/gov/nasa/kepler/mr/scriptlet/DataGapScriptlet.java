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

package gov.nasa.kepler.mr.scriptlet;

import static gov.nasa.kepler.hibernate.dr.GapCollateralPixel.ALL_PIXELS_FLAG;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.dr.GapCadence;
import gov.nasa.kepler.hibernate.dr.GapChannel;
import gov.nasa.kepler.hibernate.dr.GapCollateralPixel;
import gov.nasa.kepler.hibernate.dr.GapCrud;
import gov.nasa.kepler.hibernate.dr.GapPixel;
import gov.nasa.kepler.hibernate.dr.GapTarget;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRScriptletException;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;

/**
 * This is the scriptlet class for the data gap report.
 * 
 * @author Bill Wohler
 */
public class DataGapScriptlet extends BaseScriptlet {

    private static final Log log = LogFactory.getLog(DataGapScriptlet.class);

    public static final String REPORT_NAME_DATA_GAP = "data-gap";
    public static final String REPORT_TITLE_DATA_GAP = "Unrecoverable Science Cadence Data Gap";

    private static GapCrud gapCrud = new GapCrud();

    private List<GapCadence> gapCadences;
    private List<GapChannel> gapChannels;
    private List<GapTarget> gapTargets;
    private List<GapTarget> backgroundGapTargets;
    private List<GapPixel> gapPixels;
    private List<GapPixel> backgroundGapPixels;
    private List<GapCollateralPixel> gapCollateralPixels;

    private Set<GapFacade> fullCadenceGaps;
    private Set<GapFacade> partialCadenceGaps;

    @Override
    public void afterReportInit() throws JRScriptletException {
        super.afterReportInit();

        // Initialize start and end cadences.
        expectCadenceParameters();
        if (getStartCadence() == INVALID_CADENCE
            || getEndCadence() == INVALID_CADENCE || getErrorText() != null) {
            return;
        }

        try {
            TargetType targetTableType = TargetType.valueOf(getCadenceType());

            gapCadences = gapCrud.retrieveGapCadence(getCadenceType(),
                getStartCadence(), getEndCadence());
            gapChannels = gapCrud.retrieveGapChannel(getCadenceType(),
                getStartCadence(), getEndCadence());
            gapTargets = gapCrud.retrieveGapTarget(getCadenceType(),
                targetTableType, getStartCadence(), getEndCadence());
            backgroundGapTargets = gapCrud.retrieveGapTarget(getCadenceType(),
                TargetType.BACKGROUND, getStartCadence(), getEndCadence());
            gapPixels = gapCrud.retrieveGapPixel(getCadenceType(),
                targetTableType, getStartCadence(), getEndCadence());
            backgroundGapPixels = gapCrud.retrieveGapPixel(getCadenceType(),
                TargetType.BACKGROUND, getStartCadence(), getEndCadence());
            gapCollateralPixels = gapCrud.retrieveGapCollateralPixel(
                getCadenceType(), getStartCadence(), getEndCadence());

            if (gapCadences.size() == 0 && gapChannels.size() == 0
                && gapTargets.size() == 0 && gapPixels.size() == 0
                && gapCollateralPixels.size() == 0) {
                String text = String.format(
                    "No gaps received from cadence %d to %d.",
                    getStartCadence(), getEndCadence());
                setErrorText(text);
                log.error(text);
            }

            // Create fullCadenceGaps.
            fullCadenceGaps = new TreeSet<GapFacade>();
            for (GapCadence gapCadence : gapCadences) {
                fullCadenceGaps.add(new GapFacade(
                    gapCadence.getCadenceNumber(), false));
            }

            // Create partialCadenceGaps.
            partialCadenceGaps = new TreeSet<GapFacade>();
            for (GapChannel gapChannel : gapChannels) {
                partialCadenceGaps.add(new GapFacade(
                    gapChannel.getCadenceNumber(), true));
            }
            for (GapTarget gapTarget : gapTargets) {
                partialCadenceGaps.add(new GapFacade(
                    gapTarget.getCadenceNumber(), true));
            }
            for (GapTarget gapTarget : backgroundGapTargets) {
                partialCadenceGaps.add(new GapFacade(
                    gapTarget.getCadenceNumber(), true));
            }
            for (GapPixel gapPixel : gapPixels) {
                partialCadenceGaps.add(new GapFacade(
                    gapPixel.getCadenceNumber(), true));
            }
            for (GapPixel gapPixel : backgroundGapPixels) {
                partialCadenceGaps.add(new GapFacade(
                    gapPixel.getCadenceNumber(), true));
            }
            for (GapCollateralPixel gapCollateralPixel : gapCollateralPixels) {
                partialCadenceGaps.add(new GapFacade(
                    gapCollateralPixel.getCadenceNumber(), true));
            }

            int span = getEndCadence() - getStartCadence() + 1;
            log.debug("Missing " + fullCadenceGaps.size() + " (" + 100.0
                * fullCadenceGaps.size() / span + "%) full cadences and "
                + partialCadenceGaps.size() + " (" + 100.0
                * partialCadenceGaps.size() / span
                + "%) partial cadences out of " + span);

        } catch (HibernateException e) {
            String text = "Could not obtain gaps from cadence "
                + getStartCadence() + " to " + getEndCadence() + ": ";
            setErrorText(text + e + "\nCause: " + e.getCause());
            log.error(text, e);
            return;
        }
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the {@link GapCadence}s
     * for the current cadence range and type.
     * 
     * @return a non-{@code null} data source.
     * @throws JRScriptletException if the data source could not be created.
     */
    public JRDataSource cadenceGapsDataSource() throws JRScriptletException {

        Set<GapFacade> allGaps = new TreeSet<GapFacade>();
        if (fullCadenceGaps == null || partialCadenceGaps == null) {
            log.error("Should not be called if gaps unavailable");
            return new JRBeanCollectionDataSource(allGaps);
        }

        // Add full gaps.
        for (GapFacade gap : fullCadenceGaps) {
            allGaps.add(gap);
        }

        // Roll up partial records.
        for (GapFacade gap : partialCadenceGaps) {
            allGaps.add(gap);
        }

        // Aggregate entries.
        List<GapFacade> gaps = new ArrayList<GapFacade>();
        GapFacade previousGap = null;
        for (GapFacade gap : allGaps) {
            if (previousGap == null) {
                previousGap = gap;
            } else if (gap.getCadenceNumber() == previousGap.getEndCadenceNumber() + 1
                && gap.getPartial() == previousGap.getPartial()) {
                previousGap.setEndCadenceNumber(gap.getCadenceNumber());
            } else {
                gaps.add(previousGap);
                previousGap = gap;
            }
        }
        if (previousGap != null) {
            gaps.add(previousGap);
        }

        log.debug("Filling data source for " + gaps.size() + " cadence gaps");

        return new JRBeanCollectionDataSource(gaps);
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the {@link GapChannel}s
     * for the current cadence range and type.
     * 
     * @return a non-{@code null} data source.
     * @throws JRScriptletException if the data source could not be created.
     */
    public JRDataSource channelGapsDataSource() throws JRScriptletException {

        Set<GapFacade> allGaps = new TreeSet<GapFacade>();
        if (gapChannels == null) {
            log.error("Should not be called if gaps unavailable");
            return new JRBeanCollectionDataSource(allGaps);
        }

        for (GapChannel gapChannel : gapChannels) {
            allGaps.add(new GapFacade(gapChannel.getCadenceNumber(),
                gapChannel.getCcdModule(), gapChannel.getCcdOutput(), false));
        }

        // Roll up partial records.
        for (GapTarget gapTarget : gapTargets) {
            allGaps.add(new GapFacade(gapTarget.getCadenceNumber(),
                gapTarget.getCcdModule(), gapTarget.getCcdOutput(), true));
        }
        for (GapTarget gapTarget : backgroundGapTargets) {
            allGaps.add(new GapFacade(gapTarget.getCadenceNumber(),
                gapTarget.getCcdModule(), gapTarget.getCcdOutput(), true));
        }
        for (GapPixel gapPixel : gapPixels) {
            allGaps.add(new GapFacade(gapPixel.getCadenceNumber(),
                gapPixel.getCcdModule(), gapPixel.getCcdOutput(), true));
        }
        for (GapPixel gapPixel : backgroundGapPixels) {
            allGaps.add(new GapFacade(gapPixel.getCadenceNumber(),
                gapPixel.getCcdModule(), gapPixel.getCcdOutput(), true));
        }
        for (GapCollateralPixel gapCollateralPixel : gapCollateralPixels) {
            allGaps.add(new GapFacade(gapCollateralPixel.getCadenceNumber(),
                gapCollateralPixel.getCcdModule(),
                gapCollateralPixel.getCcdOutput(), true));
        }

        // Aggregate entries.
        List<GapFacade> gaps = new ArrayList<GapFacade>();
        GapFacade previousGap = null;
        for (GapFacade gap : allGaps) {
            if (previousGap == null) {
                previousGap = gap;
            } else if (gap.getCadenceNumber() == previousGap.getCadenceNumber()
                && sequentialChannels(previousGap, gap)
                && gap.getPartial() == previousGap.getPartial()) {
                previousGap.setEndCcdModule(gap.getCcdModule());
                previousGap.setEndCcdOutput(gap.getCcdOutput());
            } else {
                gaps.add(previousGap);
                previousGap = gap;
            }
        }
        if (previousGap != null) {
            gaps.add(previousGap);
        }

        log.debug("Filling data source for " + allGaps.size() + " channel gaps");

        return new JRBeanCollectionDataSource(gaps);
    }

    /**
     * Returns {@code true} if {@code channel2} follows {@code channel1}. This
     * is the case if the modules are the same and {@code channel2}'s output is
     * one greater, or if {@code channel1}'s output is 4, {@code channel2}'s is
     * 0, and {@code channel2}'s module is one greater.
     * 
     * @param channel1 the first record.
     * @param channel2 the second record.
     * @return {@code true} if the records are sequential; otherwise,
     * {@code false}.
     */
    private boolean sequentialChannels(GapFacade channel1, GapFacade channel2) {
        if (channel1.getEndCcdModule() == channel2.getCcdModule()
            && channel1.getEndCcdOutput() + 1 == channel2.getCcdOutput()
            || channel1.getEndCcdModule() + 1 == channel2.getCcdModule()
            && channel1.getEndCcdOutput() == FcConstants.nOutputsPerModule - 1
            && channel2.getCcdOutput() == 0) {
            return true;
        }

        return false;
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the {@link GapTarget}s
     * for science targets for the current cadence range and type.
     * 
     * @return a non-{@code null} data source.
     * @throws JRScriptletException if the data source could not be created.
     */
    public JRDataSource targetGapsDataSource() throws JRScriptletException {
        return targetGapsDataSource(false);
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the {@link GapTarget}s
     * for the current cadence range and type.
     * 
     * @param background {@code true} to return background target gaps;
     * {@code false} to return science data gaps.
     * @return a non-{@code null} data source.
     * @throws JRScriptletException if the data source could not be created.
     */
    public JRDataSource targetGapsDataSource(boolean background)
        throws JRScriptletException {

        Set<GapFacade> allGaps = new TreeSet<GapFacade>();
        if (gapTargets == null) {
            log.error("Should not be called if gaps unavailable");
            return new JRBeanCollectionDataSource(allGaps);
        }

        List<GapTarget> gapTargets = background ? backgroundGapTargets
            : this.gapTargets;
        for (GapTarget gapTarget : gapTargets) {
            allGaps.add(new GapFacade(gapTarget.getCadenceNumber(),
                gapTarget.getCcdModule(), gapTarget.getCcdOutput(),
                gapTarget.getTargetIndex(), false));
        }

        // Roll up partial records.
        List<GapPixel> gapPixels = background ? backgroundGapPixels
            : this.gapPixels;
        for (GapPixel gapPixel : gapPixels) {
            allGaps.add(new GapFacade(gapPixel.getCadenceNumber(),
                gapPixel.getCcdModule(), gapPixel.getCcdOutput(),
                gapPixel.getTargetIndex(), true));
        }

        // Aggregate entries.
        List<GapFacade> gaps = new ArrayList<GapFacade>();
        GapFacade previousGap = null;
        for (GapFacade gap : allGaps) {
            if (previousGap == null) {
                previousGap = gap;
            } else if (gap.getCadenceNumber() == previousGap.getCadenceNumber()
                && gap.getChannel()
                    .equals(previousGap.getChannel())
                && gap.getTargetIndex() == previousGap.getEndTargetIndex() + 1
                && gap.getPartial() == previousGap.getPartial()) {
                previousGap.setEndTargetIndex(gap.getTargetIndex());
            } else {
                gaps.add(previousGap);
                previousGap = gap;
            }
        }
        if (previousGap != null) {
            gaps.add(previousGap);
        }

        log.debug("Filling data source for " + allGaps.size() + " target gaps");

        return new JRBeanCollectionDataSource(gaps);
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the {@link GapPixel}s
     * for science targets for the current cadence range and type.
     * 
     * @return a non-{@code null} data source.
     * @throws JRScriptletException if the data source could not be created.
     */
    public JRDataSource pixelGapsDataSource() throws JRScriptletException {
        return pixelGapsDataSource(false);
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the {@link GapPixel}s
     * for the current cadence range and type.
     * 
     * @param background {@code true} to return background target gaps;
     * {@code false} to return science data gaps.
     * @return a non-{@code null} data source.
     * @throws JRScriptletException if the data source could not be created.
     */
    public JRDataSource pixelGapsDataSource(boolean background)
        throws JRScriptletException {

        Set<GapFacade> allGaps = new TreeSet<GapFacade>();
        if (gapPixels == null) {
            log.error("Should not be called if gaps unavailable");
            return new JRBeanCollectionDataSource(allGaps);
        }

        List<GapPixel> gapPixels = background ? backgroundGapPixels
            : this.gapPixels;
        for (GapPixel gapPixel : gapPixels) {
            allGaps.add(new GapFacade(gapPixel.getCadenceNumber(),
                gapPixel.getCcdModule(), gapPixel.getCcdOutput(),
                gapPixel.getTargetIndex(), gapPixel.getCcdRow(),
                gapPixel.getCcdColumn(), false));
        }

        // Aggregate entries.
        List<GapFacade> gaps = new ArrayList<GapFacade>();
        GapFacade previousGap = null;
        for (GapFacade gap : allGaps) {
            assert gap != null;
            if (previousGap == null) {
                previousGap = gap;
            } else if (gap.getCadenceNumber() != previousGap.getCadenceNumber()
                || gap.getCcdModule() != previousGap.getCcdModule()
                || gap.getCcdOutput() != previousGap.getCcdOutput()
                || gap.getTargetIndex() != previousGap.getTargetIndex()) {
                gaps.add(previousGap);
                previousGap = gap;
            }
            previousGap.setPixelCount(previousGap.getPixelCount() + 1);
        }
        if (previousGap != null) {
            gaps.add(previousGap);
        }

        log.debug("Filling data source for " + allGaps.size() + " pixel gaps");

        return new JRBeanCollectionDataSource(gaps);
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the
     * {@link GapCollateralPixel}s for the current cadence range and type.
     * 
     * @return a non-{@code null} data source.
     * @throws JRScriptletException if the data source could not be created.
     */
    public JRDataSource collateralPixelGapsDataSource()
        throws JRScriptletException {

        Set<GapFacade> allGaps = new TreeSet<GapFacade>();
        if (gapCollateralPixels == null) {
            log.error("Should not be called if gaps unavailable");
            return new JRBeanCollectionDataSource(allGaps);
        }

        for (GapCollateralPixel gapCollateralPixel : gapCollateralPixels) {
            allGaps.add(new GapFacade(gapCollateralPixel.getCadenceNumber(),
                gapCollateralPixel.getCcdModule(),
                gapCollateralPixel.getCcdOutput(),
                gapCollateralPixel.getPixelType(),
                gapCollateralPixel.getCcdRowOrColumn()));
        }

        // Aggregate entries.
        List<GapFacade> gaps = new ArrayList<GapFacade>();
        GapFacade previousGap = null;
        for (GapFacade gap : allGaps) {
            assert gap != null;
            if (previousGap == null) {
                previousGap = gap;
            } else if (gap.getCadenceNumber() != previousGap.getCadenceNumber()
                || gap.getCcdModule() != previousGap.getCcdModule()
                || gap.getCcdOutput() != previousGap.getCcdOutput()) {
                gaps.add(previousGap);
                previousGap = gap;
            }
            switch (gap.getPixelType()) {
                case BLACK_LEVEL:
                    if (gap.getCcdRowOrColumn() == ALL_PIXELS_FLAG) {
                        previousGap.setBlackCount(ALL_PIXELS_FLAG);
                    } else if (previousGap.getBlackCount() != ALL_PIXELS_FLAG) {
                        previousGap.setBlackCount(previousGap.getBlackCount() + 1);
                    }
                    break;
                case VIRTUAL_SMEAR:
                    if (gap.getCcdRowOrColumn() == ALL_PIXELS_FLAG) {
                        previousGap.setVirtualSmearCount(ALL_PIXELS_FLAG);
                    } else if (previousGap.getVirtualSmearCount() != ALL_PIXELS_FLAG) {
                        previousGap.setVirtualSmearCount(previousGap.getVirtualSmearCount() + 1);
                    }
                    break;
                case MASKED_SMEAR:
                    if (gap.getCcdRowOrColumn() == ALL_PIXELS_FLAG) {
                        previousGap.setMaskedSmearCount(ALL_PIXELS_FLAG);
                    } else if (previousGap.getMaskedSmearCount() != ALL_PIXELS_FLAG) {
                        previousGap.setMaskedSmearCount(previousGap.getMaskedSmearCount() + 1);
                    }
                    break;
                case BLACK_MASKED:
                    if (gap.getCcdRowOrColumn() == ALL_PIXELS_FLAG) {
                        previousGap.setBlackMaskedCount(ALL_PIXELS_FLAG);
                    } else if (previousGap.getBlackMaskedCount() != ALL_PIXELS_FLAG) {
                        previousGap.setBlackMaskedCount(previousGap.getBlackMaskedCount() + 1);
                    }
                    break;
                case BLACK_VIRTUAL:
                    if (gap.getCcdRowOrColumn() == ALL_PIXELS_FLAG) {
                        previousGap.setBlackVirtualCount(ALL_PIXELS_FLAG);
                    } else if (previousGap.getBlackVirtualCount() != ALL_PIXELS_FLAG) {
                        previousGap.setBlackVirtualCount(previousGap.getBlackVirtualCount() + 1);
                    }
                    break;
            }
        }
        if (previousGap != null) {
            gaps.add(previousGap);
        }

        log.debug("Filling data source for " + allGaps.size()
            + " collateral pixel gaps");

        return new JRBeanCollectionDataSource(gaps);
    }

    /**
     * Returns the number of full cadence gaps for the current cadence range and
     * type.
     */
    public int getFullCadenceGapCount() {
        if (fullCadenceGaps == null) {
            throw new IllegalStateException(
                "Should not be called if gaps unavailable");
        }

        return fullCadenceGaps.size();
    }

    /**
     * Returns the number of partial cadence gaps for the current cadence range
     * and type.
     */
    public int getPartialCadenceGapCount() {
        if (partialCadenceGaps == null) {
            throw new IllegalStateException(
                "Should not be called if gaps unavailable");
        }

        return partialCadenceGaps.size();
    }

    /**
     * A value-added facade to the various {@code Gap} objects. The
     * {@code pixelCount} field is not included in the {@code compareTo},
     * {@code equals}, and {@code hashCode} methods since otherwise you would
     * not be able to find an equivalent object in order to increase its pixel
     * count!
     * 
     * @author Bill Wohler
     */
    public static class GapFacade implements Comparable<GapFacade> {
        private static final int VOID = -1;

        private int cadenceNumber;
        private int endCadenceNumber;
        private int ccdModule;
        private int ccdOutput;
        private int endCcdModule;
        private int endCcdOutput;
        private int targetIndex;
        private int endTargetIndex;
        private int ccdRow;
        private int ccdColumn;
        private CollateralType pixelType;
        private int ccdRowOrColumn;
        private boolean partial;

        private int pixelCount;
        private int blackCount;
        private int virtualSmearCount;
        private int maskedSmearCount;

        private int blackVirtualCount;

        private int blackMaskedCount;

        public GapFacade(int cadenceNumber, boolean partial) {
            this(cadenceNumber, VOID, VOID, VOID, VOID, VOID, partial);
        }

        public GapFacade(int cadenceNumber, int ccdModule, int ccdOutput,
            boolean partial) {

            this(cadenceNumber, ccdModule, ccdOutput, VOID, VOID, VOID, partial);
        }

        public GapFacade(int cadenceNumber, int ccdModule, int ccdOutput,
            int targetIndex, boolean partial) {

            this(cadenceNumber, ccdModule, ccdOutput, targetIndex, VOID, VOID,
                partial);
        }

        public GapFacade(int cadenceNumber, int ccdModule, int ccdOutput,
            CollateralType pixelType, int ccdRowOrColumn) {

            this(cadenceNumber, ccdModule, ccdOutput, false);
            this.pixelType = pixelType;
            this.ccdRowOrColumn = ccdRowOrColumn;
        }

        public GapFacade(int cadenceNumber, int ccdModule, int ccdOutput,
            int targetIndex, int ccdRow, int ccdColumn, boolean partial) {

            this.cadenceNumber = cadenceNumber;
            endCadenceNumber = cadenceNumber;
            this.ccdModule = ccdModule;
            endCcdModule = ccdModule;
            this.ccdOutput = ccdOutput;
            endCcdOutput = ccdOutput;
            this.targetIndex = targetIndex;
            endTargetIndex = targetIndex;
            this.ccdRow = ccdRow;
            this.ccdColumn = ccdColumn;
            ccdRowOrColumn = GapCollateralPixel.ALL_PIXELS_FLAG - 1;
            this.partial = partial;
        }

        public String getCadence() {
            if (endCadenceNumber != cadenceNumber) {
                return String.format("%d-%d", cadenceNumber, endCadenceNumber);
            }

            return Integer.toString(cadenceNumber);
        }

        public int getCadenceNumber() {
            return cadenceNumber;
        }

        public int getEndCadenceNumber() {
            return endCadenceNumber;
        }

        public void setEndCadenceNumber(int cadenceNumber) {
            endCadenceNumber = cadenceNumber;
        }

        public String getChannel() {
            if (ccdModule != VOID && ccdOutput != VOID) {
                if (endCcdOutput != ccdOutput) {
                    return String.format("%d/%d-%d/%d", ccdModule, ccdOutput,
                        endCcdModule, endCcdOutput);
                }
                return String.format("%d/%d", ccdModule, ccdOutput);
            }

            return "";
        }

        public int getCcdModule() {
            return ccdModule;
        }

        public int getCcdOutput() {
            return ccdOutput;
        }

        public int getEndCcdModule() {
            return endCcdModule;
        }

        public void setEndCcdModule(int ccdModule) {
            endCcdModule = ccdModule;
        }

        public int getEndCcdOutput() {
            return endCcdOutput;
        }

        public void setEndCcdOutput(int ccdOutput) {
            endCcdOutput = ccdOutput;
        }

        public String getTarget() {
            if (targetIndex < 0) {
                return ALL_DATA;
            } else if (endTargetIndex != targetIndex) {
                return String.format("%d-%d", targetIndex, endTargetIndex);
            } else {
                return Integer.toString(targetIndex);
            }
        }

        public int getTargetIndex() {
            return targetIndex;
        }

        public int getEndTargetIndex() {
            return endTargetIndex;
        }

        public void setEndTargetIndex(int targetIndex) {
            endTargetIndex = targetIndex;
        }

        public CollateralType getPixelType() {
            return pixelType;
        }

        public int getCcdRow() {
            return ccdRow;
        }

        public int getCcdColumn() {
            return ccdColumn;
        }

        public int getCcdRowOrColumn() {
            return ccdRowOrColumn;
        }

        public boolean getPartial() {
            return partial;
        }

        public int getPixelCount() {
            return pixelCount;
        }

        public void setPixelCount(int count) {
            pixelCount = count;
        }

        public int getBlackCount() {
            return blackCount;
        }

        public void setBlackCount(int blackCount) {
            this.blackCount = blackCount;
        }

        public String getBlack() {
            if (blackCount < 0) {
                return ALL_DATA;
            } else if (blackCount > 0) {
                return Integer.toString(blackCount);
            } else {
                return NO_DATA;
            }
        }

        public int getVirtualSmearCount() {
            return virtualSmearCount;
        }

        public void setVirtualSmearCount(int virtualSmearCount) {
            this.virtualSmearCount = virtualSmearCount;
        }

        public String getVirtualSmear() {
            if (virtualSmearCount < 0) {
                return ALL_DATA;
            } else if (virtualSmearCount > 0) {
                return Integer.toString(virtualSmearCount);
            } else {
                return NO_DATA;
            }
        }

        public int getMaskedSmearCount() {
            return maskedSmearCount;
        }

        public void setMaskedSmearCount(int maskedSmearCount) {
            this.maskedSmearCount = maskedSmearCount;
        }

        public String getMaskedSmear() {
            if (maskedSmearCount < 0) {
                return ALL_DATA;
            } else if (maskedSmearCount > 0) {
                return Integer.toString(maskedSmearCount);
            } else {
                return NO_DATA;
            }
        }

        public int getBlackMaskedCount() {
            return blackMaskedCount;
        }

        public void setBlackMaskedCount(int blackMaskedCount) {
            this.blackMaskedCount = blackMaskedCount;
        }

        public String getBlackMasked() {
            if (blackMaskedCount < 0) {
                return ALL_DATA;
            } else if (blackMaskedCount > 0) {
                return Integer.toString(blackMaskedCount);
            } else {
                return NO_DATA;
            }
        }

        public int getBlackVirtualCount() {
            return blackVirtualCount;
        }

        public void setBlackVirtualCount(int blackVirtualCount) {
            this.blackVirtualCount = blackVirtualCount;
        }

        public String getBlackVirtual() {
            if (blackVirtualCount < 0) {
                return ALL_DATA;
            } else if (blackVirtualCount > 0) {
                return Integer.toString(blackVirtualCount);
            } else {
                return NO_DATA;
            }
        }

        @Override
        public int compareTo(GapFacade o) {
            if (o == null) {
                throw new NullPointerException("Can't compare null operand");
            }

            if (cadenceNumber != o.cadenceNumber) {
                return cadenceNumber - o.cadenceNumber;
            }
            if (ccdModule != o.ccdModule) {
                return ccdModule - o.ccdModule;
            }
            if (ccdOutput != o.ccdOutput) {
                return ccdOutput - o.ccdOutput;
            }
            if (targetIndex != o.targetIndex) {
                return targetIndex - o.targetIndex;
            }
            if (ccdRow != o.ccdRow) {
                return ccdRow - o.ccdRow;
            }
            if (ccdColumn != o.ccdColumn) {
                return ccdColumn - o.ccdColumn;
            }
            if (pixelType != o.pixelType) {
                return pixelType.ordinal() - o.pixelType.ordinal();
            }
            if (ccdRowOrColumn != o.ccdRowOrColumn) {
                return ccdRowOrColumn - o.ccdRowOrColumn;
            }
            if (partial != o.partial) {
                return partial ? 1 : -1;
            }
            return 0;
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + cadenceNumber;
            result = prime * result + ccdColumn;
            result = prime * result + ccdModule;
            result = prime * result + ccdOutput;
            result = prime * result + ccdRow;
            result = prime * result + ccdRowOrColumn;
            result = prime * result + (partial ? 1231 : 1237);
            result = prime * result
                + (pixelType == null ? 0 : pixelType.hashCode());
            result = prime * result + targetIndex;
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
            if (getClass() != obj.getClass()) {
                return false;
            }
            final GapFacade other = (GapFacade) obj;
            if (cadenceNumber != other.cadenceNumber) {
                return false;
            }
            if (ccdColumn != other.ccdColumn) {
                return false;
            }
            if (ccdModule != other.ccdModule) {
                return false;
            }
            if (ccdOutput != other.ccdOutput) {
                return false;
            }
            if (ccdRow != other.ccdRow) {
                return false;
            }
            if (ccdRowOrColumn != other.ccdRowOrColumn) {
                return false;
            }
            if (partial != other.partial) {
                return false;
            }
            if (pixelType == null) {
                if (other.pixelType != null) {
                    return false;
                }
            } else if (!pixelType.equals(other.pixelType)) {
                return false;
            }
            if (targetIndex != other.targetIndex) {
                return false;
            }
            return true;
        }
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
