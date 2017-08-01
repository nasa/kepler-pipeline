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

import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.List;

import org.apache.xmlbeans.XmlOptions;

import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.xmlbean.DoubleDataPointTypeXB;
import gov.nasa.kepler.fs.xmlbean.DoubleTimeSeriesTypeXB;
import gov.nasa.kepler.fs.xmlbean.FloatDataPointTypeXB;
import gov.nasa.kepler.fs.xmlbean.FloatMjdDataPointXB;
import gov.nasa.kepler.fs.xmlbean.FloatMjdTimeSeriesExportDocument;
import gov.nasa.kepler.fs.xmlbean.FloatMjdTimeSeriesExportTypeXB;
import gov.nasa.kepler.fs.xmlbean.FloatMjdTimeSeriesTypeXB;
import gov.nasa.kepler.fs.xmlbean.FloatTimeSeriesTypeXB;
import gov.nasa.kepler.fs.xmlbean.IntDataPointTypeXB;
import gov.nasa.kepler.fs.xmlbean.IntTimeSeriesTypeXB;
import gov.nasa.kepler.fs.xmlbean.TimeSeriesExportDocument;
import gov.nasa.kepler.fs.xmlbean.TimeSeriesExportTypeXB;
import gov.nasa.kepler.fs.xmlbean.TimeSeriesTypeXB;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

/**
 * Export time series data to xml.
 * 
 * @author Sean McCauliff
 *
 */
public class TimeSeriesXmlExporter {

	private final XmlOptions exportOptions;
	public TimeSeriesXmlExporter() {
		exportOptions = new XmlOptions();
		exportOptions.setSavePrettyPrint();
		exportOptions.setValidateOnSet();
		
	}
	
	
	public void export(Writer bwriter, TimeSeries[] timeSeries) throws IOException {
	    TimeSeriesExportDocument doc = 
	        TimeSeriesExportDocument.Factory.newInstance(exportOptions);
	    TimeSeriesExportTypeXB xmlTimeSeriesExport = doc.addNewTimeSeriesExport();
	    for (TimeSeries ts : timeSeries) {
	        switch(ts.dataType()) {
	            case FloatType:
	                addTimeSeries((FloatTimeSeries) ts, xmlTimeSeriesExport);
	                break;
	            case IntType:
	                addTimeSeries((IntTimeSeries)ts, xmlTimeSeriesExport);
	                break;
	            case DoubleType:
	                addTimeSeries((DoubleTimeSeries)ts, xmlTimeSeriesExport);
	                break;
	            default:
	                throw new IllegalStateException("Unhandled type \"" + ts.dataType() + "\".");
	        }
	    }
	    
        doc.save(bwriter, exportOptions);
        bwriter.flush();
        
	    XmlOptions validationOptions = new XmlOptions();
	    List<Object> errorList = new ArrayList<Object>();
	    validationOptions.setErrorListener(errorList);
	    if (!doc.validate(validationOptions)) {
	        StringBuilder bldr = new StringBuilder();
	        for (Object errObject : errorList) {
	            bldr.append(errObject.toString()).append('\n');
	        }
            throw new IllegalStateException("Xml validation failed.\n" + bldr.toString());
        }

	}
	
	private void addTimeSeries(FloatTimeSeries fts, TimeSeriesExportTypeXB timeSeriesExport) {
	    FloatTimeSeriesTypeXB xmlSeries = timeSeriesExport.addNewFloatSeries();
	    assignAttributes(xmlSeries, fts);
	    float[] fdata = fts.fseries();
	    for (TaggedInterval originator : fts.originators()) {
	        for (int cadence = (int) originator.start(); cadence <= originator.end(); cadence++) {
	            FloatDataPointTypeXB xmlDataPoint = xmlSeries.addNewData();
	            xmlDataPoint.setC(cadence);
	            xmlDataPoint.setO(originator.tag());
	            xmlDataPoint.setV(fdata[cadence - fts.startCadence()]);
	        }
	    }
	}

	private void addTimeSeries(IntTimeSeries its, TimeSeriesExportTypeXB timeSeriesExport) {
	    IntTimeSeriesTypeXB xmlSeries = timeSeriesExport.addNewIntSeries();
	    assignAttributes(xmlSeries, its);
	    int[] idata = its.iseries();
	    for (TaggedInterval originator : its.originators()) {
	        for (int cadence = (int) originator.start(); cadence <= originator.end(); cadence++) {
	            IntDataPointTypeXB xmlDataPoint = xmlSeries.addNewData();
	            xmlDataPoint.setC(cadence);
	            xmlDataPoint.setO(originator.tag());
	            xmlDataPoint.setV(idata[cadence - its.startCadence()]);
	        }
	    }
	}
	
	private void addTimeSeries(DoubleTimeSeries dts, TimeSeriesExportTypeXB timeSeriesExport) {
	    DoubleTimeSeriesTypeXB xmlSeries = timeSeriesExport.addNewDoubleSeries();
	    assignAttributes(xmlSeries, dts);
	    double[] ddata = dts.dseries();
	    for (TaggedInterval originator : dts.originators()) {
	        for (int cadence = (int) originator.start(); cadence <= originator.end(); cadence++) {
	            DoubleDataPointTypeXB xmlDataPoint = xmlSeries.addNewData();
	            xmlDataPoint.setC(cadence);
	            xmlDataPoint.setO(originator.tag());
	            xmlDataPoint.setV(ddata[cadence - dts.startCadence()]);
	        }
	    }
	}
	   
	public void export(Writer bwriter, FloatMjdTimeSeries[] timeSeries) throws IOException {
		FloatMjdTimeSeriesExportDocument doc = FloatMjdTimeSeriesExportDocument.Factory.newInstance(exportOptions);
		FloatMjdTimeSeriesExportTypeXB xmlExport = doc.addNewFloatMjdTimeSeriesExport();
		
		for (FloatMjdTimeSeries fmts : timeSeries) {
			FloatMjdTimeSeriesTypeXB xmlTimeSeries = xmlExport.addNewFseries();
			if (!fmts.exists()) {
				xmlTimeSeries.setExists(false);
			}
			xmlTimeSeries.setFsId(fmts.id().toString());
			xmlTimeSeries.setMjdEnd(fmts.endMjd());
			xmlTimeSeries.setMjdStart(fmts.startMjd());
			float[] values = fmts.values();
			long[] originators = fmts.originators();
			double[] mjds = fmts.mjd();
			
			for (int i=0; i < values.length; i++) {
				FloatMjdDataPointXB dataPoint = xmlTimeSeries.addNewData();
				dataPoint.setM(mjds[i]);
				dataPoint.setO(originators[i]);
				dataPoint.setV(values[i]);
			}
		}
		
		if (!doc.validate(exportOptions)) {
			throw new IllegalStateException("Bad xml export format.");
		}
		doc.save(bwriter, exportOptions);
		bwriter.flush();
	}
	
	private void assignAttributes(TimeSeriesTypeXB xmlTimeSeries, TimeSeries timeSeries) {
		xmlTimeSeries.setEndCadence(timeSeries.endCadence());
		if (!timeSeries.exists()) {
			xmlTimeSeries.setExists(false);
		}
		xmlTimeSeries.setFsId(timeSeries.id().toString());
		xmlTimeSeries.setStartCadence(timeSeries.startCadence());
	}
	
}
