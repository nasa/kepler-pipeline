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
import static com.google.common.primitives.Bytes.asList;
import static com.google.common.primitives.Doubles.asList;
import static com.google.common.primitives.Floats.asList;
import static com.google.common.primitives.Ints.asList;
import static com.google.common.primitives.Longs.asList;
import static com.google.common.primitives.Shorts.asList;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.TableHDU;

/**
 * Reads fits files.
 * 
 * Construct by supplying an open {@link InputStream} to a FITS file. The
 * {@code read} method returns a new {@link FitsFile} corresponding to the FITS
 * file.
 * 
 * @author Miles Cote
 * 
 */
public class FitsFileReader {

    private final InputStream inputStream;

    public FitsFileReader(InputStream inputStream) {
        checkNotNull(inputStream, "inputStream can't be null.");
        this.inputStream = inputStream;
    }

    public FitsFile read() {
        try {
            Fits fits = new Fits(inputStream);

            List<FitsTable> fitsTables = getFitsTables(fits);

            return new FitsFile(getFitsHeader(fits.getHDU(0)), fitsTables);
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to read.", e);
        }
    }

    private List<FitsTable> getFitsTables(Fits fits) throws FitsException,
        IOException {
        checkNotNull(fits, "fits can't be null.");
        List<FitsTable> fitsTables = newArrayList();
        for (BasicHDU basicHdu : fits.read()) {
            if (basicHdu instanceof TableHDU) {
                TableHDU tableHdu = (TableHDU) basicHdu;

                fitsTables.add(new FitsTable(getFitsHeader(tableHdu),
                    getFitsColumns(tableHdu)));
            }
        }

        return fitsTables;
    }

    private FitsHeader getFitsHeader(BasicHDU basicHdu) {
        checkNotNull(basicHdu, "basicHdu can't be null.");
        return FitsHeader.of(basicHdu.getHeader());
    }

    private List<FitsColumn> getFitsColumns(TableHDU tableHdu)
        throws FitsException {
        checkNotNull(tableHdu, "tableHdu can't be null.");
        List<FitsColumn> fitsColumns = newArrayList();
        for (int i = 0; i < tableHdu.getNCols(); i++) {
            fitsColumns.add(new FitsColumn(getValues(tableHdu.getColumn(i))));
        }

        return fitsColumns;
    }

    private List<Number> getValues(Object tableHduColumn) {
        List<Number> values = newArrayList();
        if (tableHduColumn instanceof byte[]) {
            List<Byte> list = asList((byte[]) tableHduColumn);
            for (Byte element : list) {
                values.add(element);
            }
        } else if (tableHduColumn instanceof short[]) {
            List<Short> list = asList((short[]) tableHduColumn);
            for (Short element : list) {
                values.add(element);
            }
        } else if (tableHduColumn instanceof int[]) {
            List<Integer> list = asList((int[]) tableHduColumn);
            for (Integer element : list) {
                values.add(element);
            }
        } else if (tableHduColumn instanceof long[]) {
            List<Long> list = asList((long[]) tableHduColumn);
            for (Long element : list) {
                values.add(element);
            }
        } else if (tableHduColumn instanceof float[]) {
            List<Float> list = asList((float[]) tableHduColumn);
            for (Float element : list) {
                values.add(element);
            }
        } else if (tableHduColumn instanceof double[]) {
            List<Double> list = asList((double[]) tableHduColumn);
            for (Double element : list) {
                values.add(element);
            }
        } else {
            throw new IllegalArgumentException("Unexpected type: "
                + tableHduColumn.getClass());
        }

        return values;
    }

}
