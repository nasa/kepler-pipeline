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

package gov.nasa.kepler.dr.lazyfits;

import static gov.nasa.kepler.common.FitsConstants.NAXIS1_KW;
import static gov.nasa.kepler.common.FitsConstants.NAXIS2_KW;
import static gov.nasa.kepler.common.FitsConstants.PCOUNT_KW;
import static gov.nasa.kepler.common.FitsConstants.TFIELDS_KW;
import static gov.nasa.kepler.common.FitsConstants.TFORM_KW;
import static gov.nasa.kepler.common.FitsConstants.XTENSION_BINTABLE_VALUE;
import static gov.nasa.kepler.common.FitsConstants.XTENSION_KW;
import gov.nasa.kepler.services.alert.AlertServiceFactory;

import java.io.DataInputStream;
import java.io.EOFException;
import java.io.IOException;
import java.io.RandomAccessFile;

/**
 * Represents the optional data array or table of a FITS HDU
 * 
 * @author tklaus
 * 
 */
public class Data {
    private RandomAccessFile fileReader;
    private boolean loaded = false;

    private Hdu referenceHdu = null;
    private Header header;

    private long fileOffset = 0;
    private int bytesPerRow;
    private int rowCount;
    private int extensionDataBytesCount;
    private int columnCount = 0;

    /**
     * Each element in this array is an array of primitives containing the data
     * for that column
     */
    private Object[] tableData;

    /**
     * Data type for each table column, as specified in TFORMn keyword
     */
    private char[] tableDataType;

    /**
     * The non-reference case. Immediately read the data table contents from the
     * specified RandomAccessFile. The file pointer is assumed to be set to the
     * beginning of the table
     * 
     * @param fileReader
     * @param header
     * @throws LazyFitsException
     * @throws EOFException
     */
    public Data(RandomAccessFile fileReader, Header header)
        throws LazyFitsException, EOFException {
        this.fileReader = fileReader;
        this.header = header;

        read();
    }

    /**
     * The reference case. No data is read from the file until requested.
     * 
     * @param fileReader
     * @param referenceHdu
     */
    public Data(RandomAccessFile fileReader, Hdu referenceHdu) {
        this.fileReader = fileReader;
        this.referenceHdu = referenceHdu;
    }

    public Object getColumn(int columnIndex) throws LazyFitsException,
        EOFException {
        if (!loaded) {
            read();
        }
        return tableData[columnIndex];
    }

    /**
     * Read the contents of the data table. In the reference case, the table
     * metadata (number of columns, column types, row count, etc.) is read from
     * the reference and a seek() is done to the beginning of the table using
     * the offset from the reference.
     * 
     * In the non-reference case table metadata is read from the Header.
     * 
     * @throws LazyFitsException
     * @throws EOFException
     */
    private void read() throws LazyFitsException, EOFException {
        try {
            if (referenceHdu != null) {
                fileOffset = referenceHdu.getDataFileOffset();
                fileReader.seek(fileOffset);

                Data referenceData = referenceHdu.getData();

                bytesPerRow = referenceData.bytesPerRow;
                rowCount = referenceData.rowCount;
                extensionDataBytesCount = referenceData.extensionDataBytesCount;
                columnCount = referenceData.columnCount;
                tableData = referenceData.tableData;
                tableDataType = referenceData.tableDataType;
            } else {
                fileOffset = fileReader.getFilePointer();

                String tableType = header.getStringValue(XTENSION_KW);
                if (tableType == null || !tableType.equals(XTENSION_BINTABLE_VALUE)) {
                    throw new LazyFitsException(
                        "Currently only Binary Tables are supported");
                }

                bytesPerRow = header.getIntValue(NAXIS1_KW);
                rowCount = header.getIntValue(NAXIS2_KW);
                extensionDataBytesCount = header.getIntValue(PCOUNT_KW);
                columnCount = header.getIntValue(TFIELDS_KW);

                tableData = new Object[columnCount];
                tableDataType = new char[columnCount];

                for (int columnIndex = 0; columnIndex < columnCount; columnIndex++) {
                    String columnTypeStr = header.getStringValue(TFORM_KW
                        + (columnIndex + 1));
                    char columnType = columnTypeStr.charAt(0);

                    if (Character.isDigit(columnType)) {
                        int repeatCount = Character.digit(columnType, 10);
                        if (repeatCount != 1) {
                            throw new LazyFitsException(
                                "RepeatCount != 1 not supported for columnIndex="
                                    + columnIndex + ", columnType="
                                    + columnTypeStr);
                        }
                        columnType = columnTypeStr.charAt(1);
                    }
                    tableDataType[columnIndex] = columnType;
                }
            }

            initColumnData();
            readDataContents();

            loaded = true;
        } catch (EOFException e) {
            throw e;
        } catch (IOException e) {
            throw new LazyFitsException("failed to read Hdu", e);
        }
    }

    /**
     * Initialize the column data array to the correct type (based on the TFORMn
     * keyword) and the correct length (based on rowCount)
     * 
     * @param columnIndex
     * @return
     * @throws LazyFitsException
     * @throws EOFException
     */
    private void initColumnData() throws LazyFitsException, EOFException {

        for (int columnIndex = 0; columnIndex < columnCount; columnIndex++) {
            Object columnData = null;

            char columnType = tableDataType[columnIndex];

            switch (columnType) {
                case 'B':
                    // unsigned byte, treat as Java byte
                    columnData = new byte[rowCount];
                    break;

                case 'I':
                    // 16-bit int, Java short
                    columnData = new short[rowCount];
                    break;

                case 'J':
                    // 32-bit int, Java int
                    columnData = new int[rowCount];
                    break;

                case 'K':
                    // 64-bit int, Java long
                    columnData = new long[rowCount];
                    break;

                case 'E':
                    // single-precision floating point, Java float
                    columnData = new float[rowCount];
                    break;

                case 'D':
                    // double-precision floating point, Java double
                    columnData = new double[rowCount];
                    break;

                case 'L':
                    // logical, Java boolean
                    columnData = new boolean[rowCount];
                    break;

                case 'A':
                    // Character, Java char
                    columnData = new char[rowCount];
                    break;

                default:
                    throw new LazyFitsException(
                        "Unsupported table column type=" + columnType);
            }
            tableData[columnIndex] = columnData;
            tableDataType[columnIndex] = columnType;
        }
    }

    /**
     * Read the contents of the data table
     * 
     * @throws LazyFitsException
     */
    private void readDataContents() throws LazyFitsException {

        FitsLogicalRecordInputStream fitsInput = new FitsLogicalRecordInputStream(
            fileReader);

        DataInputStream dis = null;
        try {
            dis = new DataInputStream(fitsInput);
            for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
                for (int columnIndex = 0; columnIndex < columnCount; columnIndex++) {
                    switch (tableDataType[columnIndex]) {
                        case 'B':
                            // unsigned byte, treat as Java byte
                            byte[] byteData = (byte[]) tableData[columnIndex];
                            byteData[rowIndex] = dis.readByte();
                            break;

                        case 'I':
                            // 16-bit int, Java short
                            short[] shortData = (short[]) tableData[columnIndex];
                            shortData[rowIndex] = dis.readShort();
                            break;

                        case 'J':
                            // 32-bit int, Java int
                            int[] intData = (int[]) tableData[columnIndex];
                            intData[rowIndex] = dis.readInt();
                            break;

                        case 'K':
                            // 64-bit int, Java long
                            long[] longData = (long[]) tableData[columnIndex];
                            longData[rowIndex] = dis.readLong();
                            break;

                        case 'E':
                            // single-precision floating point, Java float
                            float[] floatData = (float[]) tableData[columnIndex];
                            floatData[rowIndex] = dis.readFloat();
                            break;

                        case 'D':
                            // double-precision floating point, Java double
                            double[] doubleData = (double[]) tableData[columnIndex];
                            doubleData[rowIndex] = dis.readDouble();
                            break;

                        case 'L':
                            // logical, Java boolean
                            boolean[] booleanData = (boolean[]) tableData[columnIndex];
                            booleanData[rowIndex] = dis.readBoolean();
                            break;

                        case 'A':
                            // Character, Java char
                            char[] charData = (char[]) tableData[columnIndex];
                            charData[rowIndex] = dis.readChar();
                            break;

                        default:
                            throw new LazyFitsException(
                                "Unsupported table column type="
                                    + tableDataType[columnIndex]);
                    }
                }
            }
        } catch (IOException e) {
            throw new LazyFitsException(
                "Caught IOException trying to read table data", e);
        } finally {
            if (dis != null) {
                try {
                    dis.close();
                } catch (IOException e) {
                    AlertServiceFactory.getInstance()
                        .generateAlert(getClass().getName(),
                            "Unable to close stream." + e);
                }
            }
        }
    }

    /**
     * @return the rowCount
     */
    public int getRowCount() {
        return rowCount;
    }
}
