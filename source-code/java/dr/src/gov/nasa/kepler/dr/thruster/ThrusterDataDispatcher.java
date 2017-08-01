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

package gov.nasa.kepler.dr.thruster;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.dr.dispatch.Dispatcher;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.dr.thruster.ThrusterDataItem.ThrusterMnemonic;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.List;
import java.util.Set;
import java.util.zip.GZIPInputStream;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This dispatcher processes and stores the thruster firing data sent by the
 * DMC.
 * 
 * @author Bill Wohler
 */
public class ThrusterDataDispatcher implements Dispatcher {

    private static final String GZIP_SUFFIX = ".gz";

    /**
     * Maximum number of errors before file parsing is aborted.
     */
    public static final int MAX_ERROR_COUNT = 100;

    private static final Log log = LogFactory.getLog(ThrusterDataDispatcher.class);
    private static final String notNullTemplate = "%s can't be null";

    private Reader reader;
    private AncillaryOperations ancillaryOperations = new AncillaryOperations();

    @Override
    public void dispatch(Set<String> filenames, String sourceDirectory,
        DispatchLog dispatchLog, DispatcherWrapper dispatcherWrapper) {

        checkNotNull(filenames, notNullTemplate, "filenames");
        checkNotNull(sourceDirectory, notNullTemplate, "sourceDirectory");
        checkNotNull(dispatcherWrapper, notNullTemplate, "dispatcherWrapper");

        int fileCounter = 1;
        for (String filename : filenames) {
            log.info("Processing " + filename + " (" + fileCounter++ + " of "
                + filenames.size() + ")");

            try {
                List<ThrusterDataItem> thrusterDataItems = parseFile(getFileReader(new File(
                    sourceDirectory, filename)));
                store(thrusterDataItems);
            } catch (IOException e) {
                dispatcherWrapper.throwExceptionForFile(filename, e);
            }
        }
    }

    private Reader getFileReader(File file) throws IOException {
        if (reader != null) {
            return reader;
        }

        if (file.getName()
            .endsWith(GZIP_SUFFIX)) {
            return new InputStreamReader(new GZIPInputStream(
                new FileInputStream(file)));
        } else {
            return new FileReader(file);
        }
    }

    private void store(List<ThrusterDataItem> thrusterDataItems) {

        List<AncillaryEngineeringData> ancillaryData = initializeAncillaryData(thrusterDataItems.size());

        int itemCount = 0;
        for (ThrusterDataItem item : thrusterDataItems) {
            for (int i = 0; i < ThrusterDataItem.THRUSTER_COUNT; i++) {
                AncillaryEngineeringData data = ancillaryData.get(i);
                data.getTimestamps()[itemCount] = item.getSpacecraftTime();
                // Thruster numbers are 1-based.
                data.getValues()[itemCount] = item.getThrusterData(i + 1);
            }
            itemCount++;
        }

        ancillaryOperations.storeAncillaryEngineeringData(ancillaryData,
            DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID);
    }

    private List<AncillaryEngineeringData> initializeAncillaryData(int size) {
        List<AncillaryEngineeringData> ancillaryData = newArrayList();

        for (ThrusterMnemonic mnemonic : ThrusterMnemonic.values()) {
            AncillaryEngineeringData data = new AncillaryEngineeringData(
                mnemonic.toString());
            data.setTimestamps(new double[size]);
            data.setValues(new float[size]);
            ancillaryData.add(data);
        }

        return ancillaryData;
    }

    /**
     * Parses the given file per the Thruster Firing Report (TFR) OIA
     * (O-MOCa.2.SOCg-1, 2014-06-16). Returns a list of {@link ThrusterDataItem}
     * , or throws an {@link IllegalArgumentException} if there were any syntax
     * errors in the file.
     * <p>
     * The method wraps the reader in a {@link BufferedReader} so it is
     * unnecessary for callers to do so.
     * 
     * @param reader the non-{@code null} reader
     * @return a list of {@link ThrusterDataItem}s populated with the lines of
     * data
     * @throws NullPointerException if reader is {@code null}
     * @throws IOException if an I/O error occurs
     * @throws IllegalArgumentException if the format of any line is incorrect
     */
    List<ThrusterDataItem> parseFile(Reader reader) throws IOException {
        checkNotNull(reader, notNullTemplate, "reader");

        List<String> errors = newArrayList();
        List<ThrusterDataItem> thrusterDataItems = newArrayList();
        BufferedReader r = new BufferedReader(reader);
        int lineNo = 1;
        for (String s = r.readLine(); s != null; s = r.readLine(), lineNo++) {
            try {
                ThrusterDataItem thrusterDataItem = parseLine(s);
                if (thrusterDataItem != null) {
                    thrusterDataItems.add(thrusterDataItem);
                }
            } catch (IllegalArgumentException e) {
                errors.add(String.format("%d: %s\n  %s", lineNo,
                    e.getMessage(), s));
                if (errors.size() >= MAX_ERROR_COUNT) {
                    throw new IllegalArgumentException(StringUtils.join(
                        errors.toArray(), "\n"));
                }
            }
        }

        if (errors.size() > 0) {
            throw new IllegalArgumentException(StringUtils.join(
                errors.toArray(), "\n"));
        }

        return thrusterDataItems;
    }

    /**
     * Parses the given line per the Thruster Firing Report (TFR) OIA
     * (O-MOCa.2.SOCg-1, 2014-06-16).
     * 
     * @param line the non-{@code null} line of data
     * @return a {@link ThrusterDataItem} populated with the line of data, or
     * {@link null} if the line was empty or a comment
     * @throws NullPointerException if line is {@code null}
     * @throws IllegalArgumentException if the format of the line is incorrect
     */
    ThrusterDataItem parseLine(String line) {
        checkNotNull(line, notNullTemplate, "line");

        // If line is empty or is a comment, return null.
        if (line.isEmpty() || line.startsWith("#")) {
            return null;
        }

        String[] fields = line.split(",");
        checkArgument(fields.length == 9, "Expected %s fields, but was %s", 9,
            fields.length);

        ThrusterDataItem thrusterDataItem = new ThrusterDataItem(
            Double.parseDouble(fields[0]), Float.parseFloat(fields[1]),
            Float.parseFloat(fields[2]), Float.parseFloat(fields[3]),
            Float.parseFloat(fields[4]), Float.parseFloat(fields[5]),
            Float.parseFloat(fields[6]), Float.parseFloat(fields[7]),
            Float.parseFloat(fields[8]));

        return thrusterDataItem;
    }

    // For testing only.
    void setFileReader(Reader reader) {
        this.reader = reader;
    }

    // For testing only.
    void setAncillaryOperations(AncillaryOperations ancillaryOperations) {
        this.ancillaryOperations = ancillaryOperations;
    }
}
