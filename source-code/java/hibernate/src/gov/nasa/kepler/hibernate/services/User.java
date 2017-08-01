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

package gov.nasa.kepler.hibernate.services;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.Table;
import javax.persistence.Version;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * A user object.
 * 
 * @author Bill Wohler
 * @author tklaus
 */
@Entity
@Table(name = "PI_USER")
public class User {
    private static final String CHAR_ENCODING = "UTF-8";

    private static final Log log = LogFactory.getLog(User.class);

    private static final String RANDOM_ALGORITHM = "SHA1PRNG";
    private static final String DIGEST_ALGORITHM = "MD5";
    private static final int DIGEST_ITERATIONS = 1000;
    private static final int SALT_BYTE_LENGTH = 8;

    @Id
    private String loginName;
    private String password;
    private String displayName;
    private String email;
    private String phone;
    private Date created;

    @ManyToMany
    @JoinTable(name = "PI_USER_ROLE")
    private List<Role> roles = new ArrayList<Role>();

    @org.hibernate.annotations.CollectionOfElements
    @JoinTable(name = "PI_USER_PRIVS")
    private List<String> privileges = new ArrayList<String>();

    /** used by Hibernate to implement optimistic locking.  Should prevent 2
     * different PIG users from clobbering each others changes */
    @Version
    private int dirty = 0;
    
    public User() {
        this(null, null, null, null, null);
    }

    public User(String loginName, String displayName, String password,
        String email, String phone) {

        this.loginName = loginName;
        this.displayName = displayName;
        setPassword(password);
        this.email = email;
        this.phone = phone;
        this.created = new Date(System.currentTimeMillis());
    }

    public String getLoginName() {
        return loginName;
    }

    public void setLoginName(String loginName) {
        this.loginName = loginName;
    }

    /**
     * Returns the encrypted password.
     * 
     * @return a non-{@code null} string. May be empty.
     */
    public String getPassword() {
        return password;
    }

    /**
     * Sets the password. If {@code password} is {@code null} or empty, then
     * subsequent calls to {@link #getPassword()} will return an empty string.
     * 
     * @param password the password, may be {@code null} or empty.
     */
    public final void setPassword(String password) {
        if (password != null && password.length() > 0) {
            this.password = encryptPassword(password, generateSalt());
        } else {
            this.password = "";
        }
    }

    /**
     * Encrypt the given password using the salt in this user's password.
     * 
     * @param password the password to encrypt.
     * @return the encrypted password, or an empty string if {@code password} is
     * {@code null} or empty.
     */
    public String encryptPassword(String password) {
        return encryptPassword(password, extractSalt());
    }

    /**
     * Encrypt password per <i>How to encrypt user passwords</i> at Jasypt.
     * 
     * <ol>
     * <li>Encrypt passwords using one-way techniques, this is, digests.
     * 
     * <li>Match input and stored passwords by comparing digests, not
     * unencrypted strings.
     * 
     * <li>Use a salt containing at least 8 random bytes, and attach these
     * random bytes, undigested, to the result.
     * 
     * <li>Iterate the hash function at least 1,000 times.
     * 
     * <li>Prior to digesting, perform string-to-byte sequence translation
     * using a fixed encoding, preferably UTF-8.
     * 
     * <li>Finally, apply BASE64 encoding and store the digest as an US-ASCII
     * character string.
     * </ol>
     * 
     * @param password the password to encrypt.
     * @return the encrypted password. An empty string is returned if a
     * {@code null} or empty password is given or in the unlikely case that
     * internal message digest algorithms or encodings are not supported.
     * @see http://www.jasypt.org/howtoencryptuserpasswords.html
     */
    private String encryptPassword(String password, byte[] salt) {
        if (password == null || password.isEmpty()) {
            return "";
        }

        String encryptedPassword;
        try {
            MessageDigest messageDigest = MessageDigest.getInstance(DIGEST_ALGORITHM);
            byte[] passwordBytes = password.getBytes(CHAR_ENCODING);

            // Initialize digest to salt and password.
            byte[] passwordDigest = appendBytes(salt, passwordBytes);

            // Digest the password 1000 times.
            for (int i = 0; i < DIGEST_ITERATIONS; i++) {
                messageDigest.update(passwordDigest);
                passwordDigest = messageDigest.digest();
            }

            // Prepend the salt for later extraction and perform base64
            // encoding.
            encryptedPassword = new String(Base64.encodeBase64(appendBytes(
                salt, passwordDigest)));
        } catch (NoSuchAlgorithmException e) {
            // This should never happen.
            log.error("MD5 algorithm not supported for password encryption", e);
            return "";
        } catch (UnsupportedEncodingException e) {
            // This should never happen.
            log.error("UTF-8 encoding not supported", e);
            return "";
        }

        return encryptedPassword;
    }

    /**
     * Appends the bytes in {@code arrayB} to {@code arrayA} and returns the
     * result.
     * 
     * @param arrayA the first array.
     * @param arrayB the second array.
     * @throws NullPointerException if either array is empty.
     * @return a byte array with the concatenated result.
     */
    private byte[] appendBytes(byte[] arrayA, byte[] arrayB) {
        if (arrayA == null) {
            throw new NullPointerException("arrayA must not be null");
        }
        if (arrayB == null) {
            throw new NullPointerException("arrayB must not be null");
        }

        byte[] bytes = new byte[arrayA.length + arrayB.length];
        System.arraycopy(arrayA, 0, bytes, 0, arrayA.length);
        System.arraycopy(arrayB, 0, bytes, arrayA.length, arrayB.length);

        return bytes;
    }

    /**
     * Generates an eight-byte salt.
     * 
     * @return an eight byte array of salt.
     */
    private byte[] generateSalt() {
        byte[] salt;
        try {
            SecureRandom randomizer = SecureRandom.getInstance(RANDOM_ALGORITHM);
            salt = new byte[SALT_BYTE_LENGTH];
            randomizer.nextBytes(salt);
        } catch (NoSuchAlgorithmException e) {
            // This should never happen.
            log.error("MD5 algorithm not supported for generating salt", e);
            return new byte[0];
        }

        return salt;
    }

    /**
     * Returns the first eight bytes of the password as a string. If a password
     * has not yet been set, then a random salt is returned.
     * 
     * @return an eight byte array of salt, or an empty array in the unlikely
     * case that UTF-8 encoding is not supported.
     */
    private byte[] extractSalt() {
        if (getPassword().isEmpty()) {
            return generateSalt();
        }

        byte[] salt;
        try {
            byte[] password = getPassword().getBytes(CHAR_ENCODING);
            password = Base64.decodeBase64(password);
            salt = new byte[SALT_BYTE_LENGTH];
            System.arraycopy(password, 0, salt, 0, SALT_BYTE_LENGTH);
        } catch (UnsupportedEncodingException e) {
            // This should never happen.
            log.error("UTF-8 encoding not supported");
            return new byte[0];
        }

        return salt;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public List<Role> getRoles() {
        return roles;
    }

    public void setRoles(List<Role> roles) {
        this.roles = roles;
    }

    public void addRole(Role role) {
        roles.add(role);
    }

    public List<String> getPrivileges() {
        return privileges;
    }

    public void setPrivileges(List<String> privileges) {
        this.privileges = privileges;
    }

    public void addPrivilege(String privilege) {
        this.privileges.add(privilege);
    }

    public boolean hasPrivilege(String privilege) {
        // First check for user-level override.
        if(privileges.contains(privilege)){
            return true;
        }

        // Next check the user's roles.
        for (Role role : roles) {
            if (role.hasPrivilege(privilege)) {
                return true;
            }
        }

        // No matches.
        return false;
    }

    public Date getCreated() {
        return created;
    }

    public void setCreated(Date created) {
        this.created = created;
    }

    public int getDirty() {
        return dirty;
    }

    @Override
    public int hashCode() {
        return loginName.hashCode();
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        final User other = (User) obj;
        if (loginName == null) {
            if (other.loginName != null)
                return false;
        } else if (!loginName.equals(other.loginName))
            return false;
        return true;
    }

    public String toString() {
        return displayName;
    }
}
