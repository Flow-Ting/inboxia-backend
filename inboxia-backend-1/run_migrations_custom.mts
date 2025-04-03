// run_migrations_custom.ts
import "reflect-metadata";
import { AppDataSource } from "./src/data-source.ts"; // Note the .ts extension

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
