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

import java.io.IOException;
import java.util.*;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.spiffy.common.io.FileUtil;
import nom.tam.fits.*;
import nom.tam.util.BufferedDataInputStream;
import static gov.nasa.kepler.common.FitsConstants.*;

/**
 * Generates the World Coordinate System keywords for a given cadence.
 * 
 * @author Sean McCauliff
 *
 */
public class KeywordCopier {
    
    private static final Log log = LogFactory.getLog(KeywordCopier.class);

    private final Map<Key, List<HeaderCard>> keywordCache = 
        new HashMap<Key, List<HeaderCard>>();
    
    private final LogCrud logCrud;
    private final FileStoreClient fsClient;
    
    public KeywordCopier(LogCrud logCrud, FileStoreClient fsClient) {
        this.logCrud = logCrud;
        this.fsClient = fsClient;
    }
    
    
    public void addKeywordsToHeader(Header destHeader, Set<String> searchKeywords,
                                    int cadenceNumber, Cadence.CadenceType cadenceType) 
    throws IOException, FitsException {
        Key key = new Key(searchKeywords, cadenceNumber, cadenceType, -1, -1);
        addKeywordsToHeader(destHeader, key, searchKeywords,
            cadenceNumber, cadenceType, new HeaderFinder() {
            @Override
            public Header find(Fits src) throws IOException, FitsException {
                return src.readHDU().getHeader();
            }
        });
        
    }
    
    public void addKeywordsToHeader(Header destHeader, Set<String> searchKeywords,
                                    int cadenceNumber, Cadence.CadenceType cadenceType,
                                    final int ccdModule, final int ccdOutput)
        throws IOException, FitsException {
        
        Key key = new Key(searchKeywords, cadenceNumber, cadenceType, ccdModule, ccdOutput);
        addKeywordsToHeader(destHeader, key, searchKeywords, 
            cadenceNumber, cadenceType, new HeaderFinder() {

            @Override
            public Header find(Fits src) throws IOException, FitsException {
                for (BasicHDU hdu = src.readHDU(); hdu != null; hdu = src.readHDU()) {
                    Header header = hdu.getHeader();
                    if (!(header.getIntValue(MODULE_KW) == ccdModule &&
                        header.getIntValue(OUTPUT_KW) == ccdOutput)) {
                        continue;
                    }
                    
                    return header;
                }
                return null;
            }
            
        });
    }
    
    

    private void addKeywordsToHeader(Header destHeader, Key key, 
        Set<String> searchKeywords, 
        int cadenceNumber, Cadence.CadenceType cadenceType,
        HeaderFinder headerFinder) throws IOException, FitsException {
       
        if (keywordCache.containsKey(key)) {
            addCachedKeywords(key, destHeader);
            return;
        }
        
        log.info("Keyword cache miss on key \"" + key + "\".");
        
        List<PixelLog> pixelLogs = 
            logCrud.retrievePixelLog(cadenceType.intValue(), 
                                     cadenceNumber, cadenceNumber);

        PixelLog usePixelLog = null;
        for (PixelLog pixelLog : pixelLogs) {
            if (pixelLog.getDataSetType() == DataSetType.Target) {
                usePixelLog = pixelLog;
            }
        }
        
        if (pixelLogs.size() == 0 || usePixelLog == null) {
            log.warn("Missing pixel logs for cadence " + cadenceNumber + 
                " Not adding keywords " + 
                StringUtils.join(searchKeywords.iterator(), ','));
            return;
        }
        
        FsId pixelId = DrFsIdFactory
                .getPixelFitsHeaderFile(usePixelLog.getFitsFilename());
            
        StreamedBlobResult headerStreamResult = null;
        try {
            headerStreamResult = fsClient.readBlobAsStream(pixelId);
            Fits pixelFits = 
                new Fits(new BufferedDataInputStream(headerStreamResult.stream()));
            
            Header found = headerFinder.find(pixelFits);
            if (found == null) {
                throw new IllegalStateException("header not found");
            }
            
            List<HeaderCard> wcsKeywords = new ArrayList<HeaderCard>();
            
            for (@SuppressWarnings("unchecked") 
                 Iterator<HeaderCard> it = found.iterator(); it.hasNext(); ) {
                HeaderCard hc = it.next();
                if (searchKeywords.contains(hc.getKey())) {
                    wcsKeywords.add(hc);
                }
            }
            keywordCache.put(key, wcsKeywords);
        } finally {
            if (headerStreamResult != null) {
                FileUtil.close(headerStreamResult.stream());
            }
        }

        addCachedKeywords(key, destHeader);
        log.info("Finished with keyword cache miss for key\"" + key +"\".");
        
    }
    
    private void addCachedKeywords(Key key, Header destHeader) {
        List<HeaderCard> originalKeywords = this.keywordCache.get(key);
        for (HeaderCard wcsKeyword : originalKeywords) {
            destHeader.addLine(wcsKeyword);
        }
    }
    
    private interface HeaderFinder {
        /** @return this may return null if the header can not be found. */
        public Header find(Fits src) throws IOException, FitsException;
    }
    
    private static class Key {
        private final int cadence;
        private final int cadenceType;
        private final int ccdModule;
        private final int ccdOutput;
        private final Set<String> desiredKeywords;
        
        /**
         * @param cadence
         * @param cadenceType
         * @param ccdModule
         * @param ccdOutput
         */
        public Key(Set<String> desiredKeywords, 
            int cadence, Cadence.CadenceType cadenceType, 
            int ccdModule, int ccdOutput) {
            
            super();
            this.cadence = cadence;
            this.cadenceType = cadenceType.intValue();
            this.ccdModule = ccdModule;
            this.ccdOutput = ccdOutput;
            this.desiredKeywords = desiredKeywords;
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + cadence;
            result = prime * result + cadenceType;
            result = prime * result + ccdModule;
            result = prime * result + ccdOutput;
            result = prime * result
                + ((desiredKeywords == null) ? 0 : desiredKeywords.hashCode());
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj)
                return true;
            if (obj == null)
                return false;
            if (getClass() != obj.getClass())
                return false;
            final Key other = (Key) obj;
            if (cadence != other.cadence)
                return false;
            if (cadenceType != other.cadenceType)
                return false;
            if (ccdModule != other.ccdModule)
                return false;
            if (ccdOutput != other.ccdOutput)
                return false;
            if (desiredKeywords == null) {
                if (other.desiredKeywords != null)
                    return false;
            } else if (!desiredKeywords.equals(other.desiredKeywords))
                return false;
            return true;
        }

        
    }
    
}
