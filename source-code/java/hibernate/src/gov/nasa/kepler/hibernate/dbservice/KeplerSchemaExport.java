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

package gov.nasa.kepler.hibernate.dbservice;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.cfg.AnnotationConfiguration;
import org.hibernate.tool.hbm2ddl.SchemaExport;

/**
 * This class provides a command-line interface to the Hibernate
 * {@link SchemaExport} class which uses {@link KeplerHibernateConfiguration}
 * as the configuration source.
 * 
 * Why didn't I just use the standard hbm2ddl ant task (which calls SchemaExport directly)
 * to do this instead of writing custom code to do it?  Because the standard tools assume you
 * have a hibernate.cfg.xml file that explicitly lists all of your entity class.  Rather than
 * deal with that maintenence headache, I wrote my own configurator {@link KeplerHibernateConfiguration}
 * which scans the classpath for classes with Hibernate annotations and adds them to the
 * configuration dynamically.  Hibernate does provide some similar code that scans the classpath,
 * but it is designed to work with JPA-style configuration files (persistence.xml) which has
 * to be bundled in a jar file, so it's difficult to support multiple database configurations
 * such as what we have in kepler.properties.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class KeplerSchemaExport {
    private static final Log log = LogFactory.getLog(KeplerSchemaExport.class);

    /**
     * 
     */
    public KeplerSchemaExport() {
    }

    public static void main(String[] args) {
        try {
            boolean echoToStdOut = false;
            boolean drop = false;
            boolean create = false;
            boolean halt = true;
            boolean export = false;
            String outFile = null;
            boolean format = true;

            for (int i = 0; i < args.length; i++) {
                if (args[i].equals("--verbose")) {
                    echoToStdOut = true;
                }else if (args[i].equals("--drop")) {
                    drop = true;
                }else if (args[i].equals("--create")) {
                    create = true;
                }else if (args[i].equals("--nohaltonerror")) {
                    halt = false;
                }else if (args[i].startsWith("--output=")) {
                    outFile = args[i].substring(9);
                }else if (args[i].equals("--noformat")) {
                    format = false;
                }else{
                    System.err.println("unexpected arg: " + args[i]);
                    System.exit(-1);
                }
            }

            AnnotationConfiguration hibernateConfig = KeplerHibernateConfiguration.buildHibernateConfiguration();

            SchemaExport se = new SchemaExport(hibernateConfig).setHaltOnError(halt).setOutputFile(outFile).setDelimiter(";");
            
            if (format) {
                se.setFormat(true);
            }

            se.execute(echoToStdOut, export, drop, create);

        } catch (Exception e) {
            log.error("Error creating schema ", e);
            e.printStackTrace();
            System.exit(-1);
        }
    }
}
