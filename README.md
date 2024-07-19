# AWS Billing Project

---

Welcome to the AWS Billing Analysis Tool. This document provides essential information for setting up, understanding assumptions, and considerations for future development of the project.

## Prerequisites

Before setting up the application, ensure you have the following installed:

- Ruby (This application uses Ruby version 3.3.4. You can manage Ruby versions using a version manager like rvm or rbenv.)
- Rails (version 7.1.3)
- PostgreSQL or MySQL server
- Clickhouse for database operations

## Setup Instructions

To set up the AWS Billing Analysis Tool, follow these steps:

1. **Clone the Repository:**
   ```
   mkdir aws_billing
   cd aws_billing
   git clone https://github.com/gautam417/AWSBillingDiscountsService
   ```
2. **Set Up Docker Environment:**
   
   - Adjust database configuration (`config/database.yml`) according to your ClickHouse setup.

    Run the Clickhouse server using Docker:
    ```
    docker run -d --name clickhouse-server --ulimit nofile=262144:262144 yandex/clickhouse-server
    ```
    
    Connect to ClickHouse and Create the `aws_billing` database:
    ```
    docker exec -it clickhouse-server clickhouse-client --query "CREATE DATABASE aws_billing;"
    ```

    Create the `line_items` table:
    ```
    docker exec -it clickhouse-server clickhouse-client --query "CREATE TABLE aws_billing.line_items (
       line_item_unblended_cost Float64,
       product_servicecode String,
       line_item_line_item_type String
     ) Engine = MergeTree()
     ORDER BY (product_servicecode);"
    ```

3. **Install Dependencies:**
   ```
   bundle install
   ```
4. **Seed the Databse:**
   
   Run the rake rask to import data from the Parquet file into ClickHouse. Make sure the path to your Parquet file is correct. 

   **Note:**  On my machine MacBook Air 2015 1.6 GHz Dual-Core Intel Core i5 it took me 15-20 mins for the database to load ~110,000 records. In production, we could've used batching to make the inserts more efficient.
   ```
   rails import:billing_data
   ```

4. **Run the Application:**
   ```
   rails server
   ```

5. **Access the Application:**
   Open a web browser and go to `http://localhost:3000` to access the application.

## Viewing API Documentation

API documentation for this project is generated using RSwag. Follow these steps to view the API documentation:

![API Docs](https://github.com/gautam417/AWSBillingDiscountsService/blob/main/API%20docs.png)

1. **Start the Rails Server:**
   Ensure your Rails server is running locally. If not, start it using:
   ```
   rails server
   ```

2. **Access the Swagger UI:**
   Open a web browser and navigate to the Swagger UI endpoint:
   ```
   http://localhost:3000/api-docs/index.html
   ```

3. **Explore Endpoints:**
   Once on the Swagger UI page, you can explore the available endpoints, parameters, request bodies, and responses. This interactive documentation provides a convenient way to understand and test the API functionalities.

## Assumptions

1. **Data Consistency:**
   - It is assumed that data imported into ClickHouse (`aws_billing.line_items`) is consistent and follows AWS billing data structure. I am also assuming that there is only 1 parquet file that we handling for our dataset.

2. **Security:**
   - Basic authentication (`authenticate` endpoint) assumes a simple username-password combination for demonstration purposes. Only `username=admin` and `password=secret` are valid for this app. 
   Production deployment would require more robust authentication mechanisms. I would consider implementing RBAC (role based access control) to ensure only authorized requests.
   Additionally, I would also add a rate limiter to ensure fair usage of this API to prevent any throttling errors.

## Future Considerations

1. **Enhanced Authentication:**
   - Implement OAuth2 or more robust JWT-based authentication for improved security and scalability.

2. **Performance Optimization:**
   - Use ClickHouse-specific optimizations like partitioning the data by date or another logical grouping. This helps in managing large datasets efficiently and improves query performance by reducing the number of partitions scanned.
   - ClickHouse supports various compression algorithms (ZSTD, LZ4, etc.) to reduce storage size and improve query performance. I would use appropriate compression settings based on the data characteristics.

3. **Monitoring and Observability:**
   - Implement comprehensive monitoring (e.g., CloudWatch logs, Datadog,Sentry, Sysdig) to track errors and performance metrics in production.

4. **User Interface Enhancements:**
   - Improve UI/UX for better data visualization and user interaction. Add more color to the UI and make it aesthetic.

## Feedback and Changes

If rebuilding this project:

- **Presentation:** In my career I have often times projected a number in a report for a customer, and found that they don't take much action with the data. I would make this informtion more actionable. The goal would be to present the data in a reporting fashion but encourage the customer to take the next step in reducing their costs. One way to achieve that in this project would be to offer an additional Forecaster API that would be able to forecast what the AWS Usage bill would be like with the discounts applied for certain AWS Products.
- **Multi-cloud**: Currently this solution is tailored towards AWS customers only. I would expand on the business logic and denormalize our data model for customers that want to reduce their cloud spend in other cloud vendors such as GCP, Azure, etc. The goal here would be to make this microservice extensible for future Cloud providers and provide a unified product for customers that might have cloud infrastrucure in multiple cloud vendors.
- **Data Handling:** I would evaluate data ingestion and processing pipelines to handle larger datasets more efficiently.
- **Code linting:** I would add the Rubocop gem and enforce code linting to ensure there is a consistent format across the codebase.

## Scaling to Larger Datasets

If dealing with a dataset 100x larger:

- **Database Scaling:** Scale ClickHouse cluster horizontally to handle increased data volume and query load.
- **Partitioning:** Implement partitioning strategies within ClickHouse to manage data distribution and improve query performance.

## Meta Questions

1. **Time Taken:**
   - This project took approximately 6 hours to complete.
   - Breakdown of time:
     - Setting up Ruby environment and dependencies: 1 hour
     - Implementing models and controllers: 2 hours
     - Testing and debugging: 1.5 hours
     - Writing documentation (README and meta questions): 1.5 hours

2. **Experience with Ruby on Rails:**
   - I have extensive experience with Ruby on Rails from my time at Orbee Auto, where I managed microservices using event-driven architecture.
   - I regularly developed new features from scratch, focusing on business value and adhering to best practices like security, documentation, and testing.
   - I am proficient in using ActiveRecord for database interactions and have utilized testing frameworks like RSpec for ensuring code quality,  Rswag for documentation, and Rubocop for linting.

3. **Instructions Feedback:**
   - The instructions were clear overall.

## Screenshots
<div style="display: flex; flex-wrap: wrap; justify-content: space-around;">
  <div style="flex: 0 0 48%; margin: 1%;">
    <img src="https://github.com/gautam417/AWSBillingDiscountsService/blob/main/AWSDataTransfer.png?raw=true" alt="AWS Billing Data Transfer" style="width: 100%;">
  </div>
  <div style="flex: 0 0 48%; margin: 1%;">
    <img src="https://github.com/gautam417/AWSBillingDiscountsService/blob/main/AWSGlue.png?raw=true" alt="AWS Billing Glue" style="width: 100%;">
  </div>
  <div style="flex: 0 0 48%; margin: 1%;">
    <img src="https://github.com/gautam417/AWSBillingDiscountsService/blob/main/AmazonEC2.png?raw=true" alt="AWS Billing EC2" style="width: 100%;">
  </div>
  <div style="flex: 0 0 48%; margin: 1%;">
    <img src="https://github.com/gautam417/AWSBillingDiscountsService/blob/main/AmazonGuardDuty.png?raw=true" alt="AWS Billing GuardDuty" style="width: 100%;">
  </div>
  <div style="flex: 0 0 48%; margin: 1%;">
    <img src="https://github.com/gautam417/AWSBillingDiscountsService/blob/main/AmazonS3.png?raw=true" alt="AWS Billing S3" style="width: 100%;">
  </div>
</div>