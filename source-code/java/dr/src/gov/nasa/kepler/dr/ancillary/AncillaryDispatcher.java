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

package gov.nasa.kepler.dr.ancillary;

import static gov.nasa.kepler.common.FitsConstants.MNEMONIC_KW;
import static gov.nasa.kepler.common.FitsConstants.PAR_TYPE_KW;
import static gov.nasa.kepler.common.FitsConstants.SCCONFIG_KW;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.FitsUtils;
import gov.nasa.kepler.dr.dispatch.DispatchException;
import gov.nasa.kepler.dr.dispatch.Dispatcher;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.hibernate.dr.AncillaryDictionaryCrud;
import gov.nasa.kepler.hibernate.dr.AncillaryDictionaryMnemonic;
import gov.nasa.kepler.hibernate.dr.AncillaryDictionaryValues;
import gov.nasa.kepler.hibernate.dr.AncillaryLog;
import gov.nasa.kepler.hibernate.dr.AncillaryLogCrud;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FileInputStream;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.Header;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This dispatcher processes and stores the Ancillary Engineering data fits
 * files sent by the DMC. Typically, this class processes one contact of data at
 * a time. This contains 1440 ancillary data files, one per long cadence. This
 * dispatcher extracts the data for each mnemonic from each fits file and stores
 * one file per mnemonic per contact in the filestore.
 * 
 * @author Miles Cote
 */
public class AncillaryDispatcher implements Dispatcher {

    public enum AncillaryParameterType {
        ANALOG(1), DISCRETE(2);

        private int fitsValue;

        private AncillaryParameterType(int fitsValue) {
            this.fitsValue = fitsValue;
        }

        public static AncillaryParameterType valueOf(int fitsValue) {
            for (AncillaryParameterType type : values()) {
                if (type.fitsValue == fitsValue) {
                    return type;
                }
            }

            throw new IllegalArgumentException("Unknown type" + " FITS value "
                + fitsValue);
        }

        public int fitsValue() {
            return fitsValue;
        }
    }

    private static final int TIMESTAMP_COLUMN = 0;
    private static final int VALUE_COLUMN = 1;

    private AncillaryOperations ancillaryOperations;
    private AncillaryLogCrud ancillaryLogCrud;
    private AncillaryDictionaryCrud ancillaryDictionaryCrud;

    private static final Log log = LogFactory.getLog(AncillaryDispatcher.class);

    public AncillaryDispatcher() {
        try {
            ancillaryOperations = new AncillaryOperations();
            ancillaryLogCrud = new AncillaryLogCrud();
            ancillaryDictionaryCrud = new AncillaryDictionaryCrud();
        } catch (PipelineException e) {
            throw new DispatchException("Initilialization failure", e);
        }
    }

    @Override
    public void dispatch(Set<String> filenames, String sourceDirectory,
        DispatchLog dispatchLog, DispatcherWrapper dispatcherWrapper) {
        Map<String, AncillaryEngineeringData> mnemonicToAncillaryEngineeringData = new HashMap<String, AncillaryEngineeringData>();

        int fileCounter = 0;
        for (String filename : filenames) {
            if (fileCounter % 100 == 0) {
                log.info("Completed processing " + fileCounter + " of "
                    + filenames.size() + " files.");
            }

            try {
                Fits fits = new Fits(new FileInputStream(sourceDirectory
                    + File.separator + filename));
                fits.read();

                Header primaryHeader = fits.getHDU(0)
                    .getHeader();

                int scConfigId = FitsUtils.getHeaderIntValueChecked(
                    primaryHeader, SCCONFIG_KW);

                // Loop over all HDUs, except the first one.
                for (int i = 1; i < fits.getNumberOfHDUs(); i++) {
                    // Read FITS header fields.
                    BinaryTableHDU binaryTableHDU = (BinaryTableHDU) fits.getHDU(i);
                    String mnemonic = FitsUtils.getHeaderStringValueChecked(
                        binaryTableHDU.getHeader(), MNEMONIC_KW);

                    // Get timestamps and values.
                    double[] timestamps = (double[]) binaryTableHDU.getColumn(TIMESTAMP_COLUMN);
                    double[] values = null;
                    Object hduValueColumn = binaryTableHDU.getColumn(VALUE_COLUMN);
                    if (hduValueColumn instanceof double[]) {
                        values = (double[]) hduValueColumn;
                    } else if (hduValueColumn instanceof String[]) {
                        String[] stringValues = (String[]) hduValueColumn;
                        values = getDoubleValues(mnemonic, stringValues);
                    } else {
                        throw new IllegalArgumentException(
                            "Unexpected type for hduValueColumn.\n  Class for hduValueColumn: "
                                + hduValueColumn.getClass()
                                    .getName());
                    }

                    // Validate parameter type.
                    int parameterType = FitsUtils.getHeaderIntValueChecked(
                        binaryTableHDU.getHeader(), PAR_TYPE_KW);
                    if (hduValueColumn instanceof double[]
                        && parameterType != AncillaryParameterType.ANALOG.fitsValue()) {
                        AlertServiceFactory.getInstance()
                            .generateAlert(
                                AncillaryDispatcher.class.getName(),
                                "ancillary data values of type Double must have a parameter type of "
                                    + AncillaryParameterType.ANALOG
                                    + "\n  fileName: " + filename
                                    + "\n  channel: " + i + "\n  "
                                    + PAR_TYPE_KW + ": "
                                    + parameterType);
                    }
                    if (hduValueColumn instanceof String[]
                        && parameterType != AncillaryParameterType.DISCRETE.fitsValue()) {
                        AlertServiceFactory.getInstance()
                            .generateAlert(
                                AncillaryDispatcher.class.getName(),
                                "ancillary data values of type String must have a parameter type of "
                                    + AncillaryParameterType.ANALOG
                                    + "\n  fileName: " + filename
                                    + "\n  channel: " + i + "\n  "
                                    + PAR_TYPE_KW + ": "
                                    + parameterType);
                    }

                    // Convert double values to float values.
                    float[] floatValues = new float[values.length];
                    for (int j = 0; j < values.length; j++) {
                        floatValues[j] = (float) values[j];
                    }

                    // Find or create the struct for this mnemonic.
                    AncillaryEngineeringData struct = mnemonicToAncillaryEngineeringData.get(mnemonic);
                    if (struct == null) {
                        struct = new AncillaryEngineeringData(mnemonic);
                        mnemonicToAncillaryEngineeringData.put(mnemonic, struct);
                    }

                    // Add timestamps and values.
                    struct.setTimestamps(ArrayUtils.addAll(
                        struct.getTimestamps(), timestamps));
                    struct.setValues(ArrayUtils.addAll(struct.getValues(),
                        floatValues));
                }

                // Store metadata.
                ancillaryLogCrud.createAncillaryLog(new AncillaryLog(
                    dispatchLog, filename, scConfigId));

            } catch (Throwable e) {
                dispatcherWrapper.throwExceptionForFile(filename, e);
            }

            fileCounter++;
        }

        Collection<AncillaryEngineeringData> ancillaryData = mnemonicToAncillaryEngineeringData.values();

        log.info("Storing ancillary data structs...");
        ancillaryOperations.storeAncillaryEngineeringData(ancillaryData,
            DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID);
    }

    private double[] getDoubleValues(String mnemonic, String[] stringValues) {
        List<AncillaryDictionaryMnemonic> dictionary = ancillaryDictionaryCrud.retrieveAncillaryDictionary();
        AncillaryDictionaryMnemonic entry = null;
        for (AncillaryDictionaryMnemonic m : dictionary) {
            if (m.getMnemonic()
                .equals(mnemonic)) {
                entry = m;
                break;
            }
        }

        // Create the entry if it doesn't exist.
        if (entry == null) {
            entry = new AncillaryDictionaryMnemonic(mnemonic);
            dictionary.add(entry);
            ancillaryDictionaryCrud.createAncillaryDictionaryEntry(entry);
        }

        List<AncillaryDictionaryValues> valuesList = entry.getValues();
        double[] doubleValues = new double[stringValues.length];
        for (int i = 0; i < stringValues.length; i++) {
            AncillaryDictionaryValues values = null;
            double maxDoubleValue = 0;
            for (AncillaryDictionaryValues v : valuesList) {
                if (v.getStringValue()
                    .equals(stringValues[i])) {
                    values = v;
                }

                if (v.getDoubleValue() > maxDoubleValue) {
                    maxDoubleValue = v.getDoubleValue();
                }
            }

            // Create the entry if it doesn't exist.
            if (values == null) {
                values = new AncillaryDictionaryValues(stringValues[i],
                    maxDoubleValue + 1);
                valuesList.add(values);
            }

            doubleValues[i] = values.getDoubleValue();
        }

        return doubleValues;
    }

    void setAncillaryOperations(AncillaryOperations ancillaryOperations) {
        this.ancillaryOperations = ancillaryOperations;
    }

    void setAncillaryLogCrud(AncillaryLogCrud ancillaryLogCrud) {
        this.ancillaryLogCrud = ancillaryLogCrud;
    }

    void setAncillaryDictionaryCrud(
        AncillaryDictionaryCrud ancillaryDictionaryCrud) {
        this.ancillaryDictionaryCrud = ancillaryDictionaryCrud;
    }

}
