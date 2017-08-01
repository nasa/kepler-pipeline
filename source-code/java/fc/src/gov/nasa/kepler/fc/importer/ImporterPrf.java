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

package gov.nasa.kepler.fc.importer;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.Prf;
import gov.nasa.kepler.hibernate.fc.PrfHistoryModel;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ImporterPrf extends ImporterParentImage {
    private static final HistoryModelName HISTORY_MODEL_NAME = HistoryModelName.PRF;
	public static final String DATAFILE_DIRECTORY_NAME = "prf";
	private static double ONE_SECOND_IN_DAYS = 1.0 / 86400.0;
	/**
	 * This regex matches the format: kplrYYYYMMDDHH-MMO_prf.bin, where MM is the
	 * zero-padded module number, O is the output number, and YYYYMMDDHH is the
	 * date.
	 */
	public static final String DATAFILE_REGEX = "kplr" + // prefix
	        "(\\d\\d\\d\\d\\d\\d\\d\\d\\d\\d)"         + // Date: matcher group 1.
			"-(\\d\\d)"                                + // module: matcher group 2
			"(\\d)"                                    + // output: matcher group 3
			"_prf.bin"; // suffix

	/**
	 * 
	 * @param filename
	 *            The filename encodes the valid-MJD, module, and output that
	 *            the prf is for. It should have format
	 *            prf_moduleMODULE_outputOUTPUT_MJD.dat, where MJD is a double,
	 *            and MODULE/OUTPUT are both ints in the appropriate range.
	 * @return
	 * @throws NumberFormatException
	 * @throws IOException
	 * @throws FocalPlaneException
	 */
	public Prf parseFile(String filename) throws NumberFormatException, IOException {
		 
        log.debug("Reading file " + filename);
        
		// Bytestream-reading code was copied from SeedDatabasePrf:
		//
		File dataFile = new File(filename);
		byte[] blob = new byte[(int) dataFile.length()];
		FileInputStream stream = new FileInputStream(dataFile);
		stream.read(blob);
		
		log.debug("Done reading file " + filename);

		Prf prf = new Prf(blob);
		return prf;
	}

	/**
	 * Public for testing
	 * 
	 * @param filename
	 * @return
	 * @throws FocalPlaneException
	 */
	public int getModuleNumberFromFile(String filename) throws IOException {
		int module = Integer.parseInt(getMatcher(filename).group(2));
		return module;
	}

	/**
	 * Public for testing
	 * 
	 * @param filename
	 * @return
	 * @throws FocalPlaneException
	 */
	public int getOutputNumberFromFile(String filename) throws IOException {
		int output = Integer.parseInt(getMatcher(filename).group(3));
		return output;
	}

	/**
	 * Public for testing
	 * 
	 * @param filename
	 * @return
	 * @throws FocalPlaneException
	 */
	@Override
	public double getMjdFromFile(String filename) throws IOException {
		String dateStr = getMatcher(filename).group(1);

		int year = Integer.parseInt(dateStr.substring(0, 4));
		int month = Integer.parseInt(dateStr.substring(4, 6)) - 1; 
		// The -1 is for ModifiedJulianDate Constructor, which uses
		// zero-based Calendar.MONTH (jan = 0, dec = 11)
		
		int day = Integer.parseInt(dateStr.substring(6, 8));
		int hour = Integer.parseInt(dateStr.substring(8, 10));

		ModifiedJulianDate mjd = new ModifiedJulianDate(year, month, day, hour, 0, 0);
		return mjd.getMjd();
	}

	/**
	 * 
	 * @param filename
	 * @return
	 * @throws FocalPlaneException
	 */
	private Matcher getMatcher(String filename) throws IOException {
		Matcher matcher = Pattern.compile(DATAFILE_REGEX).matcher(filename);
		matcher.find();
		if (3 != matcher.groupCount()) {
			throw new IOException("bad filename, there s/b 3 matches: "
					+ filename + ", there are " + matcher.groupCount());
		}
		return matcher;
	}

	// /**
	// *
	// * @param prf
	// * @return
	// */
	// private boolean isAlreadyLoaded(Prf prf) {
	// Prf result = fcCrud.retrievePrfExact(prf.getCcdModule(),
	// prf.getCcdOutput());
	// return null != result;
	// }

	/**
	 * @param args
	 * @throws IOException
	 * @throws FocalPlaneException
	 */
	public static void main(String[] args) throws
			IOException {
		DatabaseService dbService = DatabaseServiceFactory.getInstance();
		try {
			dbService.beginTransaction();
			ImporterPrf importer = new ImporterPrf();
			importer.run(args);
			dbService.commitTransaction();
		} finally {
			dbService.rollbackTransactionIfActive();
			dbService.closeCurrentSession();
		}

	}

	@Override
	protected void appendNew(int ccdModule, int ccdOutput, String dataDirectory,
			String reason, Date date) throws IOException {
		FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());
        double now = ModifiedJulianDate.dateToMjd(date);

		// Get the most recent history (create one if there aren't any (first
		// run case))
		//
		History history = fcCrud.retrieveHistory(HistoryModelName.PRF);
		if (history == null) {
			String description = "created by ImporterPrf.appendNew because there were no Prf historys; " + reason;
			int version = 1;
			date = new Date();
			now = ModifiedJulianDate.dateToMjd(date);
			history = new History(now, HistoryModelName.PRF, description, version);
			fcCrud.create(history);
		}

		// Get the most recent entry for this History:
		//
		PrfHistoryModel mostRecentDatabasePrfHistoryModel = fcCrud.retrieveMostRecentPrfHistoryModel(history,
				ccdModule, ccdOutput);

        // Check if all Prfs to be persisted are later than the latest Prf
        // associated with the History. If this is not the case, throw an error
		//
		for (String filename : getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory)) {
			double prfMjd = getMjdFromFile(filename);
						
			// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			// The greater-than -ONE_SECOND_IN_DAYS is an epsilon around the imprecision in the PRF filename MJD encoding
			boolean isMostRecentNull = (mostRecentDatabasePrfHistoryModel == null);
            boolean isTooEarly = !isMostRecentNull && !((prfMjd - mostRecentDatabasePrfHistoryModel.getMjd()) > -ONE_SECOND_IN_DAYS);
            
			if (isTooEarly) {
				throw new FocalPlaneException(
						"appendNew requires new data to occur after existing data."
								+ " Your data is "
								+ mostRecentDatabasePrfHistoryModel.getMjd()
								+ " and the existing data is " + prfMjd);
			}
		}

		// Persist Prfs and PrfHistoryModels for each Prf
		//
		for (String filename : getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory)) {
			double prfMjd = getMjdFromFile(filename);
			int prfCcdModule = getModuleNumberFromFile(filename);
			int prfCcdOutput = getOutputNumberFromFile(filename);

			if (prfCcdModule == ccdModule && prfCcdOutput == ccdOutput) {
                log.info(String.format("import prf from %s", filename));
				Prf prf = parseFile(filename);
                PrfHistoryModel prfHistoryModel = new PrfHistoryModel(prf,
                    prfMjd, ccdModule, ccdOutput, reason, now, history);

				fcCrud.create(prf);
				fcCrud.create(prfHistoryModel);
				DatabaseServiceFactory.getInstance().flush();
				DatabaseServiceFactory.getInstance().evict(prf);
				DatabaseServiceFactory.getInstance().evict(prfHistoryModel);
			}
		}
        updateModelMetaData(dataDirectory, history, date);
	}

	@Override
	protected void appendNew(int ccdModule, int ccdOutput, String reason, Date date)
			throws IOException {
		appendNew(ccdModule, ccdOutput, getDataDirectory(DATAFILE_DIRECTORY_NAME).getAbsolutePath(), reason, date);
	}

	@Override
	protected void appendNew(String dataDirectory, String reason, Date date) throws IOException {
		FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());
		double now = ModifiedJulianDate.dateToMjd(date);

		// Get the most recent history (create one if there aren't any (first
		// run case))
		//
		History history = fcCrud.retrieveHistory(HistoryModelName.PRF);
		if (history == null) {
			String description = "created by ImporterPrf.appendNew becausethere were no Prf historys; " + reason;
			int version = 1;
			date = new Date();
			now = ModifiedJulianDate.dateToMjd(date);
			history = new History(now, HistoryModelName.PRF, description,
					version);
			fcCrud.create(history);
		}

        // Check if all Prfs to be persisted are later than the latest Prf
        // associated with the History. If this is not the case, throw an error
		//
		String[] filenames = getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory);
		for (String filename : filenames) {
			double prfMjd = getMjdFromFile(filename);

			int ccdModule = getModuleNumberFromFile(filename);
			int ccdOutput = getOutputNumberFromFile(filename);

			// Get the most recent entry for this History:
			//
			PrfHistoryModel mostRecentDatabasePrfHistoryModel = fcCrud.retrieveMostRecentPrfHistoryModel(history,
					ccdModule, ccdOutput);
			
			// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			// The greater-than -ONE_SECOND_IN_DAYS is an epsilon around the imprecision in the PRF filename MJD encoding
			boolean isMostRecentNull = (mostRecentDatabasePrfHistoryModel == null);
			boolean isTooEarly = !isMostRecentNull && !((prfMjd - mostRecentDatabasePrfHistoryModel.getMjd()) > -ONE_SECOND_IN_DAYS);

			if (isTooEarly) {
				throw new FocalPlaneException(
						"appendNew requires new data to occur after existing data."
								+ " Your data is "
								+ mostRecentDatabasePrfHistoryModel.getMjd()
								+ " and the existing data is " + prfMjd);
			}
		}

	
		// Persist Prfs and PrfHistoryModels for each Prf
		//
		for (String filename : filenames) {

			Prf prf = parseFile(filename);
			
			double mjd = getMjdFromFile(filename);
			int ccdModule = getModuleNumberFromFile(filename);
			int ccdOutput = getOutputNumberFromFile(filename);
			
			PrfHistoryModel prfHistoryModel = new PrfHistoryModel(prf, mjd, ccdModule, ccdOutput, reason, now, history);
			fcCrud.create(prf);
			fcCrud.create(prfHistoryModel);
			DatabaseServiceFactory.getInstance().flush();
			DatabaseServiceFactory.getInstance().evict(prf);
			DatabaseServiceFactory.getInstance().evict(prfHistoryModel);
		}
        updateModelMetaData(dataDirectory, history, date);
	}

	@Override
	protected void appendNew(String reason, Date date) throws IOException,
			FocalPlaneException {
		appendNew(getDataDirectory(DATAFILE_DIRECTORY_NAME).getAbsolutePath(), reason, date);
	}

    @Override
    public void insertBetween(int ccdModule, int ccdOutput, String dataDirectory, String reason) throws IOException,
        FocalPlaneException {

        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the current History
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.PRF);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                "no history found in insertBetween-- something is wrong!");
        }

        // Get all the Prf for that History
        List<PrfHistoryModel> prfHistoryModels = fcCrud.retrievePrfHistoryModels(oldHistory);
        List<Prf> databasePrfs = new ArrayList<Prf>();
        for (PrfHistoryModel prfHistoryModel : prfHistoryModels) {
            databasePrfs.add(prfHistoryModel.getPrf());
        }

        // Parse the data out of the files
        //
        String[] filenames = getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory);
        List<Prf> prfs = new ArrayList<Prf>();
        List<Double> mjds = new ArrayList<Double>();
        
        for (int ii = 0; ii < filenames.length; ++ii) {
        	prfs.add(parseFile(filenames[ii]));
        	mjds.add(getMjdFromFile(filenames[ii]));
        }
        
        // Create new History, iterate the version
        //
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.PRF,
            reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistoryPrfModels for each Prf
        // and persist them. Also persist the Prf object.
		for (int ii = 0; ii < prfHistoryModels.size(); ++ii) {
			double mjd = getMjdFromFile(filenames[ii]);
			PrfHistoryModel hm = new PrfHistoryModel(prfs.get(ii), mjd, prfHistoryModels.get(ii).getCcdModule(), prfHistoryModels.get(ii).getCcdOutput(), reason, now, newHistory);

			fcCrud.create(hm);
            fcCrud.create(prfs.get(ii));
        }
    }

    @Override
    public void insertBetween(int ccdModule, int ccdOutput, String reason)
        throws IOException {
        insertBetween(ccdModule, ccdOutput, DATAFILE_DIRECTORY_NAME, reason);

    }

    @Override
    public void insertBetween(String dataDirectory, String reason)
        throws IOException {
    	
    	for (int ccdModule : FcConstants.modulesList) {
    		for (int ccdOutput : FcConstants.outputsList) {
    			insertBetween(ccdModule, ccdOutput, dataDirectory, reason);
    		}
    	}

    }

    @Override
    public void insertBetween(String reason) throws IOException,
        FocalPlaneException {
        insertBetween(DATAFILE_DIRECTORY_NAME, reason);
    }
	
    @Override
    protected HistoryModelName getHistoryModelName() {
        return HISTORY_MODEL_NAME;
    }

    public void loadSeedData() throws Exception {
    	appendNew("loadSeedData", new Date());
    }

}
