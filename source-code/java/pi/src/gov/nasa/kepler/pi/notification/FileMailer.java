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

package gov.nasa.kepler.pi.notification;

import gov.nasa.kepler.common.KeplerSocBuild;
import gov.nasa.kepler.fs.FileStoreConstants;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;

import java.io.File;

import javax.activation.DataHandler;
import javax.activation.FileDataSource;
import javax.mail.Address;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.Multipart;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Mails {@link File}s.
 * 
 * @author Miles Cote
 * 
 */
class FileMailer {

    private static final String ADDRESSES_PROP_NAME = "pi.notification.FileMailer.addresses";
    private static final String SMOKE_TEST_EMAIL_ADDRESS = "user@gmail.com";
    private static final String SMOKE_TEST_PASSWORD = "password";

    private static final Log log = LogFactory.getLog(FileMailer.class);

    public void mail(File file) throws Exception {
        log.info("Creating a mail session...");

        java.util.Properties props = new java.util.Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getDefaultInstance(props,
            new Authenticator() {
                @Override
                public PasswordAuthentication getPasswordAuthentication() {
                    String username = SMOKE_TEST_EMAIL_ADDRESS;
                    String password = SMOKE_TEST_PASSWORD;
                    return new PasswordAuthentication(username, password);
                }
            });

        // Construct the message
        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(SMOKE_TEST_EMAIL_ADDRESS));
        msg.addRecipients(Message.RecipientType.TO, getAddresses());
        msg.setSubject(getServicesMachineName() + "--" + KeplerSocBuild.getId());

        // Part one is text.
        MimeBodyPart part1 = new MimeBodyPart();
        part1.setText("See attached.");

        // Part two is attachment.
        MimeBodyPart part2 = new MimeBodyPart();
        part2.setDataHandler(new DataHandler(new FileDataSource(file)));
        part2.setFileName(file.getName());

        Multipart multipart = new MimeMultipart();
        multipart.addBodyPart(part1);
        multipart.addBodyPart(part2);

        msg.setContent(multipart);

        log.info("Sending mail...");
        Transport.send(msg);
    }

    private Address[] getAddresses() throws AddressException {
        String[] addressesStringList = ConfigurationServiceFactory.getInstance()
            .getStringArray(ADDRESSES_PROP_NAME);

        Address[] addresses = new InternetAddress[addressesStringList.length];
        for (int i = 0; i < addressesStringList.length; i++) {
            addresses[i] = new InternetAddress(addressesStringList[i].trim());
        }

        return addresses;
    }

    private String getServicesMachineName() {
        String fstpUrl = ConfigurationServiceFactory.getInstance()
            .getString(FileStoreConstants.FS_FSTP_URL);
        // The fstpUrl should be of the form: fstp://host:port
        String servicesMachineName = fstpUrl.substring(7)
            .split(":")[0];

        return servicesMachineName;
    }

}
