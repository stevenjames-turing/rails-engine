# Rails Engine Lite

### Table of Contents

- About The Project
- Getting Started
- Built With
- Testing

## About The Project

- Rails Engine Lite is an E-Commerce Application. It's designed to mimic a service-oriented architecture where the front and back ends of the app communicate via APIs. This project exposes the data of Merchants and Items in the DB. 
- Utilized API consumption from [The MovieDB](https://www.themoviedb.org/)
- This is the Solo Project in Mod 3 of Turing's Back-End Program (2111 BE Cohort)
- [Turing Project Page](https://backend.turing.edu/module3/projects/rails_engine_lite/)

## Getting Started

1. Fork and Clone the repo: [GitHub - stevenjames-turing/rails-engine](https://github.com/stevenjames-turing/rails-engine)
2. Install gem packages: `bundle install`
3. Setup the database: `rails db:{create,migrate,seed}`
4. Get the Schema: `rails db:schema:dump`

## Built With:

- Framework: Ruby on Rails
- Database: PostgreSQL
- Versions
  - Ruby: 2.7.4
  - Rails: 5.2.6

## Testing:

  - This project has a test suite through Postman. 
    - Download the test suites here: 
      - [Rails Engine, Section 1 Tests](https://backend.turing.edu/module3/projects/rails_engine_lite/RailsEngineSection1.postman_collection.json)
      - [Rails Engine, Section 2 Tests](https://backend.turing.edu/module3/projects/rails_engine_lite/RailsEngineSection2.postman_collection.json)
    - More instructions on using the Postman test suite are available at the Turing project page linked above. 
  - All Features and Models are fully tested using RSpec. 
  - You can run RSpec on any directory/file using `bundle exec rspec <directory/file>`
  - SimpleCov is included to ensure tests have full coverage.
  - To run the Simplecov report type the following into your terminal: open coverage/index.html
  - See details here: [SimpleCov](https://github.com/simplecov-ruby/simplecov)

### Author
   -[Steven James](https://github.com/stevenjames-turing)<br>
