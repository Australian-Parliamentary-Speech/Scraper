using SQLite

function test()
    # Connect to the SQLite database (creates the file if it doesn't exist)
    db = SQLite.DB("mydatabase.db")

    # Create a table if it doesn't exist
    SQLite.execute(db, """
                   CREATE TABLE IF NOT EXISTS users (
                   id INTEGER PRIMARY KEY,
                   username TEXT NOT NULL,
                   email TEXT UNIQUE,
                   password TEXT
                   )
                   """)

    # Insert dummy data
    dummy_data = [
                  ("John", "john@example.com", "password123"),
                  ("Alice", "alice@example.com", "password456"),
                  ("Bob", "bob@example.com", "password789")
                 ]

    for (username, email, password) in dummy_data
        SQLite.execute(db, "INSERT INTO users (username, email, password) VALUES (?, ?, ?)", [username, email, password])
    end

    # Query data
    result = SQLite.Query(db, "SELECT * FROM users")
    for row in result
        println(row[:username], "\t", row[:email])
    end

    # Close the database connection
    SQLite.close(db)
end
