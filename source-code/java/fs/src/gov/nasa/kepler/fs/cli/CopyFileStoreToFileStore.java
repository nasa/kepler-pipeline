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

import java.util.*;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesBatch;
import gov.nasa.kepler.fs.client.FstpClient;
import gov.nasa.kepler.fs.query.QueryEvaluator;
import gov.nasa.kepler.fs.query.QueryEvaluator.DataType;
import gov.nasa.spiffy.common.collect.ListChunkIterator;
import gov.nasa.spiffy.common.concurrent.Actor;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

import com.google.common.collect.Lists;

/**
 * Copies from one file store to another.
 * 
 * @author Sean McCauliff
 *
 */
public class CopyFileStoreToFileStore {
    
    @SuppressWarnings("static-access")
    private final Option srcOption = 
            OptionBuilder.isRequired()
            .hasArg()
            .withLongOpt("src")
            .withDescription("Source fstp URL.")
            .withArgName("fstpUrl")
            .create("s");
    
    @SuppressWarnings("static-access")
    private final Option destOption = 
            OptionBuilder.isRequired()
            .hasArg()
            .withLongOpt("dest")
            .withDescription("Destination fstp URL.")
            .withArgName("fstpUrl")
            .create("d");
    
    @SuppressWarnings("static-access")
    private final Option fsIdQueryOption = 
            OptionBuilder.isRequired()
            .hasArg()
            .withLongOpt("id-query")
            .withDescription("FsId query specification.  (e.g. \"/cal/*\").")
            .withArgName("query")
            .create("q");
    
    @SuppressWarnings("static-access")
    private final Option typeOption = 
            OptionBuilder.isRequired()
            .hasArg()
            .withLongOpt("type")
            .withDescription("Type is one of {blob, ts, mts}.")
            .withArgName("type")
            .create("t");
    
    @SuppressWarnings("static-access")
    private final Option timeConstraintOption =
            OptionBuilder.isRequired()
            .hasArg()
            .withLongOpt("time-constraint")
            .withDescription("Time constraints as start,stop. (e.g. \"3000,4000\").  cadence ranges for time series and mjd for mjd time series.")
            .withArgName("start,stop")
            .create("c");

    @SuppressWarnings("static-access")
    private final Option allowOverwriteOption = 
        OptionBuilder.hasArg(false)
        .withLongOpt("force")
        .withDescription("Force overwrite of time series on the destination file store server.")
        .create("f");
    
    @SuppressWarnings("static-access")
    private final Option chunkSizeOption =
    	OptionBuilder.hasArg(true)
    	.withLongOpt("chunk-size")
    	.withDescription("Number of time series or blobs to read at a time.")
    	.withArgName("number")
    	.create("k");
    
    @SuppressWarnings("serial")
    private final Options options = new Options() {{
            addOption(srcOption);
            addOption(destOption);
            addOption(fsIdQueryOption);
            addOption(typeOption);
            addOption(timeConstraintOption);
            addOption(allowOverwriteOption);
            addOption(chunkSizeOption);
        }
    };
    
    
    private String srcFstpUrl;
    private String destFstpUrl;
    private String fsIdQuery;
    private QueryEvaluator.DataType dataType;
    private double startTime = -1;
    private double endTime = -1;
    private boolean allowOverwrite = false;
	private int chunkSize;
    
	private final ExecutorService xService = Executors.newFixedThreadPool(10);

    
    private void printHelp() {
        HelpFormatter helpFormatter = new HelpFormatter();
        helpFormatter.printHelp(80, "./runjava fscp ", "", options, "", true);
    }
    
    private void parseOptions(String[] argv) throws ParseException {
        if (argv.length == 0) {
            printHelp();
            System.exit(-1);
        }
        
        GnuParser gnuParser = new GnuParser();
        CommandLine cmdLine = gnuParser.parse(options, argv);
        srcFstpUrl = cmdLine.getOptionValue(srcOption.getOpt());
        System.out.println("src: " + srcFstpUrl);
        destFstpUrl = cmdLine.getOptionValue(destOption.getOpt());
        System.out.println("dest: " + destFstpUrl);
        
        fsIdQuery = cmdLine.getOptionValue(fsIdQueryOption.getOpt());
        if (cmdLine.getOptionValue(typeOption.getOpt()).equals("blob")) {
            dataType = QueryEvaluator.DataType.Blob;
        } else if (cmdLine.getOptionValue(typeOption.getOpt()).equals("mts")) {
            dataType = QueryEvaluator.DataType.MjdTimeSeries;
        } else if (cmdLine.getOptionValue(typeOption.getOpt()).equals("ts")) {
            dataType = QueryEvaluator.DataType.TimeSeries;
        } else {
            throw new IllegalArgumentException("Invalid data type \"" + 
                typeOption.getValue() + "\".");
        }
        
        //TODO:  this should be optional at some point
        String[] parts = cmdLine.getOptionValue(timeConstraintOption.getOpt()).split(",");
        startTime = Double.parseDouble(parts[0]);
        endTime = Double.parseDouble(parts[1]);
        
        allowOverwrite = cmdLine.hasOption(allowOverwriteOption.getOpt());
        
        if (cmdLine.hasOption(chunkSizeOption.getOpt())) {
            chunkSize = Integer.parseInt(cmdLine.getOptionValue(chunkSizeOption.getOpt()));
        } else {
        	switch (dataType) {
        	case Blob: chunkSize = 1; break;
        	case TimeSeries: chunkSize = 1024; break;
        	case MjdTimeSeries: chunkSize = 1024; break;
        	default: throw new IllegalStateException("dataType: " + dataType);
        	}
        }
    }
    
    private void copy() throws Exception {
        final FstpClient srcClient = new FstpClient(srcFstpUrl);
        final FstpClient destClient = new FstpClient(destFstpUrl);

        DestinationWriter destWriter = 
        		new DestinationWriter(destClient);
        xService.submit(destWriter);
        SourceReader sourceReader = 
        		new SourceReader(destWriter, srcClient);
        xService.submit(sourceReader);
        
        Actor<ReadRequest> afterFsIdProducer = sourceReader;
        if (!allowOverwrite) {
        	afterFsIdProducer = new PreventOverwrite(sourceReader, destClient);
        	xService.submit(afterFsIdProducer);
        }
        String queryStr = dataType.name()+"@"+fsIdQuery;
        
        FsIdProducer fsIdProducer = new FsIdProducer(afterFsIdProducer, srcClient,
        		queryStr, dataType, startTime, endTime, chunkSize);
        xService.submit(fsIdProducer);
        fsIdProducer.blockingSend("go");
        destWriter.done.await();
    }
    
 
    private interface WriteRequest {
        void writeTo(FileStoreClient fsClient);
    }
    
    private static final class EndWriteRequest implements WriteRequest {
    	static EndWriteRequest INSTANCE = new EndWriteRequest();
    	public void writeTo(FileStoreClient fsClient) {
    		throw new IllegalStateException("should never be called");
    	}
    }
    
    private interface ReadRequest {
        Collection<WriteRequest> readFrom(FileStoreClient fsClient);
    }
    
    private static final class EndReadRequest implements ReadRequest {
    	static EndReadRequest INSTANCE = new EndReadRequest();
    	private EndReadRequest() {}
    	
		@Override
		public Collection<WriteRequest> readFrom(FileStoreClient fsClient) {
			throw new IllegalStateException("should never be called");
		}
    	
    }
    
    private static final class TimeSeriesWriteRequest implements WriteRequest {
    	
    	private final TimeSeries[] timeSeries;
    	
    	TimeSeriesWriteRequest(TimeSeriesBatch tsBatch) {
    		this.timeSeries = tsBatch.timeSeries().values().toArray(new TimeSeries[0]);
    	}
    	@Override
    	public void writeTo(FileStoreClient fsClient) {
    		fsClient.writeTimeSeries(timeSeries);
    	}
    }
    
    private static final class TimeSeriesReadRequest implements ReadRequest {
        private final Set<FsId> idsToRead;
        private final int startCadence;
        private final int endCadence;
        
        //TODO:  start and end cadence may need to be dynamic, depending on the
        //time series.
        TimeSeriesReadRequest(Collection<FsId> fsIds, int startCadence, int endCadence) {
        	this.idsToRead = new HashSet<FsId>(fsIds);
        	this.startCadence = startCadence;
        	this.endCadence = endCadence;
        }
        
        @Override
        public Collection<WriteRequest> readFrom(FileStoreClient fsClient) {
        	FsIdSet fsIdSet = new FsIdSet(startCadence, endCadence, idsToRead);
        	List<FsIdSet> fetchSet = Collections.singletonList(fsIdSet);
            List<TimeSeriesBatch> timeSeriesBatches = 
            		fsClient.readTimeSeriesBatch(fetchSet, true);
            List<WriteRequest> rv = Lists.newArrayListWithCapacity(timeSeriesBatches.size());
            for (TimeSeriesBatch tsBatch : timeSeriesBatches) {
            	rv.add(new TimeSeriesWriteRequest(tsBatch));
            }
            return rv;
        }
    }
     
    private static final class DestinationWriter extends Actor<WriteRequest> {

    	private final FileStoreClient destinationClient;
    	private final CountDownLatch done = new CountDownLatch(1);
		protected DestinationWriter(FileStoreClient destinationClient) {
			this.destinationClient = destinationClient;
		}

		@Override
		protected void act(WriteRequest message) throws Exception {
			destinationClient.beginLocalFsTransaction();
			boolean complete = false;
			try {
				message.writeTo(destinationClient);
				destinationClient.commitLocalFsTransaction();
				complete = true;
			} finally {
				if (!complete) {
					destinationClient.rollbackLocalFsTransactionIfActive();
				}
			}
		}
		
		@Override
		protected boolean isDoneProducing(WriteRequest message) {
			if (message == EndWriteRequest.INSTANCE) {
				done.countDown();
				return true;
			} else {
				return false;
			}
		}
		
		@Override
		protected void handleException(Exception e) {
			done.countDown();
			super.handleException(e);
		}
    	
    }
    
    private static final class SourceReader extends Actor<ReadRequest> {

    	private final Actor<WriteRequest> destinationWriter;
    	private final FileStoreClient sourceClient;
    	
		protected SourceReader(Actor<WriteRequest> destinationWriter, FileStoreClient sourceClient) {
			this.destinationWriter = destinationWriter;
			this.sourceClient = sourceClient;
		}

		@Override
		protected void act(ReadRequest message) throws Exception {
			Collection<WriteRequest> writeRequests = 
					message.readFrom(sourceClient);
			for (WriteRequest writeRequest : writeRequests) {
				destinationWriter.blockingSend(writeRequest);
			}
		}
		
		@Override
		protected boolean isDoneProducing(ReadRequest message) {
			if (message == EndReadRequest.INSTANCE) {
				try {
					destinationWriter.blockingSend(EndWriteRequest.INSTANCE);
				} catch (InterruptedException e) {
					//TODO: log me
				}
				return true;
			} else {
				return false;
			}
		}
		
    	@Override
    	protected void handleException(Exception e) {
    		try {
				destinationWriter.blockingSend(EndWriteRequest.INSTANCE);
			} catch (InterruptedException e1) {
				//TODO: log me
			} finally {
				super.handleException(e);
			}
    	}
    }
    
    private static final class PreventOverwrite extends Actor<ReadRequest> {
    	private final Actor<ReadRequest> readingActor;
    	private final FileStoreClient destinationClient;
    	
    	PreventOverwrite(Actor<ReadRequest> readingActor,
    			FileStoreClient destinationClient) {
    		this.readingActor = readingActor;
    		this.destinationClient = destinationClient;
    	}
    	
    	@Override
    	protected void act(ReadRequest message) throws Exception {
    		//TODO:  we need some efficient way of checking existence on the destination file store server
    		readingActor.blockingSend(message);
    	}
    	
    	@Override
    	protected boolean isDoneProducing(ReadRequest message) {
    	    if (message == EndReadRequest.INSTANCE) {
    	    	try {
					readingActor.blockingSend(EndReadRequest.INSTANCE);
				} catch (InterruptedException e) {
					//TODO:  log me.
				}
    	    	return true;
    	    } else {
    	    	return false;
    	    }
    	}
    	
    	@Override
    	protected void handleException(Exception e) {
    		try {
				readingActor.blockingSend(EndReadRequest.INSTANCE);
			} catch (InterruptedException e1) {
				//TODO: log me
			} finally {
				super.handleException(e);
			}
    	}

    }
    
    //TODO:  in order for this to scale to very large numbers of FsIds the queries
    //will need to be partitioned in some way.
    private static final class FsIdProducer extends Actor<Object> {

    	private final Actor<ReadRequest> sourceReader;
    	private final FileStoreClient sourceClient;
    	private final String queryStr;
    	private final DataType dataType;
    	private final double startTime;
    	private final double endTime;
    	private final int startCadence;
    	private final int endCadence;
    	private final int chunkSize;
    	
    	/**
    	 * 
    	 * @param fiber
    	 * @param sourceReader
    	 * @param sourceClient
    	 * @param queryStr
    	 * @param dataType
    	 * @param startTime  this could refer to mjd or cadence depending on how
    	 * the command line was called.
    	 * @param endTime
    	 */
    	FsIdProducer(Actor<ReadRequest> sourceReader,
    			FileStoreClient sourceClient, String queryStr, DataType dataType,
    			double startTime, double endTime, int chunkSize) {

			this.sourceReader = sourceReader;
			this.sourceClient = sourceClient;
			this.queryStr = queryStr;
			this.dataType = dataType;
			this.startTime = startTime;
			this.endTime = endTime;
			this.startCadence = (int) startTime;
			this.endCadence = (int) endTime;
			this.chunkSize = chunkSize;
		}

		@Override
		protected void act(Object message) throws Exception {
			Set<FsId> ids = sourceClient.queryIds2(queryStr);
			ListChunkIterator<FsId> it = 
					new ListChunkIterator<FsId>(ids.iterator(), chunkSize);
			
			for (List<FsId> chunk : it) {
				//TODO:  construct different kinds of read requests.
				TimeSeriesReadRequest rq = 
						new TimeSeriesReadRequest(chunk, startCadence, endCadence);
				sourceReader.blockingSend(rq);
			}
			sourceReader.blockingSend(EndReadRequest.INSTANCE);
			//TODO:  I'm done here.
		}
		
		@Override
		protected void handleException(Exception e) {
			try {
				sourceReader.blockingSend(EndReadRequest.INSTANCE);
			} catch (InterruptedException e1) {
				//TODO: log me
			} finally {
				super.handleException(e);
			}
		}
        
    }
    
    public static void main(String[] argv) throws Exception {
    	CopyFileStoreToFileStore fscp = new CopyFileStoreToFileStore();
    	fscp.parseOptions(argv);
    	fscp.copy();
    	System.out.println("Copy complete.");
    	//TODO:  fix return code.
    	//System.exit(0);
    }
}
