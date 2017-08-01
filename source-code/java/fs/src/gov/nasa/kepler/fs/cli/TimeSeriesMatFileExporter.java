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

package gov.nasa.kepler.fs.cli;

import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import com.jmatio.io.MatFileWriter;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLCell;
import com.jmatio.types.MLChar;
import com.jmatio.types.MLDouble;
import com.jmatio.types.MLUInt8;

/**
 * Exports a set of time series as a .mat file.
 * 
 * @author Sean McCauliff
 * 
 */
public class TimeSeriesMatFileExporter {

    public TimeSeriesMatFileExporter() {

    }

    public void export(File outputFile, FloatMjdTimeSeries[] timeSeries) throws IOException {
        if (timeSeries.length == 0) {
            throw new IllegalArgumentException(
                "timeSeries[] must not be empty.");
        }

        MLCell matlabData = new MLCell("mjdTimeSeries", new int[] {
            timeSeries.length, 1 });
        MLCell matlabFsIds = new MLCell("fsIds", new int[] { timeSeries.length,
            1 });
        for (int seriesi = 0; seriesi < timeSeries.length; seriesi++) {
            FloatMjdTimeSeries mjdTimeSeries = timeSeries[seriesi];
            float[] floatValues = mjdTimeSeries.values();
            double[] doubleValues = new double[floatValues.length * 3];
            for (int valuei = 0; valuei < floatValues.length; valuei++) {
                doubleValues[valuei] = floatValues[valuei];
            }
            System.arraycopy(mjdTimeSeries.mjd(), 0, doubleValues,
                floatValues.length, floatValues.length);
            long[] originators = mjdTimeSeries.originators();
            for (int origini=0; origini < originators.length; origini++) {
                doubleValues[origini + (floatValues.length * 2)] = 
                    originators[origini];
            }
            MLDouble matlabSeries = new MLDouble("series-" + seriesi, doubleValues,
                floatValues.length);
            matlabData.set(matlabSeries, seriesi);

            MLChar matlabFsId = new MLChar("id" + seriesi, mjdTimeSeries.id()
                .toString());
            matlabFsIds.set(matlabFsId, seriesi);
        }

        List<MLArray> matlabSave = new ArrayList<MLArray>();
        matlabSave.add(matlabData);
        matlabSave.add(matlabFsIds);
        
        new MatFileWriter(outputFile, matlabSave);

    }

    
    public void export(File outputFile, TimeSeries[] allSeries) throws IOException {
        if (allSeries.length == 0) {
            throw new IllegalArgumentException("timeSeries[] must not be empty");
        }
        int columnLength = allSeries[0].cadenceLength();

        double[] dataSeries = new double[allSeries.length * columnLength];
        int dataSeriesIndex = 0;
        for (TimeSeries ts : allSeries) {
            switch (ts.dataType()) {
                case IntType:
                    IntTimeSeries its = (IntTimeSeries) ts;
                    int[] idata = its.iseries();
                    for (int dataPoint : idata) {
                        dataSeries[dataSeriesIndex++] = dataPoint;
                    }
                    break;
                case FloatType:
                    FloatTimeSeries fts = (FloatTimeSeries) ts;
                    float[] fdata = fts.fseries();
                    for (float dataPoint : fdata) {
                        dataSeries[dataSeriesIndex++] = dataPoint;
                    }
                    break;
                case DoubleType:
                    DoubleTimeSeries dts = (DoubleTimeSeries) ts;
                    double[] ddata = dts.dseries();
                    System.arraycopy(ddata, 0, dataSeries, dataSeriesIndex, ddata.length);
                    dataSeriesIndex += ddata.length;
                    break;
                default:
                    throw new IllegalStateException("Bad data type \"" + 
                        ts.dataType() + "\".");
            }
        }

        export(outputFile, dataSeries, allSeries, columnLength);
    }

    private void export(File outputFile, double[] dataSeries,
        TimeSeries[] timeSeries, int columnLength) throws IOException {
        byte[] gapIndicators = new byte[dataSeries.length];
        Arrays.fill(gapIndicators, (byte) 1);
        double[] originators = new double[dataSeries.length];
        
        int gapIndicatorsIndex = 0;
        for (TimeSeries element : timeSeries) {
            for (TaggedInterval origin : element.originators()) {
                int start = (int) (origin.start() - element.startCadence())
                    + gapIndicatorsIndex;
                int end = (int) (origin.end() - element.startCadence())
                    + gapIndicatorsIndex;
                for (int i = start; i <= end; i++) {
                    gapIndicators[i] = 0;
                    originators[i] = origin.tag();
                }
            }
            gapIndicatorsIndex += columnLength;
        }

        MLDouble matlabData = new MLDouble("values", dataSeries, columnLength);
        MLDouble matlabOriginators = new MLDouble("originators", originators, columnLength);
        MLUInt8 matlabGaps = new MLUInt8("gaps", gapIndicators, columnLength);

        MLDouble matlabMinMaxCadence = new MLDouble("minMaxCadence",
            new double[] { timeSeries[0].startCadence(),
                timeSeries[0].endCadence() }, 1);

        MLCell fsIdCellArray = new MLCell("fsids", new int[] {
            timeSeries.length, 1 });
        for (int i = 0; i < timeSeries.length; i++) {
            MLChar matlabChar = new MLChar("id" + i, timeSeries[i].id()
                .toString());
            fsIdCellArray.set(matlabChar, i);
        }

        List<MLArray> matlabOutput = new ArrayList<MLArray>(1);
        matlabOutput.add(matlabData);
        matlabOutput.add(matlabGaps);
        matlabOutput.add(matlabOriginators);
        matlabOutput.add(fsIdCellArray);
        matlabOutput.add(matlabMinMaxCadence);

        // As a side effect this writes out the file. Hey I didn't write that library.
        new MatFileWriter(outputFile, matlabOutput);

    }

}
