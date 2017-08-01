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

package gov.nasa.kepler.systest;

import gov.nasa.kepler.cm.TargetSelectionOperations;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * Command line utility to split target lists into target lists by skygroup.
 * 
 * @author Sean McCauliff
 *
 */
public class TargetListSplitter {

	private static final Log log = LogFactory.getLog(TargetListSplitter.class);

	private static final Option inputOption =
		new Option("i", "input file",true, "The input target list file.  Specifying \"-\" means read from stdin.") {{
			setRequired(true); 
	}};

	private static final Option outputOption =
	new Option("o","output-dir", true, "The output directory.") {{
		setRequired(true);
	}};

	private static final Options options = new Options() {{
		addOption(inputOption);
		addOption(outputOption);
	}};

	private static final int BATCH_SIZE = 128;

	private final SystemProvider system;
	private File inputFile;
	private File outputDir;


	private void printUsage() {
		HelpFormatter helpFormatter = new HelpFormatter();
		PrintWriter printWriter = new PrintWriter(system.out());
		helpFormatter.printHelp(printWriter, 80, 
				"java -cp ... gov.nasa.kepler.systest.TargetListSplitter",
				"", options, 2, 2, "", true);
		printWriter.flush();
	}

	TargetListSplitter(SystemProvider system) {
		this.system = system;
	}

	void parseArgs(String[] argv) throws ParseException {
		try {
			GnuParser gnuParser = new GnuParser();
			CommandLine commandLine = gnuParser.parse(options, argv);
			String inputFileStr = commandLine.getOptionValue(inputOption.getOpt()).trim();
			String outputDirStr = commandLine.getOptionValue(outputOption.getOpt()).trim();

			inputFile = new File(inputFileStr);
			if (!inputFile.exists()) {
				String m = "Target list input file \"" + inputFile + "\" does not exist.";
				system.out().println(m);
				system.exit(1);
				throw new IllegalArgumentException(m);
			}

			outputDir = new File(outputDirStr);
			outputDir.mkdirs();
			if (!outputDir.exists() || !outputDir.isDirectory()) {
				String m = "Bad directory \"" + outputDir + "\".";
				system.out().println(m);
				system.exit(1);
				throw new IllegalArgumentException(m);
			}

		} catch (ParseException px) {
			log.error(px);
			system.out().println("Bad command line.");
			printUsage();
			system.exit(1);
			throw px;
		}
	}

	void split() throws IOException, InterruptedException, Throwable {
		final BufferedReader breader = new BufferedReader(new FileReader(inputFile));

		String categoryLine = breader.readLine();
		
		final LinkedBlockingQueue<List<Pair<PlannedTarget,String>>> targetBatchQueue =
			new LinkedBlockingQueue<List<Pair<PlannedTarget,String>>>(128);

		final List<Pair<PlannedTarget,String>> BATCH_DONE = 
			new ArrayList<Pair<PlannedTarget,String>>(0);
		
		final LinkedBlockingQueue<BatchInfo> writeOutQueue = 
			new LinkedBlockingQueue<BatchInfo>(128);
		
		final BatchInfo BATCH_INFO_DONE = new BatchInfo(null, null);
		
		final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
		
		Map<Integer, BufferedWriter> cleanFiles = null;
		try {
			final Map<Integer, BufferedWriter> skyGroupToOutputFile = 
				createOutputFiles(categoryLine);
			cleanFiles = skyGroupToOutputFile;
			
			Runnable runReader = new Runnable() {
				public void run() {
					int parseCount = 0;
					try {
						List<Pair<PlannedTarget,String>> targetBatch = null;
						for (String line = breader.readLine(); 
									line != null; 
									line = breader.readLine()) {
		
							if (line.indexOf('|') == -1) {
								continue;
							}
							
							if (targetBatch == null) {
								targetBatch = new ArrayList<Pair<PlannedTarget,String>>(BATCH_SIZE);
							}
							
							PlannedTarget target = TargetSelectionOperations.stringToTarget(line);
							parseCount++;
							
							if (target.getSkyGroupId() != -1) {
								BufferedWriter bwriter = 
									skyGroupToOutputFile.get(target.getSkyGroupId());
								synchronized (bwriter) {
									bwriter.write(line);
									bwriter.write('\n');
								}
							} else {
								targetBatch.add(Pair.of(target, line));
							}
		
							if (targetBatch.size() >= BATCH_SIZE) {
								targetBatchQueue.put(targetBatch);
								targetBatch = null;
							}
						}
						
						if (!targetBatch.isEmpty()) {
							targetBatchQueue.put(targetBatch);
						}
						
					} catch (Throwable t) {
						error.compareAndSet(null, t);
						log.error("reader failed.", t);
					} finally {
						log.info("Parsed " + parseCount + " targets.");
						try {
							targetBatchQueue.put(BATCH_DONE);
						} catch (InterruptedException e) {
							log.error("Failed to queue done item.", e);
							error.compareAndSet(null,e);
						}
					}
				}
			};
			
			Runnable runDb = new Runnable() {
				public void run() {
					int batchCount = 0;
					try {
						KicCrud kicCrud = new KicCrud(true);
						while (true) {
							List<Pair<PlannedTarget,String>> batch = 
								targetBatchQueue.take();
							
							if (batch == BATCH_DONE) {
								return;
							}
							if (batch.isEmpty()) {
								continue;
							}
							
							List<Integer> keplerIds = new ArrayList<Integer>(batch.size());
							for (Pair<PlannedTarget,String> pair : batch) {
								keplerIds.add(pair.left.getKeplerId());
							}
							
							BatchInfo info = 
								new BatchInfo(kicCrud.retrieveSkyGroupIdsForKeplerIds(keplerIds), batch);
							writeOutQueue.put(info);
							batchCount++;
						}
					} catch (Throwable t) {
						error.compareAndSet(null, t);
						log.error("Db failed.", t);
					} finally {
						log.info("Processed " + batchCount + " batches of targets.");
						try {
							writeOutQueue.put(BATCH_INFO_DONE);
						} catch (InterruptedException e) {
							log.error("Failed to put done on out queue.", e);
							error.compareAndSet(null, e);
						}
					}
				}
			};
			
			Runnable runWriters = new Runnable() {
				public void run() {
					AtomicInteger processedTargetCount =new AtomicInteger();
						
					try {
						while (true) {
							BatchInfo info = writeOutQueue.take();
							if (info == BATCH_INFO_DONE) {
								return;
							}
							updateFiles(info, skyGroupToOutputFile, processedTargetCount);
						}
					} catch (Throwable t)  {
						error.compareAndSet(null, t);
						log.info("Writer failed.", t);
					} finally {
						log.info("Wrote out " + processedTargetCount + " targets.");
					}
				}
			};
			
			Thread readThread = new Thread(runReader, "Target list reader.");
			Thread dbThread = new Thread(runDb, "Db read thread.");
			Thread writersThread =new Thread(runWriters, "Writers thread.");
			
			readThread.start();
			dbThread.start();
			writersThread.start();
			
			readThread.join();
			dbThread.join();
			writersThread.join();
			
			if (error.get() != null) {
				log.error(error.get());
				system.exit(-1);
				throw error.get();
			}
		} finally {
			FileUtil.close(breader);
			if (cleanFiles != null) {
				closeAll(cleanFiles.values());
			}
		}

	}
	
	private void updateFiles(BatchInfo info, 
							 Map<Integer,BufferedWriter> skyGroupToOutputFile,
							 AtomicInteger processedTargetCount) 
		throws IOException {
		
		for (Pair<PlannedTarget,String> plannedTarget : info.batch) {
			Integer skyGroupId = info.keplerIdToSkyGroupId.get(plannedTarget.left.getKeplerId());
			BufferedWriter bwriter = skyGroupToOutputFile.get(skyGroupId);
			synchronized (bwriter) {
				bwriter.write(plannedTarget.right);
				bwriter.write('\n');
			}
			processedTargetCount.incrementAndGet();
		}
	}
	
	
	private void closeAll(Collection<BufferedWriter> writers) {
		for (BufferedWriter w : writers) {
			FileUtil.close(w);
		}
	}


	private Map<Integer, BufferedWriter> createOutputFiles(String categoryLine) throws IOException {
		KicCrud kicCrud = new KicCrud();

		//Remove the file extension if there is one.
		String fileNamePrefix = inputFile.getName();
		String fileExtension = "";
		int dotIndex = fileNamePrefix.lastIndexOf('.');
		if (dotIndex != -1) {
			fileNamePrefix = fileNamePrefix.substring(0, dotIndex);
			fileExtension = inputFile.getName().substring(dotIndex);
		}

		Map<Integer, BufferedWriter> rv = new HashMap<Integer, BufferedWriter>();
		for (SkyGroup skyGroup : kicCrud.retrieveAllSkyGroups()) {
			String newFileName = fileNamePrefix + "-" + skyGroup.getSkyGroupId() + fileExtension;
			File skyGroupFile = new File(outputDir, newFileName);
			BufferedWriter bwriter = 
				new BufferedWriter(new FileWriter(skyGroupFile), 1024*16);
			bwriter.write(categoryLine);
			bwriter.write('\n');
			rv.put(skyGroup.getSkyGroupId(),bwriter);
		}
		return rv;

	}
	
	private static class BatchInfo {
		public final Map<Integer, Integer> keplerIdToSkyGroupId;
		public final List<Pair<PlannedTarget,String>> batch;
		BatchInfo(Map<Integer,Integer> keplerIdToSkyGroupId, List<Pair<PlannedTarget,String>> batch) {
			this.keplerIdToSkyGroupId = keplerIdToSkyGroupId;
			this.batch = batch;
		}
	}

	/**
	 * @param argv
	 */
	public static void main(String[] argv) throws Throwable {

		TargetListSplitter targetListSplitter = 
			new TargetListSplitter(new DefaultSystemProvider());
		targetListSplitter.parseArgs(argv);

		DatabaseService dbService = DatabaseServiceFactory.getInstance();	
		try {
			dbService.beginTransaction();
			targetListSplitter.split();
			dbService.commitTransaction();
		} finally {
			dbService.rollbackTransactionIfActive();
		}
	}

}
