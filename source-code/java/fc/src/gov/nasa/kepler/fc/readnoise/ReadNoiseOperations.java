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

package gov.nasa.kepler.fc.readnoise;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.FcModelFactory;
import gov.nasa.kepler.fc.FcUtilities;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.ReadNoise;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The ReadNoiseOperations class handles the database operations for the
 * ReadNoise class.
 * 
 * @author kester
 * 
 */
public class ReadNoiseOperations {
    private static HistoryModelName HISTORY_NAME = HistoryModelName.READNOISE;
    private static final Log log = LogFactory.getLog(ReadNoiseOperations.class);

    public static String NO_READ_FOUND_TEXT = "no readNoise returned in ReadNoiseOperations.retreiveReadNoise";

    private DatabaseService dbService;
    private FcCrud fcCrud;
    private History history;

    public ReadNoiseOperations() {
        this(DatabaseServiceFactory.getInstance());
    }

    public ReadNoiseOperations(DatabaseService databaseService) {
        this.dbService = databaseService;
        fcCrud = new FcCrud(dbService);
        history = null;
    }

    /**
     * Constructor to get models that were valid at the time specified by
     * history.
     */
    public ReadNoiseOperations(double historyMjd) {
        this.dbService = DatabaseServiceFactory.getInstance();
        fcCrud = new FcCrud(dbService);
    }
//
//    public ReadNoiseOperations(History history) {
//        this(DatabaseServiceFactory.getInstance(), history);
//    }
//    
//    public ReadNoiseOperations(DatabaseService dbService, History history) {
//        this.history = history;
//        fcCrud = new FcCrud(dbService);
//        fcCrud.create(history);
//    }
    
    /**
     * 
     * @param readNoise The ReadNoise object to persist.
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public void persistReadNoise(ReadNoise readNoise)
        {
        if (log.isDebugEnabled()) {
            log.debug("persistReadNoise(ReadNoise) - start");
        }
        if (!FcUtilities.isAllowedModule(readNoise.getCcdModule())
            || !FcUtilities.isAllowedOutput(readNoise.getCcdOutput())) {
            throw new FocalPlaneException(
                "The inputs module or output are out of range.");
        }

        fcCrud.create(readNoise);

        if (log.isDebugEnabled()) {
            log.debug("persistReadNoise(ReadNoise) - end");
        }
    }

    /**
     * 
     * @param module The module to persist a readNoise value for.
     * @param output The output to persist a readNoise value for.
     * @param readNoise The readNoise value to persist.
     * @param start The start time of the readNoise value.
     * @param stop The stop time of the readNoise value.
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public void persistReadNoise(int module, int output, double readNoise,
        double mjd) {
        if (log.isDebugEnabled()) {
            log.debug("persistReadNoise(int, int, double, Date, Date) - start");
        }
        if (!FcUtilities.isAllowedModule(module)
            || !FcUtilities.isAllowedOutput(output)) {
            throw new FocalPlaneException(
                "The inputs module or output are out of range.");
        }

        persistReadNoise(new ReadNoise(mjd, module, output, readNoise));

        if (log.isDebugEnabled()) {
            log.debug("persistReadNoise(int, int, double, Date, Date) - end");
        }

    }

    /**
     * Retrieves the readNoise information valid for the start Date of the input
     * readNoise object.
     * 
     * @param readNoise The input readNoise object. The start Date is used for
     * the JDO lookup.
     * @return A ReadNoise object with the valid readNoise.
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public ReadNoise retrieveReadNoise(ReadNoise readNoise)
        {
        if (log.isDebugEnabled()) {
            log.debug("retreiveReadNoise(ReadNoise) - start");
        }

        ReadNoise outGt = fcCrud.retrieve(readNoise, getHistory());
        if (null == outGt) {
            throw new FocalPlaneException(
                "no readNoise returned in ReadNoiseOperations.retreiveReadNoise");
        }

        if (log.isDebugEnabled()) {
            log.debug("retreiveReadNoise(ReadNoise) - end");
        }
        return outGt;
    }

    /**
     * Retrieves the readNoise information valid for the start Date of the input
     * readNoise object.
     * 
     * @param readNoise The input readNoise object. The start Date is used for
     * the JDO lookup.
     * @return A ReadNoise object with the valid readNoise.
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public ReadNoise retrieveReadNoiseExact(ReadNoise readNoise)
        {
        if (log.isDebugEnabled()) {
            log.debug("retreiveReadNoise(ReadNoise) - start");
        }

        ReadNoise result = fcCrud.retrieveReadNoiseExact(readNoise, getHistory());
        if (log.isDebugEnabled()) {
            log.debug("retreiveReadNoise(ReadNoise) - end");
        }
        return result;
    }

    /**
     * Retreives the readNoise value for a given module/output for a given
     * julian date.
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param julianDate
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public double retrieveReadNoise(int ccdModule, int ccdOutput,
        double julianDate) {
        if (log.isDebugEnabled()) {
            log.debug("retreiveReadNoise(ccdModule, ccdOutput, julianDate) - start");
        }

        double mjd = julianDate - ModifiedJulianDate.MJD_OFFSET_FROM_JD;
        ReadNoise readNoise = fcCrud.retrieve(new ReadNoise(mjd, ccdModule,
            ccdOutput, 0.0), getHistory());

        if (log.isDebugEnabled()) {
            log.debug("retreiveReadNoise(ccdModule, ccdOutput, julianDate) - end");
        }
        return readNoise.getReadNoise();
    }

    public double[] retrieveReadNoises(int ccdModule, int ccdOutput,
        float[] timeInDaysSinceEpoch) throws
        PipelineException {
        double[] readNoiseValues = new double[timeInDaysSinceEpoch.length];
        int ii = 0;
        for (float daysSinceEpoch : timeInDaysSinceEpoch) {

            GregorianCalendar day = (GregorianCalendar) FcConstants.KEPLER_SCLK_EPOCH.clone();
            day.add(Calendar.DATE, (int) daysSinceEpoch);

            double daysOffset = (day.getTimeInMillis() - FcConstants.KEPLER_SCLK_EPOCH.getTimeInMillis()) / 86400.0 / 1000.0;
            ReadNoise readNoise = new ReadNoise(daysOffset, ccdModule,
                ccdOutput, 0.0);
            readNoiseValues[ii++] = retrieveReadNoise(readNoise).getReadNoise();
        }
        return readNoiseValues;
    }

//    /**
//     * 
//     * Return the ReadNoise models that correspond to the input array of
//     * specified MJD times. The ReadNoiseModel will contain one models for each
//     * MJD specified.
//     * 
//     * @param mjds
//     * @return
//     * @throws FocalPlaneException 
//     * @throws PipelineException
//     */
//    public ReadNoiseModel retrieveReadNoiseModel(double[] mjds)
//        {
//        double[] readNoiseMjds = new double[mjds.length];
//        double[][] constants = new double[mjds.length][84];
//
//        for (int module : FcConstants.modulesList) {
//            for (int output : FcConstants.outputsList) {
//
//                for (int iTime = 0; iTime < mjds.length; ++iTime) {
//                    double mjd = mjds[iTime];
//                    ReadNoise readNoise = fcCrud.retrieveReadNoise(mjd, module,
//                        output, getHistory());
//                    
//                    if (readNoise != null) {
//                        throw new FocalPlaneException("no ReadNoise for MJD "
//                            + mjd + " for module " + module + " output "
//                            + output);
//                    }
//                    readNoiseMjds[iTime] = readNoise.getMjd();
//
//                    int channel = FcConstants.getChannelNumber(module, output);
//                    constants[iTime][channel - 1] = readNoise.getReadNoise();
//                }
//
//            }
//        }
//
//        ReadNoiseModel readNoiseModel = new ReadNoiseModel(readNoiseMjds,
//            constants);
//        return readNoiseModel;
//    }

    /**
     * 
     * Return the unique ReadNoise models that are valid for the range of
     * specified MJD times. The ReadNoiseModel will contain only the distinct
     * models that are valid for that time range, without duplicates.
     * 
     * @param mjdStart
     * @param mjdEnd
     * @return
     * @throws PipelineException
     */
    public ReadNoiseModel retrieveReadNoiseModel(double mjdStart, double mjdEnd) {

        int tmpMod = 2;
        int tmpOut = 1;
        ReadNoise[] readNoisesTmp = fcCrud.retrieveReadNoisesBetween(tmpMod, tmpOut, mjdStart, mjdEnd, getHistory());
        int nReadNoises = readNoisesTmp.length;

        double[] mjds = new double[nReadNoises];
        double[][] constants = new double[nReadNoises][FcConstants.nModules * FcConstants.nOutputsPerModule];

    	for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                int channel = FcConstants.getChannelNumber(module, output);
                
                // Get bracketing ReadNoises
                //
                ReadNoise[] readNoises = fcCrud.retrieveReadNoisesBetween(module, output, mjdStart, mjdEnd, getHistory());
                
                for (int iTime = 0; iTime < readNoises.length; ++iTime) {
                    mjds[iTime]                   = readNoises[iTime].getMjd();
                    constants[iTime][channel - 1] = readNoises[iTime].getReadNoise();
                }

            }
        }
        return FcModelFactory.readNoiseModel(mjds, constants);
    }
    
    public ReadNoiseModel retrieveMostRecentReadNoiseModel() {
        double now = ModifiedJulianDate.dateToMjd(new Date());

        // Single element arrays to match readNoiseModel constructor args:
        //
        double[] mjds = new double[1];
        double[][] constants = new double[1][84];

        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                int channel = FcConstants.getChannelNumber(module, output);

                ReadNoise readNoise = fcCrud.retrieveReadNoise(now, module, output, getHistory());
                mjds[0] = readNoise.getMjd();
                constants[0][channel - 1] = readNoise.getReadNoise();
            }
        }
        return FcModelFactory.readNoiseModel(mjds, constants);
    }


    public ReadNoiseModel retrieveReadNoiseModelAll() {
        int numChannels = FcConstants.nModules * FcConstants.nOutputsPerModule;
        
        ReadNoise[] readNoisesTmp = fcCrud.retrieveAllReadNoises(2, 1, getHistory());
        double[] mjds        = new double[readNoisesTmp.length];
        double[][] constants = new double[readNoisesTmp.length][numChannels];

        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                int channel = FcConstants.getChannelNumber(module, output);
                
                ReadNoise[] readNoisesNew = fcCrud.retrieveAllReadNoises(module, output, getHistory());

                for (int iTime = 0; iTime < readNoisesNew.length; ++iTime) {
                    mjds[iTime] = readNoisesNew[iTime].getMjd();
                    constants[iTime][channel - 1] = readNoisesNew[iTime].getReadNoise();
                }
                
            }
        }
        return FcModelFactory.readNoiseModel(mjds, constants);
    }

    public History getHistory() {
        if (history == null) {
            history = fcCrud.retrieveHistory(HISTORY_NAME);
        }
        
        if (history == null) {
            Date now = new Date();
            double mjdNow = ModifiedJulianDate.dateToMjd(now);
            history = new History(mjdNow, HISTORY_NAME,
                "creating history in ReadNoiseOperations.getHistory()", 1);
                
            fcCrud.create(history);

        }
        return history;
    }

    public void setHistory(History history) {
        this.history = history;
    }

}
