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

package gov.nasa.kepler.fc.importer;

import static gov.nasa.kepler.fc.importer.ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Utility class for reading image information from files for
 * ImporterSmallFlatField and ImporterTwoDBlack.
 * 
 * @author kester
 * 
 */
public abstract class ImporterParentImage {
    protected static final Log log = LogFactory.getLog(ImporterParentImage.class);

    public static final String DATA = "data";
    public static final String UNCERTAINTY = "uncertainty";

    public static final String USAGE = "Usage: "
        + "'importer operation reason' \n"
        + "'importer operation directory reason' \n"
        + "'importer operation mod out reason' \n"
        + "'importer operation mod out directory reason' \n"
        + " where operation is either 'appendNew', 'insertBetween', or 'rewriteHistory'";

    /**
     * Import the data files that match the data regexp. Data files are read
     * from dataDirectory, and only the data files that are for module
     * ccdModule, output ccdOutput are used.
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param dataDirectory
     * @param reason
     * @throws IOException
     * @throws FocalPlaneException
     */
    protected abstract void appendNew(int ccdModule, int ccdOutput,
        String dataDirectory, String reason, Date date) throws IOException,
        FocalPlaneException;

    /**
     * Import the data files that match the data regexp. Data files are read
     * from the default data directory, as defined by kepler.properties. Only
     * the data files that are for module ccdModule, output ccdOutput are used.
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param reason
     * @throws IOException
     * @throws FocalPlaneException
     */
    protected abstract void appendNew(int ccdModule, int ccdOutput, String reason, Date date)
        throws IOException;

    /**
     * Import the data files that match the data regexp. Data files are read
     * from the data directory dataDirectory. ALL module/outputs that have data
     * files present are imported.
     * 
     * @param dataDirectory
     * @param reason
     * @throws IOException
     * @throws FocalPlaneException
     */
    protected abstract void appendNew(String dataDirectory, String reason, Date date)
        throws IOException;

    /**
     * Import the data files that match the data regexp. Data files are read
     * from the default data directory, as defined by kepler.properties. ALL
     * module/outputs that have data files present are imported.
     * 
     * @param reason
     * @throws IOException
     * @throws FocalPlaneException
     */
    protected abstract void appendNew(String reason, Date date) throws IOException,
        FocalPlaneException;

    public abstract void insertBetween(int ccdModule, int ccdOutput,
        String dataDirectory, String reason) throws IOException,
        FocalPlaneException;

    public abstract void insertBetween(int ccdModule, int ccdOutput,
        String reason) throws IOException;

    public abstract void insertBetween(String dataDirectory, String reason)
        throws IOException;

    public abstract void insertBetween(String reason) throws IOException,
        FocalPlaneException;

    /**
     * Extract the date from a seed data:
     * 
     * @param dataFilename
     * @return
     * @throws IOException
     */
    public double getMjdFromFile(String dataFilename) throws IOException {
        BufferedReader buf = new BufferedReader(new FileReader(dataFilename));
        String line = new String();

        // Date (MJD) is first line
        line = buf.readLine();
        double mjd = Double.parseDouble(line);
        buf.close();

        return mjd;
    }

    public Pair<Integer, Integer> getModuleOutputNumberFromFile(
        String dataFilename) throws IOException {
        BufferedReader buf = new BufferedReader(new FileReader(dataFilename));
        String line = new String();

        // Date (MJD) is first line; ignore it here:
        line = buf.readLine();
        @SuppressWarnings("unused")
        double mjd = Double.parseDouble(line);

        // Module is second line
        line = buf.readLine();
        int module = Integer.parseInt(line);

        // Output is third line
        line = buf.readLine();
        int output = Integer.parseInt(line);

        buf.close();

        Pair<Integer, Integer> moduleOutput = Pair.of(module, output);
        return moduleOutput;
    }

    /**
     * 
     * Get the pixel data out of the file:
     * 
     * @param dataFilename
     * @param date
     * @return
     * @throws IOException
     */
    public Map<String, float[][]> getDataAndUncertaintyFromFile(
        String dataFilename) throws IOException {
        BufferedReader buf = new BufferedReader(new FileReader(dataFilename));
        String line = new String();

        // Date (MJD) is first line; ignore it here:
        line = buf.readLine();
        @SuppressWarnings("unused")
        double mjd = Double.parseDouble(line);

        // Module is second line
        line = buf.readLine();
        @SuppressWarnings("unused")
        int module = Integer.parseInt(line);

        // Output is third line
        line = buf.readLine();
        @SuppressWarnings("unused")
        int output = Integer.parseInt(line);

        int numPix = FcConstants.CCD_ROWS * FcConstants.CCD_COLUMNS;
        float[][] dataVals = new float[FcConstants.CCD_ROWS][FcConstants.CCD_COLUMNS];
        float[][] uncertaintyVals = new float[FcConstants.CCD_ROWS][FcConstants.CCD_COLUMNS];

        // Load data: the first numPix is data, the second numPix is
        // uncertainty..
        //
        int ii = 0;
        int irow = 0;
        int icol = 0;
        float sumData = 0.0f;
        float sumUncert = 0.0f;
        boolean isFirstUncert = true;

        while (null != (line = buf.readLine())) {

            float val = Float.parseFloat(line);

            if (ii < numPix) {
                sumData += val;
                dataVals[irow][icol] = val;

                // // Check for illegal zeros:
                // //
                // if (val == 0) {
                // throw new IOException("illegal zero value at row " + ii +
                // " of " + dataFilename);
                // }
                ++icol;
                if (icol >= FcConstants.CCD_COLUMNS) {
                    ++irow;
                    icol = 0;
                }
            } else {
                if (isFirstUncert) {
                    isFirstUncert = false;
                    irow = 0;
                    icol = 0;
                }

                sumUncert += val;
                uncertaintyVals[irow][icol] = val;
                ++icol;
                if (icol >= FcConstants.CCD_COLUMNS) {
                    ++irow;
                    icol = 0;
                }
            }
            ++ii;
        }

        buf.close();

        Map<String, float[][]> dataAndUncertainty = new HashMap<String, float[][]>();
        dataAndUncertainty.put(DATA, dataVals);
        dataAndUncertainty.put(UNCERTAINTY, uncertaintyVals);
        log.debug("mean data = " + sumData / numPix);
        log.debug("mean uncertainty = " + sumUncert / numPix);

        return dataAndUncertainty;
    }

    /**
     * Extract the data directory's name from kepler.properties
     * 
     * @param typeName
     * @return
     */
    public String getDataDirName(String typeName) {
        String dataDirRoot = ConfigurationServiceFactory.getInstance()
            .getString(DATA_DIR_PROPERTY_PREFIX + "rootdir");
        if (dataDirRoot == null || dataDirRoot.length() == 0) {
            dataDirRoot = SocEnvVars.getLocalDataDir();
        }
        String dataTypeDir = ConfigurationServiceFactory.getInstance()
            .getString(DATA_DIR_PROPERTY_PREFIX + typeName);
        return dataDirRoot + dataTypeDir;
    }

    public static File getDataDirectory(String typeName)
        {
        return ImporterParentNonImage.getDataDirectory(typeName);
    }

    public String[] getDataFilenames(final String fileRegex, String typeName)
        {
        return ImporterParentNonImage.getDataFilenames(fileRegex, typeName);
    }

    public String[] getFilenamesFromDirectory(final String fileRegex,
        String typeName) {
        File directory = ImporterParentNonImage.getDataDirectory(typeName);
        return ImporterParentNonImage.getFilenamesFromDirectory(directory,
            fileRegex);
    }

    protected Date makeNextVersionHistory(String reason) {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the version number of the most recent history; if there isn't one, version = 1;
        //
        History history = fcCrud.retrieveHistory(getHistoryModelName());
        int version = 1;
        if (history != null) {
        	version += history.getVersion();
        }
        reason += " created by makeNextVersionHistory";
        
        Date date = new Date();
        double now = ModifiedJulianDate.dateToMjd(date);
        History newHistory = new History(now, getHistoryModelName(), reason, version);
        fcCrud.create(newHistory);
        
        return date;
    }

    protected abstract HistoryModelName getHistoryModelName();

    public void rewriteHistory(String reason) throws
        IOException {
        Date date = makeNextVersionHistory(reason);
        appendNew(reason, date);
    }

    public void rewriteHistory(String dataDirectory, String reason)
        throws IOException {
        Date date = makeNextVersionHistory(reason);
        appendNew(dataDirectory, reason, date);
    }

    public void rewriteHistory(int ccdModule, int ccdOutput, String reason)
        throws IOException {
        Date date = makeNextVersionHistory(reason);
        appendNew(ccdModule, ccdOutput, reason, date);
    }
    
    public void rewriteHistory(int[] channels, String reason)
        throws IOException {

        Date date = makeNextVersionHistory(reason);
        for (int channel : channels) {
            Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(channel);
            int ccdModule = moduleOutput.left;
            int ccdOutput = moduleOutput.right;
            appendNew(ccdModule, ccdOutput, reason, date);
        }
    }

    public void rewriteHistory(int ccdModule, int ccdOutput,
        String dataDirectory, String reason) throws IOException,
        FocalPlaneException {
        Date date = makeNextVersionHistory(reason);
        appendNew(ccdModule, ccdOutput, dataDirectory, reason, date);
    }
    
    public void rewriteHistory(int[] channels, String dataDirectory,
        String reason) throws IOException {
        Date date = makeNextVersionHistory(reason);
        for (int channel : channels) {
            Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(channel);
            int ccdModule = moduleOutput.left;
            int ccdOutput = moduleOutput.right;
            appendNew(ccdModule, ccdOutput, dataDirectory, reason, date);
        }
    }

    /**
     * @param args
     * @throws FocalPlaneException
     * @throws FocalPlaneException
     * @throws FocalPlaneException
     * @throws IOException
     * @throws PipelineException
     * @throws IOException
     * @throws PipelineException
     * @throws IOException
     * @throws PipelineException
     */
    public void run(String[] args) throws IOException {
        if (args.length < 2 || args.length > 5) {
            throw new FocalPlaneException(
                "Takes 2, 3, 4, or 5 args.  Correct usage is: \n" + USAGE);
        }

        // Strip non-ascii characters from the operator's hand-typed input:
        //
        args[args.length-1] = ImporterParentNonImage.onlyAsciiStringCopy(args[args.length-1]);

        String operation = args[0];

        boolean isAppend  = operation.equalsIgnoreCase(ImporterParentNonImage.APPEND_NEW);
        boolean isInsert  = operation.equalsIgnoreCase(ImporterParentNonImage.INSERT_BETWEEN);
        boolean isRewrite = operation.equalsIgnoreCase(ImporterParentNonImage.REWRITE_HISTORY);
        boolean isValidOp = isAppend || isInsert || isRewrite;

        if (!isValidOp) {
            throw new FocalPlaneException("Bad argument.  Correct usage is: \n"
                + USAGE);
        }

        if (args.length == 2) {
            String reason = args[1];
            if (isAppend) {
                appendNew(reason, new Date());
            } else if (isInsert) {
                insertBetween(reason);
            } else if (isRewrite) {
                rewriteHistory(reason);
            }
        } else if (args.length == 3) {
            String directory = args[1];
            String reason = args[2];
            if (isAppend) {
                appendNew(directory, reason, new Date());
            } else if (isInsert) {
                insertBetween(directory, reason);
            } else if (isRewrite) {
                rewriteHistory(directory, reason);
            }
        } else if (args.length == 4) {
            int ccdModule = Integer.parseInt(args[1]);
            int ccdOutput = Integer.parseInt(args[2]);
            String reason = args[3];
            if (isAppend) {
                appendNew(ccdModule, ccdOutput, reason, new Date());
            } else if (isInsert) {
                insertBetween(ccdModule, ccdOutput, reason);
            } else if (isRewrite) {
                rewriteHistory(ccdModule, ccdOutput, reason);
            }
        } else if (args.length == 5) {
            int ccdModule = Integer.parseInt(args[1]);
            int ccdOutput = Integer.parseInt(args[2]);
            String directory = args[3];
            String reason = args[4];
            if (isAppend) {
                appendNew(ccdModule, ccdOutput, directory, reason, new Date());
            } else if (isInsert) {
                insertBetween(ccdModule, ccdOutput, directory, reason);
            } else if (isRewrite) {
                rewriteHistory(ccdModule, ccdOutput, directory, reason);
            }
        }
    }

    protected void updateModelMetaData(String dataDirectory, History history, Date date) {
        ImporterParentNonImage.updateModelMetaData(dataDirectory, history, date);
    }

}
