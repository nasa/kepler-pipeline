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

package gov.nasa.kepler.ar.exporter.cbv;

import java.io.IOException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.util.BufferedDataOutputStream;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.Lists;
import com.google.common.io.CountingOutputStream;

import gov.nasa.kepler.ar.archive.CotrendingBasisVectors;
import gov.nasa.kepler.ar.exporter.FitsChecksumOutputStream;
import gov.nasa.kepler.ar.exporter.binarytable.*;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FitsConstants;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.io.DataOutputStream;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.ArFsIdFactory;

import static gov.nasa.kepler.ar.exporter.cbv.CbvModOutHeaderFormatter.N_COTRENDING_BASIS_VECTORS;
import static gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing.filledMjdTimeSeries;

/**
 * Export cotrending basis vector FITS file for a single mod/out.  These are later accumulated by
 * another pipeline module, the CbvAssembler, to generate the file that has all mod/outs.
 * 
 * @author Sean McCauliff
 *
 */
public class CbvModOutExporter {

    private static final Log log = LogFactory.getLog(CbvModOutExporter.class);
    
    public void export(CbvModOutExporterSource source) throws FitsException, IOException {
        
        FsId arFsId = ArFsIdFactory.getSingleChannelCbvFile(source.ccdModule(),
            source.ccdOutput(), source.cadenceType(), source.quarter());
        
        CotrendingBasisVectors basisVectors = source.basisVectors();
        
        TimestampSeries cadenceTimes = source.cadenceTimes();
        double[] filledMjds = null;
        if (source.useFakeMjds()) {
            filledMjds = filledMjdTimeSeries(cadenceTimes.midTimestamps, cadenceTimes.gapIndicators);
        } else {
            filledMjds = markGapsWithNaN(cadenceTimes);
        }
        
        boolean[] gapsAccordingToPdc = gapsAccordingToPdc(cadenceTimes, basisVectors);
        
        String pdcSoftwareRevision = pdcVersion(source.pipelineTaskCrud(), basisVectors);
        
        CbvModOutHeaderSource headerSource = headerSource(source, pdcSoftwareRevision,
            basisVectors
            );
        
        CbvModOutHeaderFormatter headerFormatter = new CbvModOutHeaderFormatter();
        
        log.info("Computing checksum for \"" + arFsId + "\".");
        Header header = headerFormatter.formatHeader(headerSource, FitsConstants.CHECKSUM_DEFAULT);
        FitsChecksumOutputStream checkOut = new FitsChecksumOutputStream();
        BufferedDataOutputStream checkOutBuffered = 
            new BufferedDataOutputStream(checkOut);
        header.write(checkOutBuffered);
        
        byte[] binaryTableData = binaryTableData(cadenceTimes.cadenceNumbers, filledMjds, gapsAccordingToPdc, basisVectors);
        checkOutBuffered.flush();
        checkOut.write(binaryTableData);
        
        ByteArrayOutputStream bout = new ByteArrayOutputStream(binaryTableData.length + 1024*16);
        BufferedDataOutputStream headerOutput = new BufferedDataOutputStream(bout);
        header = headerFormatter.formatHeader(headerSource, checkOut.checksumString());
        header.write(headerOutput);
        headerOutput.flush();
        bout.write(binaryTableData);
        bout.flush();
        
        binaryTableData = null; //GC
        
        byte[] fitsData = bout.toByteArray();
        
        writeHdu(source, arFsId, fitsData);
    }


    /**
     * See KSOC-3845 for the specification of this flag.
     * 
     * @param cadenceTimes non-null.
     * @return An array as long as there are cadences.  true indicates a gap
     * false indicates a valid data value.
     */
    private boolean[] gapsAccordingToPdc(TimestampSeries cadenceTimes, CotrendingBasisVectors basisVectors) {

        boolean[] gapIndicators =
            Arrays.copyOf(cadenceTimes.gapIndicators, cadenceTimes.gapIndicators.length);
        boolean[] additionalGaps;
        if (basisVectors != null && basisVectors.exists()) {
            additionalGaps = basisVectors.additionalGaps();
        } else {
            additionalGaps = new boolean[gapIndicators.length];
        }
        
        for (int i=0; i < gapIndicators.length; i++) {
            gapIndicators[i] |= !cadenceTimes.isFinePnt[i];
            gapIndicators[i] |= cadenceTimes.isMmntmDmp[i];
            gapIndicators[i] |= cadenceTimes.dataAnomalyFlags.attitudeTweakIndicators[i];
            gapIndicators[i] |= cadenceTimes.dataAnomalyFlags.safeModeIndicators[i];
            gapIndicators[i] |= cadenceTimes.dataAnomalyFlags.earthPointIndicators[i];
            gapIndicators[i] |= cadenceTimes.dataAnomalyFlags.coarsePointIndicators[i];
            gapIndicators[i] |= cadenceTimes.dataAnomalyFlags.argabrighteningIndicators[i];
            gapIndicators[i] |= cadenceTimes.dataAnomalyFlags.excludeIndicators[i];
            gapIndicators[i] |= cadenceTimes.isSefiCad[i];
            gapIndicators[i] |= cadenceTimes.isSefiAcc[i];
            gapIndicators[i] |= cadenceTimes.isScrcErr[i];
            gapIndicators[i] |= cadenceTimes.isLdeOos[i];
            gapIndicators[i] |= cadenceTimes.isLdeParEr[i];
            gapIndicators[i] |= additionalGaps[i];

        }
        
        return gapIndicators;
    }


    private double[] markGapsWithNaN(TimestampSeries cadenceTimes) {
        double[] filledMjds = Arrays.copyOf(cadenceTimes.midTimestamps, cadenceTimes.cadenceNumbers.length);
          for (int i = 0; i < cadenceTimes.midTimestamps.length; i++) {
              if (cadenceTimes.gapIndicators[i]) {
                  filledMjds[i] = Double.NaN;
              }
          }
          return filledMjds;
    }


    protected void writeHdu(CbvModOutExporterSource source, FsId arFsId, byte[] fitsData) {
        log.info("Writing CBV mod/out blob to \"" + arFsId + "\".");
        source.fsClient().writeBlob(arFsId, source.pipelineTaskId(), fitsData);
    }
    
    
    /**
     * Creates the PDC version number used to create the co-trending basis
     * vectors.
     * @param pipelineTaskCrud
     * @return null if we don't have basisVectors, or "\d.\d.\d@revision" or 
     * the contents of the database string should the contents not match.
     */
    private String pdcVersion(PipelineTaskCrud pipelineTaskCrud, CotrendingBasisVectors basisVectors) {
        if (basisVectors == null || !basisVectors.exists()) {
            return null;
        }
        PipelineTask pdcTask = pipelineTaskCrud.retrieve(basisVectors.originator());
        String softwareVersionString = pdcTask.getSoftwareRevision();
        //Clean up revision string so it is shorter.
        Pattern revisionRegex = Pattern.compile("(\\d+\\.\\d+(\\.\\d+)?@\\d+)");
        Matcher m = revisionRegex.matcher(softwareVersionString);
        if (!m.find()) {
            return softwareVersionString.substring(0,Math.min(40, softwareVersionString.length()));
        }
        return m.group(1);
    }
    
    private byte[] binaryTableData(
        int[] cadenceNumbers,
        double[] mjds, 
        boolean[] dataGapsAccordingToPdc,
        CotrendingBasisVectors basisVectors) {
       
        if (basisVectors == null || basisVectors.nobandVectors().length == 0) {
            return ArrayUtils.EMPTY_BYTE_ARRAY;
        }
        
        int[] gapsAsInt = new int[cadenceNumbers.length];
        for (int i=0; i < gapsAsInt.length; i++) {
            if (dataGapsAccordingToPdc[i]) {
                gapsAsInt[i] = 1;
            }
        }
        
        List<ArrayWriter> arrayWriters = Lists.newArrayList(); 
        DoubleArrayWriter timeWriter = new DoubleArrayWriter(mjds);
        arrayWriters.add(timeWriter);
        IntArrayWriter cadenceWriter = new IntArrayWriter(cadenceNumbers);
        arrayWriters.add(cadenceWriter);
        IntArrayWriter gapWriter = new IntArrayWriter(gapsAsInt);
        arrayWriters.add(gapWriter);
        
        for (int i=0; i < N_COTRENDING_BASIS_VECTORS; i++) {
            FloatArrayWriter vectorWriter = 
                new FloatArrayWriter(basisVectors.nobandVectors()[i], null);
            arrayWriters.add(vectorWriter);
        }
        
        ByteArrayOutputStream bout = new ByteArrayOutputStream(1024*512);
        CountingOutputStream count = new CountingOutputStream(bout);
        DataOutputStream dout = new DataOutputStream(count);
        for (int cadenceIndex=0; cadenceIndex < mjds.length; cadenceIndex++) {
            for (ArrayWriter arrayWriter : arrayWriters) {
                try {
                    arrayWriter.write(cadenceIndex, dout);
                } catch (IOException e) {
                    //Actually this can't happen when writing to memory.
                    throw new IllegalStateException(e);
                }
            }
        }
        
        try {
            BinaryTableUtils.padBinaryTableData(count.getCount(), dout);
            dout.flush();
        } catch (IOException e) {
            throw new IllegalStateException(e);
        }
        
        return bout.toByteArray();
    }

    private CbvModOutHeaderSource headerSource(final CbvModOutExporterSource exporterSource,
        final String pdcSoftwareRevision,
        final CotrendingBasisVectors basisVectors) {
        
        CbvModOutHeaderSource cbvModOutHeaderSource = new CbvModOutHeaderSource() {
            
            @Override
            public double startMidMjd() {
                return exporterSource.startMjd();
            }
            
            
            @Override
            public int nBinaryTableRows() {
                if (basisVectors != null && basisVectors.exists()) {
                    return exporterSource.endCadence() - exporterSource.startCadence() + 1;
                }
                return 0;
            }
            
            @Override
            public Integer mapOrder() {
                if (basisVectors != null && basisVectors.exists()) {
                    return basisVectors.mapOrder();
                }
                return null;
            }
            
            
            @Override
            public double endMidMjd() {
                return exporterSource.endMjd();
            }
            
            @Override
            public double elaspedTime() {
                return exporterSource.endMjd() - exporterSource.startMjd();
            }
            
            @Override
            public int ccdOutput() {
                return exporterSource.ccdOutput();
            }
            
            @Override
            public int ccdModule() {
                return exporterSource.ccdModule();
            }
            
            @Override
            public int ccdChannel() {
                return FcConstants.getChannelNumber(ccdModule(), ccdOutput());
            }

            @Override
            public Date generatedAt() {
                return exporterSource.generatedAt();
            }
            
            @Override
            public String pdcVersion() {
                return pdcSoftwareRevision;
            }
        };
        
        return cbvModOutHeaderSource;
    }
}
