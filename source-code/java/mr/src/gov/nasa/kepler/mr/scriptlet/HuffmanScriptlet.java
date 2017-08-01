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

import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.gar.HuffmanEntry;
import gov.nasa.kepler.hibernate.gar.HuffmanTable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRScriptletException;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;

/**
 * This is the scriptlet class for the Huffman tables report.
 * 
 * @author Bill Wohler
 */
public class HuffmanScriptlet extends BaseScriptlet {
    private static final Log log = LogFactory.getLog(HuffmanScriptlet.class);

    public static final String REPORT_NAME_HUFFMAN_TABLES = "huffman-tables";
    public static final String REPORT_TITLE_HUFFMAN_TABLES = "Huffman Table Processing";

    private static CompressionCrud compressionCrud = new CompressionCrud();;

    private HuffmanTable huffmanTable;
    private int min;
    private int avg;
    private int max;

    @Override
    public void afterReportInit() throws JRScriptletException {
        super.afterReportInit();

        expectIdParameter(true);
        if (getId() == INVALID_ID || getId() == UNINITIALIZED_ID) {
            return;
        }

        // Retrieve the Huffman table.
        try {
            huffmanTable = compressionCrud.retrieveHuffmanTable(getId());

            if (huffmanTable == null) {
                String text = String.format(
                    "Huffman table report unavailable for database ID %d.",
                    getId());
                setErrorText(text);
                log.error(text);
                return;
            }
            if (huffmanTable.getEntries()
                .size() == 0) {
                String text = String.format(
                    "Huffman table for database ID %d does not contain any entries.",
                    getId());
                setErrorText(text);
                log.error(text);
                return;
            }
        } catch (HibernateException e) {
            String text = "Could not obtain target list set " + getId() + ": ";
            setErrorText(text + e + "\nCause: " + e.getCause());
            log.error(text, e);
            return;
        }

        initializeHuffmanTableStatistics(huffmanTable);
    }

    /**
     * Returns this {@link HuffmanTable}'s table ID.
     * 
     * @return the table ID, as a string, or "-" if one isn't yet defined
     */
    public String getExternalId() {
        if (huffmanTable == null) {
            log.error("Should not be called if Huffman table unavailable");
            return NO_DATA;
        }

        int externalId = huffmanTable.getExternalId();
        if (externalId == ExportTable.INVALID_EXTERNAL_ID) {
            return NO_DATA;
        }

        return Integer.toString(externalId);
    }

    /**
     * Returns this {@link HuffmanTable}'s planned starting date.
     * 
     * @return the date, as a string
     */
    public String getStart() {
        if (huffmanTable == null) {
            log.error("Should not be called if Huffman table unavailable");
            return "";
        }

        String start = NO_DATA;
        if (huffmanTable.getPlannedStartTime() != null) {
            start = getDateFormatter().format(
                huffmanTable.getPlannedStartTime());
        }

        return start;
    }

    /**
     * Returns this {@link HuffmanTable}'s state.
     * 
     * @return the state, as a string
     */
    public String getState() {
        if (huffmanTable == null) {
            log.error("Should not be called if Huffman table unavailable");
            return "";
        }

        return huffmanTable.getState()
            .toString();
    }

    /**
     * Returns the pipeline instance ID.
     */
    public long getPipelineInstanceId() {
        return huffmanTable.getPipelineTask()
            .getPipelineInstance()
            .getId();
    }

    /**
     * Returns a {@link JRDataSource} which wraps the current
     * {@link HuffmanTable}.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource dataSource() {
        List<KeyValuePair> list = new ArrayList<KeyValuePair>();
        if (huffmanTable == null || huffmanTable.getEntries()
            .size() == 0) {
            log.error("Should not be called if Huffman table unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        log.debug("Filling data source for " + huffmanTable);

        list.add(new KeyValuePair("Theoretical Compression", String.format(
            "%f", huffmanTable.getTheoreticalCompressionRate())));
        list.add(new KeyValuePair("Effective Compression", String.format("%f",
            huffmanTable.getEffectiveCompressionRate())));
        list.add(new KeyValuePair("Number of Code Words", String.format("%,d",
            huffmanTable.getEntries()
                .size())));
        list.add(new KeyValuePair("Minimum Code Word Length Bits",
            String.format("%,d", min)));
        list.add(new KeyValuePair("Average Code Word Length Bits",
            String.format("%,d", avg)));
        list.add(new KeyValuePair("Maximum Code Word Length Bits",
            String.format("%,d", max)));

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a {@link JRDataSource} which wraps this {@link HuffmanTable}'s
     * entries as a time series.
     * 
     * @return a non-{@code null} data source
     */
    public JRDataSource codeWordLengthFrequencyDataSource() {
        List<KeyValuePair> list = new ArrayList<KeyValuePair>();

        if (huffmanTable == null || huffmanTable.getEntries()
            .size() == 0) {
            log.error("Should not be called if Huffman table unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        // Determine frequencies.
        Map<Integer, Long> codeLengthCount = new HashMap<Integer, Long>();
        for (HuffmanEntry entry : huffmanTable.getEntries()) {
            Long count = codeLengthCount.get(entry.getCodeLength());
            if (count == null) {
                count = 0L;
            }
            count += entry.getMasterHistogramEntry();

            codeLengthCount.put(entry.getCodeLength(), count);
        }

        // Create data source with collected frequencies.
        for (Map.Entry<Integer, Long> entry : codeLengthCount.entrySet()) {
            // Switch the key/value since we're plotting code word length
            // against frequency.
            list.add(new KeyValuePair(entry.getValue(), entry.getKey()));
        }
        log.debug(list);

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Initializes the minimum, average, and maximum values of the Huffman table
     * entries.
     * 
     * @param huffmanTable the {@link HuffmanTable}
     */
    private void initializeHuffmanTableStatistics(HuffmanTable huffmanTable) {
        min = Integer.MAX_VALUE;
        max = Integer.MIN_VALUE;
        int count = 0;
        long sum = 0;
        for (HuffmanEntry entry : huffmanTable.getEntries()) {
            int value = entry.getValue();
            if (value < min) {
                min = value;
            }
            if (value > max) {
                max = value;
            }
            sum += value;
            count++;
        }
        avg = (int) (sum / count);
    }
}
