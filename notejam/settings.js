var settings = {
  development: {
    db: "db/notejam.db",
    dsn: "sqlite://db/notejam.db"
  },
  test: {
    db: "db/notejam_test.db",
    dsn: "sqlite://db/notejam_test.db"
  }
};


var env = process.env.NODE_ENV
if (!env) {
  env = 'development'
};
module.exports = settings[env];
