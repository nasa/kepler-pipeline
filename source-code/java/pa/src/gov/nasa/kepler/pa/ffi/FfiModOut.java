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

import static gov.nasa.kepler.common.FitsConstants.FINE_PNT_KW;
import static gov.nasa.kepler.common.FitsConstants.LDEPARER_KW;
import static gov.nasa.kepler.common.FitsConstants.LDE_OOS_KW;
import static gov.nasa.kepler.common.FitsConstants.MMNTMDMP_KW;
import static gov.nasa.kepler.common.FitsConstants.SCRC_ERR_KW;
import static gov.nasa.kepler.common.FitsConstants.SEFI_ACC_KW;
import static gov.nasa.kepler.common.FitsConstants.SEFI_CAD_KW;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FitsUtils;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.pa.PaPixelTimeSeries;
import gov.nasa.kepler.mc.pa.PaTarget;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Set;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;

/**
 * The image of the single mod out and the important metadata.
 * 
 * @author Forrest Girouard
 * 
 */
public class FfiModOut {

    private static final boolean[] GAP = new boolean[] { true };
    private static final boolean[] NO_GAP = new boolean[] { false };

    public final float[][] data;
    public final boolean[][] gaps;
    public final double startMjd;
    public final double midMjd;
    public final double endMjd;
    public final long originator;
    public final int longCadenceNumber;
    public final BasicHDU primaryHdu;
    public final Header imageHeader;
    public final int spaceCraftConfigMapId;
    public final int ccdModule;
    public final int ccdOutput;

    /**
     * @param values
     * @param gap
     * @param collectionMjd
     */
    public FfiModOut(float[][] data, boolean[][] gaps, double startMjd,
        double midMjd, double endMjd, long originator, BasicHDU primaryHDU,
        Header imageHeader, int longCadenceNumber, int spaceCraftConfigMapId,
        int ccdModule, int ccdOutput) {

        if (startMjd > midMjd) {
            throw new IllegalArgumentException("Start mjd comes after mid mjd.");
        }
        if (midMjd > endMjd) {
            throw new IllegalArgumentException("Mid mjd comes after end mjd.");
        }

        this.data = data;
        this.gaps = gaps;
        this.startMjd = startMjd;
        this.originator = originator;
        this.midMjd = midMjd;
        this.endMjd = endMjd;
        this.primaryHdu = primaryHDU;
        this.imageHeader = imageHeader;
        this.longCadenceNumber = longCadenceNumber;
        this.spaceCraftConfigMapId = spaceCraftConfigMapId;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;

    }

    public static void getPixelTimeSeries(List<PaTarget> paTargets,
        FfiModOut values, FfiModOut uncert) {
        for (PaTarget paTarget : paTargets) {
            Set<Pixel> pixels = paTarget.getPixels();
            List<PaPixelTimeSeries> pixelTimeSeriesList = getPixelTimeSeries(
                pixels, values, uncert);
            paTarget.setPaPixelTimeSeries(pixelTimeSeriesList);
        }
    }

    public static List<PaPixelTimeSeries> getPixelTimeSeries(Set<Pixel> pixels,
        FfiModOut values, FfiModOut uncert) {
        List<PaPixelTimeSeries> pixelTimeSeriesList = new ArrayList<PaPixelTimeSeries>(
            pixels.size() * 2);
        for (Pixel pixel : pixels) {
            int row = pixel.getRow();
            int column = pixel.getColumn();
            boolean[] gapIndicators = (values.gaps[row][column]) ? GAP : NO_GAP;
            PaPixelTimeSeries timeSeries = new PaPixelTimeSeries(row, column,
                pixel.isInOptimalAperture());
            timeSeries.setValues(new float[] { values.data[row][column] });
            timeSeries.setUncertainties(new float[] { uncert.data[row][column] });
            timeSeries.setGapIndicators(gapIndicators);
            pixelTimeSeriesList.add(timeSeries);
        }

        return pixelTimeSeriesList;
    }

    public TimestampSeries getCadenceTimes() {
        TimestampSeries cadenceTimes = null;
        try {
            // Read flags from fits headers.
            Header primaryHduHeader = primaryHdu.getHeader();

            boolean[] isSefiAcc = new boolean[] { FitsUtils.getHeaderBooleanValueChecked(
                primaryHduHeader, SEFI_ACC_KW) };
            boolean[] isSefiCad = new boolean[] { FitsUtils.getHeaderBooleanValueChecked(
                primaryHduHeader, SEFI_CAD_KW) };
            boolean[] isLdeOos = new boolean[] { FitsUtils.getHeaderBooleanValueChecked(
                primaryHduHeader, LDE_OOS_KW) };
            boolean[] isFinePnt = new boolean[] { FitsUtils.getHeaderBooleanValueChecked(
                primaryHduHeader, FINE_PNT_KW) };
            boolean[] isMmntmDmp = new boolean[] { FitsUtils.getHeaderBooleanValueChecked(
                primaryHduHeader, MMNTMDMP_KW) };
            boolean[] isLdeParEr = new boolean[] { FitsUtils.getHeaderBooleanValueChecked(
                primaryHduHeader, LDEPARER_KW) };
            boolean[] isScrcErr = new boolean[] { FitsUtils.getHeaderBooleanValueChecked(
                primaryHduHeader, SCRC_ERR_KW) };

            cadenceTimes = new TimestampSeries(new double[] { startMjd },
                new double[] { midMjd }, new double[] { endMjd },
                new boolean[] { false }, new boolean[] { false },
                new int[] { longCadenceNumber }, isSefiAcc, isSefiCad,
                isLdeOos, isFinePnt, isMmntmDmp, isLdeParEr, isScrcErr);
        } catch (FitsException e) {
            throw new PipelineException("Unable to create "
                + TimestampSeries.class.getSimpleName(), e);
        }

        return cadenceTimes;
    }

    public List<ConfigMap> getConfigMaps(ConfigMapOperations configMapOperations) {

        ConfigMap configMap = configMapOperations.retrieveConfigMap(spaceCraftConfigMapId);

        if (configMap == null) {
            throw new ModuleFatalProcessingException("Missing config map for "
                + "config id " + spaceCraftConfigMapId + ".");
        }

        return Collections.singletonList(configMap);
    }
}
