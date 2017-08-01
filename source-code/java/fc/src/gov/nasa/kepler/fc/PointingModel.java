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

package gov.nasa.kepler.fc;

import gov.nasa.kepler.hibernate.fc.Pointing;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.List;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class PointingModel implements Persistable {

    @ProxyIgnore
    private static final Log log = LogFactory.getLog(PointingModel.class);
    
    private double[] mjds = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] ras = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] declinations = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] rolls = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] segmentStartMjds = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private FcModelMetadata fcModelMetadata = new FcModelMetadata();

    /**
     * Required by {@link Persistable}.
     */
    public PointingModel() {
    }

    public PointingModel(double[] mjds, double[] ras, double[] declinations,
        double[] rolls, double[] segmentStartMjds) {

        this.mjds = mjds;
        this.ras = ras;
        this.declinations = declinations;
        this.rolls = rolls;
        this.segmentStartMjds = segmentStartMjds;
        checkSize();
    }

    public PointingModel(List<Pointing> pointings) {

        double[] mjds = new double[pointings.size()];
        double[] ras = new double[pointings.size()];
        double[] declinations = new double[pointings.size()];
        double[] rolls = new double[pointings.size()];
        double[] segmentStartMjds = new double[pointings.size()];
        for (int i = 0; i < pointings.size(); ++i) {
            mjds[i] = pointings.get(i)
                .getMjd();
            ras[i] = pointings.get(i)
                .getRa();
            declinations[i] = pointings.get(i)
                .getDeclination();
            rolls[i] = pointings.get(i)
                .getRoll();
            segmentStartMjds[i] = pointings.get(i)
                .getSegmentStartMjd();
        }

        this.mjds = mjds;
        this.ras = ras;
        this.declinations = declinations;
        this.rolls = rolls;
        this.segmentStartMjds = segmentStartMjds;
    }

    private void checkSize() {
        if (mjds.length != ras.length || mjds.length != declinations.length
            || mjds.length != rolls.length
            || mjds.length != segmentStartMjds.length) {
            log.info("mjds.length: " + mjds.length);
            log.info("ras.length: " + ras.length);
            log.info("declinations.length: " + declinations.length);
            log.info("rolls.length: " + rolls.length);
            log.info("segmentStartMjds.length: " + segmentStartMjds.length);
            throw new PipelineException("Inconsistent sizes in PointingModel");
        }
    }

    public int size() {
        return mjds.length;
    }

    @Override
    public String toString() {
        StringBuilder out = new StringBuilder();
        checkSize();
        for (int i = 0; i < size(); ++i) {
            out.append(mjds[i])
                .append(" ");
            out.append(ras[i])
                .append(" ");
            out.append(declinations[i])
                .append(" ");
            out.append(rolls[i])
                .append(" ");
            out.append(segmentStartMjds[i])
                .append("\n");
        }

        return out.toString();
    }

    public double[] getMjds() {
        return this.mjds;
    }

    public void setMjds(double[] mjds) {
        this.mjds = mjds;
    }

    public double[] getRas() {
        return this.ras;
    }

    public void setRas(double[] ras) {
        this.ras = ras;
    }

    public double[] getDeclinations() {
        return this.declinations;
    }

    public void setDeclinations(double[] declinations) {
        this.declinations = declinations;
    }

    public double[] getRolls() {
        return this.rolls;
    }

    public void setRolls(double[] rolls) {
        this.rolls = rolls;
    }

    public double[] getSegmentStartMjds() {
        return segmentStartMjds;
    }

    public void setSegmentStartMjds(double[] segmentStartMjds) {
        this.segmentStartMjds = segmentStartMjds;
    }

    public void setFcModelMetadata(FcModelMetadata fcModelMetadata) {
        this.fcModelMetadata = fcModelMetadata;
    }

    public FcModelMetadata getFcModelMetadata() {
        return fcModelMetadata;
    }
}
