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

package gov.nasa.kepler.etem2;

import gov.nasa.kepler.common.FcConstants;

import java.io.File;
import java.io.FileInputStream;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTable;
import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Data;
import nom.tam.fits.Fits;
import nom.tam.fits.Header;
import nom.tam.fits.ImageData;
import nom.tam.fits.ImageHDU;
import nom.tam.util.BufferedFile;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * Adds, replaces or deletes attributes in the primary and/or secondary headers
 * in a FITS file.
 * 
 * @author jgunter
 * 
 */
public class FitsHeaderEditor {

    /**
     * Logger for this class
     */
    private static final Log log = LogFactory.getLog(FitsHeaderEditor.class);

    /**
     * @param args An arg containing '=' is an attribute=value assignment.
     * 
     * If the attribute starts with 'p:' it is set only in the primary header
     * (the first HDU).
     * 
     * If the attribute starts with 's:' it is set only in the secondary
     * headers.
     * 
     * If the attribute starts with 'ps:' it is set in both the primary and
     * secondary headers.
     * 
     * If value is an empty string, the attribute will be removed from the
     * header.
     * 
     * If value is not an empty string, the attribute will be replaced in or
     * added to the header.
     * 
     * An arg that is a path to a directory will be the output directory.
     * 
     * An arg that is a file will be one of the input files processed.
     */
    public static void main(String[] args) throws Exception {
        Logger logger = Logger.getLogger(FitsDiff.class);
        logger.setLevel(Level.INFO);
        org.apache.log4j.BasicConfigurator.configure();

        HashMap<String, Object> primaryHeaderAttributeValuePairs = new HashMap<String, Object>();
        HashMap<String, Object> secondaryHeaderAttributeValuePairs = new HashMap<String, Object>();
        List<String> inputFilenames = new LinkedList<String>();
        File outputDir = null;

        for (String arg : args) {
            int i;
            if (-1 != (i = arg.indexOf("="))) {
                String attr = arg.substring(0, i)
                    .trim();
                String value = arg.substring(i + 1)
                    .trim();
                if (value.length() == 0) {
                    value = null;
                }
                String whichHeaders = "p";
                if (-1 != (i = attr.indexOf(':'))) {
                    whichHeaders = attr.substring(0, i);
                    attr = attr.substring(i + 1);
                }
                if (-1 != whichHeaders.indexOf('p')) {
                    primaryHeaderAttributeValuePairs.put(attr, value);
                }
                if (-1 != whichHeaders.indexOf('s')) {
                    secondaryHeaderAttributeValuePairs.put(attr, value);
                }
            } else {
                File f = new File(arg);
                if (f.isDirectory()) {
                    outputDir = f;
                } else {
                    inputFilenames.add(arg);
                }
            }
        }

        new FitsHeaderEditor().editFiles(inputFilenames, outputDir,
            primaryHeaderAttributeValuePairs,
            secondaryHeaderAttributeValuePairs);
    }

    /**
     * @param inputDir directory containing files to be processed.
     * @param outputDir if null, new FITS files are written with .new suffix in
     * same directory as input files.
     * @param primaryHeaderAttributeValuePairs attribute values for primary
     * header. null values indicate attributes to be deleted from headers.
     * @param secondaryHeaderAttributeValuePairs attribute values for secondary
     * header. null values indicate attributes to be deleted from headers.
     * @throws Exception on nom.tam.fits or java.io errors.
     */
    public void editFiles(String inputDir, String outputDir,
        HashMap<String, Object> primaryHeaderAttributeValuePairs,
        HashMap<String, Object> secondaryHeaderAttributeValuePairs)
        throws Exception {
        editFiles(new File(inputDir), new File(outputDir),
            primaryHeaderAttributeValuePairs,
            secondaryHeaderAttributeValuePairs);
    }

    /**
     * @param inputDir directory containing files to be processed.
     * @param outputDir if null, new FITS files are written with .new suffix in
     * same directory as input files.
     * @param primaryHeaderAttributeValuePairs attribute values for primary
     * header. null values indicate attributes to be deleted from headers.
     * @param secondaryHeaderAttributeValuePairs attribute values for secondary
     * header. null values indicate attributes to be deleted from headers.
     * @throws Exception on nom.tam.fits or java.io errors.
     */
    public void editFiles(File inputDir, File outputDir,
        HashMap<String, Object> primaryHeaderAttributeValuePairs,
        HashMap<String, Object> secondaryHeaderAttributeValuePairs)
        throws Exception {
        List<String> filenames = new LinkedList<String>();
        filenames.addAll(Arrays.asList(inputDir.list()));
        editFiles(filenames, outputDir, primaryHeaderAttributeValuePairs,
            secondaryHeaderAttributeValuePairs);
    }

    /*
     * public void editFiles(List<String> fitsFilenames, File outputDir,
     * HashMap<String,Object> primaryHeaderAttributeValuePairs, HashMap<String,Object>
     * secondaryHeaderAttributeValuePairs) throws Exception { List<File>
     * fitsFiles = new LinkedList<File>; for (int i = 0; i <
     * fitsFilenames.length; i++) { fitsFiles[i] = new File(fitsFilenames[i]); }
     * editFiles(fitsFiles, outputDir, primaryHeaderAttributeValuePairs,
     * secondaryHeaderAttributeValuePairs); }
     */

    /**
     * @param fitsFilenames a list of input file paths.
     * @param outputDir if null, new FITS files are written with .new suffix in
     * same directory as input files.
     * @param primaryHeaderAttributeValuePairs attribute values for primary
     * header. null values indicate attributes to be deleted from headers.
     * @param secondaryHeaderAttributeValuePairs attribute values for secondary
     * header. null values indicate attributes to be deleted from headers.
     * @throws Exception on nom.tam.fits or java.io errors.
     */
    public void editFiles(List<String> fitsFilenames, File outputDir,
        HashMap<String, Object> primaryHeaderAttributeValuePairs,
        HashMap<String, Object> secondaryHeaderAttributeValuePairs)
        throws Exception {
        File newFile;
        for (String fitsFilename : fitsFilenames) {
            File fitsFile = new File(fitsFilename);
            if (outputDir == null) {
                newFile = new File(fitsFile.getAbsolutePath() + ".new");
            } else {
                newFile = new File(outputDir, fitsFile.getName());

            }
            editFile(fitsFile, newFile, primaryHeaderAttributeValuePairs,
                secondaryHeaderAttributeValuePairs);
        }

    }

    /**
     * @param inputFile a File object pointing to a FITS file.
     * @param outputFile a File object pointing to the FITS file to create.
     * @param primaryHeaderAttributeValuePairs attribute values for primary
     * header. null values indicate attributes to be deleted from headers.
     * @param secondaryHeaderAttributeValuePairs attribute values for secondary
     * header. null values indicate attributes to be deleted from headers.
     * @throws Exception on nom.tam.fits or java.io errors.
     */
    public void editFile(File inputFile, File outputFile,
        HashMap<String, Object> primaryHeaderAttributeValuePairs,
        HashMap<String, Object> secondaryHeaderAttributeValuePairs)
        throws Exception {
        BufferedFile output = new BufferedFile(outputFile.getAbsolutePath(),
            "rw");

        Fits input = new Fits(new FileInputStream(inputFile));

        HashMap<String, Object> attributeValuePairs = primaryHeaderAttributeValuePairs;

        for (int i = 0; i <= FcConstants.MODULE_OUTPUTS; i++) {
            log.debug("processing HDU #" + i);
            BasicHDU inHdu = input.getHDU(i);
            if (inHdu == null) {
                break;
            }

            Header header = inHdu.getHeader();

            // TODO for non-primary headers, we generally do not want to add new
            // attributes.
            // Do I need to pass a list of k=v for replacements and another list
            // for additions?
            
            if ( attributeValuePairs == null) {
                attributeValuePairs = new HashMap<String, Object>();
            }

            // fix attributes
            for (Object key : attributeValuePairs.keySet()) {
                String attr = (String) key;
                Object value = attributeValuePairs.get(key);
                if (value == null) {
                    header.deleteKey(attr);
                } else if (value instanceof Boolean) {
                    header.addValue(attr, (Boolean) value, "");
                } else if (value instanceof Double) {
                    header.addValue(attr, (Double) value, "");
                } else if (value instanceof Integer) {
                    header.addValue(attr, (Integer) value, "");
                } else if (value instanceof String) {
                    header.addValue(attr, (String) value, "");
                } else {
                    throw new Exception("unhandled type of value ("
                        + value.getClass() + ") for attribute '" + attr + "'");
                }
            }

            BasicHDU outHdu;

            Data data = inHdu.getData();
            if (data instanceof BinaryTable) {
                outHdu = new BinaryTableHDU(header, data);
                outHdu.write(output);
            } else if (data instanceof ImageData) {
                outHdu = new ImageHDU(header, data);
                outHdu.write(output);
            } else {
                header.write(output);
            }

            output.flush();

            attributeValuePairs = secondaryHeaderAttributeValuePairs;
        }

        output.close();
    }

}
