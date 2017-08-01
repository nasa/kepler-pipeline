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

package gov.nasa.kepler.ar.exporter.flux2;

import gov.nasa.kepler.ar.exporter.ExposureCalculator;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayWriter;
import gov.nasa.kepler.ar.exporter.binarytable.DoubleArrayWriter;
import gov.nasa.kepler.ar.exporter.binarytable.FloatArrayWriter;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;

import java.util.Map;

/**
 * A helper class to construct ArrayWriters from time series.
 * 
 * @author Sean McCauliff
 *
 */
public final class Accessor {
    private final Map<FsId, TimeSeries> src;
    private float floatFill;
    private int intFill;
    private final ExposureCalculator exposureCalc;

    public Accessor(Map<FsId, TimeSeries> src, float floatFill,
        int intFill, ExposureCalculator exposureCalc) {
        this.src = src;
        this.floatFill = floatFill;
        this.intFill = intFill;
        this.exposureCalc = exposureCalc;
    }

    public ArrayWriter farray(FsId id, boolean useCalc) {
        TimeSeries ts = src.get(id);
        if (!ts.exists()) {
            // All gaps
            return new MissingFloatArrayWriter(floatFill);
        }
        FloatTimeSeries fts = ts.asFloatTimeSeries();
        fts.fillGaps(floatFill);
        if (useCalc) {
            return new FloatArrayWriter(fts.fseries(), exposureCalc);
        }
        return new FloatArrayWriter(fts.fseries(), null);
    }

    public ArrayWriter darray(FsId id) {
        TimeSeries ts = src.get(id);
        if (!ts.exists()) {
            return new MissingDoubleArrayWriter(floatFill);
        }
        DoubleTimeSeries dts = src.get(id)
            .asDoubleTimeSeries();
        dts.fillGaps(floatFill);
        return new DoubleArrayWriter(dts.dseries());
    }
}