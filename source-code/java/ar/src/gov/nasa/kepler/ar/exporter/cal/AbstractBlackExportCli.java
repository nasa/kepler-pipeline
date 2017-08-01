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

package gov.nasa.kepler.ar.exporter.cal;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkNotNull;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.hibernate.cal.BlackAlgorithm;
import gov.nasa.kepler.hibernate.cal.CalCrud;
import gov.nasa.kepler.hibernate.cal.CalProcessingCharacteristics;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import java.io.File;
import java.text.ParsePosition;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;

/**
 * Abstract superclass capturing the functionality common to DynablackExportCli
 * and OneDBlackExportCli.
 * @author Lee Brownston
 */
public abstract class AbstractBlackExportCli {

    /** The number of modules. */
    private static final int MODULE_COUNT = 25;

    /** The number of outputs per module. */
    private static final int OUTPUT_COUNT = 4;
    /** The number of command-line arguments that must be supplied. */
    private static final int ARG_COUNT = 4;
    /** The index of the quarter command-line argument. */
    private static final int QUARTER_ARG_INDEX = 0;
    /** The index of the data release number command-line argument. */
    private static final int DATA_RELEASE_NUMBER_ARG_INDEX = 1;
    /** The index of the time stamp command-line argument. */
    private static final int TIME_STAMP_ARG_INDEX = 2;
    /** The index of the pathname command-line argument. */
    private static final int PATHNAME_ARG_INDEX = 3;
    /** The minimum value for the quarter command-line argument. */
    private static final int MIN_QUARTER = 0;
    /** The maximum value for the quarter command-line argument. */
    private static final int MAX_QUARTER = 17;
    /** How the time stamp is formatted; parse for validation. */
    private final SimpleDateFormat timeStampFormat = new SimpleDateFormat(
            "yyyyDDDHHmmss");
    /** Used to fetch the Black Algorithm. */
    private CalCrud calCrud = new CalCrud();
    /** The quarter to extract. */
    protected int quarter;
    /** Serial enumerator of the data release. */
    protected int dataReleaseNumber;
    /** The user-supplied time-stamp string. */
    protected String timeStampString;
    /** The directory into which the exported files are to be written. */
    protected File outputDirectory;
    
    /**
     * Return a filename for a BLOB based on the saved command-line arguments
     * and function arguments. These are assumed to have already been
     * validated.
     * 
     * @return a filename String based on the saved command-line arguments
     */
    protected abstract String blobFilename(int module, int output);
    
    /**
     * Export for the the quarter given in the command-line arguments and the
     * module/output pair given in the method arguments.
     */
    protected abstract void exportOneBlob(int module, int output);
    
    /**
     * A pair of longs, indicating start and end cadence.
     * There are no accessors.
     */
    class CadenceRange {
        long start;
        long end;
        CadenceRange(long start, long end) { this.start = start; this.end = end; }
    }

    /** The default constructor. */
    public AbstractBlackExportCli() {
        super();
    }
    
    /**
     * Return the usage message String.
     * It will be different for different subclasses.
     * @return the usage message String
     */
    protected abstract String usageMessage();

    /**
     * The entry point of the application.
     * Extract the arguments and export according to their specifications.
     * @param args the command-line arguments, assumed validated
     */
    protected void export(String[] args) {
        // If this fails, it is a programmer error
        checkNotNull(args);
        
        try {
            if (extractArguments(args)) {
                for (int module = 1; module <= MODULE_COUNT; module++) {
                    // The 4 corner CCDs don't collect science data
                    if ((module != 1) && (module != 5) && (module != 21)
                        && (module != 25)) {
                        for (int output = 1; output <= OUTPUT_COUNT; output++) {
                            exportOneBlob(module, output);
                        }
                    }
                }
            }
        } catch (org.hibernate.exception.JDBCConnectionException e) {
            System.out.println("It looks like the database service was not started.");
        }
    }
    
    /**
     * @return an enumeration value specifying the Dynablack/1D Black algorithm
     * CAL uses for the specified arguments; if not found, return UNDEFINED
     */
    protected BlackAlgorithm getBlackAlgorithm(int module, int output,
        long startCadence, long endCadence) {
        final CalProcessingCharacteristics calProcessingCharacteristics =
            getCalProcessingCharacteristics(module, output, startCadence, endCadence);
        final BlackAlgorithm result = 
            (calProcessingCharacteristics == null) ?
                BlackAlgorithm.UNDEFINED :
                calProcessingCharacteristics.getBlackAlgorithm();
        return result;
    }
    
    /**
     * @return the PipelineTask for the specified arguments; if not found,
     * return null
     */
    protected PipelineTask getPipelineTask(int module, int output,
        long startCadence, long endCadence) {
        final CalProcessingCharacteristics calProcessingCharacteristics =
            getCalProcessingCharacteristics(module, output, startCadence, endCadence);
        final PipelineTask result = 
            (calProcessingCharacteristics == null) ?
                null :
                calProcessingCharacteristics.getPipelineTask();
        return result;        
    }
    
    /**
     * Comparator used to find a CalProcessingCharacteristics with the maximum
     * pipeline task ID.
     */
    private static class CompareCPC implements Comparator<CalProcessingCharacteristics> {
        /** {@inheritDoc} Note: this comparator imposes orderings that are inconsistent with equals. */
        public int compare(CalProcessingCharacteristics left,
                           CalProcessingCharacteristics right) {
            return (int)(left.getPipelineTask().getId() - right.getPipelineTask().getId());
        }  
    }
    
    /**
     * @return a CalProcessingCharacterics object for the specified arguments
     * with the maximum pipeline task ID, containing information about the
     * BlackAlgorithm and the PipelineTask; if no such object exists, return null
     */
    private CalProcessingCharacteristics
    getCalProcessingCharacteristics(int module, int output, long startCadence,
        long endCadence) {
        final CadenceType cadenceType = CadenceType.LONG;
        final List<CalProcessingCharacteristics>
            calProcessingCharacteristicsList =
                calCrud.retrieveProcessingCharacteristics(module,
                        output, (int)startCadence, (int)endCadence, cadenceType);
        final CalProcessingCharacteristics result = 
            (calProcessingCharacteristicsList.size() == 0) ? null :
            // Return an element with the maximum pipeline task ID
            Collections.max(calProcessingCharacteristicsList, new CompareCPC());
        return result;
    }
    
    /**
     * BlackAlgorith.name() returns an identifier, not a print name.
     * Avoid overriding BlackAlgorithm.toString().
     * @param blackAlgorithm the enum value
     * @return a user-friendly print name
     */
    protected String blackAlgorithmToString(BlackAlgorithm blackAlgorithm) {
        final String result =
            ((blackAlgorithm == BlackAlgorithm.DYNABLACK) ?
                "Dynablack" :
                    ((blackAlgorithm == BlackAlgorithm.EXP_1D_BLACK) ?
                        "1D Black Exponential" :
                            ((blackAlgorithm == BlackAlgorithm.POLYNOMIAL_1D_BLACK) ?
                                "1D Black Polynomial" : "Undefined")));
        return result;
    }

    /**
     * If there is one BLOB in the BlobSeries, write it to the file system.
     * @param module the module being exported; for trace messages
     * @param output the output being exported; for trace messages
     * @param blobSeries a sequence of BLOB file pathnames
     */
    protected void writeBlobSeries(int module, int output,
        BlobSeries<String> blobSeries) {
        String traceMessage = null;
        switch (blobSeries.size()) {
            case 0:
            {
                traceMessage = 
                    "No data available for quarter " + quarter +
                    " module " + module + " output " + output;
                break;
            }
            case 1:
            {
                // This is where the BLOB was put in the file system
                final String exportedFilePathname =
                    (String)(blobSeries.blobFilenames()[0]);
                final File exportedFile = new File(outputDirectory, exportedFilePathname);
                final String destinationFilename = blobFilename(module, output);
                final File destination = new File(outputDirectory, destinationFilename);
                mv(exportedFile, destination);
                traceMessage = "Exported " + destinationFilename;
                break;
            }
            default: {
                traceMessage =
                    String.valueOf(blobSeries.size()) +
                    " files needed for quarter " + quarter +
                    " module " + module + " output " + output;
                break;
            }
        }
        System.out.println(traceMessage);
    }

    /**
     * Extract, parse, save and validate the quarter command-line argument.
     * 
     * @param args the command-line argumensts, assumed validated
     */
    private void extractQuarterArgument(String[] args) {
        // Extract
        final String quarterString = args[QUARTER_ARG_INDEX];
        // Parse and save
        try {
            quarter = Integer.parseInt(quarterString);
        } catch (NumberFormatException e) {
            final String message = quarterString + " not parseable as an int";
            checkArgument(false, message);
        }
        // Validate
        checkArgument(((MIN_QUARTER <= quarter) && (quarter <= MAX_QUARTER)),
            quarter + " is out of range [0,17]");
    }

    /**
     * Extract, parse, save and validate the data release number command-line
     * argument.
     * 
     * @param args the command-line arguments, assumed validated
     */
    private void extractDataReleaseNumberArgument(String[] args) {
        // Extract
        final String dataReleaseNumberString = args[DATA_RELEASE_NUMBER_ARG_INDEX];
        // Parse and save
        try {
            dataReleaseNumber = Integer.parseInt(dataReleaseNumberString);
        } catch (NumberFormatException e) {
            final String message = dataReleaseNumberString
                + " not parseable as an int";
            checkArgument(false, message);
        }
        // Validate
        checkArgument((0 < dataReleaseNumber), dataReleaseNumber
            + " is out of range [1, inf)");
    }

    /**
     * Extract, save and validate the time stamp command-line argument.
     * 
     * @param args the command-line arguments, assumed validated
     */
    private void extractTimeStampArgument(String[] args) {
        // Extract and save
        timeStampString = args[TIME_STAMP_ARG_INDEX];
        // Parse
        final Date timeStamp = timeStampFormat.parse(timeStampString,
            new ParsePosition(0));
        // Validate
        checkArgument((timeStamp != null),
            (timeStampString + " not parseable as a Date"));
    }

    /**
     * Extract, open, save and validate the output directory command-line
     * argument
     * 
     * @param args the command-line arguments, assumed validated
     */
    private void extractOutputDirectoryArgument(String[] args) {
        // Extract
        final String outputDirectoryPathname = args[PATHNAME_ARG_INDEX];
        // Open and save
        outputDirectory = new File(outputDirectoryPathname);
        // Validate
        checkArgument(outputDirectory.exists(), outputDirectoryPathname
            + " does not exist");
        checkArgument(outputDirectory.isDirectory(), outputDirectoryPathname
            + " is not a directory");
    }

    /**
     * All arguments come from the command line. Extract, parse, store and
     * validate them.
     * 
     * @param args the command-line arguments, not yet validated
     * @return whether the command-line arguments were successfully extracted
     */
    private boolean extractArguments(String[] args) {
        // If this fails, it is a programmer error
        checkNotNull(args);
        boolean ok = true;
        // If this fails, it is a user error
        try {
            checkArgument((args.length == ARG_COUNT),
                ("Requires " + ARG_COUNT + " arguments."));
        } catch (IllegalArgumentException e) {
            System.out.println(e.getMessage());
            ok = false;
        }
    
        if (ok) {
            // Right argument count; now check arguments individually
            ok = false;
            try {
                extractQuarterArgument(args);
                extractDataReleaseNumberArgument(args);
                extractTimeStampArgument(args);
                extractOutputDirectoryArgument(args);
                ok = true;
            } catch (IllegalArgumentException e) {
                System.out.println(e.getMessage());
            } catch (NullPointerException e) {
                System.out.println("Null pointer");
            }
        }
        if (!ok) {
            System.out.println(usageMessage());
        }
        return ok;
    }

    /**
     * Map a quarter to its CadenceRange.
     * A hard-coded map will work
     * @param quarter the quarter for which the CadenceRange is sought;
     * assumed in [1,17]
     * @return null if quarter is invalid; otherwise the CadenceRange for that quarter
     */
    protected CadenceRange quarterToCadenceRange(int quarter) {
        final CadenceRange[] rangeMap = {
            new CadenceRange(568, 1043),
            new CadenceRange(1105,2743),
            new CadenceRange(2965,7318),
            new CadenceRange(7404,11773),
            new CadenceRange(11914,16310),
            new CadenceRange(16373,21006),
            new CadenceRange(21069,25466),
            new CadenceRange(25509,29883),
            new CadenceRange(30657,33935),
            new CadenceRange(34237,39004),
            new CadenceRange(39049,43621),
            new CadenceRange(43667,48420),
            new CadenceRange(48473,52516),
            new CadenceRange(52551,56971),
            new CadenceRange(57024,61780),
            new CadenceRange(61886,66665),
            new CadenceRange(66712,70914),
            new CadenceRange(70976,72531)
        };
        final CadenceRange result =
            ((0 <= quarter) && (quarter <= MAX_QUARTER)) ? rangeMap[quarter] : null;
        return result;
    }
    
    /**
     * Execute the UNIX "mv" command.
     * The BLOB API chooses its own file names, and we want our own.
     * @param the source File; assumed not null
     * @param the destination File; assumed not null
     */
    protected void mv(File fromFile, File toFile) {
        // First try the most straightforward, which might not be implemented
        if (!fromFile.renameTo(toFile)) {
            // Well that didn't work. Do it a more laborious way
            final String mvCommand = "mv " + fromFile.getPath() + " " + toFile.getPath();
            final String[] shCommand = {"/bin/sh", "-c", mvCommand}; 
            try
            {
                final Runtime runtime = Runtime.getRuntime();
                final Process process = runtime.exec(shCommand);
                // Can't test process's return code until it returns
                // Is it worth waiting for it to return?
            }
            catch (Exception e)
            {
                System.err.println("Execute Command Error:");
                e.printStackTrace();
            }
        }
    }
}
