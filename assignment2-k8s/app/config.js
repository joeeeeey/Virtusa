var config = {
	database: {
		host:	  process.env.DB_HOST || 'localhost', 	// database host from env or fallback
		user: 	  process.env.DB_USER || 'root', 		// database username from env or fallback
		password: process.env.DB_PASSWORD || 'root', 	// database password from env or fallback
		port: 	  process.env.DB_PORT || 3306, 		// database port from env or fallback
		database: process.env.DB_NAME || 'test' 		// database name from env or fallback
	},
	server: {
		host: process.env.SERVER_HOST || '127.0.0.1',
		port: process.env.PORT || '3000'
	}
}

module.exports = config
