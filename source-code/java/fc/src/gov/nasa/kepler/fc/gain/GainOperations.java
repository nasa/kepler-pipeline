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

package gov.nasa.kepler.fc.gain;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.FcModelFactory;
import gov.nasa.kepler.fc.FcUtilities;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.Gain;
import gov.nasa.kepler.hibernate.fc.GainHistoryModel;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The GainOperations class handles the JDO operations for the Gain class.
 * 
 * @author kester
 * 
 */
public class GainOperations {
    private static HistoryModelName HISTORY_NAME = HistoryModelName.GAIN;
    private static final Log log = LogFactory.getLog(GainOperations.class);

    private DatabaseService dbService;
    private FcCrud fcCrud;
    private History history;

    public GainOperations() {
        this(DatabaseServiceFactory.getInstance());
    }

    public GainOperations(DatabaseService databaseService)
        {
        this.dbService = databaseService;
        fcCrud = new FcCrud(dbService);
        history = null;
    }
    
    
    public GainOperations(History history) {
        this(DatabaseServiceFactory.getInstance(), history);
    }
    
    public GainOperations(DatabaseService dbService, History history) {
        this.history = history;
        fcCrud = new FcCrud(dbService);
        fcCrud.create(history);
    }

//    /**
//     * Constructor to get models that were valid at the time specified by
//     * history.
//     */
//    public GainOperations(double historyMjd) {
//        this.dbService = DatabaseServiceFactory.getInstance();
//        fcCrud = new FcCrud(dbService);
//        history = new History(historyMjd, HISTORY_NAME);
//    }

    /**
     * 
     * @param gain The Gain object to persist.
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public void persistGain(Gain gain) throws
        PipelineException {
        if (log.isDebugEnabled()) {
            log.debug("persistGain(Gain) - start");
        }
        if (!FcUtilities.isAllowedModule(gain.getCcdModule())
            || !FcUtilities.isAllowedOutput(gain.getCcdOutput())) {
            throw new FocalPlaneException(
                "The inputs module or output are out of range.");
        }

//        gain.setHistory(getHistory());
        fcCrud.create(gain);

        if (log.isDebugEnabled()) {
            log.debug("persistGain(Gain) - end");
        }
    }

    /**
     * 
     * @param module The module to persist a gain value for.
     * @param output The output to persist a gain value for.
     * @param gain The gain value to persist.
     * @param start The start time of the gain value.
     * @param stop The stop time of the gain value.
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public void persistGain(int module, int output, double gain, double mjd)
        {
        if (log.isDebugEnabled()) {
            log.debug("persistGain(int, int, double, Date, Date) - start");
        }
        if (!FcUtilities.isAllowedModule(module)
            || !FcUtilities.isAllowedOutput(output)) {
            throw new FocalPlaneException(
                "The inputs module or output are out of range.");
        }

        persistGain(new Gain(module, output, gain, mjd));

        if (log.isDebugEnabled()) {
            log.debug("persistGain(int, int, double, Date, Date) - end");
        }

    }

    /**
     * Retrieves the gain information valid for the start Date of the input gain
     * object.
     * 
     * @param gain The input gain object. The start Date is used for the JDO
     * lookup.
     * @return A Gain object with the valid gain.
     * @throws FocalPlaneException
     * @throws PipelineException 
     */
    public Gain retrieveGain(Gain gain) {
        if (log.isDebugEnabled()) {
            log.debug("retreiveGain(Gain) - start");
        }

        Gain outGt = fcCrud.retrieve(gain, getHistory());
        if (null == outGt) {
            throw new FocalPlaneException(
                "no gain returned in GainOperations.retreiveGain");
        }

        if (log.isDebugEnabled()) {
            log.debug("retreiveGain(Gain) - end");
        }
        return outGt;
    }

    public Gain retrieveGainExact(Gain gain) {
        return fcCrud.retrieveGainExact(gain, getHistory());
    }

    /**
     * Retreives the gain value for a given module/output for a given MJD
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param mjd
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException 
     */
    public double retrieveGainValue(int ccdModule, int ccdOutput, double mjd)
        {
        return retrieveGain(ccdModule, ccdOutput, mjd).getGain();
    }

    public Gain retrieveGain(int ccdModule, int ccdOutput, double mjd)
        {
    	List<GainHistoryModel> historyModels = fcCrud.retrieveGainHistoryModels(getHistory());
    	
        Gain gain = null;
        for (GainHistoryModel historyModel : historyModels) {
        	Gain loopGain = historyModel.getGain();
        	boolean isModOutMatch = loopGain.getCcdModule() == ccdModule && loopGain.getCcdOutput() == ccdOutput;
        	boolean isTimeMatch = loopGain.getMjd() <= mjd && (gain == null || loopGain.getMjd() > gain.getMjd());
        	if (isModOutMatch && isTimeMatch) {
        		gain = loopGain;
        	}
        }
        return gain;
    }

//    public double[] retrieveGains(int ccdModule, int ccdOutput,
//        float[] timeInDaysSinceEpoch) {
//        double[] gainValues = new double[timeInDaysSinceEpoch.length];
//        int ii = 0;
//        for (float daysSinceEpoch : timeInDaysSinceEpoch) {
//            Gain gain = new Gain(ccdModule, ccdOutput);
//            GregorianCalendar day = (GregorianCalendar) FcConstants.KEPLER_SCLK_EPOCH.clone();
//            day.add(Calendar.DATE, (int) daysSinceEpoch);
//
//            double daysOffset = (day.getTimeInMillis() - FcConstants.KEPLER_SCLK_EPOCH.getTimeInMillis()) / 86400.0 / 1000.0;
//            gain.setMjd(daysOffset);
//            gainValues[ii++] = retrieveGain(gain).getGain();
//        }
//        return gainValues;
//    }

//    /**
//     * 
//     * Return the Gain models that correspond to the input array of specified
//     * MJD times. The GainModel will contain one models for each MJD specified.
//     * 
//     * @param mjds
//     * @return
//     * @throws FocalPlaneException 
//     * @throws PipelineException 
//     */
//    public GainModel retrieveGainModel(double[] mjds) {
//        double[] gainMjds = new double[mjds.length];
//        double[][] constants = new double[mjds.length][84];
//
//        for (int module : FcConstants.modulesList) {
//            for (int output : FcConstants.outputsList) {
//
//                for (int iTime = 0; iTime < mjds.length; ++iTime) {
//                    double mjd = mjds[iTime];
//                    Gain gain = fcCrud.retrieveGain(module, output, mjd,
//                        getHistory());
//                    if (gain == null) {
//    					throw new FocalPlaneException(
//    							"No Gain objects retrieved from database for module "
//    									+ module
//    									+ " output "
//    									+ output
//    									+ " for date " + mjd);
//    				}
//                    gainMjds[iTime] = gain.getMjd();
//
//                    int channel = FcConstants.getChannelNumber(module, output);
//                    constants[iTime][channel - 1] = gain.getGain();
//                }
//
//            }
//        }
//
//        GainModel gainModel = new GainModel(gainMjds, constants);
//        return gainModel;
//    }

    /**
     * 
     * Return the unique Gain models that are valid for the range of specified
     * MJD times. The GainModel will contain only the distinct models that are
     * valid for that time range, without duplicates.
     * 
     * @param mjdStart
     * @param mjdEnd
     * @return
     * @throws FocalPlaneException 
     * @throws PipelineException 
     */
    public GainModel retrieveGainModel(double mjdStart, double mjdEnd) {
        // A list of the gains for each module/output for this time range:
        //
        List<Gain[]> gainsList = new ArrayList<Gain[]>();
        
        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                List<Gain> gains = fcCrud.retrieveGainsBetween(module, output, mjdStart, mjdEnd, getHistory());
                
                if (gains.size() == 0) {
					throw new FocalPlaneException(
							"No Gain objects retrieved from database for module "
									+ module + " output " + output
									+ " for time range " + mjdStart + " to "
									+ mjdEnd);
				}
                
                Gain[] gainsArr = new Gain[gains.size()];
                int ii = 0;
                for (Gain gain : gains) {
                	gainsArr[ii] = gain;
                	ii++;
                }
                gainsList.add(gainsArr);
            }
        }
        
        double[] uniqueSortedMjds = getUniqueSortedMjdsFromGainsList(gainsList);
        double[][] constants = populateTimeGridOfGains(uniqueSortedMjds, gainsList);

        return FcModelFactory.gainModel(uniqueSortedMjds, constants);
    }
    
    public GainModel retrieveMostRecentGainModel() {
        double now = ModifiedJulianDate.dateToMjd(new Date());

        // A list of the gains for each module/output:
        //
        List<Gain[]> gainsList = new ArrayList<Gain[]>();
 
        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                Gain gain = fcCrud.retrieveGain(module, output, now, getHistory());
                gainsList.add(new Gain[] {gain});
            }
        }
        
        double[] uniqueSortedMjds = getUniqueSortedMjdsFromGainsList(gainsList);
        double[][] constants = populateTimeGridOfGains(uniqueSortedMjds, gainsList);
        
        return FcModelFactory.gainModel(uniqueSortedMjds, constants);

    }

    public GainModel retrieveGainModelAll() {
        // A list of the gains for each module/output:
        //
        List<Gain[]> gainsList = new ArrayList<Gain[]>();

        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                List<Gain> gains = fcCrud.retrieveAllGains(module, output, getHistory());
                if (gains.size() == 0) {
                    throw new FocalPlaneException(
                        "No Gain objects retrieved from database for module "
                            + module
                            + " output "
                            + output
                            + " for entire time range (the DB is empty of Gain)");
                }
                
                Gain[] gainsArr = new Gain[gains.size()];
                int ii = 0;
                for (Gain gain : gains) {
                	gainsArr[ii] = gain;
                	ii++;
                }
                gainsList.add(gainsArr);
            }
        }

        double[] uniqueSortedMjds = getUniqueSortedMjdsFromGainsList(gainsList);
        double[][] constants = populateTimeGridOfGains(uniqueSortedMjds,
            gainsList);

        return FcModelFactory.gainModel(uniqueSortedMjds, constants);
    }

    private double[] getUniqueSortedMjdsFromGainsList(List<Gain[]> gainsList) {
        // Get a sorted array of all unique MJDs
        HashSet<Double> uniqueMjds = new HashSet<Double>();
        for (Gain[] gains : gainsList) {
            for (Gain gain : gains) {
                uniqueMjds.add(gain.getMjd());
            }
        }
        double[] mjdsArr = new double[uniqueMjds.size()];
        int ii = 0;
        for (Double mjd : uniqueMjds) {
            mjdsArr[ii] = mjd;
            ++ii;
        }
        Arrays.sort(mjdsArr);

        return mjdsArr;
    }
    
    private double[][] populateTimeGridOfGains(double[] uniqueSortedMjds, List<Gain[]> gainsList) {
        int numChannels = FcConstants.nModules * FcConstants.nOutputsPerModule;

        double[][] constants = new double[uniqueSortedMjds.length][numChannels];

        for (int ichan = 0; ichan < numChannels; ++ichan) {
            Gain[] gainsForChannel = gainsList.get(ichan);
            
            for (int itime = 0; itime < uniqueSortedMjds.length; ++itime) {
                
                double mjdForElement = uniqueSortedMjds[itime];
                double gainVal  = -1.0;
                Gain firstGain = gainsForChannel[0];
                Gain lastGain = gainsForChannel[gainsForChannel.length - 1];
                
                
                if (firstGain.getMjd() >= mjdForElement) {
                    // Earliest gain for this channel is later than mjdForElement,
                    // use the earliest gain's value
                    //
                    gainVal = firstGain.getGain();
                } else if (lastGain.getMjd() <=  mjdForElement) {
                    // Last gain for this channel is earlier than mjdForElement,
                    // use the last gain's value:
                    //
                    gainVal = lastGain.getGain();
                } else {
                    // mjdForElement is between firstGain and lastGain, find the
                    // right gain and use its value:
                    //
                    for (Gain gain : gainsForChannel) {
                        if (mjdForElement >= gain.getMjd()) {
                            gainVal = gain.getGain();
                        }
                    }
                }
                
                constants[itime][ichan] = gainVal;
            }
        }
        
        return constants;
    }
    
    public History getHistory() {
        if (history == null) {
            history = fcCrud.retrieveHistory(HISTORY_NAME);
        }
        
        if (history == null) {
            Date now = new Date();
            double mjdNow = ModifiedJulianDate.dateToMjd(now);
            history = new History(
                mjdNow,
                HistoryModelName.GAIN,
                "created by GainOperations because the history table was empty",
                1);
            fcCrud.create(history);
        }
        
        return history;
    }

    public void setHistory(History history) {
        this.history = history;
    }

}
