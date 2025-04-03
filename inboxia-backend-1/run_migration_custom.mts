// run_migrations_custom.ts
import "reflect-metadata";
// Ensure the import uses the .ts extension for local files in an ES module environment
import { AppDataSource } from "./data-source.ts";

AppDataSource.initialize()
  .then(async () => {
    console.log("DataSource initialized. Running migrations...");
    await AppDataSource.runMigrations();
    console.log("Migrations completed successfully.");
    process.exit(0);
  })
  .catch((error) => {
    console.error("Error running migrations:", error);
    process.exit(1);
  });
