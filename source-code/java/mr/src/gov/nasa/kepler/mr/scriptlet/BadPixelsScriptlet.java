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

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.Pixel;
import gov.nasa.kepler.hibernate.fc.PixelType;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRScriptletException;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;

/**
 * This is the scriptlet class for the Bad Pixels report.
 * 
 * @author Bill Wohler
 */
public class BadPixelsScriptlet extends BaseScriptlet {

    private static final Log log = LogFactory.getLog(BadPixelsScriptlet.class);

    public static final String REPORT_NAME_BAD_PIXELS = "bad-pixels";
    public static final String REPORT_TITLE_BAD_PIXELS = "Bad Pixels";

    private static FcCrud fcCrud = new FcCrud();

    private List<Pixel> pixels;

    @Override
    public void afterReportInit() throws JRScriptletException {
        super.afterReportInit();

        // Initialize time.
        expectTimeParameter();
        if (getTime() == null) {
            return;
        }

        try {
            pixels = fcCrud.retrievePixels(getTime());
            if (pixels.size() == 0) {
                String text = String.format("No pixels received around %s.",
                    getDateFormatter().format(getTime()));
                setErrorText(text);
                log.error(text);
            }
        } catch (HibernateException e) {
            String text = "Could not obtain pixels around "
                + getDateFormatter().format(getTime()) + ": ";
            setErrorText(text + e + "\nCause: " + e.getCause());
            log.error(text, e);
            return;
        }
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the {@link Pixel}s for
     * the current time.
     * 
     * @return a non-{@code null} data source.
     * @throws JRScriptletException if the data source could not be created.
     */
    public JRDataSource badPixelsDataSource() throws JRScriptletException {

        log.debug("Filling data source for all bad pixels");

        Set<PixelCounts> set = new TreeSet<PixelCounts>();
        if (pixels == null) {
            log.error("Should not be called if bad pixels unavailable");
            return new JRBeanCollectionDataSource(set);
        }

        // Sort pixels by module/output.
        Map<Integer, List<Pixel>> modOutMap = new HashMap<Integer, List<Pixel>>();
        for (Pixel pixel : pixels) {
            int channel = FcConstants.getChannelNumber(pixel.getCcdModule(),
                pixel.getCcdOutput());
            List<Pixel> modOutPixels = modOutMap.get(channel);
            if (modOutPixels == null) {
                modOutPixels = new ArrayList<Pixel>();
            }
            modOutPixels.add(pixel);
            modOutMap.put(channel, modOutPixels);
        }

        // Count pixels of each type in each module/output.
        for (Map.Entry<Integer, List<Pixel>> entry : modOutMap.entrySet()) {
            Map<PixelType, Integer> counts = new EnumMap<PixelType, Integer>(
                PixelType.class);
            for (PixelType pixelType : PixelType.values()) {
                counts.put(pixelType, Integer.valueOf(0));
            }
            for (Pixel pixel : entry.getValue()) {
                Integer count = counts.get(pixel.getType());
                count++;
                counts.put(pixel.getType(), count);
            }
            int channel = entry.getKey();
            Pair<Integer, Integer> modOut = FcConstants.getModuleOutput(channel);
            set.add(new PixelCounts(modOut.left, modOut.right, counts));
        }

        return new JRBeanCollectionDataSource(set);
    }

    /**
     * Bad pixel counts for a module/output.
     * 
     * @author Bill Wohler
     */
    public static class PixelCounts implements Comparable<PixelCounts> {
        private int ccdModule;
        private int ccdOutput;
        private Map<PixelType, Integer> counts;

        public PixelCounts(int ccdModule, int ccdOutput,
            Map<PixelType, Integer> counts) {
            this.ccdModule = ccdModule;
            this.ccdOutput = ccdOutput;
            this.counts = counts;
        }

        public String getCcdModuleOutput() {
            return String.format("%02d/%d", ccdModule, ccdOutput);
        }

        public int getDeadCount() {
            return counts.get(PixelType.DEAD);
        }

        public int getHotCount() {
            return counts.get(PixelType.HOT);
        }

        public int getCrosstalkCount() {
            return counts.get(PixelType.CROSSTALK);
        }

        public int getScatteredCount() {
            return counts.get(PixelType.SCATTERED);
        }

        public int getBloomingCount() {
            return counts.get(PixelType.BLOOMING);
        }

        public int getGhostCount() {
            return counts.get(PixelType.GHOST);
        }

        public int getUnusableCount() {
            return counts.get(PixelType.UNUSABLE);
        }

        public int getTotalCount() {
            int sum = 0;
            for (Integer count : counts.values()) {
                sum += count;
            }

            return sum;
        }

        @Override
        public int compareTo(PixelCounts o) {
            if (ccdModule != o.ccdModule) {
                return ccdModule - o.ccdModule;
            }
            if (ccdOutput != o.ccdOutput) {
                return ccdOutput - o.ccdOutput;
            }

            return 0;
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + ccdModule;
            result = prime * result + ccdOutput;
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
            if (!(obj instanceof PixelCounts)) {
                return false;
            }
            PixelCounts other = (PixelCounts) obj;
            if (ccdModule != other.ccdModule) {
                return false;
            }
            if (ccdOutput != other.ccdOutput) {
                return false;
            }
            return true;
        }
    }
}
