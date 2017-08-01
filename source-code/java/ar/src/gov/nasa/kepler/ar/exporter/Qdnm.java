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

package gov.nasa.kepler.ar.exporter;

import static gov.nasa.kepler.common.file.Md5Sum.computeMd5;
import gov.nasa.kepler.nm.DataProductMessageDocument;
import gov.nasa.kepler.nm.DataProductMessageXB;
import gov.nasa.kepler.nm.FileListXB;
import gov.nasa.kepler.nm.FileXB;

import java.io.File;
import java.io.IOException;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;
import java.util.concurrent.atomic.AtomicInteger;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlException;
import org.apache.xmlbeans.XmlOptions;

/**
 * Constructs the QDNM message which is sent with all the files that AR 
 * archives.  This class is MT-safe.
 * 
 * @author Sean McCauliff
 *
 */
public class Qdnm {
    
	private static final Log log = LogFactory.getLog(Qdnm.class);
	
    private final DataProductMessageDocument messageDoc;
    private final DataProductMessageXB message;
    private final FileListXB fileList;
    private final AtomicInteger fileCount = new AtomicInteger();

    /**
     * Use this constructor to read in an existing one.
     * @param sdnmFile
     */
    public Qdnm(File qdnmFile, boolean sparse) throws IOException  {
        try {
            messageDoc = DataProductMessageDocument.Factory.parse(qdnmFile);
            if (!messageDoc.validate()) {
                throw new IllegalArgumentException("Invalid sdnm file.");
            }
            
            message = messageDoc.getDataProductMessage();
            
            fileList = message.getFileList();
            
            for (FileXB product : fileList.getFileArray()) {
                String md5 = computeMd5(new File( qdnmFile.getParent(), product.getFilename()), sparse);
                if (!md5.equals(product.getChecksum())) {
                    throw new IllegalArgumentException("Invalid md5 on file \"" + product.getFilename());
                }
            }
            
        } catch (XmlException xmle) {
            throw new IOException(xmle.toString());
        }
    }
    
    /**
     * Use this constructor to read in a new one.
     *
     */
    public Qdnm() {
        
        messageDoc = DataProductMessageDocument.Factory.newInstance();
        message = messageDoc.addNewDataProductMessage();
        Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        calendar.setTime(new Date());
        message.setMessageType("QDNM");
        
        fileList = message.addNewFileList();
    }
    
    public void addDataProduct(File productFile, boolean sparse) throws IOException {
   
    	String md5String = computeMd5(productFile, sparse);
    	
    	FileXB product = null;
    	synchronized (this) {
    		product = fileList.addNewFile();
    	}
    	
        product.setChecksum(md5String);
        product.setFilename(productFile.getName());
        product.setSize(productFile.length());
        
        int count = fileCount.getAndIncrement();
        if ((count % 1000) == 0) {
        	log.info("Added " + count + "th file to qdnm.");
        }
    }
    
   
    
    /**
     * Validates the QDNM and writes it out the QDNM to a file.
     * @param sdnmFile  The file to write the QDNM into.
     */
    public synchronized void export(File sdnmFile) throws IOException {
        message.setIdentifier(sdnmFile.getName());
        XmlOptions opts = new XmlOptions();
        opts.setSavePrettyPrint();
        messageDoc.save(sdnmFile, opts);
    }

}
