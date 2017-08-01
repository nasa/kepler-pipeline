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

package gov.nasa.kepler.fs.api.gen;


import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

/**
 * Generates stubs and skeletons for the specified Java interface.
 * 
 * @author Sean McCauliff
 *
 */
public class ApiGenerator {

    private static final Option stubOption = new Option("u", "stub", true, 
        " A fully qualified (dotted) Java class name to generate as the client stub.");
    private static final Option skeletonOption = new Option("s", "skeleton", true,
        "A fully qualified (dotted) Java class name to generate as the client stub.");
    private static final Option targetOption = new Option("t", "target", true,
        "A fully qualified, compiled Java interface name to generate from.");
    private static final Option outputOption = new Option("o", "outputdir", true,
        "Directory to write generated code.");
    
    private static final Options options = new Options();
    
    static {
        options.addOption(stubOption);
        options.addOption(skeletonOption);
        options.addOption(targetOption);
        options.addOption(outputOption);
    }
        
    /**
     * @param args
     */
    public static void main(String[] argv) throws Exception {
        
        if (argv.length == 0) {
            printUsage();
        }
        
        try {
            CommandLineParser parser = new GnuParser();
            CommandLine commandLine = parser.parse(options, argv, false);
            
            String stubClassName = commandLine.getOptionValue(stubOption.getOpt());
            String skeletonClassName = commandLine.getOptionValue(skeletonOption.getOpt());
            String targetInterfaceName = commandLine.getOptionValue(targetOption.getOpt());
            String outputPath = commandLine.getOptionValue(outputOption.getOpt());
    
            if (stubClassName == null) {
                System.err.println("A fully qualified stub class name must be specified.");
                System.exit(1);
            }
            if (skeletonClassName == null) {
                System.err.println("A fully qualified skeleton class name must be specified.");
                System.exit(1);
            }
            if (targetInterfaceName == null) {
                System.err.println("A fully qualified interface name must be specified.");
                System.exit(1);
            }
            Class<?> targetInterface = Class.forName(targetInterfaceName);
            
            if (outputPath == null) {
                System.err.println("An output path must be specified.");
                System.exit(1);
            }
    
            
            InterfaceData interfaceData = new InterfaceData(targetInterface);
            AbstractGenerator generator 
                = new FstpGenerator(skeletonClassName, stubClassName, interfaceData);
    
         
            File outputDir = new File(outputPath);
            if (!outputDir.exists()) {
                throw new IllegalArgumentException("Output directory \"" + outputDir
                        + "\" does not exist.");
            }
            
            
            writeOutClass(generator.generateClient(),  
                           generator.clientClassName(),
                           generator.clientPackageName(),
                           outputDir);
            
            writeOutClass(generator.generateServer(),  
                           generator.serverClassName(),
                           generator.serverPackageName(),
                           outputDir);
            
            System.out.println("ApiGenerator complete for \""+ skeletonClassName + 
                              "\" and \"" + stubClassName + "\".");
        } catch (ParseException px) {
            px.printStackTrace();
            printUsage();
            System.exit(1);
        }
        
    }

    /**
     * @param httpGenerator
     * @param outputDir
     * @throws IOException
     */
    private static void writeOutClass(String classDefinition, String className,
                                      String packageName, File outputDir) 
        throws IOException {

        File clientDir = 
            new File(outputDir.getAbsolutePath() + File.separatorChar + 
                     packageName.replaceAll("\\.", File.separator));
        clientDir.mkdirs();
        File classFile = new File(clientDir, className+".java");
        BufferedWriter bout = new BufferedWriter(new FileWriter(classFile));
            
        bout.write(classDefinition);
        bout.close();
    }

    private static void printUsage() {
        HelpFormatter helpFormatter = new HelpFormatter();
        helpFormatter.printHelp("java -cp ... gov.nasa.kepler.fs.api.gen.ApiGenerator", options);
    }
    
}
