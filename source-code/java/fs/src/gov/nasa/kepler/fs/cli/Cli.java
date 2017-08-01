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

package gov.nasa.kepler.fs.cli;

import gnu.trove.TLongHashSet;
import gnu.trove.TLongProcedure;
import gov.nasa.kepler.fs.FileStoreConstants;
import gov.nasa.kepler.fs.FileStoreConstants.ConnectionType;
import gov.nasa.kepler.fs.api.*;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.fs.query.QueryEvaluator.DataType;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.collect.ListChunkIterator;
import gov.nasa.spiffy.common.intervals.Interval;
import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;

import static gov.nasa.spiffy.common.io.FileUtil.close;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

import java.io.*;

/**
 * File Store command line interface.
 * 
 * For Time series file format
 * 
 * @see gov.nasa.kepler.fs.api.TimeSeries#toPipeString()
 * @author Sean McCauliff
 * 
 */
public class Cli {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(Cli.class);

    private final SystemProvider system;

    private enum ExportFormat {
        PIPE, MAT, XML;
    }

    public Cli(SystemProvider system) {
        this.system = system;
    }

    private void printUsage() {
        system.out()
            .println("Usage: [-debug] [connection-params] <cmd> <cmd-options>");
        system.out()
            .println("\tconnection params: ");
        system.out()
            .println("\t\t-t <fstp|local|disk>");
        system.out()
            .println("\t\t-url < fstp://<host>:<port> >");
        system.out()
            .println("\tcommands:");
        system.out()
            .println("\tadd-blob [-c <input dir>] <file>+");
        system.out()
            .println("\t\t-c is equivelent to changing the directory before adding blobs.");
        system.out()
            .println("\t\tThe path part of the file name becomes the path part of the FsId; If present, '.' is stripped the front part the path name.  ");
        system.out()
            .println("\tget-blob [-q] < ids+ | query>");
        system.out()
            .println(
                "\tget-ts [-q] [-m <format>] <start> <end> <output file> < ids+ | query>");
        system.out()
            .println(
                "\tget-mts [-q] [-m <format>] <start mjd> <end mjd> <output file> < ids+ | query>");
        system.out()
            .println("\t\toutput file may be \"-\" for standard output.");
        system.out()
            .println("\t\t<format> is one of \"pipe\", \"xml\", \"mat\"");
        system.out()
            .println("\t\tDefaults to -f, floating point time series.");
        system.out()
            .println("\tadd-ts <input file>");
        system.out()
            .println("\tadd-mts <input file>");
        system.out()
            .println("\t\t<input file> must be in pipe delimited format.");
        system.out()
            .println("\t\tinput file may be \"-\" for standard input.");
        system.out()
            .println("\tls-ts [-q | -p] < base-id | query >");
        system.out()
            .println("\tls-ts-intervals <ids>+");
        system.out()
            .println("\tls-mts [-q | -p] < base-id | query >");
        system.out()
            .println("\tls-blob [-q | -p] < base-id | query >");
        system.out()
            .println("\to-ts [-q] <start cadence> <end cadence> <base-id* | query>");
        system.out()
            .println("\t\t-q If the <base-id> is a query. Or -p if the base-id is a path query.  For example.");
        system.out()
            .println("\t\t/cal/pixels/SocCal/[sct,lct]/\\d/\\d/444:\\d  will get all " +
            		"the cal calibrated pixels FsIdsfrom row 444 on any module output for long or short cadence target types.");
        system.out().println("\t\tAlso '*' can be used to glob, \\c is used to match cadence types.");
        system.out()
            .println("\tstatus");

    }

    private void uniqueOriginatorsForTimeSeries(FileStoreClient store, String[] argv, int argvIndex) {
        boolean query = false;
        if (getArg(argv, argvIndex, "-q").equals("-q")) {
            argvIndex++;
            query = true;
        }
        
        int startCadence = Integer.parseInt(getArg(argv, argvIndex++, "start cadence"));
        int endCadence = Integer.parseInt(getArg(argv, argvIndex++,"end cadence"));
        

        Set<FsId> fsIds = null;
        if (!query) {
            fsIds = new HashSet<FsId>();
            for (; argvIndex < argv.length; argvIndex++) {
                fsIds.add(new FsId(argv[argvIndex]));
            }
        } else {
            fsIds = store.queryIds2("TimeSeries@" + argv[argvIndex++]);
        }
        
        TLongHashSet uniqueOriginators = new TLongHashSet();
        ListChunkIterator<FsId> it = new ListChunkIterator<FsId>(fsIds.iterator(), 1024*16);
        while (it.hasNext()) {
            List<FsId> chunk = it.next();
            Set<FsId> chunkSet = new HashSet<FsId>(chunk);
            FsIdSet idSet = new FsIdSet(startCadence, endCadence, chunkSet);
            TimeSeriesBatch readResult = 
                store.readTimeSeriesBatch(Collections.singletonList(idSet), false).get(0);
            
            for (TimeSeries ts : readResult.timeSeries().values()) {
                ts.uniqueOriginators(uniqueOriginators);
            }
        }
        system.out().println("Unique originators:");
        uniqueOriginators.forEach(new TLongProcedure() {
            
            @Override
            public boolean execute(long originator) {
                system.out().print(originator + ",");
                return true;
            }
        });
        system.out().println("");
    }
    
    /**
     * Puts a file into the file store.
     * 
     * @param store
     * @param argv
     * @param startIndex
     * @throws Exception
     */
    private void addBlob(FileStoreClient store, String[] argv, int startIndex)
        throws Exception {
        
        String changeDir = null;
        if (getArg(argv, startIndex, "-c").equals("-c")) {
            changeDir = getArg(argv, ++startIndex, "-c arg");
            startIndex++;
        }

        List<File> blobFiles = new ArrayList<File>();
        List<FsId> blobIds = new ArrayList<FsId>();
        for (; startIndex < argv.length; startIndex++) {
            File blob = null;
            if (changeDir != null) {
                if (argv[startIndex].startsWith(changeDir)) {
                    blob = new File(argv[startIndex]);
                } else {
                    blob = new File(changeDir + "/" + argv[startIndex]);
                }
            } else {
                blob = new File(argv[startIndex]);
            }

            if (!blob.exists()) {
                system.err()
                    .println("File \"" + blob + "\" does not exist.");
                system.exit(1);
            }
            String fsIdStr = argv[startIndex];
            if (changeDir != null && fsIdStr.startsWith(changeDir)) {
                fsIdStr = fsIdStr.substring(changeDir.length());
            }
            if (fsIdStr.startsWith(".")) {
                fsIdStr = fsIdStr.substring(1);
            }
            if (fsIdStr.charAt(0) != '/') {
                fsIdStr = "/" + fsIdStr;
            }
            blobFiles.add(blob);
            blobIds.add(new FsId(fsIdStr));
        }

        boolean xOK = false;
        store.beginLocalFsTransaction();
        try {

            for (int blobi = 0; blobi < blobFiles.size(); blobi++) {
                File blobFile = blobFiles.get(blobi);
                store.writeBlob(blobIds.get(blobi), 0, blobFile);
            }
            xOK = true;
        } finally {
            if (xOK) {
                store.commitLocalFsTransaction();
            } else {
                store.rollbackLocalFsTransaction();
            }
        }
    }

    /**
     * Gets a blob out of the file store.
     * 
     * @param store
     * @param argv
     * @param startIndex
     * @throws Exception
     */
    private void getBlob(FileStoreClient store, String[] argv, int startIndex)
        throws Exception {
        
        boolean parseQuery = false;
        if (argv[startIndex].equals("-q")) {
            parseQuery = true;
            startIndex++;
        }
        
        Collection<FsId> ids = null;
        if (parseQuery) {
            String queryString = DataType.Blob + "@" + argv[startIndex++];
            ids = store.queryIds2(queryString);
        } else {
            ids = new ArrayList<FsId>();
            for (; startIndex < argv.length; startIndex++) {
                ids.add(new FsId(argv[startIndex]));
            }
        }

        File destDir = new File(system.getProperty("user.dir"));
        try {
            for (FsId fsId : ids) {
                File f = new File(destDir, fsId.toString());
                f.getParentFile().mkdirs();

                long originator = store.readBlob(fsId, f);
                system.out()
                    .println(
                        "Blob \"" + fsId + "\" is from " + originator + ".");
            }
        } catch (FileStoreIdNotFoundException fsidx) {
            system.err()
                .println("File store id\"" + fsidx.id() + "\" not found.");
            system.exit(3);
        }

    }

    /**
     * Puts '|' delimited time series from a file into the file store.
     * 
     * @param store
     * @param argv
     * @param startIndex
     * @throws Exception
     */
    private void addTimeSeries(FileStoreClient store, String[] argv,
        int startIndex) throws Exception {

        String fileName = getArg(argv, startIndex, "file name.");
        PipeImporter importer = new PipeImporter() {

            @Override
            protected void parseAndStore(String line, FileStoreClient fsClient)
                throws Exception {
                TimeSeries ts = TimeSeries.fromPipeString(line);
                fsClient.writeTimeSeries(new TimeSeries[] { ts });
            }

        };

        importer.loadFileStore(fileName, store, system);

    }

    /**
     * Puts '|' delimited cosmic ray series into the file store.
     */
    private void addCosmicRaySeries(FileStoreClient fsClient, String[] argv,
        int startIndex) throws Exception {

        String fileName = getArg(argv, startIndex, "file name.");

        PipeImporter importer = new PipeImporter() {
            @Override
            protected void parseAndStore(String line, FileStoreClient fsClient)
                throws Exception {
                FloatMjdTimeSeries crs = FloatMjdTimeSeries.fromPipeString(line);
                fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { crs });
            }
        };

        importer.loadFileStore(fileName, fsClient, system);
    }

    /**
     * Gets time series from the file store and writes them out in a '|'
     * delimited format.
     * 
     * @param store
     * @param argv
     * @param startIndex
     * @throws Exception
     */
    private void getTimeSeries(FileStoreClient store, String[] argv,
        final int startIndex) throws Exception {

        boolean parseQuery = false;
        ExportFormat exportFormat = ExportFormat.PIPE;
        int currentIndex = startIndex;
        while (argv[currentIndex].startsWith("-")) {
            if (argv[currentIndex].equals("-f")) {
                String msg = "Ignoring deprecated option -f.";
                system.err().println(msg);
                log.warn(msg);
            } else if (argv[currentIndex].equals("-i")) {
                String msg = "Ignoring deprecated option -i.";
                log.warn(msg);
                system.err().println(msg);
            } else if (argv[currentIndex].equals("-m")) {
                exportFormat = ExportFormat.valueOf(argv[++currentIndex].toUpperCase());
            } else if (argv[currentIndex].equals("-q")) {
                parseQuery = true;
            } else {
                system.err()
                    .println("Bad option \"" + argv[currentIndex] + "\".);");
                system.exit(-1);
                throw new IllegalArgumentException(argv[currentIndex]);
            }
            currentIndex++;
        }

        int start = Integer.parseInt(getArg(argv, currentIndex++,
            "start cadence."));
        int end = Integer.parseInt(getArg(argv, currentIndex++, "end cadence."));

        String fileName = getArg(argv, currentIndex++, "file name.");

        if (fileName.equals("-") && exportFormat == ExportFormat.MAT) {
            system.err()
                .println(
                    "Writing to standard output not supported for .mat files.");
            system.exit(-1);
            throw new IllegalStateException("Bad combination of options.");
        }

        Set<FsId> ids = null;
        List<FsId> orderList = null;
        if (parseQuery) {
            String queryString = DataType.TimeSeries + "@" + argv[currentIndex++];
            ids = store.queryIds2(queryString);
            orderList = new ArrayList<FsId>(ids);
        } else {
            orderList = new ArrayList<FsId>();
            ids = new HashSet<FsId>();
            for (int idIndex = 0; currentIndex < argv.length; currentIndex++, idIndex++) {
                FsId id = new FsId(argv[currentIndex]);
                ids.add(id);
                orderList.add(id);
            }
        }

        if (ids.size() == 0) {
            system.err()
                .println("No ids found. / You must specify one or more fsids.");
            system.exit(-1);
            throw new IllegalArgumentException("Need ids.");
        }


        FsIdSet fsIdSet = new FsIdSet(start, end, ids);
        List<FsIdSet> fsIdSetList = Collections.singletonList(fsIdSet);
        List<TimeSeriesBatch> timeSeriesBatches = 
            store.readTimeSeriesBatch(fsIdSetList, true);
        if (timeSeriesBatches.size() != 1) {
            throw new IllegalStateException("Expected # batches == 1.");
        }
        
        //Reorder results.
        TimeSeries[] tsa = new TimeSeries[orderList.size()];
        int i=0;
        for (FsId id : orderList) {
            tsa[i++] = timeSeriesBatches.get(0).timeSeries().get(id);
        }

        switch (exportFormat) {
            case MAT:
                TimeSeriesMatFileExporter matExporter = new TimeSeriesMatFileExporter();
                File outputFile = new File(fileName);
                matExporter.export(outputFile, tsa);
                break;
            case XML:
            case PIPE:
                Writer writer = null;

                try {
                    if (fileName.equals("-")) {
                        writer = new OutputStreamWriter(system.out());
                    } else if (exportFormat == ExportFormat.PIPE
                        || exportFormat == ExportFormat.XML) {
                        File tsFile = new File(fileName);
                        writer = new BufferedWriter(new FileWriter(tsFile));
                    }

                    if (exportFormat == ExportFormat.PIPE) {
                        for (TimeSeries ts : tsa) {
                            writer.append(ts.toPipeString());
                            writer.append("\n");
                        }
                    } else {
                        TimeSeriesXmlExporter xmlExporter = new TimeSeriesXmlExporter();
                        xmlExporter.export(writer, tsa);
                        writer.append('\n');
                    }
                } finally {
                    writer.close();
                }
                break;
            default:
                throw new IllegalStateException("Invalid export format "
                    + exportFormat);
        }
    }

    private void getMjdTimeSeriesSeries(FileStoreClient fsClient,
        String[] argv, int startIndex) throws Exception {

        ExportFormat exportFormat = ExportFormat.PIPE;
        //When true parse a query instead of a list of ids.
        boolean parseQuery = false;
        while (argv[startIndex].startsWith("-")) {
            if (argv[startIndex].equals("-m")) {
                exportFormat = ExportFormat.valueOf(argv[++startIndex].toUpperCase());
            } else if (argv[startIndex].equals("-q")) {
                parseQuery = true;
            } else {
                String error = "Unexpected option \"" + argv[startIndex] + "\".";
                system.err().println(error);
                system.exit(-1);
                throw new IllegalStateException(error);
            }
            startIndex++;
        }
        
        double startMjd = Double.parseDouble(getArg(argv, startIndex++,
            "start mjd"));
        double endMjd = Double.parseDouble(getArg(argv, startIndex++, "end mjd"));
        String outputFileName = getArg(argv, startIndex++, "output file name.");

        if (exportFormat == ExportFormat.MAT && outputFileName.equals("-")) {
            String error = ".mat file format not supported to stdout.";
            system.err().println(error);
            system.exit(-1);
            throw new IllegalStateException(error);
        }
        
        FsId[] ids = null;
        if (parseQuery) {
            String queryString = DataType.MjdTimeSeries + "@" + argv[startIndex++];
            Set<FsId> querySet = fsClient.queryIds2(queryString);
            ids = new FsId[querySet.size()];
            querySet.toArray(ids);
        } else {
            ids = new FsId[argv.length - startIndex];
            for (int i = 0; startIndex < argv.length; startIndex++, i++) {
                ids[i] = new FsId(argv[startIndex]);
            }
        }

        FloatMjdTimeSeries[] raySeries = fsClient.readMjdTimeSeries(ids,
            startMjd, endMjd);

        switch (exportFormat) {
            case MAT:
                TimeSeriesMatFileExporter exporter = new TimeSeriesMatFileExporter();
                File outputFile = new File(outputFileName);
                exporter.export(outputFile, raySeries);
                break;
            case PIPE:
            case XML:
                BufferedWriter bwriter = null;
                try {
                    OutputStream useStream = outputFileName.equals("-") ? system.out()
                        : new FileOutputStream(outputFileName);

                    bwriter = new BufferedWriter(new OutputStreamWriter(
                        useStream));

                    if (exportFormat == ExportFormat.PIPE) {
                        for (FloatMjdTimeSeries cr : raySeries) {
                            bwriter.append(cr.toPipeString())
                                .append("\n");
                        }
                    } else {
                        TimeSeriesXmlExporter xmlExporter = new TimeSeriesXmlExporter();
                        xmlExporter.export(bwriter, raySeries);
                        bwriter.append('\n');
                    }
                } finally {
                    bwriter.close();
                }
        }

    }

    /**
     * Given a file store id, lists the TimeSeries along that id's path.
     * 
     * @param store
     * @param argv
     * @param currentArg
     * @throws Exception
     */
    private void listIds(FileStoreClient store, String[] argv,
        int currentArg, DataType dataType) throws Exception {
        
        String option = getArg(argv, currentArg++, "option or base path");
        boolean query = false;
        boolean pathQuery = false;
        boolean basePath = false;  //This is here to support backwards compatibility.
        String queryStr = null;
        if (option.equals("-q")) {
            query = true;
        } else if (option.equals("-p")) {
            pathQuery = true;
        } else {
            currentArg--;
            new FsId(option, "_"); //check if this is a valid id
            basePath = true;
        }

        queryStr = dataType + "@" + getArg(argv, currentArg++, "query");
        if (basePath) {
            queryStr = queryStr + "/*";
        }
       
        if (currentArg < argv.length) {
            String err = "Too many arguments. \"" + argv[currentArg] + "\".";
            system.err().println(err );
            system.exit(-2);
            throw new IllegalStateException(err);
        }
        
        Set<FsId> ids = null;
        if (query || basePath) {
            ids = store.queryIds2(queryStr);
        } else if (pathQuery) {
            ids = store.queryPaths(queryStr);
        }
       
        for (FsId id : ids) {
            system.out().println(id);
        }
    }

    /**
     * List the valid intervals for a list of time series.
     */
    private void listIntervals(FileStoreClient store, String[] argv,
        int currentArg) throws Exception {

        FsId[] ids = new FsId[argv.length - currentArg];
        for (int i = 0; i < ids.length; i++) {
            ids[i] = new FsId(argv[currentArg++]);
        }
        List<Interval>[] intervalsForIds = store.getCadenceIntervalsForId(ids);
        for (int i = 0; i < ids.length; i++) {
            system.out()
                .print(ids[i] + " ");
            for (Interval valid : intervalsForIds[i]) {
                system.out()
                    .print("(");
                system.out()
                    .print(valid.start());
                system.out()
                    .print(",");
                system.out()
                    .print(valid.end());
                system.out()
                    .print(")\n");
            }
        }
    }

    private void status(FileStoreClient store, String[] argv, int i) {
        if (argv.length >= i + 1) {
            system.err()
                .println("Status does not need options.");
            printUsage();
            system.exit(-1);
            return;
        }

        MaintenanceInterface mface = (MaintenanceInterface) store;
        List<String> statusMessages = mface.status();
        for (String m : statusMessages) {
            system.out()
                .println(m);
        }
    }

    /**
     * 
     * @param argv
     * @throws Exception
     */
    public void execute(String[] argv) throws Exception {
        if (argv.length == 0) {
            printUsage();
            system.exit(1);
            return;
        }

        ConnectionType connectionType = null;
        String url = null;
        String cmd = null;

        int i = 0;
        for (; i < argv.length; i++) {
            if (argv[i].equals("-t")) {
                connectionType = ConnectionType.valueOf(getArg(argv, ++i,
                    "connection type parameter."));
            } else if (argv[i].equals("-url")) {
                url = getArg(argv, ++i, "url parameter.");
            } else if (argv[i].equals("-debug")) {
                Logger log4jLogger = Logger.getLogger(".");
                log4jLogger.setLevel(Level.DEBUG);
            } else if (argv[i].indexOf(0) != '-' && cmd == null) {
                cmd = argv[i];
                break;

            } else {
                system.err()
                    .println("Invalid option: \"" + argv[i] + "\".");
                system.exit(1);
                return;
            }
        }
        i++;

        Configuration config = ConfigurationServiceFactory.getInstance();
        if (connectionType != null) {
            config.setProperty(FileStoreConstants.FS_DRIVER_NAME_PROPERTY,
                connectionType.name());

        }

        if (url != null) {
            if (connectionType == ConnectionType.disk
                || connectionType == ConnectionType.ram) {
                system.err()
                    .println(
                        "Can't set url for connection type \"" + connectionType
                            + "\".");
                system.exit(1);
                return;
            }
            config.setProperty(FileStoreConstants.FS_FSTP_URL, url);
        }

        FileStoreClient store = FileStoreClientFactory.getInstance(config);
        try {
            if (cmd.equals("add-blob")) {
                addBlob(store, argv, i);
            } else if (cmd.equals("get-blob")) {
                getBlob(store, argv, i);
            } else if (cmd.equals("add-ts")) {
                addTimeSeries(store, argv, i);
            } else if (cmd.equals("get-ts")) {
                getTimeSeries(store, argv, i);
            } else if (cmd.equals("ls-ts")) {
                listIds(store, argv, i, DataType.TimeSeries);
            } else if (cmd.equals("ls-ts-intervals")) {
                listIntervals(store, argv, i);
            } else if (cmd.equals("add-mts")) {
                addCosmicRaySeries(store, argv, i);
            } else if (cmd.equals("get-mts")) {
                getMjdTimeSeriesSeries(store, argv, i);
            } else if (cmd.equals("ls-mts")) {
                listIds(store, argv, i, DataType.MjdTimeSeries);
            } else if (cmd.equals("ls-blob")) {
                listIds(store, argv, i, DataType.Blob);
            } else if (cmd.equals("status")) {
                status(store, argv, i);
            } else if (cmd.equals("o-ts")) {
                uniqueOriginatorsForTimeSeries(store, argv, i);
            } else {
                system.err()
                    .println("Unknown command \"" + cmd + "\".");
                printUsage();
                system.exit(1);
                return;
            }
        } finally {
            close(store);
        }

        system.exit(0);
    }

    private String getArg(String[] argv, int index, String errMsg) {
        if (argv.length <= index) {
            throw new IllegalArgumentException("Missing " + errMsg);
        }
        return argv[index];
    }

    /**
     * @param args
     */
    public static void main(String[] argv) throws Exception {
        Cli cli = new Cli(new DefaultSystemProvider());
        cli.execute(argv);
    }

    private static abstract class PipeImporter {

        public void loadFileStore(String fileName, FileStoreClient fsClient,
            SystemProvider system) throws Exception {
            BufferedReader breader = null;
            if (fileName.equals("-")) {
                breader = new BufferedReader(new InputStreamReader(system.in()));
            } else {
                File tsFile = new File(fileName);
                if (!tsFile.exists()) {
                    system.err()
                        .println(
                            "Time series file \"" + tsFile
                                + "\" does not exist.");
                    system.exit(2);
                    return;
                }
                breader = new BufferedReader(new FileReader(tsFile));
            }

            fsClient.beginLocalFsTransaction();
            try {
                for (String line = breader.readLine(); line != null; line = breader.readLine()) {

                    if (line.length() == 0) {
                        continue;
                    }
                    parseAndStore(line, fsClient);

                }
                fsClient.commitLocalFsTransaction();
            } finally {
                fsClient.rollbackLocalFsTransactionIfActive();
                breader.close();
            }
        }

        protected abstract void parseAndStore(String line,
            FileStoreClient fsClient) throws Exception;
    }
}
