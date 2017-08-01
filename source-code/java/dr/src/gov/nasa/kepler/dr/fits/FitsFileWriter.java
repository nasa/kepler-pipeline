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

package gov.nasa.kepler.dr.fits;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Lists.newArrayList;

import java.io.DataOutputStream;
import java.io.OutputStream;
import java.util.List;

import nom.tam.fits.BinaryTable;
import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;

/**
 * Writes fits files.
 * 
 * Construct by supplying an open {@link OutputStream}. The {@code write} method
 * writes the contents of the supplied {@link FitsFile} to that
 * {@link OutputStream}.
 * 
 * @author Miles Cote
 * 
 */
public class FitsFileWriter {

    private final OutputStream outputStream;

    public FitsFileWriter(OutputStream outputStream) {
        checkNotNull(outputStream, "outputStream can't be null");
        this.outputStream = outputStream;
    }

    public void write(FitsFile fitsFile) {
        checkNotNull(fitsFile, "fitsFile can't be null");
        try {
            List<BinaryTableHDU> binaryTableHdus = getBinaryTableHdus(fitsFile);

            Fits fits = new Fits();
            fits.addHDU(Fits.makeHDU(getHeader(fitsFile.getFitsHeader())));

            for (BinaryTableHDU binaryTableHdu : binaryTableHdus) {
                fits.addHDU(binaryTableHdu);
            }

            fits.write(new DataOutputStream(outputStream));

            outputStream.close();
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to write.", e);
        }
    }

    private List<BinaryTableHDU> getBinaryTableHdus(FitsFile fitsFile)
        throws FitsException {
        checkNotNull(fitsFile, "fitsFile can't be null");
        List<BinaryTableHDU> binaryTableHdus = newArrayList();
        for (FitsTable fitsTable : fitsFile.getFitsTables()) {
            List<Object> tableHduColumns = getTableHduColumns(fitsTable);

            Header header = getHeader(fitsTable.getFitsHeader());

            BinaryTable binaryTable = new BinaryTable(
                tableHduColumns.toArray(new Object[0]));

            binaryTableHdus.add(new BinaryTableHDU(header, binaryTable));
        }

        return binaryTableHdus;
    }

    private Header getHeader(FitsHeader fitsHeader) {
        checkNotNull(fitsHeader, "fitsHeader can't be null");
        return fitsHeader.getHeader();
    }

    private List<Object> getTableHduColumns(FitsTable fitsTable) {
        checkNotNull(fitsTable, "fitsTable can't be null");
        List<Object> tableHduColumns = newArrayList();
        for (FitsColumn fitsColumn : fitsTable.getFitsColumns()) {
            Object tableHduColumn = getTableHduColumn(fitsColumn.getValues());

            tableHduColumns.add(tableHduColumn);
        }

        return tableHduColumns;
    }

    private Object getTableHduColumn(List<Number> values) {
        checkNotNull(values, "values can't be null");
        Object tableHduColumn = new int[0];
        if (!values.isEmpty()) {
            Number value = values.get(0);
            if (value instanceof Byte) {
                byte[] array = new byte[values.size()];
                for (int i = 0; i < values.size(); i++) {
                    array[i] = (Byte) values.get(i);
                }
                tableHduColumn = array;
            } else if (value instanceof Short) {
                short[] array = new short[values.size()];
                for (int i = 0; i < values.size(); i++) {
                    array[i] = (Short) values.get(i);
                }
                tableHduColumn = array;
            } else if (value instanceof Integer) {
                int[] array = new int[values.size()];
                for (int i = 0; i < values.size(); i++) {
                    array[i] = (Integer) values.get(i);
                }
                tableHduColumn = array;
            } else if (value instanceof Long) {
                long[] array = new long[values.size()];
                for (int i = 0; i < values.size(); i++) {
                    array[i] = (Long) values.get(i);
                }
                tableHduColumn = array;
            } else if (value instanceof Float) {
                float[] array = new float[values.size()];
                for (int i = 0; i < values.size(); i++) {
                    array[i] = (Float) values.get(i);
                }
                tableHduColumn = array;
            } else if (value instanceof Double) {
                double[] array = new double[values.size()];
                for (int i = 0; i < values.size(); i++) {
                    array[i] = (Double) values.get(i);
                }
                tableHduColumn = array;
            } else {
                throw new IllegalArgumentException("Unexpected type: "
                    + value.getClass());
            }
        }

        return tableHduColumn;
    }

}
