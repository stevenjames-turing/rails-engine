<div id="top"></div>

# Rails Engine Lite

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#getting-started">Getting Started</a></li>
    <li><a href="#built-with">Built With</a></li>
    <li>
      <a href="#testing">Testing</a>
      <ul>
        <li><a href="#rspec-test-results">RSpec Test Results</a></li>
        <li><a href="#postman-test-results">Postman Test Results</a></li>
      </ul>
    </li>
    <li><a href="#database-design">Database Design</a></li>
  </ol>
</details>

## About The Project

- Rails Engine Lite is an E-Commerce Application. It's designed to mimic a service-oriented architecture where the front and back ends of the app communicate via APIs. This project exposes the data of Merchants and Items in the DB. 
- This is the Solo Project in Mod 3 of Turing's Back-End Program (2111 BE Cohort)
- [Turing Project Page](https://backend.turing.edu/module3/projects/rails_engine_lite/)
<p align="right">(<a href="#top">back to top</a>)</p>

## Getting Started

1. Fork and Clone the repo: [GitHub - stevenjames-turing/rails-engine](https://github.com/stevenjames-turing/rails-engine)
2. Install gem packages: `bundle install`
3. Setup the database: `rails db:{create,migrate,seed}`
4. Get the Schema: `rails db:schema:dump`
<p align="right">(<a href="#top">back to top</a>)</p>

## Built With:

- Framework: Ruby on Rails
- Database: PostgreSQL
- Versions
  - Ruby: 2.7.4
  - Rails: 5.2.6
<p align="right">(<a href="#top">back to top</a>)</p>

## Testing:

  - This project has a test suite through Postman. 
    - Download the test suites here: 
      - [Rails Engine, Section 1 Tests](https://backend.turing.edu/module3/projects/rails_engine_lite/RailsEngineSection1.postman_collection.json)
      - [Rails Engine, Section 2 Tests](https://backend.turing.edu/module3/projects/rails_engine_lite/RailsEngineSection2.postman_collection.json)
    - More instructions on using the Postman test suite are available at the [Turing Project Page](https://backend.turing.edu/module3/projects/rails_engine_lite/). 
  - This application is fully tested through RSpec. 
  - You can run RSpec on any directory/file using `bundle exec rspec <directory/file>`
  - SimpleCov is included to ensure tests have full coverage.
  - To run the Simplecov report type the following into your terminal: open coverage/index.html
  - See details here: [SimpleCov](https://github.com/simplecov-ruby/simplecov)
  
  ### RSpec Test Results

  ![Test Results](https://user-images.githubusercontent.com/91357724/161151501-748c3870-c1fa-40b2-b01a-b507e1e2a3ac.png)
  
  ### Postman Test Results 
  
  ![Postman Test Results - Part 1](https://user-images.githubusercontent.com/91357724/161151837-2da73693-c3e0-496b-96a1-03eddd91b09e.png)
  ![Postman Test Results - Part 2](https://user-images.githubusercontent.com/91357724/161151851-bded8a9c-ade3-4ada-8b21-ad9a241168dd.png)
  

<p align="right">(<a href="#top">back to top</a>)</p>

## Database Design

![Rails Engine DB](https://user-images.githubusercontent.com/91357724/161107763-9a2af099-b49d-4ade-ae2e-8298c898b4d4.png)
<p align="right">(<a href="#top">back to top</a>)</p>

### Author
   -[Steven James](https://github.com/stevenjames-turing)<br>
<p align="right">(<a href="#top">back to top</a>)</p>
