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

package gov.nasa.kepler.mc.ppa;

import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeries;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeriesCrud;
import gov.nasa.kepler.hibernate.mc.DoubleTimeSeriesType;
import gov.nasa.kepler.mc.DoubleDbTimeSeriesOperations;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.fs.PpaFsIdFactory;
import gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * Attitude solution produced by PPA and consumed by PA.
 * 
 * @author Forrest Girouard
 * @author Jay Gunter
 * 
 */
public class AttitudeSolution implements Persistable {

    @ProxyIgnore
    public static final List<TimeSeriesType> FLOAT_TYPES = new ArrayList<TimeSeriesType>();

    static {
        FLOAT_TYPES.add(TimeSeriesType.MAX_ATTITUDE_FOCAL_PLANE_RESIDUAL);
        FLOAT_TYPES.add(TimeSeriesType.COVARIANCE_MATRIX_1_1);
        FLOAT_TYPES.add(TimeSeriesType.COVARIANCE_MATRIX_2_2);
        FLOAT_TYPES.add(TimeSeriesType.COVARIANCE_MATRIX_3_3);
        FLOAT_TYPES.add(TimeSeriesType.COVARIANCE_MATRIX_1_2);
        FLOAT_TYPES.add(TimeSeriesType.COVARIANCE_MATRIX_1_3);
        FLOAT_TYPES.add(TimeSeriesType.COVARIANCE_MATRIX_2_3);
    }

    @ProxyIgnore
    public static final List<DoubleTimeSeriesType> DOUBLE_TYPES = new ArrayList<DoubleTimeSeriesType>();

    static {
        DOUBLE_TYPES.add(DoubleTimeSeriesType.PPA_RA);
        DOUBLE_TYPES.add(DoubleTimeSeriesType.PPA_DEC);
        DOUBLE_TYPES.add(DoubleTimeSeriesType.PPA_ROLL);
    }

    private double[] ra = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] dec = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] roll = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private float[] maxAttitudeFocalPlaneResidual = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] covarianceMatrix11 = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] covarianceMatrix22 = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] covarianceMatrix33 = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] covarianceMatrix12 = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] covarianceMatrix13 = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] covarianceMatrix23 = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private boolean[] gapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;

    /**
     * Obtains an instance of the {@link AttitudeSolution} for the given
     * cadences, long only.
     * 
     * @param startLongCadence the starting cadence
     * @param endLongCadence the ending cadence
     * @param doubleDbTimeSeriesCrud the CRUD object for obtaining the double DB
     * time series (the regular time series is provided via the
     * {@link FileStoreClientFactory})
     * @param producerTaskIds the set of task IDs which is appended with the
     * producers of the time series that were read
     * @return an {@link AttitudeSolution}
     */
    public static AttitudeSolution getInstance(int startLongCadence,
        int endLongCadence, DoubleDbTimeSeriesCrud doubleDbTimeSeriesCrud,
        Set<Long> producerTaskIds) {

        AttitudeSolution attitudeSolution = new AttitudeSolution();

        List<FsId> fsIds = AttitudeSolution.getAllTimeSeriesFsIds();
        FloatTimeSeries[] floatTimeSeries = FileStoreClientFactory.getInstance()
            .readTimeSeriesAsFloat(fsIds.toArray(new FsId[fsIds.size()]),
                startLongCadence, endLongCadence, false);

        Map<FsId, FloatTimeSeries> timeSeriesByFsId = TimeSeriesOperations.getFloatTimeSeriesByFsId(floatTimeSeries);
        if (!timeSeriesByFsId.isEmpty()) {
            TimeSeriesOperations.addToDataAccountability(floatTimeSeries,
                producerTaskIds);
            attitudeSolution.setAllFloatTimeSeries(timeSeriesByFsId);

            Map<DoubleTimeSeriesType, DoubleDbTimeSeries> doubleTimeSeriesByType = new HashMap<DoubleTimeSeriesType, DoubleDbTimeSeries>();
            for (DoubleTimeSeriesType type : AttitudeSolution.getAllDoubleTimeSeriesTypes()) {
                DoubleDbTimeSeries doubleTimeSeries = doubleDbTimeSeriesCrud.retrieve(
                    type, startLongCadence, endLongCadence);
                doubleTimeSeriesByType.put(type, doubleTimeSeries);
            }
            DoubleDbTimeSeriesOperations.addToDataAccountability(
                doubleTimeSeriesByType.values()
                    .toArray(new DoubleDbTimeSeries[0]), producerTaskIds);
            attitudeSolution.setAllDoubleTimeSeries(doubleTimeSeriesByType);
        }

        return attitudeSolution;
    }

    public static List<FsId> getAllTimeSeriesFsIds() {

        List<FsId> fsIds = new ArrayList<FsId>();
        for (TimeSeriesType type : FLOAT_TYPES) {
            fsIds.add(PpaFsIdFactory.getTimeSeriesFsId(type));
        }
        return fsIds;
    }

    public static List<DoubleTimeSeriesType> getAllDoubleTimeSeriesTypes() {

        List<DoubleTimeSeriesType> types = new ArrayList<DoubleTimeSeriesType>();
        types.addAll(DOUBLE_TYPES);
        return types;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(dec);
        result = prime * result + Arrays.hashCode(ra);
        result = prime * result + Arrays.hashCode(roll);
        result = prime * result + Arrays.hashCode(covarianceMatrix11);
        result = prime * result + Arrays.hashCode(covarianceMatrix12);
        result = prime * result + Arrays.hashCode(covarianceMatrix13);
        result = prime * result + Arrays.hashCode(covarianceMatrix22);
        result = prime * result + Arrays.hashCode(covarianceMatrix23);
        result = prime * result + Arrays.hashCode(covarianceMatrix33);
        result = prime * result + Arrays.hashCode(gapIndicators);
        result = prime * result
            + Arrays.hashCode(maxAttitudeFocalPlaneResidual);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        final AttitudeSolution other = (AttitudeSolution) obj;
        if (!Arrays.equals(dec, other.dec))
            return false;
        if (!Arrays.equals(ra, other.ra))
            return false;
        if (!Arrays.equals(roll, other.roll))
            return false;
        if (!Arrays.equals(covarianceMatrix11, other.covarianceMatrix11))
            return false;
        if (!Arrays.equals(covarianceMatrix12, other.covarianceMatrix12))
            return false;
        if (!Arrays.equals(covarianceMatrix13, other.covarianceMatrix13))
            return false;
        if (!Arrays.equals(covarianceMatrix22, other.covarianceMatrix22))
            return false;
        if (!Arrays.equals(covarianceMatrix23, other.covarianceMatrix23))
            return false;
        if (!Arrays.equals(covarianceMatrix33, other.covarianceMatrix33))
            return false;
        if (!Arrays.equals(gapIndicators, other.gapIndicators))
            return false;
        if (!Arrays.equals(maxAttitudeFocalPlaneResidual,
            other.maxAttitudeFocalPlaneResidual))
            return false;
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("ra.length", ra.length)
            .append("dec.length", dec.length)
            .append("roll.length", roll.length)
            .append("maxAttitudeFocalPlaneResidual.length",
                maxAttitudeFocalPlaneResidual.length)
            .append("covarianceMatrix11.length", covarianceMatrix11.length)
            .append("covarianceMatrix22.length", covarianceMatrix22.length)
            .append("covarianceMatrix33.length", covarianceMatrix33.length)
            .append("covarianceMatrix12.length", covarianceMatrix12.length)
            .append("covarianceMatrix13.length", covarianceMatrix13.length)
            .append("covarianceMatrix23.length", covarianceMatrix23.length)
            .append("gapIndicators.length", gapIndicators.length)
            .toString();
    }

    public void setAllFloatTimeSeries(
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        setMaxAttitudeFocalPlaneResidual(timeSeriesByFsId);
        setCovarianceMatrix11(timeSeriesByFsId);
        setCovarianceMatrix22(timeSeriesByFsId);
        setCovarianceMatrix33(timeSeriesByFsId);
        setCovarianceMatrix12(timeSeriesByFsId);
        setCovarianceMatrix13(timeSeriesByFsId);
        setCovarianceMatrix23(timeSeriesByFsId);
    }

    public void setAllDoubleTimeSeries(
        Map<DoubleTimeSeriesType, DoubleDbTimeSeries> timeSeriesByType) {

        setRa(timeSeriesByType);
        setDec(timeSeriesByType);
        setRoll(timeSeriesByType);
    }

    public List<FloatTimeSeries> getAllFloatTimeSeries(int startCadence,
        int endCadence, long pipelineTaskId) {

        List<FloatTimeSeries> timeSeries = new ArrayList<FloatTimeSeries>();

        addMaxAttitudeFocalPlaneResidual(timeSeries, startCadence, endCadence,
            pipelineTaskId);
        addCovarianceMatrix11(timeSeries, startCadence, endCadence,
            pipelineTaskId);
        addCovarianceMatrix22(timeSeries, startCadence, endCadence,
            pipelineTaskId);
        addCovarianceMatrix33(timeSeries, startCadence, endCadence,
            pipelineTaskId);
        addCovarianceMatrix12(timeSeries, startCadence, endCadence,
            pipelineTaskId);
        addCovarianceMatrix13(timeSeries, startCadence, endCadence,
            pipelineTaskId);
        addCovarianceMatrix23(timeSeries, startCadence, endCadence,
            pipelineTaskId);

        return timeSeries;
    }

    public List<DoubleDbTimeSeries> getAllDoubleTimeSeries(int startCadence,
        int endCadence, long pipelineTaskId) {

        List<DoubleDbTimeSeries> timeSeries = new ArrayList<DoubleDbTimeSeries>();
        addRa(timeSeries, startCadence, endCadence, pipelineTaskId);
        addDec(timeSeries, startCadence, endCadence, pipelineTaskId);
        addRoll(timeSeries, startCadence, endCadence, pipelineTaskId);
        return timeSeries;
    }

    public void writeFloatTimeSeries(FileStoreClient fsClient,
        int startCadence, int endCadence, long pipelineTaskId) {

        List<FloatTimeSeries> timeSeries = getAllFloatTimeSeries(startCadence,
            endCadence, pipelineTaskId);
        if (timeSeries.size() > 0) {
            fsClient.writeTimeSeries(timeSeries.toArray(new FloatTimeSeries[0]));
        }
    }

    public void writeDoubleTimeSeries(
        DoubleDbTimeSeriesCrud doubleDbTimeSeriesCrud, int startCadence,
        int endCadence, long pipelineTaskId) {

        List<DoubleDbTimeSeries> timeSeries = getAllDoubleTimeSeries(
            startCadence, endCadence, pipelineTaskId);
        for (DoubleDbTimeSeries doubleTimeSeries : timeSeries) {
            doubleDbTimeSeriesCrud.create(doubleTimeSeries);
        }
    }

    public double[] getDec() {
        return dec;
    }

    public void setDec(double[] dec) {
        this.dec = dec;
    }

    public double[] getRa() {
        return ra;
    }

    public void setRa(double[] ra) {
        this.ra = ra;
    }

    public double[] getRoll() {
        return roll;
    }

    public void setRoll(double[] roll) {
        this.roll = roll;
    }

    public float[] getMaxAttitudeFocalPlaneResidual() {
        return maxAttitudeFocalPlaneResidual;
    }

    public void setMaxAttitudeFocalPlaneResidual(
        float[] maxAttitudeFocalPlaneResidual) {
        this.maxAttitudeFocalPlaneResidual = maxAttitudeFocalPlaneResidual;
    }

    public float[] getCovarianceMatrix11() {
        return covarianceMatrix11;
    }

    public void setCovarianceMatrix11(float[] covarianceMatrix11) {
        this.covarianceMatrix11 = covarianceMatrix11;
    }

    public float[] getCovarianceMatrix22() {
        return covarianceMatrix22;
    }

    public void setCovarianceMatrix22(float[] covarianceMatrix22) {
        this.covarianceMatrix22 = covarianceMatrix22;
    }

    public float[] getCovarianceMatrix33() {
        return covarianceMatrix33;
    }

    public void setCovarianceMatrix33(float[] covarianceMatrix33) {
        this.covarianceMatrix33 = covarianceMatrix33;
    }

    public float[] getCovarianceMatrix12() {
        return covarianceMatrix12;
    }

    public void setCovarianceMatrix12(float[] covarianceMatrix12) {
        this.covarianceMatrix12 = covarianceMatrix12;
    }

    public float[] getCovarianceMatrix13() {
        return covarianceMatrix13;
    }

    public void setCovarianceMatrix13(float[] covarianceMatrix13) {
        this.covarianceMatrix13 = covarianceMatrix13;
    }

    public float[] getCovarianceMatrix23() {
        return covarianceMatrix23;
    }

    public void setCovarianceMatrix23(float[] covarianceMatrix23) {
        this.covarianceMatrix23 = covarianceMatrix23;
    }

    private void addFloatTimeSeries(List<FloatTimeSeries> timeSeries,
        float[] floatsToAdd, TimeSeriesType valuesType, int startCadence,
        int endCadence, long pipelineTaskId) {

        if (floatsToAdd != null && floatsToAdd.length > 0) {
            FsId fsId = PpaFsIdFactory.getTimeSeriesFsId(valuesType);
            timeSeries.add(new FloatTimeSeries(fsId, floatsToAdd, startCadence,
                endCadence, gapIndicators, pipelineTaskId));
        }
    }

    private void addDoubleTimeSeries(List<DoubleDbTimeSeries> timeSeries,
        double[] doublesToAdd, DoubleTimeSeriesType valuesType,
        int startCadence, int endCadence, long pipelineTaskId) {

        if (doublesToAdd != null && doublesToAdd.length > 0) {
            timeSeries.add(new DoubleDbTimeSeries(doublesToAdd, startCadence,
                endCadence, gapIndicators, pipelineTaskId, valuesType));
        }
    }

    private void addRa(List<DoubleDbTimeSeries> timeSeries, int startCadence,
        int endCadence, long pipelineTaskId) {

        addDoubleTimeSeries(timeSeries, getRa(), DoubleTimeSeriesType.PPA_RA,
            startCadence, endCadence, pipelineTaskId);
    }

    private void addDec(List<DoubleDbTimeSeries> timeSeries, int startCadence,
        int endCadence, long pipelineTaskId) {

        addDoubleTimeSeries(timeSeries, getDec(), DoubleTimeSeriesType.PPA_DEC,
            startCadence, endCadence, pipelineTaskId);
    }

    private void addRoll(List<DoubleDbTimeSeries> timeSeries, int startCadence,
        int endCadence, long pipelineTaskId) {

        addDoubleTimeSeries(timeSeries, getRoll(),
            DoubleTimeSeriesType.PPA_ROLL, startCadence, endCadence,
            pipelineTaskId);
    }

    private void addMaxAttitudeFocalPlaneResidual(
        List<FloatTimeSeries> timeSeries, int startCadence, int endCadence,
        long pipelineTaskId) {

        addFloatTimeSeries(timeSeries, getMaxAttitudeFocalPlaneResidual(),
            TimeSeriesType.MAX_ATTITUDE_FOCAL_PLANE_RESIDUAL, startCadence,
            endCadence, pipelineTaskId);
    }

    private void addCovarianceMatrix11(List<FloatTimeSeries> timeSeries,
        int startCadence, int endCadence, long pipelineTaskId) {

        addFloatTimeSeries(timeSeries, getCovarianceMatrix11(),
            TimeSeriesType.COVARIANCE_MATRIX_1_1, startCadence, endCadence,
            pipelineTaskId);
    }

    private void addCovarianceMatrix22(List<FloatTimeSeries> timeSeries,
        int startCadence, int endCadence, long pipelineTaskId) {

        addFloatTimeSeries(timeSeries, getCovarianceMatrix22(),
            TimeSeriesType.COVARIANCE_MATRIX_2_2, startCadence, endCadence,
            pipelineTaskId);
    }

    private void addCovarianceMatrix33(List<FloatTimeSeries> timeSeries,
        int startCadence, int endCadence, long pipelineTaskId) {

        addFloatTimeSeries(timeSeries, getCovarianceMatrix33(),
            TimeSeriesType.COVARIANCE_MATRIX_3_3, startCadence, endCadence,
            pipelineTaskId);
    }

    private void addCovarianceMatrix12(List<FloatTimeSeries> timeSeries,
        int startCadence, int endCadence, long pipelineTaskId) {

        addFloatTimeSeries(timeSeries, getCovarianceMatrix12(),
            TimeSeriesType.COVARIANCE_MATRIX_1_2, startCadence, endCadence,
            pipelineTaskId);
    }

    private void addCovarianceMatrix13(List<FloatTimeSeries> timeSeries,
        int startCadence, int endCadence, long pipelineTaskId) {

        addFloatTimeSeries(timeSeries, getCovarianceMatrix13(),
            TimeSeriesType.COVARIANCE_MATRIX_1_3, startCadence, endCadence,
            pipelineTaskId);
    }

    private void addCovarianceMatrix23(List<FloatTimeSeries> timeSeries,
        int startCadence, int endCadence, long pipelineTaskId) {

        addFloatTimeSeries(timeSeries, getCovarianceMatrix23(),
            TimeSeriesType.COVARIANCE_MATRIX_2_3, startCadence, endCadence,
            pipelineTaskId);
    }

    private void setRa(
        Map<DoubleTimeSeriesType, DoubleDbTimeSeries> timeSeriesByType) {
        DoubleDbTimeSeries timeSeries = timeSeriesByType.get(DoubleTimeSeriesType.PPA_RA);
        if (timeSeries != null) {
            setGapIndicators(timeSeries.getGapIndicators());
            setRa(timeSeries.getValues());
        }
    }

    private void setDec(
        Map<DoubleTimeSeriesType, DoubleDbTimeSeries> timeSeriesByType) {
        DoubleDbTimeSeries timeSeries = timeSeriesByType.get(DoubleTimeSeriesType.PPA_DEC);
        if (timeSeries != null) {
            setGapIndicators(timeSeries.getGapIndicators());
            setDec(timeSeries.getValues());
        }
    }

    private void setRoll(
        Map<DoubleTimeSeriesType, DoubleDbTimeSeries> timeSeriesByType) {
        DoubleDbTimeSeries timeSeries = timeSeriesByType.get(DoubleTimeSeriesType.PPA_ROLL);
        if (timeSeries != null) {
            setGapIndicators(timeSeries.getGapIndicators());
            setRoll(timeSeries.getValues());
        }
    }

    private void setMaxAttitudeFocalPlaneResidual(
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FsId fsId = PpaFsIdFactory.getTimeSeriesFsId(TimeSeriesType.MAX_ATTITUDE_FOCAL_PLANE_RESIDUAL);
        FloatTimeSeries timeSeries = timeSeriesByFsId.get(fsId);
        if (timeSeries != null) {
            setGapIndicators(timeSeries.getGapIndicators());
            setMaxAttitudeFocalPlaneResidual(timeSeries.fseries());
        }
    }

    private void setCovarianceMatrix11(
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FsId fsId = PpaFsIdFactory.getTimeSeriesFsId(TimeSeriesType.COVARIANCE_MATRIX_1_1);
        FloatTimeSeries timeSeries = timeSeriesByFsId.get(fsId);
        if (timeSeries != null) {
            setGapIndicators(timeSeries.getGapIndicators());
            setCovarianceMatrix11(timeSeries.fseries());
        }
    }

    private void setCovarianceMatrix22(
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FsId fsId = PpaFsIdFactory.getTimeSeriesFsId(TimeSeriesType.COVARIANCE_MATRIX_2_2);
        FloatTimeSeries timeSeries = timeSeriesByFsId.get(fsId);
        if (timeSeries != null) {
            setGapIndicators(timeSeries.getGapIndicators());
            setCovarianceMatrix22(timeSeries.fseries());
        }
    }

    private void setCovarianceMatrix33(
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FsId fsId = PpaFsIdFactory.getTimeSeriesFsId(TimeSeriesType.COVARIANCE_MATRIX_3_3);
        FloatTimeSeries timeSeries = timeSeriesByFsId.get(fsId);
        if (timeSeries != null) {
            setGapIndicators(timeSeries.getGapIndicators());
            setCovarianceMatrix33(timeSeries.fseries());
        }
    }

    private void setCovarianceMatrix12(
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FsId fsId = PpaFsIdFactory.getTimeSeriesFsId(TimeSeriesType.COVARIANCE_MATRIX_1_2);
        FloatTimeSeries timeSeries = timeSeriesByFsId.get(fsId);
        if (timeSeries != null) {
            setGapIndicators(timeSeries.getGapIndicators());
            setCovarianceMatrix12(timeSeries.fseries());
        }
    }

    private void setCovarianceMatrix13(
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FsId fsId = PpaFsIdFactory.getTimeSeriesFsId(TimeSeriesType.COVARIANCE_MATRIX_1_3);
        FloatTimeSeries timeSeries = timeSeriesByFsId.get(fsId);
        if (timeSeries != null) {
            setGapIndicators(timeSeries.getGapIndicators());
            setCovarianceMatrix13(timeSeries.fseries());
        }
    }

    private void setCovarianceMatrix23(
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FsId fsId = PpaFsIdFactory.getTimeSeriesFsId(TimeSeriesType.COVARIANCE_MATRIX_2_3);
        FloatTimeSeries timeSeries = timeSeriesByFsId.get(fsId);
        if (timeSeries != null) {
            setGapIndicators(timeSeries.getGapIndicators());
            setCovarianceMatrix23(timeSeries.fseries());
        }
    }

    public boolean[] getGapIndicators() {
        return gapIndicators;
    }

    public void setGapIndicators(boolean[] gapIndicators) {
        this.gapIndicators = gapIndicators;
    }

}
