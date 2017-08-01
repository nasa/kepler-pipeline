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

import gov.nasa.kepler.common.AsciiCleanWriter;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.common.SvnUtils;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.pi.ModelMetadataCrud;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;
import java.util.Arrays;
import java.util.Date;
import java.util.regex.Pattern;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.tmatesoft.svn.core.SVNException;

public abstract class ImporterParentNonImage {
    protected static final Log log = LogFactory.getLog(ImporterParentNonImage.class);
    public static final String DATA_DIR_PROPERTY_PREFIX = "fc.importer.";

    public static final String APPEND_NEW = "appendNew";
    public static final String CHANGE_EXISTING = "changeExisting";
    public static final String INSERT_BETWEEN = "insertBetween";
    public static final String REWRITE_HISTORY= "rewriteHistory";

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

    public abstract void changeExisting(int ccdModule, int ccdOutput,
        String dataDirectory, String reason) throws IOException,
        FocalPlaneException;

    public abstract void changeExisting(int ccdModule, int ccdOutput,
        String reason) throws IOException;

    public abstract void changeExisting(String dataDirectory, String reason)
        throws IOException;

    public abstract void changeExisting(String reason) throws IOException,
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
        double nowMjd = ModifiedJulianDate.dateToMjd(date);
        History newHistory = new History(nowMjd, getHistoryModelName(), reason, version);
        fcCrud.create(newHistory);
        return date;
    }
    
    protected static void updateModelMetaData(String dataDirectory, History history, Date date) {       
        String svnInfo;
        try {
            svnInfo = SvnUtils.getSvnInfoForDirectory(dataDirectory);
        } catch (SVNException e) {
            throw new FocalPlaneException(e.getMessage());
        }
        ModelMetadataCrud modelMetadataCrud = new ModelMetadataCrud();
        modelMetadataCrud.updateModelMetaData(history.getModelType().name(), history.getDescription(), date, svnInfo);
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
     * Extract the data directory's name from kepler.properties
     * 
     * @param typeName
     * @return
     * @throws FocalPlaneException
     */
    public static String[] getDataFilenames(final String fileRegex,
        String typeName) {
        File directory = getDataDirectory(typeName);
        String[] filenames = getFilenamesFromDirectory(directory, fileRegex);

        return filenames;
    }

    /**
     * Return directory name from kepler.properties:
     * 
     * @param typeName
     * @return
     * @throws FocalPlaneException
     */
    public static File getDataDirectory(String typeName)
        {
        String dataDirRoot = ConfigurationServiceFactory.getInstance()
            .getString(DATA_DIR_PROPERTY_PREFIX + "rootdir");
        if (dataDirRoot == null) {
            dataDirRoot = SocEnvVars.getLocalDataDir();
        }
        
        String dataDirEnd = ConfigurationServiceFactory.getInstance()
            .getString(DATA_DIR_PROPERTY_PREFIX + typeName);
        
        if (dataDirEnd == null) {
        	File tmp = new File(typeName);
        	if (tmp.isDirectory()) {
        		dataDirRoot = typeName;
        		dataDirEnd  = "";
        	} else {
        		throw new IllegalStateException(DATA_DIR_PROPERTY_PREFIX + typeName
        				+ " property not defined");
        	}
        }

        File directory = new File(dataDirRoot, dataDirEnd);

        log.debug("Determining data directory is " + directory);

        if (!directory.exists()) {
            throw new FocalPlaneException("Input directory "
                + directory.getAbsolutePath() + " does not exist.");
        }
        return directory;
    }

    /**
     * Return the files in the directory that match the fileRegex. 
     * If no files in the directory match the fileRegex, log an error,
     * and return an empty array.
     * 
     * @param directory
     * @param fileRegex
     * @return
     * @throws FocalPlaneException 
     */
    public static String[] getFilenamesFromDirectory(File directory,
        final String fileRegex) {
        FileFilter fileFilter = new FileFilter() {
            @Override
            public boolean accept(File file) {
                return !file.isDirectory()
                    && Pattern.matches(fileRegex, file.getName());
            }
        };

        // Get the filenames that match and allocate an array of String
        // to hold the results.  If 'files' is empty, log an error
        // and return the null String array.
        //
        File[] files = directory.listFiles(fileFilter);
        String[] filenames = new String[files.length];

        if (files.length == 0) {
            throw new FocalPlaneException("No files found in " + directory.getAbsolutePath() + " with regex " + fileRegex);
        }

        for (int ii = 0; ii < files.length; ++ii) {
            filenames[ii] = files[ii].getAbsolutePath();
        }

        Arrays.sort(filenames);
        for (String filename : filenames) {
        	log.trace(filename);
        }
        return filenames;
    }
    
    // Remove produce a copy of the input String, removing all non-ascii characters:
    //
    public static String onlyAsciiStringCopy(String argument) throws IOException {
        StringWriter stringWriter = new StringWriter();
        Writer writer = new AsciiCleanWriter(stringWriter);
        try {
        writer.append(argument);
        } finally {
            FileUtil.close(writer);
        }
        return stringWriter.toString();
    }

    /**
     * @param args
     * @throws FocalPlaneException
     * @throws IOException
     */
    public void run(String[] args) throws IOException {
        if (args.length < 2 || args.length > 5) {
            throw new FocalPlaneException(
                "Takes 2, 3, 4, or 5 args.  Correct usage is: \n" + USAGE);
        }

        // Strip non-ascii characters from the operator's hand-typed input:
        //
        args[args.length-1] = onlyAsciiStringCopy(args[args.length-1]);
        
        
        String operation = args[0];

        boolean isAppend  = operation.equalsIgnoreCase(ImporterParentNonImage.APPEND_NEW);
        boolean isChange  = operation.equalsIgnoreCase(ImporterParentNonImage.CHANGE_EXISTING);
        boolean isInsert  = operation.equalsIgnoreCase(ImporterParentNonImage.INSERT_BETWEEN);
        boolean isRewrite = operation.equalsIgnoreCase(ImporterParentNonImage.REWRITE_HISTORY);
        boolean isValidOp = isAppend || isChange || isInsert || isRewrite;

        if (!isValidOp) {
            throw new FocalPlaneException("Bad argument.  Correct usage is: \n"
                + USAGE);
        }

        if (args.length == 2) {
            String reason = args[1];
            if (isAppend) {
                appendNew(reason, new Date());
            } else if (isChange) {
                changeExisting(reason);
            } else if (isInsert) {
                insertBetween(reason);
            } else if (isRewrite) {
                rewriteHistory(reason);
            }
        } else if (args.length == 3) {
            String directory = args[1];
            String reason    = args[2];
            if (isAppend) {
                appendNew(directory, reason, new Date());
            } else if (isChange) {
                changeExisting(directory, reason);
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
            } else if (isChange) {
                changeExisting(ccdModule, ccdOutput, reason);
            } else if (isInsert) {
                insertBetween(ccdModule, ccdOutput, reason);
            } else if (isRewrite) {
            	rewriteHistory(ccdModule, ccdOutput, reason);
            }
        } else if (args.length == 5) {
            int ccdModule = Integer.parseInt(args[1]);
            int ccdOutput = Integer.parseInt(args[2]);
            String directory = args[3];
            String reason    = args[4];
            if (isAppend) {
                appendNew(ccdModule, ccdOutput, directory, reason, new Date());
            } else if (isChange) {
                changeExisting(ccdModule, ccdOutput, directory, reason);
            } else if (isInsert) {
                insertBetween(ccdModule, ccdOutput, directory, reason);
            } else if (isRewrite) {
            	rewriteHistory(ccdModule, ccdOutput, directory, reason);
            }
        }
    }

}
