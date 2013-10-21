## Registration and Authentication
- Indentity

	Uniquely indentifies a user. Could be a username, email, api key, 
	etc.
- Credentials

	Used to authenticate a user. Could be a password, pin, public key, encrypted hash.
	
- Registration/Signup
    
    User identity is created with their credentials, email and password in this case.

-  Authentication/Login
    
    User is authenticated using their identity and credentials.

### Passwords
Do not want to store the "plain text" passwords in the DB. Just in case the system is comprimised, cracked.

We only stored hashed passwords. **Never store plain text passwords!!** So that if a malicious user gains access then they cannot obtain passwords. We're going to use the bcrypt gem to hash plain text passwords into a crypto hash. This will done by using this gem's hash_secret method.

BCrypt is just one of many types of ways to generate a hash.

    The general workflow for account registration and authentication in a hash-based account system is as follows:

    1) The password is hashed and stored in the database. At no point is the plain-text (unencrypted) password ever written to the hard drive.
    2) When the user attempts to login, the hash of the password they entered is checked against the hash of their real password (retrieved from the database).
    3) If the hashes match, the user is granted access. If not, the user is told they entered invalid login credentials.

    Steps 3 and 4 repeat everytime someone tries to login to their account.

#### Need to a use a salt to generate crypto hashes.
   
This will prevent common ways of cracking a hash. A *salt* is a random string that makes it more difficult to crack the hash. This salt is feed into the hash algorithim along with the plain text password to produce a cryptographic hash.

### Links
- [Rails Security Guide](http://guides.rubyonrails.org/security.html)
- [7 Rails Security Tips](http://railscasts.com/episodes/178-seven-security-tips)
- [Sessions](http://guides.rubyonrails.org/security.html#sessions)
- [Cross Site Request Forgery CSRF](http://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf)
- [Railscasts Authentication](http://railscasts.com/?tag_id=25&utf8=%E2%9C%93)
- [has_secure_password Simple Authentication](http://railscasts.com/episodes/270-authentication-in-rails-3-1)
### See the steps.txt file for instructions.
