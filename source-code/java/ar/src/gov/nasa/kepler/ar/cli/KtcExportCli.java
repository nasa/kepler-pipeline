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

package gov.nasa.kepler.ar.cli;

import static gov.nasa.kepler.ar.cli.CliUtils.parseDate;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.ar.exporter.ktc.KtcExporter;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.XANodeNameFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.ParseException;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.transaction.SystemException;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Sean McCauliff
 *
 */
@SuppressWarnings("serial")
public class KtcExportCli {

    private static final Log log = LogFactory.getLog(KtcExportCli.class);
    
    private final Option startOption = 
        new Option("b", "begin", true, "The start time of the target table in ISO 8601 format, UTC.") {{
            setRequired(false);
        }};
        
    private final Option endOption =
        new Option("e", "end", true, "The end time of the target table in ISO 8601 format, UTC.") {{
            setRequired(false);
        }};
        
    private final Option outputDirOption =  
        new Option("o", "output", true, "The output directory, defaults to '.'.") {{
            setRequired(false);
        }};
    
    private final Option excludedTargetLabelOption =
         OptionBuilder.hasArg().isRequired(false)
         .withDescription("comma separated list of target lables.  These targets will not be exported.")
         .withLongOpt("excluded-labels")
         .create("x");
    
    
    private final Options options = new Options() { {
        addOption(startOption);
        addOption(endOption);
        addOption(outputDirOption);
        addOption(excludedTargetLabelOption);
    }};
    

    private Date startTime;
    private Date endTime;
    private File outputFile;
    private final SystemProvider system;
    private final TargetCrud targetCrud;
    private final Set<String> excludedTargetLabels = new HashSet<String>();
    
    public KtcExportCli(SystemProvider system, TargetCrud targetCrud) {
        this.system = system;
        this.targetCrud = targetCrud;
    }
    
    public boolean parseCommandLine(String[] argv) throws org.apache.commons.cli.ParseException {
        if (argv.length == 0) {
            printUsage();
            system.exit(1);
            return false;
        }
        
        GnuParser gnuParser = new GnuParser();
        CommandLine commandLine = gnuParser.parse(options, argv);
        String startTimeStr = commandLine.getOptionValue(startOption.getOpt());
        String endTimeStr = commandLine.getOptionValue(endOption.getOpt());
        Pair<Date,Date> defaultTimes = getDefaultTimes();
        
        if (startTimeStr == null) {
            startTime = defaultTimes.left;
        } else {
            try {
                startTime = parseDate(startTimeStr);
            } catch (ParseException px) {
                system.err().println("Bad date/time format for start time \"" + startTimeStr + "\".");
                printUsage();
                system.exit(1);
            }
        }
        
        if (endTimeStr == null) {
            endTime = defaultTimes.right;
        } else {
            try {
                endTime = parseDate(endTimeStr);
            } catch (ParseException px) {
                system.err().println("Bad date/time format for end time \"" + endTimeStr + "\".");
                printUsage();
                system.exit(1);
                return false;
            }
        }
        
        String labelsString = commandLine.getOptionValue(excludedTargetLabelOption.getOpt(), "");
        String[] labels = labelsString.split(",");
        if (labels.length != 0 && labels[0].length() == 0) {
            excludedTargetLabels.addAll(Arrays.asList(labels));
        }

        FileNameFormatter fnameFormatter = new FileNameFormatter();
        File outputDir = new File(commandLine.getOptionValue(outputDirOption.getOpt()), ".");
        outputFile = new File(outputDir, fnameFormatter.targetCatalogName());
        system.out().println("Writing output to \"" + outputFile + "\".");
        return true;
    }
    
    public void execute() throws IOException, InterruptedException {
        DatabaseService dbService = null;
        try {
            dbService = DatabaseServiceFactory.getInstance();
        } catch (PipelineException e) {
            system.err().println("Failed to get a database connection.  Please " +
                    "configure your kepler.properties file.");
            e.printStackTrace();
            system.exit(1);
            return;
        }
        
        TargetCrud targetCrud = new TargetCrud(dbService);
        LogCrud logCrud = new LogCrud(dbService);
        KtcExporter ktcExporter = new KtcExporter(targetCrud, logCrud);
        try {
            ktcExporter.export(startTime, endTime, outputFile, excludedTargetLabels);
        } catch (SystemException e) {
            throw new IllegalStateException(e.toString(), e);
        }
    }
    
    private void printUsage() {
        HelpFormatter helpFormatter = new HelpFormatter();
        helpFormatter.printHelp("java -cp ... gov.nasa.kepler.ar.exporter.KtcExportCli", options);
        PrintWriter printWriter = new PrintWriter(system.out());
        printWriter.println("KTC (Kepler Target Catalog) Exporer");
        helpFormatter.printHelp(printWriter, 80, "java -cp ... gov.nasa.kepler.ar.exporter.KtcExportCli",
                            "", options, 4, 4, "");
    }
    private Pair<Date,Date> getDefaultTimes() {
        List<TargetTable> targetTables =
            targetCrud.retrieveUplinkedTargetTables(TargetType.LONG_CADENCE);
        
        Collections.sort(targetTables, new Comparator<TargetTable>() {

            @Override
            public int compare(TargetTable o1, TargetTable o2) {
                return o1.getPlannedStartTime().compareTo(o2.getPlannedStartTime());
            }
            
        });
        
        if (targetTables.size() == 0) {
            throw new IllegalArgumentException("Missing target tables.");
        }
        
        return Pair.of(targetTables.get(0).getPlannedStartTime(),
            targetTables.get(targetTables.size() - 1).getPlannedEndTime());
    }
    
    /**
     * @param args
     * @throws org.apache.commons.cli.ParseException 
     * @throws IOException 
     */
    public static void main(String[] argv)  {
        
        try {
            XANodeNameFactory.setInstance(new XANodeNameFactory("KTC"));
            DefaultSystemProvider system = new DefaultSystemProvider();
            TargetCrud targetCrud = new TargetCrud();
            KtcExportCli cli = new KtcExportCli(system, targetCrud);
            boolean parseOk = cli.parseCommandLine(argv);
            if (parseOk) {
                cli.execute();
            }
        } catch (Throwable t) {
            log.error("Bad stuff happened.", t);
            System.exit(2);
        }
        System.exit(0);
    }
    
}
