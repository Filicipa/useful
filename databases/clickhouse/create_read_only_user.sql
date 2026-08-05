CREATE USER IF NOT EXISTS <user>
IDENTIFIED WITH plaintext_password BY 'StrongPasswordHere';

GRANT SELECT ON <database>.* TO <user>;

# Check permissions
SHOW GRANTS FOR <user>;

SELECT currentUser();
SELECT currentDatabase();
SHOW USERS;
SHOW DATABASES;
SHOW GRANTS FOR CURRENT_USER;