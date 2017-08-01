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

import java.io.IOException;

import gov.nasa.kepler.ar.exporter.dv.DvReportsExporter;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;

import org.apache.commons.cli.ParseException;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Command line interface for exporting relevant MR reports to local dist so
 * they may be exported from the SOC.
 * 
 * @author Sean McCauliff
 * 
 */
public class DvReportsExportCli {

    private static final Log log = LogFactory.getLog(DvReportsExportCli.class);

    private final DvExportCommandLineParser parser;
    private final SystemProvider system;
    
    public DvReportsExportCli(SystemProvider system) {
        this.system = system;
        parser = new DvExportCommandLineParser(system);
    }
    
    public void parse(String[] argv) throws IOException, ParseException {
        parser.parse(argv, getClass());
    }
    
    public void export() throws IOException, InterruptedException {
        system.out().println("Starting export.");
        log.info("Starting export.");
        DvReportsExporter reportsExporter = 
            new DvReportsExporter(reportOps(), pipelineInstanceCrud(),
                parser.outputDir(), fsClient());
        
        reportsExporter.exportInstances(parser.pipelineInstanceId());
        system.out().println("Export complete.");
        log.info("Export complete.");
    }
    
    protected GenericReportOperations reportOps() {
        return new GenericReportOperations();
    }
    
    protected PipelineInstanceCrud pipelineInstanceCrud() {
        return new PipelineInstanceCrud();
    }
    
    protected FileStoreClient fsClient() {
        return FileStoreClientFactory.getInstance();
    }
    
    
    /**
     * @param argv command line arguments.  See DvExportCommandLineParser for
     * syntax.
     */
    public static void main(String[] argv) throws Exception {
        DefaultSystemProvider system = new DefaultSystemProvider();
        DvReportsExportCli cli = new DvReportsExportCli(system);
        cli.parse(argv);
        cli.export();
    }

}
