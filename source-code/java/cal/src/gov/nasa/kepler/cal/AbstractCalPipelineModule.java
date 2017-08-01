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

package gov.nasa.kepler.cal;

import gov.nasa.kepler.cal.io.HuffmanTable;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.UndershootModel;
import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.linearity.LinearityOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.fc.undershoot.UndershootOperations;
import gov.nasa.kepler.hibernate.cal.CalCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Base class for cal pipeline modules.
 * 
 * @author Sean McCauliff
 * 
 */
public abstract class AbstractCalPipelineModule extends
    MatlabPipelineModule {

    @SuppressWarnings("unused")
    private final Log log = LogFactory.getLog(AbstractCalPipelineModule.class);

    private ConfigMapOperations configMapOps;
    //private CompressionCrud compressionCrud;
    private CalCrud calCrud;
    private DataAccountabilityTrailCrud daCrud;
    private FlatFieldOperations flatFieldOperations;
    private GainOperations gainOperations;
    private ReadNoiseOperations readNoiseOperations;
    private TwoDBlackOperations twoDBlackOperations;
    private UndershootOperations undershootOperations;
    private LinearityOperations linearityOperations;
    private BlobOperations blobOps;
    private LogCrud logCrud;

    protected GainModel gainModel;
    protected FlatFieldModel flatFieldModel;
    protected LinearityModel linearityModel;
    protected ReadNoiseModel readNoiseModel;
    protected TwoDBlackModel twoDBlackModel;
    protected UndershootModel undershootModel;

    protected Set<Long> producerTaskIds = new HashSet<Long>();


    public AbstractCalPipelineModule() {
        super();
    }

    protected ReadNoiseOperations getReadNoiseOperations() {
        if (readNoiseOperations == null) {
            readNoiseOperations = new ReadNoiseOperations();
        }
        return readNoiseOperations;
    }

    protected UndershootOperations getUndershootOperations() {
        if (undershootOperations == null) {
            undershootOperations = new UndershootOperations();
        }
        return undershootOperations;
    }

    protected LinearityOperations getLinearityOperations() {
        if (linearityOperations == null) {
            linearityOperations = new LinearityOperations();
        }
        return linearityOperations;
    }

    protected TwoDBlackOperations getTwoDBlackOperations() {
        if (twoDBlackOperations == null) {
            twoDBlackOperations = new TwoDBlackOperations();
        }
        return twoDBlackOperations;
    }

    protected FlatFieldOperations getFlatFieldOperations() {
        if (flatFieldOperations == null) {
            flatFieldOperations = new FlatFieldOperations();
        }
        return flatFieldOperations;
    }

    protected GainOperations getGainOperations() {
        if (gainOperations == null) {
            gainOperations = new GainOperations();
        }
        return gainOperations;
    }
    
    protected BlobFileSeries retrieveDynamicTwo2Black(CadenceType cadenceType,
        int startCadence, int endCadence, int ccdModule, int ccdOutput, 
        File workingDirectory) {

        Pair<Integer, Integer> startEndCadence = null;
        switch (cadenceType) {
            case LONG: startEndCadence = Pair.of(startCadence, endCadence); break;
            case SHORT:startEndCadence = getLogCrud().shortCadenceToLongCadence(startCadence, endCadence); break;
            default:
                throw new IllegalStateException("Unhandled case.");
        }
        BlobSeries<String> dynamic2DBlackBlobs = 
            getBlobOps(workingDirectory).retrieveDynamicTwoDBlackBlobFileSeries(
                ccdModule, ccdOutput, startEndCadence.left, startEndCadence.right);
        return new BlobFileSeries(dynamic2DBlackBlobs);
    }

    protected BlobOperations getBlobOps(File workingDirectory) {
        if (blobOps == null) {
            blobOps = new BlobOperations(workingDirectory);
        }
        return blobOps;
    }
    
    void setBlobOps(BlobOperations blobOps) {
        this.blobOps = blobOps;
    }
    
    protected DataAccountabilityTrailCrud getDaCrud() {
        if (daCrud == null) {
            daCrud = new DataAccountabilityTrailCrud();
        }
        return daCrud;
    }

  

    /**
     * Sets this module's data accountability trail CRUD. This method isn't used
     * by the module interface, but by tests.
     * 
     * @param daCrud the data accountability trail CRUD.
     */
    protected void setDaCrud(DataAccountabilityTrailCrud daCrud) {
        this.daCrud = daCrud;
    }

    /**
     * Sets this module's file store client. This method isn't used by the
     * module interface, but by tests.
     * 
     * @param flatFieldOperations the flat field operations.
     */
    protected void setFlatFieldOperations(
        FlatFieldOperations flatFieldOperations) {
        this.flatFieldOperations = flatFieldOperations;
    }

    /**
     * Sets this module's file store client. This method isn't used by the
     * module interface, but by tests.
     * 
     * @param gainOperations the gain operations.
     */
    protected void setGainOperations(GainOperations gainOperations) {
        this.gainOperations = gainOperations;
    }

    /**
     * Sets this module's linearity table operations. This method isn't used by
     * the module interface, but by tests.
     * 
     * @param linearityOperations the linearity table operations.
     */
    protected void setLinearityOperations(
        LinearityOperations linearityOperations) {

        this.linearityOperations = linearityOperations;
    }

    /**
     * Sets this module's read noise operations. This method isn't used by the
     * module interface, but by tests.
     * 
     * @param readNoiseOperations the read noise operations.
     */
    protected void setReadNoiseOperations(
        ReadNoiseOperations readNoiseOperations) {
        this.readNoiseOperations = readNoiseOperations;
    }

    /**
     * Sets this module's 2D black operations. This method isn't used by the
     * module interface, but by tests.
     * 
     * @param twoDBlackOperations the 2D black operations.
     */
    protected void setTwoDBlackOperations(
        TwoDBlackOperations twoDBlackOperations) {
        this.twoDBlackOperations = twoDBlackOperations;
    }

    /**
     * Sets this module's UndershootOperations. This method isn't used by the
     * module interface, but by tests.
     * 
     * @param undershootOperations the UndershootOperations.
     */
    protected void setUndershootOperations(
        UndershootOperations undershootOperations) {
        this.undershootOperations = undershootOperations;
    }

    protected void setCalCrud(CalCrud calCrud) {
        this.calCrud = calCrud;
    }

    protected CalCrud getCalCrud() {
        if (calCrud == null) {
            calCrud = new CalCrud(DatabaseServiceFactory.getInstance());
        }
        return calCrud;
    }

    protected void setConfigMapOps(ConfigMapOperations ops) {
        configMapOps = ops;
    }

    protected ConfigMapOperations getConfigMapOperations() {
        if (configMapOps == null) {
            configMapOps = new ConfigMapOperations();
        }
        return configMapOps;
    }


    
    protected LogCrud getLogCrud() {
        if (logCrud == null) {
            logCrud = new LogCrud();
        }
        return logCrud;
    }
    
    void setLogCrud(LogCrud logCrud) {
        this.logCrud = logCrud;
    }

}