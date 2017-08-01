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

package gov.nasa.kepler.pi.module.io.cpp;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class generates the C++ code for the scientific algorithm controller
 * class as well as the main.cpp file.
 * 
 * @author tklaus
 * 
 */
public class CppController {
    /**
     * Logger for this class
     */
    private static final Log log = LogFactory.getLog(CppController.class);

    private String name;
    private String incDir = null;
    private String srcDir = null;

    /**
     * 
     * @param name
     */
    public CppController(String name, String incDir, String srcDir) {
        this.name = name;
        this.incDir = incDir;
        this.srcDir = srcDir;
    }

    /**
     * Generates the controller .h, .cpp, and the main.cpp files
     * 
     * @throws IOException
     */
    public void generate() throws IOException {

        genControllerHeader();
        genControllerCode();
        genMain();
    }

    /**
     * Generates the controller .h file
     * 
     * @throws IOException
     */
    private void genControllerHeader() throws IOException {
        File file = new File(incDir + "/" + name + "Controller.h");

        if (file.exists()) {
            log.debug("NOT generating " + file + " because it already exists");
            return;
        }

        log.debug("Generating " + file);

        FileUtils.forceMkdir(new File(incDir));

        FileWriter fw = new FileWriter(file);
        BufferedWriter bw = new BufferedWriter(fw);
        PrintWriter pw = new PrintWriter(bw);

        pw.println("#ifndef " + name.toUpperCase() + "CONTROLLER_H_");
        pw.println("#define " + name.toUpperCase() + "CONTROLLER_H_");
        pw.println();

        pw.println("#include \"" + name + "Inputs.h\"");
        pw.println("#include \"" + name + "Outputs.h\"");
        pw.println();

        pw.println("class " + name + "Controller");
        pw.println("{");
        pw.println("	public:");
        pw.println("	" + name + "Controller();");
        pw.println("	virtual ~" + name + "Controller();");
        pw.println();

        pw.println("	int doScience( " + name + "Inputs& inputs, " + name + "Outputs& outputs );");
        pw.println("};");
        pw.println();

        pw.println("#endif /*" + name.toUpperCase() + "CONTROLLER_H_*/");
        pw.println();

        pw.close();
    }

    /**
     * Generates the controller .cpp file
     * 
     * @throws IOException
     */
    private void genControllerCode() throws IOException {
        File file = new File(srcDir + "/" + name + "Controller.cpp");

        if (file.exists()) {
            log.debug("NOT generating " + file + " because it already exists");
            return;
        }

        log.debug("Generating " + file);

        FileUtils.forceMkdir(new File(srcDir));

        FileWriter fw = new FileWriter(file);
        BufferedWriter bw = new BufferedWriter(fw);
        PrintWriter pw = new PrintWriter(bw);

        pw.println();
        pw.println("#include \"" + name + "Controller.h\"");
        pw.println();

        pw.println("//#include \"lib" + name.toLowerCase() + ".h\"");
        pw.println();

        pw.println("#include <iostream>");
        pw.println();

        pw.println(name + "Controller::" + name + "Controller(){");
        pw.println("}");
        pw.println();

        pw.println(name + "Controller::~" + name + "Controller(){");
        pw.println("}");
        pw.println();

        pw.println("int " + name + "Controller::doScience( " + name + "Inputs& inputs, " + name + "Outputs& outputs ){");
        pw.println();

        pw.println("	// Call application and library initialization. Perform this ");
        pw.println("	// initialization before calling any API functions or");
        pw.println("	// Compiler-generated libraries.");
        pw.println("//	if (!mclInitializeApplication(NULL,0)){");
        pw.println("//		std::cerr << \"could not initialize the application properly\"");
        pw.println("//			<< std::endl;");
        pw.println("//		return -1;");
        pw.println("//	}");
        pw.println();

        pw.println("//	if( !lib" + name.toLowerCase() + "Initialize() ){");
        pw.println("//		std::cerr << \"could not initialize the library properly\"");
        pw.println("//			<< std::endl;");
        pw.println("//		return -1;");
        pw.println("//	}");
        pw.println();

        pw.println("//	try{");
        pw.println();

        pw.println("		// populate inputs");
        pw.println();

        pw.println("		// create outputs");
        pw.println();

        pw.println("		// invoke MATLAB function");
        pw.println();

        pw.println("		// store outputs");
        pw.println();

        pw.println("//	}catch (const mwException& e){");
        pw.println("//		std::cerr << e.what() << std::endl;");
        pw.println("//		return -2;");
        pw.println("//	}catch (...){");
        pw.println("//		std::cerr << \"Unexpected error thrown\" << std::endl;");
        pw.println("//		return -3;");
        pw.println("//	}");
        pw.println();

        pw.println("	// Call the application and library termination routine");
        pw.println("//	lib" + name.toLowerCase() + "Terminate();");
        pw.println();

        pw.println("//	mclTerminateApplication();");
        pw.println("//	return 0;");
        pw.println("}");
        pw.println();

        pw.close();
    }

    /**
     * Generates the main.cpp file
     * 
     * @throws IOException
     */
    private void genMain() throws IOException {
        File file = new File(srcDir + "/main.cpp");

        if (file.exists()) {
            log.debug("NOT generating " + file + " because it already exists");
            return;
        }

        log.debug("Generating " + file);

        FileWriter fw = new FileWriter(file);
        BufferedWriter bw = new BufferedWriter(fw);
        PrintWriter pw = new PrintWriter(bw);

        pw.println("#include <iostream>");
        pw.println();

        pw.println("#include \"" + name + "Inputs.h\"");
        pw.println("#include \"" + name + "Outputs.h\"");
        pw.println();

        pw.println("#include \"" + name + "Controller.h\"");
        pw.println();

        pw.println("#include <BinaryInputStream.h>");
        pw.println("#include <BinaryOutputStream.h>");
        pw.println("#include <IOHandler.h>");
        pw.println();

        pw.println("int main(int argc, char **argv){");
        pw.println();

        pw.println("	if( argc != 3 ){");
        pw.println("		std::cerr << \"Usage: \" << argv[0] << \" directory-name id\" << std::endl;");
        pw.println("		exit(-1);");
        pw.println("	}");
        pw.println();

        pw.println("	std::string dir = (const char*) argv[1];");
        pw.println("	std::string id = (const char*) argv[2];");
        pw.println();

        pw.println("	IOHandler ioHandler( dir, id );");
        pw.println();

        pw.println("	" + name + "Inputs input;");
        pw.println("	" + name + "Outputs output;");
        pw.println();

        pw.println("	ioHandler.loadInput( input );");
        pw.println();

        pw.println("	" + name + "Controller " + name.toLowerCase() + "Controller;");
        pw.println("	" + name.toLowerCase() + "Controller.doScience( input, output );");
        pw.println();

        pw.println("	ioHandler.saveOutput( output );");
        pw.println("}");
        pw.println();

        pw.close();
    }
}
