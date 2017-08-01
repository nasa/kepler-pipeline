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

import gov.nasa.kepler.fs.FileStoreConstants;

import java.io.*;
import java.util.*;

import org.antlr.stringtemplate.StringTemplate;
import org.antlr.stringtemplate.StringTemplateGroup;

/**
 * Generates the various XTimeSeries classes.
 * 
 * @author Sean McCauliff
 *
 */
public class TimeSeriesGenerator {

    private final Map<String, TemplateParameters> cliParameterToTemplateParameters;

    private void printUsage() {
        System.out.println("Usage: TimeSeriesGenerator <output dir> < int, float, double>+");
    }
    
    TimeSeriesGenerator() {
        cliParameterToTemplateParameters = new HashMap<String, TemplateParameters>();
        
        String enumConstructor = "%s(\"%s\",(byte) %d,%d)";
        String intEnumName = "IntType";
        String intSmallType = "int";
        String intEnumConstructor = String.format(enumConstructor, intEnumName, intSmallType, FileStoreConstants.INT_TYPE, Integer.SIZE/8); 
        TemplateParameters intParameters = 
            new TemplateParameters(intSmallType, "Int", "false", "iseries", "readInt", 
                "writeInt", "Integer.parseInt", intEnumName, intEnumConstructor);
        cliParameterToTemplateParameters.put("int", intParameters);
        
        String floatEnumName = "FloatType";
        String floatSmallType = "float";
        String floatEnumConstructor = String.format(enumConstructor, floatEnumName, floatSmallType, FileStoreConstants.FLOAT_TYPE, Float.SIZE/8);
        TemplateParameters floatParameters = 
            new TemplateParameters(floatSmallType, "Float", "true", "fseries", 
                "readFloat", "writeFloat", "Float.parseFloat", 
                floatEnumName, floatEnumConstructor);
        cliParameterToTemplateParameters.put("float", floatParameters);
        
        String doubleEnumName = "DoubleType";
        String doubleSmallType = "double";
        String doubleEnumConstructor = String.format(enumConstructor, doubleEnumName, doubleSmallType, FileStoreConstants.DOUBLE_TYPE, Double.SIZE/8);
        
        TemplateParameters doubleParameters = 
            new TemplateParameters(doubleSmallType, "Double", "false", "dseries", 
                "readDouble", "writeDouble", "Double.parseDouble", 
                doubleEnumName, doubleEnumConstructor);
        cliParameterToTemplateParameters.put("double", doubleParameters);
        
    }
    
    
    private void generate(String[] argv) throws Exception {
        if (argv.length == 0) {
            printUsage();
            return;
        }
        
        File outputRoot = new File(argv[0]);
        gov.nasa.spiffy.common.io.FileUtil.mkdirs(outputRoot);
        StringTemplateGroup timeSeriesGroup = new StringTemplateGroup(new FileReader("grammar/StringTemplate.stg"));
        
        List<TemplateParameters> types = new ArrayList<TemplateParameters>();
        for (int i=1; i < argv.length; i++) {
            TemplateParameters type = cliParameterToTemplateParameters.get(argv[i]);
            if (type == null) {
                throw new IllegalArgumentException("Bad type \"" + argv[i] + "\".");
            }
            types.add(type);
        }
        
        for (TemplateParameters type : types) {
            instantiateTimeSeriesTemplate(type, timeSeriesGroup, outputRoot);
        }
        instantiateDataTypeEnum(types, timeSeriesGroup, outputRoot);
    }
    
    private void instantiateTimeSeriesTemplate(TemplateParameters parameters,
        StringTemplateGroup timeSeriesGroup, File outputRoot) throws IOException {

        if (parameters == null) {
           
        }
        
        StringTemplate timeSeriesTemplate = timeSeriesGroup.getInstanceOf("TimeSeriesTemplate");
        timeSeriesTemplate.setAttribute("smallType", parameters.smallType);
        timeSeriesTemplate.setAttribute("classPrefix", parameters.classPrefix);
        timeSeriesTemplate.setAttribute("isFloat", parameters.isFloat);
        timeSeriesTemplate.setAttribute("seriesName", parameters.seriesName);
        timeSeriesTemplate.setAttribute("readMethod", parameters.readMethod);
        timeSeriesTemplate.setAttribute("writeMethod", parameters.writeMethod);
        timeSeriesTemplate.setAttribute("parseStringMethod", parameters.parseStringMethod);
        timeSeriesTemplate.setAttribute("enumTypeName", parameters.enumTypeName);
        
        File outputFile = new File(outputRoot, parameters.classPrefix + "TimeSeries.java");
        FileWriter fileWriter = new FileWriter(outputFile);
        fileWriter.write(timeSeriesTemplate.toString());
        fileWriter.close();
        
        System.out.println("Generated time series for " + parameters.smallType);
    }
    
    private void instantiateDataTypeEnum(Collection<TemplateParameters> dataTypes, 
        StringTemplateGroup timeSeriesGroup, File outputRoot) throws IOException {
        StringTemplate dataTypeTemplate = timeSeriesGroup.getInstanceOf("TimeSeriesDataTypeTemplate");
        for (TemplateParameters dataType : dataTypes) {
            dataTypeTemplate.setAttribute("types",dataType);
        }
        File outputFile = new File(outputRoot, "TimeSeriesDataType.java");
        FileWriter fileWriter = new FileWriter(outputFile);
        fileWriter.write(dataTypeTemplate.toString());
        fileWriter.close();
        
        System.out.println("Generated TimeSeriesDataType");
    }


    /**
     * @param args
     */
    public static void main(String[] argv) throws Exception  {
        
        TimeSeriesGenerator generator = new TimeSeriesGenerator();
        
        generator.generate(argv);

      
    }
    
    private static final class TemplateParameters {
        public final String smallType;
        public final String classPrefix;
        public final String isFloat;
        public final String seriesName;
        public final String readMethod;
        public final String writeMethod;
        public final String parseStringMethod;
        public final String enumTypeName;
        @SuppressWarnings("unused")
		public final String enumConstructor;
        
        /**
         * @param smallType
         * @param classPrefix
         * @param isFloat
         * @param seriesName
         * @param readMethod
         * @param writeMethod
         * @param parseStringMethod
         * @param pointSize
         * @param enumTypeName
         * @param eunmConstructor
         */
        public TemplateParameters(String smallType, String classPrefix,
            String isFloat, String seriesName, String readMethod,
            String writeMethod, String parseStringMethod,
            String enumTypeName, String enumConstructor) {
            super();
            this.smallType = smallType;
            this.classPrefix = classPrefix;
            this.isFloat = isFloat;
            this.seriesName = seriesName;
            this.readMethod = readMethod;
            this.writeMethod = writeMethod;
            this.parseStringMethod = parseStringMethod;
            this.enumTypeName = enumTypeName;
            this.enumConstructor = enumConstructor;
        }

    }
    

}
